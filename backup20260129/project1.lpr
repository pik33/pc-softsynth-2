program project1;


// PC Softsynth
// License: GNU GPL
// see README for details



{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, Unit2, Unit3, fft1
  { you can add units after this };

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
//  Application.CreateForm(TForm2, Form2);
//  Application.CreateForm(TForm3, Form3);
//  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.

