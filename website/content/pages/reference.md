---
title: Référence
description: L'AZERTY ISO, l'AZERTY Mac et le QWERTY US, pour comparer.
position: 1
---

<section class="hero" markdown="1">

# Référence

Les claviers que frenchy-clavier remplace, pour comparer avec <%= link_to_page "index" %>.

</section>

## AZERTY, Framework Laptop 13 ISO

Le clavier français standard, tel que Linux le sert sous le nom `fr`. C'est lui que la page d'accueil grise : une touche grisée là-bas est identique ici.

<figure class="reference">
  <%= render "keyboards/board", board: Keyboard.iso, keys: Keyboard.azerty, diff: false %>
</figure>

## AZERTY Mac, MacBook clavier français

Le français d'Apple, qui n'est pas celui du PC : `@ #` en haut à gauche, `§` et `!` sur la rangée des chiffres, `` ` £ `` à côté de ⏎, `= +` en bas à droite. Les touches portent les symboles d'Apple, et la troisième couche est celle d'Option (alt), avec ce qu'elle donne vraiment sur un Mac, `‡` sur Q compris.

<figure class="reference">
  <%= render "keyboards/board", board: Keyboard.macbook_fr, keys: Keyboard.azerty_mac, diff: false %>
</figure>

## QWERTY US, ThinkPad X1 Carbon Gen 6

Le clavier américain, ce que frenchy-clavier garde à portée des deux Ctrl pour basculer.

<figure class="reference">
  <%= render "keyboards/board", board: Keyboard.thinkpad, keys: Keyboard.qwerty_us, diff: false %>
</figure>
