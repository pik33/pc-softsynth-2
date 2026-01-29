unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, cwindows, retro, sdl2, fft, math, audio;


const scaler=1.0045073642544625156647946943413;
      fft192=0.0457763671875;
      fft441=0.08411407470703125;
//    const rld=1.0072464122237038980903435690978;  //1024 freqs
      const rld=1.0036166659754629134913855149569;  //2048 freqs
type

  { TForm1 }

  TForm1 = class(TForm)
    fft8: TDSXFastFourier;
    fft7: TDSXFastFourier;
    fft6: TDSXFastFourier;
    fft5: TDSXFastFourier;
    fft2: TDSXFastFourier;
    fft3: TDSXFastFourier;
    fft4: TDSXFastFourier;
    fft1: TDSXFastFourier;
    procedure fft1GetData(index: integer; var Value: TComplex);
    procedure fft2GetData(index: integer; var Value: TComplex);
    procedure fft3GetData(index: integer; var Value: TComplex);
    procedure fft4GetData(index: integer; var Value: TComplex);
    procedure fft5GetData(index: integer; var Value: TComplex);
    procedure fft6GetData(index: integer; var Value: TComplex);
    procedure fft7GetData(index: integer; var Value: TComplex);
    procedure fft8GetData(index: integer; var Value: TComplex);
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



  freqs1=record
    time,intfreq:integer;
    d3,d2,freq,ampl,phs:double;
    t:integer; //0-std, 1..n-maximum, n<256, 256+n - harmonic of nth max
    oct:integer;
    end;

  haars1=record
    time,freq:integer;
    ampl:double;
    end;

  ffreqs1=file of freqs1;
  fhaars1=file of haars1;

  wavedata=record
    samples :integer;
    noisefloor:array[0..9] of double;
    high,low:double;
    snr:double;
    snrplace:integer;
    pulse:double;
    quasi:array[0..3] of double;
    medium: integer;
    source:integer;
    quality:integer;
    end;



  bmppixel=array[0..2] of byte;
 // filedesc=array[0..1000,0..1] of string;
var
  Form1: TForm1;
  wavebuf: array[0..2*16777216] of smallint;
  wavebuf2:array[0..16777216] of integer;
  fftbuf2,fftbuf:array[0..1048576] of double;
  fftpos,fftpos1,fftpos2,s1,z1:integer;
  fftval,dfreq,oldfreq,freq,maxi,mini:double;
  idx,cc,kk:integer;
  currentdir,currentdir2:string;
  freqtable:array[0..2047] of double;
  bmpi:integer;
  bmpp:bmppixel absolute bmpi;
  b:byte;
  bmpbuf:array[0..2500000] of bmppixel;
  temp:cbutton;
  harmonics:array[0..50] of integer;
  sr:tsearchrec;
  minipos: integer; // minimal audio volume pos in samples for snr
  wb2:array[0..2*1921000] of smallint;
 wb2i:array[0..1921000] of integer;


     sfilebuf:array[0..50000000] of single;
     ffilebuf:array[0..50000000] of double;
     buf2:array[0..4194303] of double;
       wavepointer1:pointer=nil;
       wavepointer2,wavepointer3,wavepointer4:pointer;
         il,currentil:integer;
    wsfn:string;

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


 testsignals: array[0..2047,0..24575] of double;
 testsignalc: array[0..2047,0..24575] of double;
 testsignalsqr: array[0..2047,0..24575] of single;
 buf3:array[0..32767] of double;
 noisefloor:array[0..9] of double;
 maxfft:array[0..3419] of double;
 bandstart,bandstop:double;
   maxvalue:double;
   fs_filename:string;

 wdata:wavedata;

 buforl,buforr:array[0..65535] of double;
 bufimag:array[0..131072] of double;

implementation


 var head,head2:wavehead;
     convert:boolean;
     src_format:TSDL_AudioFormat;



procedure anal2; forward;
procedure synt1; forward;
procedure getmax; forward;

procedure haar(f:string); forward;
function cheby1(input:TFloatsample;mode:integer):Tfloatsample; forward;
function cheby3(input:TFloatsample;mode:integer):Tfloatsample; forward;
function cheby4(input:TFloatsample;mode:integer):Tfloatsample; forward;
function bessel1(input:TFloatsample; mode:integer):Tfloatsample; forward;
procedure convertpcmtofloat(from:Psample; too:PFloatsample;il:integer); forward;
function resample44to192(from,too:Pfloatsample;il:int64):int64; forward;
function resample96to192(from,too:Pfloatsample;il:int64):int64; forward;
procedure convertmonotostereo(from:Psmallint;too:Psample;il:integer); forward;
procedure convertmonotostereof(from:Psingle;too:Pfloatsample;il:integer); forward;
procedure widespectrum(filename:string; start,zakres,c:integer;overwrite:boolean); forward;
procedure main1; forward;
procedure openwave(filename:string); forward;

procedure antialias(from:Pfloatsample;too:Pfloatsample;il:integer);  forward;
function sampletimetostr(a:integer):string;     forward;
procedure denoise;    forward;
procedure declick;   forward;
function enhance(from:Pfloatsample;il:int64):int64; forward;


{$R *.lfm}

{ TForm1 }

// -----------  User interface initialization ----------------------------------

procedure waveforminit;
begin
waveform.line(40,15,1700,0,248);
waveform.line(40,55,1700,0,244);
waveform.line(40,95,1700,0,245);
waveform.line(40,135,1700,0,244);
waveform.line(40,175,1700,0,248);
waveform.line(40,215,1700,0,244);
waveform.line(40,255,1700,0,245);
waveform.line(40,295,1700,0,244);
waveform.line(40,335,1700,0,248);

waveform.line(40,365,1700,0,248);

waveform.line(40,405,1700,0,244);
waveform.line(40,445,1700,0,245);
waveform.line(40,485,1700,0,244);
waveform.line(40,525,1700,0,248);
waveform.line(40,565,1700,0,244);
waveform.line(40,605,1700,0,245);
waveform.line(40,645,1700,0,244);
waveform.line(40,685,1700,0,248);
waveform.line(40,365,1700,0,248);


waveform.line(40,350,1700,0,15);


waveform.line(40,15,0,320,250);
waveform.outtextxy(4,7,'1.00',202);
waveform.outtextxy(4,47,'0.75',202);
waveform.outtextxy(4,87,'0.50',202);
waveform.outtextxy(4,127,'0.25',202);
waveform.outtextxy(4,167,'0.00',202);
waveform.outtextxy(4,207,'0.25',202);
waveform.outtextxy(4,247,'0.50',202);
waveform.outtextxy(4,287,'0.75',202);
waveform.outtextxy(4,327,'1.00',202);

waveform.line(1740,15,0,320,250);
waveform.outtextxy(1744,7,'1.00',202);
waveform.outtextxy(1744,47,'0.75',202);
waveform.outtextxy(1744,87,'0.50',202);
waveform.outtextxy(1744,127,'0.25',202);
waveform.outtextxy(1744,167,'0.00',202);
waveform.outtextxy(1744,207,'0.25',202);
waveform.outtextxy(1744,247,'0.50',202);
waveform.outtextxy(1744,287,'0.75',202);
waveform.outtextxy(1744,327,'1.00',202);

waveform.line(40,365,0,320,250);
waveform.outtextxy(4,357,'1.00',202);
waveform.outtextxy(4,397,'0.75',202);
waveform.outtextxy(4,437,'0.50',202);
waveform.outtextxy(4,477,'0.25',202);
waveform.outtextxy(4,517,'0.00',202);
waveform.outtextxy(4,557,'0.25',202);
waveform.outtextxy(4,597,'0.50',202);
waveform.outtextxy(4,637,'0.75',202);
waveform.outtextxy(4,677,'1.00',202);

waveform.line(1740,365,0,320,250);
waveform.outtextxy(1744,357,'1.00',202);
waveform.outtextxy(1744,397,'0.75',202);
waveform.outtextxy(1744,437,'0.50',202);
waveform.outtextxy(1744,477,'0.25',202);
waveform.outtextxy(1744,517,'0.00',202);
waveform.outtextxy(1744,557,'0.25',202);
waveform.outtextxy(1744,597,'0.50',202);
waveform.outtextxy(1744,637,'0.75',202);
waveform.outtextxy(1744,677,'1.00',202);

end;

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
waveforminit;

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

operator =(a,b:tsdl_audiospec):boolean;

begin
if (a.freq=b.freq)
    and (a.format=b.format)
    and (a.channels=b.channels)
    and (a.samples=b.samples)
then result:=true else result:=false;
end;

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


// ------------------ fft modules getdata procs --------------------------------

procedure TForm1.fft1GetData(index: integer; var Value: TComplex);
begin
value.real:=wavebuf2[index];
value.imag:=0;
end;


procedure TForm1.fft2GetData(index: integer; var Value: TComplex);
begin
value.real:=buf2[index];
value.imag:=bufimag[index];
end;

procedure TForm1.fft3GetData(index: integer; var Value: TComplex);
begin
value.real:=buf2[index];
value.imag:=bufimag[index];
end;

procedure TForm1.fft4GetData(index: integer; var Value: TComplex);
begin
value.real:=buf2[index];
value.imag:=0;
end;

procedure TForm1.fft5GetData(index: integer; var Value: TComplex);
begin
value.real:=buf2[index];
value.imag:=0;
end;

procedure TForm1.fft6GetData(index: integer; var Value: TComplex);
begin
value.real:=buf3[index];
value.imag:=0;
end;

procedure TForm1.fft7GetData(index: integer; var Value: TComplex);
begin
value.real:=buf2[index];
value.imag:=0;
end;

procedure TForm1.fft8GetData(index: integer; var Value: TComplex);
begin
value.real:=buf2[index];
value.imag:=0;
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
for i:=1 to 50 do harmonics[i]:=round(192*log10(i)/log10(2));

// sinus and cosinus lookup tables

freq:=12.4280356528781;
for i:=0 to 2047 do
  begin
  freqtable[i]:=freq;
  freq*=rld;
  end;
for i:=0 to 131071 do bufimag[i]:=0;

//---------- Start the retromachine in a window  ---------------

initmachine(0);
main1;
poke($70001,1);
i:=fileopen('testsignals.def',$40);
fileread(i,testsignals,402653184);
fileread(i,testsignalc,402653184);
fileclose(i);

//for i:=1 to 50 do outtextxy(200,50+16*i,inttostr(harmonics[i]),44);
// 1600->4008
// 796->220
//outtextxy(200,200,floattostr(freqtable[796]),44);

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

  if pausebutton.selected then sdl_pauseaudio(1) else if playbutton.selected then sdl_pauseaudio(0);
  fileparams.checkmouse;



  if noise.clicked=1 then
    begin
    denoise;
    noise.clicked:=0;
    noise.unselect;
    end;

  if click1.clicked=1 then
    begin
    declick;
    click1.clicked:=0;
    click1.unselect;
    end;

  if harmonicbutton.clicked=1 then
    begin
    enhance(currentwp,samplenum);
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
      sdl_pauseaudio(0);
      end
    else begin playbutton.clicked:=0; playbutton.unselect; end;


  if (openbutton.clicked=1)  and (fs=nil) then //if fs.filename<>'' then
    begin
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
      fs_filename:=fs.filename;
      openwave(fs.filename);
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

//--------------- Open the wave file -------------------------------------------
// rev 20160307 ---
// open file, resample, get noise floor, bandwidth, pulse, classify the file
// to do: recommend methods

procedure openwave(filename:string);

label p101,p102,p999,p998;
var noconvert:boolean=false;
    f,fh3:integer;
    s:string;
    head_datasize:int64;
    delta:double;
    times:string;
    asnr:double;

    il:cardinal;
    recommend:byte=0; //enh|wow|quasi|click|noise

    c,x,ii,i,j,k,l,m,n:integer;
    q,ss,mini,maxi,maxi2,p,p2:double;
    ps:^TfloatSample;
    fs,fs2,fs3,fs4:TfloatSample;
    silence:boolean=true;
    pulsecount:integer;
    buf1:array[0..32767] of single;
   m1,m2:double;
   time:integer;
         tmprec:haars1;
        hrecords:array[0..16383] of haars1;

    h:double;
    kk:integer;
       tabl:array[0..5,0..8191] of integer;
        tabl2,tabl3,tabl4:array[0..8191] of double;
           tabl5:array[0..7] of double;
     maxf50,maxf100,maxf15,maxf19, numsfs:integer;

    buf3a:array[0..435060] of double;
    p50h,p100h,p15kh,p19kh:double;
    minw50,maxw50,minw100,maxw100,minw15k,maxw15k,minw19k,maxw19k:double;
    wowam:double;
    hq,recmq,reclq,recshell,taperadio,tapetv,tapelow,taperec:double;

// open a wave, convert if needed, place in RAM buffer

begin
fh3:=fileopen(filename,$40);
s:= copy(filename,length(filename)-6,7);
if s='192.wav' then noconvert:=true;     //192.wav is already converted file
wsfn:=fs_filename;

// reset antialias filters
cheby_lp_20k_192k(zerofsample,1);
cheby3(zerofsample,1);

// free memory if used
if wavepointer1<>nil then begin freemem(wavepointer1); wavepointer1:=nil;   end;
if wavepointer2<>nil then begin freemem(wavepointer2); wavepointer2:=nil;   end;
if wavepointer3<>nil then begin freemem(wavepointer3); wavepointer3:=nil;   end;
if wavepointer4<>nil then begin freemem(wavepointer4); wavepointer4:=nil;   end;

//prepare a message window
tempwin:=cwindow.create(500,500,800,100,800,100,256+176,256+177,'Message');


//read wave header
fileread(fh3,head,44);
if head.data<>1635017060 then
  begin  //non-standard header
  i:=0;
  repeat fileseek(fh3,i,fsfrombeginning); fileread(fh3,k,4); i+=1 until (k=1635017060) or (i>512);
  if k=1635017060 then
    begin
    head.data:=k;
    fileread(fh3,k,4);
    head.datasize:=k;
    end
  else
    begin
    tempwin.cls;
    tempwin.outtextxy(20,12,'Error - not a wave file or format unknown.',170);
    tempwin.outtextxy(20,28,'Press any key...',170);
    tempwin.redrawclient;
    fileclose(fh3);
    goto p999;
    end;
  end;

// visualize wave data
for i:=1 to length(filename) do if filename[i]='\' then j:=i;
s:=copy(filename,j+1,length(filename)-j);
fileparams.cls;
fileparams.title:='Opened file: '+s;
fileparams.outtextxy(4,8, 'size:             '+inttostr(head.size),246);
fileparams.outtextxy(4,24, 'pcm type :        '+inttostr(head.pcm),26);
fileparams.outtextxy(4,40, 'channels:         '+inttostr(head.channels),42);
fileparams.outtextxy(4,56, 'sample rate:      '+inttostr(head.srate),58);
fileparams.outtextxy(4,72, 'bitrate:          '+inttostr(head.brate),74);
fileparams.outtextxy(4,88,'bytes per sample: '+inttostr(head.bytesps),90);
fileparams.outtextxy(4,104,'bits per sample:  '+inttostr(head.bps),106);
fileparams.outtextxy(4,120,'data size:        '+inttostr(head.datasize),122);
fileparams.drawdecoration;
fileparams.redrawclient;

