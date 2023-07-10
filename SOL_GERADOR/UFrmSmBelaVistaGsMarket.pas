unit UFrmSmBelaVistaGsMarket;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrmModelo, Data.DBXOracle, Data.DB,
  Data.SqlExpr, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DBXFirebird, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.Provider, Datasnap.DBClient, //dxGDIPlusClasses,
  Math;

type
  TFrmSmBelaVistaGsMarket = class(TFrmModeloSis)
    btnGeraCest: TButton;
    BtnAmarrarCest: TButton;
    CbxLoja: TComboBox;
    lblLoja: TLabel;
    btnGerarEstoqueAtual: TButton;
    btnGeraCustoRep: TButton;
    btnGeraValorVenda: TButton;
    Label11: TLabel;
    Memo1: TMemo;
    procedure btnGeraCestClick(Sender: TObject);
    procedure BtnAmarrarCestClick(Sender: TObject);
    procedure EdtCamBancoExit(Sender: TObject);
    procedure btnGeraValorVendaClick(Sender: TObject);
    procedure btnGeraCustoRepClick(Sender: TObject);
    procedure btnGerarEstoqueAtualClick(Sender: TObject);
    procedure CkbProdLojaClick(Sender: TObject);
    procedure BtnGerarClick(Sender: TObject);
    procedure QryPrincipalAfterOpen(DataSet: TDataSet);
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
    procedure GerarReceitas; Override;

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
  FrmSmBelaVistaGsMarket: TFrmSmBelaVistaGsMarket;
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


procedure TFrmSmBelaVistaGsMarket.GerarProducao;
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

procedure TFrmSmBelaVistaGsMarket.GerarProduto;
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
//    SQL.Add('ALTER TABLE TAB_BARRAS_AUX ');
//    SQL.Add('ADD CODIGO_PRODUTO INT DEFAULT NULL; ');
//
//    try
//      ExecSQL;
//    except
//    end;
//
//    SQL.Clear;
//    SQL.Add('UPDATE PRODUTO_LJ1 ');
//    SQL.Add('SET CODIGO_PRODUTO = :COD_PRODUTO  ');
//    SQL.Add('WHERE COD_BARRA_AUX = :COD_BARRA_PRINCIPAL ');
//    SQL.Add('WHERE ATIVO = ''S'' ');

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

 SQL.Add('            SELECT      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN PB.quantidade = 6 THEN P.CODIGO +  100000      ');
 SQL.Add('                   WHEN PB.quantidade = 8 THEN P.CODIGO +  200000      ');
 SQL.Add('                   WHEN PB.quantidade = 12 THEN P.CODIGO + 300000      ');
 SQL.Add('                   WHEN PB.quantidade = 15 THEN P.CODIGO + 400000      ');
 SQL.Add('                   WHEN PB.quantidade = 18 THEN P.CODIGO + 500000      ');
 SQL.Add('                   WHEN PB.quantidade = 20 THEN P.CODIGO + 600000      ');
 SQL.Add('                   WHEN PB.quantidade = 21 THEN P.CODIGO + 700000      ');
 SQL.Add('                   WHEN PB.quantidade = 30 THEN P.CODIGO + 800000      ');
 SQL.Add('                   WHEN PB.quantidade = 40 THEN P.CODIGO + 900000      ');
 SQL.Add('                   ELSE P.CODIGO      ');
 SQL.Add('               END AS COD_PRODUTO,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN PB.quantidade > 1 THEN PB.barra      ');
 SQL.Add('                   ELSE P.produto      ');
 SQL.Add('               END AS COD_BARRA_PRINCIPAL,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN PB.quantidade > 1 THEN (REPLACE (REPLACE (REPLACE (P.NOMERED, ''Ã'', ''A''), ''É'', ''E''), ''Ç'', ''C'') || '' '' || REPLACE (REPLACE (PB.quantidade, 0, ''''), ''.'', '''') || ''UN'')     ');
 SQL.Add('                   ELSE REPLACE (REPLACE (REPLACE (P.NOMERED, ''Ã'', ''A''), ''É'', ''E''), ''Ç'', ''C'')  ');
 SQL.Add('               END AS DES_REDUZIDA,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN PB.quantidade > 1 THEN (REPLACE (REPLACE (REPLACE (P.NOME, ''Ã'', ''A''), ''É'', ''E''), ''Ç'', ''C'')|| '' '' || REPLACE (REPLACE (PB.quantidade, 0, ''''), ''.'', '''') || ''UN'')     ');
 SQL.Add('                   ELSE REPLACE (REPLACE (REPLACE (P.NOME, ''Ã'', ''A''), ''É'', ''E''), ''Ç'', ''C'')  ');
 SQL.Add('               END AS DES_PRODUTO,       ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN PB.quantidade < 1 THEN 1      ');
 SQL.Add('                   ELSE PB.quantidade      ');
 SQL.Add('               END AS QTD_EMBALAGEM_COMPRA,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN P.UNIDADE <> ''KG'' THEN ''UN''      ');
 SQL.Add('                   ELSE P.UNIDADE      ');
 SQL.Add('               END AS DES_UNIDADE_COMPRA,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN PB.quantidade < 1 THEN 1      ');
 SQL.Add('                   ELSE PB.quantidade      ');
 SQL.Add('               END AS QTD_EMBALAGEM_VENDA,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN P.UNIDADE <> ''KG'' THEN ''UN''      ');
 SQL.Add('                   ELSE P.UNIDADE      ');
 SQL.Add('               END AS DES_UNIDADE_VENDA,      ');
 SQL.Add('               0 AS TIPO_IPI,      ');
 SQL.Add('               0 AS VAL_IPI,      ');
 SQL.Add('               999 AS COD_SECAO,      ');
 SQL.Add('               999 AS COD_GRUPO,      ');
 SQL.Add('               COALESCE (P.GRUPO, 999) AS COD_SUB_GRUPO,                  ');
 SQL.Add('               CASE   ');
 SQL.Add('                   WHEN (P.agrupa IS NULL) OR (P.agrupa = 0) THEN 0   ');
 SQL.Add('                   ELSE P.AGRUPA   ');
 SQL.Add('               END AS COD_PRODUTO_SIMILAR, ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN P.BAL_TIPO = ''P'' THEN ''S''      ');
 SQL.Add('                   WHEN P.BAL_TIPO = ''U'' THEN ''N''      ');
 SQL.Add('                   ELSE ''N''      ');
 SQL.Add('               END AS IPV,      ');
 SQL.Add('               COALESCE (P.BAL_VALIDADE, 0) AS DIAS_VALIDADE,      ');
 SQL.Add('               0 AS TIPO_PRODUTO,      ');
 SQL.Add('               CASE       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''102'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''112'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''302'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''304'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''405'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''411'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''413'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''414'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''415'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''416'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''417'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''418'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''419'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''421'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''422'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''423'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''425'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''427'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''428'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''429'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''430'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''433'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''611'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''612'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''613'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''615'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''616'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''617'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''620'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''621'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''641'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''651'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''661'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''662'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''664'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''666'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''667'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''671'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''672'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''681'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''839'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''71'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''102'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''105'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''108'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''110'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''111'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''113'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''115'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''116'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''117'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''119'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''120'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''121'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''122'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''123'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''124'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''125'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''126'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''127'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''128'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''129'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''130'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''918'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''75'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''75'' AND P.PISNATREC = ''128'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL) THEN ''N''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1'' THEN ''S''   ');
 SQL.Add('      ');
 SQL.Add('                   ELSE ''OO''   ');
 SQL.Add('               END FLG_NAO_PIS_COFINS,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN P.BAL_TIPO <> '''' THEN ''S''      ');
 SQL.Add('                   ELSE ''N''      ');
 SQL.Add('               END FLG_ENVIA_BALANCA,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''999'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''102'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''103'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''112'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''201'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''202'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''302'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''304'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''405'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''411'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''413'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''414'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''415'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''416'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''417'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''418'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''419'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''421'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''422'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''423'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''425'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''427'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''428'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''429'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''430'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''433'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''611'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''612'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''613'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''615'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''616'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''617'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''620'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''621'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''641'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''651'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''661'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''662'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''664'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''666'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''667'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''671'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''672'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''681'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''839'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''71'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''101'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''102'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''101'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''103'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''105'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''108'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''110'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''111'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''113'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''115'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''116'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''117'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''119'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''120'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''121'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''122'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''123'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''124'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''125'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''126'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''127'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''128'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''129'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''130'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''201'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''918'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''75'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''75'' AND P.PISNATREC = ''128'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''101'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''103'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''201'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL)  THEN -1   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN 4   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1''   THEN 1   ');
 SQL.Add('                   ELSE 1000   ');
 SQL.Add('               END AS TIPO_NAO_PIS_COFINS,      ');
 SQL.Add('               0 AS TIPO_EVENTO,      ');
 SQL.Add('               2323 AS COD_ASSOCIADO,      ');
 SQL.Add('               CASE      ');
 SQL.Add('                   WHEN PB.quantidade > 1 THEN P.codigo      ');
 SQL.Add('                   ELSE ''''      ');
 SQL.Add('               END AS DES_OBSERVACAO,      ');
 SQL.Add('               0 AS COD_INFO_NUTRICIONAL,      ');
 SQL.Add('               CASE   ');
 SQL.Add('                   WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL) THEN ''''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN ''101''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1''   THEN ''101''   ');
 SQL.Add('                   ELSE P.PISNATREC   ');
 SQL.Add('                END AS COD_TAB_SPED,   ');
 SQL.Add('               ''N'' AS FLG_ALCOOLICO,      ');
 SQL.Add('               0 AS TIPO_ESPECIE,      ');
 SQL.Add('               0 AS COD_CLASSIF,      ');
 SQL.Add('               1 AS VAL_VDA_PESO_BRUTO,      ');
 SQL.Add('               1 AS VAL_PESO_EMB,      ');
 SQL.Add('               0 AS TIPO_EXPLOSAO_COMPRA,      ');
 SQL.Add('               '''' AS DTA_INI_OPER,      ');
 SQL.Add('               '''' AS DES_PLAQUETA,      ');
 SQL.Add('               '''' AS MES_ANO_INI_DEPREC,      ');
 SQL.Add('               0 AS TIPO_BEM,      ');
 SQL.Add('               0 AS COD_FORNECEDOR,      ');
 SQL.Add('               0 AS NUM_NF,      ');
 SQL.Add('               '''' AS DTA_ENTRADA,      ');
 SQL.Add('               0 AS COD_NAT_BEM,                        ');
 SQL.Add('               0 AS VAL_ORIG_BEM,      ');
 SQL.Add('               REPLACE (REPLACE (REPLACE (P.NOME, ''Ã'', ''A''), ''É'', ''E''), ''Ç'', ''C'') AS DES_PRODUTO_ANT      ');
 SQL.Add('                 ');
 SQL.Add('           FROM PRODUTOS P      ');
 SQL.Add('           INNER JOIN PRODUTOSBARRA PB ON      ');
 SQL.Add('               (P.CODIGO = PB.codigo)      ');
 SQL.Add('           WHERE PB.quantidade >= 1   ');
 SQL.Add('           and P.CODIGO  <= 5   ');










    Open;
    First;
    NumLinha := 0;
//    NEW_CODPROD := 78060;
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
//      Inc(NEW_CODPROD);
      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);


//
//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        with QryGeraCodigoProduto do
//        begin
          //Inc(COD_PROD);
//          Params.ParamByName('COD_PRODUTO').Value := NEW_CODPROD;
          //Params.ParamByName('COD_BARRA_PRINCIPAL').Value := Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString;
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

      Layout.FieldByName('COD_ASSOCIADO').AsString := GerarPLU( Layout.FieldByName('COD_ASSOCIADO').AsString );

      //Alterar a palavra 'KG' para 'kg' no campo DES_REDUZIDA
        Layout.FieldByName('DES_REDUZIDA').AsString :=  StrReplace(UpperCase(Layout.FieldByName('DES_REDUZIDA').AsString), 'KG', 'kg');

      //Substituir Letras Acentuadas
        Layout.FieldByName('DES_REDUZIDA').AsString := StrSubstLtsAct(Layout.FieldByName('DES_REDUZIDA').AsString);
        Layout.FieldByName('DES_PRODUTO').AsString := StrSubstLtsAct(Layout.FieldByName('DES_PRODUTO').AsString);

      if QryPrincipal.FieldByName('DTA_ENTRADA').AsString <> '' then
        Layout.FieldByName('DTA_ENTRADA').AsDateTime := FieldByName('DTA_ENTRADA').AsDateTime;



      Layout.FieldByName('DES_OBSERVACAO').AsString :=  GerarPLU (FieldByName('DES_OBSERVACAO').AsString); ///(c));
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

procedure TFrmSmBelaVistaGsMarket.GerarReceitas;

begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

 SQL.Add('   SELECT DISTINCT   ');
 SQL.Add('       R.codigo AS COD_INFO_RECEITA,   ');
 SQL.Add('       lpad (R.nomered, 15) AS DES_INFO_RECEITA,   ');
 SQL.Add('       CAST (REPLACE (R.ingredientes, '';'', '''') AS VARCHAR(650)) AS DETALHAMENTO   ');
 SQL.Add('   FROM PRODUTOS R   ');
 SQL.Add('   WHERE R.ingredientes IS NOT NULL   ');
 SQL.Add('   ORDER BY R.CODIGO   ');



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

      (*if not PLUValido(Layout.FieldByName('COD_INFO_RECEITA').AsString) then
      begin
        Layout.FieldByName('COD_INFO_RECEITA').AsString := GerarPlu(Copy(Layout.FieldByName('COD_INFO_RECEITA').AsString, 1, Length(Layout.FieldByName('COD_INFO_RECEITA').AsString) - 1));
      end; *)

      //Layout.FieldByName('DETALHAMENTO').AsString := StrReplace(StrLBReplace( StringReplace(FieldByName('DETALHAMENTO').AsString,#$A, '', [rfReplaceAll]) ), '\n', '') ;

