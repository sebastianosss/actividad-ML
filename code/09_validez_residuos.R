source("R/utils.R")
library(car)
library(MASS)

cat("=== FASE F5: VALIDEZ DE LAS CONCLUSIONES (RESIDUOS E INFLUENCIA) ===\n\n")

data(Cars93)
cols_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")
cars93_comp <- Cars93[complete.cases(Cars93[, cols_cars]), cols_cars]
n <- nrow(cars93_comp)

# Modelo seleccionado por BIC (9 predictores continuos)
mod_bic <- stepAIC(lm(MPG.city ~ ., data = cars93_comp), direction = "both", 
                   k = log(n), trace = 0)
p <- length(coef(mod_bic)) # p = 10 (incluye intercepto)

# 1. Umbrales formales de diagnóstico (Convención técnica 13)
h_cut    <- 2 * p / n               # 2 * 10 / 82 = 0.2439
cook_cut <- 4 / n                   # 4 / 82 = 0.0488
dffits_cut <- 2 * sqrt(p / n)       # 2 * sqrt(10 / 82) = 0.6984
dfbetas_cut <- 2 / sqrt(n)          # 2 / sqrt(82) = 0.2209

cat(sprintf("Dimensiones del modelo: n = %d, parametros p (con intercepto) = %d\n", n, p))
cat(sprintf("Umbral de Apalancamiento (2p/n):   %.4f\n", h_cut))
cat(sprintf("Umbral de Distancia de Cook (4/n):   %.4f\n", cook_cut))
cat(sprintf("Umbral de DFFITS (2*sqrt(p/n)):      %.4f\n", dffits_cut))
cat(sprintf("Umbral de DFBETAS (2/sqrt(n)):       %.4f\n", dfbetas_cut))

# 2. Cálculo de métricas diagnósticas
res_stud <- rstudent(mod_bic)
h_ii     <- hatvalues(mod_bic)
cook_d   <- cooks.distance(mod_bic)
dffits_val <- dffits(mod_bic)
dfbetas_mat <- dfbetas(mod_bic)

# Observaciones señaladas por Cook o Apalancamiento
obs_leverage <- which(h_ii > h_cut)
obs_cook     <- which(cook_d > cook_cut)
obs_influyentes <- sort(unique(c(obs_leverage, obs_cook)))

modelos_autos <- rownames(cars93_comp)[obs_influyentes]
tabla_influyentes <- data.frame(
  Indice = obs_influyentes,
  Auto = Cars93$Model[as.numeric(rownames(cars93_comp)[obs_influyentes])],
  Resid_Stud = round(res_stud[obs_influyentes], 3),
  Leverage_hii = round(h_ii[obs_influyentes], 4),
  Dist_Cook = round(cook_d[obs_influyentes], 4),
  DFFITS = round(dffits_val[obs_influyentes], 3),
  Supera_Apalancamiento = h_ii[obs_influyentes] > h_cut,
  Supera_Cook = cook_d[obs_influyentes] > cook_cut
)
cat("\n--- Observaciones Identificadas como Atípicas, Apalancadas o Influyentes ---\n")
print(tabla_influyentes)
guardar_tabla(tabla_influyentes, "cars93_diagnostico_influencia")

# 3. Gráficos de diagnóstico
png("fig/cars93_diagnostico_influencia.png", width = 1100, height = 700, res = 120)
par(mfrow = c(2, 2), mar = c(4.5, 4.5, 3, 1))

# A. Residuos studentizados
plot(res_stud, ylab = "Residuos Studentizados", xlab = "Índice de Observación",
     main = "Residuos Studentizados", pch = 19, col = "gray30", ylim = c(-3.5, 3.5))
abline(h = c(-2, 0, 2), col = c("red", "black", "red"), lty = c(2, 1, 2))
text(which(abs(res_stud) > 2), res_stud[abs(res_stud) > 2], 
     labels = which(abs(res_stud) > 2), pos = 3, cex = 0.8, col = "red")

# B. Apalancamiento (Leverage)
plot(h_ii, ylab = "Apalancamiento (h_ii)", xlab = "Índice de Observación",
     main = "Apalancamiento (h_ii > 2p/n)", pch = 19, col = "gray30")
abline(h = h_cut, col = "red", lty = 2)
text(obs_leverage, h_ii[obs_leverage], labels = obs_leverage, pos = 3, cex = 0.8, col = "red")

# C. Distancia de Cook
plot(cook_d, ylab = "Distancia de Cook (D_i)", xlab = "Índice de Observación",
     main = "Distancia de Cook (D_i > 4/n)", pch = 19, col = "gray30")
abline(h = cook_cut, col = "red", lty = 2)
text(obs_cook, cook_d[obs_cook], labels = obs_cook, pos = 3, cex = 0.8, col = "red")

# D. DFFITS
plot(dffits_val, ylab = "DFFITS", xlab = "Índice de Observación",
     main = "DFFITS (|DFFITS| > 2*sqrt(p/n))", pch = 19, col = "gray30")
abline(h = c(-dffits_cut, dffits_cut), col = "red", lty = 2)
dev.off()

# 4. Reajuste del modelo sin observaciones influyentes (Análisis de Sensibilidad)
idx_sin_cook <- setdiff(1:n, obs_cook)
mod_bic_reajuste <- lm(formula(mod_bic), data = cars93_comp[idx_sin_cook, ])

coef_orig <- coef(mod_bic)
se_orig   <- summary(mod_bic)$coefficients[, 2]
coef_reaj <- coef(mod_bic_reajuste)
se_reaj   <- summary(mod_bic_reajuste)$coefficients[, 2]

cambio_coef_se <- (coef_reaj - coef_orig) / se_orig

tabla_sensibilidad <- data.frame(
  Termino = names(coef_orig),
  Coef_Original = round(coef_orig, 4),
  SE_Original   = round(se_orig, 4),
  Coef_Sin_Influyentes = round(coef_reaj, 4),
  SE_Sin_Influyentes   = round(se_reaj, 4),
  Cambio_en_SE = round(cambio_coef_se, 2)
)
cat("\n--- Análisis de Sensibilidad: Reajuste sin Observaciones Influyentes ---\n")
print(tabla_sensibilidad)
cat(sprintf("R2_adj Original: %.4f | R2_adj Reajustado: %.4f\n", 
            summary(mod_bic)$adj.r.squared, summary(mod_bic_reajuste)$adj.r.squared))
guardar_tabla(tabla_sensibilidad, "cars93_sensibilidad_reajuste")
