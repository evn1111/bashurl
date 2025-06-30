#!/bin/bash

# Функция для проверки доступности URL
check_urls() {
    local url_file=${1:-urls.txt}  # По умолчанию используем urls.txt в текущей директории
    
    echo "Проверяем URL из файла: $url_file"
    echo "--------------------------------"
    
    # Читаем URL из файла построчно
    while IFS= read -r url || [ -n "$url" ]; do
        # Удаляем возможные пробелы и пустые строки
        url=$(echo "$url" | xargs)
        if [ -z "$url" ]; then
            continue
        fi
        
        # Добавляем http:// если URL не начинается с http:// или https://
        if [[ ! "$url" =~ ^https?:// ]]; then
            url="http://$url"
        fi
        
        echo -n "Проверяем $url ... "
        
        # Делаем запрос и получаем HTTP-код с таймаутом 10 секунд
        http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null)
        curl_exit=$?
        
        if [ $curl_exit -ne 0 ]; then
            echo "ОШИБКА: не удалось подключиться (код curl: $curl_exit)"
            return 1
        elif [[ "$http_code" =~ ^[45][0-9]{2}$ ]]; then
            echo "НЕДОСТУПЕН (код $http_code)"
            return 1
        else
            echo "ДОСТУПЕН (код $http_code)"
        fi
    done < "$url_file"
    
    echo "--------------------------------"
    echo "Все URL успешно проверены"
    return 0
}

# Вызываем функцию с первым параметром или по умолчанию
check_urls "$1"