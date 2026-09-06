# macOS

Deux fichiers produits par `bin/build`, depuis `layout.yml` comme les fichiers XKB :

```
frenchy-iso.keylayout    MacBook français, ou tout clavier ISO
frenchy-ansi.keylayout   MacBook US, ou tout clavier ANSI
```

```bash
macos/install.sh
```

Il les copie dans `~/Library/Keyboard Layouts`. Il faut ensuite fermer la session et la réouvrir, puis ajouter la disposition dans Réglages Système > Clavier > Sources de saisie > Modifier > +, à la rubrique Autres. Aucune signature n'est nécessaire pour un `.keylayout` posé à la main.

## Ce que macOS rend

| | |
|---|---|
| les quatre niveaux | quatre tables : base, Maj, Option, Option+Maj. Option (⌥) joue AltGr et prend la place des caractères Option d'Apple |
| les touches mortes | `<action>` et `<when state=>`, avec les mêmes tables que sous Linux : elles viennent du fichier Compose de libX11, celui que le site lit déjà |
| Verr. maj. | quatre tables de plus : les lettres passent en majuscules, Option comprise, Maj les redescend, et la rangée des chiffres comme la ponctuation ne bougent pas |
| ⌘ | les tables de base, donc ⌘Z est sous la touche Z de frenchy, comme sur un Mac français |

Une touche dont les deux niveaux AltGr sont vides répond à Option ce qu'elle répond sans lui : `_` reste `_`. C'est ce que fait la disposition Linux, où XKB ramène ces touches à deux niveaux. Le test compare les deux, touche par touche et modificateur par modificateur, contre le clavier que libxkbcommon compile.

## Ce que macOS ne rend pas

Un `.keylayout` fait parler les touches, il ne fait rien d'autre : une touche modificatrice n'y produit rien, et il n'y a ni cinquième niveau ni action de verrouillage. Donc :

- **Compose sur Verr. maj.** n'existe pas. Karabiner-Elements peut envoyer F19 sur `caps_lock`, et le générateur donnerait alors à ce code de touche une action ouvrant un état `compose` alimenté par `compose.yml`. Non fait.
- **Le verrou des chiffres** (Maj + Verr. maj.) n'a aucun équivalent. Il saute.
- **Verr. maj. par les deux Maj** non plus. Karabiner seul saurait.

## Le piège des codes de touches

macOS numérote les touches par position, et l'ISO d'Apple échange deux codes par rapport à l'ANSI : 10 est la touche en haut à gauche, 50 celle à gauche du Z, alors qu'en ANSI 50 est celle du haut. `lib/clavier/mac_codes.rb` en tient compte, la variante ISO pose donc `@` sur 10 et `#` sur 50. Ces deux touches sont les premières à vérifier sur du vrai matériel.
