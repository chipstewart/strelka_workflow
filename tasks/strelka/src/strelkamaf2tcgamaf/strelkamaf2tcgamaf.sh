#!/bin/sh

source /broad/software/scripts/useuse
use Python-2.7 

while getopts "i:m:x:o:?" Option
do
    case $Option in
        i    ) ID=$OPTARG;;
        m    ) MAF=$OPTARG;;
        x    ) EXT=$OPTARG;;
        o    ) OUT=$OPTARG;;
        ?    ) echo "Invalid option: -$OPTARG" >&2
               exit 0;;
        *    ) echo ""
               echo "Unimplemented option chosen."
               exit 0;;
    esac
done


echo "ID:              ${ID}"
echo "MAF:             ${MAF}" 
echo "Extension:       ${EXT}" 
echo "Output area:      ${OUT}" 


oopt="-o $OUT "
if [[ -z $OUT ]]; then
   echo "no output full path"
   oopt=""
   OUT="."
fi   

ls -latr ${OXOQ}

Dir=`dirname $0`

echo ""
echo "Convert strelka MAF fields to standard TCGA t_alt_count, t_ref_count : "
echo "python $Dir/strelkamaf2tcgamaf.py -i $ID -m $MAF  -x $EXT $oopt"

python $Dir/strelkamaf2tcgamaf.py -i $ID -m $MAF  -x $EXT $ooptt

echo ""
echo "done"

