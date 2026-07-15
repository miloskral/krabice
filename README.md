# Krabice · štruktúrny dizajn

Webová aplikácia (katalóg rozkresov krabíc) — beží priamo v prehliadači, aj na mobile.

## Čo appka vie
- **Katalóg** 196 rozkresov krabíc (SVG v skutočných rozmeroch mm).
- **Zmena rozmerov** — klikni na stenu v rozkrese, zadaj rozmer v mm, celý rozkres sa pomerovo prepočíta. Export **SVG** aj **DXF** v mm (na tlač / rezací plotter).
- **Foto zložených krabíc** — v detaile krabice odfotíš zloženú krabicu z knihy priamo fotoaparátom telefónu. Fotka sa uloží pod kódom rozkresu (napr. `SPD194.jpg`), aby sa dala ľahko zaradiť do katalógu.

## Ako pridať foto do katalógu
1. V appke otvor krabicu → **📷 Odfotiť z knihy** → odfoť → **Uložiť fotku**.
2. Fotka sa stiahne pomenovaná podľa kódu (`SPD194.jpg`).
3. Prekreslená verzia sa vloží do priečinka `photos/` pod rovnakým názvom a v katalógu sa automaticky zobrazí ako náhľad.

## Štruktúra
- `index.html` — celá aplikácia (HTML + CSS + JS)
- `catalog.js` — metadáta krabíc (rozmery, rodina, ryhy)
- `folddata.js` — predpočítané čiary rozkresov (pre zmenu rozmerov, funguje offline)
- `svg/` — rozkresy v mm
- `photos/` — náhľady zložených krabíc (prekreslené)

## Spustenie
Otvor `index.html` v prehliadači. Online cez GitHub Pages: zapni Pages v *Settings → Pages → Branch: main / root*.
