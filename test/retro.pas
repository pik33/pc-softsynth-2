
// Retromachine memory map @bytes

//$   00000-$    0FFFF reserved
//    0D400-     0D418 SID
//$   10000-$    4FFFF pallette banks;
//$   50000-$    50FFF 8x16 font
//$   51000-$    51FFF 8x8 fonts x2
//    52000-     59FFF sprite defs 8x4k
//    5A000-     5AFFF audio buffer 4k
//    5B000-     5FFFF reserved
//    60000-     6FFFF hardware regs area
//    70000-    FFFFFF low memory area    (16 MB-448 kB)
//  1000000-   EFFFFFF Basic area        (224 MB)
//  F000000-   FFFFFFF framebuffer area   (16 MB)


// $18000 - hard regs area @long

// 18000 - 60000 - frame counter
// 18001 - 60004 - display start
// 18002 - 60008 - current graphics mode (@60008 only)
//         60009 - bytes per pixel
// 18003 - 6000C - border color
// 18004 - 60010 - pallette bank
// 18005 - 60014 - horizontal pallette selector  bit 31 on, 30..20 add to $18004, 11:0 pixel num.
// 18006 - 60018 - display list start addr
//                 DL entry: 0_LLLLL_MM - display LLLLL lines in mode MM
//                           1_AAAAAAA - set display address to AAAAAAA
//                           F_AAAAAAA - goto address AAAAAAA
// 18007 - 6001C - horizontal scroll right register
// 18008 - 60020 - x res
// 18009   60024 - y res
// 1800A - 60028 - KBD. If key pressed then ascii code in 60028 and 1 in 6002b
// 1800B - 6002C - mouse. 6002c,d x 6002e,f y
// 1800C - 60030   keys,
// 1800D - 60034 - current dl position
// 18010 - 1801F   - sprite control long 0 31..16 y pos  15..0 x pos
//                               long 1 30..16 y zoom 15..0 x zoom 31 mode

// graphic modes: 00..15 256 col; 16..31 64k col; 32..47 32bit col; 48..63 ham (?)

unit retro;

// stripped down retromachine for sound project. Only Graphics 16 left.
// 70001 - raster interrupts effect
// 70002 - fullscreen

{$mode objfpc}{$H+}

interface

uses sdl3,sysutils,crt,classes,windows,forms,audio;

type tram=array[0..67108863] of integer;
     tramw=array[0..134217727] of word;
     tramb=array[0..268435455] of byte;
     tsample=array[0..1] of smallint;

     TRetro = class(TThread)
     private
     protected
       procedure Execute; override;
     public
       Constructor Create(CreateSuspended : boolean);
     end;

     TFiltertable=array[0..13] of double;

