source("R/utils.R")

# Carga de paquetes requeridos para el laboratorio
library(glmnet)
library(car)
library(leaps)
library(MASS)
library(mctest)
library(mlbench)
library(pls)

# Información de sesión y versiones
sessionInfo()

# Verificación e inspección de datasets en mctest
info_mctest <- data(package = "mctest")$results
cat("Conjuntos de datos en mctest:\n")
print(info_mctest[, c("Item", "Title"), drop = FALSE])

# Carga de Hald
data(Hald)
cat("\nEstructura y columnas de Hald:\n")
cat("Nombre del objeto: Hald\n")
cat("Clase:", class(Hald), "\n")
cat("Columnas:", paste(colnames(Hald), collapse = ", "), "\n")
verificar_datos(Hald, "Hald", n_esperado = nrow(Hald), p_esperado = ncol(Hald))

# Carga y verificación de Cars93 (MASS)
data(Cars93)
verificar_datos(Cars93, "Cars93", n_esperado = nrow(Cars93), p_esperado = ncol(Cars93))

# Conteo de NA en las 17 columnas de interés para Cars93
cols_cars93 <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", 
                 "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity", 
                 "Passengers", "Length", "Wheelbase", "Width", "Turn.circle", 
                 "Rear.seat.room", "Luggage.room", "Weight")
cars93_sub <- Cars93[, cols_cars93]
na_filas_cars93 <- sum(!complete.cases(cars93_sub))
cat(sprintf("Cars93: %d filas con algún NA en las 17 columnas de interés (de %d filas totales). Casos completos: %d.\n\n",
            na_filas_cars93, nrow(cars93_sub), sum(complete.cases(cars93_sub))))

# Carga y verificación de BostonHousing (mlbench)
data(BostonHousing)
verificar_datos(BostonHousing, "BostonHousing", n_esperado = nrow(BostonHousing), p_esperado = ncol(BostonHousing))

# Carga y verificación de bases de desafío opcionales (Ravishanker et al. 2026)
# 1. Deforestación
ruta_deforest <- "data/Data/deforest.csv"
if (file.exists(ruta_deforest)) {
  deforest_raw <- read.csv(ruta_deforest)
  deforest_df <- deforest_raw[, !(names(deforest_raw) %in% c("id", "code", "ename"))]
  verificar_datos(deforest_df, "Deforestación", n_esperado = 405, p_esperado = 18)
} else {
  deforest_df <- NULL
}

# 2. Glaucoma
ruta_glaucoma <- "data/ProblemsAndSolutions/Ch_6/Ch_6_Sol/Glaucoma.csv"
if (file.exists(ruta_glaucoma)) {
  glaucoma_raw <- read.csv(ruta_glaucoma)
  glaucoma_df <- glaucoma_raw[, -1]
  verificar_datos(glaucoma_df, "Glaucoma", n_esperado = 800, p_esperado = 498)
} else {
  glaucoma_df <- NULL
}

# Tabla resumen general de conjuntos de datos (Regla 9: cifras para el informe)
resumen_datasets <- data.frame(
  Dataset = c("Hald", "Cars93", "BostonHousing", "Deforestacion", "Glaucoma"),
  Fuente = c("mctest (Hald 1952)", "MASS (1993)", "mlbench (1978)", 
             "Ravishanker et al. (2026)", "Ravishanker et al. (2026)"),
  n_total = c(nrow(Hald), nrow(Cars93), nrow(BostonHousing), 
              if(!is.null(deforest_df)) nrow(deforest_df) else 405, 
              if(!is.null(glaucoma_df)) nrow(glaucoma_df) else 800),
  n_completo = c(nrow(Hald), sum(complete.cases(cars93_sub)), nrow(BostonHousing), 
                 if(!is.null(deforest_df)) sum(complete.cases(deforest_df)) else 405, 
                 if(!is.null(glaucoma_df)) sum(complete.cases(glaucoma_df)) else 800),
  p_predictores = c(4, 16, 13, 17, 497),
  Respuesta = c("y (calor cal/g)", "MPG.city (mpg)", "medv (miles USD)", "fcover (%)", "y (binaria: GLC vs AMD)"),
  NA_total = c(sum(is.na(Hald)), na_filas_cars93, sum(is.na(BostonHousing)), 
               if(!is.null(deforest_df)) sum(is.na(deforest_df)) else 0, 
               if(!is.null(glaucoma_df)) sum(is.na(glaucoma_df)) else 0),
  stringsAsFactors = FALSE
)
guardar_tabla(resumen_datasets, "resumen_datasets")
cat("\n=== Resumen consolidado de datasets ===\n")
print(resumen_datasets)
