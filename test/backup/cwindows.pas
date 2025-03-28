unit cwindows;

{$mode objfpc}{$H+}

interface

uses  sysutils,classes,retro,math;

type cwindow=class;    // forward declaration

type cbutton=class(TObject)
  x,y,l,h,c1,c2,clicked:integer;
  s:string;
  fsx,fsy:integer;
  value:integer;
  background:pointer;
  visible,highlighted,selected,radiobutton:boolean;
  next,last:cbutton;
  granny:cwindow;
  constructor create(ax,ay,al,ah,ac1,ac2:integer;aname:string;g:cwindow);
  destructor destroy; override;
  function checkmouse:boolean;
  procedure highlight;
  procedure unhighlight;
  procedure show;
  procedure hide;
  procedure select;
  procedure unselect;
  procedure draw;
  function append(ax,ay,al,ah,ac1,ac2:integer;aname:string):cbutton;
  procedure setparent(parent:cbutton);
  procedure setdesc(desc:cbutton);
  function gofirst:cbutton;
  function findselected:cbutton;
  procedure setvalue(v:integer);
  procedure checkall;

  end;

type cwindow=class(tobject)

  x,y,l,h:integer;
  lw,hw:integer;
  c1,c2:integer;
  wmx,wmy:integer;
  background,foreground:pointer;
  visible:boolean;
  title:string;
  buttons:cbutton;
  needredraw:boolean;
  needdestroy:boolean;
  cm:boolean;
  selected:boolean;
  movable:boolean;
  constructor create(ax,ay,al,ah,alw,ahw,ac1,ac2:integer; atitle:string);
  destructor destroy; override;
  procedure drawdecoration; virtual;
  procedure move(ax,ay:integer);
  procedure show; virtual;
  procedure hide;
  function checkmouse:boolean; virtual;
  procedure redrawclient; virtual;
  procedure cls;


  procedure putpixel(ax,ay,c:integer);
  procedure putpixel2(ax,ay,c:integer);
  procedure line(ax,ay,al,ah,c:integer);
  procedure line2(x1,y1,x2,y2,c:integer);

  procedure putchar(ax,ay:integer;ch:char;col:integer);
  procedure putchar2(ax,ay:integer;ch:char;col:integer);
  procedure outtextxy(ax,ay:integer; t:string;c:integer);
  procedure winblit(x1,y1,x2,y2,length,lines:integer);
  procedure box(ax,ay,al,ah,ac:integer);
  procedure box3(ax,ay,al,ah,ac:integer);
  procedure box2(ax1,ay1,ax2,ay2,color:integer);
  procedure putcharz(ax,ay:integer;ch:char;col,xz,yz:integer);
  procedure putcharz2(ax,ay:integer;ch:char;col,xz,yz:integer);
  procedure outtextxyz(ax,ay:integer; t:string;c,xz,yz:integer);
  procedure scrollup(amount:integer);
//   function getpixel(x,y:integer):integer;
//   procedure putcharz3(x,y:integer;ch:char;col:integer);
//   procedure outtextxyz3(x,y:integer; t:string;c:integer);
  end;


type cmodalwindow=class(cwindow)
   constructor create(ax,ay,al,ah,alw,ahw,ac1,ac2:integer; atitle:string);
   procedure show; override;
   procedure drawdecoration; override;
   procedure redrawclient; override;
   function checkmouse:boolean; override;
   end;



type filedesc=array[0..1000,0..1] of string;

type cfselector=class(cwindow)
  done:boolean;
  currentdir:string;
  currentdir2:string;
  filename:string;
  sr:TSearchRec;
  sel,selstart,ilf,ild:integer;
  filenames:filedesc;
  constructor create(ax,ay,al,ah,alw,ahw,ac1,ac2:integer;atitle,adir,afn:string);
  function checkmouse:boolean;

  end;


var
  test:integer ;
  iii, i,j,k,l,fh2,lines:integer;

  event:tsdl_event;
  licznik:integer=0;
  songname:string;
  q1,q2,q3:extended;
  thread:TRetro;
//  songtime:int64=0;
  sprx,sprxd,spryd,spry:integer;
  spr2x,spr2xd,spr2yd,spr2y:integer;
  spr3x,spr3xd,spr3yd,spr3y:integer;
  spr4x,spr4xd,spr4yd,spr4y:integer;
  spr5x,spr5xd,spr5yd,spr5y:integer;
  spr6x,spr6xd,spr6yd,spr6y:integer;
  spr7x,spr7xd,spr7yd,spr7y:integer;
  spr8x,spr8xd,spr8yd,spr8y:integer;

   c:int64=0;
   avsct:int64=0;
   avspt:int64=0;
   avall:int64=0;
   avsid:int64=0;
   ttttt,ttt:int64;
    qq:integer;
 //   songfreq:integer;
    pause:boolean=false;
    framecount:integer;
    testwindow:cwindow;
    testbutton:TObject;

     open:cbutton;

//    buttons:array[0..100] of cbutton;
    sls,stb,plb,over,scolor,start,range,sbutton:cbutton;
    temp:cbutton;
    wbutton,wstart,wsamples:cbutton;
    wbutton10:cbutton;
    fs:cfselector=nil;
    widespec,haaar, psk,gm,anal,synt:cbutton;




procedure uklad(start,zakres:integer);
procedure uplot(start,zakres,x:integer; data,data2:double;c:integer);
procedure u2(start,zakres:integer);
procedure uklad2;
procedure uklad3;


implementation

uses windows;

constructor cmodalwindow.create(ax,ay,al,ah,alw,ahw,ac1,ac2:integer; atitle:string);

begin

