#!/usr/bin/env python3
"""Recorta as artes de static/images/art/ a partir das pranchas de contato.

As sete exportações em design/imagens-site/ekio-imagens-site-sao-paulo são
pranchas de contato: cada PNG reúne cinco composições separadas por uma calha
branca. PANELS registra o recorte de cada composição sobre a versão XL; PICKS
diz qual composição virou qual arquivo do site.

O site usa só as pranchas 06 e 07. As outras cinco trazem legendas e números
cravados na arte — percentuais de valorização, preço por m², coeficientes de
correlação — que nenhuma análise da EKIO produziu. Ver a seção "Artes
descartadas" no fim deste arquivo.

Uso:
    python3 tools/extract-art.py [--src CAMINHO] [--panels DESTINO]

Sem --panels o script grava apenas os arquivos usados pelo site. Com --panels
ele grava também as 30 composições soltas, para trocar uma escolha por outra.
"""

import argparse
import os
from pathlib import Path

from PIL import Image

SRC_DEFAULT = Path("../design/imagens-site/ekio-imagens-site-sao-paulo/XL")
DST_DEFAULT = Path("static/images/art")

# Composição -> (arquivo de origem, caixa de recorte left/top/right/bottom).
# As calhas foram medidas procurando linhas e colunas de desvio padrão baixo,
# primeiro na prancha inteira e depois dentro de cada metade.
PANELS = {
    "01a": ("ekio_editorial_01_XL.png", (0, 0, 502, 507)),
    "01b": ("ekio_editorial_01_XL.png", (513, 0, 1536, 507)),
    "01c": ("ekio_editorial_01_XL.png", (0, 518, 502, 1024)),
    "01d": ("ekio_editorial_01_XL.png", (529, 518, 1023, 1024)),
    "01e": ("ekio_editorial_01_XL.png", (1059, 518, 1536, 1024)),
    "02a": ("ekio_editorial_02_XL.png", (0, 0, 386, 508)),
    "02b": ("ekio_editorial_02_XL.png", (396, 0, 1043, 508)),
    "02c": ("ekio_editorial_02_XL.png", (1096, 0, 1536, 508)),
    "02d": ("ekio_editorial_02_XL.png", (0, 517, 860, 1024)),
    "02e": ("ekio_editorial_02_XL.png", (875, 517, 1536, 1024)),
    "03a": ("ekio_editorial_03_XL.png", (0, 0, 726, 486)),
    "03b": ("ekio_editorial_03_XL.png", (778, 0, 1536, 486)),
    "03c": ("ekio_editorial_03_XL.png", (0, 500, 485, 1024)),
    "03d": ("ekio_editorial_03_XL.png", (527, 500, 1011, 1024)),
    "03e": ("ekio_editorial_03_XL.png", (1055, 500, 1536, 1024)),
    "05a": ("ekio_editorial_05_XL.png", (0, 0, 426, 551)),
    "05b": ("ekio_editorial_05_XL.png", (433, 0, 1142, 551)),
    "05c": ("ekio_editorial_05_XL.png", (1170, 0, 1536, 551)),
    "05d": ("ekio_editorial_05_XL.png", (0, 558, 660, 1024)),
    "05e": ("ekio_editorial_05_XL.png", (715, 558, 1536, 1024)),
    "06a": ("ekio_editorial_06_XL.png", (0, 0, 502, 507)),
    "06b": ("ekio_editorial_06_XL.png", (513, 0, 1536, 507)),
    "06c": ("ekio_editorial_06_XL.png", (0, 517, 502, 1024)),
    "06d": ("ekio_editorial_06_XL.png", (529, 517, 1023, 1024)),
    "06e": ("ekio_editorial_06_XL.png", (1046, 517, 1536, 1024)),
    "07a": ("ekio_editorial_07_XL.png", (0, 0, 433, 566)),
    "07b": ("ekio_editorial_07_XL.png", (444, 0, 1536, 566)),
    "07c": ("ekio_editorial_07_XL.png", (0, 620, 583, 1024)),
    "07d": ("ekio_editorial_07_XL.png", (594, 620, 919, 1024)),
    "07e": ("ekio_editorial_07_XL.png", (930, 620, 1536, 1024)),
}

# Composição -> (nome no site, largura máxima). As miniaturas dos cards são
# caixas `cover` deitadas, então recebem composições em paisagem: uma origem em
# retrato perde metade do desenho no corte.
PICKS = [
    ("07b", "faixa-paulista", 2200),        # faixa da home
    ("06b", "faixa-metro-sp", 2200),        # faixa do cabeçalho de insights
    ("07e", "fundo-cta-paulista", 1600),    # fundo do CTA da home
    ("06c", "fundo-cta-skyline", 1600),     # fundo do CTA de insights e de sobre
    ("06a", "thumb-precos-imoveis", 1200),
    ("07d", "thumb-aluguel-venda", 1200),
    ("07a", "thumb-indices", 1200),
    ("06d", "thumb-idh-sp", 1200),
    ("07c", "thumb-casas-apto", 1200),
    ("06e", "thumb-recessoes", 1200),
]

# ── Artes descartadas ──
# 01, 02, 03 e 05 repetem as mesmas composições de 06 e 07 com legendas e
# números sobrepostos. Os números são inventados e aparecem legíveis:
#   03a  +12,4% valorização · +8,7% demanda · +5,3% oferta
#   03c  +18,6% preço médio/m² · +9,2% absorção · -3,4% vacância
#   03e  correlações 0,78 · 0,60 · 0,42
#   02e  R$ 12.750/m² · +73% · R$ 7.350/m²
#   05c  escala de preço médio de R$ 3.000 a R$ 20.000/m²
# 03c ainda traz "TENDÂCIAS" no lugar de "tendências". As legendas usam uma
# sans que não é nenhuma das três fontes do site, e 02b desenha as linhas do
# metrô em amarelo, roxo e lilás, fora da paleta.


def crop(src_dir, key):
    filename, box = PANELS[key]
    return Image.open(src_dir / filename).convert("RGB").crop(box)


def save_webp(image, path, max_width):
    if image.width > max_width:
        height = round(image.height * max_width / image.width)
        image = image.resize((max_width, height), Image.LANCZOS)
    image.save(path, "WEBP", quality=82, method=6)
    return image


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--src", type=Path, default=SRC_DEFAULT)
    parser.add_argument("--dst", type=Path, default=DST_DEFAULT)
    parser.add_argument("--panels", type=Path, default=None,
                        help="grava também as 30 composições soltas neste diretório")
    args = parser.parse_args()

    args.dst.mkdir(parents=True, exist_ok=True)

    if args.panels:
        args.panels.mkdir(parents=True, exist_ok=True)
        for key in PANELS:
            crop(args.src, key).save(args.panels / f"{key}.png")
        print(f"{len(PANELS)} composições em {args.panels}")

    for key, name, max_width in PICKS:
        path = args.dst / f"{name}.webp"
        image = save_webp(crop(args.src, key), path, max_width)
        size_kb = os.path.getsize(path) // 1024
        print(f"{name:24s} {image.width}x{image.height:<5d} {size_kb:>4d} KB  ({key})")


if __name__ == "__main__":
    main()
