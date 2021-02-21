FROM debian:buster

# Init
SHELL ["/bin/bash", "-c"]
RUN apt-get update
RUN apt-get install -y curl wget xz-utils git build-essential libncurses5-dev gawk upx unzip python python3 file

# Prepare sdk
WORKDIR /build
ARG URL
RUN curl -s -O $URL
RUN FILE="${URL##*/}" && tar xf "${FILE}" &&  mv "${FILE%.*.*}" sdk
RUN git clone https://github.com/xiaorouji/openwrt-passwall.git

WORKDIR /build/sdk
RUN ./scripts/feeds clean
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
RUN ./scripts/feeds uninstall xray-core
RUN ./scripts/feeds install -p passwall -f xray-core
RUN cp -r ../openwrt-passwall/brook package/
#RUN cp -r ../openwrt-passwall/v2ray package/
RUN cp -r ../openwrt-passwall/xray package/
RUN cp -r ../openwrt-passwall/trojan-plus package/
RUN cp -r ../openwrt-passwall/trojan-go package/
RUN cp -r ../openwrt-passwall/kcptun package/
RUN cp -r ../openwrt-passwall/tcping package/
RUN cp -r ../openwrt-passwall/dns2socks package/
RUN cp -r ../openwrt-passwall/ipt2socks package/
RUN cp -r ../openwrt-passwall/microsocks package/.
RUN cp -r ../openwrt-passwall/ssocks package/
RUN cp -r ../openwrt-passwall/pdnsd-alt package/
RUN cp -r ../openwrt-passwall/chinadns-ng package/
RUN cp -r ../openwrt-passwall/shadowsocksr-libev package/
RUN cp -r ../openwrt-passwall/v2ray-plugin package/
RUN cp -r ../openwrt-passwall/simple-obfs package/
RUN cp -r ../openwrt-passwall/luci-app-passwall package/
RUN ln -s `which upx` staging_dir/host/bin/upx  
RUN echo "src-git dependencies https://github.com/Lienol/openwrt-packages.git;19.07" >> feeds.conf.default
#RUN echo "git clone https://github.com/kenzok8/small.git" >> feeds.conf.default

# Config
RUN make defconfig
RUN sed -i 's/CONFIG_PACKAGE_brook=m/CONFIG_PACKAGE_brook=y/g' .config
#RUN sed -i 's/CONFIG_PACKAGE_v2ray=m/CONFIG_PACKAGE_v2ray=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_xray=m/CONFIG_PACKAGE_xray=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_trojan-plus=m/CONFIG_PACKAGE_trojan-plus=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_trojan-go=m/CONFIG_PACKAGE_trojan-go=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_kcptun-client=m/CONFIG_PACKAGE_kcptun-client=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_kcptun-server=m/CONFIG_PACKAGE_kcptun-server=n/g' .config
RUN sed -i 's/CONFIG_PACKAGE_tcping=m/CONFIG_PACKAGE_tcping=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_ipt2socks=m/CONFIG_PACKAGE_ipt2socks=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_microsocks=m/CONFIG_PACKAGE_microsocks=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_ssocks=m/CONFIG_PACKAGE_ssocks=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_pdnsd-alt=m/CONFIG_PACKAGE_pdnsd-alt=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_v2ray-plugin=m/CONFIG_PACKAGE_v2ray-plugin=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_simple-obfs=m/CONFIG_PACKAGE_simple-obfs=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_chinadns-ng=m/CONFIG_PACKAGE_chinadns-ng=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_shadowsocksr-libev-alt=m/CONFIG_PACKAGE_shadowsocksr-libev-alt=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_shadowsocksr-libev-server=m/CONFIG_PACKAGE_shadowsocksr-libev-server=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=m/CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=y/g' .config
RUN sed -i 's/CONFIG_PACKAGE_luci-app-passwall=m/CONFIG_PACKAGE_luci-app-passwall=y/g' .config
RUN sed -i 's/CONFIG_V2RAY_EXCLUDE_V2CTL=y/CONFIG_V2RAY_EXCLUDE_V2CTL=n/g' .config
RUN sed -i 's/CONFIG_V2RAY_EXCLUDE_ASSETS=y/CONFIG_V2RAY_EXCLUDE_ASSETS=n/g' .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook=y" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray=y" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun=y" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks=y" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy=y" >> .config
RUN echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG=y" >> .config

# Compile 
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
RUN ./scripts/feeds install pcre boost libev luci-base
RUN ./scripts/feeds install -p dependencies golang

RUN make package/brook/compile V=99
#RUN make package/v2ray/compile V=99
RUN make package/xray/compile V=99
RUN make package/trojan-plus/compile V=99
RUN make package/trojan-go/compile V=99
RUN make package/kcptun/compile V=99
RUN make package/tcping/compile V=99
RUN make package/ipt2socks/compile V=99
RUN make package/dns2socks/compile V=99
RUN make package/microsocks/compile V=99
RUN make package/ssocks/compile V=99
RUN make package/pdnsd-alt/compile V=99
RUN make package/v2ray-plugin/compile V=99
RUN make package/simple-obfs/compile V=99
RUN make package/chinadns-ng/compile V=99
RUN make package/shadowsocksr-libev/compile V=99
RUN make package/feeds/luci/luci-base/compile V=99
RUN make package/luci-app-passwall/compile V=99

# Output
WORKDIR /output
RUN mv `find /build/sdk/bin/packages/ | grep brook` .
RUN mv `find /build/sdk/bin/packages/ | grep xray` .
RUN mv `find /build/sdk/bin/packages/ | grep trojan-plus` .
RUN mv `find /build/sdk/bin/packages/ | grep trojan-go` .
RUN mv `find /build/sdk/bin/packages/ | grep kcptun` .
RUN mv `find /build/sdk/bin/packages/ | grep tcping` .
RUN mv `find /build/sdk/bin/packages/ | grep ipt2socks` .
RUN mv `find /build/sdk/bin/packages/ | grep dns2socks` .
RUN mv `find /build/sdk/bin/packages/ | grep microsocks` .
RUN mv `find /build/sdk/bin/packages/ | grep ssocks` .
RUN mv `find /build/sdk/bin/packages/ | grep pdnsd-alt` .
RUN mv `find /build/sdk/bin/packages/ | grep v2ray-plugin` .
RUN mv `find /build/sdk/bin/packages/ | grep simple-obfs` .
RUN mv `find /build/sdk/bin/packages/ | grep chinadns-ng` .
RUN mv `find /build/sdk/bin/packages/ | grep shadowsocksr-libev` .
#RUN mv `find /build/sdk/bin/packages/ | grep v2ray` .
RUN mv `find /build/sdk/bin/packages/ | grep luci-app-passwall` .

ENTRYPOINT ["/bin/bash", "-c", "python3 -u -m http.server -b `awk 'END{print $1}' /etc/hosts` 80"]
