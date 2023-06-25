FROM alpine:latest as builder

WORKDIR /build

ENV LIBRARY_PATH=/lib:/usr/lib
ENV LIBVORBIS_LIBRARIES=""
ENV VERSION_AUDIOWAVEFORM="1.7.1"
ENV VERSION_LIBSNDFILE="1.2.0"
ENV VERSION_FLAC="1.3.3"
ENV VERSION_OGG="1.3.5"
ENV VERSION_OPUS="1.4"

RUN apk add --no-cache git make cmake gcc g++ samurai libmad-dev zlib-dev zlib-static libpng-static libpng-dev libgd \
    libid3tag-dev libsndfile-dev gd-dev boost-static boost-dev build-base autoconf automake gettext libtool libvorbis-dev \
    alsa-lib-dev

RUN cp /lib/libz* /usr/lib \
    && wget https://github.com/xiph/ogg/archive/refs/tags/v${VERSION_OGG}.tar.gz \
    && tar xzf v${VERSION_OGG}.tar.gz \
    && cd ogg-${VERSION_OGG} \
    && ./autogen.sh \
    && ./configure --enable-shared=no \
    && make -j${nproc} \
    && make install \
    && cd ../ \
    && wget https://github.com/xiph/opus/archive/v${VERSION_OPUS}.tar.gz \
    && tar xzf v${VERSION_OPUS}.tar.gz \
    && cd opus-${VERSION_OPUS} \
    && ./autogen.sh \
    && ./configure --enable-shared=no \
    && make -j${nproc}\
    && make install \
    && cd ../ \
    && wget https://github.com/xiph/flac/archive/${VERSION_FLAC}.tar.gz \
    && tar xzf ${VERSION_FLAC}.tar.gz \
    && cd flac-${VERSION_FLAC} \
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
    && git clone https://codeberg.org/tenacityteam/libid3tag \
    && cd libid3tag \
    && cmake -B build -G Ninja \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DENABLE_TESTS=YES \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_INSTALL_LIBDIR=lib \
    && cmake --build build -j $(nproc) \
    && cd build \
    && CTEST_OUTPUT_ON_FAILURE=TRUE ctest \
    && cd .. \
	  && cmake --install build \
    && wget https://github.com/libsndfile/libsndfile/archive/${VERSION_LIBSNDFILE}.tar.gz \
    && tar xzf ${VERSION_LIBSNDFILE}.tar.gz \
    && cd libsndfile-${VERSION_LIBSNDFILE} \
    && cmake -B build -G Ninja \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DENABLE_MPEG=ON \
    && cmake --build build -j $(nproc) \
    && cd build \
    && CTEST_OUTPUT_ON_FAILURE=TRUE ctest -E write_read_test_sd2 \
    && cd ../ \
    && cmake --install build \
    && cd /build \
    && wget https://github.com/bbc/audiowaveform/archive/${VERSION_AUDIOWAVEFORM}.tar.gz \
    && tar xzf ${VERSION_AUDIOWAVEFORM}.tar.gz \
    && cd audiowaveform-${VERSION_AUDIOWAVEFORM} \
    && mkdir build \
    && cd build \
    && cmake -D ENABLE_TESTS=0 -D BUILD_STATIC=1 .. \
    && make -j${nproc}\
    && cp audiowaveform* /bin \
    && cd /build \
    && rm -rf /audiowaveform

FROM alpine:latest

COPY entrypoint.sh /bin/entrypoint
COPY --from=builder /bin/audiowaveform /bin/audiowaveform

RUN chmod +x /bin/entrypoint /bin/audiowaveform \
  && apk --no-cache add gcc zlib-static libpng-static boost-static \
  && /bin/audiowaveform --version

ENTRYPOINT ["/bin/sh","/bin/entrypoint", "$@"]