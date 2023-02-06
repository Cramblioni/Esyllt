import termios, posix, tables
import terminal, os, unicode
import strformat

var origTermios: Termios
var curTermios: Termios

# ripped from IllWill
type Nod* {. pure .} = enum
  Unicode = (-2, "Unicode") # added this
  Dim = (-1, "None"),

  # Special ASCII characters
  CtrlA  = (1, "CtrlA"), CtrlB  = (2, "CtrlB"),
  CtrlC  = (3, "CtrlC"), CtrlD  = (4, "CtrlD"),
  CtrlE  = (5, "CtrlE"), CtrlF  = (6, "CtrlF"),
  CtrlG  = (7, "CtrlG"), CtrlH  = (8, "CtrlH"),
  Tab    = (9, "Tab"),     # Ctrl-I
  CtrlJ  = (10, "CtrlJ"),
  CtrlK  = (11, "CtrlK"), CtrlL  = (12, "CtrlL"),
  Enter  = (13, "Enter"),  # Ctrl-M
  CtrlN  = (14, "CtrlN"),
  CtrlO  = (15, "CtrlO"), CtrlP  = (16, "CtrlP"),
  CtrlQ  = (17, "CtrlQ"), CtrlR  = (18, "CtrlR"),
  CtrlS  = (19, "CtrlS"), CtrlT  = (20, "CtrlT"),
  CtrlU  = (21, "CtrlU"), CtrlV  = (22, "CtrlV"),
  CtrlW  = (23, "CtrlW"), CtrlX  = (24, "CtrlX"),
  CtrlY  = (25, "CtrlY"), CtrlZ  = (26, "CtrlZ"),
  Escape = (27, "Escape"),

  CtrlBackslash    = (28, "CtrlBackslash"),
  CtrlRightBracket = (29, "CtrlRightBracket"),

  # Printable ASCII characters
  Space           = (32, "Space"),
  ExclamationMark = (33, "ExclamationMark"),
  DoubleQuote     = (34, "DoubleQuote"),
  Hash            = (35, "Hash"),
  Dollar          = (36, "Dollar"),
  Percent         = (37, "Percent"),
  Ampersand       = (38, "Ampersand"),
  SingleQuote     = (39, "SingleQuote"),
  LeftParen       = (40, "LeftParen"),
  RightParen      = (41, "RightParen"),
  Asterisk        = (42, "Asterisk"),
  Plus            = (43, "Plus"),
  Comma           = (44, "Comma"),
  Minus           = (45, "Minus"),
  Dot             = (46, "Dot"),
  Slash           = (47, "Slash"),

  Zero  = (48, "Zero"), One   = (49, "One"), Two   = (50, "Two"),
  Three = (51, "Three"), Four  = (52, "Four"), Five  = (53, "Five"),
  Six   = (54, "Six"), Seven = (55, "Seven"), Eight = (56, "Eight"),
  Nine  = (57, "Nine"),

  Colon        = (58, "Colon"),
  Semicolon    = (59, "Semicolon"),
  LessThan     = (60, "LessThan"),
  Equals       = (61, "Equals"),
  GreaterThan  = (62, "GreaterThan"),
  QuestionMark = (63, "QuestionMark"),
  At           = (64, "At"),

  ShiftA  = (65, "ShiftA"), ShiftB  = (66, "ShiftB"),
  ShiftC  = (67, "ShiftC"), ShiftD  = (68, "ShiftD"),
  ShiftE  = (69, "ShiftE"), ShiftF  = (70, "ShiftF"),
  ShiftG  = (71, "ShiftG"), ShiftH  = (72, "ShiftH"),
  ShiftI  = (73, "ShiftI"), ShiftJ  = (74, "ShiftJ"),
  ShiftK  = (75, "ShiftK"), ShiftL  = (76, "ShiftL"),
  ShiftM  = (77, "ShiftM"), ShiftN  = (78, "ShiftN"),
  ShiftO  = (79, "ShiftO"), ShiftP  = (80, "ShiftP"),
  ShiftQ  = (81, "ShiftQ"), ShiftR  = (82, "ShiftR"),
  ShiftS  = (83, "ShiftS"), ShiftT  = (84, "ShiftT"),
  ShiftU  = (85, "ShiftU"), ShiftV  = (86, "ShiftV"),
  ShiftW  = (87, "ShiftW"), ShiftX  = (88, "ShiftX"),
  ShiftY  = (89, "ShiftY"), ShiftZ  = (90, "ShiftZ"),

  LeftBracket  = (91, "LeftBracket"),
  Backslash    = (92, "Backslash"),
  RightBracket = (93, "RightBracket"),
  Caret        = (94, "Caret"),
  Underscore   = (95, "Underscore"),
  GraveAccent  = (96, "GraveAccent"),

  A = (97, "A"), B = (98, "B"), C = (99, "C"), D = (100, "D"),
  E = (101, "E"), F = (102, "F"), G = (103, "G"),H = (104, "H"),
  I = (105, "I"), J = (106, "J"), K = (107, "K"), L = (108, "L"),
  M = (109, "M"), N = (110, "N"), O = (111, "O"), P = (112, "P"),
  Q = (113, "Q"), R = (114, "R"), S = (115, "S"), T = (116, "T"),
  U = (117, "U"), V = (118, "V"), W = (119, "W"), X = (120, "X"),
  Y = (121, "Y"), Z = (122, "Z"),

  LeftBrace  = (123, "LeftBrace"),
  Pipe       = (124, "Pipe"),
  RightBrace = (125, "RightBrace"),
  Tilde      = (126, "Tilde"),
  Backspace  = (127, "Backspace"),

  # Special characters with virtual keycodes
  Up       = (1001, "Up"),
  Down     = (1002, "Down"),
  Right    = (1003, "Right"),
  Left     = (1004, "Left"),
  Home     = (1005, "Home"),
  Insert   = (1006, "Insert"),
  Delete   = (1007, "Delete"),
  End      = (1008, "End"),
  PageUp   = (1009, "PageUp"),
  PageDown = (1010, "PageDown"),

  F1  = (1011, "F1"), F2  = (1012, "F2"), F3  = (1013, "F3"),
  F4  = (1014, "F4"), F5  = (1015, "F5"), F6  = (1016, "F6"),
  F7  = (1017, "F7"), F8  = (1018, "F8"), F9  = (1019, "F9"),
  F10 = (1020, "F10"), F11 = (1021, "F11"), F12 = (1022, "F12"),

