'''
Created on Apr 9, 2013

@author: stewart
'''

import sys
import argparse
import csv
import os
import re

if not (sys.version_info[0] == 2  and sys.version_info[1] in [7]):
    raise "Must use Python 2.7.x"

def parseOptions():
    description = '''
    Add annotation value to every line in maf file.
    write new maf with <fielname>.maf extension
    '''

    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('-i', '--pair_id', metavar='pair_id', type=str, help='id : pair, sample, individual.... ')
    parser.add_argument('-m', '--maf_file', metavar='maf_file', type=str, help='maf_file.')
    parser.add_argument('-o', '--output', metavar='output', type=str, help='output area', default='output')
    parser.add_argument('-x', '--extension', metavar='extension', type=str, help='file extension', default='strelka.maf')

    args = parser.parse_args()

    return args



if __name__ == "__main__":

    args = parseOptions()
    pair_id = args.pair_id
    maf_file= args.maf_file
    output = args.output
    extension = args.extension

    if len(output)>1:
        if not os.path.exists(output):
            os.makedirs(output)

    out_maf_file = output  + '/' + pair_id + '.' + extension
    out_FP = open(out_maf_file, 'wt')

    out_FP.write("##strelkamaf2tcgamaf version 1.0\n")

    kread_depth = -1
    # required indel fields
    kTIR = -1
    # required snv fields
    kAU = -1
    kCU = -1
    kGU = -1
    kTU = -1
    kReference_Allele = -1
    kTumor_Seq_Allele2 = -1
    INDEL=False
    line1 =  ""
    newfields =  ["t_alt_count","t_ref_count","i_tumor_f"]

    try:
        fh = open(maf_file,'rt')
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
        raise


    for lines in fh:
        line=lines.strip('\n')
        if line[0:2] == '##':
            continue

        mafL = line.split('\t')
        if mafL[0] == 'Hugo_Symbol':
            kread_depth = mafL.index('read_depth')
            if "TIR" in mafL:
                kTIR = mafL.index('TIR')
            else:
                kAU = mafL.index('AU')
                kCU = mafL.index('CU')
                kGU = mafL.index('GU')
                kTU = mafL.index('TU')
                kReference_Allele = mafL.index('Reference_Allele')
                kTumor_Seq_Allele2 = mafL.index('Tumor_Seq_Allele2')

            INDEL = kTIR>0
            line=line+"\t"+"\t".join(newfields)



        elif line[0] != '#':
            chrom         = mafL[4]
            pstart        = mafL[5]
            pend          = mafL[6]
            obsAllele     = mafL[11]
            mutationType  = mafL[9]
            patientName   = mafL[15].replace('-Tumor','')
            read_depth    = int(mafL[kread_depth])
            if INDEL:
                TIRS=mafL[kTIR]
                TIR = TIRS.split(",")
                t_alt_count=int(TIR[0])

            else:
                a=mafL[kAU].split(",")
                AU=int(a[0])
                a=mafL[kCU].split(",")
                CU=int(a[0])
                a=mafL[kGU].split(",")
                GU=int(a[0])
                a=mafL[kTU].split(",")
                TU=int(a[0])
                REF=mafL[kReference_Allele]
                ALT=mafL[kTumor_Seq_Allele2]
                t_alt_count=0
                if (ALT.upper() == 'A'):
                    t_alt_count=AU
                elif (ALT.upper() == 'C'):
                    t_alt_count=CU
                elif (ALT.upper() == 'G'):
                   t_alt_count=GU
                elif  (ALT.upper() == 'T'):
                   t_alt_count=TU

            t_ref_count = read_depth-t_alt_count
            tumor_f = float(t_alt_count)/float(read_depth)

            line=line+"\t"+ "%d" % t_alt_count + "\t%d" % t_ref_count + "\t%.4f" % tumor_f

        out_FP.write(line+"\n")


    out_FP.close()
    
    print('done')
    
