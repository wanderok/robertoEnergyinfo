object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'frmPrincipal'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 15
  object Button2: TButton
    Left = 136
    Top = 16
    Width = 89
    Height = 50
    Caption = 'POST'
    TabOrder = 0
  end
  object Button1: TButton
    Left = 32
    Top = 16
    Width = 89
    Height = 50
    Caption = 'GET'
    TabOrder = 1
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
    TabOrder = 2
  end
end
