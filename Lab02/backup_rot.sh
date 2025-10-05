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
