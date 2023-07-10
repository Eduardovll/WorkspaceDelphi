inherited FrmSmBelaVistaGsMarket: TFrmSmBelaVistaGsMarket
  Left = 327
  Top = 187
  Caption = 'SM BELA VISTA'
  ClientHeight = 547
  ClientWidth = 845
  ExplicitWidth = 857
  ExplicitHeight = 585
  TextHeight = 13
  inherited LblVesao: TLabel
    Anchors = [akLeft, akBottom]
  end
  inherited ImgLogo: TImage
    Left = 631
    Height = 63
    Anchors = [akTop, akRight]
    ExplicitLeft = 635
    ExplicitHeight = 63
  end
  object lblLoja: TLabel [2]
    Left = 528
    Top = 27
    Width = 20
    Height = 13
    Caption = 'Loja'
  end
  inherited PctArquivos: TPageControl
    Top = 15
    ExplicitTop = 15
    ExplicitHeight = 322
    inherited AbaParceiros: TTabSheet
      ExplicitHeight = 295
      inherited CkbCondPagForn: TCheckBox
        Left = 3
        Top = 28
        ExplicitLeft = 3
        ExplicitTop = 28
      end
      inherited CkbDivisaoForn: TCheckBox
        Top = 56
        Enabled = False
        ExplicitTop = 56
      end
      inherited CkbTransportadora: TCheckBox
        Top = 131
        Enabled = False
        ExplicitTop = 131
      end
      inherited CkbStatusPdv: TCheckBox
        Top = 262
        Enabled = False
        Visible = False
        ExplicitTop = 262
      end
      inherited CkbCliente: TCheckBox
        Left = 3
        Top = 82
        ExplicitLeft = 3
        ExplicitTop = 82
      end
      inherited CkbCondPagCli: TCheckBox
        Top = 105
        ExplicitTop = 105
      end
      inherited CkbEnderecoCliente: TCheckBox
        Top = 239
        Enabled = False
        Visible = False
        ExplicitTop = 239
      end
    end
    inherited AbaProdutos: TTabSheet
      Caption = 'Produto'
      ExplicitHeight = 295
      object Label11: TLabel [0]
        Left = 123
        Top = 161
        Width = 28
        Height = 13
        Caption = '<<---'
      end
      inherited CkbProdSimilar: TCheckBox
        Left = 3
        ExplicitLeft = 3
      end
      inherited CkbProdLoja: TCheckBox
        OnClick = CkbProdLojaClick
      end
      inherited CkbProdForn: TCheckBox
        Left = 3
        ExplicitLeft = 3
      end
      inherited CkbComposicao: TCheckBox
        Enabled = False
      end
      inherited CkbSeGruSub: TCheckBox
        Left = 3
        Top = 1
        ExplicitLeft = 3
        ExplicitTop = 1
      end
      inherited CkbInfoNutricionais: TCheckBox
        Enabled = False
      end
      inherited CkbProdComprador: TCheckBox
        Top = 281
        Enabled = False
        ExplicitTop = 281
      end
      inherited CkbDecomposicao: TCheckBox
        Enabled = False
      end
      inherited CkbProdLocalizacao: TCheckBox
        Enabled = False
      end
      inherited CkbProdProducao: TCheckBox
        Top = 240
        Caption = 'Produ'#231#227'o'
        Enabled = False
        ExplicitTop = 240
      end
      inherited CkbCest: TCheckBox
        Left = 3
        Top = 120
        ExplicitLeft = 3
        ExplicitTop = 120
      end
      object btnGerarEstoqueAtual: TButton
        Left = 157
        Top = 188
        Width = 97
        Height = 25
        Caption = 'Gera Cli Autoriz'
        Enabled = False
        TabOrder = 15
        OnClick = btnGerarEstoqueAtualClick
      end
      object btnGeraCustoRep: TButton
        Left = 157
        Top = 157
        Width = 97
        Height = 25
        Caption = 'Gera custo rep.'
        Enabled = False
        TabOrder = 16
        OnClick = btnGeraCustoRepClick
      end
      object btnGeraValorVenda: TButton
        Left = 157
        Top = 126
        Width = 97
        Height = 25
        Caption = 'Gera val. venda'
        Enabled = False
        TabOrder = 17
        OnClick = btnGeraValorVendaClick
      end
    end
    inherited AbaFiscal: TTabSheet
      ExplicitHeight = 295
      inherited CkbOutrasNFs: TCheckBox
        Enabled = False
      end
      inherited CkbNFTransf: TCheckBox
        Enabled = False
      end
      inherited CkbNFClientes: TCheckBox
        Enabled = False
      end
      inherited CkbTributacao: TCheckBox
        Enabled = False
      end
      inherited CkbNf: TCheckBox
        Enabled = False
      end
    end
    inherited Financeiro: TTabSheet
      ExplicitHeight = 295
      inherited CkbFinanceiro: TCheckBox
        Enabled = False
      end
      inherited CkbFinanceiroPagar: TCheckBox
        Top = 52
        ExplicitTop = 52
      end
      inherited CkbFinanceiroReceberCartoes: TCheckBox
        Enabled = False
      end
      inherited CkbFinanceiroReceberBoleto: TCheckBox
        Enabled = False
      end
      inherited CkbFinanceiroReceberCheque: TCheckBox
        Enabled = False
      end
    end
    inherited AbaOutros: TTabSheet
      ExplicitHeight = 295
      inherited CkbMapaResumo: TCheckBox
        Enabled = False
      end
      inherited CkbAjuste: TCheckBox
        Enabled = False
      end
      inherited CkbPlContas: TCheckBox
        Enabled = False
      end
      object btnGeraCest: TButton
        Left = 3
        Top = 248
        Width = 98
        Height = 41
        Caption = 'Cest'
        Enabled = False
        TabOrder = 4
        OnClick = btnGeraCestClick
      end
      object BtnAmarrarCest: TButton
        Left = 136
        Top = 248
        Width = 89
        Height = 41
        Caption = 'Amarrar Cest'
        Enabled = False
        TabOrder = 5
        OnClick = BtnAmarrarCestClick
      end
    end
  end
  inherited GroupBox: TGroupBox
    Top = 77
    Width = 535
    Height = 266
    ExplicitTop = 77
    ExplicitWidth = 531
    ExplicitHeight = 265
    inherited GrpCamBanco: TGroupBox
      Width = 518
      ExplicitWidth = 514
      inherited EdtCamBanco: TEdit
        Width = 413
        ExplicitWidth = 409
      end
    end
    inherited GbxCamArquivo: TGroupBox
      Width = 518
      ExplicitWidth = 514
      inherited BtnAltCamArq: TSpeedButton
        Top = 22
        ExplicitTop = 22
      end
      inherited EdtCamArquivo: TEdit
        Width = 411
        ExplicitWidth = 407
      end
    end
    inherited GrpCamBancoSoliduss: TGroupBox
      Width = 518
      Visible = False
      ExplicitWidth = 514
      inherited EdtCamBancoSoliduss: TEdit
        Width = 413
        ExplicitWidth = 409
      end
    end
    inherited PCBancoDados: TPageControl
      Left = 3
      Width = 465
      Height = 81
      Visible = False
      ExplicitLeft = 1
      ExplicitTop = 176
      ExplicitWidth = 465
      ExplicitHeight = 81
      inherited TabOracle: TTabSheet
        Enabled = False
        ExplicitWidth = 457
        ExplicitHeight = 71
        inherited Label5: TLabel
          Left = 9
          Top = 47
          Width = 36
          Caption = 'Usuario'
          ExplicitLeft = 9
          ExplicitTop = 47
          ExplicitWidth = 36
        end
        inherited Label4: TLabel
          Left = 209
          Top = 47
          ExplicitLeft = 209
          ExplicitTop = 47
        end
        inherited Label1: TLabel
          Left = 199
          Width = 37
          Caption = 'Schema'
          ExplicitLeft = 199
          ExplicitWidth = 37
        end
        inherited Label6: TLabel
          Left = 36
          Width = 10
          Caption = 'IP'
          Visible = False
          ExplicitLeft = 36
          ExplicitWidth = 10
        end
        inherited edtSchema: TEdit
          Left = 48
          Top = 43
          ExplicitLeft = 48
          ExplicitTop = 43
        end
        inherited edtSenhaOracle: TEdit
          Left = 249
          Top = 45
          Width = 190
          PasswordChar = '*'
          ExplicitLeft = 249
          ExplicitTop = 45
          ExplicitWidth = 190
        end
        inherited edtInst: TEdit
          Left = 249
          Width = 189
          ExplicitLeft = 249
          ExplicitWidth = 189
        end
        inherited edtIpOra: TEdit
          Left = 48
          Top = 3
          Visible = False
          ExplicitLeft = 48
          ExplicitTop = 3
        end
      end
      inherited TabMySql: TTabSheet
        ExplicitWidth = 457
        ExplicitHeight = 71
      end
      inherited TabSqlServer: TTabSheet
        ExplicitWidth = 457
        ExplicitHeight = 71
      end
    end
  end
  inherited GbxData: TGroupBox
    Left = 280
    Top = 10
    ExplicitLeft = 278
    ExplicitTop = 10
  end
  inherited BtnGerar: TBitBtn
    Left = 459
    Top = 349
    ExplicitLeft = 459
    ExplicitTop = 349
  end
  inherited BitSair: TBitBtn
    Top = 349
    ExplicitTop = 349
  end
  inherited ckbGrade: TCheckBox
    Top = 356
    Alignment = taLeftJustify
    ExplicitTop = 356
  end
  inherited CkbFormatado: TCheckBox
    Top = 356
    Alignment = taLeftJustify
    ExplicitTop = 356
  end
  object CbxLoja: TComboBox [11]
    Left = 554
    Top = 24
    Width = 39
    Height = 21
    TabOrder = 8
    Text = '1'
    Items.Strings = (
      '1'
      '2'
      'MARGEM-L1'
      'MARGEM-L2')
  end
  object Memo1: TMemo [12]
    Left = 9
    Top = 409
    Width = 826
    Height = 136
    Anchors = [akBottom]
    Lines.Strings = (
      '')
    TabOrder = 9
    ExplicitLeft = 7
    ExplicitTop = 408
  end
  inherited MainMenu1: TMainMenu
    Left = 770
    Top = 270
  end
end
