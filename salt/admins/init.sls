# Cadastra as utentes listadas com acesso ssh e root sem contrasinal.
#
# Para acrescentar ũa utente:
#  - Engade a sua chave pública a este cartafol, e.g.:
#     cp ~/.ssh/id_rsa.pub admins/meunome.id_rsa.pub
#  - Acrescenta o seu nome na lista de embaixo, e.g.:
#      for user in 'es','meunome'

{% for name in 'es', %}

{{ name }}:
    user.present:
      - gid_from_name: yes
      - home: /home/{{ name }}
      - shell: /bin/bash
    ssh_auth.present:
      - user: {{ name }}
      - source: salt://admins/{{ name }}.id_rsa.pub
      - require:
        - user: {{ name }}
        - file: /home/{{ name }}/.ssh

/home/{{ name }}:
    file.directory:
      - user: {{ name }}
      - mode: 700
      - require:
        - user: {{ name }}

/home/{{ name }}/.ssh:
    file.directory:
      - user: {{ name }}
      - mode: 700
      - require:
        - user: {{ name }}
        - file: /home/{{ name }}

/etc/sudoers.d/90-{{ name }}:
    file.managed:
      - source: salt://admins/nopw_sudoers
      - user: root
      - gid: root
      - mode: 440
      - template: jinja
      - context:
        username: {{ name }}

{% endfor %}
