test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("QBootTest returns p-value in [0,1]", {
  set.seed(1)
  n <- 60; p <- 30
  x <- matrix(rnorm(n * p), n, p)
  y <- rnorm(n)

  p1 <- quantile_score_test(x, y, method = "asymptotic")
  expect_true(is.numeric(p1) && length(p1) == 1)
  expect_true(p1 >= 0 && p1 <= 1)

  p2 <- quantile_score_test(x, y, method = "bootstrap", M = 50)
  expect_true(is.numeric(p2) && length(p2) == 1)
  expect_true(p2 >= 0 && p2 <= 1)
})
