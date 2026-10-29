# =====================================================================
# FASE 3: Selección de Variables, Criterios (Cp, R2-adj, BIC) y Ej. 8(b)
# Base de datos: Cars93
# Ingeniería en Estadística - UCM
# =====================================================================

suppressPackageStartupMessages({
  library(MASS)     # Para la base Cars93
  library(car)      # Para VIF
  library(glmnet)   # Para Ridge, Lasso y Elastic Net
  library(leaps)    # Para regsubsets() -> Cp de Mallows, R2-adj, BIC
})

set.seed(2026)

# 1. Preparación de datos
vars_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")

datos_cars <- na.omit(Cars93[, vars_cars])

# =====================================================================
# PARTE A: MÉTODOS STEPWISE, FORWARD Y BACKWARD
# =====================================================================
cat("\n=====================================================================\n")
cat(" 1. MÉTODOS SEQUENCIALES (Forward, Backward, Stepwise)\n")
cat("=====================================================================\n")

mod_null <- lm(MPG.city ~ 1, data = datos_cars)
mod_full <- lm(MPG.city ~ ., data = datos_cars)

# Algoritmos paso a paso
mod_forward  <- step(mod_null, scope = list(lower = mod_null, upper = mod_full), 
                     direction = "forward", trace = FALSE)

mod_backward <- step(mod_full, direction = "backward", trace = FALSE)

mod_stepwise <- step(mod_null, scope = list(lower = mod_null, upper = mod_full), 
                     direction = "both", trace = FALSE)

cat("A) Fórmula Forward:\n"); print(formula(mod_forward))
cat("\nB) Fórmula Backward:\n"); print(formula(mod_backward))
cat("\nC) Fórmula Stepwise:\n"); print(formula(mod_stepwise))

f_ej7b_step <- formula(mod_stepwise)

# =====================================================================
# PARTE B: EVALUACIÓN DE CRITERIOS DE INFORMACIÓN (Cp, R2-Adj, BIC)
# =====================================================================
cat("\n=====================================================================\n")
cat(" 2. BÚSQUEDA EXHAUSTIVA Y CRITERIOS DE INFORMACIÓN (leaps)\n")
cat("=====================================================================\n")

busqueda <- regsubsets(MPG.city ~ ., data = datos_cars, nbest = 1, nvmax = 16)
res_sub  <- summary(busqueda)

# Selección del mejor número de predictores según cada criterio
id_r2adj <- which.max(res_sub$adjr2)
id_cp    <- which.min(res_sub$cp)
id_bic   <- which.min(res_sub$bic)

cat(sprintf("• Mejor según R2-Ajustado : %d predictores (R2-adj = %.4f)\n", 
            id_r2adj, res_sub$adjr2[id_r2adj]))
cat(sprintf("• Mejor según Cp Mallows  : %d predictores (Cp = %.2f)\n", 
            id_cp, res_sub$cp[id_cp]))
cat(sprintf("• Mejor según BIC         : %d predictores (BIC = %.2f)\n\n", 
            id_bic, res_sub$bic[id_bic]))

# Variables óptimas seleccionadas bajo el criterio BIC
vars_bic <- names(which(res_sub$which[id_bic, ])[-1])
cat("Variables óptimas según criterio BIC:\n")
print(vars_bic)

f_ej7b_bic <- as.formula(paste("MPG.city ~", paste(vars_bic, collapse = " + ")))

# =====================================================================
# PARTE C: EJERCICIO 8(b) - EVALUACIÓN PREDICTIVA COMPARATIVA (100 Reps)
# Cierra la fase 3 comparando los modelos seleccionados vs penalizados
# =====================================================================
cat("\n=====================================================================\n")
cat(" 3. EJERCICIO 8(b): COMPARACIÓN DE CAPACIDAD PREDICTIVA GLOBAL\n")
cat("=====================================================================\n")

