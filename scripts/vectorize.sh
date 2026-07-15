#!/usr/bin/env bash
# Prekreslí fotky zložených krabíc: oreže okraje (klávesnica hore, prsty/popiska dole),
# zrovná svetlo (mkbitmap) a zvektorizuje na hladké čiary (potrace).
set -euo pipefail

mkdir -p photos
shopt -s nullglob nocaseglob

for f in photos/orig/*.jpg photos/orig/*.jpeg; do
  name="$(basename "$f")"; name="${name%.*}"        # napr. SPD074
  out="photos/${name}.jpg"

  c="$(mktemp).pgm"; b="$(mktemp).pbm"; s="$(mktemp).svg"; p="$(mktemp).png"

  # 1) narovnať orientáciu + PEVNÝ orez okrajov (hore ~13 %, dole ~14 %, boky ~2 %),
  #    šedotón, rozumná veľkosť
  convert "$f" -auto-orient \
          -gravity North -chop 0x13% \
          -gravity South -chop 0x14% \
          -gravity West  -chop 2x0% \
          -gravity East  -chop 2x0% \
          -colorspace Gray -resize '2200x2200>' "$c"

  # 2) highpass (zrovná stránku/svetlo, potlačí mäkké okraje) + prah na bitmapu
  mkbitmap "$c" -x -f 30 -t 0.42 -s 2 -o "$b"

  # 3) vektorizácia na hladké čiary
  potrace "$b" -b svg -t 14 -a 1.0 -O 0.3 --tight -o "$s"

  # 4) render + odstrániť malé zvyšky (kúsky kláves, textúra), čierne čiary na bielom
  rsvg-convert -w 1600 "$s" -o "$p"
  convert "$p" -background white -flatten -colorspace Gray -threshold 55% \
          -negate \
          -define connected-components:area-threshold=2000 \
          -define connected-components:mean-color=true \
          -connected-components 8 \
          -negate \
          -trim +repage -bordercolor white -border 80 -resize '1400x1400>' "$out"

  echo "  -> $out"
  rm -f "$c" "$b" "$s" "$p"
done

echo "Hotovo."
