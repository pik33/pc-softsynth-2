unit Unit3; 

// PC Softsynth
// License: GNU GPL
// see README for details

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, fft;

type

  { TForm3 }

  TForm3 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure DSXFastFourier1GetData(index: integer; var Value: TComplex);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form3: TForm3; 

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.DSXFastFourier1GetData(index: integer; var Value: TComplex);
begin

end;

procedure TForm3.BitBtn1Click(Sender: TObject);
begin

end;

procedure TForm3.BitBtn2Click(Sender: TObject);
begin

end;

end.

