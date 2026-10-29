# Bitácora POE (Predicción – Observación – Explicación)

**Proyecto:** Laboratorio MEA — Colinealidad, Selección y Regularización  
**Regla R2:** Cada predicción se registra con un commit **antes** de ejecutar el código. No se edita; se abre una entrada nueva.

**Mínimo requerido:** 10 entradas totales; mínimo 2 por cada fase F2 a F5.

---

## Contador de entradas

| Fase | Entradas registradas (pre-ejecución) | Mínimo |
|------|---------------------------------------|--------|
| F2 (Diagnóstico) | 2 | 2 |
| F3 (Selección) | 3 | 2 |
| F4 (Regularización) | 3 | 2 |
| F5 (Validez) | 2 | 2 |
| **Total** | **10** | **10** |

---

## Entradas

### Fase F2 — Diagnóstico de colinealidad

| Id | Predicción y razonamiento (antes de ejecutar) | Hora y autor/a | Observación (cifra, tabla o figura) | ¿Coincide? | Causa de la discrepancia y comprobación adicional |
|---|---|---|---|---|---|
| F2-1 | En el dataset Hald, dado que los 4 predictores son proporciones químicas de una mezcla que suma casi el 100% ($\sum X_j \approx 100$), predecimos fuerte correlación negativa entre $X_2$ y $X_4$ ($|r| > 0.90$) y entre $X_1$ y $X_3$. Debido a esta casi dependencia lineal exacta, al menos 3 o los 4 predictores tendrán VIF > 10 en el modelo completo. | 2026-10-28 22:55 Diego Espinoza (Est. A) / Equipo | | | |
| F2-2 | Predecimos que el número de condición ($\kappa$ o $\eta_{\max}$) será mayor en Cars93 ($n=82, p=16$) que en Hald ($n=13, p=4$). Razonamiento: Cars93 incluye 16 variables con redundancias mecánicas simultáneas (`Price`, `Min.Price`, `Max.Price`, dimensiones físicas y motor) que generan múltiples autovalores cercanos a cero, elevando la dispersión del espectro de autovalores respecto a los 4 predictores de Hald. | 2026-10-28 22:56 Diego Espinoza (Est. A) / Equipo | | | |

### Fase F3 — Selección de variables

| Id | Predicción y razonamiento (antes de ejecutar) | Hora y autor/a | Observación (cifra, tabla o figura) | ¿Coincide? | Causa de la discrepancia y comprobación adicional |
|---|---|---|---|---|---|
| F3-1 | En Hald, predecimos que $R^2_{\text{adj}}$ y $C_p$ de Mallows seleccionarán un modelo de mayor dimensión (posiblemente de 3 predictores, ej. $X_1, X_2, X_4$), mientras que $BIC$ seleccionará un modelo más parsimonioso de 2 predictores ($X_1, X_2$). Orden de parsimonia esperado: $BIC > C_p \ge R^2_{\text{adj}}$, ya que la penalización por parámetro en $BIC$ es $\log(13) \approx 2.565 > 2$, mientras que $C_p$ y $AIC$ penalizan con constante 2 y $R^2_{\text{adj}}$ con $2/(n-p-1)$. | 2026-10-28 22:58 Diego Espinoza (Est. A) | Tabla `out/tablas/hald_mejores_subconjuntos.csv`: $R^2_{\text{adj}}$ maximo elige 3 predictores ($X_1, X_2, X_4$, $R^2_{\text{adj}} = 0.9764$). $C_p$ minimo elige 2 predictores ($X_1, X_2$, $C_p = 2.678$). $BIC$ minimo elige 2 predictores ($X_1, X_2$, $BIC = -42.330$). En stepwise: AIC elige 3 variables ($X_1, X_2, X_4$, AIC = 63.87); BIC elige 2 variables ($X_1, X_2$, BIC = 66.57). | Parcialmente | Coincidió en que $BIC$ es el más parsimonioso (2 predictores) y $R^2_{\text{adj}}$ retiene 3. Sin embargo, $C_p$ mínimo seleccionó el modelo de 2 ($C_p = 2.678$), aunque el de 3 tiene $C_p = 3.018 \approx p$, por lo que ambos son casi equivalentes bajo $C_p$. Causa: con $n=13$, la SSE baja de 57.90 a 47.97 al agregar $X_4$, ganancia marginal similar a la penalización $2\hat{\sigma}^2$. |
| F3-2 | En Cars93 ($n = 82$, 16 predictores), predecimos que `stepAIC` con penalización $BIC$ ($k = \log(82) \approx 4.407$) partiendo del modelo completo NO coincidirá de forma idéntica con el modelo óptimo global obtenido mediante búsqueda exhaustiva con $C_p$. Razonamiento: los métodos paso a paso son algoritmos locales voraces (*greedy*) que no garantizan el óptimo global ante colinealidad, y además $BIC$ penaliza con $k = 4.41$, forzando un modelo con menos variables que $C_p$ (que usa implícitamente $k=2$). | 2026-10-28 23:00 Diego Espinoza (Est. A) | Tabla `out/tablas/cars93_comparativa_modelos.csv`: `stepAIC` con BIC selecciona 9 predictores (`Min.Price, Price, Max.Price, EngineSize, RPM, Rev.per.mile, Fuel.tank.capacity, Wheelbase, Weight`, BIC = 436.84). Búsqueda exhaustiva con $C_p$ (`regsubsets`) selecciona 10 predictores (los 9 anteriores más `Passengers`, $C_p = 8.651$, AIC = 408.93). `stepAIC` con AIC recupera exactamente el mismo modelo de 10 variables de $C_p$. | Sí | Se verificó que el modelo por BIC es estrictamente más parsimonioso (9 variables frente a 10 de $C_p$). Causa: $BIC$ penaliza con $k = 4.407$, descartando `Passengers` ($p \approx 0.052$), mientras que $C_p$ ($k=2$) la retiene. El algoritmo stepwise coincidió con la búsqueda exhaustiva para cada tamaño gracias a la consistencia secuencial de los predictores dominantes. |
| F3-3 | Predecimos que todos los modelos seleccionados por criterios parsimoniosos ($BIC$, $C_p$) tanto en Hald como en Cars93 reducirán sustancialmente los VIFs respecto al modelo saturado, logrando que los predictores retenidos presenten VIF < 10 (e idealmente VIF < 5). Razonamiento: la penalización descarta variables fuertemente redundantes que apenas aportan a la suma de cuadrados residual pero inflan la varianza de los estimadores. | 2026-10-28 23:02 Diego Espinoza (Est. A) | Tabla `out/tablas/vif_comparativa_seleccion.csv`: En Hald, el modelo BIC ($X_1, X_2$) redujo los VIFs de 282.51 a 1.06 (eliminación total de colinealidad). Sin embargo, en Cars93, el modelo BIC retuvo `Min.Price, Price, Max.Price`, resultando en un VIF máximo de 139,295 para `Price` y 5 predictores con VIF > 10. | No (discrepancia clave en Cars93) | Causa: La selección por stepwise AIC/BIC solo optimiza la bondad de ajuste penalizada, pero no detecta dependencias lineales internas si la inclusión conjunta mejora marginalmente la SSE. Dado que `Price` es aproximadamente el promedio de `Min.Price` y `Max.Price`, retener las tres genera colinealidad extrema no resuelta por stepwise. Esto evidencia empíricamente la necesidad indispensable de regularización (Ridge/Elastic Net) en F4. |

