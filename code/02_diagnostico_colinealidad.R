source("R/utils.R")
library(car)
library(MASS)
library(mctest)

# ==============================================================================
# 1. DIAGNÓSTICO EN HALD (n = 13, p = 4)
# ==============================================================================
data(Hald)
hald_df <- as.data.frame(Hald)
X_hald <- as.matrix(hald_df[, c("X1", "X2", "X3", "X4")])
y_hald <- hald_df$y
n_hald <- nrow(hald_df)
p_hald <- ncol(X_hald)

cat("=== 1. DIAGNÓSTICO DE COLINEALIDAD EN HALD ===\n")

# A. Matriz de correlaciones
cor_hald <- cor(X_hald)
cat("\n--- Matriz de correlaciones (Hald) ---\n")
print(round(cor_hald, 4))
guardar_tabla(round(cor_hald, 4), "hald_matriz_correlacion")

# B. VIF por definición y con car::vif
vif_def_hald <- diag(solve(cor_hald))
mod_hald <- lm(y ~ X1 + X2 + X3 + X4, data = hald_df)
vif_car_hald <- car::vif(mod_hald)
dif_vif_hald <- max(abs(vif_def_hald - vif_car_hald))

cat("\n--- Factores de Inflación de la Varianza (VIF) en Hald ---\n")
tabla_vif_hald <- data.frame(
  Variable = names(vif_def_hald),
  VIF_definicion = round(vif_def_hald, 3),
  VIF_car = round(vif_car_hald, 3),
  Diferencia = format(abs(vif_def_hald - vif_car_hald), scientific = TRUE)
)
print(tabla_vif_hald)
cat(sprintf("Diferencia numérica máxima entre definición y car::vif: %e\n", dif_vif_hald))
guardar_tabla(tabla_vif_hald, "hald_vif_comparacion")

# C. Autovalores e Índices de Condición (Convención 1: matriz de correlación)
eigen_cor_hald <- eigen(cor_hald)$values
indices_cor_hald <- sqrt(max(eigen_cor_hald) / eigen_cor_hald)
num_cond_cor_hald <- max(indices_cor_hald)

cat("\n--- Autovalores e Índices de Condición (Matriz de correlación) ---\n")
cat("Autovalores:", round(eigen_cor_hald, 4), "\n")
cat("Índices de condición eta_j:", round(indices_cor_hald, 3), "\n")
cat(sprintf("Número de condición (correlación): %.3f\n", num_cond_cor_hald))

# D. Descomposición de Belsley, Kuh y Welsch (BKW, 1980)
# Convención BKW: Matriz de diseño con intercepto, columnas escaladas a norma unitaria (sin centrar)
X_bkw_hald <- cbind(Intercept = 1, X_hald)
X_bkw_scaled_hald <- apply(X_bkw_hald, 2, function(col) col / sqrt(sum(col^2)))
svd_hald <- svd(X_bkw_scaled_hald)
sing_vals_hald <- svd_hald$d
cond_indices_bkw_hald <- max(sing_vals_hald) / sing_vals_hald
num_cond_bkw_hald <- max(cond_indices_bkw_hald)

# Proporciones de descomposición de varianza
V_hald <- svd_hald$v
phi_hald <- t(apply(V_hald, 1, function(v_k) (v_k / sing_vals_hald)^2))
pi_hald <- prop.table(phi_hald, margin = 1)
colnames(pi_hald) <- paste0("Dim_", 1:ncol(pi_hald))
rownames(pi_hald) <- colnames(X_bkw_hald)

tabla_bkw_hald <- data.frame(
  Valor_Singular = round(sing_vals_hald, 4),
  Indice_Condicion = round(cond_indices_bkw_hald, 3),
  t(round(pi_hald, 4))
)
cat("\n--- Descomposición de varianzas BKW (Hald con intercepto) ---\n")
print(tabla_bkw_hald)
cat(sprintf("Número de condición BKW (con intercepto): %.3f\n", num_cond_bkw_hald))
guardar_tabla(tabla_bkw_hald, "hald_bkw_descomposicion")

# Gráfico de correlación Hald
png("fig/hald_correlaciones.png", width = 800, height = 700, res = 120)
par(mar = c(4, 4, 3, 2))
image(1:4, 1:4, cor_hald[, 4:1], axes = FALSE, xlab = "", ylab = "", 
      main = "Matriz de Correlación: Cemento de Hald")