head_datasize:=head.datasize ;

// error message if more than 2 channels or not pcm file
if (head.channels>2) or not((head.pcm=1) or (head.pcm=3)) then
  begin
  tempwin.cls;
  tempwin.outtextxy(20,12,'Error - file format unknown.',170);
  tempwin.outtextxy(20,28,'Press any key...',170);
  tempwin.redrawclient;
  fileclose(fh3);
  goto p999;
  end;

// check if format conversion is needed
convert:=false;
if (head.channels<>2) or (head.pcm=1) or (head.srate<>192000) then
  begin
  if head.pcm=3 then src_format:=audio_f32
  else if (head.pcm=1) and (head.bps=16) then src_format:=audio_s16
  else if (head.pcm=1) and (head.bps=16) then src_format:=audio_u8
  else //error
    begin
    tempwin.cls;
    tempwin.outtextxy(20,12,'Error - file format unknown.',170);
    tempwin.outtextxy(20,28,'Press any key...',170);
    tempwin.redrawclient;
    fileclose(fh3);
    goto p999;
    end;
  convert:=true;
  end;

//Get a memory for the wave file
wavepointer1:=getmem(head_datasize+192000);// 33554432);
currentwp:=wavepointer1;
if wavepointer1=nil then
  begin
  tempwin.cls;
  tempwin.outtextxy(20,12,'Error - cannot allocate memory.',170);
  tempwin.outtextxy(20,28,'Press any key...',170);
  tempwin.redrawclient;
  fileclose(fh3);
  goto p999;
  end;

//Load the file into the memory
tempwin.outtextxy(20,20,'Loading wave file, please wait...',138);
tempwin.redrawclient;
il:=fileread(fh3,wavepointer1^,head.datasize);
fileclose(fh3);
if il<>head.datasize then messagedlg('Read '+inttostr(il)+'bytes instead of '+inttostr(head.datasize),Mterror,[MbOk],0);
//box(100,840,200,16,146);
currentwp:=wavepointer1;
currentdatasize:=head_datasize;

// determine the number of samples

samplenum:=currentdatasize div (head.channels*head.bps div 8);

 // convert the file to stereo, 192 kHz, 32 bit if needed
if convert then
  begin
  // if mono, convert to stereo
  if head.channels=1 then
    begin
    tempwin.cls;
    tempwin.outtextxy(20,20,'Converting mono to stereo...',138);
    tempwin.redrawclient;
    currentdatasize*=2;
    wavepointer2:=getmem(currentdatasize+192000);
    if head.pcm=1 then convertmonotostereo(currentwp,wavepointer2,samplenum)
    else convertmonotostereof(currentwp,wavepointer2,samplenum);
    currentwp:=wavepointer2;
    end;

  // if integer, convert to float
  if (head.pcm=1) then
    begin
    tempwin.cls;
    tempwin.outtextxy(20,20,'Converting int to float...',154);
    tempwin.redrawclient;
    currentdatasize*=2;
    wavepointer3:=getmem(currentdatasize+192000);
    convertpcmtofloat(currentwp,wavepointer3,samplenum);
    currentwp:=wavepointer3;
    end;

  // if sample rate<>192000, resample
  if (head.srate=44100) then     // TODO !!
    begin
    tempwin.cls;
    tempwin.outtextxy(20,12,'Resampling 44 to 192...',170);
    tempwin.redrawclient;
    currentdatasize:=64+round(currentdatasize*4.3537414965986394557823129251701);
    wavepointer4:=getmem(currentdatasize+192000);
    samplenum:=resample44to192(currentwp,wavepointer4,head_datasize div 4);
    currentwp:=wavepointer4;
    end
  else if (head.srate=96000) then
    begin
    tempwin.cls;
    tempwin.outtextxy(20,12,'Resampling 96 to 192...',170);
    tempwin.redrawclient;
    currentdatasize:=2*currentdatasize;
    wavepointer4:=getmem(currentdatasize+33554432);
    resample96to192(currentwp,wavepointer4,samplenum);
    samplenum*=2;
    currentwp:=wavepointer4;
    end
  else if (head.srate=192000) then // filter high freq noise
    begin
    tempwin.cls;
    tempwin.outtextxy(20,20,'High frequency noise filtering...',170);
    tempwin.redrawclient;
    antialias(currentwp,currentwp,samplenum);
    end
  else   // TODO: more sample rates conversion
    begin
    tempwin.cls;
    tempwin.outtextxy(20,12,'Error - sample rate unknown.',170);
    tempwin.outtextxy(20,28,'Press any key...',170);
    tempwin.redrawclient;
    goto p999
    end;
  end
else if noconvert=false then // filter high freq noise
  begin
   tempwin.cls;
   tempwin.outtextxy(20,20,'High frequency noise filtering...',170);
   tempwin.redrawclient;
   antialias(currentwp,currentwp,samplenum);

   end;

// normalize the wave to -1..1 range
if noconvert=false then
  begin
  tempwin.cls;
  tempwin.outtextxy(20,20,'Normalizing...',170);
  tempwin.redrawclient;
  maxvalue:=0;
  for i:=0 to 2*samplenum-1 do if abs(w32p[i])>maxvalue then maxvalue:=abs(w32p[i]);
  fileparams.outtextxy(4,136,'maximum value:    '+floattostr(maxvalue),184);
  fileparams.redrawclient;
  if maxvalue<>1 then for i:=0 to 2*samplenum-1 do w32p[i]:=w32p[i]/maxvalue;
  tempwin.cls;
  tempwin.outtextxy(20,20,'Writing normalized wave...',170);
  tempwin.redrawclient;
  head2:=head;
  head2.datasize:=samplenum*8;
  head2.size:=36+samplenum*8;
  head2.pcm:=3;
  head2.srate:=192000;
  head2.bps:=32;
  head2.bytesps:=8;
  head2.brate:=1536000;
  head2.channels:=2;
  fh3:=filecreate(filename+'.32-192.wav');
  filewrite(fh3,head2,44);
  filewrite(fh3,currentwp^,samplenum*8);
  fileclose(fh3);
  tempwin.cls;
  tempwin.outtextxy(20,20,'New file '+filename+'.32-192.wav written.',170);
  tempwin.redrawclient;
  wait(1000000);
  end
else
  // check if the wave is normalized
  begin
   maxvalue:=0;
  for i:=0 to 2*samplenum-1 do if abs(w32p[i])>maxvalue then maxvalue:=abs(w32p[i]);
  fileparams.outtextxy(4,136,'maximum value:    '+floattostr(maxvalue),184);
  fileparams.redrawclient;
  end;

// plot the waveform  TODO: if short wave, use lines
delta:=1700/samplenum;
waveform.cls;
waveforminit;
times:=waveformtimeinit(0,samplenum/192);
for i:=0 to samplenum-1 do waveform.putpixel(round(40+i*delta),round(175-160*w32p[2*i]),186);
for i:=0 to samplenum-1 do waveform.putpixel(round(40+i*delta),round(525-160*w32p[2*i+1]),186);
waveform.line(40,175,1700,0,248);
waveform.line(40,525,1700,0,248);
fileparams.outtextxy(4,152,'time:             '+times,200);
fileparams.redrawclient;

//write the wave data for use in the future
wdata.samples:=samplenum;

// find SNR //TODO: more intelligent omitting start and end silences
tempwin.cls;
tempwin.outtextxy(20,20,'Finding signal to noise ratio...',170);
tempwin.redrawclient;
ps:=currentwp;
cheby_snr(zerofsample,1);
cheby_snr2(zerofsample,1);
bessel_snr(zerofsample,1);
mini:=1e99;
maxi:=1e-99;
maxi2:=1e-99 ;
silence:=true;
l:=samplenum; repeat l-=1; fs:=ps[l] until (fs[0]>0.003) or (fs[1]>0.003);
for i:=0 to (l div 48000)-2 do
  begin
  p:=0;  p2:=0;
  for j:=0 to 95999 do
    begin
    fs2:=ps[48000*i+j];
    p2+= sqr(fs2[0]);
    p2+= sqr(fs2[1]);

    fs3:=cheby_snr(fs2,0);
    fs4:=cheby_snr2(fs3,0);
    fs:=bessel_snr(fs4,0);

    p+=sqr(fs[0]);
    p+=sqr(fs[1]);
    end;
  if sqrt(p/192000)>0.001 then silence:=false;
  if (silence=false) and (p<mini) then begin mini:=p; minipos:=48000*i; end;
  if p2>maxi then maxi:=p2;
  if l>384000 then
    begin
    tempwin.box(284,20,40,16,256+176);
    tempwin.outtextxy(284,20, inttostr(round(i/(0.01*((l div 48000)-2))))+' %',170);
    tempwin.redrawclient;
    end;
  waveform.box(round(40+i*1700*48000/samplenum),round(45-20*log10(sqrt(p/192000))),2,2,40);
  end;

ss:=20*log10(sqrt(maxi/mini));
wdata.snr:=ss;
wdata.snrplace:=minipos;
if ss<40 then recommend:=recommend or 1; // recommend noise reduction

fileparams.outtextxy(4,168,'SNR:              '+floattostrf(ss,fffixed,7,3)+' dB',232);
fileparams.outtextxy(4,184,'Minimum power at: '+sampletimetostr(minipos),216);
fileparams.redrawclient;

// find noise floor

tempwin.cls;
tempwin.outtextxy(20,20,'Determining noise floor...',170);
tempwin.redrawclient;

for i:=0 to 32767 do buf3[i]:=0.5*(ps[minipos+i,0]+ps[minipos+i,1]);
form1.fft6.fft;
for i:=0 to 9 do noisefloor[i]:=0;

for i:=3 to 6 do noisefloor[0]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));    //20..40
for i:=7 to 14 do noisefloor[1]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //40..80  14
for i:=15 to 27 do noisefloor[2]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //80..160  27
for i:=28 to 55 do noisefloor[3]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //160..320  55
for i:=56 to 109 do noisefloor[4]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //320..640  109
for i:=110 to 218 do noisefloor[5]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //640..1280 218
for i:=219 to 437 do noisefloor[6]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //1280..2560 437
for i:=438 to 874 do noisefloor[7]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //2560..5120  874
for i:=875 to 1748 do noisefloor[8]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //5120..10240  1748
for i:=1749 to 3413 do noisefloor[9]+=sqrt(sqr(form1.fft6.transformeddata[i].real)+sqr(form1.fft6.transformeddata[i].imag));   //10240..20000  3413

noisefloor[0]/=4;  noisefloor[1]/=8;  noisefloor[2]/=13; noisefloor[3]/=28;  noisefloor[4]/=53;
noisefloor[5]/=109;  noisefloor[6]/=218;  noisefloor[7]/=436;  noisefloor[8]/=874;  noisefloor[9]/=1665;
for i:=0 to 9 do noisefloor[i]/=16384;
for i:=0 to 9 do wdata.noisefloor[i]:=noisefloor[i];

//visualize the noise floor levels
fileparams.outtextxy(360,8,'Noise floor: ',248);
for i:=0 to 9 do fileparams.outtextxy(360,40+16*i,'Oct. '+inttostr(i)+' '+floattostrf(20*log10(noisefloor[i]),fffixed,7,3)+' dB',25+i*16);
fileparams.redrawclient;

//find the bandwidth

tempwin.cls;
tempwin.outtextxy(20,20,'Determining bandwidth...',170);
tempwin.redrawclient;
for i:=0 to 3419 do maxfft[i]:=0;
for i:=0 to (samplenum div 32768)-1 do
  begin
  for j:=0 to 32767 do
    begin
    fs2:=ps[32768*i+j];
    buf3[j]:=0.5*(fs2[0]+fs2[1]);
    end;
  form1.fft6.fft;
  for j:=3 to 3413 do
    begin
    q:=sqrt(sqr(form1.fft6.transformeddata[j].real)+sqr(form1.fft6.transformeddata[j].imag))/16384 ;
    if maxfft[j]<q then maxfft[j]:=q;
    end;
  if samplenum>384000 then
    begin
    tempwin.box(244,20,40,16,256+176);
    tempwin.outtextxy(244,20, inttostr(round(i/(0.01*((samplenum div 32768)-1))))+' %',170);
    tempwin.redrawclient;
    end;
  end;
for i:=7 to 14 do if maxfft[i]/noisefloor[1]>100 then begin bandstart:=i; goto p101; end;
for i:=15 to 27 do if maxfft[i]/noisefloor[2]>100 then begin bandstart:=i; goto p101; end;
bandstart:=28;
p101:
for i:=3413 downto 1749 do if maxfft[i]/noisefloor[9]>100 then begin bandstop:=i; goto p102; end;
for i:=1748 downto 875 do if maxfft[i]/noisefloor[8]>100 then begin bandstop:=i; goto p102; end;
for i:=874 downto 438 do if maxfft[i]/noisefloor[7]>100 then begin bandstop:=i; goto p102; end;
bandstop:=873;
p102:
fileparams.outtextxy(4,200,'Low frequency:    '+floattostrf(bandstart* 5.859375,fffixed,8,2),200);
fileparams.outtextxy(4,216,'High frequency:   '+floattostrf(bandstop* 5.859375,fffixed,8,2),184);
fileparams.redrawclient;
wdata.high:=bandstop*5.859375;
wdata.low:=bandstart*5.859375;
if wdata.high<10000 then recommend:=recommend or 16; // enhancing recommended

// pulse determination with haar transform

pulsecount:=0;
time:=0;
tempwin.cls;
tempwin.outtextxy(20,20,'Finding pulses...',170);
tempwin.redrawclient;

for i:=0 to (samplenum div 16384)-1 do
  begin

  m1:=0;
  for j:=0 to 16383 do buf1[j]:=0.5*(ps[16384*i+j,0]+ps[16384*i+j,1]);
  for j:=0 to 16383 do if buf1[j]>m1 then m1:=buf1[j];
  kk:=0;
  // do a haar! ------------

  h:=0;
  for j:=0 to 16383 do h+=buf1[j]; // all avg; haar[0]
  h*=2;
  tmprec.freq:=-1;
  tmprec.ampl:=h;
  tmprec.time:=time;
  hrecords[kk]:=tmprec;
  kk+=1;

  h:=0;
  for j:=0 to 8191 do h+=buf1[j]; // half avg;
  for j:=8192 to 16383 do h-=buf1[j];
  h*=2;
  tmprec.freq:=0;
  tmprec.ampl:=h;
  tmprec.time:=time;
  hrecords[kk]:=tmprec;
  kk+=1;
  for k:=1 to 13 do
    begin
    l:=(1 shl k)-1; // 1,3,7,15,31,63,127,255,511,1023
    m:=(8192 shr k)-1; // 511,255,127,63,31,15,7,3,1,0
    n:=(16384 shr k); // 1024,512,256,128,64,3
    for j:=0 to l do    //1,3,7,15,31.
      begin
      h:=0;
      for ii:=0 to m do h+=buf1[ii+n*j]; //2 wsp. @512,
      for ii:=m+1 to n-1 do h-=buf1[ii+n*j];
      h*=32768;
      h/=(16384 shr k);
      tmprec.freq:=k;
      tmprec.ampl:=h;
      tmprec.time:=time+j*(16384 shr k);
      hrecords[kk]:=tmprec;
      kk+=1;
      end;
    end;