if alw<al then alw:=al;
if ahw<ah then ahw:=ah;
x:=ax; y:=ay; l:=al; h:=ah; c1:=ac1; c2:=ac2; lw:=alw; hw:=ahw; title:=atitle;
wmx:=-1; wmy:=-1;
buttons:=nil;
background:=getmem(4*alw*ahw);
foreground:=getmem(4*alw*ahw);
visible:=false;
needredraw:=false;
needdestroy:=false;
movable:=false;
//selected:=true;
cm:=false;
show;
cls;
redrawclient;
end;


procedure cmodalwindow.show;

var i,j,k:integer;
    p:^integer;

begin
if not visible then begin
  p:=background;
  k:=0;
  for i:=y to y+h-1 do
  for j:=x to x+l-1 do
    begin
    (p+k)^:=retro.getpixel(j,i);
    k+=1;
    end;
  drawdecoration;
  redrawclient;
  visible:=true;
  end;
end;

procedure cmodalwindow.drawdecoration;



var c3,c4,c5,c6,l2:integer;

begin
c3:=c2+13;
c4:=c2+10;
c5:=c2+8;
c6:=c2+6;


retro.box(x,y,l,24,c4);
retro.box(x,y,4,h,c4);
retro.box(x+l-4,y,4,h,c4);
retro.box(x,y+h-4,l,4,c4);


l2:=length(title)*4;
retro.outtextxy(x+(l div 2)-l2-27,y+4,title,c2);
end;

procedure cmodalwindow.redrawclient;

var i,j:integer;
    p:^integer;

begin
p:=foreground;
for i:=0 to h-29 do
  for j:=0 to l-9 do
    retro.putpixel(x+4+j,y+24+i,(p+j+i*lw)^);
end;

constructor cwindow.create(ax,ay,al,ah,alw,ahw,ac1,ac2:integer; atitle:string);

begin
inherited create;
if alw<al then alw:=al;
if ahw<ah then ahw:=ah;
x:=ax; y:=ay; l:=al; h:=ah; c1:=ac1; c2:=ac2; lw:=alw; hw:=ahw; title:=atitle;
wmx:=-1; wmy:=-1;
buttons:=nil;
background:=getmem(4*alw*ahw);
foreground:=getmem(4*alw*ahw);
visible:=false;
needredraw:=false;
needdestroy:=false;
movable:=true;
cm:=false;
show;
cls;
redrawclient;
end;

destructor cwindow.destroy;

begin
if self<>nil then
  begin
  if visible then hide;
  freemem(foreground);
  freemem(background);
  inherited destroy;
  end;
end;


procedure cwindow.show;

var i,j,k:integer;
    p:^integer;

begin
if not visible then begin
  p:=background;
  k:=0;
  for i:=y to y+h-1 do
  for j:=x to x+l-1 do
    begin
    (p+k)^:=retro.getpixel(j,i);
    k+=1;
    end;
  drawdecoration;
  redrawclient;
  visible:=true;
  end;
end;

procedure cwindow.hide;

var i,j,k:integer;
    p:^integer;

begin
if visible then begin
  p:=background;
  k:=0;
  for i:=y to y+h-1 do
  for j:=x to x+l-1 do
    begin
    retro.putpixel(j,i,(p+k)^);
    k+=1;
    end;
  visible:=false;
  end;
end;

procedure cwindow.move(ax,ay:integer);


begin
repeat until vblank1=1;
hide;
x:=ax;
y:=ay;
show;
repeat until vblank1=0;
end;

procedure cwindow.drawdecoration;

var c3,c4,c5,c6,l2:integer;

begin
c3:=c2+13;
c4:=c2+10;
c5:=c2+8;
c6:=c2+6;


retro.box(x,y,l,24,c4);
retro.box(x,y,4,h,c4);
retro.box(x+l-4,y,4,h,c4);
retro.box(x,y+h-4,l,4,c4);
for i:=0 to 15 do for j:=0 to 15 do if lpeek($84000+4*j+64*i)=0 then retro.putpixel(x+l-20+j,y+1+i,256+36) else retro.putpixel(x+l-20+j,y+1+i,256+15);
for i:=0 to 15 do for j:=0 to 15 do if lpeek($85000+4*j+64*i)=0 then retro.putpixel(x+l-38+j,y+1+i,256+0) else retro.putpixel(x+l-38+j,y+1+i,c4);
for i:=0 to 15 do for j:=0 to 15 do if lpeek($86000+4*j+64*i)=0 then retro.putpixel(x+l-54+j,y+1+i,256+0) else retro.putpixel(x+l-54+j,y+1+i,c4);
retro.box(x+l-20,y+24,16,h-44,c5);
retro.box(x+4,y+h-20,l-24,16,c5);
retro.box(x+l-20,y+h-20,16,16,c6);
l2:=length(title)*4;
retro.outtextxy(x+(l div 2)-l2-27,y+4,title,c2);

end;



procedure cwindow.redrawclient;

var i,j:integer;
    p:^integer;

begin
p:=foreground;
for i:=0 to h-45 do
  for j:=0 to l-25 do
    retro.putpixel(x+4+j,y+24+i,(p+j+i*lw)^);
end;


function cwindow.checkmouse:boolean;

label p999;

var i,j,mmx,mmy,mx,my:integer;


begin

mx:=dpeek($6002c)-64*peek($70002);
my:=dpeek($6002e)-40*peek($70002);


if (my>y) and (my<y+16) and (mx>x+l-20) and (mx<x+l-5) then
  begin      {
  for i:=0 to 15 do for j:=0 to 15 do if lpeek($84000+4*j+64*i)=0 then retro.putpixel(x+l-20+j,y+1+i,256+39) else retro.putpixel(x+l-20+j,y+1+i,256+15);    }
  if (peek($60030)=1) then needdestroy:=true;
  end
