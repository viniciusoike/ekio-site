# Adapting the restateinsight archive → EKIO Insights

Source archive: `~/GitHub/restateinsight/posts/general-posts/` (119 posts).
Goal: bring the on-brand (real estate / spatial / economics) posts into
`insights/posts/` and route R tutorials to `ekio-academy`.

## Authoring a NEW post (the scalable path — no archive rewrite)

The blog uses Quarto's **native listing** (`insights/index.qmd` + `arquivo.qmd`
over `contents: posts`). A new post auto-appears in both — you never edit a listing.

1. Copy `insights/posts/_TEMPLATE.qmd` into `insights/posts/YYYY-MM-slug/index.qmd`.
2. Fill title / date / description / categories / image. `author`, `freeze`, TOC,
   article layout, and `execute` (echo/warning/message off) are inherited from
   `insights/posts/_metadata.yml` + `_quarto.yml` — don't repeat them.
3. Put the card thumbnail in `static/images/thumbnails/` (or omit `image:` to get a
   branded gradient card). Exactly one post may set `featured: "true"` (the hero).
4. `quarto render`, then remove `draft: true`.

The archive migration below is a one-time cost; new native posts are just step 1–4.

## Per-post recipe (adapting an ARCHIVE post)

1. **Copy** `restateinsight/posts/general-posts/<slug>/` → `insights/posts/<slug>/`.
2. **Fix data access** (the main blocker — most posts are NOT portable):
   - Absolute/sibling-repo paths (`/Users/.../shiny-atlas-brasil/...`, `qs::qread`,
     `here::here("static/data/...")`) → vendor the referenced file *into the post
     directory* and reference it by bare filename (knitr's working dir is the
     `.qmd`'s own directory). Verify on render.
   - Remove any chunk that **writes** files outside the post (e.g. `ggsave(here::here("static/images/thumbnails/..."))`) — instead vendor the pre-rendered thumbnail into `static/images/thumbnails/` and use it as `image:`.
   - Cross-post `/_site/.../figure-html/*.png` embeds → break; re-point or drop.
3. **Frontmatter** — normalize to EKIO conventions:
   - `author: "Vinicius Oike Reginatto"`
   - `categories:` → Title-Case PT taxonomy: **São Paulo, Mapas, Imóveis,
     Análise Espacial, Economia, Demografia, Censo, Visualização de Dados**
     (drop lowercase tags like `ggplot2`, `data-visualization`).
   - `image:` → local thumbnail under `/static/images/thumbnails/`.
   - add `freeze: true`; keep `execute: {echo:false, warning:false, message:false}`.
   - set `draft: true` until rendered & verified, then flip to `false`.
4. **Charts stay as-is** (Playfair/Raleway fonts, Spectral/YlGnBu/Reds palettes) —
   matches the precedent of the 6 already-live posts. (Optional later pass:
   re-theme to `ekioplot::theme_ekio()` for true brand consistency.)
5. **Translate** EN posts to PT (site is pt-BR). Give `title: "index"` posts a real title.
6. **Render** locally (`quarto render`) — needs the author's data + packages — then
   flip `draft: false`.

Skip anything that duplicates a live post: `indices-precos-imobiliarios`,
`recessoes-brasil`, `renda-sp` are already published.

## Triage

### Batch 1 — Insights, on-brand
- [x] `2024-03-affordability-sp` — "Housing Affordability em São Paulo" (PIR map). DONE (draft) — vendored geojson + thumbnail; render to verify.
- [x] `2024-02-wz-sp-idh-atlas` — "IDH por região em São Paulo". DONE (draft) — 39 MB `.qs` subset to SP-city-2010 → vendored 2.6 MB `atlas_sp_idh_2010.rds`; Raleway→Lato; no thumbnail yet (uses gradient fallback).
- [ ] `2023-10-wz-metro-sp` — Metrô de São Paulo. Vendor station CSVs (`metro_sp.csv`, `metro_sp_line_4_stations.csv`); **body is in English → translate to PT**; rename off "Weekly Viz".
- [ ] `2025-07-demografia-brasil` — "O Novo Perfil Demográfico do Brasil". Heavier: 19 MB `files.rds` + cross-post PNG embeds to resolve.

**NOT importable (verify each archive slug before picking — many recent ones are stubs):**
- `2025-02-spo-mapa-renda` — stub: `draft:true`, loads data, no chart/prose.
- `2025-12-density-sao-paulo` — no `index.qmd` (only `draft.R`), unfinished.

### Also on-brand (later)
`2024-04-sp-grid-houses` (writes svg to static — fix), `2025-03-homeownership-brazil`
(title "index", messy H1, EN?), `2023-11-preco-imoveis-brasil` (EN, near-dup),
`repost-precos-imoveis-demografia`, `2023-08-juros-affordability`,
`2024-05-generations-brazil`, `2024-12-demographic-pyramid`, `2023-12-wz-inflation`,
`repost-ipca-visualizacao`, `2025-11-pop-density`, `2025-06-censo-metro-regions`,
`2024-07-viz-metro-4`, `2024-09-viz-metro-line-5`, `2026-01-line-{2,4,5}-metro`.

### Route to ekio-academy (tutorials/methods — NOT Insights)
tutorial-tidyverse/*, `pipes-in-r`, `comandos-simples`, `2024-02-gradient-descent`,
`2024-02-media-movel`, `2024-01-sazonalidade`, `2024-02-hamilton-trend`,
`2024-03-carry-over`, `2025-07-modelo-arima`, `repost-{arima,sarima,arma,ols-*,emv,otimizacao,regressao,mqo,teoria-assintotica}`,
`2024-04-radar-plots`, `2024-04-plots-sacrilegio`, `2024-12-punchcard-plot`,
`2024-12-github-contributions-plot`, `2024-09-basemaps-ggplot2`,
`2026-06-packages-custom-fonts`, `2026-06-claudeplot`, `repost-tutorial-showtext`,
`2025-07-fixing-bad-charts`, `2024-12-replicating-nexo-plot`, `2023-11-replicating-plots`,
`2023-12-bump-plots`, coffee/starbucks scrape demos.

### Skip (personal / off-brand)
`2023-09-happiness`, `2023-09-uruguay-numbers`, `2024-04-best-movies-bias`,
`2023-09-brasilia`, `2023-08-recife`, `2025-01-top-posts-2024`, `2025-05-chart-challenge`,
`2023-08-firjan-app`.