// ----------------------- haaaaar

  time+=16384;

  tempwin.box(244,20,40,16,256+176);
  tempwin.outtextxy(244,20, inttostr(round(i/(0.01*((samplenum div 16384)-1))))+' %',170);
  tempwin.redrawclient;
  application.processmessages;

// now one 16384 samples chunk processed

  for kk:=0 to 16383 do
    begin
    tmprec:=hrecords[kk];
    h:=tmprec.ampl;
    if abs(tmprec.ampl)>10 then
      c:={16*tmprec.freq+16+}1+round(4*(log10(abs(tmprec.ampl/10))))
    else
      c:=1;

    x:=(tmprec.time mod 16384) div 2;
    if tmprec.freq=13 then tabl[5,x]:=c
    else if tmprec.freq=12 then for ii:=x to x+1 do tabl[4,ii]:=c
    else if tmprec.freq=11 then for ii:=x to x+3 do tabl[3,ii]:=c
    else if tmprec.freq=10 then for ii:=x to x+7 do tabl[2,ii]:=c
    else if tmprec.freq=9 then for ii:=x to x+15 do tabl[1,ii]:=c
    else if tmprec.freq=8 then for ii:=x to x+31 do tabl[0,ii]:=c;
    end;
  for ii:=0 to 8191 do tabl2[ii]:=1;
  for ii:=0 to 8191 do tabl4[ii]:=0;
  for ii:=0 to 8191 do tabl3[ii]:=0;

  for ii:=0 to 8191 do for j:=0 to 5 do tabl2[ii]*=tabl[j,ii];
  m2:=0;
  for ii:=0 to 8191 do if tabl2[ii]>m2 then m2:=tabl2[ii];
 // for i:=0 to 8191 do tabl2[i]:=tabl2[i]/m2;
  for ii:=0 to 7 do begin m2:=0; for j:=0 to 1023 do m2+=tabl2[j+1024*ii]; tabl5[ii]:=m2/1024; end;
//  m2:=0; for i:=0 to 8191 do m2+=tabl2[i]; m2/=8192;
  for ii:=8176 downto 16 do begin for j:=-16 to 15 do tabl3[ii]+=tabl2[ii+j]; tabl3[ii]/=32; end;
  for ii:=8177 to 8191 do tabl3[ii]:=tabl3[8176];
  for ii:=0 to 15 do tabl3[ii]:=tabl3[16];
  for ii:=0 to 8191 do if (tabl2[ii]>700000*maxvalue) and (tabl2[ii]>19*tabl5[ii div 1024]) then begin tabl4[ii]:=1; pulsecount+=1;
    waveform.box(round(40+i*1700*16384/samplenum),690,2,2,40);
    end;
end;
fileparams.outtextxy(4,232,'Pulses/second:    '+floattostrf(192000*pulsecount/time,fffixed,6,3),168);
fileparams.redrawclient;
wdata.pulse:=192000*pulsecount/time;
if wdata.pulse>3 then recommend:=recommend or 2; //pulse

for i:=0 to 435060 do buf3a[i]:=0;
numsfs:=samplenum div 4194304;
if numsfs=0 then
  begin
  tempwin.cls;
  tempwin.outtextxy(20,20,'File too short to find quasistationary noise...',170);
  tempwin.redrawclient;
  wait(1000000);
  fileparams.outtextxy(4,248,'Quasistationary:  '+'file too short',152);
  fileparams.redrawclient;
  for i:=0 to 3 do wdata.quasi[i]:=0;
  goto p998;
  end;
tempwin.cls;
tempwin.outtextxy(20,20,'Determining quasistationary noise...',170);
tempwin.redrawclient;
numsfs:=8;
l:=(samplenum-4194304) div 8;

for kk:=0 to numsfs-1 do
  begin
  for i:=0 to 4194303 do buf2[i]:=0.5*((w32p+l*kk+2*i)^+(w32p+l*kk+2*i+1)^)*sqr(sin(pi*i/4194304));
  form1.fft5.fft;
  for i:=0 to 435060 do buf3a[i]+=sqrt(sqr(form1.fft5.transformeddata[i].real)+sqr(form1.fft5.transformeddata[i].imag));
  tempwin.box(364,20,40,16,256+176);
  tempwin.outtextxy(364,20, inttostr(round(100*(kk+1)/8))+' %',170);
  tempwin.redrawclient;
  application.processmessages;
  end;
for i:=0 to 435060 do buf3a[i]/=8;
for i:=0 to 435060 do buf3a[i]/=1048576;
for i:=0 to 3 do wdata.quasi[i]:=0;
mini:=0; maxi:=0;
for i:=983 to 1201 do begin if buf3a[i]>maxi then begin maxi:=buf3a[i]; maxf50:=i; end; mini+=buf3a[i]; end;
p50h:=219*maxi/mini;
mini:=0; maxi:=0;
for i:=1966 to 2402 do begin if buf3a[i]>maxi then begin maxi:=buf3a[i]; maxf100:=i; end; mini+=buf3a[i]; end;
p100h:=437*maxi/mini;
mini:=0; maxi:=0;
for i:=321333 to 361332 do begin if buf3a[i]>maxi then begin maxi:=buf3a[i]; maxf15:=i; end; mini+=buf3a[i]; end;
p15kh:=40000*maxi/mini;
mini:=0; maxi:=0;
for i:=395061 to 435060 do begin if buf3a[i]>maxi then begin maxi:=buf3a[i]; maxf19:=i; end; mini+=buf3a[i]; end;
p19kh:=40000*maxi/mini;
if p50h>6 then wdata.quasi[0]:=maxf50*fft192;
if p100h>4 then wdata.quasi[1]:=maxf100*fft192;
if p15kh>4 then wdata.quasi[2]:=maxf15*fft192;
if p19kh>4 then wdata.quasi[3]:=maxf19*fft192;
s:='Quasistationary:  ';
if wdata.quasi[0]>0 then s:=s+floattostrf(wdata.quasi[0],fffixed,6,3)+' ';
if wdata.quasi[1]>0 then s:=s+floattostrf(wdata.quasi[1],fffixed,7,3)+' ';
if wdata.quasi[2]>0 then s:=s+floattostrf(wdata.quasi[2],fffixed,5,0)+' ';
if wdata.quasi[3]>0 then s:=s+floattostrf(wdata.quasi[3],fffixed,5,0)+' ';
if wdata.quasi[0]+wdata.quasi[1]+ wdata.quasi[1]+ wdata.quasi[3]=0 then s:=   'Quasistationary:  not found' else recommend:=recommend or 8;
fileparams.outtextxy(4,248,s,152);
fileparams.redrawclient;

//------------------------ now check wow amount


if wdata.quasi[0]<>0 then f:=1
else if wdata.quasi[1]<>0 then f:=2
else if wdata.quasi[2]<>0 then f:=3
else if wdata.quasi[3]<>0 then f:=4
else f:=0;
minw50:=50; maxw50:=50;
minw100:=100; maxw100:=100;
minw15k:=15625; maxw15k:=15625;
minw19k:=19000; maxw19k:=19000;
if (f<>0) then
  begin
  tempwin.cls;
  tempwin.outtextxy(20,20,'Determining wow amount...',170);
  tempwin.redrawclient;

  for kk:=0 to 15 do
    begin
    for i:=0 to 262143 do buf2[i]:=0.5*((w32p+kk*262144+2*i)^+(w32p+kk*262144+2*i+1)^)*sqr(sin(pi*i/262144));
    form1.fft7.fft;
    for i:=0 to 27307 do buf3a[i]+=sqrt(sqr(form1.fft7.transformeddata[i].real)+sqr(form1.fft7.transformeddata[i].imag));
    tempwin.box(364,20,40,16,256+176);
    tempwin.outtextxy(364,20, inttostr(round(100*(kk+1)/16))+' %',170);
    tempwin.redrawclient;
    application.processmessages;

    maxi:=0;
    for i:=61 to 75 do begin if buf3a[i]>maxi then begin maxi:=buf3a[i]; maxf50:=i;  end;   end;
    if (maxf50*0.732421875)<minw50 then minw50:=maxf50*0.73242187;
    if (maxf50*0.732421875)>maxw50 then maxw50:=maxf50*0.73242187;

    maxi:=0;
    for i:=123 to 150 do begin if buf3a[i]>maxi then begin maxi:=buf3a[i]; maxf100:=i; end;  end;
    if (maxf100*0.732421875)<minw100 then minw100:=maxf100*0.73242187;
    if (maxf100*0.732421875)>maxw100 then maxw100:=maxf100*0.73242187;


    maxi:=0;
    for i:=19968 to 22700 do begin if buf3a[i]>maxi then begin maxi:=buf3a[i]; maxf15:=i;  end;  end;
    if (maxf15*0.732421875)<minw15k then minw15k:=maxf15*0.73242187;
    if (maxf15*0.732421875)>maxw15k then maxw15k:=maxf15*0.73242187;

    maxi:=0;
    for i:=24576 to 27306 do begin if buf3a[i]>maxi then begin maxi:=buf3a[i]; maxf19:=i; end;   end;
    if (maxf19*0.732421875)<minw19k then minw19k:=maxf19*0.73242187;
    if (maxf19*0.732421875)>maxw19k then maxw19k:=maxf19*0.73242187;
    end;
  if f=4 then wowam:=(maxw19k/minw19k)-1;
  if f=3 then wowam:=(maxw15k/minw15k)-1;
  if f=2 then wowam:=(maxw100/minw100)-1;
  if f=1 then wowam:=(maxw50/minw50)-1;

  if wowam>0.01 then recommend:=recommend or 4;
  fileparams.outtextxy(360,216,'Wow amount: '+floattostrf(100*wowam,fffixed,6,2)+'%',232);
//  fileparams.outtextxy(360,232,floattostr(maxw50)+' '+floattostr(minw50),232);
  end;




p998:
hq:=(wdata.snr)-45+1/(wdata.pulse+0.2)+(60-wdata.low)/5+(wdata.high-16000)/1000 ;
recmq:=5-30*sqr(wdata.pulse-0.6)+25-sqr(wdata.snr-40)+(wdata.high-12000)/1000;
reclq:=10*wdata.pulse+25-sqr(wdata.high-10000)/20000000+25-sqr(wdata.snr-37);
recshell:=(10*wdata.pulse+5*(wdata.low-40)+25+10*(37-wdata.snr))/6;
taperec:=(1*wdata.pulse)*(8000-wdata.high);
taperadio:=(wdata.quasi[3]*(1-wdata.pulse))/100;
tapetv:=(wdata.quasi[2]*(1-wdata.pulse))/50;
tapelow:=(5000-wdata.high+((40-wdata.snr)*(40-wdata.snr)*(40-wdata.snr)))/(2000*wdata.pulse+8);
if (wdata.pulse>2) and (wdata.high>16000) and (wdata.snr>45) then begin wdata.pulse:=-wdata.pulse; fileparams.outtextxy(284,232,'Pulse count may be false positive',40); recommend:=recommend and %11111101; end;
          {
fileparams.outtextxy(548,68+4,'hq:       '+floattostr(hq),56);
fileparams.outtextxy(548,68+20,'recmq:    '+floattostr(recmq),72);
fileparams.outtextxy(548,68+36,'reclq:    '+floattostr(reclq),88);
fileparams.outtextxy(548,68+52,'recshell: '+floattostr(recshell),104);
fileparams.outtextxy(548,68+68,'taperadio:'+floattostr(taperadio),120);
fileparams.outtextxy(548,68+84,'tapetv:   '+floattostr(tapetv),136);
fileparams.outtextxy(548,68+100,'tapelow:  '+floattostr(tapelow),152);
fileparams.outtextxy(548,68+116,'taperec:  '+floattostr(taperec),152);
           }

kk:=8;
if (hq>recmq) and (hq>reclq) and (hq>recshell) and (hq>taperadio) and (hq>tapetv) and (hq>tapelow) and (hq>taperec)then begin wdata.medium:=0; wdata.source:=0; wdata.quality:=0; kk:=0; end;
if (recmq>hq) and (recmq>reclq) and (recmq>recshell) and (recmq>taperadio) and (recmq>tapetv) and (recmq>tapelow) and (recmq>taperec)then begin wdata.medium:=0; wdata.source:=0; wdata.quality:=1; kk:=1; end;
if (reclq>recmq) and (reclq>hq) and (reclq>recshell) and (reclq>taperadio) and (reclq>tapetv) and (reclq>tapelow) and (reclq>taperec)then begin wdata.medium:=0; wdata.source:=0; wdata.quality:=2; kk:=2;end;
if (recshell>recmq) and (recshell>reclq) and (recshell>hq) and (recshell>taperadio) and (recshell>tapetv) and (recshell>tapelow) and (recshell>taperec)then begin wdata.medium:=0; wdata.source:=3; wdata.quality:=0; kk:=3; end;
if (taperadio>recmq) and (taperadio>reclq) and (taperadio>recshell) and (taperadio>hq) and (taperadio>tapetv) and (taperadio>tapelow) and (taperadio>taperec)  then begin wdata.medium:=1; wdata.source:=1; wdata.quality:=1; kk:=4; end;
if (tapetv>recmq) and (tapetv>reclq) and (tapetv>recshell) and (tapetv>taperadio) and (tapetv>hq) and (tapetv>tapelow) and (tapetv>taperec) then begin wdata.medium:=1; wdata.source:=2; wdata.quality:=1; kk:=5; end;
if (tapelow>recmq) and (tapelow>reclq) and (tapelow>recshell) and (tapelow>taperadio) and (tapelow>tapetv) and (tapelow>hq) and (tapelow>taperec) then begin wdata.medium:=1; wdata.source:=3; wdata.quality:=1; kk:=6; end;
if (taperec>recmq) and (taperec>reclq) and (taperec>recshell) and (taperec>taperadio) and (taperec>tapetv) and (taperec>tapelow) and (taperec>hq) then begin wdata.medium:=1; wdata.source:=4; wdata.quality:=2; kk:=7; end;
if kk=0 then
  begin
  fileparams.outtextxy(648,8, 'Medium:  record',184);
  fileparams.outtextxy(648,24,'Quality: high',184);
  fileparams.outtextxy(648,40,'Source:  professional',184);
  end
else if kk=1 then
  begin
  fileparams.outtextxy(648,8, 'Medium:  record',184);
  fileparams.outtextxy(648,24,'Quality: medium',232);
  fileparams.outtextxy(648,40,'Source:  professional',184);
  end
else if kk=2 then
  begin
  fileparams.outtextxy(648,8, 'Medium:  record',184);
  fileparams.outtextxy(648,24,'Quality: low',24);
  fileparams.outtextxy(648,40,'Source:  professional',184);
  end
