
library(RSQLite)
library(DBI)
library(shiny)

conn <-dbConnect(SQLite(), dbname = "Meekness.db")
chars <- dbGetQuery(conn, "SELECT ID, `Character` FROM Characters ORDER BY `Character`")
dbDisconnect(conn)


ui <- shinyUI(
              fluidPage(theme = "style.css",
                        pageWithSidebar(
                          NULL,
                          NULL,
                          mainPanel(
                            headerPanel("Meekness Characters"),
                            selectInput("variable", NULL, setNames(chars$ID, chars$Character), 
                                        width = "400px", selected = 117),
                            imageOutput("CharImage"), height=1,
                            headerPanel("Description"),
                            textOutput("Description"),
                            headerPanel("Quote"),
                            textOutput("Quote"),    
                            headerPanel("Qualities"),
                            tableOutput("QualityTable")
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
    conn <- dbConnect(SQLite(), dbname = "Meekness.db")
    
    charid <- reactive({ 
      input$variable  
    })
    
    sql <- paste("SELECT `ID`, `Character`, HEX(Picture) AS Picture, Description, Quote",
                 "FROM Characters WHERE ID = ?CHAR")
    query <- DBI::sqlInterpolate(conn, sql, CHAR = charid())
    df <- dbGetQuery(conn, query)
    
    meek_char <- df$Character
    pic_data <- gtmBlobHexStrToRaw(df$Picture)
    
    # CREATE TEMP PIC
    outfile <- tempfile(fileext = '.png')
    f = file (outfile, "wb")
    writeBin(pic_data, con = f, useBytes=TRUE)
    close(f)
    
    sql <- "SELECT Quality FROM Qualities WHERE CharacterID = ?ID"
    query <- DBI::sqlInterpolate(conn, sql, ID = list(df$ID))
    qualities <- dbGetQuery(conn, query)
    
    return(list(qualities = qualities, pic = outfile, 
                description = df$Description, quote = df$Quote))
  }, 
  warning= function(w) {
    print(w)
  },
  error = function(e) {
    print(e)
  },
  finally = { 
    dbDisconnect(conn) 
  })
  
}

server <- function(input, output, session) {

  dbData1 <- reactive({
    getDBData(input)
  })
  
  output$CharImage <- renderImage({
    list(src =  dbData1()$pic,
         contentType = 'image/jpg',
         width = 400,
         height = 300,
         alt = "Meekness character image")
  }, deleteFile = TRUE)
  
  output$QualityTable <- renderTable({
    dbData1()$qualities
  }, colnames = FALSE)
  
  output$Description <- renderText({
    paste0(dbData1()$description, "\n")
  })
  
  output$Quote <- renderText({
    dbData1()$quote
  })

}

shinyApp(ui, server)