import ../esyllt

import std/[terminal, unicode, os]

dechrayEsyllt()
hideCursor()
let (ll, u) = terminalSize()
let
  lls = ll shr 1
  us  = u  shr 1
  x = (ll shr 1) - (lls shr 1)
  y = (u  shr 1) - (us  shr 1)


var byff = byfferNewidd(ll, u)
for i, r in "G: Gadael".toRunes:
  byff[i, 0] = r

var runeSyl = RuneTerfynell(
  symbol: ' '.Rune, fg: fgDefault, bg: bgDefault,
  style: {styleReverse}, bright: true)
var style2: set[Style] = {}
var
  dx = 0
  dy = 0

while estynNod() notin [Nod.G, Nod.ShiftG]:
  byff.darparu(stdout)
  sleep 41# tua 12FYE(FPS)
  byff[x + dx, y + dy] = runeSyl
  inc dx
  if dx >= lls: inc dy; dx = 0
  if dy >= us:
    dy = 0
    swap(runeSyl.style, style2)

stopioEsyllt()
showCursor()
