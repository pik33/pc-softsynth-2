unit Unit1; 

// PC Softsynth
// License: GNU GPL
// see README for details


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Buttons, SynEdit, fft, sdl, math, lcltype, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    Bevel3: TBevel;
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn9: TBitBtn;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    OpenDialog3: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SaveDialog3: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SynEdit1: TSynEdit;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn15Click(Sender: TObject);
    procedure BitBtn16Click(Sender: TObject);
    procedure BitBtn17Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CheckBox6Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Memo1Enter(Sender: TObject);
    procedure Menu1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SynEdit1Change(Sender: TObject);
    procedure TabSheet2Enter(Sender: TObject);
    procedure TabSheet2Show(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end; 

  const maxchannel=32;
        maxdefs=1024;
        buflen=441000;
        ver='0.08 alpha-20150308 build 150';

  type
  TSoundinfo=record
     time,command,channel,sample,adsr:integer;
     freq:double;
     vol,pan,len,start:integer;
     spl_len:integer;
     idx:integer;
     pause:integer;
     stop,effect:integer;
     esample,eadsr,ea1,ea2,ea3:integer;
     glis:integer;
     play:integer;   //0-not played, 1-playing, 2-played, 3-empty
     end;

  PsoundRecord=^TSoundRecord;

  TSoundRecord=record
     time,command,p1,p2,p3,p4,p5,depth:integer;
     next,last:PSoundRecord;
  end;


  PProgline=^Tprogline;

  TProgline=record
     linenum:integer;
     line:string[255];
     last,next:PProgline;
  end;


  Tproginfo=record
     token,linenum,channel,sample,adsr:integer;
     freq:double;
     vol,pan,len,start:integer;
     spl_len:integer;
     idx:integer;
     pause:integer;
     end;

  TWaveRec=record
     index:integer;
     name:string;
     noise:integer;
    end;


  s255=string[255];
  TWaveTable=array[-1..65535] of TWaveRec;

  TChannelsDefaults=array[-1..maxchannel] of TSoundInfo;

  TSample=array[0..1] of smallint;
  TBigSample=array[0..1] of integer;

  TSampletab=array[-1..1024] of smallint;
  Tsamples=array[-1..maxdefs] of TSampletab;

  TAdsrTab=array[0..256] of byte;
  TAdsrs=array[-1..maxdefs] of TAdsrTab;

  TOktawa=array[0..11] of double;
  TDzwieki=array[-4..6] of TOktawa;
  TKodyDzwiekow=array[-4..6,0..11] of string;

  TStrings=array[0..15] of string;
  TNums=array[0..15] of double;

  TState=record
     intfreq,freq,normfreq,vol,sleft,sright,gliss_dev,vib_dev,trans_delta,spos,apos,gliss,gliss_df,pan:double;
     intchn,sample,adsr,panmode,len,samplenum,ispos,iapos,transition,gliss_par2,gliss_time:integer;
     end;
  TStatetable=array[-1..maxchannel] of TState;
  TIntstate=record
     channel1,channel2:integer;
     freq:double;
     end;

  TEcho=record
     channel,delay:integer;
  end;

  TEchotable=array[-1..maxchannel] of TEcho;

//--- MIDI decoding

  PMDecode=^TMDecode;

  TMDecode=record
     channel,command,time,length,par1,par2,par3,par4,par5:integer;
     prev,next:PMDecode;
  end;



const a212=1.0594630943592953098431053149397484958; //2^1/12
      c03=16.351597831287416763959505349330137242; //C-4
      norm44=0.02321995464852607709750566893424;   // freq normalize const, 1024/44100

var
  Form1: TForm1;
  desired,obtained:TSDL_AudioSpec;                // zmienne do inicjacji audio

  samples:TSamples;
  adsrs:TAdsrs;
  dzwieki:TDzwieki;


  gain:double=1.0;
  g2:array[-1..maxchannel] of double;
  d,defaults,vdefaults:TChannelsDefaults;
  indeksy:array[-1..maxchannel] of integer;
  indeksy2:array[-1..maxchannel] of integer;

  old:boolean=false;
  play:boolean=false;
  start:boolean=false;

  i_cmd:string='';
  i_line:integer=-1;
  i_chn:integer=-1;
  i_freq:integer=440;
  i_len:integer=300;
  i_wave:integer=-1;
  i_adsr:integer=-1;
  i_pan:integer=0;
  i_vol:integer=32767;
  i_maxwave:integer=0;
  i_maxadsr:integer=0;

  pierwsza,ostatnia:TProgline;

  Aproglen:integer=0;

  kody:TKodyDzwiekow;

  wavetable,adsrtable:TWaveTable;
  waveidx:integer=0;
  adsridx:integer=0;

  s_dir:string;
  h_dir:string;
  m_dir:string;
  l_dir:string;
  state,state2,vstate:TStatetable;
  atari:boolean=false;
  ptime:double=-1;
  quit5:boolean=true;
  test:integer=0;
  k11:boolean=false;

  fsr,lsr:array[-1..maxchannel] of TSoundRecord;
  csr:array[-1..maxchannel] of PSoundRecord;
  modstate:integer=0;
  realtime:boolean=false;
  inttable:array[-1..maxchannel] of Tintstate; //tablica dla efektu INT

// zmienne globalne dla procedury run2

  speed:double=4;
  chtime:array[0..maxchannel] of integer;
  defchn,oldwave,oldadsr:integer;
  maxtime:integer;

  test2:integer;

  echotable:TEchotable;
  pause:boolean=false;
  atari2:boolean=false;

  MFirst,MLast:TMDecode;

  check6:integer=0;
  fhw,fht:integer;
  tempfilename:string;
  wave:boolean;

procedure starttrack;
procedure endtrack(time:integer);
procedure stop(mode:integer);
procedure addchannel3(channel,time,cmd,p1,p2,p3,p4,p5,depth:integer);
function strtofloat2(a:string):double;

//------------implementation----------------------------------------------------

implementation
uses unit2,unit3;

{$R *.lfm}

operator +(a,b:Tsample):Tsample;

var p0,p1:integer;

begin
  p0:=a[0]+b[0];
  p1:=a[1]+b[1];
  if p0<-32767 then p0:=-32767;
  if p0>32767 then p0:=32767;
  if p1<-32767 then p1:=-32767;
  if p1>32767 then p1:=32767;
  result[0]:=p0;
  result[1]:=p1;
end;

operator +(a,b:Tsample):TBigsample;

var p0,p1:integer;

begin
  p0:=a[0]+b[0];
  p1:=a[1]+b[1];
  result[0]:=p0;
  result[1]:=p1;
end;


operator +(a:TBigsample;b:Tsample):TBigsample;

var p0,p1:integer;

begin
  p0:=a[0]+b[0];
  p1:=a[1]+b[1];
  result[0]:=p0;
  result[1]:=p1;
end;


operator *(a:TBigsample;b:double):TSample;

var p0,p1:integer;

begin
  p0:=round(a[0]*b);
  p1:=round(a[1]*b);
  if p0<-32767 then p0:=-32767;
  if p0>32767 then p0:=32767;
  if p1<-32767 then p1:=-32767;
  if p1>32767 then p1:=32767;
  result[0]:=p0;
  result[1]:=p1;
end;

procedure clearstate(var s:Tstatetable);

var i:integer;

begin
for i:=-1 to maxchannel do
  begin
  s[i].intfreq:=0;
  s[i].freq:=0;
  s[i].normfreq:=0;
  s[i].vol:=0;
  s[i].sleft:=0;
  s[i].sright:=0;
  s[i].gliss_dev:=0;
  s[i].vib_dev:=0;
  s[i].trans_delta:=0;
  s[i].spos:=0;
  s[i].apos:=0;
  s[i].intchn:=-2;
  s[i].sample:=-1;
  s[i].adsr:=-1;
  s[i].panmode:=0;
  s[i].len:=0;
  s[i].samplenum:=0;
  s[i].ispos:=0;
  s[i].iapos:=0;
  s[i].transition:=-1;
  s[i].gliss_par2:=0;
  s[i].gliss_time:=0;
  s[i].gliss_df:=0;
  s[i].pan:=64;
  if i=1 then s[i].pan:=40;
  if i=2 then s[i].pan:=56;
  if i=3 then s[i].pan:=72;
  if i=4 then s[i].pan:=88;

  echotable[i].channel:=-2;
  echotable[i].delay:=0;
  end;
speed:=4;
modstate:=0;
end;

procedure emit(s:string);

//var i:integer;
//ss:array[0..30] of string;

begin
// old version
{
if form1.memo1.lines.count<30 then
  begin
  form1.Memo1.lines.add('');
  form1.memo1.lines[form1.memo1.lines.count-1]:=s;
  end
else
  begin
  for i:=0 to 29 do ss[i]:=form1.memo1.lines[i];
  form1.memo1.lines.clear;
  for i:=1 to 29 do
    begin
    form1.memo1.lines.add(ss[i]); // QT error workaround !
//    form1.memo1.lines[form1.memo1.lines.count-1]:=ss[i];
    end;
  form1.memo1.lines.add('');
  form1.memo1.lines[form1.memo1.lines.count-1]:=s;
  end;
  application.processmessages;}
form1.memo1.lines.add(s)
end;

function spaces(n:integer):s255;

var i:integer;

begin
result:='';
for i:=1 to n do result:=result+' ';
end;

function getarg(num:integer; line:string; var arg:string):integer;

var i,j,q:integer;

begin
arg:=copy(line,20*num+1,20);
if arg=spaces(20) then result:=-1 else result:=0;
arg:=trim(arg);
q:=0;
j:=0;
for i:=1 to length(arg) do if copy(arg,i,1)='.' then q:=1;
if q=1 then
  begin
  i:=length(arg);
  while (j=0) and(copy(arg,i,1)='0') or (copy(arg,i,1)='.') do
    begin
    if (copy(arg,i,1)='.') then j:=1;
    arg:=copy(arg,1,i-1);
    dec(i);
    end;
  end;
end;


function setarg(num:integer; var line:string; arg:string):integer;

var l:string;

begin
if length(line)<255 then line:=line+spaces(255-length(line));
if length(arg)<20 then arg:=arg+spaces(20-length(arg));
if length(line)>255 then line:=copy(line,1,255);
if length(arg)>20 then arg:=copy(arg,1,20);
l:=copy(line,1,20*num);
l:=l+arg;
l:=l+copy(line,20*(num+1)+1,255-20*(num+1));
line:=l;
if arg=spaces(20) then result:=-1 else result:=0;
end;

procedure vib;  // drugi syntezator dla efektu vib

label p199,p101;

var i:integer;
    spl11,spl12,samplenum,adsr,sample,len,pos1,pos2,adsr_pos3,adsr_pos2:integer;
    q:integer;
    adg,adg1,adg2,df,adsr_pos,adsr_pos4,spl,spl2,pos3:double;
    vib:boolean;

begin
vib:=false;
for i:=-1 to maxchannel do if vstate[i].vol>0 then vib:=true;
if not vib then goto p199;
for i:=-1 to maxchannel do
  begin
  samplenum:=vstate[i].samplenum; //kolejny numer generowanego sampla
  adsr:=vstate[i].adsr;           //indeks do tablicy adsrów
  sample:=vstate[i].sample;       //indeks do tablicy sampli
  len:=vstate[i].len;             //długośc w próbkach

  if (len>0) and (samplenum<=len) then // jak nie ma co wibrować to niech nie wibruje
    begin
    df:=vstate[i].normfreq;
    vstate[i].spos+=df;                                                    //new sample position
    while vstate[i].spos<0 do vstate[i].spos+=1024;
    while vstate[i].spos>=1024 do vstate[i].spos-=1024;                     // [0..1024)

    pos1:=trunc(vstate[i].spos);                                           // 0..1023
    pos2:=(pos1+1) mod 1024;
    pos3:=frac(vstate[i].spos);

    spl11:=samples[sample,pos1];
    spl12:=samples[sample,pos2];
    spl:=(1-pos3)*spl11+pos3*spl12;

    if adsr=-2 then
      begin
      adg:=255;
      goto p101;
      end;

    if adsr_pos>=256 then adg:=0
    else
      begin
      adsr_pos2:=trunc(adsr_pos);
      adsr_pos4:=frac(adsr_pos);
      adsr_pos3:=adsr_pos2+1;
      adg1:=adsrs[adsr,adsr_pos2];
      if adsr_pos3<256 then adg2:=adsrs[adsr,adsr_pos3] else adg2:=0;
      adg:=adg1*(1-adsr_pos4)+adg2*adsr_pos4;
      end;
p101:
    spl:=(spl*adg)/256;
    spl:=spl*vstate[i].vol; // vol normalizowane do 0..1 float
    inc(samplenum);
    vstate[i].samplenum:=samplenum;
    state[i].vib_dev:=norm44*spl;
    end;
  end;
p199:
end;

function synteza:TSample;

//freq,normfreq,vol,sleft,sright,glis_dev,vib_dev,trans_delta,spos,apos:double
//sample,adsr,panmode,len,samplenum,ispos,iapos,transition:integer;
//state,state2,vstate:TStatetable2;

var i:integer;
    intchn,spl11,spl12,samplenum,adsr,sample,len,pos1,pos2,adsr_pos3,adsr_pos2:integer;
    q:integer;
    spl_l,spl_r,spl3,spl4,vol,int_dev,adg,adg1,adg2,df,adsr_pos,adsr_pos4,spl,spl2,pos3:double;
    cn:integer;
    gliss_dev1,gliss_dev2,gliss_dev3:double;

begin
vib;

spl2:=0;
spl_l:=0;
spl_r:=0;
for i:=-1 to maxchannel do
  begin
 // if state[i].intchn=-2 then
  //  begin
  if state2[i].transition=-1 then g2[i]:=1;  // płynne wygaszanie przy zmianie dźwięku
  if state2[i].transition=0 then
    begin
    dec(state2[i].transition);
    state[i]:=state2[i];
    g2[i]:=1;
    end;
  if state2[i].transition>0 then
    begin
    dec(state2[i].transition);
    g2[i]:=g2[i]-(state2[i].trans_delta);
    end;
 //   end;
// check if int
  if state[i].intchn>-2 then
    cn:=state[i].intchn else cn:=i;


  samplenum:=state[cn].samplenum; //kolejny numer generowanego sampla
  if cn=i then adsr:=state[i].adsr else adsr:=defaults[i].adsr;           //indeks do tablicy adsrów
  if cn=i then sample:=state[i].sample else sample:=defaults[i].sample;       //indeks do tablicy sampli
  if cn=i then vol:=state[i].vol else vol:=defaults[i].vol/32768;
  len:=state[cn].len;             //długośc w próbkach
  intchn:=state[i].intchn;
  int_dev:=state[i].intfreq*norm44;
  gliss_dev1:=0;
  gliss_dev2:=0;
  gliss_dev3:=0;

  if (len>0) and (samplenum<=len) then // jak nie ma co grać to niech nie gra
    begin
    if intchn=-2 then
      if (state[cn].gliss_dev<>0) or (state[cn].gliss_par2<>0) then
        begin
     //   state[cn].normfreq+=state[cn].gliss_dev;  //gliss_dev wg normalizowanej częstotliwości
          gliss_dev1:=samplenum*state[cn].gliss_dev;
          gliss_dev2:=norm44*6.6*state[cn].gliss_par2*(sqr((samplenum/44100)-(state[cn].gliss_time/2000))-state[cn].gliss_df);
          gliss_dev3:=gliss_dev1+gliss_dev2;
 //         while gliss_dev3>128 do gliss_dev3-=128;
 //         while gliss_dev3<-128 do gliss_dev3+=128;
          end;

    df:=state[cn].normfreq+state[cn].vib_dev+gliss_dev3;
    df+=int_dev;
    if atari then
      begin
      if df<0 then df:=-df;
      while df>256 do df-=256;
      if df>128 then df:=256-df;
      end;
    state[i].spos+=df;                                            //new sample position
    while state[i].spos<0 do state[i].spos+=1024;
    while state[i].spos>=1024 do state[i].spos-=1024;                     // [0..1024)

    pos1:=trunc(state[i].spos);                                           // 0..1023
    pos2:=(pos1+1) mod 1024;
    pos3:=frac(state[i].spos);

    if (wavetable[sample].noise=0) or (((df+int_dev)/norm44)<20) then
      begin
      spl11:=samples[sample,pos1];
      spl12:=samples[sample,pos2];
      spl:=(1-pos3)*spl11+pos3*spl12;
      end
    else spl:=-32767+random(65535);                              // omijka brzydkiego brzmienia random.s

    adsr_pos:=256*samplenum/len;

    if adsr_pos>=256 then adg:=0
    else
      begin
      adsr_pos2:=trunc(adsr_pos);
      adsr_pos4:=frac(adsr_pos);
      adsr_pos3:=adsr_pos2+1;
      adg1:=adsrs[adsr,adsr_pos2];
      if adsr_pos3<256 then adg2:=adsrs[adsr,adsr_pos3] else adg2:=0;
      adg:=adg1*(1-adsr_pos4)+adg2*adsr_pos4;
      end;
    spl:=(spl*adg)/256;
//    spl:=spl*state[cn].vol; // vol normalizowane do 0..1 float
    spl:=spl*vol; // vol normalizowane do 0..1 float
    inc(samplenum);
    state[i].samplenum:=samplenum;
    if modstate>0 then
      begin
      if i=3 then begin spl3:=spl; spl:=0; end;
      if i=4 then begin spl4:=spl; spl:=0; end;
      end;
//    spl2+=spl*g2[i];
    spl_l+=spl*g2[i]*(128-state[i].pan)/128;
    spl_r+=spl*g2[i]*(state[i].pan)/128;
    end;
  end;
if modstate>0 then
  begin
  spl3:=(spl3*spl4)/32768;
  spl_r+=spl3*g2[i]*(128-state[i].pan)/128;
  spl_l+=spl3*g2[i]*(state[i].pan)/128;
  end;

if abs(spl_l*gain)>32767 then gain:=abs(32767/spl_l);
if abs(spl_r*gain)>32767 then gain:=abs(32767/spl_r);
result[1]:=round(spl_r*gain);
result[0]:=round(spl_l*gain);
end;


function split(a:s255;var b:Tstrings):integer;

label p101,p102;

var i,j,q,l:integer;

begin

i:=1;
q:=0;
for j:=0 to 15 do b[i]:='';
l:=length(a);
i:=1;
while (copy(a,i,1)=' ') and (i<=l) do
  begin
  inc(i);
  if i>l then goto p101;
  end;
while (copy (a,i,1)<>' ') and (copy (a,i,1)<>',') and (i<=l) do
  begin
  b[0]:=b[0]+copy(a,i,1);
  inc(i);
  q:=1;
  if i>l then goto p101;
  end;
for j:=1 to 15 do
  begin
  while ((copy(a,i,1)=' ') or (copy(a,i,1)=',')) and (i<=l) do
    begin
    if copy(a,i,2)=',,' then
      begin
      inc(i);
      b[j]:=' ';
      b[14]:=',' ;
      goto p102;
      end;
    inc(i);
    if i>l then goto p101;
    end;
  while (copy (a,i,1)<>' ') and (copy (a,i,1)<>',') and (i<=l) do
    begin
    b[j]:=b[j]+copy(a,i,1);
    inc(i);
    q:=j+1;
    if i>l then goto p101;
    end;
  p102:
  end;
p101:
result:=q;
end;

function strtofloat2(a:string):double;

label p999;

var q,d:double;
c:string;
mode,i,l:integer;
minus:double;

begin
minus:=1;
result:=-1;
q:=0;
d:=0.1;
mode:=0;
l:=length(a);
i:=1;
c:=copy(a,1,1);
if c='>' then
  begin
  result:=-2;
  goto p999;
  end;
repeat
  c:=copy(a,i,1);
  if mode=1 then
     begin
     if (c='-') then minus:=-1;
     if (c='0') then q:=q;
     if (c='1') then q:=q+1*d;
     if (c='2') then q:=q+2*d;
     if (c='3') then q:=q+3*d;
     if (c='4') then q:=q+4*d;
     if (c='5') then q:=q+5*d;
     if (c='6') then q:=q+6*d;
     if (c='7') then q:=q+7*d;
     if (c='8') then q:=q+8*d;
     if (c='9') then q:=q+9*d;
     if (c<>'0') and (c<>'1') and (c<>'2') and (c<>'3') and (c<>'4') and (c<>'5')
       and (c<>'6') and (c<>'7') and (c<>'8') and (c<>'9') and (c<>' ') and (c<>'-')
        then
          begin
          result:=-1;
          goto p999;
          end;
     d:=d/10;
     end;
  if mode=0 then
    begin
    if (c='-') then minus:=-1;
    if (c='0') then q:=10*q;
    if (c='1') then q:=10*q+1;
    if (c='2') then q:=10*q+2;
    if (c='3') then q:=10*q+3;
    if (c='4') then q:=10*q+4;
    if (c='5') then q:=10*q+5;
    if (c='6') then q:=10*q+6;
    if (c='7') then q:=10*q+7;
    if (c='8') then q:=10*q+8;
    if (c='9') then q:=10*q+9;
    if (c='.') or (c=',') then mode:=1;
    if (c<>'0') and (c<>'1') and (c<>'2') and (c<>'3') and (c<>'4') and (c<>'5')
      and (c<>'6') and (c<>'7') and (c<>'8') and (c<>'9') and (c<>'.') and (c<>',') and (c<>' ') and (c<>'-')
        then
          begin
          result:=-1;
          goto p999;
          end;
    end;
  inc(i)
until i>l;
q:=minus*q;
if q=-1 then q:=-1.0000001;
if q=-2 then q:=-2.0000001; // todo: jak zrobic to lepiej???
result:=q;
p999:
end;


procedure strstonums(a:Tstrings;var b:TNums);

var i:integer;

begin
for i:=0 to 15 do b[i]:=strtofloat2(a[i]);
end;

function decodesound(a:string):double;

var i,j:integer;

begin
result:=-1;
a:=lowercase(a);
if copy(a,1,1)='''' then
  begin
    try
      result:=strtofloat(copy(a,2,length(a)-1));
    except
      begin
      emit('Error - bad frequency string '+a+', ignored');
      result:=0;
      end;
    end;
  end
else
  begin
  if copy(a,length(a),1)='0' then a:=copy(a,1,length(a)-1);
  for i:=-4 to 6 do for j:=0 to 11 do if kody[i,j]=a then result:=dzwieki[i,j];
  end;
if result=-1 then
  begin
  result:=0;
  emit('Error - bad frequency string '+a+', ignored');

  end;
end;


function encodesound(a:double):string;

var i,j:integer;
    s:string;

begin
s:=''''+floattostrf(a,fffixed,20,3);
i:=length(s);
j:=0;
while (j=0) and ((copy(s,i,1)='0') or (copy(s,i,1)='.')) do
  begin
  if (copy(s,i,1)='.') then j:=1;
  s:=copy(s,1,i-1);
  dec(i);
  end;

result:=s;
for i:=-4 to 6 do for j:=0 to 11 do if round(10*dzwieki[i,j])=round(10*a) then result:=kody[i,j];
end;

procedure endtrack(time:integer);

var i:integer;

begin
for i:=-1 to maxchannel do if fsr[i].next<>@lsr[i] then addchannel3(i,time,1,0,0,0,0,100,0);
end;


procedure starttrack;

var i:integer;

begin
for i:=-1 to maxchannel do csr[i]:=@fsr[i];
end;

procedure addchannel3(channel,time,cmd,p1,p2,p3,p4,p5,depth:integer);

label p101;

var wsk,wsk2:PSoundRecord;
    s:integer;

begin
wsk:=@fsr[channel];
repeat
  wsk:=wsk^.next
until (wsk=@lsr[channel]) or (wsk^.time>time) or ((wsk^.time=time) and (wsk^.depth>depth));
new(wsk2);
wsk2^.time:=time;
wsk2^.command:=cmd;
wsk2^.p1:=p1;
wsk2^.p2:=p2;
wsk2^.p3:=p3;
wsk2^.p4:=p4;
wsk2^.p5:=p5;
wsk2^.depth:=depth;
wsk2^.next:=wsk;
wsk2^.last:=wsk^.last;
wsk2^.last^.next:=wsk2;
wsk^.last:=wsk2;
end;


function setwave(channel:integer;wavename:string):integer;

var found,fh,i:integer;
    s,s2:string;
    bufor:array[0..2048] of byte;
    bufor2:array[0..1024] of smallint absolute bufor;
    spl:smallint;

begin

i:=0;
found:=-1;
s:=s_dir+upcase(wavename)+'.S';
s2:=s_dir+lowercase(wavename)+'.s2';
while i<waveidx do
  begin
  if wavetable[i].name=lowercase(wavename) then found:=i;
  inc(i);
  end;
if found=-1 then //fala nie znaleziona, wczytaj z pliku
  begin
  if not atari2 then fh:=fileopen(s2,$40) else fh:=-1;
  if fh<0 then
    begin
    s:=s_dir+upcase(wavename)+'.S';
    fh:=fileopen(s,$40);
    if fh>0 then
      begin
      emit('Loaded file '+s);
      for i:=0 to 256 do bufor[i]:=0; //wyczyść bufor
      fileread(fh,bufor,256);
      fileclose(fh);
      bufor[256]:=bufor[0];
      for i:=0 to 255 do
        //wygładzanie wstępne
        begin
        samples[waveidx,4*i]:=round(4096*(bufor[i]-7.5));
        samples[waveidx,4*i+1]:=round(3072*(bufor[i]-7.5)+1024*(bufor[i+1]-7.5));
        samples[waveidx,4*i+2]:=round(2048*(bufor[i]-7.5)+2048*(bufor[i+1]-7.5));
        samples[waveidx,4*i+3]:=round(1024*(bufor[i]-7.5)+3072*(bufor[i+1]-7.5));
        end;
      wavetable[waveidx].name:=lowercase(wavename);
      wavetable[waveidx].index:=waveidx;
      if wavetable[waveidx].name='random' then wavetable[waveidx].noise:=1 else wavetable[waveidx].noise:=0;
      found:=waveidx;
      inc(waveidx);
      end
    else
      emit('Error - cannot find wave'+' '+wavename);
    end
  else
    begin
    emit('Loaded file '+s2);
    for i:=0 to 1023 do samples[waveidx,i]:=0;
    fileread(fh,bufor,16); // TODO: kontrola nagłówka!!!
    fileread(fh,bufor,2048);
    fileclose(fh);
    for i:=0 to 1023 do
      begin
      spl:=bufor2[i];
      samples[waveidx,i]:=spl;
      end;
    wavetable[waveidx].name:=lowercase(wavename);
    wavetable[waveidx].index:=waveidx;
    if wavetable[waveidx].name='random' then wavetable[waveidx].noise:=1 else wavetable[waveidx].noise:=0;
    found:=waveidx;
    inc(waveidx);
    end;
  end;
if found<>-1 then
  begin
  if channel<=maxchannel then defaults[channel].sample:=found else vdefaults[channel-2*maxchannel].sample:=found;   // channel>maxchannel -> vib
  result:=found;
  end
else result:=-1;
end;


function setadsr(channel:integer;adsrname:string):integer;

var found,fh,i:integer;
    s,s2:string;
    bufor:array[0..256] of byte;

begin
i:=0;
s:=h_dir+upcase(adsrname)+'.H';
s2:=h_dir+lowercase(adsrname)+'.h2';
found:=-1;
while i<adsridx do
  begin
  if adsrtable[i].name=lowercase(adsrname) then found:=i;
  inc(i);
  end;
if found=-1 then //adsr nie znaleziona, wczytaj z pliku
  begin
  if not atari2 then fh:=fileopen(s2,$40) else fh:=-1;
  if fh<0 then
    begin
    fh:=fileopen(s,$40);
    if fh>0 then
      begin
      emit('Loaded file '+s);
      for i:=0 to 64 do bufor[i]:=0; //wyczyść bufor
      fileread(fh,bufor,64);
      fileclose(fh);
      bufor[64]:=bufor[63];
      for i:=0 to 63 do
        begin
        adsrs[adsridx,4*i]:=round(16*(bufor[i]));
        adsrs[adsridx,4*i+1]:=round(12*(bufor[i])+4*(bufor[i+1]));
        adsrs[adsridx,4*i+2]:=round(8*(bufor[i])+8*(bufor[i+1]));
        adsrs[adsridx,4*i+3]:=round(4*(bufor[i])+12*(bufor[i+1]));
        end;
      adsrs[adsridx,256]:=0;
      adsrtable[adsridx].name:=lowercase(adsrname);
      adsrtable[adsridx].index:=adsridx;
      found:=adsridx;
      inc(adsridx);
      end
        else
      emit('Error - cannot find adsr'+' '+adsrname);
    end
  else
    begin
    emit('Loaded file '+s2);
    for i:=0 to 256 do adsrs[adsridx,i]:=0;
    fileread(fh,bufor,16);  // todo:nagłówek!
    fileread(fh,adsrs[adsridx],256);
    adsrs[adsridx,256]:=0;
    fileclose(fh);
    adsrtable[adsridx].name:=lowercase(adsrname);
    adsrtable[adsridx].index:=adsridx;
    found:=adsridx;
    inc(adsridx);
    end;
  end;
if found<>-1 then
  begin
  if channel<=maxchannel then defaults[channel].adsr:=found else vdefaults[channel-2*maxchannel].adsr:=found;   // channel>maxchannel -> vib
  result:=found;
  end
else result:=-1;
end;


function setcmd(pn:integer; var ss:Tstrings; nn:TNums; mode:boolean):integer;

// obsługa polecenia set
// mode=true - set immediately
// mode=false - only generate args

label p101,p102,p103,p104,p105,p106,p107,p108,p110;

var i,err2,chnum:integer;
    str:string;

// set ch,wave                      err=3; nn[2]=-1
// set ch,wave,adsr lub ch,,adsr    err=4; nn[2]=-1; nn[3]=-1; if ss[14]=',' pomijać ustawianie fali
// set ch,wave,adsr,pause           err=5; nn[2]=-1; nn[3]=-1; nn[4]=pause
// set ch,wave,adsr,len,pause       err=6; nn[2]=-1; nn[3]=-1; nn[4]=len; nn[5]=pause
// set ch,wave,adsr,vol,len,pause   err=7; nn[2]=-1; nn[3]=-1; nn[4]=vol; nn[5]=len; nn[6]=pause
// set ch,pause                     err=3; nn[2]=pause
// set ch,len,pause                 err=4; nn[2]=len; nn[3]=pause;
// set ch,vol,len,pause             err=5; nn[2]=vol; nn[3]=len; nn[4]=pause;


begin
result:=0;
if not mode then
  begin
  for i:=0 to 13 do
    begin
    ss[i]:=ss[i+1];
    nn[i]:=nn[i+1];
    end;
  dec(pn);
  end;
if (nn[1]=-1) or (nn[1]>maxchannel) then
  begin
//  emit('error - bad channel number');
  result:=-1;
  goto p110;
  end;

chnum:= trunc(nn[1]);
str:='';

if (pn=3) and (nn[2]=-1) then goto p101;
if (pn=4) and (nn[2]=-1) and (nn[3]=-1) then goto p102;
if (pn=5) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]>=0) then goto p103;
if (pn=6) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]>=0) and (nn[5]>=0) then goto p104;
if (pn=7) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]>=0) and (nn[5]>=0) and (nn[6]>=0) then goto p105;
if (pn=3) and (nn[2]>=0) then goto p106;
if (pn=4) and (nn[2]>=0) and (nn[3]>=0) then goto p107;
if (pn=5) and (nn[2]>=0) and (nn[3]>=0) and (nn[4]>=0) then goto p108;

