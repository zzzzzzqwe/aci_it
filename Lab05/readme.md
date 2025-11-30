# Лабораторная работа 5.
# Студент: Gachayev Dmitrii, I2302
# Задача
///

---

## Установка Gitlab CE через Docker
Выполняю такую команду с IP моей виртуалки (поменял порты так как 80 у меня занят):
```bash
sudo docker run -d \
  --hostname 192.168.56.102 \
  -p 8888:80 \
  -p 5443:443 \
  -p 8022:22 \
  --name gitlab \
  -e GITLAB_OMNIBUS_CONFIG="external_url='http://192.168.56.102:8888'; gitlab_rails['gitlab_shell_ssh_port']=8022" \
  -v gitlab-data:/var/opt/gitlab \
  -v ~/gitlab-config:/etc/gitlab \
  gitlab/gitlab-ce:latest
```
