# taf-samtools

`taf-samtools` packages SAMtools and HTSlib for TAFFISH.

Package identity:

- name: `samtools`
- command: `taf-samtools`
- kind: `tool`
- version: `1.24-r1`
- TAFFISH app license: Apache-2.0
- upstream: <https://github.com/samtools/samtools>

## What This App Packages

This release builds SAMtools 1.24 and HTSlib 1.24 from their official release
tarballs. The default command is `samtools`; TAFFISH command mode also exposes
the companion programs and scripts installed by the two upstream projects.

Verified source archives:

| Source | SHA-256 |
| --- | --- |
| `samtools-1.24.tar.bz2` | `89b2a440123eeaa400392ce1736e7d60ce9041843027d76819753c5a8246bfdd` |
| `htslib-1.24.tar.bz2` | `28a8de191381c7a97a35675ceac76fa1ea95e7b678d6a2e9d600a7874e4077de` |

## Scope

This app supports the upstream SAMtools command suite for SAM, BAM, and CRAM,
including conversion, filtering, sorting, indexing, validation, statistics,
coverage, pileup, duplicate marking, FASTA/FASTQ conversion, and terminal
viewing. It also includes HTSlib's BGZF, tabix, file-identification,
annotation, and reference-cache tools.

This app does not:

- include BCFtools; use `taf-bcftools` for VCF/BCF workflows
- bundle reference genomes, CRAM reference caches, or user data
- turn SAMtools subcommands such as `view` into standalone executables
- guarantee that remote URL input works when the selected container backend
  has no network access
- include the separately distributed `htslib-crypt4gh` file-access plugin

## Container Contents

The complete upstream-installed command surface is retained:

- core: `samtools`
- HTSlib: `annot-tsv`, `bgzip`, `htsfile`, `ref-cache`, `tabix`
- converters and generators: `ace2sam`, `maq2sam-long`, `maq2sam-short`,
  `md5fa`, `md5sum-lite`, `wgsim`
- Perl helpers: `blast2sam.pl`, `bowtie2sam.pl`, `export2sam.pl`,
  `fasta-sanitize.pl`, `interpolate_sam.pl`, `novo2sam.pl`, `psl2sam.pl`,
  `sam2vcf.pl`, `samtools.pl`, `seq_cache_populate.pl`, `soap2sam.pl`,
  `wgsim_eval.pl`, `zoom2sam.pl`
- Python helper: `seq_cache_populate.py`
- plotting helpers: `plot-bamstats`, `plot-ampliconstats`

Runtime support includes curses, libcurl/TLS, S3/GCS-capable HTSlib support,
libdeflate, bzip2, xz, gzip, Perl with `URI::Escape`, Python 3, gnuplot, and
ImageMagick. ImageMagick is required by the optional
`plot-ampliconstats -thumbnails` path.

## Installation

```sh
taf update
taf install samtools 1.24-r1
```

For an unpublished local checkout:

```sh
taf install --from .
```

## Usage

Run the default upstream command:

```sh
taf-samtools -- --version
taf-samtools -- view -h input.bam
```

For ordinary work, explicit command mode is usually clearest:

```sh
taf-samtools samtools view -b -o input.bam input.sam
taf-samtools samtools sort -o sorted.bam input.bam
taf-samtools samtools index sorted.bam
taf-samtools samtools quickcheck sorted.bam
taf-samtools samtools flagstat sorted.bam
taf-samtools samtools stats sorted.bam > sorted.bam.stats
taf-samtools samtools depth sorted.bam > depth.tsv
```

Run packaged companion commands in the same environment:

```sh
taf-samtools bgzip -c regions.bed > regions.bed.gz
taf-samtools tabix -p bed regions.bed.gz
taf-samtools htsfile sorted.bam
taf-samtools plot-bamstats -p stats-plots/ sorted.bam.stats
taf-samtools seq_cache_populate.py -root ref-cache reference.fa
```

`view`, `sort`, `index`, and other SAMtools subcommands are not standalone
programs. Use `taf-samtools samtools view ...`, not
`taf-samtools view ...`.

## Command Mode

`taf-samtools <COMMAND> ...` runs a packaged executable inside the container.
Use `taf-samtools -- ...` to pass option-leading arguments to the default
`samtools` command:

```sh
taf-samtools -- --help
taf-samtools -- --version
```

## Inputs

| Input | Meaning | Notes |
| --- | --- | --- |
| SAM/BAM/CRAM | Sequence alignments | Some operations require coordinate or name sorting |
| FASTA/FASTQ | References or reads | Used by `faidx`, conversion, simulation, and cache helpers |
| BED/GFF/VCF-like tabular files | Regions and annotations | `bgzip` plus `tabix` require compatible sorting and presets |
| Remote URL | HTSlib-supported remote object | Requires backend networking and any needed credentials |

Input paths must be visible to the container. Files under the current working
directory follow normal TAFFISH mounting behavior; other host paths may need an
explicit runtime mount.

## Output Notes

SAMtools output depends on the selected subcommand. Many commands write binary
data or text to standard output unless `-o` is supplied, so shell redirection
and TAFFISH pipe mode are supported. Index commands create `.bai`, `.csi`,
`.crai`, or `.fai` sidecars. Plot helpers write multiple image files under the
requested output prefix or directory.

## SAMtools 1.24 Notes

- `view --subsample` now derives its default seed from the input header instead
  of using zero. Set an explicit seed when exact cross-run sampling identity is
  required.
- `markdup` adds `--move-umi-to-tag`.
- `stats` uses the corrected `--customized-index` option name.
- `fixmate` now fills mate information on supplementary alignments.
- checksum merging is compatible with biobambam2 output.

See the upstream release notes for the complete list of changes.

## Resources, References, and Platform

The image targets `linux/amd64` and `linux/arm64`. CPU, memory, and disk needs
depend on file size and command. Sorting and merging large files may require
substantial temporary disk; control those locations with the relevant upstream
options.

CRAM decoding may require the matching reference. No reference is bundled.
Pass an accessible reference with the appropriate SAMtools option or configure
an HTSlib reference cache yourself. `seq_cache_populate.py` and
`seq_cache_populate.pl` are included to populate such caches from local FASTA
files.

`samtools tview` is interactive and needs a usable terminal. The image carries
curses support, but terminal allocation remains a backend/runtime concern.

## Boundaries

The wrapper intentionally remains thin and does not alter upstream argument,
format, sorting, indexing, or reference semantics. Scientific interpretation,
production resource sizing, remote authentication, and reference provenance
remain the user's responsibility.

The image contains no database and its smoke tests are offline. HTSlib remote
protocol support is packaged, but remote services are outside the reproducible
offline smoke boundary.

HTSlib is built with its default external-plugin setting (`plugins=no`). It can
detect Crypt4GH input and report that the separately maintained
`htslib-crypt4gh` plugin is required, but that plugin is not part of the
SAMtools or HTSlib release tarballs and is not bundled in this app. Decrypt or
convert such input before use, or package the optional plugin separately.

## Testing

Build-time checks are deliberately QEMU-friendly: exact versions, stable normal
help markers, command discovery, runtime libraries, and a tiny SAM-to-BAM path.
They do not invoke terminal-width-sensitive full help or plotting/rendering.

Independent index smoke cases cover:

- SAMtools 1.24 and HTSlib 1.24 identity
- 1.24-specific `markdup` and `stats` options
- tiny BAM conversion, sorting, indexing, validation, and statistics
- `bgzip`, `tabix`, `htsfile`, and `annot-tsv`
- real `plot-bamstats` output and ImageMagick image conversion
- Python reference-cache population and `wgsim` FASTQ generation
- installed helper discovery, runtime dependencies, and license notices

These checks validate packaging and minimal execution, not full scientific
correctness on production datasets or every option combination.

## License and Citation

The TAFFISH app packaging is Apache-2.0. SAMtools and HTSlib retain their own
MIT/Expat-style upstream licenses; both license texts are included in the
image.

Please cite:

> Danecek P, Bonfield JK, Liddle J, et al. Twelve years of SAMtools and BCFtools.
> GigaScience. 2021;10(2):giab008. <https://doi.org/10.1093/gigascience/giab008>

Upstream documentation:

- <https://www.htslib.org/doc/samtools.html>
- <https://github.com/samtools/samtools/releases/tag/1.24>
- <https://github.com/samtools/htslib/releases/tag/1.24>