### Fase F4 — Regularización

| Id | Predicción y razonamiento (antes de ejecutar) | Hora y autor/a | Observación (cifra, tabla o figura) | ¿Coincide? | Causa de la discrepancia y comprobación adicional |
|---|---|---|---|---|---|
| F4-1 | En Hald ($n=13$), predecimos que en Lasso ($\alpha = 1$) el predictor $X_3$ o $X_4$ será el primero en anularse a medida que $\lambda$ aumenta, y que los coeficientes de $X_2$ y $X_4$ presentarán inestabilidad respecto a MCO debido a su colinealidad de $r = -0.973$. En contraste, en Ridge ($\alpha = 0$) ningún coeficiente será exactamente cero para cualquier $\lambda$ finito. | 2026-10-29 11:10 Tomás Anabalón (Experto) / Diego Espinoza (Est. A) | | | |
| F4-2 | Predecimos que Elastic Net ($\alpha = 0.5$) exhibirá el efecto de agrupamiento (*grouping effect*) de Zou & Hastie (2005) sobre el par fuertemente correlacionado ($X_2, X_4$ en Hald y `Min.Price`, `Price`, `Max.Price` en Cars93), manteniendo ambos predictores en el modelo con coeficientes encogidos simultáneamente, a diferencia de Lasso ($\alpha = 1$) que eliminará arbitrariamente uno del par. | 2026-10-29 11:12 Diego Espinoza (Est. A) / Tomás Anabalón | | | |
| F4-3 | En Cars93 ($n=82$, 100 particiones 80/20), predecimos que los métodos regularizados (Ridge y Elastic Net) superarán en RMSE predictivo fuera de muestra a MCO en más del 70% de las particiones. Razonamiento: la severa multicolinealidad de los predictores infla la varianza muestral de MCO, mientras que la penalización $L_2$ reduce el error cuadrático medio mediante el compromiso sesgo-varianza. | 2026-10-29 11:14 Diego Espinoza (Est. A) / Sebastián Osses | | | |

### Fase F5 — Validez de las conclusiones

| Id | Predicción y razonamiento (antes de ejecutar) | Hora y autor/a | Observación (cifra, tabla o figura) | ¿Coincide? | Causa de la discrepancia y comprobación adicional |
|---|---|---|---|---|---|
| F5-1 | En el modelo seleccionado de Cars93, predecimos la presencia de observaciones influyentes ($D_i > 4/n \approx 0.0488$ y $h_{ii} > 2p/n$) asociadas a vehículos atípicos de alta gama, peso o potencia (ej. modelos de lujo o deportivos como Corvette o Cadillac). | 2026-10-29 11:16 Sebastián Osses (Est. B) / Tomás Anabalón | | | |
| F5-2 | Predecimos que al reajustar el modelo excluyendo las observaciones influyentes detectadas por distancia de Cook, los coeficientes de las variables colineales (`Price`, `EngineSize`, `Weight`) sufrirán variaciones sustanciales, evidenciando la inestabilidad de la inferencia clásica cuando no se controla la sensibilidad muestral. | 2026-10-29 11:18 Sebastián Osses (Est. B) / Diego Espinoza | | | |

---

**Requisitos de cada entrada:**
1. La predicción indica una cifra, un orden o una decisión.
2. El razonamiento usa un argumento estadístico.
3. La explicación nombra la causa y propone una prueba para decidir entre hipótesis.
4. Lo observado se distingue de lo inferido y de la regla práctica.