else
 { for i:=0 to 15 do for j:=0 to 15 do if lpeek($84000+4*j+64*i)=0 then retro.putpixel(x+l-20+j,y+1+i,256+36) else retro.putpixel(x+l-20+j,y+1+i,256+15)};

//if not selected then goto p999;
//lpoke ($6000c,$FFFFFF);

//if (my>y) and (my<y+16) and (mx>x+l-20) and (mx<x+l-5) then begin self.destroy; goto p999;end;
if movable and not cm and ((my>y) and (my<y+h) and (mx>x) and (mx<x+l) and (peek($60030)=1)) then
  begin
  cm:=true;
  wmy:=my-y;
  wmx:=mx-x;
  poke($60030,0);
  end;
if peek($60032)=0 then cm:=false;

if cm then
  begin
  mmx:=mx-wmx;
  mmy:=my-wmy;
  if movable then self.move(mmx,mmy);
  end;

checkmouse:=cm;
p999:
end;


function cmodalwindow.checkmouse:boolean;

label p999;

var i,j,mmx,mmy,mx,my:integer;


begin
mx:=dpeek($6002c)-64*peek($70002);
my:=dpeek($6002e)-40*peek($70002);

if not cm and ((my>y) and (my<y+h) and (mx>x) and (mx<x+l) and (peek($60030)=1)) then
  begin
  cm:=true;
  wmy:=my-y;
  wmx:=mx-x;
  poke($60030,0);
  end;
if peek($60032)=0 then cm:=false;

if cm then
  begin
  mmx:=mx-wmx;
  mmy:=my-wmy;
  if movable then self.move(mmx,mmy);
  end;

checkmouse:=cm;
p999:
end;

procedure cwindow.cls;

var p:^integer;
    i,j:integer;

begin
p:=foreground;
for i:=0 to hw-1 do
  for j:=0 to lw-1 do
    (p+j+i*lw)^:=c1;
//redrawclient;
end;

procedure cwindow.putpixel(ax,ay,c:integer);

var p:^integer;

begin
p:=foreground;
if (ax>=0) and (ax<lw) and (ay>=0) and (ay<hw) then
  begin
  (p+ax+lw*ay)^:=c;
//   redrawclient;
  end;
end;

procedure cwindow.putpixel2(ax,ay,c:integer);

var p:^integer;

begin
p:=foreground;
if (ax>=0) and (ax<lw) and (ay>=0) and (ay<hw) then (p+ax+lw*ay)^:=c;
end;

procedure cwindow.line(ax,ay,al,ah,c:integer);

var dx,dy,xa,ya:double;
i:integer;

begin
if (al=0) and (ah=0) then exit
else if (al<0) and (ah<0) then
  begin
  al:=-al;
  ah:=-ah;
  ax:=ax-ah+1;
  ay:=ay-ah+1;
  end
else if ((al<0) and (ah>0)) or ((al>0) and (ah<0)) then
  begin
  if abs(ah)>abs(al) then // normalize for dy=1;
    begin
    if ah<0 then begin ay:=ay+ah; ax:=ax+al; ah:=-ah; al:=-al; end;
    end
  else // normalize for dx=1
    begin
    if al<0 then begin ax:=ax+al; ay:=ay+ah; ah:=-ah; al:=-al; end;
    end;
  end;
if abs(al)<abs(ah) then
  begin
  dx:=al/ah;
  xa:=ax;
  for i:=ay to ay+ah-1 do
    begin
    putpixel2(round(xa),i,c);
    xa+=dx;
    end;
  end
else
  begin
  dy:=ah/al;
  ya:=ay;
  for i:=ax to ax+al-1 do
    begin
    putpixel2(i,round(ya),c);
    ya+=dy;
    end;
  end;
//redrawclient;
end;

procedure cwindow.line2(x1,y1,x2,y2,c:integer);

var al,ah:integer;

begin
al:=x2-x1;
ah:=y2-y1;
line(x1,y1,al,ah,c)
end;


procedure cwindow.putchar2(ax,ay:integer;ch:char;col:integer);

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
      putpixel2(ax+j,ay+i,col);
    end;
  end;

end;

procedure cwindow.putchar(ax,ay:integer;ch:char;col:integer);

begin
putchar2(ax,ay,ch,col);
//redrawclient;
end;


procedure cwindow.outtextxy(ax,ay:integer; t:string;c:integer);

var i:integer;

begin
for i:=1 to length(t) do putchar2(ax+8*i-8,ay,t[i],c);
//redrawclient;
end;


procedure cwindow.putcharz2(ax,ay:integer;ch:char;col,xz,yz:integer);

// --- TODO: translate to asm, use system variables

var i,j,k,al,start:integer;
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
        for al:=0 to xz-1 do
           putpixel2(ax+j*xz+al,ay+i*yz+k,col);
    end;
  end;
end;

procedure cwindow.putcharz(ax,ay:integer;ch:char;col,xz,yz:integer);

begin
putcharz2(ax,ay,ch,col,xz,yz);
//redrawclient;
end;

procedure cwindow.outtextxyz(ax,ay:integer; t:string;c,xz,yz:integer);

var i:integer;

begin
for i:=0 to length(t)-1 do putcharz(ax+8*xz*i,ay,t[i+1],c,xz,yz);
end;



procedure cwindow.box3(ax,ay,al,ah,ac:integer);

 var a,i,j:integer;
     adr:^integer;


begin
adr:=foreground;
if ax<0 then begin al:=al+ax; ax:=0; end;
if ax>lw then ax:=lw;
if ay<0 then begin ah:=ah+ay; ay:=0; end;
if ay>hw then ay:=hw;
if ax+al>lw then al:=lw-ax-1;
if ay+ah>hw then ah:=hw-ay-1 ;

