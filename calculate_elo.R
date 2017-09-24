
# base weight for regular season games
base_k = 20

# home field advantage
ha = 100

# read in original current rankings
ratings = read.csv("ratings.csv")

# read in previous game results
games = read.csv("games.csv");

# merge home and away current elo ratings
n1 <- merge(games, ratings, by.x = "Home", by.y = "Team", all.y = TRUE, incomparables = 1500)
colnames(n1)[which(names(n1) == "PassDef")] <- "HomePassDef"
colnames(n1)[which(names(n1) == "PassOff")] <- "HomePassOff"
colnames(n1)[which(names(n1) == "RunDef")] <- "HomeRunDef"
colnames(n1)[which(names(n1) == "RunOff")] <- "HomeRunOff"

# build working set
ws <- merge(n1, ratings, by.x = "Away", by.y = "Team", all.y = TRUE, incomparables = 1500)
colnames(ws)[which(names(ws) == "PassDef")] <- "AwayPassDef"
colnames(ws)[which(names(ws) == "PassOff")] <- "AwayPassOff"
colnames(ws)[which(names(ws) == "RunDef")] <- "AwayRunDef"
colnames(ws)[which(names(ws) == "RunOff")] <- "AwayRunOff"

# calculate win expectancies
ws <- cbind(ws, HomePassWE = 1 / (10 ^ -((ws$HomePassOff - ws$AwayPassDef + ha) / 400) + 1),
                HomeRunWE = 1 / (10 ^ -((ws$HomeRunOff - ws$HomeRunDef + ha) / 400) + 1),
                AwayPassWE = 1 / (10 ^ -((ws$AwayPassOff - ws$HomePassDef) / 400) + 1),
                AwayRunWE = 1 / (10 ^ -((ws$AwayRunOff - ws$HomeRunDef) / 400) + 1),
                KFactor = (1 + (abs(ws$HomeScore - ws$AwayScore) %% 7) * .25))


# now calculate new ELO scores
ws <-cbind(ws, NewHomePassOff = ws$HomePassOff + (ws$ExpPassPCT * (base_k * ws$KFactor) * (if(ws$HomeScore > ws$AwayScore) 1 else 0) - ws$HomePassWE),
               NewHomeRunOff = ws$HomeRunOff + ((1 - ws$ExpPassPCT) * (base_k * ws$KFactor) * (if(ws$HomeScore > ws$AwayScore) 1 else 0) - ws$HomeRunWE),
               NewHomePassDef = ws$HomePassDef + (ws$ExpPassPCT * (base_k * ws$KFactor) * (if(ws$HomeScore > ws$AwayScore) 1 else 0) - ws$HomePassWE),
               NewHomeRunDef = ws$HomeRunDef + ((1 - ws$ExpPassPCT) * (base_k * ws$KFactor) * (if(ws$HomeScore > ws$AwayScore) 1 else 0) - ws$HomeRunWE),
               NewAwayPassOff = ws$AwayPassOff + (ws$ExpPassPCT * (base_k * ws$KFactor) * (if(ws$AwayScore > ws$HomeScore) 1 else 0) - ws$AwayPassWE),
               NewAwayRunOff = ws$AwayRunOff + ((1 - ws$ExpPassPCT) * (base_k * ws$KFactor) * (if(ws$AwayScore > ws$HomeScore) 1 else 0) - ws$AwayRunWE),
               NewAwayPassDef = ws$AwayPassDef + (ws$ExpPassPCT * (base_k * ws$KFactor) * (if(ws$AwayScore > ws$HomeScore) 1 else 0) - ws$AwayPassWE),
               NewAwayRunDef = ws$AwayRunDef + ((1 - ws$ExpPassPCT) * (base_k * ws$KFactor) * (if(ws$AwayScore > ws$HomeScore) 1 else 0) - ws$AwayRunWE)
)

# separate out home scores removing NA
new_home_ratings <- na.omit(data.frame(Team = ws$Home, PassOff = ws$NewHomePassOff, 
                               PassDef = ws$NewHomePassDef, RunOff = ws$NewHomeRunOff, 
                               RunDef = ws$NewHomeRunDef))

new_away_ratings <- data.frame(Team = ws$Away, PassOff = ws$NewAwayPassOff, 
                               PassDef = ws$NewAwayPassDef, RunOff = ws$NewAwayRunOff, 
                               RunDef = ws$NewAwayRunDef)

new_ratings <- rbind(new_home_ratings, new_away_ratings)

# set any NAs to default 
new_ratings$PassOff[is.na(new_ratings$PassOff)] <- 1500
new_ratings$RunOff[is.na(new_ratings$RunOff)] <- 1500
new_ratings$PassDef[is.na(new_ratings$PassDef)] <- 1500
new_ratings$RunDef[is.na(new_ratings$RunDef)] <- 1500

# write out new ratings
today = format(Sys.time(), "%Y-%m-%d")
outfile = paste("ratings", today, sep="_")
outfile = paste(outfile, "csv", sep=".")

write.csv(new_ratings, file = outfile, row.names=FALSE);
