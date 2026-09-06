# frenchy-clavier

Une disposition AZERTY taillée pour le français, l'anglais et le code.

**[frenchy-clavier.azade.dev](https://frenchy-clavier.azade.dev)** — la disposition en ISO et en ANSI, ce qui change par rapport à l'AZERTY, et un testeur qui l'applique dans le navigateur sans rien installer.

## Pourquoi

- **Français et anglais.** Bépo n'est pas adapté : il optimise le français seul, et il faut tout réapprendre.
- **Vraiment français pour les accents.** `à è é ù ç` en accès direct, `À È É Ù Ç` sur AltGr+Maj de leur propre touche, les autres majuscules accentuées par les touches mortes.
- **Basculer en anglais avec les chiffres**, sans avoir besoin des accents. Maj+Verr. maj. verrouille la rangée des chiffres.
- **Raccourcis de code**, pour VS Code comme pour Vim : `{ } [ ] < > | / \ # @ $ & ~ ^` tous atteignables d'une main.
- **AltGr facile.** Les symboles de code sont sur la main gauche, le pouce droit tient AltGr.
- **Facile à mémoriser pour un humain.** Ça reste de l'AZERTY : les lettres ne bougent pas.
- **Moins de stats, plus d'humain.** Aucune lettre n'a été déplacée pour gagner un millimètre.
- **Rapprocher les caractères qui se ressemblent.** `à è é` ensemble, `_ - +` ensemble, `« »` juste sous `< >`, l'accent grave et sa touche morte sur la touche du tiret.
- **Adapté ISO, ANSI ou Mac.** L'ISO est la disposition par défaut, c'est le clavier de la plupart des Français : la touche à droite de la rangée du milieu devient un second Entrée, et `#` avec sa barre oblique inverse partent sur la touche supplémentaire à gauche. `kb_variant = "ansi"` pour un clavier américain.

## Ce que ça donne

Quatre niveaux par touche : base, Maj, AltGr, AltGr+Maj.

| | |
|---|---|
| rangée du haut | `@ à è é ( ) ~ ◌̈ ◌̂ * + _ =`, les chiffres sur Maj |
| accents | `à è é` en direct, `ù` sur AltGr+U, `ç` sur AltGr+C, `À È É Ù Ç` sur AltGr+Maj de la même touche, les autres majuscules accentuées par les touches mortes, `◌̈ ◌̂` sur les touches 7 et 8, `◌̀` avec le tiret et `◌́` avec la barre oblique |
| quatrième niveau | AltGr+Maj porte les majuscules accentuées, `Æ Œ ½ £ ≤ ≥` et les deux touches mortes. Le site ne le dessine pas par défaut, la feuille A4 le montre toujours |
| code | `( )` en direct, `' "` sur la touche à droite de M, `` ` `` sur Maj+`-`, `/ |` à droite de P, `{ }` sur AltGr+`(` `)`, `[ ]` sur AltGr+R T, `< >` sur AltGr+F G |
| ponctuation | `. , : ? ' / # - _ =` en direct, `\ ; ! | " · ^` sur Maj, `&` sur AltGr+É |
| typographie | `’ « » ° ± ÷ ×`, l'espace insécable sur AltGr+espace et la fine insécable sur AltGr+Maj+espace |

Le clavier complet, imprimable en A4, est dans `out/sheet.html` après un `bin/build`. Il montre les quatre niveaux de chaque touche, la couche Compose et la liste des niveaux encore libres.

Le site montre la disposition sur un clavier ISO ou ANSI, grise ce qui ne change pas par rapport à l'AZERTY, et un testeur l'applique dans le navigateur sans rien installer.

### Verr. maj.

Verr. maj. est la touche Compose, celle d'Omarchy. Maj + Verr. maj. éteint Verr. num., et la rangée des chiffres passe sur son niveau Maj : les chiffres en direct, les accents à un Maj. Le vrai Verr. maj. reste les deux Maj ensemble, comme chez Omarchy.

Le verrou des chiffres est Verr. num. lui-même, pas un verrou de plus. Verr. num. allumé, le pavé numérique tape des chiffres et la rangée du haut porte les accents ; éteint, le pavé rend ses flèches et la rangée du haut prend les chiffres. Un seul état, une seule diode, et Hyprland la rapporte déjà : `numLock` dans `hyprctl devices -j`, de quoi écrire `fc#` dans la barre sans rien sonder. C'est le procédé de `level5(level5_lock)`, celui des dispositions Neo, qu'on reprend tel quel.

Ce que ça coûte : la disposition dépend d'un état que le système possède. Omarchy démarre sur `numlock_by_default = true`, donc la session s'ouvre sur les accents. Une session qui démarre Verr. num. éteint s'ouvre sur les chiffres, et Maj + Verr. maj. remet les accents. La touche Verr. num. d'un clavier externe fait la même bascule que Maj + Verr. maj.

Une disposition installée seule porte tout : Compose, le Verr. maj. par les deux Maj et le verrou des chiffres. Ses touches Maj verrouillent par une action `LockMods` et répondent `VoidSymbol`, ce que Compose ne peut pas ignorer, donc les deux Maj referment la séquence en cours. Sous Omarchy c'est `shift:both_capslock_cancel` qui gouverne, avec le keysym `Caps_Lock` : même verrouillage, mais une séquence Compose commencée reste ouverte derrière.

Il reste une option à nous, `frenchy:digitlock`, et une seule raison de l'avoir : XKB fusionne les options après les dispositions et toujours sur le groupe 1, donc `compose:caps` écrase la touche Verr. maj. de frenchy, verrou des chiffres compris, dès que frenchy est la première disposition. L'option la repose sur chaque groupe, après le système, et l'ordre des dispositions ne compte plus.

## Installer

### Linux

```bash
linux/install.sh
```

Les fichiers vont dans `~/.config/xkb`, jamais dans `/usr/share`. `rules/evdev` reprend les règles du système par `! include %S/evdev` avant d'ajouter les siennes. Un fichier déjà là qui ne parle pas de frenchy est à quelqu'un d'autre : l'installeur le met de côté en `.bak.<date>` et le dit.

Puis, sous Hyprland, dans `~/.config/hypr/input.lua` :

```lua
hl.config({ input = {
  kb_layout = "frenchy,us",
  kb_options = "compose:caps,shift:both_capslock_cancel,grp:ctrls_toggle,frenchy:digitlock",
} })
```

Les trois premières sont celles d'Omarchy, mot pour mot : Compose sur Verr. maj., Verr. maj. par les deux Maj, et une bascule de groupe. `kb_options` remplace la valeur d'Omarchy au lieu de s'y ajouter, d'où la liste écrite en entier. Une disposition installée seule n'a besoin d'aucune : elle les porte.

Sans variante, c'est l'ISO. Sur un clavier ANSI, ajouter `kb_variant = "ansi,"` : une variante par disposition, celle du QWERTY reste vide.

`grp:ctrls_toggle` bascule les groupes par les deux Ctrl. L'exemple d'Omarchy bascule par les deux Alt, et `grp:alts_toggle` prend la touche Alt de droite pour ça : sur le groupe frenchy, AltGr ne répond plus et tout le troisième niveau disparaît. Un test le vérifie.

`frenchy:digitlock` n'ajoute que le verrou des chiffres sur Maj + Verr. maj.

### frenchy en premier

L'ordre des deux dispositions n'est pas libre sous Omarchy, et frenchy va devant :

- Hyprland résout les raccourcis écrits en lettres, `SUPER + W` et les siens, sur la première disposition et non sur celle qui est active. Omarchy le dit dans son `input.lua` et ne place le QWERTY devant que pour les dispositions non latines. frenchy devant, ces raccourcis suivent les lettres de l'AZERTY, celles qu'on tape.
- `omarchy system lock` fait `hyprctl switchxkblayout all 0` : chaque verrouillage d'écran ramène le clavier sur la première disposition. Devant, frenchy est celle qui tape le mot de passe.

Les chiffres, eux, ne changent rien : Omarchy attache ses bureaux à `code:10` à `code:19`, des positions et non des keysyms, donc les chiffres sur Maj ne leur coûtent rien.

### Ce qui reste en QWERTY

La console et l'invite de déverrouillage du disque lisent `XKBLAYOUT` dans `/etc/vconsole.conf`, qu'on ne touche pas : la phrase de passe se tape dans la disposition de l'installation, pas dans frenchy.

### macOS

```bash
macos/install.sh
```

Deux fichiers, un par matériel : ISO pour un MacBook français, ANSI pour un MacBook US. Ils vont dans `~/Library/Keyboard Layouts`, la disposition s'ajoute dans Réglages Système > Clavier > Sources de saisie après une reconnexion.

Option (⌥) joue AltGr. Verr. maj. reste Verr. maj. : ni Compose, ni verrou des chiffres, ni Verr. maj. par les deux Maj, un `.keylayout` ne sait rien faire dire à une touche modificatrice. Voir `macos/README.md`.

### Windows

Pas encore. Voir `windows/`.

## Modifier la disposition

`layout.yml` est le seul fichier à toucher. Une ligne par touche, quatre niveaux, dans l'ordre base, Maj, AltGr, AltGr+Maj. `""` marque un niveau libre, `<nom>` un keysym brut.

```yaml
  AE02: ["è", "2", "", "È"]
  AC11: ["'", "\"", "`", "<dead_grave>"]
```

```bash
bin/build              # linux/xkb/, macos/*.keylayout et la feuille A4
bin/apply              # installe et bascule Hyprland dessus, à chaud
bin/test               # les tests
site/bin/static-build  # le site, dans site/build/
```

`bin/apply` n'écrit rien dans la configuration Hyprland. `hyprctl reload` revient en arrière.

### Hyprland ne recompile pas tout seul

Hyprland compile la disposition une fois, au démarrage de la session, et ne la recompile que si une valeur de la section `input` change vraiment. Réinstaller les fichiers XKB ne suffit donc pas : `hyprctl reload` relit la configuration, n'y voit aucun changement, et garde l'ancienne disposition. `hyprctl keyword` n'aide pas non plus, il n'atteint pas un bloc `input` écrit en Lua.

`bin/apply` compare le nom que Hyprland annonce à celui de la disposition installée, et le dit quand la session est sur autre chose. Il ne voit pas une session restée sur une version précédente des mêmes fichiers : le nom n'a pas changé. Pour forcer la recompilation, il faut faire changer une valeur, puis la remettre :

```bash
sed -i 's/kb_variant = "ansi,"/kb_variant = "iso,"/' ~/.config/hypr/input.lua
hyprctl reload
sed -i 's/kb_variant = "iso,"/kb_variant = "ansi,"/' ~/.config/hypr/input.lua
hyprctl reload
```

fcitx5 garde lui aussi la disposition compilée à son démarrage, et comme son clavier virtuel est le clavier principal de la session, c'est celle-là que reçoivent les applications : `omarchy-restart-xcompose` après le `hyprctl reload`, sinon la session répond encore à l'ancienne. `xkbcli dump-keymap-wayland` montre ce qu'elle sert vraiment.

## Ce qui tient la disposition honnête

Les tests ne vérifient pas des goûts, ils vérifient des faits :

- chaque touche de `layout.yml` existe sur chacun des cinq claviers connus ;
- aucune lettre ne bouge par rapport à l'AZERTY, et la liste des touches qui changent est celle qu'on annonce ;
- chaque rangée de chaque clavier fait exactement la largeur de ce clavier ;
- les largeurs du Framework tombent sur des millimètres entiers de son propre pas ;
- la touche ISO supplémentaire n'existe que sur les claviers ISO ;
- les 94 caractères ASCII imprimables sont tous atteignables ;
- les fichiers produits compilent, et le verrou des chiffres est bien celui de Verr. num. ;
- seules les dix touches de chiffres se verrouillent, et Maj rend l'accent d'une rangée verrouillée ;
- la diode de Verr. num. s'éteint quand les chiffres sont verrouillés, c'est tout l'indicateur ;
- installée seule, la disposition porte Compose, le Verr. maj. par les deux Maj et le verrou des chiffres ;
- ses touches Maj n'entrent dans aucune table de modificateur Lock et referment la séquence Compose en cours ;
- l'option d'Omarchy verrouille bien Verr. maj., mais laisse la séquence ouverte : c'est ce qu'on accepte en la reprenant ;
- notre option ne porte que le verrou des chiffres, et atteint le groupe frenchy où qu'il soit ;
- `grp:alts_toggle` prend l'AltGr du groupe frenchy, `grp:ctrls_toggle` le laisse ;
- l'option apparaît dans le registre, là où `xkbcli list` et les sélecteurs de disposition vont la chercher ;
- aucun nom de disposition ne porte de virgule, celle qu'un indicateur de barre couperait dans l'événement `activelayout` de Hyprland ;
- les deux `.keylayout` atteignent chaque caractère de la disposition, sans donner deux sens à un code de touche, et chaque état de touche morte sait se terminer ;
- l'ISO d'Apple reçoit `@` et `#` sur les codes que son matériel envoie vraiment.

## Structure

```
layout.yml     la disposition, source unique
compose.yml    les séquences Compose montrées sur la feuille et sur le site
lib/           le générateur
linux/         les fichiers XKB produits (symboles, types, règles), et l'installeur
macos/         les .keylayout produits, et l'installeur, voir le README
windows/       vide, voir le README
site/          le site, une application Rails construite en statique, voir le README
out/           produit par bin/build, hors dépôt
```

## Les claviers connus

`lib/clavier/boards.rb` décrit cinq claviers réels, chacun à ses vraies largeurs. Le site n'en dessine que deux, le Framework en ISO et en ANSI : un visiteur a l'une ou l'autre forme, pas un modèle. La feuille A4 prend le Framework ISO.

| | forme | d'où viennent les millimètres |
|---|---|---|
| ThinkPad X1 Carbon Gen 6 | ANSI | millimètres Lenovo, via `pfaion/x1carbon-xkb-geometry` |
| Framework Laptop 13 | ANSI | le fichier CAD que Framework publie, boîtes englobantes des touches |
| Framework Laptop 13 | ISO | idem, l'ISO déduite : Framework ne publie pas ce modèle |
| MacBook, clavier US | ANSI | trois touches mesurées, le reste déduit pour que les rangées ferment |
| MacBook, clavier français | ISO | idem, plus les proportions ISO standard |

Les rangées du Framework ferment à 14,74 u, celles du MacBook à 14,5 u, celles du ThinkPad à 15 u. Chaque clavier porte la source de ses millimètres, et un test refuse un clavier qui n'en a pas.

## Licence

MIT, François Catuhe.
