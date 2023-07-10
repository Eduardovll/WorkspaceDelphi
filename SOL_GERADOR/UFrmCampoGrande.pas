unit UFrmCampoGrande;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrmModelo, Data.DBXOracle, Data.DB,
  Data.SqlExpr, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DBXFirebird, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.Provider, Datasnap.DBClient, //dxGDIPlusClasses,
  Math;

type
  TFrmCampoGrande = class(TFrmModeloSis)
    btnGeraCest: TButton;
    BtnAmarrarCest: TButton;
    CbxLoja: TComboBox;
    lblLoja: TLabel;
    btnGerarEstoqueAtual: TButton;
    btnGeraCustoRep: TButton;
    btnGeraValorVenda: TButton;
    Label11: TLabel;
    procedure btnGeraCestClick(Sender: TObject);
    procedure BtnAmarrarCestClick(Sender: TObject);
    procedure EdtCamBancoExit(Sender: TObject);
    procedure btnGeraValorVendaClick(Sender: TObject);
    procedure btnGeraCustoRepClick(Sender: TObject);
    procedure btnGerarEstoqueAtualClick(Sender: TObject);
    procedure CkbProdLojaClick(Sender: TObject);
    procedure BtnGerarClick(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
    procedure GerarCliente;           Override;
    procedure GerarFornecedor;        Override;
    procedure GerarCondPagForn;       Override;
    procedure GerarDivisaoForn;      Override;
    procedure GerarCondPagCli;       Override;
    procedure GerarTransportadora;      Override;
    procedure GerarCest; Override;

    procedure GerarSecao;           Override;
    procedure GerarGrupo;           Override;
    procedure GerarSubGrupo;        Override;

    procedure GerarProduto;           Override;
    procedure GerarCodigoBarras;      Override;
    procedure GerarProdLoja;          Override;
    procedure GerarNCM;               Override;
    procedure GerarNCMUF;                                 Override;
    procedure GerarProdSimilar;                           Override;
    procedure GerarProdForn;                              Override;
    procedure GerarInfoNutricionais;                      Override;
    procedure GerarDecomposicao;                          Override;
    procedure GerarComposicao;                            Override;
    procedure GerarProducao;                              Override;

    procedure GerarNFFornec;                              Override;
    procedure GerarNFitensFornec;                         Override;
    procedure GerarNFClientes;                            Override;
    procedure GerarNFitensClientes;                       Override;
    procedure GerarVenda;                                 Override;

    procedure GerarFinanceiro( Tipo, Situacao :Integer ); Override;
    procedure GerarFinanceiroReceber(Aberto:String);      Override;
    procedure GerarFinanceiroReceberCartao;               Override;
    procedure GerarFinanceiroPagar(Aberto:String);        Override;

    procedure GerarScriptCEST;
    procedure GerarScriptAmarrarCEST;

    procedure GerarValorVenda;
    procedure GeraCustoRep;
    procedure GeraEstoqueVenda;

  end;

var
  FrmCampoGrande: TFrmCampoGrande;
  ListNCM    : TStringList;
  TotalCont  : Integer;
  NumLinha : Integer;
  Arquivo: TextFile;
  FlgGeraDados : Boolean = false;
  FlgGeraCest : Boolean = false;
  FlgGeraAmarrarCest : Boolean = false;

  FlgAtualizaValVenda : Boolean = False;
  FlgAtualizaCustoRep : Boolean = False;
  FlgAtualizaEstoque  : Boolean = False;

implementation

{$R *.dfm}

uses xProc, UUtilidades, UProgresso;


procedure TFrmCampoGrande.GerarProducao;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    PRODUTOS_COMPOSICAO.PRODUTO_BASE AS COD_PRODUTO,');
    SQL.Add('    PRODUTOS_COMPOSICAO.PRODUTO AS COD_PRODUTO_PRODUCAO,');
    SQL.Add('    COMPOSICAO.FATOR_PRODUCAO AS QTD_PRODUCAO,');
    SQL.Add('    PRODUTOS.UNIDADE_VENDA AS DES_UNIDADE,');
    SQL.Add('    PRODUTOS_COMPOSICAO.QTDE AS QTD_RECEITA,');
    SQL.Add('    COMPOSICAO.RENDIMENTO AS QTD_RENDIMENTO');
    SQL.Add('FROM');
    SQL.Add('    PRODUTOS');
    SQL.Add('LEFT JOIN');
    SQL.Add('    PRODUTOS_COMPOSICAO');
    SQL.Add('ON');
    SQL.Add('    PRODUTOS.ID = PRODUTOS_COMPOSICAO.PRODUTO_BASE ');
    SQL.Add('LEFT JOIN');
    SQL.Add('     COMPOSICAO');
    SQL.Add('ON');
    SQL.Add('     PRODUTOS_COMPOSICAO.PRODUTO_BASE = COMPOSICAO.PRODUTO_BASE');
    SQL.Add('WHERE');
    SQL.Add('    PRODUTOS.COMPOSTO = 2');
    SQL.Add('AND');
    SQL.Add('    PRODUTOS_COMPOSICAO.PRODUTO_BASE IS NOT NULL');


    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarProduto;
var
   cod_produto, codbarras, TIPO : string;
   TotalCount, count, COD_PROD, CODIGO, NEW_CODPROD : Integer;
   QryGeraCodigoProduto : TSQLQuery;

begin
  inherited;

//  QryGeraCodigoProduto := TSQLQuery.Create(FrmProgresso);
//  with QryGeraCodigoProduto do
//  begin
//    SQLConnection := ScnBanco;
//
//    SQL.Clear;
//    SQL.Add('ALTER TABLE MATERI ');
//    SQL.Add('ADD CODIGO_PRODUTO INT DEFAULT NULL; ');
//
//    try
//      ExecSQL;
//    except
//    end;
//
//    SQL.Clear;
//    SQL.Add('UPDATE MATERI ');
//    SQL.Add('SET CODIGO_PRODUTO = :COD_PRODUTO  ');
//    SQL.Add('WHERE COD_MATERIAL = :COD_BARRA_PRINCIPAL ');
//    SQL.Add('AND CHAR_LENGTH(COD_MATERIAL) >= 8 ');
//
//    try
//      ExecSQL;
//    except
//    end;
////
//  end;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTOS.COD_MATERIAL) >= 8 THEN PRODUTOS.CODIGO_PRODUTO   ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''UN'' THEN PRODUTOS.COD_MATERIAL   ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''KG'' THEN PRODUTOS.COD_MATERIAL   ');
     SQL.Add('           ELSE PRODUTOS.COD_MATERIAL   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       PRODUTOS.COD_MATERIAL AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       TRIM(COALESCE(PRODUTOS.DESC_REG, PRODUTOS.DESC_MATERI)) AS DES_REDUZIDA,   ');
     SQL.Add('       TRIM(PRODUTOS.DESC_MATERI) AS DES_PRODUTO,   ');
     SQL.Add('       PRODUTOS.ITEM_CAIXA AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.COD_UNI = ''KG'' THEN ''KG''   ');
     SQL.Add('           WHEN PRODUTOS.UN_BRUTA = '''' THEN ''UN''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.UN_BRUTA, ''UN'')    ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('          ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       COALESCE(PRODUTOS.COD_UNI, ''UN'') AS DES_UNIDADE_VENDA,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       0 AS VAL_IPI,   ');
     SQL.Add('       SUBSTRING(PRODUTOS.SETOR FROM 1 FOR 2) AS COD_SECAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN SUBSTRING(PRODUTOS.SETOR FROM 4 FOR 2) = '''' THEN 999   ');
     SQL.Add('           ELSE SUBSTRING(PRODUTOS.SETOR FROM 4 FOR 2)   ');
     SQL.Add('       END AS COD_GRUPO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN SUBSTRING(PRODUTOS.SETOR FROM 7 FOR 2) = '''' THEN 999   ');
     SQL.Add('           ELSE SUBSTRING(PRODUTOS.SETOR FROM 7 FOR 2)   ');
     SQL.Add('       END AS COD_SUB_GRUPO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(SIMILAR1.COD_ART, 0) AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.COD_UNI = ''KG'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('      ');
     SQL.Add('       PRODUTOS.VALIDADE AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 1 AND PIS_COFINS.CST_ENT = 50 AND PIS_COFINS.CST_SAI = 1 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 0 THEN ''N''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 2 AND PIS_COFINS.CST_ENT = 60 AND PIS_COFINS.CST_SAI = 1 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 101 THEN ''N''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 1 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 2 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 202 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 105 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 108 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 110 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 111 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 113 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 115 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 116 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 117 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 119 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 120 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 121 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 122 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 123 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 124 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 125 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 126 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 127 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 128 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 129 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 130 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 914 THEN ''S''    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 918 THEN ''S''     ');
     SQL.Add('                   ELSE ''N''    ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('      ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 1 AND PIS_COFINS.CST_ENT = 50 AND PIS_COFINS.CST_SAI = 1 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 0 THEN -1    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 2 AND PIS_COFINS.CST_ENT = 60 AND PIS_COFINS.CST_SAI = 1 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 101 THEN -1    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 1 THEN 1    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 2 THEN 1    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 202 THEN 1    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 105 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 108 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 110 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 111 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 113 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 115 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 116 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 117 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 119 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 120 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 121 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 122 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 123 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 124 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 125 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 126 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 127 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 128 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 129 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 130 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 914 THEN 0    ');
     SQL.Add('                   WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 918 THEN 0     ');
     SQL.Add('                   ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       0 AS COD_INFO_RECEITA,   ');
     SQL.Add('       COALESCE(PRODUTOS.PIS_COFINS_COD_CREDITO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO,   ');
     SQL.Add('       0 AS TIPO_ESPECIE,   ');
     SQL.Add('       0 AS COD_CLASSIF,   ');
     SQL.Add('       1 AS VAL_VDA_PESO_BRUTO,   ');
     SQL.Add('       1 AS VAL_PESO_EMB,   ');
     SQL.Add('       0 AS TIPO_EXPLOSAO_COMPRA,   ');
     SQL.Add('       '''' AS DTA_INI_OPER,   ');
     SQL.Add('       '''' AS DES_PLAQUETA,   ');
     SQL.Add('       '''' AS MES_ANO_INI_DEPREC,   ');
     SQL.Add('       0 AS TIPO_BEM,   ');
     SQL.Add('       COALESCE(PRODUTOS.COD_FORNECEDOR, 0) AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       COALESCE(PRODUTOS.DATA_ENTRADA, '''') AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       TRIM(COALESCE(PRODUTOS.DESC_REG, PRODUTOS.DESC_MATERI)) AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS PRODUTOS   ');
     SQL.Add('   LEFT JOIN PIS_COFINS ON PIS_COFINS.CODIGO = PRODUTOS.PIS_COFINS_CODIGO   ');
     SQL.Add('   LEFT JOIN MATERI_GRUPO AS SIMILAR1 ON SIMILAR1.COD_ART = PRODUTOS.GRUPO ');
     //SQL.Add('   WHERE PRODUTOS.COD_MATERIAL IN (''7890541642769'', ''7890541642776'', ''7890541642790'', ''7890541915191'')   ');






    Open;
    First;
    NumLinha := 0;
    NEW_CODPROD := 10000;
    //count := 100000;
    //COD_PROD := 99999;
    //CODIGO := 0;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(NEW_CODPROD);
      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);


//
//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        with QryGeraCodigoProduto do
//        begin
//          Inc(COD_PROD);
//          Params.ParamByName('COD_PRODUTO').Value := NEW_CODPROD;
//          Params.ParamByName('COD_BARRA_PRINCIPAL').Value := Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString;
//          Layout.FieldByName('COD_PRODUTO').AsInteger := Params.ParamByName('COD_PRODUTO').Value;
//          ExecSQL();
//        end;
//      end;

        //if Length(StrLBReplace(Trim(StrRetNums( FieldByName('COD_PRODUTO').AsString) ))) < 8 then


//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
//      end;

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );



      //Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      //Layout.FieldByName('DES_REDUZIDA').AsString := StrReplace(StrLBReplace(FieldByName('DES_REDUZIDA').AsString), '\n', '');
      //Layout.FieldByName('DES_PRODUTO').AsString := StrReplace(StrLBReplace(FieldByName('DES_PRODUTO').AsString), '\n', '');

      if Length(StrLBReplace(Trim(StrRetNums( FieldByName('COD_BARRA_PRINCIPAL').AsString) ))) < 8 then
       Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := GerarPLU(FieldByName('COD_BARRA_PRINCIPAL').AsString);

      if not CodBarrasValido(Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString) then
       Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := '';

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;

    Close
  end;
end;

procedure TFrmCampoGrande.GerarScriptAmarrarCEST;
begin
  with QryPrincipal do
  begin
    Close;
    Sql.Clear;

    SQL.Add('SELECT');
    SQL.Add('	NOME,');
    SQL.Add('	CEST');
    SQL.Add('FROM');
    SQL.Add('	CLASSIFICACAO');
    SQL.Add('WHERE');
    SQL.Add('  CEST IS NOT NULL');


    Open;
    First;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Writeln(Arquivo,'UPDATE TAB_NCM SET COD_CEST =  (SELECT COD_CEST FROM TAB_CEST WHERE NUM_CEST = '+QryPrincipal.FieldByName('CEST').AsString+' ) WHERE NUM_NCM = '+QryPrincipal.FieldByName('NOME').AsString+' ;');

      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
      end;

    Next;
    end;
    WriteLn(Arquivo, 'COMMIT WORK;');
    Close;
  end;
end;

procedure TFrmCampoGrande.GerarScriptCEST;
var
  codigo : integer;
begin

  with QryPrincipal do
  begin
    Close;
    Sql.Clear;

    SQL.Add('SELECT');
    SQL.Add('	0 AS COD_CEST,');
    SQL.Add('	CEST.CODIGO AS NUM_CEST,');
    SQL.Add('	CAST(CEST.DESCRICAO AS VARCHAR2(50)) AS DES_CEST');
    SQL.Add('FROM');
    SQL.Add('	CEST');
    SQL.Add('ORDER BY');
    SQL.Add('  NUM_CEST ASC');

    codigo := 1000;

    Open;
    First;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        inc(codigo);
        Writeln(Arquivo,'INSERT INTO TAB_CEST(COD_CEST, NUM_CEST, DES_CEST) VALUES ( '+ IntToStr(codigo) +', '+QryPrincipal.FieldByName('NUM_CEST').AsString+', '''+QryPrincipal.FieldByName('DES_CEST').AsString+''' ) ;');

      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
      end;

    Next;
    end;
    WriteLn(Arquivo, 'COMMIT WORK;');
    Close;
  end;

end;

procedure TFrmCampoGrande.GerarSecao;
var
   TotalCount : integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       SUBSTRING(PRODUTOS.SETOR FROM 1 FOR 2) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(SECAO.DES_ART, ''A DEFINIR'') AS DES_SECAO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS PRODUTOS   ');
     SQL.Add('   LEFT JOIN ARTIGO AS SECAO ON SECAO.COD_ART = SUBSTRING(PRODUTOS.SETOR FROM 1 FOR 2)   ');
     //SQL.Add('   --WHERE COD_MATERIAL = 7975   ');





    Open;

    First;
    NumLinha := 0;
    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarSubGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       SUBSTRING(PRODUTOS.SETOR FROM 1 FOR 2) AS COD_SECAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN SUBSTRING(PRODUTOS.SETOR FROM 4 FOR 2) = '''' THEN 999   ');
     SQL.Add('           ELSE SUBSTRING(PRODUTOS.SETOR FROM 4 FOR 2)   ');
     SQL.Add('       END AS COD_GRUPO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN SUBSTRING(PRODUTOS.SETOR FROM 7 FOR 2) = '''' THEN 999   ');
     SQL.Add('           ELSE SUBSTRING(PRODUTOS.SETOR FROM 7 FOR 2)   ');
     SQL.Add('       END COD_SUB_GRUPO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(SUBG.DES_ART, ''A DEFINIR'') AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 VAL_META,   ');
     SQL.Add('       0 AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS PRODUTOS   ');
     SQL.Add('   LEFT JOIN GRUPO AS SUBG ON SUBG.COD_ART = SUBSTRING(PRODUTOS.SETOR FROM 1 FOR 8)   ');
     //SQL.Add('   --WHERE COD_MATERIAL = 7975   ');




    Open;

    First;
    NumLinha := 0;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarTransportadora;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    TRANSPORTADORAS.ID AS COD_TRANSPORTADORA,');
    SQL.Add('    TRANSPORTADORAS.DESCRITIVO AS DES_TRANSPORTADORA,');
    SQL.Add('    TRANSPORTADORAS.CNPJ_CPF AS NUM_CGC,');
    SQL.Add('    TRANSPORTADORAS.INSCRICAO_RG AS NUM_INSC_EST,');
    SQL.Add('    TRANSPORTADORAS.LOGRADOURO || TRANSPORTADORAS.ENDERECO AS DES_ENDERECO,');
    SQL.Add('    TRANSPORTADORAS.BAIRRO AS DES_BAIRRO,');
    SQL.Add('    TRANSPORTADORAS.CIDADE AS DES_CIDADE,');
    SQL.Add('    TRANSPORTADORAS.ESTADO AS DES_SIGLA,');
    SQL.Add('    TRANSPORTADORAS.CEP AS NUM_CEP,');
    SQL.Add('    TRANSPORTADORAS.TELEFONE1 AS NUM_FONE,');
    SQL.Add('    TRANSPORTADORAS.FAX AS NUM_FAX,');
    SQL.Add('    '''' AS DES_CONTATO,');
    SQL.Add('    2 AS COD_CONDICAO,');
    SQL.Add('    30 AS NUM_CONDICAO,');
    SQL.Add('    TRANSPORTADORAS.NUMERO AS NUM_ENDERECO,');
    SQL.Add('    TRANSPORTADORAS.OBSERVACAO AS DES_OBSERVACAO,');
    SQL.Add('    8 AS COD_ENTIDADE, --');
    SQL.Add('    TRANSPORTADORAS.EMAIL AS DES_EMAIL,');
    SQL.Add('    TRANSPORTADORAS.SITE AS DES_WEB_SITE');
    SQL.Add('FROM');
    SQL.Add('    TRANSPORTADORAS');
    SQL.Add('ORDER BY');
    SQL.Add('    TRANSPORTADORAS.ID DESC');


    Open;

    First;

    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      Layout.FieldByName('DES_EMAIL').AsString := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarValorVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('   SELECT   ');
    SQL.Add('       CASE   ');
    SQL.Add('           WHEN CHAR_LENGTH(PRODUTOS.COD_MATERIAL) >= 8 THEN PRODUTOS.CODIGO_PRODUTO   ');
    SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''UN'' THEN PRODUTOS.COD_MATERIAL   ');
    SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''KG'' THEN PRODUTOS.COD_MATERIAL   ');
    SQL.Add('           ELSE PRODUTOS.COD_MATERIAL   ');
    SQL.Add('       END AS COD_PRODUTO,   ');
    SQL.Add('       PRODUTOS.PRECO_VENDA AS VAL_VENDA   ');
    SQL.Add('   FROM   ');
    SQL.Add('       MATERI AS PRODUTOS    ');
    SQL.Add('   WHERE PRODUTOS.EST_ATU > 0  ');
    SQL.Add('   AND PRODUTOS.COD_MATERIAL = ''7896005401279''  ');


    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Inc(NumLinha);

        COD_PRODUTO := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_VENDA = '''+QryPrincipal.FieldByName('VAL_VENDA').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');

        if NumLinha = 500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 1000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 1500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 2000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 2500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 3000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 3500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 4000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 4400 then
          Writeln(Arquivo, 'COMMIT WORK;');

      except on E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
      end;
      Next;
    end;
    Writeln(Arquivo, 'COMMIT WORK;');
    Close;
  end;
end;

procedure TFrmCampoGrande.GerarVenda;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTOS.COD_MATERIAL) >= 8 THEN PRODUTOS.CODIGO_PRODUTO      ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''UN'' THEN PRODUTOS.COD_MATERIAL      ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''KG'' THEN PRODUTOS.COD_MATERIAL      ');
     SQL.Add('           ELSE PRODUTOS.COD_MATERIAL      ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       1 AS COD_LOJA,   ');
     SQL.Add('       0 AS IND_TIPO,   ');
     SQL.Add('       1 AS NUM_PDV,   ');
     SQL.Add('       VENDAS.QUANT_NORMAL AS QTD_TOTAL_PRODUTO,   ');
     SQL.Add('       VENDAS.VENDA_NORMAL AS VAL_TOTAL_PRODUTO,   ');
     SQL.Add('       VENDAS.VENDA_NORMAL AS VAL_PRECO_VENDA,   ');
     SQL.Add('       PRODUTOS.PRECO_COMPRA AS VAL_CUSTO_REP,   ');
     SQL.Add('       VENDAS.DATA AS DTA_SAIDA,   ');
     SQL.Add('       REPLACE(SUBSTRING(DATA FROM 6 FOR 2), ''-'', '''') || REPLACE(SUBSTRING(DATA FROM 1 FOR 5), ''-'', '''') AS DTA_MENSAL,   ');
     SQL.Add('       1 AS NUM_IDENT,   ');
     SQL.Add('       PRODUTOS.COD_MATERIAL AS COD_EAN,   ');
     SQL.Add('       ''0000'' AS DES_HORA,   ');
     SQL.Add('       0 AS COD_CLIENTE,   ');
     SQL.Add('       1 AS COD_ENTIDADE,   ');
     SQL.Add('       0 AS VAL_BASE_ICMS,   ');
     SQL.Add('       '''' AS DES_SITUACAO_TRIB,   ');
     SQL.Add('       0 AS VAL_ICMS,   ');
     SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       VENDAS.VENDA_NORMAL AS VAL_VENDA_PDV,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 3        ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 3         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 3         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''41.67'' THEN 6         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''4'' AND ALIQUO.DES_ALI = ''13%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 41         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''2.00'' THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''010'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''55.00'' THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''61.11'' THEN 8         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''070'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND PRODUTOS.CST = ''040'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 1         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND PRODUTOS.CST = ''040'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 1         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND PRODUTOS.CST = ''060'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND PRODUTOS.CST = ''060'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''15'' AND ALIQUO.DES_ALI = ''14%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 39         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 40      ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0'' THEN 40      ');
     SQL.Add('           ELSE 1        ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       ''N'' AS FLG_CUPOM_CANCELADO,   ');
     SQL.Add('       PRODUTOS.NCM AS NUM_NCM,   ');
     SQL.Add('       COALESCE(PRODUTOS.PIS_COFINS_COD_CREDITO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 1 AND PIS_COFINS.CST_ENT = 50 AND PIS_COFINS.CST_SAI = 1 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 0 THEN ''N''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 2 AND PIS_COFINS.CST_ENT = 60 AND PIS_COFINS.CST_SAI = 1 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 101 THEN ''N''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 1 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 2 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 202 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 105 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 108 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 110 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 111 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 113 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 115 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 116 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 117 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 119 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 120 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 121 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 122 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 123 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 124 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 125 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 126 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 127 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 128 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 129 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 130 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 914 THEN ''S''       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 918 THEN ''S''        ');
     SQL.Add('           ELSE ''N''       ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 1 AND PIS_COFINS.CST_ENT = 50 AND PIS_COFINS.CST_SAI = 1 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 0 THEN -1       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 2 AND PIS_COFINS.CST_ENT = 60 AND PIS_COFINS.CST_SAI = 1 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 101 THEN -1       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 1 THEN 1       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 2 THEN 1       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 202 THEN 1       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 105 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 108 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 110 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 111 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 113 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 115 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 116 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 117 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 119 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 120 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 121 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 122 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 123 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 124 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 125 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 126 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 127 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 128 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 129 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 130 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 914 THEN 0       ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND PRODUTOS.PIS_COFINS_COD_CREDITO = 918 THEN 0        ');
     SQL.Add('           ELSE -1      ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       ''N'' AS FLG_ONLINE,   ');
     SQL.Add('       ''N'' AS FLG_OFERTA,   ');
     SQL.Add('       0 AS COD_ASSOCIADO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       VENDA_MERCADORIA AS VENDAS   ');
     SQL.Add('   LEFT JOIN MATERI AS PRODUTOS ON PRODUTOS.COD_MATERIAL = VENDAS.CODIGO_PRODUTO   ');
     SQL.Add('   LEFT JOIN ALIQUO ON ALIQUO.COD_ALI = PRODUTOS.COD_ALI   ');
     SQL.Add('   LEFT JOIN PIS_COFINS ON PIS_COFINS.CODIGO = PRODUTOS.PIS_COFINS_CODIGO   ');
     SQL.Add('   WHERE PRODUTOS.COD_MATERIAL IS NOT NULL    ');
     SQL.Add('   AND VENDAS.DATA >= :INI');
     SQL.Add('   AND VENDAS.DATA <= :FIM');


    ParamByName('INI').AsDate := DtpInicial.Date;
    ParamByName('FIM').AsDate := DtpFinal.Date;


    Open;

    First;

    TotalCount := SetCountTotal(SQL.Text, ParamByName('INI').AsString, ParamByName('FIM').AsString );

    NumLinha := 0;


    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);
      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);
      Layout.FieldByName('DTA_SAIDA').AsDateTime := QryPrincipal.FieldByName('DTA_SAIDA').AsDateTime;
      //Layout.FieldByName('DTA_MENSAL').AsDateTime := QryPrincipal.FieldByName('DTA_MENSAL').AsDateTime;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmCampoGrande.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmCampoGrande.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmCampoGrande.BtnGerarClick(Sender: TObject);
