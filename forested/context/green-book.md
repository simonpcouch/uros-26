---
source: "Bechtold, W.A.; Patterson, P.L., eds. 2005. The enhanced forest inventory and analysis program—national sampling design and estimation procedures. Gen. Tech. Rep. SRS-80. Asheville, NC: U.S. Department of Agriculture, Forest Service, Southern Research Station. 85 p. (the 'green book')"
url: https://research.fs.usda.gov/treesearch/20371
---

# The FIA "green book": sampling design and estimation procedures

The green book documents the national sampling design and estimation procedures of the USDA Forest Service Forest Inventory and Analysis (FIA) program. FIA's standard estimator for forest area, including the share of a state's land area that is forested, is the post-stratified estimator described in chapter 4. The excerpts below are from sections 3.4.3, 4.2, 4.3, 5.1, and 5.2, lightly condensed. Equations were retyped from the PDF.

## 3.4.3 Nonsampled Plots and Plot Replacement

For various reasons, some plots (or portions of plots) within a given population cannot be sampled at the time they are scheduled for measurement. Such plots are classified as "nonsampled", a "nonsampled reason" is assigned, and no additional data are recorded. The magnitude of the problem has not been fully evaluated, but nonsampled plots have the potential to be a significant factor in populations with relatively few forested plots (e.g., Plains States). FIA currently assumes these plots are randomly distributed, so nonsampled plots assume the strata means for all estimated values as discussed in chapter 4, which ensures that estimates are produced for the entire population—not just the accessible portion. This approach presumes that conditions on nonsampled plots are missed at random, which may not be valid under some circumstances.

Access refusal by landowners is the most common reason for nonsampled plots, but plots occasionally are inaccessible due to hazardous situations encountered by field crews. To avoid altering the sampling network such that it becomes nonrepresentative of the population, inaccessible plots usually are not replaced.

## 4.2 Phase 1: stratification

Stratification is a statistical tool used to reduce the variance of attributes of interest by partitioning the population into homogenous strata, such as forest and nonforest. It may also involve partitioning out a highly variable but small portion of the population.

To use stratified sampling methods, the strata sizes (weights) must be either known or estimated. As discussed in chapter 2, strata weights commonly are estimated by classifying points on aerial photographs or pixels on satellite imagery. Full enumeration of an entire landscape (population) is possible with wall-to-wall satellite imagery, resulting in strata weights that can be treated as known values in the variance formulations. Whether the strata weights are known or estimated, strata classifications (e.g., forest and nonforest) from remote sensing are never perfectly accurate. Although this increases the variance of the resulting population estimates, it does not introduce any bias due to the interaction between Phases 1 and 2 in the estimation process.

### 4.2.1 Satellite Classification and Known Strata Weights

Using wall-to-wall satellite imagery and computer-aided classification, the population can be divided into strata of known size—typically forest, noncensus water, nonforest, or combinations of these. In this case the classified imagery divides the total area of the population (A_T) into pixels of equal and known size (e.g., 30 m square with Landsat TM), and the classification assigns one of H strata to each of these pixels. Here, the stratum weight, W_h (h = 1,…,H), typically is determined as the number of pixels classified as stratum h divided by the total number pixels in the population of interest. The weights are known quantities that are fixed by the classification system and selected strata. Each stratum, h, then contains n_h ground plots, each selected with known probability, where the Phase 2 attributes of interest are observed. Note that the strata sample sizes, n_h, are random because ground-plot locations are chosen prior to stratification.

When using classified satellite imagery for stratification, one must know the location of each plot and each pixel, so that plots and pixels can be linked in the estimation process. FIA assigns each plot to one and only one stratum using the pixel corresponding to plot center.

It is also important to remember the importance of the pixel-plot link when changing or considering a change in the stratification algorithm. Two similar algorithms may divide a population into very similar strata that have similar or identical names. The application of a different classification system will not only change the W_h (even when they have identical names), but also the strata assignments of ground plots.

### 4.2.3 Combining Small Strata and Populations

Because sample sizes are random with respect to strata, some may contain too few plots to compute a reliable mean and variance. Experience indicates that a minimum of four Phase 2 plots per stratum are required. If less than four, then similar strata must be collapsed (combined) until the minimum is attained.

The minimum-sample-size rule also affects some small populations or populations with little forest (e.g., some counties in the Eastern or Great Plains regions of the United States). Populations with fewer than 12 forested Phase 2 plots should thus be combined with adjoining counties (i.e., populations) forming what is termed as a "super-county." The use of super-counties will be especially important when using only a subset of panels.

## 4.3 Phase 2: estimation

Generally, these attributes are summed for each plot (after adjustment to correct for any plots that overlap the population boundary), and then averaged across plots in the stratum. The strata means are then combined using the Phase 1 strata weights to form a population mean. This mean is then expanded to a total using the total land area in the population.

For area estimation, the attribute of interest on each plot, P_hid, is the proportion of plot i in stratum h that falls in the domain of interest d (for example, forest land).

### 4.3.1.3 Compute Strata Means and Variances

Plot values are averaged within each stratum. In the case of simple random sampling, this is the final estimate because simple random sampling is just stratified sampling with a single stratum.

