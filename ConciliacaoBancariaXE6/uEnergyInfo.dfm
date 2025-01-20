object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'frmEnergyInfo'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Visible = True
  PixelsPerInch = 96
  TextHeight = 15
  object Button1: TButton
    Left = 32
    Top = 16
    Width = 89
    Height = 50
    Caption = 'GET'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 72
    Width = 624
    Height = 369
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Button2: TButton
    Left = 136
    Top = 16
    Width = 89
    Height = 50
    Caption = 'POST'
    TabOrder = 2
    OnClick = Button2Click
  end
end