for j:=ay to ay+ah-1 do
  begin

  for i:=ax to ax+al-1 do (adr+lw*j+i)^:=ac;
  end;

end;

procedure cwindow.box(ax,ay,al,ah,ac:integer);

begin
box3(ax,ay,al,ah,ac);
//redrawclient;
end;

procedure cwindow.box2(ax1,ay1,ax2,ay2,color:integer);

begin


if (ax1<ax2) and (ay1<ay2) then
   box(ax1,ay1,ax2-ax1+1, ay2-ay1+1,color);
end;




procedure cwindow.winblit(x1,y1,x2,y2,length,lines:integer);

var adr1,adr2,i,j:integer;
    p:^integer;

begin
adr1:=x1+lw*y1;
adr2:=x2+lw*y2;
p:=foreground;
if adr1>adr2 then
  for i:=0 to lines-1 do
    for j:=0 to length-1 do
      (p+x2+j+lw*(y2+i))^:=  (p+x1+j+lw*(y1+i))^
else if adr2>adr1 then
  for i:=lines-1 downto 0 do
    for j:=length-1 downto 0 do
      (p+x2+j+lw*(y2+i))^:=  (p+x1+j+lw*(y1+i))^ ;

//redrawclient;
end;


procedure cwindow.scrollup(amount:integer);

begin
winblit(0,amount,0,0,lw,hw-amount);
box(0,hw-amount,lw,amount,c1);
end;



constructor cfselector.create(ax,ay,al,ah,alw,ahw,ac1,ac2:integer;atitle,adir,afn:string);

var oldmode,i,ll,j:integer;
    s:string;
    d:char;

begin
currentdir2:=adir;
done:=false;
cm:=false;
filename:=afn;
sel:=0;
selstart:=0;
if alw<al then alw:=al;
if ahw<ah then ahw:=ah;
x:=ax; y:=ay; l:=al; h:=ah; c1:=ac1; c2:=ac2; lw:=alw; hw:=ahw; title:=atitle;
wmx:=-1; wmy:=-1;
buttons:=nil;
background:=getmem(4*alw*ahw);
foreground:=getmem(4*alw*ahw);
visible:=false;
needredraw:=false;
movable:=true;
show;
cls;


ilf:=0;


try

  // Search all drive letters
  for d := 'A' to 'Z' do
  begin
    s := d + ':\';

    case GetDriveType(PChar(s)) of
  {  DRIVE_REMOVABLE,}
     DRIVE_FIXED,
   {  DRIVE_REMOTE,      }
     DRIVE_CDROM
    { DRIVE_RAMDISK}:      begin
                         filenames[ilf,0]:=s;
                         filenames[ilf,1]:='        [DIR]';
                         ilf+=1;
                       end;
    end;
  end;

except
end;


currentdir:=currentdir2+'*.*';
if findfirst(currentdir,fadirectory,sr)=0 then
  repeat
  if (sr.attr and faDirectory) = faDirectory then
    begin
    filenames[ilf,0]:=sr.name;
    filenames[ilf,1]:='        [DIR]';
    ilf+=1;
    end;
  until (findnext(sr)<>0) or (ilf=1000);
  sysutils.findclose(sr);

currentdir:=currentdir2+'*.wav';

if findfirst(currentdir,faAnyFile,sr)=0 then
  repeat
    filenames[ilf,0]:=sr.name;
    filenames[ilf,1]:=inttostr(sr.size);
    ilf+=1;
  until (findnext(sr)<>0) or (ilf=1000);
sysutils.findclose(sr);

if ilf<26 then ild:=ilf else ild:=26;
box(2,6,480,16,c1);
sel:=0;
box(2,6+16*sel,480,16,256+232);
for i:=0 to ild do
  begin
  s:=filenames[i,0];
  for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
  s:=copy(s,1,45);
  if i>0 then outtextxy(8,6+16*i,s,130) else outtextxy(8,6+16*i,s,130);
  s:=filenames[i,1];
  if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
  if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);
  outtextxy(376,6+16*i,s,130);
  end;
filename:='';
if length(currentdir2)=3 then title:=uppercase(currentdir2) else title:=currentdir2;
drawdecoration;
redrawclient;
end;


function cfselector.checkmouse:boolean;

label p999;

var mmx,mmy,mx,my,i,j,ll:integer;
    s:string;
    d:char;



begin
//lpoke ($6000c,$FFFFFF);

//if not selected then goto p999;
mx:=dpeek($6002c)-64*peek($70002);
my:=dpeek($6002e)-40*peek($70002);

// check if mouse click, then select a new entry
if (my>y) and (my<y+16) and (mx>x+l-20) and (mx<x+l-5) then
  begin
  for i:=0 to 15 do for j:=0 to 15 do if lpeek($84000+4*j+64*i)=0 then retro.putpixel(x+l-20+j,y+1+i,256+39) else retro.putpixel(x+l-20+j,y+1+i,256+15);
  if (peek($60030)=1) then needdestroy:=true;
  end
else
  for i:=0 to 15 do for j:=0 to 15 do if lpeek($84000+4*j+64*i)=0 then retro.putpixel(x+l-20+j,y+1+i,256+36) else retro.putpixel(x+l-20+j,y+1+i,256+15);


