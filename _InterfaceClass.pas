unit _InterfaceClass;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls;

type
  TInterfaceUI = class(TForm)
    ListView1: TListView;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  InterfaceUI: TInterfaceUI;

implementation

uses
  _GetThreadStackClass;

{$R *.dfm}

procedure TInterfaceUI.Button1Click(Sender: TObject);
var
  Index           : Integer;
  ThreadStackList : TStringList;
begin
  ThreadStackList := TStringList.Create();
  try
    GetThreadStackPtrs(GetCurrentProcess, ThreadStackList, GetCurrentProcessId);
    if (ThreadStackList.Count <> 0) then begin
      for Index := 0 to ThreadStackList.Count - 1 do begin

      end;
    end else begin
      ShowMessage('ThreadStack not found');
    end;
  finally
    FreeAndNil(ThreadStackList);
  end;
end;

end.
