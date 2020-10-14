#tck2trk
import nibabel as nib

tck = nib.streamlines.load(sys.argv[1] )
nib.streamlines.save(tck.tractogram, output_filename, header=header)
