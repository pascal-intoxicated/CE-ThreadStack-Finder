object InterfaceUI: TInterfaceUI
  Left = 0
  Top = 0
  Caption = 'InterfaceUI'
  ClientHeight = 176
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object ListView1: TListView
    Left = 8
    Top = 8
    Width = 417
    Height = 129
    Columns = <
      item
        Caption = 'Index'
      end
      item
        AutoSize = True
        Caption = 'ThreadStack Base'
      end>
    TabOrder = 0
    ViewStyle = vsReport
  end
  object Button1: TButton
    Left = 288
    Top = 143
    Width = 137
    Height = 25
    Caption = 'Get ThreadStack Btn'
    TabOrder = 1
    OnClick = Button1Click
  end
end
