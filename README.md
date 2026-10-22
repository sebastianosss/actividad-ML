# Laboratorio MEA: Colinealidad, Selección y Regularización

**Curso:** Modelos Estadísticos Activos — Ingeniería en Estadística, Universidad Católica del Maule (UCM)  
**Profesor:** Dr. José Miguel Zúñiga Núñez  
**Versión de R requerida:** R versión 4.5.1 (2025-06-13 ucrt) o superior  

## 1. Propósito del repositorio

Este repositorio contiene la infraestructura de código, análisis reproducible, bitácora y documentación para el Laboratorio de Modelos Estadísticos Activos enfocado en:
- Diagnóstico de multicolinealidad (VIF, índices y número de condición, descomposición de varianzas BKW).
- Selección de variables (subconjuntos exhaustivos, stepwise forward/backward, AIC, BIC, Cp de Mallows).
- Regularización (Ridge regression, Lasso, Elastic Net, validación cruzada y estabilidad por remuestreo).
- Validez e inferencia post-selección (residuos, apalancamiento, distancia de Cook, DFFITS, DFBETAS).

Los análisis se desarrollan sobre tres conjuntos de datos principales:
1. **Hald** (`mctest`, $n = 13$, $p = 4$ predictores): calor de endurecimiento de cemento Portland.
2. **Cars93** (`MASS`, $n = 82$ casos completos en 17 columnas de interés, 16 predictores): eficiencia de combustible (`MPG.city`).
3. **BostonHousing** (`mlbench`, $n = 506$, 13 predictores): valor mediano de viviendas (`medv`).

---

## 2. Integrantes y roles

| Rol | Integrante | Responsabilidad principal |
|---|---|---|
| Est. A | Diego Espinoza | Modelación y selección de variables (Ej. 4, 5a, 6, 7, 9) |
| Est. B | Sebastián Osses | Diagnóstico de colinealidad y validación / sensibilidad |
| Experto/a | Tomás Anabalón | Calidad de datos, plausibilidad en el dominio e interpretación |
| Informático/a | Bastián Vera | Reproducibilidad, arquitectura del entorno, ejecutor y control de versiones |

---

## 3. Comando de ejecución

```bash
Rscript ejecutor.R && quarto render informe/informe.qmd
```

### Requisitos de entorno y ejecución:
- **Variable de entorno PATH:** Para ejecutar el comando anterior directamente desde la terminal o PowerShell, el directorio de binarios de R (por ejemplo, `C:\Program Files\R\R-4.5.1\bin`) debe estar incluido en la variable de entorno `PATH` del usuario o sistema.
- **Advertencias de compilación:** Las advertencias del tipo `package '...' was built under R version 4.5.x` que puedan aparecer en la salida de `ejecutor.R` son netamente informativas (indican que el binario del paquete fue generado bajo una subversión menor más reciente de R) y no representan errores de ejecución ni afectan la exactitud numérica de los cálculos.

---

## 4. Entorno de R y paquetes requeridos

### Versión de R (verificada con `sessionInfo()`):
- **R:** `4.5.1 (2025-06-13 ucrt)`
- **Plataforma:** `x86_64-w64-mingw32/x64 (Windows 11 x64)`

### Instalación de paquetes:

```r
install.packages(c("glmnet", "car", "leaps", "MASS", "mctest", "mlbench", "pls"))
```

### Versiones exactas adjuntas (`sessionInfo()` en `00_entorno`):
- `glmnet`: 5.1 (dependencia: `Matrix` 1.7-3, `foreach` 1.5.2, `iterators` 1.0.14, `shape` 1.4.6.1)
- `car`: 3.1-5 (dependencia: `carData` 3.0-5, `abind` 1.4-8, `Formula` 1.2-5)
- `leaps`: 3.2
- `MASS`: 7.3-65
- `mctest`: 1.3.2
- `mlbench`: 2.1-11
- `pls`: 2.9-0

---

## 5. Convención técnica sobre Hald (mctest)

En el paquete `mctest`, el conjunto de datos `Hald` es provisto como un objeto de clase `matrix array` ($13 \times 5$). Para ser utilizado en modelos lineales ajustados mediante fórmulas (`lm(y ~ ., data = ...)`) y para el cálculo de factores de inflación de varianza con `car::vif()`, es obligatorio convertirlo previamente a data frame mediante `as.data.frame(Hald)`. Las funciones auxiliares en `R/utils.R` (`verificar_datos()`) contemplan internamente esta conversión para asegurar compatibilidad universal entre matrices y data frames.

---

## 6. Estructura de carpetas

