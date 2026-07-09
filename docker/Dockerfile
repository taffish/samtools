ARG SAMTOOLS_VERSION=1.24
ARG HTSLIB_VERSION=1.24
ARG SAMTOOLS_SHA256=89b2a440123eeaa400392ce1736e7d60ce9041843027d76819753c5a8246bfdd
ARG HTSLIB_SHA256=28a8de191381c7a97a35675ceac76fa1ea95e7b678d6a2e9d600a7874e4077de

FROM debian:12-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive
ARG SAMTOOLS_VERSION
ARG HTSLIB_VERSION
ARG SAMTOOLS_SHA256
ARG HTSLIB_SHA256
ENV LD_LIBRARY_PATH=/opt/samtools/lib

RUN set -eux; \
    for attempt in 1 2 3; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            build-essential \
            ca-certificates \
            curl \
            libbz2-dev \
            libcurl4-gnutls-dev \
            libdeflate-dev \
            liblzma-dev \
            libncurses-dev \
            libssl-dev \
            zlib1g-dev; then \
        break; \
      fi; \
      if [ "$attempt" = "3" ]; then exit 1; fi; \
      apt-get clean; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

RUN curl -fsSL "https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2" \
      -o htslib.tar.bz2 \
 && echo "${HTSLIB_SHA256}  htslib.tar.bz2" | sha256sum -c - \
 && tar -xjf htslib.tar.bz2 \
 && curl -fsSL "https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2" \
      -o samtools.tar.bz2 \
 && echo "${SAMTOOLS_SHA256}  samtools.tar.bz2" | sha256sum -c - \
 && tar -xjf samtools.tar.bz2

WORKDIR /tmp/build/htslib-${HTSLIB_VERSION}

RUN ./configure --prefix=/opt/samtools \
 && make -j"$(nproc)" \
 && make install

WORKDIR /tmp/build/samtools-${SAMTOOLS_VERSION}

RUN ./configure \
      --prefix=/opt/samtools \
      --with-htslib=/opt/samtools \
 && make -j"$(nproc)" \
 && make install \
 && /opt/samtools/bin/samtools --version 2>&1 | grep -Fx "samtools ${SAMTOOLS_VERSION}" >/dev/null \
 && /opt/samtools/bin/samtools --version 2>&1 | grep -Fx "Using htslib ${HTSLIB_VERSION}" >/dev/null \
 && /opt/samtools/bin/samtools view --help 2>&1 | grep -F "Usage: samtools view" >/dev/null \
 && /opt/samtools/bin/samtools sort --help 2>&1 | grep -F "Usage: samtools sort" >/dev/null \
 && /opt/samtools/bin/samtools quickcheck --help 2>&1 | grep -F "Usage: samtools quickcheck" >/dev/null \
 && /opt/samtools/bin/samtools markdup --help 2>&1 | grep -F -- "--move-umi-to-tag" >/dev/null \
 && /opt/samtools/bin/samtools stats --help 2>&1 | grep -F -- "--customized-index" >/dev/null \
 && /opt/samtools/bin/bgzip --help >/dev/null \
 && /opt/samtools/bin/tabix --help >/dev/null \
 && /opt/samtools/bin/htsfile --help >/dev/null \
 && /opt/samtools/bin/annot-tsv --help 2>&1 | grep -Fx "Version: ${HTSLIB_VERSION}" >/dev/null \
 && /opt/samtools/bin/ref-cache 2>&1 | grep -F "ref-cache [options]" >/dev/null \
 && rm -rf /opt/samtools/include /opt/samtools/lib/pkgconfig \
 && find /opt/samtools/lib -type f -name '*.a' -delete

RUN mkdir -p \
      /opt/samtools/share/licenses/samtools \
      /opt/samtools/share/licenses/htslib \
 && install -m 0644 LICENSE /opt/samtools/share/licenses/samtools/LICENSE \
 && install -m 0644 "/tmp/build/htslib-${HTSLIB_VERSION}/LICENSE" \
      /opt/samtools/share/licenses/htslib/LICENSE

FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive
ARG SAMTOOLS_VERSION
ARG HTSLIB_VERSION

RUN set -eux; \
    for attempt in 1 2 3; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            ca-certificates \
            gnuplot-nox \
            gzip \
            imagemagick \
            libbz2-1.0 \
            libcurl3-gnutls \
            libdeflate0 \
            liblzma5 \
            libncursesw6 \
            libssl3 \
            liburi-perl \
            perl \
            python3 \
            zlib1g; then \
        break; \
      fi; \
      if [ "$attempt" = "3" ]; then exit 1; fi; \
      apt-get clean; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/samtools /opt/samtools

ENV PATH=/opt/samtools/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/samtools/lib

RUN set -eux; \
    samtools --help 2>&1 | grep -F "Program: samtools" >/dev/null; \
    samtools --version 2>&1 | grep -Fx "samtools ${SAMTOOLS_VERSION}" >/dev/null; \
    samtools --version 2>&1 | grep -Fx "Using htslib ${HTSLIB_VERSION}" >/dev/null; \
    samtools view --help 2>&1 | grep -F "Usage: samtools view" >/dev/null; \
    samtools sort --help 2>&1 | grep -F "Usage: samtools sort" >/dev/null; \
    samtools quickcheck --help 2>&1 | grep -F "Usage: samtools quickcheck" >/dev/null; \
    samtools tview --help 2>&1 | grep -F "Usage: samtools tview" >/dev/null; \
    samtools markdup --help 2>&1 | grep -F -- "--move-umi-to-tag" >/dev/null; \
    samtools stats --help 2>&1 | grep -F -- "--customized-index" >/dev/null; \
    for executable in samtools bgzip tabix htsfile annot-tsv ref-cache ace2sam maq2sam-long maq2sam-short md5fa md5sum-lite wgsim blast2sam.pl bowtie2sam.pl export2sam.pl fasta-sanitize.pl interpolate_sam.pl novo2sam.pl plot-ampliconstats plot-bamstats psl2sam.pl sam2vcf.pl samtools.pl seq_cache_populate.pl seq_cache_populate.py soap2sam.pl wgsim_eval.pl zoom2sam.pl; do command -v "$executable" >/dev/null; done; \
    annot-tsv --help 2>&1 | grep -Fx "Version: ${HTSLIB_VERSION}" >/dev/null; \
    ref-cache 2>&1 | grep -F "ref-cache [options]" >/dev/null; \
    plot-bamstats -h 2>&1 | grep -F "Usage: plot-bamstats" >/dev/null; \
    plot-ampliconstats -help 2>&1 | grep -F "Usage: plot-ampliconstats" >/dev/null; \
    seq_cache_populate.py --help 2>&1 | grep -F "Directory to create the refcache dir" >/dev/null; \
    perl -MURI::Escape -e 'print uri_escape("ok\n")' >/dev/null; \
    gnuplot --version >/dev/null; \
    convert -version 2>&1 | grep -F "ImageMagick" >/dev/null; \
    printf 'ok\n' | gzip -c | gunzip -c | grep -Fx "ok" >/dev/null; \
    test -s /opt/samtools/share/licenses/samtools/LICENSE; \
    test -s /opt/samtools/share/licenses/htslib/LICENSE

RUN set -eux; \
    work=/tmp/taf-samtools-build; \
    mkdir -p "$work"; \
    printf '@HD\tVN:1.6\tSO:unsorted\n@SQ\tSN:chr1\tLN:100\nr1\t0\tchr1\t1\t60\t10M\t*\t0\t0\tACGTACGTAC\tFFFFFFFFFF\n' > "$work/in.sam"; \
    samtools view -b -o "$work/in.bam" "$work/in.sam"; \
    samtools quickcheck "$work/in.bam"; \
    test "$(samtools view -c "$work/in.bam")" = 1; \
    rm -rf "$work"

WORKDIR /root

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=samtools