else if kk=3 then
  begin
  fileparams.outtextxy(648,8, 'Medium:  record',184);
  fileparams.outtextxy(648,24,'Quality: shellac',42);
  fileparams.outtextxy(648,40,'Source:  professional',184);
  end
else if kk=4 then
  begin
  fileparams.outtextxy(648,8, 'Medium:  tape',232);
  fileparams.outtextxy(648,24,'Quality: medium',232);
  fileparams.outtextxy(648,40,'Source:  radio',232);
  end
else if kk=5 then
  begin
  fileparams.outtextxy(648,8, 'Medium:  tape',232);
  fileparams.outtextxy(648,24,'Quality: medium',232);
  fileparams.outtextxy(648,40,'Source:  tv',24);
  end
else if kk=6 then
  begin
  fileparams.outtextxy(648,8, 'Medium:  tape',232);
  fileparams.outtextxy(648,24,'Quality: low',24);
  fileparams.outtextxy(648,40,'Source:  tape',42);
  end
else if kk=7 then
  begin
  fileparams.outtextxy(648,8, 'Medium:  tape',232);
  fileparams.outtextxy(648,24,'Quality: medium',232);
  fileparams.outtextxy(648,40,'Source:  record',188);
  end
else
  begin
  fileparams.outtextxy(648,8, 'Medium:  unknown',40);
  fileparams.outtextxy(648,24,'Quality: unknown',40);
  fileparams.outtextxy(648,40,'Source:  unknown',40);
  end ;

fileparams.outtextxy (648,72,'Recommended operations:',248);
i:=104;
box(230,876,160,160,161);
if recommend and 1 <>0 then begin fileparams.outtextxy(648,i,'Denoise',232); i+=16; outtextxy(230,876,'Recommended',199) end else outtextxy(230,876,'Not recommended',40);
if recommend and 2 <>0 then begin fileparams.outtextxy(648,i,'Declick',232); i+=16; outtextxy(230,911,'Recommended',199) end else outtextxy(230,911,'Not recommended',40);
if recommend and 4 <>0 then begin fileparams.outtextxy(648,i,'Wow reduction',232); i+=16; outtextxy(230,946,'Recommended',199) end else outtextxy(230,946,'Not recommended',40);
if recommend and 8 <>0 then begin fileparams.outtextxy(648,i,'HQ noise reduction',232); i+=16; outtextxy(230,981,'Recommended',199) end else outtextxy(230,981,'Not recommended',40);
if recommend and 16 <>0 then begin fileparams.outtextxy(648,i,'Sound enhance',232); i+=16; outtextxy(230,1016,'Recommended',199) end else outtextxy(230,1016,'Not recommended',40);
if recommend =0 then begin fileparams.outtextxy(648,i,'No restoration needed',184); i+=16; recommendedbutton.c1:=3; recommendedbutton.c2:=4; recommendedbutton.draw; end
  else begin recommendedbutton.c1:=180; recommendedbutton.c2:=232; recommendedbutton.draw; end;

waveform.redrawclient;
p999:
tempwin.destroy;
end;

procedure denoise;

var c,s:double;
    i,j,k,kk:integer;
    outfile:ffreqs1;
    buf2l:array[0..24575] of double;
    buf2r:array[0..24575] of double;
    tmprec:freqs1;
    oldresultsl,resultsl:array[0..109227] of freqs1;
    oldresultsr,resultsr:array[0..109227] of freqs1;
    time:integer;
    maxi,maxil,maxir:double;
    maxi2:integer;
    fiut:single;
    okno:array[0..9599] of double;
    outbuf,outbuf2,oldbuf,bufor3:array[0..19199] of single;
    tempbuf:array[0..9599] of single;
    fh,fh0,fh1,fh2,fh3,fh4,fh5,fh6,fh7,fh8,fh9,fh10:integer;
    fs0,fs1,fs2,fs3,fs4,fs5,fs6,fs7,fs8,fs9,fsample:TFloatsample;
    kkl,kkr,m2l,m2r,ll,rr:double;

const wsp1:double=20;
const wsp2:double=1.2;

label p999;

begin
if w32p=nil then goto p999;
for i:=0 to 9599 do okno[i]:=sqr(sin(pi*i/9600));
for i:=0 to 1048575 do buf2[i]:=0;
k:=0;
time:=0;

fh:=filecreate('d:\denoise1.raw');
tmprec.ampl:=0; tmprec.phs:=0; tmprec.freq:=0; tmprec.intfreq:=0;
tmprec.time:=0; tmprec.d2:=0; tmprec.d3:=0; tmprec.t:=0;
for i:=0 to 2047 do resultsl[i]:=tmprec;
resultsr:=resultsl;
repeat
  // left
  for i:=0 to 9599 do buf2[i]:=w32p[2*i+9600*k]*okno[i];
  form1.fft4.fft;
  for i:=0 to (109227 div 2) do
    begin
    tmprec.ampl:=sqrt(sqr(form1.fft4.transformeddata[i].real)+sqr(form1.fft4.transformeddata[i].imag))/2400;
    tmprec.phs:=arctan2(form1.fft4.transformeddata[i].real,form1.fft4.transformeddata[i].imag);
    tmprec.freq:=2*0.18310546875*i;
    if tmprec.freq<40 then tmprec.oct:=0
      else if tmprec.freq<80 then tmprec.oct:=1
      else if tmprec.freq<160 then tmprec.oct:=2
      else if tmprec.freq<320 then tmprec.oct:=3
      else if tmprec.freq<640 then tmprec.oct:=4
      else if tmprec.freq<1280 then tmprec.oct:=5
      else if tmprec.freq<2560 then tmprec.oct:=6
      else if tmprec.freq<5120 then tmprec.oct:=7
      else if tmprec.freq<10240 then tmprec.oct:=8
      else tmprec.oct:=9;
    tmprec.intfreq:=i;
    tmprec.time:=time;
    tmprec.d2:=1e-10;
    tmprec.d3:=1e-10;
    tmprec.t:=0;
    resultsl[i]:=tmprec;
    application.processmessages;
    end;

  // right
  for i:=0 to 9599 do buf2[i]:=w32p[2*i+1+9600*k]*okno[i];
  form1.fft4.fft;
  for i:=0 to (109227 div 2) do
    begin
    tmprec.ampl:=sqrt(sqr(form1.fft4.transformeddata[i].real)+sqr(form1.fft4.transformeddata[i].imag))/2400;
    tmprec.phs:=arctan2(form1.fft4.transformeddata[i].real,form1.fft4.transformeddata[i].imag);
    tmprec.freq:=2*0.18310546875*i;
    if tmprec.freq<40 then tmprec.oct:=0
      else if tmprec.freq<80 then tmprec.oct:=1
      else if tmprec.freq<160 then tmprec.oct:=2
      else if tmprec.freq<320 then tmprec.oct:=3
      else if tmprec.freq<640 then tmprec.oct:=4
      else if tmprec.freq<1280 then tmprec.oct:=5
      else if tmprec.freq<2560 then tmprec.oct:=6
      else if tmprec.freq<5120 then tmprec.oct:=7
      else if tmprec.freq<10240 then tmprec.oct:=8
      else tmprec.oct:=9;
    tmprec.intfreq:=i;
    tmprec.time:=time;
    tmprec.d2:=1e-10;
    tmprec.d3:=1e-10;
    tmprec.t:=0;
    resultsr[i]:=tmprec;
    application.processmessages;
    end;

  maxil:=0;
  for i:=40 to (109227 div 2) do if resultsl[i].ampl>maxil then begin maxil:=resultsl[i].ampl; end;
  maxir:=0;
  for i:=40 to (109227 div 2) do if resultsr[i].ampl>maxir then begin maxir:=resultsr[i].ampl; end;

  for j:=0 to 19199 do outbuf[j]:=0;
  for i:=40 to (109226 div 2)-1 do
    begin
    if (resultsl[i].ampl>resultsl[i-1].ampl) and (resultsl[i].ampl>resultsl[i+1].ampl) {and (resultsl[i].ampl>0.05*maxil)} and (resultsl[i].ampl>wsp1*noisefloor[resultsl[i].oct]) then
      begin
      for j:=0 to 9599 do outbuf[2*j]+=resultsl[i].ampl*sin(2*pi*j*resultsl[i].freq/192000+resultsl[i].phs);
      end ;
    end;

  for i:=40 to (109226 div 2)-1 do
    begin
    if (resultsr[i].ampl>resultsr[i-1].ampl) and (resultsr[i].ampl>resultsr[i+1].ampl) {and (resultsr[i].ampl>0.05*maxir)} and (resultsr[i].ampl>wsp1*noisefloor[resultsr[i].oct]) then
    begin
       for j:=0 to 9599 do outbuf[2*j+1]+=resultsr[i].ampl*sin(2*pi*j*resultsr[i].freq/192000+resultsr[i].phs);
      end ;
    end;
  for j:=0 to 9599 do outbuf[2*j]*=okno[j];
  for j:=0 to 9599 do outbuf[2*j+1]*=okno[j];
  if time=0 then filewrite(fh,outbuf,76800)
  else
    begin
    fileseek(fh,1536*time,fsfrombeginning);
    fileread(fh,tempbuf, 38400);
    fileseek(fh,1536*time,fsfrombeginning);
    for j:=0 to 9599 do outbuf[j]+=tempbuf[j];
    filewrite(fh,outbuf,76800);
    end;

  time+=25;
  box(1000,600,160,160,0);
  outtextxy(1008,608,'time='+inttostr(time),15);
  k+=1;
  application.processmessages;
until k*9600>2*samplenum;
c:=0;

fileclose(fh);

fh:=fileopen('d:\denoise1.raw',$40);
fh2:=filecreate('d:\denoise2.raw');
k:=0;
repeat
  fileread(fh,outbuf,76800);
  for i:=0 to 19199 do outbuf[i]:=w32p[i+19200*k]-outbuf[i];
  filewrite(fh2,outbuf,76800);
  k+=1;
until k*9600>samplenum;
fileclose(fh);
fileclose(fh2);



  fh:=fileopen('d:\denoise2.raw',$40);
  fh0:=filecreate('d:\out100.raw');
  fh1:=filecreate('d:\out101.raw');
  fh2:=filecreate('d:\out102.raw');
  fh3:=filecreate('d:\out103.raw');
  fh4:=filecreate('d:\out104.raw');
  fh5:=filecreate('d:\out105.raw');
  fh6:=filecreate('d:\out106.raw');
  fh7:=filecreate('d:\out107.raw');
  fh8:=filecreate('d:\out108.raw');
  fh9:=filecreate('d:\out109.raw');

  fs0:=cheby_oct0(fsample,1);
  fs1:=cheby_oct1(fsample,1);
  fs2:=cheby_oct2(fsample,1);
  fs3:=cheby_oct3(fsample,1);
  fs4:=cheby_oct4(fsample,1);
  fs5:=cheby_oct5(fsample,1);
  fs6:=cheby_oct6(fsample,1);
  fs7:=cheby_oct7(fsample,1);
  fs8:=cheby_oct8(fsample,1);
  fs9:=cheby_oct9(fsample,1);

  for i:=0 to 5 do begin

  il:=fileread(fh,fsample,8);

  fs0:=cheby_oct0(fsample,0);
  fs1:=cheby_oct1(fsample,0);
  fs2:=cheby_oct2(fsample,0);
  fs3:=cheby_oct3(fsample,0);
  fs4:=cheby_oct4(fsample,0);
  fs5:=cheby_oct5(fsample,0);
  fs6:=cheby_oct6(fsample,0);
  fs7:=cheby_oct7(fsample,0);
  fs8:=cheby_oct8(fsample,0);
  fs9:=cheby_oct9(fsample,0);
  end;


repeat
  il:=fileread(fh,fsample,8);

  fs0:=cheby_oct0(fsample,0);
  fs1:=cheby_oct1(fsample,0);
  fs2:=cheby_oct2(fsample,0);
  fs3:=cheby_oct3(fsample,0);
  fs4:=cheby_oct4(fsample,0);
  fs5:=cheby_oct5(fsample,0);
  fs6:=cheby_oct6(fsample,0);
  fs7:=cheby_oct7(fsample,0);
  fs8:=cheby_oct8(fsample,0);
  fs9:=cheby_oct9(fsample,0);

  filewrite(fh0,fs0,8);
  filewrite(fh1,fs1,8);
  filewrite(fh2,fs2,8);
  filewrite(fh3,fs3,8);
  filewrite(fh4,fs4,8);
  filewrite(fh5,fs5,8);
  filewrite(fh6,fs6,8);
  filewrite(fh7,fs7,8);
  filewrite(fh8,fs8,8);
  filewrite(fh9,fs9,8);


until il<>8;
fileclose(fh);
fileclose(fh0);
fileclose(fh1);
fileclose(fh2);
fileclose(fh3);
fileclose(fh4);
fileclose(fh5);
fileclose(fh6);
fileclose(fh7);
fileclose(fh8);
fileclose(fh9);

