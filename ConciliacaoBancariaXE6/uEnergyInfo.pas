unit uEnergyInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdHTTP, IdSSL, IdSSLOpenSSL,
  Vcl.StdCtrls,
  IdGlobal,
   System.JSON;

type
TBradesco = class
  private
    FRazaoSocial: string;
    FClienteID: Integer;
    FCNPJ: string;
    FCertificadoDigital: string;
    FConta:String;
    FAgencia:String;
  public
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property ClienteID: Integer read FClienteID write FClienteID;
    property CNPJ: string read FCNPJ write FCNPJ;
    property CertificadoDigital: string read FCertificadoDigital write FCertificadoDigital;
    property Conta: string read FConta write FConta;
    property Agencia: string read FAgencia write FAgencia;
    function Extrato(Inicio, Fim: TDateTime): String;
  end;
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

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

procedure TForm1.Button1Click(Sender: TObject);
var
  HttpClient: TIdHTTP;
  Response: string;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  HttpClient := TIdHTTP.Create(nil);
  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);

  // Atribuir o manipulador SSL
    HttpClient.IOHandler := SSLIOHandler;
    SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  try
    // Configurar para lidar com SSL (caso seja necess�rio para APIs HTTPS)
    HttpClient.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);

    try
      // Realizar a requisi��o GET
      //Response := HttpClient.Get('http://localhost:3000/api/grafico001');
      Response := HttpClient.Get('https://dicas-on-line.vercel.app/api/dicas');
      Memo1.Lines.Text := Response;
    except
      on E: Exception do
      begin
        Memo1.Lines.Text := E.Message;
        ShowMessage('Erro: ' + E.Message);
      end;
    end;
  finally
    HttpClient.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  HttpClient: TIdHTTP;
  StringStream: TStringStream;
  JsonToSend: TJSONObject;
  Response: string;
begin
  HttpClient := TIdHTTP.Create(nil);
  StringStream := TStringStream.Create('', TEncoding.UTF8);
  try
    // Configurar para lidar com SSL (caso seja necess�rio para APIs HTTPS)
    HttpClient.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);

    // Criando o JSON para enviar
    JsonToSend := TJSONObject.Create;
    JsonToSend.AddPair('title', 'foo');
    JsonToSend.AddPair('body', 'bar');
    JsonToSend.AddPair('userId', '1');

    // Convertendo JSON para string
    StringStream.WriteString(JsonToSend.ToString);
    StringStream.Position := 0;  // Resetando a posi��o do stream para leitura

    try
      // Enviar requisi��o POST
      HttpClient.Request.ContentType := 'application/json';
      HttpClient.Request.Charset := 'utf-8';
      Response := HttpClient.Post('https://jsonplaceholder.typicode.com/posts', StringStream);

      // Exibir resposta
      Memo1.Lines.Text := Response;
    except
      on E: Exception do
      begin
        Memo1.Lines.Text := E.Message;
        ShowMessage('Erro: ' + E.Message);
      end;
    end;
  finally
    JsonToSend.Free;
    StringStream.Free;
    HttpClient.Free;
  end;
end;

procedure TForm1.ok;
begin

end;

{ TBradesco }

function TBradesco.Extrato(Inicio, Fim: TDateTime): String;
var
  HttpClient: TIdHTTP;
  Response: string;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  Retorno : TStringList;
begin

  Retorno := TStringList.Create;
  HttpClient := TIdHTTP.Create(nil);
  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);

  // Atribuir o manipulador SSL
    HttpClient.IOHandler := SSLIOHandler;
    SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  try
    // Configurar para lidar com SSL (caso seja necess�rio para APIs HTTPS)
    HttpClient.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);

    try
      // Realizar a requisi��o GET
      //Response := HttpClient.Get('http://localhost:3000/api/grafico001');
      Response := HttpClient.Get('https://dicas-on-line.vercel.app/api/dicas');
      Retorno.Text := Response;
    except
      on E: Exception do
      begin
        Retorno.Text := E.Message;
        ShowMessage('Erro: ' + E.Message);
      end;
    end;
    result := Retorno.Text;
  finally
    Retorno.Free;
    HttpClient.Free;
  end;
end;


end.



=============================

Trabalhando com Resposta JSON

Se a API retornar um JSON, voc� pode fazer o parsing da resposta usando as classes TJSONObject ou TJSONArray:

uses
  System.JSON;

procedure TForm1.Button3Click(Sender: TObject);
var
  JsonResponse: TJSONObject;
  JsonArray: TJSONArray;
  Response: string;
begin
  HttpClient := TIdHTTP.Create(nil);
  try
    Response := HttpClient.Get('https://jsonplaceholder.typicode.com/posts');

    // Parse do JSON na resposta
    JsonResponse := TJSONObject.ParseJSONValue(Response) as TJSONObject;
    try
      // Exemplo de como acessar valores espec�ficos
      JsonArray := JsonResponse.GetValue<TJSONArray>('posts');
      Memo1.Lines.Text := JsonArray.ToString;
    finally
      JsonResponse.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
  HttpClient.Free;
end;

