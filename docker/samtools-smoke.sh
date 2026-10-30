#!/bin/sh
# Offline packaging probes, not a production analysis or upstream algorithm patch.
set -eu
mode=${1:?expected a smoke mode}
if [ "$mode" = identity ]; then
    output=$(samtools --version 2>&1) || { printf '%s\n' "$output" >&2; exit 1; }
    printf '%s\n' "$output" | grep -Fx 'samtools 1.25' >/dev/null
    printf '%s\n' "$output" | grep -Fx 'Using htslib 1.25' >/dev/null
    for tool in bgzip tabix htsfile; do
        output=$("$tool" --version 2>&1) || { printf '%s\n' "$output" >&2; exit 1; }
        printf '%s\n' "$output" | grep -Fx "$tool (htslib) 1.25" >/dev/null
    done
    printf 'identity: PASS\n'
    exit 0
fi

work=$(mktemp -d /tmp/taf-samtools-XXXXXX)
trap 'rm -rf "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
cd "$work"
fixture() {
    printf '>chr1\n' > ref.fa
    head -c 1000 /dev/zero | tr '\000' A >> ref.fa
    printf '\n' >> ref.fa
    printf '@HD\tVN:1.6\tSO:coordinate\n@SQ\tSN:chr1\tLN:1000\n' > in.sam
    i=1
    while [ "$i" -le 20 ]; do
        case "$((i % 3))" in
            0) sequence=AAAAAAAAAAAAAAAAAAAA ;;
            1) sequence=ACGTACGTACGTACGTACGT ;;
            2) sequence=GCGCGCGCGCGCGCGCGCGC ;;
        esac
        printf 'r%s\t0\tchr1\t%s\t60\t20M\t*\t0\t0\t%s\tFFFFFFFFFFFFFFFFFFFF\n' "$i" "$((i * 10))" "$sequence" >> in.sam
        i=$((i + 1))
    done
    samtools view -b -o in.bam in.sam
    samtools index in.bam
}
case "$mode" in
help)
    samtools --help 2>&1 | grep -F 'Program: samtools' >/dev/null
    for cmd in view sort quickcheck tview; do
        samtools "$cmd" --help 2>&1 | grep -F "Usage: samtools $cmd" >/dev/null
    done
    samtools markdup --help 2>&1 | grep -F -- '--move-umi-to-tag' >/dev/null
    samtools stats --help 2>&1 | grep -F -- '--customized-index' >/dev/null
    annot-tsv --help 2>&1 | grep -Fx 'Version: 1.25' >/dev/null
    ref-cache 2>&1 | grep -F 'ref-cache [options]' >/dev/null
    plot-bamstats -h 2>&1 | grep -F 'Usage: plot-bamstats' >/dev/null
    plot-ampliconstats -help 2>&1 | grep -F 'Usage: plot-ampliconstats' >/dev/null
    ;;
core)
    fixture
    samtools sort -o sorted.bam in.bam
    samtools index sorted.bam
    samtools quickcheck sorted.bam
    test "$(samtools view -c sorted.bam)" = 20
    samtools flagstat sorted.bam | grep -F '20 + 0 in total' >/dev/null
    samtools stats sorted.bam | grep -F 'raw total sequences:' >/dev/null
    samtools idxstats sorted.bam | grep -F 'chr1' >/dev/null
    samtools depth sorted.bam > depth.tsv
    test -s depth.tsv
    samtools tview -d T -p chr1:10 sorted.bam ref.fa > tview.txt
    grep -F 'AAAA' tview.txt >/dev/null
    if samtools quickcheck missing.bam > bad.log 2>&1; then exit 1; fi
    ;;
delta)
    fixture
    samtools checksum --check-mate in.bam > checksum.txt
    grep -F '# Checksum 2.0' checksum.txt >/dev/null
    samtools checksum --version-1 in.bam > old-checksum.txt
    grep -F '# Checksum 1.0' old-checksum.txt >/dev/null
    samtools mpileup -f ref.fa --output-extra ENDPOS in.bam > pileup.tsv
    test -s pileup.tsv
    : > empty.fastq
    samtools import --allow-empty -o empty.bam empty.fastq
    test "$(samtools view -c empty.bam)" = 0
    ;;
