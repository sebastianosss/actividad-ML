# AGENTS.md: reglas del proyecto y estado

Ubicación: raíz del repositorio. Límite de Antigravity para archivos de reglas: 12.000 caracteres. Si el estado crece, moverlo a `MEMORIA.md` y referenciarlo desde este archivo con `@MEMORIA.md`.

## 1. Contexto

- Curso: Modelos Estadísticos Activos (Ingeniería en Estadística, UCM). Actividad: laboratorio en equipo de colinealidad, selección y regularización (ridge, lasso, elastic net).
- Equipo de 4 integrantes con roles: Est. A (selección), Est. B (diagnóstico y validación), Experto/a (dominio y datos), Informático/a (reproducibilidad).
- Datos: Hald (paquete `mctest`, n = 13, 4 predictores), Cars93 (`MASS`; `MPG.city` como respuesta; 16 predictores; n = 82 casos completos), BostonHousing (`mlbench`). Desafíos opcionales: Glaucoma y Deforestación.
- Lenguaje: R con `glmnet`, `car`, `leaps`, `MASS`, `mctest`, `mlbench`, `pls`.
- Plan de fases: `plan_trabajo_MEA.md`.

## 2. Reglas de proceso

1. **Predicción antes de ejecución.** Antes de ejecutar un bloque de análisis de F2 a F5, verificar que `bitacora/bitacora.md` contenga una entrada con la predicción de ese bloque y que esa entrada esté en un commit anterior a la ejecución. Si no existe, detenerse y solicitarla.
2. **Predicciones inmutables.** No editar una predicción registrada. La observación y la explicación se agregan en sus columnas. Un cambio de criterio se registra en una entrada nueva que referencia la anterior.
3. **Predicciones del equipo.** No redactar predicciones en nombre del equipo. Cada integrante escribe la suya y luego el equipo consensúa una.
4. **Discrepancias.** Si el resultado difiere de la predicción, no modificar el código hasta que la discrepancia esté explicada en la bitácora (causa y comprobación adicional).
5. **Referencias.** No generar de memoria datos bibliográficos, páginas, ecuaciones ni citas textuales. Si se solicitan, responder "no verificado" y pedir el documento original.
6. **Fichas de lectura.** No redactar su contenido. Se permite revisar formato y ortografía.
7. **Libro del curso.** No copiar enunciados ni soluciones.
8. **Datos.** No modificar archivos de `data/`. Las transformaciones se hacen en código y se guardan en `out/`.
9. **Cifras del informe.** Toda cifra proviene de un archivo de `out/` o `fig/`. Sin valores escritos a mano.
10. **Etiquetas.** Cada afirmación del informe lleva una etiqueta: demostrado, evidencia numérica o heurística.
11. **Supuestos.** Ante una convención o decisión no definida (casos incompletos, estandarización, umbral), indicar el supuesto en la respuesta y registrarlo en la sección 5 de este archivo. No elegir en silencio.
12. **Git.** Trabajar en la rama del integrante. No hacer push a `main`. El commit lo ejecuta la persona después de revisar el cambio.
13. **Registro de uso.** Cada sesión con el agente se anota en `USO_HERRAMIENTAS.md`: fecha, integrante, tarea, qué verificó la persona por cuenta propia. Este registro sustenta la declaración final del informe.

## 3. Convenciones técnicas

- Ejecución: `Rscript ejecutor.R && quarto render informe/informe.qmd`. Comprobación final en una sesión nueva de R.
- El ejecutor lee los bloques `#@ nombre`, guarda el código en `code/` y la salida en `out/`, incluidas las advertencias. No guarda figuras: cada bloque que grafica usa `png()` o `ggsave()` con destino `fig/`.
- Semilla declarada con `set.seed()` en cada bloque con aleatoriedad.
- Primer bloque: `sessionInfo()`, versiones de paquetes, dimensiones y conteo de NA de cada conjunto de datos.
- Rutas relativas.
- Cars93: un único data frame de casos completos, con `n` declarado, para todos los modelos que se comparan por AIC o BIC.
- `step()` usa AIC; `stepAIC(k = log(n))` usa BIC. El criterio se declara en cada tabla.
- Estandarización antes de penalizar. Con `standardize = FALSE`, los predictores se estandarizan antes con `scale()`.
- Comparaciones fuera de muestra: estandarizar con media y desviación del conjunto de entrenamiento; elegir λ dentro del entrenamiento; repetir la selección por BIC dentro de cada partición.
- Mismos pliegues (`foldid`) en los métodos que se comparan.
- `cv.glmnet`: verificar que `lambda.min` no coincida con el borde de la rejilla de λ. Con `nfolds = n` (Hald), documentar la advertencia que emita.
- Umbrales de influencia (p = número de parámetros, incluido el intercepto): h_ii > 2p/n; Cook > 4/n; DFFITS > 2√(p/n); DFBETAS > 2/√n. Declararlos en el informe.
- Valores p e intervalos de un modelo elegido con los mismos datos: acompañar con la advertencia de inferencia posterior a la selección.
- Número de condición: declarar la convención (constante, centrado, escala) y el resultado bajo cada una.

## 4. Reglas del curso que limitan puntaje

| Regla | Condición | Efecto |
|---|---|---|
| R1 | Referencia inexistente, o datos bibliográficos no consultados presentados como verificados | C6 = 0 |
| R2 | Predicción editada después de ejecutar | C5 = 0 |
| R3 | Menos de 3 textos clásicos o falta una familia | C6 ≤ 3 |
| R4 | Código que no se ejecuta en entorno limpio | C7 ≤ 3 |
| R5 | Ridge, lasso o elastic net sin criterio de λ ni validación fuera de muestra | C3 ≤ 9 |
| R6 | Valores p o intervalos del modelo seleccionado sin advertencia | C4 ≤ 4 |
| R7 | Informe de más de 8 páginas sin anexos | C8: −2 |

## 5. Estado del proyecto

### Decisiones registradas

| Decisión | Valor | Fecha | Responsable |
|---|---|---|---|
| Tratamiento de casos incompletos de Cars93 | pendiente | | |
| `MPG.highway` como predictor | pendiente | | |
| Convención del número de condición | pendiente | | |
| Esquema de remuestreo para estabilidad en Hald | pendiente | | |

### Avance por fase

| Fase | Estado (pendiente / en curso / cerrada) | Entradas POE | Observaciones |
|---|---|---|---|
| F0 | pendiente | — | |
| F1 | pendiente | — | |
| F2 | pendiente | 0 de 2 | |
| F3 | pendiente | 0 de 2 | |
| F4 | pendiente | 0 de 2 | |
| F5 | pendiente | 0 de 2 | |
| F6 | pendiente | — | |

### Pendientes abiertos

- (agregar con fecha y responsable)