emit('error - bad parameters');
result:=-2;
goto p110;

p101: //set ch,wave

if mode then err2:=setwave(chnum,ss[2])
else
  begin
  setarg(0,str,'set');
  setarg(1,str,inttostr(chnum));
  setarg(2,str,ss[2]);
  end;
goto p110;

p102: //set ch,wave,adsr

if mode then
  begin
  if ss[14]<>',' then err2:=setwave(chnum,ss[2]) else ss[2]:='';
  err2:=setadsr(chnum,ss[3]);
  end
else
  begin
  if ss[14]=',' then ss[2]:='';
  setarg(0,str,'set');
  setarg(1,str,inttostr(chnum));
  setarg(2,str,ss[2]);
  setarg(3,str,ss[3]);
  end;
goto p110;

p103: // set ch,wave,adsr,pause

if mode then
  begin
  if ss[14]<>',' then err2:=setwave(chnum,ss[2]) else ss[2]:='';
  err2:=setadsr(chnum,ss[3]);
  defaults[chnum].pause:=round(nn[4]);
  end
else
  begin
  if ss[14]=',' then ss[2]:='';
  setarg(0,str,'set');
  setarg(1,str,inttostr(chnum));
  setarg(2,str,ss[2]);
  setarg(3,str,ss[3]);
  setarg(7,str,inttostr(round(nn[4])));
  end;
