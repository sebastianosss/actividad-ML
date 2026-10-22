# =====================================================================
# INGENIERÍA EN ESTADÍSTICA - UCM
# GUÍA PRÁCTICA: MULTICOLINEALIDAD (FASE 2)
# =====================================================================

suppressPackageStartupMessages({
  library(MASS)     # Para base de datos Cars93
  library(car)      # Para VIF: vif()
  library(mctest)   # Para Hald
})

options(width = 80, digits = 4)
set.seed(2026)

# Función auxiliar para localizar rutas relativas desde raíz o scripts sueltos/
buscar_ruta <- function(ruta_rel) {
  if (file.exists(ruta_rel)) return(ruta_rel)
  ruta_padre <- file.path("..", ruta_rel)
  if (file.exists(ruta_padre)) return(ruta_padre)
  stop(sprintf("No se encontró el archivo en las rutas: '%s' ni '%s'", ruta_rel, ruta_padre))
}

# =====================================================================
# FASE 2: DIAGNÓSTICO DE MULTICOLINEALIDAD Y MCO
# =====================================================================

diagnostico_fase2 <- function(data, formula_obj, nombre_bd = "Base de Datos", ejecutar_vif_drop = TRUE) {
  
  # 1. Limpieza y preparación de matrices
  d <- na.omit(data)
  mf <- model.frame(formula_obj, data = d)
  y <- model.response(mf)
  X_raw <- model.matrix(formula_obj, data = d)[, -1, drop = FALSE] # Sin intercepto
  
  # Escalamiento de predictores con varianza no nula
  sds <- apply(X_raw, 2, sd)
  if (any(sds == 0)) {
    warning("Se detectaron columnas constantes en X_raw; se omiten del escalamiento.")
    X_raw <- X_raw[, sds > 0, drop = FALSE]
  }
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
  n90 <- sum(abs(r_vals) > 0.90, na.rm = TRUE)
  
  cat("1. CORRELACIONES BIVARIADAS:\n")
  cat(sprintf("   - Total de pares con |r| > 0.90: %d\n", n90))
  if (n90 > 0) {
    idx <- which(abs(R) > 0.90 & upper.tri(R), arr.ind = TRUE)
    df_corr <- data.frame(
      Var1 = colnames(X)[idx[, 1]],
      Var2 = colnames(X)[idx[, 2]],
      r = R[idx]
    )
    # Si son muchas, mostrar las primeras 10
    if (nrow(df_corr) > 10) {
      cat("   (Mostrando los primeros 10 pares con mayor correlación):\n")
      print(head(df_corr[order(-abs(df_corr$r)), ], 10))
    } else {
      print(df_corr)
    }
  }
  
  # 3. Modelo MCO Completo
  mod_ols <- lm(y ~ ., data = dat)
  sm <- summary(mod_ols)
  
  cat("\n2. MODELO MCO COMPLETO:\n")
  cat(sprintf("   - R-cuadrado          : %.4f\n", sm$r.squared))
  cat(sprintf("   - R-cuadrado Ajustado : %.4f\n", sm$adj.r.squared))
  cat(sprintf("   - Error Estándar (RSE): %.4f\n", sm$sigma))
  
  # 4. Indicadores de Multicolinealidad (VIF y Número de Condición)
  vif_vals <- tryCatch(car::vif(mod_ols), error = function(e) {
    warning("Error al calcular car::vif: ", e$message)
    return(NULL)
  })
  
  ev <- eigen(crossprod(X) / (nrow(X) - 1), symmetric = TRUE)$values
  ev_pos <- pmax(ev, .Machine$double.eps)
  eta <- sqrt(max(ev_pos) / ev_pos) # Número de condición de la matriz X
  
  cat("\n3. DIAGNÓSTICO DE MULTICOLINEALIDAD:\n")
  if (!is.null(vif_vals)) {
    cat(sprintf("   - VIF Máximo           : %.2f (Variable: %s)\n", max(vif_vals), names(which.max(vif_vals))))
    cat(sprintf("   - VIF Promedio         : %.2f\n", mean(vif_vals)))
    cat(sprintf("   - Total VIF > 10       : %d de %d\n", sum(vif_vals > 10), length(vif_vals)))
  }
  cat(sprintf("   - Número de Condición η: %.2f ", max(eta)))
  if (max(eta) > 30) cat("(¡Multicolinealidad SEVERA η > 30!)\n") else cat("(Multicolinealidad moderada/baja)\n")
  
  # 5. Algoritmo VIF Drop (< 10)
  keep_vif <- colnames(X)
  if (ejecutar_vif_drop && ncol(X) <= 50) {
    repeat {
      v <- tryCatch(car::vif(lm(y ~ ., data = dat[, c("y", keep_vif)])), error = function(e) NULL)
      if (is.null(v) || max(v) < 10 || length(keep_vif) <= 1) break
      keep_vif <- setdiff(keep_vif, names(which.max(v)))
    }
    
    mod_vif <- lm(y ~ ., data = dat[, c("y", keep_vif)])
    sm_vif  <- summary(mod_vif)
    
    cat("\n4. MODELO REDUCIDO VIF-DROP (< 10):\n")
    cat(sprintf("   - Variables retenidas (%d de %d): %s\n", 
                length(keep_vif), ncol(X), paste(keep_vif, collapse = ", ")))
    cat(sprintf("   - R2-Ajustado VIF Drop : %.4f\n\n", sm_vif$adj.r.squared))
  } else if (ncol(X) > 50) {
    cat("\n4. MODELO REDUCIDO VIF-DROP (< 10):\n")
    cat(sprintf("   - Omitido por alta dimensionalidad (p = %d predictores; VIF-drop secuencial iterativo computacionalmente prohibitivo).\n\n", ncol(X)))
  }
  
  # Retorno del objeto
  res_list <- list(data_clean = d, y = y, X_raw = X_raw, X_scaled = X, keep_vif = keep_vif, mod_ols = mod_ols)
  return(invisible(res_list))
}

