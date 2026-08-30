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

`bin/static-build` appelle d'abord `../bin/build`, parce que la feuille A4 imprimable que le
site propose au téléchargement est rendue par le générateur, pas par Rails.

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

- les cinq claviers viennent de `lib/clavier/boards.rb`, avec leurs vraies largeurs ;
- les quatre niveaux de chaque touche viennent de `layout.yml` ;
- la variante ISO vient de la section `iso:` de `layout.yml`, la même que lit le pilote XKB ;
- les touches mortes et les suites Compose viennent du fichier Compose du système ;
- le testeur reçoit un JSON produit par `Clavier::Keymap`, jamais une table écrite à la main.

`config/application.rb` charge le générateur depuis le dossier parent, et
`Rails.application.config.clavier.root` dit où trouver `layout.yml`.

## Le testeur

Le contrôleur Stimulus lit `event.code`, la position physique de la touche, et non
`event.key`, ce que le système en a fait. La démonstration marche donc quelle que soit la
disposition installée chez le visiteur. Rien n'est envoyé nulle part : le JSON est dans la
page, dans un `<script type="application/json">`.

Il gère les quatre niveaux, les touches mortes, et les suites Compose. Une touche morte
armée repeint le clavier avec ce que chaque touche produirait ensuite.

## Sans JavaScript

Tout marche sauf le testeur, qui reste caché tant que son contrôleur ne s'est pas connecté.
Le choix du clavier et celui des niveaux sont des boutons radio et des sélecteurs CSS
`:has()`, pas du script. Sans `:has()`, les cinq claviers s'affichent les uns sous les
autres, ce qui reste lisible.

## Géométrie

Chaque clavier porte un champ `source` qui dit d'où viennent ses millimètres, et le site
l'affiche sous le clavier. Le ThinkPad et le Framework sont mesurés, le MacBook ne l'est
qu'en partie et le dit. Un test vérifie que chaque rangée de chaque clavier ferme exactement
à la largeur de ce clavier.

## Deux écarts avec rails-static

- Le gabarit déclare `<meta charset="utf-8">`. Rails envoie l'encodage dans l'en-tête HTTP,
  mais un fichier statique servi sans en-tête retombe en Latin-1, et une page pleine
  d'accents ne pardonne pas.
- Le thème Rouge est généré dans ses deux variantes, claire et sombre, sous une
  `@media (prefers-color-scheme: dark)`.
