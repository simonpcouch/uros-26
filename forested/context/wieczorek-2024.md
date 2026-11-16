---
source: "White, G.W.; Wieczorek, J.A.; Cody, Z.W.; Tan, E.X.; Chistolini, J.O.; McConville, K.S.; Frescino, T.S.; Moisen, G.G. A method for empirically assessing small area estimators via bootstrap-weighted k-Nearest-Neighbor artificial populations, with applications to forest inventory. arXiv 2306.15607. Cited in the forested package documentation as Wieczorek et al. (2024)."
url: https://arxiv.org/abs/2306.15607
---

# FIA plots and auxiliary data definitions (Wieczorek et al.)

The forested package documentation cites this paper "for more on data definitions." Excerpts:

## The FIA plot grid

> The FIA program surveys a sample of field plot locations across the US based on a hexagonal grid. Each plot samples approximately 2.5 acres (1.0 ha) of land and represents approximately 6000 acres (2428 ha) of land within each hexagon (McRoberts et al. 2005; Bechtold and Patterson 2005).

## Auxiliary variables

> We also have auxiliary X-variables from satellites, climate records, and digital elevation models that were thought to relate to and discriminate our Y variables (Table 2). [...] All auxiliary data were resampled from their original resolution to 90x90m pixels. For each plot, we have the auxiliary data corresponding to that plot's location. [...] Some of our analyses in Supplementary material S.3 used tnt for post-stratification.

Table 2 of the paper, with the matching column in the forested package:

| Variable | forested column | Units | Description |
|---|---|---|---|
| tcc | `canopy_cover` | % | National Land Cover Dataset (NLCD) Analytical Tree Canopy Cover (Yang et al. 2018) |
| elev | `elevation` | meters | LANDFIRE 2010 DEM - elevation (U.S. Geological Survey 2019) |
| eastness | `eastness` | -100 to 100 | Transformed aspect degrees to eastness (U.S. Geological Survey 2019) |
| northness | `northness` | -100 to 100 | Transformed aspect degrees to northness (U.S. Geological Survey 2019) |
| ppt | `precip_annual` | mm × 100 | PRISM mean annual precipitation - 30yr normals (1991-2020) (Daly et al. 2002) |
| tmin01 | `temp_january_min` | °C | PRISM mean minimum temperature (Jan) - 30yr normals (Daly et al. 2002) |
| wc2cl | `land_type` | class | European Space Agency (ESA) 2020 WorldCover global land cover (Zanaga et al. 2021) |
| tnt | `tree_no_tree` | class | LANDFIRE 2014 tree/non-tree lifeform mask (Rollins 2009; Picotte et al. 2019) |

## Pixel-level data

> As a basis for the artificial population, besides the survey sample we also have complete auxiliary-only data for the full population: 11,752,067 pixels in the 4286 hexagons that fall within or overlap with EcoProvince M333. [...] We use an analysis function in the FIESTAnalysis R package (which is an extension of the FIESTA R package), anGetPixeldat(), to generate pixel-level data tables for each subsection.

## Data vintage

> The survey data comes from a panel design, in which different plots are sampled in different years; and the surveyed pixels' X variables may not be from the same year as the corresponding Y. Although most of the Xs change very slowly if at all from year to year (such as elevation or precipitation), others might be more timely (such as tcc, wc2cl, or tnt which should change as forests grow, become harvested, experience wildfires, etc.).
