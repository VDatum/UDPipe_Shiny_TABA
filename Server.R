#Start of Server Code
shinyServer(function(input,output){ 
#Input file from user in the reactive mode for dynamic changes in input data
    Dataset <- reactive({ 
	  if(is.null(input$file_input)){ 
		  return(NULL) } 
	else{ 
		text <- readLines(input$file1$datapath) #readline function to read input
		text = str_replace_all(text,"<.*?>","") #overriding the html noise , cleaning the corpus
		text = text[text != ""] #selecting not null text
		str(text)
		return(text) #return the cleaned text
	} 
	}) 
    
# uploading the input modules : 3 languages : English , Spanish & Hindi
    
    model = reactive({
      
      if(input$radio==1)
      {model = udpipe_load_model("english-ud-2.0-170801.udpipe")}
      if(input$radio==2)
      {model = udpipe_load_model("spanish-ud-2.0-170801.udpipe")}
      if(input$radio==3)
      {model = udpipe_load_model("hindi-ud-2.0-170801.udpipe")}
      return(model)
    })

#Passing the input data and the above model to annotate of UDPipe
annot.obj = reactive({ 
x <- udpipe_annotate(model(),x = Dataset()) 
x <- as.data.frame(x) 
return(x) 
}) 
# module to let the user download the annotated data as a csv
output$downloadData <- downloadHandler( 
filename = function() { 
"annotated_data.csv" 
}, 
content = function(file) { 
write.csv(annot.obj()[,-4],file,row.names = FALSE) #writing the file of output as csv
} ) 
#Display n rows of the annotated corpus text 
output$dout1 = renderDataTable({ 
if(is.null(input$file1)){ 
return(NULL) 
} 
else{ 
out = annot.obj()[,-4] 
return(out) 
} 
}) 
#Word cloud for nouns
output$WordCloudPlot1 = renderPlot({ 
if(is.null(input$file1)){ 
return(NULL) 
} 
else{ 
all_nouns = annot.obj() %>% subset(., upos %in% "NOUN") #filtering for nouns
top_nouns = txt_freq(all_nouns$lemma) #count of each noun terms
wordcloud(top_nouns$key,top_nouns$freq,min.freq = input$freq, max.words=input$max, colors = 1:10) 
} 
}) 

#Word Cloud for Verbs
output$WordCloudPlot2 = renderPlot({ 
if(is.null(input$file1)){ 
return(NULL) 
} 
else{ 
all_verbs = annot.obj() %>% subset(., upos %in% "VERB") 
top_verbs = txt_freq(all_verbs$lemma) 
wordcloud(top_verbs$key,top_verbs$freq,min.freq = input$freq, max.words=input$max, colors = 1:10) 
} 
}) 

#Co Occurence Plot
output$CoOccurencePlot = renderPlot({ 
if(is.null(input$file1)){ 
return(NULL) 
} 
else{ 
india_cooc <- cooccurrence( 
x = subset(annot.obj(),upos %in% input$upos), 
term = "lemma", 
group = c("doc_id","paragraph_id","sentence_id")) 
#Creation of the Graph
wordnetwork <- head(india_cooc,50) 
wordnetwork <- igraph::graph_from_data_frame(wordnetwork)
#Plotting
ggraph(wordnetwork, layout = "fr") + 
geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") + 
geom_node_text(aes(label = name), col = "darkgreen", size = 4) + 
theme_graph(base_family = "Arial Narrow") + 
theme(legend.position = "none") + 
labs(title = "Cooccurences plot") } }) 


}) 
