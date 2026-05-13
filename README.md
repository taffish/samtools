# taf-samtools

TAFFISH wrapper for [Samtools](https://www.htslib.org/doc/samtools.html), a
command-line toolkit for reading, writing, editing, indexing, viewing, and
summarizing SAM, BAM, and CRAM alignment files.

This repository packages upstream Samtools 1.23.1 and HTSlib 1.23.1 as a
TAFFISH tool app. It exposes upstream `samtools` through a versioned TAFFISH
entry point while keeping the runtime environment inside a portable Debian 12
container image.

## Installation

Install from the public TAFFISH Hub index:

```sh
taf update
taf install samtools
```

Install the exact release:

```sh
taf install samtools 1.23.1-r1
```

For local testing before the app is published to the public index:

```sh
taf install --from .
```

## Usage

Show TAFFISH app help:

```sh
taf-samtools --help
```

Show upstream Samtools help and version:

```sh
taf-samtools samtools --help
taf-samtools samtools --version
```

Run common Samtools workflows:

```sh
taf-samtools samtools view -bS input.sam -o input.bam
taf-samtools samtools sort input.bam -o sorted.bam
taf-samtools samtools index sorted.bam
taf-samtools samtools flagstat sorted.bam
taf-samtools samtools stats sorted.bam > sorted.bam.stats
taf-samtools samtools depth sorted.bam > depth.tsv
```

Because this is a command-mode TAFFISH tool, the first non-option argument is
treated as a command available inside the container image. Use explicit command
mode for Samtools itself and for companion tools:

```sh
taf-samtools samtools quickcheck sorted.bam
taf-samtools bgzip -c regions.bed > regions.bed.gz
taf-samtools tabix -p bed regions.bed.gz
taf-samtools htsfile sorted.bam
taf-samtools plot-bamstats -p stats-plots/ sorted.bam.stats
```

Samtools subcommands such as `view`, `sort`, `index`, and `flagstat` are
subcommands of the `samtools` executable, not standalone commands in the image.
Use `taf-samtools samtools <SUBCOMMAND> ...` for normal Samtools workflows.

Do not use:

```sh
taf-samtools view input.bam
```

`view` is not a standalone executable in the container image.

When passing an upstream option through the default wrapper, use `--` so the
option is handled by Samtools instead of the TAFFISH wrapper:

```sh
taf-samtools -- --help
taf-samtools -- --version
```

For most day-to-day use, explicit command mode is clearer:

```sh
taf-samtools samtools --help
taf-samtools samtools --version
```

## Package

```text
name: samtools
command: taf-samtools
version: 1.23.1-r1
kind: tool
image: ghcr.io/taffish/samtools:1.23.1-r1
```

## Container

The container image is built from `docker/Dockerfile`. It compiles HTSlib
1.23.1 and Samtools 1.23.1 from upstream release tarballs in a builder stage,
then copies the installed Samtools runtime into a slim runtime image.

The image includes:

```text
samtools
bgzip
tabix
htsfile
plot-bamstats
plot-ampliconstats
gnuplot
perl
```

Samtools is built with curses support, so `samtools tview` is available. HTSlib
is built with libcurl, S3, GCS, libdeflate, lzma, and bzip2 support. The image
does not include BCFtools; VCF/BCF workflows should use the separate
`taf-bcftools` app and can be connected through files, pipes, or future
TAFFISH flows.

The runtime includes `gnuplot-nox` and the Perl `URI::Escape` module because
upstream helper scripts such as `plot-bamstats` and `plot-ampliconstats`
require them.

The TAFFISH metadata declares a Docker smoke check:

```text
exist: samtools, bgzip, tabix, htsfile, plot-bamstats, plot-ampliconstats, gnuplot, perl
test:  samtools --help
test:  samtools --version 2>&1 | grep -F 'samtools 1.23.1' >/dev/null
test:  samtools --version 2>&1 | grep -F 'Using htslib 1.23.1' >/dev/null
test:  samtools view --help 2>&1 | grep -F 'Usage: samtools view' >/dev/null
test:  samtools sort --help 2>&1 | grep -F 'Usage: samtools sort' >/dev/null
test:  samtools quickcheck --help 2>&1 | grep -F 'Usage: samtools quickcheck' >/dev/null
test:  samtools tview --help 2>&1 | grep -F 'Usage: samtools tview' >/dev/null
test:  bgzip --help >/dev/null
test:  tabix --help >/dev/null
test:  htsfile --help >/dev/null
test:  gnuplot --version >/dev/null
test:  plot-bamstats -h 2>&1 | grep -F 'Usage: plot-bamstats' >/dev/null
test:  plot-ampliconstats -help 2>&1 | grep -F 'Usage: plot-ampliconstats' >/dev/null
test:  perl -MURI::Escape -e 'print uri_escape(qq(ok))' >/dev/null
```

During TAFFISH Hub indexing, this smoke metadata is used to verify that the
published image can be inspected, that the upstream executable and companion
tools are available, that plotting helpers have their runtime dependencies, and
that the packaged Samtools command reports version 1.23.1 and the bundled
HTSlib reports version 1.23.1.

## Upstream

- Project: Samtools
- Homepage: <https://www.htslib.org/>
- Manual: <https://www.htslib.org/doc/samtools.html>
- Source: <https://github.com/samtools/samtools>
- Release tags: <https://github.com/samtools/samtools/releases>
- Upstream license: MIT/Expat

## Maintainer Notes

Useful checks before publishing:

```sh
taf check
taf compile -- samtools --version
taf compile -- samtools view --help
taf publish --release --dry-run
docker build --check -f docker/Dockerfile .
docker build -t ghcr.io/taffish/samtools:1.23.1-r1 -f docker/Dockerfile .
docker run --rm ghcr.io/taffish/samtools:1.23.1-r1 samtools --version
docker run --rm ghcr.io/taffish/samtools:1.23.1-r1 plot-bamstats -h
```

The repository wrapper files are licensed under Apache-2.0. Samtools, HTSlib,
and third-party runtime components are distributed under their own upstream
licenses.
