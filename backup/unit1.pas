unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, sdl3;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  window: PSDL_Window;
  renderer: PSDL_Renderer;


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);

var WindowSize: TSDL_Point = (x: 1024; y: 600);

begin

if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO or SDL_INIT_EVENTS) then
  exit;


window := SDL_CreateWindow('SDL3 Window', WindowSize.x, WindowSize.y, SDL_WINDOW_RESIZABLE);
if window = nil then begin
end;

renderer := SDL_CreateRenderer(window, nil);
if renderer = nil then begin
end;

end;

end;

end.

