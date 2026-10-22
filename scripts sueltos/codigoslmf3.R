# =====================================================================
# INGENIERÍA EN ESTADÍSTICA - UCM
# FASE 3: SELECCIÓN DE VARIABLES, CRITERIOS (Cp, R2-adj, BIC) Y EJ. 8(b)
# =====================================================================

suppressPackageStartupMessages({
  library(MASS)     # Para Cars93
  library(car)      # Para VIF
  library(glmnet)   # Para Ridge, Lasso y Elastic Net
  library(leaps)    # Para regsubsets() -> Cp de Mallows, R2-adj, BIC
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
# FUNCIÓN GENERAL DE SELECCIÓN Y COMPARACIÓN PREDICTIVA (FASE 3)
# =====================================================================

analisis_seleccion_fase3 <- function(data, formula_obj, nombre_bd = "Base de Datos", 
                                     ejecutar_cv = TRUE, B = 100) {
  cat("\n=====================================================================\n")
  cat(" FASE 3: SELECCIÓN DE VARIABLES -", toupper(nombre_bd), "\n")
  cat("=====================================================================\n")
  
  d <- na.omit(data)
  mf <- model.frame(formula_obj, data = d)
  y <- model.response(mf)
  X_raw <- model.matrix(formula_obj, data = d)[, -1, drop = FALSE]
  
  # Filtrar columnas constantes si existen
  sds <- apply(X_raw, 2, sd)
  if (any(sds == 0)) X_raw <- X_raw[, sds > 0, drop = FALSE]
  
  datos_clean <- data.frame(y = y, X_raw)
  n <- nrow(datos_clean)
  p <- ncol(X_raw)
  cat(sprintf("Muestra limpia: n = %d observaciones, p = %d predictores\n\n", n, p))
  
  # -------------------------------------------------------------------
  # 1. MÉTODOS SECUENCIALES (Forward, Backward, Stepwise)
  # -------------------------------------------------------------------
  cat("1. MÉTODOS SECUENCIALES (step con criterio AIC):\n")
  mod_null <- lm(y ~ 1, data = datos_clean)
  mod_full <- lm(y ~ ., data = datos_clean)
  
  if (p <= 50) {
    mod_fwd  <- step(mod_null, scope = list(lower = mod_null, upper = mod_full), direction = "forward", trace = FALSE)
    mod_bwd  <- step(mod_full, direction = "backward", trace = FALSE)
    mod_step <- step(mod_null, scope = list(lower = mod_null, upper = mod_full), direction = "both", trace = FALSE)
    
    cat("   - Variables Forward  :", paste(names(coef(mod_fwd))[-1], collapse = ", "), "\n")
    cat("   - Variables Backward :", paste(names(coef(mod_bwd))[-1], collapse = ", "), "\n")
    cat("   - Variables Stepwise :", paste(names(coef(mod_step))[-1], collapse = ", "), "\n\n")
    f_step <- formula(mod_step)
  } else {
    # Para alta dimensionalidad (p > 50), Forward es computacionalmente seguro
    mod_fwd <- step(mod_null, scope = list(lower = mod_null, upper = mod_full), 
                    direction = "forward", steps = 15, trace = FALSE)
    cat("   - Variables Forward (top 15):", paste(names(coef(mod_fwd))[-1], collapse = ", "), "\n\n")
    f_step <- formula(mod_fwd)
  }
  
  # -------------------------------------------------------------------
  # 2. BÚSQUEDA EXHAUSTIVA O FORWARD (leaps: Cp, R2-adj, BIC)
  # -------------------------------------------------------------------
  cat("2. BÚSQUEDA Y CRITERIOS DE INFORMACIÓN (leaps::regsubsets):\n")
  nvmax_calc <- min(p, if (p <= 20) p else 15)
  metodo_leaps <- if (p <= 20) "exhaustive" else "forward"
  
  busqueda <- regsubsets(formula_obj, data = d, nbest = 1, nvmax = nvmax_calc, 
                         method = metodo_leaps, really.big = (p > 20))
  res_sub  <- summary(busqueda)
  
  id_r2adj <- which.max(res_sub$adjr2)
  id_cp    <- which.min(res_sub$cp)
  id_bic   <- which.min(res_sub$bic)
  
  cat(sprintf("   • Mejor según R2-Ajustado : %d predictores (R2-adj = %.4f)\n", 
              id_r2adj, res_sub$adjr2[id_r2adj]))
  cat(sprintf("   • Mejor según Cp Mallows  : %d predictores (Cp = %.2f)\n", 
              id_cp, res_sub$cp[id_cp]))
  cat(sprintf("   • Mejor según BIC         : %d predictores (BIC = %.2f)\n", 
              id_bic, res_sub$bic[id_bic]))
  
  vars_bic <- names(which(res_sub$which[id_bic, ])[-1])
  cat("   - Variables óptimas según BIC:", paste(vars_bic, collapse = ", "), "\n\n")
  f_bic <- as.formula(paste("y ~", paste(vars_bic, collapse = " + ")))
  
  # -------------------------------------------------------------------
  # 3. EVALUACIÓN PREDICTIVA COMPARATIVA (100 Particiones 80/20)
  # -------------------------------------------------------------------
  if (ejecutar_cv && n >= 20) {
    cat(sprintf("3. EVALUACIÓN PREDICTIVA FUERA DE MUESTRA (%d réplicas 80/20):\n", B))
    rmse <- function(y_real, y_pred) sqrt(mean((y_real - y_pred)^2))
    lam.grid <- exp(seq(log(1e4), log(1e-4), length.out = 100))
    
    modelos_eval <- c("MCO_Completo", "MCO_Stepwise", "MCO_BIC", "Ridge", "Lasso", "ElasticNet")
    res_rmse <- matrix(NA, B, length(modelos_eval), dimnames = list(NULL, modelos_eval))
    
    for (b in 1:B) {
      idx_tr <- sample(n, round(0.8 * n))
      tr <- datos_clean[idx_tr, ]
      te <- datos_clean[-idx_tr, ]
      
      # 1. MCO Completo (o regularizado si p > n)
      if (p < (nrow(tr) - 2)) {
        m_ols <- lm(y ~ ., data = tr)
        res_rmse[b, "MCO_Completo"] <- rmse(te$y, predict(m_ols, te))
      }
      
      # 2. MCO Stepwise
      m_step <- lm(f_step, data = tr)
      res_rmse[b, "MCO_Stepwise"] <- rmse(te$y, predict(m_step, te))
      
      # 3. MCO BIC
      m_bic  <- lm(f_bic, data = tr)
      res_rmse[b, "MCO_BIC"] <- rmse(te$y, predict(m_bic, te))
      
      # Estandarización dentro de la partición (evita fuga)
      X_tr_raw <- X_raw[idx_tr, , drop = FALSE]
      X_te_raw <- X_raw[-idx_tr, , drop = FALSE]
      mu_tr <- colMeans(X_tr_raw)
      sd_tr <- apply(X_tr_raw, 2, sd)
      sd_tr[sd_tr == 0] <- 1
      
      X_tr <- scale(X_tr_raw, mu_tr, sd_tr)
      X_te <- scale(X_te_raw, mu_tr, sd_tr)
      y_tr <- y[idx_tr]
      y_te <- y[-idx_tr]
      
      # 4. Ridge
      cv_r <- cv.glmnet(X_tr, y_tr, alpha = 0, standardize = FALSE, lambda = lam.grid)
      res_rmse[b, "Ridge"] <- rmse(y_te, predict(cv_r, X_te, s = "lambda.min"))
      
      # 5. Lasso
      cv_l <- cv.glmnet(X_tr, y_tr, alpha = 1, standardize = FALSE)
      res_rmse[b, "Lasso"] <- rmse(y_te, predict(cv_l, X_te, s = "lambda.min"))
      
      # 6. Elastic Net
      cv_en <- cv.glmnet(X_tr, y_tr, alpha = 0.5, standardize = FALSE)
      res_rmse[b, "ElasticNet"] <- rmse(y_te, predict(cv_en, X_te, s = "lambda.min"))
    }
    
    tabla_fase3 <- rbind(
      "RMSE Promedio"  = colMeans(res_rmse, na.rm = TRUE),
      "Desv. Estándar" = apply(res_rmse, 2, sd, na.rm = TRUE)
    )
    print(round(tabla_fase3, 4))
  } else {
    cat("   (Evaluación predictiva out-of-sample omitida: tamaño muestral n < 20 para partición 80/20)\n")
  }
}

# =====================================================================
# EJECUCIÓN DIRECTA POR BASE DE DATOS
# =====================================================================

# 1. Base 1: Cars93 (MASS, n = 82 casos completos, 16 predictores)
vars_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")

datos_cars <- na.omit(Cars93[, vars_cars])
fase3_cars <- analisis_seleccion_fase3(datos_cars, MPG.city ~ ., nombre_bd = "Cars93")


# 2. Base 2: Hald Cement Data (mctest, n = 13, p = 4)
data(Hald, package = "mctest")
Hald_df <- as.data.frame(Hald)
fase3_hald <- analisis_seleccion_fase3(Hald_df, y ~ ., nombre_bd = "Hald Cement Data", ejecutar_cv = FALSE)


# 3. Base Adicional 1: Deforestación (deforest.csv, n = 405, p = 17)
ruta_deforest <- buscar_ruta("data/Data/deforest.csv")
deforest_raw <- read.csv(ruta_deforest)
deforest_df <- deforest_raw[, !(names(deforest_raw) %in% c("id", "code", "ename"))]
fase3_deforest <- analisis_seleccion_fase3(deforest_df, fcover ~ ., nombre_bd = "Deforestación (deforest.csv)")


# 4. Base Adicional 2: Glaucoma (Glaucoma.csv, n = 800, p = 497 SNPs)
ruta_glaucoma <- buscar_ruta("data/ProblemsAndSolutions/Ch_6/Ch_6_Sol/Glaucoma.csv")
glaucoma_raw <- read.csv(ruta_glaucoma)
glaucoma_df <- glaucoma_raw[, -1]
glaucoma_df$y <- ifelse(glaucoma_df$y == "GLC", 1, 0)
fase3_glaucoma <- analisis_seleccion_fase3(glaucoma_df, y ~ ., nombre_bd = "Glaucoma (SNP Data, n = 800, p = 497)", ejecutar_cv = FALSE)