The stratum mean is the sum of the plot observations, P_hid, divided by the number of plots in the stratum, n_h:

```
(4.3)  Pbar_hd = (1 / n_h) * sum_i P_hid
```

with variance estimator:

```
(4.4)  v(Pbar_hd) = sum_i (P_hid - Pbar_hd)^2 / (n_h * (n_h - 1))
```

Note that Pbar_hd is the mean of field-based observations in domain d within each Phase 1 stratum. This means that some plots classified as forest on the ground may have been assigned to a nonforest stratum and vice versa. These are not viewed as "misclassifications", but as strata with less than ideal homogeneity. The estimators remain unbiased.

### 4.3.2 Estimation of Population Totals and Their Variances

Nonsampled plots present an estimation problem that requires more attention than plots that are otherwise out of the population. Because field crews cannot reliably ascertain the actual land use of such plots, initial area tables in FIA reports will report the proportion of total area designated as nonsampled. However, in all subsequent tables, these plots (or the nonsampled portions of them) will be processed as if they were out of the population. This approach either reduces the sample size (n_h), or the mean proportion of stratum h observed plot areas falling within the population, or both. The result is to adjust upward the number of acres represented by the accessed plots, or portions of them, in each stratum. Thus the area that could not be accessed is redistributed based on the accessible plots within each stratum. This essentially replaces nonsampled plots with the strata means and increases the strata variances due to the reduction in sample size. This approach has the advantage of simplicity, but has the potential to incur bias if the nonsampled plots are not representative of the rest of the population.

In the simple random sampling case, there is only one stratum, so totals are estimated by multiplying the population mean by the total area in the population. FIA rarely uses simple random sampling, but it has been used for Forest Health Monitoring (FHM) and is useful in responding to special requests where stratification data may be lacking.

To estimate the total area in each domain when the population has been stratified, the strata means are averaged using the strata weights and then multiplied by the total land area in the population. The estimated total is given for the stratified estimation case as:

```
(4.5)  Ahat_d = A_T * Phat_d,  where  Phat_d = sum_h W_h * Pbar_hd
```

where A_T = total area in the population in acres, Phat_d = estimated proportion of the population in the domain of interest d, and W_h = weight for stratum h (i.e., the proportion of the population area, A_T, that is in stratum h).

An approximation of the variance of the total area in the stratified estimation (and the simple random sampling) case, where strata sizes are known, is adapted from equation 5A.42 in Cochran's (1977) finite sampling framework. An estimate of this population variance (finite population correction factors ignored) is given by:

```
(4.6)  v(Ahat_d) = (A_T^2 / n) * [ sum_h W_h * n_h * v(Pbar_hd)
                                   + sum_h (1 - W_h) * (n_h / n) * v(Pbar_hd) ]
```

The first term is for stratification, assuming proportional allocation, and the second term reflects the fact that the sample sizes are not fixed by strata in advance.

Totals and their variances from different populations are additive. Thus the variance of a total across multiple populations or subpopulations is the sum of their variances.

## 5.1 Single Panels vs. Multiple Panels

FIA measures a fraction of its plots, a panel, each year, and a full set of panels makes up an inventory cycle. Note that FIA assumes complete spatial coverage for each panel across the population of interest. When estimating inventory attributes for a single panel, the estimation approach proceeds as outlined in chapter 4.

A single panel has sampling errors that are sqrt(P) times larger than when using all P panels. However, as FIA moves to the annual system this will cause a short-term problem for analysts who must report results from only one or two panels of data.

FIA uses panels to measure both current inventory and change. One method uses the net difference between two sequential, but different, panels. Measuring different panels over time yields estimates of net change, but only remeasured panels can provide information about specific components of change behind the net change.

## 5.2 Combining Panels

There is currently no prescribed core procedure for combining panels. Whatever estimation strategy is used to estimate current conditions, variance reduction usually can be attained by combing current data with earlier data from previous panels.

### 5.2.1 The Moving Average Method

Because the moving average (MA) is a weighted sum of estimates across all panels of interest, it can be viewed as an estimate of the attribute of interest at some time between the first and last years of the time period from which the panels were drawn. Moving averages and related techniques result in estimators that dampen trends by obscuring annual fluctuations, and in that sense do not measure the current status of a finite population, but rather a temporal average of that population. However, in the absence of some widespread catastrophic event, the smoothing and lag effects of moving averages usually will be inconsequential and more than offset by the reduction in variance acquired from using the maximum number of available panels (Johnson and others 2003).

### 5.2.2 The Temporally Indifferent Method

The temporally indifferent (TI) method differs from the MA method in that all panels of interest are pooled into the equivalent of one large periodic inventory, and the same Phase 1 stratification is applied across all panels. Although this approach lacks some of the flexibility offered by alternative methods of combining panels, it does have advantages over periodic inventories because individual panels can be used to produce spatially unbiased estimates before the results of a complete periodic inventory are available.

The TI method is simpler than the MA approach in that estimation proceeds directly as specified in chapter 4, without the added complication of weighting. In addition to simplicity, use of the TI method may be advantageous when sample sizes per panel are small. When this is the case, the larger sample sizes per stratum attained with the TI method could reduce the variance considerably more than the MA alternative.
