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
| Diego Espinoza | L4: Zou y Hastie (2005) | | | |
| Sebastián Osses | L1: Belsley, Kuh y Welsch (1980) | | | |
| Tomás Anabalón | L2: Hoerl y Kennard (1970) | | | |
| Bastián Vera | L3: Tibshirani (1996) | | | |

### F1 — Contrato y entorno

| Integrante | Rol en F1 | Contribución | Commits |
|---|---|---|---|
| Diego Espinoza | Revisor | Revisión de estructura, validación de decisiones metodológicas sobre predictores de Cars93 y esquema de remuestreo en Hald | `26f09b1` (co-autor de acuerdos) |
| Sebastián Osses | Revisor / Est. B | Revisión de diagnóstico, formalización de 4 variantes de número de condición, respaldo de scripts en rama borrador y formalización de reglas en AGENTS.md | `147c3d5`, `ae256c5` |
| Tomás Anabalón | Revisor / Dominio | Revisión de datos, definición del criterio de casos completos de Cars93 (n = 82) y exclusión de `MPG.highway` por redundancia directa | `26f09b1` (co-autor de acuerdos) |
| Bastián Vera | Líder (Informático) | Infraestructura base, ejecutor modular (`analysis/*.R`), esqueleto de informe.qmd con fichas descriptivas y datos desde out/, funciones R/utils.R, bloques de análisis 00 y 01, referencias oficiales BibTeX, configuración de .gitignore y cierre de fase | `ebc54dc`, `21bf905`, `8f3c80a`, `5e1a5b5`, `20d5c47`, `0555979`, `6155a45`, `46cda6d`, `de278d6`, `280f8a4`, `644fdf4`, `a0ba680`, `b4df8b4`, `5534cd1`, `26f09b1` |

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
| Diego Espinoza | Líder | | |
| Sebastián Osses | | | |
| Tomás Anabalón | | | |
| Bastián Vera | | | |

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
