# Novas imagens para Insights

Doze imagens editoriais geradas com a ferramenta integrada image_gen em 7 de setembro de 2026.

Abra [o catálogo](catalog.html) para comparar as duas capas 2:1 e as dez imagens 3:2. Os WebP preservam as dimensões dos PNGs originais; conversão com Pillow, qualidade 88, sem recorte ou redimensionamento.

[Prompts completos](PROMPTS.md) registram as instruções exatas. O [manifesto](manifest.json) reúne dimensões, descrições em português e sugestões de uso. Os PNGs ficam em `originals/`.

As imagens ainda não foram atribuídas a páginas. Para usar uma delas em um artigo:

```yaml
image: "/static/images/art/hokusai-insights-2026-09-07/insight-financing-thresholds.webp"
image-alt: "Aberturas retangulares sobrepostas em azul e linho, com um pequeno detalhe dourado."
art-cover: true
```

Para fundos referenciados apenas em CSS, inclua o WebP nos recursos do Quarto ao integrar a imagem. Os temas são metáforas visuais; não representam dados nem conclusões dos artigos.

## Complemento residencial

Seis imagens genéricas para posts futuros: duas de moradia individual em edifícios, duas de residências de alto padrão e duas de condomínios de casas. [Prompts completos](RESIDENTIAL-PROMPTS.md). Todas em 1536 × 1024, com PNG original e WebP sem recorte.
