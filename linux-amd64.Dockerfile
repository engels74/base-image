ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_AMD64

FROM ubuntu AS builder
ARG UNRAR_VER=7.1.10
ADD https://www.rarlab.com/rar/unrarsrc-${UNRAR_VER}.tar.gz /tmp/unrar.tar.gz
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests build-essential && \
    tar -xzf /tmp/unrar.tar.gz && \
    cd unrar && \
    sed -i 's|LDFLAGS=-pthread|LDFLAGS=-pthread -static|' makefile && \
    sed -i 's|CXXFLAGS=-march=native |CXXFLAGS=|' makefile && \
    make -f makefile && \
    install -Dm 755 unrar /usr/bin/unrar


FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}

ARG IMAGE_STATS
ARG BUILD_ARCHITECTURE
ENV IMAGE_STATS=${IMAGE_STATS} BUILD_ARCHITECTURE=${BUILD_ARCHITECTURE} \
    APP_DIR="/app" CONFIG_DIR="/config" PUID="1000" PGID="1000" UMASK="002" TZ="Etc/UTC" \
    XDG_CONFIG_HOME="${CONFIG_DIR}/.config" XDG_CACHE_HOME="${CONFIG_DIR}/.cache" XDG_DATA_HOME="${CONFIG_DIR}/.local/share" \
    LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 S6_SERVICES_GRACETIME=180000 S6_STAGE2_HOOK="/etc/s6-overlay/init-hook" \
    VPN_ENABLED="false" VPN_CONF="wg0" VPN_PROVIDER="generic" VPN_LAN_NETWORK="" VPN_LAN_LEAK_ENABLED="false" VPN_EXPOSE_PORTS_ON_LAN="" VPN_AUTO_PORT_FORWARD="true" VPN_AUTO_PORT_FORWARD_TO_PORTS="" VPN_FIREWALL_TYPE="auto" VPN_HEALTHCHECK_ENABLED="false" VPN_NAMESERVERS="" PRIVOXY_ENABLED="false" UNBOUND_ENABLED="false" UNBOUND_NAMESERVERS="" \
    VPN_PIA_USER="" VPN_PIA_PASS="" VPN_PIA_PREFERRED_REGION="" VPN_PIA_DIP_TOKEN="no" VPN_PIA_PORT_FORWARD_PERSIST="false"

VOLUME ["${CONFIG_DIR}"]

ENTRYPOINT ["/init"]

ARG DEBIAN_FRONTEND="noninteractive"
# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        ca-certificates curl dos2unix figlet ipcalc-ng iproute2 iptables iputils-ping jq libcap2-bin locales natpmpc nftables p7zip-full privoxy python3 rs tzdata unbound unzip wget wireguard-go wireguard-tools xz-utils && \
    ln -s ipcalc-ng /usr/bin/ipcalc && \
    update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy && \
# generate locale
    locale-gen en_US.UTF-8 && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY --from=builder /usr/bin/unrar /usr/bin/unrar

# https://github.com/just-containers/s6-overlay/releases
ARG VERSION_S6
RUN curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-noarch.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-x86_64.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-symlinks-noarch.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-symlinks-arch.tar.xz" | tar Jpxf - -C /

# make folders
RUN mkdir "${APP_DIR}" && \
    mkdir "${CONFIG_DIR}" && \
# create user
    userdel -r ubuntu && \
    useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false hotio && \
    usermod -G users hotio

# install root-files
ARG VERSION_ROOT_FILES
RUN curl -fsSL "https://github.com/hotio/root-files/archive/${VERSION_ROOT_FILES}.tar.gz" | tar zpxf - -C / "root-files-${VERSION_ROOT_FILES}/root" --strip-components=2 && \
    chmod +x /etc/s6-overlay/init-hook
