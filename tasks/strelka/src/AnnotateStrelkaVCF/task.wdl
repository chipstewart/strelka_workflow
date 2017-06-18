composite_task AnnotateStrelkaVCF {
  step FixStrelkaVCFForAnnotation[version=5] {
    output: File("tumorOnly.fixed.vcf") as fixedVcf;
  }
  step OncotatorForStrelka[version=8] {
    input: inputFile=fixedVcf;
  }
}