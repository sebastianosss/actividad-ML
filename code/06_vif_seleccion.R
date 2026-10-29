source("R/utils.R")
library(car)
library(MASS)
library(mctest)

cat("=== Ejercicio 8(b): Diagnostico de VIF en modelos seleccionados vs completos ===\n\n")

# 1. Dataset Hald
data(Hald)
hald_df <- as.data.frame(Hald)
mod_hald_full <- lm(y ~ ., data = hald_df)
vif_hald_full <- car::vif(mod_hald_full)

# Modelo optimo de 2 predictores en Hald (X1, X2) elegido por BIC
mod_hald_bic <- lm(y ~ X1 + X2, data = hald_df)
vif_hald_bic <- car::vif(mod_hald_bic)

# Modelo de 3 predictores (X1, X2, X4) elegido por Cp
mod_hald_cp <- lm(y ~ X1 + X2 + X4, data = hald_df)
vif_hald_cp <- car::vif(mod_hald_cp)

cat("--- VIF en Hald: Modelo Completo vs Seleccionados ---\n")
cat("VIF Modelo Completo (X1, X2, X3, X4):\n")
print(round(vif_hald_full, 2))
cat("\nVIF Modelo BIC (X1, X2):\n")
print(round(vif_hald_bic, 2))
cat("\nVIF Modelo Cp (X1, X2, X4):\n")
print(round(vif_hald_cp, 2))

# 2. Dataset Cars93
data(Cars93)
cols_cars93 <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
                 "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
                 "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
                 "Rear.seat.room", "Luggage.room", "Weight")
cars93_sub <- Cars93[, cols_cars93]
cars93_comp <- cars93_sub[complete.cases(cars93_sub), ]

mod_cars_full <- lm(MPG.city ~ ., data = cars93_comp)
vif_cars_full <- car::vif(mod_cars_full)

# Modelos seleccionados por BIC y AIC
step_bic <- stepAIC(mod_cars_full, direction = "both", k = log(nrow(cars93_comp)), trace = 0)
vif_cars_bic <- car::vif(step_bic)

step_aic <- stepAIC(mod_cars_full, direction = "both", k = 2, trace = 0)
vif_cars_aic <- car::vif(step_aic)

cat("\n--- VIF en Cars93: Modelo Completo vs Seleccionados ---\n")
cat(sprintf("VIF maximo en Modelo Completo (p = 16): %.2f (Variable: %s)\n", 
            max(vif_cars_full), names(which.max(vif_cars_full))))
cat(sprintf("Variables con VIF > 10 en Modelo Completo: %d de %d\n", 
            sum(vif_cars_full > 10), length(vif_cars_full)))

cat(sprintf("\nVIF maximo en Modelo BIC (p = %d): %.2f (Variable: %s)\n", 
            length(coef(step_bic)) - 1, max(vif_cars_bic), names(which.max(vif_cars_bic))))
cat("VIFs en Modelo BIC:\n")
print(round(vif_cars_bic, 2))

cat(sprintf("\nVIF maximo en Modelo AIC (p = %d): %.2f (Variable: %s)\n", 
            length(coef(step_aic)) - 1, max(vif_cars_aic), names(which.max(vif_cars_aic))))
cat("VIFs en Modelo AIC:\n")
print(round(vif_cars_aic, 2))

# Guardar resumen de comparacion de VIF
tabla_vif_resumen <- data.frame(
  Dataset_Modelo = c("Hald Completo", "Hald Seleccionado (BIC: X1, X2)",
                     "Cars93 Completo", "Cars93 Seleccionado (BIC)", "Cars93 Seleccionado (AIC)"),
  Num_Predictores = c(4, 2, 16, length(coef(step_bic)) - 1, length(coef(step_aic)) - 1),
  VIF_Maximo = c(round(max(vif_hald_full), 2), round(max(vif_hald_bic), 2),
                 round(max(vif_cars_full), 2), round(max(vif_cars_bic), 2), round(max(vif_cars_aic), 2)),
  VIF_Medio = c(round(mean(vif_hald_full), 2), round(mean(vif_hald_bic), 2),
                round(mean(vif_cars_full), 2), round(mean(vif_cars_bic), 2), round(mean(vif_cars_aic), 2)),
  Cantidad_VIF_mayor_10 = c(sum(vif_hald_full > 10), sum(vif_hald_bic > 10),
                            sum(vif_cars_full > 10), sum(vif_cars_bic > 10), sum(vif_cars_aic > 10))
)
print(tabla_vif_resumen)
guardar_tabla(tabla_vif_resumen, "vif_comparativa_seleccion")
