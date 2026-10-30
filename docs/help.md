taf-samtools 1.25-r1

Purpose:
  Process SAM/BAM/CRAM files with SAMtools and HTSlib 1.25. Includes terminal
  viewing and upstream static HTML/PNG plots; no browser server is needed.

Usage:
  taf-samtools -- --help
  taf-samtools -- --version
  taf-samtools samtools SUBCOMMAND [ARGS...]
  taf-samtools COMMAND [ARGS...]

Common tasks:
  taf-samtools samtools view -b -o input.bam input.sam
  taf-samtools samtools sort -o sorted.bam input.bam
  taf-samtools samtools index sorted.bam
  taf-samtools samtools quickcheck sorted.bam
  taf-samtools samtools flagstat sorted.bam
  taf-samtools samtools stats sorted.bam > stats.txt
  taf-samtools samtools depth sorted.bam > depth.tsv
  taf-samtools bgzip -c regions.bed > regions.bed.gz
  taf-samtools tabix -p bed regions.bed.gz

Plots and viewing:
  taf-samtools plot-bamstats -p plots/ stats.txt
  Open plots/index.html together with its PNG files; keep the folder intact.
  Use a new relative output prefix without spaces or shell metacharacters.
  Reusing a plot prefix overwrites its files. The same commands work on all
  three backends. On narrow screens, scroll the upstream fixed-width report.
  taf-samtools samtools tview -d T sorted.bam reference.fa
  Interactive terminal (press q to quit):
  Docker: TAFFISH_DOCKER_RUN_ARGS="-t" TAFFISH_CONTAINER_BACKEND=docker taf-samtools env TERM=xterm samtools tview sorted.bam reference.fa
  Podman: TAFFISH_PODMAN_RUN_ARGS="-t" TAFFISH_CONTAINER_BACKEND=podman taf-samtools env TERM=xterm samtools tview sorted.bam reference.fa
  Apptainer: TAFFISH_CONTAINER_BACKEND=apptainer taf-samtools env TERM=xterm samtools tview sorted.bam reference.fa

References and shared inputs:
  CRAM may need its exact reference. Select it explicitly:
  taf-samtools samtools faidx reference.fa
  taf-samtools samtools view -T reference.fa -b -o decoded.bam input.cram
  An administrator can prepare FASTA plus .fai once for read-only reuse.
  Set REFS to an existing directory containing the matching reference and index:
  Docker: TAFFISH_DOCKER_RUN_ARGS="-v $REFS:/refs:ro" TAFFISH_CONTAINER_BACKEND=docker taf-samtools samtools view -T /refs/reference.fa -b -o decoded.bam input.cram
  Podman: TAFFISH_PODMAN_RUN_ARGS="-v $REFS:/refs:ro" TAFFISH_CONTAINER_BACKEND=podman taf-samtools samtools view -T /refs/reference.fa -b -o decoded.bam input.cram
  Apptainer: TAFFISH_APPTAINER_RUN_ARGS="--bind $REFS:/refs:ro" TAFFISH_CONTAINER_BACKEND=apptainer taf-samtools samtools view -T /refs/reference.fa -b -o decoded.bam input.cram
  Those short bind examples assume REFS has no spaces; see README for quoting.
  To create an optional local sequence cache from your own FASTA:
  taf-samtools seq_cache_populate.py -root ref-cache reference.fa
  Full shared-cache, offline and permissions instructions are in the README.

Inputs and outputs:
  Supply alignment files, references or sorted tables for the chosen command.
  Outputs include alignments, index sidecars, statistics, PNG and HTML.
  Keep input/output paths visible to the container; sorting needs temporary disk.
  Use -T /refs/reference.fa for read-only references with a prebuilt .fai.
  No reference, model or database is bundled; reference licenses remain yours.

Immediate notes:
  SAMtools subcommands are not executables: use "taf-samtools samtools view".
  In command mode, retain literal quotes around spaced arguments, for example:
  taf-samtools samtools view -b -o "'out file.bam'" "'input file.sam'"
  URL input and implicit CRAM reference lookup may contact upstream services.
  For offline work, pass the matching local reference and disable backend network.
  BCFtools and external HTSlib plugins are separate; ref-cache HTTP serving is
  outside this app's supported CLI/local-reference scope.
  Checksum format defaults to 2.0; use --version-1 only for legacy compatibility.

More help:
  taf-samtools samtools view --help
  taf-samtools plot-ampliconstats -help
  https://github.com/taffish/samtools
  https://www.htslib.org/doc/samtools.html

Wrapper options:
  taf-samtools --help       Show this TAFFISH help.
  taf-samtools --version    Show wrapper version.
  taf-samtools --compile    Print generated shell code.
  taf-samtools -- --help    Show upstream help.
