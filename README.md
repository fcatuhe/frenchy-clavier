# Frenchy-Clavier

Une disposition AZERTY pour qui écrit en français, en anglais, et du code.

## Pourquoi

- **Français et anglais.** Bépo n'est pas adapté : il optimise le français seul, et il faut tout réapprendre.
- **Vraiment français pour les accents.** `à è é ù ç` en accès direct, majuscules accentuées comprises.
- **Basculer en anglais avec les chiffres**, sans avoir besoin des accents. Maj+Verr. maj. verrouille la rangée des chiffres.
- **Raccourcis de code**, pour VS Code comme pour Vim : `{ } [ ] < > | / \ # @ $ & ~ ^` tous atteignables d'une main.
- **AltGr facile.** Les symboles de code sont sur la main gauche, le pouce droit tient AltGr.
- **Facile à mémoriser pour un humain.** Ça reste de l'AZERTY : les lettres ne bougent pas.
- **Moins de stats, plus d'humain.** Aucune lettre n'a été déplacée pour gagner un millimètre.
- **Rapprocher les caractères qui se ressemblent.** `à è é` ensemble, `_ - +` ensemble, `« »` juste sous `< >`, l'accent grave et sa touche morte sur la même touche.
- **Adapté ISO, ANSI ou Mac.** Sur ISO, la touche à droite de la rangée du milieu devient un second Entrée, et la barre oblique inverse part sur la touche supplémentaire à gauche.

## Ce que ça donne

Quatre niveaux par touche : base, Maj, AltGr, AltGr+Maj.

| | |
|---|---|
| rangée du haut | `@ à è é ( ) " ' _ - + * ~`, les chiffres sur Maj |
| accents | `à è é` en direct, `ù` sur AltGr+U, `ç` sur AltGr+C, majuscules sur AltGr+Maj |
| code | `( )` et `" '` en direct, `{ }` sur AltGr+`(` `)`, `[ ]` sur AltGr+R T, `< >` sur AltGr+F G |
| ponctuation | `. , ? : / #` en direct, `; ! = &` sur Maj |
| typographie | `’ — – « » … · ° ± ÷ ×` et l'espace fine insécable sur AltGr+espace |

Le clavier complet, imprimable en A4, est dans `out/sheet.html` après un `bin/build`. Il montre les quatre niveaux de chaque touche, la couche Compose, et la liste des niveaux encore libres.

### Verr. maj.

Verr. maj. est la touche Compose. Maj+Verr. maj. verrouille la rangée des chiffres sur son niveau Maj, pour taper un long nombre sans tenir Maj. Le vrai Verr. maj. est les deux Maj ensemble. La diode de Verr. maj. s'allume dans les deux cas.

## Installer

### Linux

```bash
linux/install.sh
```

Puis, sous Hyprland, dans `~/.config/hypr/input.lua` :

```lua
hl.config({ input = {
  kb_layout = "frenchy,us",
  kb_options = "shift:both_capslock_cancel,grp:ctrls_toggle",
} })
```

Les deux Ctrl basculent entre Frenchy-Clavier et QWERTY US. Sur un clavier ISO, ajouter `kb_variant = "iso"`.

`compose:caps` ne doit pas rester dans `kb_options` : l'option redéfinit la touche et écrase le verrou des chiffres.

### macOS, Windows

Pas encore. Voir `macos/` et `windows/`.

## Modifier la disposition

`layout.yml` est le seul fichier à toucher. Une ligne par touche, quatre niveaux, dans l'ordre base, Maj, AltGr, AltGr+Maj. `""` marque un niveau libre, `<nom>` un keysym brut.

```yaml
  AE02: ["è", "2", "`", "È"]
  BKSL: ["\\", "|", "", ""]
```

```bash
bin/build              # linux/xkb/ et out/sheet.html
bin/apply              # installe et bascule Hyprland dessus, à chaud
ruby test/layout_test.rb
```

`bin/apply` n'écrit rien dans la configuration Hyprland. `hyprctl reload` revient en arrière.

## Ce qui tient la disposition honnête

Les tests ne vérifient pas des goûts, ils vérifient des faits :

- chaque touche de `layout.yml` existe sur un clavier ANSI, celui du ThinkPad X1 Carbon ;
- chaque rangée dessinée fait exactement la largeur du clavier ;
- les 94 caractères ASCII imprimables sont tous atteignables ;
- les fichiers produits compilent, la diode suit bien le verrou des chiffres ;
- seules les dix touches de chiffres se verrouillent.

## Structure

```
layout.yml     la disposition, source unique
compose.yml    les séquences Compose montrées sur la feuille
lib/           le générateur
linux/         les fichiers XKB produits, et l'installeur
macos/         vide, voir le README
windows/       vide, voir le README
site/          le site, plus tard
```

## Licence

MIT, François Catuhe.
