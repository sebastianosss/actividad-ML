# Ejecuta los scripts en analysis/*.R en orden alfabetico por bloques "#@ nombre".
# Escribe code/<nombre>.R (código) y out/<nombre>.txt (salida real de R, incluidas advertencias).
dir.create("code", showWarnings = FALSE); dir.create("out", showWarnings = FALSE)
dir.create("fig",  showWarnings = FALSE)
dir.create(file.path("out", "tablas"), showWarnings = FALSE, recursive = TRUE)

lines <- unlist(lapply(sort(list.files("analysis", "\\.R$", full.names = TRUE)), readLines, encoding = "UTF-8"))
idx    <- grep("^#@ ", lines)
nombre <- sub("^#@ ", "", lines[idx])
ini    <- idx + 1
fin    <- c(idx[-1] - 1, length(lines))

trim <- function(x) {
  while (length(x) && !nzchar(trimws(x[1])))        x <- x[-1]
  while (length(x) && !nzchar(trimws(x[length(x)]))) x <- x[-length(x)]
  # quitar separadores de sección "# ----"
  x[!grepl("^# -{5,}", x)]
}

env <- new.env(parent = globalenv())   # los bloques no pisan las variables del ejecutor

for (i in seq_along(idx)) {
  cod <- trim(lines[ini[i]:fin[i]])
  writeLines(cod, file.path("code", paste0(nombre[i], ".R")), useBytes = TRUE)
  warns <- character(0)
  salida <- withCallingHandlers(
    capture.output({
      for (e in parse(text = cod, keep.source = FALSE)) {
        res.e <- withVisible(eval(e, env))
        if (res.e$visible) print(res.e$value)
      }
    }),
    warning = function(w) { warns <<- c(warns, conditionMessage(w)); invokeRestart("muffleWarning") }
  )
  if (length(warns)) salida <- c(salida, paste("## Advertencia:", unique(warns)))
  writeLines(salida, file.path("out", paste0(nombre[i], ".txt")), useBytes = TRUE)
  cat(sprintf("[%2d/%d] %-14s %3d líneas de salida%s\n", i, length(idx), nombre[i], length(salida),
              if (length(warns)) "  (con advertencias)" else ""))
}