proc mewnLlondsgrin*(file: File)
proc allanLlondsgrin*(file: File)

proc dechrayEsyllt*() =
  discard tcGetAttr(STDIN_FILENO, addr origTermios)
  curTermios = origTermios

  curTermios.c_lflag = curTermios.c_lflag and not (
      BRKINT or INPCK or ISTRIP or ECHO or ICANON or ISIG or IEXTEN)
  curTermios.c_iflag = curTermios.c_iflag and not (IXON or ICRNL)
  curTermios.c_oflag = curTermios.c_oflag and not (OPOST)
  curTermios.c_cflag = curTermios.c_cflag or (CS8)

  curTermios.c_cc[VMIN] = 0.char
  curTermios.c_cc[VTIME] = 1.char

  discard tcSetAttr(STDIN_FILENO, TCIFLUSH, addr curTermios)
  stdout.mewnLlondsgrin()

proc stopioEsyllt*() =
  stdout.allanLlondsgrin()
  discard tcSetAttr(STDIN_FILENO, TCIFLUSH, addr origTermios)

proc kbhit(): cint =
  var tv: Timeval
  tv.tv_sec = Time(0)
  tv.tv_usec = 0
  var fds: TFdSet
  FD_ZERO(fds)
  FD_SET(STDIN_FILENO, fds)
  discard select(STDIN_FILENO+1, fds.addr, nil, nil, tv.addr)
  return FD_ISSET(STDIN_FILENO, fds)

# This is now a warning, We have this handled
# but Nim doesn't like how we have it handled
{.warning[HoleEnumConv]:off.}
func iNod(x: int): Nod =
  try: return Nod(x)
  except RangeDefect: return Nod.Dim
{.warning[HoleEnumConv]:on.}

