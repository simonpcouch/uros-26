---
source: "White, G.W.; Yamamoto, J.K.; Elsyad, D.H.; Schmitt, J.F.; Korsgaard, N.H.; Hu, J.K.; Gaines III, G.C.; Frescino, T.S.; McConville, K.S. (2024). Small area estimation of forest biomass via a two-stage model for continuous zero-inflated data. arXiv 2402.03263 (ver. 2.0)."
url: https://arxiv.org/abs/2402.03263
---

# FIA's standard post-stratified estimator (White et al. 2024)

The forested package documentation cites this paper (Table 1) for more information on its source data. Excerpts:

## FIA's standard estimator

> FIA's standard estimator is a direct, design-based and model-assisted, post-stratified estimator (Bechtold and Patterson 2005). This estimator combines plot-level data with a single categorical auxiliary variable and can be represented as a weighted sum of sample means within post-strata.
>
> When these post-strata are homogeneous within- and heterogeneous between- post-strata, the post-stratified estimator allows for variance reduction over a Horvitz-Thompson estimator. However, as mentioned above, this estimator provides insufficient precision for small areas of interest with few numbers of plots.

## How the post-stratified estimator is built

> The post-stratified estimator is the result of taking a weighted sum of Horvitz-Thompson estimates that are built over the H post-strata of a single categorical auxiliary variable within a small area, with individual post-strata indexed by h. Each weight is simply the proportion of population units in that small area that belong to the corresponding post-stratum. In our case, we use the binary categorical auxiliary variable that classifies each unit in the population into either a forested or non-forested post-stratum, so H = 2.

In the paper's notation, for small area j with N_j population units (pixels), N_jh of them in post-stratum h, and n_jh sampled plots in post-stratum h:

```
muhat_PS_j = sum_h (N_jh / N_j) * muhat_HT_jh
```

where muhat_HT_jh is the sample mean of the plots in post-stratum h.

## Data

> Further, we have wall-to-wall auxiliary data from a variety of remotely-sensed and climatic raster files, which have all been resampled to a 90m × 90m pixel size. [...] The FIA ground plots and auxiliary data were extracted and matched with the FIESTA R package (Frescino, Moisen, et al. 2023).

> For this data application, only tree canopy cover and elevation were used as auxiliary variables in the models for the model-based estimators, and the binary tree/non-tree variable for the post-stratified estimator.

## Measurement years

> [W]e treat only plots measured in the most recent measurement year (2019) of data as our sample. This approximately reduces our sample size by a factor of 10 and focuses the estimators on estimating average square root biomass in 2019 rather than implicitly assuming domain stasis over the 10-year FIA inventory cycle by incorporating all measurements, irrespective of their measurement year, into domain status estimates.