//    Layout.FieldByName('DETALHAMENTO').AsString := StrReplace(StrLBReplace( StringReplace(FieldByName('DETALHAMENTO').AsString,#$A, '', [rfReplaceAll]) ), '\n', '') ;
//    texto := StringReplace(StringReplace(StringReplace(Layout.FieldByName('DETALHAMENTO').AsString, #$D#$A, '', [rfReplaceAll]), #$A, '', [rfReplaceAll]), '#$A', '', [rfReplaceAll]);
//    Layout.FieldByName('DETALHAMENTO').AsString := texto;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmBelaVistaGsMarket.GerarScriptAmarrarCEST;
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

procedure TFrmSmBelaVistaGsMarket.QryPrincipalAfterOpen(DataSet: TDataSet);
begin
inherited;
  Memo1.Lines.Add('GERANDO SCRIPT');
  Memo1.Lines.Add(QryPrincipal.SQL.Text);
end;

procedure TFrmSmBelaVistaGsMarket.GerarScriptCEST;
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

procedure TFrmSmBelaVistaGsMarket.GerarSecao;
var
   TotalCount : integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('       G.codigo AS COD_SECAO,   ');
       SQL.Add('       G.nome AS DES_SECAO,   ');
       SQL.Add('       0 AS VAL_META   ');
       SQL.Add('   FROM PRODUTOSGRUPOS G   ');
       SQL.Add('   WHERE G.classe IN (''1'', ''2'', ''3'', ''4'', ''5'', ''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''12'', ''13'', ''14'', ''15'', ''16'')   ');
       SQL.Add('   ORDER BY G.CLASSE ASC   ');



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

procedure TFrmSmBelaVistaGsMarket.GerarSubGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       999 AS COD_SECAO,   ');
       SQL.Add('       999 AS COD_GRUPO,   ');
       SQL.Add('       PG.codigo AS COD_SUB_GRUPO,   ');
       SQL.Add('       PG.nome AS DES_SUB_GRUPO,   ');
       SQL.Add('       0 AS VAL_META,   ');
       SQL.Add('       PG.margem AS VAL_MARGEM_REF,   ');
       SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
       SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
       SQL.Add('   FROM PRODUTOS P   ');
       SQL.Add('   INNER JOIN PRODUTOSGRUPOS PG ON   ');
       SQL.Add('       (PG.codigo = P.grupo)   ');




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

procedure TFrmSmBelaVistaGsMarket.GerarTransportadora;
var
  TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       TRANSP_LJ3.CODIGO AS COD_TRANSPORTADORA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN TRANSP_LJ3.NOME = '''' THEN TRANSP_LJ3.NOME_FANTASIA   ');
     SQL.Add('           ELSE COALESCE(TRANSP_LJ3.NOME, TRANSP_LJ3.NOME_FANTASIA)    ');
     SQL.Add('       END AS DES_TRANSPORTADORA,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(TRANSP_LJ3.CNPJ, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN TRANSP_LJ3.IE = '''' THEN ''ISENTO''   ');
     SQL.Add('           ELSE COALESCE(TRANSP_LJ3.IE, ''ISENTO'')    ');
     SQL.Add('       END  AS NUM_INSC_EST,   ');
     SQL.Add('      ');
     SQL.Add('       TRANSP_LJ3.END_FAT_LOGRADOURO AS DES_ENDERECO,   ');
     SQL.Add('       TRANSP_LJ3.END_FAT_BAIRRO AS DES_BAIRRO,   ');
     SQL.Add('       TRANSP_LJ3.END_FAT_CIDADE AS DES_CIDADE,   ');
     SQL.Add('       TRANSP_LJ3.END_FAT_ESTADO AS DES_SIGLA,   ');
     SQL.Add('       TRANSP_LJ3.END_FAT_CEP AS NUM_CEP,   ');
     SQL.Add('       TRANSP_LJ3.TELEFONE AS NUM_FONE,   ');
     SQL.Add('       TRANSP_LJ3.FAX AS NUM_FAX,   ');
     SQL.Add('       TRANSP_LJ3.NOME AS DES_CONTATO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN TRANSP_LJ3.END_FAT_NUMERO = '''' THEN ''S/N''   ');
     SQL.Add('           ELSE COALESCE(TRANSP_LJ3.END_FAT_NUMERO, ''S/N'')    ');
     SQL.Add('       END AS NUM_ENDERECO,   ');
     SQL.Add('      ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       '''' AS DES_EMAIL,   ');
     SQL.Add('       '''' AS DES_WEB_SITE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PESSOA AS TRANSP_LJ3   ');
     SQL.Add('   WHERE TRANSP_LJ3.TRANSP = ''S''   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT   ');
     SQL.Add('       TRANSP_LJ1.CODIGO AS COD_TRANSPORTADORA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN TRANSP_LJ1.NOME = '''' THEN TRANSP_LJ1.NOME_FANTASIA   ');
     SQL.Add('           ELSE COALESCE(TRANSP_LJ1.NOME, TRANSP_LJ1.NOME_FANTASIA)    ');
     SQL.Add('       END AS DES_TRANSPORTADORA,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(TRANSP_LJ1.CNPJ, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN TRANSP_LJ1.IE = '''' THEN ''ISENTO''   ');
     SQL.Add('           ELSE COALESCE(TRANSP_LJ1.IE, ''ISENTO'')    ');
     SQL.Add('       END  AS NUM_INSC_EST,   ');
     SQL.Add('      ');
     SQL.Add('       TRANSP_LJ1.END_FAT_LOGRADOURO AS DES_ENDERECO,   ');
     SQL.Add('       TRANSP_LJ1.END_FAT_BAIRRO AS DES_BAIRRO,   ');
     SQL.Add('       TRANSP_LJ1.END_FAT_CIDADE AS DES_CIDADE,   ');
     SQL.Add('       TRANSP_LJ1.END_FAT_ESTADO AS DES_SIGLA,   ');
     SQL.Add('       TRANSP_LJ1.END_FAT_CEP AS NUM_CEP,   ');
     SQL.Add('       TRANSP_LJ1.TELEFONE AS NUM_FONE,   ');
     SQL.Add('       TRANSP_LJ1.FAX AS NUM_FAX,   ');
     SQL.Add('       TRANSP_LJ1.NOME AS DES_CONTATO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN TRANSP_LJ1.END_FAT_NUMERO = '''' THEN ''S/N''   ');
     SQL.Add('           ELSE COALESCE(TRANSP_LJ1.END_FAT_NUMERO, ''S/N'')    ');
     SQL.Add('       END AS NUM_ENDERECO,   ');
     SQL.Add('      ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       '''' AS DES_EMAIL,   ');
     SQL.Add('       '''' AS DES_WEB_SITE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PESSOA_LOJA1 AS TRANSP_LJ1   ');
     SQL.Add('   WHERE TRANSP_LJ1.TRANSP = ''S''   ');
     SQL.Add('   AND TRANSP_LJ1.CNPJ NOT IN (   ');
     SQL.Add('       SELECT   ');
     SQL.Add('           PESSOA.CNPJ   ');
     SQL.Add('       FROM   ');
     SQL.Add('           PESSOA   ');
     SQL.Add('       WHERE PESSOA.TRANSP = ''S''   ');
     SQL.Add('   )   ');



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

//      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
//      Layout.FieldByName('DES_EMAIL').AsString := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmBelaVistaGsMarket.GerarValorVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    if CbxLoja.Text = '1' then
    begin

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO.COD AS COD_PRODUTO,   ');
     SQL.Add('       P_LOJA.PRECO_PDV AS VAL_VENDA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM AS P_LOJA ON P_LOJA.COD = PRODUTO.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PRODUTO.COD   ');
     SQL.Add('   WHERE P_LOJA.PRECO_PDV > 0   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS.BARRAS) < 14   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO_LJ2.COD + 2000000 AS COD_PRODUTO,   ');
     SQL.Add('       P_LOJA_LJ2.PRECO_PDV AS VAL_VENDA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM_LJ2 AS P_LOJA_LJ2 ON P_LOJA_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR_LJ2 AS COD_BARRAS_LJ2 ON COD_BARRAS_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   WHERE COD_BARRAS_LJ2.BARRAS NOT IN (SELECT COD_BARRAS.BARRAS FROM SM_CD_ES_PRODUTO_BAR COD_BARRAS)   ');
     SQL.Add('   AND P_LOJA_LJ2.PRECO_PDV > 0   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) >= 8');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) < 14   ');
    end
    else
    begin
      //margem
         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('       PRODUTO.COD AS COD_PRODUTO,   ');
         SQL.Add('       P_LOJA.MARGEM_ATUAL AS VAL_MARGEM   ');
         SQL.Add('   FROM   ');
         SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO   ');
         SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM AS P_LOJA ON P_LOJA.COD = PRODUTO.COD   ');
         SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PRODUTO.COD   ');
         SQL.Add('   WHERE P_LOJA.MARGEM_ATUAL > 0   ');
         SQL.Add('   AND CHAR_LENGTH(COD_BARRAS.BARRAS) < 14   ');
         SQL.Add('      ');
         SQL.Add('   UNION ALL   ');
         SQL.Add('      ');
         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('       PRODUTO_LJ2.COD + 2000000 AS COD_PRODUTO,   ');
         SQL.Add('       P_LOJA_LJ2.MARGEM_ATUAL AS VAL_MARGEM   ');
         SQL.Add('   FROM   ');
         SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2   ');
         SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM_LJ2 AS P_LOJA_LJ2 ON P_LOJA_LJ2.COD = PRODUTO_LJ2.COD   ');
         SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR_LJ2 AS COD_BARRAS_LJ2 ON COD_BARRAS_LJ2.COD = PRODUTO_LJ2.COD   ');
         SQL.Add('   WHERE COD_BARRAS_LJ2.BARRAS NOT IN (SELECT COD_BARRAS.BARRAS FROM SM_CD_ES_PRODUTO_BAR COD_BARRAS)   ');
         SQL.Add('   AND P_LOJA_LJ2.MARGEM_ATUAL > 0   ');
         SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) >= 8');
         SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) < 14   ');
    end;



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
//          COD_PRODUTO := QryPrincipal.FieldByName('COD_PRODUTO').AsString;
          if CbxLoja.Text = '1' then
          begin
            Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_VENDA = '''+QryPrincipal.FieldByName('VAL_VENDA').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' AND COD_LOJA = '+CbxLoja.Text+' ; ');
          end
          else
          begin
            if CbxLoja.Text = 'MARGEM-L1' then
            begin
              Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_MARGEM = '''+QryPrincipal.FieldByName('VAL_MARGEM').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' AND COD_LOJA = 1 ; ');
            end;
            if CbxLoja.Text = 'MARGEM-L2' then
            begin
              Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_MARGEM = '''+QryPrincipal.FieldByName('VAL_MARGEM').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' AND COD_LOJA = 2 ; ');
            end;

          end;


//        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET COD_BARRA_AUX = ''G'+QryPrincipal.FieldByName('VAL_VENDA_2').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');


//        Writeln(Arquivo, 'UPDATE TAB_PRODUTO SET COD_SECAO = '''+QryPrincipal.FieldByName('COD_SECAO').AsString+''' AND COD_GRUPO = '''+QryPrincipal.FieldByName('COD_GRUPO').AsString+''' AND COD_SUB_GRUPO = '''+QryPrincipal.FieldByName('COD_SUB_GRUPO').AsString+''' WHERE COD_PRODUTO = '''+GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString)+''' ; ');


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

procedure TFrmSmBelaVistaGsMarket.GerarVenda;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('        CPI.PRODUTO AS COD_PRODUTO,   ');
       SQL.Add('        1 AS COD_LOJA, --''+CbxLoja.TEXT+''   ');
       SQL.Add('        0 AS IND_TIPO,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN CP.ecf = 1 THEN ''101''   ');
       SQL.Add('           WHEN CP.ecf = 2 THEN ''102''   ');
       SQL.Add('           WHEN CP.ecf = 3 THEN ''103''   ');
       SQL.Add('           WHEN CP.ecf = 4 THEN ''104''   ');
       SQL.Add('           WHEN CP.ecf = 5 THEN ''105''   ');
       SQL.Add('        END AS NUM_PDV,   ');
       SQL.Add('        CPI.quantidade AS QTD_TOTAL_PRODUTO,   ');
       SQL.Add('        CPI.liquido AS VAL_TOTAL_PRODUTO,   ');
       SQL.Add('        CPI.valorun AS VAL_PRECO_VENDA,   ');
       SQL.Add('        0 AS VAL_CUSTO_REP,   ');
       SQL.Add('        CP.DATA AS DTA_SAIDA,   ');
       SQL.Add('      ');
       SQL.Add('        LPAD(extract(month FROM CP.DATA), 2, ''0'') || ''/'' || EXTRACT(year FROM CP.DATA) AS DTA_MENSAL,   ');
       SQL.Add('      ');
       SQL.Add('        CPI.codigo AS NUM_IDENT,   ');
       SQL.Add('        '''' AS COD_EAN,   ');
       SQL.Add('      ');
       SQL.Add('        LPAD(EXTRACT(HOUR FROM CP.EMISSAO), 2, ''0'') || EXTRACT(MINUTE FROM CP.EMISSAO) AS DES_HORA,   ');
       SQL.Add('      ');
       SQL.Add('        0 AS COD_CLIENTE,   ');
       SQL.Add('        1 AS COD_ENTIDADE,   ');
       SQL.Add('        0 AS VAL_BASE_ICMS,   ');
       SQL.Add('        LPAD(CPI.cstb, 3, ''0'') AS DES_SITUACAO_TRIB,   ');
       SQL.Add('        0 AS VAL_ICMS,   ');
       SQL.Add('        CP.nfce AS NUM_CUPOM_FISCAL,   ');
       SQL.Add('        CPI.liquido AS VAL_VENDA_PDV,   ');
       SQL.Add('        1 COD_TRIBUTACAO,   ');
       SQL.Add('        CASE    ');
       SQL.Add('         WHEN CP.situacao = ''C''  THEN ''S''   ');
       SQL.Add('         ELSE ''N''    ');
       SQL.Add('        END AS FLG_CUPOM_CANCELADO,   ');
       SQL.Add('        P.CODNCM AS NUM_NCM,   ');
       SQL.Add('        0 AS COD_TAB_SPED,   ');
       SQL.Add('        ''S'' AS FLG_NAO_PIS_COFINS,   ');
       SQL.Add('      ');
       SQL.Add('        CASE      ');
       SQL.Add('               WHEN P.BAL_TIPO <> '''' THEN ''S''      ');
       SQL.Add('               ELSE ''N''      ');
       SQL.Add('        END AS FLG_ENVIA_BALANCA,   ');
       SQL.Add('      ');
       SQL.Add('        -1 TIPO_NAO_PIS_COFINS,   ');
       SQL.Add('      ');
       SQL.Add('        ''S'' AS FLG_ONLINE,   ');
       SQL.Add('        ''N'' AS FLG_OFERTA,   ');
       SQL.Add('        0 AS COD_ASSOCIADO   ');
       SQL.Add('      ');
       SQL.Add('   FROM ECFVENDAS CP   ');
       SQL.Add('   INNER JOIN ECFVENDASITENS CPI ON   ');
       SQL.Add('       (CPI.codigo = CP.codigo AND CPI.ecf = CP.ecf)   ');
       SQL.Add('   INNER JOIN PRODUTOS P ON   ');
       SQL.Add('           (P.CODIGO = CPI.PRODUTO)    ');
       SQL.Add('   WHERE CP.DATA >= :INI   ');
       SQL.Add('   AND CP.DATA <= :FIM   ');





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

      //if Layout.FieldByName('DTA_SAIDA').AsString = '' then
      //begin
        Layout.FieldByName('DTA_SAIDA').AsDateTime := QryPrincipal.FieldByName('DTA_SAIDA').AsDateTime;
        //ShowMessage('a');
      //end;


      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;


procedure TFrmSmBelaVistaGsMarket.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmBelaVistaGsMarket.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmBelaVistaGsMarket.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmBelaVistaGsMarket.BtnGerarClick(Sender: TObject);
begin
//  inherited;
   if FlgAtualizaValVenda then
   begin
     if CbxLoja.Text = '1' then
     begin
       AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_VALOR_VENDA.TXT' );
     end
     else
     begin
        AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_VALOR_MARGEM.TXT' );
     end;
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
     AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_INSERT-CLIENTE-AUTORIZ.TXT' );
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

procedure TFrmSmBelaVistaGsMarket.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmBelaVistaGsMarket.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmBelaVistaGsMarket.CkbProdLojaClick(Sender: TObject);
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

procedure TFrmSmBelaVistaGsMarket.EdtCamBancoExit(Sender: TObject);
begin
  inherited;
  CriarFB(EdtCamBanco);
end;


procedure TFrmSmBelaVistaGsMarket.GeraCustoRep;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('       R.codigo AS COD_INFO_RECEITA,   ');
         SQL.Add('       lpad (TRIM(R.nomered), 20) AS DES_INFO_RECEITA,   ');
         SQL.Add('       CAST (REPLACE (R.ingredientes, '';'', '''') AS VARCHAR(700)) AS DETALHAMENTO   ');
         SQL.Add('   FROM PRODUTOS R   ');
         SQL.Add('   WHERE R.ingredientes IS NOT NULL   ');
         SQL.Add('   ORDER BY R.CODIGO   ');


    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Inc(NumLinha);

        //COD_PRODUTO := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);
