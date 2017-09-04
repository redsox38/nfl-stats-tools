#!/usr/bin/env python3

from bs4 import BeautifulSoup
import urllib3
import csv
import datetime

xlate = dict.fromkeys(map(ord, '\n'), None)
season = '2016'
#base_url = 'http://www.nfl.com/stats/categorystats?archive=true&conference=null&statisticPositionCategory=RUNNING_BACK&season=2016&seasonType=REG&experience=&tabSeq=1&qualified=true&Submit=Go'
base_url = 'http://www.nfl.com/stats/categorystats?archive=true&conference=null&seasonType=REG&experience=&tabSeq=1&qualified=true&Submit=Go'
positions = [ "QUARTERBACK" ,"RUNNING_BACK" ,"WIDE_RECEIVER" ,"TIGHT_END" ,"DEFENSIVE_LINEMAN" ,"LINEBACKER" ,"DEFENSIVE_BACK" ,"KICKOFF_KICKER" ,"KICK_RETURNER" ,"PUNTER" ,"PUNT_RETURNER" ,"FIELD_GOAL_KICKER"]

for p in positions:
  fn = p + '_' + datetime.date.today().strftime('%Y-%m-%d') + '.csv'

  http = urllib3.PoolManager()
  u = base_url + '&season=' + season + '&statisticPositionCategory=' + p
  rsp = http.request('GET', u)

  s = BeautifulSoup(rsp.data, 'html.parser')
  t = s.select_one('table.data-table1')
  hdrs = []
  for th in t.select("th"):
    l = th.text.translate(xlate)
    hdrs.append(l)

  # write out data
  with open(fn, "w") as f:
    wr = csv.writer(f)
    wr.writerow(hdrs)
    wr.writerows([[td.text.strip() for td in row.find_all("td")] for row in t.select("tr + tr")])