goto p110;

p104: // set ch,wave,adsr,len,pause

if mode then
  begin
  if ss[14]<>',' then err2:=setwave(chnum,ss[2]) else ss[2]:='';
  err2:=setadsr(chnum,ss[3]);
  defaults[chnum].len:=round(nn[4]);
  defaults[chnum].pause:=round(nn[5]);
  end
else
  begin
  if ss[14]=',' then ss[2]:='';
  setarg(0,str,'set');
  setarg(1,str,inttostr(chnum));
  setarg(2,str,ss[2]);
  setarg(3,str,ss[3]);
  setarg(6,str,inttostr(round(nn[4])));
  setarg(7,str,inttostr(round(nn[5])));
  end;
goto p110;

p105: // set ch,wave,adsr,vol,len,pause

if mode then
  begin
  if ss[14]<>',' then err2:=setwave(chnum,ss[2]) else ss[2]:='';
  err2:=setadsr(chnum,ss[3]);
  defaults[chnum].vol:=round(nn[4]);
  defaults[chnum].len:=round(nn[5]);
  defaults[chnum].pause:=round(nn[6]);
  end
else
  begin
  if ss[14]=',' then ss[2]:='';
  setarg(0,str,'set');
  setarg(1,str,inttostr(chnum));
  setarg(2,str,ss[2]);
  setarg(3,str,ss[3]);
  setarg(5,str,inttostr(round(nn[4])));
  setarg(6,str,inttostr(round(nn[5])));
  setarg(7,str,inttostr(round(nn[6])));
  end;
goto p110;

p106: // set ch,pause

if mode then defaults[chnum].pause:=round(nn[2])
else
  begin
  setarg(0,str,'set');
  setarg(1,str,inttostr(chnum));
  setarg(7,str,inttostr(round(nn[2])));
  end;
goto p110;

p107: // set ch,len,pause

if mode then
  begin
  defaults[chnum].len:=round(nn[2]);
  defaults[chnum].pause:=round(nn[3]);
  end
else
  begin
  setarg(0,str,'set');
  setarg(1,str,inttostr(chnum));
  setarg(6,str,inttostr(round(nn[2])));
  setarg(7,str,inttostr(round(nn[3])));
  end;
goto p110;

p108: // set ch,vol,len,pause

if mode then
  begin
  defaults[chnum].vol:=round(nn[2]);
  defaults[chnum].len:=round(nn[3]);
  defaults[chnum].pause:=round(nn[4]);
  end
else
  begin
  setarg(0,str,'set');
  setarg(1,str,inttostr(chnum));
  setarg(5,str,inttostr(round(nn[2])));
  setarg(6,str,inttostr(round(nn[3])));
  setarg(7,str,inttostr(round(nn[4])));
  end;
goto p110;

p110:
if mode then
  begin
  emit('');
  emit('Ready');
  end
else ss[0]:=str;
end;


procedure newcmd(mode:boolean);

// obsługa polecenia new

var wsk,wsk2:PProgline;

begin
wsk:=pierwsza.next;
wsk2:=wsk;
while wsk<>@ostatnia do
  begin
  wsk:=wsk^.next;
  dispose(wsk2);
  wsk2:=wsk;
  end;
pierwsza.next:=@ostatnia;
ostatnia.last:=@pierwsza;
if mode then emit('');
if mode then emit('Ready');
end;


function deleteline(ln:integer):integer;

var wsk:PProgline;

// kasuje linię o danym numerze, -1=nie skasowano

begin
wsk:=@pierwsza;
result:=-1;
repeat
  wsk:=wsk^.next
until (wsk^.linenum=ln) or (wsk^.next=nil);
if wsk^.linenum=ln then
  begin
  wsk^.last^.next:=wsk^.next;
  wsk^.next^.last:=wsk^.last;
  dispose(wsk);
  result:=ln;
  end;
end;

function addline(ln:integer;line:s255):integer;

var wsk,wsk2:PProgline;

begin
wsk2:=@pierwsza;
repeat
  wsk2:=wsk2^.next;
until (wsk2^.linenum>=ln);
if wsk2^.linenum=ln then // zastąp
  begin
  wsk2^.line:=line;
  result:=-ln;
  end
else   //dopisz
  begin
  new(wsk);
  wsk^.line:=line;
  wsk^.linenum:=ln;
  wsk^.next:=wsk2;
  wsk^.last:=wsk2^.last;
  wsk^.last^.next:=wsk;
  wsk2^.last:=wsk;
  result:=ln;
  end;

end;

procedure list(a1,a2,mode:integer);

var wsk:PProgline;
    arg,arg2,l,str,str2,sep:string;
    ln,i,q,q2:integer;


// progline:
// 0: 00..20 cmd
// 1: 21..40 chnum
// 2: 41..60 wave
// 3: 61..80 adsr
// 4: 81..100 freq
// 5: 101..120 vol
// 6: 121..140 len
// 7: 141..160 pause
// 8: 161..180 gliss freq
// 9: 181..200 gliss par 1
//10: 201..220 gliss par 2

begin
if a1<0 then a1:=0;
if a2<0 then a2:=999999;
if mode=1 then
  begin
  form1.synedit1.lines.clear;
  end;
wsk:=@pierwsza;
repeat
  wsk:=wsk^.next;
  if wsk^.next<>nil then
    begin
    l:=wsk^.line;
    ln:=wsk^.linenum;
    if mode <> 1 then str:=inttostr(ln)+' '
    else
      //todo: if uselinenum then str:=inttostr(ln)
      str:='';
    getarg(0,l,arg);
    if (arg=';') or (arg='?')  then sep:=' ' else sep:=',';    // todo: don't split comments into args
    str:=str+arg; // cmd
    getarg(1,l,arg);  // chnum
    str2:=' ';
    if (arg<>'') then
      begin
      str:=str+' '+arg;
      str2:=',';
      end;
    q:=getarg(4,l,arg); //freq
    if q<>-1 then
      begin
      arg2:=encodesound(strtofloat(arg));
      str:=str+str2+arg2;
      end;
    q:=getarg(2,l,arg); // wave
    q2:=getarg(3,l,arg2); //adsr
    if (q<>-1) and (q2<>-1) then str:=str+','+arg+','+arg2;
    if (q=-1) and (q2<>-1) then str:=str+',,'+arg2;
    if (q<>-1) and (q2=-1) then str:=str+','+arg;
    for i:=5 to 11 do
      begin
      q:=getarg(i,l,arg);
      if (i=8) and (q<>-1) and (sep=',') then
        begin
        arg2:=encodesound(strtofloat(arg));
        str:=str+',>'+arg2;
        end;
      if (i<>8) and (q<>-1) then str:=str+sep+arg;
      end;
    if (ln>=a1) and (ln<=a2) then
      begin
      if copy(str,length(str)-2,3)='off' then str:=copy(str,1,length(str)-4)+' off';
      if mode=0 then emit(str);
      if mode=1 then form1.synedit1.lines.add(str);
      end;
    end;
until wsk^.next=nil;
if mode=0 then
  begin
  emit('');
  emit('Ready');
  end;
end;

procedure renum;

var wsk:PProgline;
    arg,arg2,l,str,str2:string;
    ln,i,q,q2:integer;

begin
q:=10;
wsk:=@pierwsza;
repeat
  wsk:=wsk^.next;
  if wsk^.next<>nil then
    begin
    wsk^.linenum:=q;
    inc(q,10);
    end;
until wsk^.next=nil;
list(0,999999,1);
emit('');
emit('Ready');
end;

procedure stop(mode:integer);

var il,size,i,j:integer;
    fwsk,fwsk2:PSoundRecord;
    bufor:array[0..65535] of byte;
    bufor3:array[0..16383] of integer absolute bufor;

begin
play:=false;
if wave and (mode=1) then
  begin
  wave:=false;
  fileclose(fht);
  size:=filesize(tempfilename);
  bufor[0]:=$52;//RIFF
  bufor[1]:=$49;
  bufor[2]:=$46;
  bufor[3]:=$46;
  bufor3[1]:=size+36; // ??
  bufor[8]:=$57; //WAVEfmt
  bufor[9]:=$41;
  bufor[10]:=$56;
  bufor[11]:=$45;
  bufor[12]:=$66;
  bufor[13]:=$6d;
  bufor[14]:=$74;
  bufor[15]:=$20;
  bufor3[4]:=$10; // ??
  bufor[20]:=1;//pcm
  bufor[21]:=0;
  bufor[22]:=2; //chn
  bufor[23]:=0;
  bufor[24]:=$44;//smpls p.s.
  bufor[25]:=$AC;
  bufor[26]:=0;
  bufor[27]:=0;
  bufor[28]:=$10;//bits p.s.
  bufor[29]:=$B1;
  bufor[30]:=2;
  bufor[31]:=0;
  bufor[32]:=4; // bytes/block
  bufor[33]:=0;
  bufor[34]:=$10; //bits p.s.
  bufor[35]:=0;
  bufor[36]:=$64;
  bufor[37]:=$61;
  bufor[38]:=$74;
  bufor[39]:=$61;
  bufor3[10]:=size;
  filewrite(fhw,bufor,44);
  fht:=fileopen(tempfilename,$40);
  repeat
    il:=fileread(fht,bufor,65536);
    filewrite(fhw,bufor,il)
  until il<65536;
  fileclose(fht);
  fileclose(fhw);
  deletefile(tempfilename);
  end;
ptime:=-2;
for i:=-1 to maxchannel do
  begin
  indeksy[i]:=0;
  indeksy2[i]:=0;
  fwsk:=fsr[i].next;
  fwsk2:=fwsk;
  while fwsk<>@lsr[i] do
    begin
    fwsk:=fwsk^.next;
    dispose(fwsk2);
    fwsk2:=fwsk;
    end;
  fsr[i].next:=@lsr[i];
  lsr[i].last:=@fsr[i];
  clearstate(state);
  clearstate(vstate);
  clearstate(state2);
  end;
check6:=0;
end;


function run2(new,l1,l2,start,len2,depth:integer):integer;

// wersja rekurencyjna
// if new, then inicjuj tabele else dopisuj do tego co jest
// l1 - pierwsza linijka do interpretacji
// l2 - ostatnia
// start: czas od którego bedą wstawiane polecenia
// len: czas trwania melodii

label p001,p199,p999,p299,p399;

var wsk,trackwsk:PProgline;
    arg,l,str:string;
    i,q:integer;
    chnum:integer;
    time,fq,freq2,freq:double;
    defchn,oldwave,oldadsr,vol,len,pause:integer;
    ll1,ll2,t1,t2,oldctime,num,ctime,id,t,tracktime,tracknum:integer;
    chtime:array[0..maxchannel] of integer;
    newpause:integer;
    qq:boolean;
    j,p1,p2,p3,p4,p5,p6,p7,p8,p9:integer;
    count:integer; //debug

begin
count:=0;
time:=start;
p001:
if new=1 then
  begin
  for i:=0 to maxchannel do chtime[i]:=0;
  defchn:=1;
  oldwave:=-2;
  oldadsr:=-2;
  stop(0);
  wsk:=@pierwsza;
  starttrack;
  maxtime:=0;
  end
else
// nie od początku, znajdź linię
  begin
  wsk:=@pierwsza;
  repeat
    wsk:=wsk^.next;
  until (wsk^.next=nil) or (wsk^.linenum>=l1);
  if wsk^.next=nil then goto p999; // wypad jeśli pusto lub nie znaleziona linia
  wsk:=wsk^.last; //cofnij o jedną, bo zaraz w repeat pójdzie znów do przodu
  end;
repeat
  wsk:=wsk^.next;
  if wsk^.next<>nil then
    begin
    l:=wsk^.line;
    str:=inttostr(wsk^.linenum);
    getarg(0,l,arg);   //cmd

    if lowercase(arg)='track' then

//-----------------------track
// zignorować wszystko po słowie kluczowym track; do "end" lub nowego "track"

      begin
      repeat
        wsk:=wsk^.next;
        if wsk^.next<>nil then
          begin
          l:=wsk^.line;
          getarg(0,l,arg);
          end;
      until (wsk^.next=nil) or (lowercase(arg)='track') or (lowercase(arg)='end') ;
      if lowercase(arg)='track' then wsk:=wsk^.last;
      goto p199;
      end;

    if lowercase(arg)='wait' then

//-----------------wait

      begin
      getarg(1,l,arg);  // time
      q:=strtoint(arg);
      fq:=5*speed*q;
      time+=fq;
      goto p199;
      end;

    if lowercase(arg)='speed' then

//-----------------speed

      begin
      getarg(1,l,arg);  // speed
      fq:=strtofloat(arg);
      speed:=fq;
      goto p199;
      end;

//----------------mod

    if lowercase(arg)='mod' then
      begin
      getarg(1,l,arg);
      q:=strtoint(arg);
      addchannel3(-1,round(time),7,q,0,0,0,0,depth); // mod
      end;

//----------------pan

    if lowercase(arg)='pan' then
      begin
      getarg(1,l,arg);
      q:=strtoint(arg);
      getarg(5,l,arg);
      p2:=strtoint(arg);
      addchannel3(-1,round(time),9,q,p2,0,0,0,depth); // pan
      end;


//----------------gain

    if lowercase(arg)='gain' then
      begin
      getarg(1,l,arg);
      q:=round(1000*strtofloat(arg));
      addchannel3(-1,round(time),8,q,0,0,0,0,depth); // gain
      end;


//-----------------echo

     if lowercase(arg)='echo' then
      begin
      p1:=-2;
      p2:=-2;
      p3:=0;
      q:=getarg(2,l,arg);
      if q<>-1 then if arg='off' then
        begin
        p3:=-2;
        goto p399;
        end;
      getarg(1,l,arg);
      p1:=strtoint(arg); //slave
      getarg(5,l,arg);
      chnum:=strtoint(arg);  //master
      getarg(6,l,arg);
      p2:=round(strtofloat(arg));
      p2:=round(speed*5*p2);
p399:
 //     addchannel3(chnum,time,6,p1,p2,p3,0,0,depth); //6 - echo
      if p3<>-2 then
        begin
        echotable[p1].channel:=chnum;
        echotable[p1].delay:=p2;
        end
      else
        for j:=-1 to maxchannel do
          begin
           echotable[j].channel:=-2;
           echotable[j].delay:=0;
           end;

      goto p199;
      end;





//------------------int

     if lowercase(arg)='int' then
      begin
      getarg(1,l,arg);
      p1:=strtoint(arg); //slave
      getarg(5,l,arg);
      chnum:=strtoint(arg);  //master
      getarg(6,l,arg);
      p2:=round(1000*strtofloat(arg));
      addchannel3(chnum,round(time),5,p1,p2,0,0,0,depth); //5 - int
