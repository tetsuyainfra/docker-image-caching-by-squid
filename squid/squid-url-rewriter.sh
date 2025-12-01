#!/bin/bash

while read line; do
    # Squidからの入力は「URL その他のメタデータ」
    url=$(echo "$line" | awk -F' ' '{print $1}')
    echo "INPUT $line" >> /tmp/tmp.log
    echo "PARSE $url" >> /tmp/tmp.log

    # "http://HTTPS/..." を "https://..." に変換
    if [[ "$url" =~ ^http://https/ ]]; then
        newurl=$(echo "$url" | sed -E 's|^http://https/|https://|')
        echo "OK status=302 url=\"$newurl\"" >> /tmp/tmp.log
        echo "OK status=302 url=\"$newurl\""
    else
        # 変更しないURLはそのまま返す
        echo "OK" >> /tmp/tmp.log
        echo "OK"
    fi
done
