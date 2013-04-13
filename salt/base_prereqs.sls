base-packages:
    pkg.installed:
        - order: 1
        - names:
            - python-software-properties
            - build-essential
            - git
            - python-dev


# assumimos que pip foi instalado por bootstrap.  asseguramo-nos de ter
# a ultima versom.
pip:
    cmd.run:
        - name: "pip install --upgrade pip"

# Necessário para o fileserver backend.
gitpython:
    pip.installed:
        - order: 1
        - require:
            - pkg: build-essential
            - pkg: git
            - pkg: python-dev
            - cmd: pip
