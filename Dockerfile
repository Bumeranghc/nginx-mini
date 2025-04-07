FROM ubuntu:24.04 AS build

#Define build arguments for version
ARG VERSION=1.24.0
ARG PATCH=2ubuntu7.3
ARG TIMEZONE=Asia/Jerusalem

ENV TZ=${TIMEZONE}
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools, libraries and utilities 
RUN apt-get update -y && apt-get install -y \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    libgd-dev \
    libxml2-dev \
    wget \
    gnupg2 \
    devscripts

# Prepare NGINX source signature check
RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/nginx/${VERSION}-${PATCH}/nginx_${VERSION}-${PATCH}.dsc && \
    gpg --verify nginx_${VERSION}-${PATCH}.dsc 2>&1 | grep "using" | awk '{print $NF}' > /tmp/KEYID && rm nginx_${VERSION}-${PATCH}.dsc && \
    mkdir -p /root/.gnupg && chmod 700 /root/.gnupg && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys $(cat /tmp/KEYID) && \
    gpg --export $(cat /tmp/KEYID) | gpg --dearmor -o /etc/apt/trusted.gpg.d/nginx.gpg && \
    rm /tmp/KEYID

# Use rootless user
RUN adduser --disabled-password --gecos '' -u 2000 nginx_user
RUN usermod -a -G www-data nginx_user
USER nginx_user

# Retrieve, verify and unpack Nginx source 
RUN mkdir -p ~/.gnupg && chmod 700 ~/.gnupg && gpg --list-keys
RUN echo 'DSCVERIFY_KEYRINGS="/etc/apt/trusted.gpg.d/nginx.gpg:~/.gnupg/trustdb.gpg"' > ~/.devscripts
WORKDIR /tmp
RUN dget -x https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/nginx/${VERSION}-${PATCH}/nginx_${VERSION}-${PATCH}.dsc
WORKDIR /tmp/nginx-${VERSION}

# Build and install nginx
RUN ./configure --with-ld-opt="-static" \
    --prefix=/home/nginx_user/nginx \
    --with-http_sub_module \
    --with-pcre  \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_addition_module \
    --user=nginx_user \
    --group=nginx_user && \
    make install &&  \
    strip /home/nginx_user/nginx/sbin/nginx

# Symlink access and error logs to /dev/stdout and /dev/stderr, in 
# order to make use of Docker's logging mechanism
RUN ln -sf /dev/stdout /home/nginx_user/nginx/logs/access.log && \
    ln -sf /dev/stderr /home/nginx_user/nginx/logs/error.log

FROM scratch AS result

# Customise static content, and configuration
COPY --from=build /etc/passwd /etc/group /etc/

# Use rootless user
USER nginx_user

WORKDIR /home/nginx_user/nginx/client_body_temp
WORKDIR /home/nginx_user/nginx/html
WORKDIR /home/nginx_user/nginx/conf
COPY --from=build /home/nginx_user/nginx /home/nginx_user/nginx

COPY index.html /home/nginx_user/nginx/html/
COPY nginx.conf /home/nginx_user/nginx/conf/
COPY mime.types /home/nginx_user/nginx/conf/

#Change default stop signal from SIGTERM to SIGQUIT
STOPSIGNAL SIGQUIT

WORKDIR /

# Expose port
EXPOSE 8080

# Define entrypoint and default parameters 
ENTRYPOINT ["/home/nginx_user/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
