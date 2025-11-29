# Лабораторная работа 3.
# Студент: Gachayev Dmitrii, I2302
# Задача

---

## Плейбук 1. «Статический сайт через Nginx + распаковка архива»
1. Запускаю виртуальную машину, подключаюсь к ней через SSH
2. Запаковываю сайт в архив и передаю на VM:
```bash
tar -czvf site.tar.gz index.html
scp site.tar.gz vboxuser@192.168.56.102:/home/vboxuser
```
3. Создаю `mysite.conf`:
```bash
server {
    listen 8080;
    listen [::]:8080;

    server_name _;

    root /var/www/mysite;
    index index.html;

    access_log /var/log/nginx/mysite_access.log;
    error_log  /var/log/nginx/mysite_error.log;

    location / {
        try_files $uri $uri/ =404;
    }
}
```
4. Далее создаю плейбук:
```
---
- name: Static site via nginx
  hosts: local
  become: yes

  vars:
    site_root: /var/www/mysite

  handlers:
    - name: reload nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded

  tasks:
    # 1. Установить nginx
    - name: Install nginx
      ansible.builtin.package:
        name: nginx
        state: present

    # 1.5. Убедиться, что nginx запущен
    - name: Ensure nginx is running and enabled
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes

    # 2. Создать каталог для сайта
    - name: Create directory for static site
      ansible.builtin.file:
        path: "{{ site_root }}"
        state: directory
        mode: "0755"

    # 3. Распаковать архив сайта files/site.tar.gz
    - name: Unarchive static website
      ansible.builtin.unarchive:
        src: ../files/site.tar.gz
        dest: "{{ site_root }}"
        remote_src: no
      notify: reload nginx

    # 4. Положить nginx vhost
    - name: Install nginx vhost config
      ansible.builtin.copy:
        src: ../files/mysite.conf
        dest: /etc/nginx/conf.d/mysite.conf
        mode: "0644"
      notify: reload nginx

```
5. Запускаю плейбук:
```bash
sudo ansible-playbook playbooks/01_static_site.yml
```

Спустя несколько исправлений получаю работающий плейбук:
```bash
PLAY [Static site via nginx] ******************************************************************************************* TASK [Gathering Facts] ************************************************************************************************* ok: [localhost] TASK [Install nginx] *************************************************************************************************** ok: [localhost] TASK [Ensure nginx is running and enabled] ***************************************************************************** ok: [localhost] TASK [Create directory for static site] ******************************************************************************** ok: [localhost] TASK [Unarchive static website] **************************************************************************************** changed: [localhost] TASK [Install nginx vhost config] ************************************************************************************** changed: [localhost] RUNNING HANDLER [reload nginx] ***************************************************************************************** changed: [localhost] PLAY RECAP ************************************************************************************************************* localhost : ok=7 changed=3 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```
После этого сайт распакован в `/var/www/mysite`, сайт открывается `curl http://localhost:8080`.

## Плейбук 2. «Пользователь деплоя + SSH-ключ + sudoers drop-in»
1. Создаю ssh ключ:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -C "deploy-user"
```
Получаю приватные и публичные ключи.

2. Создаю плейбук `02_deploy_user.yml`
```bash
---
- name: Create deploy user with SSH key and sudoers drop-in
  hosts: local
  become: yes

  vars:
    deploy_user: deploy
    deploy_pubkey: "{{ lookup('file', '~/.ssh/deploy_key.pub') }}"

  tasks:

    # 1. Создать пользователя и добавить в группу sudo
    - name: Ensure deploy user exists and is in sudo group
      ansible.builtin.user:
        name: "{{ deploy_user }}"
        groups: sudo
        append: yes
        shell: /bin/bash
        create_home: yes

    # 2. Создать каталог .ssh для deploy
    - name: Create .ssh directory
      ansible.builtin.file:
        path: "/home/{{ deploy_user }}/.ssh"
        state: directory
        owner: "{{ deploy_user }}"
        group: "{{ deploy_user }}"
        mode: "0700"

    # 3. Добавить публичный ключ в authorized_keys
    - name: Install authorized key for deploy
      ansible.builtin.authorized_key:
        user: "{{ deploy_user }}"
        key: "{{ deploy_pubkey }}"
        state: present

    # 4. Создать sudoers drop-in файл
    - name: Install sudoers drop-in for deploy (with syntax validation)
      ansible.builtin.copy:
        dest: "/etc/sudoers.d/{{ deploy_user }}"
        content: "{{ deploy_user }} ALL=(ALL) NOPASSWD:ALL\n"
        owner: root
        group: root
        mode: "0440"
        validate: "visudo -cf %s"

```

3. Запускаю плейбук:
```bash
sudo ansible-playbook playbooks/02_deploy_user.yml
```

Спустя несколько правок и ошибок плейбук выполняется:
```bash
PLAY [Create deploy user with SSH key and sudoers drop-in] ************************************************************

TASK [Gathering Facts] ************************************************************************************************
ok: [localhost]

TASK [Ensure deploy user exists and is in sudo group] *****************************************************************
ok: [localhost]

TASK [Create .ssh directory] ******************************************************************************************
ok: [localhost]

TASK [Install authorized key for deploy] ******************************************************************************
changed: [localhost]

TASK [Install sudoers drop-in for deploy (with syntax validation)] ****************************************************
changed: [localhost]

PLAY RECAP ************************************************************************************************************
localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Проверяю наличие юзера:
```bash
~/ansible-lab$ id deploy
uid=1001(deploy) gid=1001(deploy) groups=1001(deploy),27(sudo)
```

Проверяю права юзера:
```bash
vboxuser@Zabbix-Server:~/ansible-lab$ sudo -iu deploy
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

deploy@Zabbix-Server:~$ whoami
deploy
deploy@Zabbix-Server:~$ ls -la ~
total 24
drwxr-x--- 3 deploy deploy 4096 Nov 29 18:19 .
drwxr-xr-x 4 root   root   4096 Nov 29 18:19 ..
-rw-r--r-- 1 deploy deploy  220 Mar 31  2024 .bash_logout
-rw-r--r-- 1 deploy deploy 3771 Mar 31  2024 .bashrc
-rw-r--r-- 1 deploy deploy  807 Mar 31  2024 .profile
drwx------ 2 deploy deploy 4096 Nov 29 18:25 .ssh
deploy@Zabbix-Server:~$ ls -la ~/.ssh
total 12
drwx------ 2 deploy deploy 4096 Nov 29 18:25 .
drwxr-x--- 3 deploy deploy 4096 Nov 29 18:19 ..
-rw------- 1 deploy deploy   93 Nov 29 18:25 authorized_keys
deploy@Zabbix-Server:~$ ls -l /etc/sudoers.d/
total 8
-r--r----- 1 root root   30 Nov 29 18:25 deploy
-r--r----- 1 root root 1068 Jan 29  2024 README
deploy@Zabbix-Server:~$ cat /etc/sudoers.d/deploy
cat: /etc/sudoers.d/deploy: Permission denied
deploy@Zabbix-Server:~$ sudo visudo -cf /etc/sudoers.d/deploy
/etc/sudoers.d/deploy: parsed OK
deploy@Zabbix-Server:~$
```

## Вывод
В ходе работы были созданы два плейбука Ansible. Первый автоматически развернул статический сайт через nginx, второй создал пользователя deploy, настроил вход по SSH-ключу и выдал ему права sudo через отдельный файл с проверкой синтаксиса.