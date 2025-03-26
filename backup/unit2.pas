unit Unit2;

// PC Softsynth
// License: GNU GPL
// see README for details

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Spin, fft, sdl;

type

  { TForm2 }

  TForm2 = class(TForm)
    Bevel1: TBevel;
    Bevel10: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    DSXFastFourier1: TDSXFastFourier;
    Edit22: TEdit;
    Edit23: TEdit;
    Edit24: TEdit;
    Edit25: TEdit;
    Edit26: TEdit;
    Edit27: TEdit;
    fft1: TDSXFastFourier;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit2: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ScrollBar1: TScrollBar;
    ScrollBar10: TScrollBar;
    ScrollBar11: TScrollBar;
    ScrollBar12: TScrollBar;
    ScrollBar13: TScrollBar;
    ScrollBar14: TScrollBar;
    ScrollBar15: TScrollBar;
    ScrollBar16: TScrollBar;
    ScrollBar17: TScrollBar;
    ScrollBar18: TScrollBar;
    ScrollBar19: TScrollBar;
    ScrollBar2: TScrollBar;
    ScrollBar20: TScrollBar;
    ScrollBar21: TScrollBar;
    ScrollBar22: TScrollBar;
    ScrollBar23: TScrollBar;
    ScrollBar24: TScrollBar;
    ScrollBar25: TScrollBar;
    ScrollBar26: TScrollBar;
    ScrollBar27: TScrollBar;
    ScrollBar3: TScrollBar;
    ScrollBar4: TScrollBar;
    ScrollBar5: TScrollBar;
    ScrollBar6: TScrollBar;
    ScrollBar7: TScrollBar;
    ScrollBar8: TScrollBar;
    ScrollBar9: TScrollBar;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Bevel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Bevel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Bevel2ChangeBounds(Sender: TObject);
    procedure Bevel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Bevel2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Bevel3ChangeBounds(Sender: TObject);
    procedure Bevel4ChangeBounds(Sender: TObject);
    procedure Bevel8ChangeBounds(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn15Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox11Change(Sender: TObject);
    procedure CheckBox12Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox7Change(Sender: TObject);
    procedure CheckBox8Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure fft1GetData(index: integer; var Value: TComplex);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image2Click(Sender: TObject);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScrollBar10Change(Sender: TObject);
    procedure ScrollBar11Change(Sender: TObject);
    procedure ScrollBar12Change(Sender: TObject);
    procedure ScrollBar13Change(Sender: TObject);
    procedure ScrollBar14Change(Sender: TObject);
    procedure ScrollBar15Change(Sender: TObject);
    procedure ScrollBar16Change(Sender: TObject);
    procedure ScrollBar17Change(Sender: TObject);
    procedure ScrollBar18Change(Sender: TObject);
    procedure ScrollBar19Change(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar20Change(Sender: TObject);
    procedure ScrollBar21Change(Sender: TObject);
    procedure ScrollBar22Change(Sender: TObject);
    procedure ScrollBar23Change(Sender: TObject);
    procedure ScrollBar24Change(Sender: TObject);
    procedure ScrollBar25Change(Sender: TObject);
    procedure ScrollBar26Change(Sender: TObject);
    procedure ScrollBar27Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure ScrollBar3Change(Sender: TObject);
    procedure ScrollBar4Change(Sender: TObject);
    procedure ScrollBar5Change(Sender: TObject);
    procedure ScrollBar6Change(Sender: TObject);
    procedure ScrollBar7Change(Sender: TObject);
    procedure ScrollBar8Change(Sender: TObject);
    procedure ScrollBar9Change(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton2DblClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;
  h:array[1..31] of double;
  a,s:array[1..31]of longint;
  chd:boolean=false;
  chd2:boolean=false;
  chg3:boolean=false;
  chg4:boolean=false;
  testlen:integer=300;
  ox,oy,oax,oay:integer;
  afw:boolean=false;
  afw2:boolean=true;
  aafw:boolean=true;
  aafw2:boolean=true;

procedure przeliczsampla;
procedure przeliczadsr;
//procedure addchannel(channel,sample,adsr:integer;freq:double;vol,pan,len,start,stop:integer);

implementation
uses unit1;

{$R *.lfm}

procedure przeliczsampla;

var q,i,j:integer;
spl:array[0..1023] of double;
d1,d2,maxi, mini,med,delta:double;

begin

for i:=0 to 1023 do spl[i]:=0;

if form2.checkbox11.checked then
  begin
  // złóż falę z harmonicznych
  for i:=1 to 31 do
    begin
    for j:=0 to 1023 do
      begin
      spl[j]:=spl[j]+32768*h[i]*sin(2*pi*i*j/1024);
      end;
    end;

  end;

if form2.checkbox12.checked then
  begin
  for j:=0 to 1023 do spl[j]:=spl[j]+32768*s[1]*sin(2*pi*j/1024);
  q:=(1024*s[3]) div 100;
  for j:=0 to 1023 do if j<q then spl[j]:=spl[j]+32768*s[2] else spl[j]:=spl[j]-32768*s[2];
  q:=(1024*s[5]) div 100;
  if q<1 then q:=1;
  if q>1023 then q:=1023;
  d1:=1/q;
  d2:=1/(1024-q);
  for j:=0 to q-1 do spl[j]:=spl[j]+round(s[4]*(-32768+65536*(d1*j)));
  for j:=q to 1023 do spl[j]:=spl[j]+round(s[4]*(32768-65536*(d2*(j-q))));
  for j:=0 to 1023 do spl[j]:=spl[j]+s[6]*(-32678+random(65536));
  end;


//normalizacja
maxi:=-1e99;
mini:=1e99;
for i:=0 to 1023 do
  begin
  if spl[i]<mini then mini:=spl[i];
  if spl[i]>maxi then maxi:=spl[i];
  end;
delta:=maxi-mini;
med:=(maxi+mini)/2;
if delta=0 then delta:=1e-99;
for i:=0 to 1023 do spl[i]:=(65534/delta)*(spl[i]-med);
for i:=0 to 1023 do samples[-1,i]:=round(spl[i]);
form2.image1.canvas.clear;
form2.image1.canvas.refresh;
//p.x:=0;
//p.y:=128+samples[0,i] div 256;
form2.image1.canvas.moveto(0,128-samples[-1,0] div 256);
for i:=1 to 1023 do form2.image1.canvas.lineto(i,128-samples[-1,i] div 256);
end;

procedure przeliczadsr;

var i,det,sut,att,alltime:integer;

begin
alltime:=a[1]+a[2]+a[4]+a[6];
if alltime=0 then alltime:=1;
att:=round(256*a[1]/alltime);
det:=round(256*(a[1]+a[2])/alltime);
sut:=round(256*(a[1]+a[2]+a[4])/alltime);
for i:=0 to att-1 do adsrs[-1,i]:=round(255*(i/att));
for i:=att to det-1 do adsrs[-1,i]:=round(255-(255-a[3])*(i-att)/(det-att));
for i:=det to sut-1 do adsrs[-1,i]:=round(a[3]-(a[3]-a[5])*(i-det)/(sut-det));
for i:=sut to 255 do adsrs[-1,i]:=round(a[5]-a[5]*(i-sut)/(256-sut));
adsrs[-1,256]:=0;
form2.image2.canvas.clear;
form2.image2.canvas.refresh;
//p.x:=0;
//p.y:=128+samples[0,i] div 256;
form2.image2.canvas.moveto(0,255-adsrs[-1,0]);
for i:=1 to 255 do form2.image2.canvas.lineto(i,255-adsrs[-1,i] );

end;

{ TForm2 }

procedure TForm2.Bevel3ChangeBounds(Sender: TObject);
begin

end;

procedure TForm2.Bevel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);



var i,newsample,oldsample:integer; delta:double;

begin
if (x>=8) and (x<1032) then
  begin
  x:=x-8;
  if x<0 then x:=0;
  if x>1023 then x:=1023;
  if afw and afw2 and (shift=[ssleft]) then
    begin
    if y>100 then newsample:=-32767 else newsample:=32767;
    oldsample:=samples[-1,ox];
    if x-ox<>0 then delta:=(newsample-oldsample)/(x-ox) else delta:=1;
    if x>ox then
      begin
      for i:=ox to x do
      samples[-1,i]:=round(oldsample+(i-ox)*delta);
      end;
    if x<ox then
      begin
      for i:=x to ox do
        samples[-1,i]:=round(newsample+(i-x)*delta);
      end;
    ox:=x;
    oy:=y;
    chg3:=true;
    end;
  end;
end;

procedure TForm2.Bevel2ChangeBounds(Sender: TObject);
begin

end;

procedure TForm2.Bevel2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

aafw2:=true;
if aafw and (shift=[ssleft]) and (x>=8) and (x<264) then
  begin
  oax:=x-8;
  if oax>255 then oax:=255;
  if oax<0 then oax:=0;
  oay:=y;
  end;
end;

procedure TForm2.Bevel2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);


var i,newsample,oldsample:integer; delta:double;

begin
if (x>=8) and (x<264) then
  begin
  x:=x-8;
  if x<0 then x:=0;
  if x>255 then x:=255;
  if aafw and aafw2 and (shift=[ssleft]) then
    begin
    if y>100 then newsample:=0 else newsample:=255;
    oldsample:=adsrs[-1,oax];
    if x-oax<>0 then delta:=(newsample-oldsample)/(x-oax) else delta:=1;
    if x>oax then
      begin
      for i:=oax to x do
      adsrs[-1,i]:=round(oldsample+(i-oax)*delta);
      end;
    if x<oax then
      begin
      for i:=x to oax do
        adsrs[-1,i]:=round(newsample+(i-x)*delta);
      end;
    oax:=x;
    oay:=y;
    chg4:=true;
    end;
  end;
end;




procedure TForm2.Bevel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
afw2:=true;
if afw and (shift=[ssleft]) and (x>=8) and (x<1032) then
  begin
  ox:=x-8;
  if ox>1023 then ox:=1023;
  if ox<0 then ox:=0;
  oy:=y;
//  if y<100 then newsample:=32767 else newsample:=-32767;
  end;
end;



procedure TForm2.Bevel4ChangeBounds(Sender: TObject);
begin

end;

procedure TForm2.Bevel8ChangeBounds(Sender: TObject);
begin

end;

procedure TForm2.BitBtn12Click(Sender: TObject);

var maxi:double;
i:integer;
harm:array[1..63] of double;
begin
  fft1.fft;
  maxi:=0;
  for i:=1 to 63 do
    begin
    harm[i]:=sqrt(sqr(fft1.TransformedData[i].real)+sqr(fft1.transformeddata[i].imag));
    if harm[i]>maxi then maxi:=harm[i];
    end;
  if maxi=0 then //nie dziel przez zero
    begin
    maxi:=1;
    harm[2]:=1
    end;
  for i:=1 to 31 do h[i]:=harm[2*i]/maxi;
  edit1.Text:=inttostr(round(100*(h[1])));
  edit2.Text:=inttostr(round(100*(h[2])));
  edit3.Text:=inttostr(round(100*(h[3])));
  edit4.Text:=inttostr(round(100*(h[4])));
  edit5.Text:=inttostr(round(100*(h[5])));
  edit6.Text:=inttostr(round(100*(h[6])));
  edit7.Text:=inttostr(round(100*(h[7])));
  edit8.Text:=inttostr(round(100*(h[8])));
  edit9.Text:=inttostr(round(100*(h[9])));
  edit10.Text:=inttostr(round(100*(h[10])));
  edit11.Text:=inttostr(round(100*(h[11])));
  edit12.Text:=inttostr(round(100*(h[12])));
  edit19.Text:=inttostr(round(100*(h[13])));
  edit20.Text:=inttostr(round(100*(h[14])));
  edit21.Text:=inttostr(round(100*(h[15])));
  scrollbar1.position:=100-round(100*h[1]);
  scrollbar2.position:=100-round(100*h[2]);
  scrollbar3.position:=100-round(100*h[3]);
  scrollbar4.position:=100-round(100*h[4]);
  scrollbar5.position:=100-round(100*h[5]);
  scrollbar6.position:=100-round(100*h[6]);
  scrollbar7.position:=100-round(100*h[7]);
  scrollbar8.position:=100-round(100*h[8]);
  scrollbar9.position:=100-round(100*h[9]);
  scrollbar10.position:=100-round(100*h[10]);
  scrollbar11.position:=100-round(100*h[11]);
  scrollbar12.position:=100-round(100*h[12]);
  scrollbar19.position:=100-round(100*h[13]);
  scrollbar20.position:=100-round(100*h[14]);
  scrollbar21.position:=100-round(100*h[15]);
  speedbutton3.down:=true;
  checkbox11.checked:=true;
  checkbox12.checked:=false;
  chd:=true;
end;

procedure TForm2.BitBtn13Click(Sender: TObject);

var i:integer;

begin
  if speedbutton3.down then
    begin
    h[1]:=100;
    for i:=2 to 15 do h[i]:=0;
    scrollbar1.Position:=0;
    scrollbar2.position:=100;
    scrollbar3.position:=100;
    scrollbar4.position:=100;
    scrollbar5.position:=100;
    scrollbar6.position:=100;
    scrollbar7.position:=100;
    scrollbar8.position:=100;
    scrollbar9.position:=100;
    scrollbar10.position:=100;
    scrollbar11.position:=100;
    scrollbar12.position:=100;
    scrollbar19.position:=100;
    scrollbar20.position:=100;
    scrollbar21.position:=100;
    checkbox11.checked:=true;
    checkbox12.checked:=false;
    chd:=true;
    end
  else
    begin
    for i:=0 to 1023 do samples[-1,i]:=0;
    image1.canvas.clear;
    image1.canvas.moveto(0,127);
    image1.canvas.lineto(1023,127);
    end;
end;

procedure TForm2.BitBtn15Click(Sender: TObject);

var temp,temp2:array[-100..356] of double;
    i,j:integer;
    q,mini,maxi,skala:double;
    a:integer;

begin

  a:=spinedit2.value;
  mini:=255;
  maxi:=0;

for i:=-100 to 356 do temp[i]:=0;
if checkbox9.checked then for i:=-100 to 0 do temp[i]:=adsrs[-1,0];
if checkbox10.checked then for i:=256 to 356 do temp[i]:=adsrs[-1,255];
for i:=0 to 255 do temp[i]:=adsrs[-1,i];
for i:=0 to 255 do
  begin
  q:=0;
  for j:=-a to a do
    begin
    q:=q+temp[i+j];
    end;
    temp2[i]:=(q/(2*a+1));
    if temp2[i]>maxi then maxi:=temp2[i];
    if temp2[i]<mini then mini:=temp2[i];
   end;
  if checkbox7.checked then
  begin
  skala:=255/(maxi-mini);
  for i:=0 to 255 do
    begin
    temp2[i]:=(temp2[i]-mini)*skala;
    if temp2[i]<0 then temp2[i]:=0;
    if temp2[i]>255 then temp2[i]:=255;
    adsrs[-1,i]:=round(temp2[i]);
    end;
  end
  else
  for i:=0 to 255 do adsrs[-1,i]:=round(temp2[i]);

  chg4:=true;
end;


procedure addchannel(channel,sample,adsr:integer;freq:double;vol,pan,len,start,stop:integer;var t:integer);

begin
addchannel3(channel,t,1,sample,adsr,trunc(1000*freq),vol,len,0);
t:=t+len;
end;

procedure TForm2.BitBtn1Click(Sender: TObject);

var t:integer;


begin
sdl_pauseaudio(0);
indeksy2[-1]:=0;
gain:=1;
play:=false;
t:=0;
atari:=false;
starttrack;
if checkbox1.checked then
  begin
  addchannel(-1,-1,-1,dzwieki[-2,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-2,2],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-2,4],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-2,5],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-2,7],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-2,9],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-2,11],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-1,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,9],0,0,testlen,0,0,t);
  end;