begin
//  inherited;
     if FlgAtualizaValVenda then
   begin
     AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_VALOR_VENDA.TXT' );
     Rewrite(Arquivo);
     CkbProdLoja.Checked := True;
   end;

   if FlgAtualizaCustoRep then
   begin
     AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_CUSTO_REP.TXT' );
     Rewrite(Arquivo);
     CkbProdLoja.Checked := True;
   end;

   if FlgAtualizaEstoque then
   begin
     AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_ESTOQUE_ATUAL.TXT' );
     Rewrite(Arquivo);
     CkbProdLoja.Checked := True;
   end;

  inherited;


  if FlgAtualizaValVenda then
    CloseFile(Arquivo);

  if FlgAtualizaCustoRep then
    CloseFile(Arquivo);

  if FlgAtualizaEstoque then
    CloseFile(Arquivo);
end;

procedure TFrmCampoGrande.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmCampoGrande.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmCampoGrande.CkbProdLojaClick(Sender: TObject);
begin
  inherited;
  btnGeraValorVenda.Enabled := True;
  btnGeraCustoRep.Enabled := True;
  btnGerarEstoqueAtual.Enabled := True;

  if CkbProdLoja.Checked = False then
  begin
    btnGeraValorVenda.Enabled := False;
    btnGeraCustoRep.Enabled := False;
    btnGerarEstoqueAtual.Enabled := False;
  end;
end;

procedure TFrmCampoGrande.EdtCamBancoExit(Sender: TObject);
begin
  inherited;
  CriarFB(EdtCamBanco);
end;

procedure TFrmCampoGrande.GeraCustoRep;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('   SELECT   ');
    SQL.Add('       CASE   ');
    SQL.Add('           WHEN CHAR_LENGTH(PRODUTOS.COD_MATERIAL) >= 8 THEN PRODUTOS.CODIGO_PRODUTO   ');
    SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''UN'' THEN PRODUTOS.COD_MATERIAL   ');
    SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''KG'' THEN PRODUTOS.COD_MATERIAL   ');
    SQL.Add('           ELSE PRODUTOS.COD_MATERIAL   ');
    SQL.Add('       END AS COD_PRODUTO,   ');
    SQL.Add('       PRODUTOS.PRECO_COMPRA AS VAL_CUSTO_REP   ');
    SQL.Add('   FROM   ');
    SQL.Add('       MATERI AS PRODUTOS   ');
    SQL.Add('   WHERE PRODUTOS.EST_ATU > 0  ');


    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Inc(NumLinha);

        COD_PRODUTO := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_CUSTO_REP = '''+QryPrincipal.FieldByName('VAL_CUSTO_REP').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');

        if NumLinha = 500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 1000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 1500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 2000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 2500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 3000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 3500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 4000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 4400 then
          Writeln(Arquivo, 'COMMIT WORK;');

      except on E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
      end;
      Next;
    end;
    Writeln(Arquivo, 'COMMIT WORK;');
    Close;
  end;
end;

procedure TFrmCampoGrande.GeraEstoqueVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('   SELECT   '); 
    SQL.Add('       CASE   '); 
    SQL.Add('           WHEN CHAR_LENGTH(PRODUTOS.COD_MATERIAL) >= 8 THEN PRODUTOS.CODIGO_PRODUTO   '); 
    SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''UN'' THEN PRODUTOS.COD_MATERIAL   '); 
    SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''KG'' THEN PRODUTOS.COD_MATERIAL   '); 
    SQL.Add('           ELSE PRODUTOS.COD_MATERIAL   '); 
    SQL.Add('       END AS COD_PRODUTO,   '); 
    SQL.Add('       PRODUTOS.EST_ATU AS QTD_EST_ATUAL   '); 
    SQL.Add('   FROM   '); 
    SQL.Add('       MATERI AS PRODUTOS   ');
    SQL.Add('   WHERE PRODUTOS.EST_ATU > 0  ');


    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Inc(NumLinha);

        COD_PRODUTO := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET QTD_EST_ATUAL = '''+QryPrincipal.FieldByName('QTD_EST_ATUAL').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');

        if NumLinha = 500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 1000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 1500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 2000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 2500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 3000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 3500 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 4000 then
          Writeln(Arquivo, 'COMMIT WORK;');
        if NumLinha = 4400 then
          Writeln(Arquivo, 'COMMIT WORK;');

          
      except on E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
      end;
      Next;
    end;
    Writeln(Arquivo, 'COMMIT WORK;');
    Close;
  end;
end;

procedure TFrmCampoGrande.GerarCest;
var
   TotalCount : integer;
   count : integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('      0 AS COD_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CEST = '''' THEN ''9999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.CEST, ''9999999'')    ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       ''A DEFINIR'' AS DES_CEST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS PRODUTOS   ');





    Open;
    First;

    count := 0;
    NumLinha := 0;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(count);
      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      Layout.FieldByName('COD_CEST').AsInteger := count;
      Layout.FieldByName('NUM_CEST').AsString := StrRetNums( Layout.FieldByName('NUM_CEST').AsString );

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarCliente;
//var
//  QryGeraCodigoCliente : TSQLQuery;
//  CODIGO_CLIENTE : Integer;
begin
  inherited;

//  QryGeraCodigoCliente := TSQLQuery.Create(FrmProgresso);
//  with QryGeraCodigoCliente do
//  begin
//    SQLConnection := ScnBanco;
//
//    SQL.Clear;
//    SQL.Add('ALTER TABLE EMD105 ');
//    SQL.Add('ADD CODIGO_CLIENTE INT DEFAULT NULL; ');
//
//    try
//      //ExecSQL;
//    except
//    end;
//
//    SQL.Clear;
//    SQL.Add('UPDATE EMD105');
//    SQL.Add('SET CODIGO_CLIENTE = :COD_CLIENTE ');
//    SQL.Add('WHERE COALESCE(REPLACE(REPLACE(REPLACE(CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') = :NUM_CGC ');
//
//    try
//      //ExecSQL;
//    except
//    end;
//
//  end;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;


       SQL.Add('   SELECT   ');
       SQL.Add('       CLIENTES.COD_FORNECEDOR AS COD_CLIENTE,   ');
       SQL.Add('       COALESCE(CLIENTES.RAZAO_SOCIAL, CLIENTES.NOME_FANTASIA) AS DES_CLIENTE,   ');
       SQL.Add('       CLIENTES.CNPJ AS NUM_CGC,   ');
       SQL.Add('      ');
//       SQL.Add('       CASE   ');
//       SQL.Add('           WHEN CLIENTES.INSC_ESTADUAL = ''ISENTO'' THEN ''''   ');
//       SQL.Add('           ELSE TRIM(COALESCE(REPLACE(REPLACE(CLIENTES.INSC_ESTADUAL, ''.'', ''''), ''-'', ''''), ''''))    ');
       SQL.Add('       '''' AS NUM_INSC_EST,   ');
       SQL.Add('      ');
       SQL.Add('       COALESCE(CLIENTES.ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,   ');
       SQL.Add('       COALESCE(CLIENTES.BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,   ');
       SQL.Add('       COALESCE(CLIENTES.CIDADE, '''') AS DES_CIDADE,   ');
       SQL.Add('       COALESCE(CLIENTES.ESTADO, ''RJ'') AS DES_SIGLA,   ');
       SQL.Add('       COALESCE(CLIENTES.CEP, ''1111111'') AS NUM_CEP,   ');
       SQL.Add('       COALESCE(CLIENTES.TEL1, '''') AS NUM_FONE,   ');
       SQL.Add('       '''' AS NUM_FAX,   ');
       SQL.Add('       COALESCE(CLIENTES.CONTATO, ''A DEFINIR'') AS DES_CONTATO,   ');
       SQL.Add('       0 AS FLG_SEXO,   ');
       SQL.Add('       0 AS VAL_LIMITE_CRETID,   ');
       SQL.Add('       COALESCE(CLIENTES.LIMITE_VENDA, 0) AS VAL_LIMITE_CONV,   ');
       SQL.Add('       0 AS VAL_DEBITO,   ');
       SQL.Add('       0 AS VAL_RENDA,   ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN CLIENTES.LIMITE_VENDA > 0 THEN 99999   ');
       SQL.Add('           ELSE 0   ');
       SQL.Add('       END AS COD_CONVENIO,   ');

       SQL.Add('       0 AS COD_STATUS_PDV,   ');
       SQL.Add('          ');
