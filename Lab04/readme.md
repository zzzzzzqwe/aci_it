# Лабораторная работа 4.
# Студент: Gachayev Dmitrii, I2302
# Задача
////

---

## Плейбук 1. install_docker.yml для автоматизированной установки Docker на всех хостах в группе "docker_hosts".

Создаю такой файл:
```bash
---
- name: Install Docker Engine and Docker Compose plugin
  hosts: docker_hosts
  become: yes

  vars:
    docker_user: vboxuser

  tasks:
    - name: Install required packages
      ansible.builtin.apt:
        name:
          - ca-certificates
          - curl
          - gnupg
          - lsb-release
        state: present
        update_cache: yes

    - name: Add Docker GPG apt key
      ansible.builtin.apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker APT repository
      ansible.builtin.apt_repository:
        repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        state: present
        filename: docker

    - name: Install Docker Engine and plugins
      ansible.builtin.apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: present
        update_cache: yes

    - name: Ensure Docker service is running and enabled
      ansible.builtin.service:
        name: docker
        state: started
        enabled: yes

    - name: Add user to docker group
      ansible.builtin.user:
        name: "{{ docker_user }}"
        groups: docker
        append: yes
```
Он установит необходимые системные пакеты, добавит официальный репозиторий Docker для Ubuntu, установит и запустит Docker.

Далее запускаю этот плейбук:
```bash
sudo ansible-playbook playbook/install_docker.yml
```

Плейбук выполняется без ошибок:
```bash
PLAY [Install Docker Engine and Docker Compose plugin] *****************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]

TASK [Install required packages] ***************************************************************************************
ok: [localhost]

TASK [Add Docker GPG apt key] ******************************************************************************************
changed: [localhost]

TASK [Add Docker APT repository] ***************************************************************************************
changed: [localhost]

TASK [Install Docker Engine and plugins] *******************************************************************************
changed: [localhost]

TASK [Ensure Docker service is running and enabled] ********************************************************************
ok: [localhost]

TASK [Add user to docker group] ****************************************************************************************
changed: [localhost]

PLAY RECAP *************************************************************************************************************
localhost                  : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Проверяю работу Docker:
```
~/ansible-lab2$ docker --version
Docker version 29.1.1, build 0aedba5
~/ansible-lab2$ docker compose version
Docker Compose version v2.40.3
```