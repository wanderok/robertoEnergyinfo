object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'frmPrincipal'
  ClientHeight = 811
  ClientWidth = 1244
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1244
    Height = 58
    Align = alTop
    Caption = 'Extrato Banc'#225'rio'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object Button2: TButton
      Left = 1154
      Top = 1
      Width = 89
      Height = 56
      Align = alRight
      Caption = 'POST'
      TabOrder = 0
      Visible = False
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 58
    Width = 1244
    Height = 753
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Extrato'
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 616
        Height = 154
        TabOrder = 0
      end
      object Button1: TButton
        Left = 0
        Top = 672
        Width = 1236
        Height = 51
        Align = alBottom
        Caption = 'Gerar Extrato'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Memo2: TMemo
        Left = 0
        Top = 152
        Width = 616
        Height = 148
        TabOrder = 2
      end
      object Memo3: TMemo
        Left = 0
        Top = 300
        Width = 616
        Height = 138
        TabOrder = 3
      end
      object Memo4: TMemo
        Left = 0
        Top = 435
        Width = 616
        Height = 130
        TabOrder = 4
      end
      object Memo5: TMemo
        Left = 618
        Top = 0
        Width = 616
        Height = 154
        TabOrder = 5
      end
      object Memo6: TMemo
        Left = 618
        Top = 152
        Width = 616
        Height = 148
        TabOrder = 6
      end
      object Memo7: TMemo
        Left = 618
        Top = 300
        Width = 616
        Height = 138
        TabOrder = 7
      end
      object Memo8: TMemo
        Left = 618
        Top = 435
        Width = 616
        Height = 130
        TabOrder = 8
      end
      object Memo9: TMemo
        Left = 0
        Top = 574
        Width = 1236
        Height = 98
        Align = alBottom
        TabOrder = 9
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Configura'#231#245'es'
      ImageIndex = 1
      object Label1: TLabel
        Left = 6
        Top = 8
        Width = 65
        Height = 15
        Caption = 'Raz'#227'o Social'
      end
      object Label2: TLabel
        Left = 6
        Top = 50
        Width = 27
        Height = 15
        Caption = 'CNPJ'
      end
      object Label3: TLabel
        Left = 6
        Top = 92
        Width = 148
        Height = 15
        Caption = 'Chave do Certificado Digital'
      end
      object edtRazaoSocial: TEdit
        Left = 3
        Top = 25
        Width = 610
        Height = 23
        TabOrder = 0
      end
      object edtCNPJ: TEdit
        Left = 3
        Top = 67
        Width = 174
        Height = 23
        TabOrder = 1
      end
      object edtChaveCertificado: TEdit
        Left = 3
        Top = 109
        Width = 610
        Height = 23
        TabOrder = 2
      end
      object Panel2: TPanel
        Left = 0
        Top = 665
        Width = 1236
        Height = 58
        Align = alBottom
        TabOrder = 3
        object Button3: TButton
          Left = 209
          Top = 0
          Width = 184
          Height = 52
          Caption = 'Salvar Configura'#231#245'es'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = Button3Click
        end
      end
      object PageControl2: TPageControl
        Left = 0
        Top = 412
        Width = 1236
        Height = 253
        ActivePage = TabSheet3
        Align = alBottom
        TabOrder = 4
        object TabSheet3: TTabSheet
          Caption = 'Bradesco'
          object Label4: TLabel
            Left = 3
            Top = 21
            Width = 43
            Height = 15
            Caption = 'Ag'#234'ncia'
          end
          object Label5: TLabel
            Left = 79
            Top = 18
            Width = 81
            Height = 15
            Caption = 'Conta Corrente'
          end
          object Label6: TLabel
            Left = 3
            Top = 61
            Width = 53
            Height = 15
            Caption = 'Client Key'
          end
          object Label7: TLabel
            Left = 3
            Top = 107
            Width = 66
            Height = 15
            Caption = 'Client Secret'
          end
          object Label12: TLabel
            Left = 0
            Top = 0
            Width = 1228
            Height = 15
            Align = alTop
            Alignment = taCenter
            Caption = 'BRADESCO'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            ExplicitWidth = 62
          end
          object Label15: TLabel
            Left = 3
            Top = 154
            Width = 217
            Height = 15
            Caption = 'Caminho dos arquivos de trabalho (APIS)'
          end
          object edtAgenciaBradesco: TEdit
            Left = 2
            Top = 35
            Width = 69
            Height = 23
            TabOrder = 0
          end
          object edtContaBradesco: TEdit
            Left = 71
            Top = 35
            Width = 125
            Height = 23
            TabOrder = 1
          end
          object edtClienteKeyBradesco: TEdit
            Left = 2
            Top = 78
            Width = 599
            Height = 23
            TabOrder = 2
          end
          object edtClienteSecretBradesco: TEdit
            Left = 2
            Top = 124
            Width = 599
            Height = 23
            TabOrder = 3
          end
          object edtPastaDeTrabalhoBradesco: TEdit
            Left = 2
            Top = 173
            Width = 599
            Height = 23
            TabOrder = 4
          end
        end
        object TabSheet4: TTabSheet
          Caption = 'Ita'#250
          ImageIndex = 1
          object Label8: TLabel
            Left = 10
            Top = 18
            Width = 43
            Height = 15
            Caption = 'Ag'#234'ncia'
          end
          object Label9: TLabel
            Left = 79
            Top = 18
            Width = 81
            Height = 15
            Caption = 'Conta Corrente'
          end
          object Label10: TLabel
            Left = 10
            Top = 61
            Width = 53
            Height = 15
            Caption = 'Client Key'
          end
          object Label11: TLabel
            Left = 10
            Top = 107
            Width = 66
            Height = 15
            Caption = 'Client Secret'
          end
          object Label13: TLabel
            Left = 0
            Top = 0
            Width = 1228
            Height = 15
            Align = alTop
            Alignment = taCenter
            Caption = 'ITA'#218
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            ExplicitWidth = 27
          end
          object Edit6: TEdit
            Left = 7
            Top = 35
            Width = 69
            Height = 23
            TabOrder = 0
          end
          object Edit7: TEdit
            Left = 76
            Top = 35
            Width = 125
            Height = 23
            TabOrder = 1
          end
          object Edit8: TEdit
            Left = 7
            Top = 78
            Width = 607
            Height = 23
            TabOrder = 2
          end
          object Edit9: TEdit
            Left = 7
            Top = 124
            Width = 607
            Height = 23
            TabOrder = 3
          end
        end
        object TabSheet5: TTabSheet
          Caption = 'Etc...'
          ImageIndex = 2
          object Label14: TLabel
            Left = 0
            Top = 0
            Width = 1228
            Height = 15
            Align = alTop
            Alignment = taCenter
            Caption = 'ETC...'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            ExplicitWidth = 29
          end
        end
      end
    end
  end
end
