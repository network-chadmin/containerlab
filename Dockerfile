# Network Lab Ubuntu Image
# Based on Ubuntu 22.04 LTS with networking tools for education
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
# This is critical for automated Docker builds
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone to avoid tzdata prompts
ENV TZ=America/Phoenix

# Optimize apt to reduce image size by disabling unnecessary packages
# Install-Suggests "0" = don't install suggested packages
# Install-Recommends "0" = don't install recommended packages  
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

# Update package list and install networking tools
# Each tool serves a specific educational purpose
RUN apt-get update && apt-get install -y \
    # Basic system tools
    bash \
    nano \
    vim \
    curl \
    wget \
    git \
    jq \
    sudo \
    # Networking analysis tools
    tcpdump \
    tshark \
    nmap \
    # Network connectivity tools  
    iputils-ping \
    traceroute \
    mtr-tiny \
    dnsutils \
    # Network services
    nginx \
    openssh-client \
    openssh-server \
    telnet \
    isc-dhcp-client \
    # Network testing tools
    netcat-openbsd \
    socat \
    iperf3 \
    # Performance testing
    apache2-utils \
    # Interface management
    ethtool \
    iproute2 \
    net-tools \
    # Traditional networking (for ifupdown)
    ifupdown \
    # Miscellanous
    debianutils \
    libc6 \
    # Clean up package cache to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create nginx directory structure and fix permissions
RUN mkdir -p /var/log/nginx /var/lib/nginx /run \
    && chown -R www-data:www-data /var/log/nginx /var/lib/nginx

# Create a simple nginx configuration for testing
RUN echo 'server { \
    listen 80 default_server; \
    listen [::]:80 default_server; \
    root /var/www/html; \
    index index.html index.htm; \
    server_name _; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
}' > /etc/nginx/sites-available/default

RUN mkdir -p /var/www/html && cat <<'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>SeaMart Partner Portal</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    html, body { margin:0; padding:0; font-family: Arial, sans-serif; background:#f4f7f9; color:#222; }
    header { background:#004f6e; color:#fff; padding: 20px 40px; }
    header h1 { margin:0; font-size: 26px; }
    main { max-width: 800px; margin: 40px auto; background:#fff; padding: 32px; border-radius:8px; box-shadow: 0 2px 12px rgba(0,0,0,0.1); }
    p { line-height: 1.5; }
    .muted { color: #666; font-size: 0.9rem; }
    code { background:#f0f0f0; padding: 2px 6px; border-radius: 4px; }
  </style>
</head>
<body>
  <header>
    <h1>SeaMart Partner Portal</h1>
  </header>
  <main>
    <p>Welcome to the <strong>SeaMart Partner Portal</strong>. This secure gateway is used by partners, suppliers, and Shrimp Co. employees to access shared resources and applications.</p>
    <p class="muted">If you have reached this page during a lab exercise, you have successfully connected to the SeaMart edge web server.</p>
    <p><strong>Server Hostname:</strong> <span id="hostname">Loading…</span></p>
    <p class="muted">Try <code>curl http://seamart.com</code> from a lab host or browse to this page to validate NAT, routing, and DNS.</p>
  </main>
  <script>
    document.getElementById("hostname").textContent = window.location.hostname;
  </script>
</body>
</html>
EOF

RUN mkdir /var/run/sshd && \
    # Enable password authentication
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    # Allow labuser to login
    echo 'AllowUsers labuser' >> /etc/ssh/sshd_config && \
# Create a network lab user (non-root for security best practices)
RUN useradd -ms /bin/bash labuser && \
    usermod -aG sudo labuser && \
    echo "labuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Set password for SSH access
    echo 'labuser:admin' | chpasswd

# Create startup script that handles both nginx and keeps container running
RUN echo '#!/bin/bash \
# Start nginx in background \
nginx -g "daemon off;" & \
# Keep container running by tailing a log file \
tail -f /dev/null' > /usr/local/bin/start-lab.sh \
    && chmod +x /usr/local/bin/start-lab.sh

# Set working directory
WORKDIR /home/labuser

# Switch to non-root user
USER labuser

# Expose HTTP port for testing
EXPOSE 80

# Simple startup - just keep container alive
# Students can start nginx manually when needed
CMD ["tail", "-f", "/dev/null"]