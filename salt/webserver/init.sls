nginx:
    user.present:
        - gid_from_name: yes
    service.running:
        - enable: yes
        - require:
            - pkg: nginx
        - watch:
            - file: /etc/nginx/nginx.conf
    pkg.installed:
        - require:
            - pkg: old-nginx-purged
            - cmd: nginx-sources-updated
apache2:
    service.dead:
        - enable: no
    pkg.purged: []

old-nginx-purged:
    pkg.purged:
        - names:
            - nginx-full
            - nginx-common

/root/nginx_signing.key:
    file.managed:
        - source: salt://webserver/nginx_signing.key
        - user: root
        - group: root
        - mode: 600

add-nginx-signing-key:
    cmd.wait:
        - name: "apt-key add /root/nginx_signing.key"
        - watch:
            - file: /root/nginx_signing.key

add-nginx-to-sources:
    file.append:
        - name: /etc/apt/sources.list
        - text:
            - "deb http://nginx.org/packages/ubuntu/ precise nginx"
            - "deb-src http://nginx.org/packages/ubuntu/ precise nginx"
        - require:
            - cmd: add-nginx-signing-key

nginx-sources-updated:
    cmd.wait:
        - name: "apt-get update -y"
        - watch:
            - file: add-nginx-to-sources

/etc/nginx/nginx.conf:
    file.managed:
        - source: salt://webserver/nginx.conf
        - user: root
        - group: root
        - mode: 644

/etc/ufw/applications.d/nginx:
    file.managed:
        - source: salt://webserver/ufw_rules
        - user: root
        - group: root
        - mode: 644

"ufw allow 'nginx full'":
    cmd.run:
        - require:
            - file: /etc/ufw/applications.d/nginx

libevent-dev:
    pkg.installed

python-webserver-libs:
    pip.installed:
        - names:
            - greenlet
            - gevent
            - gunicorn
            - flask
        - require:
            - pkg: libevent-dev
