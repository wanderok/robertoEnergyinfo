unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Soap.InvokeRegistry, IdHTTP, IdSSL, IdSSLOpenSSL,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, System.IniFiles, System.Rtti,
  IdCoderMIME, IdGlobal, uOxymed, System.JSON;



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
    Label15: TLabel;
    edtPastaDeTrabalhoBradesco: TEdit;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    Memo7: TMemo;
    Memo8: TMemo;
    Memo9: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure LerConfig;
    procedure GravarConfig;
    function CriptografarTexto(const Texto: string): string;
    function DescriptografarTexto(const Texto: string): string;
    procedure PreencheMemos(Bradesco:TBradesco);
//    procedure PosicionarNoInicio(Memo:TMemo);
    procedure PosicionarNoInicio;
    procedure ScrollMemo(Memo: TMemo; Direction: Integer);
    procedure FormatAndDisplayJson(const JsonStr: string; Memo: TMemo);
      public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}


const
  ARQUIVO_INI = 'oxymed.ini';
  CHAVE_CRIPTOGRAFIA = 'OXYMED COMERCIO E LOCACAO DE EQUIPAMENTO'; // Troque pela chave que voc� usar para criptografar



procedure TfrmPrincipal.Button1Click(Sender: TObject);
var Bradesco : TBradesco;
    vData1, vData2 : TDateTime;
begin
     Bradesco := TBradesco.Create;

     LerConfig;
     Bradesco.RazaoSocial := edtRazaoSocial.Text; // 'OXYMED COMERCIO E LOCACAO DE EQUIPAMENTO';
     Bradesco.CNPJ := edtCNPJ.Text; //'38.052.160/0057-01';
     Bradesco.ClientKey := edtClienteKeyBradesco.Text;
     Bradesco.Agencia := edtAgenciaBradesco.Text; //'3995';
     Bradesco.Conta := edtContaBradesco.Text; // '75557-5';
     Bradesco.PastaDeTrabalho:= edtPastaDeTrabalhoBradesco.Text;
     //Bradesco.ClienteID := 0000;
     Bradesco.CertificadoDigital := edtChaveCertificado.Text;// 'xxxx';
     Memo1.Lines.Clear;
     vData1 := Date-30;
     vData2 := Date;

     Bradesco.Iniciar;
     PreencheMemos(Bradesco);
     PosicionarNoInicio;

     Memo9.Lines.Clear;
     Memo9.Lines.Add('BearerToken:');
     Memo9.Lines.Add('');
     Memo9.lines.add(Bradesco.Extrato(vData1,vData2));
     Memo9.SelStart := 0;

     PreencheMemos(Bradesco);

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
  localDoArquivoINI: String;
begin
  if edtPastaDeTrabalhoBradesco.Text = '' then
  begin
    edtPastaDeTrabalhoBradesco.Text := 'C:\WANDER';
  end;

  localDoArquivoINI := edtPastaDeTrabalhoBradesco.Text+'\'+ARQUIVO_INI;
  Ini := TIniFile.Create(localDoArquivoINI);
  try
    Ini.WriteString('Empresa', 'RazaoSocial', CriptografarTexto(edtRazaoSocial.Text));
    Ini.WriteString('Empresa', 'CNPJ', CriptografarTexto(edtCNPJ.Text));
    Ini.WriteString('Certificados', 'ChaveCertificado', CriptografarTexto(edtChaveCertificado.Text));
    Ini.WriteString('Bradesco', 'Conta', CriptografarTexto(edtContaBradesco.Text));
    Ini.WriteString('Bradesco', 'Agencia', CriptografarTexto(edtAgenciaBradesco.Text));
    //Ini.WriteString('Bradesco', 'ID', CriptografarTexto(edtClienteID.Text));
    Ini.WriteString('Bradesco', 'Key', CriptografarTexto(edtClienteKeyBradesco.Text));
    Ini.WriteString('Bradesco', 'Secret', CriptografarTexto(edtClienteSecretBradesco.Text));
    Ini.WriteString('Bradesco', 'PastaDeTrabalho', CriptografarTexto(edtPastaDeTrabalhoBradesco.Text));
  finally
    Ini.Free;
  end;
end;

procedure TfrmPrincipal.LerConfig;
var
  Ini: TIniFile;
  localDoArquivoINI: String;
