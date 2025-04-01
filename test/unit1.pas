unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, cwindows, retro, fft, math, audio;


const scaler=1.0045073642544625156647946943413;
      fft192=0.0457763671875;
      fft441=0.08411407470703125;
//    const rld=1.0072464122237038980903435690978;  //1024 freqs
      const rld=1.0036166659754629134913855149569;  //2048 freqs
type

  { TForm1 }

  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;


  wavehead=packed record
    riff:integer;
    size:cardinal;
    wave:integer;
    fmt:integer;
    fmtl:integer;
    pcm:smallint;
    channels:smallint;
    srate:integer;
    brate:integer;
    bytesps:smallint;
    bps:smallint;
    data:integer;
    datasize:cardinal;
  end;

  bmppixel=array[0..2] of byte;

var

Form1: TForm1;
currentdir,currentdir2:string;
b:byte;
temp:cbutton;
openbutton:cbutton;
playbutton:cbutton;
stopbutton:cbutton;
snrbutton:cbutton;
widespecbutton:cbutton;
anal2button:cbutton;
syntbutton:cbutton;
pausebutton:cbutton;
test:cbutton;
haaar:cbutton;
fileparams:cwindow;
tempwin:cwindow;
transport:cwindow;
control:cwindow;
waveform:cwindow;
noise:cbutton;
click1: cbutton;
savebutton:cbutton;
wowbutton:cbutton;
quasibutton:cbutton;
harmonicbutton:cbutton;
recommendedbutton:cbutton;
toolsbutton:cbutton;
toolswindow:cwindow;

start, range:cbutton;
sbutton19:cbutton;


implementation



{$R *.lfm}

{ TForm1 }

// -----------  User interface initialization ----------------------------------


function waveformtimeinit(start,eend:double):string;

var h,m,s,t,l,i:integer;
   px,t5:double;
   ts,ss,ms,hs,sss:string;
   hb,mb,sb:boolean;

begin
for i:=1 to 9 do waveform.line(40+170*i,365,0,320,245);
for i:=1 to 9 do waveform.line(40+170*i,15,0,320,245);
t5:=(eend-start)/10;
if eend>3600000 then hb:=true else hb:=false;
if eend>60000 then mb:=true else mb:=false;
if eend>1000 then sb:=true else sb:=false;

px:=start;
for i:=0 to 10 do
  begin
  h:=trunc(px/3600000);
  m:=trunc(px/60000) mod 60;
  s:=trunc(px/1000) mod 60;
  t:=round(px) mod 1000;
  ts:=inttostr(t);
  if t<100 then ts:='0'+ts;
  if t<10 then ts:='0'+ts;
  ss:=inttostr(s);
  if s<10 then ss:='0'+ss;
  ms:=inttostr(m);
  if m<10 then ms:='0'+ms;
  hs:=inttostr(h);
  sss:=ts;
  if sb then sss:=ss+'.'+sss ;
  if mb then sss:=ms+':'+sss;
  if hb then sss:=hs+':'+sss;
  l:=length(sss)*4;
  waveform.outtextxy(40+170*i-l,694,sss,202);
  px+=t5;
  end;
result:=sss;
end;



procedure main1 ;

var i:integer;

begin
poke($70001,1);
retro.graphics(16);
for i:=1 to 3 do setataripallette(i);
cls(146);
dpoke($6000c,$002040);
ttt:=gettime;
framecount:=raml^[$18000];
box(0,0,1792,32,120);
outtextxyz(450,8,'The retromachine sound project v. 0.10 --- 2016.04.21',156,2,1);
box(0,1096,1792,24,120);

waveform:=cmodalwindow.create(2,35,1788,758,1788,758,0,130,'Waveform view');


waveform.redrawclient;

control:=cmodalwindow.create(2,794,415,300,647,300,161,161,'Control');
transport:=cmodalwindow.create(418,794,481,300,480,300,193,193,'Transport');
fileparams:=cmodalwindow.create(900,794,890,300,659,300,241,241,'Wave parameters') ;


fileparams.outtextxy(4,4,'No file loaded.',24);
fileparams.redrawclient;
playbutton:=cbutton.create(436,1050,144,28,196,232,'Play',nil);
pausebutton:=cbutton.create(586,1050,144,28,196,232,'Pause',nil);
stopbutton:=cbutton.create(736,1050,144,28,36,232,'Stop',nil);

