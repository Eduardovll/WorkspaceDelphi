inherited FrmSmNossoPao: TFrmSmNossoPao
  Caption = 'SM NOSSO PAO UNIFICA'#199#195'O'
  ClientHeight = 570
  ExplicitHeight = 609
  TextHeight = 13
  inherited ImgLogo: TImage
    Left = 624
    Height = 63
    Anchors = [akTop, akRight]
    ExplicitLeft = 624
    ExplicitHeight = 63
  end
  object lblLoja: TLabel [2]
    Left = 296
    Top = 11
    Width = 20
    Height = 13
    Caption = 'Loja'
  end
  inherited PctArquivos: TPageControl
    Top = 15
    ActivePage = AbaProdutos
    ExplicitTop = 15
    inherited AbaParceiros: TTabSheet
      inherited CkbCondPagForn: TCheckBox
        Top = 28
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
        Top = 82
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
      object Label11: TLabel [0]
        Left = 119
        Top = 161
        Width = 28
        Height = 13
        Caption = '<<---'
      end
      inherited CkbProdLoja: TCheckBox
        OnClick = CkbProdLojaClick
      end
      inherited CkbComposicao: TCheckBox
        Enabled = False
      end
      inherited CkbReceitas: TCheckBox
        Enabled = False
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
      object btnGeraCustoRep: TButton
        Left = 153
        Top = 151
        Width = 92
        Height = 25
        Caption = 'Gera custo rep.'
        Enabled = False
        TabOrder = 15
        OnClick = btnGeraCustoRepClick
      end
      object btnGerarEstoqueAtual: TButton
        Left = 159
        Top = 182
        Width = 92
        Height = 25
        Caption = 'Gera estoque '
        Enabled = False
        TabOrder = 16
        OnClick = btnGerarEstoqueAtualClick
      end
      object btnGeraPromocao: TButton
        Left = 159
        Top = 213
        Width = 92
        Height = 25
        Caption = 'Gera Promo'#231#227'o'
        Enabled = False
        TabOrder = 17
        OnClick = btnGeraPromocaoClick
      end
      object btnGeraUpdateInativo: TButton
        Left = 153
        Top = 242
        Width = 92
        Height = 25
        Caption = 'Gera Upd. Inativo'
        Enabled = False
        TabOrder = 18
        OnClick = btnGeraUpdateInativoClick
      end
    end
    inherited AbaFiscal: TTabSheet
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
      inherited CkbFinanceiro: TCheckBox
        Enabled = False
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
      inherited CkbMapaResumo: TCheckBox
        Enabled = False
      end
      inherited CkbAjuste: TCheckBox
        Left = 3
        Top = 21
        Enabled = False
        ExplicitLeft = 3
        ExplicitTop = 21
      end
      inherited CkbPlContas: TCheckBox
        Enabled = False
      end
    end
  end
  inherited GroupBox: TGroupBox
    inherited GrpCamBanco: TGroupBox
      Visible = False
      inherited EdtCamBanco: TEdit
        Visible = False
      end
    end
    inherited GrpCamBancoSoliduss: TGroupBox
      Visible = False
    end
    inherited PCBancoDados: TPageControl
      Left = 8
      Top = 176
      Width = 465
      Height = 81
      ExplicitLeft = 8
      ExplicitTop = 176
      ExplicitWidth = 465
      ExplicitHeight = 81
      inherited TabOracle: TTabSheet
        ExplicitWidth = 457
        ExplicitHeight = 71
        inherited Label5: TLabel
          Left = 1
          Top = 15
          Width = 44
          Caption = 'Instancia'
          ExplicitLeft = 1
          ExplicitTop = 15
          ExplicitWidth = 44
        end
        inherited Label4: TLabel
          Left = 217
          Top = 47
          ExplicitLeft = 217
          ExplicitTop = 47
        end
        inherited Label1: TLabel
          Left = 4
          Top = 48
          Width = 36
          Caption = 'Usuario'
          ExplicitLeft = 4
          ExplicitTop = 48
          ExplicitWidth = 36
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
          Top = 11
          Width = 377
          ExplicitTop = 11
          ExplicitWidth = 377
        end
        inherited edtSenhaOracle: TEdit
          Left = 255
          Top = 43
          Width = 176
          PasswordChar = '*'
          ExplicitLeft = 255
          ExplicitTop = 43
          ExplicitWidth = 176
        end
        inherited edtInst: TEdit
          Left = 54
          Top = 43
          Width = 139
          ExplicitLeft = 54
          ExplicitTop = 43
          ExplicitWidth = 139
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
    Left = 288
    Top = 34
    ExplicitLeft = 288
    ExplicitTop = 34
  end
  object CbxLoja: TComboBox [11]
    Left = 322
    Top = 8
    Width = 65
    Height = 21
    TabOrder = 8
    Text = '1'
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6')
  end
  object btnGeraValorVenda: TButton [12]
    Left = 165
    Top = 159
    Width = 92
    Height = 25
    Caption = 'Gera val. venda'
    Enabled = False
    TabOrder = 9
    OnClick = btnGeraValorVendaClick
  end
  object Memo1: TMemo [13]
    Left = 8
    Top = 409
    Width = 824
    Height = 160
    Lines.Strings = (
      'Memo1')
    TabOrder = 10
  end
  inherited MainMenu1: TMainMenu
    Top = 56
  end
  object ADOMySQL: TADOConnection
    ConnectionString = 
      'Provider=MSDASQL.1;Password=aaa123456@;Persist Security Info=Tru' +
      'e;User ID=postgres;Data Source=CONVERSAO_SmNossoPao;Initial Cata' +
      'log=SmVIA2'
    LoginPrompt = False
    Provider = 'MSDASQL.1'
    Left = 576
    Top = 8
  end
  object QryPrincipal2: TADOQuery
    Connection = ADOMySQL
    Parameters = <>
    Left = 464
    Top = 8
  end
  object QryAux: TADOQuery
    Connection = ADOMySQL
    Parameters = <>
    Left = 592
    Top = 80
  end
end
