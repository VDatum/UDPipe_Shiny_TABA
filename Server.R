#Start of server code
shinyServer(function(input, output) {
  
  #Module to input data from user  
  
  # Input from user is in rective mode since the data should change with every change in input data  
  Dataset <- reactive({
    if (is.null(input$file1)) { return(NULL) }  #here we have used file1 since the UI.r has the same name
    else{
      text<- readLines(input$file1$datapath) #readline function to read the input from user
      text = str_replace_all(text, "<.*?>","") # stringr library has the function str_replace_all to clean the corpus
      text=text[text!=""] #selecting not null text
      return(text) # return cleaned corpus
    }
  })
  
  # uploading the input module  
  
  model = reactive({
    
    if(input$radio==1)
    {model = udpipe_load_model("english-ud-2.0-170801.udpipe")}
    if(input$radio==2)
    {model = udpipe_load_model("spanish-ud-2.0-170801.udpipe")}
    if(input$radio==3)
    {model = udpipe_load_model("hindi-ud-2.0-170801.udpipe")}
    return(model)
  })
  
  #passing the input data and english model to the UDpipe annotate function  
  
  annot.obj =reactive({
    x<-udpipe_annotate(model(),x=Dataset())
    x<-as.data.frame(x)
    return(x)
  })
  
  #--------------tab panel 2 outputs--------------------#   
  
  # module to let the user download the annotated data as a csv input  
  output$downloadData <- downloadHandler(
    filename=function(){
      "annonated_data.csv" #name of the downloaded file
    },
    content = function(file) {
      write.csv(annot.obj()[,-4],file,row.names=FALSE) #writing the output as a csv after removing the sentence column
    })
  
  # module to display the top 100 rows of the annotated corpus. we have intentionally hidden the sentence field    
  output$dout1 = renderDataTable({
    if(is.null(input$file1)) {return (NULL)} #exception handler in case the file is empty
    else{
      out=annot.obj ()[,-4]
      return(head(out,100))
    }
  })
  
  #--------------tab panel 3 outputs--------------------# 
  
  #module to print a wordcloud for nouns
  
  output$plot1 = renderPlot({
    
    if(is.null(input$file1)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      all_nouns=annot.obj() %>% subset(.,upos %in% "NOUN") #filtering the corpus for nouns
      top_nouns =txt_freq(all_nouns$lemma) # count of each noun terms
      wordcloud(top_nouns$key,top_nouns$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(8,"Dark2")) # plotting on a word cloud
    }
    
  })
  
  #module to print a wordcloud for verbs
  
  output$plot2 = renderPlot({
    
    if(is.null(input$file1)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      all_verbs=annot.obj() %>% subset(.,upos %in% "VERB") #filtering the corpus for verbs
      top_verbs =txt_freq(all_verbs$lemma)  # count of each verbs terms
      #head(top_verbs,10)
      wordcloud(top_verbs$key,top_verbs$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(8,"Dark2")) # plotting on a word cloud
    }
    
  })
  
  #--------------tab panel 4 output--------------------#   
  
  output$plot3 = renderPlot({
    
    if(is.null(input$file1)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      data_cooc<-cooccurrence(
        x=subset(annot.obj(),upos %in% input$upos), #collecting required upos from user input and filtering the annonated corpus
        term="lemma", #paramerter to specify the extraction terms as lemma
        group=c("doc_id","paragraph_id","sentence_id"))
      
      
      # creation of co-occurrence graph
      wordnetwork<- head(data_cooc,50)
      wordnetwork<-igraph::graph_from_data_frame(wordnetwork)
      
      #plotting the graph
      ggraph(wordnetwork,layout="fr") +
        geom_edge_link(aes(width=cooc,edge_alpha=cooc),edge_colour="orange")+
        geom_node_text(aes(label=name),col="darkgreen", size=4)+
        theme_graph(base_family="Arial Narrow")+
        theme(legend.position="none")+
        
        labs(title= "Cooccurrences Plot")
    }
    
  })
  
})