fh0:=fileopen('d:\out100.raw', $40);
fh1:=filecreate('d:\out200.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out101.raw', $40);
fh1:=filecreate('d:\out201.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out102.raw', $40);
fh1:=filecreate('d:\out202.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out103.raw', $40);
fh1:=filecreate('d:\out203.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out104.raw', $40);
fh1:=filecreate('d:\out204.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out105.raw', $40);
fh1:=filecreate('d:\out205.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out106.raw', $40);
fh1:=filecreate('d:\out206.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out107.raw', $40);
fh1:=filecreate('d:\out207.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out108.raw', $40);
fh1:=filecreate('d:\out208.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out109.raw', $40);
fh1:=filecreate('d:\out209.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh:=fileopen('d:\denoise1.raw',$40);
fh0:=fileopen('d:\out200.raw',$40);
fh1:=fileopen('d:\out201.raw',$40);
fh2:=fileopen('d:\out202.raw',$40);
fh3:=fileopen('d:\out203.raw',$40);
fh4:=fileopen('d:\out204.raw',$40);
fh5:=fileopen('d:\out205.raw',$40);
fh6:=fileopen('d:\out206.raw',$40);
fh7:=fileopen('d:\out207.raw',$40);
fh8:=fileopen('d:\out208.raw',$40);
fh9:=fileopen('d:\out209.raw',$40);
fh10:=filecreate('d:\output.raw');

repeat
//  for i:=0 to for i:=0 to 19199 do [i]:=0;
  il:=fileread(fh,outbuf,76800);
  fileread(fh0,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh1,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh2,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh3,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh4,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh5,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh6,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh7,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh8,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh9,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  filewrite(fh10,outbuf,76800);
until il<>76800;
fileclose(fh);
fileclose(fh0);
fileclose(fh1);
fileclose(fh2);
fileclose(fh3);
fileclose(fh4);
fileclose(fh5);
fileclose(fh6);
fileclose(fh7);
fileclose(fh8);
fileclose(fh9);
fileclose(fh10);

p999:
end;




procedure declick;

var c,s:double;
    i,j,k,kk:integer;
    outfile:ffreqs1;
    buf2l:array[0..24575] of double;
    buf2r:array[0..24575] of double;
    tmprec:freqs1;
    oldresultsl,resultsl:array[0..109227] of freqs1;
    oldresultsr,resultsr:array[0..109227] of freqs1;
    time:integer;
    maxi,maxil,maxir:double;
    maxi2:integer;
    fiut:single;
    okno:array[0..262143] of double;
    outbuf,outbuf2,oldbuf,bufor3:array[0..524287] of single;
    tempbuf:array[0..524287] of single;
    fh,fh0,fh1,fh2,fh3,fh4,fh5,fh6,fh7,fh8,fh9,fh10:integer;
    fs0,fs1,fs2,fs3,fs4,fs5,fs6,fs7,fs8,fs9,fsample:TFloatsample;
    phase:array[0..131071] of double;
    kkl,kkr,m2l,m2r,ll,rr:double;

const wsp1:double=4;
const wsp2:double=1.2;

label p999;

begin
for i:=0 to 16383 do phase[i]:=random*2*pi;
if w32p=nil then goto p999;
//for i:=0 to 262143 do okno[i]:=sqr(sin(pi*i/262144));
for i:=0 to 16384 do okno[i]:=sqr(sin(pi*i/16384));
for i:=0 to 65536 do buf2[i]:=0;
k:=0;
time:=0;
fh:=filecreate('d:\declick1.raw');
tmprec.ampl:=0; tmprec.phs:=0; tmprec.freq:=0; tmprec.intfreq:=0;
tmprec.time:=0; tmprec.d2:=0; tmprec.d3:=0; tmprec.t:=0;
for i:=0 to 2047 do resultsl[i]:=tmprec;
resultsr:=resultsl;
repeat
  // left

  for i:=0 to 16383 do buf2[i]:=w32p[2*i+16384*k];//*okno[i];
  for i:=0 to 16383 do bufimag[i]:=0;
  form1.fft2.fft;
  for i:=0 to 8191 do
    begin

    tmprec.ampl:=sqrt(sqr(form1.fft2.transformeddata[i].real)+sqr(form1.fft2.transformeddata[i].imag));
    tmprec.phs:=arctan2(form1.fft2.transformeddata[i].real,form1.fft2.transformeddata[i].imag)+phase[i]; //

    buf2[i]:=tmprec.ampl*cos(tmprec.phs);//form1.fft3.transformeddata[i].real;
    buf2[16384-i]:=buf2[i];

    bufimag[i]:=-1*tmprec.ampl*sin(tmprec.phs);//form1.fft3.transformeddata[i].imag;
    bufimag[16384-i]:=-bufimag[i];
    end;
  form1.fft2.ifft;
  for i:=0 to 16383 do outbuf[2*i]:=form1.fft2.transformeddata[i].real*okno[i];

// right

  for i:=0 to 16383 do buf2[i]:=w32p[2*i+1+16384*k];//*okno[i];
  for i:=0 to 16383 do bufimag[i]:=0;
  form1.fft2.fft;
  for i:=0 to 8191 do
    begin
    tmprec.ampl:=sqrt(sqr(form1.fft2.transformeddata[i].real)+sqr(form1.fft2.transformeddata[i].imag));
    tmprec.phs:=arctan2(form1.fft2.transformeddata[i].real,form1.fft2.transformeddata[i].imag)+phase[i];
    buf2[i]:=tmprec.ampl*cos(tmprec.phs); //form1.fft3.transformeddata[i].real;
    buf2[16384-i]:=buf2[i];
    bufimag[i]:=-1*tmprec.ampl*sin(tmprec.phs); //form1.fft3.transformeddata[i].imag;
    bufimag[16384-i]:=-bufimag[i];
    end;
  form1.fft2.ifft;
  for i:=0 to 16383 do outbuf[2*i+1]:=form1.fft2.transformeddata[i].real*okno[i];



  //  for i:=0 to 262143 do buf2[i]:=w32p[2*i+262144*k]*okno[i];
//    tmprec.ampl:=sqrt(sqr(form1.fft3.transformeddata[i].real)+sqr(form1.fft3.transformeddata[i].imag)); //32768;
//    tmprec.phs:=arctan2(form1.fft3.transformeddata[i].real,form1.fft3.transformeddata[i].imag);//+phase[i];
//    buf2[i]:=form1.fft3.transformeddata[i].real;//tmprec.ampl*cos(tmprec.phs);
//    buf2[131071-i]:=buf2[i];
//    bufimag[i]:=form1.fft3.transformeddata[i].real//tmprec.ampl*sin(tmprec.phs);
//    bufimag[131071-i]:=-bufimag[i];
//    end;
//  form1.fft3.ifft;
//  for j:=0 to 131071 do outbuf[2*j]:=form1.fft3.transformeddata[i].real*okno[i];//+=resultsl[i].ampl*sin(2*pi*j*resultsl[i].freq/192000+resultsl[i].phs+phase[i]);  inc(kk);

{
  for i:=0 to 32767 do
    begin
    tmprec.ampl:=sqrt(sqr(form1.fft3.transformeddata[i].real)+sqr(form1.fft3.transformeddata[i].imag))/32768;
    tmprec.phs:=arctan2(form1.fft3.transformeddata[i].real,form1.fft3.transformeddata[i].imag);

    tmprec.freq:=0.732421875*i*2;
 //       tmprec.phs+= phase[i];
      if tmprec.freq<40 then tmprec.oct:=0
      else if tmprec.freq<80 then tmprec.oct:=1
      else if tmprec.freq<160 then tmprec.oct:=2
      else if tmprec.freq<320 then tmprec.oct:=3
      else if tmprec.freq<640 then tmprec.oct:=4
      else if tmprec.freq<1280 then tmprec.oct:=5
      else if tmprec.freq<2560 then tmprec.oct:=6
      else if tmprec.freq<5120 then tmprec.oct:=7
      else if tmprec.freq<10240 then tmprec.oct:=8
      else tmprec.oct:=9;

    tmprec.intfreq:=i;
    tmprec.time:=time;
    tmprec.d2:=1e-10;
    tmprec.d3:=1e-10;
    tmprec.t:=0;
    resultsl[i]:=tmprec;
    application.processmessages;
    end;
}



  // right
//  for i:=0 to 131071 do buf2[i]:=w32p[2*i+1+131072*k]*okno[i];
//  for i:=0 to 131071 do bufimag[i]:=0;

//  form1.fft3.fft;

 //   for i:=0 to 131071 do
 //   begin
//    tmprec.ampl:=sqrt(sqr(form1.fft3.transformeddata[i].real)+sqr(form1.fft3.transformeddata[i].imag)); //32768;
//    tmprec.phs:=arctan2(form1.fft3.transformeddata[i].real,form1.fft3.transformeddata[i].imag);//+phase[i];
//    buf2[i]:=form1.fft3.transformeddata[i].real; //tmprec.ampl*cos(tmprec.phs);
//    buf2[131071-i]:=buf2[i];
//    bufimag[i]:=form1.fft3.transformeddata[i].imag;//tmprec.ampl*sin(tmprec.phs);
//    bufimag[131071-i]:=-bufimag[i];
//    end;
//  form1.fft3.ifft;
//  for j:=0 to 131071 do outbuf[2*j+1]:=form1.fft3.transformeddata[i].real*okno[i];
 {

  for i:=0 to 32767 do
    begin
    tmprec.ampl:=sqrt(sqr(form1.fft3.transformeddata[i].real)+sqr(form1.fft3.transformeddata[i].imag))/32768;
    tmprec.phs:=arctan2(form1.fft3.transformeddata[i].real,form1.fft3.transformeddata[i].imag);
    tmprec.freq:=0.732421875*i*2;
  //  tmprec.phs+=phase[i];
     if tmprec.freq<40 then tmprec.oct:=0
      else if tmprec.freq<80 then tmprec.oct:=1
      else if tmprec.freq<160 then tmprec.oct:=2
      else if tmprec.freq<320 then tmprec.oct:=3
      else if tmprec.freq<640 then tmprec.oct:=4
      else if tmprec.freq<1280 then tmprec.oct:=5
      else if tmprec.freq<2560 then tmprec.oct:=6
      else if tmprec.freq<5120 then tmprec.oct:=7
      else if tmprec.freq<10240 then tmprec.oct:=8
      else tmprec.oct:=9;

    tmprec.intfreq:=i;
    tmprec.time:=time;
    tmprec.d2:=1e-10;
    tmprec.d3:=1e-10;
    tmprec.t:=0;
    resultsr[i]:=tmprec;
    application.processmessages;
    end;
  }

  {
  maxil:=0;

  for i:=20 to 32766 do if resultsl[i].ampl>maxil then begin maxil:=resultsl[i].ampl; end;
  maxir:=0;

  for i:=20 to 32766 do if resultsr[i].ampl>maxir then begin maxir:=resultsr[i].ampl; end;

  for j:=0 to 524287 do outbuf[j]:=0;
  kk:=0;
  for i:=20 to  32766 do
    begin

     if (resultsl[i].ampl>resultsl[i-1].ampl) and (resultsl[i].ampl>resultsl[i+1].ampl) and (resultsl[i].ampl>0.0001{*maxil})  {and (resultsl[i].ampl>wsp1*noisefloor[resultsl[i].oct])} then
      begin
      for j:=0 to 131071 do outbuf[2*j]+=resultsl[i].ampl*sin(2*pi*j*resultsl[i].freq/192000+resultsl[i].phs+phase[i]);  inc(kk);
      end ;
    end;
  kk:=0;
  for i:=20 to 32766 do
    begin

    if (resultsr[i].ampl>resultsr[i-1].ampl) and (resultsr[i].ampl>resultsr[i+1].ampl) and (resultsr[i].ampl>0.0001{*maxir})  {and (resultsr[i].ampl>wsp1*noisefloor[resultsr[i].oct])} then
    begin
       for j:=0 to  131071 do outbuf[2*j+1]+=resultsr[i].ampl*sin(2*pi*j*resultsr[i].freq/192000+resultsr[i].phs+phase[i]);  inc(kk);
      end ;

    end;
  }
      box(500,500,100,50,0);
    outtextxyz(500,500,inttostr(kk),40,2,2);
//  for j:=0 to 131071 do outbuf[2*j]*=okno[j];
//  for j:=0 to 131071 do outbuf[2*j+1]*=okno[j];
  if time=0 then filewrite(fh,outbuf,2097152 div 16)
  else
    begin
    fileseek(fh,(1048576 div 16)*time,fsfrombeginning);
    fileread(fh,tempbuf, 1048576 div 16);
    fileseek(fh,(1048576 div 16)*time,fsfrombeginning);
    for j:=0 to 16383 do outbuf[j]+=tempbuf[j];
    filewrite(fh,outbuf,2097152 div 16);
    end;

  time+=1;
  box(1000,600,160,160,0);
  outtextxy(1008,608,'time='+inttostr(time),15);
  k+=1;
  application.processmessages;
until (k+2)*16384>=2*samplenum;
c:=0;

fileclose(fh);      {
fh:=fileopen('d:\denoise1.raw',$40);
fh2:=filecreate('d:\denoise2.raw');
k:=0;
repeat
  fileread(fh,outbuf,76800);
  for i:=0 to 19199 do outbuf[i]:=w32p[i+19200*k]-outbuf[i];
  filewrite(fh2,outbuf,76800);
  k+=1;
until k*9600>samplenum;
fileclose(fh);
fileclose(fh2);



  fh:=fileopen('d:\denoise2.raw',$40);
  fh0:=filecreate('d:\out100.raw');
  fh1:=filecreate('d:\out101.raw');
  fh2:=filecreate('d:\out102.raw');
  fh3:=filecreate('d:\out103.raw');
  fh4:=filecreate('d:\out104.raw');
  fh5:=filecreate('d:\out105.raw');
  fh6:=filecreate('d:\out106.raw');
  fh7:=filecreate('d:\out107.raw');
  fh8:=filecreate('d:\out108.raw');
  fh9:=filecreate('d:\out109.raw');

  fs0:=bessel_oct0(fsample,1);
  fs1:=bessel_oct1(fsample,1);
  fs2:=bessel_oct2(fsample,1);
  fs3:=bessel_oct3(fsample,1);
  fs4:=bessel_oct4(fsample,1);
  fs5:=bessel_oct5(fsample,1);
  fs6:=bessel_oct6(fsample,1);
  fs7:=bessel_oct7(fsample,1);
  fs8:=bessel_oct8(fsample,1);
  fs9:=bessel_oct9(fsample,1);

  il:=fileread(fh,fsample,8);

  fs0:=bessel_oct0(fsample,0);
  fs1:=bessel_oct1(fsample,0);
  fs2:=bessel_oct2(fsample,0);
  fs3:=bessel_oct3(fsample,0);
  fs4:=bessel_oct4(fsample,0);
  fs5:=bessel_oct5(fsample,0);
  fs6:=bessel_oct6(fsample,0);
  fs7:=bessel_oct7(fsample,0);
  fs8:=bessel_oct8(fsample,0);
  fs9:=bessel_oct9(fsample,0);

  il:=fileread(fh,fsample,8);

  fs0:=bessel_oct0(fsample,0);
  fs1:=bessel_oct1(fsample,0);
  fs2:=bessel_oct2(fsample,0);
  fs3:=bessel_oct3(fsample,0);
  fs4:=bessel_oct4(fsample,0);
  fs5:=bessel_oct5(fsample,0);
  fs6:=bessel_oct6(fsample,0);
  fs7:=bessel_oct7(fsample,0);
  fs8:=bessel_oct8(fsample,0);
  fs9:=bessel_oct9(fsample,0);

repeat
  il:=fileread(fh,fsample,8);

  fs0:=bessel_oct0(fsample,0);
  fs1:=bessel_oct1(fsample,0);
  fs2:=bessel_oct2(fsample,0);
  fs3:=bessel_oct3(fsample,0);
  fs4:=bessel_oct4(fsample,0);
  fs5:=bessel_oct5(fsample,0);
  fs6:=bessel_oct6(fsample,0);
  fs7:=bessel_oct7(fsample,0);
  fs8:=bessel_oct8(fsample,0);
  fs9:=bessel_oct9(fsample,0);

  filewrite(fh0,fs0,8);
  filewrite(fh1,fs1,8);
  filewrite(fh2,fs2,8);
  filewrite(fh3,fs3,8);
  filewrite(fh4,fs4,8);
  filewrite(fh5,fs5,8);
  filewrite(fh6,fs6,8);
  filewrite(fh7,fs7,8);
  filewrite(fh8,fs8,8);
  filewrite(fh9,fs9,8);


until il<>8;
fileclose(fh);
fileclose(fh0);
fileclose(fh1);
fileclose(fh2);
fileclose(fh3);
fileclose(fh4);
fileclose(fh5);
fileclose(fh6);
fileclose(fh7);
fileclose(fh8);
fileclose(fh9);

fh0:=fileopen('d:\out100.raw', $40);
fh1:=filecreate('d:\out200.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out101.raw', $40);
fh1:=filecreate('d:\out201.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out102.raw', $40);
fh1:=filecreate('d:\out202.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out103.raw', $40);
fh1:=filecreate('d:\out203.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out104.raw', $40);
fh1:=filecreate('d:\out204.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out105.raw', $40);
fh1:=filecreate('d:\out205.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out106.raw', $40);
fh1:=filecreate('d:\out206.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out107.raw', $40);
fh1:=filecreate('d:\out207.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out108.raw', $40);
fh1:=filecreate('d:\out208.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh0:=fileopen('d:\out109.raw', $40);
fh1:=filecreate('d:\out209.raw', $40);
for i:=0 to 19199 do outbuf2[i]:=0;
fileseek(fh0,minipos*8, fsfrombeginning);
ll:=0;
rr:=0;
for i:=0 to 95999 do
  begin
  fileread(fh0,fsample,8);
  ll+=sqr(fsample[0]);
  rr+=sqr(fsample[1]);
  end;
ll:=wsp2*sqrt(ll/96000);
rr:=wsp2*sqrt(rr/96000);
fileseek(fh0,0,fsfrombeginning);
repeat
  il:=fileread(fh0,outbuf,76800);
  fileseek(fh0,-38400,fsfromcurrent);
  m2l:=0;
  m2r:=0;
  for i:=0 to 9599 do m2l+=sqr(outbuf[2*i]);
  for i:=0 to 9599 do m2r+=sqr(outbuf[2*i+1]);
  m2l:=sqrt(m2l/9600);
  m2r:=sqrt(m2r/9600);
  if m2l>ll then kkl:=(m2l-ll)/m2l else kkl:=0;
  if m2r>rr then kkr:=(m2r-rr)/m2r else kkr:=0;
  oldbuf:=outbuf2;
  for i:=0 to 9599 do
    begin
    outbuf2[2*i]:=outbuf[2*i]*kkl*okno[i];
    outbuf2[2*i+1]:=outbuf[2*i+1]*kkr*okno[i];
    end;
  for i:=0 to 9599 do bufor3[i]:=outbuf2[i]+oldbuf[9600+i];
  filewrite(fh1,bufor3,38400);
  application.processmessages;
until il<>76800;
fileclose(fh0);
fileclose(fh1);

fh:=fileopen('d:\denoise1.raw',$40);
fh0:=fileopen('d:\out200.raw',$40);
fh1:=fileopen('d:\out201.raw',$40);
fh2:=fileopen('d:\out202.raw',$40);
fh3:=fileopen('d:\out203.raw',$40);
fh4:=fileopen('d:\out204.raw',$40);
fh5:=fileopen('d:\out205.raw',$40);
fh6:=fileopen('d:\out206.raw',$40);
fh7:=fileopen('d:\out207.raw',$40);
fh8:=fileopen('d:\out208.raw',$40);
fh9:=fileopen('d:\out209.raw',$40);
fh10:=filecreate('d:\output.raw');

repeat
//  for i:=0 to for i:=0 to 19199 do [i]:=0;
  il:=fileread(fh,outbuf,76800);
  fileread(fh0,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh1,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh2,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh3,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh4,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh5,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh6,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh7,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh8,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  fileread(fh9,outbuf2,76800);
  for i:=0 to 19199 do outbuf[i]+=outbuf2[i];
  filewrite(fh10,outbuf,76800);
until il<>76800;
fileclose(fh);
fileclose(fh0);
fileclose(fh1);
fileclose(fh2);
fileclose(fh3);
fileclose(fh4);
fileclose(fh5);
fileclose(fh6);
fileclose(fh7);
fileclose(fh8);
fileclose(fh9);
fileclose(fh10);
 }
p999:
end;


procedure denoise2;

var c,s:double;
    i,j,k,kk:integer;
    outfile:ffreqs1;
    buf2l:array[0..24575] of double;
    buf2r:array[0..24575] of double;
    tmprec:freqs1;
    oldresultsl,resultsl:array[0..2047] of freqs1;
    oldresultsr,resultsr:array[0..2047] of freqs1;
    time:integer;
    maxi,maxil,maxir:double;
    maxi2:integer;
    fiut:single;

label p999;

begin
if w32p=nil then goto p999;
k:=0;
time:=0;
assignfile(outfile,'d:\outfile.max');
rewrite(outfile);
tmprec.ampl:=0; tmprec.phs:=0; tmprec.freq:=0; tmprec.intfreq:=0;
tmprec.time:=0; tmprec.d2:=0; tmprec.d3:=0; tmprec.t:=0;
for i:=0 to 2047 do resultsl[i]:=tmprec;
resultsr:=resultsl;
repeat
  for i:=0 to 24575 do buf2l[i]:=w32p[2*i+24576*k];
  for i:=0 to 24575 do buf2r[i]:=w32p[2*i+24576*k+1];
  oldresultsl:=resultsl;
  oldresultsr:=resultsr;
  for i:=0 to 2047 do
    begin
    c:=0;
    s:=0;
    for j:=0 to 24575 do
      begin
      s+=buf2l[j]*testsignals[i,j];
      c+=buf2l[j]*testsignalc[i,j];
      end;
    tmprec.ampl:=sqrt(sqr(s) +sqr(c))/6144;
    tmprec.phs:=arctan2(c,s);
    tmprec.freq:=freqtable[i];
    if tmprec.freq<40 then tmprec.oct:=0
      else if tmprec.freq<80 then tmprec.oct:=1
      else if tmprec.freq<160 then tmprec.oct:=2
      else if tmprec.freq<320 then tmprec.oct:=3
      else if tmprec.freq<640 then tmprec.oct:=4
      else if tmprec.freq<1280 then tmprec.oct:=5
      else if tmprec.freq<2560 then tmprec.oct:=6
      else if tmprec.freq<5120 then tmprec.oct:=7
      else if tmprec.freq<10240 then tmprec.oct:=8
      else tmprec.oct:=9;
    tmprec.intfreq:=i;
    tmprec.time:=time;
    tmprec.d2:=1e-10;
    tmprec.d3:=1e-10;
    tmprec.t:=0;
    resultsl[i]:=tmprec;
    application.processmessages;

    c:=0;
    s:=0;
    for j:=0 to 24575 do
      begin
      s+=buf2r[j]*testsignals[i,j];
      c+=buf2r[j]*testsignalc[i,j];
      end;
    tmprec.ampl:=sqrt(sqr(s) +sqr(c))/6144;
    tmprec.phs:=arctan2(c,s);
    tmprec.freq:=freqtable[i];
    if tmprec.freq<40 then tmprec.oct:=0
      else if tmprec.freq<80 then tmprec.oct:=1
      else if tmprec.freq<160 then tmprec.oct:=2
      else if tmprec.freq<320 then tmprec.oct:=3
      else if tmprec.freq<640 then tmprec.oct:=4
      else if tmprec.freq<1280 then tmprec.oct:=5
      else if tmprec.freq<2560 then tmprec.oct:=6
      else if tmprec.freq<5120 then tmprec.oct:=7
      else if tmprec.freq<10240 then tmprec.oct:=8
      else tmprec.oct:=9;
    tmprec.intfreq:=i;
    tmprec.time:=time;
    tmprec.d2:=1e-10;
    tmprec.d3:=1e-10;
    tmprec.t:=0;
    resultsr[i]:=tmprec;
    application.processmessages;
    end;
//  tu mam wyniki. Trzeba teraz znaleźć maksima. Po jednym będzie za długo trwało. Spróbuję odnaleźć takie, że > 0.1 maksimum globalnego. Listki boczne sa niżej.

  maxil:=0;
  for i:=0 to 2047 do if resultsl[i].ampl>maxil then begin maxil:=resultsl[i].ampl; end;
  maxir:=0;
  for i:=0 to 2047 do if resultsr[i].ampl>maxir then begin maxir:=resultsr[i].ampl; end;


  for i:=1 to 2046 do
    begin
    if (resultsl[i].ampl>resultsl[i-1].ampl) and (resultsl[i].ampl>resultsl[i+1].ampl) and (resultsl[i].ampl>0.04*maxil) and (resultsl[i].ampl>100*noisefloor[resultsl[i].oct]) then
    begin
    write(outfile,resultsl[i]);
    end ;
  end;
  time+=64;
  box(1000,600,160,160,0);
  outtextxy(1008,608,'time='+inttostr(time),15);
  k+=1;
  application.processmessages;
until k*24576>2*samplenum;
c:=0;
repeat c+=20.8333333333; line(round(c),300,0,576,34); until c>1792;
closefile(outfile);
p999:
end;



// ---------------THE BIG MESS !! ----------------------------------------------


function sampletimetostr(a:integer):string;

var px:double;
    i,h,m,s:integer;
    ss,ms,hs,ts,sss:string;

begin
px:=a/192;
for i:=0 to 10 do
  begin
  h:=trunc(px/3600000);
  m:=trunc(px/60000) mod 60;
  s:=trunc(px/1000) mod 60;
  t:=trunc(px) mod 1000;
  ts:=inttostr(t);
  if t<100 then ts:='0'+ts;
  if t<10 then ts:='0'+ts;
  ss:=inttostr(s);
  if s<10 then ss:='0'+ss;
  ms:=inttostr(m);
  if m<10 then ms:='0'+ms;
  hs:=inttostr(h);
  sss:=ts;
  sss:=ss+'.'+sss ;
  sss:=ms+':'+sss;
  sss:=hs+':'+sss;
  end;
result:=sss;
end;

procedure widespectrum(filename:string; start,zakres,c:integer;overwrite:boolean);


var fh:integer;


    maxf50,maxf100,maxf15,maxf19, numsfs:integer;
    i,j,kk:integer;
    buf3:array[0..873815] of double;
    p50h,p100h,p15kh,p19kh:double;

begin
for i:=0 to 873814 do buf3[i]:=0;
numsfs:=samplenum div 4194304;
if numsfs=0 then numsfs:=1;
box(1200,100,100,16,146); outtextxy(1200,100,inttostr(numsfs),106);
for kk:=0 to numsfs*2-1 do
  begin
// get samples                                                         //1092 - 50 Hz
  //2184 - 100 Hz
  //
  for i:=0 to 4194303 do                                         ///341333     415061
    begin
    buf2[i]:=(w32p+4194304*kk+2*i)^*sqr(sin(2*pi*i/524288));
    end;
   form1.fft5.fft;
   for i:=0 to 873814 do buf3[i]+=sqrt(sqr(form1.fft5.transformeddata[i].real)+sqr(form1.fft5.transformeddata[i].imag));
   box(1200,120,100,16,146); outtextxy(1200,120,inttostr(kk),106); application.processmessages;
  end;
for i:=0 to 873814 do buf3[i]/=(numsfs*2);
for i:=0 to 873814 do buf3[i]/=1048576;
mini:=0; maxi:=0;
for i:=1042 to 1141 do begin if buf3[i]>maxi then begin maxi:=buf3[i]; maxf50:=i; end; mini+=buf3[i]; end;
p50h:=100*maxi/mini;
mini:=0; maxi:=0;
for i:=2084 to 2283 do begin if buf3[i]>maxi then begin maxi:=buf3[i]; maxf100:=i; end; mini+=buf3[i]; end;
p100h:=200*maxi/mini;
mini:=0; maxi:=0;
for i:=331333 to 351332 do begin if buf3[i]>maxi then begin maxi:=buf3[i]; maxf15:=i; end; mini+=buf3[i]; end;
p15kh:=20000*maxi/mini;
mini:=0; maxi:=0;
for i:=395061 to 435060 do begin if buf3[i]>maxi then begin maxi:=buf3[i]; maxf19:=i; end; mini+=buf3[i]; end;
p19kh:=40000*maxi/mini;


blit($F000000,0,0,$F800000,0,0,1792,1120,1792,1792);
box(0,0,1792,1120,15);
outtextxyz(8,8,'Please wait, calculating...',0,2,2);
poke($60028,0);

maxi:=0;
for i:=0 to 873814 do if buf3[i]>maxi then maxi:=buf3[i];
freq:=20;
oldfreq:=20;
for i:=1 to 1536 do
  begin
  oldfreq:=freq;
  freq:=freq*scaler;
  dfreq:=(freq-oldfreq)/2;
  fftpos:=round(freq/fft192);
  fftpos1:=round((freq-dfreq)/fft192);
  fftpos2:=round((freq+dfreq)/fft192);
  fftval:=0;
//  for j:=fftpos1 to fftpos2 do fftval+=fftbuf[fftpos];
 for j:=fftpos1 to fftpos2 do if buf3[j]>fftval then fftval:=buf3[j];
//  fftval/=(fftpos2-fftpos1+1);
//  fftval:=0.01;
if fftval=0 then fftval:=0.001;
  fftbuf2[i]:=20*log10(fftval);
  end;

mini:=99e99;
maxi:=-99e99;
for i:=1 to 1536 do if fftbuf2[i]<mini then mini:=fftbuf2[i];
for i:=1 to 1536 do if fftbuf2[i]>maxi then maxi:=fftbuf2[i];
z1:=round(maxi-mini);//+6;
s1:=round(mini);
if start=0 then start:=s1 else start:=-start;
if zakres=0 then zakres:=z1;
if overwrite and (peek($81000)>0) then start:=-peek($81000);
if overwrite and (peek($81001)>0) then zakres:=peek($81001);

if not overwrite or (peek($81002)=0) then uklad(start,zakres) else blit($E000000,0,0,$f000000,0,0,1792,1120,1792,1792);
// for i:=1 to 768 do line2(192+2*i,10,193+2*i+1,500,40  );

for i:=1 to 1534 do
uplot(start,zakres,i,fftbuf2[i],fftbuf2[i+1],c);
u2(start,zakres);
fh:=filecreate(wsfn+'_fftw.bmp');
for i:=0 to 53 do
  begin
  b:=peek($80000+i);
  filewrite(fh,b,1);
  end;
k:=0;
for i:=1119 downto 0 do
  for j:=0 to 1791 do
   begin
   idx:=dpeek($F000000+2*(1792*i+j));
   bmpi:=lpeek($10000+4*idx);
   bmpbuf[k]:=bmpp;
   k+=1;
   end;
filewrite(fh,bmpbuf,6021120);
fileclose (fh);
fh:=-1;
box(200,40,300,80,15);
outtextxy(200,40,'50 Hz '+floattostr(p50h)+ ' '+floattostr(maxf50*fft192),99);
outtextxy(200,60,'100 Hz '+floattostr(p100h)+ ' '+floattostr(maxf100*fft192),99);
outtextxy(200,80,'15 kHz '+floattostr(p15kh)+ ' '+floattostr(maxf15*fft192),99);
outtextxy(200,100,'19 kHz '+floattostr(p19kh)+ ' '+floattostr(maxf19*fft192),99);

outtextxyz(16,1080,'(Ready - Press any key or mouse button to return)',0,2,2);
repeat application.processmessages until (peek($60028)<>0) or (peek($60030)<>0);
poke($60028,0);
poke($60030,0);
poke($81000,-start);
poke($81001,zakres);
poke($81002,1);
blit($F000000,0,0,$E000000,0,0,1792,1120,1792,1792);
blit($F800000,0,0,$F000000,0,0,1792,1120,1792,1792);


end;




procedure harmsynth;

begin
end;


procedure anal2;


var c,s:double;
    i,j,k,kk:integer;
    outfile:ffreqs1;
    buf2:array[0..24575] of double;
    tmprec:freqs1;
    results:array[0..2047] of freqs1;
    time:integer;
    maxi:double;
    maxi2:integer;


begin

k:=0;
time:=0;
assignfile(outfile,'d:\outfile.max');
rewrite(outfile);
repeat
  for i:=0 to 24575 do buf2[i]:=w32p[2*i+24576*k];
  for i:=0 to 2047 do
    begin
    c:=0;
    s:=0;
    for j:=0 to 24575 do
      begin
      s+=buf2[j]*testsignals[i,j];
      c+=buf2[j]*testsignalc[i,j];
      end;
    tmprec.ampl:=sqrt(sqr(s) +sqr(c))/6144;
    tmprec.phs:=arctan2(c,s);
    tmprec.freq:=freqtable[i];
    tmprec.intfreq:=i;
    tmprec.time:=time;
    tmprec.d2:=1e-10;
    tmprec.d3:=1e-10;
    tmprec.t:=0;
    results[i]:=tmprec;
 //   if (i>796) and (i< 1180) then putpixel(time div 64,1480-i,round(256*tmprec.ampl));
    application.processmessages;
    end;

  box(1000,600,160,160,0);
  for kk:=1 to 7 do
    begin
    maxi:=0; maxi2:=0;
    // find the maximum
    for i:=0 to 2047 do if (results[i].ampl>maxi) and (results[i].t=0) then begin maxi:=results[i].ampl; results[i].t:=kk; maxi2:=i; end;
    if maxi2>0 then
      begin
      i:=maxi2+1; repeat results[i].t:=-1; i+=1; until (i>2046) or (results[i].ampl>results[i-1].ampl);
      i:=maxi2-1; repeat results[i].t:=-1; i-=1; until (i<1) or (results[i].ampl>results[i+1].ampl);        //avoid finding the same maximum more times
      if maxi2+192<2040 then results[maxi2].d2:=results[maxi2+192].ampl/results[maxi2].ampl;     //2nd harmonics coefficient
      if maxi2+305<2040 then results[maxi2].d3:=(0.69*results[maxi2+304].ampl+0.31*results[maxi2+305].ampl)/results[maxi2].ampl ;  //3rd harmonics coefficient
      for i:=maxi2+187 to maxi2+199 do if i<2048 then results[i].t:=256+kk;   //2nd harmonics
      for i:=maxi2-199 to maxi2-187 do if i>0 then results[i].t:=256+kk;   //2nd subharm
      for i:=maxi2-312 to maxi2-296 do if i>0 then results[i].t:=256+kk;   //3rd subharm
      for i:=maxi2+296 to maxi2+312 do if i<2048 then results[i].t:=256+kk;   //3rd subharm
      for i:=4 to 50 do
        begin
        if i mod 2=0 then
          begin
          if (harmonics[i]+maxi2<2047) and (harmonics[i]+maxi2>=1600) then
            begin
            results[harmonics[i]+maxi2].ampl:=results[maxi2].ampl*results[maxi2].d2/i;
            results[harmonics[i]+maxi2].phs:=results[maxi2].phs*i;
            end;
          end
        else
          begin
          if (harmonics[i]+maxi2<2047) and (harmonics[i]+maxi2>=1600)  then
            begin
            results[harmonics[i]+maxi2].ampl:=results[maxi2].ampl*results[maxi2].d3/i;
            results[harmonics[i]+maxi2].phs:=results[maxi2].phs*i;
            end;
          end;
        end;

      end;
 //debug

    end;



//  for j:=2 to 50 do if maxi2+harmonics[i]
  for i:=1 to 2046 do if (results[i].ampl>results[i-1].ampl) and (results[i].ampl>results[i+1].ampl) then
    begin
{    putpixel(time div 64,1480-i,0);
    if (i>604) and (i< 1180) and (results[i].t>0) and (results[i].t<16) then putpixel(time div 64,1480-i,15);
    if (((i-604) mod 16)=0) and (i>604) and (i< 1180) and (results[i].t>0) and (results[i].t<16) then putpixel(time div 64,1480-i,44);
}    write(outfile,results[i]);
    end
  else
    begin
{    if (i>604) and (i< 1180) then putpixel(time div 64,1480-i,0);
    if (((i-604) mod 16)=0) and (i>604) and (i< 1180) then putpixel(time div 64,1480-i,34);
}   end;

  time+=64;
  box(1000,600,160,160,0);
  outtextxy(1008,608,'time='+inttostr(time),15);
  k+=1;
  application.processmessages;
until k*24576>2*samplenum;
c:=0;
repeat c+=20.8333333333; line(round(c),300,0,576,34); until c>1792;
closefile(outfile);
end;

procedure synt1;

label p999,p998;


var maxi,start,i,fh:integer;
    temprec:freqs1;
    infile1:ffreqs1;
    ss,cc:array[0..10] of double;
    sq:double;

const magic64:int64=$3837363534333231;

begin
fh:=filecreate('d:\output.raw');
assignfile(infile1,'d:\outfile.max');
reset(infile1);
for i:=0 to 50000000 do ffilebuf[i]:=0;
maxi:=0;
repeat
  read(infile1,temprec);
// if (temprec.freq<438) or (temprec.freq>442) then goto p998;;
  start:=192*temprec.time;
//  delay
  if maxi<start+9600 then maxi:=start+9600;
  for i:=0 to 9599 do
     ffilebuf[i+start]+=temprec.ampl*sin(2*pi*i*temprec.freq/192000+temprec.phs)*sqr(sin(pi*i/9600));

  application.processmessages ;
  if (temprec.freq<200)  then
    begin
    box(1000,600,640,64,0);
    outtextxy(1008,608,'time='+inttostr(maxi),15);
    end;

p998:
until eof(infile1) or (maxi>50000000);
close(infile1);
for i:=0 to maxi do sfilebuf[i]:=ffilebuf[i];
filewrite(fh,sfilebuf,4*maxi);
fileclose(fh);
end;



procedure synt1a;

label p999,p998;


var maxi,start,i,fh:integer;
    temprec:freqs1;
    infile1:ffreqs1;
    ss,cc:array[0..10] of double;
    sq:double;

const magic64:int64=$3837363534333231;

begin
fh:=filecreate('d:\output.raw');
assignfile(infile1,'d:\outfile.max');
reset(infile1);
for i:=0 to 50000000 do ffilebuf[i]:=0;
maxi:=0;
repeat
  read(infile1,temprec);
//  if (temprec.intfreq<988) or (temprec.intfreq>989) then goto p998;;
  start:=192*temprec.time;
  for j:=1 to 10 do ss[j]:=sin(j*temprec.phs);
  for j:=1 to 10 do cc[j]:=cos(j*temprec.phs);
//  delay
  if maxi<start+24576 then maxi:=start+24576;
  for i:=0 to 24575 do
    begin
        ffilebuf[i+start]+=cc[1]*temprec.ampl*testsignals[temprec.intfreq,i];
        ffilebuf[i+start]+=ss[1]*temprec.ampl*testsignalc[temprec.intfreq,i];



    end;

  application.processmessages ;
  if (temprec.freq<200)  then
    begin
    box(1000,600,640,64,0);
    outtextxy(1008,608,'time='+inttostr(maxi),15);
    end;

p998:
until eof(infile1) or (maxi>50000000);
close(infile1);
for i:=0 to maxi do sfilebuf[i]:=ffilebuf[i];
filewrite(fh,sfilebuf,4*maxi);
fileclose(fh);
end;



procedure getmax;

var infile1,infile2,infile3,outfile:ffreqs1;
    freqs:array[0..3788] of freqs1;
    minis:array[0..3788] of double;
    skl,i,time,fh:integer;
    temprec:freqs1;

//1536 1229 984

begin


assignfile(infile1,'d:\outfile.low');
assignfile(infile2,'d:\outfile.med');
assignfile(infile3,'d:\outfile.hi');
assignfile(outfile,'d:\outfile.max');

fh:=fileopen('d:\outfile.min',$40);
fileread(fh,minis,3789*8);
fileclose(fh);
reset(infile1);
reset(infile2);
reset(infile3);
rewrite(outfile);
time:=0;

repeat
  if (time mod 64) = 0 then
    for i:=0 to 993 do
    begin
    if not eof(infile1) then begin
      read(infile1,temprec);
      freqs[i]:=temprec;
      end;
    end;

  if (time mod 8) = 0 then
    for i:=994 to 2242 do
    begin
    if not eof(infile2) then begin
      read(infile2,temprec);
      freqs[i]:=temprec;
      end;
    end;

  for i:=2243 to 3788 do

    begin
    if not eof(infile3) then begin
      read(infile3,temprec);
      freqs[i]:=temprec;
      end;
    end;

// get noise floor
  for i:=0 to 3788 do freqs[i].time:=time;

  skl:=0;
  for i:=1 to 3787 do if (freqs[i].ampl>freqs[i-1].ampl) and (freqs[i].ampl>freqs[i+1].ampl) and (freqs[i].ampl>minis[i]*1.1) then
    begin
    skl+=1;
    if (i<984) and ((time mod 64)=0) then write(outfile,freqs[i])
    else if (i>1004) and (i<2233) and  ((time mod 8)=0) then write(outfile,freqs[i])
    else if (i>2252) then write(outfile,freqs[i]);
    end;
  time+=1;
  application.processmessages ;
  if (time mod 64)=0  then begin
    box(1000,600,640,64,0);
    outtextxy(1008,608,'time='+inttostr(time),15);
    outtextxy(1008,630,'skl='+inttostr(skl),15);
    end;
  until eof(infile1) and eof(infile2) and eof(infile3);
closefile(infile1);
closefile(infile2);
closefile(infile3);
closefile(outfile);

end;


procedure haar(f:string);

//2048 spls; 2048-1024-512-256-128-64-32-16-8-4-2-1


var h:double;
    kk,x,y,c,fh,il,i,j,k,l,m,n:integer;
    intfreq:integer;
    outfile:fhaars1;
    buf1:array[0..32767] of single;
    tmprec:haars1;
    time:integer;
    message:cwindow;
    haars:array[0..14] of double;
    colors:array[0..14,0..1750] of integer;
    wavebuf:array[0..4095] of double;
    wb:boolean;
    m1,m2:double;
    tabl:array[0..5,0..8191] of integer;
    tabl2,tabl3,tabl4:array[0..8191] of double;
    hrecords:array[0..16383] of haars1;
    pulsecount:integer;
    tabl5:array[0..7] of double;

begin

pulsecount:=0;
for i:=0 to 14 do for j:=0 to 1750 do colors[i,j]:=0;
time:=0;
fh:=fileopen(f,$40);
message:=cwindow.create(700,550,400,100,200,100,196,192,'Computing Haar transform');
wb:=false;
repeat
  m1:=0;
  fileseek(fh,44+8*time,fsfrombeginning);
  il:=fileread(fh,buf1,4*32768);
  for i:=0 to 16383 do
    begin
    buf1[i]:=0.5*buf1[2*i]+0.5*buf1[2*i+1];
    if buf1[i]>m1 then m1:=buf1[i];
    end;
  kk:=0;
  // do a haar! ------------

  h:=0;
  for i:=0 to 16383 do h+=buf1[i]; // średnia całości, haar[0]
  h*=2;//h/=16384;
  tmprec.freq:=-1;
  tmprec.ampl:=h;
  tmprec.time:=time;
  hrecords[kk]:=tmprec;
  kk+=1;

  h:=0;
  for i:=0 to 8191 do h+=buf1[i]; // średnia połowy, haar[1]:=h1024-haar[0]
  for i:=8192 to 16383 do h-=buf1[i];
  h*=2;//h/=16384;
  tmprec.freq:=0;
  tmprec.ampl:=h;
  tmprec.time:=time;
  hrecords[kk]:=tmprec;
  kk+=1;


  for k:=1 to 13 do

    begin
    l:=(1 shl k)-1; // 1,3,7,15,31,63,127,255,511,1023
    m:=(8192 shr k)-1; // 511,255,127,63,31,15,7,3,1,0
    n:=(16384 shr k); // 1024,512,256,128,64,3
    for j:=0 to l do    //1,3,7,15,31.
      begin
      h:=0;
      for i:=0 to m do h+=buf1[i+n*j]; //2 wsp. @512,
      for i:=m+1 to n-1 do h-=buf1[i+n*j];
      h*=32768;
      h/=(16384 shr k);
      tmprec.freq:=k;
      tmprec.ampl:=h;
      tmprec.time:=time+j*(16384 shr k);
      hrecords[kk]:=tmprec;
      kk+=1;
      end;
    end;

// ----------------------- haaaaar

  time+=16384;
  message.checkmouse;
  poke($60030,0);
  message.cls;
  message.outtextxyz(8,12,'time='+floattostr(time/192000),205,2,2);
  message.redrawclient;
  application.processmessages;

// now one 16384 samples chunk processed

  for kk:=0 to 16383 do
    begin
    tmprec:=hrecords[kk];
    h:=tmprec.ampl;
    if abs(tmprec.ampl)>10 then
      c:={16*tmprec.freq+16+}1+round(4*(log10(abs(tmprec.ampl/10))))
    else
      c:=1;

    x:=(tmprec.time mod 16384) div 2;
    if tmprec.freq=13 then tabl[5,x]:=c
    else if tmprec.freq=12 then for i:=x to x+1 do tabl[4,i]:=c
    else if tmprec.freq=11 then for i:=x to x+3 do tabl[3,i]:=c
    else if tmprec.freq=10 then for i:=x to x+7 do tabl[2,i]:=c
    else if tmprec.freq=9 then for i:=x to x+15 do tabl[1,i]:=c
    else if tmprec.freq=8 then for i:=x to x+31 do tabl[0,i]:=c;
    end;
  for i:=0 to 8191 do tabl2[i]:=1;
  for i:=0 to 8191 do tabl4[i]:=0;
  for i:=0 to 8191 do tabl3[i]:=0;

  for i:=0 to 8191 do for j:=0 to 5 do tabl2[i]*=tabl[j,i];
  m2:=0;
  for i:=0 to 8191 do if tabl2[i]>m2 then m2:=tabl2[i];
 // for i:=0 to 8191 do tabl2[i]:=tabl2[i]/m2;
  for i:=0 to 7 do begin m2:=0; for j:=0 to 1023 do m2+=tabl2[j+1024*i]; tabl5[i]:=m2/1024; end;
//  m2:=0; for i:=0 to 8191 do m2+=tabl2[i]; m2/=8192;
  for i:=8176 downto 16 do begin for j:=-16 to 15 do tabl3[i]+=tabl2[i+j]; tabl3[i]/=32; end;
  for i:=8177 to 8191 do tabl3[i]:=tabl3[8176];
  for i:=0 to 15 do tabl3[i]:=tabl3[16];
  for i:=0 to 8191 do if (tabl2[i]>600000*maxvalue) and (tabl2[i]>17*tabl5[i div 1024]) then begin tabl4[i]:=1; pulsecount+=1;    end;
//if time=16384 then begin
//  for i:=0 to 8191 do
//    begin
//    putpixel(i div 4,round(900-200*tabl2[i]),40);
//    putpixel(i div 4,round(900-200*tabl3[i]),120);
//    putpixel(i div 4,round(900-100*tabl5[i div 1024]),200);
//    putpixel(i div 4,round(900-200*tabl4[i]),15);
//    end;

//  end;


until il<131072;


message.cls;
message.outtextxyz(32,12,'Ready. Pulse count '+floattostr(192000*pulsecount/time),205,1,1);
message.redrawclient;
repeat message.checkmouse; poke($60030,0); wait(1000) until peek($60028)<>0;
poke($60028,0);
message.destroy;
fileclose(fh);
end;

procedure convertmonotostereo(from:Psmallint;too:Psample;il:integer);

var i:integer;

begin
for i:=0 to il do begin (too+i)^[0]:=(from+i)^;  (too+i)^[1]:=(from+i)^;   end;
end;

procedure convertmonotostereof(from:Psingle;too:Pfloatsample;il:integer);

var i:integer;

begin
for i:=0 to il do begin (too+i)^[0]:=(from+i)^;  (too+i)^[1]:=(from+i)^;   end;
end;

procedure convertpcmtofloat(from:Psample; too:PFloatsample;il:integer);


var i:integer;

begin
for i:=0 to il do (too+i)^:=(from+i)^;
end;


  procedure antialias(from:Pfloatsample;too:Pfloatsample;il:integer);
 var i:integer;

 begin
 cheby_lp_20k_192k(zerofsample,1);
 for i:=0 to 9 do cheby_lp_20k_192k((from+i)^,0);
 for i:=10 to il do begin (too+i-10)^:=cheby_lp_20k_192k((from+i)^,0);  end;
 end;

function resample44to192(from,too:Pfloatsample;il:int64):int64;

//1 insert 63 zeros
//2 feed 64 spls to cheby 3
//3 interpolate with step=14.7

const zerofsample:TFloatsample=(0,0);


var i,j,k:integer;
    q1,l:double;
    buf1,buf2,buf3:array[0..63] of TFloatsample;
    q3,q2,q,a1,a2:TFloatsample;

begin

//form1.progressbar1.position:=0;
for i:=0 to il+192000 {4194303} do (too+i)^:=zerofsample;
i:=0;
k:=0;
l:=0;
repeat
  buf3:=buf2;
  buf1[0]:=(from+i)^*64;
  for j:=1 to 63 do buf1[j]:=zerofsample;
  for j:=0 to 63 do buf2[j]:=cheby3(buf1[j],0);

  repeat
    if l<0 then
      begin
      a1:=buf3[63];
      a2:=buf2[0];
      end
    else
      begin
      a1:=buf2[trunc(l)];
      a2:=buf2[trunc(l)+1];
      end;
    q1:=frac(l+2);
    q:=a2*q1+a1*(1-q1);
    q2:=cheby_lp_20k_192k(q,0);
    q3:=cheby_highpass_4000(cheby_highpass_1200_2(cheby_highpass_1200(q2,0),0),0);     //nonlinear






    (too+k)^:=q2+q3;
    k+=1;
    l+=14.7;
  until l>=63;
  l-=64;
  i+=1;
if (i div 1000) mod 10 = 0 then
  begin
  tempwin.box(20,28,50,16,176);
  tempwin.outtextxy(20,28,inttostr(round(100*i/il))+'%',170);
  tempwin.redrawclient;
  application.processmessages;
  end;
until i>il;
tempwin.box(20,28,50,16,176);
tempwin.outtextxy(20,28,'100%',170);
application.processmessages;
result:=k;
end;

function resample96to192(from,too:Pfloatsample;il:int64):int64;

//1 insert 63 zeros
//2 feed 64 spls to cheby 3
//3 interpolate with step=14.7

const zerofsample:TFloatsample=(0,0);


var i,j,k:int64;
    q1,l:double;
    buf1,buf2,buf3:array[0..63] of TFloatsample;
    q3,q2,q,a1,a2:TFloatsample;

begin
for i:=0 to il do (too+i)^:=zerofsample;
i:=0;
k:=0;
l:=0;
repeat
  buf3:=buf2;
  buf1[0]:=(from+i)^*64;
  for j:=0 to 31 do buf1[2*j+1]:=zerofsample;
  for j:=0 to 31 do begin buf1[2*j]:=(from+i)^*2; i+=1; end;
  for j:=0 to 63 do begin (too+k)^:=cheby_lp_20k_192k(buf1[j],0); k+=1; end;
  if (i div 1000) mod 10 = 0 then
    begin
    tempwin.box(20,28,50,16,176);
    tempwin.outtextxy(20,28,inttostr(round(100*i/il))+'%',170);
    tempwin.redrawclient;
    application.processmessages;
    end;
until i>il;
tempwin.box(20,28,50,16,176);
tempwin.outtextxy(20,28,'100%',170);
application.processmessages;
result:=k;
end;

function enhance(from:Pfloatsample;il:int64):int64;

//1 insert 63 zeros
//2 feed 64 spls to cheby 3
//3 interpolate with step=14.7

const zerofsample:TFloatsample=(0,0);


var i,j,k:integer;
    l:double;
    buf1,buf2,buf3:array[0..63] of TFloatsample;
    q1,q3,q2,q,a1,a2:TFloatsample;
    tempwin:cwindow;
begin

//form1.progressbar1.position:=0;

i:=0;
k:=0;
l:=0;

tempwin:=cwindow.create(500,500,800,100,800,100,256+176,256+177,'Message');
repeat
  q1:=(from+i)^;
  q3:=cheby_highpass_4000(cheby_highpass_1200_2(cheby_highpass_1200(q1,0),0),0);          // orig. cheby_highpass_4000
  q2:=q1+q3;
  (from+i)^:=q2;
  if (i div 1000) mod 10 = 0 then
    begin
    tempwin.box(20,28,50,16,176);
    tempwin.outtextxy(20,28,inttostr(round(100*i/il))+'%',170);
    tempwin.redrawclient;
    application.processmessages;
    end;
  inc(i);
until i>il;
//antialias(from, from, il);
tempwin.box(20,28,50,16,176);
tempwin.outtextxy(20,28,'100%',170);
application.processmessages;
result:=k;
tempwin.destroy;
end;


function cheby1(input:TFloatsample; mode:integer):Tfloatsample;
var i:integer;
// filter up to 20k @ 1411200
// computed with mkfilter http://www-users.cs.york.ac.uk/~fisher/mkfilter/trad.html


const xvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const xvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const gain=1.202243263e+08;

begin
if mode=1 then for i:=0 to 8 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4]; xvl[4]:=xvl[5]; xvl[5]:=xvl[6]; xvl[6]:=xvl[7]; xvl[7]:=xvl[8];
xvl[8]:=input[0]/gain;

yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4]; yvl[4]:=yvl[5]; yvl[5]:=yvl[6]; yvl[6]:=yvl[7]; yvl[7]:= yvl[8];
yvl[8]:=(xvl[0] + xvl[8]) +   4.1799297777 * (xvl[1] + xvl[7]) +   5.0795786660 * (xvl[2] + xvl[6])
                     -   1.3010533350 * (xvl[3] + xvl[5]) -   6.4014044466 * xvl[4]
                     + ( -0.0000000000 * yvl[0]) + ( -0.0000000000 * yvl[1])
                     + ( -0.8585981845 * yvl[2]) + (  5.2720858671 * yvl[3])
                     + (-13.5006598310 * yvl[4]) + ( 18.4553337190 * yvl[5])
                     + (-14.2040360000 * yvl[6]) + (  5.8358743349 * yvl[7]);
result[0] := yvl[8];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4]; xvr[4]:=xvr[5]; xvr[5]:=xvr[6]; xvr[6]:=xvr[7]; xvr[7]:=xvr[8];
xvr[8]:=input[1]/gain;

yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4]; yvr[4]:=yvr[5]; yvr[5]:=yvr[6]; yvr[6]:=yvr[7]; yvr[7]:= yvr[8];
yvr[8]:=(xvr[0] + xvr[8]) +   4.1799297777 * (xvr[1] + xvr[7]) +   5.0795786660 * (xvr[2] + xvr[6])
                     -   1.3010533350 * (xvr[3] + xvr[5]) -   6.4014044466 * xvr[4]
                     + ( -0.0000000000 * yvr[0]) + ( -0.0000000000 * yvr[1])
                     + ( -0.8585981845 * yvr[2]) + (  5.2720858671 * yvr[3])
                     + (-13.5006598310 * yvr[4]) + ( 18.4553337190 * yvr[5])
                     + (-14.2040360000 * yvr[6]) + (  5.8358743349 * yvr[7]);
