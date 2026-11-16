# Forested commons agent

A commons agent over `forested::forested` (FIA plots in Washington) for the commons demo in the talk. From the talk repository root:

```r
shiny::runApp("forested")
```

The pieces:

- `measures/forest-area.R`: the trusted calculation, `pct_forested_post_stratified()`, FIA's post-stratified estimator from the green book (Bechtold and Patterson 2005, eqs. 4.3-4.6), post-stratified by `tree_no_tree`.
- `dictionaries/fia.yaml`: a data dictionary for the `plots` and `strata` tables.
- `context/`: excerpts from the green book and the three references in `?forested`.
- `agent.R`: builds the agent; `instructions.md` is appended to its system prompt.

The stratum weights in `agent.R` are illustrative, not LANDFIRE pixel counts for Washington. They're set so the trusted estimate is 59.2% (SE 0.4%, 58.4% to 59.9%), matching the intro. The unweighted share of forested plots is 54.8%.
