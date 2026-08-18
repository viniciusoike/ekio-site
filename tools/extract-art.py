#!/usr/bin/env python3
"""Recorta as artes de static/images/art/ a partir das pranchas de contato.

As nove exportações em design/ekio_imagens_site são pranchas de contato: cada
PNG reúne de duas a quatro composições separadas por uma calha clara. Só
01_editorial_retrato é uma imagem única. PANELS registra o recorte de cada
composição sobre a versão XL; PICKS diz qual composição virou qual arquivo do
site.

Uso:
    python3 tools/extract-art.py [--src CAMINHO] [--panels DESTINO]

Sem --panels o script grava apenas os arquivos usados pelo site. Com --panels
ele grava também as 28 composições soltas, para trocar uma escolha por outra.
"""

import argparse
import os
from pathlib import Path

from PIL import Image

SRC_DEFAULT = Path("../design/ekio_imagens_site/XL_extragrande")
DST_DEFAULT = Path("static/images/art")

# Composição -> (arquivo de origem, caixa de recorte left/top/right/bottom).
# As calhas foram medidas procurando linhas e colunas de desvio padrão baixo.
PANELS = {
    "01a": ("01_editorial_retrato_XL.png", (0, 0, 1024, 1536)),
    "02a": ("02_variacoes_retrato_XL.png", (0, 0, 506, 763)),
    "02b": ("02_variacoes_retrato_XL.png", (517, 0, 1024, 763)),
    "02c": ("02_variacoes_retrato_XL.png", (0, 773, 506, 1536)),
    "02d": ("02_variacoes_retrato_XL.png", (517, 773, 1024, 1536)),
    "03a": ("03_variacoes_paisagem_XL.png", (0, 0, 1536, 505)),
    "03b": ("03_variacoes_paisagem_XL.png", (0, 518, 752, 1024)),
    "03c": ("03_variacoes_paisagem_XL.png", (767, 518, 1536, 1024)),
    "04a": ("04_sao_paulo_variante_01_XL.png", (0, 0, 555, 1024)),
    "04b": ("04_sao_paulo_variante_01_XL.png", (565, 0, 1536, 538)),
    "04c": ("04_sao_paulo_variante_01_XL.png", (565, 550, 1536, 1024)),
    "05a": ("05_sao_paulo_variante_02_XL.png", (0, 0, 482, 1024)),
    "05b": ("05_sao_paulo_variante_02_XL.png", (495, 0, 1536, 518)),
    "05c": ("05_sao_paulo_variante_02_XL.png", (495, 561, 1536, 1024)),
    "06a": ("06_sao_paulo_variante_03_XL.png", (0, 0, 673, 504)),
    "06b": ("06_sao_paulo_variante_03_XL.png", (685, 0, 1536, 504)),
    "06c": ("06_sao_paulo_variante_03_XL.png", (0, 515, 673, 1024)),
    "06d": ("06_sao_paulo_variante_03_XL.png", (685, 515, 1536, 1024)),
    "07a": ("07_sao_paulo_variante_04_XL.png", (0, 0, 537, 1024)),
    "07b": ("07_sao_paulo_variante_04_XL.png", (550, 0, 1536, 498)),
    "07c": ("07_sao_paulo_variante_04_XL.png", (550, 523, 1536, 1024)),
    "08a": ("08_sao_paulo_variante_05_XL.png", (0, 0, 593, 535)),
    "08b": ("08_sao_paulo_variante_05_XL.png", (629, 0, 1536, 535)),
    "08c": ("08_sao_paulo_variante_05_XL.png", (0, 548, 593, 1024)),
    "08d": ("08_sao_paulo_variante_05_XL.png", (629, 548, 1536, 1024)),
    "09a": ("09_sao_paulo_variante_06_XL.png", (0, 0, 568, 1024)),
    "09b": ("09_sao_paulo_variante_06_XL.png", (580, 0, 1536, 469)),
    "09c": ("09_sao_paulo_variante_06_XL.png", (580, 545, 1536, 1024)),
}

# Composição -> (nome no site, largura máxima). As miniaturas dos cards são
# caixas `cover` deitadas, então recebem composições em paisagem: uma origem em
# retrato perde metade do desenho no corte.
PICKS = [
    ("03a", "faixa-skyline-larga", 2200),   # faixa da home
    ("09b", "faixa-malha-sp", 2200),        # faixa do cabeçalho de insights
    ("07c", "faixa-skyline-mapa", 1800),    # fundo do CTA de sobre.qmd
    ("05b", "fundo-cta-sp", 2000),          # fundo do CTA da home e de insights
    ("03c", "thumb-precos-imoveis", 1200),
    ("03b", "thumb-aluguel-venda", 1200),
    ("06d", "thumb-indices", 1200),
    ("06c", "thumb-idh-sp", 1200),
    ("04b", "thumb-casas-apto", 1200),
    ("09c", "thumb-recessoes", 1200),
    ("01a", "editorial-retrato", 1100),     # reserva, em retrato
]


def crop(src_dir, key):
    filename, box = PANELS[key]
    return Image.open(src_dir / filename).convert("RGB").crop(box)


def save_webp(image, path, max_width):
    if image.width > max_width:
        height = round(image.height * max_width / image.width)
        image = image.resize((max_width, height), Image.LANCZOS)
    image.save(path, "WEBP", quality=86, method=6)
    return image


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--src", type=Path, default=SRC_DEFAULT)
    parser.add_argument("--dst", type=Path, default=DST_DEFAULT)
    parser.add_argument("--panels", type=Path, default=None,
                        help="grava também as 28 composições soltas neste diretório")
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
