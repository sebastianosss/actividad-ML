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
| Diego Espinoza | L4: Zou y Hastie (2005) | Sí (L4.md) | Sí (R 4.5.1) | Verificada con el artículo original (JRSS-B, Vol. 67, Part 2, pp. 301–320). Teorema 1 y agrupamiento vinculados a F4. |
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
| Diego Espinoza | | | |
| Sebastián Osses | Líder | | |
| Tomás Anabalón | | | |
| Bastián Vera | | | |

### F3 — Selección de variables

| Integrante | Rol (driver/navegante/revisor) | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | Líder / Driver | Modelación y selección modular de variables: Ej. 7 (Hald: mejores subconjuntos, Cp, AIC, BIC), Ej. 4 (BostonHousing: Cp y AIC), Ej. 5a y 6 (Cars93: stepAIC con k=2 y k=log(n), regresiones posibles Cp, 65535 vs 136 modelos evaluados), Ej. 8b (diagnóstico de VIF pre y post selección). Registro y cierre de 3 entradas POE (F3-1, F3-2, F3-3). | `50a2920`, `4076d95` |
| Sebastián Osses | Navegante / Revisor | Revisión de consistencia en criterios de información y contraste de VIFs | |
| Tomás Anabalón | Revisor (Dominio) | Verificación de plausibilidad en exclusión de variables y redundancia de precios en Cars93 | |
| Bastián Vera | Revisor (Informático) | Verificación de reproducibilidad con ejecutor.R y generación de tablas en out/tablas/ | |

### F4 — Regularización

| Integrante | Rol (driver/navegante/revisor) | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | | | |
| Sebastián Osses | | | |
| Tomás Anabalón | Líder | | |
| Bastián Vera | | | |

### F5 — Validez de las conclusiones

| Integrante | Rol (driver/navegante/revisor) | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | | | |
| Sebastián Osses | Líder | | |
| Tomás Anabalón | | | |
| Bastián Vera | | | |

### F6 — Síntesis y defensa

| Integrante | Rol | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | | | |
| Sebastián Osses | | | |
| Tomás Anabalón | Líder | | |
| Bastián Vera | | | |

---

## Reglas de rotación

- Ningún integrante es driver en dos fases consecutivas.
- El/la Informático/a digita como máximo dos fases.
- Si un integrante falta, se declara en la bitácora y otro cubre el rol.
