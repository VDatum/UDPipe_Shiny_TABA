#Server code of the Shiny Web app'n
library(shiny)

#Defining the Shiny Server function with input and output passed to it : 
shinyServer(function(input, output) {

  # I/p is reactive so as to be dynamic
  #Reading the text file using the standard upload functionality and returning the cleaned text  here below :
  data_file <- reactive({
    if (is.null(input$file_input)) { return(NULL) }  #we check if the file_input used is null or not since the UI.r has the same name
    else{
      text<- readLines(input$file_input$datapath) #The Readlines function to read the input file from user , who has to upload the file [text]
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
      return(head(out,100)) #Gives 100  entries per page output on the Annotation tab
    }
  })
  

  
  #Nouns Wordcloud
  
  output$plot1 = renderPlot({
    
    if(is.null(input$file1)) {return (NULL)} #exception handler
    else
    {
      all_nouns=annot.obj() %>% subset(.,upos %in% "NOUN") #filtering the corpus text for nouns
      top_nouns =txt_freq(all_nouns$lemma) # count of each noun terms in the corpus
      wordcloud(top_nouns$key,top_nouns$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(7,"Dark2"))
    }
    
  })
  
  #Verbs Wordcloud
  
  output$plot2 = renderPlot({
    
    if(is.null(input$file1)) {return (NULL)} #exception handler
    else
    {
      all_verbs=annot.obj() %>% subset(.,upos %in% "VERB") #filtering the corpus text for verbs
      top_verbs =txt_freq(all_verbs$lemma)  # count of each verbs terms in the corpus text
      wordcloud(top_verbs$key,top_verbs$freq,min.freq = input$freq, max.words=input$max,colors =brewer.pal(7,"Dark2")) # plotting on a word cloud
    }
    
  })
  
  output$plot3 = renderPlot({
    
    if(is.null(input$file1)) {return (NULL)} #exception handler
    else
    {
      data_cooc<-cooccurrence(
        x=subset(annot.obj(),upos %in% input$upos), 
        #Taking a subset based on the input given by the user and filtering the annonated corpus text
        #Default is Adjective, Noun and Proper Noun
        term="lemma", #paramerter to specify the extraction terms as lemma
        group=c("doc_id","paragraph_id","sentence_id"))
      
      
      # Creating the plot of Co-Occurrence
      wordnetwork<- head(data_cooc,50)
      wordnetwork<-igraph::graph_from_data_frame(wordnetwork)
      
      ggraph(wordnetwork,layout="fr") +
        geom_edge_link(aes(width=cooc,edge_alpha=cooc),edge_colour="orange")+
        geom_node_text(aes(label=name),col="darkgreen", size=4)+
        theme_graph(base_family="Arial Narrow")+
        theme(legend.position="none")+
        
        labs(title= ":Cooccurrence Plot:")
    }
    
  })
  
})