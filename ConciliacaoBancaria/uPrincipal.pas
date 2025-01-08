unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Soap.InvokeRegistry, IdHTTP, IdSSL, IdSSLOpenSSL,
  Vcl.StdCtrls;


type
  TfrmPrincipal = class(TForm)
    Button2: TButton;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses uOxymed;

procedure TfrmPrincipal.Button1Click(Sender: TObject);
var Bradesco : TBradesco;
    vData1, vData2 : TDateTime;
begin
     Bradesco := TBradesco.Create;
     Bradesco.RazaoSocial := 'OXYMED COMERCIO E LOCACAO DE EQUIPAMENTO';
     Bradesco.CNPJ := '38.052.160/0057-01';
     Bradesco.Agencia := '3995';
     Bradesco.Conta := '75557-5';
     Bradesco.ClienteID := 0000;
     Bradesco.CertificadoDigital := 'xxxx';
     Memo1.Lines.Clear;
     vData1 := Date;
     vData2 := Date + 30;
     Memo1.Text := Bradesco.Extrato(vData1,vData2);
     Bradesco.Free;
end;

end.


