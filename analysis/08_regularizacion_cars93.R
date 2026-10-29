#@ 08_regularizacion_cars93
source("R/utils.R")
library(glmnet)
library(MASS)

cat("=== EXTENSIÓN F4: VALIDACIÓN PREDICTIVA FUERA DE MUESTRA EN CARS93 ===\n\n")

data(Cars93)
cols_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")
cars93_comp <- Cars93[complete.cases(Cars93[, cols_cars]), cols_cars]
n <- nrow(cars93_comp)

# Configuración del experimento Monte Carlo
set.seed(123)
N_REPS <- 100
n_train <- round(0.80 * n) # 66 train, 16 test

rmse_mco   <- numeric(N_REPS)
rmse_bic   <- numeric(N_REPS)
rmse_ridge <- numeric(N_REPS)
rmse_lasso <- numeric(N_REPS)
rmse_enet  <- numeric(N_REPS)

cat(sprintf("Ejecutando %d particiones 80/20 independientes (n_train = %d, n_test = %d)...\n", 
            N_REPS, n_train, n - n_train))

for(i in 1:N_REPS) {
  idx_train <- sample(1:n, size = n_train, replace = FALSE)
  train_df <- cars93_comp[idx_train, ]
  test_df  <- cars93_comp[-idx_train, ]
  
  y_train <- train_df$MPG.city
  y_test  <- test_df$MPG.city
  
  # Predictores crudos
  X_tr_raw <- as.matrix(train_df[, -1])
  X_te_raw <- as.matrix(test_df[, -1])
  
  # Estandarización con parámetros de entrenamiento (evitar fuga de información)
  mean_tr <- colMeans(X_tr_raw)
  sd_tr   <- apply(X_tr_raw, 2, sd)
  
  X_tr_std <- scale(X_tr_raw, center = mean_tr, scale = sd_tr)
  X_te_std <- scale(X_te_raw, center = mean_tr, scale = sd_tr)
  
  # 1. MCO Completo
  mod_mco <- lm(MPG.city ~ ., data = train_df)
  pred_mco <- predict(mod_mco, newdata = test_df)
  rmse_mco[i] <- sqrt(mean((y_test - pred_mco)^2))
  
  # 2. Selección por BIC repetida dentro de la partición (evitar fuga)
  mod_bic <- stepAIC(mod_mco, direction = "both", k = log(nrow(train_df)), trace = 0)
  pred_bic <- predict(mod_bic, newdata = test_df)
  rmse_bic[i] <- sqrt(mean((y_test - pred_bic)^2))
  
  # 3. Ridge (alpha = 0)
  cv_r <- cv.glmnet(X_tr_std, y_train, alpha = 0, standardize = FALSE)
  pred_r <- as.vector(predict(cv_r, newx = X_te_std, s = "lambda.min"))
  rmse_ridge[i] <- sqrt(mean((y_test - pred_r)^2))
  
  # 4. Lasso (alpha = 1)
  cv_l <- cv.glmnet(X_tr_std, y_train, alpha = 1, standardize = FALSE)
  pred_l <- as.vector(predict(cv_l, newx = X_te_std, s = "lambda.min"))
  rmse_lasso[i] <- sqrt(mean((y_test - pred_l)^2))
  
  # 5. Elastic Net (alpha = 0.5)
  cv_e <- cv.glmnet(X_tr_std, y_train, alpha = 0.5, standardize = FALSE)
  pred_e <- as.vector(predict(cv_e, newx = X_te_std, s = "lambda.min"))
  rmse_enet[i] <- sqrt(mean((y_test - pred_e)^2))
}

# Tabla resumen de desempeño predictivo fuera de muestra
tabla_rmse <- data.frame(
  Metodo = c("MCO Completo", "Selección BIC (interna)", "Ridge (alpha = 0)", "Lasso (alpha = 1)", "Elastic Net (alpha = 0.5)"),
  RMSE_Medio = round(c(mean(rmse_mco), mean(rmse_bic), mean(rmse_ridge), mean(rmse_lasso), mean(rmse_enet)), 3),
  RMSE_SD    = round(c(sd(rmse_mco), sd(rmse_bic), sd(rmse_ridge), sd(rmse_lasso), sd(rmse_enet)), 3),
  RMSE_Mediana = round(c(median(rmse_mco), median(rmse_bic), median(rmse_ridge), median(rmse_lasso), median(rmse_enet)), 3),
  Pct_Mejora_sobre_MCO = c(
    0.0,
    round(100 * mean(rmse_bic < rmse_mco), 1),
    round(100 * mean(rmse_ridge < rmse_mco), 1),
    round(100 * mean(rmse_lasso < rmse_mco), 1),
    round(100 * mean(rmse_enet < rmse_mco), 1)
  )
)
cat("\n--- Resumen de Validación Fuera de Muestra (100 Particiones 80/20) ---\n")
print(tabla_rmse)
guardar_tabla(tabla_rmse, "cars93_comparativa_cv_fuera_muestra")

# Gráfico de Boxplots de RMSE
png("fig/cars93_boxplots_rmse_cv.png", width = 900, height = 600, res = 120)
boxplot(list("MCO" = rmse_mco, "BIC" = rmse_bic, "Ridge" = rmse_ridge, "Lasso" = rmse_lasso, "Elastic Net" = rmse_enet),
        col = c("gray90", "lightcyan", "lightblue", "lavender", "mistyrose"),
        ylab = "RMSE Fuera de Muestra (MPG.city)",
        main = "Desempeño Predictivo Fuera de Muestra (100 Particiones 80/20)",
        las = 1)
abline(h = median(rmse_mco), col = "red", lty = 2)
dev.off()

