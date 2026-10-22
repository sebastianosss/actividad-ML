# =====================================================================
# Regresión Ridge, Lasso y Elastic Net: de la multicolinealidad a la selección
# Ingeniería en Estadística - UCM
# Autor: José Miguel Zúñiga Núñez
#
# Este script se ejecuta por bloques con run_chunks.R. Cada bloque marcado con
# "#@ nombre" produce code/nombre.R (código mostrado en las diapositivas) y
# out/nombre.txt (salida real de R). Los bloques fig_* generan las figuras.
# Ejecutar:  Rscript run_chunks.R
# =====================================================================

#@ setup
suppressPackageStartupMessages({
  library(MASS)     # Cars93
  library(car)      # vif()
  library(glmnet)   # ridge, lasso, elastic net
  library(leaps)    # regsubsets()
})
options(width = 80, digits = 4)
set.seed(2026)

#@ datos
vars <- c("MPG.city", "Min.Price", "Price", "Max.Price", "EngineSize", "Horsepower",
          "RPM", "Rev.per.mile", "Fuel.tank.capacity", "Passengers", "Length",
          "Wheelbase", "Width", "Turn.circle", "Rear.seat.room", "Luggage.room", "Weight")
d <- Cars93[, vars]
cat("Filas con algún NA:", sum(!complete.cases(d)), "de", nrow(d), "\n")
colSums(is.na(d))[colSums(is.na(d)) > 0]
d <- d[complete.cases(d), ]          # casos completos (supuesto declarado)
X <- scale(d[, -1])                  # predictores centrados y escalados
y <- d$MPG.city
dat <- data.frame(MPG.city = y, X)
cat("n =", nrow(X), " p =", ncol(X), "\n")

#@ precio
# Price es, por construcción, el punto medio entre Min.Price y Max.Price
round(cor(d[, c("Min.Price", "Price", "Max.Price")]), 3)
max(abs(d$Price - (d$Min.Price + d$Max.Price) / 2))

#@ cor_alta
R <- cor(X)                       # correlaciones
pares <- which(upper.tri(R), arr.ind = TRUE)
r <- R[pares]
o <- order(-abs(r))[1:8]          # 8 mayores
data.frame(var1 = colnames(R)[pares[o, 1]],
           var2 = colnames(R)[pares[o, 2]],
           r = round(r[o], 3))
n90 <- sum(abs(r) > 0.90); n95 <- sum(abs(r) > 0.95)
cat("Pares con |r| > 0.90:", n90, "de", length(r), "\n")
cat("Pares con |r| > 0.95:", n95, "\n")
pm <- (d$Min.Price + d$Max.Price) / 2   # punto medio
max(abs(d$Price - pm))                  # Price vs punto medio

#@ ols
mod.1 <- lm(MPG.city ~ ., data = dat)
sm <- summary(mod.1)
round(sm$coefficients, 3)
c(R2 = sm$r.squared,
  R2.adj = sm$adj.r.squared,
  F = unname(sm$fstatistic[1]))

#@ vif
vif.1 <- sort(car::vif(mod.1), decreasing = TRUE)
data.frame(VIF = round(vif.1, 1))
cat("VIF medio:", round(mean(vif.1), 1), "\n")

#@ cond
R <- crossprod(X) / (nrow(X) - 1)    # matriz de correlación
ev <- eigen(R, symmetric = TRUE)$values
signif(ev, 3)
eta <- sqrt(max(ev) / ev)            # índices de condición
round(eta, 1)
cat("Número de condición C =", round(max(eta), 1), "\n")

#@ drop
# Eliminación iterativa del predictor con mayor VIF hasta que todos sean < 10
keep <- names(dat)[-1]
repeat {
  v <- car::vif(lm(MPG.city ~ ., data = dat[, c("MPG.city", keep)]))
  cat(sprintf("p = %2d   VIF max = %9.1f   (%s)\n", length(keep), max(v), names(which.max(v))))
  if (max(v) < 10) break
  keep <- setdiff(keep, names(which.max(v)))
}

#@ drop_fit
mod.drop <- lm(MPG.city ~ ., data = dat[, c("MPG.city", keep)])
round(summary(mod.drop)$coefficients, 3)
c(R2 = summary(mod.drop)$r.squared, R2.adj = summary(mod.drop)$adj.r.squared)

