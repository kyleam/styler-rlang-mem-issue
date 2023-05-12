FROM rstudio/r-base:4.1.3-bionic

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends eatmydata && \
    eatmydata apt-get install -y --no-install-recommends locales && \
    echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen && locale-gen && \
    eatmydata apt-get install -y --no-install-recommends git && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG CRAN=https://packagemanager.rstudio.com/cran/__linux__/bionic/2023-03-10+L-i8FJMJ
RUN printf 'options(repos = c("CRAN"= "%s"))\n' "$CRAN" >/opt/R/4.1.3/lib/R/etc/Rprofile.site
RUN curl -fSsL -O https://cran.rstudio.com/src/contrib/styler_1.9.1.tar.gz
RUN Rscript -e 'install.packages(c("remotes", "rcmdcheck"))' && \
    Rscript -e 'remotes::install_deps("styler_1.9.1.tar.gz", dependencies = TRUE, upgrade = "always")' && \
    rm -rf /tmp/R*

ARG RLANG_COMMIT=35e87908418619f70917e191a2d9721c709527d0
RUN git clone https://github.com/r-lib/rlang.git && \
    git -C rlang checkout "$RLANG_COMMIT" && \
    R CMD INSTALL rlang

COPY check.R check.sh /
RUN mkdir -p /scratch
WORKDIR /scratch
ENTRYPOINT ["/check.sh"]
CMD []
