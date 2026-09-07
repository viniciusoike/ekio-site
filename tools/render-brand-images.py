#!/usr/bin/env python3
"""Compose the social card and the insight placeholder from the brand marks.

Both images are cream marks on flat navy. Rather than tracing the letterforms
again, this script lifts the geometry straight out of static/images/brand and
places it on a navy ground, where the mark's own navy plate disappears. Only
the supporting text is typeset.

    python3 tools/render-brand-images.py

Writes og-card.svg, og-card.png and insight-placeholder.svg. The PNG needs
rsvg-convert and the Lato family installed.
"""

import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BRAND = ROOT / "static" / "images" / "brand"
IMAGES = ROOT / "static" / "images"

NAVY = "#1E3A5F"
LATO = "Lato, 'Helvetica Neue', Arial, sans-serif"

# Transparency over navy is allowed at exactly these two weights.
TEXT = "rgba(255,255,255,0.86)"
MUTED = "rgba(255,255,255,0.6)"


def mark_body(name: str) -> str:
    """The drawable contents of a brand SVG, without its <svg> wrapper."""
    svg = (BRAND / name).read_text(encoding="utf-8")
    open_end = svg.index(">", svg.index("<svg"))
    return svg[open_end + 1 : svg.rindex("</svg>")].strip()


def render_og_card() -> None:
    # The lockup is 151x47 natively; 2x puts it at 302x94.
    lockup = mark_body("lockup-navy.svg")

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630" role="img" aria-label="EKIO — consultoria econômica, ciência de dados e inteligência espacial">
  <rect width="1200" height="630" fill="{NAVY}"/>

  <!-- Lockup at 2x. Its navy plate reads as the ground, leaving the cream
       mark on navy — the first approved pairing. -->
  <g transform="translate(96 176) scale(2)">
{indent(lockup, 4)}
  </g>

  <line x1="96" y1="366" x2="1104" y2="366" stroke="{MUTED}" stroke-width="1"/>

  <text x="96" y="428" fill="{TEXT}" font-family="{LATO}" font-size="30" font-weight="400" letter-spacing="0.5">Consultoria Econômica · Ciência de Dados · Inteligência Espacial</text>
  <text x="96" y="534" fill="{MUTED}" font-family="{LATO}" font-size="22" font-weight="400" letter-spacing="2.5">ekio.io</text>
</svg>
"""
    out_svg = IMAGES / "og-card.svg"
    out_svg.write_text(svg, encoding="utf-8")

    if shutil.which("rsvg-convert") is None:
        sys.exit("rsvg-convert not found; og-card.svg written but not rasterized")

    subprocess.run(
        [
            "rsvg-convert",
            "-w", "1200",
            "-h", "630",
            "-o", str(IMAGES / "og-card.png"),
            str(out_svg),
        ],
        check=True,
    )


def render_placeholder() -> None:
    # The monogram is 43x43 natively; 3.2x centres a 137.6px mark on 600x400.
    monogram = mark_body("monogram-navy.svg")
    scale = 3.2
    size = 43 * scale
    x = (600 - size) / 2
    y = (400 - size) / 2

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 400" role="img" aria-label="EKIO">
  <rect width="600" height="400" fill="{NAVY}"/>
  <g transform="translate({x:.1f} {y:.1f}) scale({scale})">
{indent(monogram, 4)}
  </g>
</svg>
"""
    (IMAGES / "insight-placeholder.svg").write_text(svg, encoding="utf-8")


def indent(block: str, spaces: int) -> str:
    pad = " " * spaces
    return "\n".join(pad + line for line in block.splitlines())


if __name__ == "__main__":
    render_og_card()
    render_placeholder()
    print("wrote og-card.svg, og-card.png, insight-placeholder.svg")