//       SQL.Add('       CASE   ');
//       SQL.Add('           WHEN CLIENTES.INSC_ESTADUAL = ''ISENTO'' THEN ''N''   ');
//       SQL.Add('           ELSE ''S''    ');
       SQL.Add('       ''N'' AS FLG_EMPRESA,   ');
       SQL.Add('          ');
       SQL.Add('       ''N'' AS FLG_CONVENIO,   ');
       SQL.Add('       ''N'' AS MICRO_EMPRESA,   ');
       SQL.Add('       '''' AS DTA_CADASTRO,   ');
       SQL.Add('       COALESCE(CLIENTES.NUMERO, ''1234'') AS NUM_ENDERECO,   ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN CHAR_LENGTH(CLIENTES.CNPJ) = 11 THEN CASE WHEN CLIENTES.INSC_ESTADUAL = ''ISENTO'' THEN '''' ELSE CLIENTES.INSC_ESTADUAL END  ');
       SQL.Add('           WHEN CLIENTES.CNPJ = ''ISENTO'' THEN ''''   ');
       SQL.Add('           ELSE ''''   ');
       SQL.Add('       END AS NUM_RG,   ');
       SQL.Add('       0 AS FLG_EST_CIVIL,   ');
       SQL.Add('       '''' AS NUM_CELULAR,   ');
       SQL.Add('       '''' AS DTA_ALTERACAO,   ');
       SQL.Add('       COALESCE(REPLACE(CLIENTES.OBS, ASCII_CHAR(13) || ASCII_CHAR(10), ''''), '''' ||''|''|| COALESCE(CLIENTES.TEL1, '''') ||''|''|| COALESCE(CLIENTES.TEL2, '''')) AS DES_OBSERVACAO,   ');
       SQL.Add('       COALESCE(CLIENTES.COMPLEMENTO, ''A DEFINIR'') AS DES_COMPLEMENTO,   ');
       SQL.Add('       COALESCE(CLIENTES.EMAIL, '''') AS DES_EMAIL,   ');
       SQL.Add('       COALESCE(CLIENTES.NOME_FANTASIA, CLIENTES.RAZAO_SOCIAL) AS DES_FANTASIA,   ');
       SQL.Add('       '''' AS DTA_NASCIMENTO,   ');
       SQL.Add('       '''' AS DES_PAI,   ');
       SQL.Add('       '''' AS DES_MAE,   ');
       SQL.Add('       '''' AS DES_CONJUGE,   ');
       SQL.Add('       '''' AS NUM_CPF_CONJUGE,   ');
       SQL.Add('       0 AS VAL_DEB_CONV,   ');
       SQL.Add('       ''N'' AS INATIVO,   ');
       SQL.Add('       '''' AS DES_MATRICULA,   ');
       SQL.Add('       ''N'' AS NUM_CGC_ASSOCIADO,   ');
       SQL.Add('       ''N'' AS FLG_PROD_RURAL,   ');
       SQL.Add('       0 AS COD_STATUS_PDV_CONV,   ');
       SQL.Add('       ''S'' AS FLG_ENVIA_CODIGO,   ');
       SQL.Add('       '''' AS DTA_NASC_CONJUGE,   ');
       SQL.Add('       0 AS COD_CLASSIF   ');
       SQL.Add('   FROM   ');
       SQL.Add('       FORNECEDOR AS CLIENTES   ');
       SQL.Add('   WHERE CHAR_LENGTH(CLIENTES.CNPJ) <= 11   ');




    Open;
    First;
    NumLinha := 0;
    //CODIGO_CLIENTE := 0;
    TotalCont := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
           Layout.SetValues(QryPrincipal, NumLinha, TotalCont);
//      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);


//      with QryGeraCodigoCliente do
//      begin
//        Inc(CODIGO_CLIENTE);
//        Params.ParamByName('COD_CLIENTE').Value := CODIGO_CLIENTE;
//        Params.ParamByName('NUM_CGC').Value := Layout.FieldByName('NUM_CGC').AsString;
//        Layout.FieldByName('COD_CLIENTE').AsInteger := Params.ParamByName('COD_CLIENTE').Value;
//        //ExecSQL();
//      end;

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

      //if StrRetNums(Layout.FieldByName('NUM_RG').AsString) = '' then
        //Layout.FieldByName('NUM_RG').AsString := ''
      //else
        //Layout.FieldByName('NUM_RG').AsString := StrRetNums(Layout.FieldByName('NUM_RG').AsString);

      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

      //if QryPrincipal.FieldByName('NUM_INSC_EST').AsString <> 'ISENTO' then
         //Layout.FieldByName('NUM_INSC_EST').AsString := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);

      //Layout.FieldByName('DTA_NASCIMENTO').AsDateTime := FieldByName('DTA_NASCIMENTO').AsDateTime;
      //Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;

      //Layout.FieldByName('NUM_FONE').AsString := StrRetNums( FieldByName('NUM_FONE').AsString );

      if Layout.FieldByName('FLG_EMPRESA').AsString = 'S' then
      begin
        if not ValidaCGC(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';
      end
      else
        if not ValidaCpf(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';

      //Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      //Layout.FieldByName('DES_EMAIL').AsString := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarCodigoBarras;
var
 count, NEW_CODPROD, TotalCount : Integer;
 cod_antigo, codbarras : string;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.COD_MATERIAL) >= 8 THEN PRODUTO.CODIGO_PRODUTO   ');
     SQL.Add('           WHEN PRODUTO.BALANCA = ''1'' AND PRODUTO.COD_UNI = ''UN'' THEN PRODUTO.COD_MATERIAL   ');
     SQL.Add('           WHEN PRODUTO.BALANCA = ''1'' AND PRODUTO.COD_UNI = ''KG'' THEN PRODUTO.COD_MATERIAL   ');
     SQL.Add('           ELSE PRODUTO.COD_MATERIAL   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTO.COD_MATERIAL AS COD_EAN   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS PRODUTO   ');
     //SQL.Add('   WHERE PRODUTO.COD_MATERIAL IN (''7890541642769'', ''7890541642776'', ''7890541642790'', ''7890541915191'')   ');





    Open;
    First;
    NumLinha := 0;
    TotalCount := SetCountTotal(SQL.Text);
    NEW_CODPROD := 10000;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(NEW_CODPROD);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
      begin
        Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
      end;


      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );

      if Length(StrLBReplace(Trim(StrRetNums( FieldByName('COD_EAN').AsString) ))) < 8 then
       Layout.FieldByName('COD_EAN').AsString := GerarPLU(FieldByName('COD_EAN').AsString);

      if not CodBarrasValido(Layout.FieldByName('COD_EAN').AsString) then
       Layout.FieldByName('COD_EAN').AsString := '';


      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarComposicao;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    COMPOSICAO.PRODUTO_BASE AS COD_PRODUTO,');
    SQL.Add('    COMPOSICAO.PRODUTO AS COD_PRODUTO_COMP,');
    SQL.Add('    COMPOSICAO.QTDE AS QTD_PRODUTO,');
    SQL.Add('    0 AS VAL_VENDA,');
    SQL.Add('    0 AS PER_RATEIO,');
    SQL.Add('    0 AS VAL_DIF');
    SQL.Add('FROM');
    SQL.Add('    PRODUTOS');
    SQL.Add('LEFT JOIN');
    SQL.Add('    PRODUTOS_COMPOSICAO COMPOSICAO');
    SQL.Add('ON');
    SQL.Add('    PRODUTOS.ID = COMPOSICAO.PRODUTO_BASE    ');
    SQL.Add('WHERE');
    SQL.Add('    PRODUTOS.COMPOSTO = 1');
    SQL.Add('AND');
    SQL.Add('    COMPOSICAO.PRODUTO_BASE IS NOT NULL');

    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

//      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//
//      Layout.FieldByName('COD_PRODUTO_COMP').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO_COMP').AsString );

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT      ');
     SQL.Add('       CLIENTES.COD_FORNECEDOR AS COD_CLIENTE,      ');
     SQL.Add('       30 AS NUM_CONDICAO,      ');
     SQL.Add('       2 AS COD_CONDICAO,      ');
     SQL.Add('       1 AS COD_ENTIDADE      ');
     SQL.Add('   FROM      ');
     SQL.Add('       FORNECEDOR AS CLIENTES   ');
     SQL.Add('   WHERE CHAR_LENGTH(CLIENTES.CNPJ) <= 11   ');



    Open;

    First;
    TotalCont := SetCountTotal(SQL.Text);
    NumLinha := 0;



    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCont);
      //Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarCondPagForn;
//var
//  COD_FORNECEDOR : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDOR.COD_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       FORNECEDOR.CNPJ AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('       FORNECEDOR   ');
     SQL.Add('   WHERE CHAR_LENGTH(FORNECEDOR.CNPJ) >= 14   ');




    Open;

    First;

    NumLinha := 0;
//    COD_FORNECEDOR := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

//      Inc(COD_FORNECEDOR);
//      Layout.FieldByName('COD_FORNECEDOR').AsInteger := COD_FORNECEDOR;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarDecomposicao;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    DECOMPOSICAO.PRODUTO_BASE AS COD_PRODUTO,');
    SQL.Add('    DECOMPOSICAO.PRODUTO AS COD_PRODUTO_DECOM,');
    SQL.Add('    DECOMPOSICAO.QTDE * 100 AS QTD_DECOMP,');
    SQL.Add('    PRODUTOS.UNIDADE_COMPRA AS DES_UNIDADE');
    SQL.Add('FROM');
    SQL.Add('    PRODUTOS');
    SQL.Add('LEFT JOIN');
    SQL.Add('    PRODUTOS_COMPOSICAO DECOMPOSICAO');
    SQL.Add('ON');
    SQL.Add('    PRODUTOS.ID = DECOMPOSICAO.PRODUTO_BASE');
    SQL.Add('WHERE');
    SQL.Add('    PRODUTOS.COMPOSTO = 4');



    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

