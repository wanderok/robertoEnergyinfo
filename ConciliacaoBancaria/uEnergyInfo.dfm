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
    Left = 240
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Button1'
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
end
