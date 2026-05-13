taf-samtools 1.23.1-r1

TAFFISH wrapper for Samtools, a command-line toolkit for reading, writing,
editing, indexing, viewing, and summarizing SAM, BAM, and CRAM alignment files.

Usage:
  taf-samtools [TAF-APP-OPTION]
  taf-samtools samtools [SAMTOOLS-COMMAND] [COMMAND-ARGS...]
  taf-samtools bgzip [BGZIP-ARGS...]
  taf-samtools tabix [TABIX-ARGS...]
  taf-samtools plot-bamstats [PLOT-ARGS...]
  taf-samtools plot-ampliconstats [PLOT-ARGS...]
  taf-samtools -- [SAMTOOLS-OPTION...]
  taf-samtools <COMMAND> [COMMAND-ARGS...]

TAF app options:
  -h, --help       Show this help text
  -v, --version    Show package and command version
  --compile        Print generated shell code instead of running it
  --               Stop parsing TAFFISH wrapper options

Upstream help:
  taf-samtools samtools --help
  taf-samtools samtools --version
  taf-samtools samtools view --help
  taf-samtools samtools sort --help

Recommended Samtools examples:
  taf-samtools samtools view -bS input.sam -o input.bam
  taf-samtools samtools sort input.bam -o sorted.bam
  taf-samtools samtools index sorted.bam
  taf-samtools samtools quickcheck sorted.bam
  taf-samtools samtools flagstat sorted.bam
  taf-samtools samtools stats sorted.bam > sorted.bam.stats
  taf-samtools samtools depth sorted.bam > depth.tsv
  taf-samtools samtools mpileup -f reference.fa sorted.bam > pileup.txt
  taf-samtools samtools faidx reference.fa

Companion command examples:
  taf-samtools bgzip -c regions.bed > regions.bed.gz
  taf-samtools tabix -p bed regions.bed.gz
  taf-samtools htsfile sorted.bam
  taf-samtools plot-bamstats -p stats-plots/ sorted.bam.stats

Common Samtools subcommands:
  view
  sort
  index
  quickcheck
  flagstat
  stats
  depth
  coverage
  idxstats
  mpileup
  fastq
  fasta
  faidx
  dict
  collate
  merge
  markdup
  fixmate
  calmd
  tview

Notes:
  - This command runs Samtools inside the TAFFISH container image.
  - Use "taf-samtools samtools <SUBCOMMAND> ..." for ordinary Samtools
    workflows.
  - Use explicit command mode for companion tools available in the image, such
    as "bgzip", "tabix", "htsfile", "plot-bamstats", and
    "plot-ampliconstats".
  - Samtools subcommands such as "view", "sort", "index", and "flagstat" are
    not standalone executables in the container image. Do not use
    "taf-samtools view ..."; use "taf-samtools samtools view ...".
  - Use "--" before upstream options when an option may be handled by the
    TAFFISH wrapper itself, such as "--help" or "--version".
  - This image includes HTSlib tools and plotting helpers, but it does not
    include BCFtools. Use "taf-bcftools" for VCF/BCF workflows.
  - The image includes curses support for "samtools tview".
  - The image includes gnuplot and Perl URI::Escape for Samtools plotting
    helper scripts.
  - Input and output paths should be accessible from the current working
    directory or from mounted user paths.
  - This image packages upstream Samtools 1.23.1 with HTSlib 1.23.1 in a
    Debian 12 runtime image.

Container:
  image: ghcr.io/taffish/samtools:1.23.1-r1
  supported backends: apptainer, podman, docker

Upstream:
  project: Samtools
  homepage: https://www.htslib.org/
  manual:   https://www.htslib.org/doc/samtools.html
  source:   https://github.com/samtools/samtools
