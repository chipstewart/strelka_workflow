tumorbam=test_bams/tumor_something.bam
normalbam=test_bams/normal_something.bam

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
		echo "WARNING: COULDN'T CREATE SYMLINK"
	fi
}

create_bam_symlinks $tumorbam tumor
create_bam_symlinks $normalbam normal
