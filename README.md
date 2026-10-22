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

El script `ejecutor.R` lee todos los archivos `.R` dentro del directorio `analysis/` en **orden alfabético estricto** (`sort(list.files("analysis", "\\.R$", full.names = TRUE))`). Cada bloque identificado con la etiqueta `#@ <nombre>` se extrae en `code/<nombre>.R` y su salida se guarda en `out/<nombre>.txt`. Todos los bloques se ejecutan de manera secuencial compartiendo un mismo entorno de R (`env`), lo que permite que los objetos creados en un bloque anterior estén disponibles para los bloques siguientes.

## Paquetes requeridos

```r
install.packages(c("glmnet", "car", "leaps", "MASS", "mctest", "mlbench", "pls"))
```

## Estructura del repositorio

```
├── README.md              # Este archivo
├── .gitignore
├── data/                  # Datos descomprimidos de datos.tgz (sin edición manual)
├── analysis/              # Bloques #@ de análisis modularizados
├── R/                     # Funciones auxiliares y utilitarias
├── ejecutor.R             # Ejecutor de bloques (run_chunks)
├── code/                  # Código extraído por bloque (generado)
├── out/                   # Salida real de ejecución (generado)
│   └── tablas/            # Tablas exportadas en CSV (generado)
├── fig/                   # Figuras generadas
├── informe/informe.qmd    # Informe Quarto (lee out/ y fig/)
├── bitacora/bitacora.md   # Entradas POE (predicción-observación-explicación)
├── lecturas/L*.md         # Fichas de lectura de textos clásicos
└── contribuciones.md      # Registro de contribuciones por integrante y fase
```

## Datos

Los datos provienen del archivo `datos.tgz` del curso y se encuentran en `data/` sin edición manual (Regla 8 de `AGENTS.md`).

### Listado de archivos extraídos en `data/`

#### `data/Code/Data/` (13 archivos)
- `BloodLead.rda`
- `GLOW.RData`
- `OzoneLondon.csv`
- `OzoneNewYork.csv`
- `OzoneWashington.csv`
- `Violent Crime-by state-2010-table-5.xls`
- `Violent Crime-by state-2011-table-5.xls`
- `Violent Crime-by state-2016-table-3.xls`
- `Violent Crime-by state-2017-table-5.xls`
- `Violent Crime-by state-2018-table-5.xls`
- `Violent Crime-by state-2019-table-5.xls`
- `battery.csv`
- `crashseverity2wk.csv`

#### `data/Data/` (39 archivos)
- `Bankdata.csv`
- `GLOW.RData`
- `birds.csv`
- `crabs.csv`
- `crashseverity.csv`
- `deforest.csv`
- `glass.csv`
- `hajardownwind.csv`
- `hajarupwind.csv`
- `hajarupwind1718.csv`
- `oranges.csv`
- `snails.csv`
- `tensile.csv`
- `tnc-3facme.csv`
- `tnc-nested.csv`
- `tnc-re.csv`
- `total-households-town-2019.csv`
- `trees.csv`
- `Data_Exercises/AAPL_returns.csv`
- `Data_Exercises/Arthritis.csv`
- `Data_Exercises/BabyWeights.csv`
- `Data_Exercises/CASP2.csv`
- `Data_Exercises/Cars93.csv`
- `Data_Exercises/Chapter3/WH_allcounty_10 2.csv`
- `Data_Exercises/Chapter3/WH_allcounty_20.csv`
- `Data_Exercises/Chapter3/crashesbymonth.csv`
- `Data_Exercises/Meat.csv`
- `Data_Exercises/O3.RData`
- `Data_Exercises/apple_juice.csv`
- `Data_Exercises/diamonds.csv`
- `Data_Exercises/fishdata.csv`
- `Data_Exercises/frostedflakes.csv`
- `Data_Exercises/haberman.csv`
- `Data_Exercises/islands.csv`
- `Data_Exercises/kchouse.csv`
- `Data_Exercises/mtcars.csv`
- `Data_Exercises/shoes.csv`
- `Data_Exercises/trees.csv`
- `Data_Exercises/ugenrollment_allcounties.csv`

