options(connectionObserver = NULL)

library(DBI, quietly = TRUE)
library(odbc, quietly = TRUE)

library(ggplot2)
library(grid)
library(gridExtra)


setwd('/home/parfaitg/Documents/MEEKNESS_DEV/GRAPHS')

# RETRIEVE DATA FROM ORACLE
conn <- dbConnect(odbc::odbc(), Driver = "Oracle 11g ODBC Driver", ServerName = "****",
                  uid = "****", pwd = "****")

character_df <- dbGetQuery(conn, 'SELECT ID AS "Id", CHARACTER AS "Character" FROM Characters')
quality_df <- dbGetQuery(conn, 'SELECT CHARACTERID AS "CharacterID", TRIM(Quality) AS "Quality" FROM Qualities')
works_df <- dbGetQuery(conn, 'SELECT CHARACTERID AS "CharacterID", WORKSTYPE AS "WorksType" FROM Works')

dbDisconnect(conn)


seabornPalette <- c("#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2",
                    "#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868",
                    "#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd",
                    "#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2",
                    "#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868",
                    "#c44e52","#8172b2","#ccb974","#64b5cd","#4c72b0","#55a868","#c44e52","#8172b2","#ccb974","#64b5cd")


# PAIRWISE CHARACTER TABLE
charqual_df <- transform(merge(character_df, quality_df, by.x="Id", by.y="CharacterID")[c("Character", "Quality")],
                         key = 1)

agg_df <- aggregate(key ~ Quality, charqual_df, length)

df_list <- by(charqual_df, charqual_df$Character, function(sub) {
  charname <- as.character(sub$Character[[1]])
  tmp <- merge(agg_df[c("Quality")], sub, by="Quality", all.x=TRUE)
  
  tmp$Character <- ifelse(is.na(tmp$Character), NA, as.character(tmp$Quality))
  setNames(tmp, c("Character", charname))[[charname]]
})

x <- Filter(function(x) length(x) == 324, df_list)

g <- tableGrob(table(x$`Mr. Freeze`, x$`Captain Ahab`))
grid.arrange(g, left=textGrob("Mr. Freeze"), bottom=textGrob("Captain Ahab"),
             top=textGrob("Pairwise Character Matrix Table", gp=gpar(fontsize=20,font=3)))


# ALL CHARACTER MATRIX
cross_join <- subset(merge(charqual_df, charqual_df, by="key"),
                     as.character(Character.x) < as.character(Character.y) & Quality.x == Quality.y)
cross_join[] <- sapply(cross_join, as.character)

agg_df <- aggregate(key ~ Character.x + Character.y, cross_join, length)
reshape_df <- reshape(agg_df, idvar="Character.x", v.names="key", timevar="Character.y", 
                      drop=c("Quality.x", "Quality.y"), direction="wide")

row.names(reshape_df) <- NULL
colnames(reshape_df) <- gsub("key.", "", colnames(reshape_df))


# HEAT MAPS (CONVERT TO SQL QUERY)
raw <- table(Char1=cross_join$Character.x, Char2=cross_join$Character.y)

for (i in c("Bleeding Gums Murphy", "Barney Gumble", "Bartleby", "Alyosha", "Hamlet")) {
  print(i)
  sub <- subset(data.frame(raw), Char1 ==i)
  sub <- with(sub, sub[order(-Freq),])
  
  print(ggplot(data = sub[1:50,], aes(x=Char1, y=Char2, fill=Freq)) + 
          geom_tile())
  
}

# OVERALL TOP 10 QUALITY COUNTS
agg_df <- setNames(aggregate(CharacterID ~ Quality, quality_df, FUN=length), c("Quality", "Count"))
agg_df <- with(agg_df, agg_df[order(-Count),])

agg_df <- within(agg_df, Quality <- factor(Quality, levels=Quality[order(-Count)]))

ggplot(head(agg_df, 10), aes(Quality, Count, fill=Quality)) + 
  geom_col() + guides(fill=FALSE) +
  labs(title="All Characters Top 10 Qualities", y="Counts") +
  scale_fill_manual(values = seabornPalette) +
  scale_y_continuous(limits = c(0,max(head(agg_df, 10)$Count)+10), expand = c(0, 0)) +
  theme(plot.title = element_text(hjust=0.5, size=18))


# PIE / DONUT CHART
prop_df <- head(agg_df, 10)
prop_df$fraction <- prop_df$Count / sum(prop_df$Count)
prop_df <- with(prop_df, prop_df[order(fraction),])
prop_df$ymax <- cumsum(prop_df$fraction)
prop_df$ymin <- c(0, head(prop_df$ymax, -1))

prop_df

ggplot(prop_df, aes(fill=Quality, ymax=ymax, ymin=ymin, xmax=4, xmin=3)) +
  geom_rect() + guides(fill=FALSE) + coord_polar(theta="y") +
  scale_fill_manual(values = seabornPalette) +
  geom_text(aes(label=Quality, x=3.85, y=(ymin+ymax)/2),
            inherit.aes = TRUE, show.legend = FALSE) +
  geom_text(aes(label=paste(round(fraction*100, 0),"%"), x=3.5, y=(ymin+ymax)/2),
            show.legend = FALSE) +
  labs(title="Top 10 Qualities Breakdown", y="", x="") +
  theme(panel.grid=element_blank(),
        axis.text=element_blank(),
        axis.ticks=element_blank(),
        plot.title = element_text(hjust = 0.5, size=18))


# TOP 10 QUALITY COUNTS BY WORKS TYPE
quality_df <- merge(quality_df, works_df, by="CharacterID")

qualplots <- by(quality_df, quality_df$WorksType, function(sub) {
  
  agg_df <- setNames(aggregate(CharacterID ~ Quality, sub, FUN=length), c("Quality", "Count"))
  agg_df <- with(agg_df, agg_df[order(-Count),])
  
  agg_df <- within(agg_df, Quality <- factor(Quality, levels=Quality[order(-Count)]))
  
  ggplot(agg_df[1:10,], aes(Quality, Count, fill=Quality)) + 
    geom_col() + guides(fill=FALSE) +
    labs(title=paste("All Characters Top 10 Qualities\nfor", sub$WorksType[[1]], "Type"), y="Counts") +
    scale_fill_manual(values = seabornPalette) + 
    scale_y_continuous(limits = c(0,max(agg_df$Count)+1), expand = c(0, 0)) +
    theme(plot.title = element_text(hjust = 0.5, size=12),
          axis.text.x = element_text(angle = 23, hjust = 1))
})

do.call(grid.arrange, qualplots)


# OVERALL TOP 10 QUALITY COUNTS
agg_df <- aggregate(CharacterID~  WorksType + Quality, quality_df, FUN=length)
agg_df <- setNames(agg_df, c("WorksType", "Quality", "Count"))
agg_df <- with(agg_df, agg_df[order(-Count),])


ggplot(agg_df[1:50,], aes(Quality, Count, fill=Quality)) + 
  geom_col() + guides(fill=FALSE) +
  labs(title="All Characters Top 50 Qualities By Works Type", y="Counts") +
  scale_fill_manual(values = seabornPalette) +
  scale_y_continuous(expand = c(0, 0)) +
  theme(plot.title = element_text(hjust = 0.5, size=18),
        axis.text.x = element_text(angle = 23, hjust = 1)) + 
  facet_wrap(~WorksType, scales="free_x")



