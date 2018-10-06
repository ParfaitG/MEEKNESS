
library(data.tree)
library(networkD3)

library(RPostgreSQL)

setwd('/path/to/working/directory')

# RETRIEVE DATA FROM POSTGRESQL
conn <- dbConnect(RPostgreSQL::PostgreSQL(), host="****", dbname="****",
                  user="****", password="****", port=5432)

# TOP MATCHING CHARACTERS
sql <- "SELECT c.ID, c.Character, w.*, CAST(w.YearCreated / 10 AS INT) * 10 AS Decade
        FROM Characters c
        INNER JOIN Works w 
          ON c.ID = w.CharacterID
        ORDER BY c.Character"

# COUNT OF MATCHING CHARACTERS
sql <- "WITH cte AS 
          (SELECT c.ID, c.Character, q.Quality 
           FROM Characters c
           INNER JOIN Qualities q ON c.ID = q.CharacterID)

        SELECT main.*, agg.QualCount
        FROM 
           (SELECT c.ID As CharID, c.Character, w.*, CAST(w.YearCreated / 10 AS INT) * 10 AS Decade
            FROM Characters c
            INNER JOIN Works w ON c.ID = w.CharacterID) As main
        INNER JOIN
           (SELECT c1.ID, COUNT(DISTINCT c2.ID) As QualCount
            FROM cte c1
            INNER JOIN cte c2 ON c1.Quality = c2.Quality AND c1.ID <> c2.ID
            GROUP BY c1.ID) AS agg 
        ON main.CharID = agg.ID
        ORDER BY main.Character"

chars_df <- dbGetQuery(conn, sql)

# QUALITIES
sql <- "SELECT c.ID As CharID, c.Character, w.WorksType, q.Quality, CAST(w.YearCreated / 10 AS INT) * 10 AS Decade
        FROM Characters c
        INNER JOIN Works w ON c.ID = w.CharacterID
        INNER JOIN Qualities q ON c.ID = q.CharacterID
        ORDER BY c.Character"

quals_df <- dbGetQuery(conn, sql)

dbDisconnect(conn)


######################
### DATA TREE
######################

### BY WORKS TYPE
charlist <- by(chars_df, chars_df$workstype, 
               function(sub) list(type=sub$workstype[[1]], char=sub$character, qual=sub$qualcount))

meek_tree <- Node$new("Meekness")
meek_tree$q <- sum(chars_df$qualcount)

for(obj in charlist) {
  typ <- meek_tree$AddChild(obj$type)
  typ$q <- sum(obj$qual)
  
  for(i in seq_along(obj$char)) {
    ch <- typ$AddChild(obj$char[[i]])
    ch$q <- obj$qual[[i]]
  }
}

rm(typ, ch)
print(meek_tree, "q")

### BY DECADE
charlist <- by(chars_df, chars_df$decade, 
               function(sub) list(decade=sub$decade[[1]], char=sub$character, qual=sub$qualcount))

meek_tree <- Node$new("Meekness")
meek_tree$q <- sum(chars_df$qualcount)

for(obj in charlist) {
  typ <- meek_tree$AddChild(obj$decade)
  typ$q <- sum(obj$qual)
  
  for(i in seq_along(obj$char)) {
    ch <- typ$AddChild(obj$char[[i]])
    ch$q <- obj$qual[[i]]
  }
}

rm(typ, ch)
names(meek_tree)

plot(meek_tree[["1910"]])

plot(meek_tree[["1990"]])

plot(meek_tree[["2010"]])


######################
### NETWORK
######################

### BY WORKS TYPE
charlist <- unname(by(chars_df, chars_df$workstype, 
               function(sub) list(name=sub$workstype[[1]], 
                                  children=Map(function(nm, q) list(name=nm, size=q), 
                                               sub$character, sub$qualcount, USE.NAMES=FALSE))))

networklist <- list(name="Meekness", children=charlist)

plot <- radialNetwork(List = networklist, fontSize = 10, opacity = 0.9)
saveNetwork(plot, 'OUTPUT/Characters_RadialNetworkD3.html')

plot <- diagonalNetwork(List = networklist, fontSize = 10, opacity = 0.9)
saveNetwork(plot, 'OUTPUT/Characters_DiagonalNetworkD3.html')


lapply(list(c(1:3), c(4:6), c(7:9), c(10:11)), function(s) {
  networklist <- list(name="Meekness", children=charlist)
  networklist$children <- networklist$children[s]
  radialNetwork(List = networklist, fontSize = 10, opacity = 0.9)
})



### BY QUALITY
proper <- function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

# WORKS TYPE
for(qual in c("death", "friend", "loneliness")) {
   quallist <- unname(by(subset(quals_df, quality==qual), subset(quals_df, quality==qual)$workstype, 
                      function(sub) list(name=sub$workstype[[1]], 
                                         children=lapply(sub$character, function(nm) list(name=nm)))))

  networklist <- list(name=proper(qual), children=quallist)
  plot <- radialNetwork(List = networklist, fontSize = 10, opacity = 0.9)
  print(plot)
  Sys.sleep(1)
}

# DECADE
for(qual in c("death", "friend", "loneliness")) {
  quallist <- unname(by(subset(quals_df, quality==qual), subset(quals_df, quality==qual)$decade, 
                        function(sub) list(name=sub$decade[[1]], 
                                           children=lapply(sub$character, function(nm) list(name=nm)))))
  
  networklist <- list(name=proper(qual), children=quallist)
  plot <- diagonalNetwork(List = networklist, fontSize = 10, opacity = 0.9)
  print(plot)
  Sys.sleep(1)
}


