tabPanel(title="ClimPACT",value="frontPage",
  fluidPage(
    div(class = "jumbotron",
      div(class="container",
        h1(class="display-4", "ClimPACT"),
        p(class="lead", "An R software package that calculates ET-SCI indices.")
      )
    ),
    includeMarkdown(file.path("ui", "getting_started.md"))
  )
)
