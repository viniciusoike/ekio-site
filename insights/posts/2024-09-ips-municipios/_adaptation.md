# Notas de adaptação

Origem: `~/GitHub/restateinsight/posts/general-posts/2024-09-ips-brasil/`.
Adaptado em 2026-09-09. A estrutura de seções do original foi mantida; o texto
foi reescrito onde afirmava mais do que os dados sustentam. A data original
identifica o artigo do arquivo, não uma nova edição do índice.

## Dados e reprodução

- `data.R` prepara os arquivos locais. Executar da raiz do repositório; depende
  do CSV original do arquivo. O post não executa esse script.
- `ips-municipios.csv`: subconjunto de `static/data/ips_brasil_municipios.csv`
  do arquivo — 5.570 municípios, o índice geral, as três dimensões, os doze
  componentes, população de 2022 e PIB per capita de 2021. O original tem 75
  colunas e 5,7 MB; os escores são arredondados para três casas, que preservam
  o ordenamento das tabelas de extremos.
- `ips-variaveis.csv`: rótulos originais dos indicadores e a que dimensão cada
  componente pertence.
- A renderização não acessa a rede nem o repositório de origem.

## Correções necessárias

- O original descrevia a distribuição do IPS como assimétrica, com "cauda longa"
  de municípios ruins. Média (58,1) e mediana (58,1) coincidem; a distribuição é
  simétrica. O texto passa a descrever concentração, não assimetria.
- O original afirmava que Oportunidades tem "maior variabilidade". Seu
  desvio-padrão (5,9) é menor que o de Necessidades Humanas Básicas (8,0). O que
  distingue a dimensão é o nível, e o texto passa a dizer isso.
- O gráfico por unidade da federação trata o Distrito Federal como um estado.
  O DF é um único município e o subtítulo passa a registrar a ressalva.
- A média simples entre municípios (58,1) difere da média ponderada pela
  população (61,8). O texto explicita qual medida usa e por quê.
- O original atribuía aos dez piores municípios "economia baseada em agricultura
  de subsistência", afirmação que os dados não sustentam. Substituída pelo que se
  observa: todos estão no Pará e em Roraima e pontuam mal nas três dimensões.
- A correlação com o PIB per capita passa a aparecer como número (0,40 contra o
  logaritmo), sustentando a afirmação de que o índice não acompanha a renda.

## Edição

- Cortada a seção "Implicações para Políticas Públicas", uma lista de
  prescrições genéricas que não decorriam da análise.
- Cortada a seção "Principais Conclusões", que apenas retomava o corpo do post.
- Acrescentado um gráfico com a média dos doze componentes. Ele identifica
  direitos individuais (28,5) e acesso à educação superior (30,0) como o piso do
  índice, o que o original afirmava sem mostrar.
- Acrescentada a inversão regional em Oportunidades: o Nordeste (40,5) fica
  acima do Sudeste (39,2), pelo componente de inclusão social.

## Apresentação

Três tabelas e quatro gráficos, todos com os auxiliares compartilhados do site
(`_ekio-style.R` e `ekiotable::gt_theme_hokusai`). A paleta fixa do original
(`#2E86AB`, `#A23B72`, `#F18F01`) e o `opt_stylize()` do gt foram removidos.
A capa reaproveita `cover-layered-inquiry.webp`.