if (peek($60030)=1) and (mx>x+2) and (mx<x+482) and (my>y+30) and (my<y+462) then
  begin
  i:=(my-30-y) div 16;
  box(2,6+16*sel,480,16,c1);
  ll:=length(filenames[sel+selstart,0])-4;
  if ll>36 then s:=copy(filenames[sel+selstart,0],1,45) else s:=filenames[sel+selstart,0];
  for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
  outtextxy(8,6+16*sel,s,130);
  s:=filenames[sel+selstart,1];
  if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
  if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);
  outtextxy(376,6+16*sel,s,130);
  sel:=i;
  box(2,6+16*sel,480,16,256+232);
  ll:=length(filenames[sel+selstart,0])-4;
  if ll>36 then s:=copy(filenames[sel+selstart,0],1,45) else s:=filenames[sel+selstart,0];
  for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
  outtextxy(8,6+16*sel,s,130);
  s:=filenames[sel+selstart,1];
  if s<>'        [DIR]' then filename:=currentdir2+filenames[sel+selstart,0];
  if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
  if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);
  outtextxy(376,6+16*sel,s,130);
  if peek($60033)=2 then poke($60028,13); // insert enter when doubleclick
  redrawclient;
  end;

// if directory double clicked, change it

if (peek($60028)=13) and (filenames[sel+selstart,1]='        [DIR]') then
  begin
  poke($60028,0);
  s:=filenames[sel+selstart,0];
  if copy(s,length(s),1)<>'\' then
    begin
    setcurrentdir(currentdir2+s);
    currentdir2:=getcurrentdir+'\';
    if copy(currentdir2,length(currentdir2)-1,2)='\\'then currentdir2:=copy(currentdir2,1,length(currentdir2)-1);
    end
  else
    begin
    setcurrentdir(s);
    currentdir2:=getcurrentdir;
    end;
  ilf:=0;
  if length(currentdir2)=3 then
    try

    // Search all drive letters
    for d := 'A' to 'Z' do
    begin
    s := d + ':\';

    case GetDriveType(PChar(s)) of
  {   DRIVE_REMOVABLE,}
     DRIVE_FIXED,
     DRIVE_CDROM:
     begin
                         filenames[ilf,0]:=s;
                         filenames[ilf,1]:='        [DIR]';
                         ilf+=1;
                       end;
    end;
  end;

except
end;



  selstart:=0; sel:=0;
  currentdir:=currentdir2+'*.*';
  if findfirst(currentdir,fadirectory,sr)=0 then
    repeat
    if (sr.attr and faDirectory) = faDirectory then
      begin
      filenames[ilf,0]:=sr.name;
      filenames[ilf,1]:='        [DIR]';
      ilf+=1;
      end;
    until (findnext(sr)<>0) or (ilf=1000);
  sysutils.findclose(sr);
  currentdir:=currentdir2+'*.wav';
  if findfirst(currentdir,faAnyFile,sr)=0 then
    repeat
    filenames[ilf,0]:=sr.name;
    filenames[ilf,1]:=inttostr(sr.size);
    ilf+=1;
    until (findnext(sr)<>0) or (ilf=1000);
  sysutils.findclose(sr);
  ilf-=1;
  cls;
  if ilf<26 then ild:=ilf else ild:=26;
  box(2,6+16*sel,480,16,256+232);
  for i:=0 to ild do
    begin
    ll:=length(filenames[i])-4;
    s:=filenames[i,0];
    for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
    s:=copy(s,1,45);
    if i>0 then outtextxy(8,6+16*i,s,130) else outtextxy(8,6+16*i,s,130);
    s:=filenames[i,1];
    if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
    if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);
    if i>0 then outtextxy(376,6+16*i,s,130) else outtextxy(376,6+16*i,s,130);
    end;
  filename:='';
  redrawclient;
  if length(currentdir2)=3 then title:=uppercase(currentdir2) else title:=currentdir2;

    drawdecoration;
  end;

if (peek($60028)=13) and (filenames[sel+selstart,1]<>'        [DIR]') then
  begin
  filename:=currentdir2+filenames[sel+selstart,0];
  done:=true;
  end;
// down arrow pressed or wheel down


  if (dpeek($60028)=16465) or (peek($60031)=255) then
    begin
    dpoke($60028,0);
    poke($60031,0);
    if sel<ild then
      begin
      box(2,6+16*sel,480,16,141);
      ll:=length(filenames[sel+selstart,0])-4;
      if ll>36 then s:=copy(filenames[sel+selstart,0],1,45) else s:=filenames[sel+selstart,0];
      for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
      outtextxy(8,6+16*sel,s,130);
      s:=filenames[sel+selstart,1];
      if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
      if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3); ;
      outtextxy(376,6+16*sel,s,130);

      sel+=1;
      box(2,6+16*sel,480,16,256+232);
      ll:=length(filenames[sel+selstart,0])-4;
      if l>36 then s:=copy(filenames[sel+selstart,0],1,45) else s:=filenames[sel+selstart,0];
      for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
      outtextxy(8,6+16*sel,s,130);
      s:=filenames[sel+selstart,1];
              if s<>'        [DIR]' then filename:=currentdir2+filenames[sel+selstart,0];
              if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
              if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);

      outtextxy(376,6+16*sel,s,130);
      end
    else if sel+selstart<ilf{-1} then
      begin
      selstart+=1;
      cls;
      box(2,6+16*sel,480,16,256+232);
      for i:=0 to ild do
        begin
        ll:=length(filenames[i+selstart,0])-4;
        if ll>36 then s:=copy (filenames[i+selstart,0],1,45) else s:= filenames[i+selstart,0]  ;
        for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
        if i<ild then outtextxy(8,6+16*i,s,130) else  outtextxy(8,6+16*i,s,130);
        s:=filenames[i+selstart,1];
        if s<>'        [DIR]' then filename:=currentdir2+filenames[sel+selstart,0];
        if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
        if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);

        if i<ild then outtextxy(376,6+16*i,s,130) else outtextxy(376,6+16*i,s,130);
        end;
      end;
    redrawclient;
    end;

  // up arrow pressed or wheel up

  if (dpeek($60028)=16466) or (peek($60031)=1) then
    begin
    dpoke($60028,0);
    poke($60031,0);
    if sel>0 then
      begin
      box(2,6+16*sel,480,16,141);
      ll:=length(filenames[sel+selstart,0])-4;
      if ll>36 then s:=copy(filenames[sel+selstart,0],1,45) else  s:=filenames[sel+selstart,0];
      for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
      outtextxy(8,6+16*sel,s,130);
      s:=filenames[sel+selstart,1];
      if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
      if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);
      outtextxy(376,6+16*sel,s,130);

      sel-=1;
      box(2,6+16*sel,480,16,256+232);
      ll:=length(filenames[sel+selstart,0])-4;
      if ll>36 then s:=copy(filenames[sel+selstart,0],1,45) else s:=filenames[sel+selstart,0];
      for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
      outtextxy(8,6+16*sel,s,130);
      s:=filenames[sel+selstart,1];
      if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
      if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);


      outtextxy(376,6+16*sel,s,130);


      end
    else if sel+selstart>0 then
      begin
      selstart-=1;
      cls;
      box(2,6+16*sel,480,16,256+32);
      for i:=0 to ild do
        begin
        ll:=length(filenames[i+selstart,0])-4;
        if ll>36 then s:=copy (filenames[i+selstart,0],1,45) else s:= filenames[i+selstart,0]  ;
        for j:=1 to length(s) do if s[j]='_' then s[j]:=' ';
        if i>0 then outtextxy(8,6+16*i,s,130) else  outtextxy(8,6+16*i,s,130);
        s:=filenames[i+selstart,1];
        if s<>'        [DIR]' then filename:=currentdir2+filenames[sel+selstart,0];
        if s<>'        [DIR]' then if length(s)<10 then for j:=10 downto length(s)+1 do s:=' '+s;
        if s<>'        [DIR]' then s:=copy(s,1,1)+' '+copy(s,2,3)+' '+copy(s,5,3)+' '+copy(s,8,3);

        if i>0 then outtextxy(376,6+16*i,s,130) else outtextxy(376,6+16*i,s,130);
        end;
      end;

      redrawclient;

    end;



