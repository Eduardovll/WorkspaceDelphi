unit UFrmSmRonyMG;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, ComObj,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrmModelo, Data.DBXOracle, Data.DB,
  Data.SqlExpr, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DBXFirebird, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.Provider, Datasnap.DBClient, //dxGDIPlusClasses,
  Math;

type
  TFrmSmRonyMG = class(TFrmModeloSis)
    CbxLoja: TComboBox;
    lblLoja: TLabel;
    ADOMySQL: TADOConnection;
    QryPrincipal2: TADOQuery;
    QryAux: TADOQuery;
    Label11: TLabel;
    btnGeraValorVenda: TButton;
    btnGeraCustoRep: TButton;
    btnGerarEstoqueAtual: TButton;
    procedure btnGeraCestClick(Sender: TObject);
    procedure BtnAmarrarCestClick(Sender: TObject);
    procedure BtnGerarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGeraValorVendaClick(Sender: TObject);
    procedure btnGeraCustoRepClick(Sender: TObject);
    procedure btnGerarEstoqueAtualClick(Sender: TObject);
    procedure CkbProdLojaClick(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
    procedure GerarCliente;           Override;
    procedure GerarFornecedor;        Override;
    procedure GerarCondPagForn;       Override;
    procedure GerarDivisaoForn;      Override;
    procedure GerarCondPagCli;       Override;

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


    procedure GerarValorVenda;
    procedure GeraCustoRep;
    procedure GeraEstoqueVenda;

  end;

var
  FrmSmRonyMG: TFrmSmRonyMG;
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


procedure TFrmSmRonyMG.GerarProducao;
begin
  inherited;
  with QryPrincipal2 do
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

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarProduto;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,   ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   				 WHEN PRODUTO.PRO_BALANCA = ''S'' THEN PRODUTO.PRO_CODBALANCA   ');
     SQL.Add('   				 ELSE PRODUTO.PRO_EAN1    ');
     SQL.Add('   		 END AS COD_BARRA_PRINCIPAL,    ');
     SQL.Add('       PRODUTO.PRO_RESUMIDO AS DES_REDUZIDA,   ');
     SQL.Add('       PRODUTO.PRO_DESCRICAO AS DES_PRODUTO,   ');
     SQL.Add('       COALESCE(PRODUTO.PRO_QUANT_UNID, 1) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PRO_EMBUNIDADE = ''1'' THEN ''UN''   ');
     SQL.Add('           ELSE PRODUTO.PRO_EMBUNIDADE    ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,    ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PRO_UNIDADE = ''1'' THEN ''UN''   ');
     SQL.Add('   	       ELSE PRODUTO.PRO_UNIDADE    ');
     SQL.Add('       END AS DES_UNIDADE_VENDA,    ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       0 AS VAL_IPI,   ');
     SQL.Add('       999 AS COD_SECAO,   ');
     SQL.Add('       999 AS COD_GRUPO,   ');
     SQL.Add('       999 AS COD_SUB_GRUPO,   ');
     SQL.Add('       0 AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PRO_UNIDADE = ''KG'' AND PRODUTO.PRO_BALANCA = ''S'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PRODUTO.PRO_VALIDADE_BALANCA, 0) AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('          ');
     SQL.Add('       PRODUTO.PRO_BALANCA AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN -1   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN -1   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       COALESCE(PRODUTO.PRO_OBSERVACOES, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       COALESCE(PRODUTO.NAT_CODIGO, 999) AS COD_TAB_SPED,   ');
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
     SQL.Add('       PRODUTO.FOR_ID AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       PRODUTO.PRO_DATACADASTRO AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       PRODUTO.PRO_DESCRICAO AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
//     SQL.Add('   WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''     ');
     SQL.Add('   WHERE PRODUTO.PRO_EAN2 IS NULL ');

     SQL.Add('UNION ALL');

     SQL.Add('   SELECT   ');
     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,   ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   				 WHEN PRODUTO.PRO_BALANCA = ''S'' THEN PRODUTO.PRO_CODBALANCA   ');
     SQL.Add('   				 ELSE PRODUTO.PRO_EAN2    ');
     SQL.Add('   		 END AS COD_BARRA_PRINCIPAL,    ');
     SQL.Add('       PRODUTO.PRO_RESUMIDO AS DES_REDUZIDA,   ');
     SQL.Add('       PRODUTO.PRO_DESCRICAO AS DES_PRODUTO,   ');
     SQL.Add('       COALESCE(PRODUTO.PRO_QUANT_UNID, 1) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PRO_EMBUNIDADE = ''1'' THEN ''UN''   ');
     SQL.Add('           ELSE PRODUTO.PRO_EMBUNIDADE    ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,    ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PRO_UNIDADE = ''1'' THEN ''UN''   ');
     SQL.Add('   	       ELSE PRODUTO.PRO_UNIDADE    ');
     SQL.Add('       END AS DES_UNIDADE_VENDA,    ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       0 AS VAL_IPI,   ');
     SQL.Add('       999 AS COD_SECAO,   ');
     SQL.Add('       999 AS COD_GRUPO,   ');
     SQL.Add('       999 AS COD_SUB_GRUPO,   ');
     SQL.Add('       0 AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PRO_UNIDADE = ''KG'' AND PRODUTO.PRO_BALANCA = ''S'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PRODUTO.PRO_VALIDADE_BALANCA, 0) AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('          ');
     SQL.Add('       PRODUTO.PRO_BALANCA AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN -1   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN -1   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       COALESCE(PRODUTO.PRO_OBSERVACOES, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       COALESCE(PRODUTO.NAT_CODIGO, 999) AS COD_TAB_SPED,   ');
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
     SQL.Add('       PRODUTO.FOR_ID AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       PRODUTO.PRO_DATACADASTRO AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       PRODUTO.PRO_DESCRICAO AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
//     SQL.Add('   WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''     ');
     SQL.Add('   WHERE PRODUTO.PRO_EAN2 IS NOT NULL ');





    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

      //Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      Layout.FieldByName('DES_REDUZIDA').AsString := StrReplace(StrLBReplace(FieldByName('DES_REDUZIDA').AsString), '\n', '');
      Layout.FieldByName('DES_PRODUTO').AsString := StrReplace(StrLBReplace(FieldByName('DES_PRODUTO').AsString), '\n', '');

      if ( Length(TiraZerosEsquerda(Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString)) < 8 ) then
        Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := GerarPLU( Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString );

      if( not CodBarrasValido(Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString) ) then
        Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := '';



      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
    Close;
  end;
end;


procedure TFrmSmRonyMG.GerarSecao;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       999 AS COD_SECAO,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_SECAO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     //SQL.Add('   LEFT JOIN DEPARTAMENTO ON DEPARTAMENTO.DEP_ID = PRODUTO.DEP_ID   ');




    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarSubGrupo;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       999 AS COD_SECAO,   ');
     SQL.Add('       999 AS COD_GRUPO,   ');
     SQL.Add('       999 AS COD_SUB_GRUPO,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 AS VAL_META,   ');
     SQL.Add('       0 AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');

    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

//      if Layout.FieldByName('DES_SUB_GRUPO').AsString = '' then
//        Layout.FieldByName('DES_SUB_GRUPO').AsString := 'A DEFINIR';


      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarValorVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('    PRODUTOS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('   	REPLACE(COALESCE(PRODUTOS.PRO_VENDA, 0), '','', ''.'') AS VAL_VENDA   ');
     SQL.Add('   FROM   ');
     SQL.Add('   	PRODUTOS AS PRODUTOS   ');
     SQL.Add('   WHERE PRODUTOS.PRO_BARRA <> 0   ');

    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Inc(NumLinha);

        COD_PRODUTO := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_VENDA = '''+QryPrincipal2.FieldByName('VAL_VENDA').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');


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

procedure TFrmSmRonyMG.GerarVenda;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    //NAO FISCAL

//     SQL.Add('   SELECT   ');
//     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,   ');
//     SQL.Add('       1 AS COD_LOJA,   ');
//     SQL.Add('       0 AS IND_TIPO,   ');
//     SQL.Add('       1 AS NUM_PDV,   ');
//     SQL.Add('       ITEM_VENDA.ITV_QTDE AS QTD_TOTAL_PRODUTO,   ');
//     SQL.Add('       ITEM_VENDA.ITV_VALORTOTAL AS VAL_TOTAL_PRODUTO,   ');
//     SQL.Add('       ITEM_VENDA.ITV_PRECOVENDA AS VAL_PRECO_VENDA,   ');
//     SQL.Add('       ITEM_VENDA.PRO_CUSTOREAL AS VAL_CUSTO_REP,   ');
//     SQL.Add('       VENDA.VEN_DATA AS DTA_SAIDA,   ');
//     SQL.Add('      ');
//     SQL.Add('       CASE         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''JAN'' THEN ''01'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''FEV'' THEN ''02'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''FEB'' THEN ''02'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''MAR'' THEN ''03'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''ABR'' THEN ''04'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''APR'' THEN ''04'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''MAI'' THEN ''05'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''MAY'' THEN ''05'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''JUN'' THEN ''06'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''JUL'' THEN ''07'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''AGO'' THEN ''08'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''AUG'' THEN ''08'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''SET'' THEN ''09'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''SEP'' THEN ''09'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''OUT'' THEN ''10'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''OCT'' THEN ''10'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''NOV'' THEN ''11'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')         ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''DEZ'' THEN ''12'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')        ');
//     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''') = ''DEC'' THEN ''12'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 7,10)), '' '', '''')        ');
//     SQL.Add('           ELSE REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDA.VEN_DATA, 106), 3,5)), '' '', '''')         ');
//     SQL.Add('       END AS DTA_MENSAL,   ');
//     SQL.Add('      ');
//     SQL.Add('       ITEM_VENDA.ITV_NUM_ITEM AS NUM_IDENT,   ');
//     SQL.Add('       PRODUTO.PRO_EAN1 AS COD_EAN,   ');
//     SQL.Add('      ');
//     SQL.Add('       CASE         ');
//     SQL.Add('           WHEN LEN(LTRIM(REPLACE(SUBSTRING(CAST(VENDA.VEN_HORA AS VARCHAR), 13, 5), '':'', ''''))) = 3 THEN ''0'' + LTRIM(REPLACE(SUBSTRING(CAST(VENDA.VEN_HORA AS VARCHAR), 13, 5), '':'', ''''))         ');
//     SQL.Add('           ELSE REPLACE(SUBSTRING(CAST(VENDA.VEN_HORA AS VARCHAR), 13, 5), '':'', '''')          ');
//     SQL.Add('       END AS DES_HORA,   ');
//     SQL.Add('      ');
//     SQL.Add('       CLIENTES.CLI_ID AS COD_CLIENTE,   ');
//     SQL.Add('       1 AS COD_ENTIDADE,   ');
//     SQL.Add('       0 AS VAL_BASE_ICMS,   ');
//     SQL.Add('       '''' AS DES_SITUACAO_TRIB,   ');
//     SQL.Add('       0 AS VAL_ICMS,   ');
//     SQL.Add('       VENDA.VEN_ID AS NUM_CUPOM_FISCAL,   ');
//     SQL.Add('       ITEM_VENDA.ITV_PRECOVENDA AS VAL_VENDA_PDV,       ');
//     SQL.Add('       1 AS COD_TRIBUTACAO,   ');
//     SQL.Add('       ''N'' AS FLG_CUPOM_CANCELADO,   ');
//     SQL.Add('      ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN PRODUTO.PRO_CODIGONBM = ''00000000'' THEN ''99999998''    ');
//     SQL.Add('           ELSE COALESCE(PRODUTO.PRO_CODIGONBM, ''99999999'')    ');
//     SQL.Add('       END AS NUM_NCM,   ');
//     SQL.Add('          ');
//     SQL.Add('       COALESCE(PRODUTO.NAT_CODIGO, 999) AS COD_TAB_SPED,       ');
//     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
//     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
//     SQL.Add('       ''S'' AS FLG_ONLINE,   ');
//     SQL.Add('       ''N'' AS FLG_OFERTA,   ');
//     SQL.Add('       0 AS COD_ASSOCIADO   ');
//     SQL.Add('   FROM   ');
//     SQL.Add('       VENDA   ');
//     SQL.Add('   LEFT JOIN ITEM_VENDA ON ITEM_VENDA.VEN_ID = VENDA.VEN_ID   ');
//     SQL.Add('   LEFT JOIN PRODUTO ON PRODUTO.PRO_EAN1 = ITEM_VENDA.ITV_REFER OR PRODUTO.PRO_EAN2 = ITEM_VENDA.ITV_REFER  ');
//     SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_ID = VENDA.CLI_ID   ');
//     SQL.Add('   LEFT JOIN NATUREZA_FISCAL AS NF ON (PRODUTO.NAF_CODFISCAL = NF.NAF_CODFISCAL)   ');
//     SQL.Add('   WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''   ');
//     SQL.Add('   AND');
//     SQL.Add('      VENDA.VEN_DATA >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
//     SQL.Add('   AND');
//     SQL.Add('      VENDA.VEN_DATA <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');


    // FISCAL

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,   ');
     SQL.Add('       1 AS COD_LOJA,   ');
     SQL.Add('       0 AS IND_TIPO,   ');
     SQL.Add('       1 AS NUM_PDV,   ');
     SQL.Add('       ITENS_VENDAS.ITS_QUANT AS QTD_TOTAL_PRODUTO,   ');
//     SQL.Add('       (ITENS_VENDAS.ITS_VLR_TOTAL - (ITENS_VENDAS.ITS_VLR_DESC + ITENS_VENDAS.ITS_DESC + ITENS_VENDAS.ITS_DESCONTO)) AS VAL_TOTAL_PRODUTO,   ');
     sql.Add('       ITENS_VENDAS.ITS_VLR_TOTAL AS VAL_TOTAL_PRODUTO,     ');
     SQL.Add('       1 AS VAL_PRECO_VENDA,   ');
     SQL.Add('       ITENS_VENDAS.PRO_CUSTOREAL AS VAL_CUSTO_REP,   ');
     SQL.Add('       VENDAS.SAI_DT_EMISSAO AS DTA_SAIDA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''JAN'' THEN ''01'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''FEV'' THEN ''02'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''FEB'' THEN ''02'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''MAR'' THEN ''03'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''ABR'' THEN ''04'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''APR'' THEN ''04'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''MAI'' THEN ''05'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''MAY'' THEN ''05'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''JUN'' THEN ''06'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''JUL'' THEN ''07'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''AGO'' THEN ''08'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''AUG'' THEN ''08'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''SET'' THEN ''09'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''SEP'' THEN ''09'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''OUT'' THEN ''10'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''OCT'' THEN ''10'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''NOV'' THEN ''11'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')         ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''DEZ'' THEN ''12'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')        ');
     SQL.Add('           WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''') = ''DEC'' THEN ''12'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 7,10)), '' '', '''')        ');
     SQL.Add('           ELSE REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.SAI_DT_EMISSAO, 106), 3,5)), '' '', '''')         ');
     SQL.Add('       END AS DTA_MENSAL,   ');
     SQL.Add('          ');
     SQL.Add('       ITENS_VENDAS.ITS_NUM_ITEM AS NUM_IDENT,   ');
     SQL.Add('       PRODUTO.PRO_EAN1 AS COD_EAN,   ');
     SQL.Add('       REPLACE(VENDAS.SAI_HORA, '':'', '''') AS DES_HORA,   ');
     SQL.Add('       CLIENTES.CLI_ID AS COD_CLIENTE,   ');
     SQL.Add('       1 AS COD_ENTIDADE,   ');
     SQL.Add('       ITENS_VENDAS.ITS_BASE_CALC_ICMS AS VAL_BASE_ICMS,   ');
     SQL.Add('       '''' AS DES_SITUACAO_TRIB,   ');
     SQL.Add('       ITENS_VENDAS.ITS_VLR_ICMS AS VAL_ICMS,   ');
     SQL.Add('       VENDAS.SAI_NUMNOTA AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       1 AS VAL_VENDA_PDV,   ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
     SQL.Add('           ELSE 1      ');
     SQL.Add('       END AS COD_TRIBUTACAO,      ');
     SQL.Add('      ');
     SQL.Add('       ''N'' AS FLG_CUPOM_CANCELADO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTO.PRO_CODIGONBM = ''00000000'' THEN ''99999998''    ');
     SQL.Add('           ELSE COALESCE(PRODUTO.PRO_CODIGONBM, ''99999999'')    ');
     SQL.Add('       END AS NUM_NCM,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PRODUTO.NAT_CODIGO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''N''      ');
     SQL.Add('           ELSE ''N''      ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,      ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN -1      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN -1      ');
     SQL.Add('           ELSE -1      ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,      ');
     SQL.Add('      ');
     SQL.Add('       ''S'' AS FLG_ONLINE,   ');
     SQL.Add('       ''N'' AS FLG_OFERTA,   ');
     SQL.Add('       0 AS COD_ASSOCIADO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SAIDA AS VENDAS   ');
     SQL.Add('   LEFT JOIN ITEM_SAIDA AS ITENS_VENDAS ON ITENS_VENDAS.SAI_NUMNOTA = VENDAS.SAI_NUMNOTA   ');
     SQL.Add('   LEFT JOIN PRODUTO ON PRODUTO.PRO_ID = ITENS_VENDAS.PRO_ID   ');
     SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_ID = VENDAS.CLI_ID   ');
     SQL.Add('   LEFT JOIN NATUREZA_FISCAL AS NF ON (PRODUTO.NAF_CODFISCAL = NF.NAF_CODFISCAL)   ');
//     SQL.Add('   WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''   ');
//     SQL.Add('   AND VENDAS.SAI_SERIE = 4   ');
//     SQL.Add('   AND VENDAS.SER_ID = 7   ');
     SQL.Add('   WHERE VENDAS.SAI_DT_EMISSAO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('   AND VENDAS.SAI_DT_EMISSAO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+'''  ');


    Open;
    First;
    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;
        Inc(NumLinha);

        Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

        Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);
        Layout.FieldByName('COD_ASSOCIADO').AsString := GerarPLU( Layout.FieldByName('COD_ASSOCIADO').AsString );
        Layout.FieldByName('DTA_SAIDA').AsDateTime := QryPrincipal2.FieldByName('DTA_SAIDA').AsDateTime;

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmRonyMG.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmRonyMG.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmRonyMG.BtnGerarClick(Sender: TObject);
begin
   ADOMySQL.Connected := False;
   ADOMySQL.ConnectionString := 'Provider=MSDASQL.1;Password="'+edtSenhaOracle.Text+'";Persist Security Info=True;User ID='+edtInst.Text+';Data Source='+edtSchema.Text+'';

//Provider=MSDASQL.1;Password="";Persist Security Info=True;User ID=root;Data Source=predileto_l1

//   ADOSQLServer.Connected := false;
////   ADOSQLServer.ConnectionString := 'Provider=MSDASQL.1;Persist Security Info=False;Data Source='+edtSchema.Text+';User ID='+edtInst.Text+';Password'+edtSenhaOracle.Text+'';
//   ADOSQLServer.ConnectionString := 'Provider=MSDASQL.1;Persist Security Info=False;Data Source='+edtSchema.Text+';User ID='+edtInst.Text+';Password='+edtSenhaOracle.Text+'';
//
   ADOMySQL.Connected := true;

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
     AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_OFERTA.TXT' );
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
//
//   ADOSQLServer.Connected := false;
end;



procedure TFrmSmRonyMG.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmRonyMG.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmRonyMG.CkbProdLojaClick(Sender: TObject);
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

procedure TFrmSmRonyMG.FormCreate(Sender: TObject);
begin
  inherited;

end;

//procedure Dourado.FormCreate(Sender: TObject);
//begin
//  inherited;
////  Left:=(Screen.Width-Width)  div 2;
////  Top:=(Screen.Height-Height) div 2;
//end;

procedure TFrmSmRonyMG.GeraCustoRep;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;


     SQL.Add('   SELECT   ');
     SQL.Add('   	PRODUTOS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('   	REPLACE(COALESCE(PRODUTOS.PRO_CUSTOREAL, 0), '','', ''.'') AS VAL_CUSTO_REP   ');
     SQL.Add('   FROM   ');
     SQL.Add('    PRODUTOS AS PRODUTOS   ');
     SQL.Add('   WHERE PRODUTOS.PRO_BARRA <> 0   ');



    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Inc(NumLinha);

        COD_PRODUTO := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_CUSTO_REP = '''+QryPrincipal2.FieldByName('VAL_CUSTO_REP').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');


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

procedure TFrmSmRonyMG.GeraEstoqueVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   '); 
     SQL.Add('   	PRODUTOS.CODPROD_PRODUTOS AS COD_PRODUTO,   '); 
     SQL.Add('   	REPLACE(COALESCE(PRODLOJA.QUANTIDADE, 1), '','', ''.'') AS QTD_EST_ATUAL    '); 
     SQL.Add('   FROM   '); 
     SQL.Add('   	CE_PRODUTOS AS PRODUTOS   '); 
     SQL.Add('   LEFT JOIN PRODUTOSEMPRESA AS PRODLOJA ON PRODUTOS.CODBARRA_PRODUTOS = PRODLOJA.BARRAS   '); 


    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

         Inc(NumLinha);

        COD_PRODUTO := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET QTD_EST_ATUAL = '''+QryPrincipal2.FieldByName('QTD_EST_ATUAL').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');


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

procedure TFrmSmRonyMG.GerarCest;
var
   count : integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(CEST.CES_ID, 999) AS COD_CEST,   ');
     SQL.Add('       CASE   ');
     SQL.Add('   		    WHEN PRODUTO.CES_CODIGO = ''00.000.00'' THEN ''9999999''   ');
     SQL.Add('   				ELSE COALESCE(REPLACE(PRODUTO.CES_CODIGO, ''.'', ''''), ''9999999'')    ');
     SQL.Add('   		 END AS NUM_CEST,     ');
     SQL.Add('       ''A DEFINIR'' AS DES_CEST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     SQL.Add('   LEFT JOIN CEST ON CEST.CES_CODIGO = PRODUTO.CES_CODIGO   ');

//   SQL.Add('   WHERE PRODUTOS.COD_LOJA = '+CbxLoja.Text+'   ');

    //SQL.Add('ORDER BY PRODUTOS.ATIVO');

    Open;
    First;

    count := 0;


    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(count);
      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      //Layout.FieldByName('COD_CEST').AsInteger := count;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarCliente;
begin

   inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('       SELECT      ');
     SQL.Add('               CLIENTES.CLI_ID AS COD_CLIENTE,      ');
     SQL.Add('               CLIENTES.CLI_NOME AS DES_CLIENTE,      ');
     SQL.Add('               COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(CLIENTES.CLI_CPF, '''')) AS NUM_CGC,      ');
     SQL.Add('                  ');
     SQL.Add('   			CASE   ');
     SQL.Add('   				WHEN CLIENTES.CLI_TIPOPES = ''F'' AND CLIENTES.CLI_INSCRICAO IS NOT NULL THEN ''''   ');
     SQL.Add('   				ELSE CLIENTES.CLI_INSCRICAO    ');
     SQL.Add('   			END AS NUM_INSC_EST,      ');
     SQL.Add('                  ');
     SQL.Add('   			COALESCE(CLIENTES.CLI_ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,      ');
     SQL.Add('               CLIENTES.CLI_CIDADE AS DES_CIDADE,      ');
     SQL.Add('               CLIENTES.CLI_ESTADO AS DES_SIGLA,      ');
     SQL.Add('               CLIENTES.CLI_CEP AS NUM_CEP,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_TELEFONE, '''') AS NUM_FONE,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_CELULARFAX, '''') AS NUM_FAX,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_CONTATO, CLIENTES.CLI_NOME) AS DES_CONTATO,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTES.CLI_SEXO = ''F'' THEN 1      ');
     SQL.Add('                   ELSE 0      ');
     SQL.Add('               END AS FLG_SEXO,      ');
     SQL.Add('                     ');
     SQL.Add('               0 AS VAL_LIMITE_CRETID,      ');
     SQL.Add('               COALESCE(CLIENTES.MAXCOMPRAS, 0) AS VAL_LIMITE_CONV,      ');
     SQL.Add('               0 AS VAL_DEBITO,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_RENDA, 0) AS VAL_RENDA,      ');
     SQL.Add('                  ');
     SQL.Add('   			CASE   ');
     SQL.Add('   				WHEN CLIENTES.MAXCOMPRAS > 0 THEN 99999   ');
     SQL.Add('   				ELSE 0   ');
     SQL.Add('   			END AS COD_CONVENIO,      ');
     SQL.Add('                  ');
     SQL.Add('   			0 AS COD_STATUS_PDV,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTES.CLI_TIPOPES = ''J'' THEN ''S''      ');
     SQL.Add('                   ELSE ''N''      ');
     SQL.Add('               END AS FLG_EMPRESA,      ');
     SQL.Add('                     ');
     SQL.Add('               ''N'' AS FLG_CONVENIO,      ');
     SQL.Add('               ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('               CLIENTES.CLI_DATACADASTRO AS DTA_CADASTRO,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTES.CLI_NUMERO = '''' THEN ''S/N''      ');
     SQL.Add('                   ELSE COALESCE(CLIENTES.CLI_NUMERO, ''S/N'')       ');
     SQL.Add('               END AS NUM_ENDERECO,      ');
     SQL.Add('                 ');
     SQL.Add('               COALESCE(CLIENTES.CLI_RG, '''') AS NUM_RG,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTES.CLI_ESTADO_CIVIL = ''Casado(a)'' THEN 1      ');
     SQL.Add('                   ELSE 0      ');
     SQL.Add('               END AS FLG_EST_CIVIL,      ');
     SQL.Add('                     ');
     SQL.Add('               '''' AS NUM_CELULAR,      ');
     SQL.Add('               '''' AS DTA_ALTERACAO,   ');
     SQL.Add('   			   ');
     SQL.Add('CASE   ');
     SQL.Add(' WHEN CLIENTES.CLI_TIPOPES = ''F'' AND CLIENTES.CLI_INSCRICAO IS NOT NULL THEN CONCAT(COALESCE(CLIENTES.CLI_OBSERVACAO, ''''),'' - '', ''IE: '', CLIENTES.CLI_INSCRICAO,'' - '', ''TELEFONE 2: '', CLIENTES.CLI_TELEFONE1, ''TELEFONE 3: '', CLIENTES.CLI_TELEFONE2)');
     SQL.Add(' ELSE CONCAT(COALESCE(CLIENTES.CLI_OBSERVACAO, ''''), ''TELEFONE 2: '', CLIENTES.CLI_TELEFONE1, ''TELEFONE 3: '', CLIENTES.CLI_TELEFONE2)   ');
     SQL.Add('END AS DES_OBSERVACAO,      ');
     SQL.Add('                  ');
     SQL.Add('   			COALESCE(CLIENTES.CLI_COMPLEMENTO, ''A DEFINIR'') AS DES_COMPLEMENTO,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_EMAIL, '''') AS DES_EMAIL,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_NOMEFANTASIA, CLIENTES.CLI_NOME) AS DES_FANTASIA,      ');
     SQL.Add('               CLIENTES.CLI_DATANASCIMENTO AS DTA_NASCIMENTO,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_PAI, '''') AS DES_PAI,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_MAE, '''') AS DES_MAE,      ');
     SQL.Add('               COALESCE(CLIENTES.CLI_CONJUGE, '''') AS DES_CONJUGE,      ');
     SQL.Add('               '''' AS NUM_CPF_CONJUGE,      ');
     SQL.Add('               0 AS VAL_DEB_CONV,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTES.CLI_ATIVO = ''I'' THEN ''S''      ');
     SQL.Add('                   ELSE ''N''      ');
     SQL.Add('               END AS INATIVO,      ');
     SQL.Add('                 ');
     SQL.Add('               '''' AS DES_MATRICULA,      ');
     SQL.Add('               ''N'' AS NUM_CGC_ASSOCIADO,      ');
     SQL.Add('               ''N'' AS FLG_PROD_RURAL,      ');
     SQL.Add('               0 AS COD_STATUS_PDV_CONV,      ');
     SQL.Add('               ''S'' AS FLG_ENVIA_CODIGO,      ');
     SQL.Add('               '''' AS DTA_NASC_CONJUGE,      ');
     SQL.Add('               0 AS COD_CLASSIF      ');
     SQL.Add('           FROM      ');
     SQL.Add('               CLIENTES   ');


    Open;
    First;

//    TotalCont := SetCountTotal(SQL.Text);
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);


//      Layout.SetValues(QryPrincipal2, NumLinha, TotalCont);
      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);
      Layout.FieldByName('NUM_CPF_CONJUGE').AsString := StrRetNums(Layout.FieldByName('NUM_CPF_CONJUGE').AsString);

      if (StrRetNums(Layout.FieldByName('NUM_ENDERECO').AsString) = '') then
         Layout.FieldByName('NUM_ENDERECO').AsString := 'S/N'
      else if strtoint(StrRetNums(Layout.FieldByName('NUM_ENDERECO').AsString)) = 0 then
         Layout.FieldByName('NUM_ENDERECO').AsString := 'S/N'
      else
         Layout.FieldByName('NUM_ENDERECO').AsString := StrRetNums(Layout.FieldByName('NUM_ENDERECO').AsString);

      if StrRetNums(Layout.FieldByName('NUM_RG').AsString) = '' then
        Layout.FieldByName('NUM_RG').AsString := ''
      else
        Layout.FieldByName('NUM_RG').AsString := StrRetNums(Layout.FieldByName('NUM_RG').AsString);

      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

//      if Layout.FieldByName('DTA_NASCIMENTO').AsString <> '' then
//      begin
         Layout.FieldByName('DTA_NASCIMENTO').AsDateTime := FieldByName('DTA_NASCIMENTO').AsDateTime;
//      end;


//      if Layout.FieldByName('DTA_CADASTRO').AsString <> '' then
//      begin
        Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;
        //Layout.FieldByName('DTA_NASCIMENTO').AsDateTime := FieldByName('DTA_NASCIMENTO').AsDateTime;
//      end;

      //Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;
      //if Layout.FieldByName('DTA_ALTERACAO').AsString <> '' then
      //begin
      //  Layout.FieldByName('DTA_ALTERACAO').AsDateTime := FieldByName('DTA_ALTERACAO').AsDateTime;
      //end;

      Layout.FieldByName('NUM_FONE').AsString := StrRetNums( FieldByName('NUM_FONE').AsString );
//
      if Layout.FieldByName('FLG_EMPRESA').AsString = 'S' then
      begin
        if not ValidaCGC(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';
      end
      else
        if not ValidaCpf(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';
//
//    if Layout.FieldByName('NUM_CEP').AsString = '' then
//      Layout.FieldByName('NUM_CEP').AsString := '28922270';




      Layout.FieldByName('DES_OBSERVACAO').AsString := StrLBReplace(FieldByName('DES_OBSERVACAO').AsString);
      Layout.FieldByName('DES_EMAIL').AsString := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');
      Layout.FieldByName('DES_ENDERECO').AsString := StrReplace(StrLBReplace(FieldByName('DES_ENDERECO').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarCodigoBarras;
var
 count, count1 : Integer;
 codigoBarra : string;
begin
  inherited;
   with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('  SELECT      ');
     SQL.Add('      REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,      ');
     SQL.Add('      CASE   ');
     SQL.Add('   				WHEN PRODUTO.PRO_BALANCA = ''S'' THEN PRODUTO.PRO_CODBALANCA   ');
     SQL.Add('   				ELSE PRODUTO.PRO_EAN1    ');
     SQL.Add('   		END AS COD_EAN      ');
     SQL.Add('  FROM      ');
     SQL.Add('      PRODUTO      ');
//     SQL.Add('  WHERE PRODUTO.PRO_EAN2 IS NULL    ');
//     SQL.Add('  WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''     ');
     SQL.Add('                 ');
     SQL.Add('  UNION ALL      ');
     SQL.Add('                 ');
     SQL.Add('  SELECT      ');
     SQL.Add('      REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,      ');
     SQL.Add('      CASE   ');
     SQL.Add('   				WHEN PRODUTO.PRO_BALANCA = ''S'' THEN PRODUTO.PRO_CODBALANCA   ');
     SQL.Add('   				ELSE PRODUTO.PRO_EAN2    ');
     SQL.Add('   		END AS COD_EAN      ');
     SQL.Add('  FROM      ');
     SQL.Add('      PRODUTO      ');
     SQL.Add('  WHERE PRODUTO.PRO_EAN2 IS NOT NULL     ');
//     SQL.Add('  WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''     ');





    Open;
    First;
    //count := 99999;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);
      //Layout.FieldByName('COD_EAN').AsString := TiraZerosEsquerda(Layout.FieldByName('COD_EAN').AsString);

      if ( Length(TiraZerosEsquerda(Layout.FieldByName('COD_EAN').AsString)) < 8 ) then
        Layout.FieldByName('COD_EAN').AsString := GerarPLU( Layout.FieldByName('COD_EAN').AsString );

      if( not CodBarrasValido(Layout.FieldByName('COD_EAN').AsString) ) then
        Layout.FieldByName('COD_EAN').AsString := '';



      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarComposicao;
begin
  inherited;
  with QryPrincipal2 do
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

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

//      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//
//      Layout.FieldByName('COD_PRODUTO_COMP').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO_COMP').AsString );

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('        CLIENTES.CLI_ID AS COD_CLIENTE,   ');
     SQL.Add('        30 AS NUM_CONDICAO,   ');
     SQL.Add('        2 AS COD_CONDICAO,   ');
     SQL.Add('        1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('        CLIENTES   ');

    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarCondPagForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('        FORNECEDORES.FOR_ID AS COD_FORNECEDOR,   ');
     SQL.Add('        30 AS NUM_CONDICAO,   ');
     SQL.Add('        2 AS COD_CONDICAO,   ');
     SQL.Add('        8 AS COD_ENTIDADE,   ');
     SQL.Add('        COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.FOR_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(FORNECEDORES.FOR_CPF, '''')) AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('        FORNECEDORES   ');

    Open;

    First;

    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarDecomposicao;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTOS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('       SUBPRODUTOS.PRO_SUBCODIGO AS COD_PRODUTO_DECOM,   ');
     SQL.Add('       1 AS QTD_DECOMP,   ');
     SQL.Add('       ''UN'' AS DES_UNIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SUBPRODUTOS   ');
     SQL.Add('   LEFT JOIN PRODUTOS ON PRODUTOS.PRO_CODIGO = SUBPRODUTOS.PRO_CODIGO   ');
     SQL.Add('   LEFT JOIN FORNECEDOR ON FORNECEDOR.FOR_CODIGO = PRODUTOS.FOR_CODIGO   ');


    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//
      Layout.FieldByName('COD_PRODUTO_DECOM').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO_DECOM').AsString );

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarDivisaoForn;
begin
  inherited;
    with QryPrincipal2 do
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

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

      Layout.FieldByName('DES_EMAIL').AsString := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmRonyMG.GerarFinanceiroPagar(Aberto: String);
var
  NUM_DOCTO : string;
  COD_PARCEIRO, CORRIGIR  : Integer;

begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;
    if Aberto = '1' then
    begin
      //ABERTO

     SQL.Add('   SELECT   ');
     SQL.Add('       1 AS TIPO_PARCEIRO,   ');
     SQL.Add('       PAGAR.FOR_ID AS COD_PARCEIRO,   ');
     SQL.Add('       0 AS TIPO_CONTA,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       PAGAR.DOCUMENTO AS NUM_DOCTO,   ');
     SQL.Add('       999 AS COD_BANCO,   ');
     SQL.Add('       '''' AS DES_BANCO,   ');
     SQL.Add('       PAGAR.DATAEMISSAO AS DTA_EMISSAO,   ');
     SQL.Add('       PAGAR.DATAVENCIMENTO AS DTA_VENCIMENTO,   ');
     SQL.Add('       PAGAR.VALORORIGINAL AS VAL_PARCELA,   ');
     SQL.Add('       COALESCE(PAGAR.JUROS, 0) AS VAL_JUROS,   ');
     SQL.Add('       COALESCE(PAGAR.DESCONTO, 0) AS VAL_DESCONTO,   ');
     SQL.Add('       ''N'' AS FLG_QUITADO,   ');
     SQL.Add('       '''' AS DTA_QUITADA,   ');
     SQL.Add('       998 AS COD_CATEGORIA,   ');
     SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
     SQL.Add('       1 AS NUM_PARCELA,   ');
     SQL.Add('       1 AS QTD_PARCELA,   ');
     SQL.Add('       1 AS COD_LOJA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.FOR_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(FORNECEDORES.FOR_CPF, '''')) AS NUM_CGC,   ');
     SQL.Add('       0 AS NUM_BORDERO,   ');
     SQL.Add('       COALESCE(PAGAR.ENT_NUMNOTA, 0) AS NUM_NF,   ');
     SQL.Add('       '''' AS NUM_SERIE_NF,   ');
     SQL.Add('       PAGAR.VALORAPAGAR AS VAL_TOTAL_NF,   ');
     SQL.Add('       COALESCE(PAGAR.OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS NUM_PDV,   ');
     SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       0 AS COD_MOTIVO,   ');
     SQL.Add('       0 AS COD_CONVENIO,   ');
     SQL.Add('       0 AS COD_BIN,   ');
     SQL.Add('       '''' AS DES_BANDEIRA,   ');
     SQL.Add('       '''' AS DES_REDE_TEF,   ');
     SQL.Add('       0 AS VAL_RETENCAO,   ');
     SQL.Add('       0 AS COD_CONDICAO,   ');
     SQL.Add('       '''' AS DTA_PAGTO,   ');
     SQL.Add('       PAGAR.DATALANCAMENTO AS DTA_ENTRADA,   ');
     SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
     SQL.Add('       '''' AS COD_BARRA,   ');
     SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
     SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
     SQL.Add('       '''' AS DES_TITULAR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       0 AS VAL_CREDITO,   ');
     SQL.Add('       ''999'' AS COD_BANCO_PGTO,   ');
     SQL.Add('       ''PAGTO'' AS DES_CC,   ');
     SQL.Add('       0 AS COD_BANDEIRA,   ');
     SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
     SQL.Add('       1 AS NUM_SEQ_FIN,   ');
     SQL.Add('       0 AS COD_COBRANCA,   ');
     SQL.Add('       '''' AS DTA_COBRANCA,   ');
     SQL.Add('       ''N'' AS FLG_ACEITE,   ');
     SQL.Add('       0 AS TIPO_ACEITE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PAGAR   ');
     SQL.Add('   LEFT JOIN FORNECEDORES ON FORNECEDORES.FOR_ID = PAGAR.FOR_ID   ');
     SQL.Add('   WHERE PAGAR.DATAPAGAMENTO IS NULL   ');
     SQL.Add('   AND PAGAR.VALORPAGO = 0   ');


      //FIM ABERTO
    end
    else
    begin
      //QUITADO

         SQL.Add('   SELECT   ');
         SQL.Add('       1 AS TIPO_PARCEIRO,   ');
         SQL.Add('       PAGAR.FOR_ID AS COD_PARCEIRO,   ');
         SQL.Add('       0 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       PAGAR.DOCUMENTO AS NUM_DOCTO,   ');
         SQL.Add('       999 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       PAGAR.DATAEMISSAO AS DTA_EMISSAO,   ');
         SQL.Add('       PAGAR.DATAVENCIMENTO AS DTA_VENCIMENTO,   ');
         SQL.Add('       PAGAR.VALORORIGINAL AS VAL_PARCELA,   ');
         SQL.Add('       COALESCE(PAGAR.JUROS, 0) AS VAL_JUROS,   ');
         SQL.Add('       COALESCE(PAGAR.DESCONTO, 0) AS VAL_DESCONTO,   ');
         SQL.Add('       ''S'' AS FLG_QUITADO,   ');
         SQL.Add('       CASE WHEN PAGAR.DATAEMISSAO < PAGAR.DATAPAGAMENTO THEN PAGAR.DATAEMISSAO ELSE PAGAR.DATAPAGAMENTO END AS DTA_QUITADA,   ');
         SQL.Add('       998 AS COD_CATEGORIA,   ');
         SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       1 AS NUM_PARCELA,   ');
         SQL.Add('       1 AS QTD_PARCELA,   ');
         SQL.Add('       1 AS COD_LOJA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.FOR_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(FORNECEDORES.FOR_CPF, '''')) AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       COALESCE(PAGAR.ENT_NUMNOTA, 0) AS NUM_NF,   ');
         SQL.Add('       '''' AS NUM_SERIE_NF,   ');
         SQL.Add('       PAGAR.VALORORIGINAL AS VAL_TOTAL_NF,   ');
         SQL.Add('       COALESCE(PAGAR.OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
         SQL.Add('       0 AS NUM_PDV,   ');
         SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('       0 AS COD_MOTIVO,   ');
         SQL.Add('       0 AS COD_CONVENIO,   ');
         SQL.Add('       0 AS COD_BIN,   ');
         SQL.Add('       '''' AS DES_BANDEIRA,   ');
         SQL.Add('       '''' AS DES_REDE_TEF,   ');
         SQL.Add('       0 AS VAL_RETENCAO,   ');
         SQL.Add('       0 AS COD_CONDICAO,   ');
         SQL.Add('       PAGAR.DATAPAGAMENTO AS DTA_PAGTO,   ');
         SQL.Add('       PAGAR.DATALANCAMENTO AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       '''' AS DES_TITULAR,   ');
         SQL.Add('       30 AS NUM_CONDICAO,   ');
         SQL.Add('       0 AS VAL_CREDITO,   ');
         SQL.Add('       ''999'' AS COD_BANCO_PGTO,   ');
         SQL.Add('       ''PAGTO'' AS DES_CC,   ');
         SQL.Add('       0 AS COD_BANDEIRA,   ');
         SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
         SQL.Add('       1 AS NUM_SEQ_FIN,   ');
         SQL.Add('       0 AS COD_COBRANCA,   ');
         SQL.Add('       '''' AS DTA_COBRANCA,   ');
         SQL.Add('       ''N'' AS FLG_ACEITE,   ');
         SQL.Add('       0 AS TIPO_ACEITE   ');
         SQL.Add('   FROM   ');
         SQL.Add('       PAGAR   ');
         SQL.Add('   LEFT JOIN FORNECEDORES ON FORNECEDORES.FOR_ID = PAGAR.FOR_ID   ');
         SQL.Add('   WHERE PAGAR.DATAPAGAMENTO IS NOT NULL   ');
         SQL.Add('   AND PAGAR.VALORPAGO > 0   ');
         SQL.Add('   AND  ');
         SQL.Add('   CAST(PAGAR.DATAPAGAMENTO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
         SQL.Add('   AND');
         SQL.Add('   CAST(PAGAR.DATAPAGAMENTO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');



      //FIM QUITADO
    end;

//    ShowMessage(sql.Text);

    Open;

    First;
    NumLinha := 0;
    CORRIGIR := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(CORRIGIR);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrLBReplace(QryPrincipal2.FieldByName('DES_OBSERVACAO').AsString);
      Layout.FieldByName('NUM_NF').AsString := StrRetNums(QryPrincipal2.FieldByName('NUM_NF').AsString);
      //Layout.FieldByName('NUM_CUPOM_FISCAL').AsString := StrRetNums(QryPrincipal2.FieldByName('NUM_CUPOM_FISCAL').AsString);

      //Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);
      //Layout.FieldByName('DTA_VENCIMENTO').AsString := '';
      if QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsString <> '' then
        Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);
      //Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);

        //Layout.FieldByName('DTA_QUITADA').AsString := '';
        if QryPrincipal2.FieldByName('DTA_QUITADA').AsString <> '' then
          Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);

        //Layout.FieldByName('DTA_PAGTO').AsString := '';
        if QryPrincipal2.FieldByName('DTA_PAGTO').AsString <> '' then
          Layout.FieldByName('DTA_PAGTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_PAGTO').AsDateTime);

        Layout.FieldByName('DTA_EMISSAO').AsString := '';
        if QryPrincipal2.FieldByName('DTA_EMISSAO').AsString <> '' then
          Layout.FieldByName('DTA_EMISSAO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);

        //if QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsString <> '' then
          //Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);

        //Layout.FieldByName('DTA_ENTRADA').AsString := '';
        if QryPrincipal2.FieldByName('DTA_ENTRADA').AsString <> '' then
          Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime);

      //        if Layout.FieldByName('NUM_NF').AsString = '' then
//        begin
//          Layout.FieldByName('NUM_NF').AsString := Layout.FieldByName('NUM_DOCTO').AsString;
//        end;

        //GERAR PARCELA
//        if(NumDocto = QryPrincipal2.FieldByName('NUM_DOCTO').AsInteger) and
//          (CodParceiro = QryPrincipal2.FieldByName('COD_PARCEIRO').AsInteger) then
//        begin
//          inc(NumParcela);
//          Layout.FieldByName('NUM_PARCELA').AsInteger := NumParcela;
//          //ShowMessage('IF');
//        end
//        else
//        begin
//          NumDocto := QryPrincipal2.FieldByName('NUM_DOCTO').AsInteger;
//          CodParceiro := QryPrincipal2.FieldByName('COD_PARCEIRO').AsInteger;
//          NumParcela := 1;
//          //ShowMessage('ELSE');
//        end;
//        //FIM GERA PARCELA


      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarFinanceiroReceber(Aberto: String);
var
   codParceiro : Integer;
   numDocto : String;
   count : integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;
    if Aberto = '1' then
    begin
      //ABERTO
       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('        0 AS TIPO_PARCEIRO,   ');
       SQL.Add('        RECEBER.CLI_ID AS COD_PARCEIRO,   ');
       SQL.Add('        1 AS TIPO_CONTA,   ');
       SQL.Add('        8 AS COD_ENTIDADE,   ');
       SQL.Add('        RECEBER.DOCUMENTO AS NUM_DOCTO,   ');
       SQL.Add('        999 AS COD_BANCO,   ');
       SQL.Add('        '''' AS DES_BANCO,   ');
       SQL.Add('        RECEBER.DATAEMISSAO AS DTA_EMISSAO,   ');
       SQL.Add('        RECEBER.DATAVENCIMENTO AS DTA_VENCIMENTO,   ');
       SQL.Add('        RECEBER.VALORARECEBER AS VAL_PARCELA,   ');
       SQL.Add('        RECEBER.JUROS AS VAL_JUROS,   ');
       SQL.Add('        RECEBER.DESCONTO AS VAL_DESCONTO,   ');
       SQL.Add('        ''N'' AS FLG_QUITADO,   ');
       SQL.Add('        '''' AS DTA_QUITADA,   ');
       SQL.Add('        997 AS COD_CATEGORIA,   ');
       SQL.Add('        997 AS COD_SUBCATEGORIA,   ');
       SQL.Add('        1 AS NUM_PARCELA,   ');
       SQL.Add('        1 AS QTD_PARCELA,   ');
       SQL.Add('        1 AS COD_LOJA,   ');
       SQL.Add('        COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(CLIENTES.CLI_CPF, '''')) AS NUM_CGC,   ');
       SQL.Add('        0 AS NUM_BORDERO,   ');
       SQL.Add('        RECEBER.DOCUMENTO AS NUM_NF,   ');
       SQL.Add('        '''' AS NUM_SERIE_NF,   ');
       SQL.Add('        RECEBER.VALORORIGINAL AS VAL_TOTAL_NF,   ');
       SQL.Add('        COALESCE(RECEBER.OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
       SQL.Add('        0 AS NUM_PDV,   ');
       SQL.Add('        0 AS NUM_CUPOM_FISCAL,   ');
       SQL.Add('        0 AS COD_MOTIVO,   ');
       SQL.Add('        0 AS COD_CONVENIO,   ');
       SQL.Add('        0 AS COD_BIN,   ');
       SQL.Add('        '''' AS DES_BANDEIRA,   ');
       SQL.Add('        '''' AS DES_REDE_TEF,   ');
       SQL.Add('        0 AS VAL_RETENCAO,   ');
       SQL.Add('        0 AS COD_CONDICAO,   ');
       SQL.Add('        '''' AS DTA_PAGTO,   ');
       SQL.Add('        RECEBER.DATALANCAMENTO AS DTA_ENTRADA,   ');
       SQL.Add('        '''' AS NUM_NOSSO_NUMERO,   ');
       SQL.Add('        '''' AS COD_BARRA,   ');
       SQL.Add('        ''N'' AS FLG_BOLETO_EMIT,   ');
       SQL.Add('        '''' AS NUM_CGC_CPF_TITULAR,   ');
       SQL.Add('        '''' AS DES_TITULAR,   ');
       SQL.Add('        30 AS NUM_CONDICAO,   ');
       SQL.Add('        0 AS VAL_CREDITO,   ');
       SQL.Add('        999 AS COD_BANCO_PGTO,   ');
       SQL.Add('        ''RECEBTO'' AS DES_CC,   ');
       SQL.Add('        0 AS COD_BANDEIRA,   ');
       SQL.Add('        '''' AS DTA_PRORROGACAO,   ');
       SQL.Add('        1 AS NUM_SEQ_FIN,   ');
       SQL.Add('        0 AS COD_COBRANCA,   ');
       SQL.Add('        '''' AS DTA_COBRANCA,   ');
       SQL.Add('        ''N'' AS FLG_ACEITE,   ');
       SQL.Add('        0 AS TIPO_ACEITE   ');
       SQL.Add('   FROM   ');
       SQL.Add('        RECEBER   ');
       SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_ID = RECEBER.CLI_ID   ');
       SQL.Add('   WHERE RECEBER.DATARECEBIMENTO IS NULL   ');
       SQL.Add('   AND RECEBER.VALORARECEBER > 0   ');


      //FIM ABERTO
    end
    else
    begin
      // QUITADO

         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('        0 AS TIPO_PARCEIRO,   ');
         SQL.Add('        RECEBER.CLI_ID AS COD_PARCEIRO,   ');
         SQL.Add('        1 AS TIPO_CONTA,   ');
         SQL.Add('        8 AS COD_ENTIDADE,   ');
         SQL.Add('        RECEBER.DOCUMENTO AS NUM_DOCTO,   ');
         SQL.Add('        999 AS COD_BANCO,   ');
         SQL.Add('        '''' AS DES_BANCO,   ');
         SQL.Add('        RECEBER.DATAEMISSAO AS DTA_EMISSAO,   ');
         SQL.Add('        RECEBER.DATAVENCIMENTO AS DTA_VENCIMENTO,   ');
         SQL.Add('        RECEBER.VALORRECEBIDO AS VAL_PARCELA,   ');
         SQL.Add('        RECEBER.JUROS AS VAL_JUROS,   ');
         SQL.Add('        RECEBER.DESCONTO AS VAL_DESCONTO,   ');
         SQL.Add('        ''S'' AS FLG_QUITADO,   ');
         SQL.Add('        RECEBER.DATARECEBIMENTO AS DTA_QUITADA,   ');
         SQL.Add('        997 AS COD_CATEGORIA,   ');
         SQL.Add('        997 AS COD_SUBCATEGORIA,   ');
         SQL.Add('        1 AS NUM_PARCELA,   ');
         SQL.Add('        1 AS QTD_PARCELA,   ');
         SQL.Add('        1 AS COD_LOJA,   ');
         SQL.Add('        COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(CLIENTES.CLI_CPF, '''')) AS NUM_CGC,   ');
         SQL.Add('        0 AS NUM_BORDERO,   ');
         SQL.Add('        RECEBER.DOCUMENTO AS NUM_NF,   ');
         SQL.Add('        '''' AS NUM_SERIE_NF,   ');
         SQL.Add('        RECEBER.VALORORIGINAL AS VAL_TOTAL_NF,   ');
         SQL.Add('        COALESCE(RECEBER.OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
         SQL.Add('        0 AS NUM_PDV,   ');
         SQL.Add('        0 AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('        0 AS COD_MOTIVO,   ');
         SQL.Add('        0 AS COD_CONVENIO,   ');
         SQL.Add('        0 AS COD_BIN,   ');
         SQL.Add('        '''' AS DES_BANDEIRA,   ');
         SQL.Add('        '''' AS DES_REDE_TEF,   ');
         SQL.Add('        0 AS VAL_RETENCAO,   ');
         SQL.Add('        0 AS COD_CONDICAO,   ');
         SQL.Add('        RECEBER.DATARECEBIMENTO AS DTA_PAGTO,   ');
         SQL.Add('        RECEBER.DATALANCAMENTO AS DTA_ENTRADA,   ');
         SQL.Add('        '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('        '''' AS COD_BARRA,   ');
         SQL.Add('        ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('        '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('        '''' AS DES_TITULAR,   ');
         SQL.Add('        30 AS NUM_CONDICAO,   ');
         SQL.Add('        0 AS VAL_CREDITO,   ');
         SQL.Add('        999 AS COD_BANCO_PGTO,   ');
         SQL.Add('        ''RECEBTO'' AS DES_CC,   ');
         SQL.Add('        0 AS COD_BANDEIRA,   ');
         SQL.Add('        '''' AS DTA_PRORROGACAO,   ');
         SQL.Add('        1 AS NUM_SEQ_FIN,   ');
         SQL.Add('        0 AS COD_COBRANCA,   ');
         SQL.Add('        '''' AS DTA_COBRANCA,   ');
         SQL.Add('        ''N'' AS FLG_ACEITE,   ');
         SQL.Add('        0 AS TIPO_ACEITE   ');
         SQL.Add('   FROM   ');
         SQL.Add('        RECEBER   ');
         SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_ID = RECEBER.CLI_ID   ');
         SQL.Add('   WHERE RECEBER.DATARECEBIMENTO IS NOT NULL   ');
         //SQL.Add('   AND RECEBER.VALORRECEBIDO > 0   ');
         SQL.Add('   AND  ');
         SQL.Add('   CAST(RECEBER.DATALANCAMENTO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
         SQL.Add('   AND');
         SQL.Add('   CAST(RECEBER.DATALANCAMENTO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

      //FIM QUITADO
    end;

    Open;

    First;
    NumLinha := 0;
    codParceiro := 0;
    numDocto := '';
    count := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrLBReplace(QryPrincipal2.FieldByName('DES_OBSERVACAO').AsString);
      Layout.FieldByName('NUM_NF').AsString := StrRetNums(QryPrincipal2.FieldByName('NUM_NF').AsString);
      Layout.FieldByName('NUM_CUPOM_FISCAL').AsString := StrRetNums(QryPrincipal2.FieldByName('NUM_CUPOM_FISCAL').AsString);


        if QryPrincipal2.FieldByName('DTA_QUITADA').AsString <> '' then
          Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_PAGTO').AsString <> '' then
          Layout.FieldByName('DTA_PAGTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_PAGTO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_EMISSAO').AsString <> '' then
          Layout.FieldByName('DTA_EMISSAO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsString <> '' then
          Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_ENTRADA').AsString <> '' then
          Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime);

        
      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarFinanceiroReceberCartao;
begin
  inherited;
  with QryPrincipal2 do
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

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

//      if( (codParceiro = QryPrincipal2.FieldByName('COD_PARCEIRO').AsInteger) and (numDocto = QryPrincipal2.FieldByName('NUM_DOCTO').AsString) ) then
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
//         numDocto := QryPrincipal2.FieldByName('NUM_DOCTO').AsString;
//         codParceiro := QryPrincipal2.FieldByName('COD_PARCEIRO').AsInteger;
//      end;

      Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime);
      Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);
      Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);

//      if Aberto = '1' then
//      begin
//        Layout.FieldByName('DTA_QUITADA').AsString := '';
//        Layout.FieldByName('DTA_PAGTO').AsString := '';
//      end
//      else
//      begin
        Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);
        Layout.FieldByName('DTA_PAGTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_PAGTO').AsDateTime);
//      end;

      Layout.FieldByName('DTA_COBRANCA').AsDateTime:= QryPrincipal2.FieldByName('DTA_COBRANCA').AsDateTime;

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');

      Layout.FieldByName('COD_BARRA').AsString := StrRetNums(Layout.FieldByName('COD_BARRA').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarFornecedor;
var
   observacao, email, inscEst : string;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('           SELECT      ');
     SQL.Add('               FORNECEDORES.FOR_ID AS COD_FORNECEDOR,      ');
     SQL.Add('               FORNECEDORES.FOR_NOME AS DES_FORNECEDOR,    ');
     SQL.Add('   			   ');
     SQL.Add('   			CASE   ');
     SQL.Add('   				WHEN FORNECEDORES.FOR_FANTASIA = '''' THEN FORNECEDORES.FOR_NOME   ');
     SQL.Add('   				ELSE COALESCE(FORNECEDORES.FOR_FANTASIA, FORNECEDORES.FOR_NOME)    ');
     SQL.Add('   			END AS DES_FANTASIA,   ');
     SQL.Add('   			     ');
     SQL.Add('   			CASE   ');
     SQL.Add('   				WHEN FORNECEDORES.FOR_CGC = '''' THEN FORNECEDORES.FOR_CPF   ');
     SQL.Add('   				ELSE COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.FOR_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(FORNECEDORES.FOR_CPF, ''''))    ');
     SQL.Add('   			END AS NUM_CGC,   ');
     SQL.Add('   			      ');
     SQL.Add('               FORNECEDORES.FOR_INSCRICAO AS NUM_INSC_EST,      ');
     SQL.Add('               COALESCE(FORNECEDORES.FOR_ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,      ');
     SQL.Add('               COALESCE(FORNECEDORES.FOR_BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,      ');
     SQL.Add('               FORNECEDORES.FOR_CIDADE AS DES_CIDADE,      ');
     SQL.Add('               FORNECEDORES.FOR_ESTADO AS DES_SIGLA,      ');
     SQL.Add('               FORNECEDORES.FOR_CEP AS NUM_CEP,      ');
     SQL.Add('               COALESCE(FORNECEDORES.FOR_TELEFONE, '''') AS NUM_FONE,      ');
     SQL.Add('               COALESCE(FORNECEDORES.FOR_CELULARFAX, '''') AS NUM_FAX,      ');
     SQL.Add('               COALESCE(FORNECEDORES.FOR_CONTATO, COALESCE(FORNECEDORES.FOR_NOMEREPRESENTANTE, '''')) AS DES_CONTATO,      ');
     SQL.Add('               0 AS QTD_DIA_CARENCIA,      ');
     SQL.Add('               0 AS NUM_FREQ_VISITA,      ');
     SQL.Add('               0 AS VAL_DESCONTO,      ');
     SQL.Add('               0 AS NUM_PRAZO,      ');
     SQL.Add('               ''N'' AS ACEITA_DEVOL_MER,      ');
     SQL.Add('               ''N'' AS CAL_IPI_VAL_BRUTO,      ');
     SQL.Add('               ''N'' AS CAL_ICMS_ENC_FIN,      ');
     SQL.Add('               ''N'' AS CAL_ICMS_VAL_IPI,      ');
     SQL.Add('               ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('               FORNECEDORES.FOR_CODIGO AS COD_FORNECEDOR_ANT,      ');
     SQL.Add('               COALESCE(FORNECEDORES.FOR_NUMERO, ''S/N'') AS NUM_ENDERECO,      ');
     SQL.Add('               COALESCE(FORNECEDORES.FOR_OBSERVACAO, CONCAT(COALESCE(FORNECEDORES.FOR_TELEFONE2, ''''), '' '', FORNECEDORES.FOR_TELREPRESENTANTE1)) AS DES_OBSERVACAO,      ');
     SQL.Add('               COALESCE(FORNECEDORES.FOR_EMAIL, '''') AS DES_EMAIL,      ');
     SQL.Add('               '''' AS DES_WEB_SITE,      ');
     SQL.Add('               ''N'' AS FABRICANTE,      ');
     SQL.Add('               ''N'' AS FLG_PRODUTOR_RURAL,      ');
     SQL.Add('               0 AS TIPO_FRETE,      ');
     SQL.Add('               ''N'' AS FLG_SIMPLES,      ');
     SQL.Add('               ''N'' AS FLG_SUBSTITUTO_TRIB,      ');
     SQL.Add('               0 AS COD_CONTACCFORN,      ');
     SQL.Add('               ''N'' AS INATIVO,      ');
     SQL.Add('               0 AS COD_CLASSIF,      ');
     SQL.Add('               '''' AS DTA_CADASTRO,      ');
     SQL.Add('               0 AS VAL_CREDITO,      ');
     SQL.Add('               0 AS VAL_DEBITO,      ');
     SQL.Add('               1 AS PED_MIN_VAL,      ');
     SQL.Add('               '''' AS DES_EMAIL_VEND,      ');
     SQL.Add('               '''' AS SENHA_COTACAO,      ');
     SQL.Add('               -1 AS TIPO_PRODUTOR,      ');
     SQL.Add('               '''' AS NUM_CELULAR      ');
     SQL.Add('           FROM      ');
     SQL.Add('               FORNECEDORES     ');

    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);
      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);
      Layout.FieldByName('NUM_ENDERECO').AsString := StrRetNums(Layout.FieldByName('NUM_ENDERECO').AsString);

      if( Layout.FieldByName('NUM_ENDERECO').AsString = '' ) then
         Layout.FieldByName('NUM_ENDERECO').AsString := 'S/N';

      if Length(Layout.FieldByName('NUM_CGC').AsString) > 11 then
      begin
        if not ValidaCGC(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';
      end
      else
        if not ValidaCPF(Layout.FieldByName('NUM_CGC').AsString) then
          Layout.FieldByName('NUM_CGC').AsString := '';

      Layout.FieldByName('NUM_FONE').AsString := StrRetNums( FieldByName('NUM_FONE').AsString );

      observacao := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      email := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');
      inscEst := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);

      if( inscEst = '' ) then
        Layout.FieldByName('NUM_INSC_EST').AsString := 'ISENTO'
      else begin
         if StrToFloat(inscEst) = 0 then
           Layout.FieldByName('NUM_INSC_EST').AsString := ''
         else
           Layout.FieldByName('NUM_INSC_EST').AsString := inscEst;
      end;

//      if Layout.FieldByName('NUM_CEP').AsString = '' then
//        Layout.FieldByName('NUM_CEP').AsString := '28922270';

      Layout.FieldByName('DES_OBSERVACAO').AsString := observacao;
      Layout.FieldByName('DES_EMAIL').AsString := email;
      //Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
    Close;
  end;
end;

procedure TFrmSmRonyMG.GerarGrupo;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       999 AS COD_SECAO,   ');
     SQL.Add('       999 AS COD_GRUPO,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_GRUPO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');

    //SQL.Add('ORDER BY PRODUTOS.ATIVO');

    Open;

    First;

    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarInfoNutricionais;
begin
  inherited;

  with QryPrincipal2 do
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

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

//      Layout.FieldByName('COD_INFO_NUTRICIONAL').AsString := GerarPLU( Layout.FieldByName('COD_INFO_NUTRICIONAL').AsString );

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarNCM;
var
 count : Integer;
begin
  inherited;


  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       0 AS COD_NCM,   ');
     SQL.Add('       COALESCE(NCM.NCM_DESCRICAO, ''A DEFINIR'') AS DES_NCM,   ');
     //SQL.Add('       ''A DEFINIR'' AS DES_NCM,   ');
     SQL.Add('       CASE WHEN PRODUTO.PRO_CODIGONBM = ''00000000'' THEN ''99999998'' ELSE COALESCE(PRODUTO.PRO_CODIGONBM, ''99999999'') END AS NUM_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN -1   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN -1   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(PRODUTO.NAT_CODIGO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       CASE   ');
     SQL.Add('   		    WHEN PRODUTO.CES_CODIGO = ''00.000.00'' THEN ''9999999''   ');
     SQL.Add('   				ELSE COALESCE(REPLACE(PRODUTO.CES_CODIGO, ''.'', ''''), ''9999999'')    ');
     SQL.Add('   		 END AS NUM_CEST,     ');
     SQL.Add('       ''MG'' AS DES_SIGLA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
     SQL.Add('       PRODUTO.PRO_MVA AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     SQL.Add('   LEFT JOIN NCM ON NCM.NCM_COD = PRODUTO.PRO_CODIGONBM   ');
     SQL.Add('   LEFT JOIN NATUREZA_FISCAL AS NF ON (PRODUTO.NAF_CODFISCAL = NF.NAF_CODFISCAL)   ');


    Open;
    First;

    count := 0;


    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(count);
      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_NCM').AsInteger := count;

      if (Layout.FieldByName('DES_NCM').AsString = '')  then
      begin
        Layout.FieldByName('DES_NCM').AsString := 'A DEFINIR';
      end
      else
      begin
        Layout.FieldByName('DES_NCM').AsString := Layout.FieldByName('DES_NCM').AsString;
      end;

//        with QryAux do
//        begin
//          Parameters.ParamByName('COD_NCM').Value := count;
//          Parameters.ParamByName('DES_NCM').Value := QryPrincipal2.FieldByName('DES_NCM').AsString;
//          Parameters.ParamByName('NUM_NCM').Value := QryPrincipal2.FieldByName('NUM_NCM').AsString;
//          Parameters.ParamByName('FLG_NAO_PIS_COFINS').Value := QryPrincipal2.FieldByName('FLG_NAO_PIS_COFINS').AsString;
//          Parameters.ParamByName('TIPO_NAO_PIS_COFINS').Value := QryPrincipal2.FieldByName('TIPO_NAO_PIS_COFINS').AsInteger;
//          Parameters.ParamByName('COD_TAB_SPED').Value := QryPrincipal2.FieldByName('COD_TAB_SPED').AsInteger;
//          Parameters.ParamByName('DES_SIGLA').Value := QryPrincipal2.FieldByName('DES_SIGLA').AsString;
//          Parameters.ParamByName('COD_TRIB_ENTRADA').Value := QryPrincipal2.FieldByName('COD_TRIB_ENTRADA').AsInteger;
//          Parameters.ParamByName('COD_TRIB_SAIDA').Value := QryPrincipal2.FieldByName('COD_TRIB_SAIDA').AsInteger;
//          Parameters.ParamByName('PER_IVA').Value := QryPrincipal2.FieldByName('PER_IVA').AsFloat;
//          ExecSQL;
//        end;



      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarNCMUF;
var
 count : Integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       0 AS COD_NCM,   ');
     SQL.Add('       COALESCE(NCM.NCM_DESCRICAO, ''A DEFINIR'') AS DES_NCM,   ');
     //SQL.Add('       ''A DEFINIR'' AS DES_NCM,   ');
     SQL.Add('       CASE WHEN PRODUTO.PRO_CODIGONBM = ''00000000'' THEN ''99999998'' ELSE COALESCE(PRODUTO.PRO_CODIGONBM, ''99999999'') END AS NUM_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 7 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 99 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 67 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 50 AND PRODUTO.STPC_CODIGO_SAI = 1 AND PRODUTO.PRO_ALIQPIS = ''1.65'' AND PRODUTO.PRO_ALIQPIS_SAI = ''1.65'' AND PRODUTO.PRO_ALIQCOFINS = ''7.60'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''7.60'' THEN -1   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 70 AND PRODUTO.STPC_CODIGO_SAI = 6 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.STPC_CODIGO = 53 AND PRODUTO.STPC_CODIGO_SAI = 7 AND PRODUTO.PRO_ALIQPIS = ''0.0000'' AND PRODUTO.PRO_ALIQPIS_SAI = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS = ''0.0000'' AND PRODUTO.PRO_ALIQCOFINS_SAI = ''0.0000'' THEN -1   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(PRODUTO.NAT_CODIGO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       CASE   ');
     SQL.Add('   		    WHEN PRODUTO.CES_CODIGO = ''00.000.00'' THEN ''9999999''   ');
     SQL.Add('   				ELSE COALESCE(REPLACE(PRODUTO.CES_CODIGO, ''.'', ''''), ''9999999'')    ');
     SQL.Add('   		 END AS NUM_CEST,     ');
     SQL.Add('       ''MG'' AS DES_SIGLA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
     SQL.Add('       PRODUTO.PRO_MVA AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     SQL.Add('   LEFT JOIN NCM ON NCM.NCM_COD = PRODUTO.PRO_CODIGONBM   ');
     SQL.Add('   LEFT JOIN NATUREZA_FISCAL AS NF ON (PRODUTO.NAF_CODFISCAL = NF.NAF_CODFISCAL)   ');


    Open;
    First;

    count := 0;


    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(count);
      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_NCM').AsInteger := count;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarNFClientes;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CAPA.CODIGO AS COD_CLIENTE,   ');
     SQL.Add('       COALESCE(CAPA.NOT_NNOTA, CAPA.NOT_REGISTRO) AS NUM_NF_CLI,   ');
     SQL.Add('       CAPA.NOT_SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('       ''5929'' AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
     SQL.Add('       CAPA.NOT_VALOR AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.NOT_DATA AS DTA_EMISSAO,   ');
     SQL.Add('       CAPA.NOT_DATA AS DTA_ENTRADA,   ');
     SQL.Add('       CAPA.NOT_IPI AS VAL_TOTAL_IPI,   ');
     SQL.Add('       CAPA.NOT_FRETE AS VAL_FRETE,   ');
     SQL.Add('       0 AS VAL_ENC_FINANC,   ');
     SQL.Add('       0 AS VAL_DESC_FINANC,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CPFCGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       '''' AS DES_NATUREZA,   ');
     SQL.Add('       COALESCE(CAPA.NOT_OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADA,   ');
     SQL.Add('       COALESCE(CAPA.NOT_CHAVE, '''') AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       NOTA_CAB AS CAPA   ');
     SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_CODIGO = CAPA.CODIGO   ');
     SQL.Add('WHERE    ');
     SQL.Add(' CAST(CAPA.NOT_DATA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('AND');
     SQL.Add(' CAST(CAPA.NOT_DATA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add(' ORDER BY CAPA.NOT_NNOTA, CAPA.CODIGO, CAPA.NOT_SERIE ');
//    SQL.Add('AND    ');
//    SQL.Add('    CAPA.ID_EMPRESA_A = '+ CbxLoja.Text +'');

//    Parameters.ParamByName('INI').Value := FormatDateTime('dd/mm/yyyy', DtpInicial.Date);
//    Parameters.ParamByName('FIM').Value := FormatDateTime('dd/mm/yyyy', DtpFinal.Date);

    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('DTA_EMISSAO').AsDateTime := QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime;
      Layout.FieldByName('DTA_ENTRADA').AsDateTime := QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime;

      Layout.FieldByName('DES_OBSERVACAO').AsString := StrLBReplace(FieldByName('DES_OBSERVACAO').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarNFFornec;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       CAPA.FOR_ID AS COD_FORNECEDOR,   ');
     SQL.Add('       CAPA.ENT_NUMNOTA AS NUM_NF_FORN,   ');
     SQL.Add('       CASE WHEN CAPA.ENT_SERIE = '''' THEN ''1'' ELSE COALESCE(CAPA.ENT_SERIE, ''1'') END AS NUM_SERIE_NF,   ');
     SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
     SQL.Add('       CAPA.CFO_ID AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
     SQL.Add('       CAPA.ENT_TOTAL_NOTA AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.ENT_DT_EMISSAO AS DTA_EMISSAO,   ');
     SQL.Add('       CAPA.ENT_DT_ENTRADA AS DTA_ENTRADA,   ');
     SQL.Add('       CAPA.ENT_VALOR_IPI AS VAL_TOTAL_IPI,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       CAPA.ENT_VALOR_FRETE AS VAL_FRETE,   ');
     SQL.Add('       0 AS VAL_ACRESCIMO,   ');
     SQL.Add('       CAPA.ENT_DESCONTO AS VAL_DESCONTO,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.FOR_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(FORNECEDORES.FOR_CPF, '''')) AS NUM_CGC,   ');
     SQL.Add('       CAPA.ENT_BASE_CALC_ICMS AS VAL_TOTAL_BC,   ');
     SQL.Add('       CAPA.ENT_VALOR_ICMS AS VAL_TOTAL_ICMS,   ');
     SQL.Add('       CAPA.ENT_BASE_CALC_ICMS_SUBST AS VAL_BC_SUBST,   ');
     SQL.Add('       CAPA.ENT_VALOR_ICMS_SUBST AS VAL_ICMS_SUBST,   ');
     SQL.Add('       0 AS VAL_FUNRURAL,   ');
     SQL.Add('       CASE WHEN CAPA.CFO_ID = ''1910'' OR CAPA.CFO_ID = ''2910'' THEN 5 ELSE 1 END AS COD_PERFIL,   ');
     SQL.Add('       0 AS VAL_DESP_ACESS,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('       COALESCE(CAPA.ENT_OBS, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       COALESCE(CAPA.ENT_CHAVE, '''') AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTRADA AS CAPA   ');
     SQL.Add('   LEFT JOIN FORNECEDORES ON FORNECEDORES.FOR_ID = CAPA.FOR_ID   ');
     SQL.Add('   WHERE');
     SQL.Add('      CAST(CAPA.ENT_DT_ENTRADA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('   AND');
     SQL.Add('      CAST(CAPA.ENT_DT_ENTRADA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');


//   Parameters.ParamByName('INI').AsDate := DtpInicial.Date;
//   Parameters.ParamByName('FIM').AsDate := DtpFinal.Date;
//
//
//    Parameters.ParamByName('INI').Value := FormatDateTime('dd/mm/yyyy', DtpInicial.Date);
//    Parameters.ParamByName('FIM').Value := FormatDateTime('dd/mm/yyyy', DtpFinal.Date);

    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('DTA_EMISSAO').AsDateTime := QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime;
      Layout.FieldByName('DTA_ENTRADA').AsDateTime := QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime;
      Layout.FieldByName('DES_OBSERVACAO').AsString := StrLBReplace(FieldByName('DES_OBSERVACAO').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarNFitensClientes;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT    ');
     SQL.Add('       CAPA.CODIGO AS COD_CLIENTE,   ');
     SQL.Add('       COALESCE(CAPA.NOT_NNOTA, CAPA.NOT_REGISTRO) AS NUM_NF_CLI,   ');
     SQL.Add('       CAPA.NOT_SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('       ITENS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 1 THEN 13      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 2 THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 4 THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 5 THEN 3      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 6 THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 7 THEN 5      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 8 THEN 8      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 9 THEN 6      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 10 THEN 7      ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 11 THEN 27   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 12 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 13 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 14 THEN 20   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 15 THEN 39   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 16 THEN 39   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 17 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 18 THEN 40   ');
     SQL.Add('           ELSE 1      ');
     SQL.Add('       END AS COD_TRIBUTACAO,      ');
     SQL.Add('      ');
     SQL.Add('       1 AS QTD_EMBALAGEM,   ');
     SQL.Add('       ITENS.QUANTIDADE AS QTD_ENTRADA,   ');
     SQL.Add('       CASE WHEN ITENS.PRO_UNIDADE = ''UNID'' THEN ''UN'' ELSE ITENS.PRO_UNIDADE END AS DES_UNIDADE,   ');
     SQL.Add('       ITENS.PRO_VENDA AS VAL_TABELA,   ');
     SQL.Add('       COALESCE(ITENS.PRO_DESCONTO_ITEM, 0) AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       0 AS VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       COALESCE(ITENS.IPIV, 0) AS VAL_IPI_ITEM,   ');
     SQL.Add('       COALESCE(ITENS.PRO_VALORICMS, 0) AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       COALESCE(ITENS.PRO_TOTAL, 0) AS VAL_TABELA_LIQ,   ');
     SQL.Add('       ITENS.PRO_CUSTOREAL AS VAL_CUSTO_REP,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CAPA.CPFCGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       ITENS.PRO_BASEICMS AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('       COALESCE(ITENS.NAT_CODIGO, ''5929'') AS COD_FISCAL,   ');
     SQL.Add('       ITENS.NOT_ITEM AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI   ');
     SQL.Add('   FROM   ');
     SQL.Add('       NOTA_ITEM AS ITENS   ');
     SQL.Add('   LEFT JOIN NOTA_CAB AS CAPA ON CAPA.NOT_REGISTRO = ITENS.NOT_REGISTRO   ');
     SQL.Add('   LEFT JOIN PRODUTOS ON PRODUTOS.PRO_CODIGO = ITENS.PRO_CODIGO   ');
     SQL.Add('WHERE    ');
     SQL.Add(' CAST(CAPA.NOT_DATA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('AND');
     SQL.Add(' CAST(CAPA.NOT_DATA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add(' ORDER BY CAPA.NOT_NNOTA, CAPA.CODIGO, CAPA.NOT_SERIE ');
//    SQL.Add('AND    ');
//    SQL.Add('    CAPA.ID_EMPRESA_A = '+ CbxLoja.Text +'');

//    Parameters.ParamByName('INI').Value := FormatDateTime('dd/mm/yyyy', DtpInicial.Date);
//    Parameters.ParamByName('FIM').Value := FormatDateTime('dd/mm/yyyy', DtpFinal.Date);


    Open;

    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmRonyMG.GerarNFitensFornec;
var
//   fornecedor, nota, serie : string;
//   count, TotalCount : integer;

   NumLinha, TotalReg, NumItem  :Integer;
   nota, serie, fornecedor : string;
   count : integer;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       CAPA.FOR_ID AS COD_FORNECEDOR,   ');
       SQL.Add('       CAPA.ENT_NUMNOTA AS NUM_NF_FORN,   ');
       SQL.Add('       CASE WHEN CAPA.ENT_SERIE = '''' THEN ''1'' ELSE COALESCE(CAPA.ENT_SERIE, ''1'') END AS NUM_SERIE_NF,   ');
       SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,   ');
       SQL.Add('          ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1      ');
       SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13      ');
       SQL.Add('           ELSE 1    ');
       SQL.Add('       END AS COD_TRIBUTACAO,   ');
       SQL.Add('          ');
       SQL.Add('       1 AS QTD_EMBALAGEM,   ');
       SQL.Add('       ITEM.ITE_QUANT AS QTD_ENTRADA,   ');
       SQL.Add('       ''UN'' AS DES_UNIDADE,   ');
       SQL.Add('       ITEM.ITE_VLR_UNIT AS VAL_TABELA,   ');
       SQL.Add('       (ITEM.ITE_VLR_DESCONTO / ITEM.ITE_QUANT)  AS VAL_DESCONTO_ITEM,   ');
       SQL.Add('       0 AS VAL_ACRESCIMO_ITEM,   ');
       SQL.Add('       (ITEM.ITE_VLR_IPI / ITEM.ITE_QUANT) AS VAL_IPI_ITEM,   ');
       SQL.Add('       0 AS VAL_SUBST_ITEM,   ');
       SQL.Add('       0 AS VAL_FRETE_ITEM,   ');
       SQL.Add('       ITEM.ITE_VLR_ICMS AS VAL_CREDITO_ICMS,   ');
       SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
       SQL.Add('       ITEM.ITE_VLR_TOTAL AS VAL_TABELA_LIQ,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.FOR_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(FORNECEDORES.FOR_CPF, '''')) AS NUM_CGC,   ');
       SQL.Add('       ITEM.ITE_BASE_CALC_ICMS AS VAL_TOT_BC_ICMS,   ');
       SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
       SQL.Add('       ITEM.CFO_ID AS CFOP,   ');
       SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
       SQL.Add('       0 AS VAL_TOT_BC_ST,   ');
       SQL.Add('       ITEM.ITE_VALOR_ICMS_SUBST AS VAL_TOT_ST,   ');
       SQL.Add('       1 AS NUM_ITEM,   ');
       SQL.Add('       0 AS TIPO_IPI,   ');
       SQL.Add('       CASE WHEN PRODUTO.PRO_CODIGONBM = ''00000000'' THEN ''99999998'' ELSE COALESCE(PRODUTO.PRO_CODIGONBM, ''99999999'') END AS NUM_NCM,   ');
       SQL.Add('       ITEM.ITE_REFERENCIA AS DES_REFERENCIA    ');
       SQL.Add('   FROM   ');
       SQL.Add('       ITEM_ENTRADA AS ITEM   ');
       SQL.Add('   LEFT JOIN ENTRADA AS CAPA ON CAPA.ENT_NUMNOTA = ITEM.ENT_NUMNOTA AND CAPA.FOR_ID = ITEM.FOR_ID   ');
       SQL.Add('   LEFT JOIN PRODUTO ON PRODUTO.PRO_ID = ITEM.PRO_ID   ');
       SQL.Add('   LEFT JOIN NATUREZA_FISCAL AS NF ON (PRODUTO.NAF_CODFISCAL = NF.NAF_CODFISCAL)   ');
       SQL.Add('   LEFT JOIN FORNECEDORES ON FORNECEDORES.FOR_ID = ITEM.FOR_ID   ');
       SQL.Add('   WHERE');
       SQL.Add('      CAST(CAPA.ENT_DT_ENTRADA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
       SQL.Add('   AND');
       SQL.Add('      CAST(CAPA.ENT_DT_ENTRADA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');




    //Parameters.ParamByName('INI').Value := FormatDateTime('dd/mm/yyyy', DtpInicial.Date);
    //Parameters.ParamByName('FIM').Value := FormatDateTime('dd/mm/yyyy', DtpFinal.Date);


    Open;

    First;
    NumLinha := 0;
    NumItem := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

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
//
      Layout.FieldByName('NUM_ITEM').AsInteger := count;
//
      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarProdForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTO.FOR_ID AS COD_FORNECEDOR,   ');
     SQL.Add('       REPLACE(COALESCE(PRODUTO.PRO_REFERENCIA, ''''), ''A'', '''') AS DES_REFERENCIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.FOR_CGC, ''-'', ''''), ''.'', ''''), ''/'', ''''), COALESCE(FORNECEDORES.FOR_CPF, '''')) AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('       PRODUTO.PRO_UNIDADE AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       PRODUTO.PRO_QUANT_UNID AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       1 AS QTD_TROCA,   ');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     SQL.Add('   LEFT JOIN FORNECEDORES ON FORNECEDORES.FOR_ID = PRODUTO.FOR_ID   ');
//     SQL.Add('   WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''     ');





    Open;

    First;

    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmRonyMG.GerarProdLoja;
var
  count, count1 : Integer;
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


  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTO.PRO_CUSTONOTA AS VAL_CUSTO_REP,   ');
     SQL.Add('       PRODUTO.PRO_VLRVENDA AS VAL_VENDA,   ');
     SQL.Add('       COALESCE(PRODUTO.PRO_PROMOCAO_VLR, 0) AS VAL_OFERTA,   ');
     SQL.Add('       PRODUTO.PRO_ESTOQUE AS QTD_EST_VDA,   ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       PRODUTO.PRO_MARGEM AS VAL_MARGEM,   ');
     SQL.Add('       1 AS QTD_ETIQUETA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PRO_ATIVO = ''I'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_INATIVO,   ');
     SQL.Add('          ');
     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO_ANT,   ');
     SQL.Add('       CASE WHEN PRODUTO.PRO_CODIGONBM = ''00000000'' THEN ''99999998'' ELSE COALESCE(PRODUTO.PRO_CODIGONBM, ''99999999'') END AS NUM_NCM,   ');
     SQL.Add('       0 AS TIPO_NCM,   ');
     SQL.Add('   		 CASE   ');
     SQL.Add('   				 WHEN PRODUTO.PRO_VLRVENDA <> PRODUTO.PRO_VLRPRAZO THEN PRODUTO.PRO_VLRPRAZO   ');
     SQL.Add('   				 ELSE 0    ');
     SQL.Add('   		 END AS VAL_VENDA_2,   ');
     SQL.Add('       PRODUTO.PRO_PROMOCAO_DTFIM AS DTA_VALIDA_OFERTA,   ');
     SQL.Add('       PRODUTO.PRO_ESTOQMIN AS QTD_EST_MINIMO,   ');
     SQL.Add('       NULL AS COD_VASILHAME,   ');
     SQL.Add('       ''N'' AS FORA_LINHA,   ');
     SQL.Add('       0 AS QTD_PRECO_DIF,   ');
     SQL.Add('       0 AS VAL_FORCA_VDA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('   		    WHEN PRODUTO.CES_CODIGO = ''00.000.00'' THEN ''9999999''   ');
     SQL.Add('   				ELSE COALESCE(REPLACE(PRODUTO.CES_CODIGO, ''.'', ''''), ''9999999'')    ');
     SQL.Add('   		 END AS NUM_CEST,     ');
     SQL.Add('       PRODUTO.PRO_MVA AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST,   ');
     SQL.Add('       0 AS PER_FIDELIDADE,   ');
     SQL.Add('       999 AS COD_INFO_RECEITA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     SQL.Add('   LEFT JOIN NATUREZA_FISCAL AS NF ON (PRODUTO.NAF_CODFISCAL = NF.NAF_CODFISCAL)   ');
//     SQL.Add('   WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''     ');
     SQL.Add('   WHERE PRODUTO.PRO_EAN2 IS NULL ');

     SQL.Add('UNION ALL');

     SQL.Add('   SELECT   ');
     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTO.PRO_CUSTONOTA AS VAL_CUSTO_REP,   ');
     SQL.Add('       PRODUTO.PRO_VLRVENDA AS VAL_VENDA,   ');
     SQL.Add('       COALESCE(PRODUTO.PRO_PROMOCAO_VLR, 0) AS VAL_OFERTA,   ');
     SQL.Add('       PRODUTO.PRO_ESTOQUE AS QTD_EST_VDA,   ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       PRODUTO.PRO_MARGEM AS VAL_MARGEM,   ');
     SQL.Add('       1 AS QTD_ETIQUETA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 43   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 12   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 29   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 14   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 44   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 45   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''25.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 5   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 46   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 11   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''31.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''5.600'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''700'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0900'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0400'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''27.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''0.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''040'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''18.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 13   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''NN'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0500'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''1800'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''12.000'' AND NF.NAF_CODIMPRES = ''1800'' THEN 3   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0300'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''7.000'' AND NF.NAF_CODIMPRES = ''1200'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''20.000'' AND NF.NAF_CODIMPRES = ''II'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CST_ID = ''0102'' AND PRODUTO.PRO_ALIQUOTA_NCM_EST = ''8.800'' AND NF.NAF_CODIMPRES = ''FF'' THEN 13   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PRO_ATIVO = ''I'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_INATIVO,   ');
     SQL.Add('          ');
     SQL.Add('       REPLACE(PRODUTO.PRO_REFERENCIA, ''A'', '''') AS COD_PRODUTO_ANT,   ');
     SQL.Add('       CASE WHEN PRODUTO.PRO_CODIGONBM = ''00000000'' THEN ''99999998'' ELSE COALESCE(PRODUTO.PRO_CODIGONBM, ''99999999'') END AS NUM_NCM,   ');
     SQL.Add('       0 AS TIPO_NCM,   ');
     SQL.Add('   		 CASE   ');
     SQL.Add('   				 WHEN PRODUTO.PRO_VLRVENDA <> PRODUTO.PRO_VLRPRAZO THEN PRODUTO.PRO_VLRPRAZO   ');
     SQL.Add('   				 ELSE 0    ');
     SQL.Add('   		 END AS VAL_VENDA_2,   ');
     SQL.Add('       PRODUTO.PRO_PROMOCAO_DTFIM AS DTA_VALIDA_OFERTA,   ');
     SQL.Add('       PRODUTO.PRO_ESTOQMIN AS QTD_EST_MINIMO,   ');
     SQL.Add('       NULL AS COD_VASILHAME,   ');
     SQL.Add('       ''N'' AS FORA_LINHA,   ');
     SQL.Add('       0 AS QTD_PRECO_DIF,   ');
     SQL.Add('       0 AS VAL_FORCA_VDA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('   		    WHEN PRODUTO.CES_CODIGO = ''00.000.00'' THEN ''9999999''   ');
     SQL.Add('   				ELSE COALESCE(REPLACE(PRODUTO.CES_CODIGO, ''.'', ''''), ''9999999'')    ');
     SQL.Add('   		 END AS NUM_CEST,     ');
     SQL.Add('       PRODUTO.PRO_MVA AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST,   ');
     SQL.Add('       0 AS PER_FIDELIDADE,   ');
     SQL.Add('       999 AS COD_INFO_RECEITA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     SQL.Add('   LEFT JOIN NATUREZA_FISCAL AS NF ON (PRODUTO.NAF_CODFISCAL = NF.NAF_CODFISCAL)   ');
//     SQL.Add('   WHERE PRODUTO.PRO_DESCRICAO NOT LIKE ''Z%''     ');
     SQL.Add('   WHERE PRODUTO.PRO_EAN2 IS NOT NULL ');





    Open;
    //showmessage(FieldByName('NUM_NCM').Text);
    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);
      Layout.FieldByName('COD_PRODUTO').AsString := Layout.FieldByName('COD_PRODUTO').AsString;

       //Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
       Layout.FieldByName('COD_PRODUTO_ANT').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO_ANT').AsString);
       Layout.FieldByName('COD_PRODUTO_ANT').AsString := Layout.FieldByName('COD_PRODUTO_ANT').AsString;

      //if( Layout.FieldByName('DTA_VALIDA_OFERTA').AsString <> '' ) then
         Layout.FieldByName('DTA_VALIDA_OFERTA').AsDateTime := FieldByName('DTA_VALIDA_OFERTA').AsDateTime;

//      Layout.FieldByName('COD_PRODUTO').AsString := TiraZerosEsquerda(Layout.FieldByName('COD_PRODUTO').AsString);
//      Layout.FieldByName('COD_PRODUTO_ANT').AsString := TiraZerosEsquerda(Layout.FieldByName('COD_PRODUTO_ANT').AsString);
//      Layout.FieldByName('COD_EAN').AsString := TiraZerosEsquerda(Layout.FieldByName('COD_EAN').AsString);



//      if CbxLoja.Text = '4' then
//      begin
//        if QryPrincipal2.FieldByName('COD_PRODUTO').AsInteger = 0  then
//          begin
//            Layout.FieldByName('COD_PRODUTO').AsInteger := count1;
//            Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//          end;
//      end;



//


//      if CbxLoja.Text = '4' then
//      begin
//        if QryPrincipal2.FieldByName('COD_PRODUTO_ANT').AsInteger = 0  then
//          begin
//            Layout.FieldByName('COD_PRODUTO_ANT').AsInteger := count1;
//            Layout.FieldByName('COD_PRODUTO_ANT').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO_ANT').AsString );
//          end;
//      end;
//
//



//      if (Layout.FieldByName('NUM_NCM').AsString = '0')
//      and (Layout.FieldByName('COD_TRIBUTACAO').AsInteger = 2)
//      and (Layout.FieldByName('COD_TRIBUTACAO').AsInteger = 2)  then
//        ShowMessage(Layout.FieldByName('COD_PRODUTO').AsString);
        //Layout.FieldByName('NUM_NCM').AsString := '99999999'



      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
    Close;
  end;
end;

procedure TFrmSmRonyMG.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       S_PRODUTO.CDSUPERPRODUTO AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('       S_PRODUTO.NMPRODUTOPAI AS DES_PRODUTO_SIMILAR,   ');
     SQL.Add('       0 AS VAL_META    ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBSUPERPRODUTO AS S_PRODUTO   ');
     SQL.Add('   WHERE S_PRODUTO.CDSUPERPRODUTO IN (   ');
     SQL.Add('       SELECT   ');
     SQL.Add('           PRODUTO.CDSUPERPRODUTO   ');
     SQL.Add('       FROM   ');
     SQL.Add('           TBPRODUTO AS PRODUTO   ');
     SQL.Add('       GROUP BY PRODUTO.CDSUPERPRODUTO   ');
     SQL.Add('       HAVING COUNT (*) > 1   ');
     SQL.Add('   )   ');


    Open;    
    
    First;
    NumLinha := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

end.
