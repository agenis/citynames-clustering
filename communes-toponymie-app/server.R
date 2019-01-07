function(input, output, session) {

  vals = reactiveValues(
    toplot = NULL
  )
  
  observeEvent(list(input$mycity_raw, input$mymetric, input$maxnum), eventExpr = {
    
    newname = com[com$nom_brut==input$mycity_raw, "nom"]
    if (input$mymetric=="4gram"){
      vals$toplot <- com %>% mutate(d_city = metric_3gram(newname, nom)) %>% arrange(d_city) %>% head(input$maxnum)
    } else if(input$mymetric=="3gram"){
      vals$toplot <- com %>% mutate(d_city = metric_4gram(newname, nom)) %>% arrange(d_city) %>% head(input$maxnum)
    } else if(input$mymetric=="Levenshtein"){
      vals$toplot <- com %>% mutate(d_city = metric_lv(newname, nom)) %>% arrange(d_city) %>% head(input$maxnum)
    } else if(input$mymetric=="mixed"){
      vals$toplot <- com %>% mutate(d_city = metric_mixed(newname, nom)) %>% arrange(d_city) %>% head(input$maxnum)
    }
    
  })
  
  
  output$map <- renderPlot({
    plotfunc(vals$toplot)
  })
  
  output$top50 = renderTable({
    vals$toplot %>% select(nom_brut, dpmt, 'score'=d_city)
      })
  
}