openbutton:=cbutton.create(14,830,192,28,163,232,'Open',nil);
noise:=cbutton.create(14,870,192,28,120,232,'Denoise',nil);
click1:=cbutton.create(14,905,192,28,120,232,'Declick',nil);
wowbutton:=cbutton.create(14,940,192,28,120,232,'Wow reduction',nil);
quasibutton:=cbutton.create(14,975,192,28,120,232,'HQ noise reduction',nil);
harmonicbutton:=cbutton.create(14,1010 ,192,28,120,232,'Sound enhance',nil);
//snrbutton:=cbutton.create(14,874,96,32,120,232,'SNR',nil);
//widespecbutton:=cbutton.create(14,914,96,32,120,232,'Wide spc',nil);
//anal2button:=cbutton.create(14,954,96,32,120,232,'Anal 2',nil);
//syntbutton:=cbutton.create(14,994,96,32,120,232,'Synt',nil);
//test:=cbutton.create(14,1034,96,32,120,232,'Test',nil);
//haaar:=cbutton.create(114,834 ,96,32,120,232,'Haar',nil);


savebutton:=cbutton.create(14,1050 ,192,28,38,232,'Save',nil);
recommendedbutton:=cbutton.create(214,1050 ,192,28,180,232,'Auto reconstruction',nil);
toolsbutton:=cbutton.create(214,830 ,192,28,116,232,'Tools',nil);
end;

procedure tools;


var i:integer;

begin
sls:=cbutton.create(745,650,165,32,136,232,'Last spectrum',nil);
haaar:=cbutton.create(575,610,335,32,136,232,'Haar',nil);

sbutton:=cbutton.create(575,570,165,32,136,232,'Plot wide spectrum',nil);
sbutton19:=cbutton.create(575,530,165,32,136,232,'Plot spectrum',nil);
over:=cbutton.create(575,650,165,32,136,232,'Overdraw',nil);
wbutton:=cbutton.create(745,530,165,32,136,232,'Plot waveform',nil);
wbutton10:=cbutton.create(745,570,165,32,136,232,'Waveform 10s',nil);

outtextxyz(636,323,'Start',152,1,1);
start:=cbutton.create(575,345,165,32,149,156,'-66 dB',nil);
start.setvalue(60);
start:=start.append(575,380,165,32,149,156,'-84 dB');
start.setvalue(80);
start:=start.append(575,415,165,32,149,156,'-102 dB');
start.setvalue(100);
start:=start.append(575,450,165,32,149,156,'-126 dB');
start.setvalue(120);
start:=start.append(575,485,165,32,149,156,'Auto');
start.setvalue(0);
start.highlight;
start.select;
start:=start.gofirst;

outtextxyz(806,323,'Range',172,1,1);
range:=cbutton.create(745,345,165,32,164,172,'60 dB',nil);
range.setvalue(60);
range:=range.append(745,380,165,32,164,172,'96 dB');
range.setvalue(96);
range:=range.append(745,415,165,32,164,172,'120 dB');
range.setvalue(120);
range:=range.append(745,450,165,32,164,172,'144 dB');
range.setvalue(144);
range:=range.append(745,485,165,32,164,172,'Auto');
range.setvalue(0);
range.highlight;
range.select;
temp:=range.gofirst;
repeat
  temp.radiobutton:=true;
  temp:=temp.next;
until temp=nil;

temp:=start.gofirst;
repeat
  temp.radiobutton:=true;
  temp:=temp.next;
until temp=nil;


range:=range.gofirst;

outtextxyz(724,160,'Color',15,1,1);
scolor:=cbutton.create(575,180,80,32,136,0,'Black',nil);
scolor:=scolor.append(660,180,80,32,136,20,'Brown');
scolor:=scolor.append(745,180,80,32,136,36,'Red');
scolor:=scolor.append(830,180,80,32,136,52,'Pink');
scolor:=scolor.append(575,215,80,32,136,76,'Purple');
scolor:=scolor.append(660,215,80,32,136,86,'Violet');
scolor:=scolor.append(745,215,80,32,136,102,'Blue');
scolor:=scolor.append(830,215,80,32,136,118,'Blue2');
scolor:=scolor.append(575,250,80,32,136,138,'Ocean');
scolor:=scolor.append(660,250,80,32,136,154,'Sky');
scolor:=scolor.append(745,250,80,32,136,170,'Grass');
scolor:=scolor.append(830,250,80,32,136,186,'Green');
scolor:=scolor.append(575,285,80,32,136,202,'Spring');
scolor:=scolor.append(660,285,80,32,136,218,'Olive');
scolor:=scolor.append(745,285,80,32,136,234,'Yellow');
scolor:=scolor.append(830,285,80,32,136,250,'Orange');
scolor:=scolor.gofirst;
temp:=scolor;
i:=0;
  repeat
  if temp.last=nil then temp.setvalue(0) else temp.setvalue(6+i*16);
  temp.radiobutton:=true;
  temp:=temp.next;
  i+=1;
