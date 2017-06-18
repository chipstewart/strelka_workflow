task strelka {

    #Inputs and constants defined here
    File tumor_bam
    File tumor_bai
    File normal_bam
    File normal_bai
    File genome
    File genome_dict
    File genome_index
    String id 
    ## datatype = 'exome' or 'wgs' ##
    String datatype
    String preemptible_limit 
    String output_disk_gb = "500"
    String boot_disk_gb = "50"
    String ram_gb = "4"
    String cpu_cores = "1"
    command {
python_cmd="
import subprocess,os
def run(cmd):
    subprocess.check_call(cmd,shell=True)

run('ln -sT `pwd` /opt/execution')
run('ln -sT `pwd`/../inputs /opt/inputs')
run('/opt/src/algutil/monitor_start.py')

# start task-specific calls
##########################

run('ln -vs ${genome} ')
run('ln -vs ${genome_dict} ')
run('ln -vs ${genome_index} ')
REFERENCE = os.path.basename('${genome}')    

run('ln -vs ${tumor_bam} ')
run('ln -vs ${tumor_bai} ')
run('ln -vs ${normal_bam} ')
run('ln -vs ${normal_bai} ')
TBAM = os.path.basename('${tumor_bam}')    
NBAM = os.path.basename('${normal_bam}')    

# somthing to chew on in to kick off stdout...
run('ls -latrh ')
run('samtools idxstats ' + TBAM)
run('samtools idxstats ' + NBAM)

# FH hydrant command 
# sh <libdir>runStrelka.sh <libdir>  ${file tumor.bam} ${file normal.bam} ${file ref} ${text individual.id} ${text config.file=strelka_config_bwa_cga_exome.ini}

LIBDIR = '/opt/src/RunStrelka'

CONFIG = '/opt/src/RunStrelka/strelka_config_bwa_cga_exome.ini'
if ${datatype} is 'wgs'
    CONFIG = '/opt/src/RunStrelka/strelka_config_bwa_cga_wgs.ini'

run('sh /opt/src/RunStrelka/RunStrelka.sh  ' + LIBDIR + '  ' + TBAM + '  ' + NBAM  + ' ' + REFERENCE + ' ${id}  ' CONFIG )

run('ls -latrh ')


run('grep -v "^#" ${id}.passed.somatic.indels.vcf | wc ')
run('grep -v "^#" ${id}.passed.somatic.snvs.vcf | wc ')

run('tar cvfz ${id}.strelka.tar.gz ${id}.all.somatic.indels.vcf ${id}.passed.somatic.indels.vcf   ${id}.all.somatic.snvs.vcf ${id}.passed.somatic.snvs.vcf')

run('/opt/src/RunStrelka/bgzip ${id}.all.somatic.indels.vcf')
run('/opt/src/RunStrelka/tabix ${id}.all.somatic.indels.vcf.gz')

run('/opt/src/RunStrelka/bgzip ${id}.passed.somatic.indels.vcf')
run('/opt/src/RunStrelka/tabix ${id}.passed.somatic.indels.vcf.gz')


run('ls -latrh ')

#########################
# end task-specific calls
run('/opt/src/algutil/monitor_stop.py')
"
        echo "$python_cmd"
        python -c "$python_cmd"

    }

    output {
        File Strelka_targz="${id}.strelka.tar.gz"
        File Strelka_passed_indels="${id}.passed.somatic.indels.vcf"
        File Strelka_passed_snvs="${id}.passed.somatic.snvs.vcf"
        File Strelka_all_indels="${id}.passed.somatic.indels.vcf"
        File Strelka_all_indels="${id}.passed.somatic.snvs.vcf"
    }

    runtime {
        docker : "docker.io/chipstewart/Strelka_workflow:1"
        memory: "${ram_gb}GB"
        cpu: "${cpu_cores}"
        disks: "local-disk ${output_disk_gb} HDD"
        bootDiskSizeGb: "${boot_disk_gb}"
        preemptible: "${preemptible_limit}"
    }


    meta {
        author : "Chip Stewart"
        email : "stewart@broadinstitute.org"
    }

}

workflow strelka_workflow {
    call strelka
}