htslib)
    printf 'chr1\t0\t10\tgeneA\nchr1\t20\t30\tgeneB\n' > regions.bed
    bgzip -c regions.bed > regions.bed.gz
    tabix -p bed regions.bed.gz
    tabix regions.bed.gz chr1:1-10 | grep -F geneA >/dev/null
    htsfile regions.bed.gz | grep -iF BED >/dev/null
    printf 'chr1\t1\t10\tgeneA\n' > source.tsv
    printf 'chr1\t5\t5\t.\n' > target.tsv
    annot-tsv -s source.tsv -t target.tsv -c 1,2,3:1,2,3 -f 4:4 | grep -F geneA >/dev/null
    ;;
plot)
    fixture
    samtools stats in.bam > stats.txt
    mkdir plots
    plot-bamstats -p plots/ stats.txt
    test -s plots/index.html
    test -s plots/gc-content.png
    convert plots/gc-content.png -scale 50% thumbnail.png
    test -s thumbnail.png
    ;;
amplicon)
    printf '@HD\tVN:1.6\tSO:unsorted\n@SQ\tSN:chr1\tLN:1000\n' > paired.sam
    sequence=$(head -c 50 /dev/zero | tr '\000' A)
    quality=$(head -c 50 /dev/zero | tr '\000' F)
    for start in 1 201; do
        for n in 1 2 3 4 5; do
            printf 'p%s_%s\t99\tchr1\t%s\t60\t50M\t=\t%s\t100\t%s\t%s\n' "$start" "$n" "$start" "$((start + 50))" "$sequence" "$quality" >> paired.sam
            printf 'p%s_%s\t147\tchr1\t%s\t60\t50M\t=\t%s\t-100\t%s\t%s\n' "$start" "$n" "$((start + 50))" "$start" "$sequence" "$quality" >> paired.sam
        done
    done
    samtools sort -o one.bam paired.sam
    cp one.bam two.bam
    printf 'chr1\t0\t5\tamp1_LEFT\t0\t+\nchr1\t95\t100\tamp1_RIGHT\t0\t-\nchr1\t200\t205\tamp2_LEFT\t0\t+\nchr1\t295\t300\tamp2_RIGHT\t0\t-\n' > primers.bed
    samtools ampliconstats primers.bed one.bam two.bam > amplicon.stats
    mkdir amplicon
    plot-ampliconstats -thumbnails amplicon/amp amplicon.stats
    test -s amplicon/index.html
    find amplicon -name '*.thumb.png' -type f -size +0c | grep -q .
    ;;
refcache)
    fixture
    samtools faidx ref.fa
    samtools view -C -T ref.fa --output-fmt-option embed_ref=0 -o in.cram in.bam
    seq_cache_populate.py -root cache ref.fa
    find cache -type f -size +0c | grep -q .
    before=$(find cache -type f -exec sha256sum '{}' \; | sort)
    seq_cache_populate.py -root cache ref.fa
    test "$before" = "$(find cache -type f -exec sha256sum '{}' \; | sort)"
    mv ref.fa ref.hidden
    mv ref.fa.fai ref.hidden.fai
    REF_PATH="$work/cache/%2s/%2s/%s" REF_CACHE="$work/cache/%2s/%2s/%s" samtools view in.cram > decoded.sam
    test "$(wc -l < decoded.sam)" -eq 20
    if samtools view -T missing.fa in.cram > bad.log 2>&1; then exit 1; fi
    ;;
wgsim)
    fixture
    wgsim -N 2 -1 20 -2 20 -d 100 -s 10 -e 0 -r 0 -R 0 -X 0 ref.fa read1.fq read2.fq
    test "$(wc -l < read1.fq)" -eq 8
    test "$(wc -l < read2.fq)" -eq 8
    ;;
extras)
    printf '>chr,1\nACGT\n' | fasta-sanitize.pl | grep -Fx '>chr_1' >/dev/null
    samtools.pl 2>&1 | grep -F 'Program: samtools.pl' >/dev/null
    perl -MURI::Escape -e 'print uri_escape(qq(ok))' | grep -Fx ok >/dev/null
    gnuplot --version >/dev/null
    convert -version | grep -F ImageMagick >/dev/null
    printf 'ok\n' | gzip -c | gunzip -c | grep -Fx ok >/dev/null
    test -s /opt/samtools/share/licenses/samtools/LICENSE
    test -s /opt/samtools/share/licenses/htslib/LICENSE
    ;;
*) printf 'Unknown smoke mode: %s\n' "$mode" >&2; exit 2 ;;
esac
printf '%s: PASS\n' "$mode"