//      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//
//      Layout.FieldByName('COD_PRODUTO_DECOM').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO_DECOM').AsString );

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarDivisaoForn;
begin
  inherited;
    with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    DIVISAO.FORNECEDOR AS COD_FORNECEDOR,');
    SQL.Add('    DIVISAO.ID AS COD_DIVISAO,');
    SQL.Add('    DIVISAO.DESCRITIVO AS DES_DIVISAO,');
    SQL.Add('    FORNECEDORES.LOGRADOURO || '' '' || FORNECEDORES.ENDERECO AS DES_ENDERECO,');
    SQL.Add('    FORNECEDORES.BAIRRO AS DES_BAIRRO,');
    SQL.Add('    FORNECEDORES.CEP AS NUM_CEP,');
    SQL.Add('    FORNECEDORES.CIDADE AS DES_CIDADE,');
    SQL.Add('    FORNECEDORES.ESTADO AS DES_SIGLA,');
    SQL.Add('    FORNECEDORES.TELEFONE1 AS NUM_FONE,');
    SQL.Add('    '''' AS DES_CONTATO,');
    SQL.Add('    FORNECEDORES.EMAIL AS DES_EMAIL,');
    SQL.Add('    FORNECEDORES.OBSERVACAO AS DES_OBSERVACAO');
    SQL.Add('FROM');
    SQL.Add('    FORNECEDORES_LINHAS DIVISAO');
    SQL.Add('LEFT JOIN');
    SQL.Add('    FORNECEDORES');
    SQL.Add('ON');
    SQL.Add('    DIVISAO.FORNECEDOR = FORNECEDORES.ID');

    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

      Layout.FieldByName('DES_EMAIL').AsString := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmCampoGrande.GerarFinanceiroPagar(Aberto: String);
var
   TotalCount : Integer;
   cgc: string;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;
    if Aberto = '1' then
    begin
        //ABERTO
     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('       1 AS TIPO_PARCEIRO,   ');
     SQL.Add('       PAGAR_ABERTO.FORNECEDOR AS COD_PARCEIRO,   ');
     SQL.Add('       0 AS TIPO_CONTA,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       COALESCE(PAGAR_ABERTO.BOLETO, '''') AS NUM_DOCTO,   ');
     SQL.Add('       999 AS COD_BANCO,   ');
     SQL.Add('       0 AS DES_BANCO,   ');
     SQL.Add('       PAGAR_ABERTO.DATA_CADASTRO AS DTA_EMISSAO,   ');
     SQL.Add('       PAGAR_ABERTO.DATA_VENCIMENTO AS DTA_VENCIMENTO,   ');
     SQL.Add('       PAGAR_ABERTO.VALOR_VENCIMENTO AS VAL_PARCELA,   ');
     SQL.Add('       0 AS VAL_JUROS,   ');
     SQL.Add('       0 AS VAL_DESCONTO,   ');
     SQL.Add('       ''N'' AS FLG_QUITADO,   ');
     SQL.Add('       '''' AS DTA_QUITADA,   ');
     SQL.Add('       998 AS COD_CATEGORIA,   ');
     SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
     SQL.Add('       1 AS NUM_PARCELA,   ');
     SQL.Add('       1 AS QTD_PARCELA,   ');
     SQL.Add('       1 AS COD_LOJA,   ');
     SQL.Add('       FORNECEDOR.CNPJ AS NUM_CGC,   ');
     SQL.Add('       0 AS NUM_BORDERO,   ');
     SQL.Add('       COALESCE(PAGAR_ABERTO.NOTA_FISCAL, '''') AS NUM_NF,   ');
     SQL.Add('       '''' AS NUM_SERIE_NF,   ');
     SQL.Add('       PAGAR_ABERTO.VALOR_VENCIMENTO AS VAL_TOTAL_NF,   ');
     SQL.Add('       COALESCE(PAGAR_ABERTO.OBS, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS NUM_PDV,   ');
     SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       0 AS COD_MOTIVO,   ');
     SQL.Add('       0 AS COD_CONVENIO,   ');
     SQL.Add('       0 AS COD_BIN,   ');
     SQL.Add('       '''' AS DES_BANDEIRA,   ');
     SQL.Add('       '''' AS DES_REDE_TEF,   ');
     SQL.Add('       0 AS VAL_RETENCAO,    ');
     SQL.Add('       0 AS COD_CONDICAO,   ');
     SQL.Add('       '''' AS DTA_PAGTO,   ');
     SQL.Add('       PAGAR_ABERTO.DATA_CADASTRO AS DTA_ENTRADA,   ');
     SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
     SQL.Add('       '''' AS COD_BARRA,   ');
     SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
     SQL.Add('       FORNECEDOR.CNPJ AS NUM_CGC_CPF_TITULAR,   ');
     SQL.Add('       COALESCE(FORNECEDOR.RAZAO_SOCIAL, FORNECEDOR.NOME_FANTASIA) AS DES_TITULAR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       0 AS VAL_CREDITO,   ');
     SQL.Add('       999 AS COD_BANCO_PGTO,   ');
     SQL.Add('       ''PAGTO'' AS DES_CC,   ');
     SQL.Add('       0 AS COD_BANDEIRA,   ');
     SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
     SQL.Add('       1 AS NUM_SEQ_FIN,   ');
     SQL.Add('       0 AS COD_COBRANCA,   ');
     SQL.Add('       '''' AS DTA_COBRANCA,   ');
     SQL.Add('       ''N'' AS FLG_ACEITE,   ');
     SQL.Add('       0 AS TIPO_ACEITE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CONTAS_A_PAGAR AS PAGAR_ABERTO   ');
     SQL.Add('   LEFT JOIN FORNECEDOR ON FORNECEDOR.COD_FORNECEDOR = PAGAR_ABERTO.FORNECEDOR   ');
     SQL.Add('   WHERE PAGAR_ABERTO.DATA_PAGAMENTO IS NULL   ');
     SQL.Add('   AND PAGAR_ABERTO.VALOR_VENCIMENTO > 0    ');
     SQL.Add('   AND PAGAR_ABERTO.VALOR_VENCIMENTO IS NOT NULL ');
     SQL.Add('   AND CHAR_LENGTH(FORNECEDOR.CNPJ) >= 14 ');
    end
    else
    begin
      //QUITADO
       SQL.Add('           SELECT DISTINCT      ');
       SQL.Add('               1 AS TIPO_PARCEIRO,      ');
       SQL.Add('               PAGAR_ABERTO.FORNECEDOR AS COD_PARCEIRO,      ');
       SQL.Add('               0 AS TIPO_CONTA,      ');
       SQL.Add('               8 AS COD_ENTIDADE,      ');
       SQL.Add('               COALESCE(PAGAR_ABERTO.BOLETO, '''') AS NUM_DOCTO,      ');
       SQL.Add('               999 AS COD_BANCO,      ');
       SQL.Add('               0 AS DES_BANCO,      ');
       SQL.Add('               PAGAR_ABERTO.DATA_CADASTRO AS DTA_EMISSAO,      ');
       SQL.Add('               PAGAR_ABERTO.DATA_VENCIMENTO AS DTA_VENCIMENTO,      ');
       SQL.Add('               PAGAR_ABERTO.VALOR_VENCIMENTO AS VAL_PARCELA,      ');
       SQL.Add('               0 AS VAL_JUROS,      ');
       SQL.Add('               0 AS VAL_DESCONTO,      ');
       SQL.Add('               ''S'' AS FLG_QUITADO,      ');
       SQL.Add('               PAGAR_ABERTO.DATA_PAGAMENTO AS DTA_QUITADA,      ');
       SQL.Add('               998 AS COD_CATEGORIA,      ');
       SQL.Add('               998 AS COD_SUBCATEGORIA,      ');
       SQL.Add('               1 AS NUM_PARCELA,      ');
       SQL.Add('               1 AS QTD_PARCELA,      ');
       SQL.Add('               1 AS COD_LOJA,      ');
       SQL.Add('               FORNECEDOR.CNPJ AS NUM_CGC,      ');
       SQL.Add('               0 AS NUM_BORDERO,      ');
       SQL.Add('               COALESCE(PAGAR_ABERTO.NOTA_FISCAL, '''') AS NUM_NF,      ');
       SQL.Add('               '''' AS NUM_SERIE_NF,      ');
       SQL.Add('               PAGAR_ABERTO.VALOR_VENCIMENTO AS VAL_TOTAL_NF,      ');
       SQL.Add('               COALESCE(PAGAR_ABERTO.OBS, '''') AS DES_OBSERVACAO,      ');
       SQL.Add('               0 AS NUM_PDV,      ');
       SQL.Add('               0 AS NUM_CUPOM_FISCAL,      ');
       SQL.Add('               0 AS COD_MOTIVO,      ');
       SQL.Add('               0 AS COD_CONVENIO,      ');
       SQL.Add('               0 AS COD_BIN,      ');
       SQL.Add('               '''' AS DES_BANDEIRA,      ');
       SQL.Add('               '''' AS DES_REDE_TEF,      ');
       SQL.Add('               0 AS VAL_RETENCAO,       ');
       SQL.Add('               0 AS COD_CONDICAO,      ');
       SQL.Add('               PAGAR_ABERTO.DATA_PAGAMENTO AS DTA_PAGTO,      ');
       SQL.Add('               PAGAR_ABERTO.DATA_CADASTRO AS DTA_ENTRADA,      ');
       SQL.Add('               '''' AS NUM_NOSSO_NUMERO,      ');
       SQL.Add('               '''' AS COD_BARRA,      ');
       SQL.Add('               ''N'' AS FLG_BOLETO_EMIT,      ');
       SQL.Add('               FORNECEDOR.CNPJ AS NUM_CGC_CPF_TITULAR,      ');
       SQL.Add('               COALESCE(FORNECEDOR.RAZAO_SOCIAL, FORNECEDOR.NOME_FANTASIA) AS DES_TITULAR,      ');
       SQL.Add('               30 AS NUM_CONDICAO,      ');
       SQL.Add('               0 AS VAL_CREDITO,      ');
       SQL.Add('               999 AS COD_BANCO_PGTO,      ');
       SQL.Add('               ''PAGTO'' AS DES_CC,      ');
       SQL.Add('               0 AS COD_BANDEIRA,      ');
       SQL.Add('               '''' AS DTA_PRORROGACAO,      ');
       SQL.Add('               1 AS NUM_SEQ_FIN,      ');
       SQL.Add('               0 AS COD_COBRANCA,      ');
       SQL.Add('               '''' AS DTA_COBRANCA,      ');
       SQL.Add('               ''N'' AS FLG_ACEITE,      ');
       SQL.Add('               0 AS TIPO_ACEITE      ');
       SQL.Add('           FROM      ');
       SQL.Add('               CONTAS_A_PAGAR AS PAGAR_ABERTO      ');
       SQL.Add('           LEFT JOIN FORNECEDOR ON FORNECEDOR.COD_FORNECEDOR = PAGAR_ABERTO.FORNECEDOR      ');
       SQL.Add('           WHERE PAGAR_ABERTO.DATA_PAGAMENTO IS NOT NULL      ');
       SQL.Add('           AND PAGAR_ABERTO.VALOR_VENCIMENTO > 0       ');
       SQL.Add('           AND PAGAR_ABERTO.VALOR_VENCIMENTO IS NOT NULL    ');
       SQL.Add('           AND CHAR_LENGTH(FORNECEDOR.CNPJ) >= 14   ');
       SQL.Add('AND');
       SQL.Add('    PAGAR_ABERTO.DATA_PAGAMENTO >= :INI ');
       SQL.Add('AND');
       SQL.Add('    PAGAR_ABERTO.DATA_PAGAMENTO <= :FIM ');
       ParamByName('INI').AsDate := DtpInicial.Date;
       ParamByName('FIM').AsDate := DtpFinal.Date;

    end;


    Open;
    First;

    if( Aberto = '1' ) then
      TotalCount := SetCountTotal(SQL.Text)
    else
      TotalCount := SetCountTotal(SQL.Text, ParamByName('INI').AsString, ParamByName('FIM').AsString );
//    TotalCount := SetCountTotal(SQL.Text);

    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

//      if( CbxLoja.Text = '2' ) then
//      begin
//         cgc := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);
//         if( Length(cgc) > 11 ) then begin
//           if( not CNPJEValido(cgc) ) then
//            Layout.FieldByName('COD_PARCEIRO').AsInteger := Layout.FieldByName('COD_PARCEIRO').AsInteger + 1000
//           else
//            Layout.FieldByName('COD_PARCEIRO').AsInteger := 0;
//         end
//         else
//         begin
//            if( not CPFEValido(cgc) ) then
//               Layout.FieldByName('COD_PARCEIRO').AsInteger := Layout.FieldByName('COD_PARCEIRO').AsInteger + 1000
//            else
//               Layout.FieldByName('COD_PARCEIRO').AsInteger := 0;
//         end;
//      end;

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

      Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
      Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime);
      Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);

      Layout.FieldByName('NUM_NF').AsString := StrRetNums(Layout.FieldByName('NUM_NF').AsString);

      if Aberto = '1' then
      begin
        Layout.FieldByName('DTA_QUITADA').AsString := '';
        Layout.FieldByName('DTA_PAGTO').AsString := '';
      end
      else
      begin
        Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_QUITADA').AsDateTime);
        Layout.FieldByName('DTA_PAGTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_PAGTO').AsDateTime);
      end;

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarFinanceiroReceber(Aberto: String);
var
   TotalCount : Integer;
   cgc : string;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    0 AS TIPO_PARCEIRO,');
    SQL.Add('    RECEBER.COD_CLI AS COD_PARCEIRO,');
    SQL.Add('    1 AS TIPO_CONTA,');
    SQL.Add('    1 AS COD_ENTIDADE,');
    SQL.Add('    RECEBER.SEQ AS NUM_DOCTO,');
    SQL.Add('    999 AS COD_BANCO,');
    SQL.Add('    '''' AS DES_BANCO,');
    SQL.Add('    RECEBER.DT_VENDA AS DTA_EMISSAO,');
    SQL.Add('    RECEBER.VENCIMENTO AS DTA_VENCIMENTO,');
    SQL.Add('    CASE');
    SQL.Add('        WHEN RECEBER.BAIXADO = ''S'' THEN RECEBER.VALOR');
    SQL.Add('        ELSE RECEBER.VR_ATUAL');
    SQL.Add('    END AS VAL_PARCELA,');
    SQL.Add('    0 AS VAL_JUROS,');
    SQL.Add('    0 AS VAL_DESCONTO,');
    SQL.Add('');
    SQL.Add('    CASE ');
    SQL.Add('        WHEN RECEBER.BAIXADO = ''S'' THEN ''S''');
    SQL.Add('        ELSE ''N''');
    SQL.Add('    END AS FLG_QUITADO,');
    SQL.Add('    ');
    SQL.Add('    CASE ');
    SQL.Add('        WHEN RECEBER.BAIXADO = ''S'' THEN LPAD(EXTRACT(DAY FROM RECEBER.DT_PAGAMENTO), 2, ''0'') || ''/'' || LPAD(EXTRACT(MONTH FROM RECEBER.DT_PAGAMENTO), 2, ''0'')|| ''/'' || LPAD(EXTRACT(YEAR FROM RECEBER.DT_PAGAMENTO), 4, ''0'')');
    SQL.Add('        ELSE ''''');
    SQL.Add('    END AS DTA_QUITADA,');
    SQL.Add('');
    SQL.Add('    ''997'' AS COD_CATEGORIA,');
    SQL.Add('    ''997'' AS COD_SUBCATEGORIA,');
    SQL.Add('    1 AS NUM_PARCELA,');
    SQL.Add('    1 AS QTD_PARCELA,');
    SQL.Add('    1 AS COD_LOJA,');
    SQL.Add('    CLIENTE.CGC AS NUM_CGC,');
    SQL.Add('    0 AS NUM_BORDERO,');
    SQL.Add('    RECEBER.N_FISCAL AS NUM_NF,');
    SQL.Add('    '''' AS NUM_SERIE_NF,');
    SQL.Add('    RECEBER.VALOR AS VAL_TOTAL_NF,');
    SQL.Add('    '''' AS DES_OBSERVACAO,');
    SQL.Add('    COALESCE(CAIXA.COD_CAIXA, 1) AS NUM_PDV,');
    SQL.Add('    RECEBER.N_FISCAL AS NUM_CUPOM_FISCAL,');
    SQL.Add('    0 AS COD_MOTIVO,');
    SQL.Add('    0 AS COD_CONVENIO,');
    SQL.Add('    0 AS COD_BIN,');
    SQL.Add('    '''' AS DES_BANDEIRA,');
    SQL.Add('    '''' AS DES_REDE_TEF,');
    SQL.Add('    0 AS VAL_RETENCAO,');
    SQL.Add('    0 AS COD_CONDICAO,');
    SQL.Add('');
    SQL.Add('    CASE ');
    SQL.Add('        WHEN RECEBER.BAIXADO = ''S'' THEN LPAD(EXTRACT(DAY FROM RECEBER.DT_PAGAMENTO), 2, ''0'') || ''/'' || LPAD(EXTRACT(MONTH FROM RECEBER.DT_PAGAMENTO), 2, ''0'')|| ''/'' || LPAD(EXTRACT(YEAR FROM RECEBER.DT_PAGAMENTO), 4, ''0'')');
    SQL.Add('        ELSE ''''');
    SQL.Add('    END AS DTA_PAGTO,');
    SQL.Add('');
    SQL.Add('    RECEBER.DT_VENDA AS DTA_ENTRADA,');
    SQL.Add('    '''' AS NUM_NOSSO_NUMERO,');
    SQL.Add('    '''' AS COD_BARRA,');
    SQL.Add('    ''N'' AS FLG_BOLETO_EMIT,');
    SQL.Add('    '''' AS NUM_CGC_CPF_TITULAR,');
    SQL.Add('    '''' AS DES_TITULAR,');
    SQL.Add('    30 AS NUM_CONDICAO,');
    SQL.Add('    0 AS VAL_CREDITO,');
    SQL.Add('    999 AS COD_BANCO_PGTO,');
    SQL.Add('    ''RECEBTO-1'' AS DES_CC,');
    SQL.Add('    0 AS COD_BANDEIRA,');
    SQL.Add('    '''' AS DTA_PRORROGACAO,');
    SQL.Add('    1 AS NUM_SEQ_FIN,');
    SQL.Add('    0 AS COD_COBRANCA,');
    SQL.Add('    '''' AS DTA_COBRANCA,');
    SQL.Add('    ''N'' AS FLG_ACEITE,');
    SQL.Add('    0 AS TIPO_ACEITE');
    SQL.Add('FROM RECEBER');
    SQL.Add('LEFT JOIN CAIXA');
    SQL.Add('ON RECEBER.NUM_OPER = CAIXA.NUM_OPER');
    SQL.Add('LEFT JOIN CADCLI AS CLIENTE');
    SQL.Add('ON RECEBER.COD_CLI = CLIENTE.CODIGO');
    SQL.Add('WHERE RECEBER.VALOR > 0');

    if Aberto = '1' then
    begin
      SQL.Add('AND RECEBER.BAIXADO <> ''S''');
    end
    else
    begin
      SQL.Add('AND RECEBER.DT_PAGAMENTO >= :INI ');
      SQL.Add('AND RECEBER.DT_PAGAMENTO <= :FIM ');
      SQL.Add('AND RECEBER.BAIXADO = ''S'' ');

      ParamByName('INI').AsDate := DtpInicial.Date;
      ParamByName('FIM').AsDate := DtpFinal.Date;
    end;

    Open;

    First;

    if( Aberto = '1' ) then
      TotalCount := SetCountTotal(SQL.Text)
    else
      TotalCount := SetCountTotal(SQL.Text, ParamByName('INI').AsString, ParamByName('FIM').AsString );

    Open;

    First;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      if( CbxLoja.Text = '2' ) then
      begin
         cgc := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);
         if( Length(cgc) > 11 ) then begin
           if( not CNPJEValido(cgc) ) then
            Layout.FieldByName('COD_PARCEIRO').AsInteger := Layout.FieldByName('COD_PARCEIRO').AsInteger + 2000
           else
            Layout.FieldByName('COD_PARCEIRO').AsInteger := 0;
         end
         else
         begin
            if( not CPFEValido(cgc) ) then
               Layout.FieldByName('COD_PARCEIRO').AsInteger := Layout.FieldByName('COD_PARCEIRO').AsInteger + 2000
            else
               Layout.FieldByName('COD_PARCEIRO').AsInteger := 0;
         end;
      end;

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

      Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
      Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime);
      Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);

      if Aberto = '1' then
      begin
        Layout.FieldByName('DTA_QUITADA').AsString := '';
        Layout.FieldByName('DTA_PAGTO').AsString := '';
      end
      else
      begin
        Layout.FieldByName('DTA_QUITADA').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_QUITADA').AsDateTime);
        Layout.FieldByName('DTA_PAGTO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_PAGTO').AsDateTime);
      end;

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarFinanceiroReceberCartao;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

