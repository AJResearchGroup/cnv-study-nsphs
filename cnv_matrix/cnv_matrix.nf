nextflow.enable.dsl=2

process filter_cnvs {
  cpus 1
  time '10m'
  beforeScript 'ml R_packages'

  input:
    path variants
  output:
    path "*_filtered.bed"
  shell:
    template 'filter_variants.R'
}

process make_windows {
  cpus 4
  time '30m'

  input:
    path variants
  output:
    path 'windows.bed'
  shell:
    template 'makewindows.sh'
}

process align_cnvs {
  cpus 2
  time '1h'

  input:
    path variants
    path windows
    val sample_size
  output:
    path '*_200bp.bed', emit 'cnv_calls/aligned'
  shell:
    template 'align_cnvs.bed'
}

process assemble_matrix {
  cpus 4
  time '1h'

  input:
    path bed_files
  output:
    'cnv_matrix.txt', emit 'cnv_calls/matrix'
  shell:
    template: 'assemble_matrix.R'
}

workflow create_matrix {
  take:
    raw_variants
    qc_variants
  main:
    filter_cnvs(raw_variants)
    filtered_cnvs = filter_cnvs.out.collect()
    num_samples = filtered_cnvs.size()
    make_windows(filtered_cnvs)
    align_cnvs(qc_variants, make_windows.out, num_samples)
  emit:
    align_cnvs.out
}

params.raw_variants="/proj/sens2016007/nobackup/disentanglement/cnv_calls/raw/*"
params.qc_variants="/proj/sens2016007/nobackup/disentanglement/cnv_calls/qc/*"

workflow {
  create_matrix(params.raw_variants, params.qc_variants)
  create_matrix.out.view()
}