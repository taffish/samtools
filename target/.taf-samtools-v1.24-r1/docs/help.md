taf-samtools 1.24-r1

Purpose:
  Run SAMtools 1.24 and HTSlib 1.24 commands for SAM, BAM, CRAM, BGZF,
  tabix-indexed files, alignment statistics, conversion, and plotting.

Usage:
  taf-samtools -- --help
  taf-samtools -- --version
  taf-samtools samtools SUBCOMMAND [ARGS...]
  taf-samtools COMMAND [ARGS...]

Common workflows:
  taf-samtools samtools view -b -o input.bam input.sam
  taf-samtools samtools sort -o sorted.bam input.bam
  taf-samtools samtools index sorted.bam
  taf-samtools samtools quickcheck sorted.bam
  taf-samtools samtools flagstat sorted.bam
  taf-samtools samtools stats sorted.bam > sorted.bam.stats
  taf-samtools samtools depth sorted.bam > depth.tsv

Companion workflows:
  taf-samtools bgzip -c regions.bed > regions.bed.gz
  taf-samtools tabix -p bed regions.bed.gz
  taf-samtools htsfile sorted.bam
  taf-samtools plot-bamstats -p stats-plots/ sorted.bam.stats
  taf-samtools seq_cache_populate.py -root ref-cache reference.fa

Packaged commands:
  samtools                 Main SAM/BAM/CRAM toolkit.
  bgzip, tabix             BGZF compression and coordinate indexing.
  htsfile, annot-tsv       File identification and tabular annotation.
  ref-cache                HTSlib reference-cache inspection and management.
  plot-bamstats            Plot output from samtools stats.
  plot-ampliconstats       Plot output from samtools ampliconstats.
  wgsim                    Small read simulator.
  ace2sam, maq2sam-*       Upstream alignment converters.
  md5fa, md5sum-lite       Upstream checksum helpers.
  *.pl, *.py               Installed SAMtools conversion/cache helper scripts.

Upstream help and version:
  taf-samtools -- --help
  taf-samtools -- --version
  taf-samtools samtools view --help
  taf-samtools bgzip --help
  taf-samtools tabix --help

Inputs:
  SAM/BAM/CRAM             Alignment files accepted by SAMtools/HTSlib.
  FASTA/FASTQ              References or reads for relevant subcommands.
  BED/GFF/VCF-like files   Sorted region or annotation tables for HTSlib tools.
  Remote URLs              Require backend networking and credentials.

Key outputs:
  SAM/BAM/CRAM             Converted, filtered, sorted, or merged alignments.
  BAI/CSI/CRAI/FAI         Index sidecars from index/faidx operations.
  Text tables              Statistics, depth, coverage, and annotation output.
  PNG files                Plot helper output under the requested prefix.

Platform and resources:
  linux/amd64 and linux/arm64 are supported.
  Sorting and merging large files may require substantial temporary disk.
  samtools tview needs an interactive terminal.

Version 1.24 notes:
  view --subsample now derives its default seed from the input header.
  markdup adds --move-umi-to-tag.
  stats uses the corrected --customized-index option name.

Boundaries:
  SAMtools subcommands are not standalone commands. Use
  "taf-samtools samtools view ...", not "taf-samtools view ...".
  BCFtools is not included; use taf-bcftools for VCF/BCF workflows.
  Reference genomes and CRAM caches are not bundled.
  Remote access needs networking; the optional htslib-crypt4gh plugin is absent.

Detailed documentation:
  https://github.com/taffish/samtools
  https://www.htslib.org/doc/samtools.html

Wrapper options:
  taf-samtools --help       Show this TAFFISH help.
  taf-samtools --version    Show TAFFISH wrapper version.
  taf-samtools --compile    Print generated shell code.
  taf-samtools -- --help    Pass option-leading arguments to samtools.

Notes:
  Input and output paths must be visible to the container. The image includes
  Python, Perl URI::Escape, gnuplot, gzip, and ImageMagick for upstream helper
  paths; plot-ampliconstats thumbnails specifically require ImageMagick.
