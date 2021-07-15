FROM debian:buster AS builder

# Init
SHELL ["/bin/bash", "-c"]
RUN apt-get update
RUN apt-get install -y curl wget xz-utils git build-essential libncurses5-dev gawk upx unzip python file

# Prepare sdk
WORKDIR /build
ARG URL
RUN curl -s -O $URL && FILE="${URL##*/}" && tar xf "${FILE}" && mv "${FILE%.*.*}" sdk

WORKDIR /build/sdk
RUN echo "src-git dependencies https://github.com/Lienol/openwrt-packages.git;19.07" >> feeds.conf.default
RUN echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git" >> feeds.conf.default

RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -p passwall luci-app-passwall xray-plugin
RUN ./scripts/feeds install -p dependencies golang

RUN sed -i 's/include $(INCLUDE_DIR)\/package.mk/PKG_BUILD_DIR := $(BUILD_DIR)\/$(PKG_NAME)-$(PKG_VERSION)\n\ninclude $(INCLUDE_DIR)\/package.mk/' package/feeds/passwall/luci-app-passwall/Makefile

RUN make defconfig
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook=y" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG=y" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Kcptun=y" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client=n" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Plugin=n" >> .config
RUN echo "CONFIG_XRAY_PLUGIN_PROVIDE_V2RAY_PLUGIN=y" >> .config

RUN ln -s `which upx` staging_dir/host/bin/upx

# Compile 
RUN make package/feeds/passwall/luci-app-passwall/compile V=s
RUN make package/feeds/passwall/xray-plugin/compile V=s

# Output
WORKDIR /output
RUN mv `find /build/sdk/bin/packages/ | grep brook` .
RUN mv `find /build/sdk/bin/packages/ | grep xray-core` .
RUN mv `find /build/sdk/bin/packages/ | grep xray-geodata` .
RUN mv `find /build/sdk/bin/packages/ | grep xray-plugin` .
RUN mv `find /build/sdk/bin/packages/ | grep trojan-plus` .
RUN mv `find /build/sdk/bin/packages/ | grep kcptun` .
RUN mv `find /build/sdk/bin/packages/ | grep tcping` .
RUN mv `find /build/sdk/bin/packages/ | grep ipt2socks` .
RUN mv `find /build/sdk/bin/packages/ | grep dns2socks` .
RUN mv `find /build/sdk/bin/packages/ | grep microsocks` .
RUN mv `find /build/sdk/bin/packages/ | grep pdnsd-alt` .
RUN mv `find /build/sdk/bin/packages/ | grep simple-obfs` .
RUN mv `find /build/sdk/bin/packages/ | grep chinadns-ng` .
RUN mv `find /build/sdk/bin/packages/ | grep shadowsocksr-libev` .
RUN mv `find /build/sdk/bin/packages/ | grep luci-app-passwall` .
RUN mv `find /build/sdk/bin/packages/ | grep luci-i18n-passwall` .

FROM debian:buster

RUN apt-get update && apt-get install -y python3

WORKDIR /output
COPY --from=builder /output/ .

ENTRYPOINT ["/bin/bash", "-c", "python3 -u -m http.server -b `awk 'END{print $1}' /etc/hosts` 80"]
