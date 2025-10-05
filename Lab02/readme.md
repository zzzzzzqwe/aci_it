# Лабораторная работа 2. Основы скриптинга для автоматизации
# Студент: Gachayev Dmitrii, I2302
# Дата выполнения: 05.10.2025

---

# Задача 1: CLI‑ассистент: приветствие, валидация и мини‑отчёт о системе.

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

---

# Задача 2: Резервное копирование каталога с логированием и ротацией

### Цель

Отработать аргументы скрипта, работу с файлами/путями, условия, архивирование, коды возврата и логирование.

### Итоговый скрипт
```bash
#!/bin/bash


SRC_DIR="$1"
DST_DIR="${2:-$HOME/backups}"  # если второй аргумент не задан, используем ~/backups

if [[ -z "$SRC_DIR" ]]; then
    echo "Ошибка: не указан путь к каталогу-источнику."
    echo "Использование: $0 <source_dir> [backup_dir]"
    exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
    echo "Ошибка: источник '$SRC_DIR' не существует или не является каталогом."
    exit 2
fi


mkdir -p "$DST_DIR" || {
    echo "Ошибка: не удалось создать каталог для бэкапов '$DST_DIR'."
    exit 3
}


if [[ ! -w "$DST_DIR" ]]; then
    echo "Ошибка: каталог для бэкапов '$DST_DIR' недоступен для записи."
    exit 4
fi


BASENAME_SRC=$(basename "$SRC_DIR")
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
ARCHIVE_NAME="backup_${BASENAME_SRC}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$DST_DIR/$ARCHIVE_NAME"


tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SRC_DIR")" "$BASENAME_SRC"
STATUS=$?


if [[ $STATUS -eq 0 ]]; then
    SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
else
    SIZE=0
fi


LOG_FILE="$DST_DIR/backup.log"
echo "$(date -Iseconds) SRC=$SRC_DIR DST=$DST_DIR FILE=$ARCHIVE_NAME SIZE=$SIZE STATUS=$STATUS" >> "$LOG_FILE"


exit $STATUS
```

1. Аргументы и директории
```bash
SRC_DIR="$1"
DST_DIR="${2:-$HOME/backups}"
```

SRC_DIR — путь к каталогу, который нужно архивировать.

DST_DIR — путь к каталогу для хранения бэкапов; если не указан, по умолчанию используется ~/backups.

2. Проверка существования источника
```
if [[ -z "$SRC_DIR" ]]; then
    echo "Ошибка: не указан путь к каталогу-источнику."
    exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
    echo "Ошибка: источник '$SRC_DIR' не существует или не является каталогом."
    exit 2
fi
```

Проверяет, что путь передан и существует как каталог.

Если нет — скрипт завершается с кодом ошибки.

3. Создание каталога бэкапов
```
mkdir -p "$DST_DIR" || {
    echo "Ошибка: не удалось создать каталог для бэкапов '$DST_DIR'."
    exit 3
}

if [[ ! -w "$DST_DIR" ]]; then
    echo "Ошибка: каталог для бэкапов '$DST_DIR' недоступен для записи."
    exit 4
fi
```

Создаёт каталог для бэкапов при необходимости (mkdir -p).

Проверяет, что каталог доступен для записи.

4. Формирование имени архива
```
BASENAME_SRC=$(basename "$SRC_DIR")
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
ARCHIVE_NAME="backup_${BASENAME_SRC}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$DST_DIR/$ARCHIVE_NAME"
```

Берёт имя исходного каталога (basename).

Формирует метку времени в формате YYYYMMDD_HHMMSS.

Создаёт полное имя архива.

5. Создание архива
```
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SRC_DIR")" "$BASENAME_SRC"
STATUS=$?
```

Создаёт сжатый архив tar.gz.

-C "$(dirname "$SRC_DIR")" переключает директорию на родительскую, чтобы архив содержал только сам каталог без полного пути.


Сохраняет код возврата команды в STATUS.

6. Получение размера архива
```
if [[ $STATUS -eq 0 ]]; then
    SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
else
    SIZE=0
fi
```

Если архив создан успешно, вычисляет его размер с помощью du -h.

Если ошибка — размер приравнивается к 0.

7. Логирование
```
LOG_FILE="$DST_DIR/backup.log"
echo "$(date -Iseconds) SRC=$SRC_DIR DST=$DST_DIR FILE=$ARCHIVE_NAME SIZE=$SIZE STATUS=$STATUS" >> "$LOG_FILE"
```

Записывает лог в файл backup.log.

Формат записи:

```
2025-10-05T19:18:21 SRC=/path/to/source DST=/home/user/backups FILE=backup_source_20251005_191821.tar.gz SIZE=128M STATUS=0
```
8. Завершение скрипта
```
exit $STATUS
```

Возвращает код возврата:

0 — успешное создание архива,

!=0 — ошибка при архивировании или проверках.

---

# Задача 3: Мониторинг дискового пространства

### Цель

Закрепить циклы, условия, работу с системными командами (`df`, `awk`), аргументы и коды возврата.

### Итоговый скрипт
```
#!/bin/bash


FS_PATH="$1"
THRESHOLD="${2:-80}"


if [[ -z "$FS_PATH" ]]; then
    echo "Ошибка: не указан путь к файловой системе."
    echo "Использование: $0 <path> [threshold%]"
    exit 2
fi

if [[ ! -e "$FS_PATH" ]]; then
    echo "Ошибка: путь '$FS_PATH' не существует."
    exit 2
fi

USAGE=$(df -h "$FS_PATH" | awk 'NR==2 {print $5}' | tr -d '%')

if [[ -z "$USAGE" ]]; then
    echo "Ошибка: не удалось получить данные по диску."
    exit 2
fi

CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "$CURRENT_DATE"
echo "Путь: $FS_PATH"
echo "Использовано: ${USAGE}%"

if (( USAGE < THRESHOLD )); then
    echo "Статус: OK"
    exit 0
else
    echo "Статус: WARNING: диск почти заполнен!"
    exit 1
fi
```

1. Аргументы скрипта
```
FS_PATH="$1"
THRESHOLD="${2:-80}"
```

FS_PATH — путь к файловой системе или каталогу, который нужно проверить.

THRESHOLD — порог заполнения в процентах; по умолчанию 80%.

2. Проверка аргументов
```
if [[ -z "$FS_PATH" ]]; then
    echo "Ошибка: не указан путь к файловой системе."
    exit 2
fi

if [[ ! -e "$FS_PATH" ]]; then
    echo "Ошибка: путь '$FS_PATH' не существует."
    exit 2
fi
```

Проверяет, что путь передан и существует.

Если путь не указан или не существует, скрипт завершает работу с кодом 2.

3. Получение процента заполнения
```
USAGE=$(df -h "$FS_PATH" | awk 'NR==2 {print $5}' | tr -d '%')
```

Использует команду df -h для получения информации о файловой системе.

awk 'NR==2 {print $5}' выбирает процент использования из второй строки таблицы.

tr -d '%' удаляет знак процента для удобства сравнения чисел.

4. Проверка корректности данных
```
if [[ -z "$USAGE" ]]; then
    echo "Ошибка: не удалось получить данные по диску."
    exit 2
fi
```

Если не удалось получить данные о заполнении, скрипт завершает работу с кодом 2.

5. Вывод текущей информации
```
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "$CURRENT_DATE"
echo "Путь: $FS_PATH"
echo "Использовано: ${USAGE}%"
```

Показывает дату и время выполнения скрипта.

Выводит проверяемый путь и процент использования диска.

6. Проверка порога и статус
```
if (( USAGE < THRESHOLD )); then
    echo "Статус: OK"
    exit 0
else
    echo "Статус: WARNING: диск почти заполнен!"
    exit 1
fi
```

Сравнивает текущий процент заполнения с пороговым значением.

Если меньше порога — выводится "OK" и код возврата 0.

Если больше или равно порогу — предупреждение и код возврата 1.

## Вывод

В ходе работы над этими скриптами были изучены и закреплены ключевые навыки работы с Bash и стандартными утилитами Linux. Были освоены циклы и условные конструкции для проверки ввода и управления логикой скрипта, работа с аргументами командной строки и установление значений по умолчанию.
