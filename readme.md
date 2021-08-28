# audiowaveform-alpine
Audiowaveform compiled to run on latest alpine base image

# Building
docker build -t medleybox/audiowaveform-alpine .

# Usage

COPY --from=ghcr.io/medleybox/audiowaveform-alpine:latest /bin/audiowaveform /bin/audiowaveform

RUN apk --no-cache add gcc zlib-static libpng-static boost-static

RUN /bin/audiowaveform --version;
