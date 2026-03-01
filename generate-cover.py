#!/usr/bin/env python3
"""Generate a premium cover image for pretty-terminal README."""

import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops, PngImagePlugin
import math

# --- Ultra high-res (5x scale, DPI=1200) ---
SCALE = 5
W, H = 1280 * SCALE, 400 * SCALE  # 6400x2000 pixels
DPI = 1200

# Dracula palette
BG_DARK = np.array([40, 42, 54])
BG_DEEPER = np.array([18, 19, 26])
PURPLE = np.array([189, 147, 249])
CYAN = np.array([139, 233, 253])
GREEN = np.array([80, 250, 123])
PINK = np.array([255, 121, 198])
WHITE = (248, 248, 242)
CYAN_RGB = (139, 233, 253)
PURPLE_RGB = (189, 147, 249)
PINK_RGB = (255, 121, 198)

# --- Build background with numpy ---
np.random.seed(42)
bg = np.zeros((H, W, 3), dtype=np.float64)
bg[:] = BG_DEEPER

# === Layer 1: Vertical stripes (more, thinner, varied) ===
for i in range(900):
    cx = np.random.randint(0, W)
    width = np.random.randint(1 * SCALE, 10 * SCALE)
    mix = np.random.random()
    color = BG_DARK * 0.5 + PURPLE * mix * 0.12 + CYAN * (1 - mix) * 0.06
    center_dist = abs(cx - W / 2) / (W / 2)
    opacity = (1 - center_dist ** 1.5) * np.random.uniform(0.02, 0.12)

    x0 = max(0, cx - width // 2)
    x1 = min(W, cx + width // 2)
    # Vectorized vertical gradient
    y_coords = np.arange(H)
    y_fade = 1.0 - 0.3 * (np.abs(y_coords - H / 2) / (H / 2)) ** 2
    for y in range(H):
        bg[y, x0:x1] = bg[y, x0:x1] * (1 - opacity * y_fade[y]) + color * opacity * y_fade[y]

# === Layer 2: Broad center glow (purple + cyan dual glow) ===
y_coords = np.arange(H).reshape(-1, 1)
x_coords = np.arange(W).reshape(1, -1)
cx_dist = np.abs(x_coords - W / 2) / (W / 2)
cy_dist = np.abs(y_coords - H / 2) / (H / 2)

# Purple glow (center, slightly above)
glow_p = np.maximum(0, (1 - cx_dist ** 1.8) * (1 - ((y_coords - H * 0.42) / (H * 0.6)) ** 2) * 0.07)
glow_p = np.clip(glow_p, 0, 1)
for c in range(3):
    bg[:, :, c] += PURPLE[c] * glow_p * 0.35

# Cyan glow (center, slightly below)
glow_c = np.maximum(0, (1 - cx_dist ** 2.0) * (1 - ((y_coords - H * 0.58) / (H * 0.6)) ** 2) * 0.05)
glow_c = np.clip(glow_c, 0, 1)
for c in range(3):
    bg[:, :, c] += CYAN[c] * glow_c * 0.2

# === Layer 3: Subtle noise texture ===
noise = np.random.normal(0, 1.8, (H, W, 3))
bg += noise

# === Layer 4: Vignette (stronger, cinematic) ===
vignette = np.ones((H, W), dtype=np.float64)
for y in range(H):
    y_factor = (abs(y - H / 2) / (H / 2)) ** 2.2
    for x_block in range(0, W, SCALE):
        x_factor = (abs(x_block - W / 2) / (W / 2)) ** 1.6
        darken = max(0, 1 - (x_factor * 0.45 + y_factor * 0.3))
        x_end = min(x_block + SCALE, W)
        vignette[y, x_block:x_end] = darken

bg[:, :, 0] *= vignette
bg[:, :, 1] *= vignette
bg[:, :, 2] *= vignette

# === Layer 5: Floating particles (depth effect) ===
for _ in range(200):
    px = np.random.randint(0, W)
    py = np.random.randint(0, H)
    radius = np.random.uniform(1 * SCALE, 4 * SCALE)
    brightness = np.random.uniform(0.03, 0.15)
    # Particles are purple or cyan tinted
    if np.random.random() > 0.5:
        p_color = PURPLE * brightness
    else:
        p_color = CYAN * brightness

    # Center distance fade (particles more visible near center)
    pc_dist = math.sqrt(((px - W/2) / (W/2))**2 + ((py - H/2) / (H/2))**2)
    if pc_dist > 1.2:
        continue
    fade = max(0, 1 - pc_dist ** 2) * 0.7

    r = int(radius)
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            dist = math.sqrt(dx*dx + dy*dy)
            if dist <= radius:
                nx, ny = px + dx, py + dy
                if 0 <= nx < W and 0 <= ny < H:
                    alpha = (1 - dist / radius) ** 2 * fade
                    bg[ny, nx] = bg[ny, nx] + p_color * alpha

# Clamp and convert
bg = np.clip(bg, 0, 255).astype(np.uint8)
img = Image.fromarray(bg, "RGB")

# Smooth background
img = img.filter(ImageFilter.GaussianBlur(radius=2.5 * SCALE))

# --- Fonts ---
font_title = ImageFont.truetype(
    "/Users/woojin/Library/Fonts/JetBrainsMonoNerdFont-Bold.ttf", 88 * SCALE
)
font_sub = ImageFont.truetype(
    "/Users/woojin/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf", 20 * SCALE
)

title = "pretty\nterminal"
subtitle = "One command to beautify your terminal."

# --- Measure layout ---
temp_draw = ImageDraw.Draw(img)
title_bbox = temp_draw.multiline_textbbox(
    (0, 0), title, font=font_title, align="center", spacing=16 * SCALE
)
tw = title_bbox[2] - title_bbox[0]
th = title_bbox[3] - title_bbox[1]

sub_bbox = temp_draw.textbbox((0, 0), subtitle, font=font_sub)
sw = sub_bbox[2] - sub_bbox[0]
sh = sub_bbox[3] - sub_bbox[1]

# Layout with generous spacing
accent_gap = 38 * SCALE
accent_to_sub = 32 * SCALE
total_h = th + accent_gap + accent_to_sub + sh
ty = (H - total_h) / 2 - 12 * SCALE
tx = (W - tw) / 2

# === Title glow — dual color bloom ===
# Purple bloom
glow_purple = Image.new("RGB", (W, H), (0, 0, 0))
gd = ImageDraw.Draw(glow_purple)
gd.multiline_text(
    (tx, ty), title,
    font=font_title, fill=PURPLE_RGB, align="center", spacing=16 * SCALE
)
glow_purple = glow_purple.filter(ImageFilter.GaussianBlur(radius=30 * SCALE))

# Cyan bloom (offset slightly down)
glow_cyan = Image.new("RGB", (W, H), (0, 0, 0))
gc = ImageDraw.Draw(glow_cyan)
gc.multiline_text(
    (tx, ty + 4 * SCALE), title,
    font=font_title, fill=CYAN_RGB, align="center", spacing=16 * SCALE
)
glow_cyan = glow_cyan.filter(ImageFilter.GaussianBlur(radius=35 * SCALE))

# Screen blend both glows onto background
img_np = np.array(img, dtype=np.float64)
gp_np = np.array(glow_purple, dtype=np.float64)
gc_np = np.array(glow_cyan, dtype=np.float64)

# Combine glows with different intensities
combined_glow = gp_np * 0.45 + gc_np * 0.25
blended = 255.0 - (255.0 - img_np) * (255.0 - combined_glow) / 255.0
img = Image.fromarray(np.clip(blended, 0, 255).astype(np.uint8), "RGB")

# === Multi-pass soft shadows ===
for offset, alpha in [(14 * SCALE, 20), (8 * SCALE, 40), (4 * SCALE, 65), (2 * SCALE, 90)]:
    shadow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow_layer)
    sd.multiline_text(
        (tx + offset, ty + offset), title,
        font=font_title, fill=(0, 0, 0, alpha), align="center", spacing=16 * SCALE
    )
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=max(1, offset // 2)))
    # Composite
    rgba_base = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    composited = Image.alpha_composite(rgba_base, shadow_layer)
    img.paste(composited.convert("RGB"), mask=composited.split()[3])

# === Main title — bright white ===
draw = ImageDraw.Draw(img)
draw.multiline_text(
    (tx, ty), title,
    font=font_title, fill=WHITE, align="center", spacing=16 * SCALE
)

# === Accent line — gradient with strong glow ===
accent_y = int(ty + th + accent_gap)
accent_w = int(min(tw * 0.55, 550 * SCALE))
accent_x0 = int((W - accent_w) / 2)
accent_h = max(2, int(2 * SCALE))

accent_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ad = ImageDraw.Draw(accent_layer)

for x in range(accent_w):
    t = x / accent_w
    edge_fade = min(t * 5, 1.0) * min((1 - t) * 5, 1.0)
    # Cyan → Purple → Pink gradient
    if t < 0.5:
        t2 = t * 2
        r = int(CYAN_RGB[0] * (1 - t2) + PURPLE_RGB[0] * t2)
        g = int(CYAN_RGB[1] * (1 - t2) + PURPLE_RGB[1] * t2)
        b = int(CYAN_RGB[2] * (1 - t2) + PURPLE_RGB[2] * t2)
    else:
        t2 = (t - 0.5) * 2
        r = int(PURPLE_RGB[0] * (1 - t2) + PINK_RGB[0] * t2)
        g = int(PURPLE_RGB[1] * (1 - t2) + PINK_RGB[1] * t2)
        b = int(PURPLE_RGB[2] * (1 - t2) + PINK_RGB[2] * t2)
    a = int(220 * edge_fade)
    for dy in range(accent_h):
        ad.point((accent_x0 + x, accent_y + dy), fill=(r, g, b, a))

# Accent glow (wider, softer)
accent_glow = accent_layer.filter(ImageFilter.GaussianBlur(radius=6 * SCALE))
accent_glow2 = accent_layer.filter(ImageFilter.GaussianBlur(radius=12 * SCALE))

# Layer glow passes
for layer in [accent_glow2, accent_glow, accent_layer]:
    rgba_base = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    composited = Image.alpha_composite(rgba_base, layer)
    img.paste(composited.convert("RGB"), mask=composited.split()[3])

# === Subtitle ===
draw = ImageDraw.Draw(img)
sx = (W - sw) / 2
sy = accent_y + accent_h + accent_to_sub

# Subtle shadow
draw.text((sx + 2 * SCALE, sy + 2 * SCALE), subtitle, font=font_sub, fill=(0, 0, 0))
# Subtitle in muted cyan
draw.text((sx, sy), subtitle, font=font_sub, fill=(160, 220, 240))

# === Subtle top/bottom border lines ===
border_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
bd = ImageDraw.Draw(border_layer)
border_w = int(W * 0.7)
border_x0 = (W - border_w) // 2
for x in range(border_w):
    t = x / border_w
    edge = min(t * 6, 1.0) * min((1 - t) * 6, 1.0)
    a = int(30 * edge)
    bd.point((border_x0 + x, int(35 * SCALE)), fill=(139, 233, 253, a))
    bd.point((border_x0 + x, H - int(35 * SCALE)), fill=(189, 147, 249, a))

border_glow = border_layer.filter(ImageFilter.GaussianBlur(radius=3 * SCALE))
rgba_base = Image.new("RGBA", (W, H), (0, 0, 0, 0))
composited = Image.alpha_composite(rgba_base, border_glow)
img.paste(composited.convert("RGB"), mask=composited.split()[3])
composited = Image.alpha_composite(rgba_base, border_layer)
img.paste(composited.convert("RGB"), mask=composited.split()[3])

# --- Save with DPI metadata ---
out = "/Users/woojin/Downloads/pretty-terminal/cover.png"
pnginfo = PngImagePlugin.PngInfo()
pnginfo.add_text("dpi", str(DPI))
img.save(out, "PNG", dpi=(DPI, DPI), pnginfo=pnginfo)
print(f"Saved to {out} ({img.width}x{img.height}, {DPI} DPI)")
