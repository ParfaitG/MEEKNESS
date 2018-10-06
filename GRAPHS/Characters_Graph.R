options(connectionObserver = NULL)

library(DBI, quietly = TRUE)
library(odbc, quietly = TRUE)
library(ggplot2)

setwd('/path/to/working/directory')

seabornPalette <- c("#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2",
                    "#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868",
                    "#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd",
                    "#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2",
                    "#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868",
                    "#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd")


# RETRIEVE DATA FROM SQL SERVER
retrieve_data <- function(sql) {
  conn <- dbConnect(odbc::odbc(), driver = "ODBC Driver 17 for SQL Server",
                    server = "****", port = 1433, database = "****",
                    uid = "****", pwd = "****")
  sql_df <- dbGetQuery(conn, sql)
  dbDisconnect(conn)
  
  return(sql_df)
}


# TOP 10 MATCHED CHARACTERS
strSQL <-  strSQL <- paste("WITH cte AS (",
                           "  SELECT c.[ID], c.[Character], q.[Quality]",
                           "  FROM [Characters] c" , 
                           "  INNER JOIN [Qualities] q ON c.ID = q.CharacterID",
                           "  ",
                           ")",
                           "SELECT TOP 10 c1.Character,",
                           "       SUM(CASE WHEN c1.Quality = c2.Quality THEN 1 ELSE 0 END) AS MatchCount", 
                           "FROM cte As c1",
                           "CROSS JOIN cte As c2",
                           "WHERE c1.ID < c2.ID",
                           " ",
                           "GROUP BY c1.Character",
                           "ORDER BY SUM(CASE WHEN c1.Quality = c2.Quality THEN 1 ELSE 0 END) DESC")
                           
char_df <- retrieve_data(strSQL)
char_df <- within(char_df, Character <- factor(Character, levels=Character[order(-MatchCount)]))

ggplot(char_df[1:10,], aes(Character, MatchCount, fill=Character)) + 
  geom_col() + 
  labs(title="Top 10 Matched Characters", y="Counts") +
  scale_fill_manual(values = seabornPalette) +
  scale_y_continuous(expand = c(0, 0)) +
  theme(plot.title = element_text(hjust = 0.5))


# TOP 10 BY WORKS TYPE
strSQL <-  strSQL <- paste("WITH cte AS (",
                           "  SELECT c.[ID], c.[Character], q.[Quality], w.[WorksType]",
                           "  FROM [Characters] c" , 
                           "  INNER JOIN [Qualities] q ON c.ID = q.CharacterID",
                           "  INNER JOIN [Works] w ON c.ID = w.CharacterID",
                           "  ",
                           ")",
                           "SELECT TOP 10 c1.WorksType,",
                           "       SUM(CASE WHEN c1.Quality = c2.Quality THEN 1 ELSE 0 END) AS MatchCount", 
                           "FROM cte As c1",
                           "CROSS JOIN cte As c2",
                           "WHERE c1.ID < c2.ID",
                           " ",
                           "GROUP BY c1.WorksType",
                           "ORDER BY SUM(CASE WHEN c1.Quality = c2.Quality THEN 1 ELSE 0 END) DESC")

works_df <- retrieve_data(strSQL)
works_df <- within(works_df, WorksType <- factor(WorksType, levels=WorksType[order(-MatchCount)]))

ggplot(works_df, aes(WorksType, MatchCount, fill=WorksType)) + 
  geom_col() + 
  labs(title="Top 10 Matched By Works Type", y="Counts") +
  scale_fill_manual(values = seabornPalette) +
  scale_y_continuous(limits = c(0, 2000), expand=c(0,0)) +
  theme(plot.title = element_text(hjust = 0.5))


# TOP 10 BY DECADE
strSQL <-  strSQL <- paste("WITH cte AS (",
                           "  SELECT c.[ID], c.[Character], q.[Quality],", 
                           "         CAST(w.[YearCreated] / 10 AS INT) * 10 AS Decade",
                           "  FROM [Characters] c" , 
                           "  INNER JOIN [Qualities] q ON c.ID = q.CharacterID",
                           "  INNER JOIN [Works] w ON c.ID = w.CharacterID",
                           "  ",
                           ")",
                           "SELECT TOP 10 c1.Decade,",
                           "       SUM(CASE WHEN c1.Quality = c2.Quality THEN 1 ELSE 0 END) AS MatchCount", 
                           "FROM cte As c1",
                           "CROSS JOIN cte As c2",
                           "WHERE c1.ID < c2.ID",
                           " ",
                           "GROUP BY c1.Decade",
                           "ORDER BY SUM(CASE WHEN c1.Quality = c2.Quality THEN 1 ELSE 0 END) DESC")

decade_df <- retrieve_data(strSQL)
decade_df$Decade <- as.factor(decade_df$Decade)

ggplot(decade_df, aes(Decade, MatchCount, fill=Decade)) + 
  geom_col() + 
  labs(title="Top 10 Matched By Decade", y="Counts") +
  scale_fill_manual(values = seabornPalette) +
  scale_y_continuous(limits = c(0, 1200), expand=c(0,0)) +
  theme(plot.title = element_text(hjust = 0.5))

