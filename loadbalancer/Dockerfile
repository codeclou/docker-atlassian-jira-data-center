FROM alpine:3.8

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
            pip install --upgrade pip && \
            pip install shinto-cli

#
# ERROR LOG, USER
#
COPY docker-entrypoint.sh /work-private/docker-entrypoint.sh
COPY proxy.conf /etc/apache2/conf.d/proxy.conf
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
    sed -i -e 's/Listen 80/#Listen 80\nServerName localhost/g' /etc/apache2/httpd.conf && \
    sed -i -e 's/AllowOverride\s*None/AllowOverride All/ig' /etc/apache2/httpd.conf && \
    echo "Include /work-private/loadbalancer-virtual-host.conf" >> /etc/apache2/httpd.conf


#
# TEMPLATES
#
COPY loadbalancer-virtual-host.conf.jinja2 /work-private/loadbalancer-virtual-host.conf.jinja2
COPY document-root /work-private/document-root
RUN chown -R worker /work-private/* && chmod -R a+x /work-private


#
# WORKDIR
#
WORKDIR /work

#
# RUN
#
USER worker
ENV NODES 1
ENV LB_PORT 9090
ENV NODES_NAME_SCHEMA node___NUM___
VOLUME ["/work"]
ENTRYPOINT ["/work-private/docker-entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]
