// supabase/functions/search-albums/index.ts
// Edge Function — busca álbuns no MusicBrainz com:
//   - Capa: Cover Art Archive (primário) → iTunes (fallback)
//   - Gêneros: MusicBrainz + iTunes
//   - Foto do artista: Wikimedia/Wikidata
//
// Deploy: supabase functions deploy search-albums
// Sem API keys externas necessárias — todas as fontes são públicas e gratuitas.

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.4.0";

// ─── Tipos ────────────────────────────────────────────────────────────────────

interface SearchParams {
  titulo?: string;
  artista?: string;
  gravadora?: string;
  ano?: string;
}

interface AlbumResult {
  album_mbid: string;
  titulo: string;
  cover_url: string | null;
  lancamento: string | null;
  gravadora: string | null;
  generos: string[];
  pais: string | null;
  idioma: string | null;
  artista_mbid: string;
  artista_nome: string;
  artista_foto: string | null;
  nota_media: number | null;
  total_reviews: number;
}

// ─── CORS ─────────────────────────────────────────────────────────────────────

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

// ─── MusicBrainz ──────────────────────────────────────────────────────────────

const MB_BASE = "https://musicbrainz.org/ws/2";
const MB_HEADERS = {
  "User-Agent": "AlbumRatingApp/1.0 (manoel.sette@souunit.com.br)",
  "Accept": "application/json",
};

async function buscarAlbunsMusicBrainz(params: SearchParams) {
  const partes: string[] = [];
  if (params.titulo)    partes.push(`release:${params.titulo}`);
  if (params.artista)   partes.push(`artist:${params.artista}`);
  if (params.gravadora) partes.push(`label:${params.gravadora}`);
  if (params.ano)       partes.push(`date:${params.ano}`);

  const query = encodeURIComponent(partes.join(" AND "));
  const url = `${MB_BASE}/release-group?query=${query}&type=album&limit=20&fmt=json`;

  const resp = await fetch(url, { headers: MB_HEADERS });
  if (!resp.ok) throw new Error(`MusicBrainz error: ${resp.status}`);
  const data = await resp.json();
  return data["release-groups"] ?? [];
}

async function detalharAlbumMusicBrainz(mbid: string) {
  const url = `${MB_BASE}/release-group/${mbid}?inc=artists+releases+genres&fmt=json`;
  const resp = await fetch(url, { headers: MB_HEADERS });
  if (!resp.ok) throw new Error(`MusicBrainz detail error: ${resp.status}`);
  return resp.json();
}

// ─── Cover Art Archive ────────────────────────────────────────────────────────
// FIX: usa resp.url após redirect para obter a URL real da imagem no S3

async function buscarCapaCoverArt(releaseMbid: string): Promise<string | null> {
  try {
    const url = `https://coverartarchive.org/release/${releaseMbid}/front-500`;
    const resp = await fetch(url, { redirect: "follow" });
    if (!resp.ok) return null;
    return resp.url; // URL final após redirect (aponta para archive.org/S3)
  } catch {
    return null;
  }
}

// ─── iTunes Search API (fallback de capa + gêneros) ──────────────────────────

async function buscarCapaETagsITunes(
  artista: string,
  album: string
): Promise<{ capa: string | null; tags: string[] }> {
  try {
    const url =
      `https://itunes.apple.com/search?term=${encodeURIComponent(
        `${artista} ${album}`
      )}&entity=album&limit=1&country=us`;

    const resp = await fetch(url);
    if (!resp.ok) return { capa: null, tags: [] };

    const data = await resp.json();
    const item = data.results?.[0];
    if (!item) return { capa: null, tags: [] };

    // Troca resolução 100x100 por 600x600 para melhor qualidade
    const capa =
      item.artworkUrl100?.replace("100x100bb", "600x600bb") ??
      item.artworkUrl100 ??
      null;

    const tags = item.primaryGenreName ? [item.primaryGenreName] : [];
    return { capa, tags };
  } catch {
    return { capa: null, tags: [] };
  }
}

// ─── Foto do artista via Wikimedia/Wikidata ───────────────────────────────────

