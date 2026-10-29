#@ 03_seleccion_hald
source("R/utils.R")
library(leaps)
library(MASS)
library(mctest)

# Carga de datos Hald y conversion a data.frame (convencion tecnica)
data(Hald)
hald_df <- as.data.frame(Hald)
n_hald <- nrow(hald_df)
cat(sprintf("=== Ejercicio 7: Seleccion de variables en Hald (n = %d, p = 4) ===\n", n_hald))

# 1. Busqueda exhaustiva de mejores subconjuntos con regsubsets
reg_all <- regsubsets(y ~ ., data = hald_df, nvmax = 4)
res_all <- summary(reg_all)

# Tabla resumen de criterios para mejores subconjuntos por tamano
# Nota: regsubsets reporta bic = n*log(SSE/n) + k*log(n)
tabla_subconjuntos <- data.frame(
  p_predictores = 1:4,
  Variables = apply(res_all$which[, -1], 1, function(row) paste(names(row)[row], collapse = ", ")),
  SSE = round(res_all$rss, 3),
  R2 = round(res_all$rsq, 4),
  R2_adj = round(res_all$adjr2, 4),
  Cp_Mallows = round(res_all$cp, 3),
  BIC = round(res_all$bic, 3)
)
rownames(tabla_subconjuntos) <- paste0("Tamano_", 1:4)
cat("\n--- Mejores subconjuntos por tamano (busqueda exhaustiva) ---\n")
print(tabla_subconjuntos)
guardar_tabla(tabla_subconjuntos, "hald_mejores_subconjuntos")

# Modelos optimos segun cada criterio
mejor_r2adj <- which.max(res_all$adjr2)
mejor_cp    <- which.min(abs(res_all$cp - (1:4 + 1))) # Cp mas cercano a p+1 o minimo
mejor_bic   <- which.min(res_all$bic)

cat(sprintf("\nModelo optimo por R2_adj (max): Tamano %d (%s), R2_adj = %.4f\n", 
            mejor_r2adj, tabla_subconjuntos$Variables[mejor_r2adj], res_all$adjr2[mejor_r2adj]))
cat(sprintf("Modelo optimo por Cp (min):     Tamano %d (%s), Cp = %.3f\n", 
            which.min(res_all$cp), tabla_subconjuntos$Variables[which.min(res_all$cp)], min(res_all$cp)))
cat(sprintf("Modelo optimo por BIC (min):    Tamano %d (%s), BIC = %.3f\n", 
            mejor_bic, tabla_subconjuntos$Variables[mejor_bic], res_all$bic[mejor_bic]))

# 2. Metodos paso a paso (Forward, Backward, Stepwise) con step() y AIC (k = 2)
mod_nulo <- lm(y ~ 1, data = hald_df)
mod_completo <- lm(y ~ ., data = hald_df)

step_fwd <- step(mod_nulo, scope = list(lower = mod_nulo, upper = mod_completo), 
                 direction = "forward", trace = 0)
step_bwd <- step(mod_completo, direction = "backward", trace = 0)
step_both <- step(mod_nulo, scope = list(lower = mod_nulo, upper = mod_completo), 
                  direction = "both", trace = 0)

# Metodos paso a paso con BIC (k = log(n))
step_fwd_bic <- stepAIC(mod_nulo, scope = list(lower = mod_nulo, upper = mod_completo), 
                        direction = "forward", k = log(n_hald), trace = 0)
step_bwd_bic <- stepAIC(mod_completo, direction = "backward", k = log(n_hald), trace = 0)
step_both_bic <- stepAIC(mod_nulo, scope = list(lower = mod_nulo, upper = mod_completo), 
                         direction = "both", k = log(n_hald), trace = 0)

tabla_metodos <- data.frame(
  Metodo = c("Forward (AIC, k=2)", "Backward (AIC, k=2)", "Stepwise (AIC, k=2)",
             "Forward (BIC, k=log n)", "Backward (BIC, k=log n)", "Stepwise (BIC, k=log n)"),
  Variables_Seleccionadas = c(
    paste(names(coef(step_fwd))[-1], collapse = ", "),
    paste(names(coef(step_bwd))[-1], collapse = ", "),
    paste(names(coef(step_both))[-1], collapse = ", "),
    paste(names(coef(step_fwd_bic))[-1], collapse = ", "),
    paste(names(coef(step_bwd_bic))[-1], collapse = ", "),
    paste(names(coef(step_both_bic))[-1], collapse = ", ")
  ),
  AIC = round(c(AIC(step_fwd), AIC(step_bwd), AIC(step_both),
                AIC(step_fwd_bic), AIC(step_bwd_bic), AIC(step_both_bic)), 3),
  BIC = round(c(BIC(step_fwd), BIC(step_bwd), BIC(step_both),
                BIC(step_fwd_bic), BIC(step_bwd_bic), BIC(step_both_bic)), 3)
)
cat("\n--- Comparacion de metodos paso a paso (AIC vs BIC) en Hald ---\n")
print(tabla_metodos)
guardar_tabla(tabla_metodos, "hald_metodos_paso_a_paso")

