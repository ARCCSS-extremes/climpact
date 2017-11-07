tabPanel(title="EXIT ClimPACT",
  #stopApp()
  #useShinyjs(),
   jscode <- "shinyjs.closeWindow = function() { window.close(); }",
   
   extendShinyjs(text = jscode, functions = c("closeWindow")),
   js$closeWindow(),
   stopApp()
)