result[1] := yvr[8];
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

 function cheby3(input:TFloatsample; mode:integer):Tfloatsample;

// Low pass Chebyshev filter 48k @ 2822400 Hz
// computed with mkfilter http://www-users.cs.york.ac.uk/~fisher/mkfilter/trad.html


const xvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const xvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const gain= 1.033341201e+07;
var i:integer;

begin
if mode=1 then for i:=0 to 8 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4]; xvl[4]:=xvl[5]; xvl[5]:=xvl[6]; xvl[6]:=xvl[7]; xvl[7]:=xvl[8];
xvl[8]:=(0.00005*random+input[0])/gain;

yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4]; yvl[4]:=yvl[5]; yvl[5]:=yvl[6]; yvl[6]:=yvl[7]; yvl[7]:= yvl[8];
yvl[8] :=   (xvl[0] + xvl[8]) +   4.0455000071 * (xvl[1] + xvl[7]) +   4.2730000425 * (xvl[2] + xvl[6])
             -   3.3174998938 * (xvl[3] + xvl[5]) -   9.0899998584 * xvl[4]
             + ( -0.0000000000 * yvl[0]) + ( -0.0000000000 * yvl[1])
             + ( -0.8328181514 * yvl[2]) + (  5.1346862353 * yvl[3])
             + (-13.2077057100 * yvl[4]) + ( 18.1429544020 * yvl[5])
             + (-14.0374349520 * yvl[6]) + (  5.8003178940 * yvl[7]);


