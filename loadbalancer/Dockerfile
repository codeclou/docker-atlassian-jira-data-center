FROM alpine:3.5

#
# BASE PACKAGES
#
RUN apk add --no-cache \
            bash \
            apache2 \
            apache2-proxy \
            apache2-utils \
            python \
            py-pip && \
            pip install shinto-cli

#
# ERROR LOG, USER
#
COPY docker-entrypoint.sh /work-private/docker-entrypoint.sh
RUN chmod u+rx,g+rx,o+rx,a-w /work-private/docker-entrypoint.sh && \
    ln -sf /dev/stderr /var/log/apache2/error.log && \
    addgroup -g 10777 worker && \
    adduser -h /work -H -D -G worker -u 10777 worker && \
    mkdir -p /work && \
    mkdir -p /work-private && \
    chown -R worker:worker /work/ && \
    chown -R worker:worker /work-private && \
    chown -R worker:worker /var/www/logs && \
    chown -R worker:worker /etc/apache2/ && \
    touch /var/www/logs/error.log && chown -R worker:worker /var/www/logs/error.log && \
    touch /var/www/logs/access.log && chown -R worker:worker /var/www/logs/access.log && \
    chown -R worker:worker /var/log/apache2 && \
    mkdir /run/apache2 && chown -R worker:worker /run/apache2 && \
    sed -i -e 's/Listen 80/Listen 9999\nServerName localhost/g' /etc/apache2/httpd.conf && \
    sed -i -e 's/AllowOverride\s*None/AllowOverride All/ig' /etc/apache2/httpd.conf && \
    echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/apache2/httpd.conf && \
    echo "LoadModule proxy_http_module modules/mod_proxy_http.so" >> /etc/apache2/httpd.conf && \
    echo "LoadModule proxy_balancer_module modules/mod_proxy_balancer.so" >> /etc/apache2/httpd.conf && \
    echo "LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so" >> /etc/apache2/httpd.conf && \
    echo "LoadModule slotmem_shm_module modules/mod_slotmem_shm.so" >> /etc/apache2/httpd.conf && \
    echo "Include /work-private/loadbalancer-virtual-host.conf" >> /etc/apache2/httpd.conf

#
# TEMPLATES
#
COPY loadbalancer-virtual-host.conf.jinja2 /work-private

#
# WORKDIR
#
WORKDIR /work
EXPOSE 9999

#
# RUN
#
USER worker
ENV NODES 1
VOLUME ["/work"]
ENTRYPOINT ["/work-private/docker-entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]