```
actividad-ML/
├── README.md              # Propósito, ejecución, estructura y listado de datos
├── AGENTS.md              # Reglas de proceso, convenciones técnicas, estado y penalizaciones
├── USO_HERRAMIENTAS.md    # Registro obligatorio de interacción con herramientas de apoyo
├── plan_trabajo_MEA.md    # Plan de fases detallado del laboratorio
├── .gitignore             # Archivos de entorno y sesión de R (.Rhistory, .RData, etc.)
├── ejecutor.R             # Script que ejecuta los bloques de analysis/
├── data/                  # Conjuntos de datos descomprimidos de datos.tgz (inmutables)
├── analysis/              # Scripts modulares con bloques #@ (leídos alfabéticamente)
│   ├── 00_entorno.R       # Bloque inicial de verificación de paquetes y datos
│   └── 01_prueba_utils.R  # Prueba de funciones utilitarias con datos simulados
├── R/                     # Funciones auxiliares y utilitarias del proyecto
│   └── utils.R            # verificar_datos(), verificar_lambda(), guardar_tabla()
├── code/                  # Código R extraído por cada bloque (generado por ejecutor.R)
├── out/                   # Salidas textuales reales generadas por ejecutor.R
│   └── tablas/            # Tablas CSV exportadas con guardar_tabla()
├── fig/                   # Figuras generadas (PNG/PDF)
├── informe/               # Documento maestro Quarto y bibliografía
│   └── informe.qmd        # Informe reproducible
├── bitacora/              # Bitácora POE (Predicción - Observación - Explicación)
│   └── bitacora.md        # Entradas POE con commit previo obligatorio
├── lecturas/              # Fichas de lectura de textos clásicos (L1 a L4)
│   ├── L1.md              # Belsley, Kuh y Welsch (1980) - Diagnóstico
│   ├── L2.md              # Hoerl y Kennard (1970) - Ridge
│   ├── L3.md              # Tibshirani (1996) - Lasso
│   └── L4.md              # Zou y Hastie (2005) - Elastic Net
└── contribuciones.md      # Registro de aportes por integrante y fase
```

---

## 7. Convenciones técnicas (Sección 3 de AGENTS.md)

1. **Ejecución estándar:** `Rscript ejecutor.R && quarto render informe/informe.qmd`. Comprobación final en una sesión nueva de R.
2. **Extracción y registro:** El ejecutor lee los bloques `#@ nombre`, guarda el código en `code/` y la salida en `out/`, incluyendo advertencias.
3. **Generación de figuras:** Cada bloque que grafica guarda directamente en `fig/` con `png()`, `cairo_pdf()` o `ggsave()`.
4. **Semillas aleatorias:** Declarar explícitamente `set.seed()` en cada bloque que contenga aleatoriedad o remuestreo.
5. **Bloque inicial:** El primer bloque debe contener `sessionInfo()`, versiones de paquetes, dimensiones y conteo de NA de cada conjunto de datos.
6. **Rutas relativas:** Todo acceso a archivos en código y documentación emplea rutas relativas a la raíz del repositorio.
7. **Comparabilidad en Cars93:** Utilizar un único data frame de casos completos, con $n$ declarado ($n = 82$), para todos los modelos que se comparen por AIC o BIC.
8. **Criterios de selección paso a paso:** `step()` utiliza AIC ($k = 2$); `stepAIC(k = log(n))` utiliza BIC. El criterio debe declararse en cada tabla comparativa.
9. **Estandarización en regularización:** Los predictores se estandarizan con `scale()` antes de penalizar cuando se utiliza `standardize = FALSE`.
10. **Validación fuera de muestra:** Estandarizar con la media y desviación del conjunto de entrenamiento; seleccionar $\lambda$ dentro del entrenamiento; repetir la selección por BIC dentro de cada partición (evitar fuga de información).
11. **Pliegues idénticos:** Usar los mismos pliegues (`foldid`) en todos los métodos comparados por validación cruzada.
12. **Bordes de rejilla en glmnet:** Con `cv.glmnet`, verificar que $\lambda_{\min}$ no coincida con el borde inferior de la rejilla. Con $n_{\text{folds}} = n$ (LOOCV en Hald), documentar cualquier advertencia emitida.
13. **Umbrales de diagnóstico e influencia:** Declarar en el informe los umbrales formales ($p$ = número de parámetros, incluido el intercepto):
    - Apalancamiento: $h_{ii} > \frac{2p}{n}$
    - Distancia de Cook: $D_i > \frac{4}{n}$
    - DFFITS: $|\text{DFFITS}_i| > 2\sqrt{\frac{p}{n}}$
    - DFBETAS: $|\text{DFBETAS}_{ij}| > \frac{2}{\sqrt{n}}$
14. **Inferencia post-selección:** Los valores $p$ e intervalos de confianza de modelos seleccionados mediante los mismos datos deben acompañarse de la advertencia formal sobre la pérdida de validez distribucional nominal.
15. **Número de condición:** Declarar la convención adoptada (con/sin constante, con/sin centrado, escalamiento) y documentar el resultado bajo cada variante.

---

## 8. Archivos en `data/`

Los datos se obtuvieron descomprimiendo `datos.tgz` en `data/`. El archivo comprimido contiene exactamente **115 archivos** (13 en `Code/Data/`, 39 en `Data/`, y 63 en `ProblemsAndSolutions/`), los cuales coinciden de forma exacta con los 115 archivos verificados en disco dentro de `data/` y se encuentran bajo control de versiones para asegurar reproducibilidad total.

### `data/Code/Data/` (13 archivos)
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

### `data/Data/` (39 archivos)
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

### `data/ProblemsAndSolutions/` (63 archivos)
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
