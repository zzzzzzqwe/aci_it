# Лабораторная работа 2. Основы скриптинга для автоматизации
# Студент: Gachayev Dmitrii, I2302
# Дата выполнения: 05.10.2025

---

# Задача 1: 

CLI‑ассистент: приветствие, валидация и мини‑отчёт о системе.

### Цель

Освоить ввод/вывод, переменные, условия, простые циклы, подстановку команд.

### Итоговый скрипт
```bash
#!/bin/bash

MAX_ATTEMPTS=3

ask_input() {
    local prompt="$1"
    local attempts=0
    local value=""

    while [[ $attempts -lt $MAX_ATTEMPTS ]]; do
        read -rp "$prompt: " value
        if [[ -n "$value" ]]; then
            ASKED_VALUE="$value"
            return 0
        fi
        ((attempts++))
        echo "Поле не может быть пустым. Попробуйте снова. ($attempts/$MAX_ATTEMPTS)"
    done

    echo "Слишком много пустых попыток. Завершение работы."
    exit 1
}


ask_input "Введите ваше имя"
USER_NAME="$ASKED_VALUE"


read -rp "Введите ваш отдел/группу (можно оставить пустым): " USER_DEPT
if [[ -z "$USER_DEPT" ]]; then
    USER_DEPT="не указан"
fi


CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")
HOST_NAME=$(hostname 2>/dev/null || echo "hostname недоступен")
UPTIME_INFO=$(uptime -p 2>/dev/null || echo "uptime недоступен")
FREE_SPACE=$(df -h / 2>/dev/null | awk 'NR==2 {print $4}' || echo "df недоступен")
USER_COUNT=$(who 2>/dev/null | wc -l || echo "who недоступен")


echo "=============================="
echo "      Отчет о системе         "
echo "=============================="
echo "Дата:          $CURRENT_DATE"
echo "Имя хоста:     $HOST_NAME"
echo "Аптайм:        $UPTIME_INFO"
echo "Свободно на /: $FREE_SPACE"
echo "Пользователей: $USER_COUNT"
echo "=============================="

echo "Здравствуйте, $USER_NAME ($USER_DEPT)!"
```

### Описание работы

1. Настройка и константы
```bash
MAX_ATTEMPTS=3
```

Задаёт максимальное количество попыток ввода имени пользователя, чтобы избежать бесконечного цикла.

2. Функция ask_input
```bash
ask_input() {
    local prompt="$1"
    local attempts=0
    local value=""


    while [[ $attempts -lt $MAX_ATTEMPTS ]]; do
        read -rp "$prompt: " value
        if [[ -n "$value" ]]; then
            ASKED_VALUE="$value"
            return 0
        fi
        ((attempts++))
        echo "Поле не может быть пустым. Попробуйте снова. ($attempts/$MAX_ATTEMPTS)"
    done


    echo "Слишком много пустых попыток. Завершение работы."
    exit 1
}
```

Принимает строку-приглашение (prompt) для ввода.

Цикл while до MAX_ATTEMPTS:

- Запрашивает ввод через read -rp "$prompt: " value.
- Если значение непустое, сохраняет его в глобальную переменную ASKED_VALUE и выходит из функции (return 0).
- Если пустое, выводит предупреждение "Поле не может быть пустым...".

После превышения числа попыток завершает скрипт с exit 1.

3. Ввод имени и отдела

```bash
ask_input "Введите ваше имя"
USER_NAME="$ASKED_VALUE"
read -rp "Введите ваш отдел/группу (можно оставить пустым): " USER_DEPT
if [[ -z "$USER_DEPT" ]]; then
    USER_DEPT="не указан"
fi
```

Имя вводится через функцию ask_input.

Отдел/группа вводятся напрямую через read.

Если отдел не указан, присваивается значение "не указан".

4. Сбор системной информации
```bash
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")
HOST_NAME=$(hostname 2>/dev/null || echo "hostname недоступен")
UPTIME_INFO=$(uptime -p 2>/dev/null || echo "uptime недоступен")
FREE_SPACE=$(df -h / 2>/dev/null | awk 'NR==2 {print $4}' || echo "df недоступен")
USER_COUNT=$(who 2>/dev/null | wc -l || echo "who недоступен")
```

date — текущие дата и время.

hostname — имя компьютера; при ошибке выводится "hostname недоступен".

uptime -p — время работы системы в человекочитаемом виде.

df -h / | awk 'NR==2 {print $4}' — свободное место на корневом разделе /.

who | wc -l — количество вошедших пользователей.

5. Вывод отчёта

``` bash
echo "=============================="
echo "      Отчет о системе         "
echo "=============================="
echo "Дата:          $CURRENT_DATE"
echo "Имя хоста:     $HOST_NAME"
echo "Аптайм:        $UPTIME_INFO"
echo "Свободно на /: $FREE_SPACE"
echo "Пользователей: $USER_COUNT"
echo "=============================="
```

Форматирует и выводит мини-отчёт о системе с текущей информацией.

6. Итоговое приветствие
```bash
echo "Здравствуйте, $USER_NAME ($USER_DEPT)!"
```

Выводит персонализированное приветствие, используя введённое имя и отдел/группу.