async function buscarFotoArtistWikimedia(artistaMbid: string): Promise<string | null> {
  try {
    // 1. Busca relações do artista no MusicBrainz para encontrar Wikidata/Wikipedia
    const url = `${MB_BASE}/artist/${artistaMbid}?inc=url-rels&fmt=json`;
    const resp = await fetch(url, { headers: MB_HEADERS });
    if (!resp.ok) return null;

    const data = await resp.json();
    const relations = data.relations ?? [];

    const wikidataRel = relations.find(
      (r: { type?: string; url?: { resource?: string } }) =>
        r.type === "wikidata" && r.url?.resource
    );
    const wikipediaRel = relations.find(
      (r: { type?: string; url?: { resource?: string } }) =>
        r.type === "wikipedia" && r.url?.resource
    );

    // 2a. Tenta via Wikidata (mais confiável — usa propriedade P18 = imagem)
    async function fetchWikidataImage(qid: string): Promise<string | null> {
      const wdUrl = `https://www.wikidata.org/wiki/Special:EntityData/${qid}.json`;
      const wdResp = await fetch(wdUrl);
      if (!wdResp.ok) return null;

      const wdData = await wdResp.json();
      const claims = wdData.entities?.[qid]?.claims ?? {};
      const p18 = claims.P18?.[0]?.mainsnak?.datavalue?.value;
      if (!p18) return null;

      // Busca URL real da imagem no Wikimedia Commons
      const commonsUrl =
        `https://commons.wikimedia.org/w/api.php?action=query&titles=File:${encodeURIComponent(
          p18
        )}&prop=imageinfo&iiprop=url&format=json&origin=*`;
      const commonsResp = await fetch(commonsUrl);
      if (!commonsResp.ok) return null;

      const commonsData = await commonsResp.json();
      const page = Object.values(commonsData.query?.pages ?? {})[0] as {
        imageinfo?: { url: string }[];
      };
      return page?.imageinfo?.[0]?.url ?? null;
    }

    // 2b. Fallback via Wikipedia (thumbnail da página)
    async function fetchWikipediaImage(pageUrl: string): Promise<string | null> {
      const title = pageUrl.split("/wiki/").pop();
      if (!title) return null;

      const wikiUrl =
        `https://en.wikipedia.org/w/api.php?action=query&titles=${encodeURIComponent(
          title
        )}&prop=pageimages&piprop=thumbnail&pithumbsize=500&format=json&origin=*`;
      const wikiResp = await fetch(wikiUrl);
      if (!wikiResp.ok) return null;

      const wikiData = await wikiResp.json();
      const page = Object.values(wikiData.query?.pages ?? {})[0] as {
        thumbnail?: { source: string };
      };
      return page?.thumbnail?.source ?? null;
    }

    // Tenta Wikidata primeiro, depois Wikipedia
    if (wikidataRel?.url?.resource) {
      const qidMatch = wikidataRel.url.resource.match(/\/wiki\/(Q\d+)$/);
      if (qidMatch) {
        const image = await fetchWikidataImage(qidMatch[1]);
        if (image) return image;
      }
    }

    if (wikipediaRel?.url?.resource) {
      return fetchWikipediaImage(wikipediaRel.url.resource);
    }

    return null;
  } catch {
    return null;
  }
}

// ─── Tracklist ────────────────────────────────────────────────────────────────

async function buscarTracklist(releaseMbid: string) {
  const url = `${MB_BASE}/release/${releaseMbid}?inc=recordings+artist-credits&fmt=json`;
  const resp = await fetch(url, { headers: MB_HEADERS });
  if (!resp.ok) return [];
  const data = await resp.json();

  const tracks: {
    musica_mbid: string;
    nome: string;
    posicao: number;
    duracao_ms: number | null;
    creditos: { artista_mbid: string; nome: string; papel: string }[];
  }[] = [];

  for (const medio of data.media ?? []) {
    for (const track of medio.tracks ?? []) {
      const recording = track.recording;
      const creditos = (recording["artist-credit"] ?? [])
        .filter((ac: { artist?: { id: string; name: string } }) => ac.artist)
        .map(
          (ac: { artist: { id: string; name: string } }) => ({
            artista_mbid: ac.artist.id,
            nome: ac.artist.name,
            papel: "performer",
          })
        );

      tracks.push({
        musica_mbid: recording.id,
        nome: track.title ?? recording.title,
        posicao: track.position,
        duracao_ms: recording.length ?? null,
        creditos,
      });
    }
  }

  return tracks;
}

// ─── Upsert no Supabase ───────────────────────────────────────────────────────

