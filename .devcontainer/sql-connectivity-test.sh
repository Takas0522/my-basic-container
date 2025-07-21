#!/bin/bash

SERVER="your_sql_server"
DATABASE="your_database"
USER="your_username"
PASSWORD="your_password"

if sqlcmd -S $SERVER -d $DATABASE -U $USER -P $PASSWORD -Q "SELECT 1" > /dev/null 2>&1; then
    echo "SQL Server への接続に成功しました。"
else
    echo "SQL Server への接続に失敗しました。"
    exit 1
fi