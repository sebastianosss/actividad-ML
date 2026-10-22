# Imprime dimensiones y NA por columna, valida dimensiones esperadas e informa valores Inf o NaN.
verificar_datos <- function(df, nombre, n_esperado = NULL, p_esperado = NULL) {
  cat(sprintf("=== Verificación de datos: %s ===\n", nombre))
  cat(sprintf("Dimensiones: %d filas x %d columnas\n", nrow(df), ncol(df)))
  
  # Validación de dimensiones esperadas
  if (!is.null(n_esperado) && nrow(df) != n_esperado) {
    stop(sprintf("Error en %s: n observado (%d) != n esperado (%d)", nombre, nrow(df), n_esperado))
  }
  if (!is.null(p_esperado) && ncol(df) != p_esperado) {
    stop(sprintf("Error en %s: p observado (%d) != p esperado (%d)", nombre, ncol(df), p_esperado))
  }
  
  # Conteo de NA por columna
  cat("NA por columna:\n")
  print(colSums(is.na(df)))
  
  # Verificación de Inf y NaN en columnas numéricas
  num_cols <- which(sapply(df, is.numeric))
  if (length(num_cols) > 0) {
    inf_cols <- names(num_cols)[sapply(df[, num_cols, drop = FALSE], function(col) any(is.infinite(col)))]
    nan_cols <- names(num_cols)[sapply(df[, num_cols, drop = FALSE], function(col) any(is.nan(col)))]
    
    if (length(inf_cols) > 0) {
      cat(sprintf("Columnas con valores Inf en %s: %s\n", nombre, paste(inf_cols, collapse = ", ")))
    } else {
      cat(sprintf("Valores Inf en %s: Ninguno detectado\n", nombre))
    }
    
    if (length(nan_cols) > 0) {
      cat(sprintf("Columnas con valores NaN en %s: %s\n", nombre, paste(nan_cols, collapse = ", ")))
    } else {
      cat(sprintf("Valores NaN en %s: Ninguno detectado\n", nombre))
    }
  }
  cat("\n")
}

# Informa si lambda.min coincide con el menor valor de la rejilla de lambda y emite una advertencia.
verificar_lambda <- function(cv_obj) {
  min_grid <- min(cv_obj$lambda)
  en_borde <- isTRUE(all.equal(cv_obj$lambda.min, min_grid)) || (cv_obj$lambda.min <= min_grid)
  
  if (en_borde) {
    msg <- sprintf("Alerta: lambda.min (%g) coincide con el borde inferior de la rejilla (%g).", 
                   cv_obj$lambda.min, min_grid)
    cat(paste(msg, "\n"))
    warning(msg)
  } else {
    cat(sprintf("lambda.min (%g) se encuentra dentro de la rejilla (min: %g, max: %g).\n", 
                cv_obj$lambda.min, min_grid, max(cv_obj$lambda)))
  }
}

# Guarda un data frame o matriz en out/tablas/<nombre>.csv con nombres de fila.
guardar_tabla <- function(df, nombre) {
  dir.create(file.path("out", "tablas"), recursive = TRUE, showWarnings = FALSE)
  ruta <- file.path("out", "tablas", paste0(nombre, ".csv"))
  write.csv(df, file = ruta, row.names = TRUE)
  cat(sprintf("Tabla guardada en: %s\n", ruta))
}
