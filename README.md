
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{quadrige.explorer}`

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of `{quadrige.explorer}` like
so:

``` r
install_github("FlorenceMounier/quadrige.explorer")
```

## Run

You can launch the application by running:

``` r
quadrige.explorer::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-07-04 10:38:27 CEST"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading quadrige.explorer
#> ── R CMD check results ─────────────────────── quadrige.explorer 0.0.0.9000 ────
#> Duration: 1m 16.3s
#> 
#> ❯ checking code files for non-ASCII characters ... WARNING
#>   Found the following file with non-ASCII characters:
#>     R/mod_exploration_raw_data.R
#>   Portable packages must use only ASCII characters in their R code and
#>   NAMESPACE directives, except perhaps in comments.
#>   Use \uxxxx escapes for other characters.
#>   Function 'tools::showNonASCIIfile' can help in finding non-ASCII
#>   characters in files.
#> 
#> ❯ checking for missing documentation entries ... WARNING
#>   Objets code non documentés :
#>     'data_benthos' 'data_contamination' 'sextant_outputs'
#>   Jeux de données non documentés :
#>     'data_benthos' 'data_contamination' 'sextant_outputs'
#>   All user-level objects in a package should have documentation entries.
#>   See chapter 'Writing R documentation files' in the 'Writing R
#>   Extensions' manual.
#> 
#> ❯ checking LazyData ... WARNING
#>     LazyData DB of 9.1 MB without LazyDataCompression set
#>     See §1.1.6 of 'Writing R Extensions'
#> 
#> ❯ checking installed package size ... NOTE
#>     installed size is  9.3Mb
#>     sub-directories of 1Mb or more:
#>       data   9.1Mb
#> 
#> ❯ checking package subdirectories ... NOTE
#>   Problems with news in 'NEWS.md':
#>   No news entries found.
#> 
#> ❯ checking R code for possible problems ... NOTE
#>   mod_exploration_raw_data_server : <anonymous>: no visible global
#>     function definition for 'year'
#>   mod_exploration_raw_data_server : <anonymous>: no visible global
#>     function definition for 'element_text'
#>   Undefined global functions or variables:
#>     element_text year
#> 
#> 0 errors ✔ | 3 warnings ✖ | 3 notes ✖
#> Error: R CMD check found WARNINGs
```