const dilyniannauNod = {
  ord(Nod.Up):        @["\eOA", "\e[A"],
  ord(Nod.Down):      @["\eOB", "\e[B"],
  ord(Nod.Right):     @["\eOC", "\e[C"],
  ord(Nod.Left):      @["\eOD", "\e[D"],

  ord(Nod.Home):      @["\e[1~", "\e[7~", "\eOH", "\e[H"],
  ord(Nod.Insert):    @["\e[2~"],
  ord(Nod.Delete):    @["\e[3~"],
  ord(Nod.End):       @["\e[4~", "\e[8~", "\eOF", "\e[F"],
  ord(Nod.PageUp):    @["\e[5~"],
  ord(Nod.PageDown):  @["\e[6~"],

  ord(Nod.F1):        @["\e[11~", "\eOP"],
  ord(Nod.F2):        @["\e[12~", "\eOQ"],
  ord(Nod.F3):        @["\e[13~", "\eOR"],
  ord(Nod.F4):        @["\e[14~", "\eOS"],
  ord(Nod.F5):        @["\e[15~"],
  ord(Nod.F6):        @["\e[17~"],
  ord(Nod.F7):        @["\e[18~"],
  ord(Nod.F8):        @["\e[19~"],
  ord(Nod.F9):        @["\e[20~"],
  ord(Nod.F10):       @["\e[21~"],
  ord(Nod.F11):       @["\e[23~"],
  ord(Nod.F12):       @["\e[24~"],
}.toTable

proc estynNodR*(): tuple[k: Nod, r: Rune] =
  var 
    buff: array[8,char]
    ind = 0
  while kbhit() > 0:
    if read(STDIN_FILENO, addr buff[ind], 1) == 0:
      break
    inc ind
  if ind == 0: return (Nod.Dim, 0.Rune)
  # now we parse the key
  if ind == 1:
    case buff[0].uint8
    of 9:  return (Nod.Tab, 9.Rune)
    of 10: return (Nod.Enter, 10.Rune)
    of 27: return (Nod.Escape, 27.Rune)
    of 32: return (Nod.Space, 32.Rune)
    of 0, 29, 30, 31: return (Nod.Dim, 0.Rune)
    of 33 .. 127: return (iNod(buff[0].int), buff[0].Rune)
    else: return (iNod(buff[0].int), 0.Rune)
  else:
    # key lookups
    var dilynNod = newStringOfCap(ind - 1)
    for i in 0 ..< ind: dilynNod.add buff[i]
    # utf8 or ascii check
    if (dilynNod[0].uint8 shr 7) > 0: # utf8
      return (Nod.Unicode, runeAt(dilynNod, 0))
    for nod, dilyniannau in dilyniannauNod.pairs:
      for dilnod in dilyniannau:
        if dilnod == dilynNod: return (iNod(nod), 0.Rune)
  return (Nod.Dim, 0.Rune)

proc estynNod*(): Nod = estynNodR()[0]

const
  XtermColor    = "xterm-color"
  Xterm256Color = "xterm-256color"

proc mewnLlondsgrin*(file: File) =
  ## Enters full-screen mode (clears the terminal).
  when defined(posix):
    case getEnv("TERM"):
    of XtermColor:
      stdout.write "\e7\e[?47h"
    of Xterm256Color:
      stdout.write "\e[?1049h"
    else:
      eraseScreen()
  else:
    eraseScreen()

proc allanLlondsgrin*(file: File) =
  ## Exits full-screen mode (restores the previous contents of the terminal).
  when defined(posix):
    case getEnv("TERM"):
    of XtermColor:
      stdout.write "\e[2J\e[?47l\e8"
    of Xterm256Color:
      stdout.write "\e[?1049l"
    else:
      eraseScreen()
  else:
    eraseScreen()
    setCursorPos(0, 0)

# finally starting with our buffering interface
# ripped from IllWill [ish]
# utility/ convenience point type

type
  RuneTerfynell* = object
    symbol*: Rune
    fg*: ForegroundColor
    bg*: BackgroundColor
    style*: set[Style]
    bright*: bool

