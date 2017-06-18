#!/bin/bash -l


libdir=$1
tumorBam=$2
normalBam=$3
ref=$4
indiv=$5
config=$6

echo "start"
date

function create_bam_symlinks {
	bam=$1
	output=$2
	echo "linking $bam to $output.bam"
	ln -s $bam $output.bam

	if [ -e $bam.bai ]; then
		echo "linking $bam.bai to $output.bai"
		ln -s $bam.bai $output.bai
	elif [ -e "${bam%.*}".bai ]; then
		ln -s "${bam%.*}".bai $output.bai
		echo "linking "${bam%.*}".bai to $output.bai"
	else
		echo "WARNING: COULDN'T CREATE SYMLINKS for $bam -> $output"
	fi
}

echo "Creating symlinks to bams to avoid the potential error due to bam paths having bam in them"

create_bam_symlinks $tumorBam tumor
create_bam_symlinks $normalBam normal

STRELKA_INSTALL_DIR=${libdir}/strelka_workflow_1.0.11

$STRELKA_INSTALL_DIR/bin/configureStrelkaWorkflow_cga.pl --normal=normal.bam --tumor=tumor.bam --ref=$ref --config=${libdir}/${config} --output-dir=./analysis

make -j 4 -C ./analysis

cp -v analysis/results/all.somatic.indels.vcf $indiv.all.somatic.indels.vcf 
cp -v analysis/results/passed.somatic.indels.vcf $indiv.passed.somatic.indels.vcf 
cp -v analysis/results/all.somatic.snvs.vcf $indiv.all.somatic.snvs.vcf 
cp -v analysis/results/passed.somatic.snvs.vcf $indiv.passed.somatic.snvs.vcf 

echo "done"
date





