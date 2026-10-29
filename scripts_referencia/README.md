# Scripts de Referencia y Exploración Preliminar

Esta carpeta contiene los scripts exploratorios iniciales desarrollados por el equipo como base y cantera de código para las distintas fases del laboratorio.

> [!NOTE]
> Estos scripts son **material de consulta y referencia técnica**. No son ejecutados por `ejecutor.R` (el cual ejecuta exclusivamente los scripts modulares en `analysis/*.R` con bloques `#@`). Cada integrante debe adaptar, modularizar y validar el código en su respectiva rama y fase según el protocolo POE de `bitacora/bitacora.md`.

---

## Contenido por fase y responsable

| Archivo | Fase | Responsable | Descripción técnica |
|---|:---:|---|---|
| [`codigoslmf2.R`](codigoslmf2.R) | **F2** | **Sebastián Osses** *(Est. B)* | Diagnóstico de colinealidad: correlaciones, cálculo de VIF por definición analítica y con `car::vif()`, descomposición en valores singulares (SVD), índices y número de condición bajo distintas convenciones, descomposición de varianzas BKW para `Hald`, `Cars93`, `Deforestación` y `Glaucoma`. |
| [`codigoslmf3.R`](codigoslmf3.R) | **F3** | **Diego Espinoza** *(Est. A)* | Selección de variables: mejores subconjuntos exhaustivos (`leaps::regsubsets`), selección secuencial hacia adelante/atrás (stepwise forward, backward) mediante AIC y BIC, cálculo de $C_p$ de Mallows para `Hald`, `BostonHousing` y `Cars93`. |
| [`codigoslmf4.R`](codigoslmf4.R) | **F4** | **Tomás Anabalón** *(Experto)* | Regularización: regresión Ridge ($\alpha = 0$), Lasso ($\alpha = 1$) y Elastic Net ($\alpha = 0.5$) mediante `glmnet`, validación cruzada (`cv.glmnet`), trazas de coeficientes y evaluación de estabilidad. |
