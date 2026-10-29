# Asegurar ruta de libreria de usuario en Windows si existe
user_lib <- file.path(Sys.getenv("LOCALAPPDATA"), "R", "win-library", paste0(R.version$major, ".", sub("\\..*", "", R.version$minor)))
if (dir.exists(user_lib)) {
  .libPaths(c(user_lib, .libPaths()))
}

