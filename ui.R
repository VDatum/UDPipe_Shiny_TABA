#invoking shiny library
library("shiny")
library("shinythemes")

shinyUI( # start of UI code
  fluidPage(theme = shinytheme("sandstone"), # start of fluid page - to adjust to screen dimension
            
            titlePanel(strong("UDPipe Text Analytics")), #title of the App
            
            sidebarLayout( #start of side bar layout
              
              sidebarPanel #side bar panel start
              (
                fileInput("file1", label = h4("Upload Text File")), #section to ask user to upload input
                
                #create check box options for getting user input
                checkboxGroupInput("upos", 
                                   label = h5(span(strong("Select Parts of Speech for co-occurrences filtering"))),
                                   
                                   choices = list("Adjective"= 'jj',
                                                  "Noun" = 'NN',
                                                  "Proper Noun" = 'PPN',
                                                  "Adverb" = 'Av',
                                                  "Verb" = 'VB'),
                                   selected = c("jJ","Nn","Ppn")),
                
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
              ), #end of side bar panel
              
              #start of main panel code where we will create the panel tabs    
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
                                     p(' Please note that only 100 rows are displayed. Entire corpus can be downloaded using the download button'),
                                     
                                     p(span (strong("Plots")),': Display a word clouds of all the nouns and verbs in the corpus'),
                                     p(' Adjust the minimum frequency and maximum number of words from side panel'),
                                     
                                     p(span (strong("Co-Occurrence")),': Display a plot of top-30 co-occurrences at document level using a network plot'),
                                     p(' Please use the checkbox to select different parts of speech for this plot')
                            ),
                            
                            
                            
                            tabPanel("Annotation",    # second panel tab - annotated document section
                                     dataTableOutput('dout1'),
                                     downloadButton("download Data", "Download Annotated Data")
                                     
                                     
                                     
                                     
                            ),
                            
                            tabPanel("Plots",         # third panel tab - wordcloud of nouns and verbs
                                     h3("Nouns"),
                                     plotOutput('plot1'),
                                     h3("Verbs"),
                                     plotOutput('plot2')),
                            tabPanel("Co-Occurrences",   # fourth panel tab - wordcloud of nouns and verbs
                                     plotOutput('plot3'))
                ) # End of Tab Set Panel
                
                
              ) # end of main Panel
              
            ) # end of sidebarLayout
  )  # end if fluidPage
) # end of UI

