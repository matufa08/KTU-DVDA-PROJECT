library(h2o)
library(tidyverse)
h2o.init(max_mem_size = "8g")

df <- h2o.importFile("../1-data/train_data.csv")
test_data <- h2o.importFile("../1-data/test_data.csv")
df
class(df)
summary(df)

y <- "y"
x <- setdiff(names(df), c(y, "id"))
df$y <- as.factor(df$y)
summary(df)

splits <- h2o.splitFrame(df, c(0.6,0.2), seed=123)
train  <- h2o.assign(splits[[1]], "train") # 60%
valid  <- h2o.assign(splits[[2]], "valid") # 20%
test   <- h2o.assign(splits[[3]], "test")  # 20%

autoML <- h2o.automl(
  x = x,
  y = y,
  training_frame = train,
  max_runtime_secs = 3600,  # Maximum time in seconds for AutoML
  nfolds = 5,  # Number of cross-validation folds
  max_models = 20  # Maximum number of models to build
)
leaderboard <- autoML@leaderboard
print(leaderboard)

best_model <- h2o.getModel(leaderboard@model_ids[[1]])

#Random Forest

rf_model <- h2o.randomForest(x,
                             y,
                             training_frame = train,
                             validation_frame = valid,
                             ntrees = 20,
                             max_depth = 10,
                             stopping_metric = "AUC",
                             seed = 1234)
rf_model
rf_auc = h2o.auc(rf_model)
h2o.auc(h2o.performance(rf_model, valid = TRUE))
rf_test_auc = h2o.auc(h2o.performance(rf_model, newdata = test))

#GBM
gbm_model <- h2o.gbm(x,
                     y,
                     training_frame = train,
                     validation_frame = valid,
                     ntrees = 20,
                     max_depth = 10,
                     stopping_metric = "AUC",
                     seed = 1234)
gbm_auc = h2o.auc(gbm_model)
h2o.auc(h2o.performance(gbm_model, valid = TRUE))
gbm_test_auc = h2o.auc(h2o.performance(gbm_model, newdata = test))

#Deep learning
dl_model <- h2o.deeplearning(
  model_id="dl_model",
  activation =  "Tanh",
  training_frame=train, 
  validation_frame=valid, 
  x=x, 
  y=y, 
  overwrite_with_best_model=F,    ## Return the final model after 10 epochs, even if not the best
  hidden=c(32,16,32),           ## more hidden layers -> more complex interactions
  epochs=5,                      ## to keep it short enough
  score_validation_samples=10000, ## down sample validation set for faster scoring
  score_duty_cycle=0.025,         ## don't score more than 2.5% of the wall time
  adaptive_rate=F,                ## manually tuned learning rate
  rate=0.01, 
  rate_annealing=2e-6,            
  momentum_start=0.2,             ## manually tuned momentum
  momentum_stable=0.4, 
  momentum_ramp=1e7, 
  l1=1e-5,                        ## add some L1/L2 regularization
  l2=1e-5,
  seed = 1234
) 

dl_model_auc = h2o.auc(dl_model)
h2o.auc(h2o.performance(dl_model, valid = TRUE))
dl_model_test_auc = h2o.auc(h2o.performance(dl_model, newdata = test))

#Naive Byes
nb_model <- h2o.naiveBayes(training_frame = train, x = x, y = y)
nb_model_auc = h2o.auc(nb_model)
h2o.auc(h2o.performance(nb_model, valid = TRUE))
nb_model_test_auc = h2o.auc(h2o.performance(nb_model, newdata = test))

#GLM
glm_model <- h2o.glm(
  x = x,
  y = y,
  training_frame = train,
  family = "binomial"
)
glm_model_auc = h2o.auc(glm_model)
h2o.auc(h2o.performance(glm_model, valid = TRUE))
glm_model_test_auc = h2o.auc(h2o.performance(glm_model, newdata = test))


rf_auc
rf_test_auc
gbm_auc
gbm_test_auc
dl_model_auc
dl_model_test_auc
nb_model_auc
nb_model_test_auc
glm_model_auc
glm_model_test_auc

predictions <- h2o.predict(gbm_model, test_data)

predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("../5-predictions/predictions1.csv")

h2o.saveModel(gbm_model, "../4-model/", filename = "my_best_model_gbm")