//          COD_PRODUTO := QryPrincipal.FieldByName('COD_PRODUTO').AsString;
        //Layout.FieldByName('DETALHAMENTO').AsString := StrReplace(FieldByName('DETALHAMENTO').AsString, '\n', '') ;
        //Layout.FieldByName('DETALHAMENTO').AsString := StrReplace(StrLBReplace( StringReplace(FieldByName('DETALHAMENTO').AsString,#$A, '', [rfReplaceAll]) ), '\n', '') ;
        Writeln(Arquivo, 'insert into tab_info_receita (cod_info_receita, des_info_receita, detalhamento, usuario, dta_alteracao, dta_cadastro) values ( '+QryPrincipal.FieldByName('COD_INFO_RECEITA').AsString+','''+QryPrincipal.FieldByName('DES_INFO_RECEITA').AsString+''','''+QryPrincipal.FieldByName('DETALHAMENTO').AsString+''', '''', ''30/01/2023'', ''30/01/2023''); ');

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

procedure TFrmSmBelaVistaGsMarket.GeraEstoqueVenda;
var
  NUM_CGC, codTest: string;
  COD_CLI_AUTORIZ: integer;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       C.codigo AS COD_CLIENTE,   ');
     SQL.Add('       1 AS COD_CLIENTE_AUTORIZ,   ');
     SQL.Add('       C.nome AS DES_AUTORIZ,   ');
     SQL.Add('       C.cpf AS NUM_CGC   ');
     SQL.Add('   FROM CLIENTESAUT C   ');

    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Inc(NumLinha);

        NUM_CGC := (QryPrincipal.FieldByName('NUM_CGC').AsString);
        //COD_CLI_AUTORIZ := StrToInt((QryPrincipal.FieldByName('COD_CLIENTE_AUTORIZ').AsString));
        //Inc(COD_CLI_AUTORIZ);
        codTest := IntToStr(NumLinha);

        Writeln(Arquivo,'INSERT INTO TAB_CLIENTE_AUTORIZ (COD_CLIENTE, NUM_CGC_CPF, DES_AUTORIZ, FLG_REQUISICAO, DTA_INCLUSAO, USUARIO, COD_STATUS_CHEQUE, COD_STATUS_CONV, COD_CLIENTE_AUTORIZ) VALUES ('+QryPrincipal.FieldByName('COD_CLIENTE').AsString+','''+NUM_CGC+''','''+QryPrincipal.FieldByName('DES_AUTORIZ').AsString+''',''N'',''01/02/2023'', NULL, NULL, NULL, '+codTest+');' );


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

procedure TFrmSmBelaVistaGsMarket.GerarCest;
var
   TotalCount : integer;
   count : integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('        0 AS COD_CEST,   ');
     SQL.Add('        CASE      ');
     SQL.Add('               WHEN (P.codcest IS NULL) OR (P.codcest = '''') THEN ''9999999''      ');
     SQL.Add('               WHEN (P.codcest = ''0000000'') THEN ''9999999''      ');
     SQL.Add('               ELSE P.codcest      ');
     SQL.Add('        END AS NUM_CEST,      ');
     SQL.Add('        ''A DEFINIR'' AS DES_CEST   ');
     SQL.Add('   FROM PRODUTOS P   ');

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
      Layout.FieldByName('DES_CEST').AsString := StrReplace(StrLBReplace(FieldByName('DES_CEST').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmBelaVistaGsMarket.GerarCliente;
//var
//  QryGeraCodigoCliente : TSQLQuery;
//  CODIGO_CLIENTE : Integer;
begin
  inherited;


  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('        C.CODIGO AS COD_CLIENTE,   ');
       SQL.Add('        C.NOME AS DES_CLIENTE,   ');
       SQL.Add('        --C.CNPJ,   ');
       SQL.Add('        REPLACE (REPLACE (REPLACE (C.CNPJ, ''.'', ''''), ''/'', ''''), ''-'', '''') AS NUM_CGC,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.tipo = ''J'' THEN COALESCE (REPLACE( REPLACE( C.IE, ''.'', ''''), ''-'', ''''), '''')   ');
       SQL.Add('           ELSE ''''   ');
       SQL.Add('        END AS NUM_INSC_EST,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.ENDERECO = '''' THEN ''A DEFINIR''   ');
       SQL.Add('           ELSE C.ENDERECO   ');
       SQL.Add('        END AS DES_ENDERECO,   ');
       SQL.Add('        CASE   ');
       SQL.Add('         WHEN C.BAIRRO = '''' THEN ''A DEFINIR''   ');
       SQL.Add('         ELSE C.BAIRRO   ');
       SQL.Add('        END AS DES_BAIRRO,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.CIDADE = '''' THEN ''BELA VISTA''   ');
       SQL.Add('           ELSE C.CIDADE   ');
       SQL.Add('        END AS DES_CIDADE,   ');
       SQL.Add('        C.UF AS DES_SIGLA,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN (C.CEP = '''') OR (C.CEP = 0)  THEN ''76260000''   ');
       SQL.Add('           ELSE C.CEP   ');
       SQL.Add('        END AS NUM_CEP,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN (C.TELEFONE IS NULL) OR (C.TELEFONE = '''') THEN   ');
       SQL.Add('               CASE   ');
       SQL.Add('                   WHEN (C.TELEFONE1 IS NULL) OR (C.TELEFONE1 = '''') THEN COALESCE (REPLACE (REPLACE (REPLACE (C.CELULAR, ''('', ''''), '')'', ''''), ''-'', ''''), '''')   ');
       SQL.Add('                   ELSE COALESCE (REPLACE (REPLACE (REPLACE (C.TELEFONE1, ''('', ''''), '')'', ''''), ''-'', ''''), '''')   ');
       SQL.Add('               END   ');
       SQL.Add('           ELSE COALESCE (REPLACE (REPLACE (REPLACE (C.TELEFONE, ''('', ''''), '')'', ''''), ''-'', ''''), '''')   ');
       SQL.Add('        END AS NUM_FONE,   ');
       SQL.Add('        '''' AS NUM_FAX,   ');
       SQL.Add('        C.NOME AS DES_CONTATO,   ');
       SQL.Add('        0 AS FLG_SEXO,   ');
       SQL.Add('        0 AS VAL_LIMITE_CRETID,   ');
       SQL.Add('        COALESCE (C.LIMITE, 0) AS VAL_LIMITE_CONV,   ');
       SQL.Add('        0 AS VAL_DEBITO,   ');
       SQL.Add('        0 AS VAL_RENDA,   ');
       SQL.Add('        99999 AS COD_CONVENIO,   ');
       SQL.Add('        0 AS COD_STATUS_PDV,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.TIPO = ''F'' THEN ''N''   ');
       SQL.Add('           ELSE ''S''   ');
       SQL.Add('        END AS FLG_EMPRESA,   ');
       SQL.Add('        ''N'' AS FLG_CONVENIO,   ');
       SQL.Add('        ''N'' AS MICRO_EMPRESA,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.DATA IS NULL THEN ''01/01/1899''   ');
       SQL.Add('           ELSE LPAD(extract(day FROM C.DATA), 2, ''0'') || ''/'' || LPAD(extract(month FROM C.DATA), 2, ''0'') || ''/'' || EXTRACT(year FROM C.DATA)   ');
       SQL.Add('        END AS DTA_CADASTRO,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.NUMERO = 0 THEN ''S/N''   ');
       SQL.Add('           ELSE C.NUMERO   ');
       SQL.Add('        END AS NUM_ENDERECO,   ');
       SQL.Add('        COALESCE (REPLACE (REPLACE (C.rg, ''SSP'', ''''), ''SSP/MS'', ''''), '''') AS NUM_RG,   ');
       SQL.Add('        0 AS FLG_EST_CIVIL,   ');
       SQL.Add('        COALESCE (REPLACE (REPLACE (REPLACE (C.CELULAR, ''('', ''''), '')'', ''''), ''-'', ''''), '''') AS NUM_CELULAR,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.DATAATUALIZ IS NULL THEN ''01/02/2023''   ');
       SQL.Add('           ELSE COALESCE (LPAD(extract(day FROM C.DATAATUALIZ), 2, ''0'') || ''/'' || LPAD(extract(month FROM C.DATAATUALIZ), 2, ''0'') || ''/'' || EXTRACT(year FROM C.DATAATUALIZ), ''01.02.2023'')   ');
       SQL.Add('        END AS DTA_ALTERACAO,   ');
       SQL.Add('        '''' AS DES_OBSERVACAO,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.COMPLEMENTO IS NULL THEN ''A DEFINIR''   ');
       SQL.Add('           ELSE C.COMPLEMENTO   ');
       SQL.Add('        END AS DES_COMPLEMENTO,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.EMAIL IS NULL THEN ''''   ');
       SQL.Add('           ELSE C.EMAIL   ');
       SQL.Add('        END AS DES_EMAIL,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN (C.FANTASIA IS NULL) OR (C.FANTASIA = '''')  THEN C.NOME   ');
       SQL.Add('           ELSE COALESCE (C.FANTASIA, C.NOME)   ');
       SQL.Add('        END AS DES_FANTASIA,   ');
       SQL.Add('        COALESCE (LPAD(extract(day FROM C.DATANASCIM), 2, ''0'') || ''/'' || LPAD(extract(month FROM C.DATANASCIM), 2, ''0'') || ''/'' || EXTRACT(year FROM C.DATANASCIM), ''01/01/1899'')  AS DTA_NASCIMENTO,   ');
       SQL.Add('        COALESCE (C.PAI, '''') AS DES_PAI,   ');
       SQL.Add('        COALESCE (C.MAE, '''') AS DES_MAE,   ');
       SQL.Add('        COALESCE (C.CONJUGE, '''') AS DES_CONJUGE,   ');
       SQL.Add('        '''' AS NUM_CPF_CONJUGE,   ');
       SQL.Add('        0 AS VAL_DEB_CONV,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.INATIVO = ''S'' THEN ''S''   ');
       SQL.Add('           ELSE ''N''   ');
       SQL.Add('        END AS INATIVO,   ');
       SQL.Add('        0 AS DES_MATRICULA,   ');
       SQL.Add('        ''N'' AS NUM_CGC_ASSOCIADO,   ');
       SQL.Add('        ''N'' AS FLG_PROD_RURAL,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN C.BLOQUEADO = ''S'' THEN ''1''   ');
       SQL.Add('           ELSE ''0''   ');
       SQL.Add('        END AS COD_STATUS_PDV_CONV,   ');
       SQL.Add('        ''N'' AS FLG_ENVIA_CODIGO,   ');
       SQL.Add('        NULL  DTA_NASC_CONJUGE,   ');
       SQL.Add('        0 AS COD_CLASSIF   ');
       SQL.Add('      ');
       SQL.Add('   FROM CLIENTES C   ');



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

       //Substituir Letras Acentuadas
        Layout.FieldByName('DES_CLIENTE').AsString := StrSubstLtsAct(Layout.FieldByName('DES_CLIENTE').AsString);
        Layout.FieldByName('DES_FANTASIA').AsString := StrSubstLtsAct(Layout.FieldByName('DES_FANTASIA').AsString);

      //if StrRetNums(Layout.FieldByName('NUM_RG').AsString) = '' then
        //Layout.FieldByName('NUM_RG').AsString := ''
      //else
        //Layout.FieldByName('NUM_RG').AsString := StrRetNums(Layout.FieldByName('NUM_RG').AsString);

      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

      //if QryPrincipal.FieldByName('NUM_INSC_EST').AsString <> 'ISENTO' then
         //Layout.FieldByName('NUM_INSC_EST').AsString := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);

      if QryPrincipal.FieldByName('DTA_CADASTRO').AsString <> '' then
        Layout.FieldByName('DTA_CADASTRO').AsString := FieldByName('DTA_CADASTRO').AsString;

      if QryPrincipal.FieldByName('DTA_ALTERACAO').AsString <> '' then
        Layout.FieldByName('DTA_ALTERACAO').AsString := FieldByName('DTA_ALTERACAO').AsString;

      if QryPrincipal.FieldByName('DTA_NASCIMENTO').AsString <> '' then
        Layout.FieldByName('DTA_NASCIMENTO').AsString := FieldByName('DTA_NASCIMENTO').AsString;



      //Layout.FieldByName('NUM_FONE').AsString := StrRetNums( FieldByName('NUM_FONE').AsString );

      if Layout.FieldByName('FLG_EMPRESA').AsString = 'S' then
      begin
        if not ValidaCGC(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';
      end
      else
        if not ValidaCpf(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
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

procedure TFrmSmBelaVistaGsMarket.GerarCodigoBarras;
var
 count, NEW_CODPROD, TotalCount : Integer;
 cod_antigo, codbarras : string;
 QryGeraCodigoProduto : TSQLQuery;

begin
  inherited;


  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('    SELECT DISTINCT   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PB.quantidade = 6 THEN PB.CODIGO  + 100000   ');
     SQL.Add('           WHEN PB.quantidade = 8 THEN PB.CODIGO  + 200000   ');
     SQL.Add('           WHEN PB.quantidade = 12 THEN PB.CODIGO + 300000   ');
     SQL.Add('           WHEN PB.quantidade = 15 THEN PB.CODIGO + 400000   ');
     SQL.Add('           WHEN PB.quantidade = 18 THEN PB.CODIGO + 500000   ');
     SQL.Add('           WHEN PB.quantidade = 20 THEN PB.CODIGO + 600000   ');
     SQL.Add('           WHEN PB.quantidade = 21 THEN PB.CODIGO + 700000   ');
     SQL.Add('           WHEN PB.quantidade = 30 THEN PB.CODIGO + 800000   ');
     SQL.Add('           WHEN PB.quantidade = 40 THEN PB.CODIGO + 900000   ');
     SQL.Add('           ELSE PB.CODIGO   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('       PB.barra AS COD_EAN      ');
     SQL.Add('   FROM produtosbarra PB   ');
     SQL.Add('   WHERE PB.quantidade >= 1   ');


    Open;
    First;
    NumLinha := 0;
    TotalCount := SetCountTotal(SQL.Text);
//    NEW_CODPROD := 78060;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      //Inc(NEW_CODPROD);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);



//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        with QryGeraCodigoProduto do
//        begin
//          Inc(NEW_CODPROD);
//          ShowMessage(IntToStr(NEW_CODPROD));
//          Params.ParamByName('COD_PRODUTO').Value := NEW_CODPROD;
//          Params.ParamByName('COD_EAN').Value := Layout.FieldByName('COD_EAN').AsString;
//          Layout.FieldByName('COD_PRODUTO').AsInteger := Params.ParamByName('COD_PRODUTO').Value;
//          ExecSQL();
//        end;
//      end;

//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
//      end;


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

procedure TFrmSmBelaVistaGsMarket.GerarComposicao;
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

procedure TFrmSmBelaVistaGsMarket.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;


     SQL.Add('   SELECT   ');
     SQL.Add('           C.codigo AS COD_CLIENTE,   ');
     SQL.Add('           30 AS NUM_CONDICAO,   ');
     SQL.Add('           2 AS COD_CONDICAO,   ');
     SQL.Add('           1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM CLIENTES C   ');

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

procedure TFrmSmBelaVistaGsMarket.GerarCondPagForn;
//var
//  COD_FORNECEDOR : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT    ');
     SQL.Add('       F.CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       F.CNPJ AS NUM_CGC   ');
     SQL.Add('      ');
     SQL.Add('   FROM FORNECEDORES F   ');


    Open;

    First;
    TotalCont := SetCountTotal(SQL.Text);
    NumLinha := 0;
//    COD_FORNECEDOR := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCont);

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

procedure TFrmSmBelaVistaGsMarket.GerarDecomposicao;
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

procedure TFrmSmBelaVistaGsMarket.GerarDivisaoForn;
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

procedure TFrmSmBelaVistaGsMarket.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmBelaVistaGsMarket.GerarFinanceiroPagar(Aberto: String);
var
   TotalCount, novo_nr_documento : Integer;
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
         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('        1 AS TIPO_PARCEIRO,   ');
         SQL.Add('        COALESCE (FINCAPA.transac, 0) AS COD_PARCEIRO,   ');
         SQL.Add('        0 AS TIPO_CONTA,   ');
         SQL.Add('        8 AS COD_ENTIDADE,   ');
         SQL.Add('        CASE   ');
         SQL.Add('           WHEN ((FINCAPA.documento = '''') OR (FINCAPA.documento = ''0'')) THEN FINCAPA.codigo   ');
         SQL.Add('           WHEN FINCAPA.parcelas > 1 THEN COALESCE (FINCAPA.documento , FINCAPA.codigo) || ''/'' || FINPARC.parcela   ');
         SQL.Add('           ELSE COALESCE (FINCAPA.documento , FINCAPA.codigo)   ');
         SQL.Add('        END AS NUM_DOCTO,   ');
         SQL.Add('        999 AS COD_BANCO,      ');
         SQL.Add('        '''' AS DES_BANCO,   ');
         SQL.Add('        LPAD(extract(day FROM FINCAPA.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINCAPA.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FINCAPA.data) AS DTA_EMISSAO,   ');
         SQL.Add('        LPAD(extract(day FROM FINPARC.vencimento), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINPARC.vencimento), 2, ''0'') || ''/'' || EXTRACT(year FROM FINPARC.vencimento) AS DTA_VENCIMENTO,   ');
         SQL.Add('        FINPARC.valor AS VAL_PARCELA,   ');
         SQL.Add('        0 AS VAL_JUROS,   ');
         SQL.Add('        0 AS VAL_DESCONTO,   ');
         SQL.Add('        ''N'' AS FLG_QUITADO,   ');
         SQL.Add('        '''' AS DTA_QUITADA,   ');
         SQL.Add('        002 AS COD_CATEGORIA,   ');
         SQL.Add('        002 AS COD_SUBCATEGORIA,   ');
         SQL.Add('        FINPARC.parcela AS NUM_PARCELA,      ');
         SQL.Add('        FINCAPA.parcelas AS QTD_PARCELA,   ');
         SQL.Add('        1 AS COD_LOJA,   ');
         SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( F.cnpj, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
         SQL.Add('        0 AS NUM_BORDERO,      ');
         SQL.Add('        '''' AS NUM_NF,      ');
         SQL.Add('        0 AS NUM_SERIE_NF,      ');
         SQL.Add('        FINCAPA.valor AS VAL_TOTAL_NF,   ');
         SQL.Add('        '''' AS DES_OBSERVACAO,      ');
         SQL.Add('        0 AS NUM_PDV,   ');
         SQL.Add('        '''' AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('        0 AS COD_MOTIVO,      ');
         SQL.Add('        0 AS COD_CONVENIO,   ');
         SQL.Add('        0 AS COD_BIN,      ');
         SQL.Add('        '''' AS DES_BANDEIRA,      ');
         SQL.Add('        '''' AS DES_REDE_TEF,      ');
         SQL.Add('        0 AS VAL_RETENCAO,      ');
         SQL.Add('        0 AS COD_CONDICAO,      ');
         SQL.Add('        '''' AS DTA_PAGTO,   ');
         SQL.Add('        LPAD(extract(day FROM FINCAPA.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINCAPA.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FINCAPA.data) AS DTA_ENTRADA,   ');
         SQL.Add('        '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('        '''' AS COD_BARRA,   ');
         SQL.Add('        ''N'' AS FLG_BOLETO_EMIT,      ');
         SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( F.cnpj, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('        COALESCE (F.nome, '''') AS DES_TITULAR,   ');
         SQL.Add('        30 AS NUM_CONDICAO,   ');
         SQL.Add('        0 AS VAL_CREDITO,      ');
         SQL.Add('        999 AS COD_BANCO_PGTO,   ');
         SQL.Add('        ''PAGTO'' AS DES_CC,   ');
         SQL.Add('        0 AS COD_BANDEIRA,   ');
         SQL.Add('        '''' AS DTA_PRORROGACAO,   ');
         SQL.Add('        1 AS NUM_SEQ_FIN,   ');
         SQL.Add('        0 AS COD_COBRANCA,   ');
         SQL.Add('        '''' AS DTA_COBRANCA,   ');
         SQL.Add('        ''N'' AS FLG_ACEITE,   ');
         SQL.Add('        0 AS TIPO_ACEITE   ');
         SQL.Add('   FROM DESABER A   ');
         SQL.Add('   INNER JOIN DESPESAS FINCAPA ON   ');
         SQL.Add('       (FINCAPA.CODIGO = A.CODIGO)   ');
         SQL.Add('   INNER JOIN DESPESASPARC FINPARC  ON   ');
         SQL.Add('       (FINPARC.codigo = FINCAPA.codigo)   ');
         SQL.Add('   INNER JOIN FORNECEDORES F ON   ');
         SQL.Add('       (F.codigo = FINCAPA.transac)   ');
         SQL.Add('   WHERE NOT EXISTS (SELECT* FROM DESPESASBX BX WHERE BX.codigo = FINPARC.codigo AND BX.parcela = FINPARC.parcela)   ');



      end
      else
      begin
        //QUITADO
         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('        1 AS TIPO_PARCEIRO,   ');
         SQL.Add('        COALESCE (FINCAPA.transac, 0) AS COD_PARCEIRO,   ');
         SQL.Add('        0 AS TIPO_CONTA,   ');
         SQL.Add('        8 AS COD_ENTIDADE,   ');
         SQL.Add('        CASE   ');
         SQL.Add('           WHEN ((FINCAPA.parcelas > 1)OR (FIN.baixa > 1 )) THEN COALESCE (FINCAPA.documento , FIN.codigo) || ''/'' || FIN.baixa   ');
         SQL.Add('           WHEN ((FINCAPA.documento = '''') or (FINCAPA.documento = ''0'')) THEN FIN.codigo   ');
         SQL.Add('           ELSE COALESCE (FINCAPA.documento , FIN.codigo)   ');
         SQL.Add('        END AS NUM_DOCTO,   ');
         SQL.Add('        999 AS COD_BANCO,      ');
         SQL.Add('        '''' AS DES_BANCO,   ');
         SQL.Add('        LPAD(extract(day FROM FINCAPA.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINCAPA.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FINCAPA.data) AS DTA_EMISSAO,   ');
         SQL.Add('        LPAD(extract(day FROM FINPARC.vencimento), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINPARC.vencimento), 2, ''0'') || ''/'' || EXTRACT(year FROM FINPARC.vencimento) AS DTA_VENCIMENTO,   ');
         SQL.Add('        FINPARC.valor AS VAL_PARCELA,   ');
         SQL.Add('        FIN.juros AS VAL_JUROS,   ');
         SQL.Add('        FIN.desconto+FIN.abatimento AS VAL_DESCONTO,   ');
         SQL.Add('        ''S'' AS FLG_QUITADO,   ');
         SQL.Add('        LPAD(extract(day FROM FIN.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FIN.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FIN.data) AS DTA_QUITADA,   ');
         SQL.Add('        002 AS COD_CATEGORIA,   ');
         SQL.Add('        002 AS COD_SUBCATEGORIA,   ');
         SQL.Add('        FINPARC.parcela AS NUM_PARCELA,   ');
         SQL.Add('        1 AS QTD_PARCELA,   ');
         SQL.Add('        1 AS COD_LOJA,      ');
         SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( F.cnpj, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
         SQL.Add('        0 AS NUM_BORDERO,      ');
         SQL.Add('        '''' AS NUM_NF,      ');
         SQL.Add('        0 AS NUM_SERIE_NF,      ');
         SQL.Add('        FINCAPA.valor AS VAL_TOTAL_NF,   ');
         SQL.Add('        '''' AS DES_OBSERVACAO,      ');
         SQL.Add('        0 AS NUM_PDV,   ');
         SQL.Add('        '''' AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('        0 AS COD_MOTIVO,      ');
         SQL.Add('        0 AS COD_CONVENIO,   ');
         SQL.Add('        0 AS COD_BIN,      ');
         SQL.Add('        '''' AS DES_BANDEIRA,      ');
         SQL.Add('        '''' AS DES_REDE_TEF,      ');
         SQL.Add('        0 AS VAL_RETENCAO,      ');
         SQL.Add('        0 AS COD_CONDICAO,      ');
         SQL.Add('        LPAD(extract(day FROM FIN.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FIN.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FIN.data) AS DTA_PAGTO,   ');
         SQL.Add('        LPAD(extract(day FROM FINCAPA.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINCAPA.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FINCAPA.data) AS DTA_ENTRADA,   ');
         SQL.Add('        '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('        '''' AS COD_BARRA,   ');
         SQL.Add('        ''N'' AS FLG_BOLETO_EMIT,      ');
         SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( F.cnpj, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('        COALESCE (F.nome, '''') AS DES_TITULAR,   ');
         SQL.Add('        30 AS NUM_CONDICAO,   ');
         SQL.Add('        0 AS VAL_CREDITO,      ');
         SQL.Add('        999 AS COD_BANCO_PGTO,   ');
         SQL.Add('        ''PAGTO'' AS DES_CC,   ');
         SQL.Add('        0 AS COD_BANDEIRA,   ');
         SQL.Add('        '''' AS DTA_PRORROGACAO,   ');
         SQL.Add('        1 AS NUM_SEQ_FIN,   ');
         SQL.Add('        0 AS COD_COBRANCA,   ');
         SQL.Add('        '''' AS DTA_COBRANCA,   ');
         SQL.Add('        ''N'' AS FLG_ACEITE,   ');
         SQL.Add('        0 AS TIPO_ACEITE   ');
         SQL.Add('   FROM DESPESASBX FIN   ');
         SQL.Add('   INNER JOIN DESPESASPARC FINPARC ON   ');
         SQL.Add('       (FINPARC.codigo = FIN.codigo AND FINPARC.parcela = FIN.parcela)   ');
         SQL.Add('   INNER JOIN DESPESAS FINCAPA ON   ');
         SQL.Add('       (FINCAPA.codigo = FINPARC.codigo)   ');
         SQL.Add('   INNER JOIN FORNECEDORES F ON   ');
         SQL.Add('       (F.codigo = FINCAPA.transac)   ');
         SQL.Add('   WHERE FINCAPA.data >= :INI   ');
         SQL.Add('   AND FINCAPA.data <= :FIM  ');

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
    novo_nr_documento := 999500;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(novo_nr_documento);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

        Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

        if Layout.FieldByName('FLG_QUITADO').AsString = 'N' then
        begin
            if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
            begin
                Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
            end;
            Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime);
            Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);

            if Layout.FieldByName('DTA_QUITADA').AsString <> '' then
            begin
              Layout.FieldByName('DTA_QUITADA').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_QUITADA').AsDateTime);
            end;

            if Layout.FieldByName('DTA_PAGTO').AsString <> '' then
            begin
              Layout.FieldByName('DTA_PAGTO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_PAGTO').AsDateTime);
            end;
        end
        else
        begin
            if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
            begin
                Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
            end;
            Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime);
            Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);

//            if Layout.FieldByName('DTA_QUITADA').AsString = '' then
//            begin
//               Layout.FieldByName('DTA_QUITADA').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);
//            end
//            else
//            begin
              Layout.FieldByName('DTA_QUITADA').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_QUITADA').AsDateTime);
//            end;

            if Layout.FieldByName('DTA_PAGTO').AsString = '' then
            begin
               Layout.FieldByName('DTA_PAGTO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);
            end
            else
            begin
              Layout.FieldByName('DTA_PAGTO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_PAGTO').AsDateTime);
            end;
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

procedure TFrmSmBelaVistaGsMarket.GerarFinanceiroReceber(Aberto: String);
var
   TotalCount : Integer;
   cgc : string;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       if Aberto = '1' then
      begin
      //ABERTO
           SQL.Add('   SELECT DISTINCT   ');
           SQL.Add('        0 AS TIPO_PARCEIRO,         ');
           SQL.Add('        COALESCE (FINCAPA.tomador, 0) AS COD_PARCEIRO,      ');
           SQL.Add('        1 AS TIPO_CONTA,         ');
           SQL.Add('        CASE      ');
           SQL.Add('           WHEN FINCAPA.tipo = ''CP'' THEN 3      ');
           SQL.Add('           ELSE 4      ');
           SQL.Add('        END AS COD_ENTIDADE,      ');
           SQL.Add('        CASE   ');
           SQL.Add('           WHEN ((FINCAPA.documento = '''') OR (FINCAPA.documento = ''0'')) THEN FINCAPA.codigo   ');
           SQL.Add('           WHEN FINCAPA.parcelas > 1 THEN COALESCE (FINCAPA.documento , FINCAPA.codigo) || ''/'' || FINPARC.parcela   ');
           SQL.Add('           ELSE COALESCE (FINCAPA.documento , FINCAPA.codigo)   ');
           SQL.Add('        END AS NUM_DOCTO,      ');
           SQL.Add('        999 AS COD_BANCO,         ');
           SQL.Add('        ''RECEBTO'' AS DES_BANCO,      ');
           SQL.Add('        LPAD(extract(day FROM FINCAPA.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINCAPA.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FINCAPA.data) AS DTA_EMISSAO,      ');
           SQL.Add('        LPAD(extract(day FROM FINPARC.vencimento), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINPARC.vencimento), 2, ''0'') || ''/'' || EXTRACT(year FROM FINPARC.vencimento) AS DTA_VENCIMENTO,      ');
           SQL.Add('        FINPARC.valor - COALESCE(BX.valor, 0) AS VAL_PARCELA,   ');
           SQL.Add('        0 AS VAL_JUROS,      ');
           SQL.Add('        0 AS VAL_DESCONTO,      ');
           SQL.Add('        ''N'' AS FLG_QUITADO,   ');
           SQL.Add('        '''' AS DTA_QUITADA,   ');
           SQL.Add('        001 AS COD_CATEGORIA,         ');
           SQL.Add('        001 AS COD_SUBCATEGORIA,         ');
           SQL.Add('        FINPARC.parcela AS NUM_PARCELA,      ');
           SQL.Add('        FINCAPA.parcelas AS QTD_PARCELA,   ');
           SQL.Add('        1 AS COD_LOJA,         ');
           SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( C.cnpj, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
           SQL.Add('        0 AS NUM_BORDERO,         ');
           SQL.Add('        '''' AS NUM_NF,         ');
           SQL.Add('        0 AS NUM_SERIE_NF,         ');
           SQL.Add('        FINCAPA.valor AS VAL_TOTAL_NF,      ');
           SQL.Add('        '''' AS DES_OBSERVACAO,         ');
           SQL.Add('        101 AS NUM_PDV,      ');
           SQL.Add('        '''' AS NUM_CUPOM_FISCAL,      ');
           SQL.Add('        0 AS COD_MOTIVO,         ');
           SQL.Add('        99999 AS COD_CONVENIO,      ');
           SQL.Add('        0 AS COD_BIN,         ');
           SQL.Add('        '''' AS DES_BANDEIRA,         ');
           SQL.Add('        '''' AS DES_REDE_TEF,         ');
           SQL.Add('        0 AS VAL_RETENCAO,         ');
           SQL.Add('        0 AS COD_CONDICAO,         ');
           SQL.Add('        '''' AS DTA_PAGTO,   ');
           SQL.Add('        LPAD(extract(day FROM FINCAPA.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINCAPA.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FINCAPA.data) AS DTA_ENTRADA,      ');
           SQL.Add('        '''' AS NUM_NOSSO_NUMERO,      ');
           SQL.Add('        '''' AS COD_BARRA,      ');
           SQL.Add('        ''N'' AS FLG_BOLETO_EMIT,         ');
           SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( C.cnpj, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC_CPF_TITULAR,      ');
           SQL.Add('        COALESCE (C.nome, '''') AS DES_TITULAR,      ');
           SQL.Add('        0 AS NUM_CONDICAO      ');
           SQL.Add('   FROM RECABER A   ');
           SQL.Add('   INNER JOIN RECEITAS FINCAPA ON   ');
           SQL.Add('       (FINCAPA.CODIGO = A.CODIGO)   ');
           SQL.Add('   INNER JOIN RECEITASPARC FINPARC  ON   ');
           SQL.Add('       (FINPARC.codigo = FINCAPA.codigo)   ');
           SQL.Add('   LEFT JOIN RECEITASBX BX ON   ');
           SQL.Add('       (FINPARC.codigo = BX.codigo AND FINPARC.parcela = BX.parcela)   ');
           SQL.Add('   INNER JOIN CLIENTES C ON   ');
           SQL.Add('       (C.codigo = FINCAPA.tomador)   ');




      end
      else
      begin
       //QUITADO
           SQL.Add('   SELECT DISTINCT   ');
           SQL.Add('        0 AS TIPO_PARCEIRO,      ');
           SQL.Add('        COALESCE (FINCAPA.tomador, 0) AS COD_PARCEIRO,   ');
           SQL.Add('        1 AS TIPO_CONTA,      ');
           SQL.Add('        CASE   ');
           SQL.Add('           WHEN FINCAPA.tipo = ''CP'' THEN 3   ');
           SQL.Add('           ELSE 4   ');
           SQL.Add('        END AS COD_ENTIDADE,   ');
           SQL.Add('        CASE   ');
           SQL.Add('           WHEN ((FINCAPA.parcelas > 1)OR (FIN.baixa > 1 )) THEN COALESCE (FINCAPA.documento , FIN.codigo) || ''/'' || FIN.baixa   ');
           SQL.Add('           WHEN ((FINCAPA.documento = '''') or (FINCAPA.documento = ''0'')) THEN FIN.codigo   ');
           SQL.Add('           ELSE COALESCE (FINCAPA.documento , FIN.codigo)   ');
           SQL.Add('        END AS NUM_DOCTO,   ');
           SQL.Add('        999 AS COD_BANCO,      ');
           SQL.Add('        ''RECEBTO'' AS DES_BANCO,   ');
           SQL.Add('        LPAD(extract(day FROM FINCAPA.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINCAPA.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FINCAPA.data) AS DTA_EMISSAO,   ');
           SQL.Add('        LPAD(extract(day FROM FINPARC.vencimento), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINPARC.vencimento), 2, ''0'') || ''/'' || EXTRACT(year FROM FINPARC.vencimento) AS DTA_VENCIMENTO,   ');
           SQL.Add('        FINPARC.valor AS VAL_PARCELA,   ');
           SQL.Add('        0 AS VAL_JUROS,   ');
           SQL.Add('        0 AS VAL_DESCONTO,   ');
           SQL.Add('        ''S'' AS FLG_QUITADO,   ');
           SQL.Add('        LPAD(extract(day FROM FIN.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FIN.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FIN.data) AS DTA_QUITADA,   ');
           SQL.Add('        001 AS COD_CATEGORIA,      ');
           SQL.Add('        001 AS COD_SUBCATEGORIA,      ');
           SQL.Add('        FINPARC.parcela AS NUM_PARCELA,   ');
           SQL.Add('        1 AS QTD_PARCELA,   ');
           SQL.Add('        1 AS COD_LOJA,      ');
           SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( C.cnpj, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
           SQL.Add('        0 AS NUM_BORDERO,      ');
           SQL.Add('        '''' AS NUM_NF,      ');
           SQL.Add('        0 AS NUM_SERIE_NF,      ');
           SQL.Add('        FINCAPA.valor AS VAL_TOTAL_NF,   ');
           SQL.Add('        '''' AS DES_OBSERVACAO,      ');
           SQL.Add('        101 AS NUM_PDV,   ');
           SQL.Add('        '''' AS NUM_CUPOM_FISCAL,   ');
           SQL.Add('        0 AS COD_MOTIVO,      ');
           SQL.Add('        99999 AS COD_CONVENIO,   ');
           SQL.Add('        0 AS COD_BIN,      ');
           SQL.Add('        '''' AS DES_BANDEIRA,      ');
           SQL.Add('        '''' AS DES_REDE_TEF,      ');
           SQL.Add('        0 AS VAL_RETENCAO,      ');
           SQL.Add('        0 AS COD_CONDICAO,      ');
           SQL.Add('        LPAD(extract(day FROM FIN.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FIN.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FIN.data) AS DTA_PAGTO,   ');
           SQL.Add('        LPAD(extract(day FROM FINCAPA.data), 2, ''0'') || ''/'' || LPAD(extract(month FROM FINCAPA.data), 2, ''0'') || ''/'' || EXTRACT(year FROM FINCAPA.data) AS DTA_ENTRADA,   ');
           SQL.Add('        '''' AS NUM_NOSSO_NUMERO,   ');
           SQL.Add('        '''' AS COD_BARRA,   ');
           SQL.Add('        ''N'' AS FLG_BOLETO_EMIT,      ');
           SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( C.cnpj, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC_CPF_TITULAR,   ');
           SQL.Add('        COALESCE (C.nome, '''') AS DES_TITULAR,   ');
           SQL.Add('        0 AS NUM_CONDICAO   ');
           SQL.Add('   FROM RECEITASBX FIN   ');
           SQL.Add('   INNER JOIN RECEITASPARC FINPARC ON   ');
           SQL.Add('       (FINPARC.codigo = FIN.codigo AND FINPARC.parcela = FIN.parcela)   ');
           SQL.Add('   INNER JOIN RECEITAS FINCAPA ON   ');
           SQL.Add('       (FINCAPA.codigo = FINPARC.codigo)   ');
           SQL.Add('   INNER JOIN CLIENTES C ON   ');
           SQL.Add('       (C.codigo = FINCAPA.tomador)   ');
           SQL.Add('   WHERE FINCAPA.data >= :INI   ');
           SQL.Add('   AND FINCAPA.data <= :FIM  ');

          // SQL.Add('AND PDV.PEDVV_DATALANCTO >= :INI ');
          // SQL.Add('AND PDV.PEDVV_DATALANCTO <= :FIM ');

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

        Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

        if Layout.FieldByName('FLG_QUITADO').AsString = 'N' then
        begin
            if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
            begin
                Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
            end;
            Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime);
            Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);

            if Layout.FieldByName('DTA_QUITADA').AsString <> '' then
            begin
              Layout.FieldByName('DTA_QUITADA').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_QUITADA').AsDateTime);
            end;

            if Layout.FieldByName('DTA_PAGTO').AsString <> '' then
            begin
              Layout.FieldByName('DTA_PAGTO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_PAGTO').AsDateTime);
            end;
        end
        else
        begin
            if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
            begin
                Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
            end;
            Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_EMISSAO').AsDateTime);
            Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);

//            if Layout.FieldByName('DTA_QUITADA').AsString = '' then
//            begin
//               Layout.FieldByName('DTA_QUITADA').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);
//            end
//            else
//            begin
              Layout.FieldByName('DTA_QUITADA').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_QUITADA').AsDateTime);
//            end;

            if Layout.FieldByName('DTA_PAGTO').AsString = '' then
            begin
               Layout.FieldByName('DTA_PAGTO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_VENCIMENTO').AsDateTime);
            end
            else
            begin
              Layout.FieldByName('DTA_PAGTO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_PAGTO').AsDateTime);
            end;
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

procedure TFrmSmBelaVistaGsMarket.GerarFinanceiroReceberCartao;
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
//    SQL.Add('    ''COBRANÇA: '' || RECEBER.DATACOB || '' | 1 DEVOL: '' || RECEBER.DEVOLUCAOA || '' | 2 DEVOL : '' || RECEBER.DEVOLUCAOB || '' | ''  || RECEBER.OBSERVACAO AS DES_OBSERVACAO,');
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
    SQL.Add('''COBRANÇA: '' || RECEBER.DATACOB || '' | 1 DEVOL: '' || RECEBER.DEVOLUCAOA || '' | 2 DEVOL : '' || RECEBER.DEVOLUCAOB || '' | ''  || RECEBER.OBSERVACAO AS DES_OBSERVACAO,');
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

procedure TFrmSmBelaVistaGsMarket.GerarFornecedor;
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

         SQL.Add('                 SELECT      ');
         SQL.Add('                 F.codigo AS COD_FORNECEDOR,      ');
         SQL.Add('                 F.nome AS DES_FORNECEDOR,      ');
         SQL.Add('                 CASE      ');
         SQL.Add('                     WHEN F.FANTASIA = '''' THEN F.NOME      ');
         SQL.Add('                     ELSE COALESCE (F.fantasia, F.NOME)      ');
         SQL.Add('                 END AS DES_FANTASIA,      ');
         SQL.Add('                 COALESCE (F.cnpj, '''') AS NUM_CGC,      ');
         SQL.Add('                 CASE      ');
         SQL.Add('                     WHEN F.tipo = ''J'' THEN      ');
         SQL.Add('                         CASE      ');
         SQL.Add('                             WHEN (F.IE IS NULL) OR (F.ie = '''') THEN ''0''      ');
         SQL.Add('                             ELSE COALESCE (REPLACE (REPLACE( REPLACE( F.ie, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''')   ');
         SQL.Add('                         END      ');
         SQL.Add('                     ELSE COALESCE (REPLACE (REPLACE( REPLACE( F.ie, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''')   ');
         SQL.Add('                 END AS NUM_INSC_EST,      ');
         SQL.Add('                 COALESCE (F.endereco, ''A DEFINIR'') AS DES_ENDERECO,      ');
         SQL.Add('                 COALESCE (F.bairro,  ''A DEFINIR'') AS DES_BAIRRO,      ');
         SQL.Add('                 CASE      ');
         SQL.Add('                     WHEN F.CIDADE = '''' THEN ''BELA VISTA''      ');
         SQL.Add('                     ELSE COALESCE (F.cidade, ''BELA VISTA'')      ');
         SQL.Add('                 END AS DES_CIDADE,      ');
         SQL.Add('                 COALESCE (F.uf,  ''MS'') AS DES_SIGLA,      ');
         SQL.Add('                 COALESCE (F.cep, ''79260000'') AS NUM_CEP,      ');
         SQL.Add('                 COALESCE (REPLACE (REPLACE (REPLACE (F.telefone, ''('', ''''), '')'', ''''), ''-'', ''''), '''') AS NUM_FONE,      ');
         SQL.Add('                 '''' AS NUM_FAX,      ');
         SQL.Add('                 COALESCE (F.nome, '''') AS DES_CONTATO,      ');
         SQL.Add('                 0 AS QTD_DIA_CARENCIA,      ');
         SQL.Add('                 0 AS NUM_FREQ_VISITA,      ');
         SQL.Add('                 0 AS VAL_DESCONTO,      ');
         SQL.Add('                 0 AS NUM_PRAZO,      ');
         SQL.Add('                 ''N''AS ACEITA_DEVOL_MER,      ');
         SQL.Add('                 ''N'' AS CAL_IPI_VAL_BRUTO,      ');
         SQL.Add('                 ''N'' AS CAL_ICMS_ENC_FIN,      ');
         SQL.Add('                 ''N'' AS CAL_ICMS_VAL_IPI,      ');
         SQL.Add('                 ''N'' AS MICRO_EMPRESA,      ');
         SQL.Add('                 F.codigo AS COD_FORNECEDOR_ANT,      ');
         SQL.Add('                 CASE      ');
         SQL.Add('                     WHEN F.NUMERO = ''0'' THEN ''S/N''      ');
         SQL.Add('                     ELSE COALESCE (F.numero, ''S/N'')      ');
         SQL.Add('                 END AS NUM_ENDERECO,      ');
         SQL.Add('                 '''' AS DES_OBSERVACAO,      ');
         SQL.Add('                 COALESCE (F.email, '''') AS DES_EMAIL,      ');
         SQL.Add('                 '''' AS DES_WEB_SITE,      ');
         SQL.Add('                 ''N'' AS FABRICANTE,      ');
         SQL.Add('                 ''N'' AS FLG_PRODUTOR_RURAL,      ');
         SQL.Add('                 1 AS TIPO_FRETE,      ');
         SQL.Add('                 ''N'' AS FLG_SIMPLES,      ');
         SQL.Add('                 ''N'' AS FLG_SUBSTITUTO_TRIB,      ');
         SQL.Add('                 0 AS COD_CONTACCFORN,      ');
         SQL.Add('                 COALESCE (F.INATIVO, ''N'') AS INATIVO,      ');
         SQL.Add('                 21 AS COD_CLASSIF,      ');
         SQL.Add('                 LPAD(extract(day FROM F.DATA), 2, ''0'') || ''/'' || LPAD(extract(month FROM F.DATA), 2, ''0'') || ''/'' || EXTRACT(year FROM F.DATA) AS DTA_CADASTRO,      ');
         SQL.Add('                 0 AS VAL_CREDITO,            ');
         SQL.Add('                 0 AS VAL_DEBITO,      ');
         SQL.Add('                 1 AS PED_MIN_VAL,      ');
         SQL.Add('                 COALESCE (F.email, '''') AS DES_EMAIL_VEND,   ');
         SQL.Add('                 '''' AS SENHA_COTACAO,      ');
         SQL.Add('                 -1 AS TIPO_PRODUTOR,      ');
         SQL.Add('                 COALESCE (REPLACE (REPLACE (REPLACE (F.CELULAR, ''('', ''''), '')'', ''''), ''-'', ''''), '''') AS NUM_CELULAR      ');
         SQL.Add('             FROM FORNECEDORES F      ');


    Open;

    First;
    TotalCont := SetCountTotal(SQL.Text);
    NumLinha := 0;
//    COD_FORNECEDOR := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCont);


//      with QryGeraCodigoFornecedor do
//      begin
//        Inc(COD_FORNECEDOR);
//        Params.ParamByName('COD_FORNECEDOR').Value := COD_FORNECEDOR;
//        Params.ParamByName('NUM_CGC').Value := Layout.FieldByName('NUM_CGC').AsString;
//        Layout.FieldByName('COD_FORNECEDOR').AsInteger := Params.ParamByName('COD_FORNECEDOR').Value;
//        ExecSQL();
//      end;


      Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;

      //Layout.FieldByName('COD_FORNECEDOR').AsInteger := COD_FORNECEDOR;

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);
      Layout.FieldByName('NUM_INSC_EST').AsString := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);
      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

