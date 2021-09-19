FROM nginx:1.18.0 AS build

RUN apt-get update && \
    apt-get install -y \
        openssh-client \
        git \
        wget \
        libxml2 \
        libxslt1-dev \
        libpcre3 \
        libpcre3-dev \
        zlib1g \
        zlib1g-dev \
        openssl \
        libssl-dev \
        libtool \
        automake \
        gcc \
        g++ \
        make && \
    rm -rf /var/cache/apt

RUN wget "https://people.freebsd.org/~osa/ngx_http_redis-0.3.9.tar.gz" && \
    tar -C /usr/src -xzvf ngx_http_redis-0.3.9.tar.gz

RUN wget "https://hg.nginx.org/nginx/archive/tip.tar.gz" && \
    tar -C /usr/src -xzvf tip.tar.gz

RUN wget "https://github.com/openresty/redis2-nginx-module/archive/refs/tags/v0.15.tar.gz" && \
    tar -C /usr/src -xzvf v0.15.tar.gz

RUN wget "https://github.com/openresty/srcache-nginx-module/archive/refs/tags/v0.32.tar.gz" && \
    tar -C /usr/src -xzvf v0.32.tar.gz

RUN wget "https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v0.3.1.tar.gz" && \
    tar -C /usr/src -xzvf v0.3.1.tar.gz

RUN wget "https://github.com/openresty/set-misc-nginx-module/archive/refs/tags/v0.33.tar.gz" && \
    tar -C /usr/src -xzvf v0.33.tar.gz

RUN wget "https://github.com/openresty/echo-nginx-module/archive/refs/tags/v0.62.tar.gz" && \
    tar -C /usr/src -xzvf v0.62.tar.gz


RUN wget "http://nginx.org/download/nginx-1.21.1.tar.gz" && \
    tar -C /usr/src -xzvf nginx-1.21.1.tar.gz

RUN cd /usr/src/nginx-97cf8284fd19 && \
    auto/configure `nginx -V 2>&1 | sed "s/ \-\-/ \\\ \n\t--/g" | grep "\-\-" | grep -ve opt= -e param=` \
                   --with-http_ssl_module --with-debug --add-module=/usr/src/ngx_http_redis-0.3.9 --add-module=/usr/src/redis2-nginx-module-0.15 --add-module=/usr/src/srcache-nginx-module-0.32 --add-module=/usr/src/ngx_devel_kit-0.3.1 --add-module=/usr/src/set-misc-nginx-module-0.33 --add-module=/usr/src/echo-nginx-module-0.62 && \
    make

FROM nginx:1.18.0
COPY --from=build /usr/src/nginx-97cf8284fd19/objs/nginx /usr/sbin
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443
