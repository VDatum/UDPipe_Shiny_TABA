#User Interface Definition of the RShiny  App
library("shiny")
library("shinythemes")

shinyUI( # start of UI code
  fluidPage(theme = shinytheme("sandstone"),
            
            titlePanel(strong("TABA:UDPipe NLP Workflow")), # Giving a title to the Application
            
            sidebarLayout(
              
              sidebarPanel #side bar panel startpoint
              (
                fileInput("file_input", label = h4("Upload Text File")), #upload option for user to give the input file
                
                #create check box options for getting user input
                checkboxGroupInput("upos", 
                                   label = h5(span(strong("Select Universal Parts-of-Speech Tags for co-occurrences filtering"))),
                                   
                                   choices = list("Adjective"= 'ADJ',
                                                  "Noun" = 'NOUN',
                                                  "Proper Noun" = 'PROPN',
                                                  "Adverb" = 'ADV',
                                                  "Verb" = 'VERB'),
                                   selected = c("ADJ","NOUN","PROPN")),
                #Default selection to be Adjective , Noun and Proper Noun
                
                h5(span(strong(p("Wordcloud parameters")))),
                
                sliderInput("freq",
                            "Minimum Frequency in the Wordcloud",
                            min = 1,  max = 50, value = 25),
                sliderInput("max",
                            "Maximum Number of Words:",
                            min = 1,  max = 300,  value = 150),
    
                 radioButtons("radio", label = h5("UdPipe Model"),
                             choices = list("English" = 1, "Hindi" = 2, "Spanish" = 3), 
                             selected = 1)
              ), #Default Selection as 1 for the English UDPipe Model for the annotated text
              
              #start of main panel code where we will create the panel tabs    
              mainPanel(
                tabsetPanel(type = "tabs",
                            tabPanel("Overview",  # first panel tab - overview section
                                     
                                     h2(p("The App Overview :  Data Input")),
                                     p("This is developed by the team of 3 members [ Vishal Somshekhar Shetty,  Shreenath KS and Aastha Sharma ] as part of the TABA Assignment of CBA Course : Batch 11"),
                                     p("This app supports only text files.Kindly ensure the data input is in notepad format or .txt", align ="justify"),
                                     p("Kindly refer to the link below for sample text file."),
                                     a(href="https://raw.githubusercontent.com/VDatum/UDPipe_Shiny_UPOS/master/isb%20pgp%20goog%20search.txt"
                                       ,"Sample data input file"),  
                                     br(),
                                     h3('How to use this app'),
                                     p('To use this app,click on', 
                                       span (strong("Upload text file")),
                                       'and upload the text file'),
                                     
                                     h3('End Goal of this App ?'),
                                     p(span (strong("Annotation")),': Display a table of annotated document using UDPipe library'),
                                     p(' To make use of UDPipe for  making annotation table , word clouds &  co-occurence graphs'),
                                     
                                     p(span (strong("Plots")),': Display a word clouds of all the nouns and verbs in the corpus'),
                                     p(' Adjust the minimum frequency and maximum number of words from side panel'),
                                     
                                     p(span (strong("Co-Occurrence")),': Display a plot of top-30 co-occurrences at document level using a network plot'),
                                     p(' Please use the checkbox to select different parts of speech for this plot')
                            ),
                            
                            
                            
                            tabPanel("Annotation",
                                     dataTableOutput('dout1'),
                                     downloadButton("download Data", "Download Annotated Data")
                                  ),
                            
                            tabPanel("Plots",         # Wordcloud of nouns and verbs
                                     h3("Nouns"),
                                     plotOutput('plot_nouns'), 
                                     h3("Verbs"),
                                     plotOutput('plot_verbs')),
                            tabPanel("Co-Occurrence Plot",   # Co Occurence Plot based on selection
                                     plotOutput('plot_CoOccurence_Plot'))
                           
                ) # End of Tab Set Panel
                
                
              ) # end of main Panel
              
            ) # end of sidebarLayout
  )  # end if fluidPage
) # end of UI