if checkbox2.checked then
  begin
  addchannel(-1,-1,-1,dzwieki[-1,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-1,2],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-1,4],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-1,5],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-1,7],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-1,9],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-1,11],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[0,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,9],0,0,testlen,0,0,t);
  end;
if checkbox3.checked then
  begin
  addchannel(-1,-1,-1,dzwieki[-0,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,2],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,4],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,5],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,7],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,9],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,11],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[1,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,9],0,0,testlen,0,0,t);
  end;
if checkbox4.checked then
  begin
  addchannel(-1,-1,-1,dzwieki[1,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[1,2],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[1,4],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[1,5],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[1,7],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[1,9],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[1,11],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[2,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,9],0,0,testlen,0,0,t);
  end;
if checkbox5.checked then
  begin
  addchannel(-1,-1,-1,dzwieki[2,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[2,2],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[2,4],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[2,5],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[2,7],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[2,9],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[2,11],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[3,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,9],0,0,testlen,0,0,t);
  end;
if checkbox6.checked then
  begin
  addchannel(-1,-1,-1,dzwieki[3,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[3,2],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[3,4],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[3,5],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[3,7],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[3,9],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[3,11],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[4,0],32767,0,testlen,0,0,t);
  addchannel(-1,-1,-1,dzwieki[-0,9],0,0,testlen,0,0,t);
  end;

if checkbox8.checked then
  addchannel(-1,-1,-1,spinedit1.value,32767,0,testlen,0,0,t);

endtrack(t);
//start:=true;
play:=true;
end;

procedure TForm2.BitBtn3Click(Sender: TObject);

var fh,i:integer;
    bufor:array[0..256] of byte;

begin
for i:=0 to 256 do bufor[i]:=0; //wyczyść bufor
opendialog1.Title:='Open Atari Softsynth wave definition';
opendialog1.DefaultExt:='.s';
opendialog1.InitialDir:=s_dir;
if opendialog1.execute then
  begin
  fh:=fileopen(opendialog1.filename,$40);
  fileread(fh,bufor,256);
  fileclose(fh);
  bufor[256]:=bufor[0];
  for i:=0 to 256 do if bufor[i]>15 then bufor[i]:=15;

  for i:=0 to 255 do

  //wygładzanie wstępne
    begin
    samples[-1,4*i]:=round(4096*(bufor[i]-7.5));
    samples[-1,4*i+1]:=round(3072*(bufor[i]-7.5)+1024*(bufor[i+1]-7.5));
    samples[-1,4*i+2]:=round(2048*(bufor[i]-7.5)+2048*(bufor[i+1]-7.5));
    samples[-1,4*i+3]:=round(1024*(bufor[i]-7.5)+3072*(bufor[i+1]-7.5));
    end;
  //rysowanie fali

  form2.image1.canvas.clear;
  form2.image1.canvas.refresh;
  form2.image1.canvas.moveto(0,128-samples[-1,0] div 256);
  for i:=1 to 1023 do form2.image1.canvas.lineto(i,128-samples[-1,i] div 256);
  label40.caption:='Wave: '+opendialog1.filename;
  end;
end;

procedure TForm2.BitBtn4Click(Sender: TObject);

var i,fh:integer;
bufor:array[0..2080] of byte;
bufor2:array[0..1040]of smallint absolute bufor;

begin
savedialog1.Title:='Save 16-bit wave definition';
savedialog1.InitialDir:=s_dir;
savedialog1.DefaultExt:='s2';
if savedialog1.execute then
  begin
  if fileexists(savedialog1.filename) then
    if messagedlg('File exists - overwrite?',MtConfirmation,[Mbyes,MbNo],0)<>MrYes then exit;
  fh:=filecreate(savedialog1.filename);
  //16 bajtów nagłówka
  //0..1 - 's2'
  //2..5 - długość próbki w bajtach
  //6 - rozdzielczość w bitach
  //7..15 - reserved
  bufor[0]:=byte('s');
  bufor[1]:=byte('2');
  bufor[2]:=0;
  bufor[3]:=4;
  bufor[4]:=0;
  bufor[5]:=0;
  bufor[6]:=16;
  for i:=7 to 15 do bufor[i]:=0;
  for i:=8 to 1031 do bufor2[i]:=samples[-1,i-8];
  filewrite(fh,bufor,2064);
  fileclose(fh);
  end;
end;

procedure TForm2.BitBtn9Click(Sender: TObject);

var i,fh:integer;
bufor:array[0..2080] of byte;

begin
opendialog2.Title:='Open 8-bit adsr definition';
opendialog2.InitialDir:=h_dir;
opendialog2.DefaultExt:='m2';
if opendialog2.execute then
  begin
  fh:=fileopen(opendialog2.filename,$40);
  fileread(fh,bufor,16);
  if (bufor[0]<>byte('h')) or (bufor[1]<>byte('2')) then
    begin
    messagedlg('Bad file format',MtError,[MbOk],0);
    fileclose(fh);
    exit;
    end;
  if (bufor[2]<>0) or (bufor[3]<>1) or (bufor[4]<>0) or (bufor[5]<>0) or (bufor[6]<>8) then
    begin
    messagedlg('Bad file format',MtError,[MbOk],0);
    fileclose(fh);
    exit
    end;   //TODO in next versions: different wave formats
  fileread(fh,bufor,256);
  fileclose(fh);
  for i:=0 to 255 do adsrs[-1,i]:=bufor[i];


  form2.image2.canvas.clear;
  form2.image2.canvas.refresh;
  form2.image2.canvas.moveto(0,255-adsrs[-1,0]);
  for i:=1 to 255 do form2.image2.canvas.lineto(i,255-adsrs[-1,i]);
  label42.caption:='ADSR: '+opendialog2.filename;


  end;

end;

procedure TForm2.BitBtn7Click(Sender: TObject);

var bufor:array[0..64] of byte;
    i,fh:integer;

begin
  opendialog2.InitialDir:=h_dir;
  if opendialog2.execute then
    begin
      fh:=fileopen(opendialog2.filename,$40);
      fileread(fh,bufor,64);
      fileclose(fh);
      bufor[64]:=bufor[63];
      for i:=0 to 63 do
        begin
        adsrs[-1,4*i]:=round(16*(bufor[i]));
        adsrs[-1,4*i+1]:=round(12*(bufor[i])+4*(bufor[i+1]));
        adsrs[-1,4*i+2]:=round(8*(bufor[i])+8*(bufor[i+1]));
        adsrs[-1,4*i+3]:=round(4*(bufor[i])+12*(bufor[i+1]));
        end;
// smoothing

      form2.image2.canvas.clear;
      form2.image2.canvas.refresh;
form2.image2.canvas.moveto(0,255-adsrs[-1,0]);
for i:=1 to 255 do form2.image2.canvas.lineto(i,255-adsrs[-1,i]);
label42.caption:='ADSR: '+opendialog2.filename;
end;

end;

procedure TForm2.BitBtn8Click(Sender: TObject);

var i,fh:integer;
bufor:array[0..2080] of byte;

begin
savedialog1.Title:='Save 8-bit adsr definition';
savedialog1.InitialDir:=h_dir;
savedialog1.DefaultExt:='m2';
if savedialog1.execute then
  begin
  if fileexists(savedialog1.filename) then
    if messagedlg('File exists - overwrite?',MtConfirmation,[Mbyes,MbNo],0)<>MrYes then exit;
  fh:=filecreate(savedialog1.filename);
  //16 bajtów nagłówka
  //0..1 - 'h2'
  //2..5 - długość próbki w bajtach
  //6 - rozdzielczość w bitach
  //7..15 - reserved
  bufor[0]:=byte('h');
  bufor[1]:=byte('2');
  bufor[2]:=0;
  bufor[3]:=1;
  bufor[4]:=0;
  bufor[5]:=0;
  bufor[6]:=8;
  for i:=7 to 15 do bufor[i]:=0;
  for i:=16 to 271 do bufor[i]:=adsrs[-1,i-16];
  filewrite(fh,bufor,272);
  fileclose(fh);
  end;
end;

procedure TForm2.BitBtn5Click(Sender: TObject);

var i,fh:integer;
bufor:array[0..2080] of byte;
bufor2:array[0..1040] of smallint absolute bufor;

begin
opendialog1.Title:='Open 16-bit wave definition';
opendialog1.InitialDir:=s_dir;
opendialog1.DefaultExt:='s2';
if opendialog1.execute then
  begin
  fh:=fileopen(opendialog1.filename,$40);
  fileread(fh,bufor,16);
  if (bufor[0]<>byte('s')) or (bufor[1]<>byte('2')) then
    begin
    messagedlg('Bad file format',MtError,[MbOk],0);
    fileclose(fh);
    exit;
    end;
  if (bufor[2]<>0) or (bufor[3]<>4) or (bufor[4]<>0) or (bufor[5]<>0) or (bufor[6]<>16) then
    begin
    messagedlg('Bad file format',MtError,[MbOk],0);
    fileclose(fh);
    exit
    end;   //TODO in next versions: different wave formats
  fileread(fh,bufor2,2048);
  fileclose(fh);
  for i:=0 to 1023 do samples[-1,i]:=bufor2[i];


  form2.image1.canvas.clear;
  form2.image1.canvas.refresh;
  form2.image1.canvas.moveto(0,128-samples[-1,0] div 256);
  for i:=1 to 1023 do form2.image1.canvas.lineto(i,128-samples[-1,i] div 256);
  label40.caption:='Wave: '+opendialog1.filename;


  end;

end;


procedure TForm2.Button1Click(Sender: TObject);
begin

end;

procedure TForm2.CheckBox11Change(Sender: TObject);
begin
if speedbutton3.down then chd:=true;
end;

procedure TForm2.CheckBox12Change(Sender: TObject);
begin
  if speedbutton3.down then chd:=true;
end;

procedure TForm2.CheckBox3Change(Sender: TObject);
begin

end;

procedure TForm2.CheckBox7Change(Sender: TObject);
begin

end;

procedure TForm2.CheckBox8Change(Sender: TObject);
begin

end;

procedure TForm2.Edit1Change(Sender: TObject);

begin
end;

procedure TForm2.Edit1Exit(Sender: TObject);



var s:integer;

begin
  try
    s:=strtoint(edit1.text);
  except
    s:=100-scrollbar1.position;
    edit1.text:=inttostr(s);
  end;
  scrollbar1.position:=100-s;
end;



procedure TForm2.fft1GetData(index: integer; var Value: TComplex);
begin
  value.real:=samples[-1,index mod 1024];
  value.imag:=0;
end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  form1.show;
end;

procedure TForm2.FormCreate(Sender: TObject);

var i,j:integer;

begin
  for i:=2 to 12 do h[i]:=0;
  h[1]:=100;
  a[1]:=10;
  a[2]:=10;
  a[3]:=128;
  a[4]:=60;
  a[5]:=96;
  a[6]:=20;
  for i:=0 to 1023 do for j:=0 to 255 do image1.canvas.pixels[i,j]:=$FFFFFF;
  for i:=0 to 255 do for j:=0 to 255 do image2.canvas.pixels[i,j]:=$FFFFFF;
  przeliczsampla;
  przeliczadsr;
end;

procedure TForm2.Image1Click(Sender: TObject);
begin

end;

procedure TForm2.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  afw2:=true;
  if afw and (shift=[ssleft]) then
    begin
      ox:=x;
      oy:=y;

     end;
end;

procedure TForm2.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

var i,s,newsample,oldsample:integer; delta:double;

begin
  if x<0 then x:=0;
  if x>1023 then x:=1023;
  label39.caption:=inttostr(samples[-1,x]);

if afw and afw2 and (shift=[ssleft]) then
  begin
  newsample:=(128-y)*256;
  oldsample:=samples[-1,ox];
  if x-ox<>0 then delta:=(newsample-oldsample)/(x-ox) else delta:=1;
  if x>ox then
    begin
    for i:=ox to x do
      begin
      s:=round(oldsample+(i-ox)*delta);
      if s>32767 then s:=32767;
      if s<-32767 then s:=-32767;
      samples[-1,i]:=s;
      end;
    end;
  if x<ox then
    begin
    for i:=x to ox do
      begin
      s:=round(newsample+(i-x)*delta);
      if s>32767 then s:=32767;
      if s<-32767 then s:=-32767;
      samples[-1,i]:=s;
      end;
    end;

 ox:=x;
 oy:=y;
 label39.caption:=inttostr(samples[-1,x]);

     chg3:=true;

    end;
end;

procedure TForm2.Image2Click(Sender: TObject);
begin

end;

procedure TForm2.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if x<0 then x:=0;
if x>255 then x:=255;
  aafw2:=true;
  if shift=[ssleft] then
    begin
      oax:=x;
      oay:=y;
     adsrs[-1,x]:=255-y;
    chg4:=true;
     end;
end;


procedure TForm2.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var i,newsample,oldsample:integer; delta:double;

begin
  if x<0 then x:=0;
  if x>255 then x:=255;
  if y<0 then y:=0;
  if y>255 then y:=255;
  if aafw and aafw2 and (shift=[ssleft]) then
  begin
  newsample:=255-y;
  oldsample:=adsrs[-1,oax];
  if x-oax<>0 then delta:=(newsample-oldsample)/(x-oax) else delta:=1;
  if x>oax then
    begin
    for i:=oax to x do
      adsrs[-1,i]:=round(oldsample+(i-oax)*delta);
    end;
  if x<oax then
    begin
    for i:=x to oax do
      adsrs[-1,i]:=round(newsample+(i-x)*delta);
    end;

 oax:=x;
 oay:=y;


     chg4:=true;

    end;
end;

procedure TForm2.Image2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  aafw2:=true;
end;


procedure TForm2.ScrollBar10Change(Sender: TObject);
begin
  h[10]:=(100-scrollbar10.position)/100;
  if speedbutton3.Down then chd:=true;
  edit10.text:=inttostr(100-scrollbar10.position);
end;

procedure TForm2.ScrollBar11Change(Sender: TObject);
begin
    h[11]:=(100-scrollbar11.position)/100;
  if speedbutton3.Down then chd:=true;
  edit11.text:=inttostr(100-scrollbar11.position);
end;

procedure TForm2.ScrollBar12Change(Sender: TObject);
begin
  h[12]:=(100-scrollbar12.position)/100;
  if speedbutton3.Down then chd:=true;
  edit12.text:=inttostr(100-scrollbar12.position);
end;

procedure TForm2.ScrollBar13Change(Sender: TObject);
begin
  a[1]:=scrollbar13.position;
  if speedbutton4.Down then begin chd2:=true; end;
  edit13.text:=inttostr(scrollbar13.position);
end;

procedure TForm2.ScrollBar14Change(Sender: TObject);
begin
  a[2]:=scrollbar14.position;
  if speedbutton4.Down then begin chd2:=true; end;
  edit14.text:=inttostr(scrollbar14.position);

end;

procedure TForm2.ScrollBar15Change(Sender: TObject);
begin
  a[3]:=scrollbar15.position;
  if speedbutton4.Down then begin chd2:=true; end;
  edit15.text:=inttostr(scrollbar15.position);

end;

procedure TForm2.ScrollBar16Change(Sender: TObject);
begin
   a[4]:=scrollbar16.position;
  if speedbutton4.Down then begin chd2:=true; end;
  edit16.text:=inttostr(scrollbar16.position);
end;

procedure TForm2.ScrollBar17Change(Sender: TObject);
begin
    a[5]:=scrollbar17.position;
  if speedbutton4.Down then begin chd2:=true; end;
  edit17.text:=inttostr(scrollbar17.position);

end;

procedure TForm2.ScrollBar18Change(Sender: TObject);
begin
    a[6]:=scrollbar18.position;
  if speedbutton4.Down then begin chd2:=true; end;
  edit18.text:=inttostr(scrollbar18.position);

end;

procedure TForm2.ScrollBar19Change(Sender: TObject);
begin
  h[13]:=(100-scrollbar19.position)/100;
  if speedbutton3.Down then begin chd:=true; end;
  edit19.text:=inttostr(100-scrollbar19.position);
end;

procedure TForm2.ScrollBar1Change(Sender: TObject);
begin
  h[1]:=(100-scrollbar1.position)/100;
  if speedbutton3.Down then begin chd:=true; end;
  edit1.text:=inttostr(100-scrollbar1.position);
end;

procedure TForm2.ScrollBar20Change(Sender: TObject);
begin
   h[14]:=(100-scrollbar20.position)/100;
  if speedbutton3.Down then begin chd:=true; end;
  edit20.text:=inttostr(100-scrollbar20.position);

end;

procedure TForm2.ScrollBar21Change(Sender: TObject);
begin
  h[15]:=(100-scrollbar21.position)/100;
  if speedbutton3.Down then begin chd:=true; end;
  edit21.text:=inttostr(100-scrollbar21.position);

end;

procedure TForm2.ScrollBar22Change(Sender: TObject);
begin
s[1]:=100-scrollbar22.position;
if speedbutton3.Down then chd:=true;
edit22.text:=inttostr(100-scrollbar22.position);
end;

procedure TForm2.ScrollBar23Change(Sender: TObject);
begin
s[2]:=100-scrollbar23.position;
if speedbutton3.Down then chd:=true;
edit23.text:=inttostr(100-scrollbar23.position);
end;

procedure TForm2.ScrollBar24Change(Sender: TObject);
begin
s[3]:=100-scrollbar24.position;
if speedbutton3.Down then chd:=true;
edit24.text:=inttostr(100-scrollbar24.position);
end;

procedure TForm2.ScrollBar25Change(Sender: TObject);
begin
s[4]:=100-scrollbar25.position;
if speedbutton3.Down then chd:=true;
edit25.text:=inttostr(100-scrollbar25.position);
end;

procedure TForm2.ScrollBar26Change(Sender: TObject);
begin
s[5]:=100-scrollbar26.position;
if speedbutton3.Down then chd:=true;
edit26.text:=inttostr(100-scrollbar26.position);
end;

procedure TForm2.ScrollBar27Change(Sender: TObject);
begin
s[6]:=100-scrollbar27.position;
if speedbutton3.Down then chd:=true;
edit27.text:=inttostr(100-scrollbar27.position);
end;

procedure TForm2.ScrollBar2Change(Sender: TObject);
begin
   h[2]:=(100-scrollbar2.position)/100;
  if speedbutton3.Down then chd:=true;
  edit2.text:=inttostr(100-scrollbar2.position);
end;

procedure TForm2.ScrollBar3Change(Sender: TObject);
begin
   h[3]:=(100-scrollbar3.position)/100;
  if speedbutton3.Down then chd:=true;
  edit3.text:=inttostr(100-scrollbar3.position);
end;

procedure TForm2.ScrollBar4Change(Sender: TObject);
begin
   h[4]:=(100-scrollbar4.position)/100;
  if speedbutton3.Down then chd:=true;
  edit4.text:=inttostr(100-scrollbar4.position);
end;

procedure TForm2.ScrollBar5Change(Sender: TObject);
begin
  h[5]:=(100-scrollbar5.position)/100;
  if speedbutton3.Down then chd:=true;
  edit5.text:=inttostr(100-scrollbar5.position);
end;

procedure TForm2.ScrollBar6Change(Sender: TObject);
begin
  h[6]:=(100-scrollbar6.position)/100;
  if speedbutton3.Down then chd:=true;
  edit6.text:=inttostr(100-scrollbar6.position);
end;

procedure TForm2.ScrollBar7Change(Sender: TObject);
begin
  h[7]:=(100-scrollbar7.position)/100;
  if speedbutton3.Down then chd:=true;
  edit7.text:=inttostr(100-scrollbar7.position);
end;

procedure TForm2.ScrollBar8Change(Sender: TObject);
begin
  h[8]:=(100-scrollbar8.position)/100;
  if speedbutton3.Down then chd:=true;
  edit8.text:=inttostr(100-scrollbar8.position);
end;

procedure TForm2.ScrollBar9Change(Sender: TObject);
begin
  h[9]:=(100-scrollbar9.position)/100;
  if speedbutton3.Down then chd:=true;
  edit9.text:=inttostr(100-scrollbar9.position);
end;

procedure TForm2.SpeedButton2Click(Sender: TObject);
begin
speedbutton2.down:=true;
speedbutton3.Down:=false;
afw:=true;
end;

procedure TForm2.SpeedButton2DblClick(Sender: TObject);
begin
  speedbutton2.click;
  afw:=true;
end;

procedure TForm2.SpeedButton3Click(Sender: TObject);
begin
  speedbutton2.Down:=false;
  chd:=true;
  afw:=false;
end;

procedure TForm2.SpeedButton4Click(Sender: TObject);
begin
  if not speedbutton5.down then aafw:=false;
end;

procedure TForm2.SpeedButton5Click(Sender: TObject);
begin
  speedbutton5.down:=true;
  if speedbutton5.down then aafw:=true;
end;

procedure TForm2.SpinEdit2Change(Sender: TObject);
begin

end;

procedure TForm2.SpinEdit3Change(Sender: TObject);
begin
  testlen:=spinedit3.value;
end;

procedure TForm2.Timer1Timer(Sender: TObject);

var i:integer;

begin
  if chd then
    begin
      przeliczsampla;
      chd:=false;
    end;
  if chd2 then
    begin
      przeliczadsr;
      chd2:=false;
    end;
  if chg3 then
    begin
                  form2.image1.canvas.clear;
      form2.image1.canvas.refresh;
form2.image1.canvas.moveto(0,128-samples[-1,0] div 256);
for i:=1 to 1023 do form2.image1.canvas.lineto(i,128-samples[-1,i] div 256);
    chg3:=false;

    end;
    if chg4 then
      begin
                    form2.image2.canvas.clear;
        form2.image2.canvas.refresh;
  form2.image2.canvas.moveto(0,255-adsrs[-1,0]);
  for i:=1 to 255 do form2.image2.canvas.lineto(i,255-adsrs[-1,i]);
      chg4:=false;
  end;
end;

procedure TForm2.Timer2Timer(Sender: TObject);
begin
  if play then bitbtn1.color:=$FF else bitbtn1.color:=ClBtnFace;
end;

end.

