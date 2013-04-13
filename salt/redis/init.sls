#XXX: refactorar criaçom de utentes a ũa macro de jinja.

# Lembrar de abrir portos com ufw e requerir contrasinal em redis.conf quando
# quigermos servir redis a outros nodos.

redis:
    user.present:
        - gid_from_name: yes
        - shell: /bin/bash
        - home: /home/redis

{% for directory in '/home/redis','/var/log/redis' %}
{{ directory }}:
    file.directory:
        - user: redis
        - group: redis
        - mode: 700
        - require:
            - user: redis
{% endfor %}

/etc/redis.conf:
    file.managed:
        - source: salt://redis/redis.conf
        - mode: 600
        - user: redis
        - group: redis

/etc/init.d/redis-server:
    file.managed:
        - source: salt://redis/init-script
        - mode: 700
        - user: root
        - root: root

/home/redis/build-redis.bash:
    file.managed:
        - source: salt://redis/build-redis.bash
        - mode: 700
        - user: redis
        - group: redis
        - require:
            - file: /home/redis

build-redis:
    cmd.run:
        - name: "./build-redis.bash"
        - unless: "which redis-server"
        - cwd: /home/redis
        - user: redis
        - require:
            - file: /home/redis/build-redis.bash

redis-installed:
    cmd.run:
        - name: "make install"
        - unless: "which redis-server"
        - cwd: /home/redis/src
        - user: root
        - require:
            - cmd: build-redis

redis-server:
    service.running:
        - enable: yes
        - require:
            - file: /home/redis
            - file: /var/log/redis
            - cmd: redis-installed
        - watch:
            - file: /etc/init.d/redis-server
            - file: /etc/redis.conf