#@ ridge_fit
set.seed(2026)
foldid <- sample(rep(1:10, length.out = nrow(X)))   # mismos pliegues para todos los métodos
# Rejilla ampliada para ridge: la rejilla por defecto se detiene antes de alcanzar el mínimo
lam.grid  <- exp(seq(log(1e4), log(1e-4), length.out = 100))
fit.ridge <- glmnet(X, y, alpha = 0, standardize = FALSE, lambda = lam.grid)
cv.ridge  <- cv.glmnet(X, y, alpha = 0, standardize = FALSE, foldid = foldid,
                       type.measure = "mse", lambda = lam.grid)
c(lambda.min = cv.ridge$lambda.min, lambda.1se = cv.ridge$lambda.1se)
range(lam.grid)    # el mínimo debe quedar dentro de la rejilla, no en su borde

#@ ridge_closed
# Verificación de la solución cerrada. glmnet estandariza y internamente (con 1/n);
# con y estandarizada, el lambda de glmnet coincide con el de la fórmula (X'X/n + lambda I)
sy  <- sqrt(mean((y - mean(y))^2))
ys  <- (y - mean(y)) / sy
lam <- 0.5
b.closed <- solve(crossprod(X) / nrow(X) + lam * diag(ncol(X)), crossprod(X, ys) / nrow(X))
fit.chk  <- glmnet(X, ys, alpha = 0, lambda = lam, standardize = FALSE, thresh = 1e-14)
max(abs(b.closed - as.matrix(coef(fit.chk))[-1, ]))

#@ ridge_coef
bt <- function(cv, s) as.numeric(coef(cv, s = s))
cf.r <- cbind(OLS = coef(mod.1),
  ridge.min = bt(cv.ridge, "lambda.min"),
  ridge.1se = bt(cv.ridge, "lambda.1se"))
round(cf.r, 3)

#@ ridge_lambda
ev.n <- eigen(crossprod(X) / nrow(X), symmetric = TRUE)$values
cond.r <- function(l) sqrt((max(ev.n) + l) / (min(ev.n) + l))
df.r   <- function(l) sum(ev.n / (ev.n + l))
ls <- c(0, 0.01, 0.1, cv.ridge$lambda.min, 1,
        cv.ridge$lambda.1se, 100)
data.frame(lambda = signif(ls, 3),
  cond = round(sapply(ls, cond.r), 1),
  df = round(sapply(ls, df.r), 2))

#@ subsets
out <- regsubsets(x = X, y = y, nvmax = ncol(X), nbest = 1, intercept = TRUE)
bic <- summary(out)$bic
round(bic, 1)
cat("BIC mínimo con", which.min(bic), "predictores:\n")
names(which(summary(out)$which[which.min(bic), -1]))

#@ lasso_fit
fit.lasso <- glmnet(X, y, alpha = 1, standardize = FALSE)
cv.lasso  <- cv.glmnet(X, y, alpha = 1, standardize = FALSE, foldid = foldid,
                       type.measure = "mse")
c(lambda.min = cv.lasso$lambda.min, lambda.1se = cv.lasso$lambda.1se)

#@ lasso_coef
cf.l <- cbind(lambda.min = as.numeric(coef(cv.lasso, s = "lambda.min")),
              lambda.1se = as.numeric(coef(cv.lasso, s = "lambda.1se")))
rownames(cf.l) <- rownames(coef(cv.lasso))
round(cf.l[rowSums(cf.l != 0) > 0, ], 3)        # solo coeficientes no nulos
cat("Predictores con coef. no nulo:", colSums(cf.l[-1, ] != 0), "\n")

#@ enet_fit
fit.enet <- glmnet(X, y, alpha = 0.5, standardize = FALSE)
cv.enet  <- cv.glmnet(X, y, alpha = 0.5, standardize = FALSE, foldid = foldid,
                      type.measure = "mse")
c(lambda.min = cv.enet$lambda.min, lambda.1se = cv.enet$lambda.1se)

