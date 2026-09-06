---
title: Installer
description: Poser frenchy-clavier sur Linux, et revenir en arrière.
position: 1
---

<section class="hero" markdown="1">

# Installer

Linux aujourd'hui. macOS et Windows, pas encore.

</section>

## Linux

La disposition s'installe dans `~/.config/xkb`, sans `sudo` et sans toucher au système.

```bash
git clone https://github.com/fcatuhe/frenchy-clavier
cd frenchy-clavier
linux/install.sh
```

<p class="warn" markdown="1">
C'est un script shell qui écrit dans votre configuration. Il fait dix lignes, [lisez-le avant](https://github.com/fcatuhe/frenchy-clavier/blob/main/linux/install.sh){:target="install"}.
</p>

### Hyprland

Dans `~/.config/hypr/input.lua` :

```lua
hl.config({ input = {
  kb_layout = "us,frenchy",
  kb_options = "frenchy:capslock,grp:ctrls_toggle",
} })
```

Les deux Ctrl basculent entre frenchy-clavier et QWERTY US. Sans variante c'est l'ISO, le clavier de la plupart des Français. Sur un clavier ANSI, ajoutez `kb_variant = ",ansi"`.

`frenchy:capslock` donne Compose sur Verr. maj. et le Verr. maj. par les deux Maj aux deux dispositions, et le verrou des chiffres à frenchy seule. Le pourquoi est dans le [README](https://github.com/fcatuhe/frenchy-clavier#verr-maj).

### GNOME, KDE, X11

La disposition apparaît dans la liste des dispositions du système sous le nom **frenchy-clavier**, en ISO et en ANSI. Choisissez-la comme n'importe quelle autre.

## Revenir en arrière

Remettez `kb_layout` comme il était, ou retirez la disposition dans les réglages du système. Pour effacer les fichiers posés par le script :

```bash
rm ~/.config/xkb/{symbols,types,compat}/frenchy
rm ~/.config/xkb/rules/evdev ~/.config/xkb/rules/evdev.xml
```

## macOS, Windows

Pas encore. Chacun demande son propre format de fichier, et le verrou des chiffres n'a d'équivalent ni chez l'un ni chez l'autre.
