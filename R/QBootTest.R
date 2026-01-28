#' Multiplier bootstrap tests for high-dimensional quantile regression
#'
#' @param x Numeric matrix of predictors with dimension n x p.
#' @param y Numeric response vector of length n.
#' @param tau Quantile level in (0, 1). Default is 0.5.
#' @param method Either "asymptotic" or "bootstrap".
#' @param multiplier Either "gaussian" or "rademacher". Used when method = "bootstrap".
#' @param M Number of bootstrap replicates. Used when method = "bootstrap".
#' @param scale Logical; if TRUE, standardize x and y.
#' @param return_details Logical; if TRUE, return a list with statistic and settings.
#'
#' @return If return_details = FALSE (default), returns a single p-value.
#' If TRUE, returns a list with elements pval, Tn, Tn_std (if asymptotic),
#' and bootstrap_stats (if bootstrap).
#'
#' @examples
#' set.seed(1)
#' n <- 80; p <- 50
#' x <- matrix(rnorm(n * p), n, p)
#' y <- rnorm(n)
#' quantile_score_test(x, y, tau = 0.5, method = "asymptotic")
#' quantile_score_test(x, y, tau = 0.5, method = "bootstrap", M = 200)
#'
#' @export
QBootTest <- function(x, y, tau = 0.5,
                      method = c("asymptotic", "bootstrap"),
                      multiplier = c("gaussian", "rademacher"),
                      M = 500, scale = FALSE,
                      return_details = FALSE) {

  method <- match.arg(method)
  multiplier <- match.arg(multiplier)

  # basic checks
  if (!is.matrix(x)) x <- as.matrix(x)
  if (!is.numeric(x)) stop("`x` must be numeric.")
  if (!is.numeric(y)) stop("`y` must be numeric.")
  n <- nrow(x); p <- ncol(x)
  if (length(y) != n) stop("Length of `y` must match nrow(x).")
  if (!is.finite(tau) || tau <= 0 || tau >= 1) stop("`tau` must be in (0, 1).")
  if (!is.numeric(M) || length(M) != 1 || M < 1) stop("`M` must be a positive integer.")
  M <- as.integer(M)

  if (isTRUE(scale)) {
    x <- base::scale(x)
    y <- as.numeric(base::scale(y))
  }

  # psi_tau(y) = tau - I(y < 0)
  err <- rep(tau, n) - as.numeric(y < 0)

  # x.mat = X X^T
  x.mat <- x %*% t(x)

  # Tn = (sum_{i!=j} err_i err_j x_i^T x_j) / n
  err.mat <- outer(err, err, "*")
  A <- err.mat * x.mat
  Tn <- (sum(A) - sum(diag(A))) / n

  if (method == "asymptotic") {
    # tr(Sigx^2) estimator based on x.mat
    x2 <- x.mat^2
    tr.Sigx2.hat <- (sum(x2) - sum(diag(x2))) / (n * (n - 1))
    sigma.hat <- tau * (1 - tau)
    Tn.std <- Tn / (sigma.hat * sqrt(2 * tr.Sigx2.hat))
    pval <- 1 - stats::pnorm(Tn.std)

    if (!return_details) return(pval)
    return(list(
      pval = pval,
      Tn = Tn,
      Tn_std = Tn.std,
      method = method,
      tau = tau,
      n = n,
      p = p
    ))
  }

  # bootstrap
  Tn.bootstrap <- switch(
    multiplier,
    gaussian = {
      vapply(seq_len(M), function(i) {
        e <- stats::rnorm(n)
        e.mat <- outer(e, e, "*")
        B <- A * e.mat
        (sum(B) - sum(diag(B))) / n
      }, numeric(1))
    },
    rademacher = {
      vapply(seq_len(M), function(i) {
        e <- 2 * (stats::rbinom(n, 1, 0.5) - 0.5)
        e.mat <- outer(e, e, "*")
        B <- A * e.mat
        (sum(B) - sum(diag(B))) / n
      }, numeric(1))
    }
  )

  pval <- (sum(Tn.bootstrap >= Tn) + 1) / (M + 1)

  if (!return_details) return(pval)
  list(
    pval = pval,
    Tn = Tn,
    bootstrap_stats = Tn.bootstrap,
    method = method,
    multiplier = multiplier,
    M = M,
    tau = tau,
    n = n,
    p = p
  )
}