#@ alpha_grid
alphas <- c(0, 0.25, 0.5, 0.75, 1)
cv.grid <- lapply(alphas, function(a)
  cv.glmnet(X, y, alpha = a, standardize = FALSE, foldid = foldid,
            lambda = if (a == 0) lam.grid else NULL))
data.frame(alpha = alphas,
           lambda.min = sapply(cv.grid, function(f) f$lambda.min),
           cv.mse     = sapply(cv.grid, function(f) min(f$cvm)),
           cv.se      = sapply(cv.grid, function(f) f$cvsd[which.min(f$cvm)]),
           no.nulos   = unname(sapply(cv.grid, function(f) f$nzero[which.min(f$cvm)])))

#@ compare
bt <- function(cv, s) as.numeric(coef(cv, s = s))
tab <- cbind(OLS = coef(mod.1),
  ridge = bt(cv.ridge, "lambda.1se"),
  lasso = bt(cv.lasso, "lambda.1se"),
  EN = bt(cv.enet, "lambda.1se"))
rownames(tab) <- rownames(coef(cv.ridge))
round(tab, 3)
cat("No nulos (sin intercepto):\n")
colSums(tab[-1, ] != 0)

#@ estab
# 200 submuestras (50 %, sin reemplazo); lambda.1se en cada una
set.seed(11); B <- 200; m <- floor(nrow(X) / 2)
nz <- function(a, xb, yb)
  as.numeric(coef(cv.glmnet(xb, yb, alpha = a, standardize = FALSE),
                  s = "lambda.1se")[-1] != 0)
cuenta <- list(lasso = 0, EN = 0)
for (b in 1:B) {
  i <- sample(nrow(X), m)
  xb <- scale(d[i, -1]); yb <- y[i]
  cuenta$lasso <- cuenta$lasso + nz(1, xb, yb)
  cuenta$EN    <- cuenta$EN    + nz(0.5, xb, yb)
}
fr <- cbind(lasso = cuenta$lasso, EN = cuenta$EN) / B
rownames(fr) <- colnames(X)
round(fr[order(-fr[, "lasso"]), ], 2)

#@ split
# Validación repetida: 200 particiones 80/20; se reestandariza con el conjunto de entrenamiento
rmse <- function(a, b) sqrt(mean((a - b)^2))
B <- 200
res <- matrix(NA, B, 5, dimnames = list(NULL, c("OLS", "OLS.VIF", "ridge", "lasso", "EN")))
set.seed(93)
for (b in 1:B) {
  tr  <- sample(nrow(d), round(0.8 * nrow(d)))
  mu  <- colMeans(d[tr, -1]); s <- apply(d[tr, -1], 2, sd)
  xtr <- scale(d[tr, -1], mu, s);  xte <- scale(d[-tr, -1], mu, s)
  ytr <- y[tr];                    yte <- y[-tr]
  dtr <- data.frame(MPG.city = ytr, xtr);  dte <- data.frame(xte)
  res[b, "OLS"]     <- rmse(yte, predict(lm(MPG.city ~ ., dtr), dte))
  res[b, "OLS.VIF"] <- rmse(yte, predict(lm(MPG.city ~ ., dtr[, c("MPG.city", keep)]), dte))
  for (nm in c("ridge", "lasso", "EN")) {
    a   <- c(ridge = 0, lasso = 1, EN = 0.5)[[nm]]
    cvf <- cv.glmnet(xtr, ytr, alpha = a, standardize = FALSE, nfolds = 10,
                     lambda = if (a == 0) lam.grid else NULL)
    res[b, nm] <- rmse(yte, predict(cvf, xte, s = "lambda.min"))
  }
}
rbind(RMSE.medio = colMeans(res), DE = apply(res, 2, sd),
      mejor.que.OLS = colMeans(res < res[, "OLS"]))

