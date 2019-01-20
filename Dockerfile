FROM pyunramura/alpine-s6:3.8

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.version="$VERSION" \
      org.label-schema.maintainer="pyunramura"

# The versions are pinned for stable,
# reproducible, deterministic, pure builds.
RUN \
    echo "---- installing packages ----" && \
    apk add --no-cache \
        jq=1.6_rc1-r1 \
        rsync=3.1.3-r1 \
	transmission-cli=2.94-r0 \
        transmission-daemon=2.94-r0

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -L 'https://api.ipify.org'

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413
VOLUME /config /downloads /watch
