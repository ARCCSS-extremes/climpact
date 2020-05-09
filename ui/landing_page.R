tabPanel(title="ClimPACT", value="frontPage",
  div(class = "jumbotron",
    div(class="container",
      h1(class="display-4", "ClimPACT"),
      p(class="lead", "An R software package that calculates ET-SCI indices.")
    )
  ),
  div(class="landing-content",
    includeMarkdown(file.path("ui", "getting_started.md"))
  ),
  div(class="photo-credit", HTML("Background photo by Dominik Schr&ouml;der on Unsplash"))
)
