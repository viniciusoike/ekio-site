# Adapting the restateinsight archive → EKIO Insights

Source archive: `~/GitHub/restateinsight/posts/general-posts/` (122 folders: 119 with `index.qmd`, 3 without).
Inventory refreshed on 2026-09-09 against the local archive and current `main`.
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
3. **Frontmatter** — follow `insights/posts/_TEMPLATE.qmd` and shared defaults in
   `insights/posts/_metadata.yml`; do not duplicate inherited author, freeze or
   execution settings. Use Portuguese categories consistent with current posts,
   a local cover with `image-alt`, and `draft: true` until verification.
4. **Charts and tables** — follow the current site helpers in
   `insights/posts/_ekio-style.R` and current EKIO posts. Older migrations used
   archive styling; that is historical context, not the default for new adaptations.
5. **Editorial review** — translate EN posts to PT, replace placeholder titles,
   check overlap with existing Insights, and verify dates, definitions and claims.
6. **Render and verify** the post, figures, tables, links and responsive layout;
   then remove `draft: true`. Do not publish an unverified adaptation.

## Inventory status

Every source folder is listed once below. This is a local inventory, not a check
of the deployed website. **Adapted** means an EKIO source exists without
`draft: true`; **EKIO draft** means an adaptation exists but remains a draft.
For unadapted entries, routing is provisional until the body, data and dependencies
are reviewed. A source draft is not automatically unusable, but needs extra review.
Tutorials outside `general-posts/` (including `tutorial-tidyverse/`) also belong in
`ekio-academy` and are outside the 122-folder count.

## Already adapted / EKIO drafts (13)

| Source folder | Source title | Status / next step |
|---|---|---|
| `2023-08-juros-affordability` | O impacto dos juros na demanda imobiliário | EKIO draft → [EKIO source](posts/2023-08-juros-financiamento/index.qmd). |
| `2023-12-wz-inflation` | Weekly Viz: Brazilian Inflation | Adapted → [EKIO source](posts/2023-12-inflacao-brasil/index.qmd). |
| `2024-01-wz-house-prices` | Preços de Imóveis no Brasil | EKIO draft → [EKIO source](posts/2024-01-precos-imoveis/index.qmd). |
| `2024-02-house-prices-br` | Índices de Preços Imobiliários no Brasil | Adapted → [EKIO source](posts/2024-02-indices-precos-imobiliarios/index.qmd). |
| `2024-02-wz-rent-house` | Preços de Aluguel e de Venda de Imóveis | EKIO draft → [EKIO source](posts/2024-02-aluguel-venda-imoveis/index.qmd). |
| `2024-02-wz-sp-idh-atlas` | IDH por região em São Paulo | Adapted → [EKIO source](posts/2024-02-wz-sp-idh-atlas/index.qmd). |
| `2024-02-wz-sp-renda` | Distribuição de Renda em São Paulo | Adapted → [EKIO source](posts/2024-02-renda-sp/index.qmd). |
| `2024-03-affordability-sp` | Housing Affordability em São Paulo | EKIO draft → [EKIO source](posts/2024-03-affordability-sp/index.qmd). |
| `2024-03-censo-apartamentos` | Casas e Apartamentos | EKIO draft → [EKIO source](posts/2024-03-casas-apartamentos/index.qmd). |
| `2024-03-ciclos-economicos` | Recessões no Brasil | Adapted → [EKIO source](posts/2024-03-recessoes-brasil/index.qmd). |
| `2024-04-wz-age-index` | Índice de Envelhecimento no Brasil | Adapted → [EKIO source](posts/2024-04-envelhecimento-brasil/index.qmd). |
| `2024-05-generations-brazil` | Generations in Brazil | Adapted → [EKIO source](posts/2025-02-generations-brazil/index.qmd). |
| `2025-06-censo-metro-regions` | O crescimento das Regiões Metropolitanas Brasileiras | Adapted → [EKIO source](posts/2025-06-censo-metro-regions/index.qmd). Rates and boundaries audited; five tables, three charts and interactive map rebuilt. |


## Insights candidates — provisional (47)