result[0] := yvl[8];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4]; xvr[4]:=xvr[5]; xvr[5]:=xvr[6]; xvr[6]:=xvr[7]; xvr[7]:=xvr[8];
xvr[8]:=(0.00005*random+input[1])/gain;

yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4]; yvr[4]:=yvr[5]; yvr[5]:=yvr[6]; yvr[6]:=yvr[7]; yvr[7]:= yvr[8];
yvr[8] :=   (xvr[0] + xvr[8]) +   4.0455000071 * (xvr[1] + xvr[7]) +   4.2730000425 * (xvr[2] + xvr[6])
             -   3.3174998938 * (xvr[3] + xvr[5]) -   9.0899998584 * xvr[4]
             + ( -0.0000000000 * yvr[0]) + ( -0.0000000000 * yvr[1])
             + ( -0.8328181514 * yvr[2]) + (  5.1346862353 * yvr[3])
             + (-13.2077057100 * yvr[4]) + ( 18.1429544020 * yvr[5])
             + (-14.0374349520 * yvr[6]) + (  5.8003178940 * yvr[7]);
result[1] := yvr[8];
end;


 function bessel1(input:TFloatsample; mode:integer):Tfloatsample;

// Low pass Bessel filter 20k @ 2822400 Hz
// computed with mkfilter http://www-users.cs.york.ac.uk/~fisher/mkfilter/trad.html


const xvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const xvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const gain=1.101446441e+05;
var i:integer;

begin
if mode=1 then for i:=0 to 8 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4]; xvl[4]:=xvl[5]; xvl[5]:=xvl[6]; xvl[6]:=xvl[7]; xvl[7]:=xvl[8];
xvl[8]:=input[0]/gain;

yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4]; yvl[4]:=yvl[5]; yvl[5]:=yvl[6]; yvl[6]:=yvl[7]; yvl[7]:= yvl[8];
yvl[8] :=   (xvl[0] + xvl[8]) +   4.0455000071 * (xvl[1] + xvl[7]) +   4.2730000425 * (xvl[2] + xvl[6])
             -   3.3174998938 * (xvl[3] + xvl[5]) -   9.0899998584 * xvl[4]
             + ( -0.0000000000 * yvl[0]) + ( -0.0000000000 * yvl[1])
             + ( -0.4361003958 * yvl[2]) + (  2.9847272706 * yvl[3])
             + ( -8.5331904016 * yvl[4]) + ( 13.0454905950 * yvl[5])
             + (-11.2492017410 * yvl[6]) + (  5.1882482350 * yvl[7]);



result[0] := yvl[8];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4]; xvr[4]:=xvr[5]; xvr[5]:=xvr[6]; xvr[6]:=xvr[7]; xvr[7]:=xvr[8];
xvr[8]:=input[1]/gain;

yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4]; yvr[4]:=yvr[5]; yvr[5]:=yvr[6]; yvr[6]:=yvr[7]; yvr[7]:= yvr[8];
yvr[8] :=   (xvr[0] + xvr[8]) +   4.0455000071 * (xvr[1] + xvr[7]) +   4.2730000425 * (xvr[2] + xvr[6])
             -   3.3174998938 * (xvr[3] + xvr[5]) -   9.0899998584 * xvr[4]
             + ( -0.0000000000 * yvr[0]) + ( -0.0000000000 * yvr[1])
             + ( -0.4361003958 * yvr[2]) + (  2.9847272706 * yvr[3])
             + ( -8.5331904016 * yvr[4]) + ( 13.0454905950 * yvr[5])
             + (-11.2492017410 * yvr[6]) + (  5.1882482350 * yvr[7]);

result[1] := yvr[8];
end;


{
function fft_oct

begin

for i:=0 to 65535 do okno[i]:=sqr(sin(pi*i/65536));

fh0:=filecreate('d:\out300.raw');
fh1:=filecreate('d:\out301.raw');
fh2:=filecreate('d:\out302.raw');
fh3:=filecreate('d:\out303.raw');
fh4:=filecreate('d:\out304.raw');
fh5:=filecreate('d:\out305.raw');
fh6:=filecreate('d:\out306.raw');
fh7:=filecreate('d:\out307.raw');
fh8:=filecreate('d:\out308.raw');
fh9:=filecreate('d:\out309.raw');
fh:=fileopen('d:\denoise2.raw',$40);
 repeat
   for i:=0 to 131072 do bufor[i]:=0;
   il:=fileread(fh,bufor,524288);
   for i:=0 to 65535 do
     begin
     buforl[i]:=bufor[2*i]*okno[i];
     buforr[i]:=bufor[2*i+1]*okno[i];
     end;
   form1.fft10.fft; //65536 spl.  6-13 14-27 28-54 55-109 110-218 219-436 437-873 874-1747 1748-3495 3496-6990
   form1.fft11.fft

   fo

}

end.