//      if QryPrincipal.FieldByName('NUM_INSC_EST').AsString = '0' then
//         Layout.FieldByName('NUM_INSC_EST').AsString := 'ISENTO';
//
//      if QryPrincipal.FieldByName('NUM_INSC_EST').AsString <> 'ISENTO' then
//         Layout.FieldByName('NUM_INSC_EST').AsString := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);

       //Substituir Letras Acentuadas
        Layout.FieldByName('DES_FORNECEDOR').AsString := StrSubstLtsAct(Layout.FieldByName('DES_FORNECEDOR').AsString);
        Layout.FieldByName('DES_FANTASIA').AsString := StrSubstLtsAct(Layout.FieldByName('DES_FANTASIA').AsString);

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
      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      Layout.FieldByName('DES_EMAIL').AsString := StrReplace(StrLBReplace(UpperCase(FieldByName('DES_EMAIL').AsString)), '\n', '');
      Layout.FieldByName('DES_EMAIL_VEND').AsString := StrReplace(StrLBReplace(UpperCase(FieldByName('DES_EMAIL_VEND').AsString)), '\n', '');


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

procedure TFrmSmBelaVistaGsMarket.GerarGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

         SQL.Add('   SELECT   ');
         SQL.Add('       999 AS COD_SECAO,   ');
         SQL.Add('       G.codigo AS COD_GRUPO,   ');
         SQL.Add('       G.nome AS DES_GRUPO,   ');
         SQL.Add('       0 AS VAL_META   ');
         SQL.Add('   FROM PRODUTOSGRUPOS G   ');
         SQL.Add('   WHERE CHAR_LENGTH (G.classe) <= 5   ');
         SQL.Add('   AND G.codigo NOT IN (SELECT CODIGO FROM produtosgrupos WHERE classe IN (''1'', ''2'', ''3'', ''4'', ''5'', ''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''12'', ''13'', ''14'', ''15'', ''16'')  )   ');
         SQL.Add('   ORDER BY G.CLASSE ASC   ');


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

