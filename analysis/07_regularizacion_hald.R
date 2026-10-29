#@ 07_regularizacion_hald
source("R/utils.R")
library(glmnet)
library(mctest)

cat("=== EJERCICIO 9: REGULARIZACIÓN EN HALD (RIDGE, LASSO, ELASTIC NET) ===\n\n")

data(Hald)
hald_df <- as.data.frame(Hald)
X_raw <- as.matrix(hald_df[, c("X1", "X2", "X3", "X4")])
y <- hald_df$y
n <- nrow(X_raw)

# 1. Estandarización previa de predictores (Convención técnica 9)
X_std <- scale(X_raw)
attr(X_std, "scaled:center") <- NULL
attr(X_std, "scaled:scale") <- NULL

# 2. Ajustes glmnet con alpha in {0, 0.5, 1}
set.seed(123)
fit_ridge <- glmnet(X_std, y, alpha = 0, standardize = FALSE)
fit_enet  <- glmnet(X_std, y, alpha = 0.5, standardize = FALSE)
fit_lasso <- glmnet(X_std, y, alpha = 1, standardize = FALSE)

# 3. Validación cruzada LOOCV (nfolds = n = 13)
# Nota: cv.glmnet con nfolds = n emite advertencia sobre agrupamiento en n pequeno
set.seed(123)
cv_ridge <- cv.glmnet(X_std, y, alpha = 0, nfolds = n, standardize = FALSE, grouped = FALSE)
set.seed(123)
cv_enet  <- cv.glmnet(X_std, y, alpha = 0.5, nfolds = n, standardize = FALSE, grouped = FALSE)
set.seed(123)
cv_lasso <- cv.glmnet(X_std, y, alpha = 1, nfolds = n, standardize = FALSE, grouped = FALSE)

cat("--- Verificación de bordes de rejilla (verificar_lambda) ---\n")
cat("Ridge (alpha = 0): "); verificar_lambda(cv_ridge)
cat("Elastic Net (alpha = 0.5): "); verificar_lambda(cv_enet)
cat("Lasso (alpha = 1): "); verificar_lambda(cv_lasso)

# 4. Tabla comparativa de coeficientes (MCO vs Penalizados)
# Coeficientes en escala estandarizada
mod_mco_std <- lm(y ~ X_std)
coef_mco <- coef(mod_mco_std)[-1]

coef_ridge_min <- as.vector(coef(cv_ridge, s = "lambda.min"))[-1]
coef_enet_min  <- as.vector(coef(cv_enet,  s = "lambda.min"))[-1]
coef_lasso_min <- as.vector(coef(cv_lasso, s = "lambda.min"))[-1]

coef_ridge_1se <- as.vector(coef(cv_ridge, s = "lambda.1se"))[-1]
coef_enet_1se  <- as.vector(coef(cv_enet,  s = "lambda.1se"))[-1]
coef_lasso_1se <- as.vector(coef(cv_lasso, s = "lambda.1se"))[-1]

tabla_coef_hald <- data.frame(
  Predictor = colnames(X_raw),
  MCO_Std = round(coef_mco, 4),
  Ridge_min = round(coef_ridge_min, 4),
  Ridge_1se = round(coef_ridge_1se, 4),
  Enet_min = round(coef_enet_min, 4),
  Enet_1se = round(coef_enet_1se, 4),
  Lasso_min = round(coef_lasso_min, 4),
  Lasso_1se = round(coef_lasso_1se, 4)
)
cat("\n--- Comparación de Coeficientes Estandarizados en Hald ---\n")
print(tabla_coef_hald)
guardar_tabla(tabla_coef_hald, "hald_comparativa_regularizacion")

# 5. Gráficos de trazas de regularización y curvas de validación cruzada
png("fig/hald_trazas_regularizacion.png", width = 1200, height = 450, res = 130)
par(mfrow = c(1, 3), mar = c(4.5, 4.5, 3, 1))
plot(fit_ridge, xvar = "lambda", label = TRUE, main = "Ridge (alpha = 0)")
plot(fit_enet,  xvar = "lambda", label = TRUE, main = "Elastic Net (alpha = 0.5)")
plot(fit_lasso, xvar = "lambda", label = TRUE, main = "Lasso (alpha = 1)")
dev.off()

png("fig/hald_cv_regularizacion.png", width = 1200, height = 450, res = 130)
par(mfrow = c(1, 3), mar = c(4.5, 4.5, 3, 1))
plot(cv_ridge, main = "CV Ridge (alpha = 0)")
plot(cv_enet,  main = "CV Elastic Net (alpha = 0.5)")
plot(cv_lasso, main = "CV Lasso (alpha = 1)")
dev.off()

# 6. Estabilidad de la selección por remuestreo (Bootstrap, B = 500)
set.seed(123)
B <- 500
sel_lasso <- matrix(0, nrow = B, ncol = 4)
sel_enet  <- matrix(0, nrow = B, ncol = 4)
colnames(sel_lasso) <- colnames(sel_enet) <- colnames(X_raw)

for(b in 1:B) {
  idx <- sample(1:n, replace = TRUE)
  X_b <- X_std[idx, ]
  y_b <- y[idx]
  
  fit_l <- glmnet(X_b, y_b, alpha = 1, lambda = cv_lasso$lambda.1se, standardize = FALSE)
  fit_e <- glmnet(X_b, y_b, alpha = 0.5, lambda = cv_enet$lambda.1se, standardize = FALSE)
  
  sel_lasso[b, ] <- as.numeric(as.vector(coef(fit_l))[-1] != 0)
  sel_enet[b, ]  <- as.numeric(as.vector(coef(fit_e))[-1] != 0)
}

tabla_estabilidad <- data.frame(
  Predictor = colnames(X_raw),
  Prop_Lasso_1se = round(colMeans(sel_lasso), 3),
  Prop_Enet_1se  = round(colMeans(sel_enet), 3)
)
cat("\n--- Estabilidad de Selección por Remuestreo (B = 500) en Hald ---\n")
print(tabla_estabilidad)
guardar_tabla(tabla_estabilidad, "hald_estabilidad_remuestreo")

