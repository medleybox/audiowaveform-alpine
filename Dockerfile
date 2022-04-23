FROM alpine:latest as builder

ENV LIBRARY_PATH=/lib:/usr/lib
ENV LIBVORBIS_LIBRARIES=""

RUN apk add --no-cache git make cmake gcc g++ libmad-dev zlib-dev zlib-static libpng-static libpng-dev libgd \
                       libid3tag-dev libsndfile-dev gd-dev boost-static boost-dev build-base autoconf automake gettext libtool libvorbis-dev
RUN cp /lib/libz* /usr/lib \
    && wget https://github.com/xiph/flac/archive/1.3.3.tar.gz \
    && tar xzf 1.3.3.tar.gz \
    && ls \
    && cd flac-1.3.3 \
    && ./autogen.sh \
    && ./configure --enable-shared=no \
    && make -j${nproc}\
    && make install \
    && cd ../ \
    && git clone https://github.com/xiph/vorbis.git \
    && cd vorbis \
    && ./autogen.sh \
    && ./configure --enable-shared=no \
    && make -j${nproc}\
    && make install \
    && cd ../ \
    && git clone https://github.com/bbc/audiowaveform.git \
    && cd audiowaveform \
    && wget https://github.com/google/googletest/archive/release-1.10.0.tar.gz \
    && tar xzf release-1.10.0.tar.gz \
    && ln -s googletest-release-1.10.0/googletest googletest \
    && ln -s googletest-release-1.10.0/googlemock googlemock \
    && mkdir build \
    && cd build \
    && cmake -D ENABLE_TESTS=0 -D BUILD_STATIC=1 .. \
    && make -j${nproc}\
    && cp audiowaveform* /bin \
    && cd \
    && rm -rf /audiowaveform

FROM alpine:latest

COPY entrypoint.sh /bin/entrypoint
COPY --from=builder /bin/audiowaveform /bin/audiowaveform

RUN chmod +x /bin/entrypoint /bin/audiowaveform \
  && apk --no-cache add gcc zlib-static libpng-static boost-static \
  && /bin/audiowaveform --version

ENTRYPOINT ["/bin/sh","/bin/entrypoint", "$@"]
#ENTRYPOINT /bin/entrypoint