procedure TFrmSmBelaVistaGsMarket.GerarInfoNutricionais;
var
  TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       NUTRI.COD AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       CASE WHEN NUTRI.DSC = '''' THEN ''A DEFINIR'' ELSE NUTRI.DSC END AS DES_INFO_NUTRICIONAL,   ');
     SQL.Add('       NUTRI.TOLEDO_PORCAO_QUANTIDADE AS PORCAO,   ');
     SQL.Add('       NUTRI.VCALORICO AS VALOR_CALORICO,   ');
     SQL.Add('       NUTRI.VCARBOIDRATO AS CARBOIDRATO,   ');
     SQL.Add('       NUTRI.VPROTEINAS AS PROTEINA,   ');
     SQL.Add('       NUTRI.VGORDURATOTAL AS GORDURA_TOTAL,   ');
     SQL.Add('       NUTRI.VGORDURASATURADA AS GORDURA_SATURADA,   ');
     SQL.Add('       NUTRI.VCOLESTEROL AS COLESTEROL,   ');
     SQL.Add('       NUTRI.VFIBRAALIMENTAR AS FIBRA_ALIMENTAR,   ');
     SQL.Add('       NUTRI.VCALCIO AS CALCIO,   ');
     SQL.Add('       NUTRI.VFERRO AS FERRO,   ');
     SQL.Add('       NUTRI.VSODIO AS SODIO,   ');
     SQL.Add('       (NUTRI.VCALORICO * 100) / 2000 AS VD_VALOR_CALORICO,   ');
     SQL.Add('       (NUTRI.VCARBOIDRATO * 100) / 300 AS VD_CARBOIDRATO,   ');
     SQL.Add('       (NUTRI.VPROTEINAS * 100) / 75 AS VD_PROTEINA,   ');
     SQL.Add('       (NUTRI.VGORDURATOTAL * 100) / 55 AS VD_GORDURA_TOTAL,   ');
     SQL.Add('       (NUTRI.VGORDURASATURADA * 100) / 22 AS VD_GORDURA_SATURADA,   ');
     SQL.Add('       (NUTRI.VCOLESTEROL * 100) / 300 AS VD_COLESTEROL,   ');
     SQL.Add('       (NUTRI.VFIBRAALIMENTAR * 100) / 25 AS VD_FIBRA_ALIMENTAR,   ');
     SQL.Add('       (NUTRI.VCALCIO * 100) / 1000 AS VD_CALCIO,   ');
     SQL.Add('       (NUTRI.VFERRO * 100) / 14 AS VD_FERRO,   ');
     SQL.Add('       (NUTRI.VSODIO * 100) / 2400 AS VD_SODIO,   ');
     SQL.Add('       NUTRI.VGORDURATRANS AS GORDURA_TRANS,   ');
     SQL.Add('       0 AS VD_GORDURA_TRANS,   ');
     SQL.Add('       ''UN'' AS UNIDADE_PORCAO,   ');
     SQL.Add('       NUTRI.FILIZOLA_PORCAO AS DES_PORCAO,   ');
     SQL.Add('       0 AS PARTE_INTEIRA_MED_CASEIRA,   ');
     SQL.Add('       '''' AS MED_CASEIRA_UTILIZADA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_TABELA_NUTRICIONAL AS NUTRI   ');

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