if not cm and ((my>y) and (my<y+h) and (mx>x) and (mx<x+l) and (peek($60030)=1)) then
  begin
  cm:=true;
  wmy:=my-y;
  wmx:=mx-x;
//  poke($60030,0);
  end;
if peek($60032)=0 then cm:=false;

if cm then
  begin
//  poke($60030,0);
  mmx:=mx-wmx;
  mmy:=my-wmy;
  {if (mmx<>x) and (mmy<>y)then }self.move(mmx,mmy);
  end;

checkmouse:=cm;

p999:
//poke($60030,0);
//lpoke($6000c,0);
end;









constructor cbutton.create(ax,ay,al,ah,ac1,ac2:integer;aname:string;g:cwindow);

begin
inherited create;
x:=ax; y:=ay; l:=al; h:=ah; c1:=ac1; c2:=ac2; s:=aname;
background:=getmem(4*al*ah);
granny:=g;
visible:=false; highlighted:=false; selected:=false; radiobutton:=false;
next:=nil; last:=nil;
fsx:=1; fsy:=1;
self.show;
end;


destructor cbutton.destroy;

begin
if visible then hide;
freemem(background);
if (last=nil) and (next<>nil) then next.setparent(nil)
else if next<>nil then next.setparent(last);
if (next=nil) and (last<>nil) then last.setdesc(nil)
else if last<>nil then last.setdesc(next);
inherited destroy;
end;


procedure cbutton.setvalue(v:integer);

begin
value:=v;
end;

function cbutton.findselected:cbutton;

var temp:cbutton;

begin
temp:=self.gofirst;
while not (temp=nil) do
  begin
  if temp.selected then break else temp:=temp.next;

  end;
result:=temp;
end;

function cbutton.checkmouse:boolean;

var mx,my:integer;

begin
mx:=dpeek($6002c)-64*peek($70002);
my:=dpeek($6002e)-40*peek($70002);
if (my>y) and (my<y+h) and (mx>x) and (mx<x+l) then checkmouse:=true else checkmouse:=false;
end;


procedure cbutton.highlight;

var c:integer;

begin
if visible and not highlighted then begin
  c1+=2;
  draw;
  highlighted:=true;
  end;
end;

procedure cbutton.unhighlight;

begin

if visible and highlighted then begin
  c1-=2;
  draw;
  highlighted:=false;
  end;
end;

procedure cbutton.draw;

var l2,a:integer;

begin
if selected then a:=-2 else a:=2;
box(x,y,l,h,c1+a);
box(x,y+3,l-3,h-3,c1-a);
putpixel(x,y+1,c1-a); putpixel(x,y+2,c1-a); putpixel(x+1,y+2,c1-a);
putpixel(x+l-3,y+h-2,c1-a); putpixel(x+l-3,y+h-1,c1-a); putpixel(x+l-2,y+h-1,c1-a);
box(x+3,y+3,l-6,h-6,c1);
l2:=length(s)*4*fsx;
outtextxyz(x+(l div 2)-l2,y+(h div 2)-8*fsy,s,c2,fsx,fsy);
end;


procedure cbutton.show;

var i,j,k:integer;
    p:^integer;

begin
if not visible then begin
p:=background;
k:=0;
for i:=y to y+h-1 do
  for j:=x to x+l-1 do
    begin
    (p+k)^:=retro.getpixel(j,i);
    k+=1;
    end;
draw;
visible:=true;
end;
end;

procedure cbutton.hide;

var i,j,k:integer;
    p:^integer;

begin
if visible then begin
  p:=background;
  k:=0;
  for i:=y to y+h-1 do
    for j:=x to x+l-1 do
      begin
      putpixel(j,i,(p+k)^);
      k+=1;
      end;
  visible:=false;
  end;
end;


procedure cbutton.select;

var c:integer;
    temp:cbutton;