//    SQL.Add('SELECT');
//    SQL.Add('');
//    SQL.Add('    CASE RECEBER.TIPO_CADASTRO');
//    SQL.Add('        WHEN 0 THEN 0');
//    SQL.Add('        WHEN 1 THEN 3');
//    SQL.Add('        WHEN 4 THEN 4');
//    SQL.Add('        WHEN 5 THEN 0');
//    SQL.Add('    END AS TIPO_PARCEIRO, -- TIPO_CADASTRO');
//    SQL.Add('');
//    SQL.Add('     CASE');
//    SQL.Add('          WHEN RECEBER.TIPO_CADASTRO = 5 THEN 2400 + RECEBER.ID_CADASTRO ');
//    SQL.Add('          WHEN RECEBER.TIPO_CADASTRO = 5 AND COALESCE(RECEBER.ID_CADASTRO, 0) = 0 THEN 6');
//    SQL.Add('          WHEN RECEBER.TIPO_CADASTRO = 4 THEN 99');
//    SQL.Add('          ELSE CASE WHEN COALESCE(RECEBER.ID_CADASTRO, 0) = 0 THEN 99999 ELSE RECEBER.ID_CADASTRO END');
//    SQL.Add('     END AS COD_PARCEIRO,  ');
//    SQL.Add('');
//    SQL.Add('    1 AS TIPO_CONTA,');
//    SQL.Add('');
//    SQL.Add('    CASE RECEBER.FORMA_PAGTO');
//    SQL.Add('        WHEN 1 THEN 1');
//    SQL.Add('        WHEN 2 THEN 2');
//    SQL.Add('        WHEN 3 THEN 4');
//    SQL.Add('        WHEN 4 THEN 10');
//    SQL.Add('        WHEN 5 THEN 11');
//    SQL.Add('        WHEN 6 THEN 6');
//    SQL.Add('        WHEN 7 THEN 12');
//    SQL.Add('        WHEN 8 THEN 3');
//    SQL.Add('        WHEN 9 THEN 13');
//    SQL.Add('        WHEN 10 THEN 5');
//    SQL.Add('        WHEN 11 THEN 7');
//    SQL.Add('        WHEN 12 THEN 14');
//    SQL.Add('        WHEN 13 THEN 15');
//    SQL.Add('        WHEN 14 THEN 16');
//    SQL.Add('        WHEN 15 THEN 17');
//    SQL.Add('        WHEN 16 THEN 18');
//    SQL.Add('        WHEN 17 THEN 19');
//    SQL.Add('        WHEN 18 THEN 20');
//    SQL.Add('        WHEN 19 THEN 21');
//    SQL.Add('        WHEN 20 THEN 22');
//    SQL.Add('        WHEN 21 THEN 23');
//    SQL.Add('        WHEN 22 THEN 24');
//    SQL.Add('        WHEN 23 THEN 25');
//    SQL.Add('        WHEN 24 THEN 26');
//    SQL.Add('        WHEN 25 THEN 27');
//    SQL.Add('        ELSE 1');
//    SQL.Add('    END AS COD_ENTIDADE,');
//    SQL.Add('');
//    SQL.Add('    RECEBER.ARQUIVO AS NUM_DOCTO,');
//    SQL.Add('    999 AS COD_BANCO,');
//    SQL.Add('    '''' AS DES_BANCO,');
//    SQL.Add('    RECEBER.EMISSAO AS DTA_EMISSAO,');
//    SQL.Add('    RECEBER.VENCIMENTO AS DTA_VENCIMENTO,');
//    SQL.Add('    RECEBER.VALOR AS VAL_PARCELA,');
//    SQL.Add('    RECEBER.ACRESCIMO + RECEBER.CARTORIO + COALESCE(RECEBER.CREDITO, 0) AS VAL_JUROS,');
//    SQL.Add('    RECEBER.DESCONTO AS VAL_DESCONTO,');
//    SQL.Add('');
//    SQL.Add('    CASE ');
//    SQL.Add('        WHEN RECEBER.PAGAMENTO IS NULL THEN ''N''');
//    SQL.Add('        ELSE ''S''');
//    SQL.Add('    END AS FLG_QUITADO,');
//    SQL.Add('');
//    SQL.Add('    CASE ');
//    SQL.Add('        WHEN RECEBER.PAGAMENTO IS NULL THEN NULL');
//    SQL.Add('        ELSE RECEBER.PAGAMENTO');
//    SQL.Add('    END AS DTA_QUITADA,');
//    SQL.Add('');
//    SQL.Add('    ');
//    SQL.Add('    CASE RECEBER.CAIXA');
//    SQL.Add('        WHEN 2 THEN ''001''');
//    SQL.Add('        ELSE ''997''');
//    SQL.Add('    END AS COD_CATEGORIA,');
//    SQL.Add('');
//    SQL.Add('    CASE RECEBER.CAIXA');
//    SQL.Add('        WHEN 2 THEN ''032''');
//    SQL.Add('        ELSE ''997''');
//    SQL.Add('    END AS COD_SUBCATEGORIA,');
//    SQL.Add('');
//    SQL.Add('    RECEBER.PARCELA AS NUM_PARCELA,');
//    SQL.Add('    RECEBER.TOTAL_PARCELA AS QTD_PARCELA,');
//    SQL.Add('    RECEBER.EMPRESA AS COD_LOJA,');
//    SQL.Add('    RECEBER.CPF_CNPJ AS NUM_CGC,');
//    SQL.Add('    COALESCE(RECEBER.BORDERO, 0) AS NUM_BORDERO,');
//    SQL.Add('    RECEBER.NF AS NUM_NF,');
//    SQL.Add('    '''' AS NUM_SERIE_NF,');
//    SQL.Add('    CASE WHEN NF.VAL_TOTAL_NF = 0 THEN RECEBER.VALOR ELSE NF.VAL_TOTAL_NF END AS VAL_TOTAL_NF, -- EFETUAR A SOMA');
//    SQL.Add('    ''COBRAN�A: '' || RECEBER.DATACOB || '' | 1 DEVOL: '' || RECEBER.DEVOLUCAOA || '' | 2 DEVOL : '' || RECEBER.DEVOLUCAOB || '' | ''  || RECEBER.OBSERVACAO AS DES_OBSERVACAO,');
//    SQL.Add('    COALESCE(RECEBER.PDV, 0) AS NUM_PDV,');
//    SQL.Add('    RECEBER.NOTA AS NUM_CUPOM_FISCAL,');
//    SQL.Add('    0 AS COD_MOTIVO,');
//    SQL.Add('');
//    SQL.Add('    CASE RECEBER.FORMA_PAGTO');
//    SQL.Add('        WHEN 14 THEN (SELECT COALESCE(24000 + CLIENTES.EMPRESA_CONVENIO, 0) FROM CLIENTES WHERE CLIENTES.ID = RECEBER.ID_CADASTRO)');
//    SQL.Add('        ELSE 0');
//    SQL.Add('    END AS COD_CONVENIO,');
//    SQL.Add('');
//    SQL.Add('    0 AS COD_BIN,');
//    SQL.Add('    '''' AS DES_BANDEIRA,');
//    SQL.Add('    '''' AS DES_REDE_TEF,');
//    SQL.Add('    0 AS VAL_RETENCAO,');
//    SQL.Add('    0 AS COD_CONDICAO,');
//    SQL.Add('');
//    SQL.Add('    CASE ');
//    SQL.Add('        WHEN RECEBER.PAGAMENTO IS NULL THEN NULL');
//    SQL.Add('        ELSE RECEBER.PAGAMENTO');
//    SQL.Add('    END AS DTA_PAGTO,');
//    SQL.Add('');
//    SQL.Add('    RECEBER.DATAHORA_CADASTRO AS DTA_ENTRADA,');
//    SQL.Add('');
//    SQL.Add('    '''' AS NUM_NOSSO_NUMERO,');
//    SQL.Add('    COALESCE(RECEBER.CODBARRAS, '''') AS COD_BARRA,');
//    SQL.Add('    ''N'' AS FLG_BOLETO_EMIT,');
//    SQL.Add('    '''' AS NUM_CGC_CPF_TITULAR,');
//    SQL.Add('    '''' AS DES_TITULAR,');
//    SQL.Add('    CASE RECEBER.FORMA_PAGTO');
//    SQL.Add('        WHEN 11 THEN 0');
//    SQL.Add('        ELSE 30');
//    SQL.Add('    END AS NUM_CONDICAO,');
//    SQL.Add('    0 AS VAL_CREDITO,');
//    SQL.Add('    ''999'' AS COD_BANCO_PGTO,');
//    SQL.Add('    ''RECEBTO-1'' AS DES_CC,');
//
//    SQL.Add('    CASE ');
//    SQL.Add('        WHEN RECEBER.TIPO_CADASTRO = 4 THEN CASE WHEN RECEBER.EMPRESA = 1 THEN 9999 ELSE 999 END');
//    SQL.Add('        ELSE 0');
//    SQL.Add('        END AS COD_BANDEIRA,');
//
//
//    SQL.Add('    '''' AS DTA_PRORROGACAO,');
//    SQL.Add('    1 AS NUM_SEQ_FIN,');
//    SQL.Add('    CASE RECEBER.COBRADOR');
//    SQL.Add('        WHEN 1 THEN 3405');
//    SQL.Add('        WHEN 2 THEN 3403');
//    SQL.Add('        WHEN 3 THEN 3404');
//    SQL.Add('        ELSE 0');
//    SQL.Add('    END AS COD_COBRANCA,');
//    SQL.Add('    RECEBER.DATACOB AS DTA_COBRANCA,');
//    SQL.Add('    CASE');
//    SQL.Add('        WHEN LENGTH(RECEBER.CODBARRAS) > 0 THEN ''S''');
//    SQL.Add('        ELSE ''N''');
//    SQL.Add('    END AS FLG_ACEITE,');
//    SQL.Add('    CASE');
//    SQL.Add('        WHEN LENGTH(RECEBER.CODBARRAS) = 34 THEN 4 ');
//    SQL.Add('        WHEN LENGTH(RECEBER.CODBARRAS) > 34 THEN 1 ');
//    SQL.Add('        ELSE 0');
//    SQL.Add('    END AS TIPO_ACEITE');
//
//    SQL.Add('FROM');
//    SQL.Add('    CONTAS RECEBER');

    SQL.Add('SELECT');
    SQL.Add('');
    SQL.Add('CASE RECEBER.TIPO_CADASTRO');
    SQL.Add('    WHEN 0 THEN 0');
    SQL.Add('    WHEN 1 THEN 3');
    SQL.Add('    WHEN 4 THEN 4');
    SQL.Add('    WHEN 5 THEN 0');
    SQL.Add('END AS TIPO_PARCEIRO, -- TIPO_CADASTRO');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('        WHEN RECEBER.TIPO_CADASTRO = 5 THEN 2400 + RECEBER.ID_CADASTRO ');
    SQL.Add('        WHEN RECEBER.TIPO_CADASTRO = 5 AND COALESCE(RECEBER.ID_CADASTRO, 0) = 0 THEN 6');
    SQL.Add('        WHEN RECEBER.TIPO_CADASTRO = 4 THEN 99');
    SQL.Add('        ELSE CASE WHEN COALESCE(RECEBER.ID_CADASTRO, 0) = 0 THEN 99999 ELSE RECEBER.ID_CADASTRO END');
    SQL.Add('    END AS COD_PARCEIRO,  ');
    SQL.Add('');
    SQL.Add('1 AS TIPO_CONTA,');
    SQL.Add('');
    SQL.Add('CASE RECEBER.FORMA_PAGTO');
    SQL.Add('    WHEN 1 THEN 1');
    SQL.Add('    WHEN 2 THEN 2');
    SQL.Add('    WHEN 3 THEN 4');
    SQL.Add('    WHEN 4 THEN 10');
    SQL.Add('    WHEN 5 THEN 11');
    SQL.Add('    WHEN 6 THEN 6');
    SQL.Add('    WHEN 7 THEN 12');
    SQL.Add('    WHEN 8 THEN 3');
    SQL.Add('    WHEN 9 THEN 13');
    SQL.Add('    WHEN 10 THEN 5');
    SQL.Add('    WHEN 11 THEN 7');
    SQL.Add('    WHEN 12 THEN 14');
    SQL.Add('    WHEN 13 THEN 15');
    SQL.Add('    WHEN 14 THEN 16');
    SQL.Add('    WHEN 15 THEN 17');
    SQL.Add('    WHEN 16 THEN 18');
    SQL.Add('    WHEN 17 THEN 19');
    SQL.Add('    WHEN 18 THEN 20');
    SQL.Add('    WHEN 19 THEN 21');
    SQL.Add('    WHEN 20 THEN 22');
    SQL.Add('    WHEN 21 THEN 23');
    SQL.Add('    WHEN 22 THEN 24');
    SQL.Add('    WHEN 23 THEN 25');
    SQL.Add('    WHEN 24 THEN 26');
    SQL.Add('    WHEN 25 THEN 27');
    SQL.Add('    ELSE 1');
    SQL.Add('END AS COD_ENTIDADE,');
    SQL.Add('');
    SQL.Add('RECEBER.ARQUIVO AS NUM_DOCTO,');
    SQL.Add('999 AS COD_BANCO,');
    SQL.Add(''''' AS DES_BANCO,');
    SQL.Add('RECEBER.EMISSAO AS DTA_EMISSAO,');
    SQL.Add('RECEBER.VENCIMENTO AS DTA_VENCIMENTO,');
    SQL.Add('RECEBER.VALOR AS VAL_PARCELA,');
    SQL.Add('RECEBER.ACRESCIMO + RECEBER.CARTORIO + COALESCE(RECEBER.CREDITO, 0) AS VAL_JUROS,');
    SQL.Add('RECEBER.DESCONTO AS VAL_DESCONTO,');
    SQL.Add('');
    SQL.Add('CASE ');
    SQL.Add('    WHEN RECEBER.PAGAMENTO IS NULL THEN ''N''');
    SQL.Add('    ELSE ''S''');
    SQL.Add('END AS FLG_QUITADO,');
    SQL.Add('');
    SQL.Add('CASE ');
    SQL.Add('    WHEN RECEBER.PAGAMENTO IS NULL THEN NULL');
    SQL.Add('    ELSE RECEBER.PAGAMENTO');
    SQL.Add('END AS DTA_QUITADA,');
    SQL.Add('');
    SQL.Add('');
    SQL.Add('CASE RECEBER.CAIXA');
    SQL.Add('    WHEN 2 THEN ''001''');
    SQL.Add('    ELSE ''997''');
    SQL.Add('END AS COD_CATEGORIA,');
    SQL.Add('');
    SQL.Add('CASE RECEBER.CAIXA');
    SQL.Add('    WHEN 2 THEN ''032''');
    SQL.Add('    ELSE ''997''');
    SQL.Add('END AS COD_SUBCATEGORIA,');
    SQL.Add('');
    SQL.Add('RECEBER.PARCELA AS NUM_PARCELA,');
    SQL.Add('RECEBER.TOTAL_PARCELA AS QTD_PARCELA,');
    SQL.Add('RECEBER.EMPRESA AS COD_LOJA,');
    SQL.Add('RECEBER.CPF_CNPJ AS NUM_CGC,');
    SQL.Add('COALESCE(RECEBER.BORDERO, 0) AS NUM_BORDERO,');
    SQL.Add('RECEBER.NF AS NUM_NF,');
    SQL.Add(''''' AS NUM_SERIE_NF,');
    SQL.Add('CASE WHEN NF.VAL_TOTAL_NF = 0 THEN RECEBER.VALOR ELSE NF.VAL_TOTAL_NF END AS VAL_TOTAL_NF, -- EFETUAR A SOMA');
    SQL.Add('''COBRAN�A: '' || RECEBER.DATACOB || '' | 1 DEVOL: '' || RECEBER.DEVOLUCAOA || '' | 2 DEVOL : '' || RECEBER.DEVOLUCAOB || '' | ''  || RECEBER.OBSERVACAO AS DES_OBSERVACAO,');
    SQL.Add('COALESCE(RECEBER.PDV, 0) AS NUM_PDV,');
    SQL.Add('RECEBER.NOTA AS NUM_CUPOM_FISCAL,');
    SQL.Add('0 AS COD_MOTIVO,');
    SQL.Add('');
    SQL.Add('CASE RECEBER.FORMA_PAGTO');
    SQL.Add('    WHEN 14 THEN (SELECT COALESCE(24000 + CLIENTES.EMPRESA_CONVENIO, 0) FROM CLIENTES WHERE CLIENTES.ID = RECEBER.ID_CADASTRO)');
    SQL.Add('    ELSE 0');
    SQL.Add('END AS COD_CONVENIO,');
    SQL.Add('');
    SQL.Add('0 AS COD_BIN,');
//    SQL.Add('ADM_CARTOES.DESCRITIVO AS DES_BANDEIRA,');
    SQL.Add(' '''' AS DES_BANDEIRA,');
    SQL.Add(''''' AS DES_REDE_TEF,');
    SQL.Add('0 AS VAL_RETENCAO,');
    SQL.Add('0 AS COD_CONDICAO,');
    SQL.Add('');
    SQL.Add('CASE ');
    SQL.Add('    WHEN RECEBER.PAGAMENTO IS NULL THEN NULL');
    SQL.Add('    ELSE RECEBER.PAGAMENTO');
    SQL.Add('END AS DTA_PAGTO,');
    SQL.Add('');
    SQL.Add('RECEBER.DATAHORA_CADASTRO AS DTA_ENTRADA,');
    SQL.Add('');
    SQL.Add(''''' AS NUM_NOSSO_NUMERO,');
    SQL.Add('COALESCE(RECEBER.CODBARRAS, '''') AS COD_BARRA,');
    SQL.Add('''N'' AS FLG_BOLETO_EMIT,');
    SQL.Add(''''' AS NUM_CGC_CPF_TITULAR,');
    SQL.Add(''''' AS DES_TITULAR,');
    SQL.Add('CASE RECEBER.FORMA_PAGTO');
    SQL.Add('    WHEN 11 THEN 0');
    SQL.Add('    ELSE 30');
    SQL.Add('END AS NUM_CONDICAO,');
    SQL.Add('0 AS VAL_CREDITO,');
    SQL.Add('''999'' AS COD_BANCO_PGTO,');
    SQL.Add('''RECEBTO-1'' AS DES_CC,');
    SQL.Add('');
    SQL.Add(' 10000 + RECEBER.ID_CADASTRO AS COD_BANDEIRA,');
    SQL.Add('');
    SQL.Add('');
    SQL.Add(''''' AS DTA_PRORROGACAO,');
    SQL.Add('1 AS NUM_SEQ_FIN,');
    SQL.Add('CASE RECEBER.COBRADOR');
    SQL.Add('    WHEN 1 THEN 3405');
    SQL.Add('    WHEN 2 THEN 3403');
    SQL.Add('    WHEN 3 THEN 3404');
    SQL.Add('    ELSE 0');
    SQL.Add('END AS COD_COBRANCA,');
    SQL.Add('RECEBER.DATACOB AS DTA_COBRANCA,');
    SQL.Add('CASE');
    SQL.Add('    WHEN LENGTH(RECEBER.CODBARRAS) > 0 THEN ''S''');
    SQL.Add('    ELSE ''N''');
    SQL.Add('END AS FLG_ACEITE,');
    SQL.Add('CASE');
    SQL.Add('    WHEN LENGTH(RECEBER.CODBARRAS) = 34 THEN 4 ');
    SQL.Add('    WHEN LENGTH(RECEBER.CODBARRAS) > 34 THEN 1 ');
    SQL.Add('    ELSE 0');
    SQL.Add('END AS TIPO_ACEITE');
    SQL.Add('');
    SQL.Add('FROM');
    SQL.Add('CONTAS RECEBER');
    SQL.Add('LEFT JOIN');
    SQL.Add('ADM_CARTOES  ');
    SQL.Add('ON');
    SQL.Add('RECEBER.ID_CADASTRO = ADM_CARTOES.ID');
    SQL.Add('LEFT JOIN');
    SQL.Add('    (');
    SQL.Add('        SELECT ');
    SQL.Add('            NF,');
    SQL.Add('            TIPO_CADASTRO,');
    SQL.Add('            ID_CADASTRO,');
    SQL.Add('            SUM(VALOR - DESCONTO + ACRESCIMO + CARTORIO + COALESCE(CREDITO, 0)) AS VAL_TOTAL_NF');
    SQL.Add('        FROM ');
    SQL.Add('            CONTAS  ');
    SQL.Add('        WHERE');
    SQL.Add('            CONTAS.TIPO_CONTA = 1');
    SQL.Add('        AND');
    SQL.Add('            CONTAS.EMPRESA = '+ CbxLoja.Text +'');
    SQL.Add('        AND');
    SQL.Add('            CONTAS.TIPO_CADASTRO IN (4) -- Adicionar o filtro de cartoes');
    SQL.Add('        AND');
    SQL.Add('            CONTAS.PARCELA > 0');
    SQL.Add('        AND');
    SQL.Add('            CONTAS.VALOR > 0');
    SQL.Add('        GROUP BY');
    SQL.Add('            NF,');
    SQL.Add('            TIPO_CADASTRO,');
    SQL.Add('            ID_CADASTRO');
    SQL.Add('    ) NF');
    SQL.Add('ON');
    SQL.Add('    RECEBER.NF = NF.NF');
    SQL.Add('AND');
    SQL.Add('    RECEBER.TIPO_CADASTRO = NF.TIPO_CADASTRO');
    SQL.Add('AND');
    SQL.Add('    RECEBER.ID_CADASTRO = NF.ID_CADASTRO        ');
    SQL.Add('WHERE');
    SQL.Add('    RECEBER.TIPO_CONTA = 1');
    SQL.Add('AND');
    SQL.Add('    RECEBER.TIPO_CADASTRO IN (4) -- Adicionar o filtro de cartoes');
    SQL.Add('AND');
    SQL.Add('    RECEBER.PARCELA > 0');

    SQL.Add('AND');
    SQL.Add('    RECEBER.VALOR > 0');


    SQL.Add('AND');
    SQL.Add('    RECEBER.EMPRESA = '+ CbxLoja.Text +' ');

    SQL.Add('AND');
    SQL.Add('    RECEBER.EMISSAO >= '''+FormatDateTime('dd/mm/yyyy',DtpInicial.Date)+''' ');
    SQL.Add('AND');
    SQL.Add('    RECEBER.EMISSAO <= '''+FormatDateTime('dd/mm/yyyy',DtpFinal.Date)+''' ');

    SQL.Add('ORDER BY');
    SQL.Add('    NUM_DOCTO, COD_PARCEIRO');

    Open;

    First;
    NumLinha := 0;
//    codParceiro := 0;
//    numDocto := '';
//    count := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

//      if( (codParceiro = QryPrincipal.FieldByName('COD_PARCEIRO').AsInteger) and (numDocto = QryPrincipal.FieldByName('NUM_DOCTO').AsString) ) then
//      begin
//         inc(count);
//         if( numDocto <> '' ) then
//            Layout.FieldByName('NUM_DOCTO').AsString := numDocto + ' - ' + IntToStr(count)
//         else
//            Layout.FieldByName('NUM_DOCTO').AsString := IntToStr(count);
//      end
//      else
//      begin
//         count := 0;
//         numDocto := QryPrincipal.FieldByName('NUM_DOCTO').AsString;
//         codParceiro := QryPrincipal.FieldByName('COD_PARCEIRO').AsInteger;
//      end;

      Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
      Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime);
      Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);

//      if Aberto = '1' then
//      begin
//        Layout.FieldByName('DTA_QUITADA').AsString := '';
//        Layout.FieldByName('DTA_PAGTO').AsString := '';
//      end
//      else
//      begin
        Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_QUITADA').AsDateTime);
        Layout.FieldByName('DTA_PAGTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_PAGTO').AsDateTime);
//      end;

      Layout.FieldByName('DTA_COBRANCA').AsDateTime:= QryPrincipal.FieldByName('DTA_COBRANCA').AsDateTime;

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');

      Layout.FieldByName('COD_BARRA').AsString := StrRetNums(Layout.FieldByName('COD_BARRA').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarFornecedor;
var
   observacao, email : string;
//   COD_FORNECEDOR : Integer;
//   QryGeraCodigoFornecedor : TSQLQuery;
begin
  inherited;

//  QryGeraCodigoFornecedor := TSQLQuery.Create(FrmProgresso);
//  with QryGeraCodigoFornecedor do
//  begin
//    SQLConnection := ScnBanco;
//
//    SQL.Clear;
//    SQL.Add('ALTER TABLE EMD101 ');
//    SQL.Add('ADD CODIGO_FORNECEDOR INT DEFAULT NULL; ');
//
//    try
//      ExecSQL;
//    except
//    end;
//
//    SQL.Clear;
//    SQL.Add('UPDATE EMD101');
//    SQL.Add('SET CODIGO_FORNECEDOR = :COD_FORNECEDOR ');
//    SQL.Add('WHERE COALESCE(REPLACE(REPLACE(REPLACE(CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') = :NUM_CGC ');
//    SQL.Add('AND NOME NOT LIKE ''%CONS.%''');
//    SQL.Add('AND NOME NOT LIKE ''%CONSUMIDOR%''');
//
//    try
//      ExecSQL;
//    except
//    end;
//
//  end;


  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDOR.COD_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       COALESCE(FORNECEDOR.RAZAO_SOCIAL, FORNECEDOR.NOME_FANTASIA) AS DES_FORNECEDOR,   ');
     SQL.Add('       COALESCE(FORNECEDOR.NOME_FANTASIA, FORNECEDOR.RAZAO_SOCIAL) AS DES_FANTASIA,   ');
     SQL.Add('       FORNECEDOR.CNPJ AS NUM_CGC,   ');
     SQL.Add('       TRIM(COALESCE(REPLACE(REPLACE(FORNECEDOR.INSC_ESTADUAL, ''.'', ''''), ''-'', ''''), ''ISENTO'')) AS NUM_INSC_EST,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN FORNECEDOR.COMPLEMENTO IS NULL OR FORNECEDOR.COMPLEMENTO = '''' THEN COALESCE(FORNECEDOR.ENDERECO, ''A DEFINIR'')   ');
     SQL.Add('           ELSE COALESCE(FORNECEDOR.ENDERECO, ''A DEFINIR'') || ''- '' || COALESCE(FORNECEDOR.COMPLEMENTO, '''')   ');
     SQL.Add('       END AS DES_ENDERECO,   ');
     SQL.Add('       COALESCE(FORNECEDOR.BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,   ');
     SQL.Add('       COALESCE(FORNECEDOR.CIDADE, '''') AS DES_CIDADE,   ');
     SQL.Add('       COALESCE(FORNECEDOR.ESTADO, ''RJ'') AS DES_SIGLA,   ');
     SQL.Add('       COALESCE(FORNECEDOR.CEP, ''1111111'') AS NUM_CEP,   ');
     SQL.Add('       COALESCE(FORNECEDOR.TEL1, '''') AS NUM_FONE,   ');
     SQL.Add('       '''' AS NUM_FAX,   ');
     SQL.Add('       COALESCE(FORNECEDOR.CONTATO, ''A DEFINIR'') AS DES_CONTATO,   ');
     SQL.Add('       0 AS QTD_DIA_CARENCIA,   ');
     SQL.Add('       0 AS NUM_FREQ_VISITA,   ');
     SQL.Add('       0 AS VAL_DESCONTO,   ');
     SQL.Add('       0 AS NUM_PRAZO,   ');
     SQL.Add('       ''N'' AS ACEITA_DEVOL_MER,   ');
     SQL.Add('       ''N'' AS CAL_IPI_VAL_BRUTO,   ');
     SQL.Add('       ''N'' AS CAL_ICMS_ENC_FIN,   ');
     SQL.Add('       ''N'' AS CAL_ICMS_VAL_IPI,   ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,   ');
     SQL.Add('       0 AS COD_FORNECEDOR_ANT,   ');
     SQL.Add('       COALESCE(FORNECEDOR.NUMERO, ''1234'') AS NUM_ENDERECO,   ');
     SQL.Add('       COALESCE(REPLACE(FORNECEDOR.OBS, ASCII_CHAR(13) || ASCII_CHAR(10), ''''), '''' ||''|''|| COALESCE(FORNECEDOR.TEL1, '''') ||''|''|| COALESCE(FORNECEDOR.TEL2, '''')) AS DES_OBSERVACAO,     ');
     SQL.Add('       COALESCE(FORNECEDOR.EMAIL, '''') AS DES_EMAIL,   ');
     SQL.Add('       '''' AS DES_WEB_SITE,   ');
     SQL.Add('       ''N'' AS FABRICANTE,   ');
     SQL.Add('       ''N'' AS FLG_PRODUTOR_RURAL,   ');
     SQL.Add('       0 AS TIPO_FRETE,   ');
     SQL.Add('       ''N'' AS FLG_SIMPLES,   ');
     SQL.Add('       ''N'' AS FLG_SUBSTITUTO_TRIB,   ');
     SQL.Add('       0 AS COD_CONTACCFORN,   ');
     SQL.Add('       ''N'' AS INATIVO,   ');
     SQL.Add('       0 AS COD_CLASSIF,   ');
     SQL.Add('       '''' AS DTA_CADASTRO,   ');
     SQL.Add('       0 AS VAL_CREDITO,   ');
     SQL.Add('       0 AS VAL_DEBITO,   ');
     SQL.Add('       1 AS PED_MIN_VAL,   ');
     SQL.Add('       '''' AS DES_EMAIL_VEND,   ');
     SQL.Add('       COALESCE(FORNECEDOR.SENHA_COTACAO, '''') AS SENHA_COTACAO,   ');
     SQL.Add('       -1 AS TIPO_PRODUTOR,   ');
     SQL.Add('       '''' AS NUM_CELULAR   ');
     SQL.Add('   FROM   ');
     SQL.Add('       FORNECEDOR   ');
     SQL.Add('   WHERE CHAR_LENGTH(FORNECEDOR.CNPJ) >= 14   ');


    Open;

    First;
    NumLinha := 0;
//    COD_FORNECEDOR := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);


//      with QryGeraCodigoFornecedor do
//      begin
//        Inc(COD_FORNECEDOR);
//        Params.ParamByName('COD_FORNECEDOR').Value := COD_FORNECEDOR;
//        Params.ParamByName('NUM_CGC').Value := Layout.FieldByName('NUM_CGC').AsString;
//        Layout.FieldByName('COD_FORNECEDOR').AsInteger := Params.ParamByName('COD_FORNECEDOR').Value;
//        ExecSQL();
//      end;



      //Layout.FieldByName('COD_FORNECEDOR').AsInteger := COD_FORNECEDOR;

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);
      //Layout.FieldByName('NUM_INSC_EST').AsString := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);
      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

//      if QryPrincipal.FieldByName('NUM_INSC_EST').AsString = '0' then
//         Layout.FieldByName('NUM_INSC_EST').AsString := 'ISENTO';
//
//      if QryPrincipal.FieldByName('NUM_INSC_EST').AsString <> 'ISENTO' then
//         Layout.FieldByName('NUM_INSC_EST').AsString := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);


//    if((Layout.FieldByName('COD_FORNECEDOR').AsInteger =  561 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  623 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  773 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  780 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  792 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  794 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  795 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  813 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  828 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  843 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  844 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  886 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  893 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  910 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  911 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  925 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  954 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1029 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1030 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1031 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1032 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1033 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1034 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1035 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1036 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1037 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1038 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1039 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1040 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1041 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1042 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1043 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1044 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1045 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1046 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1047 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1048 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1049 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1050 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1051 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1052 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1066 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1077 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1082 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1099 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1102 )or
//    (Layout.FieldByName('COD_FORNECEDOR').AsInteger =  1125 ))
//  then
//      begin
//        Layout.FieldByName('NUM')
//      end;


      if Length(Layout.FieldByName('NUM_CGC').AsString) > 11 then
      begin
        if not ValidaCGC(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';
      end
      else
        if not ValidaCPF(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';

      Layout.FieldByName('NUM_FONE').AsString := StrRetNums( FieldByName('NUM_FONE').AsString );

      //observacao := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      Layout.FieldByName('DES_EMAIL').AsString := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');
      Layout.FieldByName('DES_EMAIL_VEND').AsString := StrReplace(StrLBReplace(FieldByName('DES_EMAIL_VEND').AsString), '\n', '');


//      if Layout.FieldByName('FLG_PRODUTOR_RURAL').AsString = 'S' then
//      begin
//        if StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString) = '' then
//            Layout.FieldByName('TIPO_PRODUTOR').AsInteger := 0
//        else
//            Layout.FieldByName('TIPO_PRODUTOR').AsInteger := 1
//      end;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
    Close;
  end;
end;

procedure TFrmCampoGrande.GerarGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       SUBSTRING(PRODUTOS.SETOR FROM 1 FOR 2) AS COD_SECAO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN SUBSTRING(PRODUTOS.SETOR FROM 4 FOR 2) = '''' THEN 999   ');
     SQL.Add('           ELSE SUBSTRING(PRODUTOS.SETOR FROM 4 FOR 2)   ');
     SQL.Add('       END AS COD_GRUPO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(GRUPOS.DES_ART, ''A DEFINIR'') AS DES_GRUPO,   ');
     SQL.Add('       0 VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS PRODUTOS   ');
     SQL.Add('   LEFT JOIN SUBARTIGO AS GRUPOS ON GRUPOS.COD_ART = SUBSTRING(PRODUTOS.SETOR FROM 1 FOR 5)   ');
     //SQL.Add('   --WHERE COD_MATERIAL = 7975   ');




    Open;

    First;
    NumLinha := 0;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarInfoNutricionais;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    NUTRICIONAL.ID AS COD_INFO_NUTRICIONAL,');
    SQL.Add('    NUTRICIONAL.DESCRITIVO AS DES_INFO_NUTRICIONAL,');
    SQL.Add('    NUTRICIONAL.QUANTIDADE AS PORCAO,');
    SQL.Add('    NUTRICIONAL.VALOR_CALORICO AS VALOR_CALORICO,');
    SQL.Add('    NUTRICIONAL.CARBOIDRATOS AS CARBOIDRATO,');
    SQL.Add('    NUTRICIONAL.PROTEINA AS PROTEINA,');
    SQL.Add('    NUTRICIONAL.GORDURAS AS GORDURA_TOTAL,');
    SQL.Add('    NUTRICIONAL.GORDURAS_SATURADA AS GORDURA_SATURADA,');
    SQL.Add('    NUTRICIONAL.COLESTEROL AS COLESTEROL,');
    SQL.Add('    NUTRICIONAL.FIBRA_ALIMENTAR AS FIBRA_ALIMENTAR,');
    SQL.Add('    NUTRICIONAL.CALCIO AS CALCIO,');
    SQL.Add('    NUTRICIONAL.FERRO AS FERRO,');
    SQL.Add('    NUTRICIONAL.SODIO AS SODIO,');
    SQL.Add('    (NUTRICIONAL.VALOR_CALORICO * 100) / 2000 AS VD_VALOR_CALORICO,');
    SQL.Add('    (NUTRICIONAL.CARBOIDRATOS * 100) / 300 AS VD_CARBOIDRATO,');
    SQL.Add('    (NUTRICIONAL.PROTEINA * 100) / 75 AS VD_PROTEINA,');
    SQL.Add('    (NUTRICIONAL.GORDURAS * 100) / 55 AS VD_GORDURA_TOTAL,');
    SQL.Add('    (NUTRICIONAL.GORDURAS_SATURADA * 100) / 22 AS VD_GORDURA_SATURADA,');
    SQL.Add('    (NUTRICIONAL.COLESTEROL * 100) / 300 AS VD_COLESTEROL,');
    SQL.Add('    (NUTRICIONAL.FIBRA_ALIMENTAR * 100) / 25 AS VD_FIBRA_ALIMENTAR,');
    SQL.Add('    (NUTRICIONAL.CALCIO * 100) / 1000 AS VD_CALCIO,');
    SQL.Add('    (NUTRICIONAL.FERRO * 100) / 14 AS VD_FERRO,');
    SQL.Add('    (NUTRICIONAL.SODIO * 100) / 2400 AS VD_SODIO,');
    SQL.Add('    NUTRICIONAL.GORDURATRANS AS GORDURA_TRANS,');
    SQL.Add('    0 AS VD_GORDURA_TRANS,');
    SQL.Add('');
    SQL.Add('    CASE NUTRICIONAL.UNIDADE');
    SQL.Add('        WHEN 0 THEN ''G''');
    SQL.Add('        WHEN 1 THEN ''ML''');
    SQL.Add('        WHEN 2 THEN ''UN''');
    SQL.Add('        ELSE ''KG''');
    SQL.Add('    END AS UNIDADE_PORCAO,');
    SQL.Add('');
    SQL.Add('    CASE MED_CASEIRA');
    SQL.Add('        WHEN 25 THEN NUTRICIONAL.MEDIDAI || '' '' || ''PITADA(S)''');
    SQL.Add('        WHEN 6 THEN NUTRICIONAL.MEDIDAI || '' '' || ''PACOTE(S)''');
    SQL.Add('        WHEN 21 THEN NUTRICIONAL.MEDIDAI || '' '' || ''FIL�(S)''');
    SQL.Add('        WHEN 20 THEN NUTRICIONAL.MEDIDAI || '' '' || ''BIFE(S)''');
    SQL.Add('        WHEN 2 THEN NUTRICIONAL.MEDIDAI || '' '' || ''COLHER(ES) DE CH�''');
    SQL.Add('        WHEN 5 THEN NUTRICIONAL.MEDIDAI || '' '' || ''UNIDADE''');
    SQL.Add('        WHEN 24 THEN NUTRICIONAL.MEDIDAI || '' '' || ''PRATO(S) FUNDO(S)''');
    SQL.Add('        WHEN 4 THEN NUTRICIONAL.MEDIDAI || '' '' || ''DE X�CARA(S)''');
    SQL.Add('        WHEN 8 THEN NUTRICIONAL.MEDIDAI || '' '' || ''FATIA(S) FINA(S)''');
    SQL.Add('        WHEN 7 THEN NUTRICIONAL.MEDIDAI || '' '' || ''FATIA(S)''');
    SQL.Add('        WHEN 3 THEN NUTRICIONAL.MEDIDAI || '' '' || ''X�CARA(S)''');
    SQL.Add('        WHEN 15 THEN NUTRICIONAL.MEDIDAI || '' '' || ''COPO(S)''');
    SQL.Add('        WHEN 0 THEN NUTRICIONAL.MEDIDAI || '' '' || ''COLHER(ES) DE SOPA''');
    SQL.Add('        WHEN 16 THEN NUTRICIONAL.MEDIDAI || '' '' || ''POR��O(�ES)''');
    SQL.Add('        WHEN 9 THEN NUTRICIONAL.MEDIDAI || '' '' || ''PEDA�O(S)''');
    SQL.Add('    END AS DES_PORCAO,');
    SQL.Add('    -- '''' AS DES_PORCAO,');
    SQL.Add('');
    SQL.Add('    NUTRICIONAL.MEDIDAI AS PARTE_INTEIRA_MED_CASEIRA,');
    SQL.Add('    MED_CASEIRA AS MED_CASEIRA_UTILIZADA');
    SQL.Add('FROM');
    SQL.Add('    NUTRICIONAL');
    SQL.Add('INNER JOIN');
    SQL.Add('    VALORES_NUTRI VD');
    SQL.Add('ON');
    SQL.Add('    NUTRICIONAL.REFVD = VD.ID');

    Open;

    First;

    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

//      Layout.FieldByName('COD_INFO_NUTRICIONAL').AsString := GerarPLU( Layout.FieldByName('COD_INFO_NUTRICIONAL').AsString );

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarNCM;
var
 count, TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       0 AS COD_NCM,   ');
     SQL.Add('       CASE WHEN COALESCE(NCM.DESCRICAO, ''A DEFINIR'') = '''' THEN ''A DEFINIR'' ELSE COALESCE(NCM.DESCRICAO, ''A DEFINIR'') END AS DES_NCM,   ');
     SQL.Add('       NCMS.NCM AS NUM_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 1 AND PIS_COFINS.CST_ENT = 50 AND PIS_COFINS.CST_SAI = 1 AND NCMS.PIS_COFINS_COD_CREDITO = 0 THEN ''N''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 2 AND PIS_COFINS.CST_ENT = 60 AND PIS_COFINS.CST_SAI = 1 AND NCMS.PIS_COFINS_COD_CREDITO = 101 THEN ''N''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 1 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 2 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 202 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 105 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 108 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 110 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 111 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 113 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 115 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 116 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 117 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 119 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 120 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 121 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 122 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 123 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 124 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 125 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 126 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 127 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 128 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 129 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 130 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 914 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 918 THEN ''S''     ');
     SQL.Add('                   ELSE ''N''     ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 1 AND PIS_COFINS.CST_ENT = 50 AND PIS_COFINS.CST_SAI = 1 AND NCMS.PIS_COFINS_COD_CREDITO = 0 THEN -1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 2 AND PIS_COFINS.CST_ENT = 60 AND PIS_COFINS.CST_SAI = 1 AND NCMS.PIS_COFINS_COD_CREDITO = 101 THEN -1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 1 THEN 1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 2 THEN 1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 202 THEN 1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 105 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 108 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 110 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 111 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 113 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 115 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 116 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 117 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 119 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 120 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 121 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 122 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 123 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 124 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 125 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 126 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 127 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 128 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 129 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 130 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 914 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 918 THEN 0     ');
     SQL.Add('                   ELSE -1    ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(NCMS.PIS_COFINS_COD_CREDITO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN NCMS.CEST = '''' THEN ''9999999''   ');
     SQL.Add('           ELSE COALESCE(NCMS.CEST, ''9999999'')    ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       ''RJ'' AS DES_SIGLA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 3     ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 3      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE IS NULL THEN 3      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''41.67'' THEN 6      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''4'' AND ALIQUO.DES_ALI = ''13%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 41      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''2.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''010'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''55.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''61.11'' THEN 8      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''070'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND NCMS.CST = ''040'' AND NCMS.REDUCAO_BASE IS NULL THEN 1      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND NCMS.CST = ''040'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 1      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND NCMS.CST = ''060'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND NCMS.CST = ''060'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''15'' AND ALIQUO.DES_ALI = ''14%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 39      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 40   ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0'' THEN 40   ');
     SQL.Add('                   ELSE 1     ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 3     ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 3      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE IS NULL THEN 3      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''41.67'' THEN 6      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''4'' AND ALIQUO.DES_ALI = ''13%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 41      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''2.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''010'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''55.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''61.11'' THEN 8      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''070'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND NCMS.CST = ''040'' AND NCMS.REDUCAO_BASE IS NULL THEN 1      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND NCMS.CST = ''040'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 1      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND NCMS.CST = ''060'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND NCMS.CST = ''060'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''15'' AND ALIQUO.DES_ALI = ''14%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 39      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 40   ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0'' THEN 40   ');
     SQL.Add('                   ELSE 1     ');
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS NCMS   ');
     SQL.Add('   LEFT JOIN NCM ON NCM.CODIGO = NCMS.NCM   ');
     SQL.Add('   LEFT JOIN ALIQUO ON ALIQUO.COD_ALI = NCMS.COD_ALI   ');
     SQL.Add('   LEFT JOIN PIS_COFINS ON PIS_COFINS.CODIGO = NCMS.PIS_COFINS_CODIGO   ');



    Open;
    First;

    count := 0;


    NumLinha := 0;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(count);
      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      Layout.FieldByName('NUM_NCM').AsString := StrRetNums(Layout.FieldByName('NUM_NCM').AsString);
      Layout.FieldByName('NUM_CEST').AsString := StrRetNums( Layout.FieldByName('NUM_CEST').AsString );

      Layout.FieldByName('COD_NCM').AsInteger := count;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarNCMUF;
var
 count, TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       0 AS COD_NCM,   ');
     SQL.Add('       CASE WHEN COALESCE(NCM.DESCRICAO, ''A DEFINIR'') = '''' THEN ''A DEFINIR'' ELSE COALESCE(NCM.DESCRICAO, ''A DEFINIR'') END AS DES_NCM,   ');
     SQL.Add('       NCMS.NCM AS NUM_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 1 AND PIS_COFINS.CST_ENT = 50 AND PIS_COFINS.CST_SAI = 1 AND NCMS.PIS_COFINS_COD_CREDITO = 0 THEN ''N''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 2 AND PIS_COFINS.CST_ENT = 60 AND PIS_COFINS.CST_SAI = 1 AND NCMS.PIS_COFINS_COD_CREDITO = 101 THEN ''N''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 1 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 2 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 202 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 105 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 108 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 110 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 111 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 113 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 115 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 116 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 117 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 119 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 120 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 121 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 122 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 123 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 124 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 125 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 126 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 127 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 128 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 129 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 130 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 914 THEN ''S''    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 918 THEN ''S''     ');
     SQL.Add('                   ELSE ''N''     ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 1 AND PIS_COFINS.CST_ENT = 50 AND PIS_COFINS.CST_SAI = 1 AND NCMS.PIS_COFINS_COD_CREDITO = 0 THEN -1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 2 AND PIS_COFINS.CST_ENT = 60 AND PIS_COFINS.CST_SAI = 1 AND NCMS.PIS_COFINS_COD_CREDITO = 101 THEN -1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 1 THEN 1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 2 THEN 1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 5 AND PIS_COFINS.CST_ENT = 70 AND PIS_COFINS.CST_SAI = 4 AND NCMS.PIS_COFINS_COD_CREDITO = 202 THEN 1    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 105 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 108 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 110 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 111 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 113 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 115 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 116 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 117 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 119 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 120 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 121 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 122 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 123 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 124 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 125 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 126 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 127 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 128 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 129 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 130 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 914 THEN 0    ');
     SQL.Add('                   WHEN NCMS.PIS_COFINS_CODIGO = 6 AND PIS_COFINS.CST_ENT = 73 AND PIS_COFINS.CST_SAI = 6 AND NCMS.PIS_COFINS_COD_CREDITO = 918 THEN 0     ');
     SQL.Add('                   ELSE -1    ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(NCMS.PIS_COFINS_COD_CREDITO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN NCMS.CEST = '''' THEN ''9999999''   ');
     SQL.Add('           ELSE COALESCE(NCMS.CEST, ''9999999'')    ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       ''RJ'' AS DES_SIGLA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 3     ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 3      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE IS NULL THEN 3      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''41.67'' THEN 6      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''4'' AND ALIQUO.DES_ALI = ''13%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 41      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''2.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''010'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''55.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''61.11'' THEN 8      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''070'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND NCMS.CST = ''040'' AND NCMS.REDUCAO_BASE IS NULL THEN 1      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND NCMS.CST = ''040'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 1      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND NCMS.CST = ''060'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND NCMS.CST = ''060'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''15'' AND ALIQUO.DES_ALI = ''14%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 39      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 40   ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0'' THEN 40   ');
     SQL.Add('                   ELSE 1     ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 3     ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 3      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE IS NULL THEN 3      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''41.67'' THEN 6      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''4'' AND ALIQUO.DES_ALI = ''13%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 41      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''2.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''010'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''55.00'' THEN 4      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''020'' AND NCMS.REDUCAO_BASE = ''61.11'' THEN 8      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND NCMS.CST = ''070'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND NCMS.CST = ''040'' AND NCMS.REDUCAO_BASE IS NULL THEN 1      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND NCMS.CST = ''040'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 1      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND NCMS.CST = ''060'' AND NCMS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND NCMS.CST = ''060'' AND NCMS.REDUCAO_BASE = ''0.00'' THEN 13      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''15'' AND ALIQUO.DES_ALI = ''14%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 39      ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE IS NULL THEN 40   ');
     SQL.Add('                   WHEN NCMS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND NCMS.CST = ''000'' AND NCMS.REDUCAO_BASE = ''0'' THEN 40   ');
     SQL.Add('                   ELSE 1     ');
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS NCMS   ');
     SQL.Add('   LEFT JOIN NCM ON NCM.CODIGO = NCMS.NCM   ');
     SQL.Add('   LEFT JOIN ALIQUO ON ALIQUO.COD_ALI = NCMS.COD_ALI   ');
     SQL.Add('   LEFT JOIN PIS_COFINS ON PIS_COFINS.CODIGO = NCMS.PIS_COFINS_CODIGO   ');



    Open;
    First;

    count := 0;


    NumLinha := 0;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(count);
      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      Layout.FieldByName('COD_NCM').AsInteger := count;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarNFClientes;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

      Layout.FieldByName('DTA_EMISSAO').AsDateTime := QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime;
      Layout.FieldByName('DTA_ENTRADA').AsDateTime := QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime;

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrLBReplace(FieldByName('DES_OBSERVACAO').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarNFFornec;
var
   TotalCount : integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       CAPA.FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       CAPA.NOTA AS NUM_NF_FORN,   ');
     SQL.Add('       CAPA.SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
     SQL.Add('       '''' AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
     SQL.Add('       CAPA.VALOR_NOTA AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.DATA_NOTA AS DTA_EMISSAO,   ');
     SQL.Add('       CAPA.DATA_CADASTRO AS DTA_ENTRADA,   ');
     SQL.Add('       CAPA.IPI AS VAL_TOTAL_IPI,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       CAPA.FRETE AS VAL_FRETE,   ');
     SQL.Add('       CAPA.ACRESCIMO AS VAL_ACRESCIMO,   ');
     SQL.Add('       CAPA.DESCONTO AS VAL_DESCONTO,   ');
     SQL.Add('       FORNECEDOR.CNPJ AS NUM_CGC,   ');
     SQL.Add('       0 AS VAL_TOTAL_BC,   ');
     SQL.Add('       CAPA.ICMS AS VAL_TOTAL_ICMS,   ');
     SQL.Add('       CAPA.BCI_ST AS VAL_BC_SUBST,   ');
     SQL.Add('       CAPA.SUBST_TRIBUTARIA AS VAL_ICMS_SUBST,   ');
     SQL.Add('       0 AS VAL_FUNRURAL,   ');
     SQL.Add('       CASE WHEN ENTRADA_MERCADORIA.CFOP = 5910 THEN 5 WHEN ENTRADA_MERCADORIA.CFOP = 6910 THEN 5 ELSE 1 END AS COD_PERFIL,   ');
     SQL.Add('       0 AS VAL_DESP_ACESS,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('       COALESCE(CAPA.OBS, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       CAPA.CHAVE_NFE AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTRADA AS CAPA   ');
     SQL.Add('   LEFT JOIN FORNECEDOR ON FORNECEDOR.COD_FORNECEDOR = CAPA.FORNECEDOR   ');
     SQL.Add('   LEFT JOIN ENTRADA_MERCADORIA ON ENTRADA_MERCADORIA.SEQUENCIAL = CAPA.SEQUENCIAL  ');
     SQL.Add('   WHERE CHAR_LENGTH(FORNECEDOR.CNPJ) >= 14   ');
     SQL.Add('   AND CAPA.NOTA <> 98882 ');
     SQL.Add('   AND CAPA.DATA_NOTA >= :INI');
     SQL.Add('   AND CAPA.DATA_NOTA <= :FIM');
//
    ParamByName('INI').AsDate := DtpInicial.Date;
    ParamByName('FIM').AsDate := DtpFinal.Date;


    Open;

    First;

    TotalCount := SetCountTotal(SQL.Text, ParamByName('INI').AsString, ParamByName('FIM').AsString );

    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      //if Layout.FieldByName('DTA_EMISSAO').AsString <> '' then
        Layout.FieldByName('DTA_EMISSAO').AsDateTime := QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime;

      //if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
        Layout.FieldByName('DTA_ENTRADA').AsDateTime := QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime;

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrLBReplace(FieldByName('DES_OBSERVACAO').AsString);

      //Layout.FieldByName('NUM_SERIE_NF').AsString =

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarNFitensClientes;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;


    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);



      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmCampoGrande.GerarNFitensFornec;
var
   fornecedor, nota, serie : string;
   count, TotalCount : integer;

begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(CAPA.FORNECEDOR, FORNECEDOR.COD_FORNECEDOR) AS COD_FORNECEDOR,   ');
     SQL.Add('       CAPA.NOTA AS NUM_NF_FORN,   ');
     SQL.Add('       CAPA.SERIE  AS NUM_SERIE_NF,   ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTOS.COD_MATERIAL) >= 8 THEN PRODUTOS.CODIGO_PRODUTO      ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''UN'' THEN PRODUTOS.COD_MATERIAL      ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''KG'' THEN PRODUTOS.COD_MATERIAL      ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.COD_MATERIAL, ITENS.CODIGO)      ');
     SQL.Add('       END  AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 3        ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 3         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 3         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''41.67'' THEN 6         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''4'' AND ALIQUO.DES_ALI = ''13%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 41         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''2.00'' THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''010'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''55.00'' THEN 4         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''61.11'' THEN 8         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''070'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND PRODUTOS.CST = ''040'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 1         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND PRODUTOS.CST = ''040'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 1         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND PRODUTOS.CST = ''060'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND PRODUTOS.CST = ''060'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''15'' AND ALIQUO.DES_ALI = ''14%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 39         ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 40      ');
     SQL.Add('           WHEN PRODUTOS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0'' THEN 40      ');
     SQL.Add('           ELSE 1        ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       ITENS.QUANTIDADE_POR_CAIXA AS QTD_EMBALAGEM,   ');
     SQL.Add('       ITENS.TOTAL_DE_CAIXAS AS QTD_ENTRADA,   ');
     SQL.Add('       ''UN'' AS DES_UNIDADE,   ');
     SQL.Add('       (ITENS.PRECO_UNITARIO * ITENS.QUANTIDADE_POR_CAIXA) AS VAL_TABELA,   ');
     SQL.Add('       (ITENS.DESCONTO / ITENS.TOTAL_DE_CAIXAS) AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       ITENS.ACRESCIMO AS VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       (ITENS.IPI / ITENS.TOTAL_DE_CAIXAS) AS VAL_IPI_ITEM,   ');
     SQL.Add('       0 AS VAL_SUBST_ITEM,   ');
     SQL.Add('       ITENS.FRETE AS VAL_FRETE_ITEM,   ');
     SQL.Add('       ITENS.ICMS AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       (ITENS.TOTAL_DE_CAIXAS * (PRECO_UNITARIO * QUANTIDADE_POR_CAIXA)) AS VAL_TABELA_LIQ,   ');
     SQL.Add('       FORNECEDOR.CNPJ AS NUM_CGC,   ');
     SQL.Add('       0 AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('               CASE   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''1202'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''1949'' THEN ''1949''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''2102'' THEN ''1202''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''2403'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5101'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5102'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5103'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5104'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5106'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5401'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5402'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5403'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5405'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5908'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5910'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5923'' THEN ''1202''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5929'' THEN ''1949''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''5949'' THEN ''2949''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6101'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6102'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6103'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6105'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6106'' THEN ''1102''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6401'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6403'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6404'' THEN ''1403''   ');
     SQL.Add('                   WHEN ITENS.CFOP = ''6910'' THEN ''2910''   ');
     SQL.Add('                   ELSE ''1102''   ');
     SQL.Add('               END AS CFOP,   ');
     SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
     SQL.Add('       0 AS VAL_TOT_BC_ST,   ');
     SQL.Add('       COALESCE(ITENS.SUBST_TRIBUTARIA, 0) AS VAL_TOT_ST,   ');
     SQL.Add('       1 AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       PRODUTOS.NCM AS NUM_NCM,   ');
     SQL.Add('       COALESCE(ITENS.CODIGO_RAPIDO_STR, '''') AS DES_REFERENCIA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTRADA_MERCADORIA AS ITENS   ');
     SQL.Add('   LEFT JOIN ENTRADA AS CAPA ON CAPA.SEQUENCIAL = ITENS.SEQUENCIAL   ');
     SQL.Add('   LEFT JOIN MATERI AS PRODUTOS ON PRODUTOS.COD_MATERIAL = ITENS.CODIGO   ');
     SQL.Add('   LEFT JOIN ALIQUO ON ALIQUO.COD_ALI = PRODUTOS.COD_ALI   ');
     SQL.Add('   LEFT JOIN FORNECEDOR ON FORNECEDOR.COD_FORNECEDOR = CAPA.FORNECEDOR   ');
     SQL.Add('   WHERE CHAR_LENGTH(FORNECEDOR.CNPJ) >= 14   ');
     SQL.Add('   AND CAPA.NOTA <> 98882 ');
     SQL.Add('   AND CAPA.DATA_NOTA >= :INI  ');
     SQL.Add('   AND CAPA.DATA_NOTA <= :FIM  ');

     //SQL.Add('   ORDER BY ITENS.ORDEM_INCLUSAO ');
//
//

    ParamByName('INI').AsDate := DtpInicial.Date;
    ParamByName('FIM').AsDate := DtpFinal.Date;


    Open;

    First;

    TotalCount := SetCountTotal(SQL.Text, ParamByName('INI').AsString, ParamByName('FIM').AsString );

    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      if( (Layout.FieldByName('COD_FORNECEDOR').AsString = fornecedor) and
          (Layout.FieldByName('NUM_NF_FORN').AsString = nota) and
          (Layout.FieldByName('NUM_SERIE_NF').AsString = serie) ) then
      begin
          inc(count);
      end
      else
      begin
        fornecedor := Layout.FieldByName('COD_FORNECEDOR').AsString;
        nota := Layout.FieldByName('NUM_NF_FORN').AsString;
        serie := Layout.FieldByName('NUM_SERIE_NF').AsString;
        count := 1;
      end;

      Layout.FieldByName('NUM_ITEM').AsInteger := count;
//
      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarProdForn;
var
   TotalCount, NEW_CODPROD : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(PROD_FORN.COD_MATERIAL) >= 8 THEN PROD_FORN.CODIGO_PRODUTO   ');
     SQL.Add('           WHEN PROD_FORN.BALANCA = ''1'' AND PROD_FORN.COD_UNI = ''UN'' THEN PROD_FORN.COD_MATERIAL   ');
     SQL.Add('           WHEN PROD_FORN.BALANCA = ''1'' AND PROD_FORN.COD_UNI = ''KG'' THEN PROD_FORN.COD_MATERIAL   ');
     SQL.Add('           ELSE PROD_FORN.COD_MATERIAL   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PROD_FORN.COD_FORNECEDOR, 0) AS COD_FORNECEDOR,   ');
     SQL.Add('       COALESCE(PROD_FORN.CODIGO_RAPIDO_FORNECEDOR, '''') AS DES_REFERENCIA,   ');
     SQL.Add('       FORNECEDOR.CNPJ AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PROD_FORN.UN_BRUTA = '''' THEN ''UN''   ');
     SQL.Add('           ELSE COALESCE(PROD_FORN.UN_BRUTA, ''UN'')    ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('      ');
     SQL.Add('       PROD_FORN.ITEM_CAIXA AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       1 AS QTD_TROCA,   ');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS PROD_FORN   ');
     SQL.Add('   LEFT JOIN FORNECEDOR ON FORNECEDOR.COD_FORNECEDOR = PROD_FORN.COD_FORNECEDOR   ');
     SQL.Add('   WHERE CHAR_LENGTH(FORNECEDOR.CNPJ) >= 14   ');


    Open;

    First;

    NumLinha := 0;

    NEW_CODPROD := 10000;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
      begin
        Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
      end;

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmCampoGrande.GerarProdLoja;
var
   TotalCount, NEW_CODPROD : integer;
begin
  inherited;

  if FlgAtualizaValVenda then
  begin
    GerarValorVenda;
    Exit;
  end;

  if FlgAtualizaCustoRep then
  begin
    GeraCustoRep;
    Exit;
  end;

  if FlgAtualizaEstoque then
  begin
    GeraEstoqueVenda;
    Exit;
  end;


  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTOS.COD_MATERIAL) >= 8 THEN PRODUTOS.CODIGO_PRODUTO   ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''UN'' THEN PRODUTOS.COD_MATERIAL   ');
     SQL.Add('           WHEN PRODUTOS.BALANCA = ''1'' AND PRODUTOS.COD_UNI = ''KG'' THEN PRODUTOS.COD_MATERIAL   ');
     SQL.Add('           ELSE PRODUTOS.COD_MATERIAL   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       PRODUTOS.PRECO_COMPRA AS VAL_CUSTO_REP,   ');
     SQL.Add('       PRODUTOS.PRECO_VENDA AS VAL_VENDA,   ');
     //SQL.Add('       CASE   ');
     //SQL.Add('           WHEN PRODUTOS.DATA_PROMOCAO2 >= CURRENT_DATE THEN COALESCE(PRODUTOS.PRECO_PROMOCAO, 0)   ');
     //SQL.Add('           ELSE 0   ');
     SQL.Add('       0 AS VAL_OFERTA,   ');
     SQL.Add('       PRODUTOS.EST_ATU AS QTD_EST_VDA,   ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 3     ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 3      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 3      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''41.67'' THEN 6      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''4'' AND ALIQUO.DES_ALI = ''13%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 41      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''2.00'' THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''010'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''55.00'' THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''61.11'' THEN 8      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''070'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND PRODUTOS.CST = ''040'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 1      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND PRODUTOS.CST = ''040'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 1      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND PRODUTOS.CST = ''060'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND PRODUTOS.CST = ''060'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 13      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''15'' AND ALIQUO.DES_ALI = ''14%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 39      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 40   ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0'' THEN 40   ');
     SQL.Add('                   ELSE 1     ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PRODUTOS.MARGEM_BASICA, 0) AS VAL_MARGEM,   ');
     SQL.Add('       1 AS QTD_ETIQUETA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 3     ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 3      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 3      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''3'' AND ALIQUO.DES_ALI = ''12%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''41.67'' THEN 6      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''4'' AND ALIQUO.DES_ALI = ''13%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 41      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''2.00'' THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''010'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6.00'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''55.00'' THEN 4      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''020'' AND PRODUTOS.REDUCAO_BASE = ''61.11'' THEN 8      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''6'' AND ALIQUO.DES_ALI = ''18%'' AND PRODUTOS.CST = ''070'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND PRODUTOS.CST = ''040'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 1      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''12'' AND ALIQUO.DES_ALI = ''I1'' AND PRODUTOS.CST = ''040'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 1      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND PRODUTOS.CST = ''060'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 13      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''13'' AND ALIQUO.DES_ALI = ''F1'' AND PRODUTOS.CST = ''060'' AND PRODUTOS.REDUCAO_BASE = ''0.00'' THEN 13      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''15'' AND ALIQUO.DES_ALI = ''14%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 39      ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE IS NULL THEN 40   ');
     SQL.Add('                   WHEN PRODUTOS.COD_ALI = ''16'' AND ALIQUO.DES_ALI = ''20%'' AND PRODUTOS.CST = ''000'' AND PRODUTOS.REDUCAO_BASE = ''0'' THEN 40   ');
     SQL.Add('                   ELSE 1     ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       ''N'' AS FLG_INATIVO,   ');
     SQL.Add('       PRODUTOS.COD_MATERIAL AS COD_PRODUTO_ANT,   ');
     SQL.Add('       PRODUTOS.NCM AS NUM_NCM,   ');
     SQL.Add('       0 AS TIPO_NCM,   ');
     SQL.Add('       0 AS VAL_VENDA_2,   ');
     SQL.Add('       '''' AS DTA_VALIDA_OFERTA,   ');
     SQL.Add('       PRODUTOS.EST_MIN AS QTD_EST_MINIMO,   ');
     SQL.Add('       NULL AS COD_VASILHAME,   ');
     SQL.Add('       ''N'' AS FORA_LINHA,   ');
     SQL.Add('       0 AS QTD_PRECO_DIF,   ');
     SQL.Add('       0 AS VAL_FORCA_VDA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CEST = '''' THEN ''9999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.CEST, ''9999999'')    ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST,   ');
     SQL.Add('       0 AS PER_FIDELIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI AS PRODUTOS   ');
     SQL.Add('   LEFT JOIN NCM ON NCM.CODIGO = PRODUTOS.NCM   ');
     SQL.Add('   LEFT JOIN ALIQUO ON ALIQUO.COD_ALI = PRODUTOS.COD_ALI   ');
     //SQL.Add('   WHERE PRODUTOS.COD_MATERIAL IN (''7890541642769'', ''7890541642776'', ''7890541642790'', ''7890541915191'')   ');





    Open;
    First;
    NumLinha := 0;
    NEW_CODPROD := 10000;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(NEW_CODPROD);
      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
      begin
        Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
      end;

//      if Layout.FieldByName('COD_PRODUTO_ANT').AsString = '0' then
//      begin
//        Layout.FieldByName('COD_PRODUTO_ANT').AsInteger := NEW_CODPROD;
//      end;

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );

      Layout.FieldByName('COD_PRODUTO_ANT').AsString := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO_ANT').AsString);

      Layout.FieldByName('NUM_NCM').AsString := StrRetNums(Layout.FieldByName('NUM_NCM').AsString);

      Layout.FieldByName('NUM_CEST').AsString := StrRetNums( Layout.FieldByName('NUM_CEST').AsString );

//      Layout.FieldByName('DTA_VALIDA_OFERTA').AsDateTime := FieldByName('DTA_VALIDA_OFERTA').AsDateTime;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
    Close;
  end;
end;

procedure TFrmCampoGrande.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT    ');
     SQL.Add('       PRODUTO.COD_ART AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('       TRIM(COALESCE(PRODUTO.DES_ART, ''A DEFINIR'')) AS DES_PRODUTO_SIMILAR,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       MATERI_GRUPO AS PRODUTO   ');
//     SQL.Add('   LEFT JOIN MATERI_AUX AS PRO_SIMILAR ON PRO_SIMILAR.COD_ART = PRODUTO.GRUPO   ');
//     SQL.Add('   WHERE PRODUTO.GRUPO IS NOT NULL   ');
//     SQL.Add('   AND PRODUTO.GRUPO > 0   ');



    Open;    

    First;
    TotalCont := SetCountTotal(SQL.Text);
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCont);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

end.