procedure TFrmSmBelaVistaGsMarket.GerarNCM;
var
 count, TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

  SQL.Add('       SELECT DISTINCT      ');
 SQL.Add('           0 AS COD_NCM,      ');
 SQL.Add('           ''A DEFINIR'' AS DES_NCM,      ');
 SQL.Add('           P.codncm AS NUM_NCM,      ');
 SQL.Add('           CASE       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''102'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''112'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''302'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''304'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''405'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''411'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''413'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''414'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''415'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''416'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''417'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''418'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''419'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''421'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''422'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''423'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''425'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''427'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''428'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''429'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''430'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''433'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''611'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''612'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''613'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''615'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''616'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''617'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''620'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''621'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''641'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''651'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''661'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''662'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''664'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''666'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''667'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''671'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''672'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''681'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''839'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''71'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''102'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''105'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''108'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''110'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''111'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''113'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''115'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''116'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''117'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''119'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''120'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''121'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''122'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''123'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''124'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''125'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''126'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''127'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''128'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''129'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''130'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''918'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''75'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''75'' AND P.PISNATREC = ''128'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL) THEN ''N''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1'' THEN ''S''   ');
 SQL.Add('      ');
 SQL.Add('           END AS FLG_NAO_PIS_COFINS,      ');
 SQL.Add('           CASE      ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''999'' THEN 1   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''102'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''103'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''112'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''201'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''202'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''302'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''304'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''405'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''411'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''413'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''414'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''415'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''416'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''417'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''418'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''419'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''421'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''422'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''423'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''425'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''427'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''428'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''429'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''430'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''433'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''611'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''612'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''613'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''615'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''616'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''617'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''620'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''621'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''641'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''651'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''661'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''662'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''664'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''666'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''667'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''671'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''672'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''681'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''839'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''71'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''101'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''102'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''101'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''103'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''105'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''108'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''110'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''111'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''113'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''115'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''116'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''117'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''119'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''120'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''121'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''122'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''123'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''124'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''125'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''126'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''127'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''128'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''129'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''130'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''201'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''918'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''75'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''75'' AND P.PISNATREC = ''128'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''101'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''103'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''201'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL)  THEN -1   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN 4   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1''   THEN 1   ');
 SQL.Add('                   ELSE ''FALTANTE''   ');
 SQL.Add('           END AS TIPO_NAO_PIS_COFINS,      ');
 SQL.Add('           CASE   ');
 SQL.Add('               WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL) THEN ''''   ');
 SQL.Add('               WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN ''101''   ');
 SQL.Add('               WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1''   THEN ''101''   ');
 SQL.Add('               ELSE P.PISNATREC   ');
 SQL.Add('           END AS COD_TAB_SPED,   ');
 SQL.Add('           CASE      ');
 SQL.Add('               WHEN (P.codcest IS NULL) OR (P.codcest = '''') THEN ''9999999''      ');
 SQL.Add('               WHEN (P.codcest = ''0000000'') THEN ''9999999''      ');
 SQL.Add('               ELSE P.codcest      ');
 SQL.Add('           END AS NUM_CEST,      ');
 SQL.Add('           ''MS'' AS DES_SIGLA,      ');
 SQL.Add('           CASE      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''     AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''040''  THEN  1      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''    AND P.BASESUB = ''0.00''  AND P.CST = ''051''  THEN  20      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''    AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  25      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''59''         AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  13      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  46      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''29.41''     AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  47      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''29.412''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  47      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''58.82''     AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''58.824''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  49      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  49      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''  AND P.REDUCAOBASE = ''70.589''      AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  50      ');
 SQL.Add('               ELSE 999      ');
 SQL.Add('           END AS COD_TRIB_ENTRADA,      ');
 SQL.Add('           CASE      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''     AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''040''  THEN  1      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''    AND P.BASESUB = ''0.00''  AND P.CST = ''051''  THEN  20      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''    AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  25      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''59''         AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  13      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  46      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''29.41''     AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  47      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''29.412''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  47      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''58.82''     AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''58.824''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  49      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  49      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''  AND P.REDUCAOBASE = ''70.589''      AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  50      ');
 SQL.Add('               ELSE 999      ');
 SQL.Add('           END AS COD_TRIB_SAIDA,      ');
 SQL.Add('           0 AS PER_IVA,         ');
 SQL.Add('           0 AS PER_FCP_ST      ');
 SQL.Add('             ');
 SQL.Add('       FROM PRODUTOS P   ');








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

