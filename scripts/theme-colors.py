#!/usr/bin/env python3
"""Extract a glass-style palette from the currently configured wallpaper.

Usage: theme-colors.py <source_image> <output_palette.env>
"""

import colorsys
import sys
from pathlib import Path

from PIL import Image, ImageEnhance, ImageStat


def clamp(v):
    return max(0, min(255, int(v)))


def rgb_hex(rgb):
    return "{:02x}{:02x}{:02x}".format(*rgb)


def mix(a, b, t):
    return tuple(clamp(a[i] + (b[i] - a[i]) * t) for i in range(3))


def contrast_text(bg):
    lum = sum(bg[i] * w for i, w in enumerate((0.2126, 0.7152, 0.0722))) / 255
    return (255, 255, 255) if lum < 0.58 else (8, 10, 18)


def vivid(rgb):
    r, g, b = (x / 255 for x in rgb)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s = min(1.0, s * 1.35)
    v = min(1.0, max(0.42, v))
    rr, gg, bb = colorsys.hsv_to_rgb(h, s, v)
    return tuple(clamp(x * 255) for x in (rr, gg, bb))


def main():
    if len(sys.argv) != 3:
        print("usage: theme-colors.py <image> <palette.env>", file=sys.stderr)
        return 2

    source = Path(sys.argv[1]).expanduser()
    output = Path(sys.argv[2])
    if not source.is_file():
        print("wallpaper not found: " + str(source), file=sys.stderr)
        return 1

    image = Image.open(source).convert("RGB")
    image.thumbnail((240, 240))

    # Adaptive quantization uses dominant balanced colours rather than one pixel.
    quant = image.quantize(colors=24, method=Image.MEDIANCUT)
    colors = quant.getcolors(240 * 240)
    if not colors:
        return 1

    ranked = []
    for count, index in sorted(colors, reverse=True):
        rgb = quant.palette.getcolor(quant.palette.colors[0][0]) if False else quant.palette.colors
        pal = quant.getpalette()
        i = index * 3
        col = tuple(pal[i:i + 3])
        sat = max(col) - min(col)
        lum = sum(col) / 3
        score = count * (0.75 + sat / 255 * 1.25) * (0.7 + (255 - abs(lum - 128)) / 255 * 0.3)
        ranked.append((score, col))
    ranked.sort(reverse=True)

    # Prefer warm/amber-like saturated colours for Glass Amber,
    # but fall back to the dominant colour if the image is blue/neutral.
    warm_candidates = []
    for score, col in ranked:
        r, g, b = (x / 255 for x in col)
        h, s, v = colorsys.rgb_to_hsv(r, g, b)
        degrees = h * 360
        warm = (0 <= degrees <= 75 or 330 <= degrees <= 360)
        if warm and s > 0.18:
            warm_candidates.append((score * (1.0 + s), col))

    if warm_candidates:
        warm_candidates.sort(reverse=True)
        dominant = warm_candidates[0][1]
    else:
        dominant = ranked[0][1]
    accent = vivid(dominant)
    # Ensure warm wallpaper colours become a visible amber/copper glass accent.
    ar, ag, ab = accent
    h, s, v = colorsys.rgb_to_hsv(ar / 255, ag / 255, ab / 255)
    degrees = h * 360
    if 15 <= degrees <= 75:
        accent = tuple(clamp(x) for x in (255, 177, 77))

    stat = ImageStat.Stat(image)
    avg = tuple(clamp(x) for x in stat.mean)
    dark = tuple(clamp(x * 0.34) for x in avg)
    bg_alt = mix(dark, accent, 0.18)
    bg_hover = mix(bg_alt, accent, 0.24)

    lum = sum(dark[i] * w for i, w in enumerate((0.2126, 0.7152, 0.0722))) / 255
    if lum > 105:
        dark = tuple(clamp(x * 0.58) for x in avg)
        bg_alt = mix(dark, accent, 0.14)

    # Glass Amber always uses readable warm-light text over its derived dark glass.
    fg = (242, 235, 216)
    fg_muted = mix(fg, accent, 0.40)

    warn = vivid((255, 184, 108))
    good = vivid((67, 230, 165))
    danger = vivid((255, 107, 133))

    lines = [
        "# Glass theme generated from the live wallpaper",
        "MODE=dark",
        "BG=" + rgb_hex(dark),
        "BG_ALT=" + rgb_hex(bg_alt),
        "BG_HOVER=" + rgb_hex(bg_hover),
        "FG=" + rgb_hex(fg),
        "FG_MUTED=" + rgb_hex(fg_muted),
        "ACCENT=" + rgb_hex(accent),
        "ACCENT_ALT=" + rgb_hex(vivid(mix(accent, (178, 139, 255), 0.42))),
        "WARN=" + rgb_hex(warn),
        "GOOD=" + rgb_hex(good),
        "DANGER=" + rgb_hex(danger),
    ]

    palette = [dark, danger, good, warn, accent, vivid((167, 139, 250)), vivid((86, 200, 255)), fg,
               mix(dark, fg, 0.32), vivid((255, 138, 161)), vivid((112, 239, 186)), vivid((255, 198, 138)),
               vivid((130, 173, 255)), vivid((182, 154, 255)), vivid((123, 220, 255)), mix(fg, (255, 255, 255), 0.45)]
    for i, col in enumerate(palette):
        lines.append("ANSI%d=" % i + rgb_hex(col))

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("Generated palette from " + str(source) + " -> " + str(output))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
