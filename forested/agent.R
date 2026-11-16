library(commons)

new_forested_agent <- function(
  client = ellmer::chat_openai(model = "gpt-5.6-luna")
) {
  agent(client, commons = forested_commons(), instructions = "instructions.md")
}

forested_commons <- function() {
  commons(
    data_sources = list(
      fia = data_source(
        plots = forested::forested,
        strata = stratum_weights(),
        dictionary = "dictionaries/fia.yaml"
      )
    ),
    semantic_layer = semantic_layer("measures"),
    context_layer = context_layer(
      list.files("context", pattern = "\\.md$", full.names = TRUE)
    )
  )
}

# Illustrative weights for the demo, chosen so the post-stratified estimate
# matches the 59.2% in the talk; real weights would be LANDFIRE pixel counts.
stratum_weights <- function() {
  data.frame(stratum = c("Tree", "No tree"), weight = c(0.58, 0.42))
}