procedure TFrmSmBelaVistaGsMarket.GerarNCMUF;
var
 count, TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

 SQL.Add('       SELECT DISTINCT      ');
 SQL.Add('           0 AS COD_NCM,      ');
 SQL.Add('           ''A DEFINIR'' AS DES_NCM,      ');
 SQL.Add('           P.codncm AS NUM_NCM,      ');
 SQL.Add('           CASE       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''102'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''112'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''302'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''304'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''405'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''411'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''413'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''414'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''415'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''416'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''417'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''418'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''419'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''421'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''422'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''423'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''425'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''427'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''428'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''429'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''430'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''433'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''611'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''612'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''613'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''615'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''616'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''617'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''620'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''621'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''641'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''651'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''661'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''662'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''664'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''666'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''667'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''671'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''672'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''681'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''839'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''71'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''102'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''105'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''108'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''110'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''111'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''113'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''115'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''116'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''117'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''119'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''120'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''121'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''122'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''123'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''124'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''125'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''126'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''127'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''128'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''129'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''130'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''918'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''75'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''75'' AND P.PISNATREC = ''128'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''101'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''103'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''201'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL) THEN ''N''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN ''S''   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1'' THEN ''S''   ');
 SQL.Add('      ');
 SQL.Add('           END AS FLG_NAO_PIS_COFINS,      ');
 SQL.Add('           CASE      ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''999'' THEN 1   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''102'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''103'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''112'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''201'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''202'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''302'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''304'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''405'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''411'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''413'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''414'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''415'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''416'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''417'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''418'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''419'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''421'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''422'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''423'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''425'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''427'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''428'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''429'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''430'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''433'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''611'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''612'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''613'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''615'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''616'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''617'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''620'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''621'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''641'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''651'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''661'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''662'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''664'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''666'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''667'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''671'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''672'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''681'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''839'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''71'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''434'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''668'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''101'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''5'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''74'' AND P.COFAL = ''0.00'' AND P.COFCT = ''5'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''74'' AND P.PISNATREC = ''102'' THEN 1       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''101'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''103'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''105'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''108'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''110'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''111'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''113'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''115'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''116'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''117'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''119'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''120'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''121'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''122'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''123'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''124'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''125'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''126'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''127'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''128'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''129'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''130'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''201'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''202'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''73'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''73'' AND P.PISNATREC = ''918'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''6'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''75'' AND P.COFAL = ''0.00'' AND P.COFCT = ''6'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''75'' AND P.PISNATREC = ''128'' THEN 0       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''101'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''103'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''201'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC = ''999'' THEN 4       ');
 SQL.Add('                   WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL)  THEN -1   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN 4   ');
 SQL.Add('                   WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1''   THEN 1   ');
 SQL.Add('                   ELSE ''FALTANTE''   ');
 SQL.Add('           END AS TIPO_NAO_PIS_COFINS,      ');
 SQL.Add('           CASE   ');
 SQL.Add('               WHEN P.PISAL = ''1.65'' AND P.PISCT = ''1'' AND P.PISAL1 = ''1.65'' AND PISCT1 = ''50'' AND P.COFAL = ''7.60'' AND P.COFCT = ''1'' AND P.COFAL1 = ''7.60'' AND P.COFCT1 = ''50'' AND (P.PISNATREC = ''0'' or P.PISNATREC IS NULL) THEN ''''   ');
 SQL.Add('               WHEN P.PISAL = ''0.00'' AND P.PISCT = ''9'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''72'' AND P.COFAL = ''0.00'' AND P.COFCT = ''9'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''72'' AND P.PISNATREC IS NULL THEN ''101''   ');
 SQL.Add('               WHEN P.PISAL = ''0.00'' AND P.PISCT = ''4'' AND P.PISAL1 = ''0.00'' AND PISCT1 = ''70'' AND P.COFAL = ''0.00'' AND P.COFCT = ''4'' AND P.COFAL1 = ''0.00'' AND P.COFCT1 = ''70'' AND P.PISNATREC = ''1''   THEN ''101''   ');
 SQL.Add('               ELSE P.PISNATREC   ');
 SQL.Add('           END AS COD_TAB_SPED,   ');
 SQL.Add('           CASE      ');
 SQL.Add('               WHEN (P.codcest IS NULL) OR (P.codcest = '''') THEN ''9999999''      ');
 SQL.Add('               WHEN (P.codcest = ''0000000'') THEN ''9999999''      ');
 SQL.Add('               ELSE P.codcest      ');
 SQL.Add('           END AS NUM_CEST,      ');
 SQL.Add('           ''MS'' AS DES_SIGLA,      ');
 SQL.Add('           CASE      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''     AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''040''  THEN  1      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''    AND P.BASESUB = ''0.00''  AND P.CST = ''051''  THEN  20      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''    AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  25      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''59''         AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  13      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  46      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''29.41''     AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  47      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''29.412''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  47      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''58.82''     AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''58.824''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  49      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  49      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''  AND P.REDUCAOBASE = ''70.589''      AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  50      ');
 SQL.Add('               ELSE 999      ');
 SQL.Add('           END AS COD_TRIB_ENTRADA,      ');
 SQL.Add('           CASE      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''     AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''040''  THEN  1      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''    AND P.BASESUB = ''0.00''  AND P.CST = ''051''  THEN  20      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''    AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  25      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''59''         AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  13      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  46      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''29.41''     AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  47      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''29.412''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  47      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''58.82''     AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''58.824''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  49      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  49      ');
 SQL.Add('               WHEN P.ALIQUOTA = ''17.00''  AND P.REDUCAOBASE = ''70.589''      AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  50      ');
 SQL.Add('               ELSE 999      ');
 SQL.Add('           END AS COD_TRIB_SAIDA,      ');
 SQL.Add('           0 AS PER_IVA,         ');
 SQL.Add('           0 AS PER_FCP_ST      ');
 SQL.Add('             ');
 SQL.Add('       FROM PRODUTOS P   ');







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

procedure TFrmSmBelaVistaGsMarket.GerarNFClientes;
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

procedure TFrmSmBelaVistaGsMarket.GerarNFFornec;
var
   TotalCount : integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('        NF.TRANSAC AS COD_FORNECEDOR,   ');
       SQL.Add('        NF.NOTA AS NUM_NF_FORN,   ');
       SQL.Add('        NF.SERIE AS NUM_SERIE_NF,   ');
       SQL.Add('        '''' AS NUM_SUBSERIE_NF,   ');
       SQL.Add('        NF.operacao AS CFOP,   ');
       SQL.Add('        0 AS TIPO_NF,   ');
       SQL.Add('        NF.MODELO AS DES_ESPECIE,   ');
       SQL.Add('        NF.VALOR AS VAL_TOTAL_NF,   ');
       SQL.Add('        NF.DATA AS DTA_EMISSAO,   ');
       SQL.Add('        NF.DATASAI AS DTA_ENTRADA,   ');
       SQL.Add('        NF.VALORIPI AS VAL_TOTAL_IPI,   ');
       SQL.Add('        NF.VALOR AS VAL_VENDA_VAREJO,   ');
       SQL.Add('        0 VAL_FRETE,   ');
       SQL.Add('        0 AS VAL_ACRESCIMO,   ');
       SQL.Add('        NF.DESCONTO AS VAL_DESCONTO,   ');
       SQL.Add('        COALESCE (REPLACE (REPLACE( REPLACE( F.CNPJ, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('        NF.BASEICMS AS VAL_TOTAL_BC,   ');
       SQL.Add('        NF.VALOICMS AS VAL_TOTAL_ICMS,   ');
       SQL.Add('        NF.BASESUB AS VAL_BC_SUBST,   ');
       SQL.Add('        NF.VALOSUB AS VAL_ICMS_SUBST,   ');
       SQL.Add('        0 AS VAL_FUNRURAL,   ');
       SQL.Add('        CASE   ');
       SQL.Add('           WHEN NF.operacao IN (''1102'', ''1403'') THEN 1   ');
       SQL.Add('           ELSE 5   ');
       SQL.Add('        END AS COD_PERFIL,   ');
       SQL.Add('        0 AS  VAL_DESP_ACESS,   ');
       SQL.Add('        ''N'' AS FLG_CANCELADO,   ');
       SQL.Add('        '''' AS DES_OBSERVACAO,   ');
       SQL.Add('        NF.CHAVENFE AS NUM_CHAVE_ACESSO,   ');
       SQL.Add('        NF.FCPVALOR AS VAL_TOT_ST_FCP   ');
       SQL.Add('   FROM NOTAFISCAL NF   ');
       SQL.Add('   LEFT JOIN FORNECEDORES F ON   ');
       SQL.Add('       (F.CODIGO = NF.TRANSAC)   ');
       SQL.Add('   WHERE NF.DATA >= :INI   ');
       SQL.Add('   AND NF.DATA <= :FIM   ');
       SQL.Add('   AND NF.TIPO = ''E''   ');
       SQL.Add('   AND NF.STATUS IN (''00'', ''08'')   ');
       SQL.Add('   AND NF.OPERACAO IN (''1102'', ''1403'', ''1910'', ''2910'')   ');


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

      if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
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

procedure TFrmSmBelaVistaGsMarket.GerarNFitensClientes;
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

procedure TFrmSmBelaVistaGsMarket.GerarNFitensFornec;
var
   fornecedor, nota, serie : string;
   count, TotalCount : integer;

begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('       NF.transac AS COD_FORNECEDOR,   ');
       SQL.Add('       NF.nota AS NUM_NF_FORN,   ');
       SQL.Add('       NF.serie AS NUM_SERIE_NF,   ');
       SQL.Add('       NFI.produto AS COD_PRODUTO,   ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''040''  THEN  1   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''051''  THEN  20   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  25   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  13   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  46   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''29.41''     AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  47   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''29.412''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  47   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''58.82''     AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''58.824''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  49   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  49   ');
       SQL.Add('           WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''70.589''    AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  50   ');
       SQL.Add('           ELSE 999   ');
       SQL.Add('       END AS COD_TRIBUTACAO,   ');
       SQL.Add('       NFI.qua_unid AS QTD_EMBALAGEM,   ');
       SQL.Add('       NFI.quantidade AS QTD_ENTRADA,   ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN NFI.unid <> ''KG'' THEN ''UN''   ');
       SQL.Add('           ELSE NFI.unid   ');
       SQL.Add('       END AS DES_UNIDADE,   ');
       SQL.Add('       (NFI.unitario / NFI.qua_unid) AS VAL_TABELA,   ');
       SQL.Add('       (NFI.desconto / NFI.qua_unid) AS VAL_DESCONTO_ITEM,   ');
       SQL.Add('       0 VAL_ACRESCIMO_ITEM,      ');
       SQL.Add('       (NFI.ipivr / NFI.qua_unid) AS VAL_IPI_ITEM,   ');
       SQL.Add('       0 AS VAL_IPI_PER,   ');
       SQL.Add('       NFI.VALORSUB AS VAL_SUBST_ITEM,   ');
       SQL.Add('       0 AS VAL_FRETE_ITEM,   ');
       SQL.Add('       (NFI.valoicms) AS VAL_CREDITO_ICMS,   ');
       SQL.Add('       NFI.total AS VAL_VENDA_VAREJO,   ');
       SQL.Add('       NFI.total AS VAL_TABELA_LIQ,   ');
       SQL.Add('       COALESCE (REPLACE (REPLACE( REPLACE( F.CNPJ, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('       NFI.baseicms AS VAL_TOT_BC_ICMS,   ');
       SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
       SQL.Add('       NFI.cfop AS CFOP,   ');
       SQL.Add('       0 AS VAL_TOT_ISENTO,      ');
       SQL.Add('       NFI.basesub AS VAL_TOT_BC_ST,   ');
       SQL.Add('       NFI.valorsub AS VAL_TOT_ST,   ');
       SQL.Add('       NFI.ITEM AS NUM_ITEM,   ');
       SQL.Add('       0 AS TIPO_IPI,      ');
       SQL.Add('       P.CODNCM AS NUM_NCM,   ');
       SQL.Add('       '''' AS DES_REFERENCIA,      ');
       SQL.Add('       (NFI.fcpvalor / NFI.qua_unid) AS VAL_TOT_ST_FCP,   ');
       SQL.Add('       0 AS VAL_DESP_ACESS_ITEM   ');
       SQL.Add('   FROM NOTAFISCALITENS NFI   ');
       SQL.Add('   INNER JOIN NOTAFISCAL NF ON   ');
       SQL.Add('       (NF.numero = NFI.numero)   ');
       SQL.Add('   LEFT JOIN PRODUTOS P ON   ');
       SQL.Add('       (P.codigo = NFI.produto)   ');
       SQL.Add('   left JOIN FORNECEDORES F ON   ');
       SQL.Add('       (F.codigo = NF.transac)   ');
       SQL.Add('   WHERE NF.DATA >= :INI   ');
       SQL.Add('   AND NF.DATA <= :FIM   ');
       SQL.Add('   AND NF.tipo = ''E''   ');
       SQL.Add('   AND NF.STATUS IN (''00'', ''08'')   ');
       SQL.Add('   AND NF.OPERACAO IN (''1102'', ''1403'', ''1910'', ''2910'')   ');

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

//      if( (Layout.FieldByName('COD_FORNECEDOR').AsString = fornecedor) and
//          (Layout.FieldByName('NUM_NF_FORN').AsString = nota) and
//          (Layout.FieldByName('NUM_SERIE_NF').AsString = serie) ) then
//      begin
//          inc(count);
//      end
//      else
//      begin
//        fornecedor := Layout.FieldByName('COD_FORNECEDOR').AsString;
//        nota := Layout.FieldByName('NUM_NF_FORN').AsString;
//        serie := Layout.FieldByName('NUM_SERIE_NF').AsString;
//        count := 1;
//      end;
//
//      Layout.FieldByName('NUM_ITEM').AsInteger := count;
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

procedure TFrmSmBelaVistaGsMarket.GerarProdForn;
var
   TotalCount, NEW_CODPROD : Integer;
   convReferencia : String;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       PF.codigo AS COD_PRODUTO,   ');
       SQL.Add('       PF.fornecedor AS COD_FORNECEDOR,   ');
       SQL.Add('       PF.produto AS DES_REFERENCIA,   ');
       SQL.Add('       COALESCE (REPLACE (REPLACE( REPLACE( F.CNPJ, ''.'', ''''), ''-'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('       ''UN'' AS DES_UNIDADE_COMPRA,   ');
       SQL.Add('       0 AS COD_DIVISAO   ');
       SQL.Add('   FROM PRODUTOSFORN PF   ');
       SQL.Add('   INNER JOIN FORNECEDORES F ON   ');
       SQL.Add('       (PF.fornecedor = F.codigo )   ');


    Open;

    First;

    NumLinha := 0;

    //NEW_CODPROD := 10000;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);
      //Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
//      end;

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

      convReferencia := Layout.FieldByName('DES_REFERENCIA').AsString;

      Layout.FieldByName('DES_REFERENCIA').AsString := TiraZerosEsquerda(convReferencia);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmBelaVistaGsMarket.GerarProdLoja;
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

       SQL.Add('       SELECT      ');
       SQL.Add('           CASE      ');
       SQL.Add('               WHEN PB.quantidade = 6 THEN P.CODIGO +  100000      ');
       SQL.Add('               WHEN PB.quantidade = 8 THEN P.CODIGO +  200000      ');
       SQL.Add('               WHEN PB.quantidade = 12 THEN P.CODIGO + 300000      ');
       SQL.Add('               WHEN PB.quantidade = 15 THEN P.CODIGO + 400000      ');
       SQL.Add('               WHEN PB.quantidade = 18 THEN P.CODIGO + 500000      ');
       SQL.Add('               WHEN PB.quantidade = 20 THEN P.CODIGO + 600000      ');
       SQL.Add('               WHEN PB.quantidade = 21 THEN P.CODIGO + 700000      ');
       SQL.Add('               WHEN PB.quantidade = 30 THEN P.CODIGO + 800000      ');
       SQL.Add('               WHEN PB.quantidade = 40 THEN P.CODIGO + 900000      ');
       SQL.Add('               ELSE P.CODIGO      ');
       SQL.Add('           END AS COD_PRODUTO,      ');
       SQL.Add('            PP.CUSTO VAL_CUSTO_REP,      ');
       SQL.Add('            PP.PRECO AS VAL_VENDA,      ');
       SQL.Add('            COALESCE ((SELECT FIRST 1 PTI.preco FROM produtostabit PTI   ');
       SQL.Add('                               INNER JOIN PRODUTOSTAB PT ON (PT.codigo = PTI.tabela) WHERE PT.datafin >= ''01.02.2023'' AND PTI.barra = PB.barra ), 0) AS VAL_OFERTA,   ');
       SQL.Add('            CASE      ');
       SQL.Add('               WHEN PB.quantidade > 1 THEN 0      ');
       SQL.Add('               ELSE COALESCE (PE.QUANTIDADE, 0)      ');
       SQL.Add('            END AS QTD_EST_VDA,      ');
       SQL.Add('            '''' AS TECLA_BALANCA,      ');
       SQL.Add('           CASE      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''040''  THEN  1      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''051''  THEN  20      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  25      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  13      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  46      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''29.41''     AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  47      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''29.412''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  47      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''58.82''     AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''58.824''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  49      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  49      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''70.589''    AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  50      ');
       SQL.Add('               ELSE 999      ');
       SQL.Add('           END AS COD_TRIBUTACAO,      ');
       SQL.Add('           COALESCE (PP.MARGEM, 0) AS VAL_MARGEM,      ');
       SQL.Add('           1 AS QTD_ETIQUETA,      ');
       SQL.Add('           CASE      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''040''  THEN  1      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''051''  THEN  20      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  25      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''0.00''    AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''060''  THEN  13      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''0.00000''   AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  46      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''29.41''     AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  47      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''29.412''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  47      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''58.82''     AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''58.824''    AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  48      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  49      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''59''        AND P.BASESUB = ''0.00''  AND P.CST = ''020''  THEN  49      ');
       SQL.Add('               WHEN P.ALIQUOTA = ''17.00''   AND P.REDUCAOBASE = ''70.589''    AND P.BASESUB = ''0.00''  AND P.CST = ''000''  THEN  50      ');
       SQL.Add('               ELSE 999      ');
       SQL.Add('           END AS COD_TRIB_ENTRADA,      ');
       SQL.Add('           P.INATIVO AS FLG_INATIVO,      ');
       SQL.Add('           P.CODIGO AS COD_PRODUTO_ANT,      ');
       SQL.Add('           P.CODNCM AS NUM_NCM,      ');
       SQL.Add('           0 AS TIPO_NCM,      ');
       SQL.Add('           PP.preco2 AS VAL_VENDA_2,   ');
       SQL.Add('           COALESCE ((SELECT FIRST 1 LPAD(extract(day FROM PT.datafin), 2, ''0'') || ''/'' || LPAD(extract(month FROM PT.datafin), 2, ''0'') || ''/'' || EXTRACT(year FROM PT.datafin) FROM produtostabit PTI   ');
       SQL.Add('                       INNER JOIN PRODUTOSTAB PT ON (PT.codigo = PTI.tabela) WHERE PT.datafin >= ''01.02.2023'' AND PTI.barra = PB.barra ), '''') AS DTA_VALIDA_OFERTA,   ');
       SQL.Add('           1 AS QTD_EST_MINIMO,      ');
       SQL.Add('           NULL AS COD_VASILHAME,      ');
       SQL.Add('           ''N'' AS FORA_LINHA,      ');
       SQL.Add('           0 AS QTD_PRECO_DIF,      ');
       SQL.Add('           0 AS VAL_FORCA_VDA,      ');
       SQL.Add('           CASE         ');
       SQL.Add('               WHEN (P.codcest IS NULL) OR (P.codcest = '''') THEN ''9999999''      ');
       SQL.Add('               WHEN (P.codcest = ''0000000'') THEN ''9999999''      ');
       SQL.Add('               ELSE P.codcest      ');
       SQL.Add('           END AS NUM_CEST,      ');
       SQL.Add('           0 AS PER_IVA,      ');
       SQL.Add('           0 AS PER_FCP_ST,      ');
       SQL.Add('           0 AS PER_FIDELIDADE,      ');
       SQL.Add('           CASE   ');
       SQL.Add('               WHEN P.ingredientes IS NULL THEN NULL   ');
       SQL.Add('               ELSE P.codigo   ');
       SQL.Add('           END AS COD_INFO_RECEITA,   ');
       SQL.Add('               2323 AS COD_ASSOCIADO      ');
       SQL.Add('       FROM PRODUTOS P      ');
       SQL.Add('       INNER JOIN PRODUTOSBARRA PB ON      ');
       SQL.Add('           (P.CODIGO = PB.CODIGO)      ');
       SQL.Add('       INNER JOIN PRODUTOSPRECO PP ON      ');
       SQL.Add('           (PB.BARRA = PP.BARRA)      ');
       SQL.Add('       LEFT JOIN PRODUTOSEST PE ON      ');
       SQL.Add('           (PE.PRODUTO = P.CODIGO)   ');
       SQL.Add('       WHERE PB.QUANTIDADE >= 1   ');
       SQL.Add('       and P.CODIGO  <= 5   ');







    Open;
    First;
    NumLinha := 0;
    //NEW_CODPROD := 10000;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      //Inc(NEW_CODPROD);
      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
//      end;

//      if Layout.FieldByName('COD_PRODUTO_ANT').AsString = '0' then
//      begin
//        Layout.FieldByName('COD_PRODUTO_ANT').AsInteger := NEW_CODPROD;
//      end;

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
      Layout.FieldByName('COD_PRODUTO_ANT').AsString := Layout.FieldByName('COD_PRODUTO_ANT').AsString;
      Layout.FieldByName('COD_ASSOCIADO').AsString := GerarPLU( Layout.FieldByName('COD_ASSOCIADO').AsString );

//      Layout.FieldByName('COD_PRODUTO_ANT').AsString := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO_ANT').AsString);

//      Layout.FieldByName('NUM_NCM').AsString := StrRetNums(Layout.FieldByName('NUM_NCM').AsString);

//      if Layout.FieldByName('NUM_NCM').AsString = '00000000' then
//      begin
//        Layout.FieldByName('NUM_NCM').AsString := '00000000';
//      end
//      else
//      begin
        Layout.FieldByName('NUM_NCM').AsString := StrRetNums(Layout.FieldByName('NUM_NCM').AsString);
//      end;

      Layout.FieldByName('NUM_CEST').AsString := StrRetNums( Layout.FieldByName('NUM_CEST').AsString );

      if QryPrincipal.FieldByName('DTA_VALIDA_OFERTA').AsString <> '' then
        Layout.FieldByName('DTA_VALIDA_OFERTA').AsDateTime := FieldByName('DTA_VALIDA_OFERTA').AsDateTime;
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

procedure TFrmSmBelaVistaGsMarket.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('       PS.codigo AS COD_PRODUTO_SIMILAR,   ');
       SQL.Add('       PS.nome AS DES_PRODUTO_SIMILAR,   ');
       SQL.Add('       0 AS VAL_META   ');
       SQL.Add('   FROM PRODUTOSAGRUPA PS   ');



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