#@ sim_agrup
# Efecto de agrupamiento: x1 y x2 con correlación rho y efecto beta cada uno (n = 100, p = 10)
sim.sc <- function(rho, beta, nrep = 200, n = 100, p = 10) {
  sel <- dif <- matrix(NA, nrep, 2, dimnames = list(NULL, c("lasso", "EN")))
  for (r in 1:nrep) {
    z  <- rnorm(n)
    xs <- cbind(sqrt(rho) * z + sqrt(1 - rho) * rnorm(n),
                sqrt(rho) * z + sqrt(1 - rho) * rnorm(n), matrix(rnorm(n * (p - 2)), n, p - 2))
    ys <- drop(xs %*% c(beta, beta, rep(0, p - 2))) + rnorm(n)
    xs <- scale(xs)
    for (nm in c("lasso", "EN")) {
      a <- c(lasso = 1, EN = 0.5)[[nm]]
      b <- as.numeric(coef(cv.glmnet(xs, ys, alpha = a, standardize = FALSE),
                           s = "lambda.min"))[2:3]
      sel[r, nm] <- sum(b != 0);  dif[r, nm] <- abs(b[1] - b[2])
    }
  }
  c(ambos.lasso = mean(sel[, "lasso"] == 2), ambos.EN = mean(sel[, "EN"] == 2),
    dif.lasso = mean(dif[, "lasso"]), dif.EN = mean(dif[, "EN"]))
}
set.seed(7)
esc <- expand.grid(rho = c(0.90, 0.99), beta = c(1.5, 0.5))
res.sim <- cbind(esc, t(mapply(sim.sc, esc$rho, esc$beta)))
round(res.sim, 3)

#@ sessioninfo
sessionInfo()

# ------------------------------- FIGURAS -------------------------------
#@ fig_setup
pal <- c(ols = "#52514e", ridge = "#2a78d6", lasso = "#eb6834", enet = "#1baf7a",
         ucm = "#0B3C70", grid = "#d9d8d3", ink = "#0b0b0b")
fig <- function(name, w = 6.2, h = 3.0) {
  dir.create("fig", showWarnings = FALSE)
  cairo_pdf(file.path("fig", paste0(name, ".pdf")), width = w, height = h, family = "Roboto")
  par(mar = c(3.6, 3.9, 0.8, 0.8), mgp = c(2.3, 0.7, 0), cex = 0.85, las = 1,
      col.axis = "#52514e", fg = "#52514e", tcl = -0.3)
}
plot_cv <- function(cvf, col, ylab = "ECM de validación cruzada") {
  ll <- log(cvf$lambda)
  plot(ll, cvf$cvm, type = "n", xlab = expression(log(lambda)), ylab = ylab,
       ylim = range(cvf$cvm - cvf$cvsd, cvf$cvm + cvf$cvsd))
  grid(col = pal["grid"], lty = 1)
  polygon(c(ll, rev(ll)), c(cvf$cvm - cvf$cvsd, rev(cvf$cvm + cvf$cvsd)),
          col = adjustcolor(col, 0.18), border = NA)
  lines(ll, cvf$cvm, col = col, lwd = 2)
  abline(v = log(c(cvf$lambda.min, cvf$lambda.1se)), lty = c(2, 3), col = pal["ink"])
  legend("topleft", bty = "n", cex = 0.9, lty = c(2, 3), col = pal["ink"],
         legend = c(expression(lambda[min]), expression(lambda[1*se])))
}
plot_path <- function(fitg, hi, cols, cvf, labs) {
  b <- as.matrix(fitg$beta); ll <- log(fitg$lambda)
  matplot(ll, t(b), type = "l", lty = 1, lwd = 1, col = pal["grid"], xlab = expression(log(lambda)),
          ylab = "Coeficiente estandarizado")
  grid(col = "#eeeeea", lty = 1)
  for (i in seq_along(hi)) lines(ll, b[hi[i], ], col = cols[i], lwd = 2.4)
  abline(v = log(c(cvf$lambda.min, cvf$lambda.1se)), lty = c(2, 3), col = pal["ink"])
  legend("topright", bty = "n", cex = 0.85, lwd = 2.4, col = cols, legend = labs)
}

#@ fig_vif
fig("vif", 6.2, 3.1)
par(mar = c(3.6, 8.6, 0.8, 1))
v <- sort(car::vif(mod.1))
bp <- barplot(log10(v), horiz = TRUE, names.arg = names(v), col = ifelse(v >= 10, pal["ucm"], "#b9b8b2"),
              border = NA, xlab = "VIF (escala logarítmica)", xaxt = "n", cex.names = 0.8, xlim = c(0, 5.6))
