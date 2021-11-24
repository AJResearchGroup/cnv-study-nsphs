#!/bin/bash

module load ROOT/6.06.08 bioinfo-tools CNVnator
chrom=$(seq 1 22)
root_file="$(basename !{bam} .bam).root"
cnvnator -root "$root_file" -chrom $chrom -tree "!{bam}" -unique