for (pos in c("QUARTERBACK" ,"RUNNING_BACK" ,"WIDE_RECEIVER" ,"TIGHT_END" ,"DEFENSIVE_LINEMAN" ,"LINEBACKER" ,"DEFENSIVE_BACK" ,"KICKOFF_KICKER" ,"KICK_RETURNER" ,"PUNTER" ,"PUNT_RETURNER" ,"FIELD_GOAL_KICKER")) {
  today = format(Sys.time(), "%Y-%m-%d")
  file = paste(pos, today, sep="_")
  file = paste(file, "csv", sep=".")
  mydata = read.csv(file)
}
