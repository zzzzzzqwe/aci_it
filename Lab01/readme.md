# Лабораторная работа 1. Установка виртуальной машины и Ubuntu на Windows
# Студент: Gachayev Dmitrii, I2302
# Дата выполнения: 20.09.2025

---

# Установка VirtualBox

Загружаю установщик VirtualBox с официального сайта, принимаю соглашение, завершаю установку.

![image](screenshots/Screenshot_1.png)

![image](screenshots/Screenshot_2.png)

![image](screenshots/Screenshot_3.png)

# Загрузка ISO-образа Ubuntu

Загружаю Ubuntu Desktop с официиального сайта.

![image](screenshots/Screenshot_4.png)

# Создание виртуальной машины

Создаю виртуальную машину, выбираю тип и версию, выделяю оперативную память и память для жесткого диска

![image](screenshots/Screenshot_5.png)

![image](screenshots/Screenshot_6.png)

# Настройка виртуальной машины

Выделяю 4 ядра, увеличиваю видеопамять до 128MB, в разделе носители выбираю скачанный заранее ISO-файл

![image](screenshots/Screenshot_7.png)

![image](screenshots/Screenshot_8.png)

![image](screenshots/Screenshot_9.png)

# Установка Ubuntu

Запускаю виртуальную машину, прохожу все этапы установки Ubuntu, создаю пользователя, задаю пароль, завершаю установку

![image](screenshots/Screenshot_10.png)

![image](screenshots/Screenshot_11.png)

![image](screenshots/Screenshot_12.png)

![image](screenshots/Screenshot_13.png)


# Установка Guest Additions

Устанавливаю Guest Additions, в консоли вышедшей папки прописываю:

    ```bash
    sudo apt update 
    sudo apt install -y build-essential dkms linux-headers-$(uname -r) 
    cd /media/$USER/VBox_GAs_* 
    sudo ./VBoxLinuxAdditions.run 
    sudo reboot
    ```

![image](screenshots/Screenshot_14.png)