func rendroBg*(x: RuneTerfynell): string =
  ansiStyleCode(x.bg.ord + (if x.bright: 60 else: 0))
func rendroFg*(x: RuneTerfynell): string =
  ansiStyleCode(x.fg.ord + (if x.bright: 60 else: 0))
func rendroStyle*(x: RuneTerfynell): string =
  result = newStringOfCap(x.style.card * 4)
  for stylette in x.style.items: result &= ansiStyleCode(stylette.ord)

func `~~`*(a, b: RuneTerfynell): bool = # similar operator
  (a.fg == b.fg) and (a.bg == b.bg) and (a.style == b.style) and (a.bright and b.bright)

type
  ByfferTerfynellObj = object
    tlled, tuchder: Natural
    celloedd: seq[RuneTerfynell]
  ByfferTerfynell* = ref ByfferTerfynellObj

# buffer creation functions
func byfferNewidd*(lled, uchder: Natural): ByfferTerfynell =
  const blank = RuneTerfynell(
    symbol: ' '.Rune,
    bg: bgDefault, fg: fgDefault,
    style: {}, bright: false)
  result = new ByfferTerfynellObj
  result.tlled = lled
  result.tuchder = uchder
  result.celloedd = newSeq[RuneTerfynell](lled * uchder)
  for i in 0 ..< lled * uchder:
    result.celloedd[i] = blank

# buffer interfacing functions
func lled*(byff: ByfferTerfynell): Natural = byff.tlled
func uchder*(byff: ByfferTerfynell): Natural = byff.tuchder


func `[]`*(byff: ByfferTerfynell; x, y: int): RuneTerfynell =
  if 0 > x or x >= byff.tlled:
    return
  if 0 > y or y >= byff.tuchder:
    return
  byff.celloedd[x + y * byff.tlled]

func `[]`*(byff: var ByfferTerfynell; x, y: int): var RuneTerfynell =
  if 0 > x or x >= byff.tlled:
    return
  if 0 > y or y >= byff.tuchder:
    return
  byff.celloedd[x + y * byff.tlled]

func `[]=`*(byff: var ByfferTerfynell; x,y: int; rune: RuneTerfynell) =
  ## noop if (x, y) out of bounds
  if 0 > x or x >= byff.tlled:
    return
  if 0 > y or y >= byff.tuchder:
    return
  byff.celloedd[x + y * byff.tlled] = rune

func `[]=`*(byff: var ByfferTerfynell; x, y: int, rune: Rune) =
  ## noop if (x, y) out of bounds
  if 0 > x or x >= byff.tlled:
    return
  if 0 > y or y >= byff.tuchder:
    return
  let ind = x + y * byff.tlled
  var base = byff.celloedd[ind]
  base.symbol = rune
  byff.celloedd[ind] = base

func chwydu*(cyrch: var ByfferTerfynell, ffyn: ByfferTerfynell; fx, fy, cx, cy: Natural) =
  let
    nw = max(min(cyrch.tlled - cx, ffyn.tlled - fx), 0.int)
    nh = max(min(cyrch.tuchder - cy, ffyn.uchder - fy), 0.int)
  for y in 0 ..< nh:
    for x in 0 ..< nw:
      cyrch[x + cx, y + cy] = ffyn[x + fx, y + fy]

func llenwy*(byff: var ByfferTerfynell, rune: RuneTerfynell) =
  for i in 0 ..< byff.tlled * byff.tuchder:
    byff.celloedd[i] = rune

func clôn*(byff: ByfferTerfynell; x, y, ll, u: Natural): ByfferTerfynell =
  result = byfferNewidd(ll, u)
  for yc in 0 ..< u:
    for xc in 0 ..< ll:
      result[xc, yc] = byff[x + xc, y + yc]

