FROM alpine:3.18 AS builder

ARG tag="r1_5_4"

RUN apk update && apk add curl unzip
RUN curl -LO "https://github.com/pukiwiki/pukiwiki/archive/refs/tags/$tag.zip"
RUN unzip "$tag.zip"
RUN mv "pukiwiki-$tag" pukiwiki

WORKDIR /pukiwiki
RUN rm -f *.txt *.zip
RUN mkdir -p .orig/conf
RUN for i in `find * -maxdepth 0 -name '*.ini.php'`; do mv $i .orig/conf/; ln -s /ext/conf/$i; done
RUN cp -r wiki .orig/ && rm -rf wiki && ln -s /ext/wiki wiki


FROM alpine:3.18
LABEL org.opencontainers.image.authors="Abe Masahiro <pen@thcomp.org>" \
    org.opencontainers.image.source="https://github.com/pen/docker-pukiwiki"

RUN apk add --no-cache \
            h2o \
            perl \
            php-cgi \
            php-mbstring \
            php-bcmath \
            php-ctype

COPY --from=builder /pukiwiki /var/www
COPY rootfs /

VOLUME /ext
EXPOSE 80

CMD ["/etc/rc.entry"]
