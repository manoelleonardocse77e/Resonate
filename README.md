# 🎵 Resonate

**Aplicativo mobile de catalogação, avaliação e compartilhamento social de álbuns musicais.**

Resonate é proposto como o "Letterboxd dos álbuns musicais": uma plataforma que une um catálogo musical robusto, recursos de crítica (notas e reviews) e uma camada social orientada à comunidade de ouvintes — sem depender de licenciamento de conteúdo musical.

> Trabalho de Conclusão de Curso (disciplina de Desenvolvimento Mobile, 7º período de Ciência da Computação) — Centro Universitário Tiradentes, Recife - PE, 2026.

---

## 📖 Sobre o projeto

O mercado fonográfico produz um volume colossal de obras musicais — o streaming de música já representa a maior parte da receita do setor. Apesar disso, não existe no nicho musical uma aplicação equivalente ao Letterboxd (cinema) ou ao Goodreads (livros): uma plataforma que combine catálogo robusto, crítica social e organização pessoal de conteúdo.

O Resonate propõe preencher essa lacuna integrando três APIs públicas de dados musicais para compor um catálogo sem dependência de licenciamento:

- **[MusicBrainz](https://musicbrainz.org/doc/MusicBrainz_API)** — metadados, tracklist, créditos e identificadores de lançamentos.
- **[Cover Art Archive](https://coverartarchive.org)** — capas de álbuns.
- **[Last.fm](https://www.last.fm/api)** — estatísticas de popularidade e imagens de artistas.

Sobre essas fontes externas, o Resonate constrói uma camada social própria: reviews, listas, playlists, perfis e notificações.

### Objetivo geral

Projetar e especificar o sistema Resonate, integrando as APIs públicas do MusicBrainz, Last.fm e Cover Art Archive como fontes primárias de dados musicais.

### Objetivos específicos

- Analisar as capacidades e limitações das APIs para determinar quais funcionalidades são viáveis sem licenciamento adicional.
- Modelar os requisitos funcionais e não funcionais do sistema por meio de casos de uso em notação UML.
- Definir a arquitetura do sistema, incluindo front-end mobile, banco de dados relacional e backend próprio.
- Especificar o modelo de dados das entidades sociais (usuários, reviews, follows, playlists e notificações).
- Elaborar o protótipo de telas, evidenciando a experiência do usuário em ambiente mobile.

---

## ✨ Funcionalidades

| ID | Funcionalidade | Descrição |
| --- | --- | --- |
| RF-01 | Busca de conteúdo | Busca de álbuns por título, artista, gravadora e ano de lançamento. |
| RF-02 | Exibição de álbuns | Página de álbum com capa, tracklist, créditos, gêneros, idioma, país e popularidade. |
| RF-03 | Criação de avaliação | Usuário autenticado registra avaliação com nota obrigatória e texto opcional. |
| RF-04 | Exibição de avaliações | Reviews populares e recentes exibidas na página de cada álbum. |
| RF-05 | Interação entre usuários | Usuários podem se seguir mutuamente. |
| RF-06 | Feed social | Feed com reviews recentes dos usuários seguidos. |
| RF-07 | Notificações | Notificações de novos seguidores, curtidas e reviews de amigos. |
| RF-08 | Listas | Criação, edição e exclusão de listas de álbuns. |
| RF-09 | Exibição de perfil | Estatísticas de avaliações, playlists, seguidores e distribuição de notas. |
| RF-10 | Gerenciamento de playlist | Adição de álbuns à playlist pessoal de "próximos a escutar". |

### Atores do sistema

- **Usuário autenticado** — ator central da plataforma; pesquisa álbuns, cria listas, organiza playlist, faz reviews, segue outros usuários e recebe notificações.
- **Usuário visitante** — acesso não autenticado; pode visualizar páginas públicas de álbuns, artistas e perfis, mas não interagir.

### Principais casos de uso

1. **Pesquisar e visualizar álbum** — busca via MusicBrainz, com dados combinados de capa (Cover Art Archive), popularidade (Last.fm) e reviews (backend próprio).
2. **Criar review de álbum** — nota de 0,5 a 5,0 estrelas (incrementos de 0,5) e texto opcional, vinculada ao MBID do álbum.
3. **Gerenciar listas** — listas públicas ou privadas, com título e descrição, exibidas no perfil.
4. **Adicionar à playlist** — organização pessoal e privada de álbuns que o usuário pretende escutar.

---

## 🧩 Requisitos não funcionais

- Tempo de resposta da página de álbum inferior a 3 segundos em conexão 4G.
- Disponibilidade mínima do backend próprio de 99,5% ao mês.
- Escalabilidade horizontal via containers.
- Senhas armazenadas com hash **bcrypt**.
- Cache de dados externos no **Redis**, com TTL definido por tipo de dado.
- Compatibilidade com Android 8.0 ou superior.
- Rate limiting nas rotas da API para mitigar abuso e ataques de negação de serviço.

---

## 🏗️ Arquitetura

O sistema é estruturado em três camadas principais:

1. **Frontend mobile** — aplicativo executado no dispositivo do usuário.
2. **Backend próprio** — API REST responsável pelos dados sociais da plataforma (usuários, reviews, listas, playlists, notificações).
3. **APIs externas de dados musicais** — MusicBrainz, Cover Art Archive e Last.fm.

O princípio estruturante da arquitetura é a separação entre **dados musicais** (provenientes de fontes externas abertas) e **dados sociais** (persistidos e gerenciados pelo backend próprio). O Redis atua como camada intermediária de cache, reduzindo requisições às APIs externas e contornando o limite de uma requisição por segundo imposto pelo MusicBrainz.

### Modelo de dados (visão geral)

- **Usuário** — entidade central; relaciona-se com Review e Lista; mantém playlist de próximos álbuns, seguidores e seguidos.
- **Álbum** — eixo do catálogo musical; referenciado por Review, Lista e Música; metadados vindos do MusicBrainz e Cover Art Archive.
- **Review** — avaliação (nota + texto) de um usuário sobre um álbum.
- **Lista** / **Lista_Álbum** — agrupamento de álbuns definido pelo usuário (entidade associativa).
- **Música** — faixas de um álbum; conecta-se a **Artista** via **Crédito** (cobrindo artistas, produtores e equipe).

---

## 🛠️ Tecnologias

| Camada | Tecnologia | Por quê |
| --- | --- | --- |
| Mobile | **Flutter** | Framework open source da Google; renderiza cada pixel diretamente, garantindo aparência consistente entre dispositivos; compila Dart para código nativo, evitando a ponte JavaScript-nativo usada por outros frameworks. |
| Backend e dados | **Supabase** | BaaS sobre PostgreSQL; sincronização em tempo real via WebSockets; gerenciamento eficiente de relações complexas entre usuários, álbuns e avaliações; autenticação e segurança nativas. |
| Cache | **Redis + redis-py** | Armazenamento em memória das respostas de APIs externas, reduzindo latência; suporte a TTL por chave para expiração automática do cache. |
| Dados musicais externos | **MusicBrainz**, **Cover Art Archive**, **Last.fm** | Catálogo musical robusto e gratuito, sem dependência de licenciamento de conteúdo. |

---

## 📌 Limitações conhecidas

- Cobertura incompleta de capas de álbuns na Cover Art Archive.
- Ausência de dados de streaming ou preview de áudio nas APIs escolhidas.
- Dependência da disponibilidade dos serviços externos para o funcionamento pleno do catálogo.

## 🔮 Direções futuras

- Algoritmo de recomendação baseado no histórico de avaliações do usuário.
- Notificações push nativas.
- Importação de histórico de plataformas como Last.fm e Spotify.

---

## 👥 Autores

- Manoel Leonardo Carneiro Sette Serrano
- Rafael Souza Gomes Lins

**Orientador:** Prof. Petros Barreto Silva

Centro Universitário Tiradentes — Ciência da Computação, Recife - PE, 2026.

---

## 📚 Referências

- COVER ART ARCHIVE. *Cover Art Archive API Documentation*. Disponível em: https://coverartarchive.org. Acesso em: abr. 2026.
- SUPABASE. *Supabase Docs*. Disponível em: https://supabase.com/docs. Acesso em: abr. 2026.
- FLUTTER. *Flutter Documentation*. Google LLC, 2024. Disponível em: https://docs.flutter.dev. Acesso em: abr. 2026.
- IFPI — INTERNATIONAL FEDERATION OF THE PHONOGRAPHIC INDUSTRY. *Global Music Report 2022*. Londres: IFPI, 2022.
- LAST.FM. *Last.fm API Documentation*. Londres: Audioscrobbler, 2024. Disponível em: https://www.last.fm/api. Acesso em: abr. 2026.
- LETTERBOXD. *Letterboxd — Social film discovery*. Disponível em: https://letterboxd.com. Acesso em: abr. 2026.
- MUSICBRAINZ. *MusicBrainz API Documentation*. San Francisco: MetaBrainz Foundation, 2024. Disponível em: https://musicbrainz.org/doc/MusicBrainz_API. Acesso em: abr. 2026.
- REDIS. *Redis Documentation*. Redis Ltd., 2024. Disponível em: https://redis.io/docs. Acesso em: abr. 2026.
- REDIS-PY. *redis-py — Python client for Redis*. Disponível em: https://pypi.org/project/redis. Acesso em: abr. 2026.
