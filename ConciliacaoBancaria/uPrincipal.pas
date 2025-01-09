unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Soap.InvokeRegistry, IdHTTP, IdSSL, IdSSLOpenSSL,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, System.IniFiles, System.Rtti,
  IdCoderMIME, IdGlobal;


type
  TfrmPrincipal = class(TForm)
    Panel1: TPanel;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Memo1: TMemo;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    edtRazaoSocial: TEdit;
    Label2: TLabel;
    edtCNPJ: TEdit;
    Label3: TLabel;
    edtChaveCertificado: TEdit;
    Panel2: TPanel;
    Button3: TButton;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtAgenciaBradesco: TEdit;
    edtContaBradesco: TEdit;
    edtClienteKeyBradesco: TEdit;
    edtClienteSecretBradesco: TEdit;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    Label8: TLabel;
    Edit6: TEdit;
    Edit7: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Edit8: TEdit;
    Label11: TLabel;
    Edit9: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Button1: TButton;
    Memo2: TMemo;
    Memo3: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure LerConfig;
    procedure GravarConfig;
    function CriptografarTexto(const Texto: string): string;
    function DescriptografarTexto(const Texto: string): string;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses uOxymed;

const
  ARQUIVO_INI = 'oxymed.ini';
  CHAVE_CRIPTOGRAFIA = 'OXYMED COMERCIO E LOCACAO DE EQUIPAMENTO'; // Troque pela chave que voc� usar para criptografar



procedure TfrmPrincipal.Button1Click(Sender: TObject);
var Bradesco : TBradesco;
    vData1, vData2 : TDateTime;
begin
     Bradesco := TBradesco.Create;
//     Memo2.Lines.Clear;
//     Memo2.Lines.Add('Header:');
//     Memo2.Lines.Add(Bradesco.Header);
//     Memo2.Lines.Add(' ');
//     Memo2.Lines.Add('Payload:');
//     Memo2.Lines.Add(Bradesco.Payload);
//     Memo2.Lines.Add(' ');
//     Memo2.Lines.Add('JWS:');
//     Memo2.Lines.Add(Bradesco.JWS);

     Bradesco.RazaoSocial := edtRazaoSocial.Text; // 'OXYMED COMERCIO E LOCACAO DE EQUIPAMENTO';
     Bradesco.CNPJ := edtCNPJ.Text; //'38.052.160/0057-01';
     Bradesco.ClientKey := edtClienteKeyBradesco.Text;
     Bradesco.Agencia := edtAgenciaBradesco.Text; //'3995';
     Bradesco.Conta := edtContaBradesco.Text; // '75557-5';
     //Bradesco.ClienteID := 0000;
     Bradesco.CertificadoDigital := edtChaveCertificado.Text;// 'xxxx';
     Memo1.Lines.Clear;
     vData1 := Date-30;
     vData2 := Date;
     Memo1.Text := Bradesco.Extrato(vData1,vData2);
     Memo2.Lines.Add('Token:');
     Memo2.Lines.Add(Bradesco.Token);
     Bradesco.Free;
end;


procedure TfrmPrincipal.Button3Click(Sender: TObject);
begin
   GravarConfig;
end;

function TfrmPrincipal.CriptografarTexto(const Texto: string): string;
var
  i: integer;
  OutValue: AnsiString;
begin
  OutValue := '';
  for i := 1 to Length(Texto) do
    OutValue := OutValue + Ansichar(Not(ord(Texto[i]) - 15));
  result := OutValue;
end;


function TfrmPrincipal.DescriptografarTexto(const Texto: string): string;
var
  i: integer;
  OutValue: AnsiString;
begin
  OutValue := '';
  for i := 1 to Length(Texto) do
    OutValue := OutValue + Ansichar(Not(ord(Texto[i])) + 15);
  result := OutValue;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
   LerConfig;
end;

procedure TfrmPrincipal.GravarConfig;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ARQUIVO_INI);
  try
    Ini.WriteString('Empresa', 'RazaoSocial', CriptografarTexto(edtRazaoSocial.Text));
    Ini.WriteString('Empresa', 'CNPJ', CriptografarTexto(edtCNPJ.Text));
    Ini.WriteString('Certificados', 'ChaveCertificado', CriptografarTexto(edtChaveCertificado.Text));
    Ini.WriteString('Bradesco', 'Conta', CriptografarTexto(edtContaBradesco.Text));
    Ini.WriteString('Bradesco', 'Agencia', CriptografarTexto(edtAgenciaBradesco.Text));
    //Ini.WriteString('Bradesco', 'ID', CriptografarTexto(edtClienteID.Text));
    Ini.WriteString('Bradesco', 'Key', CriptografarTexto(edtClienteKeyBradesco.Text));
    Ini.WriteString('Bradesco', 'Secret', CriptografarTexto(edtClienteSecretBradesco.Text));
  finally
    Ini.Free;
  end;
end;

procedure TfrmPrincipal.LerConfig;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ARQUIVO_INI);
  try

    edtRazaoSocial.Text := DescriptografarTexto(Ini.ReadString('Empresa', 'RazaoSocial', ''));
    edtCNPJ.Text := DescriptografarTexto(Ini.ReadString('Empresa', 'CNPJ', ''));
    edtChaveCertificado.Text := DescriptografarTexto(Ini.ReadString('Certificados', 'ChaveCertificado', ''));
    edtContaBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'Conta', ''));
    edtAgenciaBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'Agencia', ''));
    //edtClienteID.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'ID', ''));
    edtClienteKeyBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'Key', ''));
    edtClienteSecretBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'Secret', ''));
  finally
    Ini.Free;
  end;
end;

end.


