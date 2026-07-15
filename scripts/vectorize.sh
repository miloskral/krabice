#!/usr/bin/env bash
# Prekreslí (zvektorizuje) fotky zložených krabíc z photos/orig/*.jpg do photos/<KOD>.jpg
# Používa mkbitmap (flatten nerovného svetla) + potrace (hladké vektorové čiary).
set -euo pipefail

mkdir -p photos
shopt -s nullglob nocaseglob

for f in photos/orig/*.jpg photos/orig/*.jpeg; do
  name="$(basename "$f")"
  name="${name%.*}"                 # napr. SPD074
  out="photos/${name}.jpg"

  tmpg="$(mktemp).pgm"
  tmpb="$(mktemp).pbm"
  tmps="$(mktemp).svg"
  tmpp="$(mktemp).png"

  # 1) šedotón, narovnať orientáciu, rozumná veľkosť
  convert "$f" -auto-orient -colorspace Gray -resize '2400x2400>' "$tmpg"

  # 2) highpass filter (zrovná krémovú stránku aj nerovné svetlo) + prah na bitmapu
  #    -f = polomer filtra (väčší = viac zrovná pozadie), -t = prah čiernej
  mkbitmap "$tmpg" -x -f 24 -t 0.42 -s 2 -o "$tmpb"

  # 3) vektorizácia na hladké čiary
  #    -t = odstrániť fliačiky menšie ako N, -a = zaoblenie rohov, -O = optimalizácia kriviek
  potrace "$tmpb" -b svg -t 12 -a 1.0 -O 0.3 --tight -o "$tmps"

  # 4) render na čistý náhľad (čierne čiary na bielom)
  rsvg-convert -w 1600 "$tmps" -o "$tmpp"
  convert "$tmpp" -background white -flatten -trim +repage \
          -bordercolor white -border 70 -resize '1400x1400>' "$out"

  echo "  -> $out"
  rm -f "$tmpg" "$tmpb" "$tmps" "$tmpp"
done

echo "Hotovo."
