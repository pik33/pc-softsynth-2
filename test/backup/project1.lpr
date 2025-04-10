program project1;

{$mode objfpc}{$H+}
{$MAXSTACKSIZE 2000000000}

uses

  cthreads,

  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, cwindows, retro, fft1, audio
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

