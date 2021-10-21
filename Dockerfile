FROM nginx:1.18.0 AS build

ENV lua_module=0.10.15
ENV luaJIT=2.0.5
ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.0

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
    
RUN wget "https://github.com/openresty/lua-nginx-module/archive/refs/tags/v${lua_module}.tar.gz" --no-check-certificate && \
    tar -C /usr/src -xzvf v0.10.15.tar.gz
    
RUN wget "https://github.com/LuaJIT/LuaJIT/archive/refs/tags/v${luaJIT}.tar.gz" --no-check-certificate && \
    tar -C /usr/src -xzvf v2.0.5.tar.gz && \
    cd /usr/src/LuaJIT-2.0.5 && \
    make install

RUN NGINX_ARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \  
        ./configure --with-cc-opt=-O2 --with-ld-opt=-Wl,-rpath,/usr/local/lib --with-compat --with-http_ssl_module --add-dynamic-module=/usr/src/ngx_http_redis-${redis_module} --add-dynamic-module=/usr/src/redis2-nginx-module-${redis2_module} --add-dynamic-module=/usr/src/srcache-nginx-module-${srcache_module} --add-dynamic-module=/usr/src/ngx_devel_kit-${ndk} --add-dynamic-module=/usr/src/set-misc-nginx-module-${setmisc_module} --add-dynamic-module=/usr/src/echo-nginx-module-${echo_module} --add-dynamic-module=/usr/src/form-input-nginx-module-${forminput_module} --add-dynamic-module=/usr/src/nginx_cookie_flag_module-${cookieflag_module} --add-dynamic-module=/usr/src/lua-nginx-module-${lua_module} ${NGINX_ARGS} && \
    make modules

FROM nginx:1.18.0

ENV LUAJIT_LIB=/etc/nginx/modules
ENV LUAJIT_INC=/etc/nginx/modules
RUN apt-get update && \
    apt-get install nano

COPY --from=build /usr/src/nginx-97cf8284fd19/objs/nginx /usr/sbin
COPY --from=build /usr/local/lib/* /usr/local/lib/
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443
