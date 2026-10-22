#@ 01_prueba_utils
source("R/utils.R")

# 1. Prueba de guardar_tabla() con un data.frame de 3 filas
cat("--- Prueba de guardar_tabla() ---\n")
df_prueba <- data.frame(
  Metodo = c("MCO", "Ridge", "Lasso"),
  Parametro = c("Ninguno", "lambda = 0.15", "lambda = 0.08"),
  RMSE_simulado = c(3.42, 2.89, 2.75)
)
guardar_tabla(df_prueba, "prueba_utils")

# Verificación de que el archivo fue escrito en disco
ruta_tabla <- file.path("out", "tablas", "prueba_utils.csv")
if (file.exists(ruta_tabla)) {
  cat(sprintf("Archivo verificado en disco: %s (%d bytes)\n", ruta_tabla, file.info(ruta_tabla)$size))
} else {
  stop("Error: No se encontró el archivo out/tablas/prueba_utils.csv")
}

# 2. Prueba de verificar_lambda() con datos simulados y cv.glmnet
cat("\n--- Prueba de verificar_lambda() con datos simulados ---\n")
set.seed(1)
n_sim <- 60
p_sim <- 6
X_sim <- matrix(rnorm(n_sim * p_sim), nrow = n_sim, ncol = p_sim)
colnames(X_sim) <- paste0("X", 1:p_sim)
y_sim <- X_sim[, 1] * 2 - X_sim[, 2] * 1.5 + rnorm(n_sim)

# Ajuste cv.glmnet con semilla y pliegues controlados
cv_sim <- cv.glmnet(X_sim, y_sim, alpha = 1)
verificar_lambda(cv_sim)
