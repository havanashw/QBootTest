
<!-- README.md is generated from README.Rmd. Please edit that file -->

# QBootTest

<!-- badges: start -->
<!-- badges: end -->

The goal of QBootTest is to conduct multiplier bootstrap tests for
high-dimensional quantile regression

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

set.seed(1)
n <- 80; p <- 50
x <- matrix(rnorm(n * p), n, p)
y <- rnorm(n)

QBootTest(x, y, tau = 0.5, method = "asymptotic")
#> [1] 0.3513358
```

### Multiplier bootstrap p-value

``` r
set.seed(1)
n <- 80; p <- 50
x <- matrix(rnorm(n * p), n, p)
y <- rnorm(n)

QBootTest(x, y, tau = 0.5, method = "bootstrap", multiplier = "gaussian", M = 200)
#> [1] 0.3432836
```

### Return test statistic and bootstrap draws (optional)

If you want the test statistic and bootstrap replicates for plots, use
`return_details = TRUE`

``` r
set.seed(1)
n <- 80; p <- 50
x <- matrix(rnorm(n * p), n, p)
y <- rnorm(n)

res <- QBootTest(x, y, tau = 0.5, method = "bootstrap", 
                 multiplier = "rademacher", M = 200,
                 return_details = TRUE)
str(res, max.level = 1)
#> List of 9
#>  $ pval           : num 0.348
#>  $ Tn             : num 1.02
#>  $ bootstrap_stats: num [1:200] 4.87 8.27 1 4.31 -1.6 ...
#>  $ method         : chr "bootstrap"
#>  $ multiplier     : chr "rademacher"
#>  $ M              : int 200
#>  $ tau            : num 0.5
#>  $ n              : int 80
#>  $ p              : int 50
```

## Notes

1.  $x$ should be an $n \times p$ numeric matrix and $y$ is a length-$n$
    numeric vector.

2.  Use `scale = TRUE` if you want to standardize $x$ and $y$ before
    computing the test.
