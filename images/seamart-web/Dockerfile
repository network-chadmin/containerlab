# seamart-web 2.0
#
# The SeaMart partner portal page, served by nginx. Used only by the
# seamart-server node in the labs. Build after network-host:2.0.
#   docker buildx build --platform linux/amd64,linux/arm64 \
#     -t networkchadmin/seamart-web:2.0 --push images/seamart-web
FROM networkchadmin/network-host:2.0

RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Serve the page on port 80 with the default site disabled.
COPY nginx-seamart.conf /etc/nginx/conf.d/seamart.conf
RUN rm -f /etc/nginx/sites-enabled/default
COPY index.html /var/www/html/index.html

EXPOSE 80
# The base entrypoint starts sshd, then nginx runs in the foreground.
CMD ["nginx", "-g", "daemon off;"]
