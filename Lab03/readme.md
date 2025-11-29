# Лабораторная работа 3.
# Студент: Gachayev Dmitrii, I2302
# Задача

---

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