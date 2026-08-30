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
- **Adapté ISO, ANSI ou Mac.** L'ISO est la disposition par défaut, c'est le clavier de la plupart des Français : la touche à droite de la rangée du milieu devient un second Entrée, et la barre oblique inverse part sur la touche supplémentaire à gauche. `kb_variant = "ansi"` pour un clavier américain.

## Ce que ça donne

Quatre niveaux par touche : base, Maj, AltGr, AltGr+Maj.

| | |
|---|---|
| rangée du haut | `@ à è é ( ) " ' _ - + * ~`, les chiffres sur Maj |
| accents | `à è é` en direct, `ù` sur AltGr+U, `ç` sur AltGr+C, majuscules sur AltGr+Maj |
| code | `( )` et `" '` en direct, `{ }` sur AltGr+`(` `)`, `[ ]` sur AltGr+R T, `< >` sur AltGr+F G |
| ponctuation | `. , : ? / #` en direct, `; = ! &` sur Maj |
| typographie | `’ — – « » … · ° ± ÷ ×` et l'espace fine insécable sur AltGr+espace |

Le clavier complet, imprimable en A4, est dans `out/sheet.html` après un `bin/build`. Il montre les quatre niveaux de chaque touche, la couche Compose, et la liste des niveaux encore libres.

Le site, dans `out/site/`, montre la même disposition sur cinq claviers réels, avec un testeur qui l'applique dans le navigateur sans rien installer.

### Verr. maj.

Verr. maj. est la touche Compose. Maj+Verr. maj. verrouille la rangée des chiffres sur son niveau Maj, pour taper un long nombre sans tenir Maj. Le vrai Verr. maj. est les deux Maj ensemble.

Les deux sont dans la disposition, aucune option à ajouter. Les touches Maj verrouillent par une action `LockMods` et non par le keysym `Caps_Lock`, sinon elles entreraient dans la table du modificateur Lock, qui appartient à la touche et pas au groupe : la moindre autre disposition partageant le clavier hériterait du verrouillage. La diode de Verr. maj. s'allume dans les deux cas.

## Installer

### Linux

```bash
linux/install.sh
```

Puis, sous Hyprland, dans `~/.config/hypr/input.lua` :

```lua
hl.config({ input = {
  kb_layout = "us,frenchy",
  kb_options = "caps:none,grp:ctrls_toggle",
} })
```

Les deux Ctrl basculent entre Frenchy-Clavier et QWERTY US. Sans variante, c'est l'ISO. Sur un clavier ANSI, ajouter `kb_variant = ",ansi"` : une variante par disposition, celle du QWERTY reste vide.

Deux options sont à écarter, `compose:caps` et `shift:both_capslock_cancel` : la disposition fait déjà les deux, et les options écraseraient le verrou des chiffres.

`caps:none` n'est là que parce qu'une seconde disposition partage le clavier. Sans elle, le `Caps_Lock` du groupe QWERTY met le modificateur Lock sur la touche, et un modificateur appartient à la touche et non au groupe : Compose verrouillerait les majuscules avec lui. Le prix est que Verr. maj. ne fait plus rien du côté QWERTY.

### macOS, Windows

Pas encore. Voir `macos/` et `windows/`.

## Modifier la disposition

`layout.yml` est le seul fichier à toucher. Une ligne par touche, quatre niveaux, dans l'ordre base, Maj, AltGr, AltGr+Maj. `""` marque un niveau libre, `<nom>` un keysym brut.

```yaml
  AE02: ["è", "2", "`", "È"]
  BKSL: ["\\", "|", "", ""]
```

```bash
bin/build              # linux/xkb/, out/sheet.html et out/site/
bin/apply              # installe et bascule Hyprland dessus, à chaud
bin/test
```

`bin/apply` n'écrit rien dans la configuration Hyprland. `hyprctl reload` revient en arrière.

## Ce qui tient la disposition honnête

Les tests ne vérifient pas des goûts, ils vérifient des faits :

- chaque touche de `layout.yml` existe sur chacun des cinq claviers dessinés ;
- chaque rangée de chaque clavier fait exactement la largeur de ce clavier ;
- les largeurs du Framework tombent sur des millimètres entiers de son propre pas ;
- la touche ISO supplémentaire n'existe que sur les claviers ISO ;
- les 94 caractères ASCII imprimables sont tous atteignables ;
- les fichiers produits compilent, la diode suit bien le verrou des chiffres ;
- seules les dix touches de chiffres se verrouillent ;
- les touches Maj n'entrent dans aucune table de modificateur Lock.

## Structure

```
layout.yml     la disposition, source unique
compose.yml    les séquences Compose montrées sur la feuille et sur le site
lib/           le générateur, et les gabarits du site
linux/         les fichiers XKB produits, et l'installeur
macos/         vide, voir le README
windows/       vide, voir le README
site/          le CSS et le testeur du site, voir le README
out/           produit par bin/build, hors dépôt
```

## Les claviers dessinés

La même disposition, rendue sur cinq claviers réels, chacun à ses vraies largeurs :

| | forme | d'où viennent les millimètres |
|---|---|---|
| ThinkPad X1 Carbon Gen 6 | ANSI | millimètres Lenovo, via `pfaion/x1carbon-xkb-geometry` |
| Framework Laptop 13 | ANSI | le fichier CAD que Framework publie, boîtes englobantes des touches |
| Framework Laptop 13 | ISO | idem, l'ISO déduite : Framework ne publie pas ce modèle |
| MacBook, clavier US | ANSI | trois touches mesurées, le reste déduit pour que les rangées ferment |
| MacBook, clavier français | ISO | idem, plus les proportions ISO standard |

Les rangées du Framework ferment à 14,74 u, celles du MacBook à 14,5 u, celles du ThinkPad à 15 u. Ce ne sont pas les mêmes claviers, et la page ne fait pas semblant du contraire. Chaque clavier affiche sa provenance sous lui.

## Licence

MIT, François Catuhe.
