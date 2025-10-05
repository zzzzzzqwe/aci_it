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
