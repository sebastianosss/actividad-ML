# =====================================================================
# INGENIERÍA EN ESTADÍSTICA - UCM
# GUÍA PRÁCTICA: MULTICOLINEALIDAD (FASE 2)
# =====================================================================

suppressPackageStartupMessages({
  library(MASS)     # Para base de datos Cars93
  library(car)      # Para VIF: vif()
})

options(width = 80, digits = 4)
set.seed(2026)

# =====================================================================
# FASE 2: DIAGNÓSTICO DE MULTICOLINEALIDAD Y MCO
# =====================================================================

diagnostico_fase2 <- function(data, formula_obj, nombre_bd = "Base de Datos") {
  
  # 1. Limpieza y preparación de matrices
  d <- na.omit(data)
  mf <- model.frame(formula_obj, data = d)
  y <- model.response(mf)
  X_raw <- model.matrix(formula_obj, data = d)[, -1] # Sin intercepto
  
  X <- scale(X_raw)
  dat <- data.frame(y = y, X)
  
  cat("\n=====================================================================\n")
  cat(" FASE 2: DIAGNÓSTICO DE MULTICOLINEALIDAD -", toupper(nombre_bd), "\n")
  cat("=====================================================================\n")
  cat(sprintf("Muestra limpia: n = %d observaciones, p = %d predictores\n\n", nrow(X), ncol(X)))
  
  # 2. Análisis de Correlaciones Pares (|r| > 0.90)
  R <- cor(X)
  pares <- which(upper.tri(R), arr.ind = TRUE)
  r_vals <- R[pares]
  n90 <- sum(abs(r_vals) > 0.90)
  
  cat("1. CORRELACIONES BIVARIADAS:\n")
  cat(sprintf("   - Total de pares con |r| > 0.90: %d\n", n90))
  if (n90 > 0) {
    idx <- which(abs(R) > 0.90 & upper.tri(R), arr.ind = TRUE)
    df_corr <- data.frame(
      Var1 = colnames(X)[idx[, 1]],
      Var2 = colnames(X)[idx[, 2]],
      r = R[idx]
    )
    print(df_corr)
  }
  
  # 3. Modelo MCO Completo
  mod_ols <- lm(y ~ ., data = dat)
  sm <- summary(mod_ols)
  
  cat("\n2. MODELO MCO COMPLETO:\n")
  cat(sprintf("   - R-cuadrado          : %.4f\n", sm$r.squared))
  cat(sprintf("   - R-cuadrado Ajustado : %.4f\n", sm$adj.r.squared))
  cat(sprintf("   - Error Estándar (RSE): %.4f\n", sm$sigma))
  
  # 4. Indicadores de Multicolinealidad (VIF y Número de Condición)
  vif_vals <- car::vif(mod_ols)
  ev <- eigen(crossprod(X) / (nrow(X) - 1), symmetric = TRUE)$values
  eta <- sqrt(max(ev) / ev) # Número de condición de la matriz X
  
  cat("\n3. DIAGNÓSTICO DE MULTICOLINEALIDAD:\n")
  cat(sprintf("   - VIF Máximo           : %.2f (Variable: %s)\n", max(vif_vals), names(which.max(vif_vals))))
  cat(sprintf("   - VIF Promedio         : %.2f\n", mean(vif_vals)))
  cat(sprintf("   - Número de Condición η: %.2f ", max(eta)))
  if (max(eta) > 30) cat("(¡Multicolinealidad SEVERA η > 30!)\n") else cat("(Multicolinealidad moderada/baja)\n")
  
  # 5. Algoritmo VIF Drop (< 10)
  keep_vif <- colnames(X)
  repeat {
    v <- car::vif(lm(y ~ ., data = dat[, c("y", keep_vif)]))
    if (max(v) < 10 || length(keep_vif) <= 1) break
    keep_vif <- setdiff(keep_vif, names(which.max(v)))
  }
  
  mod_vif <- lm(y ~ ., data = dat[, c("y", keep_vif)])
  sm_vif  <- summary(mod_vif)
  
  cat("\n4. MODELO REDUCIDO VIF-DROP (< 10):\n")
  cat(sprintf("   - Variables retenidas (%d de %d): %s\n", 
              length(keep_vif), ncol(X), paste(keep_vif, collapse = ", ")))
  cat(sprintf("   - R2-Ajustado VIF Drop : %.4f\n\n", sm_vif$adj.r.squared))
  
  # Retorno del objeto
  res_list <- list(data_clean = d, y = y, X_raw = X_raw, X_scaled = X, keep_vif = keep_vif, mod_ols = mod_ols)
  return(res_list)
}

# =====================================================================
# EJECUCIÓN DIRECTA Y VISUALIZACIÓN EN CONSOLA
# =====================================================================

# 1. Definir variables y ejecutar Cars93
vars_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")

fase2_cars <- diagnostico_fase2(Cars93[, vars_cars], MPG.city ~ ., nombre_bd = "Cars93")


# 2. Definir dataframe Hald y ejecutar Hald Cement Data
Hald <- data.frame(
  X1 = c(7, 1, 11, 11, 7, 11, 3, 1, 2, 21, 1, 11, 10),
  X2 = c(26, 29, 56, 31, 52, 55, 71, 31, 54, 47, 40, 66, 68),
  X3 = c(6, 15, 8, 8, 6, 9, 17, 22, 18, 4, 23, 9, 2),
  X4 = c(60, 52, 20, 47, 33, 22, 6, 44, 22, 26, 34, 12, 12),
  Y  = c(78.5, 74.3, 104.3, 87.6, 95.9, 109.2, 102.7, 72.5, 93.1, 115.9, 83.8, 113.3, 109.4)
)

fase2_hald <- diagnostico_fase2(Hald, Y ~ ., nombre_bd = "Hald Cement Data")