# Registro de contribuciones

**Proyecto:** Laboratorio MEA — Colinealidad, Selección y Regularización

Cada integrante registra aquí sus contribuciones por fase. Los commits de Git sirven como evidencia verificable.

---

## Integrantes y roles

| Rol | Integrante |
|---|---|
| Est. A (Modelación y selección) | Diego Espinoza |
| Est. B (Diagnóstico y validación) | Sebastián Osses |
| Experto/a (Dominio y calidad del dato) | Tomás Anabalón |
| Informático/a (Reproducibilidad y flujo) | Bastián Vera |

---

## Registro por fase

### F0 — Preparación individual

| Integrante | Lectura asignada | Ficha completada | Paquetes instalados | Observaciones |
|---|---|---|---|---|
| Diego Espinoza | L4: Zou y Hastie (2005) | Sí (L4.md) | Sí (R 4.4 / 4.5) | Verificada con el artículo original (JRSS-B, Vol. 67, Part 2, pp. 301–320). Teorema 1 y agrupamiento vinculados a F4. |
| Sebastián Osses | L1: Belsley, Kuh y Welsch (1980) | | | |
| Tomás Anabalón | L2: Hoerl y Kennard (1970) | | | |
| Bastián Vera | L3: Tibshirani (1996) | | | |

### F1 — Contrato y entorno

| Integrante | Rol en F1 | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | Revisor | Revisión de estructura y acuerdos de equipo | |
| Sebastián Osses | Revisor | Revisión de diagnóstico y acuerdos de equipo | |
| Tomás Anabalón | Revisor / Dominio | Revisión de datos y acuerdos de equipo | |
| Bastián Vera | Líder (Informático) | Infraestructura base, ejecutor modular, esqueleto de informe.qmd, funciones R/utils.R, bloques de análisis 00 y 01, documentación de datos y entorno en README | `ebc54dc`, `21bf905`, `8f3c80a`, `5e1a5b5`, `20d5c47`, `0555979`, `6155a45`, `46cda6d`, `de278d6`, `280f8a4`, `644fdf4`, `a0ba680`, `b4df8b4`, `5534cd1` |

### F2 — Diagnóstico de colinealidad

| Integrante | Rol (driver/navegante/revisor) | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | Navegante / Revisor | Registro de predicciones previas POE (F2-1 y F2-2) sobre Hald y Cars93; contraste de VIF por definición vs car::vif y comparación de números de condición | `6a30a87` |
| Sebastián Osses | Líder / Driver | Implementación de análisis modular `02_diagnostico_colinealidad.R`, cálculo de correlaciones, autovalores, índices BKW con/sin constante y centrado, generación de figuras y tablas | `6a30a87` |
| Tomás Anabalón | Revisor (Dominio) | Interpretación de composición de mezcla en Hald ($\sum X_j \approx 98\%$) y redundancia de precios en Cars93 | |
| Bastián Vera | Revisor (Informático) | Validación de ejecución limpia en ejecutor.R y registro de tablas BKW | |

### F3 — Selección de variables

| Integrante | Rol (driver/navegante/revisor) | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | Líder / Driver | Modelación y selección modular de variables: Ej. 7 (Hald: mejores subconjuntos, Cp, AIC, BIC), Ej. 4 (BostonHousing: Cp y AIC), Ej. 5a y 6 (Cars93: stepAIC con k=2 y k=log(n), regresiones posibles Cp, 65535 vs 136 modelos evaluados), Ej. 8b (diagnóstico de VIF pre y post selección). Redacción de la Sección 3 del informe y cierre de 3 entradas POE (F3-1, F3-2, F3-3). | `50a2920`, `4076d95`, `1e7e141`, `3ee892d` |
| Sebastián Osses | Navegante / Revisor | Revisión de consistencia en criterios de información y contraste de VIFs | |
| Tomás Anabalón | Revisor (Dominio) | Verificación de plausibilidad en exclusión de variables y redundancia de precios en Cars93 | |
| Bastián Vera | Revisor (Informático) | Verificación de reproducibilidad con ejecutor.R y generación de tablas en out/tablas/ | |

### F4 — Regularización

| Integrante | Rol (driver/navegante/revisor) | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | Navegante / Asesor L4 | Formulación de predicciones POE (F4-1, F4-2, F4-3), diseño conceptual del efecto de agrupamiento de Elastic Net según Zou & Hastie (2005) y validación fuera de muestra (100 particiones) | `6a30a87` |
| Sebastián Osses | Revisor | Revisión de convergencia y curvas de validación cruzada | |
| Tomás Anabalón | Líder / Driver | Implementación de scripts modulares 07 y 08: Ridge, Lasso y Elastic Net con glmnet, trazas, estabilidad por remuestreo bootstrap y evaluación de RMSE fuera de muestra | `6a30a87` |
| Bastián Vera | Revisor (Informático) | Control de semillas fijas (set.seed(123)) y prevención de fuga de información en particiones | |

### F5 — Validez de las conclusiones

| Integrante | Rol (driver/navegante/revisor) | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | Revisor / Co-autor | Redacción del párrafo obligatorio de advertencia de inferencia post-selección (R6), predicciones F5-1 y F5-2 y análisis de sensibilidad de coeficientes | `6a30a87` |
| Sebastián Osses | Líder / Driver | Implementación de script modular 09: cálculo de residuos studentizados, leverage (2p/n), Cook (4/n), DFFITS, DFBETAS, reajuste del modelo sin influyentes y gráficos | `6a30a87` |
| Tomás Anabalón | Revisor (Dominio) | Identificación de autos extremos (Civic y Metro como atípicos de consumo; Mercedes 300E como leverage) | |
| Bastián Vera | Revisor (Informático) | Verificación de generación de gráficos diagnósticos en fig/ | |

### F6 — Síntesis y defensa

| Integrante | Rol | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | Co-autor (Est. A) | Co-redacción del informe técnico final, síntesis de conclusión en 147 palabras, etiquetado formal de afirmaciones y preparación para defensa | |
| Sebastián Osses | Co-autor (Est. B) | Consolidación de gráficos e interpretación de sensibilidad muestral | |
| Tomás Anabalón | Líder | Ensamblaje del informe final E1, control del límite de 8 páginas y balance narrativo | |
| Bastián Vera | Informático | Control de reproducibilidad total con un solo comando (E2) | |

---

## Reglas de rotación

- Ningún integrante es driver en dos fases consecutivas.
- El/la Informático/a digita como máximo dos fases.
- Si un integrante falta, se declara en la bitácora y otro cubre el rol.