| Source folder | Source title | Status / next step |
|---|---|---|
| `2023-09-ruas-porto-alegre` | Weekly Viz: Ruas de Porto Alegre | Review before adaptation. |
| `2023-09-wz-unemployment` | Brazil in Charts: Unemployment | Review before adaptation. |
| `2023-10-brazil-growth-context` | Crescimento do Brasil em contexto | Source `draft: true`.  |
| `2023-10-censo-erros` | Censo 2022: O que houve de errado? | Review before adaptation. |
| `2023-10-mapas-altitude` | Cidades Brasil | Review before adaptation. |
| `2023-10-nascimentos-brasil` | Nascimentos no Brasil | Review before adaptation. |
| `2023-10-unemployment` | Brazil: Unemployment | Review before adaptation. |
| `2023-10-wv-nascimentos-brasil` | Weekly Viz: Nascimentos no Brasil | Review before adaptation. |
| `2023-10-wz-census` | Weekly Viz - Brazilian Census | Review before adaptation. |
| `2023-10-wz-metro-sp` | Weekly Viz - Metro em São Paulo | Medium: station CSVs, translate English body, remove Weekly Viz framing. |
| `2023-10-wz-weddings` | Brazil in Charts: Weddings and Births | Source `draft: true`.  |
| `2023-11-preco-imoveis-brasil` | House Prices in Brazil: where is the Crisis? | Source `draft: true`. English source draft; near-duplicate of existing price analysis. |
| `2023-11-wz-cars` | Weekly Viz: Car Dependency in São Paulo | Review before adaptation. |
| `2023-11-wz-census-ages` | Envelhecimento no Brasil | Check overlap with adapted aging-index post. |
| `2023-11-wz-expectativa` | Expectativa de Vida em São Paulo | Review before adaptation. |
| `2023-11-wz-sp-carros` | Carros em São Paulo | Review before adaptation. |
| `2023-11-wz-sp-college` | Ensino Superior em São Paulo | Review before adaptation. |
| `2023-11-wz-temperatura` | Weekly Viz: Temperatura em Porto Alegre | Source `draft: true`.  |
| `2023-11-wz-transport` | Weekly Viz: Transportation in São Paulo | Review before adaptation. |
| `2023-12-carros-renda` | Carros e Renda em Sao Paulo | Review before adaptation. |
| `2023-12-wz-acesso-saude` | Acesso a Hospitais e Leitos em São Paulo | Review before adaptation. |
| `2024-02-affordability-mapa` | Acessibilidade financeira à moradia em São Paulo | Check overlap with adapted affordability post. |
| `2024-02-wz-energy` | Energia Elétrica e Crescimento Econômico no Brasil | Previously adapted under Dataviz, then removed from current main; review editorial fit before reintroducing. |
| `2024-03-maps-birth-deaths` | Nascimentos e Óbitos no Brasil | Review before adaptation. |
| `2024-03-wz-acidentes-carro` | Acidentes de Trânsito em São Paulo | Review before adaptation. |
| `2024-04-brazil-rates` | Demographic Trends in Brazil | Source `draft: true`.  |
| `2024-04-sp-grid-houses` | Domicilios em Sao Paulo | Remove writes to shared static SVG paths. |
| `2024-04-wz-pib-municipios` | GDP in Brazil | Review before adaptation. |
| `2024-04-wz-rdt-brasil` | Razão de Dependência no Brasil | Review before adaptation. |
| `2024-05-births-weddings` | Weddings and Births in Brazil | Source `draft: true`.  |
| `2024-05-illiterate-census` | Analfabetismo no Brasil | Review before adaptation. |
| `2024-07-viz-metro-4` | Linha-4 Amarela Metrô de São Paulo | Short visualization; compare with January 2026 version. |
| `2024-09-ips-brasil` | Índice de Progresso Social nos Municípios Brasileiros | Review before adaptation. |
| `2024-09-viz-metro-line-5` | Linha-5 Lilás Metrô de São Paulo | Short visualization; compare with January 2026 version. |
| `2025-03-homeownership-brazil` | index | Source `draft: true`. Short source draft with placeholder title; needs substantive development. |
| `2025-03-map-brazil-census-race` | A Distribuição Racial do Brasil | Review before adaptation. |
| `2025-07-demografia-brasil` | O Novo Perfil Demográfico do Brasil | Hard: 18 MiB `files.rds`, cross-post `/_site/` images, repeated sections, inverted aging-index formula and dependency-denominator review; overlaps two existing Insights. |
| `2025-11-pop-density` | Densidade populacional | Source `draft: true`. Short source draft; review completeness before selection. |
| `2026-01-line-2-metro` | Linha 2-Verde do Metrô de São Paulo | Review before adaptation. |
| `2026-01-line-4-metro` | Linha-4 Amarela Metrô de São Paulo | Source `draft: true`.  |
| `2026-01-line-5-metro` | Linha-5 Lilás Metrô de São Paulo | Source `draft: true`.  |
| `repost-aquecimento-global` | Aquecimento Global | Review before adaptation. |
| `repost-crescimento-pib-mundo` | Crescimento do PIB per capita no mundo | Review before adaptation. |
| `repost-gapminder` | Repost: Expectativa de vida e Crescimento Econômico | Review before adaptation. |
| `repost-ipca-visualizacao` | Visualizando o IPCA | Review before adaptation. |
| `repost-precos-imoveis-demografia` | Preços de Imóveis e Demografia | Review before adaptation. |
| `repost-temperatura-poa` | Temperatura Porto Alegre | Source `draft: true`.  |

