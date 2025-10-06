#!/bin/sh
# images.sh — compare ./Resources (or ./Resource) images vs any *.xcassets under current dir
# Works on macOS /bin/sh (BSD find), no arrays, no eval.

set -eu

# --- locate Resources folder (supports "Resources" or "Resource") ---
if [ -d "./Resources" ]; then
  RES_DIR="./Resources"
elif [ -d "./Resource" ]; then
  RES_DIR="./Resource"
else
  echo "❌ Neither ./Resources nor ./Resource found next to this script." >&2
  exit 1
fi

TMPDIR="${TMPDIR:-/tmp}"
ASSET_TMP="$(mktemp "${TMPDIR%/}/assets_names.XXXXXX")"
RESMAP_TMP="$(mktemp "${TMPDIR%/}/res_map.XXXXXX")"
UNUSED_TMP="$(mktemp "${TMPDIR%/}/unused_paths.XXXXXX")"
trap 'rm -f "$ASSET_TMP" "$RESMAP_TMP" "$UNUSED_TMP"' EXIT INT HUP

normalize_name() {
  # input: $1 = base filename
  base="$1"
  # strip extension (last dot segment)
  base=$(printf '%s' "$base" | sed -E 's/\.[^.]+$//')
  # strip @2x/@3x suffix
  base=$(printf '%s' "$base" | sed -E 's/@[23]x$//')
  printf '%s\n' "$base"
}

# --- collect asset names from all *.xcassets ---
# 1) imageset folder names (Foo.imageset -> Foo)
find . -type d -name "*.xcassets" -print0 \
| xargs -0 -I{} find "{}" -type d -name "*.imageset" -print0 \
| xargs -0 -n1 basename \
| sed -E 's/\.imageset$//' \
>> "$ASSET_TMP"

# 2) "filename" entries inside Contents.json
if command -v jq >/dev/null 2>&1; then
  find . -type d -name "*.xcassets" -print0 \
  | xargs -0 -I{} find "{}" -type f -name Contents.json -print0 \
  | xargs -0 -n1 jq -r '..|.filename? // empty' \
  >> "$ASSET_TMP"
else
  find . -type d -name "*.xcassets" -print0 \
  | xargs -0 -I{} find "{}" -type f -name Contents.json -print0 \
  | xargs -0 -n1 grep -hoE '"filename"\s*:\s*"[^"]+"' \
  | sed -E 's/.*"filename"\s*:\s*"([^"]+)".*/\1/' \
  >> "$ASSET_TMP"
fi

# normalize & uniquify asset names
tmp_norm="$(mktemp "${TMPDIR%/}/assets_norm.XXXXXX")"
trap 'rm -f "$ASSET_TMP" "$RESMAP_TMP" "$UNUSED_TMP" "$tmp_norm"' EXIT INT HUP
awk 'NF' "$ASSET_TMP" | while IFS= read -r fn; do
  bn=$(basename -- "$fn" 2>/dev/null || echo "$fn")
  normalize_name "$bn"
done | sort -u > "$tmp_norm"
mv "$tmp_norm" "$ASSET_TMP"

# --- scan Resources; filter by extension via case (no regex/parentheses) ---
found_any=0
find "$RES_DIR" -type f -print0 \
| while IFS= read -r -d '' f; do
    case "$f" in
      *.png|*.PNG|*.jpg|*.JPG|*.jpeg|*.JPEG|*.gif|*.GIF|*.webp|*.WEBP|*.pdf|*.PDF|*.heic|*.HEIC|*.svg|*.SVG|*.tiff|*.TIFF|*.bmp|*.BMP)
        found_any=1
        bn=$(basename -- "$f")
        nn=$(normalize_name "$bn")
        printf '%s\t%s\n' "$nn" "$f"
        ;;
    esac
  done > "$RESMAP_TMP"

# The subshell above can’t update found_any; check file instead:
if [ ! -s "$RESMAP_TMP" ]; then
  echo "ℹ️ No image files found in $RES_DIR (extensions: png/jpg/jpeg/gif/webp/pdf/heic/svg/tiff/bmp)"
  exit 0
fi

# compare resource names to asset names
while IFS=' ' read -r nn path; do
  if ! grep -Fxq "$nn" "$ASSET_TMP"; then
    printf '%s\n' "$path" >> "$UNUSED_TMP"
  fi
done < "$RESMAP_TMP"

if [ ! -s "$UNUSED_TMP" ]; then
  res_count=$(wc -l < "$RESMAP_TMP" | tr -d ' ')
  asset_count=$(wc -l < "$ASSET_TMP" | tr -d ' ')
  echo "✅ All images in $RES_DIR have corresponding entries in your .xcassets."
  echo "   (scanned $res_count files in $RES_DIR; found $asset_count asset names)"
  exit 0
fi

echo "🧹 Images in $RES_DIR NOT present in any .xcassets:"
awk '{printf " - %s\n",$0}' "$UNUSED_TMP"

echo
echo "Total size of these files:"
# avoid argv too long
cat "$UNUSED_TMP" | xargs du -ch | tail -n1

exit 2
