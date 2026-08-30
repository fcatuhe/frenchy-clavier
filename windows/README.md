# Windows

Rien ici pour l'instant.

Windows ne lit pas XKB non plus. Une disposition Windows est une DLL, produite à partir d'un fichier texte `.klc` par le Microsoft Keyboard Layout Creator, ou par `kbdutool` en ligne de commande.

Ce qui reste à faire :

- Générer le `.klc` depuis `layout.yml`. Le format donne quatre colonnes par touche (base, Maj, AltGr, AltGr+Maj), ce qui correspond exactement aux quatre niveaux de Frenchy-Clavier.
- Les touches mortes se déclarent en fin de fichier, une table par accent.
- Le verrou des chiffres n'existe pas sous Windows. Il sautera.
- Compiler la DLL avec `kbdutool -u -x`, puis fournir un installeur.

Le Microsoft Keyboard Layout Creator fait les deux, à la main, en attendant le générateur.
