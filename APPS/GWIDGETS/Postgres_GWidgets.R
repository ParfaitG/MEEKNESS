options(connectionObserver = NULL)

library(RPostgreSQL, quietly = TRUE)
library(gWidgets2, quietly = TRUE)
library(gWidgets2tcltk, quietly = TRUE)
options(guiToolkit="tcltk")

setwd("/path/to/working/directory")


getList <- function(){
  conn <- dbConnect(RPostgreSQL::PostgreSQL(), host="*****", dbname="*****",
                    user="***", password="***", port=5432)
  
  strSQL <- paste("SELECT c.ID, c.Character",
                  "FROM Characters c ORDER BY c.Character")
  
  df <- dbGetQuery(conn, strSQL)
  datalist <- list(c(NA, df[[1]]), c("", df[[2]]))
  dbDisconnect(conn)
  
  return(datalist)
}


getCharData <- function(conn, param){
  strSQL <- paste("SELECT c.Character, c.Description, encode(c.Picture::bytea, 'hex') AS PicData",
                  "FROM Characters c",
                  "WHERE c.Character = ?CHAR")
  
  query <- sqlInterpolate(conn, strSQL, CHAR = param)
  df <- dbGetQuery(conn, query)
  datalist <- as.list(df[1,])
  return(datalist)
}


getQualData <- function(conn, param){
  strSQL <- paste("SELECT q.Quality",
                  "FROM Qualities q",
                  "INNER JOIN Characters c ON q.CharacterID = c.ID",
                  "WHERE c.Character = ?CHAR")
  
  query <- sqlInterpolate(conn, strSQL, CHAR = param)
  df <- dbGetQuery(conn, query)
  datalist <- c(df[[1]])
  
  return(datalist)
}

gtmBlobHexStrToRaw <- function(hexStr) {
  
  # CREDIT: Github - @gtmaskall/blobUtilsR
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

mainWindow <- function(times=1, charnum='Boy in The Carrot Seed'){
  
  # TOP OF WINDOW
  win <- gWidgets2::gwindow("Meekness Characters", height = 850, width = 400, toolkit = guiToolkit())
  
  tbl <- glayout(cont=win, spacing = 5, expand=TRUE)
  
  tbl[1,1] <- gimage(filename = "Postgres.gif", 
                     dirname = getwd(), container = tbl)
  
  tbl[2,1] <- glabel("PostgresSQL", container = tbl)
  font(tbl[2,1]) <- list(size=14, family="Arial")
  
  
  # CHARACTER DROP DOWN
  charlist <- getList()
  
  tbl[3,1, expand=TRUE] <- charcbo <- gcombobox(charlist[[2]], selected = 1, editable = TRUE, 
                                                index=TRUE, container = tbl)
  font(tbl[3,1]) <- list(size=14, family="Arial")
  
  # POPULATE DATA
  runData <- function(charnum) {
    
    conn <- dbConnect(RPostgreSQL::PostgreSQL(), host="10.0.0.220", dbname="meekness",
                      user="meekdba", password="poet17", port=5432)
    
    # CHARACTER IMAGE
    charData <- getCharData(conn, charnum)
    
    pic_data <- gtmBlobHexStrToRaw(charData[[3]])
    
    # CREATE TEMP PIC
    f = file (paste0(getwd(), '/tmp.png'), "wb")
    writeBin(pic_data, con = f, useBytes=TRUE)
    close(f)
    
    system(paste0("convert -resize 388x250 ", getwd(), "/tmp.png ", getwd(), "/tmp.gif"))
    unlink(paste0(getwd(), "/tmp.png"))
    
    tbl[4,1] <- gimage("ok", dirname="stock", container = tbl)
    tbl[4,1] <- gimage(filename = "tmp.gif", dirname = getwd(), container = tbl)
    unlink(paste0(getwd(), "/tmp.gif"))
    
    tbl[5,1] <- glabel("", container = tbl)
    tbl[5,1] <- glabel(charData[[1]], container = tbl)
    font(tbl[5,1]) <- list(size=14, family="Arial")
    
    # DESCRIPTION
    lines <- strwrap(charData[[2]], 65)
    str <- paste0("\n", paste(lines, collapse ="\n"), "\n")
    
    tbl[6,1] <- glabel(NA, container = tbl)
    tbl[6,1] <- glabel(str, container = tbl)
    font(tbl[6,1]) <- list(size=10, family="Arial")
    
    # QUALITIES
    qualData <- getQualData(conn, charnum)
    
    for(i in seq_along(qualData)){
      tbl[i+6, 1] <- glabel("", container = tbl)
      tbl[i+6, 1] <- glabel(qualData[[i]], container = tbl)
      font(tbl[i+6,1]) <- list(size=14, family="Arial")
    }
    
    dbDisconnect(conn)
  }
  
  runData(charnum)
  
  addHandlerChanged(charcbo, handler=function(...)  {
    runData(charnum=svalue(charcbo))
  })
  
  return(list(win=win))
}

m <- mainWindow()
while(isExtant(m$win)) Sys.sleep(1)