//      for i:=-1 to maxchannel do if echotable[i].channel=chnum then addchannel3(i,time+echotable[i].delay,5,p1,p2,0,0,0,depth);
//      todo :check if int+echo ma jakiś sens
      goto p199;
      end;



    if lowercase(arg)='vib' then

//-----------------vib

      begin
      p1:=-2;
      p2:=-2;
      p3:=-2;
      p4:=-2;
      p5:=-2;

      getarg(1,l,arg);  // chnum
      chnum:=strtoint(arg);
      q:=getarg(2,l,arg);
      if q<>-1 then
        begin
        if arg<>'off' then
          begin
          setwave(chnum+2*maxchannel,arg);
          p1:=vdefaults[chnum].sample;
          end
        else goto p299; //  vib off
        end;
      q:=getarg(3,l,arg);
      if q<>-1 then
        begin
        setadsr(chnum+2*maxchannel,arg);
        p2:=vdefaults[chnum].adsr;
        end;
      q:=getarg(5,l,arg);
      if q<>-1 then
        begin
        p3:=strtoint(arg);     //TODO: float p3; if int p3 then atari
        if p3<10 then p3:=round(1.25*power(2,p3));  // odchyłka w Hz dla vib
        end;
      q:=getarg(6,l,arg);
      if q<>-1 then
        begin
        p4:=strtoint(arg); //okres vib w ms
        p4:=round(5*speed*strtoint(arg));
        end;
      q:=getarg(7,l,arg);
      if q<>-1 then
        begin
        p5:=round(5*speed*strtoint(arg));
        end;

      p299:
      addchannel3(chnum,round(time),4,p1,p2,p3,p4,p5,depth); //cmd 4=vib
      for i:=-1 to maxchannel do if echotable[i].channel=chnum then addchannel3(i,round(time)+echotable[i].delay,4,p1,p2,p3,p4,p5,depth);
      goto p199;
      end;




    if lowercase(arg)='set' then

//-----------------set

      begin
      p1:=-2;
      p2:=-2;
      p3:=-2;
      p4:=-2;
      p5:=-2;

      getarg(1,l,arg);  // chnum
      chnum:=strtoint(arg);
      q:=getarg(2,l,arg);
      if q<>-1 then
        begin
        setwave(chnum,arg);
        p1:=defaults[chnum].sample;
        end;
      q:=getarg(3,l,arg);
      if q<>-1 then
        begin
        setadsr(chnum,arg);
        p2:=defaults[chnum].adsr;
        end;
      q:=getarg(5,l,arg);
      if q<>-1 then
        begin
        q:=strtoint(arg);
        defaults[chnum].vol:=q;
        if q<16 then defaults[chnum].vol:=2000*strtoint(arg);
        p4:=defaults[chnum].vol;
        end;
      q:=getarg(6,l,arg);
      if q<>-1 then
        begin
        defaults[chnum].len:=round(5*speed*strtoint(arg));
        p5:=defaults[chnum].len;
        end;
      q:=getarg(7,l,arg);
      if q<>-1 then
        begin
        defaults[chnum].pause:=round(5*speed*strtoint(arg));
        end;
      addchannel3(chnum,round(time),2,p1,p2,p3,p4,p5,depth);
      for i:=-1 to maxchannel do if echotable[i].channel=chnum then addchannel3(i,round(time)+echotable[i].delay,2,p1,p2,p3,p4,p5,depth);
      goto p199;
      end;


    if lowercase(arg)='play' then

//----------------play

      begin

      p1:=-2;
      p2:=-2;
      p3:=-2;
      p4:=-2;
      p5:=-2;
      p6:=-2;
      p7:=-2;
      p8:=0;
      p9:=0;

      getarg(1,l,arg);  // chnum
      if arg<>'' then chnum:=strtoint(arg) else chnum:=defchn;
      if chnum>maxchannel then chnum:=defchn else defchn:=chnum;
      q:=getarg(2,l,arg);
      if q<>-1 then
        begin
        oldwave:=defaults[chnum].sample;
        setwave(chnum,arg);
        p1:=defaults[chnum].sample;
        defaults[chnum].sample:=oldwave;
        end;
      q:=getarg(3,l,arg);
      if q<>-1 then
        begin
        oldadsr:=defaults[chnum].adsr;
        setadsr(chnum,arg);
        p2:=defaults[chnum].adsr;
        defaults[chnum].adsr:=oldadsr;
        end;
      q:=getarg(5,l,arg);
      if q<>-1 then
        begin
        vol:=strtoint(arg);
        if vol<16 then vol:=2000*strtoint(arg);
        p4:=vol;
        end
      else vol:=defaults[chnum].vol;
      q:=getarg(6,l,arg);
      if q<>-1 then
        begin
        len:=round(5*speed*strtoint(arg));
        p5:=len;
        end
      else len:=defaults[chnum].len;
      q:=getarg(7,l,arg);
      if q<>-1 then
        begin
        pause:=round(5*speed*strtoint(arg));
        end
      else pause:=defaults[chnum].pause;
      q:=getarg(4,l,arg); //freq
      if q<>-1 then
        begin
        freq:=(strtofloat(arg));
        defaults[chnum].freq:=freq;
        p3:=trunc(1000*freq);
        end
      else freq:=defaults[chnum].freq;

      q:=getarg(8,l,arg); //gliss freq
      if q<>-1 then
        begin
        freq2:=(strtofloat(arg));
        p6:=trunc(1000*freq2);
        end;

      q:=getarg(9,l,arg);
      if q<>-1 then
        begin
        p7:=round(5*speed*strtoint(arg));
        p9:=p7;
        freq2:=(freq2-freq)/p7; //  Hz/s
        p7:=round(1000000*freq2);  //mHz/s
        end;

      q:=getarg(10,l,arg);
      if q<>-1 then
        begin
        p8:=strtoint(arg); // gliss par 2
        end;


      // now add to queue

      addchannel3(chnum,round(time),1,p1,p2,p3,p4,p5,depth);            //cmd=1: play
      for i:=-1 to maxchannel do if echotable[i].channel=chnum then addchannel3(i,round(time)+echotable[i].delay,1,p1,p2,p3,p4,p5,depth);
      if p6>0 then
        begin
        addchannel3(chnum,round(time),3,p6,p7,p8,p9,0,depth); //cmd=3: gliss; gliss ma być ostatnia;
        // gliss:  p6:gliss end freq, p7:gliss speed, p8: gliss sq fun dep, p9: gliss time
        for i:=-1 to maxchannel do if echotable[i].channel=chnum then addchannel3(i,round(time)+echotable[i].delay,3,p6,p7,p8,p9,0,depth);
        end;
      time:=time+pause;
      goto p199;
      end;

    if lowercase(arg)='tron' then

// tron !!!
// (1) get current time
// (2) find troff
// (3) count time to troff
// (4) find track
// (5) interpret all command from track with local time until time for troff

      begin
// #1, #2, #3
      getarg(1,l,arg);
      tracknum:=strtoint(arg);
      tracktime:=round(time);
      trackwsk:=wsk;
      qq:=false;
      d:=defaults; //lokalne defaulty
      repeat

      trackwsk:=trackwsk^.next;
        if trackwsk^.next<>nil then
          begin
          l:=trackwsk^.line;
          getarg(0,l,arg);
          if lowercase(arg)='wait' then
            begin
            getarg(1,l,arg);
            tracktime+=round(5*speed*strtoint(arg));
            end;

          if lowercase(arg)='set' then

            begin
            getarg(1,l,arg);  // chnum
            chnum:=strtoint(arg);
            q:=getarg(7,l,arg);
            if q<>-1 then
              begin
              d[chnum].pause:=round(5*speed*strtoint(arg));
              end;
            end;

          if lowercase(arg)='play' then
            begin
            getarg(1,l,arg);
            if arg<>'' then chnum:=strtoint(arg) else chnum:=defchn;
            getarg(7,l,arg);
            if arg<>'' then
              begin
              q:=strtoint(arg);
              q:=round(5*speed*q);
              tracktime+=q;
              end
            else tracktime+=d[chnum].pause;
            end;
          if lowercase(arg)='troff' then
            begin
            getarg(1,l,arg);
            if arg<>'' then num:=strtoint(arg);
            if num=tracknum then qq:=true;
            end;
          if lowercase(arg)='track' then qq:=true;


          end;
      until (trackwsk^.next=nil) or qq;

// #4: find track def;
      trackwsk:=@pierwsza;
      qq:=false;
      repeat
      trackwsk:=trackwsk^.next;
      if trackwsk^.next<>nil then
        begin
        l:=trackwsk^.line;
        str:=inttostr(trackwsk^.linenum);
        getarg(0,l,arg);   //cmd
        end;
        if lowercase(arg)='track' then
          begin
          getarg(1,l,arg);
          num:=strtoint(arg);
          if num=tracknum then qq:=true;// start track found !!!
          end;
      until qq or (trackwsk^.next=nil);

      if qq then

        begin
// #5: interpret track !!!
        trackwsk:=trackwsk^.next; // omiń 'track'
        ll1:=trackwsk^.linenum;
        t1:=round(time);
        t2:=round(tracktime-time);
// znajdź koniec

        qq:=false;
        l:=trackwsk^.line;
        getarg(0,l,arg);
        if(arg='wait') or (arg='play') then qq:=true;
        repeat
          trackwsk:=trackwsk^.next;
          l:=trackwsk^.line;
          getarg(0,l,arg);
          if (arg='wait') or (arg='play') then  qq:=true;
        until (trackwsk^.next=nil) or (lowercase(arg)='end') or (lowercase(arg)='track');
        trackwsk:=trackwsk^.last; // nie interpretuj enda albo linii 999999
        ll2:=trackwsk^.linenum;
        // if not qq then tracktime=0... do not let it run
        if qq then maxtime:=run2(0,ll1,ll2,t1,t2,depth+1); // bum, bum, rekurencja!!!!!!!!!
        end;
      goto p199;
      end;
    end;
    p199:

// if new=1 then repeat until nil. If not, repeat until time=t1+t2.

until (wsk^.next=nil) or ((new=0) and ((time>=start+len2) or (wsk^.linenum>=l2)));
if new=1 then
  begin
  if time>maxtime then maxtime:=round(time);
  endtrack(maxtime);
  gain:=1;
  for i:=-1 to maxchannel do g2[i]:=1;
  play:=true;
  goto p999;
  end
else
  if time>=start+len2 then
    goto p999
  else
    goto p001;

p999:
if time>maxtime then maxtime:=round(time);
result:=maxtime;
end;


function progadd(pn:integer;ss:TStrings;nn:TNums):integer;

label p100,p101,p102,p103,p104,p105,p106,p107,p108,p109,p110,p111,p112,p113,p114,p198,p199,p200,p300,p500,
      p510,p520,p530,p540,p550,p560,p565,p570,p580,p590,p600,p610,p620,p630;

var i,glis,chnum,line:integer;
    str,chstr:string;


begin

if pn=1 then goto p101;
if ss[1]=';' then goto p560; // comment
if ss[1]='?' then goto p565; // ?
if lowercase(ss[1])='vib' then goto p600;
if lowercase(ss[1])='kw' then goto p199;
if lowercase(ss[1])='echo' then goto p580;
if lowercase(ss[1])='phas' then goto p199;
if lowercase(ss[1])='tron' then goto p530;
if lowercase(ss[1])='troff' then goto p540;
if lowercase(ss[1])='end' then goto p510;
if lowercase(ss[1])='speed' then goto p550;
if lowercase(ss[1])='wait' then goto p520;
if lowercase(ss[1])='track' then goto p500;
if lowercase(ss[1])='int' then goto p570;
if lowercase(ss[1])='mod' then goto p590;
if lowercase(ss[1])='set' then goto p200;
if lowercase(ss[1])='play' then goto p100;
if lowercase(ss[1])='gain' then goto p610;
if lowercase(ss[1])='off' then goto p620;
if lowercase(ss[1])='pan' then goto p630;

if nn[1]<>-1 then goto p300;
// polecenie nie rozpoznane i nn[1]=-1 -> play default, freq


for i:=13 downto 1 do
  begin
  nn[i]:=nn[i-1] ;
  ss[i]:=ss[i-1] ;
  end;
nn[1]:=maxchannel+1;
chnum:=maxchannel+1;
inc(pn);
goto p300;

p100: //play

dec(pn);
for i:=1 to 13 do
  begin
  nn[i]:=nn[i+1];
  ss[i]:=ss[i+1];
  end;

p300: //play - shortcut

line:=round(nn[0]);
if nn[1]<>-1 then chnum:=round(nn[1]) ;
if chnum>maxchannel then goto p199;
str:='';
setarg(0,str,'play');
setarg(1,str,inttostr(chnum));

// check for '>'

i:=1;
glis:=0;
repeat inc(i) until (nn[i]=-2) or (i>13);
if nn[i]=-2 then
  begin
  pn:=i; //TODO: add effect '>' decode
  glis:=i;
  end;

if (pn=2) and (nn[1]>-1) then goto p102;
if (pn=3) and (nn[1]>-1) and (nn[2]=-1) then goto p103;
if (pn=4) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]<>-1) then goto p104;
if (pn=5) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]<>-1) and (nn[4]<>-1) then goto p105;
if (pn=6) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]<>-1) and (nn[4]<>-1) and (nn[5]<>-1) then goto p106;

if (pn=4) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]=-1) then goto p107;
if (pn=5) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]=-1) then goto p108;
if (pn=6) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]=-1) and (nn[5]<>-1) then goto p109;
if (pn=7) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]=-1) and (nn[5]<>-1) and (nn[6]<>-1) then goto p110;
if (pn=8) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]=-1) and (nn[5]<>-1) and (nn[6]<>-1) and (nn[7]<>-1) then goto p111;

if (pn=5) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]<>-1) then goto p112;
if (pn=6) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]<>-1) and (nn[5]<>-1) then goto p113;
if (pn=7) and (nn[1]>-1) and (nn[2]=-1) and (nn[3]=-1) and (nn[4]<>-1) and (nn[5]<>-1) and (nn[6]<>-1) then goto p114;


goto p199;

p101:
line:=round(nn[0]);
deleteline(line);
goto p199;

p102: //linenum, chn
goto p198;

p103: //linenum, chn, freq

nn[2]:=decodesound(ss[2]);
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
goto p198;

p104: //linenum, chn, freq, pause

nn[2]:=decodesound(ss[2]);
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(7,str,inttostr(round(nn[3])));
goto p198;

p105: //linenum, chn, freq, len, pause

nn[2]:=decodesound(ss[2]);
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(6,str,inttostr(round(nn[3])));
setarg(7,str,inttostr(round(nn[4])));
goto p198;

p106: //linenum, chn, freq, vol, len, pause

nn[2]:=decodesound(ss[2]);
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(5,str,inttostr(round(nn[3])));
setarg(6,str,inttostr(round(nn[4])));
setarg(7,str,inttostr(round(nn[5])));
goto p198;

p107: //linenum, chn, freq, wave

nn[2]:=decodesound(ss[2]);
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(2,str,ss[3]);
goto p198;


p108: //linenum, chn, freq, wave, adsr

nn[2]:=decodesound(ss[2]);
if ss[14]=',' then ss[3]:='';
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(2,str,ss[3]);
setarg(3,str,ss[4]);
goto p198;


p109: //linenum, chn, freq, wave, adsr, pause

nn[2]:=decodesound(ss[2]);
if ss[14]=',' then ss[3]:='';
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(2,str,ss[3]);
setarg(3,str,ss[4]);
setarg(7,str,inttostr(round(nn[5])));
goto p198;

p110: //linenum, chn, freq, wave, adsr, len, pause

