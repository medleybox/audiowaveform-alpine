# audiowaveform-alpine
[Audiowaveform][github-audiowaveform] binary compiled to run on latest alpine base image.

Used within the [Medleybox project][github-vault] to extract waveform data and display within the web player.

## Usage
To use audiowaveform within your image, copy the compiled binary from ghcr.io repo and install some packages required to run audiowaveform on alpine.

Dockerfile:
```dockerfile
COPY --from=ghcr.io/medleybox/audiowaveform-alpine:master /bin/audiowaveform /bin/audiowaveform

# Install minimal runtime dependencies
RUN apk --no-cache add gcc zlib-static libpng-static boost-static

RUN /bin/audiowaveform --version;
```

This image can also be used to run the via `docker run`:
```bash
docker run --rm -it ghcr.io/medleybox/audiowaveform-alpine:master --help
docker run --rm -it ghcr.io/medleybox/audiowaveform-alpine:master --version
```

## Docker image
Images are built and published to the Github docker repository.

[Github actions][github-actions] builds are tagged with `master` and published when new commits are pushed to this repo.

You can view all avalible images [here][docker-image-versions]

### Building localy
Use the `build.sh` script to build and push image tags
```bash
docker build -t ghcr.io/medleybox/audiowaveform-alpine:master .
```

[github-vault]: https://github.com/medleybox/vault/blob/master/src/Service/Audiowaveform.php
[github-audiowaveform]: https://github.com/bbc/audiowaveform
[github-actions]: https://github.com/medleybox/audiowaveform-alpine/actions/workflows/docker-publish.yml
[docker-image-version]: https://github.com/medleybox/audiowaveform-alpine/pkgs/container/audiowaveform-alpine/versions