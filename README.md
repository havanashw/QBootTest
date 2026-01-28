
# QBootTest

The goal of QBootTest is to conduct multiplier bootstrap tests for high-dimensional quantile regression.

## Installation

You can install the development version from GitHub:

``` r
install.packages("remotes")
remotes::install_github("havanashw/QBootTest")
```

## Example

### Asymptotic p-value

``` r
library(QBootTest)
library(MASS)

set.seed(1)
n <- 80; p <- 50
beta.true <- rep(1, p)
Sig <- toeplitz(0.5^seq(0, p-1))
error <- rnorm(n)
x <- mvrnorm(n, mu=rep(0, p), Sigma=Sig)
y <- x%*%beta.true + error

QBootTest(x, y, tau = 0.5, method = "asymptotic")
#> [1] 0
```

### Multiplier bootstrap p-value

``` r
QBootTest(x, y, tau = 0.5, method = "bootstrap", multiplier = "gaussian", M = 200)
#> [1] 0.004975124
```

### Return test statistic and bootstrap draws (optional)

If you want the test statistic and bootstrap replicates for plots, use
`return_details = TRUE`:

``` r
res <- QBootTest(x, y, tau = 0.5, method = "bootstrap", 
                 multiplier = "rademacher", M = 200,
                 return_details = TRUE)
str(res, max.level = 1)
#> List of 9
#>  $ pval           : num 0.00498
#>  $ Tn             : num 31.6
#>  $ bootstrap_stats: num [1:200] -1.424 0.684 3.131 2.512 0.374 ...
#>  $ method         : chr "bootstrap"
#>  $ multiplier     : chr "rademacher"
#>  $ M              : int 200
#>  $ tau            : num 0.5
#>  $ n              : int 80
#>  $ p              : int 50
```

## Notes

1.  $x$ should be an $n \times p$ numeric matrix and $y$ is an $n$ numeric vector.

2.  Use `scale = TRUE` if you want to standardize $x$ and $y$ before computing the test.
