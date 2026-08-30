# macOS

Rien ici pour l'instant.

macOS ne lit pas XKB. Il faut un bundle `.bundle` contenant un `.keylayout`, un fichier XML qui liste, pour chaque combinaison de modificateurs, le caractère produit par chaque code de touche. Le format accepte les touches mortes (`<action>` et `<when state=...>`), donc tout ce que fait frenchy-clavier est exprimable.

Ce qui reste à faire :

- Générer le `.keylayout` depuis `layout.yml`, comme `lib/clavier/xkb.rb` génère les fichiers Linux. La table des codes de touches macOS diffère d'evdev, il faut la mapper.
- Le verrou des chiffres (Shift+Verr. maj.) n'a pas d'équivalent macOS. Il sautera.
- AltGr n'existe pas : c'est Option (⌥) qui joue le troisième niveau, et il est déjà pris par les caractères système d'Apple.
- Empaqueter et signer le bundle, puis l'installer dans `~/Library/Keyboard Layouts/`.

Ukelele ouvre et modifie ces fichiers à la main, en attendant le générateur.
