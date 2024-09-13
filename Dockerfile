FROM debian:latest
WORKDIR /root

ARG TAILSCALE_VERSION
ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

RUN apt-get -qq update \
  && apt-get -qq install --upgrade -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    netcat-openbsd \
    wget \
    dnsutils \
  > /dev/null \
  && apt-get -qq clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
  && :

RUN echo "+search +short" > /root/.digrc
COPY run-tailscale.sh /root/

RUN wget -q "https://pkgs.tailscale.com/stable/tailscale_1.70.0_amd64.tgz" && tar xzf "tailscale_1.70.0_amd64.tgz" --strip-components=1
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

EXPOSE 80
EXPOSE 10000

RUN echo "/root/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 & /root/tailscale up --hostname=vpn-sydney --advertise-exit-node && sleep infinity" > /root/start.sh
RUN chmod +x /root/start.sh

CMD ["/root/start.sh"]
