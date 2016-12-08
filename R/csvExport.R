#!/usr/bin/Rscript

library("RJDBC")
library("ini")

config = read.ini('config.ini')
server <- print(paste("jdbc:sap://", config$db$host, ":", config$db$port, "/?autocommit=false", sep = ""))

jdbcDriver <- JDBC(driverClass="com.sap.db.jdbc.Driver", classPath="./ngdbc.jar")
jdbcConnection <- dbConnect(jdbcDriver, server, config$db$user, config$db$password)
result <- dbGetQuery(jdbcConnection, 'SELECT * FROM "TUKGRP1"."TRAINING_FEATURES" LIMIT 10')
write.csv(result, file = 'result.csv')
