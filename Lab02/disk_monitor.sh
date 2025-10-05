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
