---
title: Installer
description: Poser frenchy-clavier sur Linux, et ce qu'il reste à faire pour macOS et Windows.
position: 2
---

<section class="hero" markdown="1">

# Installer

Linux marche aujourd'hui, avec un script qui ne demande pas Ruby. macOS et Windows demandent chacun un autre format de fichier, et ne sont pas encore écrits.

</section>

## Linux

XKB lit la disposition depuis `~/.config/xkb`, sans droits d'administrateur et sans toucher au système. Le script y copie quatre fichiers.

```bash
git clone https://github.com/fcatuhe/frenchy-clavier
cd frenchy-clavier
linux/install.sh
```

<p class="warn" markdown="1">
C'est un script shell qui écrit dans votre configuration. Il fait dix lignes, [lisez-le avant](https://github.com/fcatuhe/frenchy-clavier/blob/main/linux/install.sh){:target="install"}. Il n'utilise pas `sudo`.
</p>

### Hyprland

Dans `~/.config/hypr/input.lua` :

```lua
hl.config({ input = {
  kb_layout = "us,frenchy",
  kb_options = "caps:none,grp:ctrls_toggle",
} })
```

Les deux Ctrl basculent entre frenchy-clavier et QWERTY US. Sans variante c'est l'ISO, le clavier de la plupart des Français. Sur un clavier ANSI, ajoutez `kb_variant = ",ansi"` : une variante par disposition, celle du QWERTY reste vide.

### GNOME, KDE, X11

La disposition s'annonce dans le registre XKB, donc elle apparaît dans la liste des dispositions du système sous le nom **frenchy-clavier**, avec ses deux variantes ISO et ANSI. Rien de plus à faire.

<details markdown="1">
<summary>Deux options à ne pas ajouter</summary>

`compose:caps` et `shift:both_capslock_cancel` : la disposition fait déjà les deux, et les options écraseraient le verrou des chiffres.

</details>

<details markdown="1">
<summary>Pourquoi <code>caps:none</code></summary>

Uniquement parce qu'une seconde disposition partage le clavier. Sans elle, le `Caps_Lock` du groupe QWERTY pose le modificateur Lock sur la touche, et un modificateur appartient à la touche et non au groupe : Compose verrouillerait les majuscules avec lui. Le prix est que Verr. maj. ne fait plus rien du côté QWERTY.

</details>

## macOS

Pas encore. macOS ne lit pas XKB : il faut un bundle contenant un `.keylayout`, un XML qui liste, pour chaque combinaison de modificateurs, le caractère produit par chaque code de touche. Le format accepte les touches mortes, donc tout ce que fait frenchy-clavier est exprimable.

Deux choses ne survivront pas au portage, et autant le dire tout de suite : le verrou des chiffres n'a pas d'équivalent, et AltGr n'existe pas. C'est Option qui tiendrait le troisième niveau, et Apple s'en sert déjà.

## Windows

Pas encore. Il faut un `.klc`, compilé par le Microsoft Keyboard Layout Creator en un pilote à installer. Les touches mortes passent, le verrou des chiffres non.

## Changer la disposition

`layout.yml` est le seul fichier à toucher. Une ligne par touche, quatre niveaux, dans l'ordre direct, Maj, AltGr, AltGr+Maj. `""` marque un niveau libre, `<nom>` un keysym brut.

```yaml
AE02: ["è", "2", "`", "È"]
BKSL: ["\\", "|", "", ""]
```

Puis :

```bash
bin/build              # les fichiers XKB et la feuille A4
bin/apply              # installe et bascule Hyprland dessus, à chaud
bin/test               # les tests
site/bin/static-build  # le site, dans site/build
```

`bin/apply` n'écrit rien dans la configuration Hyprland. `hyprctl reload` revient en arrière.