nn[2]:=decodesound(ss[2]);
if ss[14]=',' then ss[3]:='';
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(2,str,ss[3]);
setarg(3,str,ss[4]);
setarg(6,str,inttostr(round(nn[5])));
setarg(7,str,inttostr(round(nn[6])));
goto p198;

p111: //linenum, chn, freq, wave, adsr, vol, len, pause

nn[2]:=decodesound(ss[2]);
if ss[14]=',' then ss[3]:='';
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(2,str,ss[3]);
setarg(3,str,ss[4]);
setarg(5,str,inttostr(round(nn[5])));
setarg(6,str,inttostr(round(nn[6])));
setarg(7,str,inttostr(round(nn[7])));
goto p198;

p112: //linenum, chn, freq, wave, pause

nn[2]:=decodesound(ss[2]);
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(2,str,ss[3]);
setarg(7,str,inttostr(round(nn[4])));
goto p198;

p113: //linenum, chn, freq, wave, len, pause

nn[2]:=decodesound(ss[2]);
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(2,str,ss[3]);
setarg(6,str,inttostr(round(nn[4])));
setarg(7,str,inttostr(round(nn[5])));
goto p198;

p114: //linenum, chn, freq, wave, vol, len, pause

nn[2]:=decodesound(ss[2]);
chstr:=floattostrf(nn[2],fffixed,20,3);
setarg(4,str,chstr);
setarg(2,str,ss[3]);
setarg(5,str,inttostr(round(nn[4])));
setarg(6,str,inttostr(round(nn[5])));
setarg(7,str,inttostr(round(nn[6])));
goto p198;

p198:
if glis>0 then
  begin
  ss[glis]:=copy(ss[glis],2,length(ss[glis])-1);
  nn[glis]:=decodesound(ss[glis]);
  setarg(8,str,floattostrf(nn[glis],fffixed,20,3));
  if nn[glis+1]<>-1 then setarg (9,str,inttostr(round(nn[glis+1])));
  if nn[glis+2]<>-1 then setarg (10,str,inttostr(round(nn[glis+2])));
  end;
addline(line,str);
goto p199;

p200: //set
line:=round(nn[0]);
setcmd(pn,ss,nn,false);
addline(line,ss[0]);
goto p199;

p500: //track
line:=round(nn[0]);
if nn[2]<>-1 then
  begin
  setarg(0,str,'track');
  setarg(1,str,inttostr(round(nn[2])));
  addline(line,str);
  end;
goto p199;

p510: //end
line:=round(nn[0]);
setarg(0,str,'end');
addline(line,str);
goto p199;

p520: //wait
line:=round(nn[0]);
if nn[2]<>-1 then
  begin
  setarg(0,str,'wait');
  setarg(1,str,inttostr(round(nn[2])));
  addline(line,str);
  end;
goto p199;

p530: //tron
line:=round(nn[0]);
if nn[2]<>-1 then
  begin
  setarg(0,str,'tron');
  setarg(1,str,inttostr(round(nn[2])));
  addline(line,str);
  end;
goto p199;

p540: //troff
line:=round(nn[0]);
if nn[2]<>-1 then
  begin
  setarg(0,str,'troff');
  setarg(1,str,inttostr(round(nn[2])));
  addline(line,str);
  end;
goto p199;

p550: //speed
line:=round(nn[0]);
if nn[2]<>-1 then
  begin
  setarg(0,str,'speed');
  chstr:=floattostrf(nn[2],fffixed,20,3);
  setarg(1,str,chstr);
  addline(line,str);
  end;
goto p199;

p560: //comment
line:=round(nn[0]);
  begin
  setarg(0,str,';');
  for i:=2 to 10 do setarg(i+3,str,ss[i]);
  addline(line,str);
  end;
goto p199;

p565: //?
line:=round(nn[0]);
  begin
  setarg(0,str,'?');
  for i:=2 to 10 do setarg(i+3,str,ss[i]);
  addline(line,str);
  end;
goto p199;

p570: //int
line:=round(nn[0]);
  begin
  setarg(0,str,'int');
  setarg(1,str,inttostr(round(nn[2])));
  setarg(5,str,inttostr(round(nn[3])));
  chstr:=floattostrf(nn[4],fffixed,20,3);
  setarg(6,str,chstr);
  addline(line,str);
  end;
goto p199;

p580: //echo

//ver 1: echo chn,chn,delay
//ver 2: echo off

line:=round(nn[0]);
if pn=3 then
  begin
  setarg(0,str,'echo');
  setarg(2,str,'off');
  addline(line,str);
  end;
if pn=5 then
  begin
  setarg(0,str,'echo');
  setarg(1,str,inttostr(round(nn[2])));
  setarg(5,str,inttostr(round(nn[3])));
  setarg(6,str,inttostr(round(nn[4])));
  addline(line,str);
  end;
goto p199;



p590: //mod
line:=round(nn[0]);
if pn=3 then
  begin
  setarg(0,str,'mod');
  setarg(1,str,inttostr(round(nn[2])));
  addline(line,str);
  end;
goto p199;

p610: //gain
line:=round(nn[0]);
if pn=3 then
  begin
  setarg(0,str,'gain');
  chstr:=floattostrf(nn[2],fffixed,20,3);
  setarg(1,str,chstr);
  addline(line,str);
  end;
goto p199;


p600: //vib
// ver 1: vib chn,wave,depth,length
// ver 2: vib chn,wave,adsr,depth,wave length,adsr length
// ver 3: vib chn,off

line:=round(nn[0]);
if pn=4 then
  begin     //ver 1
  setarg(0,str,'vib');
  setarg(1,str,inttostr(round(nn[2])));
  setarg(2,str,'off');
  addline(line,str);
  end;
if pn=6 then
  begin     //ver 1
  setarg(0,str,'vib');
  setarg(1,str,inttostr(round(nn[2])));
  setarg(2,str,ss[3]);
  setarg(5,str,inttostr(round(nn[4])));
  setarg(6,str,inttostr(round(nn[5])));
  addline(line,str);
  end;
if pn=8 then
  begin     //ver 2
  setarg(0,str,'vib');
  setarg(1,str,inttostr(round(nn[2])));
  setarg(2,str,ss[3]);
  setarg(3,str,ss[4]);
  setarg(5,str,inttostr(round(nn[5])));
  setarg(6,str,inttostr(round(nn[6])));
  setarg(7,str,inttostr(round(nn[7])));
  addline(line,str);
  end;

goto p199;


p620: //off
line:=round(nn[0]);
if pn=3 then
  begin
  setarg(0,str,'off');
  setarg(1,str,inttostr(round(nn[2])));
  addline(line,str);
  end;
goto p199;

p630: //pan
line:=round(nn[0]);
if pn=4 then
  begin
  setarg(0,str,'pan');
  setarg(1,str,inttostr(round(nn[2])));
  setarg(5,str,inttostr(round(nn[3])));
  addline(line,str);
  end;
goto p199;


p199:
//list(0,999999,1);
end;

procedure correctcomment(var a:string);

var b,c1,c2:string;
    i:integer;
// changes '?' to ';'
// if there is no space after '?' or ';', adds one

begin
if length(a)>=2 then
  begin
  b:='';
  for i:=1 to length(a)-1 do
    begin
    c1:=copy(a,i,1);
    c2:=copy(a,i+1,1);
    if c1='?' then c1:=';';
    if (c1=';') and (c2<>' ') then c1:='; ';
    b+=c1;
    end;
  b+=c2;
  end
else
  begin
  if (copy(a,1,1)=';') or (copy(a,1,1)='?') and (copy (a,2,1)<>' ') then b:='; '+copy (a,2,1) else b:=a;
  end;
a:=b;
end;

function interpret(a:string;mode:boolean):integer;

var ss:TStrings;
nn:TNums;
chnum,i,j,err,err2:integer;
fh,found:integer;
bufor:array[0..256] of byte;
s:string;

begin
correctcomment(a);
err:=split(a,ss);
strstonums(ss,nn);


if nn[0]<>-1 then err2:=progadd(err,ss,nn);  // add line to program

if lowercase(ss[0])='new' then newcmd(mode); //polecenie new

if lowercase(ss[0])='set' then err2:=setcmd(err,ss,nn,true); // polecenie set

if lowercase(ss[0])='list' then list(round(nn[1]),round(nn[2]),0); //testuj!!

if lowercase(ss[0])='ren' then renum;

