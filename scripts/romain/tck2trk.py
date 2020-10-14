import os
import argparse

import nibabel as nib
import numpy as np
from nibabel.streamlines import Field
from nibabel.orientations import aff2axcodes
from dipy.io import streamline

def build_argparser():
    DESCRIPTION = "Convert tractograms (TCK -> TRK)."
    p = argparse.ArgumentParser(description=DESCRIPTION)
    p.add_argument('anatomy', help='reference anatomy (.nii|.nii.gz.')
    p.add_argument('tractograms', metavar='tractogram', nargs="+", help='list of tractograms (.tck).')
    p.add_argument('-f', '--force', action="store_true", help='overwrite existing output files.')
    return p


def main():
    parser = build_argparser()
    args = parser.parse_args()

    try:
        nii = nib.load(args.anatomy)
    except:
        parser.error("Expecting anatomy image as first agument.")

    for tractogram in args.tractograms:
        if nib.streamlines.detect_format(tractogram) is not nib.streamlines.TckFile:
            print("Skipping non TCK file: '{}'".format(tractogram))
            continue

        output_filename = tractogram[:-4] + 'tovoxmm.trk'
        if os.path.isfile(output_filename) and not args.force:
            print("Skipping existing file: '{}'. Use -f to overwrite.".format(output_filename))
            continue

        header = {}
        header[Field.VOXEL_TO_RASMM] = nii.affine.copy()
        header[Field.VOXEL_SIZES] = nii.header.get_zooms()[:3]
        header[Field.DIMENSIONS] = nii.shape[:3]
        header[Field.VOXEL_ORDER] = "".join(aff2axcodes(nii.affine))
        print(header)

        #tck=streamline.load_tractogram(tractogram,args.anatomy)
        #tck.to_voxmm()
        #streamline.save_tractogram(tck, output_filename,True)

       tck = nib.streamlines.load(tractogram)
       nib.streamlines.save(tck.tractogram, output_filename, header=header)

if __name__ == '__main__':
    main()