begin
if visible and not selected then begin
  selected:=true;
  draw;
  temp:=self;
  while temp.last<>nil do
    begin
    temp:=temp.last;
    temp.unselect;
    end;
  temp:=self;
  while temp.next<>nil do
    begin
    temp:=temp.next;
    temp.unselect;
    end;
   end;
end;

procedure cbutton.unselect;

begin

if visible and  selected then begin
  selected:=false;
  draw;
  end;
end;

function cbutton.append(ax,ay,al,ah,ac1,ac2:integer;aname:string):cbutton;

begin
next:=cbutton.create(ax,ay,al,ah,ac1,ac2,aname,self.granny);
next.setparent(self);
result:=next;
end;

procedure cbutton.setparent(parent:cbutton);

begin
last:=parent;
end;

procedure cbutton.setdesc(desc:cbutton);

begin
next:=desc;
end;

function cbutton.gofirst:cbutton;

begin
result:=self;
while result.last<>nil do result:=result.last;
end;

procedure cbutton.checkall;

begin
temp:=self.gofirst;
while temp<>nil do
  begin
  if temp.checkmouse then temp.highlight else temp.unhighlight;
  if temp.checkmouse and (peek($60030)=1) then begin
      if (temp.selected) and not temp.radiobutton then temp.unselect else temp.select;
      temp.clicked:=1;
      poke($60030,0);
      end;
  temp:=temp.next;
  end;
end;






procedure u2(start,zakres:integer);
var t:int64;
    j,i,dbd,dzialki:integer;
    dbpx:double;
    s:string;


begin
start:=6*(start div 6)-6;
if zakres<=24 then begin zakres:=24; dzialki:=8; dbd:=3; dbpx:=0.025; end
else if zakres<=30 then begin zakres:=30; dzialki:=10; dbd:=3; dbpx:=0.03125; end
else if zakres<=36 then begin zakres:=36; dzialki:=12; dbd:=3; dbpx:=0.0375; end
else if zakres<=48 then begin zakres:=48; dzialki:=8; dbd:=6; dbpx:=0.05; end
else if zakres<=60 then begin zakres:=60; dzialki:=10; dbd:=6; dbpx:=0.0625; end
else if zakres<=72 then begin zakres:=72; dzialki:=12; dbd:=6; dbpx:=0.075; end
else if zakres<=96 then begin zakres:=96; dzialki:=8; dbd:=12; dbpx:=0.1; end
else if zakres<=120 then begin zakres:=120; dzialki:=10; dbd:=12; dbpx:=0.125; end
else begin zakres:=144; dzialki:=12; dbd:=12; dbpx:=0.15; end;

//154
box(0,0,190,1119,15);
box(0,994,1792,125,15);
box(0,0,1792,31,15);


for i:=0 to dzialki do
  begin
  s:=inttostr(start+zakres-dbd*i);
  outtextxyz(176-16*length(s),16+i*(960 div dzialki),s,0,2,2);
  end;
outtextxyz(64,64,'dB',0,3,3);
outtextxyz(184,1008,'20',0,2,2);
outtextxyz(512+176,1008,'200',0,2,2);
outtextxyz(1024+184,1008,'2k',0,2,2);
outtextxyz(1536+176,1008,'20k',0,2,2);
outtextxyz(1280+176,1008,'Hz',0,3,3);


//t:=gettime;
//repeat until gettime-t>500000;
//blit($Fc00000,0,0,$F000000,0,0,1792,1120,1792,1792);
end;

procedure uklad(start,zakres:integer);

var t:int64;
    j,i,dbd,dzialki:integer;
    dbpx:double;
    s:string;

begin
start:=6*(start div 6)-6;
if zakres<=24 then begin zakres:=24; dzialki:=8; dbd:=3; dbpx:=0.025; end
else if zakres<=30 then begin zakres:=30; dzialki:=10; dbd:=3; dbpx:=0.03125; end
else if zakres<=36 then begin zakres:=36; dzialki:=12; dbd:=3; dbpx:=0.0375; end
else if zakres<=48 then begin zakres:=48; dzialki:=8; dbd:=6; dbpx:=0.05; end
else if zakres<=60 then begin zakres:=60; dzialki:=10; dbd:=6; dbpx:=0.0625; end
else if zakres<=72 then begin zakres:=72; dzialki:=12; dbd:=6; dbpx:=0.075; end
else if zakres<=96 then begin zakres:=96; dzialki:=8; dbd:=12; dbpx:=0.1; end
else if zakres<=120 then begin zakres:=120; dzialki:=10; dbd:=12; dbpx:=0.125; end
else begin zakres:=144; dzialki:=12; dbd:=12; dbpx:=0.15; end;

//154


box(0,0,1792,1120,15);
for i:=0 to dzialki do for j:=-1 to 1 do line(191,j+32+i*(960 div dzialki),1537,0,0);
for i:=0 to dzialki do
  begin
  s:=inttostr(start+zakres-dbd*i);
  outtextxyz(176-16*length(s),16+i*(960 div dzialki),s,0,2,2);
  end;
outtextxyz(64,64,'dB',0,3,3);
for i:=2 to 10 do
  begin
  j:=round(512*log10(i/2));
  line(j+191,31,0,961,0);
  line(j+512+191,31,0,961,0);
  line(j+1024+191,31,0,961,0);
  end;
for j:=1 to 3 do line(190+j+1536,31,0,961,0);
for j:=1 to 3 do line(190+j+1024,31,0,961,0);
for j:=1 to 3 do line(190+j+512,31,0,961,0);
for j:=1 to 3 do line(190+j,31,0,961,0);
outtextxyz(184,1008,'20',0,2,2);
outtextxyz(512+176,1008,'200',0,2,2);
outtextxyz(1024+184,1008,'2k',0,2,2);
outtextxyz(1536+176,1008,'20k',0,2,2);
outtextxyz(1280+176,1008,'Hz',0,3,3);


