Q = require 'q'
fs = require 'fs'

args = process.argv

if args.length < 3
  console.log 'useage: coffee weight.coffee stats.html'
  process.exit(1)

file = args[2]
content = fs.readFileSync(file, 'utf8')
lines = content.split("\n")

dateToWeight = {}

rDay = /(\d+?\/\d+)/g
getDay = (line) ->
  matches = line.match(rDay)
  if matches?.length isnt 1
    return null
  return matches[0]

rWeight = /(\d+(\.\d+?|))\s*lbs/
getWeight = (line) ->
  matches = line.match(rWeight)
  if not matches? or matches?.length < 2
    return null
  return matches[1]

newDay = false
dayNow = null
weightDist = -1
for line in lines
  if line.indexOf('---') is 0
    newDay = true
    continue

  if newDay
    newDay = false
    day = getDay(line)
    if day
      dayNow = day
      weightDist = 2

  if weightDist > 0
    weightDist--
    continue

  if weightDist is 0
    weightDist = -1
    weight = getWeight(line)
    if weight?
      dateToWeight[ dayNow ] = weight
    dayNow = null

dates = Object.keys(dateToWeight)

dates = dates.sort (a, b) ->
  [ m1, d1 ] = a.split '/'
  [ m2, d2 ] = b.split '/'

  # Put high numbered months early (since dates are really
  # 2013 -> 2014)
  m1 = Number(m1) % 11
  m2 = Number(m2) % 11

  d1 = Number(d1)
  d2 = Number(d2)

  if m1 > m2
    return 1
  if m1 < m2
    return -1
  if d1 > d2
    return 1
  return -1

for d in dates
  console.log "#{d}, #{ dateToWeight[d] }"
