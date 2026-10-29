source("R/utils.R")
library(leaps)
library(MASS)
library(mlbench)

# Carga de datos BostonHousing
data(BostonHousing)
df_boston <- BostonHousing[, c("medv", "indus", "rm", "ptratio", "lstat")]
n_boston <- nrow(df_boston)
cat(sprintf("=== Ejercicio 4: BostonHousing (medv ~ indus + rm + ptratio + lstat) (n = %d) ===\n", n_boston))

# 1. Búsqueda exhaustiva de mejores subconjuntos (1 a 4 predictores)
reg_boston <- regsubsets(medv ~ indus + rm + ptratio + lstat, data = df_boston, nvmax = 4)
res_boston <- summary(reg_boston)

tabla_boston <- data.frame(
  p_predictores = 1:4,
  Variables = apply(res_boston$which[, -1], 1, function(row) paste(names(row)[row], collapse = ", ")),
  SSE = round(res_boston$rss, 2),
  R2 = round(res_boston$rsq, 4),
  R2_adj = round(res_boston$adjr2, 4),
  Cp_Mallows = round(res_boston$cp, 3),
  BIC = round(res_boston$bic, 2)
)
rownames(tabla_boston) <- paste0("Tamano_", 1:4)
cat("\n--- Mejores subconjuntos por tamaño en BostonHousing ---\n")
print(tabla_boston)
guardar_tabla(tabla_boston, "boston_mejores_subconjuntos")

# Modelo por Cp y modelo por AIC/BIC
mod_completo_b <- lm(medv ~ indus + rm + ptratio + lstat, data = df_boston)
step_aic_b <- step(mod_completo_b, direction = "both", trace = 0)
step_bic_b <- stepAIC(mod_completo_b, direction = "both", k = log(n_boston), trace = 0)

cat(sprintf("\nModelo óptimo por Cp (min):  Tamano %d (%s), Cp = %.3f\n", 
            which.min(res_boston$cp), tabla_boston$Variables[which.min(res_boston$cp)], min(res_boston$cp)))
cat(sprintf("Modelo óptimo por AIC (k=2):  Variables retenidas: %s (AIC = %.2f)\n", 
            paste(names(coef(step_aic_b))[-1], collapse = ", "), AIC(step_aic_b)))
cat(sprintf("Modelo óptimo por BIC:        Variables retenidas: %s (BIC = %.2f)\n", 
            paste(names(coef(step_bic_b))[-1], collapse = ", "), BIC(step_bic_b)))