proc darparu*(byff: ByfferTerfynell, file: File) =
  file.setCursorPos(0, 0)
  var cur : RuneTerfynell = byff.celloedd[0]
  file.resetAttributes()
  file.write (cur.rendroBg & cur.rendroFg)
  for y in 0 ..< byff.tuchder:
    let yoff = y * byff.tlled
    file.setCursorPos(0, y)
    for x in 0 ..< byff.tlled:
      let ap = byff.celloedd[yoff + x]
      if not (ap ~~ cur):
        # file.resetAttributes()
        if ap.bg != cur.bg: file.write ap.rendroBg
        if ap.fg != cur.fg: file.write ap.rendroFg
        if ap.style != cur.style: file.write ap.rendroStyle
        cur = ap
      file.write $ap.symbol
    file.flushFile()


type Pwynt* = object
  x*, y*: int
#converter toPoint(p: tuple[x, y: int]): Pwynt = Pwynt(x: p[0], y: p[1])

func iNat(x: int): Natural {. inline .} = (if x < 0: 0 else: x)
func `+`*(a, b: Pwynt): Pwynt = Pwynt(x: a.x + b.x, y: a.y + b.y)
func `-`*(a, b: Pwynt): Pwynt = Pwynt(x: a.x - b.x, y: a.y - b.y)
func `*`*(a, b: Pwynt): Pwynt = Pwynt(x: a.x * b.x, y: a.y * b.y)

func chwydu*(cyrch: var ByfferTerfynell, ffyn: ByfferTerfynell; f, c: Pwynt) =
  chwydu(cyrch, ffyn,
          f.x.iNat, f.y.iNat,
          c.x.iNat, c.y.iNat)

func `[]`*(byff: ByfferTerfynell; p: Pwynt): RuneTerfynell =
  byff[p.x.iNat, p.y.iNat]
func `[]`*(byff: var ByfferTerfynell; p: Pwynt): RuneTerfynell =
  byff[p.x.iNat, p.y.iNat]
func `[]=`*(byff: var ByfferTerfynell; p: Pwynt; rune: RuneTerfynell) =
  byff[p.x.iNat, p.y.iNat] = rune
func `[]=`*(byff: var ByfferTerfynell; p: Pwynt, rune: Rune) =
  byff[p.x.iNat, p.y.iNat] = rune


func clôn*(byff: ByfferTerfynell, p: Pwynt; ll, u: Natural): ByfferTerfynell =
  clôn(byff, p.x.iNat, p.y.iNat, ll, u)
func clôn*(byff: ByfferTerfynell; p, m: Pwynt): ByfferTerfynell =
  clôn(byff, p.x.iNat, p.y.iNat, m.x.iNat, m.y.iNat)

# Achos unicode
type Tecst* = distinct seq[Rune]
func tecstNewidd*(): Tecst = Tecst(newSeq[Rune](0))
func tecstNewiddOCap*(capasiti: Natural): Tecst = Tecst(newSeqOfCap[Rune](capasiti))
func hyd*(tecst: Tecst): int = seq[Rune](tecst).len
func `[]`*(tecst: Tecst, i: Natural | BackwardsIndex): lent Rune =
  seq[Rune](tecst)[i]
func `[]`*(tecst: var Tecst, i: Natural | BackwardsIndex): var Rune =
  seq[Rune](tecst)[i]

func add*(tecst: var Tecst, v: Rune) = seq[Rune](tecst).add v
func adio*(tecst: var Tecst, v: Rune) = seq[Rune](tecst).add v
func `&`*(a, b: Tecst): Tecst = Tecst(seq[Rune](a) & seq[Rune](b))
func `&=`*(a: var Tecst, b: Tecst) =
  for x in seq[Rune](b): seq[Rune](a).add x
func mewnosod*(tecst: var Tecst, r: Rune, ind: Natural) =
  seq[Rune](tecst).insert(r, ind)
func dileu*(tecst: var Tecst, ind: Natural) = seq[Rune](tecst).delete ind

func `@`*(t: string): Tecst = Tecst(t.toRunes)
func `@`*(t: char): Rune = t.Rune
func `$`*(t: Tecst): string = $seq[Rune](t)

iterator items*(t: Tecst): Rune =
  for x in seq[Rune](t): yield x
iterator pairs*(t: Tecst): tuple[ind: int, rune: Rune] =
  for i, x in seq[Rune](t): yield (i, x)