axis(1, at = 0:5, labels = c(1, 10, 100, "1 000", "10 000", "100 000"))
abline(v = 1, lty = 2, col = pal["ink"])
text(1, max(bp) + 0.95, "VIF = 10", pos = 4, cex = 0.8, xpd = NA)
dev.off()

#@ fig_ridge_trace
fig("ridge_trace", 4.4, 2.8)
plot_path(fit.ridge, hi = match(c("Min.Price", "Price", "Max.Price"), rownames(fit.ridge$beta)),
          cols = pal[c("ridge", "lasso", "enet")], cvf = cv.ridge,
          labs = c("Min.Price", "Price", "Max.Price"))
dev.off()

#@ fig_cv_ridge
fig("cv_ridge", 4.4, 2.8); plot_cv(cv.ridge, pal["ridge"]); dev.off()

#@ fig_cv_lasso
fig("cv_lasso", 4.4, 2.8); plot_cv(cv.lasso, pal["lasso"]); dev.off()

#@ fig_cv_enet
fig("cv_enet", 6.2, 2.7); plot_cv(cv.enet, pal["enet"]); dev.off()

#@ fig_lasso_path
fig("lasso_path", 4.4, 2.8)
plot_path(fit.lasso, hi = match(c("Weight", "Fuel.tank.capacity", "Rev.per.mile"), rownames(fit.lasso$beta)),
          cols = pal[c("lasso", "ridge", "enet")], cvf = cv.lasso,
          labs = c("Weight", "Fuel.tank.capacity", "Rev.per.mile"))
dev.off()

#@ fig_cv_alpha
fig("cv_alpha", 6.2, 2.9)
cols.a <- colorRampPalette(c("#a9c9f0", "#0B3C70"))(length(alphas))
plot(NA, xlim = range(log(unlist(lapply(cv.grid, function(f) f$lambda)))),
     ylim = c(min(sapply(cv.grid, function(f) min(f$cvm))) * 0.95, 16),
     xlab = expression(log(lambda)), ylab = "ECM de validación cruzada")
grid(col = pal["grid"], lty = 1)
for (i in seq_along(alphas)) lines(log(cv.grid[[i]]$lambda), cv.grid[[i]]$cvm, col = cols.a[i], lwd = 2)
legend("topleft", bty = "n", lwd = 2, col = cols.a, cex = 0.85, title = expression(alpha),
       legend = alphas)
dev.off()

#@ fig_coef
fig("coef", 6.2, 3.3)
par(mar = c(3.6, 8.6, 0.8, 1))
tb <- tab[-1, -1]; tb <- tb[order(abs(tb[, "ridge"])), ]
plot(NA, xlim = range(tb), ylim = c(0.5, nrow(tb) + 0.5), yaxt = "n", xlab = "Coeficiente estandarizado", ylab = "")
abline(h = seq_len(nrow(tb)), col = pal["grid"]); abline(v = 0, col = pal["ols"], lty = 2)
axis(2, at = seq_len(nrow(tb)), labels = rownames(tb), cex.axis = 0.75, tick = FALSE)
points(tb[, "ridge"], seq_len(nrow(tb)), pch = 16, col = pal["ridge"], cex = 1.1)
points(tb[, "lasso"], seq_len(nrow(tb)), pch = 17, col = pal["lasso"], cex = 1.1)
points(tb[, "EN"],    seq_len(nrow(tb)), pch = 15, col = pal["enet"],  cex = 1.0)
legend("bottomleft", bty = "n", cex = 0.85, pch = c(16, 17, 15), col = pal[c("ridge", "lasso", "enet")],
       legend = c("Ridge", "Lasso", "Elastic net (0.5)"))
dev.off()

#@ fig_rmse
fig("rmse", 6.2, 2.7)
par(mar = c(3.6, 5.2, 0.8, 1))
boxplot(res, horizontal = TRUE, las = 1, col = c("#b9b8b2", "#b9b8b2", pal[c("ridge", "lasso", "enet")]),
        border = pal["ols"], xlab = "RMSE de prueba (200 particiones 80/20)", outline = TRUE, pch = 16, cex = 0.5)
dev.off()

