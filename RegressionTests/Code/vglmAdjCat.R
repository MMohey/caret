timestamp <- Sys.time()
library(caret)

model <- "vglmAdjCat"

#########################################################################

set.seed(2)
training <- twoClassSim(100, ordinal = TRUE)
testing <- twoClassSim(500, ordinal = TRUE)
trainX <- training[, -ncol(training)]
trainY <- training$Class

weight_test <- function (data, lev = NULL, model = NULL)  {
  mean(data$weights)
  postResample(data[, "pred"], data[, "obs"])
}

grid <- expand.grid(parallel = TRUE, link = "loge")

cctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all",
                       classProbs = TRUE)
cctrl2 <- trainControl(method = "LOOCV",
                       classProbs = TRUE)
cctrl3 <- trainControl(method = "none",
                       classProbs = TRUE)

cctrl4 <- trainControl(method = "cv", number = 3, 
                       summaryFunction = weight_test)
cctrl5 <- trainControl(method = "LOOCV", summaryFunction = weight_test)

set.seed(849)
test_class_cv_model <- train(trainX, trainY, 
                             method = "vglmAdjCat",
                             tuneGrid = grid, 
                             trControl = cctrl1,
                             metric = "Kappa", 
                             preProc = c("center", "scale"))

set.seed(849)
test_class_cv_form <- train(Class ~ ., data = training, 
                            method = "vglmAdjCat",
                            tuneGrid = grid, 
                            trControl = cctrl1,
                            metric = "Kappa", 
                            preProc = c("center", "scale"))

test_class_pred <- predict(test_class_cv_model, testing[, -ncol(testing)])
test_class_prob <- predict(test_class_cv_model, testing[, -ncol(testing)], type = "prob")
test_class_pred_form <- predict(test_class_cv_form, testing[, -ncol(testing)])
test_class_prob_form <- predict(test_class_cv_form, testing[, -ncol(testing)], type = "prob")

set.seed(849)
test_class_loo_model <- train(trainX, trainY, 
                              method = "vglmAdjCat",
                              tuneGrid = grid, 
                              trControl = cctrl2,
                              metric = "Kappa", 
                              preProc = c("center", "scale"))

set.seed(849)

test_class_none_model <- train(trainX, trainY, 
                               method = "vglmAdjCat", 
                               trControl = cctrl3,
                               tuneGrid = grid[1,],
                               metric = "Kappa", 
                               preProc = c("center", "scale"))

test_class_none_pred <- predict(test_class_none_model, testing[, -ncol(testing)])
test_class_none_prob <- predict(test_class_none_model, testing[, -ncol(testing)], type = "prob")

set.seed(849)
test_class_cv_weight <- train(trainX, trainY, 
                              weights = runif(nrow(trainX)),
                              method = "vglmAdjCat", 
                              trControl = cctrl4,
                              tuneGrid = grid,
                              metric = "Accuracy", 
                              preProc = c("center", "scale"))

set.seed(849)
test_class_loo_weight <- train(trainX, trainY, 
                               weights = runif(nrow(trainX)),
                               method = "vglmAdjCat", 
                               trControl = cctrl5,
                               tuneGrid = grid,
                               metric = "Accuracy", 
                               preProc = c("center", "scale"))

test_levels <- levels(test_class_cv_model)
if(!all(levels(trainY) %in% test_levels))
  cat("wrong levels")

#########################################################################

test_class_predictors1 <- caret:::predictors.train(test_class_cv_model)

#########################################################################

test_class_imp <- varImp(test_class_cv_model)

#########################################################################

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

sInfo <- sessionInfo()
timestamp_end <- Sys.time()

save(list = c(tests, "sInfo", "timestamp", "timestamp_end"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")


