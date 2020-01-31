FROM debian:buster

# Init
SHELL ["/bin/bash", "-c"]
RUN apt-get update > /dev/null && apt-get upgrade > /dev/null
RUN apt-get install -y wget xz-utils git build-essential libncurses5-dev gawk unzip python python3 file > /dev/null

# Prepare sdk
WORKDIR /build
ARG URL
RUN wget -q $URL
RUN FILE="${URL##*/}" && tar xf "${FILE}" &&  mv "${FILE%.*.*}" sdk
RUN git clone -q https://github.com/coolsnowwolf/lede

WORKDIR /build/sdk
RUN cp -r ../lede/package/lean/v2ray package/
RUN cp -r ../lede/package/lean/trojan package/
RUN cp -r ../lede/package/lean/kcptun package/
RUN cp -r ../lede/package/lean/ipt2socks package/
RUN cp -r ../lede/package/lean/pdnsd-alt package/
RUN cp -r ../lede/package/lean/shadowsocksr-libev package/
RUN cp -r ../lede/package/lean/luci-app-ssr-plus package/
RUN git clone -q https://github.com/aa65535/openwrt-chinadns.git package/chinadns
RUN git clone -q https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci

# Config
RUN make --quiet defconfig
RUN sed -i 's/CONFIG_PACKAGE_v2ray=m/CONFIG_PACKAGE_v2ray=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_trojan=m/CONFIG_PACKAGE_trojan=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_kcptun-client=m/CONFIG_PACKAGE_kcptun-client=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_ipt2socks=m/CONFIG_PACKAGE_ipt2socks=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_pdnsd-alt=m/CONFIG_PACKAGE_pdnsd-alt=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_shadowsocksr-libev-alt=m/CONFIG_PACKAGE_shadowsocksr-libev-alt=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_shadowsocksr-libev-server=m/CONFIG_PACKAGE_shadowsocksr-libev-server=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=m/CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_luci-app-ssr-plus=m/CONFIG_PACKAGE_luci-app-ssr-plus=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_ChinaDNS=m/CONFIG_PACKAGE_ChinaDNS=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_luci-app-chinadns=m/CONFIG_PACKAGE_luci-app-chinadns=y/g' .config
RUN echo "CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun=y" >> .config

# Compile
RUN ./scripts/feeds update -a > /dev/null
RUN ./scripts/feeds install libuv pcre zlib openssl boost golang > /dev/null

RUN pushd package/openwrt-dist-luci/tools/po2lmo && make && make install && popd

RUN make --quiet package/v2ray/compile V=99
RUN make --quiet package/trojan/compile V=99
RUN make --quiet package/kcptun/compile V=99
RUN make --quiet package/ipt2socks/compile V=99
RUN make --quiet package/pdnsd-alt/compile V=99
RUN make --quiet package/shadowsocksr-libev/compile V=99
RUN make --quiet package/luci-app-ssr-plus/compile V=99
RUN make --quiet package/chinadns/compile V=99
RUN make --quiet package/openwrt-dist-luci/compile V=99

# Output
WORKDIR /output
RUN mv `find /build/sdk/bin/packages/ | grep v2ray` .
RUN mv `find /build/sdk/bin/packages/ | grep trojan` .
RUN mv `find /build/sdk/bin/packages/ | grep kcptun-client` .
RUN mv `find /build/sdk/bin/packages/ | grep ipt2socks` .
RUN mv `find /build/sdk/bin/packages/ | grep pdnsd-alt` .
RUN mv `find /build/sdk/bin/packages/ | grep shadowsocksr-libev-alt` .
RUN mv `find /build/sdk/bin/packages/ | grep shadowsocksr-libev-server` .
RUN mv `find /build/sdk/bin/packages/ | grep shadowsocksr-libev-ssr-local` .
RUN mv `find /build/sdk/bin/packages/ | grep luci-app-ssr-plus` .
RUN mv `find /build/sdk/bin/packages/ | grep ChinaDNS` .
RUN mv `find /build/sdk/bin/packages/ | grep luci-app-chinadns` .
RUN tar czvf packages.tar.gz *.ipk
RUN mkdir ipks && mv *.ipk ipks
RUN rm -rf /build

CMD ["/bin/bash", "-c", "python3 -u -m http.server -b `awk 'END{print $1}' /etc/hosts` 80"]
