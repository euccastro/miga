# Quando tivermos outros minions, lembremo-nos de abrir os portos de salt no
# guarda-fogo:
#
# "ufw allow salt":
#     - cmd.run

/etc/salt:
    file.directory:
        - user: root
        - group: root
        - mode: 700

{% for service in 'master','minion' %}

/etc/salt/{{ service }}:
    file.managed:
        - source: salt://salt/{{ service }}
        - user: root
        - group: root
        - mode: 600
        - require:
            - file: /etc/salt

salt-{{ service }}:
    pkg:
        - installed
    service.running:
        - enable: yes
        - watch:
            - file: /etc/salt/{{ service }}

{% endfor %}
