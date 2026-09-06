---
title: Installer
description: Poser frenchy-clavier sur Linux, et revenir en arrière.
position: 1
---

<section class="hero" markdown="1">

# Installer

Linux et macOS aujourd'hui. Windows, pas encore.

</section>

## Linux

La disposition s'installe dans `~/.config/xkb`, sans `sudo` et sans toucher au système.

```bash
git clone https://github.com/fcatuhe/frenchy-clavier
cd frenchy-clavier
linux/install.sh
```

<p class="warn" markdown="1">
C'est un script shell qui écrit dans votre configuration. Il est court, [lisez-le avant](https://github.com/fcatuhe/frenchy-clavier/blob/main/linux/install.sh){:target="install"}. Un fichier déjà présent qui ne lui appartient pas est mis de côté en `.bak`, jamais écrasé.
</p>

### Hyprland

Dans `~/.config/hypr/input.lua` :

```lua
hl.config({ input = {
  kb_layout = "frenchy,us",
  kb_options = "compose:caps,shift:both_capslock_cancel,grp:ctrls_toggle,frenchy:digitlock",
} })
```

Les deux Ctrl basculent entre frenchy-clavier et QWERTY US. Sans variante c'est l'ISO, le clavier de la plupart des Français. Sur un clavier ANSI, ajoutez `kb_variant = "ansi,"`, une variante par disposition.

Gardez frenchy devant. Hyprland résout les raccourcis écrits en lettres sur la première disposition, jamais sur celle qui est active, et sous Omarchy le verrouillage de l'écran ramène le clavier sur elle.

Les trois premières options sont celles d'Omarchy : Compose sur Verr. maj., Verr. maj. par les deux Maj, et la bascule de groupe, ici sur les deux Ctrl pour laisser l'AltGr tranquille. `frenchy:digitlock` n'ajoute que le verrou des chiffres, sur Maj + Verr. maj. Le pourquoi est dans le [README](https://github.com/fcatuhe/frenchy-clavier#verr-maj).

### GNOME, KDE, X11

La disposition apparaît dans la liste des dispositions du système sous le nom **frenchy-clavier**, en ISO et en ANSI. Choisissez-la comme n'importe quelle autre.

## Revenir en arrière

Remettez `kb_layout` comme il était, ou retirez la disposition dans les réglages du système. Pour effacer les fichiers posés par le script :

```bash
rm -f ~/.config/xkb/{symbols,types,compat}/frenchy
rm -f ~/.config/xkb/rules/evdev ~/.config/xkb/rules/evdev.xml
```

## macOS

Deux fichiers `.keylayout`, un par matériel : ISO pour un MacBook français, ANSI pour un MacBook US.

```bash
git clone https://github.com/fcatuhe/frenchy-clavier
cd frenchy-clavier
macos/install.sh
```

Fermer la session, la réouvrir, puis ajouter la disposition dans Réglages Système > Clavier > Sources de saisie > Modifier > +, à la rubrique Autres.

Option (⌥) joue AltGr, et les touches mortes répondent comme sous Linux. Verr. maj. reste Verr. maj. : un fichier de disposition macOS ne sait rien faire dire à une touche modificatrice, donc ni Compose, ni verrou des chiffres, ni Verr. maj. par les deux Maj.

Pour la retirer, la supprimer de la liste des sources de saisie puis :

```bash
rm ~/Library/Keyboard\ Layouts/frenchy-*.keylayout
```

## Windows

Pas encore. Il demande son propre format de fichier, et le verrou des chiffres n'y a pas d'équivalent.