if ss[0]='play' then

  // play (run program)               err=1
  // play linenum                     err=2; nn[2]>0
  // play ch,sound                    err=3; nn[2]=-1
  // play ch,freq                     err=3; nn[2]>0
  // play ch,sound,len                err=4; nn[2]=-1; nn[3]>0
  // play ch,freq,len                 err=4; nn[2]>0;  nn[3]>0
  // play ch,sound,vol,len            err=5; nn[2]=-1; nn[3]>-0; nn[4]>0
  // play ch,freq,vol,len             err=5; nn[2]>0
  // set ch,wave,adsr lub ch,,adsr    err=4; nn[2]=-1; nn[3]=-1; if ss[14]=',' pomijać ustawianie fali
  // set ch,wave,adsr,pause           err=5; nn[2]=-1; nn[3]=-1; nn[4]=pause
  // set ch,wave,adsr,len,pause       err=6; nn[2]=-1; nn[3]=-1; nn[4]=len; nn[5]=pause
  // set ch,wave,adsr,vol,len,pause   err=7; nn[2]=-1; nn[3]=-1; nn[4]=vol; nn[5]=len; nn[6]=pause
  // set ch,pause                     err=3; nn[2]=pause
  // set ch,len,pause                 err=4; nn[2]=len; nn[3]=pause;
  // set ch,vol,len,pause             err=5; nn[2]=vol; nn[3]=len; nn[4]=pause;


  begin
  if err=1 then
    begin
    run2(1,0,999999,0,0,0);
    end;
  if err=2 then
    begin
    //zagraj utwór od linii
    end;
  if err=3 then
    begin
    if (nn[1]<>-1) and (nn[2]<>-1) and (ss[15]='''') then
      //zagraj dzwiek, chn. nn[2], freq nn[3]
      begin
      chnum:=trunc(nn[1]);
      stop(0);
      starttrack;
      addchannel3(chnum,0,1,defaults[chnum].sample,defaults[chnum].adsr,trunc(1000*nn[2]),defaults[chnum].vol,defaults[chnum].len,0);
      endtrack(defaults[chnum].len);
      play:=true;
      end;
    if (nn[1]<>-1) and (nn[2]=-1) then
      //zagraj dzwiek, chn. nn[2], freq nn[3]
      begin
      chnum:=trunc(nn[1]);
      nn[2]:=decodesound(ss[2]);
      stop(0);
      starttrack;
      addchannel3(chnum,0,1,defaults[chnum].sample,defaults[chnum].adsr,trunc(1000*nn[2]),defaults[chnum].vol,defaults[chnum].len,0);
      endtrack(defaults[chnum].len);
      play:=true;
      end;
    end;
    if err=4 then
    begin
    if (nn[1]<>-1) and (nn[2]<>-1) and (nn[3]<>-1) and (ss[15]='''') then
      //zagraj dzwiek, chn. nn[1], freq nn[2], len nn[3];
      begin
      chnum:=trunc(nn[1]);
      stop(0);
      starttrack;
      addchannel3(chnum,0,1,defaults[chnum].sample,defaults[chnum].adsr,trunc(1000*nn[2]),defaults[chnum].vol,trunc(nn[3]),0);
      endtrack(trunc(nn[3]));
      play:=true;
      end;
    if (nn[1]<>-1) and (nn[2]=-1) and (nn[3]<>-1)  then
      //zagraj dzwiek, chn. nn[1], freq nn[2], len nn[3];
      begin
      chnum:=trunc(nn[1]);
      nn[2]:=decodesound(ss[2]);
      stop(0);
      starttrack;
      addchannel3(chnum,0,1,defaults[chnum].sample,defaults[chnum].adsr,trunc(1000*nn[2]),defaults[chnum].vol,trunc(nn[3]),0);
      endtrack(trunc(nn[3]));
      play:=true;
      end;

    end;

  end;

end;


function teststop:boolean;

var i,j:integer;
quit5:boolean;

begin

quit5:=true;
if realtime then quit5:=false;
for i:=-1 to maxchannel do
  begin
  if (csr[i]<>@lsr[i]) and (fsr[i].next<>@lsr[i]) then quit5:=false;
  end;
result:=quit5;
end;

procedure AudioCallback(userdata:pointer; audio:Pbyte; length:integer); cdecl;

label p101,p102,p110,p109,p209,p210;

var freq,a1,a2,i,j,k:integer;
    sample:smallint;
    audio2:Psmallint;
    s:TSample;
    err:integer;
    channel:integer;
    bcn:TBigSample;
    spl:array[-1..maxchannel] of TSample;
    maxi,g2:double;
    spl_len:integer;
    old_ptime,new_ptime:integer;
    cmd,p1,p2,p3,p4,p5:integer;
    qq:boolean;
    vfreq:double;
    bufor:array[0..65535] of byte;


begin
test:=trunc(ptime); //test;
audio2:=PSmallint(audio);


if pause or (not play) then // wypełnij zerami i uciekaj :)
  begin
  for k:=0 to (length div 4)-1 do
    begin
      audio2[2*k]:=0;
      audio2[2*k+1]:=0;
    end;
  goto p102;
  end;

// skoro nie uciekł, to gra...



for k:=0 to (length div 4)-1 do
  begin
  if play then begin
  old_ptime:=trunc(ptime);
  ptime:=ptime+0.02267573696145124717; //milisekundy
  new_ptime:=trunc(ptime);

  if (not realtime) and play and (old_ptime<>new_ptime) then // zmiana całej milisekundy - sprawdź tablice
    begin
    if teststop then
      begin
      stop(1);
      goto p110;
      end;

    // tu sprawdzanie czy nie trzeba przejść dalej i czy jest co grać; ew. przechodzenie na nast. pozycję
    for i:=-1 to maxchannel do
      begin
      if fsr[i].next=@lsr[i] then goto p210; //pusty kanał
      if csr[i]^.next=@lsr[i] then
        begin
        csr[i]:=@lsr[i];
        goto p210; // stoi na końcu
        end;
      if (csr[i]^.next=nil) then goto p210;
      if (csr[i]^.next^.time<=ptime) then
        begin
        repeat
          csr[i]:=csr[i]^.next;
          cmd:=csr[i]^.command;
          if cmd=1 then // play
            begin
            state2[i]:=state[i];
            if csr[i]^.p1<>-2 then state2[i].sample:=csr[i]^.p1 else state2[i].sample:=defaults[i].sample;  //channel
            if csr[i]^.p2<>-2 then state2[i].adsr:=csr[i]^.p2 else state2[i].adsr:=defaults[i].adsr;  //adsr
            if csr[i]^.p3<>-2 then state2[i].freq:=csr[i]^.p3/1000 else state2[i].freq:=defaults[i].freq; //freq
            if csr[i]^.p4<>-2 then state2[i].vol:=csr[i]^.p4/32768 else state2[i].vol:=defaults[i].vol/32768; //vol
            if csr[i]^.p5<>-2 then state2[i].len:=round(csr[i]^.p5*44.1) else state2[i].len:=round(44.1*defaults[i].len); //len
            state2[i].normfreq:=state2[i].freq*norm44;
            state2[i].samplenum:=0;
            state2[i].spos:=0;
            state2[i].apos:=0;        // chyba niepotrzebnie
            state2[i].transition:=4; // 1 ms transition time;
            state2[i].trans_delta:=1/state2[i].transition; // delta gain for transition
            state2[i].vib_dev:=0;
            state2[i].gliss_dev:=0;
            state2[i].intchn:=-2;
            state2[i].intfreq:=0;
            state2[i].gliss_df:=0;
            state2[i].gliss_par2:=0;

   {
            for j:=-1 to maxchannel do if inttable[j].channel2=i then
              begin
              inttable[j].freq:=0;
              inttable[j].channel1:=-2;
              inttable[j].channel2:=-2;
              vstate[i].vol:=0;
              end;
            if inttable[i].channel2<>-2 then
              begin
              j:=inttable[i].channel2;
              state2[j].sample:=defaults[j].sample;  //channel
              state2[j].adsr:=defaults[j].adsr;  //adsr
              state2[j].freq:=state2[i].freq+inttable[i].freq; //freq
              state2[j].vol:=state2[i].vol; //vol
              state2[j].len:=state2[i].len; //len
              state2[j].normfreq:=state2[j].freq*norm44;
              state2[j].samplenum:=0;
              state2[j].spos:=0;
              state2[j].apos:=0;        // chyba niepotrzebnie
              state2[j].transition:=441; // 1 ms transition time;
              state2[j].trans_delta:=1/state2[i].transition; // delta gain for transition
              state2[j].vib_dev:=0;
              state2[j].gliss_dev:=state2[i].gliss_dev;   //todo poprawić... !!!
              vstate[j]:=vstate[i];
              end;   }

            goto p209;
            end;

          if cmd=2 then //set
            begin
            if csr[i]^.p1<>-2 then
              begin
              defaults[i].sample:=csr[i]^.p1;
              end;
            if csr[i]^.p2<>-2 then
              begin
              defaults[i].adsr:=csr[i]^.p2;
              end;
            if csr[i]^.p4<>-2 then
              begin
              defaults[i].vol:=csr[i]^.p4;
              end;
            if csr[i]^.p5<>-2 then
              begin
              defaults[i].len:=csr[i]^.p5;
              end;
            goto p209;
            end;

          if cmd=3 then   //glis
            begin

            if csr[i]^.p2<>-2 then
              begin
              p5:=csr[i]^.p2;
              state2[i].gliss_dev:=0.001*norm44*csr[i]^.p2/44100;
              state2[i].gliss_par2:=csr[i]^.p3;
              state2[i].gliss_time:=csr[i]^.p4;
              state2[i].gliss_df:=sqr(csr[i]^.p4/2000);
              end;

            goto p209;
            end;

          if cmd=4 then //vib
            begin
            if csr[i]^.p1<>-2 then vstate[i].sample:=csr[i]^.p1 else vstate[i].sample:=vdefaults[i].sample;  //channel
            if csr[i]^.p2<>-2 then vstate[i].adsr:=csr[i]^.p2 else vstate[i].adsr:=-2;  //adsr
            if csr[i]^.p3<>-2 then vstate[i].vol:=csr[i]^.p3/32768 else vstate[i].vol:=0;  //vol
            if csr[i]^.p4<>-2 then
              begin
              vfreq:=1000/csr[i]^.p4;
              vstate[i].freq:=vfreq;
              vstate[i].normfreq:=norm44*vfreq;
              end
            else vstate[i].freq:=0; //freq

            if csr[i]^.p5<>-2 then vstate[i].len:=round(csr[i]^.p5*44.1) else vstate[i].len:=maxint; //len
            vstate[i].samplenum:=0;
            vstate[i].spos:=0;
            vstate[i].apos:=0;        // chyba niepotrzebnie
            goto p209;
            end;

          if cmd=5 then //int
            begin
            j:=csr[i]^.p1;
            state[j].intchn:=i;
            state[j].intfreq:=csr[i]^.p2/1000;
            state[j].adsr:=defaults[j].adsr;
            state[j].sample:=defaults[j].sample;
            state[j].vol:=defaults[j].vol;

  //          inttable[i].channel2:=csr[i]^.p1;
 //           inttable[i].channel1:=i;
            goto p209;
            end;

          if cmd=7 then //mod
            begin
            modstate:=csr[i]^.p1;
            goto p209;
            end;

          if cmd=8 then //gain
             begin
             gain:=csr[i]^.p1/1000;
             goto p209;
             end;

          if cmd=9 then //pan
             begin
             j:=csr[i]^.p1;
             state[j].pan:=csr[i]^.p2;
             goto p209;
             end;


p209:
        qq:=false;
        if csr[i]^.next=@lsr[i] then qq:=true;
        if (csr[i]^.next^.time>ptime) then qq:=true;
        until qq;
p210:
        end;
      end;

p110:
    end;
  s:=synteza;
  audio2[2*k]:=s[0];
  audio2[2*k+1]:=s[1];
  end else begin audio2[2*k]:=0; audio2[2*k+1]:=0;end; end;

if k11 then begin

for k:=0 to (length div 16)-1 do
  begin
  a1:=0;
  a2:=0;
  for i:=0 to 3 do
    begin
    a1:=a1+audio2[8*k+2*i];
    a2:=a2+audio2[8*k+2*i+1]
    end;
  a1:=a1 div 4;
  a2:=a2 div 4;
    for i:=0 to 3 do
    begin
    audio2[8*k+2*i]:=a1;
    audio2[8*k+2*i+1]:=a2;
    end;
  end;
for k:=0 to (length div 4)-1 do
  begin
  audio2[2*k]:=smallint($F000 and audio2[2*k]);
  audio2[2*k+1]:=smallint($F000 and audio2[2*k+1]);
  end;
end;
if wave then
  begin
  for i:=0 to length-1 do bufor[i]:=audio[i];
  filewrite(fht,bufor,length);
  end;
p102:
end;

//--------------------------MIDI Decoding---------------------------------------


function decodenote(i:integer):string;

begin
if i=0 then result:='C-5';
if i=1 then result:='C#-5';
if i=2 then result:='D-5';
if i=3 then result:='D#-5';
if i=4 then result:='E-5';
if i=5 then result:='F-5';
if i=6 then result:='F#-5';
if i=7 then result:='G-5';
if i=8 then result:='G#-5';
if i=9 then result:='A-5';
if i=10 then result:='A#-5';
if i=11 then result:='H-5';
if i=12 then result:='C-4';
if i=13 then result:='C#-4';
if i=14 then result:='D-4';
if i=15 then result:='D#-4';
if i=16 then result:='E-4';
if i=17 then result:='F-4';
if i=18 then result:='F#-4';
if i=19 then result:='G-4';
if i=20 then result:='G#-4';
if i=21 then result:='A-4';
if i=22 then result:='A#-4';
if i=23 then result:='H-4';
if i=24 then result:='C-3';
if i=25 then result:='C#-3';
if i=26 then result:='D-3';
if i=27 then result:='D#-3';
if i=28 then result:='E-3';
if i=29 then result:='F-3';
if i=30 then result:='F#-3';
if i=31 then result:='G-3';
if i=32 then result:='G#-3';
if i=33 then result:='A-3';
if i=34 then result:='A#-3';
if i=35 then result:='H-3';
if i=36 then result:='C-2';
if i=37 then result:='C#-2';
if i=38 then result:='D-2';
if i=39 then result:='D#-2';
if i=40 then result:='E-2';
if i=41 then result:='F-2';
if i=42 then result:='F#-2';
if i=43 then result:='G-2';
if i=44 then result:='G#-2';
if i=45 then result:='A-2';
if i=46 then result:='A#-2';
if i=47 then result:='H-2';
if i=48 then result:='C-1';
if i=49 then result:='C#-1';
if i=50 then result:='D-1';
if i=51 then result:='D#-1';
if i=52 then result:='E-1';
if i=53 then result:='F-1';
if i=54 then result:='F#-1';
if i=55 then result:='G-1';
if i=56 then result:='G#-1';
if i=57 then result:='A-1';
if i=58 then result:='A#-1';
if i=59 then result:='H-1';
if i=60 then result:='C';
if i=61 then result:='C#';
if i=62 then result:='D';
if i=63 then result:='D#';
if i=64 then result:='E';
if i=65 then result:='F';
if i=66 then result:='F#';
if i=67 then result:='G';
if i=68 then result:='G#';
if i=69 then result:='A';
if i=70 then result:='A#';
if i=71 then result:='H';
if i=72 then result:='C1';
if i=73 then result:='C#1';
if i=74 then result:='D1';
if i=75 then result:='D#1';
if i=76 then result:='E1';
if i=77 then result:='F1';
if i=78 then result:='F#1';
if i=79 then result:='G1';
if i=80 then result:='G#1';
if i=81 then result:='A1';
if i=82 then result:='A#1';
if i=83 then result:='H1';
if i=84 then result:='C2';
if i=85 then result:='C#2';
if i=86 then result:='D2';
if i=87 then result:='D#2';
if i=88 then result:='E2';
if i=89 then result:='F2';
if i=90 then result:='F#2';
if i=91 then result:='G2';
if i=92 then result:='G#2';
if i=93 then result:='A2';
if i=94 then result:='A#2';
if i=95 then result:='H2';
if i=96 then result:='C3';
if i=97 then result:='C#3';
if i=98 then result:='D3';
if i=99 then result:='D#3';
if i=100 then result:='E3';
if i=101 then result:='F3';
if i=102 then result:='F#3';
if i=103 then result:='G3';
if i=104 then result:='G#3';
if i=105 then result:='A3';
if i=106 then result:='A#3';
if i=107 then result:='H3';
if i=108 then result:='C4';
if i=109 then result:='C#4';
if i=110 then result:='D4';
if i=111 then result:='D#4';
if i=112 then result:='E4';
if i=113 then result:='F4';
if i=114 then result:='F#4';
if i=115 then result:='G4';
if i=116 then result:='G#4';
if i=117 then result:='A4';
if i=118 then result:='A#4';
if i=119 then result:='H4';
if i=120 then result:='C5';
if i=121 then result:='C#5';
if i=122 then result:='D5';
if i=123 then result:='D#5';
if i=124 then result:='E5';
if i=125 then result:='F5';
if i=126 then result:='F#5';
if i=127 then result:='G5';
end;


function decodecontroller(i:integer):string;

begin
result:=inttostr(i);
if i=0 then result:='Bank Select';
if i=1 then result:='Modulation';
if i=2 then result:='Breath Controller';
if i=4 then result:='Foot Controller';
if i=5 then result:='Portamento Time';
if i=6 then result:='Data Entry';
if i=7 then result:='Main volume';
if i=8 then result:='Balance';
if i=10 then result:='Pan';
if i=11 then result:='Expression Controller';
if i=12 then result:='Effect 1';
if i=13 then result:='Effect 2';
if i=16 then result:='General Purpose 1';
if i=17 then result:='General Purpose 2';
if i=18 then result:='General Purpose 3';
if i=19 then result:='General Purpose 4';

if i=32 then result:='Bank Select LSB';
if i=33 then result:='Modulation LSB';
if i=34 then result:='Breath Controller LSB';
if i=36 then result:='Foot Controller LSB';
if i=37 then result:='Portamento Time LSB';
if i=38 then result:='Data Entry LSB';
if i=39 then result:='Main volume LSB';
if i=40 then result:='Balance LSB';
if i=42 then result:='Pan LSB';
if i=43 then result:='Expression Controller LSB';
if i=44 then result:='Effect 1 LSB';
if i=45 then result:='Effect 2 LSB';
if i=48 then result:='General Purpose 1 LSB';
if i=49 then result:='General Purpose 2 LSB';
if i=50 then result:='General Purpose 3 LSB';
if i=51 then result:='General Purpose 4 LSB';

if i=64 then result:='Sustain';
if i=65 then result:='Portamento';
if i=66 then result:='Sostenuto';
if i=67 then result:='Soft Pedal';
if i=68 then result:='Legato Footswitch';
if i=69 then result:='Hold 2';
if i=70 then result:='Timber/Variation';
if i=71 then result:='Timber/Harmonic content';
if i=72 then result:='Release Time';
if i=73 then result:='Attack Time';
if i=74 then result:='Sound Controller 5';
if i=75 then result:='Sound Controller 6';
if i=76 then result:='Sound Controller 7';
if i=77 then result:='Sound Controller 8';
if i=78 then result:='Sound Controller 9';
if i=79 then result:='Sound Controller 10';


if i=80 then result:='General Purpose 5';
if i=81 then result:='General Purpose 6';
if i=82 then result:='General Purpose 7';
if i=83 then result:='General Purpose 8';

if i=84 then result:='Portamento';

if i=91 then result:='External Effect';
if i=92 then result:='Tremolo';
if i=93 then result:='Chorus';
if i=94 then result:='Celeste Detune';
if i=95 then result:='Phaser';
if i=96 then result:='Data Increment';
if i=97 then result:='Data Decrement';
if i=98 then result:='Non Registered Parameter Number LSB';
if i=99 then result:='Non Registered Parameter Number MSB';
if i=100 then result:='Registered Parameter Number LSB';
if i=101 then result:='Registered Parameter Number MSB';


end;

procedure  TForm1.BitBtn17Click(Sender: TObject);

label p199;

var fr,hh,bpm,msq,il,q,trc,oldchn,tracktime,t2,oldcmd,channel,command,note,vol,i,j,fh,trl:integer;
  s:string;
  s2:array[0..255] of byte;
  b,c,d:byte;
  qq:boolean;

// midi->text
//todo: zapisać tę procedurę jako osobny program

begin
{  if opendialog3.execute then
  begin
    i:=0;
    fh:=fileopen(opendialog3.filename,$40);
    repeat
      fileseek(fh,i,fsFromBeginning);
      fileread(fh,s2,4);
      s:='';
      for j:=0 to 3 do s:=s+chr(s2[j]);
      inc(i);
    until (i>100) or (s='MThd');
    memo2.lines.clear;
    memo2.lines.add('MIDI header found at position '+inttostr(i-1));
    fileseek(fh,i+7,fsfrombeginning);
    fileread(fh,s2,2);
    memo2.lines.add ('Midi file type '+inttostr(s2[1]));
    fileread(fh,s2,2);
    memo2.lines.add ('Tracks count: '+inttostr(s2[1]));
    trc:=s2[1];
    fileread(fh,s2,2);
    memo2.lines.add('Ticks per 1/4 note: '+inttostr(256*s2[0]+s2[1]));

 for q:=1 to trc do begin
 qq:=false;
 fileread(fh,s2,4); //Mtrk
 memo2.lines.add('Track '+inttostr(q));
 s:='';
 for j:=0 to 3 do s:=s+chr(s2[j]);
 memo2.lines.add(s);
 fileread(fh,s2,4); //
 trl:=s2[0];
 trl:=256*trl+s2[1];
 trl:=256*trl+s2[2];
 trl:=256*trl+s2[3];
 memo2.lines.add('Track length: '+inttostr(trl));
 tracktime:=0;
 oldcmd:=0;
 oldchn:=0;
 repeat
   application.processmessages;
   t2:=0;
   repeat
    il:=fileread(fh,b,1);
     t2:=128*t2+(b and 127);
   until b<128;
   tracktime+=t2;
   fileread(fh,b,1); //

// ok, b=midi command;




   if b=255 then
     begin
     fileread(fh,d,1);
     if (d>0) and (d<8) then
       begin
       fileread(fh,c,1);
       for j:=1 to c do  fileread(fh,s2[j],1);
       s:='';
       for j:=1 to c do s:=s+chr(s2[j]);
       if d=1 then memo2.lines.add(' time: '+inttostr(tracktime)+' comment: '+s);
       if d=2 then memo2.lines.add(' time: '+inttostr(tracktime)+' copyright: '+s);
       if d=3 then memo2.lines.add(' time: '+inttostr(tracktime)+' name: '+s);
       if d=4 then memo2.lines.add(' time: '+inttostr(tracktime)+' instrument: '+s);
       if d=5 then memo2.lines.add(' time: '+inttostr(tracktime)+' lyric: '+s);
       if d=6 then memo2.lines.add(' time: '+inttostr(tracktime)+' marker: '+s);
       if d=7 then memo2.lines.add(' time: '+inttostr(tracktime)+' cue point: '+s);
       goto p199;
       end;
     if d=0 then
       begin
       fileread(fh,s2,3);
       memo2.lines.add (' time: '+inttostr(tracktime)+' sequence number: '+inttostr(256*s2[1]+s2[2]));
       goto p199;
       end;
     if d=81 then
       begin
       fileread(fh,s2,4);
       msq:=65536*s2[1]+256*s2[2]+s2[3];
       if msq<>0 then bpm:=60000000 div msq;
       memo2.lines.add (' time: '+inttostr(tracktime)+' Microseconds per quarter note: ' +inttostr(msq)+'; BPM: '+inttostr(bpm));
       goto p199;
       end;

     if d=88 then
       begin
       fileread(fh,s2,5);
       memo2.lines.add (' time: '+inttostr(tracktime)+' Time signature: '+inttostr(s2[1])+'/'+inttostr(round(power(2,s2[2])))+'; metronome speed:'+inttostr(s2[3])+'; 1/32 notes per 24 ticks: '+inttostr(s2[4]));
       goto p199;
       end;


     if d=84 then
       begin
       fileread(fh,b,1);
       fileread(fh,s2,5);
       fr:=s2[0] and $E0;
       if fr=0 then fr:=23976;
       if fr=1 then fr:=25000;
       if fr=2 then fr:=29970;
       if fr=3 then fr:=30000;
       hh:=s2[0] and $1F;
       memo2.lines.add(' time: '+inttostr(tracktime)+' SMPTE Offset: fps:'+floattostr(fr/1000)+'; hour: '+inttostr(hh)+'; min: '+inttostr(s2[1])+'; sec: '+inttostr(s2[2])+'; frame: '+inttostr(s2[3])+'; subframe: '+inttostr(s2[4]));
       goto p199;
       end;

     if d=89 then
       begin
       fileread(fh,b,1);
       fileread(fh,s2,2);
       if s2[1]=1 then s:='minor' else s:='major';
       memo2.lines.add(' time: '+inttostr(tracktime)+' Key signature '+inttostr(s2[0])+' '+s);
       goto p199;
       end;

     if d=127 then
       begin
       t2:=0;
       repeat
         fileread(fh,b,1);
         t2:=128*t2+(b and 127);
       until b<128;
       for i:=1 to t2 do fileread(fh,b,1);
       memo2.lines.add(' time: '+inttostr(tracktime)+' Sequencer data - length:'+inttostr(t2));
       goto p199;
       end;

     if d=32 then
       begin
       fileread(fh,b,1);
       fileread(fh,c,1);
       memo2.lines.add(' time: '+inttostr(tracktime)+' Channel prefix: '+inttostr(c));
       goto p199;
       end;
     if d=47 then
       begin
       fileread(fh,b,1);
       memo2.lines.add(' time: '+inttostr(tracktime)+' End of track');
       qq:=true;
       goto p199;
       end;
     end;
   if (b=240) or (b=247) then
     begin
     t2:=0;
     repeat
       fileread(fh,b,1);
       t2:=128*t2+(b and 127);
     until b<128;
     for i:=1 to t2 do fileread(fh,b,1);
     memo2.lines.add(' time: '+inttostr(tracktime)+' SYSEX; length:'+inttostr(t2));
     goto p199;
     end;


   channel:=oldchn;
   command:=oldcmd;

   if b>=128 then //command
     begin
       channel:=b and 15;
       command:=(b and $F0) shr 4;
       oldcmd:=command;
       oldchn:=channel;
       fileread(fh,b,1);

   note:=b;
   if ((command<>13) and (command<>12)) then fileread(fh,b,1) else b:=0;
   vol:=b;
   if (command=8) or (command=9) or (command=10) then s:=decodenote(note);
   if command=11 then s:=decodecontroller(note);
   if command=8 then memo2.lines.add(' time: '+inttostr(tracktime)+' channel: '+inttostr(channel)+' note off: '+s+' velocity: '+inttostr(vol));
   if command=9 then memo2.lines.add(' time: '+inttostr(tracktime)+' channel: '+inttostr(channel)+' note on: '+s+' velocity: '+inttostr(vol));
   if command=10 then memo2.lines.add(' time: '+inttostr(tracktime)+' channel: '+inttostr(channel)+' note aftertouch: '+s+' velocity: '+inttostr(vol));
   if command=11 then memo2.Lines.add(' time: '+inttostr(tracktime)+' channel: '+inttostr(channel)+' controller: '+s+' value: '+inttostr(vol));
   if command=12 then memo2.Lines.add(' time: '+inttostr(tracktime)+' channel: '+inttostr(channel)+' Program change: '+inttostr(note));
   if command=13 then memo2.Lines.add(' time: '+inttostr(tracktime)+' channel: '+inttostr(channel)+' Channel aftertouch: '+inttostr(note));
   if command=14 then memo2.Lines.add(' time: '+inttostr(tracktime)+' channel: '+inttostr(channel)+' Pitch bend: '+inttostr(128*note+(vol and 127)));

   goto p199;
   end;

   if b<128 then
     begin
     command:=oldcmd;
     channel:=oldchn;
     if ((oldcmd<>12) and (oldcmd<>13)) then fileread (fh,c,1) else c:=0;
     memo2.lines.add(' time: '+inttostr(tracktime)+' Short command;  channel: '+inttostr(channel)+' command: '+inttostr(command)+' par1: '+inttostr(note)+' par2: '+inttostr(vol));
     goto p199;
     end;

 p199:
 until (qq) or (il=0);
 end ;

  fileclose(fh);

  end; }
end;


procedure MListadd(channel,command,time,length,par1,par2,par3,par4,par5:integer);

var wsk2:PMDecode;

begin
new(wsk2);
wsk2^.channel:=channel;
wsk2^.command:=command;
wsk2^.par1:=par1;
wsk2^.par2:=par2;
wsk2^.par3:=par3;
wsk2^.par4:=par4;
wsk2^.par5:=par5;
wsk2^.time:=time;
wsk2^.length:=length;
Mlast.prev^.next:=wsk2;
wsk2^.next:=@Mlast;
wsk2^.prev:=Mlast.prev;
Mlast.prev:=wsk2;
end;

procedure TForm1.BitBtn16Click(Sender: TObject); //MIDI->masic convert

label p199,p999;

var l,waittime,filetype,fr,hh,bpm,msq,il,q,trc,oldchn,tracktime,t2,oldcmd,channel,command,note,vol,i,j,fh,trl:integer;
  s:string;
  s2:array[0..255] of byte;
  b,c,d:byte;
  qq:boolean;
  oldtime,atsp,tpqn,linenum:integer;
  tun:double;
  wsk,wsk2:PMDecode;

begin

//Pass 1. Add midi events to list

if opendialog3.execute then
  begin
  i:=0;
  fh:=fileopen(opendialog3.filename,$40);
  if fh<0 then
    begin
    messagedlg('Cannot open file '+opendialog3.FileName,MtError,[MbOk],0);
    goto p999; // abort when Menu1 not opened
    end;
  repeat
    fileseek(fh,i,fsFromBeginning);
    fileread(fh,s2,4);
    s:='';
    for j:=0 to 3 do s:=s+chr(s2[j]);
    inc(i);
  until (i>100) or (s='MThd');
  if i>100 then
    begin
    messagedlg(opendialog3.filename+': Cannot find MIDI header -aborting.',MtError,[MbOk],0);
    goto p999; // abort when header not found
    end;
  fileseek(fh,i+7,fsfrombeginning);
  fileread(fh,s2,2);
  filetype:=s2[1]; //MIDI Menu1 type
  if (filetype<>0) and (filetype<>1) then
    begin
    messagedlg(opendialog3.filename+': Only Type 1 and Type 2 MIDI files can be converted - aborting.',MtError,[MbOk],0);
    goto p999; // abort when header not found
    end;
  fileread(fh,s2,2);
  trc:=s2[1];
  fileread(fh,s2,2);
  tpqn:=256*s2[0]+s2[1];
  tun:=500/tpqn; //timeunit in ms assumed 120 bpm
  MListadd(0,257,0,0,round(tun*1000),0,0,0,0);    //metacmd 257, time unit in microsec.
  for q:=1 to trc do  // process all tracks
    begin
    qq:=false;
    fileread(fh,s2,4); //Mtrk
    s:='';
    for j:=0 to 3 do s:=s+chr(s2[j]);
    if s<>'MTrk' then
      begin
      messagedlg(opendialog3.filename+': Cannot find track header -aborting.',MtError,[MbOk],0);
      fileclose(fh);
      goto p999; // abort when header not found
      end;
    MListadd(0,256,0,0,q,0,0,0,0);     //metacmd 256=Track, par1=track num
    fileread(fh,s2,4); //
    trl:=s2[0];
    trl:=256*trl+s2[1];
    trl:=256*trl+s2[2];
    trl:=256*trl+s2[3];  // track length in bytes;

    tracktime:=0;
    oldcmd:=0;
    oldchn:=0;

    repeat
      t2:=0;
      repeat
        il:=fileread(fh,b,1);
        t2:=128*t2+(b and 127);
      until b<128;
      oldtime:=tracktime;
      tracktime+=t2;
      fileread(fh,b,1); // midi command;

      if b=255 then  // meta events
        begin
        fileread(fh,d,1);
        if (d>0) and (d<8) then
          begin
          fileread(fh,c,1);
          for j:=1 to c do  fileread(fh,s2[j],1);
          s:='';
          for j:=1 to c do s:=s+chr(s2[j]);
          // text events. Ignore them.
          goto p199;
          end;
        if d=0 then
          begin
          fileread(fh,s2,3);
          // sequence number event, ignore;
          goto p199;
          end;
        if d=81 then
          begin
          fileread(fh,s2,4);
          msq:=65536*s2[1]+256*s2[2]+s2[3];
          if msq<>0 then bpm:=60000000 div msq;
          tun:=(60000/bpm)/tpqn;
          MListadd(0,257,tracktime,0,round(tun*1000),0,0,0,0);    //metacmd 257, time unit in microsec.
          goto p199;
          end;

        if d=88 then
          begin
          fileread(fh,s2,5);
          // Time signature event, ignore
          goto p199;
          end;

        if d=84 then
          begin
          fileread(fh,s2,6);
          // SMPTE Offset event, ignore
          goto p199;
          end;

        if d=89 then
          begin
          fileread(fh,s2,3);
          // Key signature event, ignore;
         goto p199;
         end;

        if d=127 then
          begin
          t2:=0;
          repeat
            fileread(fh,b,1);
            t2:=128*t2+(b and 127);
          until b<128;
          for i:=1 to t2 do fileread(fh,b,1);
          // Sequencer data - length:'+inttostr(t2));
          goto p199;
          end;

        if d=32 then
          begin
          fileread(fh,b,1);
          fileread(fh,c,1);
          // MListadd(0,258,tracktime,0,c,0,0,0,0);    //metacmd 258, channel prefix.
          // .. ignoring now...
          goto p199;
          end;
        if d=47 then
          begin
          fileread(fh,b,1);
          //  End of track
          qq:=true;
          goto p199;
          end;
        end;

// end of meta events -------------------------------------------

      if (b=240) or (b=247) then  //SYSEX
        begin
        t2:=0;
        repeat
          fileread(fh,b,1);
          t2:=128*t2+(b and 127);
        until b<128;
        for i:=1 to t2 do fileread(fh,b,1);
        //  SYSEX; length:t2;
        goto p199;
        end;

// music commands

      channel:=oldchn;
      command:=oldcmd;

      if b>=128 then // long command
        begin
        channel:=b and 15;
        command:=(b and $F0) shr 4;
        oldcmd:=command;
        oldchn:=channel;
        fileread(fh,b,1);
        note:=b;
        if ((command<>13) and (command<>12)) then fileread(fh,b,1) else b:=0;
        vol:=b;
        MListadd(channel,command,tracktime,0,note,vol,0,0,0);
        goto p199;
        end;

      if b<128 then
        begin
        command:=oldcmd;
        channel:=oldchn;
        if ((oldcmd<>12) and (oldcmd<>13)) then fileread (fh,c,1) else c:=0;
        MListadd(channel,command,tracktime,0,b,c,0,0,0);
        goto p199;
        end;

      p199:
      until (qq) or (il=0);
    end ;
    fileclose(fh);
  end

else goto p999; // Opendialog cancelled

// Pass 2. Make MASIC :)

linenum:=10;
synedit1.lines.clear;
MFirst.time:=0;
wsk:=@MFirst;
while wsk^.next<>nil do
  begin
  wsk:=wsk^.next;
  if wsk^.command=256 then synedit1.lines.add('track '+inttostr(wsk^.par1));
  if wsk^.command=257 then
    begin
    atsp:=round(wsk^.par1/5000);
    synedit1.lines.add('speed '+inttostr(atsp));
    synedit1.lines.add('; time unit: '+inttostr(wsk^.par1)+' microseconds');
    end;
  if (wsk^.command=9) then
    begin
    wsk2:=wsk;
    repeat
      wsk2:=wsk2^.next
    until (wsk2^.next=nil) or (wsk2^.command=9);
    if wsk2^.next<>nil then waittime:=wsk2^.time-wsk^.time else waittime:=50;
    if waittime<0 then waittime:=100;
    end;



  if (wsk^.command=8) or (wsk^.command=9) or (wsk^.command=10) then s:=decodenote(wsk^.par1);
  if wsk^.command=11 then s:=decodecontroller(wsk^.par1);

//  if wsk^.command=8 then synedit1.lines.add(inttostr(linenum)+' play '+inttostr(wsk^.channel)+','+s+',0,0,'+inttostr(waittime));
  if wsk^.channel=9 then l:=10 else l:=100; // percussion ...łata dopóki nie dorobię się presetów i dekodowania perkusji
  if wsk^.command=9 then synedit1.lines.add('play '+inttostr(wsk^.channel)+' '+s+','+inttostr(wsk^.par2 div 8)+','+inttostr(l)+','+inttostr(waittime));
  if wsk^.command=12 then synedit1.Lines.add('set '+inttostr(wsk^.channel)+', gm'+inttostr(wsk^.par1)+', gm'+inttostr(wsk^.par1)+',15,100,100');
  inc(linenum,10);
  application.ProcessMessages;
  end;

// release event list

wsk:=MFirst.next;
wsk2:=wsk;
while wsk<>@MLast do
  begin
  wsk:=wsk^.next;
  dispose(wsk2);
  wsk2:=wsk;
  end;
MFirst.next:=@MLast;
MLast.prev:=@MFirst;

p999:

end;



function sdl_sound_init:integer;

// Zainicjuj bibliotekę sdl_sound

begin
Result:=0;

if SDL_Init(SDL_INIT_AUDIO) <> 0 then
  begin
  Result:=-1; // sdl_audio nie da się zainicjować
  exit;
  end;

desired.freq := 44100;                                     // sample rate
desired.format := AUDIO_S16;                               // 16-bit samples
desired.samples := 4096;                                   // sample na 1 callback
desired.channels := 2;                                     // stereo
desired.callback := @AudioCallback;
desired.userdata := nil;                                   // niepotrzebne poki co

if (SDL_OpenAudio(@desired, @obtained) < 0) then
  begin
  Result:=-2;   // nie da się otworzyć urządzenia
  end;
end;


{ TForm1 }

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);

