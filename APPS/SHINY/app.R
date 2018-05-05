
library(shiny)

chardf <- readRDS("MeekCharData.rds")
qualdf <- readRDS("MeekQualData.rds")
points <- 0
attempts <- 0

ui <- fluidPage(theme = "style.css",
  headerPanel("Meekness Characters"),
  mainPanel(
    fluidRow(
      column(12,
             fluidRow(  
               column(width = 6,
                      selectInput("variable", NULL,
                                  setNames(chardf$ID, chardf$Character), selected = 117),
                      h4("Matches"),
                      tableOutput("Matches")),
               column(width = 6,
                      h4(strong('Objective: Earn Most Quality Matching Points in 5 Attempts')),
                      h4(""),
                      fluidRow(
                        column(h4("Points"), width = 2,
                               textOutput("Points")),
                        column(h4("Attempts"),  width = 2,
                               textOutput("Attempts"))
                      ))
             ),
             fluidRow(
               
               column(imageOutput("CharImage1"), width = 6, height=1,
                      h3("Description"),
                      textOutput("Description1"),
                      h3("Quote"),
                      textOutput("Quote1"),    
                      h3("Qualities"),
                      tableOutput("QualityTable1")),
               
               column(imageOutput("CharImage2"), width = 6, height=1,
                      h3("Description"),
                      textOutput("Description2"),
                      h3("Quote"),
                      textOutput("Quote2"),    
                      h3("Qualities"),
                      tableOutput("QualityTable2"))
             )
             
      )
    )
  )
)

gtmBlobHexStrToRaw <- function(hexStr) {
  
  # CREDIT: Githubg - @gtmaskall/blobUtilsR
  # URL: https://github.com/gtmaskall/blobUtilsR/blob/master/gtmBlob.R
  
  # Define function to process individual hex strings (single row)
  # Current method is by the far the fastest out of various ways of doing this involving sapply or for loops
  convertSingleRow <- function(hexRow)
  {
    numChars    <- nchar(hexRow)
    tmpSplit    <- unlist(strsplit(hexRow, split="")) #yields vector of individual chars (we need pairs)
    # tmpSplit is now a character vector of length numChars
    # Now to paste adjacent pairs together
    oddInds     <- seq(1, numChars, by=2)
    evenInds    <- oddInds + 1
    tmpCharVec  <- paste(tmpSplit[oddInds], tmpSplit[evenInds], sep="")
    tmpRaw      <- as.raw(as.hexmode(tmpCharVec))
    return(tmpRaw)
  }
  
  # hexStr could contain multiple rows (e.g. be of length N)
  numRows <- length(hexStr)
  
  if (numRows > 1)
  {
    # Requires matrix
    lenStr      <- nchar(hexStr) # could be vector (of length numRows)
    numOutCols  <- lenStr/2      # could be vector (of length numRows)
    
    # A for loop here actually allows us to predefine a matrix of suitable size
    # (sapply was much slower)
    output <- matrix(as.raw(0), numRows, max(numOutCols))
    for (iRow in 1:numRows)
    {
      output[iRow,1:numOutCols[iRow]] <- convertSingleRow(hexStr[iRow])
    }
  } else
  {
    output <- convertSingleRow(hexStr)
  }
  return(output)
}

getDBData <- function(input) {
    tryCatch({
      
      charid <- reactive({ 
        charid <- input$variable  
      })
      
      df <- subset(chardf, ID == charid())
      
      meek_char <- df$Character[1]
      pic_data <- gtmBlobHexStrToRaw(df$Picture[1])
      
      # CREATE TEMP PIC
      outfile <- tempfile(fileext = '.png')
      f = file (outfile, "wb")
      writeBin(pic_data, con = f, useBytes=TRUE)
      close(f)
      
      qualities <- subset(qualdf, CharacterID == df$ID[1])
      
      return(list(qualities = qualities[,c("Quality")], pic = outfile, 
                  description = df$Description[1], quote = paste0(df$Quote[1]), "<br/>"))
    }, 
    warning= function(w) {
      print(w)
    },
    error = function(e) {
      print(e)
    })
}

server <- function(input, output, session) {
  
  # CHARACTER 1
  dbData1 <- reactive({
    getDBData(input)
  })
  
  output$CharImage1 <- renderImage({
    list(src =  dbData1()$pic,
         contentType = 'image/jpg',
         width = 400,
         height = 300,
         alt = "Meekness character image")
  }, deleteFile = TRUE)
  
  output$QualityTable1 <- renderTable({
    dbData1()$qualities
  }, colnames = FALSE)
  
  output$Description1 <- renderText({
    paste0(dbData1()$description)
  })
  
  output$Quote1 <- renderText({
    tmp <- dbData1()$quote
    ifelse(tmp=="NA"|is.na(tmp), "", paste0(tmp, ""))
  })
  
  # CHARACTER 2
  dbData2 <- reactive({
    getDBData(list(variable = sample(1:150, 1), var2 = input$variable))
  })
  
  output$CharImage2 <- renderImage({
    list(src =  dbData2()$pic,
         contentType = 'image/jpg',
         width = 400,
         height = 300,
         alt = "Meekness character image")
  }, deleteFile = TRUE)
  
  output$QualityTable2 <- renderTable({
    dbData2()$qualities
  }, colnames = FALSE)
  
  output$Description2 <- renderText({
    paste0(dbData2()$description)
  })
  
  output$Quote2 <- renderText({
    tmp <- dbData2()$quote
    ifelse(tmp=="NA"|is.na(tmp), "", paste0(tmp, ""))
  })
  
  output$Matches <- renderTable({
    intersect(dbData1()$qualities, dbData2()$qualities)
  }, colnames = FALSE)
  
  output$Points <- renderText({
    if(attempts == 5) {
      points <<- 0
      attempts <<- 0
    }
    points <<- points + length(intersect(dbData1()$qualities, dbData2()$qualities))
    
    return(paste0(points))
  })
  
  output$Attempts <- renderText({
    m <- length(intersect(dbData1()$qualities, dbData2()$qualities))
    attempts <<- attempts + 1
    
    return(paste0(attempts))
  })
}

shinyApp(ui, server)