# =====================================================================
# FASE 4: REGRESIÓN PENALIZADA (RIDGE, LASSO Y ELASTIC NET)
# =====================================================================

estimacion_fase4 <- function(fase2_obj, nombre_bd = "Base de Datos") {
  cat("\n=====================================================================\n")
  cat(" FASE 4: REGRESIÓN PENALIZADA Y PREDICCIÓN -", toupper(nombre_bd), "\n")
  cat("=====================================================================\n")
  
  y <- fase2_obj$y
  X <- fase2_obj$X_scaled
  X_raw <- fase2_obj$X_raw
  keep_vif <- fase2_obj$keep_vif
  n <- nrow(X)
  
  # 1. Ajuste con Validación Cruzada 10-Fold para optimizar Lambda
  foldid <- sample(rep(1:10, length.out = n))
  lam_grid <- exp(seq(log(1e4), log(1e-4), length.out = 100))
  
  cv_ridge <- cv.glmnet(X, y, alpha = 0, standardize = FALSE, foldid = foldid, lambda = lam_grid)
  cv_lasso <- cv.glmnet(X, y, alpha = 1, standardize = FALSE, foldid = foldid)
  cv_enet  <- cv.glmnet(X, y, alpha = 0.5, standardize = FALSE, foldid = foldid)
  
  cat("1. PARÁMETROS DE PENALIZACIÓN OPTIMIZADOS (Lambda):\n")
  cat(sprintf("   - Ridge       : Lambda.min = %.4f | Lambda.1se = %.4f\n", cv_ridge$lambda.min, cv_ridge$lambda.1se))
  cat(sprintf("   - Lasso       : Lambda.min = %.4f | Lambda.1se = %.4f\n", cv_lasso$lambda.min, cv_lasso$lambda.1se))
  cat(sprintf("   - Elastic Net : Lambda.min = %.4f | Lambda.1se = %.4f\n", cv_enet$lambda.min, cv_enet$lambda.1se))
  
  # 2. Comparación de Coeficientes Estimados (lambda.1se para parsimonia)
  get_coef <- function(cv_mod) as.numeric(coef(cv_mod, s = "lambda.1se"))
  
  tabla_coef <- cbind(
    MCO_Completo = coef(fase2_obj$mod_ols),
    Ridge_1se    = get_coef(cv_ridge),
    Lasso_1se    = get_coef(cv_lasso),
    ENet_1se     = get_coef(cv_enet)
  )
  rownames(tabla_coef) <- c("(Intercept)", colnames(X))
  
  cat("\n2. COMPARACIÓN DE COEFICIENTES ESTIMADOS (lambda.1se):\n")
  print(round(tabla_coef, 4))
  
  cat("\n3. SELECCIÓN DE VARIABLES (Predictores no nulos):\n")
  print(colSums(tabla_coef[-1, , drop = FALSE] != 0))
  
  # 3. Evaluación de Capacidad Predictiva Out-of-Sample (100 Réplicas 80/20)
  cat("\n4. EVALUACIÓN PREDICTIVA (Validación Cruzada Repetida 100 réplicas - 80/20):\n")
  
  B <- 100
  rmse <- function(y_real, y_pred) sqrt(mean((y_real - y_pred)^2))
  res_rmse <- matrix(NA, B, 5, dimnames = list(NULL, c("MCO_Completo", "MCO_VIF_Drop", "Ridge", "Lasso", "ElasticNet")))
  
  for (b in 1:B) {
    tr <- sample(n, round(0.8 * n))
    
    # Estandarización correcta dentro de cada pliegue para evitar fuga de información
    mu_tr <- colMeans(X_raw[tr, , drop = FALSE])
    sd_tr <- apply(X_raw[tr, , drop = FALSE], 2, sd)
    
    X_tr <- scale(X_raw[tr, , drop = FALSE], mu_tr, sd_tr)
    X_te <- scale(X_raw[-tr, , drop = FALSE], mu_tr, sd_tr)
    y_tr <- y[tr]
    y_te <- y[-tr]
    
    dtr <- data.frame(y = y_tr, X_tr)
    dte <- data.frame(X_te)
    
    # Evaluar modelos
    res_rmse[b, "MCO_Completo"] <- rmse(y_te, predict(lm(y ~ ., dtr), dte))
    res_rmse[b, "MCO_VIF_Drop"] <- rmse(y_te, predict(lm(y ~ ., dtr[, c("y", keep_vif)]), dte))
    
    res_rmse[b, "Ridge"]      <- rmse(y_te, predict(cv.glmnet(X_tr, y_tr, alpha = 0, standardize = FALSE, lambda = lam_grid), X_te, s = "lambda.min"))
    res_rmse[b, "Lasso"]      <- rmse(y_te, predict(cv.glmnet(X_tr, y_tr, alpha = 1, standardize = FALSE), X_te, s = "lambda.min"))
    res_rmse[b, "ElasticNet"] <- rmse(y_te, predict(cv.glmnet(X_tr, y_tr, alpha = 0.5, standardize = FALSE), X_te, s = "lambda.min"))
  }
  
  tabla_eval <- rbind(
    "RMSE Promedio"  = colMeans(res_rmse),
    "Desv. Estándar" = apply(res_rmse, 2, sd)
  )
  print(round(tabla_eval, 4))
  
  return(invisible(list(coeficientes = tabla_coef, rmse_matriz = res_rmse)))
}


# =====================================================================
# EJECUCIÓN PASO A PASO POR FASES
# =====================================================================

# ---------------------------------------------------------------------
# BASE 1: Cars93
# ---------------------------------------------------------------------
vars_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")

# Ejecución Fase 2 (Cars93)
fase2_cars <- diagnostico_fase2(Cars93[, vars_cars], MPG.city ~ ., nombre_bd = "Cars93")

# Ejecución Fase 4 (Cars93)
fase4_cars <- estimacion_fase4(fase2_cars, nombre_bd = "Cars93")


# ---------------------------------------------------------------------
# BASE 2: Hald Cement Data
# ---------------------------------------------------------------------
Hald <- data.frame(
  X1 = c(7, 1, 11, 11, 7, 11, 3, 1, 2, 21, 1, 11, 10),
  X2 = c(26, 29, 56, 31, 52, 55, 71, 31, 54, 47, 40, 66, 68),
  X3 = c(6, 15, 8, 8, 6, 9, 17, 22, 18, 4, 23, 9, 2),
  X4 = c(60, 52, 20, 47, 33, 22, 6, 44, 22, 26, 34, 12, 12),
  Y  = c(78.5, 74.3, 104.3, 87.6, 95.9, 109.2, 102.7, 72.5, 93.1, 115.9, 83.8, 113.3, 109.4)
)

# Ejecución Fase 2 (Hald)
fase2_hald <- diagnostico_fase2(Hald, Y ~ ., nombre_bd = "Hald Cement Data")

# Ejecución Fase 4 (Hald)
fase4_hald <- estimacion_fase4(fase2_hald, nombre_bd = "Hald Cement Data")