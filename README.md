# taf-samtools

`taf-samtools` packages SAMtools and HTSlib for TAFFISH.

Package identity:

- name: `samtools`
- command: `taf-samtools`
- kind: `tool`
- version: `1.25-r1`
- TAFFISH app license: Apache-2.0
- upstream: <https://github.com/samtools/samtools>

## What This App Packages

This release builds SAMtools 1.25 and HTSlib 1.25 from their official release
tarballs. The default command is `samtools`; TAFFISH command mode also exposes
the companion programs and scripts installed by the two upstream projects.

Verified source archives:

| Source | SHA-256 |
| --- | --- |
| `samtools-1.25.tar.bz2` | `8bbd2b3cb447953149a74ab0b00e3ec4e88a789a27b8373a31fa6b5b2dee02b1` |
| `htslib-1.25.tar.bz2` | `158c271e4e2986bb2dd11283b640edc10c56695b293df77a109ce99480303730` |

## Scope

This app supports the upstream SAMtools command suite for SAM, BAM, and CRAM,
including conversion, filtering, sorting, indexing, validation, statistics,
coverage, pileup, duplicate marking, FASTA/FASTQ conversion, and terminal
viewing. It also includes HTSlib's BGZF, tabix, file-identification,
annotation, and local reference-cache population tools. The installed HTSlib
`ref-cache` HTTP proxy is retained upstream content, not a tested service contract.
No independent server, noVNC desktop or external viewer is added.

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
taf install samtools 1.25-r1
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

For command-mode arguments containing spaces, retain literal quotes through the
TAFFISH shell-command layer (the outer double quotes are consumed by your shell):

```sh
taf-samtools samtools view -b -o "'out file.bam'" "'input file.sam'"
```

Do not use untrusted text as a shell command. The wrapper does not change upstream
argument or file-format semantics.

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

## SAMtools 1.25 Notes

- Checksum output now identifies the corrected algorithm as format 2.0.
  Version 1.24 used the corrected mate checksum but labelled it 1.0; follow
  upstream guidance before comparing old checksums. `--version-1` is available
  for explicitly requested legacy compatibility.
- `mpileup --output-extra ENDPOS` adds alignment-end positions.
- `import --allow-empty` explicitly accepts empty FASTQ input; several markdup, stats and CRAM error
  handling issues are fixed upstream. The packaging does not patch algorithms.

