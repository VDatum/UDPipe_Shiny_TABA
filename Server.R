#Server code of the Shiny Web app'n
library(shiny)

#Defining the Shiny Server function with input and output passed to it : 
shinyServer(function(input, output) {
  storeWarn<- getOption("warn")
  options(warn = -1) 
  # I/p is reactive so as to be dynamic
  #Reading the text file using the standard upload functionality and returning the cleaned text  here below :
  data_file <- reactive({
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    if (is.null(input$file_input)) { return(NULL) }  #we check if the file_input used is null or not since the UI.r has the same name
    else{
      text<- readLines(input$file_input$datapath,encoding='UTF-8') #The Readlines function to read the input file from user , who has to upload the file [text]
      text = str_replace_all(text, "<.*?>","") # clean the corpus text
      text=text[text!=""] #selecting all except null text
      return(text) # return the cleaned corpus text
    }
  })
  
  # uploading the udpipe_model function [ Languages included : English, Spanish and Hindi ]
  # Giving option to upload trained udpipe udpipe_model for different languages as specified above
  
  udpipe_model = reactive({
    
    if(input$radio==1)
    {udpipe_model = udpipe_load_model("english-ud-2.0-170801.udpipe")}
    if(input$radio==2)
    {udpipe_model = udpipe_load_model("hindi-ud-2.0-170801.udpipe")}
    if(input$radio==3)
    {udpipe_model = udpipe_load_model("spanish-ud-2.0-170801.udpipe")}
    return(udpipe_model)
  })
  
  #passing the input data uploaded to the UDpipe annotate function  
  
  annot.obj =reactive({
    x<-udpipe_annotate(udpipe_model(),x=data_file())
    x<-as.data.frame(x)
     
    return(x)
  })
  
 
  
  # letting the user download the annotated data as a csv file 
  output$downloadData <- downloadHandler(
    filename=function(){
      "annonated_data.csv" #name of the downloaded file
    },
    content = function(file) {
      write.csv(annot.obj()[,-4],file,row.names=FALSE)
    })
  
  # Display the rows of annotated corpus text. 
  output$dout1 = renderDataTable({
    if(is.null(input$file_input)) {return (NULL)}
    else{
      out=annot.obj ()[,-4]
      return(head(out,100))
    }
  })
  
  
  
  #Nouns Wordcloud
  
  output$plot_nouns = renderPlot({
    
    if(is.null(input$file_input)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      if(input$radio==2) {
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    }
      all_nouns=annot.obj() %>% subset(.,xpos %in% "NN") #filtering the corpus text for nouns
      top_nouns =txt_freq(all_nouns$lemma) # count of each noun terms in the text
      wordcloud(top_nouns$key,top_nouns$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(7,"Dark2"))
    }
    
  })
  
  #Word Plot for Adjectives
  output$plot_adjectives = renderPlot({
    
    if(is.null(input$file_input)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      if(input$radio==2) {
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    }
      all_adjs=annot.obj() %>% subset(.,xpos %in% "JJ") #filtering the corpus text for adjectives
      top_adjs =txt_freq(all_adjs$lemma) # count of each adjectives terms in the text
      wordcloud(top_adjs$key,top_adjs$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(7,"Dark2"))
    }
    
  })
  
  #Word Plot for Proper Nouns
   output$plot_propernouns= renderPlot({
    
    if(is.null(input$file_input)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      if(input$radio==2) {
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    }
      all_prpn=annot.obj() %>% subset(.,xpos %in% "NNP") #filtering the corpus text for proper nouns
      top_prpn =txt_freq(all_prpn$lemma) # count of each proper noun terms in the text
      wordcloud(top_prpn$key,top_prpn$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(7,"Dark2"))
    }
    
  })
  
  
  #Verbs Wordcloud
  
  output$plot_verbs = renderPlot({
    
    if(is.null(input$file_input)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      if(input$radio==2) {
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    }
      all_verbs=annot.obj() %>% subset(.,xpos %in% "VB") #filtering the corpus text for verbs
      top_verbs =txt_freq(all_verbs$lemma)  # count of each verbs terms in the text
      wordcloud(top_verbs$key,top_verbs$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(7,"Dark2"))
    }
    
  })
  
    #Word Plot for Adverbs
   output$plot_adverbs= renderPlot({
    
    if(is.null(input$file_input)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      if(input$radio==2) {
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    }
      all_adverbs=annot.obj() %>% subset(.,xpos %in% "RB") #filtering the corpus text for proper nouns
      top_adverbs =txt_freq(all_adverbs$lemma) # count of each proper noun terms in the text
      wordcloud(top_adverbs$key,top_adverbs$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(7,"Dark2"))
    }
    
  })
  
  output$plot_CoOccurence_Plot = renderPlot({
    
    if(is.null(input$file_input)) {return (NULL)} #exception handler in case the file is empty
    else
    {
      if(input$radio==2) {
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    }
      data_cooc<-cooccurrence(
        x=subset(annot.obj(),xpos %in% input$xpos), 
        #collecting required xpos from user input and filtering the annonated corpus . 
        #By default it is : Adjective [JJ], Noun [NN] and Proper  Noun [NNP]
        term="lemma", #extract terms as lemma
        group=c("doc_id","paragraph_id","sentence_id"))
      
      
      # Creating the Co-Occurence plot
      wordnetwork<- head(data_cooc,50)
      wordnetwork<-igraph::graph_from_data_frame(wordnetwork)
      
      ggraph(wordnetwork,layout="fr") +
        geom_edge_link(aes(width=cooc,edge_alpha=cooc),edge_colour="orange")+
        geom_node_text(aes(label=name),col="darkgreen", size=4)+
        theme_graph(base_family="Arial Narrow")+
        theme(legend.position="none")+
        labs(title= "Cooccurrences Plot from the XPOS selected")
      }
   })
  
  
   output$plot_freqplot <- renderPlot({
       if(is.null(input$file)){
        return(NULL)
      }
      else{
      freqtext <- txt_freq(annot.obj$xpos)
      freqtext$key <- factor(freqtext$key, levels = rev(freqtext$key))
      barchart(key ~ freq, data = set1, col = "cadetblue", 
               main = "XPOS \n frequency of occurrence", 
               xlab = "Freq")
        } 
     
  })
  
})
