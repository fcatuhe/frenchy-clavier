---
title: Référence
description: L'AZERTY ISO et le QWERTY US ANSI, pour comparer.
position: 1
---

<section class="hero" markdown="1">

# Référence

Les deux claviers que frenchy-clavier remplace, pour comparer avec <%= link_to_page "index" %>.

</section>

## AZERTY, clavier ISO

Le clavier français standard, tel que Linux le sert sous le nom `fr`. C'est lui que la page d'accueil grise : une touche grisée là-bas est identique ici.

<figure class="reference">
  <%= render "keyboards/board", board: Keyboard.iso, keys: Keyboard.azerty, diff: false %>
</figure>

## QWERTY US, clavier ANSI

Le clavier américain, ce que frenchy-clavier garde à portée des deux Ctrl pour basculer.

<figure class="reference">
  <%= render "keyboards/board", board: Keyboard.ansi, keys: Keyboard.qwerty_us, diff: false %>
</figure>
