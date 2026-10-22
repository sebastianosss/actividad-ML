# =====================================================================
# INGENIERÍA EN ESTADÍSTICA - UCM
# FASE 4: REGRESIÓN PENALIZADA (RIDGE, LASSO Y ELASTIC NET)
# =====================================================================

suppressPackageStartupMessages({
  library(MASS)     # Para base Cars93
  library(car)      # Para VIF
  library(glmnet)   # Para Ridge, Lasso y Elastic Net
  library(mctest)   # Para Hald
})

options(width = 80, digits = 4)
set.seed(2026)

# Función auxiliar para localizar rutas relativas
buscar_ruta <- function(ruta_rel) {
  if (file.exists(ruta_rel)) return(ruta_rel)
  ruta_padre <- file.path("..", ruta_rel)
  if (file.exists(ruta_padre)) return(ruta_padre)
  stop(sprintf("No se encontró el archivo en las rutas: '%s' ni '%s'", ruta_rel, ruta_padre))
}

# =====================================================================
# FASE 2 AUXILIAR (Para generar los objetos requeridos por Fase 4)
# =====================================================================

diagnostico_fase2 <- function(data, formula_obj, nombre_bd = "Base de Datos", ejecutar_vif_drop = TRUE) {
  d <- na.omit(data)
  mf <- model.frame(formula_obj, data = d)
  y <- model.response(mf)
  X_raw <- model.matrix(formula_obj, data = d)[, -1, drop = FALSE]
  
  sds <- apply(X_raw, 2, sd)
  if (any(sds == 0)) X_raw <- X_raw[, sds > 0, drop = FALSE]
  X <- scale(X_raw)
  dat <- data.frame(y = y, X)
  
  mod_ols <- if (ncol(X) < nrow(X)) lm(y ~ ., data = dat) else NULL
  
  keep_vif <- colnames(X)
  if (ejecutar_vif_drop && ncol(X) <= 50 && !is.null(mod_ols)) {
    repeat {
      v <- tryCatch(car::vif(lm(y ~ ., data = dat[, c("y", keep_vif)])), error = function(e) NULL)
      if (is.null(v) || max(v) < 10 || length(keep_vif) <= 1) break
      keep_vif <- setdiff(keep_vif, names(which.max(v)))
    }
  }
  
  return(list(data_clean = d, y = y, X_raw = X_raw, X_scaled = X, keep_vif = keep_vif, mod_ols = mod_ols))
}

# =====================================================================
# FASE 4: REGRESIÓN PENALIZADA Y COMPARACIÓN PREDICTIVA
# =====================================================================

