#!/usr/bin/env bash
# Prekreslí fotky zložených krabíc: NAJPRV oreže tesne na nákres, POTOM vektorizuje.
# Postup: nájsť rámček najväčšieho útvaru (nákres) -> crop -> mkbitmap -> potrace -> očistiť.
set -euo pipefail

mkdir -p photos
shopt -s nullglob nocaseglob

for f in photos/orig/*.jpg photos/orig/*.jpeg; do
  name="$(basename "$f")"; name="${name%.*}"        # napr. SPD074
  out="photos/${name}.jpg"

  g="$(mktemp).pgm"; c="$(mktemp).pgm"
  b="$(mktemp).pbm"; s="$(mktemp).svg"; p="$(mktemp).png"

  # 1) šedotón + narovnať orientáciu + rozumná veľkosť
  convert "$f" -auto-orient -colorspace Gray -resize '2000x2000>' "$g"

  # 2) nájsť rámček NAJVÄČŠIEHO útvaru = samotný nákres (klávesnica/prsty sú menšie/rozdrobené)
  geom="$(convert "$g" -lat 31x31+10% -negate -morphology Dilate Disk:6 \
          -define connected-components:verbose=true -connected-components 4 null: 2>&1 \
          | awk '/gray\(255\)/{a=$4+0; if(a>m){m=a; geo=$2}} END{print geo}')" || true

  # 3) orezať tesne na nákres (s malým okrajom); ak zlyhá, fallback pevný orez
  if [ -n "${geom:-}" ]; then
    convert "$g" -crop "$geom" +repage -bordercolor white -border 25 "$c"
  else
    convert "$g" -gravity North -chop 0x9% -gravity South -chop 0x12% "$c"
  fi

  # 4) zrovnať svetlo (mkbitmap) + vektorizovať na hladké čiary (potrace)
  mkbitmap "$c" -x -f 24 -t 0.42 -s 2 -o "$b"
  potrace "$b" -b svg -t 12 -a 1.0 -O 0.3 --tight -o "$s"

  # 5) render + odstrániť drobné zvyšky, čierne čiary na bielom
  rsvg-convert -w 1600 "$s" -o "$p"
  convert "$p" -background white -flatten -colorspace Gray -threshold 55% \
          -negate \
          -define connected-components:area-threshold=1400 \
          -define connected-components:mean-color=true \
          -connected-components 8 \
          -negate \
          -trim +repage -bordercolor white -border 70 -resize '1400x1400>' "$out"

  echo "  -> $out   (crop: ${geom:-fallback})"
  rm -f "$g" "$c" "$b" "$s" "$p"
done

echo "Hotovo."