#### `data/ProblemsAndSolutions/` (63 archivos)
- `Ch_1/Ch_1_Sol/Wirebond data.csv`
- `Ch_1/Ch_1_Sol/snails.csv`
- `Ch_2/Ch_2_Sol/AAPL-returns.csv`
- `Ch_2/Ch_2_Sol/OlympicGDP.csv`
- `Ch_2/Ch_2_Sol/WH10.csv`
- `Ch_2/Ch_2_Sol/crabs.csv`
- `Ch_2/Ch_2_Sol/income19.csv`
- `Ch_2/Ch_2_Sol/islands.csv`
- `Ch_2/Ch_2_Sol/laptoprices.csv`
- `Ch_2/Ch_2_Sol/mtcars.csv`
- `Ch_2/Ch_2_Sol/trees.csv`
- `Ch_2/Ch_2_Sol/ugen.csv`
- `Ch_3/Ch_3_Sol/Arthritis.csv`
- `Ch_3/Ch_3_Sol/BabyWeights.csv`
- `Ch_3/Ch_3_Sol/WH10_20.csv`
- `Ch_3/Ch_3_Sol/crashesbymonth.csv`
- `Ch_3/Ch_3_Sol/diamonds.csv`
- `Ch_3/Ch_3_Sol/frostedflakes.csv`
- `Ch_3/Ch_3_Sol/shoes.csv`
- `Ch_3/Ch_3_Sol/ugen.csv`
- `Ch_4/Ch_4_Sol/Dog_Toys.csv`
- `Ch_4/Ch_4_Sol/FoodNutrients.csv`
- `Ch_4/Ch_4_Sol/beans.csv`
- `Ch_4/Ch_4_Sol/coffeebeans.csv`
- `Ch_4/Ch_4_Sol/forestcover.csv`
- `Ch_4/Ch_4_Sol/transport.clean.csv`
- `Ch_4/Ch_4_Sol/transport.csv`
- `Ch_4/Ch_4_Sol/wine.csv`
- `Ch_5/Ch_5_Sol/Fish.csv`
- `Ch_5/Ch_5_Sol/IMHE-Swiss-mortality 3.csv`
- `Ch_5/Ch_5_Sol/bloodiron_obesity.csv`
- `Ch_5/Ch_5_Sol/concrete.csv`
- `Ch_5/Ch_5_Sol/pneumonia.csv`
- `Ch_6/Ch_6_Sol/Glaucoma.csv`
- `Ch_7/Ch_7_Sol/abalone.data.csv`
- `Ch_7/Ch_7_Sol/bicycle.csv`
- `Ch_7/Ch_7_Sol/caesarian.csv`
- `Ch_7/Ch_7_Sol/diabetes.csv`
- `Ch_7/Ch_7_Sol/earinfections.csv`
- `Ch_7/Ch_7_Sol/haberman.csv`
- `Ch_7/Ch_7_Sol/heartfailure.csv`
- `Ch_7/Ch_7_Sol/levee failure.csv`
- `Ch_7/Ch_7_Sol/nbainjuries.csv`
- `Ch_7/Ch_7_Sol/trips.csv`
- `Ch_7/Ch_7_Sol/workstatus-women.csv`
- `Ch_8/Ch_8_Sol/CASP.csv`
- `Ch_8/Ch_8_Sol/RedWineQuality.csv`
- `Ch_8/Ch_8_Sol/caesarian.csv`
- `Ch_8/Ch_8_Sol/churn.csv`
- `Ch_8/Ch_8_Sol/cmc.data.csv`
- `Ch_8/Ch_8_Sol/dermatology.csv`
- `Ch_8/Ch_8_Sol/haberman.csv`
- `Ch_8/Ch_8_Sol/heartfailure.csv`
- `Ch_8/Ch_8_Sol/nursery.data.csv`
- `Ch_8/Ch_8_Sol/postoperative.csv`
- `Ch_8/Ch_8_Sol/seeds.csv`
- `Ch_8/Ch_8_Sol/vehicle.csv`
- `Ch_8/Ch_8_Sol/workstatus-women.csv`
- `Ch_9/Ch_9_Sol/WUR.csv`
- `Ch_9/Ch_9_Sol/driver.csv`
- `Ch_9/Ch_9_Sol/life expectancy.csv`
- `Ch_9/Ch_9_Sol/progabide.csv`
- `Ch_9/Ch_9_Sol/wallaby.csv`

## Fechas

| Hito | Fecha |
|---|---|
| Entrega del informe | *Por confirmar* |
| Defensa oral | *Por confirmar* |

## Herramientas de apoyo

*Declarar aquí las herramientas utilizadas (asistentes de código, redacción, etc.) y qué se verificó de forma independiente.*
