import ../esyllt
import std/[os, terminal, unicode]
import strformat

discard fmt"{0.Rune}"
# Nid Nano, golygudd tecst sy'n debyg i nano GNU

const HELPIAU = ["C-g :: Gadael", "C-y :: Ysgrifennu"]
const PARHAD  = 1000 div 30

type Cynllun = object
  lled, uchder: Natural
  lledTeitl: Natural

func rendroTeitl(byff: var ByfferTerfynell, cyn: Cynllun, teitl: Tecst) =
  let x = (cyn.lled shr 1) - (teitl.hyd shr 1)
  for dx, r in teitl:
    byff[x + dx, 0] = r

proc rendroBwrdd(bwrdd: var ByfferTerfynell): Cynllun =
  # rendro'r bwrdd ag yn creu cynllun I'wn golygudd defnyddio
  const marc = @"Nid Nano"
  let 
    ll = bwrdd.lled
    u  = bwrdd.uchder
  result.lled = ll
  for x in 0 ..< ll:
    bwrdd[x, 0].fg = fgBlack
    bwrdd[x, 0].bg = bgWhite
  if ll > marc.hyd + 5:
    for i, x in @"Nid Nano":
      bwrdd[i, 0] = x
    result.lledTeitl = ll - (marc.hyd * 2 + 1)
  else:
    result.lledTeitl = ll - 2

  var llinellau = newSeq[Tecst]()
  block:
    var llinell = tecstNewiddOCap(ll)
    for help in HELPIAU:
      let destun = @help
      if llinell.hyd + destun.hyd > ll:
        llinellau.add llinell
        llinell = tecstNewiddOCap(ll)
      llinell &= destun
      llinell.adio (@' ')
    if llinell.hyd > 0:
      llinellau.add llinell
  for dy, tecst in llinellau:
    let y = u - (llinellau.len - dy)
    for x, r in tecst: bwrdd[x, y] = r
  result.uchder = u - (1 + llinellau.len)
  for x in 0 ..< ll:
    var rune = addr bwrdd[x, result.uchder]
    rune[].fg = fgBlack
    rune[].bg = bgWhite
  
###############

type
  Targed = object
    case agor: bool
    of true: llwybr: Tecst
    of false: discard

func estynTeitl(targed: Targed): Tecst =
  case targed.agor
  of true: targed.llwybr
  of false: @"[ddim enw]"

template mewnLwp(côd: untyped) =
  mixin bwrdd, cynllun
  while true:
    hideCursor(); bwrdd.darparu(stdout)
    showCursor()
    let (n, r) = estynNodR()
    let nod {. inject, used .} = n
    let rune {. inject, used .} = r
    côd

func rendroYnFfenstr(bwrdd:  dechray: Pwynt, tecst: Tecst; gwth, lled: Natural) =
  let lledTecst = min(lled, tecst.hyd - gwth)
  let lledGwag  = lled - lledTecst

template estynTecst(anogwr: Tecst, cynateb = @""): Tecst =
  mixin bwrdd, cynllun
  let manDestun = Pwynt(x: 0, y: cynllun.uchder)
  var tecst = tecstNewidd()
  var cyrchwr = 0
  let lledFfenestr = bwrdd.lled - anogwr.hyd
  var gwthFfenestr = 0 
  # chwydu anogwr arno'r destun
  for i, r in anogwr:
    bwrdd[i, manDestun.y] = r

  mewnLwp:
    var newid = false
    setCursorPos(cyrchwr + anogwr.hyd, manDestun.y)
    showCursor()
    case nod
    of Nod.Enter:
      break
    of Nod.Left:
      if cyrchwr > 0: dec cyrchwr
    of Nod.Right:
      if cyrchwr < tecst.hyd: inc cyrchwr
    of Nod.Backspace:
      if cyrchwr > 0: tecst.dileu(cyrchwr - 1)
      newid = true
    of Nod.Delete:
      newid = true
      if cyrchwr < tecst.hyd: tecst.dileu(cyrchwr)
    else:
      if nod == Nod.Unicode or rune != 0.Rune:
        tecst.mewnosod rune, cyrchwr
        inc cyrchwr
        newid = true
      else:
        sleep PARHAD
    if newid:
      for i in 0 ..< tecst.hyd:
        bwrdd[i + anogwr.hyd, manDestun.y] = tecst[i.Natural]
        continue
      for i in tecst.hyd ..< bwrdd.lled: bwrdd[i + anogwr.hyd, manDestun.y] = @' '
  # gwagio'r destun
  for x in 0 ..< bwrdd.lled:
    bwrdd[x, manDestun.y] = @' '
  tecst

proc darllenFfeil(destyn: var seq[Tecst], llwybr: Tecst, llinell: Natural) =
  let path = $llwybr
  var i = 0
  for ll in lines(path):
    destyn.insert(@ll, llinell + i)
    inc i
  
proc ysgrifennuFfeil(destyn: seq[Tecst], llwybr: Tecst) =
  var f = open($llwybr, fmwrite)
  for llinell in destyn:
    f.writeLine $llinell

template rendroDestyn() =
  mixin bwrdd, cynllun, destyn, xc, yc, yff
  for ind in yff ..< min(cynllun.uchder, destyn.len - yff):
    for x, r in destyn[ind]:
      bwrdd[x, ind + 1] = r

func estynNeu(a: Targed, b: Tecst): Tecst =
  if a.agor: a.llwybr
  else: b

proc prif(argiau: seq[Tecst]): int =
  let (ll, u) = terminalSize()
  if u < 20 or ll < 30:
    echo "Mae'r terfynell yn rhy bach i nidnano rhedeg"
    return 1
  
  dechrayEsyllt()
  defer:
    stopioEsyllt()
  
  var bwrdd = byfferNewidd(ll, u)
  let cynllun = rendroBwrdd(bwrdd)

  var
    destyn = newSeq[Tecst]()
    xc:  Natural = 0
    yc:  Natural = 0
    yff: Natural = 0
    wediNewid = false
    targed = (if argiau.len > 0:
                Targed(agor: true, llwybr: @argiau[0])
              else:
                Targed(agor: false))
  if targed.agor:
    darllenFfeil(destyn, targed.llwybr, 0)
  bwrdd.rendroTeitl(cynllun, targed.estynTeitl)
  rendroDestyn()
  mewnLwp:
    case nod
    of Nod.CtrlG:
      break
    of Nod.CtrlY:
      discard estynTecst(@"llwybr? ", targed.estynNeu(@""))
    else: discard
    sleep PARHAD

when isMainModule:
  let aLlC = commandLineParams()
  var argiau = newSeq[Tecst](aLlC.len)
  for i, v in aLlC:
    argiau[i] = @v
  quit prif(argiau)
