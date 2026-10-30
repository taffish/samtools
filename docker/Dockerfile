ARG SAMTOOLS_VERSION=1.25
ARG HTSLIB_VERSION=1.25
ARG SAMTOOLS_SHA256=8bbd2b3cb447953149a74ab0b00e3ec4e88a789a27b8373a31fa6b5b2dee02b1
ARG HTSLIB_SHA256=158c271e4e2986bb2dd11283b640edc10c56695b293df77a109ce99480303730

# Debian tags and apt repositories are mutable: later rebuilds may resolve
# different base layers/packages or fail when upstream removes old resources.
# The release archives below are versioned and SHA256-checked; the hashes detect
# drift but do not guarantee continued upstream availability. No bitwise rebuild
# guarantee is made for the floating base/package repositories.
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

# Keep build-time probes deterministic and non-rendering on both native runners.
# Full help, plotting, terminal viewing and readonly checks run independently.
RUN install -d -m 0755 /opt/samtools/share/taffish
COPY docker/samtools-smoke.sh /opt/samtools/share/taffish/smoke.sh
RUN chmod 0644 /opt/samtools/share/taffish/smoke.sh \
 && sh /opt/samtools/share/taffish/smoke.sh identity

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
