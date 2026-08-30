---
title: Apprendre
description: Les règles de frenchy-clavier, ses touches mortes et sa couche Compose.
position: 1
---

<section class="hero" markdown="1">

# Apprendre

Il n'y a pas de leçons ici, parce qu'il n'y a rien à réapprendre : les lettres sont celles de l'AZERTY. Il y a des règles, et elles tiennent en une page.

</section>

## Une règle par famille

### Rapprocher ce qui se ressemble

`à è é` se suivent sur les trois premières touches. `_ - +` se suivent aussi. Les guillemets doubles `« »` sont juste sous les chevrons simples `< >`, une rangée plus bas. Rien de tout cela ne sort d'un calcul : ce sont des voisinages qu'un humain retient.

### Un accent et sa touche morte partagent une touche

Le caractère littéral et sa touche morte ne sont jamais à deux endroits différents : ils sont sur la même touche, à un niveau d'écart. L'accent grave et le sien vont ensemble, l'accent aigu et le sien aussi.

### Le code sous la main gauche

Le pouce droit tient AltGr, donc tout ce qui se tape en tenant AltGr est à gauche. Les accolades sont sur les parenthèses, les crochets sur R et T, les chevrons sur F et G.

## Touches mortes

Une touche morte ne produit rien toute seule : elle attend la lettre suivante. Sur <%= link_to_page "index" %>, appuyer sur l'une d'elles repeint le clavier avec ce qu'elle donnerait. Voici ce que chacune produit sur les voyelles.

<%= render "keyboards/dead_keys" %>

## Compose

<kbd>Verr. maj.</kbd> est la touche Compose. On l'appuie, on la relâche, puis on tape une suite courte, et le système rend un caractère. C'est la réserve : tout ce qui ne mérite pas une touche à lui vit ici.

La règle la plus facile à retenir : **la même touche deux fois**. Compose puis `o` `o` donne `°`. Voici les suites qui servent vraiment.

<%= render "keyboards/compose_table" %>

## Verrouiller les chiffres

<kbd>Maj</kbd> + <kbd>Verr. maj.</kbd> verrouille la rangée des chiffres sur son niveau Maj. On tape un long nombre sans tenir Maj, et le reste du clavier ne bouge pas : les lettres restent des minuscules.

Le vrai Verr. maj. existe toujours, c'est les **deux Maj ensemble**, et la diode ne s'allume que pour lui. Les deux sont dans la disposition, il n'y a aucune option à ajouter.

`'` et `"` vivent sur les deux touches à droite de la rangée du haut, celles que le verrou des chiffres ne touche pas. Elles restent donc en accès direct en mode chiffres, là où tout le reste de la rangée est parti sur les chiffres.

Le verrou des chiffres, lui, allume l'indicateur Verr. défil. Aucun portable ne l'affiche, mais le système le voit, et la barre d'état peut donc le montrer sans que la diode de Verr. maj. ait à dire deux choses à la fois.

## Ce qui reste libre

<%= Keyboard.layout.free_levels.size %> niveaux ne portent encore rien. Ils sont listés pour que le prochain ajout se pose là où il y a de la place, et pas sur quelque chose d'utile.

```
<%= Keyboard.layout.free_levels.each_slice(6).map { it.join("   ") }.join("\n") %>
```
