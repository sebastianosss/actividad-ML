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
