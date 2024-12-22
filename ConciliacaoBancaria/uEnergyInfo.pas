unit uEnergyInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ACBrBase, ACBrExtratoAPI;

type
  TForm1 = class(TForm)
    ACBrExtratoAPI1: TACBrExtratoAPI;
  private
    { Private declarations }
    procedure ok;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

procedure TForm1.ok;
begin
ACBrExtratoAPI1.ConsultarExtrato()
end;

end.
