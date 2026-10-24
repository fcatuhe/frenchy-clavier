---
title: Le clavier
description: Une disposition AZERTY taillée pour le français, l'anglais et le code.
position: 0
---

<section class="hero" markdown="1">

# Une disposition AZERTY taillée pour le français, l'anglais et le code.

Les lettres ne bougent pas. Ce qui bouge, c'est tout le reste : **les accents en accès direct**, les signes du code sous la main gauche, et Verr. num. qui rend les chiffres à la rangée du haut pour l'anglais et le code.

</section>

<div data-controller="tester" markdown="0">
<%= render "keyboards/stage" %>
<%= render "keyboards/tester" %>
</div>

## Le premier jour

Ce qu'il faut savoir pour taper dès l'installation. Le reste s'apprend en regardant le clavier ci-dessus.

| Pour | Faites |
|---|---|
| `à è é` | en direct, les trois premières touches de la rangée du haut |
| les chiffres | <kbd>Maj</kbd>. Pour l'anglais, le code ou un long nombre, <kbd>Maj</kbd> + <kbd>Verr. maj.</kbd> éteint Verr. num. : les chiffres en direct, les accents sur <kbd>Maj</kbd>. La même combinaison revient au français |
| `ç` `ù` | <kbd>AltGr</kbd> + <kbd>C</kbd>, <kbd>AltGr</kbd> + <kbd>U</kbd> |
| `É À È Ù Ç` | <kbd>AltGr</kbd> + <kbd>Maj</kbd> + la touche de la minuscule |
| `ê ë` et les autres | `^` sur la touche 8 et `¨` sur la touche 7, puis la voyelle |
| `. , : ?` | en direct sur la rangée du bas, `;` et `!` sur <kbd>Maj</kbd> |
| `' "` | la touche à droite de M |
| `-` `/` et la barre verticale | les deux touches à droite de P, `` ` `` et la barre sur <kbd>Maj</kbd> |
| `@` | la touche `²`, en haut à gauche |
| `{ }` `[ ]` `< >` | <kbd>AltGr</kbd> + `( )`, <kbd>AltGr</kbd> + <kbd>R</kbd> <kbd>T</kbd>, <kbd>AltGr</kbd> + <kbd>F</kbd> <kbd>G</kbd> |
| `« »` `€` | <kbd>AltGr</kbd> + <kbd>V</kbd> <kbd>B</kbd>, <kbd>AltGr</kbd> + <kbd>E</kbd> |
| `°` `→` `½` | <kbd>Verr. maj.</kbd> est Compose : <kbd>Verr. maj.</kbd> puis `o o`, `- >`, `1 2` |
| MAJUSCULES | les deux <kbd>Maj</kbd> ensemble, la diode s'allume, un seul <kbd>Maj</kbd> libère |

<a href="/imprimer">Imprimez le clavier</a> sur une feuille A4 et posez-la sous l'écran : elle montre tout, Compose compris.

## Pourquoi

Bépo optimise le français seul et demande de tout réapprendre. Ici les lettres restent celles de l'AZERTY, donc la mémoire des doigts sert encore, et ce qui change répond à trois besoins : écrire le français avec ses accents sans détour, passer à l'anglais sans qu'un accent traîne sur les chiffres, et coder d'une main, `{ } [ ] < > | / \ # @` sous la gauche pendant que le pouce droit tient AltGr.

Aucune touche n'a été déplacée pour gagner un millimètre à une statistique. Les voisinages sont ceux qu'un humain retient : `à è é` se suivent, `_ - +` aussi, `« »` juste sous `< >`.

Pour poser la disposition sur votre machine : <%= link_to_page "installer" %>.