var fh:integer;
    scr:PSDL_window;
    sdlRenderer:PSDL_Renderer;
    sdltexture:psdl_texture;
    p2,p3:^integer;
    p4: ^byte absolute p3;
    tim,t,t2,t3,ts:int64;
    vblank1:byte;
    needrestart:byte=0;
    needclose:byte=0;

    combined:array[0..1023] of byte;
    scope:array[0..959] of integer;

    desired,obtained:TSDL_AudioSpec;

    db:boolean=false;
    debug:integer;
    sidtime:int64;
    timer1:int64=-1;
    siddelay:int64=20000;
    songtime,songfreq:int64;
    skip:integer;
    scj:integer=0;
    ft1r:Tfiltertable=(0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    ft1l:Tfiltertable=(0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    thread:TRetro;

    r1:pointer;
    raml:^tram absolute r1;
    ramw:^tramw absolute r1;
    ramb:^tramb absolute r1;

    juzmoznagrac:integer=-1;
   playtime:double=0;
    jj:integer=0; // audio callback

       currentwp:pointer=nil;
       w8p:^byte absolute currentwp;
       w16p:^smallint absolute currentwp;
       w32p:^single absolute currentwp;

 //      cvt:TSdl_audiocvt;
       il,currentil:integer;

       currentdatasize, samplenum:int64;



    procedure initmachine(mode:integer);
    procedure stopmachine;
    procedure graphics(mode:integer);
    procedure scrconvert(screen:pointer; buf:integer);
    procedure scrconvert2(screen:pointer; buf:integer);
    procedure setataripallette(bank:integer);
    procedure cls(c:integer);
    procedure putpixel(x,y,color:integer);
    procedure line(x,y,l,h,c:integer);
    procedure line2(x1,y1,x2,y2,c:integer);
    procedure putchar(x,y:integer;ch:char;col:integer);
    procedure outtextxy(x,y:integer; t:string;c:integer);
    procedure blit(from,x,y,too,x2,y2,length,lines,bpl1,bpl2:integer);
    procedure box(x,y,l,h,c:integer);
    procedure box2(x1,y1,x2,y2,color:integer);
    function gettime:int64;
    procedure poke(addr:integer;b:byte);
    procedure dpoke(addr:integer;w:word);
    procedure lpoke(addr:integer;c:cardinal);
    procedure slpoke(addr,i:integer);
    function peek(addr:integer):byte;
    function dpeek(addr:integer):word;
    function lpeek(addr:integer):cardinal;
    function slpeek(addr:integer):integer;
    procedure sethidecolor(c,bank,mask:integer);
    procedure putcharz(x,y:integer;ch:char;col,xz,yz:integer);
    procedure outtextxyz(x,y:integer; t:string;c,xz,yz:integer);
    procedure scrollup;
    procedure wait(us:int64);
    procedure wvbl;
    procedure button(x,y,l,h,c1,c2:integer;s:string);
    function testmouse(x,y,l,h:integer):boolean;
    function getpixel(x,y:integer):integer;
    procedure putcharz3(x,y:integer;ch:char;col:integer);
    procedure outtextxyz3(x,y:integer; t:string;c:integer);

implementation


var
  running:integer=0;
  fh2:integer;


// ---- prototypes

procedure sprite(screen:pointer); forward;
procedure sdlevents; forward;
procedure AudioCallback(userdata:pointer; audio:Pbyte; length:integer); cdecl;    forward;
function sdl_sound_init:integer; forward;
procedure vblank; forward;

operator =(a,b:tsdl_audiospec):boolean;

begin
if (a.freq=b.freq)
    and (a.format=b.format)
    and (a.channels=b.channels)
 //   and (a.samples=b.samples)
then result:=true else result:=false;
end;

// ---- TRetro thread methods --------------------------------------------------

// ----------------------------------------------------------------------
// constructor: create the thread for the retromachine
// ----------------------------------------------------------------------

constructor TRetro.Create(CreateSuspended : boolean);

begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

// ----------------------------------------------------------------------
// THIS IS THE MAIN RETROMACHINE THREAD
// - convert retromachine screen to raspberry screen
// - display sprites
// - get hardware events from sdl and put them to system variable
// ----------------------------------------------------------------------

procedure TRetro.Execute;

var  t,buf:int64;
     i,j,k,l:integer;
     d:boolean;
     driver:pchar;
     s:psdl_surface;

begin
s:=SDL_LoadBMP('.\lettuce.bmp');
d:=SDL_Init(SDL_INIT_audio or SDL_INIT_video or SDL_INIT_events);
    driver:=sdl_getrenderdriver(0);
//SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, 'best'); // make the scaled rendering look smoother.
SDL_SetHint(SDL_HINT_RENDER_DIRECT3D_THREADSAFE, '1');
if peek($70002)=1 then scr := SDL_CreateWindow( 'The Retromachine', 1920,1200 , SDL_WINDOW_fullscreen)
else scr := SDL_CreateWindow( 'The Retromachine',  1792,1120, 0);
sdlRenderer := SDL_CreateRenderer(scr,driver);
SDL_SetRenderVSync(sdlRenderer, 1);
if peek($70002)=1  then begin sdlTexture := SDL_CreateTexture(sdlRenderer,SDL_PIXELFORMAT_XRGB8888,SDL_TEXTUREACCESS_STreaming,1920,1200);
                                   SDL_SetRenderLogicalPresentation(sdlRenderer,1920,1200,SDL_LOGICAL_PRESENTATION_DISABLED);
                                   end
else begin sdlTexture := SDL_CreateTexture(sdlRenderer,SDL_PIXELFORMAT_XRGB8888,SDL_TEXTUREACCESS_STreaming,1792,1120);
                                   SDL_SetRenderLogicalPresentation(sdlRenderer,1792,1120,SDL_LOGICAL_PRESENTATION_STRETCH);
                                   end ;

sdl_hidecursor;             // hide sdl cursor
//sdl_sound_init;
//sdl_pauseaudio(0);
running:=1;                               // tell them the machine is running

repeat

if (p2<>nil) then                           // the screen is prepared
  begin
  raml^[$1801e]:=raml^[$1800B];
  p3:=p2+2304000;                         // second frame buffer
  sdlevents;                              // get events from SDL and update system variables
  vblank1:=0;                             // tell them there is no vblank
  t:=gettime;                             // prepare for screen time measurement
  if peek($70002)=1 then scrconvert(p2,raml^[$18001])  else  scrconvert2(p2,raml^[$18001]);        // convert the screen
  tim:=gettime-t;                         // get screen time for debug
  raml^[$18000]+=1;                       // increment frame counter
  vblank1:=1;                             // we are in vblank now
  sprite(p2);               // draw sprites
  vblank;                   // callback

  if (needrestart>0) then
    begin
    if peek($70002)=0 then begin
      if needrestart=2 then sdl_setwindowfullscreen(scr,false);
      SDL_SetRenderLogicalPresentation(sdlRenderer,1792,1120,  SDL_LOGICAL_PRESENTATION_STRETCH);
      end
    else
      begin
      if needrestart=2 then sdl_setwindowfullscreen(scr,true);
      SDL_SetRenderLogicalPresentation(sdlRenderer,1792,1120,  SDL_LOGICAL_PRESENTATION_DISABLED);
      end ;
    needrestart:=0;
    end;

  if peek($70002)=1 then SDL_UpdateTexture(sdlTexture, nil, p2, 1920 * 4)   // render the screen
  else SDL_UpdateTexture(sdlTexture,nil, p2, 1792 * 4) ;
  SDL_RenderClear(sdlRenderer);
  SDL_RenderTexture(sdlRenderer, sdlTexture,nil,nil);
  SDL_SetRenderVSync(sdlRenderer,1);
  SDL_RenderPresent(sdlRenderer);
  poke ($70000,1);                        // screen rendered, resizing possible

  raml^[$1801e]:=raml^[$1800B];
  sdlevents;                              // process the second buffer
  vblank1:=0;
  t:=gettime;
  if peek($70002)=1 then scrconvert(p3,raml^[$18001]) else  scrconvert2(p3,raml^[$18001]);
  tim:=gettime-t;
  raml^[$18000]+=1;
  vblank1:=1;

  sprite(p3);
    if (needrestart=1) then
    begin
    needrestart:=0;
    if peek($70002)=0 then begin
      SDL_SetRenderLogicalPresentation(sdlRenderer,1792,1120,  SDL_LOGICAL_PRESENTATION_STRETCH);
      end
    else
    begin
      SDL_SetRenderLogicalPresentation(sdlRenderer,1792,1120,  SDL_LOGICAL_PRESENTATION_DISABLED);
      end ;
    end;
  vblank;
  repeat until peek($70000)<2;
  poke ($70000,0);
  if peek($70002)=1  then SDL_UpdateTexture(sdlTexture, nil, p3, 1920 * 4)
  else  SDL_UpdateTexture(sdlTexture, nil, p3, 1792 * 4);
  SDL_RenderClear(sdlRenderer);
  d:=  SDL_Rendertexture(sdlRenderer, sdlTexture,nil,nil);
  SDL_SetRenderVSync(sdlRenderer,1);
  SDL_RenderPresent(sdlRenderer);
  poke($70000,1) ;

  end;
until terminated;
running:=0;
sdl_pauseaudiodevice(0);
SDL_DestroyTexture( sdlTexture );
SDL_DestroyRenderer( sdlRenderer );
SDL_DestroyWindow ( scr);
sdl_quit;
end;

// ---- Retromachine procedures ------------------------------------------------

// ----------------------------------------------------------------------
// initmachine: start the machine
// constructor procedure: allocate ram, load data from files
// prepare all hardware things
// ----------------------------------------------------------------------

procedure initmachine(mode:integer);

var a,i:integer;
    bb:byte;

begin

r1:=virtualalloc(nil,268435456, MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE);  // get 256 MB ram
p2:=virtualalloc(nil,20971520, MEM_COMMIT or MEM_RESERVE,PAGE_READWRITE);  // get the RAM for the framebuffer

fh2:=fileopen('./st4font.def',$40);              // load 8x16 font
fileread(fh2,ramb^[$50000],2048);
fileclose(fh2);
for i:=0 to 2047 do poke($50000+2048+i,peek($50000+i) xor $FF);

fh2:=fileopen('./combinedwaveforms.bin',$40);   // load combined waveforms for SID
fileread(fh2,combined,1024);
fileclose(fh2);

fh2:=fileopen('./mysz.def',$40);                // load mouse cursor definition at sprite 8
for i:=0 to 1023 do
  begin
  fileread(fh2,bb,1);
  a:=bb;
  a:=a+(a shl 8) + (a shl 16);
  raml^[$16400+i]:=a;
  end;
fileclose(fh2);

for i:=0 to 31  do   begin
raml^[$14800+32*i]:=$8080ff;
raml^[$14800+32*i+1]:=$8080ff;
raml^[$14800+32*i+2]:=$8080ff;
raml^[$14c00+32*i]:=$ff8080;
raml^[$14c00+32*i+1]:=$ff8080;
raml^[$14c00+32*i+2]:=$ff8080;
end;

lpoke($60040,$004a002d);
lpoke($60044,$000a0001);
lpoke($60048,$01a8002d);
lpoke($6004c,$000a0001);


fh2:=fileopen('./bmphead',$40);                // load mouse cursor definition at sprite 8
for i:=0 to 53 do
  begin
  fileread(fh2,bb,1);
  poke($80000+i,bb);
  end;
fileclose(fh2);

fh2:=fileopen('./krzyzyk',$40);                // load mouse cursor definition at sprite 8
for i:=0 to 255 do
  begin
  fileread(fh2,a,4);
  lpoke($84000+4*i,a);
  end;
fileclose(fh2);

fh2:=fileopen('./mini',$40);                // load mouse cursor definition at sprite 8
for i:=0 to 255 do
  begin
  fileread(fh2,a,4);
  lpoke($85000+4*i,a);
  end;
fileclose(fh2);

fh2:=fileopen('./maxi',$40);                // load mouse cursor definition at sprite 8
for i:=0 to 255 do
  begin
  fileread(fh2,a,4);
  lpoke($86000+4*i,a);
  end;
fileclose(fh2);

for i:=3 to 7 do
  begin
  raml^[$18010+2*i]:=$01001100;
  raml^[$18010+2*i]:=$00010001;
  end; // init sprites

poke($70002,mode);
thread:=tretro.create(true);   // start frame refreshing thread
thread.start;
end;


//  ---------------------------------------------------------------------
//   procedure stopmachine
//   destructor for the retromachine
//   stop the process, free the RAM
//   rev. 2015.10.14
//  ---------------------------------------------------------------------

procedure stopmachine;

begin
thread.terminate;
repeat until running=0;

// free retromachine memory

virtualfree(p2,0,mem_release);
virtualfree(r1,0,mem_release);

end;

//  ---------------------------------------------------------------------
//   BASIC type poke/peek procedures
//   works @ byte addresses
//   rev. 2015.11.01
// ----------------------------------------------------------------------

procedure poke(addr:integer;b:byte);

begin
ramb^[addr]:=b;
end;

procedure dpoke(addr:integer;w:word);

begin
ramw^[addr shr 1]:=w;
end;


procedure lpoke(addr:integer;c:cardinal);

begin
raml^[addr shr 2]:=c;
end;

procedure slpoke(addr,i:integer);

begin
raml^[addr shr 2]:=i;
end;

function peek(addr:integer):byte;

begin
peek:=ramb^[addr];
end;

function dpeek(addr:integer):word;

begin
dpeek:=ramb^[addr]+256*ramb^[addr+1];
end;

function lpeek(addr:integer):cardinal;

begin
lpeek:=raml^[addr shr 2];
end;

function slpeek(addr:integer):integer;

begin
slpeek:=raml^[addr shr 2];
end;

procedure wvbl;

begin
repeat application.processmessages until vblank1=1;
end;

//  ---------------------------------------------------------------------
//   function gettime:int64
//   the function returns the system time in microseconds
//   rev. 2015.11.27
//  ---------------------------------------------------------------------

function gettime:int64;

var pf,tm:int64;

begin
QueryPerformanceFrequency(pf);
QueryPerformanceCounter(tm);
gettime:=round(1000000*tm/pf);
end;

//  ---------------------------------------------------------------------
//   procedure sdlevents
//   Get events from sdl and put them into system vars
//   STUB! rev. 2015.10.18
//   TODO: this should be run in another thread ?
//  ---------------------------------------------------------------------


procedure sdlevents;

label p101;

var qq:integer;
    qqb:boolean absolute qq;
    aevent:tsdl_event;
    key:cardinal;

const x:integer=0;
      y:integer=0;

begin
qqb:=sdl_pollevent(@aevent);
if not qqb then goto p101;
if aevent.window._type=SDL_EVENT_WINDOW_MOUSE_ENTER then needrestart:=1;
if aevent.window._type=SDL_EVENT_WINDOW_CLOSE_REQUESTED then needclose:=1;
if (aevent._type=SDL_EVENT_MOUSE_MOTION)  then
  begin
  x:=round(aevent.motion.x);
  y:=round(aevent.motion.y);
  if (peek($70002)=1) and (x<64) then x:=64;
  if (peek($70002)=1) and (x>1855) then x:=1855;
  if (peek($70002)=1) and (y<40) then y:=40;
  if (peek($70002)=1) and (y>1159) then y:=1159;
  ramw^[$30016]:=x;
  ramw^[$30017]:=y;
  end
else if (aevent._type=SDL_EVENT_MOUSE_BUTTON_DOWN)  then
  begin
  if aevent.button.down=true then
    begin
    ramb^[$60033]:=aevent.button.clicks;
    ramb^[$60030]:=aevent.button.button;
    ramb^[$60032]:=ramb^[$60032] or (1 shl aevent.button.button);
    end;
  end
else if (aevent._type=SDL_EVENT_MOUSE_BUTTON_UP)  then
  begin
  if aevent.button.down=false then
    begin
//      ramb^[$60033]:=aevent.button.clicks;
//      ramb^[$60030]:=aevent.button.button;
    ramb^[$60032]:=ramb^[$60032] and not (1 shl aevent.button.button);
    end;
  end
else if (aevent._type=SDL_EVENT_MOUSE_WHEEL)  then
  begin
    begin
    ramb^[$60033]:=2;
    ramb^[$60031]:=round(aevent.wheel.y);
    end;
  end
else if (aevent._type=SDL_EVENT_KEY_DOWN) then
  begin
  ramb^[$6002B]:=1;
  key:=aevent.key.key;
  key:=(key shr 24) shl 8 + (key and $FF);
  dpoke($60028,key);
  end;
p101:
end;

//  ---------------------------------------------------------------------
//   procedure blit(from,x,y,too,x2,y2,lines,length,bpl1,bpl2:integer)
//   copy a rectangle from screen "from" to screen "too"
//   bpl1,bpl1 - bit per line at screen1 and screen 2
//   STUB!  rev. 2015.10.18
//  -------------------------------------------------------------------


procedure blit(from,x,y,too,x2,y2,length,lines,bpl1,bpl2:integer);

// --- TODO - write in asm, add advanced blitting modes

var i,j:integer;
    b1,b2:integer;

begin
if raml^[$18002]<16 then
  begin
  from:=from+x;
  too:=too+x2;
  for i:=0 to lines-1 do
    begin
    b2:=too+bpl2*(i+y2);
    b1:=from+bpl1*(i+y);
    for j:=0 to length-1 do
      ramb^[b2+j]:=ramb^[b1+j];
    end;
  end
else if (raml^[$18002]>=16) and (raml^[$18002]<32) then
  begin
  from:=(from shr 1)+x;
  too:=(too shr 1)+x2;
  for i:=0 to lines-1 do
    begin
    b2:=too+bpl2*(i+y2);
    b1:=from+bpl1*(i+y);
    for j:=0 to length-1 do
      ramw^[b2+j]:=ramw^[b1+j];
    end;
  end
else
  begin
  from:=(from shr 2)+x;
  too:=(too shr 2)+x2;
  for i:=0 to lines-1 do
    begin
    b2:=too+bpl2*(i+y2);
    b1:=from+bpl1*(i+y);
    for j:=0 to length-1 do
      raml^[b2+j]:=raml^[b1+j];
    end;
  end;
end;

procedure graphics(mode:integer);

begin
raml^[$18001]:=$F000000;
case mode of

   16: begin

       raml^[$18002]:=16;
       raml^[$18008]:=1792;
       raml^[$18009]:=1120;
       end;


   else begin

        raml^[$18002]:=16;
        raml^[$18008]:=1792;
        raml^[$18009]:=1120;
        end;
    end;
raml^[$18001]:=$F000000;
setataripallette(0);

cls(0);
end;


procedure scrconvert(screen:pointer;buf:integer);  //convert retro fb to raspberry fb @ graphics mode 16
                                                      //1792x1120x64k

var
  b:integer;
  pi:^integer;
  i,j,k,l:integer;


begin
buf:=buf shr 1;
pi:=screen;
b:=raml^[$18003];
l:=0;
for i:=0 to 39 do begin if peek($70001)=0 then b:=lpeek($10000+4*((i div 4)+lpeek($60000)  ) mod 1024); for j:=0 to 1919  do (pi+i*1920+j)^:=b; end;
k:=76800;
for i:=40 to 1159 do
  begin
  for j:=0 to 63 do begin if peek($70001)=0 then b:=lpeek($10000+4*((i div 4)+lpeek($60000) ) mod 1024); (pi+k)^:=b; k+=1; end;
  for j:=0 to 1791 do begin
  (pi+k)^:=raml^[$4000+ramw^[buf+l]]; k+=1; l+=1; end;
  for j:=0 to 63 do begin (pi+k)^:=b; k+=1; end;
  end;
for i:=1160 to 1199 do begin if peek($70001)=0 then b:=lpeek($10000+4*((i div 4)+lpeek($60000) ) mod 1024); for j:=0 to 1919  do (pi+i*1920+j)^:=b; end;
end;

procedure scrconvert2(screen:pointer;buf:integer);

//1792x1120x64k   without border


var pi:^integer;
    i,j,k,l:integer;


begin
buf:=buf shr 1;
pi:=screen;
l:=0;
k:=0;
for i:=0 to 1119 do
  for j:=0 to 1791 do begin (pi+k)^:=raml^[$4000+ramw^[buf+l]]; k+=1; l+=1; end;
end;




//  ---------------------------------------------------------------------
//           draw sprites on screen
//           called from retromachine emulation thread
//           rev. 2015.10.13
//  ---------------------------------------------------------------------

procedure sprite(screen:pointer);

  label p100;

var  s,xs,ys,offset,pixel, spritebase, spritedefs,ctrl1:integer;
     screenbase,pi:^integer;
     xpos,ypos,xzoom, yzoom, i,j,k,l,m: integer;
     mask:cardinal;
                                //  sprite control long 0 31..16 y pos  15..0 x pos
                                //  long 1 30..16 y zoom 15..0 x zoom 31 mode
                                // defs @ 52000

begin
if peek($70002)=1 then s:=1920 else s:=1792;
if peek($70002)=1 then xs:=0 else xs:=0;
if peek($70002)=1 then ys:=0 else ys:=0;
pi:=screen;
spritebase:=$60040;
spritedefs:=$52000;
t:=gettime;
for i:=0 to 7 do
  begin
  mask:=1 shl (i+24);
  ctrl1:=lpeek(spritebase);
  spritebase+=4;
  ypos:=(ctrl1 shr 16) - ys;
  xpos:=(ctrl1 and $FFFF) -xs;
  ctrl1:=lpeek(spritebase);
  spritebase+=4;
  yzoom:=(ctrl1 shr 16) and $7FFF ;
  if yzoom>10 then yzoom:=10;
  if yzoom<1 then yzoom:=1;
  xzoom:=ctrl1 and $7FFF ;
  if xzoom>10 then xzoom:=10;
  if xzoom<1 then xzoom:=1;
  if (xpos>2048) or (ypos>2048) then
    begin
    spritedefs+=4096;
    goto p100;
    end;
  for l:=0 to 31 do
    begin
    for m:=1 to yzoom do
      begin
      offset:=xpos+s*(ypos+yzoom*l+m-1);
      screenbase:=pi+offset;
      for j:=0 to 31 do
        begin
        for k:=1 to xzoom do
          begin
          pixel:=lpeek(spritedefs);
          if ((screenbase^ and mask)=0) and (offset<2304000) and (pixel<>0) then screenbase^:=pixel ;
          screenbase+=1;
          end;
        spritedefs+=4;
        end;
      spritedefs-=128
      end;
    spritedefs+=128;
    end;
  p100:
  end;
ts:=gettime-t;

end;


procedure setataripallette(bank:integer);

var fh,i:integer;


begin
fh:=fileopen('./ataripalette.def',$40);
fileread(fh,raml^[$4000+256*bank],1024);
fileclose(fh);
for i:=0 to 255 do raml^[$4000+256*bank+i] :=  raml^[$4000+256*bank+i]
end;

procedure sethidecolor(c,bank,mask:integer);

begin
raml^[$4000+256*bank+c]+=(mask shl 24);
end;

procedure cls(c:integer);

var c2, i,l:integer;

begin
c:=c mod 65535;

l:=(raml^[$18008]*raml^[$18009]) div 2 ;
c:=c+(c shl 16);
for i:=0 to l do raml^[$3C00000+i]:=c;

end;


//  ---------------------------------------------------------------------
//   putpixel (x,y,color)
//   asm procedure - put color pixel on screen at position (x,y)
//   rev. 2015.10.14
//  ---------------------------------------------------------------------


procedure putpixel(x,y,color:integer);

var adr:integer;

begin
if (x>=0) and (y>=0) and (x<1792) and (y<1120) then begin
if raml^[$18002]<16 then
  begin adr:=$F000000+x+1792*y; if adr<$FFFFFFF then ramb^[adr]:=color; end
else if (raml^[$18002]>=16) and (raml^[$18002]<32) then
  begin adr:=$7800000+x+1792*y; if adr<$7FFFFFF then ramw^[adr]:=color; end
else
  begin adr:=$3c00000+x+1792*y; if adr<$3FFFFFF then raml^[adr]:=color; end;
  end;
end;

function getpixel(x,y:integer):integer;

var adr:integer;

begin
getpixel:=0;
if (x>=0) and (y>=0) and (x<1792) and (y<1120) then begin
if raml^[$18002]<16 then
  begin adr:=$F000000+x+1792*y; if adr<$FFFFFFF then getpixel:=ramb^[adr]; end
else if (raml^[$18002]>=16) and (raml^[$18002]<32) then
  begin adr:=$7800000+x+1792*y; if adr<$7FFFFFF then getpixel:=ramw^[adr]; end
else
  begin adr:=$3c00000+x+1792*y; if adr<$3FFFFFF then getpixel:=raml^[adr]; end;
  end;
end;

procedure line(x,y,l,h,c:integer);

var dx,dy,xa,ya:double;
i:integer;

begin
if (l=0) and (h=0) then exit
else if (l<0) and (h<0) then
  begin
  l:=-l;
  h:=-h;
  x:=x-h+1;
  y:=y-h+1;
  end
else if ((l<0) and (h>0)) or ((l>0) and (h<0)) then
  begin
  if abs(h)>abs(l) then // normalize for dy=1;
    begin
    if h<0 then begin y:=y+h; x:=x+l; h:=-h; l:=-l; end;
    end

  else // normalize for dx=1
    begin
    if l<0 then begin x:=x+l; y:=y+h; h:=-h; l:=-l; end;
    end;
  end;
if abs(l)<abs(h) then
  begin
  dx:=l/h;
  xa:=x;
  for i:=y to y+h-1 do
    begin
    putpixel(round(xa),i,c);
    xa+=dx;
    end;
  end
else
  begin
  dy:=h/l;
  ya:=y;
  for i:=x to x+l-1 do
    begin
    putpixel(i,round(ya),c);
    ya+=dy;
    end;
  end;
end;


procedure line2(x1,y1,x2,y2,c:integer);

var l,h:integer;

begin
l:=x2-x1;
h:=y2-y1;
line(x1,y1,l,h,c)
end;

procedure wait(us:int64);

var t:int64;

begin
t:=gettime;
repeat application.processmessages until gettime-t>us;
end;

//  ---------------------------------------------------------------------
//   box(x,y,l,h,color)
//   asm procedure - draw a filled rectangle, upper left at position (x,y)
//   length l, height h
//   rev. 2015.10.14
//  ---------------------------------------------------------------------

procedure box(x,y,l,h,c:integer);

 var adr,a,i,j:integer;

label p999,p101,p102,p111,p112,p121,p122,p131,p132;
label a60008;


begin
//repeat until vblank1=0;
if x<0 then begin l:=l+x; x:=0; end;
if x>1792 then x:=1792;
if y<0 then begin h:=h+y; y:=0; end;
if y>1120 then y:=1120;
if x+l>1792 then l:=1792-x-1;
if y+h>1120 then h:=1120-y-1 ;
if raml^[$18002]<16 then
  begin
  for j:=y to y+h-1 do
    begin
    adr:=$F000000+1792*j;
    for i:=x to x+l-1 do ramb^[adr+i]:=c;
    end;
  end
else if (raml^[$18002]>=16) and (raml^[$18002]<32) then
  begin
  for j:=y to y+h-1 do
    begin
    adr:=$7800000+1792*j;
    for i:=x to x+l-1 do ramw^[adr+i]:=c;
    end;
  end
else
  begin
  for j:=y to y+h-1 do
    begin
    adr:=$3c00000+1792*j;
    for i:=x to x+l-1 do raml^[adr+i]:=c;
    end;
  end
end;

//  ---------------------------------------------------------------------
//   box2(x1,y1,x2,y2,color)
//   Draw a filled rectangle, upper left at position (x1,y1)
//   lower right at position (x2,y2)
//   wrapper for box procedure
//   rev. 2015.10.17
//  ---------------------------------------------------------------------

procedure box2(x1,y1,x2,y2,color:integer);

begin


if (x1<x2) and (y1<y2) then
   box(x1,y1,x2-x1+1, y2-y1+1,color);

end;


//  ---------------------------------------------------------------------
//   putchar(x,y,ch,color)
//   Draw a 8x16 character at position (x1,y1)
//   STUB, will be replaced by asm procedure
//   rev. 2015.10.14
//  ---------------------------------------------------------------------


procedure putchar(x,y:integer;ch:char;col:integer);

// --- TODO: translate to asm, use system variables

var i,j,start:integer;
  b:byte;

begin
start:=$50000+16*ord(ch);
for i:=0 to 15 do
  begin
  b:=ramb^[start+i];
  for j:=0 to 7 do
    begin
    if (b and (1 shl j))<>0 then
      putpixel(x+j,y+i,col);
    end;
  end;
end;

procedure putcharz(x,y:integer;ch:char;col,xz,yz:integer);

// --- TODO: translate to asm, use system variables

var i,j,k,l,start:integer;
  b:byte;

begin
start:=$50000+16*ord(ch);
for i:=0 to 15 do
  begin
  b:=ramb^[start+i];
  for j:=0 to 7 do
    begin
    if (b and (1 shl j))<>0 then
      for k:=0 to yz-1 do
        for l:=0 to xz-1 do
           putpixel(x+j*xz+l,y+i*yz+k,col);
    end;
  end;
end;

procedure putcharz3(x,y:integer;ch:char;col:integer);

// --- TODO: translate to asm, use system variables

var i,j,k,l,m,n,start:integer;
  b:byte;

begin
start:=$50000+16*ord(ch);
for i:=0 to 23 do
  begin
  m:=(i*2) div 3;
  b:=ramb^[start+m];
  for j:=0 to 11 do
    begin
    n:=(j*2) div 3;
    if (b and (1 shl n))<>0 then
      begin
      putpixel(x+j,y+i,col);
      end;
     end;

  end;
end;

procedure outtextxy(x,y:integer; t:string;c:integer);

var i:integer;

begin
for i:=1 to length(t) do putchar(x+8*i-8,y,t[i],c);
end;

procedure outtextxyz(x,y:integer; t:string;c,xz,yz:integer);

var i:integer;

begin
for i:=0 to length(t)-1 do putcharz(x+8*xz*i,y,t[i+1],c,xz,yz);
end;


procedure outtextxyz3(x,y:integer; t:string;c:integer);

var i:integer;

begin
for i:=0 to length(t)-1 do putcharz3(x+12*i,y,t[i+1],c);
end;

procedure scrollup;

var i:integer;

begin
for i:=0 to 447 do raml^[$3c7a800+i]:=raml^[$3c00000+i];
for i:=0 to 501760 do raml^[$3C00000+i]:=raml^[$3c001c0+i];
end;

procedure button(x,y,l,h,c1,c2:integer;s:string);

var l2:integer;

begin
box(x,y,l,h,c1);
box(x+2,y+2,l-4,h-4,c2);
box(x+4,y+4,l-8,h-8,c1);
l2:=length(s)*8;
outtextxyz(x+(l div 2)-l2,y+(h div 2)-16,s,c2,2,2);
end;

function testmouse(x,y,l,h:integer):boolean;

var mx,my:integer;

begin
mx:=dpeek($6002c)-64;
my:=dpeek($6002e)-40;
if (my>y) and (my<y+h) and (mx>x) and (mx<x+l) then testmouse:=true else testmouse:=false;
end;


// ------------- sdl sound initializaton -------------------------------------

function sdl_sound_init:integer;

begin
end;

procedure AudioCallback(userdata:pointer; audio:Pbyte; length:integer); cdecl;

var audio2:psingle;
    i:integer;

//const j:integer=0;

begin

end;



procedure vblank;

var h,m,s,tt,dx,dy:integer;
  t:double;
hs,ms,ss,ts:string;
// all things which should be done in vblank

begin

// display the current time in the status bar
box2(1712,1100,1791,1119,120);
outtextxy(1712,1100,timetostr(time),233);

tt:=round(playtime) mod 1000;
s:=(round(playtime) div 1000) mod 60;
m:=(round(playtime) div 60000) mod 60;
h:=(round(playtime) div 3600000);
ts:=inttostr(tt);
ss:=inttostr(s);
ms:=inttostr(m);
hs:=inttostr(h);
if tt<100 then ts:='0'+ts;
if tt<10 then ts:='0'+ts;
if m<10 then ms:='0'+ms;
if s<10 then ss:='0'+ss;

box(440,950,440,48,193);
outtextxyz(440,950,hs+':'+ms+':'+ss+':'+ts,28,5,3);
dy:=$00280000*peek($70002);
dx:=$00000040*peek($70002);
lpoke($60040,dx+dy+$004a0000 +(45+round(1700*playtime*192/samplenum)));
lpoke($60048,dx+dy+$01a80000 + (45+round(1700*playtime*192/samplenum)));
end;


end.

