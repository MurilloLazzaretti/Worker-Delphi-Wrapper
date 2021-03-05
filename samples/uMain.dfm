object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Worker Wrapper Delphi'
  ClientHeight = 293
  ClientWidth = 293
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 97
    Width = 44
    Height = 13
    Caption = 'Process :'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 113
    Height = 25
    Caption = 'Process ID :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 192
    Top = 70
    Width = 73
    Height = 13
    Caption = 'Sleep Process :'
  end
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 116
    Width = 287
    Height = 174
    Align = alBottom
    Lines.Strings = (
      '')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 192
    Top = 8
    Width = 93
    Height = 25
    Caption = 'Simulate Crash'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 192
    Top = 89
    Width = 93
    Height = 21
    TabOrder = 2
    Text = '5000'
  end
end