axis(1, at = 1:4, labels = colnames(cor_hald))
axis(2, at = 1:4, labels = rev(colnames(cor_hald)))
for(x in 1:4) {
  for(y in 1:4) {
    val <- cor_hald[x, 5 - y]
    text(x, y, sprintf("%.2f", val), cex = 1.2, col = if(abs(val) > 0.6) "white" else "black")
  }
}
dev.off()

# ==============================================================================
# 2. DIAGNÓSTICO EN CARS93 (n = 82 casos completos, p = 16 predictores)
# ==============================================================================
data(Cars93)
cols_cars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
               "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
               "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
               "Rear.seat.room", "Luggage.room", "Weight")
cars93_comp <- Cars93[complete.cases(Cars93[, cols_cars]), cols_cars]
X_cars <- as.matrix(cars93_comp[, -1])
y_cars <- cars93_comp$MPG.city
n_cars <- nrow(cars93_comp)
p_cars <- ncol(X_cars)

cat("\n=== 2. DIAGNÓSTICO DE COLINEALIDAD EN CARS93 (n = 82, p = 16) ===\n")

# A. Matriz de correlaciones
cor_cars <- cor(X_cars)
guardar_tabla(round(cor_cars, 4), "cars93_matriz_correlacion")

# B. VIF por definición y car::vif
vif_def_cars <- diag(solve(cor_cars))
mod_cars <- lm(MPG.city ~ ., data = cars93_comp)
vif_car_cars <- car::vif(mod_cars)
dif_vif_cars <- max(abs(vif_def_cars - vif_car_cars))

tabla_vif_cars <- data.frame(
  Variable = names(vif_def_cars),
  VIF_definicion = round(vif_def_cars, 2),
  VIF_car = round(vif_car_cars, 2),
  Diferencia = format(abs(vif_def_cars - vif_car_cars), scientific = TRUE)
)
cat("\n--- VIF en Cars93 (Top 6 predictores con mayor VIF) ---\n")
print(head(tabla_vif_cars[order(-tabla_vif_cars$VIF_definicion), ], 6))
cat(sprintf("Diferencia máxima entre definición y car::vif en Cars93: %e\n", dif_vif_cars))
guardar_tabla(tabla_vif_cars, "cars93_vif_comparacion")

# C. Autovalores e Índices de Condición (Correlación)
eigen_cor_cars <- eigen(cor_cars)$values
indices_cor_cars <- sqrt(max(eigen_cor_cars) / eigen_cor_cars)
num_cond_cor_cars <- max(indices_cor_cars)

cat(sprintf("\nNúmero de condición en Cars93 (matriz correlación): %.3f\n", num_cond_cor_cars))

# D. BKW con intercepto en Cars93
X_bkw_cars <- cbind(Intercept = 1, X_cars)
X_bkw_scaled_cars <- apply(X_bkw_cars, 2, function(col) col / sqrt(sum(col^2)))
svd_cars <- svd(X_bkw_scaled_cars)
sing_vals_cars <- svd_cars$d
cond_indices_bkw_cars <- max(sing_vals_cars) / sing_vals_cars
num_cond_bkw_cars <- max(cond_indices_bkw_cars)

cat(sprintf("Número de condición BKW en Cars93 (con intercepto, escalado unitario): %.3f\n", num_cond_bkw_cars))

# Tabla comparativa de diagnósticos de colinealidad (Hald vs Cars93)
tabla_diagnostico_global <- data.frame(
  Dataset = c("Hald", "Cars93"),
  n = c(n_hald, n_cars),
  p = c(p_hald, p_cars),
  Num_Cond_Correlacion = round(c(num_cond_cor_hald, num_cond_cor_cars), 2),
  Num_Cond_BKW = round(c(num_cond_bkw_hald, num_cond_bkw_cars), 2),
  VIF_Maximo = round(c(max(vif_def_hald), max(vif_def_cars)), 2),
  VIF_Mayor_10 = c(sum(vif_def_hald > 10), sum(vif_def_cars > 10)),
  Correlacion_Maxima = round(c(max(abs(cor_hald[lower.tri(cor_hald)])), 
                               max(abs(cor_cars[lower.tri(cor_cars)]))), 4)
)
cat("\n--- Tabla Comparativa General de Colinealidad ---\n")
print(tabla_diagnostico_global)
guardar_tabla(tabla_diagnostico_global, "diagnostico_colinealidad_comparativo")