until temp=nil;
scolor:=scolor.gofirst;
scolor.highlight;
scolor.select;
for i:=0 to 3 do poke($81000+i,0);
end;


// -----------  sample math operators ------------------------------------------

//operator =(a,b:tsdl_audiospec):boolean;

//begin
//if (a.freq=b.freq)
//    and (a.format=b.format)
//    and (a.channels=b.channels)
//    and (a.samples=b.samples)
//then result:=true else result:=false;
//end;

operator *(a:TFloatsample;b:double):TFloatsample;

begin
result[0]:=a[0]*b;
result[1]:=a[1]*b;
end;

operator :=(a:Tsample):TFloatsample;

begin
result[0]:=a[0]/32768;
result[1]:=a[1]/32768;
end;

operator +(a,b:TFloatsample):TFloatsample;

begin
result[0]:=a[0]+b[0];
result[1]:=a[1]+b[1];
end;


//------------------------------------------------------------------------------
// Form create: prepare everything, then enter the main loop
//------------------------------------------------------------------------------
//
//------------ MAIN LOOP HERE --------------------------------------------------

procedure TForm1.FormCreate(Sender: TObject);


label p999,p998;
var mx,my,cc,i:integer;

begin
// create frequency tables etc stuff
DefaultFormatSettings.DecimalSeparator := '.';


//---------- Start the retromachine in a window  ---------------

initmachine(0);
main1;
poke($70001,1);

// -------- main loop start ---------------

sethidecolor(232,0,%00000011);
for i:=0 to 255 do sethidecolor(i,1,%00000011);
repeat
  // if fileselector active, then check it
  mx:=dpeek($6002c)-64*peek($70002);
  my:=dpeek($6002e)-40*peek($70002);
  if (fs=nil) and (peek($60030)=1) and (mx>44) and (mx<1746) and (my>72) and(my<744) then
    begin
    playtime:=(mx-45)*samplenum/(192*1700);
    jj:=round(playtime*192/4096);
    end;
  if fs<>nil then
    begin
    fs.checkmouse;
    if fs.needdestroy then
      begin
      freeandnil(fs);
      application.processmessages;
      fileparams.checkmouse;
      fileparams.redrawclient;
      waveform.redrawclient;
      end;
    end;

    if toolswindow<>nil then
    begin

    sls.checkall;
    haaar.checkall;
    sbutton.checkall;
    sbutton19.checkall;
    over.checkall;
    wbutton.checkall;
    wbutton10.checkall;
    start.checkall;
    range.checkall;
    toolswindow.checkmouse;

    if toolswindow.needdestroy then
      begin
      freeandnil(toolswindow);
      application.processmessages;
      fileparams.checkmouse;
      fileparams.redrawclient;
      waveform.redrawclient;
      end;
    goto p998;
    end;


  pausebutton.checkall;
  stopbutton.checkall;
  playbutton.checkall;
  wowbutton.checkall;
  quasibutton.checkall;
  harmonicbutton.checkall;
  savebutton.checkall;
  recommendedbutton.checkall;
  toolsbutton.checkall;

  if (toolsbutton.clicked=1) and (toolswindow=nil) then
     begin
     toolswindow:=cwindow.create(568,132,365,577,365,577,256+147,256+144,'Tools');
     toolswindow.movable:=false;
     toolsbutton.clicked:=0;
     toolsbutton.unselect;
     tools;
     end;


  // if wave not playing, then unselect transport buttons
  if juzmoznagrac=-1 then

    begin
    playbutton.unselect;
    stopbutton.unselect;
    pausebutton.unselect;
  //  playtime:=0;
    end;


  openbutton.checkall;


  noise.checkall;
  click1.checkall;

  //if pausebutton.selected then sdl_pauseaudio(1) else if playbutton.selected then sdl_pauseaudio(0);
  fileparams.checkmouse;



  if noise.clicked=1 then
    begin
    noise.clicked:=0;
    noise.unselect;
    end;

  if click1.clicked=1 then
    begin
    click1.clicked:=0;
    click1.unselect;
    end;

  if harmonicbutton.clicked=1 then
    begin
    harmonicbutton.clicked:=0;
    harmonicbutton.unselect;
    end;


  if stopbutton.clicked=1 then
    begin
    stopbutton.clicked:=0;
    stopbutton.unselect;
    playbutton.unselect;
    juzmoznagrac:=-1;
    end;

  if (playbutton.clicked=1) then
    if currentwp<>nil then
      begin
      playbutton.select;
      playbutton.clicked:=0;
      juzmoznagrac:=0;
      //sdl_pauseaudio(0);
      end
    else begin playbutton.clicked:=0; playbutton.unselect; end;


  if (openbutton.clicked=1)  and (fs=nil) then //if fs.filename<>'' then
    begin
    opendialog1.execute;
    fs:=cfselector.create(642,184,508,492,508,492,256+141,256+128,'File selector','D:\','');
    openbutton.clicked:=0;
    openbutton.unselect;
    end
  else  if fs<>nil then
    begin
    openbutton.clicked:=0;
    openbutton.unselect;
    end;

  if fs<>nil then
    if fs.done then
      begin
      juzmoznagrac:=-1;
 //     fs_filename:=fs.filename;
//      openwave(fs.filename);
      fs.destroy;
      fs:=nil;
      fileparams.redrawclient;
      waveform.redrawclient;
      end;

p998:
// ---------------  raster interrupts effect switch ----------------------------

  if peek($60028)=ord('i') then poke($70001, peek($70001) xor 1);

// ---------------  switch to full screen --------------------------------------

  if (peek($60028)=ord('f')) and (peek($70002)=0) then
    begin
    poke($60028,0);
    poke($70002,1);
    needrestart:=2;
    end;
;

  // ---------------  switch to window -----------------------------------------

  if (peek($60028)=ord('f')) and (peek($70002)=1) then
    begin
    poke($60028,0);
    poke($70002,0);
    needrestart:=2;
    end;


  poke($60030,0);  // clear mouse button
  lpoke($60028,0); // clear kbd

  application.processmessages;

p999:
until ((peek($6002b)<>0) and (peek($60028)=27)) or (needclose=1);
timer1:=-1;
fileclose(fh);
stopmachine;
halt;
end;

//------------------ MAIN LOOP END ---------------------------------------------

// ---------------- Allow the program to close ---------------------------------

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
closeaction:=cafree;
end;

function cheby4(input:TFloatsample; mode:integer):Tfloatsample;
var i:integer;

// Low pass Chebyshev filter 20k @ 192k
// computed with mkfilter http://www-users.cs.york.ac.uk/~fisher/mkfilter/trad.html

const xvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const xvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const gain= 2.366354733e+05 ;

begin
if mode=1 then for i:=0 to 8 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4]; xvl[4]:=xvl[5]; xvl[5]:=xvl[6]; xvl[6]:=xvl[7]; xvl[7]:=xvl[8];
xvl[8]:=(0.00005*random+input[0])/gain;

yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4]; yvl[4]:=yvl[5]; yvl[5]:=yvl[6]; yvl[6]:=yvl[7]; yvl[7]:= yvl[8];
yvl[8] :=   (xvl[0] + xvl[8]) + 8 * (xvl[1] + xvl[7]) + 28 * (xvl[2] + xvl[6])
             + 56 * (xvl[3] + xvl[5]) + 70 * xvl[4]
             + ( -0.3334450683 * yvl[0]) + (  2.7238758762 * yvl[1])
             + (-10.0475727760 * yvl[2]) + ( 21.8605976810 * yvl[3])
             + (-30.7017569250 * yvl[4]) + ( 28.5340593520 * yvl[5])
             + (-17.1697147400 * yvl[6]) + (  6.1328747665 * yvl[7]);
result[0] := yvl[8];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4]; xvr[4]:=xvr[5]; xvr[5]:=xvr[6]; xvr[6]:=xvr[7]; xvr[7]:=xvr[8];
xvr[8]:=(0.00005*random+input[1])/gain;

yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4]; yvr[4]:=yvr[5]; yvr[5]:=yvr[6]; yvr[6]:=yvr[7]; yvr[7]:= yvr[8];
yvr[8] :=   (xvr[0] + xvr[8]) + 8 * (xvr[1] + xvr[7]) + 28 * (xvr[2] + xvr[6])
             + 56 * (xvr[3] + xvr[5]) + 70 * xvr[4]
             + ( -0.3334450683 * yvr[0]) + (  2.7238758762 * yvr[1])
             + (-10.0475727760 * yvr[2]) + ( 21.8605976810 * yvr[3])
             + (-30.7017569250 * yvr[4]) + ( 28.5340593520 * yvr[5])
             + (-17.1697147400 * yvr[6]) + (  6.1328747665 * yvr[7]);
result[1] := yvr[8];
end;

end.

