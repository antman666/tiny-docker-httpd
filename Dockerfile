FROM alpine AS builder
WORKDIR /src

ENV CFLAGS=" \
  -static                                 \
  -O3                                     \
  -flto                                   \
  -D_FORTIFY_SOURCE=2                     \
  -fstack-clash-protection                \
  -fstack-protector-strong                \
  -pipe                                   \
  -Wall                                   \
  -Werror=format-security                 \
  -Werror=implicit-function-declaration   \
  -Wl,-z,defs                             \
  -Wl,-z,now                              \
  -Wl,-z,relro                            \
  -Wl,-z,noexecstack                      \
"

RUN apk add --no-cache build-base git \
    && git clone https://github.com/emikulic/darkhttpd.git --branch v1.17 \
    && cd /src/darkhttpd \
    && make darkhttpd \
    && strip darkhttpd

# Just the static binary
FROM scratch
# set label
LABEL maintainer="antman666"
WORKDIR /www
COPY --from=builder /src/darkhttpd/darkhttpd /darkhttpd
EXPOSE 6880
VOLUME [ "/www" ]
ENTRYPOINT [ "/darkhttpd" ]
CMD [ "/www", "--chroot" ]
