FROM nginx:1.18.0 AS build

WORKDIR /src
RUN apt-get update && \
    apt-get install -y git gcc make mercurial libperl-dev libpcre3-dev zlib1g-dev libxslt1-dev libgd-ocaml-dev libgeoip-dev wget
RUN git clone -b openssl-3.0 https://github.com/openssl/openssl openssl-3.0 && \
    hg clone https://hg.nginx.org/nginx && \
    hg clone http://hg.nginx.org/njs
    
RUN wget "https://people.freebsd.org/~osa/ngx_http_redis-0.3.9.tar.gz" && \
    tar -C /src -xzvf ngx_http_redis-0.3.9.tar.gz


RUN cd nginx && \
    auto/configure `nginx -V 2>&1 | sed "s/ \-\-/ \\\ \n\t--/g" | grep "\-\-" | grep -ve opt= -e param=` \
                   --with-openssl=../openssl-3.0 --with-debug  && \
    make

FROM nginx:1.18.0
COPY --from=build /src/nginx/objs/nginx /usr/sbin
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443