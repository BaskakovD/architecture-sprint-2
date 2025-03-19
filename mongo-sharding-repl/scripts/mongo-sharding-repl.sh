#!/bin/bash

###
# Инициализируем сервер конфигураций
###

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF


###
# Инициализируем shard11
###

docker compose exec -T shard11 mongosh --port 27018 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard11:27018" },
        { _id : 1, host : "shard12:27021" },
        { _id : 2, host : "shard13:27022" }
      ]
    }
);
EOF

###
# Инициализируем shard21
###

docker compose exec -T shard21 mongosh --port 27019 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard21:27019" },
        { _id : 1, host : "shard22:27023" },
        { _id : 2, host : "shard23:27024" }
      ]
    }
);
EOF


###
# Инициализируем роутер
###

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard( "shard1/shard11:27018,shard12:27021,shard13:27022");
sh.addShard( "shard2/shard21:27019,shard22:27023,shard23:27024");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i});

db.helloDoc.countDocuments();
EOF