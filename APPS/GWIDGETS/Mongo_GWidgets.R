options(connectionObserver = NULL)

library(mongolite, quietly = TRUE)
library(gWidgets2, quietly = TRUE)
library(gWidgets2tcltk, quietly = TRUE)
options(guiToolkit="tcltk")

setwd("/path/to/working/directory")


getList <- function(){
  conn <- mongo(collection="characters", db = "meekness", url = "mongodb://*****:27017")
  
  df <- conn$find(query = '{}', 
                  fields = paste0('{"_id":true, "character":true}'))
  
  datalist <- list(c(NA, df$`_id`), c("", sort(df$character)))
  
  conn <- NULL; rm(conn); invisible(gc())
  
  return(datalist)
}


getCharData <- function(conn, param){
  df <- conn$find(query = paste0('{"character":"', param, '"}'), 
                  fields = paste0('{"character":true, "description":true,',
                                  ' "quote":true, "picture":true, "_id":false}'))
  
  datalist <- as.list(df[1,])
  return(datalist)
}


getQualData <- function(conn, param){
  df <- conn$find(query = paste0('{"character":"', param, '"}'), 
                  fields = paste0('{"qualities":true, "_id":false}'))
  
  datalist <- unlist(df$qualities)
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

mainWindow <- function(times=1, charnum="Laura Wingfield"){
  
  # TOP OF WINDOW
  win <- gWidgets2::gwindow("Meekness Characters", height = 850, width = 400)
  
  tbl <- glayout(cont=win, spacing = 5, expand=TRUE)
  
  tbl[1,1] <- gimage(filename = "Mongo.gif", 
                     dirname = getwd(), container = tbl)
  
  tbl[2,1] <- glabel("DB2", container = tbl)
  font(tbl[2,1]) <- list(size=14, family="Arial")
  
  
  # CHARACTER DROP DOWN
  charlist <- getList()
  
  tbl[3,1, expand=TRUE] <- charcbo <- gcombobox(charlist[[2]], selected = 1, editable = TRUE, 
                                                index=TRUE, container = tbl)
  font(tbl[3,1]) <- list(size=14, family="Arial")
  
  # POPULATE DATA
  runData <- function(charnum) {
    
    conn <- mongo(collection="characters", db = "meekness", url = "mongodb://10.0.0.220:27017")
    
    # CHARACTER IMAGE
    charData <- getCharData(conn, charnum)
    pic_data <- gtmBlobHexStrToRaw(charData$picture)
    
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
    tbl[5,1] <- glabel(charData$character, container = tbl)
    font(tbl[5,1]) <- list(size=14, family="Arial")
    
    # DESCRIPTION
    lines <- strwrap(charData$description, 65)
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
    
    conn <- NULL; rm(conn); invisible(gc())
  }
  
  runData(charnum)
  
  addHandlerChanged(charcbo, handler=function(...)  {
    runData(charnum=svalue(charcbo))
  })
  
  return(list(win=win))
}

m <- mainWindow()
while(isExtant(m$win)) Sys.sleep(1)