## Academy — tutorials and methods (49)

| Source folder | Source title | Status / next step |
|---|---|---|
| `2023-08-importando-dados-sidra` | Importando dados do SIDRA | Review before adaptation. |
| `2023-09-comandos-simples` | Importando arquivos, visualizando linhas | Review before adaptation. |
| `2023-09-pipes-in-r` | Pipes | Review before adaptation. |
| `2023-10-realestatebr` | Um pacote com dados do mercado imobiliário | Review before adaptation. |
| `2023-11-replicating-plots` | Replicando gráficos | Review before adaptation. |
| `2023-11-webscrape-metro` | Dados do Metrô | Source `draft: true`.  |
| `2023-12-bump-plots` | Bump Plots | Review before adaptation. |
| `2024-01-sazonalidade` | Tendência e Sazonalidade | Review before adaptation. |
| `2024-02-gradient-descent` | Gradient Descent | Review before adaptation. |
| `2024-02-hamilton-trend` | Filtro HP e Filtro de Hamilton | Review before adaptation. |
| `2024-02-media-movel` | Médias móveis | Review before adaptation. |
| `2024-03-carry-over` | Ano de 2024 começa mais difícil | Review before adaptation. |
| `2024-03-google-places` | Enriquecendo e coletando do Google Maps | Review before adaptation. |
| `2024-03-mapas-interativos-leaflet` | Mapas Interativos com Leaflet e R | Review before adaptation. |
| `2024-03-starbucks-scrape` | Encontrando todos os Starbucks do Brasil | Review before adaptation. |
| `2024-04-brazil-shapes` | Administrative and Statistical Divisions in Brazil | Review before adaptation. |
| `2024-04-importando-pdf` | Importando dados em PDF no R | Review before adaptation. |
| `2024-04-plots-sacrilegio` | Os Pecados da Visualização de Dados | Review before adaptation. |
| `2024-04-radar-plots` | Radar Plots | Review before adaptation. |
| `2024-04-setores-censitarios` | Census Tracts in Brazil | Review before adaptation. |
| `2024-06-finding-the-coffee` | Locating all The Coffee shops in Brazil | Review before adaptation. |
| `2024-07-finding-coffee-shops` | Finding coffee shops in Brazil | Source `draft: true`.  |
| `2024-07-finding-starbucks` | Finding All Starbucks in Brazil | Review before adaptation. |
| `2024-07-webscrape-metro-4` | Line-4 Metro | Review before adaptation. |
| `2024-10-pnadc-exploring` | Working with PNADC Microdata in R | Review before adaptation. |
| `2024-12-demographic-pyramid` | Demographic Pyramids in R | Review before adaptation. |
| `2024-12-github-contributions-plot` | Replicating the Github Contributions plot in R using ggplot2 | Review before adaptation. |
| `2024-12-punchcard-plot` | Punchcard plots in R | Review before adaptation. |
| `2024-12-replicating-nexo-plot` | Film ratings over the decades: replicating a Nexo plot | Review before adaptation. |
| `2025-07-fixing-bad-charts` | Melhorando gráficos ruins | Review before adaptation. |
| `2025-07-modelo-arima` | Modelo ARIMA no R | Review before adaptation. |
| `2025-07-setup-r` | Instalando o R (Guia Completo) | Review before adaptation. |
| `2026-06-claudeplot` | claudeplot: an R package built by Claude, about Claude, in a single prompt | Source `draft: true`.  |
| `2026-06-packages-custom-fonts` | Custom Fonts in R Packages: A Practical Guide | Review before adaptation. |
| `repost-arima-no-r` | Séries de Tempo no R | Review before adaptation. |
| `repost-arma-exemplo-simples` | ARMA: um exemplo simples | Review before adaptation. |
| `repost-definindo-objetos` | Definindo objetos no R. `=` ou `<-` ? | Review before adaptation. |
| `repost-emv-no-r` | EMV no R | Review before adaptation. |
| `repost-eq-diferencas` | Equações a diferenças | Source `draft: true`.  |
| `repost-mapa-desigualdade` | Visualizando uma única variável | Review before adaptation. |
| `repost-mqo-teoria-assintotica` | MQO - teoria assintótica | Review before adaptation. |
| `repost-ols-com-matrizes` | OLS com matrizes | Review before adaptation. |
| `repost-ols-timeseries` | Regressão Linear com Séries de Tempo | Review before adaptation. |
| `repost-otimizacao-newton` | Repost: Otimização numérica - métodos de Newton | Review before adaptation. |
| `repost-pacotes-essenciais-r` | Pacotes Essenciais R | Review before adaptation. |
| `repost-regressao-linear-no-r` | Regressão Linear no R | Source `draft: true`.  |
| `repost-sarima-no-r` | SARIMA no R | Review before adaptation. |
| `repost-teoria-assintotica` | Teoria Assintótica - LGN e TCL | Review before adaptation. |
| `repost-tutorial-showtext` | Usando fontes com showtext no R | Review before adaptation. |

