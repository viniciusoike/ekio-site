# Preparação dos arquivos locais --------------------------------------------
# Executar da raiz do projeto. Não é executado pelo post.
# O arquivo original do arquivo tem 75 colunas e 5,7 MB; o post usa o índice,
# as três dimensões, os doze componentes e as variáveis de contexto.

library(dplyr)
library(readr)

post_dir <- here::here("insights/posts/2024-09-ips-municipios")
archive_file <- path.expand(
  "~/GitHub/restateinsight/static/data/ips_brasil_municipios.csv"
)

ips_raw <- read_csv(archive_file, show_col_types = FALSE)

# Dimensões e componentes ---------------------------------------------------
# A ordem segue a metodologia: cada dimensão é seguida dos componentes que a
# compõem. "Acesso à Cultura, Lazer e Esporte" tem vírgula no nome original e
# é lido com quebra de linha; não é usado aqui.

dimensions <- tribble(
  ~variable,      ~source_name,                          ~dimension,
  "ips",          "Índice de Progresso Social",           NA_character_,
  "nhb",          "Necessidades Humanas Básicas",         NA_character_,
  "fbe",          "Fundamentos do Bem-estar",             NA_character_,
  "opo",          "Oportunidades",                        NA_character_,
  "nutricao",     "Nutrição e Cuidados Médicos Básicos",  "nhb",
  "saneamento",   "Água e Saneamento",                    "nhb",
  "moradia",      "Moradia",                              "nhb",
  "seguranca",    "Segurança Pessoal",                    "nhb",
  "conhecimento", "Acesso ao Conhecimento Básico",        "fbe",
  "informacao",   "Acesso à Informação e Comunicação",    "fbe",
  "saude",        "Saúde e Bem-estar",                    "fbe",
  "ambiente",     "Qualidade do Meio Ambiente",           "fbe",
  "direitos",     "Direitos Individuais",                 "opo",
  "liberdades",   "Liberdades Individuais e de Escolha",  "opo",
  "inclusao",     "Inclusão Social",                      "opo",
  "educacao",     "Acesso à Educação Superior",           "opo"
)

stopifnot(all(dimensions$source_name %in% names(ips_raw)))

# Municípios ----------------------------------------------------------------
# O nome vem com a UF entre parênteses ("Nova Lima (MG)"); as tabelas do post
# trazem a UF em coluna própria.

context <- ips_raw |>
  transmute(
    code_muni = as.integer(`Código IBGE`),
    name_muni = sub(" \\([A-Z]{2}\\)$", "", Município),
    abbrev_state = UF,
    pop_2022 = as.integer(`População 2022`),
    gdp_pc_2021 = round(`PIB per capita 2021`, 2)
  )

# Os escores são índices de 0 a 100. Três casas cortam dois terços do arquivo
# e preservam o ordenamento dos municípios nas tabelas de extremos.
scores <- ips_raw[, dimensions$source_name]
names(scores) <- dimensions$variable
scores <- mutate(scores, across(everything(), \(x) round(x, 3)))

ips <- bind_cols(context, scores)

stopifnot(
  nrow(ips) == 5570,
  !anyNA(ips),
  !anyDuplicated(ips$code_muni),
  n_distinct(ips$abbrev_state) == 27,
  # As três dimensões e o índice geral ficam na escala de 0 a 100.
  all(sapply(scores, \(x) min(x) >= 0 && max(x) <= 100))
)

# Exportação ----------------------------------------------------------------

write_csv(ips, file.path(post_dir, "ips-municipios.csv"))
write_csv(dimensions, file.path(post_dir, "ips-variaveis.csv"))
cli::cli_alert_success(
  "Dados locais preparados para {nrow(ips)} municípios e {nrow(dimensions)} indicadores."
)