//t:=gettime;
//repeat until gettime-t>500000;
//blit($Fc00000,0,0,$F000000,0,0,1792,1120,1792,1792);
end;

procedure uklad2;

var t:int64;
    start,zakres:integer;
    j,i,dbd,dzialki:integer;
    dbpx:double;
    s:string;

begin

start:=-32768 ;
dzialki:=8; dbpx:=0.0146484375; zakres:=65536; dbd:=8192;

box(0,0,1792,1120,15);
for i:=0 to dzialki do for j:=-1 to 1 do line(191,j+32+i*(960 div dzialki),1537,0,0);
for i:=0 to dzialki do
  begin
  s:=inttostr(start+zakres-dbd*i);
  outtextxyz(176-16*length(s),16+i*(960 div dzialki),s,0,2,2);
  end;
//outtextxyz(64,64,'dB',0,3,3);
for i:=1 to 3 do
  begin
  j:=round(128*i);
  line(j+191,31,0,961,0);
  line(j+512+191,31,0,961,0);
  line(j+1024+191,31,0,961,0);
  end;
for j:=1 to 3 do line(190+j+1536,31,0,961,0);
for j:=1 to 3 do line(190+j+1024,31,0,961,0);
for j:=1 to 3 do line(190+j+512,31,0,961,0);
for j:=1 to 3 do line(190+j,31,0,961,0);
outtextxyz(176,1008,'0',0,2,2);
outtextxyz(512+176,1008,'512',0,2,2);
outtextxyz(1024+168,1008,'1024',0,2,2);
outtextxyz(1536+168,1008,'1536',0,2,2);
outtextxyz(1280+176,1008,'Pr'+#30+'bka',0,3,3);
//outtextxyz(176,1008,'0',0,2,2);
//outtextxyz(512+176,1008,'3.33',0,2,2);
//outtextxyz(1024+176,1008,'6.67',0,2,2);
//outtextxyz(1536+184,1008,'10',0,2,2);
//outtextxyz(1280+176,1008,'Czas [s]',0,3,3);


t:=gettime;

end;


procedure uklad3;

var t:int64;
    start,zakres:integer;
    j,i,dbd,dzialki:integer;
    dbpx:double;
    s:string;

begin

start:=-32768 ;
dzialki:=8; dbpx:=0.0146484375; zakres:=65536; dbd:=8192;

box(0,0,1792,1120,15);
for i:=0 to dzialki do for j:=-1 to 1 do line(191,j+32+i*(960 div dzialki),1537,0,0);
for i:=0 to dzialki do
  begin
  s:=inttostr(start+zakres-dbd*i);
  outtextxyz(176-16*length(s),16+i*(960 div dzialki),s,0,2,2);
  end;
//outtextxyz(64,64,'dB',0,3,3);
for i:=1 to 3 do
  begin
  j:=round(128*i);
  line(j+191,31,0,961,0);
  line(j+512+191,31,0,961,0);
  line(j+1024+191,31,0,961,0);
  end;
for j:=1 to 3 do line(190+j+1536,31,0,961,0);
for j:=1 to 3 do line(190+j+1024,31,0,961,0);
for j:=1 to 3 do line(190+j+512,31,0,961,0);
for j:=1 to 3 do line(190+j,31,0,961,0);
//outtextxyz(176,1008,'0',0,2,2);
//outtextxyz(512+176,1008,'512',0,2,2);
//outtextxyz(1024+168,1008,'1024',0,2,2);
//outtextxyz(1536+168,1008,'1536',0,2,2);
//outtextxyz(1280+176,1008,'Pr'+#30+'bka',0,3,3);
outtextxyz(176,1008,'0',0,2,2);
outtextxyz(512+176,1008,'3.33',0,2,2);
outtextxyz(1024+176,1008,'6.67',0,2,2);
outtextxyz(1536+184,1008,'10',0,2,2);
outtextxyz(1280+176,1008,'Czas [s]',0,3,3);


t:=gettime;

end;

procedure uplot(start,zakres,x:integer; data,data2:double;c:integer);

var t:int64;
    pixel2,pixel,j,i,dbd,dzialki:integer;
    dbpx:double;
    s:string;

begin
start:=6*(start div 6)-6;
if zakres<=24 then begin zakres:=24; dzialki:=8; dbd:=3; dbpx:=0.025; end
else if zakres<=30 then begin zakres:=30; dzialki:=10; dbd:=3; dbpx:=0.03125; end
else if zakres<=36 then begin zakres:=36; dzialki:=12; dbd:=3; dbpx:=0.0375; end
else if zakres<=48 then begin zakres:=48; dzialki:=8; dbd:=6; dbpx:=0.05; end
else if zakres<=60 then begin zakres:=60; dzialki:=10; dbd:=6; dbpx:=0.0625; end
else if zakres<=72 then begin zakres:=72; dzialki:=12; dbd:=6; dbpx:=0.075; end
else if zakres<=96 then begin zakres:=96; dzialki:=8; dbd:=12; dbpx:=0.1; end
else if zakres<=120 then begin zakres:=120; dzialki:=10; dbd:=12; dbpx:=0.125; end
else begin zakres:=144; dzialki:=12; dbd:=12; dbpx:=0.15; end;

pixel:=round((data-start)/dbpx);
pixel2:=round((data2-start)/dbpx);
line2(191+x,992-pixel,192+x,992-pixel2,c);
line2(192+x,992-pixel,193+x,992-pixel2,c);
line2(191+x,993-pixel,192+x,993-pixel2,c);
line2(192+x,993-pixel,193+x,993-pixel2,c);
end;



end.

