ARG SAMTOOLS_VERSION=1.23.1
ARG HTSLIB_VERSION=1.23.1

FROM debian:12-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive
ARG SAMTOOLS_VERSION
ARG HTSLIB_VERSION
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
 && tar -xjf htslib.tar.bz2 \
 && curl -fsSL "https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2" \
      -o samtools.tar.bz2 \
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
 && /opt/samtools/bin/samtools --version 2>&1 | grep -F "samtools ${SAMTOOLS_VERSION}" >/dev/null \
 && /opt/samtools/bin/samtools --version 2>&1 | grep -F "Using htslib ${HTSLIB_VERSION}" >/dev/null \
 && /opt/samtools/bin/samtools view --help 2>&1 | grep -F "Usage: samtools view" >/dev/null \
 && /opt/samtools/bin/samtools sort --help 2>&1 | grep -F "Usage: samtools sort" >/dev/null \
 && /opt/samtools/bin/samtools quickcheck --help 2>&1 | grep -F "Usage: samtools quickcheck" >/dev/null \
 && /opt/samtools/bin/bgzip --help >/dev/null \
 && /opt/samtools/bin/tabix --help >/dev/null \
 && /opt/samtools/bin/htsfile --help >/dev/null

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
            libbz2-1.0 \
            libcurl3-gnutls \
            libdeflate0 \
            liblzma5 \
            libncursesw6 \
            libssl3 \
            liburi-perl \
            perl \
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

RUN samtools --help >/dev/null \
 && samtools --version 2>&1 | grep -F "samtools ${SAMTOOLS_VERSION}" >/dev/null \
 && samtools --version 2>&1 | grep -F "Using htslib ${HTSLIB_VERSION}" >/dev/null \
 && samtools view --help 2>&1 | grep -F "Usage: samtools view" >/dev/null \
 && samtools sort --help 2>&1 | grep -F "Usage: samtools sort" >/dev/null \
 && samtools quickcheck --help 2>&1 | grep -F "Usage: samtools quickcheck" >/dev/null \
 && samtools tview --help 2>&1 | grep -F "Usage: samtools tview" >/dev/null \
 && bgzip --help >/dev/null \
 && tabix --help >/dev/null \
 && htsfile --help >/dev/null \
 && gnuplot --version >/dev/null \
 && plot-bamstats -h 2>&1 | grep -F "Usage: plot-bamstats" >/dev/null \
 && plot-ampliconstats -help 2>&1 | grep -F "Usage: plot-ampliconstats" >/dev/null \
 && perl -MURI::Escape -e 'print uri_escape("ok\n")' >/dev/null \
 && perl -e 'print "ok\n"' >/dev/null

WORKDIR /root

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=samtools
