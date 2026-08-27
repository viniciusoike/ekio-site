# Site da EKIO

Este repositório contém o código-fonte do site institucional da EKIO, uma
consultoria em economia, ciência de dados e inteligência espacial. O site reúne
informações sobre os serviços da empresa, sua atuação e artigos de análise
aplicada.

O projeto usa [Quarto](https://quarto.org/) para gerar um site estático. As
páginas institucionais combinam documentos Quarto, estilos próprios e recursos
visuais; os artigos também podem executar código R.

## Estrutura do projeto

- `_quarto.yml` define a navegação, o tema e as opções gerais de renderização.
- Os arquivos `.qmd` na raiz correspondem às páginas institucionais.
- `insights/` contém o índice, os modelos e os artigos publicados.
- `static/` reúne folhas de estilo, imagens e outros recursos estáticos.
- `_freeze/` armazena resultados computados pelo Quarto e integra o controle de
  versão.
- `_site/` recebe o site renderizado localmente e não integra o controle de
  versão.
- `ekio_ref/` preserva o protótipo estático usado como referência visual.

## Desenvolvimento local

O desenvolvimento requer uma instalação recente do Quarto. Para recalcular os
artigos, também são necessários R e os pacotes usados em cada documento. Os
resultados armazenados em `_freeze/` permitem renderizar o conteúdo publicado
sem repetir todos os cálculos.

Clone o repositório e inicie a visualização local com os comandos abaixo.

```bash
git clone https://github.com/viniciusoike/ekio-site.git
cd ekio-site
quarto preview
```

Para gerar o site completo em `_site/`, execute:

```bash
quarto render
```

A configuração exclui `casos.qmd` da renderização enquanto a página permanece
fora do ar.

## Controle de versão

O branch principal é `main`. O repositório mantém os resultados congelados do
Quarto, mas ignora o site renderizado, arquivos temporários do Quarto, dados da
sessão do R e arquivos locais do sistema operacional.

Antes de registrar uma alteração, renderize o site e revise os arquivos
modificados.

```bash
quarto render
git status
git diff
```

Use mensagens de commit curtas e descritivas, de acordo com o padrão já adotado
no histórico do projeto, como `feat:`, `fix:`, `content:` e `chore:`.

## Publicação

O Quarto grava a versão pronta para publicação em `_site/`. O serviço de
hospedagem deve publicar o conteúdo desse diretório e usar `https://ekio.io`
como endereço principal.
