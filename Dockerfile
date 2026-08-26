FROM golang:1.26.3-trixie

ARG TARGETARCH
ARG ZIG_VERSION=0.15.2
ARG GHOSTTY_COMMIT=d4ac93a0395d321b043ee0116dc8a1a384f0fb83

LABEL org.opencontainers.image.source=https://github.com/jumpserver-dev/libghostty-vt
LABEL org.opencontainers.image.description="Prebuilt libghostty-vt for JumpServer"

RUN set -ex \
    && case "${TARGETARCH}" in \
        amd64) ZIG_ARCH=x86_64 ;; \
        arm64) ZIG_ARCH=aarch64 ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && apt-get update \
    && apt-get install -y --no-install-recommends pkg-config xz-utils \
    && wget -O /tmp/zig.tar.xz "https://ziglang.org/download/${ZIG_VERSION}/zig-${ZIG_ARCH}-linux-${ZIG_VERSION}.tar.xz" \
    && tar -xf /tmp/zig.tar.xz -C /opt \
    && mv "/opt/zig-${ZIG_ARCH}-linux-${ZIG_VERSION}" /opt/zig \
    && wget -O /tmp/ghostty.tar.gz "https://github.com/ghostty-org/ghostty/archive/${GHOSTTY_COMMIT}.tar.gz" \
    && tar -xf /tmp/ghostty.tar.gz -C /tmp \
    && cd "/tmp/ghostty-${GHOSTTY_COMMIT}" \
    && /opt/zig/zig build -Demit-lib-vt -Doptimize=ReleaseFast --prefix /opt/libghostty-vt \
    && rm -rf /opt/zig /tmp/zig.tar.xz /tmp/ghostty.tar.gz "/tmp/ghostty-${GHOSTTY_COMMIT}" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PKG_CONFIG_PATH=/opt/libghostty-vt/share/pkgconfig
