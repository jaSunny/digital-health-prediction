#!/usr/bin/Rscript

# install dependencies
if (!require("caret")) {
  install.packages('caret', dependencies=TRUE, repos="http://cran.rstudio.com/")
  library("caret")
}
if (!require("plotly")) {
  install.packages('plotly', dependencies=TRUE, repos="http://cran.rstudio.com/")
  library('plotly')
}

this_dir <- function(directory)
setwd( file.path(getwd(), directory) )

# Load Data
dat <- read.csv("../data/feature_view_classified.csv",  sep = ",", header=TRUE, na.strings=c(""))

training <- dat[, !names(dat) %in% c("X", "ID")]  # 'X' seems to be the generated column name for the view id

full_training_set <- training
feature_set <- names(full_training_set)
feature_set <- feature_set[!feature_set %in% c('SICK')] # remove target value

all_combinations <- combn(feature_set, length(feature_set) -1 )
for (i in 1:ncol(all_combinations)) {
  subset <- all_combinations[,i] 
  training <- full_training_set[c(subset, "SICK")]

  # Using caret
  training_sample_ids <- createDataPartition(training$SICK, p=0.5, list=FALSE)
  training_sample <- training[training_sample_ids, ]
  training_sample$SICK <- factor(training_sample$SICK)

  validation_sample <- training[-training_sample_ids, ]
  validation_sample$SICK <- factor(validation_sample$SICK)

  glm_ctrl <- trainControl(method = "cv", number = 10)

  # Finds best logistic fit
  glm_fit <- train(SICK ~ ., data = training_sample,
                   method = "glm",
                   preProcess = c("center", "scale"),
                   trControl = glm_ctrl,
                   family="binomial")


  pred <- predict(glm_fit, newdata=validation_sample)
  importance <- varImp(glm_fit, scale=FALSE)


  ##############
  # LOG OUTPUT #
  ##############

  print(summary(glm_fit))
  print(importance)
  print(confusionMatrix(data=pred, reference=validation_sample$SICK))

  #######################################
  # PRINT PERFORMANCE FOR IMPROVEMENTS  #
  #######################################

  csv_row <- data.frame(
                        precision(data=pred, reference=validation_sample$SICK),
                        recall(data=pred, reference=validation_sample$SICK),
                        F_meas(data=pred, reference=validation_sample$SICK),
                        posPredValue(data=pred, reference=validation_sample$SICK),
                        negPredValue(data=pred, reference=validation_sample$SICK)
                        )
  csv_row[feature_set]  <- feature_set %in% subset
  names(csv_row) <- c('precision','recall','F_meas','posPredValue', 'negPredValue', feature_set)
  write.table(csv_row, file = "../data/performance.csv", col.names=!file.exists("../data/performance.csv"), row.names=FALSE, append=TRUE, sep=",")  # write.csv ignores append=TRUE
}


training <- full_training_set
training_sample_ids <- createDataPartition(training$SICK, p=0.5, list=FALSE)
training_sample <- training[training_sample_ids, ]
training_sample$SICK <- factor(training_sample$SICK)

validation_sample <- training[-training_sample_ids, ]
validation_sample$SICK <- factor(validation_sample$SICK)

glm_ctrl <- trainControl(method = "cv", number = 10)

# Finds best logistic fit
glm_fit <- train(SICK ~ ., data = training_sample,
                 method = "glm",
                 preProcess = c("center", "scale"),
                 trControl = glm_ctrl,
                 family="binomial")


pred <- predict(glm_fit, newdata=validation_sample)
importance <- varImp(glm_fit, scale=FALSE)


################################
# VISUALIZE IMPORTANCE FACTORS #
################################

# estimate variable importance
# summarize importance

plot_data <- data.frame(rownames(importance$importance), importance$importance$Overall, stringsAsFactors = FALSE)
names(plot_data) <- c('feature', 'importance')

plot_data <- plot_data[order(plot_data$importance),]
plot_data$feature <-factor(plot_data$feature, levels=plot_data[order(plot_data$importance), "feature"])

p <- plot_ly(plot_data,
             x = ~importance,
             y = ~feature,
             name = "importance",
             type = "bar"
             #)
             ) %>% layout(margin = list(l = 280))

html_path <- paste(paste(getwd(), '../data/html', sep='/'), '/importance_', paste(as.integer(csv_row[feature_set]), collapse=''), '.html', sep="")

htmlwidgets::saveWidget(p, file = html_path)
