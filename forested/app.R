library(shiny)
library(shinychat)

source("agent.R")

greeting <- paste0(
  "Ask questions about Washington's forests, using Forest Inventory and ",
  "Analysis plot data.\n\n",
  "- <span class='suggestion'>What percentage of Washington is forested?</span>\n",
  "- <span class='suggestion'>Which county has the most forest?</span>\n",
  "- <span class='suggestion'>How has forest cover changed over time?</span>\n"
)

ui <- page_chat(
  list(),
  id = "chat",
  greeting = greeting,
  theme = commons_theme()
)

server <- function(input, output, session) {
  # Each recording starts from a fresh conversation.
  commons_server("chat", new_forested_agent(), history = FALSE)
}

shinyApp(ui, server)
