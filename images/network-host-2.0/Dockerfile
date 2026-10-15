# network-host 2.0
#
# General-purpose Linux host for the Network Academy and Shrimp Co. labs.
# Build for both architectures and push. Build this image before seamart-web.
#   docker buildx build --platform linux/amd64,linux/arm64 \
#     -t networkchadmin/network-host:2.0 --push images/network-host-2.0
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Phoenix

# Tools grouped by purpose. --no-install-recommends skips optional packages
# apt would otherwise add, which keeps the image smaller.
#   shell and editing:       bash nano vim-tiny sudo ifupdown
#   SSH:                     openssh-client openssh-server
#   addressing and DNS:      iproute2 iputils-ping traceroute mtr-tiny dnsutils net-tools isc-dhcp-client
#   capture and scanning:    tcpdump tshark nmap
#   traffic testing:         iperf3 socat netcat-openbsd curl telnet
#   multicast:               smcroute omping
#   utilities:               jq ethtool
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash nano vim-tiny sudo ifupdown \
        openssh-client openssh-server \
        iproute2 iputils-ping traceroute mtr-tiny dnsutils net-tools isc-dhcp-client \
        tcpdump tshark nmap \
        iperf3 socat netcat-openbsd curl telnet \
        smcroute omping \
        jq ethtool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# DHCP client settings carried over from 1.0. They control how DHCP-provided
# DNS servers are handled, so DNS labs behave the same way they did before.
RUN printf 'supersede domain-name-servers;\nprepend domain-name-servers;\n' > /etc/dhcp/dhclient.conf

# sshd needs its run directory. Password login is enabled for the labs.
# labuser is a regular user with passwordless sudo, for lab convenience.
RUN mkdir -p /run/sshd \
    && printf 'PasswordAuthentication yes\nPermitRootLogin no\n' > /etc/ssh/sshd_config.d/lab.conf \
    && useradd -ms /bin/bash labuser \
    && echo 'labuser:admin' | chpasswd \
    && usermod -aG sudo labuser \
    && echo 'labuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/labuser \
    && chmod 0440 /etc/sudoers.d/labuser

# The entrypoint starts sshd in the background, then runs the container command.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

WORKDIR /home/labuser
EXPOSE 22

# The container runs as root so sshd can start. labuser logs in over SSH.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