y <- datos_cars$MPG.city
X_raw <- model.matrix(MPG.city ~ ., data = datos_cars)[, -1]

# Variables de MCO VIF-Drop (< 10) de la Fase 2
keep_vif <- colnames(X_raw)
repeat {
  v <- car::vif(lm(as.formula(paste("MPG.city ~", paste(keep_vif, collapse = " + "))), data = datos_cars))
  if (max(v) < 10 || length(keep_vif) <= 1) break
  keep_vif <- setdiff(keep_vif, names(which.max(v)))
}
f_vif <- as.formula(paste("MPG.city ~", paste(keep_vif, collapse = " + ")))

B <- 100
rmse <- function(y_real, y_pred) sqrt(mean((y_real - y_pred)^2))
lam.grid <- exp(seq(log(1e4), log(1e-4), length.out = 100))

# Matriz para almacenar resultados de 100 validaciones cruzadas (80/20)
res_8b <- matrix(NA, B, 7, 
                 dimnames = list(NULL, c("MCO_Completo", "MCO_VIF_Drop", 
                                         "MCO_Stepwise", "MCO_BIC", 
                                         "Ridge", "Lasso", "ElasticNet")))

for (b in 1:B) {
  # Partición aleatoria
  idx_tr <- sample(nrow(datos_cars), round(0.8 * nrow(datos_cars)))
  train  <- datos_cars[idx_tr, ]
  test   <- datos_cars[-idx_tr, ]
  
  # 1. MCO Completo
  m_ols <- lm(MPG.city ~ ., data = train)
  res_8b[b, "MCO_Completo"] <- rmse(test$MPG.city, predict(m_ols, test))
  
  # 2. MCO VIF Drop
  m_vif <- lm(f_vif, data = train)
  res_8b[b, "MCO_VIF_Drop"] <- rmse(test$MPG.city, predict(m_vif, test))
  
  # 3. MCO Stepwise (Ej. 7b)
  m_step <- lm(f_ej7b_step, data = train)
  res_8b[b, "MCO_Stepwise"] <- rmse(test$MPG.city, predict(m_step, test))
  
  # 4. MCO BIC (Ej. 7b)
  m_bic  <- lm(f_ej7b_bic, data = train)
  res_8b[b, "MCO_BIC"] <- rmse(test$MPG.city, predict(m_bic, test))
  
  # Estandarización de predictores para modelos penalizados
  mu <- colMeans(X_raw[idx_tr, ])
  s  <- apply(X_raw[idx_tr, ], 2, sd)
  
  X_tr <- scale(X_raw[idx_tr, ], mu, s)
  X_te <- scale(X_raw[-idx_tr, ], mu, s)
  y_tr <- y[idx_tr]
  y_te <- y[-idx_tr]
  
  # 5. Ridge
  cv_r <- cv.glmnet(X_tr, y_tr, alpha = 0, standardize = FALSE, lambda = lam.grid)
  res_8b[b, "Ridge"] <- rmse(y_te, predict(cv_r, X_te, s = "lambda.min"))
  
  # 6. Lasso
  cv_l <- cv.glmnet(X_tr, y_tr, alpha = 1, standardize = FALSE)
  res_8b[b, "Lasso"] <- rmse(y_te, predict(cv_l, X_te, s = "lambda.min"))
  
  # 7. Elastic Net
  cv_en <- cv.glmnet(X_tr, y_tr, alpha = 0.5, standardize = FALSE)
  res_8b[b, "ElasticNet"] <- rmse(y_te, predict(cv_en, X_te, s = "lambda.min"))
}

# Tabla de resultados
cat("--- RESULTADO FINAL DE EVALUACIÓN PREDICTIVA EN PRUEBA (RMSE) ---\n")
tabla_fase3 <- rbind(
  "RMSE Promedio"  = colMeans(res_8b),
  "Desv. Estándar" = apply(res_8b, 2, sd)
)
print(round(tabla_fase3, 4))

