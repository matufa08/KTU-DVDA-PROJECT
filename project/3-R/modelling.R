library(h2o)
library(tidyverse)
h2o.init(max_mem_size = "6g")

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
  max_models = 30  # Maximum number of models to build
)



leaderboard <- autoML@leaderboard
print(leaderboard)
model <- h2o.loadModel("../4-model/best_gbm_model_v1")

h2o.performance(model, train = TRUE)
h2o.performance(model, valid = TRUE)
perf <- h2o.performance(model, newdata = test)

h2o.auc(perf)
plot(perf, type = "roc")

predictions <- h2o.predict(model, test_data)
predictions

predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("../5-predictions/predictions1.csv")

h2o.saveModel(model, "../4-model/", filename = "best_gbm_model_v1")


