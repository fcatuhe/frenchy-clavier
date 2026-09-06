# Site

[frenchy-clavier.azade.dev](https://frenchy-clavier.azade.dev)

Une application Rails qui ne sert jamais de requête : elle est construite en fichiers
statiques par Parklife, et déployée sur GitHub Pages. La recette est celle de
[rails-static](https://github.com/fcatuhe/rails-static) : Decant pour le contenu, kramdown
pour le markdown, Rouge pour la coloration, Parklife pour la sortie, Importmap, Turbo et
Stimulus pour le navigateur.

```bash
cd site
bin/setup            # les gems
bin/dev              # http://localhost:3000
bin/static-build     # site/build
```

`bin/static-build` appelle d'abord `../bin/build`, parce que la page à imprimer,
`public/imprimer.html` servie sur `/imprimer`, est rendue par le générateur, pas par Rails.

## Où vit quoi

```
content/pages/*.md            les trois pages, en français, frontmatter + markdown + ERB
app/views/keyboards/          les partiels qui dessinent un clavier, une touche, l'étage
app/helpers/keyboards_helper  les classes CSS de géométrie, calculées depuis les claviers
app/models/keyboard.rb        le pont vers le générateur, un dossier plus haut
app/javascript/controllers/   le contrôleur Stimulus du testeur
app/assets/stylesheets/       le style, et le thème Rouge dans ses deux variantes
```

## Rien n'est écrit deux fois

Le markdown porte la prose et rien d'autre. Tout ce qui décrit la disposition est demandé au
générateur au moment du rendu :

- les deux claviers, ISO et ANSI, viennent de `lib/clavier/boards.rb`, avec leurs vraies largeurs ;
- l'AZERTY et le QWERTY US de la page Référence viennent de `lib/clavier/reference.rb`, et c'est le même AZERTY, comparé niveau par niveau, qui dit ce que l'accueil grise ;
- les quatre niveaux de chaque touche viennent de `layout.yml` ;
- la variante ISO vient de la section `iso:` de `layout.yml`, la même que lit le pilote XKB ;
- les touches mortes et les suites Compose du testeur viennent du fichier Compose du système ;
- le testeur reçoit un JSON produit par `Clavier::Keymap`, jamais une table écrite à la main.

`config/application.rb` charge le générateur depuis le dossier parent, et
`Rails.application.config.clavier.root` dit où trouver `layout.yml`.

## Le testeur

Le contrôleur Stimulus lit `event.code`, la position physique de la touche, et non
`event.key`, ce que le système en a fait. La démonstration marche donc quelle que soit la
disposition installée chez le visiteur. Rien n'est envoyé nulle part : le JSON est dans la
page, dans un `<script type="application/json">`.

Il gère les quatre niveaux, les touches mortes et les suites Compose. Une touche morte
armée repeint le clavier avec ce que chaque touche produirait ensuite.

## Sans JavaScript

Tout marche sauf le testeur, qui reste caché tant que son contrôleur ne s'est pas connecté.
Le choix ISO ou ANSI et le grisé de l'AZERTY sont des boutons radio, une case à cocher et
des sélecteurs CSS `:has()`, pas du script. Sans `:has()`, les deux claviers s'affichent
l'un sous l'autre, ce qui reste lisible.

## Géométrie

Le site dessine le Framework Laptop 13, en ISO et en ANSI, sans sa rangée de fonctions. Un
test vérifie que chaque rangée de chaque clavier ferme exactement à la largeur de ce clavier.

## Deux écarts avec rails-static

- Le gabarit déclare `<meta charset="utf-8">`. Rails envoie l'encodage dans l'en-tête HTTP,
  mais un fichier statique servi sans en-tête retombe en Latin-1, et une page pleine
  d'accents ne pardonne pas.
- Le thème Rouge est généré dans ses deux variantes, claire et sombre, sous une
  `@media (prefers-color-scheme: dark)`.
