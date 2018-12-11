library("shiny") 
library("shinythemes")
shinyUI( 
fluidPage(theme = shinytheme("united"), 
tags$head( 
tags$style(HTML(" 
@import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700'); 
")) 
), 
titlePanel(h1("Group Assignment - Text Analysis - Building a Shiny App around the UDPipe NLP Workflow",  
style = "font-family: 'Lobster', cursive; 
font-weight: 400; line-height: 1.1;  
color: #d86636;")), 
sidebarLayout( 
sidebarPanel( 
fileInput("file_input","Please upload text file"), 
checkboxGroupInput("upos", 
label = h3("Select Universal POS for co-occurrences filtering"), 
choices = list("Adjective" = 'JJ', 
"Noun" = "NN", 
"Proper Noun" = "NNP", 
"Adverb" = 'RB', 
"Verb" = 'VB'), 
selected = c("JJ","NN","NNP")) ,
h5(span(strong(p("Wordcloud parameters")))),

sliderInput("freq",
            "Minimum Frequency:",
            min = 1,  max = 50, value = 15),
sliderInput("max",
            "Maximum Number of Words:",
            min = 1,  max = 300,  value = 100),

radioButtons("radio", label = h5("UdPipe Model"),
             choices = list("English" = 1, "Spanish" = 2, "Hindi" = 3), 
             selected = 1)
),
mainPanel(
  tabsetPanel(type = "tabs",
              tabPanel("Overview",  # first panel tab - overview section
                       
                       h3(p("Data Input")),
                       p("This app supports only text files. ", align ="justify"),
                       p("Please refer to the link below for sample csv file."),
                       a(href="https://raw.githubusercontent.com/VDatum/UDPipe_Shiny_UPOS/master/isb%20pgp%20goog%20search.txt"
                         ,"Sample data input file"),   
                       h3('How to use this app'),
                       p('To use this app,click on', 
                         span (strong("Upload text file")),
                         'and upload the text file'),
                       
                       h3('What is the output from this app ?'),
                       p(span (strong("Annotation")),': Display a table of annotated document using UDPipe library'),
                       
                       p(span (strong("Plots")),': Display a word clouds of all the nouns and verbs in the corpus'),
                       p(' Adjust the minimum frequency and maximum number of words from side panel'),
                       
                       p(span (strong("Co-Occurrence")),': Display a plot of co-occurrences at document level using a network plot'),
                       p(' Please use the checkbox to select different parts of speech for this plot')
              ), 
tabPanel("Annotation", 
dataTableOutput('dout1'), 
h4('Please click below button to download the annotated data'), 
downloadButton("downloadData","Download Annotated Data")), 
tabPanel("Word Clouds", 
h3("Nouns"), 
plotOutput('WordCloudPlot1'), 
h3("verbs"), 
plotOutput('WordCloudPlot2')), 
tabPanel("Co-occurences",
h3("Co-occurences"),
plotOutput('CoOccurencePlot')),
tabPanel("Most frequently occured UPOS",p(textOutput('placeholderTab5')),
         plotOutput('UPOS_Plot')) ) ) ) ) 
