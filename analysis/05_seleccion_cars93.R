#@ 05_seleccion_cars93
source("R/utils.R")
library(leaps)
library(MASS)

data(Cars93)
# 1. Definicion de variables y filtrado de casos completos acordado en F1
cols_cars93 <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
                 "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
                 "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
                 "Rear.seat.room", "Luggage.room", "Weight")

cars93_sub <- Cars93[, cols_cars93]
cars93_comp <- cars93_sub[complete.cases(cars93_sub), ]
n_cars <- nrow(cars93_comp)
p_cars <- ncol(cars93_comp) - 1

cat(sprintf("=== Ejercicios 5(a) y 6: Seleccion de variables en Cars93 ===\n"))
cat(sprintf("Casos completos analizados: n = %d, predictores p = %d (excluyendo MPG.highway)\n", n_cars, p_cars))
verificar_datos(cars93_comp, "Cars93_Completo", n_esperado = 82, p_esperado = 17)

# 2. Ejercicio 5(a): stepAIC con AIC (k = 2) desde modelo completo
mod_full_cars <- lm(MPG.city ~ ., data = cars93_comp)
step_aic_cars <- stepAIC(mod_full_cars, direction = "both", k = 2, trace = 0)

vars_aic <- names(coef(step_aic_cars))[-1]
cat("\n--- Ejercicio 5(a): Modelo seleccionado por stepAIC con AIC (k = 2) ---\n")
cat("Predictores seleccionados:\n", paste(vars_aic, collapse = ", "), "\n")
cat(sprintf("AIC = %.3f | R2 = %.4f | R2_adj = %.4f | p = %d predictores\n", 
            AIC(step_aic_cars), summary(step_aic_cars)$r.squared, 
            summary(step_aic_cars)$adj.r.squared, length(vars_aic)))

# 3. Ejercicio 6: stepAIC con BIC (k = log(n)) desde modelo completo
step_bic_cars <- stepAIC(mod_full_cars, direction = "both", k = log(n_cars), trace = 0)
vars_bic <- names(coef(step_bic_cars))[-1]

cat("\n--- Ejercicio 6: Modelo seleccionado por stepAIC con BIC (k = log(n)) ---\n")
cat("Predictores seleccionados:\n", paste(vars_bic, collapse = ", "), "\n")
cat(sprintf("BIC = %.3f | AIC = %.3f | R2 = %.4f | R2_adj = %.4f | p = %d predictores\n", 
            BIC(step_bic_cars), AIC(step_bic_cars), summary(step_bic_cars)$r.squared, 
            summary(step_bic_cars)$adj.r.squared, length(vars_bic)))

# 4. Ejercicio 6: Todas las regresiones posibles con Cp de Mallows (nvmax = 16)
reg_cars <- regsubsets(MPG.city ~ ., data = cars93_comp, nvmax = p_cars, really.big = TRUE)
res_cars <- summary(reg_cars)

# Modelo con minimo Cp
idx_cp_min <- which.min(res_cars$cp)
vars_cp <- names(which(res_cars$which[idx_cp_min, -1]))

cat("\n--- Ejercicio 6: Búsqueda exhaustiva por Cp de Mallows ---\n")
cat(sprintf("Tamano optimo por Cp (min): %d predictores\n", idx_cp_min))
cat("Predictores seleccionados por Cp:\n", paste(vars_cp, collapse = ", "), "\n")
cat(sprintf("Cp = %.3f | R2 = %.4f | R2_adj = %.4f | BIC = %.3f\n", 
            res_cars$cp[idx_cp_min], res_cars$rsq[idx_cp_min], 
            res_cars$adjr2[idx_cp_min], res_cars$bic[idx_cp_min]))

# Tabla comparativa de los tres modelos de Cars93
tabla_comparativa_cars <- data.frame(
  Criterio_Metodo = c("AIC paso a paso (Ej 5a)", "BIC paso a paso (Ej 6)", "Cp exhaustivo (Ej 6)", "Modelo Completo (MCO)"),
  Num_Predictores = c(length(vars_aic), length(vars_bic), length(vars_cp), p_cars),
  AIC = round(c(AIC(step_aic_cars), AIC(step_bic_cars), 
                AIC(lm(as.formula(paste("MPG.city ~", paste(vars_cp, collapse = "+"))), data = cars93_comp)), 
                AIC(mod_full_cars)), 2),
  BIC = round(c(BIC(step_aic_cars), BIC(step_bic_cars), 
                BIC(lm(as.formula(paste("MPG.city ~", paste(vars_cp, collapse = "+"))), data = cars93_comp)), 
                BIC(mod_full_cars)), 2),
  R2_adj = round(c(summary(step_aic_cars)$adj.r.squared, summary(step_bic_cars)$adj.r.squared, 
                   res_cars$adjr2[idx_cp_min], summary(mod_full_cars)$adj.r.squared), 4)
)
cat("\n--- Resumen comparativo de modelos en Cars93 ---\n")
print(tabla_comparativa_cars)
guardar_tabla(tabla_comparativa_cars, "cars93_comparativa_modelos")

# 5. Modelos evaluados: Exhaustivo vs Paso a paso
modelos_exhaustivos <- 2^p_cars - 1
cat(sprintf("\n--- Costo computacional de modelos evaluados (p = %d) ---\n", p_cars))
cat(sprintf("Modelos posibles evaluados en búsqueda exhaustiva (2^p - 1): %d\n", modelos_exhaustivos))
cat(sprintf("Modelos evaluados aproximadamente por stepwise: a lo sumo p*(p+1)/2 = %d evaluaciones\n", 
            as.integer(p_cars * (p_cars + 1) / 2)))

