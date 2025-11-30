# Лабораторная работа 5.
# Студент: Gachayev Dmitrii, I2302
# Задача
///

---

## 1. Развертывание GitLab CE
Выполняю такую команду с IP моей виртуалки (поменял порты так как 80 у меня занят):
```bash
sudo docker run -d \
  --hostname 192.168.56.103 \
  -p 8888:80 \
  -p 5443:443 \
  -p 8022:22 \
  --name gitlab \
  -e GITLAB_OMNIBUS_CONFIG="external_url='http://192.168.56.103:8888'; gitlab_rails['gitlab_shell_ssh_port']=8022" \
  -v gitlab-data:/var/opt/gitlab \
  -v ~/gitlab-config:/etc/gitlab \
  gitlab/gitlab-ce:latest
```

После выполнения команды жду и проверяю http://192.168.56.103:8888, вижу рабочий сайт:

![alt text](image.png)

Вхожу под root:

![alt text](image-1.png)

## 2. Настройка Runner

Устанавливаю GitLab Runner:
  ```bash
  curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
  sudo apt-get install -y gitlab-runner
  ```

Регистрирую Runner:

![alt text](image-2.png)

Запускаю его:
```bash
gitlab-runner run
```

Все запускается успешно:
```bash
vboxuser@Ansible:~$ sudo gitlab-runner status
[sudo] password for vboxuser:
Runtime platform                                    arch=amd64 os=linux pid=16010 revision=dbac4904 version=18.6.3
gitlab-runner: Service is running
vboxuser@Ansible:~$
```

## 3. Создание проекта и репозитория в GitLab