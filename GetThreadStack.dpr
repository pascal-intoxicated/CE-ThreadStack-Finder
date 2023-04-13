program GetThreadStack;

uses
  Vcl.Forms,
  _InterfaceClass in '_InterfaceClass.pas' {InterfaceUI},
  _GetThreadStackClass in 'Classes\_GetThreadStackClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TInterfaceUI, InterfaceUI);
  Application.Run;
end.