async function salvarAlbumNoSupabase(
  supabase: ReturnType<typeof createClient>,
  albumMB: Record<string, unknown>,
  artistaMbid: string,
  artistaNome: string,
  coverUrl: string | null,
  extraGeneros: string[],
  artistaFoto: string | null
) {
  // 1. Artista
  await supabase.from("artista").upsert(
    { artista_mbid: artistaMbid, nome: artistaNome, foto_url: artistaFoto },
    { onConflict: "artista_mbid", ignoreDuplicates: false }
  );

  // 2. Álbum
  const releases =
    (albumMB.releases as {
      id: string;
      date?: string;
      "label-info"?: { label?: { name?: string } }[];
      country?: string;
      "text-representation"?: { language?: string };
    }[]) ?? [];
  const primeiroRelease = releases[0] ?? {};
  const gravadora = primeiroRelease["label-info"]?.[0]?.label?.name ?? null;
  const pais      = primeiroRelease.country ?? null;
  const idioma    = primeiroRelease["text-representation"]?.language ?? null;
  const generosMB = ((albumMB.genres ?? albumMB.tags) as { name: string }[] ?? []).map(
    (g) => g.name
  );
  const generos = [...new Set([...generosMB, ...extraGeneros])].slice(0, 10);

  await supabase.from("album").upsert(
    {
      album_mbid: albumMB.id as string,
      titulo: albumMB.title as string,
      gravadora,
      lancamento:
        (albumMB["first-release-date"] as string | undefined) ??
        primeiroRelease.date ??
        null,
      cover_url: coverUrl,
      generos,
      pais,
      idioma,
      artista_mbid: artistaMbid,
    },
    { onConflict: "album_mbid", ignoreDuplicates: false }
  );

  // 3. Tracklist
  if (primeiroRelease.id) {
    await new Promise((r) => setTimeout(r, 1100)); // rate limit MusicBrainz
    const tracks = await buscarTracklist(primeiroRelease.id);

    for (const track of tracks) {
      for (const credito of track.creditos) {
        await supabase.from("artista").upsert(
          { artista_mbid: credito.artista_mbid, nome: credito.nome },
          { onConflict: "artista_mbid", ignoreDuplicates: true }
        );
      }

      await supabase.from("musica").upsert(
        {
          musica_mbid: track.musica_mbid,
          album_mbid: albumMB.id as string,
          nome: track.nome,
          posicao: track.posicao,
          duracao_ms: track.duracao_ms,
        },
        { onConflict: "musica_mbid", ignoreDuplicates: false }
      );

      for (const credito of track.creditos) {
        await supabase.from("credito").upsert(
          {
            musica_mbid: track.musica_mbid,
            artista_mbid: credito.artista_mbid,
            papel: credito.papel,
          },
          { onConflict: "musica_mbid,artista_mbid,papel", ignoreDuplicates: true }
        );
      }
    }
  }
}

// ─── Handler principal ────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const params: SearchParams = await req.json();

    if (!params.titulo && !params.artista && !params.gravadora && !params.ano) {
      return new Response(
        JSON.stringify({ error: "Informe ao menos um critério de busca." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 1. Cache no Supabase ───────────────────────────────────────────────
    const { data: cache } = await supabase.rpc("buscar_albuns", {
      p_titulo:    params.titulo    ?? null,
      p_artista:   params.artista   ?? null,
      p_gravadora: params.gravadora ?? null,
      p_ano:       params.ano       ?? null,
    });

    if (cache && cache.length > 0) {
      return new Response(
        JSON.stringify({ source: "cache", results: cache }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 2. MusicBrainz ────────────────────────────────────────────────────
    const releaseGroups = await buscarAlbunsMusicBrainz(params);

    if (releaseGroups.length === 0) {
      return new Response(
        JSON.stringify({ source: "api", results: [] }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 3. Detalha, complementa e salva cada álbum ────────────────────────
    const resultados: AlbumResult[] = [];

    for (const rg of releaseGroups.slice(0, 10)) {
      try {
        await new Promise((r) => setTimeout(r, 1100)); // rate limit
        const detalhe = await detalharAlbumMusicBrainz(rg.id);

        const artistaCredits = detalhe["artist-credit"] ?? [];
        const artistaMbid    = artistaCredits[0]?.artist?.id   ?? rg.id;
        const artistaNome    = artistaCredits[0]?.artist?.name ?? "Desconhecido";
        const primeiroRelease = detalhe.releases?.[0] ?? {};

        // Busca capa, iTunes e foto do artista em paralelo
        const [coverArtUrl, itunesData, artistaFoto] = await Promise.all([
          primeiroRelease.id
            ? buscarCapaCoverArt(primeiroRelease.id)
            : Promise.resolve<string | null>(null),
          buscarCapaETagsITunes(artistaNome, detalhe.title),
          buscarFotoArtistWikimedia(artistaMbid),
        ]);

        // Cover Art Archive tem prioridade; iTunes é fallback
        const coverUrl = coverArtUrl ?? itunesData.capa ?? null;

        const combinedGeneros = [
          ...(detalhe.genres ?? detalhe.tags ?? []).map(
            (g: { name: string }) => g.name
          ),
          ...itunesData.tags,
        ];

        await salvarAlbumNoSupabase(
          supabase,
          detalhe,
          artistaMbid,
          artistaNome,
          coverUrl,
          combinedGeneros,
          artistaFoto
        );

        resultados.push({
          album_mbid:   detalhe.id,
          titulo:       detalhe.title,
          cover_url:    coverUrl,
          lancamento:   detalhe["first-release-date"] ?? null,
          gravadora:    primeiroRelease["label-info"]?.[0]?.label?.name ?? null,
          generos:      combinedGeneros.slice(0, 10),
          pais:         primeiroRelease.country ?? null,
          idioma:       primeiroRelease["text-representation"]?.language ?? null,
          artista_mbid: artistaMbid,
          artista_nome: artistaNome,
          artista_foto: artistaFoto,
          nota_media:   null,
          total_reviews: 0,
        });
      } catch (err) {
        console.error(`Erro ao processar álbum ${rg.id}:`, err);
      }
    }

    return new Response(
      JSON.stringify({ source: "api", results: resultados }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("Erro na Edge Function:", err);
    return new Response(
      JSON.stringify({ error: "Erro interno na busca de álbuns." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});