begin
sdl_quit;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if messagedlg('Really close program?', MtConfirmation,[MbYes,MbNo],0)=mryes then canclose:=true else canclose :=false;
end;


procedure TForm1.BitBtn10Click(Sender: TObject);
begin
  form1.close;
end;

procedure TForm1.BitBtn11Click(Sender: TObject);
begin
  list(0,999999,1);
end;

procedure TForm1.BitBtn12Click(Sender: TObject);
begin
  interpret('new',false);
  list(0,999999,1);
end;

procedure TForm1.BitBtn13Click(Sender: TObject);
begin
  interpret('ren',false);
  list(0,999999,1);

end;

procedure TForm1.BitBtn14Click(Sender: TObject);
begin
 // form4.show;
end;

procedure TForm1.BitBtn15Click(Sender: TObject);

label p199;

var wsk:PProgline;
    sep,arg,arg2,l,str,str2:string;
    ln,i,q,q2:integer;
    fh:integer;
    c:string[1];

begin
savedialog2.Title:='Save Atari .LST';
savedialog2.InitialDir:=l_dir;
savedialog2.DefaultExt:='LST';
if savedialog2.execute then
  begin
  if fileexists(savedialog2.filename) then
    begin
    if messagedlg('File exists - overwrite?',MtConfirmation,[MbYes,MbNo],0)=MrNo then goto p199;
    end;
  fh:=filecreate(savedialog2.filename);

  wsk:=@pierwsza;
  repeat

  wsk:=wsk^.next;
  if wsk^.next<>nil then
    begin
    l:=wsk^.line;
    ln:=wsk^.linenum;
    str:=inttostr(ln);
    getarg(0,l,arg);
    if (arg=';') or (arg='?')  then sep:=' ' else sep:=',';
    if arg <>'play' then str:=str+' '+arg; // cmd
    getarg(1,l,arg);  // chnum
    str2:=' ';
    if (arg<>'') then
      begin
      str:=str+' '+arg;
      str2:=',';
      end;
    q:=getarg(4,l,arg); //freq
    if q<>-1 then
      begin
      arg2:=encodesound(strtofloat(arg));
      str:=str+str2+arg2;
      end;
    q:=getarg(2,l,arg); // wave
    q2:=getarg(3,l,arg2); //adsr
    if (q<>-1) and (q2<>-1) then str:=str+','+arg+','+arg2;
    if (q=-1) and (q2<>-1) then str:=str+',,'+arg2;
    if (q<>-1) and (q2=-1) then str:=str+','+arg;
    for i:=5 to 11 do
      begin
      q:=getarg(i,l,arg);
      if (i=8) and (q<>-1) and (sep=',') then
        begin
        arg2:=encodesound(strtofloat(arg));
        str:=str+',>'+arg2;
        end;
      if (i<>8) and (q<>-1) then str:=str+sep+arg;
      end;
    if copy(str,length(str)-2,3)='off' then str:=copy(str,1,length(str)-4)+' off';

    for i:=1 to length(str) do
      begin
      c:=upcase(copy(str,i,1));
      filewrite(fh,c[1],1);
      end;
    i:=$9B;
    filewrite(fh,i,1);
    end;
  until wsk^.next=nil;
  fileclose(fh);
  end;