## Hold — no article file or stub (5)

| Source folder | Source title | Status / next step |
|---|---|---|
| `2023-11-population-density-models` | No index.qmd | No index.qmd; unfinished source folder. |
| `2024-09-basemaps-ggplot2` | Basemaps in ggplot2 | Source `draft: true`. Stub, not ready. |
| `2025-02-spo-mapa-renda` | index | Source `draft: true`. Stub: data loading only; not ready to adapt. |
| `2025-12-cidades-crescimento` | No index.qmd | No index.qmd; unfinished source folder. |
| `2025-12-density-sao-paulo` | No index.qmd | No index.qmd; unfinished source folder. |

## Skip — personal / off-brand (8)

| Source folder | Source title | Status / next step |
|---|---|---|
| `2023-08-firjan-app` | Shiny Dashboard: IDH municípios | Review before adaptation. |
| `2023-08-recife` | Weekly Viz: Recife em mapas | Review before adaptation. |
| `2023-09-brasilia` | Mapa de altitude de ruas de Brasília | Review before adaptation. |
| `2023-09-happiness` | Life Satisfaction and GDP per capita | Review before adaptation. |
| `2023-09-uruguay-numbers` | Uruguay in numbers | Review before adaptation. |
| `2024-04-best-movies-bias` | The Greatest Films of All-time: a data approach | Review before adaptation. |
| `2025-01-top-posts-2024` | Melhores Posts de 2024 | Review before adaptation. |
| `2025-05-chart-challenge` | 30DayChartChallenge: personal highlights | Review before adaptation. |

## Latest adaptation — completed

`2025-06-censo-metro-regions` was approved with a constraint to preserve the
original text and make only necessary adaptations, typo/grammar fixes and data
corrections. The original title and substantive section structure are retained.

The post uses local census tables and a compact Belo Horizonte spatial file,
with five EKIO tables, three charts and an interactive map. Annual rates now use
actual census intervals. The 2018 territorial definitions and inclusion of
associated areas are explicit. See [adaptation notes](posts/2025-06-censo-metro-regions/_adaptation.md)
for data provenance, necessary factual corrections and reproduction commands.

Validation: all 81 metropolitan units reconcile with the municipal data;
5,570 municipal growth rates agree with the published IBGE rates within rounding;
the map contains the expected 34 RM and 16 colar municipalities. Quarto rendering
and desktop/mobile checks cover tables, chart tabsets, map and local assets.
