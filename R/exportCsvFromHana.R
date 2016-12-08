#!/usr/bin/Rscript
# Things you may need to change:
# - classPath (This needs to Point to the HANA JDBC Driver)
# - jdbcDriver (This slightly different depending which JDBC driver you have)
# - SAP HANA Host & port name after jdbc:sap://
# - username (HANA DB User)
# - password (HANA DB User Password)
# - dbGetQuery (Change the Select Query, here I selected a 10% Sample of the CENSUS table in my own schema)

if (!require("RJDBC")) {
  install.packages("RJDBC",repos="http://cran.rstudio.com/")
  library("RJDBC")
}
if (!require("ini")) {
  install.packages("ini",repos="http://cran.rstudio.com/")
  library("ini")
}

this_dir <- function(directory)
setwd( file.path(getwd(), directory) )


config = read.ini('config.ini')
server <- print(paste("jdbc:sap://", config$db$host, ":", config$db$port, "/?autocommit=false", sep = ""))
>>>>>>> 1774086... setwd and output to data folder:R/exportCsvFromHana.R

# classPath="/Users/i049374/Documents/HANA/Install/R/ngdbc.jar")
# classPath="/Applications/SAP Clients.app/Contents/Eclipse/plugins/com.sap.ndb.studio.jdbc_2.2.8.jar")
# For ngdbc.jar use        # jdbcDriver <- JDBC(driverClass="com.sap.db.jdbc.Driver",
# For HANA Studio jar use  # jdbcDriver <- JDBC(driverClass="com.sap.ndb.studio.jdbc.JDBCConnection",

jdbcDriver <- JDBC(driverClass="com.sap.db.jdbc.Driver",
                   classPath="C:\\Program Files\\sap\\hdbclient\\ngdbc.jar")
jdbcConnection <- dbConnect(jdbcDriver,
                            "jdbc:sap://192.168.30.150:31615/?autocommit=false"
                            ,"TUKGRP1"
                            ,"encUrt8e")
result <- dbGetQuery(jdbcConnection, "select * from TUKGRP1.TRAINING_FEATURES_UNCLASSIFIED LIMIT 100000")
write.csv(result, file = "../data/feature_view_unclassified.csv")
result <- dbGetQuery(jdbcConnection, "select * from TUKGRP1.TRAINING_FEATURES_CLASSIFIED")
write.csv(result, file = "../data/feature_view_classified.csv")
dbDisconnect(jdbcConnection)
