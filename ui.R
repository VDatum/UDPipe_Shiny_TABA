#User Interface Definition of the RShiny  App
library("shiny")
library("shinythemes")
#Suppress Warnings
tags$style(type="text/css",
           ".shiny-output-error { visibility: hidden; }",
           ".shiny-output-error:before { visibility: hidden; }"
)
shinyUI( # start of UI code
  fluidPage(theme = shinytheme("slate"),
            
            titlePanel(strong("TABA:UDPipe NLP Workflow")), # Giving a title to the Application
            
            sidebarLayout(
              
              sidebarPanel #side bar panel startpoint
              (
                fileInput("file_input", label = h4("Upload Text File")), #upload option for user to give the input file
                 radioButtons("radio", label = h5("UdPipe Model"),
                             choices = list("English" = 1, "Hindi" = 2, "Spanish" = 3), 
                             selected = 1),
                  #Default Selection as 1 for the English UDPipe Model for the annotated text  
                         
                #create check box options for getting user input
                checkboxGroupInput("xpos", 
                                   label = h5(span(strong("Select Universal Parts-of-Speech Tags for co-occurrences filtering"))),
                                   
                                   choices = list("Adjective"= 'JJ',
                                                  "Noun" = 'NN',
                                                  "Proper Noun" = 'NNP',
                                                  "Adverb" = 'RB',
                                                  "Verb" = 'VB'),
                                   selected = c("JJ","NN","NNP")),
                #Default selection to be Adjective , Noun and Proper Noun
                   
                h5(span(strong(p("Wordcloud parameters")))),
                
                sliderInput("freq",
                            "Minimum Frequency in the Wordcloud",
                            min = 1,  max = 50, value = 15),
                sliderInput("max",
                            "Maximum Number of Words:",
                            min = 1,  max = 300,  value = 150)
                
              ), 
              
              #start of main panel code where we will create the panel tabs    
              mainPanel(
                tabsetPanel(type = "tabs",
                            tabPanel("Overview",  # first panel tab - overview section
                                     
                                     h2(p("The App Overview :  Data Input")),
                                     p("This is developed by the team of 3 members [ Vishal Somshekhar Shetty,  Shreenath KS and Aastha Sharma ] as part of the TABA Assignment of CBA Course : Batch 11"),
                                     
                                     
                                 
                                     h3('Logical Flow of the App'),
                                     p(span (strong("A. Upload and Read Text File")),'Click on browse to upload the text file and wait for few mins for it to reflect in the annotation tab'),
                                     p("This app supports only text files.Kindly ensure the data input is in notepad format or .txt", align ="justify"),
                                     p("Kindly refer to the link below for sample text file."),
                                     a(href="https://raw.githubusercontent.com/VDatum/UDPipe_Shiny_TABA/master/isb%20pgp%20goog%20search.txt"
                                       ,"Sample data input file"),  
                                     
                                     p(span (strong("B. Select the udpipe model")),'Option to upload the trained udpipe model in English, Hindi and Spanish.'),
                                     p('Choose the respective models based on the uploaded text file. Default is chosen as English'),
                                     
                                     p(span (strong("C. Select the XPOS Tags for the  co-occurence plot")),'Select list of part-of-speech tags (XPOS) using check box for plotting co-occurrences'),
                                     p(' Please use the checkbox to select different parts of speech for this plot. Default is Noun, Adjective & Proper Noun'),
                                     
                                
                                     h3('End Goal of this App ?'),
                                     p(span (strong("Annotation")),': Display a table of annotated document using UDPipe library'),
                                     p(' To make use of UDPipe for  making annotation table , word clouds &  co-occurence graphs'),
                                     
                                     p(span (strong("Plots")),': Display a word clouds of all the list of part of speech tags (XPOS) in the corpus'),
                                     p(' Adjust the minimum frequency and maximum number of words from side panel'),
                                     
                                     p(span (strong("Co-Occurrence")),': Display a plot of co-occurrences at document level using a network plot'),
                                     p(' Please use the checkbox to select different parts of speech for this plot'),
                                     
                                     p(span (strong("Most Frequently Occured XPOS tags")),': Display a Frequency plot of XPOS tags'),
                                     p(' Based on the different parts of speech listed applied on the annotated text')
                                     
                            ),
                            
                            
                            
                            tabPanel("Annotation",
                                     dataTableOutput('dout1'),
                                     downloadButton("download Data", "Download Annotated Data")
                            ),
                            
                            tabPanel("Plots",         # third panel tab - wordcloud of nouns , adjectives , Proper Nounes, Adverbs and verbs
                                     h3("Nouns"),
                                     plotOutput('plot_nouns'),
                                     h3("Adjectives"),
                                     plotOutput('plot_adjectives'),
                                     h3("Proper Nouns"),
                                     plotOutput('plot_propernouns'),
                                     h3("Adverbs"),
                                     plotOutput('plot_adverbs'),
                                     h3("Verbs"),
                                     plotOutput('plot_verbs')),
                            tabPanel("Co-Occurrence Plot",   # Co Occurence Plot based on selection
                                     plotOutput('plot_CoOccurence_Plot')),
                             tabPanel("Most frequently occured XPOS",   # Frequency plot on the occurence of difference XPOS tags
                                     plotOutput('plot_freqplot'))
                            
                ) # End of Tab Set Panel
                
                
              ) # end of main Panel
              
            ) # end of sidebarLayout
  )  # end if fluidPage
) # end of UI