estimacion_fase4 <- function(fase2_obj, nombre_bd = "Base de Datos", B = 100, ejecutar_cv_rep = TRUE) {
  cat("\n=====================================================================\n")
  cat(" FASE 4: REGRESIÓN PENALIZADA Y PREDICCIÓN -", toupper(nombre_bd), "\n")
  cat("=====================================================================\n")
  
  y <- fase2_obj$y
  X <- fase2_obj$X_scaled
  X_raw <- fase2_obj$X_raw
  keep_vif <- fase2_obj$keep_vif
  n <- nrow(X)
  p <- ncol(X)
  
  # 1. Ajuste con Validación Cruzada para optimizar Lambda
  # En Hald (n = 13), usar LOOCV (nfolds = 13)
  nfolds_val <- if (n <= 15) n else 10
  foldid <- sample(rep(1:nfolds_val, length.out = n))
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
  
  coef_mco <- if (!is.null(fase2_obj$mod_ols)) coef(fase2_obj$mod_ols) else rep(NA, p + 1)
  
  tabla_coef <- cbind(
    MCO_Completo = coef_mco,
    Ridge_1se    = get_coef(cv_ridge),
    Lasso_1se    = get_coef(cv_lasso),
    ENet_1se     = get_coef(cv_enet)
  )
  rownames(tabla_coef) <- c("(Intercept)", colnames(X))
  
  cat("\n2. COMPARACIÓN DE COEFICIENTES ESTIMADOS (lambda.1se):\n")
  print(round(tabla_coef, 4))
  
  cat("\n3. SELECCIÓN DE VARIABLES (Predictores no nulos con lambda.1se):\n")
  print(colSums(tabla_coef[-1, , drop = FALSE] != 0, na.rm = TRUE))
  
  # 3. Evaluación de Capacidad Predictiva Out-of-Sample (100 réplicas 80/20)
  if (ejecutar_cv_rep && n >= 20) {
    cat(sprintf("\n4. EVALUACIÓN PREDICTIVA (Validación Cruzada Repetida %d réplicas - 80/20):\n", B))
    
    rmse <- function(y_real, y_pred) sqrt(mean((y_real - y_pred)^2))
    modelos_eval <- c("MCO_Completo", "MCO_VIF_Drop", "Ridge", "Lasso", "ElasticNet")
    res_rmse <- matrix(NA, B, length(modelos_eval), dimnames = list(NULL, modelos_eval))
    
    for (b in 1:B) {
      tr <- sample(n, round(0.8 * n))
      
      mu_tr <- colMeans(X_raw[tr, , drop = FALSE])
      sd_tr <- apply(X_raw[tr, , drop = FALSE], 2, sd)
      sd_tr[sd_tr == 0] <- 1
      
      X_tr <- scale(X_raw[tr, , drop = FALSE], mu_tr, sd_tr)
      X_te <- scale(X_raw[-tr, , drop = FALSE], mu_tr, sd_tr)
      y_tr <- y[tr]
      y_te <- y[-tr]
      
      dtr <- data.frame(y = y_tr, X_tr)
      dte <- data.frame(X_te)
      
      # MCO Completo
      if (p < (length(tr) - 2)) {
        m_ols <- lm(y ~ ., data = dtr)
        res_rmse[b, "MCO_Completo"] <- rmse(y_te, predict(m_ols, dte))
      }
      
      # MCO VIF Drop
      if (length(keep_vif) < (length(tr) - 2) && length(keep_vif) > 0) {
        m_vif <- lm(y ~ ., data = dtr[, c("y", keep_vif), drop = FALSE])
        res_rmse[b, "MCO_VIF_Drop"] <- rmse(y_te, predict(m_vif, dte))
      }
      
      # Modelos regularizados
      c_r <- cv.glmnet(X_tr, y_tr, alpha = 0, standardize = FALSE, lambda = lam_grid)
      res_rmse[b, "Ridge"] <- rmse(y_te, as.numeric(predict(c_r, X_te, s = "lambda.min")))
      
      c_l <- cv.glmnet(X_tr, y_tr, alpha = 1, standardize = FALSE)
      res_rmse[b, "Lasso"] <- rmse(y_te, as.numeric(predict(c_l, X_te, s = "lambda.min")))
      
      c_en <- cv.glmnet(X_tr, y_tr, alpha = 0.5, standardize = FALSE)
      res_rmse[b, "ElasticNet"] <- rmse(y_te, as.numeric(predict(c_en, X_te, s = "lambda.min")))
    }
    
    tabla_eval <- rbind(
      "RMSE Promedio"  = colMeans(res_rmse, na.rm = TRUE),
      "Desv. Estándar" = apply(res_rmse, 2, sd, na.rm = TRUE)
    )
    print(round(tabla_eval, 4))
  } else {
    cat("\n4. EVALUACIÓN PREDICTIVA:\n   (Omitida: muestra pequeña n < 20 para partición 80/20)\n")
  }
  
  return(invisible(list(coeficientes = tabla_coef, cv_ridge = cv_ridge, cv_lasso = cv_lasso, cv_enet = cv_enet)))
}

# =====================================================================
# EJECUCIÓN PASO A PASO POR FASES Y BASES DE DATOS
# =====================================================================

# ---------------------------------------------------------------------
# BASE 1: Cars93 (MASS, n = 82 casos completos, 16 predictores)
# ---------------------------------------------------------------------
vars_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")

fase2_cars <- diagnostico_fase2(Cars93[, vars_cars], MPG.city ~ ., nombre_bd = "Cars93")
fase4_cars <- estimacion_fase4(fase2_cars, nombre_bd = "Cars93", B = 100)


# ---------------------------------------------------------------------
# BASE 2: Hald Cement Data (mctest, n = 13, p = 4)
# ---------------------------------------------------------------------
data(Hald, package = "mctest")
Hald_df <- as.data.frame(Hald)
fase2_hald <- diagnostico_fase2(Hald_df, y ~ ., nombre_bd = "Hald Cement Data")
fase4_hald <- estimacion_fase4(fase2_hald, nombre_bd = "Hald Cement Data", ejecutar_cv_rep = FALSE)


# ---------------------------------------------------------------------
# BASE 3: Deforestación (deforest.csv, n = 405, p = 17)
# ---------------------------------------------------------------------
ruta_deforest <- buscar_ruta("data/Data/deforest.csv")
deforest_raw <- read.csv(ruta_deforest)
deforest_df <- deforest_raw[, !(names(deforest_raw) %in% c("id", "code", "ename"))]

fase2_deforest <- diagnostico_fase2(deforest_df, fcover ~ ., nombre_bd = "Deforestación")
fase4_deforest <- estimacion_fase4(fase2_deforest, nombre_bd = "Deforestación", B = 100)

# Nota: El análisis de Glaucoma (respuesta binaria, familia binomial) se retomará
# más adelante para el desafío opcional D1.