begin
  if edtPastaDeTrabalhoBradesco.Text = '' then
  begin
    edtPastaDeTrabalhoBradesco.Text := 'C:\WANDER';
  end;
  localDoArquivoINI := edtPastaDeTrabalhoBradesco.Text+'\'+ARQUIVO_INI;
  Ini := TIniFile.Create(localDoArquivoINI);
  try
    edtRazaoSocial.Text := DescriptografarTexto(Ini.ReadString('Empresa', 'RazaoSocial', ''));
    edtCNPJ.Text := DescriptografarTexto(Ini.ReadString('Empresa', 'CNPJ', ''));
    edtChaveCertificado.Text := DescriptografarTexto(Ini.ReadString('Certificados', 'ChaveCertificado', ''));
    edtContaBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'Conta', ''));
    edtAgenciaBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'Agencia', ''));
    //edtClienteID.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'ID', ''));
    edtClienteKeyBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'Key', ''));
    edtClienteSecretBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'Secret', ''));
    edtPastaDeTrabalhoBradesco.Text := DescriptografarTexto(Ini.ReadString('Bradesco', 'PastaDeTrabalho', ''));
  finally
    Ini.Free;
  end;
end;


//procedure TfrmPrincipal.PosicionarNoInicio(Memo: TMemo);
//begin
//  Memo.SelStart := 0;
//  Perform(WM_VSCROLL, SB_TOP, 0);
//end;

procedure TfrmPrincipal.PreencheMemos(Bradesco: TBradesco);
begin
     Memo1.Lines.Clear;
     Memo1.Lines.Add('Header:');
     Memo1.Lines.Add('');
     FormatAndDisplayJson(Bradesco.Header, Memo1);
//     Memo1.lines.add(Bradesco.Header);

     Memo2.Lines.Clear;
     Memo2.Lines.Add('HeaderBase64:');
     Memo2.Lines.Add('');
     Memo2.lines.add(Bradesco.HeaderBase64);

     Memo3.Lines.Clear;
     Memo3.Lines.Add('Payload:');
     Memo3.Lines.Add('');
     FormatAndDisplayJson(Bradesco.Payload, Memo3);


     Memo4.Lines.Clear;
     Memo4.Lines.Add('PayloadBase64:');
     Memo4.Lines.Add('');
     Memo4.lines.add(Bradesco.PayloadBase64);

     Memo5.Lines.Clear;
     Memo5.Lines.Add('JWT:');
     Memo5.Lines.Add('');
     Memo5.Lines.Add(Bradesco.JWT);

     Memo6.Lines.Clear;
     Memo6.Lines.Add('Assinatura:');
     Memo6.Lines.Add('');
     Memo6.lines.add(Bradesco.Assinatura);

     Memo7.Lines.Clear;
     Memo7.Lines.Add('JWS:');
     Memo7.Lines.Add('');
     Memo7.lines.add(Bradesco.JWS);

     Memo8.Lines.Clear;
     Memo8.Lines.Add('BearerToken:');
     Memo8.Lines.Add('');
     Memo8.lines.add(Bradesco.BearerToken);
end;


procedure TfrmPrincipal.PosicionarNoInicio;
var
  i: Integer;
begin
   //ScrollMemo(Memo1, SB_LINEUP); // Rola para o in�cio
   //ScrollMemo(Memo1, SB_LINEDOWN); // Rola para o final
  // Itera por todos os componentes no Formul�rio
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TMemo then
    begin
      ScrollMemo((Components[i] as TMemo), SB_LINEUP);

//      TMemo(Components[i]).SetFocus;
//      TMemo(Components[i]).SelStart := 0; // Posiciona o cursor no in�cio
//      TMemo(Components[i]).Perform(WM_VSCROLL, SB_TOP, 0); // Rolagem para o topo
    end;
  end;
end;

procedure TfrmPrincipal.ScrollMemo(Memo: TMemo; Direction: Integer);
var
  ScrollMessage: TWMVScroll;
  I: Integer;
begin
  ScrollMessage.Msg := WM_VSCROLL;
  Memo.Lines.BeginUpdate;
  try
    for I := 0 to Memo.Lines.Count do
    begin
     ScrollMessage.ScrollCode := Direction;
     ScrollMessage.Pos := 0;
     Memo.Dispatch(ScrollMessage);
    end;
  finally
    Memo.Lines.EndUpdate;
  end;
end;


procedure TfrmPrincipal.FormatAndDisplayJson(const JsonStr: string; Memo: TMemo);
var
  JsonValue: TJSONObject;
  PrettyJson: string;
begin
  // Converte a string JSON para um objeto JSON
  JsonValue := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
  try
    if JsonValue <> nil then
    begin
      // Formata o JSON com indenta��o
      PrettyJson := JsonValue.Format(2);  // O n�mero 2 define o n�mero de espa�os para a indenta��o

      // Exibe o JSON formatado no TMemo
      Memo.Lines.add(PrettyJson);
    end
    else
      Memo.Lines.add('JSON inv�lido.');
  finally
    JsonValue.Free;
  end;
end;


end.