# =====================================================================
# EJECUCIÓN DIRECTA Y VISUALIZACIÓN EN CONSOLA
# =====================================================================

# 1. Definir variables y ejecutar Cars93 (MASS, casos completos n = 82)
vars_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")

fase2_cars <- diagnostico_fase2(Cars93[, vars_cars], MPG.city ~ ., nombre_bd = "Cars93")


# 2. Cargar y ejecutar Hald Cement Data (mctest, n = 13, p = 4)
data(Hald, package = "mctest")
Hald_df <- as.data.frame(Hald)
fase2_hald <- diagnostico_fase2(Hald_df, y ~ ., nombre_bd = "Hald Cement Data")


# 3. Base Adicional 1: Deforestación (deforest.csv, n = 405, p = 17)
ruta_deforest <- buscar_ruta("data/Data/deforest.csv")
deforest_raw <- read.csv(ruta_deforest)
# Exclusión de identificadores no numéricos / administrativos (id, code, ename)
deforest_df <- deforest_raw[, !(names(deforest_raw) %in% c("id", "code", "ename"))]
fase2_deforest <- diagnostico_fase2(deforest_df, fcover ~ ., nombre_bd = "Deforestación (deforest.csv)")


# 4. Base Adicional 2: Glaucoma (Glaucoma.csv, n = 800, p = 497 SNPs)
ruta_glaucoma <- buscar_ruta("data/ProblemsAndSolutions/Ch_6/Ch_6_Sol/Glaucoma.csv")
glaucoma_raw <- read.csv(ruta_glaucoma)
# Columna 1 (X) es identificador del paciente; Columna 2 (y) es respuesta binaria (AMD vs GLC)
glaucoma_df <- glaucoma_raw[, -1]
glaucoma_df$y <- ifelse(glaucoma_df$y == "GLC", 1, 0)
fase2_glaucoma <- diagnostico_fase2(glaucoma_df, y ~ ., nombre_bd = "Glaucoma (SNP Data, n = 800, p = 497)", ejecutar_vif_drop = FALSE)