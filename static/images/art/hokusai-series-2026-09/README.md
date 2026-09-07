# Artes EKIO — setembro de 2026

18 imagens geradas com a ferramenta integrada `image_gen`: dois heroes,
dois banners, dois cards e doze variações temáticas para insights.

Abra [o catálogo visual](catalog.html) para comparar as composições. Os arquivos
WebP são as versões para o site; `originals/` preserva os PNGs gerados.
[manifest.json](manifest.json) registra dimensões, tamanho e o prompt de cada arte.

## Prompts e referências

- [Prompts exatos da série inicial](PROMPTS.md).
- [Prompts exatos das doze variações para insights](INSIGHT-PROMPTS.md).
- Referência principal: `../hero-geometry-hokusai.webp`.
- Referências adicionais: as quatro gravuras enviadas pelo usuário, descritas em
  `PROMPTS.md`, usadas para cor e textura.
- Paleta: [ekio_brand, do ekioplot](https://viniciusoike.github.io/ekioplot/articles/palettes.html).

As cores hexadecimais são referências para a geração; a textura da tinta produz
variação tonal. Os gráficos são ilustrações de padrões plausíveis, sem dados
observados, texto ou identificação de variáveis.

## Uso no site

O hero de São Paulo está na página inicial. O hero metropolitano aparece nos
fundos de chamada para contato. Serviços e Insights usam o banner de dados;
Sobre usa a composição de patrimônio arquitetônico.

Os nove posts existentes têm uma imagem atribuída em `image`, com descrição em
`image-alt`. O filtro `static/filters/post-cover.lua` usa essa imagem como capa
do artigo quando `art-cover: true`. O filtro lê o front matter atual, inclusive
quando o Quarto usa resultados congelados de R. As demais variações ficam disponíveis neste
catálogo para novos posts ou trocas editoriais.

Para trocar uma capa, use um caminho a partir da raiz do site:

```yaml
image: "/static/images/art/hokusai-series-2026-09/insight-courtyard-housing.webp"
image-alt: "Ilustração de edifícios residenciais ao redor de um pátio"
```

Os WebP entram na publicação. PNGs, prompts e catálogo ficam como materiais de
trabalho no repositório. O perfil `art-review` mostra os rascunhos localmente em
`_site-art-review`, sem mudar o estado editorial dos posts:

```sh
quarto render --profile art-review --no-execute
python3 -m http.server 4324 --directory _site-art-review
```

`--no-execute` permite revisar a arte sem recalcular análises; não valida os
resultados computacionais dos artigos. Para a renderização normal: `quarto render`.
