---
title: Le clavier
description: Une disposition AZERTY pour qui écrit en français, en anglais, et du code.
position: 0
---

<section class="hero" markdown="1">

# Une disposition AZERTY pour le français, l'anglais, et le code.

Les lettres ne bougent pas. Ce qui bouge, c'est tout le reste : **les accents en accès direct**, les chiffres sur Maj, et les signes du code sous la main gauche.

</section>

<%= render "keyboards/stage" %>

<%= render "keyboards/tester" %>

## Pourquoi

<div class="cards" markdown="1">

<div class="card" markdown="1">
### Français et anglais
Bépo n'est pas adapté : il optimise le français seul, et il faut tout réapprendre. Ici les lettres restent où elles sont.
</div>

<div class="card" markdown="1">
### Vraiment français
`à è é ù ç` en accès direct, majuscules accentuées comprises. Pas de détour par une touche morte pour écrire un mot courant.
</div>

<div class="card" markdown="1">
### Basculer en anglais
Maj + Verr. maj. verrouille la rangée des chiffres. Le clavier devient une rangée numérique, sans accent qui traîne.
</div>

<div class="card" markdown="1">
### Raccourcis de code
`{ } [ ] < > | / \ # @ $ & ~ ^` tous atteignables d'une main, pour VS Code comme pour Vim.
</div>

<div class="card" markdown="1">
### AltGr facile
Les signes du code sont sur la main gauche, le pouce droit tient AltGr. Jamais les deux mains pour une accolade.
</div>

<div class="card" markdown="1">
### Moins de stats, plus d'humain
Aucune lettre n'a été déplacée pour gagner un millimètre. Il n'y a pas de page de statistiques ici, et c'est voulu.
</div>

</div>

## Ce que ça donne

| | | |
|---|---|---|
| Rangée du haut | `@ à è é ( ) " ' _ - + * ~` | les chiffres passent sur Maj |
| Accents | `à è é` | en direct, `ù` sur AltGr+U, `ç` sur AltGr+C, majuscules sur AltGr+Maj |
| Code | `( ) " '` | en direct, `{ }` sur AltGr+`( )`, `[ ]` sur AltGr+R T, `< >` sur AltGr+F G |
| Ponctuation | `. , : ? / #` | en direct, `; = ! &` sur Maj |
| Typographie | `’ — – « » … · ° ± ÷ ×` | et l'espace fine insécable sur AltGr+espace |

Les règles derrière ces choix, les touches mortes et la couche Compose sont sur <%= link_to_page "apprendre" %>. Pour poser la disposition sur votre machine, <%= link_to_page "installer" %>.