See the [official release](https://github.com/samtools/samtools/releases/tag/1.25)
for the full changes. The matching HTSlib is also 1.25.

## Resources, References, and Platform

The image targets `linux/amd64` and `linux/arm64`. CPU, memory, and disk needs
depend on file size and command. Sorting and merging large files may require
substantial temporary disk; control those locations with the relevant upstream
options.

CRAM decoding may need its exact reference. This is a user/project-specific
input, not a SAMtools-versioned database or model catalog. The image does not
select a species/build, download a genome, or auto-discover a database root.
A download manager would not know the user's required reference identity or
license. Keep an explicit source/version/SHA256 record for your FASTA. The
reference owner's license, not SAMtools' software license, controls sharing.

### Prepare once, share read-only

An administrator may prepare `reference.fa` and its `.fai` in a new staging
folder under a versioned location such as
`/opt/taffish/references/samtools/REFERENCE-ID/` or
`/usr/local/share/taffish/references/samtools/REFERENCE-ID/`. A personal
alternative is `~/.local/share/taffish/references/samtools/REFERENCE-ID/`.
Run `taf-samtools samtools faidx reference.fa` in that writable staging
folder; verify identity and indexes, then grant intended readers directory
traversal (normally 0755) and file reads (normally 0644). Do not recursively
change ownership of an existing unrelated library. Publish the prepared folder
only after validation; ordinary analysis users do not need write access.

From the analysis working directory, using a prepared directory whose path has
no spaces:

```sh
REFS=/opt/taffish/references/samtools/REFERENCE-ID
TAFFISH_DOCKER_RUN_ARGS="--network none -v $REFS:/refs:ro" TAFFISH_CONTAINER_BACKEND=docker taf-samtools samtools view -T /refs/reference.fa -b -o decoded.bam input.cram
TAFFISH_PODMAN_RUN_ARGS="--network none -v $REFS:/refs:ro" TAFFISH_CONTAINER_BACKEND=podman taf-samtools samtools view -T /refs/reference.fa -b -o decoded.bam input.cram
TAFFISH_APPTAINER_RUN_ARGS="--cleanenv --containall --no-mount bind-paths --net --network none --bind $REFS:/refs:ro" TAFFISH_CONTAINER_BACKEND=apptainer taf-samtools samtools view -T /refs/reference.fa -b -o decoded.bam input.cram
```

For a spaced bind root, retain quotes inside the runtime argument string, for
example `TAFFISH_DOCKER_RUN_ARGS="-v '$REFS:/refs:ro'"` (Podman likewise), or
`TAFFISH_APPTAINER_RUN_ARGS="--bind '$REFS:/refs:ro'"`. Resolve any intentional
symlink to a trusted prepared directory first. Indexing an unprepared read-only
FASTA can fail because its adjacent index cannot be written; prepare the index
once instead of making the shared library writable.

### Optional sequence cache

`seq_cache_populate.py -root ref-cache reference.fa` derives a content-addressed
cache from a supplied local FASTA. It does not download genomes. Use a fresh
staging directory, validate the resulting sequence digests and a decoding path,
and only then make the completed snapshot available read-only. The raw upstream
population tools are not a transactional catalog installer and do not promise
rollback or repair of arbitrary old caches; retain original FASTA and recovery
copies. A simple explicit `-T` reference remains the recommended path.

To reuse a prepared cache, bind it as `/refs:ro` using the appropriate backend
above and run:

```sh
taf-samtools env REF_PATH=/refs/%2s/%2s/%s REF_CACHE=/refs/%2s/%2s/%s samtools view -b -o decoded.bam input.cram
```

Set backend arguments on the same invocation. All required sequences must be
present. Without an explicit reference or complete local cache, upstream HTSlib
can try CRAM header URLs/public reference services. This online upstream behavior
is not a reproducible download contract: use explicit local inputs and disabled
networking for offline work. Missing/wrong references must not be ignored.

### Terminal and static viewers

`samtools tview -d T sorted.bam reference.fa` prints a noninteractive text view;
`-d H` emits HTML. For interactive curses, add `-t` to Docker/Podman runtime
arguments and run `taf-samtools env TERM=xterm samtools tview sorted.bam reference.fa`;
Apptainer uses the caller's terminal without Docker's `-t`. Press `q` to exit.

`plot-bamstats -p plots/ stats.txt` creates `plots/index.html` and linked PNGs.
After creating a separate `amplicon/` output directory,
`plot-ampliconstats -thumbnails amplicon/amp amplicon.stats` creates
`amplicon/index.html` plus plots/thumbnails. These are upstream-generated static pages, not a new TAFFISH
renderer; no ports, browser service, authentication or TLS are involved. Copy the
complete output bundle, not just its HTML. Prefer a new **relative prefix without
spaces or shell metacharacters**: the upstream plotting scripts construct some
shell commands internally. A working directory with spaces is supported when
the relative plotting prefix is safe. Reusing the prefix overwrites its files.
Native report layouts are fixed-width; narrow screens may require scrolling.
Reports can expose sample names and paths: share them according to data policy.

The official release provides curses `tview`, its text/HTML forms and the two
plot helpers. Its install files do not declare a separate mandatory GUI package;
BCFtools, iRODS and Crypt4GH extensions remain separately maintained tools/plugins.
No external desktop or browser service is needed for the bundled viewers.

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

## Build and validation

Both declared platforms are native Linux builds: `linux/amd64` and
`linux/arm64`. Build-time checks are deliberately lightweight: exact versions
with checked exit codes and one tiny SAM-to-BAM path. Plotting, full command
help and terminal behavior are checked at runtime, not used as fragile build
requirements. Official archives are SHA256-verified; Debian base tags and apt
repositories remain mutable. Checksums detect source drift but cannot guarantee
future availability or bit-for-bit rebuilds of unpinned dependency packages.

The packaging test helper runs independent offline modes for identity, help,
BAM processing, 1.25 changes, HTSlib tools, both plots, reference cache reuse,
read simulation, dependencies and notices. The real wrapper is tested separately
for argument boundaries, host outputs, ordinary-user read-only references,
missing inputs, upstream reports and terminal rendering.

Current native validation (2026-10-29):

| Host / platform | Backends | Scope |
| --- | --- | --- |
| xjp / Linux amd64 | Docker, Podman, Apptainer | Offline exact smoke, real wrapper, shared references/cache, reports, terminal quit and permissions |
| Local / Linux ARM64 VMs | Docker, Podman | Same runtime scope; Docker also builds the native image |

Docker/Podman tests include normal, read-only-root and nonzero-UID/no-capability
runs. Apptainer uses a real read-only SIF from the same amd64 OCI image with a
clean, contained, offline environment. Shared synthetic FASTA/cache tests cover
read-only reuse, rejected writes, wrong/missing references, MD5 rejection of a
corrupt cache, explicit recovery and repeated population. These demonstrate the
mechanism, not a full production reference installation or license approval.

Native uncompressed image sizes are 312,017,743 bytes (amd64) and 324,408,291 bytes
(ARM64), not registry download sizes. The SAMtools/HTSlib tree occupies about
26/24 MiB respectively. Build sources, headers, static libraries and apt lists
are absent; shared libraries, fonts and plotting dependencies are intentionally
retained. BuildKit 0.33.1 was used with app-root context and the canonical
Dockerfile path. The Action is an unchanged copy of the current `taf new` template.

Both native report generators, image links, overwrite behavior and `taf run`
were exercised. The maintainer directly opened the final offline report files
and confirmed that their display and links work correctly.
Public CI, GHCR and Index results are only available after publication. Tests
use small synthetic inputs and do not establish scientific correctness for
production datasets or every upstream option.

## License and Citation

The TAFFISH app packaging is Apache-2.0. SAMtools and HTSlib retain their own
MIT/Expat-style upstream licenses; both license texts are included in the
image.

Please cite:

> Danecek P, Bonfield JK, Liddle J, et al. Twelve years of SAMtools and BCFtools.
> GigaScience. 2021;10(2):giab008. <https://doi.org/10.1093/gigascience/giab008>

Upstream documentation:

- <https://www.htslib.org/doc/samtools.html>
- <https://github.com/samtools/samtools/releases/tag/1.25>
- <https://github.com/samtools/htslib/releases/tag/1.25>
