# Laboratorio MEA: Colinealidad, Selección y Regularización

**Curso:** Modelos Estadísticos Activos — Ingeniería en Estadística, UCM  
**Profesor:** Dr. José Miguel Zúñiga Núñez

## Integrantes

| Rol | Integrante |
|---|---|
| Est. A (Modelación y selección) | Diego Espinoza |
| Est. B (Diagnóstico y validación) | Sebastián Osses |
| Experto/a (Dominio y calidad del dato) | Tomás Anabalón |
| Informático/a (Reproducibilidad y flujo) | Bastián Vera |

## Descripción

Laboratorio sobre diagnóstico de multicolinealidad, selección de variables (subconjuntos, stepwise, AIC/BIC) y regularización (Ridge, Lasso, Elastic Net) aplicado a los conjuntos de datos **Hald**, **Cars93** y **BostonHousing**.

## Ejecución

```bash
# Requisito: R con los paquetes listados abajo, y Quarto instalado
Rscript ejecutor.R && quarto render informe/informe.qmd
```

El ejecutor procesa `analysis.R` bloque a bloque (`#@ nombre`) y genera:
- `code/<nombre>.R` — código de cada bloque
- `out/<nombre>.txt` — salida real de R (incluidas advertencias)
- `fig/` — figuras guardadas por los bloques `fig_*`

El informe Quarto lee `out/` y `fig/` para compilar el PDF final.

## Paquetes requeridos

```r
install.packages(c("glmnet", "car", "leaps", "MASS", "mctest", "mlbench", "pls"))
```

## Estructura del repositorio

```
├── README.md              # Este archivo
├── .gitignore
├── data/                  # Datos descomprimidos de datos.tgz (sin edición manual)
├── analysis.R             # Script maestro con bloques #@ por ejercicio
├── ejecutor.R             # Ejecutor de bloques (run_chunks)
├── informe/informe.qmd    # Informe Quarto (lee out/ y fig/)
├── bitacora/bitacora.md   # Entradas POE (predicción-observación-explicación)
├── lecturas/L*.md         # Fichas de lectura de textos clásicos
└── contribuciones.md      # Registro de contribuciones por integrante y fase
```

## Datos

Los datos están incluidos en `data/` para garantizar la reproducibilidad del proyecto. Provienen de `datos.tgz` proporcionado por el profesor.

## Fechas

| Hito | Fecha |
|---|---|
| Entrega del informe | *Por confirmar* |
| Defensa oral | *Por confirmar* |

## Herramientas de apoyo

*Declarar aquí las herramientas utilizadas (asistentes de código, redacción, etc.) y qué se verificó de forma independiente.*
