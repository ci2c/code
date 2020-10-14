#!/bin/bash

echo "
1) Analyse standard : pour recaler l'ASL dasn l'espace du MNI, puis calcul CBF par rapport au template aal.mnc

2) Correction mouvements ASl : pour effectuer un simple recalage et générer la carto

3) Correction et recalage non-linéaire : appliquer un recalage non linéaire d'ASL pour mieux fitter le template (analyse très longue) et pas toujours correcte

4) traitement de ROIs : Calcul les valeurs de CBF pour chaque ROIs si vous avez déjà corriger les images

5) analyse freesurfer (en développement) : Segmente le 3DT1 puis calcul les valeurs de CBF pour chaque regions du volume (plus précis que le template mais analyse très longue). On mappe aussi le CBF sur la surface corticale, c'est très beau !!

"
