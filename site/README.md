# Site

Le site est généré depuis `layout.yml`, comme le reste. `bin/build` écrit `out/site/`.

```
site/assets/           le CSS et le testeur, écrits à la main, copiés tels quels
lib/clavier/site.rb    le rendu
lib/clavier/site/      les gabarits ERB, un par page, plus la carcasse et le clavier
```

Trois pages, en français : le clavier, apprendre, installer. La feuille A4 imprimable
(`out/sheet.html`) est copiée à côté et reste l'artefact d'impression.

## Ce qui n'est pas dupliqué

Rien de la disposition n'est écrit deux fois. Les gabarits demandent au générateur, jamais
à une copie :

- les cinq claviers viennent de `lib/clavier/boards.rb`, avec leurs vraies largeurs ;
- les quatre niveaux de chaque touche viennent de `layout.yml` ;
- la variante ISO vient de la section `iso:` de `layout.yml`, la même que lit le pilote XKB ;
- les touches mortes et les suites Compose viennent du fichier Compose du système ;
- le testeur reçoit un JSON produit par `Site#keymap_json`, jamais une table écrite à la main.

## Le testeur

`site/assets/tester.js` lit `event.code`, la position physique de la touche, et non
`event.key`, ce que le système en a fait. La démonstration marche donc quelle que soit la
disposition installée chez le visiteur. Rien n'est envoyé nulle part : le JSON est dans la
page, dans un `<script type="application/json">`.

Il gère les quatre niveaux, les touches mortes, et les suites Compose. Une touche morte
armée repeint le clavier avec ce que chaque touche produirait ensuite.

## Sans JavaScript

Tout marche sauf le testeur, qui se cache. Le choix du clavier et celui des niveaux sont
des boutons radio et des sélecteurs CSS `:has()`, pas du script. Sans `:has()`, les cinq
claviers s'affichent les uns sous les autres, ce qui reste lisible.

## Géométrie

Chaque clavier porte un champ `source` qui dit d'où viennent ses millimètres, et le site
l'affiche sous le clavier. Le ThinkPad et le Framework sont mesurés, le MacBook ne l'est
qu'en partie et le dit. Un test vérifie que chaque rangée de chaque clavier ferme
exactement à la largeur de ce clavier.
