A single-layer Random Forest model for pixel classification (image segmentation).


This code is based on
https://github.com/HMS-IDAC/MLRFS
and
https://github.com/HMS-IDAC/MLRFSwCF

The main differences are:
> Only one Random Forest layer is implemented. This makes the model simpler to understand and faster to train/test.
> More feature options are available, notably steerable and log filters. This makes it useful for a wider range or problems (e.g. filament and point source detection).
> Parallel processing is implemented, both during training and segmentation. This makes it significantly faster to train/execute.

The main scripts are:
pixelClassifierTrain, used to train the model, and
pixelClassifier, used to segment images after the model is trained.
See those files for details and parameters to set.

Labels/annotations can be created with ImageAnnotationBot, available at https://www.mathworks.com/matlabcentral/fileexchange/64719-imageannotationbot

A sample dataset for a running demo is available at https://www.dropbox.com/s/hl6jvwyea9vwh50/DataForPC.zip?dl=0

This code uses 2-D steerable filters for feature detection, developed by Francois Aguet, available at http://www.francoisaguet.net/software.html


Developed by:
Marcelo Cicconet
marceloc.net