#@ fig_sim
fig("sim", 6.2, 2.8)
m <- rbind(Lasso = res.sim$ambos.lasso, `Elastic net` = res.sim$ambos.EN) * 100
colnames(m) <- paste0("ρ = ", format(res.sim$rho, nsmall = 2), ",  β = ", res.sim$beta)
bp <- barplot(m, beside = TRUE, col = pal[c("lasso", "enet")], border = NA, ylim = c(0, 128),
              ylab = "% de réplicas con x1 y x2", cex.names = 0.78, yaxt = "n")
axis(2, at = seq(0, 100, 25))
text(bp, m + 5, sprintf("%.0f", m), cex = 0.75, col = pal["ink"])
legend("top", bty = "n", cex = 0.85, fill = pal[c("lasso", "enet")], border = NA,
       legend = c("Lasso", "Elastic net (0.5)"), horiz = TRUE)
dev.off()

#@ fig_df
fig("df", 3.7, 3.25)
ll <- seq(-6, 6, length.out = 400)
plot(ll, sapply(exp(ll), df.r), type = "l", lwd = 2.4, col = pal["ridge"],
     xlab = expression(log(lambda)), ylab = "Grados de libertad efectivos",
     ylim = c(0, ncol(X)))
grid(col = pal["grid"], lty = 1)
lines(ll, sapply(exp(ll), df.r), lwd = 2.4, col = pal["ridge"])
abline(v = log(c(cv.ridge$lambda.min, cv.ridge$lambda.1se)), lty = c(2, 3), col = pal["ink"])
legend("topright", bty = "n", cex = 0.8, lty = c(2, 3), col = pal["ink"],
       legend = c(expression(lambda[min]), expression(lambda[1*se])))
dev.off()

#@ fig_lambda
fig("lambda", 3.7, 3.25)
s2 <- 1; b <- 1.5                      # diseño ortonormal ilustrativo
ll <- seq(-4, 4, length.out = 400); l <- exp(ll)
sesgo2 <- (l * b / (1 + l))^2; varz <- s2 / (1 + l)^2; ecm <- sesgo2 + varz
plot(ll, ecm, type = "n", ylim = c(0, max(ecm) * 1.05),
     xlab = expression(log(lambda)), ylab = "Error")
grid(col = pal["grid"], lty = 1)
lines(ll, ecm, lwd = 2.6, col = pal["ucm"])
lines(ll, sesgo2, lwd = 2.2, col = "#C8962E")
lines(ll, varz, lwd = 2.2, col = pal["ols"], lty = 2)
abline(v = log(s2 / b^2), lty = 3, col = pal["ink"])
points(log(s2 / b^2), s2 * b^2 / (s2 + b^2), pch = 19, col = pal["ucm"])
text(log(s2 / b^2) + 0.15, 0.12, expression(lambda^"*"), adj = 0, cex = 0.9)
text(-4, s2 + 0.1, "MCO", adj = 0, cex = 0.8, col = pal["ols"])
legend("right", bty = "n", cex = 0.8, lwd = c(2.6, 2.2, 2.2), lty = c(1, 1, 2),
       col = c(pal["ucm"], "#C8962E", pal["ols"]),
       legend = c("ECM", expression(sesgo^2), "varianza"))
dev.off()

#@ fig_soft
fig("soft", 3.7, 3.25)
b <- seq(-3, 3, length.out = 601); lam <- 1; al <- 0.5
S <- function(z, g) sign(z) * pmax(abs(z) - g, 0)
plot(b, b, type = "l", lty = 2, col = pal["ols"], xlab = expression(hat(beta)[j]~"(MCO)"), ylab = "Estimador penalizado")
grid(col = pal["grid"], lty = 1)
lines(b, b / (1 + lam), col = pal["ridge"], lwd = 2.4)
lines(b, S(b, lam), col = pal["lasso"], lwd = 2.4)
lines(b, S(b, lam * al) / (1 + lam * (1 - al)), col = pal["enet"], lwd = 2.4)
legend("topleft", bty = "n", cex = 0.8, lwd = c(1, 2.4, 2.4, 2.4), lty = c(2, 1, 1, 1),
       col = pal[c("ols", "ridge", "lasso", "enet")],
       legend = c("MCO", "Ridge", "Lasso", expression(paste("Elastic net, ", alpha == 0.5))))
dev.off()