p199:
end;



procedure TForm1.BitBtn1Click(Sender: TObject);

label p101,p102;

var count,err:integer;
    line:string;
    f:textfile;


begin
opendialog1.Title:='Load song';
opendialog1.InitialDir:=m_dir;
opendialog1.DefaultExt:='m2';
if opendialog1.execute then
    begin
  assignfile(f,opendialog1.filename);
  reset(f);
  newcmd(false);
  readln(f,line);
  if line='PC Softsynth Module' then     // old format load
    begin
    count:=0;
    label5.visible:=true;
    label6.visible:=true;
    repeat
      readln(f,line);
      err:=interpret(line,false);
      inc(count);
      label5.caption:=inttostr(count);
      application.processmessages;
    until eof(f);
    list(0,999999,1);
    emit(inttostr(count)+' lines loaded');
    goto p101;
    end;          // TODO always fill synedit !!
  if line='PC Softsynth Module v2' then
    begin
    count:=0;
    synedit1.lines.clear;
    repeat
      readln(f,line);
      synedit1.lines.add(line);
      inc(count);
      label5.caption:=inttostr(count);
      application.processmessages;
    until eof(f);
    emit(inttostr(count)+' lines loaded');
    goto p101;
    end;          // TODO always fill synedit !!


  begin
  emit('Bad file format, loading aborted');
  goto p102;
  end;

p101:
  form1.caption:='Malina Softsynth '+ver+' --- '+opendialog1.filename;
p102:
  closefile(f);
  synedit1.setfocus;
  end;
label5.visible:=false;
label6.visible:=false;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);

var wsk:PProgline;
    sep,arg,arg2,l,str,str2:string;
    ln,i,q,q2:integer;
    f:textfile;

begin
savedialog1.Title:='Save song';
savedialog1.InitialDir:=m_dir;
savedialog1.DefaultExt:='m2';
if savedialog1.execute then
  begin
  assignfile(f,savedialog1.filename);
  rewrite(f);
  writeln(f,'PC Softsynth Module v2');
  for i:=0 to synedit1.lines.count-1 do
    writeln(f,synedit1.lines[i]);

{  ---------  old version

  wsk:=@pierwsza;
  repeat


  wsk:=wsk^.next;
  if wsk^.next<>nil then
    begin
    l:=wsk^.line;
    ln:=wsk^.linenum;
    str:=inttostr(ln);
    getarg(0,l,arg);
    if (arg=';') or (arg='?')  then sep:=' ' else sep:=',';
    str:=str+' '+arg; // cmd
    getarg(1,l,arg);  // chnum
    str2:=' ';
    if (arg<>'') then
      begin
      str:=str+' '+arg;
      str2:=',';
      end;
    q:=getarg(4,l,arg); //freq
    if q<>-1 then
      begin
      arg2:=encodesound(strtofloat(arg));
      str:=str+str2+arg2;
      end;
    q:=getarg(2,l,arg); // wave
    q2:=getarg(3,l,arg2); //adsr
    if (q<>-1) and (q2<>-1) then str:=str+','+arg+','+arg2;
    if (q=-1) and (q2<>-1) then str:=str+',,'+arg2;
    if (q<>-1) and (q2=-1) then str:=str+','+arg;
    for i:=5 to 11 do
      begin
      q:=getarg(i,l,arg);
      if (i=8) and (q<>-1) and (sep=',') then
        begin
        arg2:=encodesound(strtofloat(arg));
        str:=str+',>'+arg2;
        end;
      if (i<>8) and (q<>-1) then str:=str+sep+arg;
      end;
      writeln(f,str);
    end;
  until wsk^.next=nil;
  }
  closefile(f);
  end;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
form1.hide;
form2.show;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);

begin
stop(1);
end;


procedure TForm1.BitBtn5Click(Sender: TObject);

var s:TSample;
i:integer;
f:textfile;
path,s1,s2,s3,s4,filename:string;

begin
path:=getuserdir;
 filename:=path+'softsynth.ini';
 if fileexists(filename) then
   begin
   assignfile(f,filename);
   reset(f);
   readln(f,s1);
   readln(f,s2);
   readln(f,s3);
   readln(f,s4);
   closefile(f);
   end
 else
   begin
   s1:=s_dir;
   s2:=h_dir;
   s3:=m_dir;
   s4:=l_dir;
   end;
 form3.edit1.text:=s1;
 form3.edit2.text:=s2;
 form3.edit3.text:=s3;
 form3.edit4.text:=s4;
 form3.showmodal;
 if (form3.modalresult=mrok) then
   begin
   s_dir:=form3.edit1.text;
   h_dir:=form3.Edit2.text;
   m_dir:=form3.edit3.text;
   l_dir:=form3.edit4.text;
   assignfile(f,filename);
   rewrite(f);
   writeln(f,s_dir);
   writeln(f,h_dir);
   writeln(f,m_dir);
   writeln(f,l_dir);
   closefile(f);
   end;
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
begin
  adsridx:=0;
  waveidx:=0;
end;

procedure TForm1.BitBtn7Click(Sender: TObject);

// Atari import

  label p101;

var err:integer;
    line:string;
    il,fh:integer;
    bufor:byte;
    count:integer;

begin
count:=0;
opendialog2.InitialDir:=l_dir;
opendialog2.DefaultExt:='LST';
if opendialog2.execute then
  begin
  fh:=fileopen(opendialog2.filename, $40);
  if fh>0 then
    begin
    label5.visible:=true;
    label6.visible:=true;
    newcmd(false);
    repeat
      line:='';
      repeat
        il:=fileread(fh,bufor,1);
        if (bufor<128) and (bufor>=32) then line:=line+chr(bufor);
      until (il<1) or (bufor=$9B) or (bufor=$0A) or (bufor=$0D);
      err:=interpret(line,false);
      inc(count);
    until (il<1);
  p101:
  fileclose(fh);
  edit1.setfocus;
  form1.caption:='Malina Softsynth '+ver+' --- '+opendialog2.filename;
  emit(' ');
  emit(inttostr(count)+' lines loaded');
  emit('Ready');
  end;
end;
list(0,999999,1);
label5.visible:=false;
label6.visible:=false;
end;

procedure TForm1.BitBtn8Click(Sender: TObject);

var i:integer;
    str:string;

begin
  interpret('new',false);
  for i:=0 to synedit1.Lines.count-1 do
    begin
    str:=inttostr(10*(i+1))+' '+synedit1.lines[i];
    interpret(str,false);
    end;
end;


procedure TForm1.BitBtn9Click(Sender: TObject);

var i:integer;
     str:string;

begin

// apply changes in editor

interpret('new',false);
for i:=0 to synedit1.Lines.count-1 do
  begin
  str:=inttostr(10*(i+1))+' '+synedit1.lines[i];
  interpret(str,false);
  end;


wave:=false;
if checkbox6.checked then
  begin
  if savedialog3.execute then
    begin
    tempfilename:=savedialog3.FileName+'.tmp';
    fhw:=filecreate(savedialog3.filename);
    fht:=filecreate(tempfilename);
    if (fhw>0) and (fht>0) then wave:=true;
    end
  else
    checkbox6.checked:=false;
  end;
interpret('play',false);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  list(0,999999,1);
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
//  if checkbox1.checked then atari:=true else atari:=false;
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
  if checkbox2.checked then k11:=true else k11:=false;
end;

procedure TForm1.CheckBox4Change(Sender: TObject);
begin
{  if checkbox4.checked then
  begin
  form1.synedit1.gutter.visible:=true;
  form1.synedit1.Gutter.autosize:=true;
  end
    else
  begin
   form1.synedit1.gutter.visible:=false;
   form1.synedit1.gutter.AutoSize:=false;;
   form1.synedit1.Gutter.Width:=0;
   end;    }
end;

procedure TForm1.CheckBox5Click(Sender: TObject);
begin
  adsridx:=0;
  waveidx:=0;
  atari2:=checkbox5.checked;
end;

procedure TForm1.CheckBox6Change(Sender: TObject);
begin
  if checkbox6.checked then check6:=1;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin

end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: char);

var err,i:integer;

ss:tstrings;
nn:tnums;
s:string;
p:tpoint;

begin
  if ord(key)=13 then
    begin
    s:=edit1.text;
    emit(s);
    err:=interpret(s,true);
    edit1.text:='';
    end;
end;


procedure TForm1.FormActivate(Sender: TObject);
begin
  form1.caption:='Malina Softsynth '+ver;
  decimalseparator:='.';
//  form1.synedit1.gutter.visible:=false;
//  form1.synedit1.Gutter.autosize:=false;
//  form1.synedit1.gutter.width:=0;
//  form1.synedit1.lines.clear;
  edit1.setfocus;
end;


procedure TForm1.FormCreate(Sender: TObject);

var i,j,error:integer;
    s:double;
    f:textfile;
    s1,s2,s3,s4,filename:string;

begin

//zainicjuj sdl

error:=sdl_sound_init;
if error<>0 then
  begin
  messagedlg('Problem z zainicjowaniem sdl_audio', MtError,[MbOk],0);
  application.Terminate;    // zakończ program w związku z brakiem SDL-a
  end;

// zainicjuj tablice sampli i adsr

for j:=-1 to maxdefs do
  begin
  for i:=0 to 1023 do samples[j,i]:=round(32767*sin(2*pi*i/1024));
  for i:=0 to 255 do adsrs[j,i]:=255-i;
  end;

// zainicjuj tablicę dźwięków

s:=c03;
for i:=-4 to 6 do
  for j:=0 to 11 do
    begin
    dzwieki[i,j]:=s;
    s:=s*a212;
    end;

// ustaw defaulty

for i:=-1 to maxchannel do
  begin
  defaults[i].adsr:=-1;   //defaulty - adsr i wave z edytora, max vol, 300 ms
  defaults[i].channel:=i;
  defaults[i].freq:=440;
  defaults[i].idx:=-1;
  defaults[i].len:=300;
  defaults[i].pan:=0;
  defaults[i].sample:=-1;
  defaults[i].spl_len:=13230;
  defaults[i].start:=0;
  defaults[i].vol:=32767;
  end;

// zainicjuj listę programu

pierwsza.last:=nil;
pierwsza.next:=@ostatnia;
pierwsza.linenum:=0;
pierwsza.line:=spaces(255);;
ostatnia.last:=@pierwsza;
ostatnia.next:=nil;
ostatnia.linenum:=999999;
ostatnia.line:=spaces(255);

//zainicjuj listy syntezy

for i:=-1 to maxchannel do
  begin
  fsr[i].last:=nil;
  fsr[i].next:=@lsr[i];
  lsr[i].next:=nil;
  lsr[i].last:=@fsr[i];
  end;

// wyzeruj listę dźwięków i indeksy

stop(0);

//zainicjuj kody dzwiekow

for i:=-4 to 6 do
  begin
  if i<>0 then s1:=inttostr(i) else s1:='';
  kody[i,0]:='c'+s1;
  kody[i,1]:='c#'+s1;
  kody[i,2]:='d'+s1;
  kody[i,3]:='d#'+s1;
  kody[i,4]:='e'+s1;
  kody[i,5]:='f'+s1;
  kody[i,6]:='f#'+s1;
  kody[i,7]:='g'+s1;
  kody[i,8]:='g#'+s1;
  kody[i,9]:='a'+s1;
  kody[i,10]:='a#'+s1;
  kody[i,11]:='h'+s1;
  end;

filename:=getuserdir+'softsynth.ini';
if fileexists(filename) then
  begin
  assignfile(f,filename);
  reset(f);
  readln(f,s1);
  readln(f,s2);
  readln(f,s3);
  readln(f,s4);
  closefile(f);
  end
else
  begin
  s1:=getuserdir;
  s2:=getuserdir;
  s3:=getuserdir;
  s4:=getuserdir;
  end;
s_dir:=s1;
h_dir:=s2;
m_dir:=s3;
l_dir:=s4;

//midi
MFirst.next:=@MLast;
Mlast.prev:=@MFirst;
MFirst.prev:=nil;
MLast.next:=nil;

// uruchom sdl audio

sdl_pauseaudio(0);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
 // form1.Height:=703;
 // form1.width:=636;
end;

procedure TForm1.Memo1Enter(Sender: TObject);
begin
  edit1.setfocus;
end;

procedure TForm1.Menu1Click(Sender: TObject);
begin

end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  pause:= speedbutton1.down;
end;

procedure TForm1.SynEdit1Change(Sender: TObject);
begin

end;

procedure TForm1.TabSheet2Enter(Sender: TObject);
begin
//  list(0,999999,1);
end;

procedure TForm1.TabSheet2Show(Sender: TObject);
begin
list(0,999999,1);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin

end;

procedure TForm1.Timer2Timer(Sender: TObject);

var h,m,s,ms:integer;
    hs,mms,ss,mss:string;


begin
if test>=0 then
  begin
  h:=test div 3600000;
  m:=(test div 60000) mod 60;
  s:=(test div 1000) mod 60;
  ms:=test mod 1000;
  hs:=inttostr(h);
  if length(hs)=1 then hs:='0'+hs;
  mms:=inttostr(m);
  if length(mms)=1 then mms:='0'+mms;
  ss:=inttostr(s);
  if length(ss)=1 then ss:='0'+ss;
  mss:=inttostr(ms);
  if length(mss)=1 then mss:='00'+mss;
  if length(mss)=2 then mss:='0'+mss;
  label2.caption:=hs+':'+mms+':'+ss+'.'+mss;
  end
else label2.caption:='00:00:00.000';
label4.caption:=floattostrf(gain,fffixed,8,6);
if check6=0 then checkbox6.checked:=false;
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin
  if checkbox3.checked then
    if not play then run2(1,0,999999,0,0,0);
end;

end.

