#!/bin/bash

###
# Проверка числ документов в базе MongoDB
###

###
# Проверка числ документов в базе chard1
###
printf "Проверяем число документов в shard1"
printf "\n"
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF

###
# Проверка числ документов в базе chard2
###

printf "\n"
printf "Проверяем число документов в shard2"
printf "\n"
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF
