# Plan de trabajo: Laboratorio MEA (colinealidad, selección y regularización)

Curso: Modelos Estadísticos Activos, Ingeniería en Estadística, UCM.
Fuente: guía de la actividad (Parte I y Parte II) y diapositivas de la sesión (52 diapositivas).

Uso del documento: cada fase tiene tareas por rol y una lista de verificación. Una fase se cierra cuando todas sus casillas están marcadas y el registro de la sección 9 está actualizado.

---

## 0. Datos del equipo

| Campo | Valor |
|---|---|
| Integrante y rol: Est. A | |
| Integrante y rol: Est. B | |
| Integrante y rol: Experto/a | |
| Integrante y rol: Informático/a | |
| Canal de comunicación | |
| Horarios de trabajo | |
| Regla de desacuerdo | |
| Fecha de entrega del informe | |
| Fecha de defensa | |

Contrato de equipo (5 min en F1): canal, horarios y regla de desacuerdo. La decisión estadística corresponde al rol responsable; toda objeción se anota en la bitácora.

### Decisiones metodológicas acordadas (F1)

| Decisión | Valor | Fecha | Responsable |
|---|---|---|---|
| Tratamiento de casos incompletos de Cars93 | Usar un único data.frame de casos completos (n = 82) sobre las 17 variables de interés (excluyendo las 11 filas con NA en Rear.seat.room y Luggage.room) para garantizar comparabilidad exacta en AIC/BIC | 2026-10-22 | Tomás Anabalón / Sebastián Osses |
| `MPG.highway` como predictor | Excluido del conjunto principal de 16 predictores de MPG.city por redundancia mecánica directa; se reserva para análisis de sensibilidad | 2026-10-22 | Tomás Anabalón / Diego Espinoza |
| Convención del número de condición | Reportar y comparar explícitamente ambas convenciones en F2: (i) sobre matriz de correlación / predictores centrados y escalados sin intercepto, y (ii) sobre matriz de diseño con intercepto y columnas escaladas a longitud unitaria según Belsley, Kuh y Welsch (1980) | 2026-10-22 | Sebastián Osses |
| Esquema de remuestreo para estabilidad en Hald | En cv.glmnet usar validación cruzada dejando uno fuera (LOOCV, nfolds = 13) documentando advertencias numéricas, y evaluar estabilidad de selección mediante remuestreo con semilla fija set.seed() | 2026-10-22 | Sebastián Osses / Diego Espinoza |

---

## 1. Entregables

| Id | Entregable | Especificación | Responsable de ensamblar |
|---|---|---|---|
| E1 | Informe técnico | Máximo 8 páginas sin anexos. Estructura: pregunta y datos, diagnóstico, selección, regularización, validez y límites, conclusión, referencias. Cada tabla y figura con leyenda e interpretación. Cada afirmación con etiqueta. | Experto/a |
| E2 | Código reproducible | Un comando regenera tablas, figuras e informe. Semillas, `sessionInfo()`, verificación de dimensiones, NA, dominios y convergencia. | Informático/a |
| E3 | Bitácora POE | Mínimo 10 entradas; mínimo 2 por cada fase F2 a F5. | Todos |
| E4 | Fichas de lectura | Una por texto; mínimo 3, una por familia. | Cada lector |
| E5 | Defensa oral | 8 min de exposición y 4 min de preguntas; participan los cuatro. | Todos |
| E6 | Coevaluación | Formulario individual entregado al docente. | Cada integrante |

Declaración obligatoria al final del informe: herramientas de apoyo utilizadas (incluidos asistentes de código o de redacción) y qué se verificó de forma independiente.

## 2. Distribución del puntaje

| Código | Criterio | Puntos |
|---|---|---|
| C1 | Diagnóstico de colinealidad | 10 |
| C2 | Selección de variables y criterios | 12 |
| C3 | Regularización y validación | 14 |
| C4 | Validez: residuos, influencia e inferencia posterior a la selección | 8 |
| C5 | Bitácora POE | 8 |
| C6 | Literatura clásica | 10 |
| C7 | Reproducibilidad | 10 |
| C8 | Comunicación e interpretación | 8 |
| I1 | Defensa oral individual por rol | 10 |
| I2 | Contribución verificable | 10 |
| D | Bonificación (D1 a D3) | hasta +6 (tope total 100) |

## 3. Reglas que limitan el puntaje

| Regla | Condición | Efecto | Control del equipo |
|---|---|---|---|
| R1 | Referencia inexistente, o datos bibliográficos no consultados presentados como verificados | C6 = 0 | Cada dato bibliográfico se compara con el documento original. Lo no comparado se marca "no verificado". |
| R2 | Predicción de la bitácora editada después de ejecutar | C5 = 0 | Commit de cada predicción antes de ejecutar el código. No se edita; se abre una entrada nueva. |
| R3 | Menos de 3 textos o falta una familia | C6 ≤ 3 | Lecturas: (i) diagnóstico o selección, (ii) ridge, (iii) lasso o elastic net. |
| R4 | El código no se ejecuta en un entorno limpio | C7 ≤ 3 | Prueba en sesión nueva de R antes de entregar. |
| R5 | Ridge, lasso o elastic net sin criterio de λ ni validación fuera de muestra | C3 ≤ 9 | Validación cruzada, `lambda.min`, `lambda.1se` y comparación fuera de muestra. |
| R6 | Valores p o intervalos del modelo seleccionado sin advertencia sobre la selección | C4 ≤ 4 | Párrafo de inferencia posterior a la selección en el informe. |
| R7 | Informe de más de 8 páginas sin anexos | C8: −2 | Conteo de páginas en cada compilación. |

---

## 4. Roles

| Rol | Responsabilidad | Pregunta que formula | Producto propio |
|---|---|---|---|
| Est. A | Modelación y selección (Ej. 4, 5(a), 6, 7, 9) | ¿Qué modelo se estima y qué criterio corresponde al objetivo: predecir o explicar? | Tablas de selección y de regularización con justificación |
| Est. B | Diagnóstico y validación | ¿Qué supuesto puede fallar y cómo se comprueba? | Secciones de diagnóstico y de validez; análisis de sensibilidad |
| Experto/a | Dominio y calidad del dato | ¿Qué es la variable, cómo se midió y el signo es plausible? | Ficha de datos; interpretación en el dominio; mensaje para audiencia no técnica |
| Informático/a | Reproducibilidad y flujo | ¿Otra persona reproduce todo con un comando? | Código, entorno y registro de contribuciones |

Reglas de trabajo:

- En cada fase una persona digita (driver) y otra dirige y verifica (navegante); las otras dos revisan.
- Ningún integrante es driver en dos fases consecutivas. El/la Informático/a digita como máximo dos fases.
- Antes de ejecutar, cada integrante escribe su predicción en silencio durante 30 s; luego el equipo consensúa una.
- Si un integrante falta, se declara en la bitácora y otro cubre el rol.

Asignación propuesta de lecturas (modificable):

| Texto | Familia | Lector propuesto |
|---|---|---|
| L1 Belsley, Kuh y Welsch (1980) | Diagnóstico | Est. B |
| L2 Hoerl y Kennard (1970) | Ridge | Experto/a |
| L3 Tibshirani (1996) | Lasso | Informático/a |
| L4 Zou y Hastie (2005) | Elastic net | Est. A |
| L5 Mallows (1973), optativo | Selección | |
| L6 Galton (1886), optativo | Contexto | |

---

## 5. Estructura del repositorio y convenciones

```
proyecto-mea/
  README.md                 # un comando de ejecución, versiones, datos
  data/                     # datos.tgz descomprimido; sin edición manual
  analysis.R                # bloques "#@ nombre", uno por ejercicio
  ejecutor.R                # script de ejemplosr1.txt
  code/                     # generado por el ejecutor
  out/                      # salida de R generada por el ejecutor
  fig/                      # figuras guardadas desde el código (png/pdf)
  informe/informe.qmd       # lee out/ y fig/; sin cifras escritas a mano
  bitacora/bitacora.md      # entradas POE con commit previo a la ejecución
  lecturas/L1.md ...        # fichas de lectura (Anexo B)
  contribuciones.md         # registro por integrante y fase
```

Convenciones:

1. Comando de ejecución: `Rscript ejecutor.R && quarto render informe/informe.qmd`.
2. El ejecutor guarda código en `code/` y salida en `out/`. No guarda figuras: cada bloque que grafica llama a `png()` o `ggsave()` con destino `fig/`.
3. `set.seed()` declarado en cada bloque con aleatoriedad.
4. Un solo data frame de casos completos por ejercicio, declarado con su `n`.
5. Rutas relativas.
6. Primer bloque de `analysis.R`: `sessionInfo()`, versiones de paquetes y verificaciones de dimensiones y NA.
7. Cada bloque registra advertencias (el ejecutor las incluye en `out/`).
8. Commits por integrante; mensaje con fase y ejercicio.
9. Los mismos pliegues (`foldid`) en todos los métodos que se comparan.

---

## 6. Fases

### F0. Preparación individual (120 min, antes del taller)

Líder: cada integrante.

Tareas:
- Leer secciones 5.2, 5.4 (estandarización), 6.2 (diagnóstico) y 6.4.2 (forward, backward, stepwise) del libro.
- Leer el texto clásico asignado y completar la ficha (Anexo B): referencia completa, páginas, secciones o ecuaciones consultadas, problema, ecuación central en notación del autor y de la clase, elección del parámetro, afirmación contrastada con evidencia propia y su estatus, limitación, pregunta para la defensa.
- Instalar `glmnet`, `car`, `leaps`, `MASS`, `mctest`, `mlbench`, `pls`.

Verificación:
- [ ] Ficha de lectura de cada integrante con páginas, secciones o ecuaciones citadas.
- [ ] Datos bibliográficos comparados con el original o marcados "no verificado".
- [ ] Una afirmación del texto elegida para contrastar con evidencia propia (se ejecuta en F2 a F4).
- [ ] Paquetes instalados y cargables en cada equipo.

### F1. Contrato y entorno (20 min)

Líder: Informático/a.

Tareas:
- Informático/a: crear repositorio, registrar versiones de R y paquetes, descomprimir `datos.tgz` en `data/`, crear `analysis.R` con un bloque `#@` por ejercicio, copiar el ejecutor, crear el esqueleto de `informe.qmd`, crear `bitacora.md` y `contribuciones.md`.
- Experto/a: iniciar la ficha de datos de Hald, Cars93 y BostonHousing (significado, unidades, valores faltantes, fuente).
- Todos: acordar el contrato de equipo (sección 0) y exponer cada uno su lectura en 3 min (jigsaw).

Verificación:
- [ ] Contrato de equipo completado.
- [x] `Rscript ejecutor.R` corre sin error sobre el esqueleto en una sesión nueva.
- [ ] Todos los integrantes tienen acceso de escritura al repositorio y hicieron un commit.
- [ ] Jigsaw realizado (cada lectura expuesta al equipo).

### F2. Diagnóstico de colinealidad (35 min)

Líder: Est. B. Ejercicios: 8(a), 8(c) y 5(b). Diapositivas 8 a 15.

Predicción previa (por escrito, antes de ejecutar):
- (a) Pares de predictores de Hald con mayor correlación y cantidad de VIF mayores que 10.
- (b) Número de condición mayor en Hald (n = 13, p = 4) o en Cars93 (n = 82 casos completos, p = 16), con justificación.

Cálculos:
1. Matriz de correlaciones (Hald y Cars93).
2. VIF por definición, `diag(solve(cor(X)))`, y con `car::vif` sobre un `lm`.
3. Autovalores de la matriz de correlación, índices η_j = √(λ_máx / λ_j) y número de condición.
4. Descomposición de varianzas de Belsley, Kuh y Welsch con `svd()`, con y sin constante y con y sin centrado.
5. Experto/a: significado de cada columna; en Hald, suma de las filas de los predictores; en Cars93, comparación de `Min.Price`, `Price` y `Max.Price`.

Registrar la convención de cálculo usada para cada número de condición y el resultado bajo cada convención.

Verificación:
- [ ] Mínimo 2 entradas POE con predicción registrada antes de ejecutar.
- [ ] Tabla de diagnósticos: correlaciones, VIF, índices y número de condición, en Hald y Cars93.
- [ ] Los VIF por definición coinciden con `car::vif` (diferencia numérica verificada).
- [ ] Nota con la convención (constante, centrado, escala) y su efecto sobre el número de condición.
- [ ] Dependencias casi lineales identificadas con las variables que las componen.
- [ ] Explicación de qué detectan los índices que las correlaciones por pares no detectan.
- [ ] Interpretación de las dependencias desde el dominio (Experto/a).
- [ ] Visto bueno formativo del docente.

### F3. Selección de variables (60 min)

Líder: Est. A. Orden de ejercicios: 7, 4, 5(a), 6, 8(b). Diapositivas 29 y 30; sección 6.4.2.

Decisiones que se registran por escrito antes de ajustar:
- Tratamiento de casos incompletos de Cars93 y `n` resultante.
- Inclusión o exclusión de `MPG.highway` como predictor, con justificación. Las diapositivas la excluyen por ser casi una segunda respuesta. Si se excluye en el modelo principal, se ejecuta una variante con ella como análisis de sensibilidad.

Predicción previa:
- (a) Hald: si R²adj, Cp y BIC eligen el mismo modelo; orden de los tres criterios según parsimonia.
- (b) Cars93: si `stepAIC` con BIC desde el modelo completo recupera el modelo de la búsqueda exhaustiva.
- (c) Si los modelos elegidos tienen VIF bajos.

Cálculos:
1. Ej. 7 (Hald): `regsubsets` con 1 a 4 regresores y SSE mínima; modelo elegido por R²adj, Cp y BIC; forward, backward y stepwise (`regsubsets(method=)` y/o `step()`). `step()` usa AIC; el criterio se declara en cada tabla.
2. Ej. 4 (BostonHousing, `medv ~ indus + rm + ptratio + lstat`): mejores subconjuntos de 1 a 4 predictores; modelo por Cp; modelo por AIC.
3. Ej. 5(a) (Cars93): `stepAIC` con `k = 2`.
4. Ej. 6 (Cars93): `stepAIC` con `k = log(n)`; todas las regresiones posibles con Cp para `MPG.city`; comparación del modelo por Cp con el modelo de 5(a).
5. Ej. 8(b): VIF de los modelos elegidos en 7(b), con interpretación.
6. Número de modelos evaluados por cada método frente a 2^p.

Todos los modelos de Cars93 se ajustan sobre el mismo data frame de casos completos para que AIC y BIC sean comparables.

Verificación:
- [ ] Mínimo 3 entradas POE con predicción registrada antes de ejecutar.
- [ ] Decisión sobre `MPG.highway` y sobre casos incompletos documentada con `n`.
- [ ] Tabla comparativa de criterios (R²adj, Cp, AIC, BIC) y de métodos (exhaustivo, forward, backward, stepwise).
- [ ] Explicación de qué penaliza cada criterio y por qué discrepan.
- [ ] Explicación de por qué un método paso a paso puede diferir del exhaustivo.
- [ ] VIF de los modelos elegidos calculados e interpretados (Ej. 8(b)).
- [ ] Declaración del objetivo (predecir o explicar) que justifica el modelo final.
- [ ] Visto bueno formativo del docente.

### F4. Regularización (45 min)

Líder: Experto/a. Ejercicio 9 y extensión de clase. Diapositivas 18 a 46.

Predicción previa (bosquejo a mano):
- Trayectorias de los cuatro coeficientes de Hald frente a log λ en ridge y lasso.
- Cuál coeficiente se anula primero.
- Si hay cambios de signo respecto de MCO.
- Comportamiento del elastic net con el par de predictores más correlacionado.

Cálculos, Ej. 9 (Hald):
1. Predictores estandarizados con `scale()`; con `standardize = FALSE`, la estandarización ocurre antes del ajuste.
2. `glmnet` con α ∈ {0, 0.5, 1}.
3. `cv.glmnet` con `nfolds = n` (validación cruzada dejando uno fuera). Documentar la advertencia que emita `cv.glmnet` con este valor.
4. Reportar `lambda.min` y `lambda.1se`; verificar que `lambda.min` no coincida con el borde de la rejilla de λ (diapositiva 25).
5. Trazas, curvas de validación cruzada y grados de libertad efectivos.
6. Estabilidad de la selección por remuestreo; declarar el esquema de remuestreo y la relación entre el tamaño de la muestra y la estabilidad estimada.
7. Tabla comparativa de coeficientes MCO, ridge, lasso y elastic net.
8. Lecturas de λ (penalización, restricción, bayesiana) y efecto de α sobre variables correlacionadas.
9. Experto/a: plausibilidad de signos y magnitudes en el dominio.

Cálculos, extensión de clase (Cars93, diapositivas 43 a 46):
1. Mínimo 100 particiones 80/20 con semilla declarada.
2. Métodos comparados: MCO, modelo elegido por BIC, ridge, lasso y elastic net.
3. En cada partición: estandarización con media y desviación del conjunto de entrenamiento; λ elegido por validación cruzada dentro del entrenamiento; selección por BIC repetida dentro del entrenamiento. Un modelo BIC fijado con todos los datos introduce fuga de información.
4. Medida de error fuera de muestra (RMSE), con media, desviación y proporción de particiones en que cada método supera a MCO.
5. Sensibilidad a pliegues, semilla y α.

Verificación:
- [ ] Mínimo 3 entradas POE con predicción registrada antes de ejecutar.
- [ ] Predictores estandarizados; criterio de elección de λ documentado.
- [ ] `lambda.min` y `lambda.1se` reportados para ridge, lasso y elastic net.
- [ ] Trazas, curvas de validación cruzada y grados de libertad en `fig/`.
- [ ] Coeficientes penalizados descritos como penalizados (sin lectura como coeficientes de MCO).
- [ ] Explicación de los cambios de signo mediante sesgo–varianza o agrupamiento.
- [ ] Comparación fuera de muestra con semilla y esquema de partición declarados.
- [ ] Selección BIC repetida dentro de cada partición.
- [ ] Análisis de sensibilidad (pliegues, semilla, α).
- [ ] Advertencias numéricas documentadas.
- [ ] Visto bueno formativo del docente.

### F5. Validez de las conclusiones (30 min)

Líder: Est. B. Ejercicios: 4(d), 5(c) y 6(b). Sección 6.2; diapositivas 37 y 47.

Predicción previa: observaciones esperadas como atípicas, apalancadas o influyentes. El Experto/a propone candidatos desde el dominio.

Cálculos en cada modelo elegido:
1. Boxplot de residuos.
2. Apalancamiento h_ii frente a 2p/n.
3. Distancia de Cook frente a 4/n.
4. DFFITS frente a 2√(p/n).
5. DFBETAS frente a 2/√n.
6. En todos los umbrales, p es el número de parámetros del modelo, incluido el intercepto. Los umbrales usados se declaran en el informe.
7. Reajuste sin las observaciones señaladas; comparación de la selección y de los coeficientes.
8. Ej. 4(d): comparación de los modelos de 4(b) y 4(c) con diagnósticos de residuos.

Párrafo de inferencia posterior a la selección: los valores p e intervalos del modelo elegido con los mismos datos no tienen la distribución nominal. Se indican prácticas disponibles: separar muestras de selección e inferencia, validar fuera de muestra, informar estabilidad de la selección.

Verificación:
- [ ] Mínimo 2 entradas POE con predicción registrada antes de ejecutar.
- [ ] Figuras con líneas de umbral dibujadas y umbrales declarados.
- [ ] Distinción escrita entre observación atípica, apalancada e influyente.
- [ ] Tabla de sensibilidad (selección y coeficientes con y sin observaciones influyentes).
- [ ] Párrafo de inferencia posterior a la selección incluido en el informe.
- [ ] Todo valor p o intervalo del informe acompañado de la advertencia (R6).

### F6. Síntesis y defensa (30 min de síntesis, 8 + 4 min de defensa)

Líder: Experto/a.

Tareas:
- Conclusión de 150 palabras como máximo: modelo recomendado, objetivo, evidencia y límites.
- Etiquetar cada afirmación del informe como resultado demostrado, evidencia numérica o heurística.
- Contrastar al menos dos afirmaciones de los textos clásicos con evidencia propia y clasificarlas.
- Compilar el informe y contar páginas.
- Ejecutar el comando de la sección 5 en una sesión nueva de R.
- Preparar preguntas de rol y preguntas cruzadas; cada integrante practica explicar un resultado de otro rol.
- Completar la declaración de herramientas de apoyo.
- Cada integrante entrega la coevaluación (Anexo C) al docente.

Verificación:
- [ ] Conclusión de 150 palabras o menos, con modelo, objetivo, evidencia y límites.
- [ ] Todas las afirmaciones del informe con etiqueta.
- [ ] Informe de 8 páginas o menos sin anexos.
- [ ] Ejecución en sesión nueva de R sin intervención manual, con resultados que coinciden con el informe.
- [ ] Bitácora con 10 entradas o más; ninguna predicción editada después de ejecutar (verificado con el historial de commits).
- [ ] Fichas de lectura: mínimo 3, una por familia, con páginas, secciones o ecuaciones.
- [ ] Declaración de herramientas de apoyo incluida.
- [ ] Coevaluaciones entregadas.
- [ ] Ensayo de la defensa dentro de 8 min de exposición.

---

## 7. Desafíos opcionales (bonificación hasta +6)

Cada desafío puntúa si alcanza el nivel "Logrado" o superior en el criterio correspondiente.

| Desafío | Ejercicio | Datos | Requisito técnico | Puntos |
|---|---|---|---|---|
| D1 | Ej. 12: lasso y elastic net | Glaucoma | Respuesta binaria: `family = "binomial"` (Cap. 7); gráfico del error de validación cruzada de ambos modelos; interpretación de coeficientes no nulos | hasta 2 |
| D2 | Ej. 10: regresión por componentes principales | Hald | `pls::pcr`; estimación de parámetros | hasta 2 |
| D3 | Ej. 11: PLS y componentes principales | Deforestación (Ej. 6.2.1) | Partición 80/20 con semilla 123; `pls::plsr` y `pls::pcr`; comparación de poder predictivo | hasta 2 |

Verificación:
- [ ] Desafío elegido y responsable asignado.
- [ ] Criterio de la rúbrica al que aporta identificado.

---

## 8. Etiquetas de afirmaciones

| Etiqueta | Uso |
|---|---|
| Demostrado | Resultado matemático (por ejemplo, Var(β̂_j) = σ²/S_jj × VIF_j). |
| Evidencia numérica | Resultado de una muestra o simulación del equipo; no se generaliza más allá de los datos usados. |
| Heurística | Regla práctica (por ejemplo, VIF > 10; índice de condición > 30). |

---

## 9. Registro de avance

| Fase | Líder | Fecha límite interna | Estado (pendiente / en curso / cerrada) | Entradas POE | Visto bueno docente | Observaciones |
|---|---|---|---|---|---|---|
| F0 | Cada integrante | | | — | — | |
| F1 | Informático/a | 2026-10-22 | en curso (técnica completada) | — | — | Infraestructura modular, ejecutor.R, R/utils.R, esqueleto informe.qmd, references.bib y verificación Quarto |
| F2 | Est. B | | | | | |
| F3 | Est. A | 2026-10-28 | técnica completada | 3 de 2 | | Análisis modular (03, 04, 05, 06) ejecutado; tablas guardadas en out/tablas/; entradas F3-1, F3-2, F3-3 cerradas en bitácora. |
| F4 | Experto/a | | | | | |
| F5 | Est. B | | | | | |
| F6 | Experto/a | | | — | — | |

Contador de bitácora POE: total 5 (mínimo 10); F2 2 (predicciones registradas), F3 3 (cerradas), F4 0, F5 0.

Plantilla de entrada POE (una por predicción):

| Id | Predicción y razonamiento (antes de ejecutar) | Hora y autor/a | Observación (cifra, tabla o figura) | ¿Coincide? | Causa de la discrepancia y comprobación adicional |
|---|---|---|---|---|---|
| F2-1 | | | | | |

Requisitos de cada entrada: la predicción indica una cifra, un orden o una decisión; el razonamiento usa un argumento estadístico; la explicación nombra la causa y propone una prueba para decidir entre hipótesis; lo observado se distingue de lo inferido y de la regla práctica.

---

## 10. Verificación previa a la entrega

- [ ] El código corre de principio a fin en una sesión nueva, con semilla y `sessionInfo()`.
- [ ] El informe tiene 8 páginas o menos sin anexos; cada figura y tabla tiene leyenda e interpretación.
- [ ] Cada afirmación tiene etiqueta.
- [ ] La bitácora tiene 10 entradas o más y ninguna predicción fue editada después de ejecutar.
- [ ] Hay una ficha de lectura por cada texto clásico consultado (mínimo 3, una por familia) con páginas o ecuaciones.
- [ ] Las referencias se compararon con el original o se marcaron como no verificadas.
- [ ] Se declaró el uso de herramientas de apoyo.
- [ ] Cada integrante entregó su coevaluación al docente.
- [ ] Cada integrante puede explicar con sus palabras el trabajo de su rol y un resultado de otro rol.
