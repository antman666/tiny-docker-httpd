FROM alpine AS builder
WORKDIR /src

RUN apk add --no-cache build-base git \
    && git clone https://github.com/emikulic/darkhttpd.git \
    && cd /src/darkhttpd \
    && make darkhttpd-static \
    && strip darkhttpd-static

# Just the static binary
FROM scratch
# set label
LABEL maintainer="antman666"
WORKDIR /www
COPY --from=builder /src/darkhttpd/darkhttpd-static /darkhttpd
EXPOSE 6880
VOLUME [ "/www" ]
ENTRYPOINT [ "/darkhttpd" ]
CMD [ "/www" ]
