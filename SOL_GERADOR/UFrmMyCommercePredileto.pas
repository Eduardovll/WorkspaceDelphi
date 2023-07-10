unit UFrmMyCommercePredileto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, ComObj,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrmModelo, Data.DBXOracle, Data.DB,
  Data.SqlExpr, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DBXFirebird, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.Provider, Datasnap.DBClient,
  //dxGDIPlusClasses,
  Math;

type
  TFrmMyCommercePredileto = class(TFrmModeloSis)
    CbxLoja: TComboBox;
    lblLoja: TLabel;
    ADOMySQL: TADOConnection;
    QryPrincipal2: TADOQuery;
    procedure btnGeraCestClick(Sender: TObject);
    procedure BtnAmarrarCestClick(Sender: TObject);
    procedure BtnGerarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

  end;

var
  FrmMyCommercePredileto: TFrmMyCommercePredileto;
  ListNCM    : TStringList;
  TotalCont  : Integer;
  NumLinha : Integer;
  Arquivo: TextFile;
  FlgGeraDados : Boolean = false;
  FlgGeraCest : Boolean = false;
  FlgGeraAmarrarCest : Boolean = false;

implementation

{$R *.dfm}

uses xProc, UUtilidades, UProgresso;


procedure TFrmMyCommercePredileto.GerarProducao;
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

procedure TFrmMyCommercePredileto.GerarProduto;
var
   codigoBarra : String;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

SQL.Add('SELECT');
SQL.Add('	CASE');
SQL.Add('		WHEN LENGTH(CAST(PRODUTOS.CODIGOBARRAS AS INTEGER)) < 8 THEN PRODUTOS.CODIGO');
SQL.Add('		ELSE 30000 + PRODUTOS.CODIGO');
SQL.Add('	END AS COD_PRODUTO,');
SQL.Add('	');
SQL.Add('	COALESCE(PRODUTOS.CODIGOBARRAS, ''0'') AS COD_BARRA_PRINCIPAL,');
SQL.Add('   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PRODUTOS.DESCRICAO, ''�'', ''A''), ''�'',''A''),''�'',''A''),''�'',''E''),''�'',''E''),''�'',''I''),''�'',''O''),''�'',''O''),''�'',''O''),''�'',''U''),''�'',''U''),''�'',''C'') AS DES_REDUZIDA,   ');
SQL.Add('   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PRODUTOS.DESCRICAO, ''�'', ''A''), ''�'',''A''),''�'',''A''),''�'',''E''),''�'',''E''),''�'',''I''),''�'',''O''),''�'',''O''),''�'',''O''),''�'',''U''),''�'',''U''),''�'',''C'') AS DES_PRODUTO,');
SQL.Add('	1 AS QTD_EMBALAGEM_COMPRA,');
SQL.Add('	PRODUTOS.UNCOMPRA AS DES_UNIDADE_COMPRA,');
SQL.Add('	COALESCE(ASSOCIADO.QTDE) AS QTD_EMBALAGEM_VENDA,');
SQL.Add('	PRODUTOS.UNVENDA AS DES_UNIDADE_VENDA,');
SQL.Add('	0 AS TIPO_IPI,');
SQL.Add('	0 AS VAL_IPI,');
SQL.Add('	COALESCE(PRODUTOS.CODIGOSECAO, 999) AS COD_SECAO,');
SQL.Add('	COALESCE(PRODUTOS.CODIGOGRUPO, 999) AS COD_GRUPO,');
SQL.Add('	COALESCE(PRODUTOS.CODIGOSUBGRUPO, 999) AS COD_SUB_GRUPO,');
SQL.Add('	0 AS COD_PRODUTO_SIMILAR,');
SQL.Add('');
SQL.Add('	CASE PRODUTOS.UNVENDA');
SQL.Add('		WHEN ''KG'' THEN ''S''');
SQL.Add('		ELSE ''N''');
SQL.Add('	END AS IPV,');
SQL.Add('	');
SQL.Add('	COALESCE(PRODUTOS.PRAZOVALIDADE, 0) AS DIAS_VALIDADE,');
SQL.Add('	0 AS TIPO_PRODUTO,');
SQL.Add('');
SQL.Add('	CASE');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''04'' AND PRODUTOS.CST_COFINS = ''04'' THEN ''S''');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''01'' AND PRODUTOS.CST_COFINS = ''01'' THEN ''N''');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''06'' AND PRODUTOS.CST_COFINS = ''06'' THEN ''S''');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''49'' AND PRODUTOS.CST_COFINS = ''49'' THEN ''S''');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''05'' AND PRODUTOS.CST_COFINS = ''05'' THEN ''S''');
SQL.Add('		ELSE ''N''');
SQL.Add('	END AS FLG_NAO_PIS_COFINS,');
SQL.Add('	');
SQL.Add('	CASE PRODUTOS.ENVIABALANCA ');
SQL.Add('		WHEN 1 THEN ''S''');
SQL.Add('		ELSE ''N''');
SQL.Add('	END AS FLG_ENVIA_BALANCA,');
SQL.Add('	');
SQL.Add('	CASE');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''04'' AND PRODUTOS.CST_COFINS = ''04'' THEN 1');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''01'' AND PRODUTOS.CST_COFINS = ''01'' THEN -1');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''06'' AND PRODUTOS.CST_COFINS = ''06'' THEN 0');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''49'' AND PRODUTOS.CST_COFINS = ''49'' THEN 0');
SQL.Add('		WHEN PRODUTOS.CST_PIS = ''05'' AND PRODUTOS.CST_COFINS = ''05'' THEN 2');
SQL.Add('		ELSE -1');
SQL.Add('	END AS TIPO_NAO_PIS_COFINS,');
SQL.Add('');
SQL.Add('	0 AS TIPO_EVENTO,');
SQL.Add('	CASE');
SQL.Add('		WHEN LENGTH(CAST(PRODFILHO.CODIGOBARRAS AS INTEGER)) < 8 THEN ASSOCIADO.CODPRODUTOKIT');
SQL.Add('		ELSE 30000 + ASSOCIADO.CODPRODUTOKIT');
SQL.Add('	END AS COD_ASSOCIADO,');
SQL.Add('	'''' AS DES_OBSERVACAO,');
SQL.Add('	0 AS COD_INFO_NUTRICIONAL,');
SQL.Add('	0 AS COD_INFO_RECEITA,');
SQL.Add('	COALESCE(PRODUTOS.CODNATUREZAPIS, 0) AS COD_TAB_SPED,');
SQL.Add('	''N'' AS FLG_ALCOOLICO,');
SQL.Add('	0 AS TIPO_ESPECIE,');
SQL.Add('	0 AS COD_CLASSIF,');
SQL.Add('	1 AS VAL_VDA_PESO_BRUTO,');
SQL.Add('	1 AS VAL_PESO_EMB,');
SQL.Add('	0 AS TIPO_EXPLOSAO_COMPRA,');
SQL.Add('	'''' AS DTA_INI_OPER,');
SQL.Add('	'''' AS DES_PLAQUETA,');
SQL.Add('	'''' AS MES_ANO_INI_DEPREC,');
SQL.Add('	0 AS TIPO_BEM,');
SQL.Add('	0 AS COD_FORNECEDOR,');
SQL.Add('	0 AS NUM_NF,');
SQL.Add('	'''' AS DTA_ENTRADA,');
SQL.Add('	0 AS COD_NAT_BEM,');
SQL.Add('	0 AS VAL_ORIG_BEM');
SQL.Add('FROM PRODUTOS');
SQL.Add('LEFT JOIN PRODUTOS_KITS AS ASSOCIADO ON PRODUTOS.CODIGO = ASSOCIADO.PRODUTOPRINCIPAL');
 SQL.Add('   LEFT JOIN PRODUTOS PRODFILHO ON PRODFILHO.CODIGO = ASSOCIADO.CODPRODUTOKIT   ');
SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
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

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
      Layout.FieldByName('COD_ASSOCIADO').AsString := GerarPLU( Layout.FieldByName('COD_ASSOCIADO').AsString );


      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
      Layout.FieldByName('DES_REDUZIDA').AsString := StrReplace(StrLBReplace(FieldByName('DES_REDUZIDA').AsString), '\n', '');
      Layout.FieldByName('DES_PRODUTO').AsString := StrReplace(StrLBReplace(FieldByName('DES_PRODUTO').AsString), '\n', '');

      codigoBarra := StrRetNums(Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString);

//      if( StrToFloat(codigoBarra) = 0 ) then
//      begin
//         Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := '';
//      end
//      else
//      begin
//         if( Length(TiraZerosEsquerda(codigoBarra)) <= 8 ) then
//            Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := GerarPLU( codigoBarra );
//
////         if ( Length(TiraZerosEsquerda(Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString)) <= 8 ) then
////            Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := GerarPLU( Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString );
//      end;
//
//      if( not CodBarrasValido(Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString) ) then
//         Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := '';
      if( codigoBarra = '' ) then
         Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := ''
      else if( StrToFloat(codigoBarra) = 0 ) then
      begin
         Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := '';
      end
      else
      begin
         if( Length(TiraZerosEsquerda(codigoBarra)) < 8 ) then
             codigoBarra := GerarPLU( codigoBarra )
         else
            if( not CodBarrasValido(codigoBarra) ) then
               codigoBarra := '';
      end;

      Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := codigoBarra;



      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;

    Close
  end;
end;


procedure TFrmMyCommercePredileto.GerarSecao;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT');
    SQL.Add('    COALESCE(PRODUTOS.CODIGOSECAO, 999) AS COD_SECAO,');
    SQL.Add('    COALESCE(PRODUTOS.SECAO, ''A DEFINIR'') AS DES_SECAO,');
    SQL.Add('    0 AS VAL_META');
    SQL.Add('FROM PRODUTOS');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
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

procedure TFrmMyCommercePredileto.GerarSubGrupo;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT');
    SQL.Add('    COALESCE(PRODUTOS.CODIGOSECAO, 999) AS COD_SECAO,');
    SQL.Add('    COALESCE(PRODUTOS.CODIGOGRUPO, 999) AS COD_GRUPO,');
    SQL.Add('    COALESCE(PRODUTOS.CODIGOSUBGRUPO, 999) AS COD_SUB_GRUPO,');
    SQL.Add('    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PRODUTOS.SUBGRUPO, ''�'', ''A''), ''�'',''A''),''�'',''A''),''�'',''E''),''�'',''E''),''�'',''I''),''�'',''O''),''�'',''O''),''�'',''O''),''�'',''U''),''�'',''U''),''�'',''C'') AS DES_SUB_GRUPO,   ');
    SQL.Add('    0 AS VAL_META,');
    SQL.Add('    0 AS VAL_MARGEM_REF,');
    SQL.Add('    0 AS QTD_DIA_SEGURANCA,');
    SQL.Add('    ''N'' AS FLG_ALCOOLICO');
    SQL.Add('FROM PRODUTOS');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
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

      if Layout.FieldByName('DES_SUB_GRUPO').AsString = '' then
        Layout.FieldByName('DES_SUB_GRUPO').AsString := 'A DEFINIR';


      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmMyCommercePredileto.GerarVenda;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('          ');
     SQL.Add('    CASE   ');
     SQL.Add('   		WHEN LENGTH(CAST(VENDASPRODUTOS.CODIGOBARRAS AS INTEGER)) < 8 THEN VENDASPRODUTOS.CODIGOPRODUTO   ');
     SQL.Add('   		ELSE 30000 + VENDASPRODUTOS.CODIGOPRODUTO   ');
     SQL.Add('   	END AS COD_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
     SQL.Add('       0 AS IND_TIPO,   ');
     SQL.Add('       CAST(RIGHT(VENDAS.TERMINAL , 2) AS INTEGER) AS NUM_PDV, ');
     SQL.Add('       VENDASPRODUTOS.QUANTIDADE AS QTD_TOTAL_PRODUTO,   ');
     SQL.Add('       VENDASPRODUTOS.VALORTOTAL AS VAL_TOTAL_PRODUTO,   ');
     SQL.Add('       COALESCE(PRODUTOS.VENDAT1, 0) AS VAL_PRECO_VENDA,   ');
     SQL.Add('       VENDASPRODUTOS.VALORCUSTO AS VAL_CUSTO_REP,   ');
     SQL.Add('       VENDAS.DATA AS DTA_SAIDA,   ');
     SQL.Add('       '''' AS DTA_MENSAL,   ');
     SQL.Add('       VENDAS.CODIGO AS NUM_IDENT,   ');
     SQL.Add('       VENDASPRODUTOS.CODIGOBARRAS AS COD_EAN,   ');
     SQL.Add('       REPLACE(VENDAS.HORA, '':'', '''') AS DES_HORA,   ');
     SQL.Add('       CLIENTES.CODIGO AS COD_CLIENTE,   ');
     SQL.Add('          ');
     SQL.Add('       CASE CLIENTES.IDMODALIDADECB      ');
     SQL.Add('           WHEN 1 THEN 29      ');
     SQL.Add('           WHEN 2 THEN 8      ');
     SQL.Add('           WHEN 3 THEN 2      ');
     SQL.Add('           WHEN 4 THEN 6      ');
     SQL.Add('           WHEN 5 THEN 7      ');
     SQL.Add('           WHEN 6 THEN 31      ');
     SQL.Add('           WHEN 7 THEN 1      ');
     SQL.Add('           WHEN 8 THEN 32      ');
     SQL.Add('           ELSE 1      ');
     SQL.Add('       END AS COD_ENTIDADE,   ');
     SQL.Add('          ');
     SQL.Add('       VENDASPRODUTOS.VALORBASEICMS AS VAL_BASE_ICMS,   ');
     SQL.Add('       '''' AS DES_SITUACAO_TRIB,   ');
     SQL.Add('       VENDASPRODUTOS.VALORICMS AS VAL_ICMS,   ');
     SQL.Add('       VENDAS.CODIGO AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       COALESCE(PRODUTOS.VENDAT1, 0) AS VAL_VENDA_PDV,   ');
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4            ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25          ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33    ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4    ');
     SQL.Add('           ELSE 1      ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE VENDASPRODUTOS.CANCELADA WHEN 1 THEN ''S'' ELSE ''N'' END AS FLG_CUPOM_CANCELADO,   ');
     SQL.Add('       REPLACE(PRODUTOS.NCM, ''.'', '''')  AS NUM_NCM,   ');
     SQL.Add('       COALESCE(PRODUTOS.CODNATUREZAPIS, 0) AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('    CASE   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''04'' AND PRODUTOS.CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''01'' AND PRODUTOS.CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''06'' AND PRODUTOS.CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''49'' AND PRODUTOS.CST_COFINS = ''49'' THEN ''S''   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''05'' AND PRODUTOS.CST_COFINS = ''05'' THEN ''S''   ');
     SQL.Add('   		ELSE ''N''   ');
     SQL.Add('   	END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('    CASE   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''04'' AND PRODUTOS.CST_COFINS = ''04'' THEN 1   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''01'' AND PRODUTOS.CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''06'' AND PRODUTOS.CST_COFINS = ''06'' THEN 0   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''49'' AND PRODUTOS.CST_COFINS = ''49'' THEN 0   ');
     SQL.Add('   		WHEN PRODUTOS.CST_PIS = ''05'' AND PRODUTOS.CST_COFINS = ''05'' THEN 2   ');
     SQL.Add('   		ELSE -1   ');
     SQL.Add('   	END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       '''' AS FLG_ONLINE,   ');
     SQL.Add('       '''' AS FLG_OFERTA,   ');
     SQL.Add('          ');
     SQL.Add('    CASE   ');
     SQL.Add('   		WHEN LENGTH(CAST(PRODFILHO.CODIGOBARRAS AS INTEGER)) < 8 THEN ASSOCIADO.CODPRODUTOKIT   ');
     SQL.Add('   		ELSE 30000 + ASSOCIADO.CODPRODUTOKIT   ');
     SQL.Add('   	END AS COD_ASSOCIADO   ');
     SQL.Add('      ');
     SQL.Add('   FROM   ');
     SQL.Add('       VENDAS   ');
     SQL.Add('   LEFT JOIN VENDASPRODUTOS ON VENDAS.CODIGO = VENDASPRODUTOS.CODIGOVENDA   ');
     SQL.Add('   LEFT JOIN CLIENTES ON VENDAS.CODIGOCLIENTE = CLIENTES.CODIGO   ');
     SQL.Add('   LEFT JOIN PRODUTOS ON VENDASPRODUTOS.CODIGOPRODUTO = PRODUTOS.CODIGO   ');
     SQL.Add('   LEFT JOIN PRODUTOS_KITS AS ASSOCIADO ON PRODUTOS.CODIGO = ASSOCIADO.PRODUTOPRINCIPAL   ');
     SQL.Add('   LEFT JOIN PRODUTOS PRODFILHO ON PRODFILHO.CODIGO = ASSOCIADO.CODPRODUTOKIT   ');
     SQL.Add('   WHERE CLIENTES.TIPO IN (''C'', ''E'')   ');
     SQL.Add('   AND PRODUTOS.DESCRICAO IS NOT NULL   ');
     SQL.Add('   AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''   ');
     SQL.Add('   AND VENDASPRODUTOS.CANCELADA IS NULL');
     SQL.Add('   AND VENDAS.EMPRESA = '+CbxLoja.Text+'   ');
     SQL.Add('   AND');
     SQL.Add('      VENDAS.DATA >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('   AND');
     SQL.Add('      VENDAS.DATA <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

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

procedure TFrmMyCommercePredileto.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmMyCommercePredileto.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmMyCommercePredileto.BtnGerarClick(Sender: TObject);
begin
   ADOMySQL.Connected := False;
   ADOMySQL.ConnectionString := 'Provider=MSDASQL.1;Password="'+edtSenhaOracle.Text+'";Persist Security Info=True;User ID='+edtInst.Text+';Data Source='+edtSchema.Text+'';

//Provider=MSDASQL.1;Password="";Persist Security Info=True;User ID=root;Data Source=predileto_l1

//   ADOSQLServer.Connected := false;
////   ADOSQLServer.ConnectionString := 'Provider=MSDASQL.1;Persist Security Info=False;Data Source='+edtSchema.Text+';User ID='+edtInst.Text+';Password'+edtSenhaOracle.Text+'';
//   ADOSQLServer.ConnectionString := 'Provider=MSDASQL.1;Persist Security Info=False;Data Source='+edtSchema.Text+';User ID='+edtInst.Text+';Password='+edtSenhaOracle.Text+'';
//
   ADOMySQL.Connected := true;
  inherited;
//
//   ADOSQLServer.Connected := false;
end;

procedure TFrmMyCommercePredileto.FormCreate(Sender: TObject);
begin
  inherited;
//  Left:=(Screen.Width-Width)  div 2;
//  Top:=(Screen.Height-Height) div 2;
end;

procedure TFrmMyCommercePredileto.GerarCest;
var
   count : integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT');
    SQL.Add('    0 AS COD_CEST,');
    SQL.Add('    CASE WHEN COALESCE(PRODUTOS.CEST, '''') = '''' THEN ''9999999'' ELSE PRODUTOS.CEST END AS NUM_CEST,');
    SQL.Add('    ''A DEFINIR'' AS DES_CEST');
    SQL.Add('FROM PRODUTOS');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
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

      Layout.FieldByName('COD_CEST').AsInteger := count;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmMyCommercePredileto.GerarCliente;
begin

   inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT   ');
SQL.Add('    CLIENTES.CODIGO AS COD_CLIENTE,      ');
SQL.Add('    COALESCE(CLIENTES.RAZAOSOCIAL, ''A DEFINIR'') AS DES_CLIENTE,      ');
SQL.Add('        ');
SQL.Add('    CLIENTES.CGC AS NUM_CGC,      ');
SQL.Add('    ');
SQL.Add('    CASE CLIENTES.FISICAJURIDICA   ');
SQL.Add('        WHEN ''J'' THEN CASE CLIENTES.IE   ');
SQL.Add('                        WHEN ''000000000000'' THEN ''ISENTO''   ');
SQL.Add('                        WHEN ''00000000'' THEN ''ISENTO''   ');
SQL.Add('                        ELSE COALESCE(TRIM(REPLACE(REPLACE(REPLACE(CLIENTES.IE, ''.'', ''''), ''-'', ''''), ''/'', '''')), ''ISENTO'')    ');
SQL.Add('                        END   ');
SQL.Add('        ELSE ''''   ');
SQL.Add('    END AS NUM_INSC_EST,      ');
SQL.Add('        ');
SQL.Add('    COALESCE(CLIENTES.ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,      ');
SQL.Add('    COALESCE(CLIENTES.BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,      ');
SQL.Add('    COALESCE(CLIENTES.CIDADE, ''A DEFINIR'') AS DES_CIDADE,      ');
SQL.Add('    CLIENTES.UF AS DES_SIGLA,      ');
SQL.Add('    COALESCE(CLIENTES.CEP, ''28922270'') AS NUM_CEP,      ');
SQL.Add('');
SQL.Add('    CASE   ');
SQL.Add('        WHEN LENGTH(CLIENTES.TELEFONE1) >= 11 THEN ''''   ');
SQL.Add('        ELSE COALESCE(CLIENTES.TELEFONE1, '''')    ');
SQL.Add('    END AS NUM_FONE,  ');
SQL.Add('');
SQL.Add('    CASE   ');
SQL.Add('        WHEN LENGTH(CLIENTES.FAX) >= 11 THEN ''''   ');
SQL.Add('        ELSE CLIENTES.FAX    ');
SQL.Add('    END AS NUM_FAX,   ');
SQL.Add('');
SQL.Add('    COALESCE(CLIENTES.RAZAOSOCIAL, ''A DEFINIR'') AS DES_CONTATO,      ');
SQL.Add('    COALESCE(CLIENTES.SEXO, 0) AS FLG_SEXO,      ');
SQL.Add('    0 AS VAL_LIMITE_CRETID,      ');
SQL.Add('    COALESCE(CLIENTES.VALORCREDITO, 0) AS VAL_LIMITE_CONV,      ');
SQL.Add('    0 AS VAL_DEBITO,      ');
SQL.Add('    0 AS VAL_RENDA,      ');
SQL.Add('    99999 AS COD_CONVENIO,      ');
SQL.Add('    0 AS COD_STATUS_PDV,      ');
SQL.Add('            ');
SQL.Add('    CASE CLIENTES.FISICAJURIDICA      ');
SQL.Add('        WHEN ''J'' THEN ''S''      ');
SQL.Add('        ELSE ''N''      ');
SQL.Add('    END AS FLG_EMPRESA,      ');
SQL.Add('            ');
SQL.Add('    ''N'' AS FLG_CONVENIO,      ');
SQL.Add('    ''N'' AS MICRO_EMPRESA,      ');
SQL.Add('        ');
SQL.Add('    CLIENTES.DATACADASTRO AS DTA_CADASTRO,                              ');
SQL.Add('    CLIENTES.NUMERO AS NUM_ENDERECO,  ');
SQL.Add('    CLIENTES.RG AS NUM_RG,');
SQL.Add('            ');
SQL.Add('    CASE CLIENTES.ESTADOCIVIL       ');
SQL.Add('        WHEN NULL THEN 0      ');
SQL.Add('        WHEN ''SOLTEIRO(A)'' THEN 0     ');
SQL.Add('        WHEN ''CASADO(A)'' THEN 1   ');
SQL.Add('        ELSE 0      ');
SQL.Add('    END AS FLG_EST_CIVIL,      ');
SQL.Add('            ');
SQL.Add('    COALESCE(CLIENTES.TELEFONE2, '''') AS NUM_CELULAR,  ');
SQL.Add('');
SQL.Add('    CLIENTES.DATAALTERACAO AS DTA_ALTERACAO,   ');
SQL.Add('    ');
SQL.Add('       CASE   ');
SQL.Add('           WHEN CLIENTES.CODIGO <> 3688 THEN CASE      ');
SQL.Add('               WHEN LENGTH(CLIENTES.TELEFONE1) >= 11 THEN CONCAT(CONCAT(CONCAT(CLIENTES.OBSERVACAO, '' - ROTA:''), CLIENTES.ROTA, '' '', CLIENTES.NOMEROTA), CLIENTES.TELEFONE1)      ');
SQL.Add('               WHEN LENGTH(CLIENTES.FAX) >= 11 THEN CONCAT(CONCAT(CONCAT(CLIENTES.OBSERVACAO, '' - ROTA:''), CLIENTES.ROTA, '' '', CLIENTES.NOMEROTA), CLIENTES.FAX)      ');
SQL.Add('               WHEN LENGTH(CLIENTES.TELEFONE1) >= 11 AND LENGTH(CLIENTES.FAX) >= 11 THEN CONCAT(CONCAT(CONCAT(CONCAT(CLIENTES.OBSERVACAO, '' - ROTA:''), CLIENTES.ROTA, '' '', CLIENTES.NOMEROTA), CLIENTES.TELEFONE1), CLIENTES.FAX)      ');
SQL.Add('               ELSE CONCAT(CONCAT(CLIENTES.OBSERVACAO, '' - ROTA:''), CLIENTES.ROTA, '' '', CLIENTES.NOMEROTA)    ');
SQL.Add('               END     ');
SQL.Add('           ELSE CLIENTES.OBSERVACAO   ');
SQL.Add('       END AS DES_OBSERVACAO,   ');
SQL.Add('');
SQL.Add('    COALESCE(CLIENTES.COMPLEMENTO, ''A DEFINIR'') AS DES_COMPLEMENTO,   ');
SQL.Add('    COALESCE(CLIENTES.EMAIL, '''') AS DES_EMAIL,      ');
SQL.Add('    COALESCE(CLIENTES.NOMEFANTASIA, '''') AS DES_FANTASIA,');
SQL.Add('');
SQL.Add('    CLIENTES.DATANASCIMENTO AS DTA_NASCIMENTO,       ');
SQL.Add('           ');
SQL.Add('    COALESCE(CLIENTES.NOMEPAI, '''') AS DES_PAI,      ');
SQL.Add('    COALESCE(CLIENTES.NOMEMAE, '''') AS DES_MAE,      ');
SQL.Add('    COALESCE(CLIENTES.CONJUGENOME, '''') AS DES_CONJUGE,      ');
SQL.Add('        ');
SQL.Add('    CLIENTES.CONJUGECPF AS NUM_CPF_CONJUGE,      ');
SQL.Add('        ');
SQL.Add('    0 AS VAL_DEB_CONV,      ');
SQL.Add('            ');
SQL.Add('    ''N'' AS INATIVO,      ');
SQL.Add('        ');
SQL.Add('    '''' AS DES_MATRICULA,      ');
SQL.Add('    ''N'' AS NUM_CGC_ASSOCIADO,      ');
SQL.Add('    ''N'' AS FLG_PROD_RURAL,      ');
SQL.Add('    0 AS COD_STATUS_PDV_CONV,      ');
SQL.Add('    ''S'' AS FLG_ENVIA_CODIGO,      ');
SQL.Add('    '''' AS DTA_NASC_CONJUGE,      ');
SQL.Add('    0 AS COD_CLASSIF      ');
SQL.Add('FROM CLIENTES AS CLIENTES');
SQL.Add('WHERE CLIENTES.TIPO IN (''C'', ''E'')');
SQL.Add('AND CLIENTES.RAZAOSOCIAL IS NOT NULL ');
// SQL.Add('AND CLIENTES.CODIGO = 3688');


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

      Layout.FieldByName('DTA_NASCIMENTO').AsDateTime := FieldByName('DTA_NASCIMENTO').AsDateTime;
      Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;
      Layout.FieldByName('DTA_ALTERACAO').AsDateTime := FieldByName('DTA_ALTERACAO').AsDateTime;

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

    if Layout.FieldByName('NUM_CEP').AsString = '' then
      Layout.FieldByName('NUM_CEP').AsString := '28922270';




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

procedure TFrmMyCommercePredileto.GerarCodigoBarras;
var
 count : Integer;
 codigoBarra : string;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    CASE');
    SQL.Add('        WHEN LENGTH(CAST(PRODUTOS.CODIGOBARRAS AS INTEGER)) < 8 THEN PRODUTOS.CODIGO');
    SQL.Add('        ELSE 30000 + PRODUTOS.CODIGO');
    SQL.Add('    END AS COD_PRODUTO,');
    SQL.Add('    ');
    SQL.Add('    COALESCE(PRODUTOS.CODIGOBARRAS, ''0'') AS COD_EAN');
    SQL.Add('FROM PRODUTOS');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
    SQL.Add('');
    SQL.Add('UNION ALL');
    SQL.Add('');
    SQL.Add('SELECT');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('        WHEN LENGTH(CAST(PRODUTOS.CODIGOBARRAS AS INTEGER)) < 8 THEN PRODUTOS.CODIGO');
    SQL.Add('        ELSE 30000 + PRODUTOS.CODIGO');
    SQL.Add('    END AS COD_PRODUTO,');
    SQL.Add('');
    SQL.Add('    PRODUTOSBARCODE.BARCODE AS COD_EAN');
    SQL.Add('FROM PRODUTOSBARCODE');
    SQL.Add('LEFT JOIN PRODUTOS');
    SQL.Add('ON PRODUTOSBARCODE.CODIGOPRODUTO = PRODUTOS.CODIGO');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
    //SQL.Add('ORDER BY PRODUTOS.ATIVO');

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

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//      Layout.FieldByName('COD_EAN').AsString := StrRetNums( Layout.FieldByName('COD_EAN').AsString );

      codigoBarra := StrRetNums(Layout.FieldByName('COD_EAN').AsString);

      if( codigoBarra = '' ) then
         Layout.FieldByName('COD_EAN').AsString := ''
      else if( StrToFloat(codigoBarra) = 0 ) then
      begin
         Layout.FieldByName('COD_EAN').AsString := '';
      end
      else
      begin
         if( Length(TiraZerosEsquerda(codigoBarra)) < 8 ) then
             codigoBarra := GerarPLU( codigoBarra )
         else
            if( not CodBarrasValido(codigoBarra) ) then
               codigoBarra := '';
      end;

      Layout.FieldByName('COD_EAN').AsString := codigoBarra;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmMyCommercePredileto.GerarComposicao;
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

procedure TFrmMyCommercePredileto.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT   ');
    SQL.Add('    CLIENTES.CODIGO AS COD_CLIENTE,   ');
    SQL.Add('    ');
    SQL.Add('    CASE CLIENTES.IDFORMAPARCELAMENTO   ');
    SQL.Add('        WHEN 1 THEN 1   ');
    SQL.Add('        WHEN 2 THEN 30   ');
    SQL.Add('        WHEN 3 THEN 30   ');
    SQL.Add('        WHEN 4 THEN 7   ');
    SQL.Add('        WHEN 5 THEN 14   ');
    SQL.Add('        WHEN 6 THEN 21   ');
    SQL.Add('        WHEN 7 THEN 2   ');
    SQL.Add('        WHEN 8 THEN 10   ');
    SQL.Add('        ELSE 30   ');
    SQL.Add('    END AS NUM_CONDICAO,   ');
    SQL.Add('    ');
    SQL.Add('    2 AS COD_CONDICAO,   ');
    SQL.Add('    ');
    SQL.Add('    CASE CLIENTES.IDMODALIDADECB   ');
    SQL.Add('        WHEN 1 THEN 29   ');
    SQL.Add('        WHEN 2 THEN 8   ');
    SQL.Add('        WHEN 3 THEN 2   ');
    SQL.Add('        WHEN 4 THEN 6   ');
    SQL.Add('        WHEN 5 THEN 7   ');
    SQL.Add('        WHEN 6 THEN 31   ');
    SQL.Add('        WHEN 7 THEN 1   ');
    SQL.Add('        WHEN 8 THEN 32   ');
    SQL.Add('        ELSE 1   ');
    SQL.Add('    END AS COD_ENTIDADE   ');
    SQL.Add('FROM   ');
    SQL.Add('    CLIENTES   ');
    SQL.Add('WHERE CLIENTES.TIPO IN (''C'', ''E'')   ');
    SQL.Add('AND CLIENTES.RAZAOSOCIAL IS NOT NULL');



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

procedure TFrmMyCommercePredileto.GerarCondPagForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('	FORNECEDORES.CODIGO AS COD_FORNECEDOR,');
    SQL.Add('');
    SQL.Add('	CASE FORNECEDORES.IDFORMAPARCELAMENTO');
    SQL.Add('        WHEN 1 THEN 1');
    SQL.Add('        WHEN 2 THEN 30');
    SQL.Add('        WHEN 3 THEN 30');
    SQL.Add('        WHEN 4 THEN 7');
    SQL.Add('        WHEN 5 THEN 14');
    SQL.Add('        WHEN 6 THEN 21');
    SQL.Add('        WHEN 7 THEN 2');
    SQL.Add('        WHEN 8 THEN 10');
    SQL.Add('        ELSE 30');
    SQL.Add('    END AS NUM_CONDICAO,');
    SQL.Add('');
    SQL.Add('	2 AS COD_CONDICAO,');
    SQL.Add('');
    SQL.Add('	CASE FORNECEDORES.IDMODALIDADECB');
    SQL.Add('        WHEN 1 THEN 29');
    SQL.Add('        WHEN 2 THEN 8');
    SQL.Add('        WHEN 3 THEN 2');
    SQL.Add('        WHEN 4 THEN 6');
    SQL.Add('        WHEN 5 THEN 7');
    SQL.Add('        WHEN 6 THEN 31');
    SQL.Add('        WHEN 7 THEN 1');
    SQL.Add('        WHEN 8 THEN 32');
    SQL.Add('        ELSE 1');
    SQL.Add('    END AS COD_ENTIDADE,');
    SQL.Add('');
    SQL.Add('	'''' AS NUM_CGC');
    SQL.Add('FROM CLIENTES AS FORNECEDORES ');
    SQL.Add('WHERE TIPO IN (''F'', ''P'')');

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

procedure TFrmMyCommercePredileto.GerarDecomposicao;
begin
  inherited;

  with QryPrincipal2 do
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

      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

//      Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//
//      Layout.FieldByName('COD_PRODUTO_DECOM').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO_DECOM').AsString );

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmMyCommercePredileto.GerarDivisaoForn;
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

procedure TFrmMyCommercePredileto.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmMyCommercePredileto.GerarFinanceiroPagar(Aberto: String);
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;
    if Aberto = '1' then
    begin

     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('       CASE WHEN FORNECEDOR.TIPO = ''F'' THEN 1 ELSE 0 END AS TIPO_PARCEIRO,   ');
     SQL.Add('       PAGARABERTO.CODIGO AS COD_PARCEIRO,   ');
     SQL.Add('       0 AS TIPO_CONTA,   ');
     SQL.Add('       CASE PAGARABERTO.CODMODALIDADE   ');
     SQL.Add('           WHEN 1 THEN 29   ');
     SQL.Add('           WHEN 2 THEN 8   ');
     SQL.Add('           WHEN 3 THEN 3   ');
     SQL.Add('           WHEN 4 THEN 6   ');
     SQL.Add('           WHEN 5 THEN 7   ');
     SQL.Add('           WHEN 6 THEN 9   ');
     SQL.Add('           WHEN 7 THEN 1   ');
     SQL.Add('           WHEN 8 THEN 32   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_ENTIDADE,   ');
     SQL.Add('   CAST(COALESCE(SUBSTRING(PAGARABERTO.DESCRICAO, 13, 8), '''') AS INTEGER) AS NUM_DOCTO,    ');
     SQL.Add('       999 AS COD_BANCO,   ');
     SQL.Add('       '''' AS DES_BANCO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(      ');
     SQL.Add('           CONCAT(      ');
     SQL.Add('               CONCAT(      ');
     SQL.Add('                   CONCAT(      ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATALANCAMENTO, 9,2), ''/''),              ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATALANCAMENTO, 6,2), ''/''),      ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATALANCAMENTO, 1,4)), '''') AS DTA_EMISSAO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(      ');
     SQL.Add('           CONCAT(      ');
     SQL.Add('               CONCAT(      ');
     SQL.Add('                   CONCAT(      ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.VENCIMENTO, 9,2), ''/''),              ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.VENCIMENTO, 6,2), ''/''),      ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.VENCIMENTO, 1,4)), '''') AS DTA_VENCIMENTO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PAGARABERTO.VALORPENDENTE, 0) AS VAL_PARCELA,   ');
     SQL.Add('       COALESCE(PAGARABERTO.JURO, 0) AS VAL_JUROS,   ');
     SQL.Add('       COALESCE(PAGARABERTO.DESCONTO, 0) AS VAL_DESCONTO,   ');
     SQL.Add('       ''N'' AS FLG_QUITADO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(      ');
     SQL.Add('           CONCAT(      ');
     SQL.Add('               CONCAT(      ');
     SQL.Add('                   CONCAT(      ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATAQUITACAO, 9,2), ''/''),              ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATAQUITACAO, 6,2), ''/''),      ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATAQUITACAO, 1,4)), '''') AS DTA_QUITADA,   ');
     SQL.Add('      ');
     SQL.Add('       998 AS COD_CATEGORIA,   ');
     SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
     SQL.Add('       COALESCE(PAGARABERTO.NPAGAMENTO, 1) AS NUM_PARCELA,   ');
     SQL.Add('       COALESCE(PAGARABERTO.QUANTIDADEPAGAMENTOS, 1) AS QTD_PARCELA,   ');
     SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE FORNECEDOR.FISICAJURIDICA      ');
     SQL.Add('           WHEN ''J'' THEN COALESCE(TRIM(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJ, ''.'', ''''), ''-'', ''''), ''/'','''')), '''')      ');
     SQL.Add('           ELSE COALESCE(TRIM(REPLACE(REPLACE(FORNECEDOR.CPF, ''.'', ''''), ''-'', '''')), '''')       ');
     SQL.Add('       END AS NUM_CGC,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS NUM_BORDERO,   ');
     SQL.Add('   CAST(COALESCE(SUBSTRING(PAGARABERTO.DESCRICAO, 13, 8), '''') AS INTEGER) AS NUM_NF,   ');
     SQL.Add('       '''' AS NUM_SERIE_NF,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PAGARABERTO.QUANTIDADEPAGAMENTOS > 1 THEN VALPARCELA.VAL_TOTAL_NF   ');
     SQL.Add('           ELSE PAGARABERTO.VALORPENDENTE   ');
     SQL.Add('       END AS VAL_TOTAL_NF,   ');
     SQL.Add('       PAGARABERTO.DESCRICAO AS DES_OBSERVACAO,   ');
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
     SQL.Add('      ');
     SQL.Add('       COALESCE(      ');
     SQL.Add('           CONCAT(      ');
     SQL.Add('               CONCAT(      ');
     SQL.Add('                   CONCAT(      ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATALANCAMENTO, 9,2), ''/''),              ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATALANCAMENTO, 6,2), ''/''),      ');
     SQL.Add('                       SUBSTRING(PAGARABERTO.DATALANCAMENTO, 1,4)), '''') AS DTA_ENTRADA,   ');
     SQL.Add('                          ');
     SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
     SQL.Add('       '''' AS COD_BARRA,   ');
     SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
     SQL.Add('       CASE PAGARABERTO.CODMODALIDADE         ');
     SQL.Add('           WHEN 3 THEN COALESCE(TRIM(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJ, ''.'', ''''), ''-'', ''''), ''/'','''')), '''')         ');
     SQL.Add('           ELSE ''''      ');
     SQL.Add('       END AS NUM_CGC_CPF_TITULAR,   ');
     SQL.Add('          ');
     SQL.Add('       CASE PAGARABERTO.CODMODALIDADE   ');
     SQL.Add('           WHEN 3 THEN COALESCE(PAGARABERTO.RAZAOSOCIAL, '''')    ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS DES_TITULAR,     ');
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
     SQL.Add('       CONTASAPAGAR AS PAGARABERTO   ');
     SQL.Add('   LEFT JOIN CLIENTES AS FORNECEDOR ON PAGARABERTO.CODIGO = FORNECEDOR.CODIGO   ');
     SQL.Add('   LEFT JOIN   ');
     SQL.Add('   (   ');
     SQL.Add('       SELECT   ');
     SQL.Add('           CODIGO,   ');
     SQL.Add('           CODIGOENTRADA,   ');
     SQL.Add('           SUM(VALORPENDENTE) AS VAL_TOTAL_NF   ');
     SQL.Add('       FROM   ');
     SQL.Add('           CONTASAPAGAR   ');
     SQL.Add('       GROUP BY   ');
     SQL.Add('           CODIGOENTRADA, CODIGO   ');
     SQL.Add('   ) AS VALPARCELA   ');
     SQL.Add('   ON   ');
     SQL.Add('       PAGARABERTO.CODIGO = VALPARCELA.CODIGO   ');
     SQL.Add('   AND   ');
     SQL.Add('       PAGARABERTO.CODIGOENTRADA = VALPARCELA.CODIGOENTRADA   ');
     SQL.Add('   WHERE PAGARABERTO.QUITADO = 0   ');
     SQL.Add('AND FORNECEDOR.TIPO IN (''F'', ''C'', ''E'') ');
     SQL.Add('AND PAGARABERTO.CANCELADA IS NULL   ');
     SQL.Add('AND PAGARABERTO.EMPRESA = '+CbxLoja.Text+' ');
//     SQL.Add('AND');

//     SQL.Add(' PAGARABERTO.VENCIMENTO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
//     SQL.Add('AND');
//     SQL.Add(' PAGARABERTO.VENCIMENTO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
    end
    else
    begin
    //QUITADO
     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('       CASE WHEN FORNECEDOR.TIPO = ''F'' THEN 1 ELSE 0 END AS TIPO_PARCEIRO,   ');
     SQL.Add('       PAGARQUITADO.CODIGO AS COD_PARCEIRO,   ');
     SQL.Add('       0 AS TIPO_CONTA,   ');
     SQL.Add('       CASE PAGARQUITADO.CODMODALIDADE   ');
     SQL.Add('           WHEN 1 THEN 29   ');
     SQL.Add('           WHEN 2 THEN 8   ');
     SQL.Add('           WHEN 3 THEN 3   ');
     SQL.Add('           WHEN 4 THEN 6   ');
     SQL.Add('           WHEN 5 THEN 7   ');
     SQL.Add('           WHEN 6 THEN 9   ');
     SQL.Add('           WHEN 7 THEN 1   ');
     SQL.Add('           WHEN 8 THEN 32   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_ENTIDADE,   ');
     SQL.Add('   CAST(COALESCE(SUBSTRING(PAGARQUITADO.DESCRICAO, 13, 8), '''') AS INTEGER) AS NUM_DOCTO,    ');
     SQL.Add('       999 AS COD_BANCO,   ');
     SQL.Add('       '''' AS DES_BANCO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(      ');
     SQL.Add('           CONCAT(      ');
     SQL.Add('               CONCAT(      ');
     SQL.Add('                   CONCAT(      ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATALANCAMENTO, 9,2), ''/''),              ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATALANCAMENTO, 6,2), ''/''),      ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATALANCAMENTO, 1,4)), '''') AS DTA_EMISSAO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(      ');
     SQL.Add('           CONCAT(      ');
     SQL.Add('               CONCAT(      ');
     SQL.Add('                   CONCAT(      ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.VENCIMENTO, 9,2), ''/''),              ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.VENCIMENTO, 6,2), ''/''),      ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.VENCIMENTO, 1,4)), '''') AS DTA_VENCIMENTO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(PAGARQUITADO.VALORPAGO, 0) AS VAL_PARCELA,   ');
     SQL.Add('       COALESCE(PAGARQUITADO.JURO, 0) AS VAL_JUROS,   ');
     SQL.Add('       COALESCE(PAGARQUITADO.DESCONTO, 0) AS VAL_DESCONTO,   ');
     SQL.Add('       ''S'' AS FLG_QUITADO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(      ');
     SQL.Add('           CONCAT(      ');
     SQL.Add('               CONCAT(      ');
     SQL.Add('                   CONCAT(      ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATAQUITACAO, 9,2), ''/''),              ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATAQUITACAO, 6,2), ''/''),      ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATAQUITACAO, 1,4)), '''')  AS DTA_QUITADA,   ');
     SQL.Add('          ');
     SQL.Add('       998 AS COD_CATEGORIA,   ');
     SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
     SQL.Add('       COALESCE(PAGARQUITADO.NPAGAMENTO, 1) AS NUM_PARCELA,   ');
     SQL.Add('       COALESCE(PAGARQUITADO.QUANTIDADEPAGAMENTOS, 1) AS QTD_PARCELA,   ');
     SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE FORNECEDOR.FISICAJURIDICA      ');
     SQL.Add('           WHEN ''J'' THEN COALESCE(TRIM(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJ, ''.'', ''''), ''-'', ''''), ''/'','''')), '''')      ');
     SQL.Add('           ELSE COALESCE(TRIM(REPLACE(REPLACE(FORNECEDOR.CPF, ''.'', ''''), ''-'', '''')), '''')       ');
     SQL.Add('       END AS NUM_CGC,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS NUM_BORDERO,   ');
     SQL.Add('   CAST(COALESCE(SUBSTRING(PAGARQUITADO.DESCRICAO, 13, 8), '''') AS INTEGER) AS NUM_NF,   ');
     SQL.Add('       '''' AS NUM_SERIE_NF,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PAGARQUITADO.QUANTIDADEPAGAMENTOS > 1 THEN VALPARCELA.VAL_TOTAL_NF   ');
     SQL.Add('           ELSE PAGARQUITADO.VALORPAGO   ');
     SQL.Add('       END AS VAL_TOTAL_NF,   ');
     SQL.Add('       PAGARQUITADO.DESCRICAO AS DES_OBSERVACAO,   ');
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
     SQL.Add('      ');
     SQL.Add('       COALESCE(      ');
     SQL.Add('           CONCAT(      ');
     SQL.Add('               CONCAT(      ');
     SQL.Add('                   CONCAT(      ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATALANCAMENTO, 9,2), ''/''),              ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATALANCAMENTO, 6,2), ''/''),      ');
     SQL.Add('                       SUBSTRING(PAGARQUITADO.DATALANCAMENTO, 1,4)), '''') AS DTA_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
     SQL.Add('       '''' AS COD_BARRA,   ');
     SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
     SQL.Add('       CASE PAGARQUITADO.CODMODALIDADE         ');
     SQL.Add('           WHEN 3 THEN COALESCE(TRIM(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJ, ''.'', ''''), ''-'', ''''), ''/'','''')), '''')         ');
     SQL.Add('           ELSE ''''      ');
     SQL.Add('       END AS NUM_CGC_CPF_TITULAR,   ');
     SQL.Add('          ');
     SQL.Add('       CASE PAGARQUITADO.CODMODALIDADE   ');
     SQL.Add('           WHEN 3 THEN COALESCE(PAGARQUITADO.RAZAOSOCIAL, '''')    ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS DES_TITULAR,     ');
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
     SQL.Add('       CONTASAPAGAR AS PAGARQUITADO   ');
     SQL.Add('   LEFT JOIN CLIENTES AS FORNECEDOR ON PAGARQUITADO.CODIGO = FORNECEDOR.CODIGO   ');
     SQL.Add('   LEFT JOIN   ');
     SQL.Add('   (   ');
     SQL.Add('       SELECT   ');
     SQL.Add('           CODIGO,   ');
     SQL.Add('           CODIGOENTRADA,   ');
     SQL.Add('           SUM(VALORPAGO) AS VAL_TOTAL_NF   ');
     SQL.Add('       FROM   ');
     SQL.Add('           CONTASAPAGAR   ');
     SQL.Add('       GROUP BY   ');
     SQL.Add('           CODIGOENTRADA, CODIGO   ');
     SQL.Add('   ) AS VALPARCELA   ');
     SQL.Add('   ON   ');
     SQL.Add('       PAGARQUITADO.CODIGO = VALPARCELA.CODIGO   ');
     SQL.Add('   AND   ');
     SQL.Add('       PAGARQUITADO.CODIGOENTRADA = VALPARCELA.CODIGOENTRADA   ');
     SQL.Add('   WHERE PAGARQUITADO.QUITADO = 1   ');
     SQL.Add('AND FORNECEDOR.TIPO IN (''F'', ''C'', ''E'')');
     SQL.Add('AND PAGARQUITADO.CANCELADA IS NULL   ');
     SQL.Add('AND');
     SQL.Add(' PAGARQUITADO.VENCIMENTO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('AND');
     SQL.Add(' PAGARQUITADO.VENCIMENTO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add('AND PAGARQUITADO.EMPRESA = '+CbxLoja.Text+' ');
    end;

//    ShowMessage(sql.Text);

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

procedure TFrmMyCommercePredileto.GerarFinanceiroReceber(Aberto: String);
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

     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('       CASE WHEN CLIENTES.TIPO = ''F'' THEN 1 ELSE 0 END AS TIPO_PARCEIRO,   ');
     SQL.Add('       RECEBERABERTO.CODIGO AS COD_PARCEIRO,   ');
     SQL.Add('       1 AS TIPO_CONTA,   ');
     SQL.Add('       CASE RECEBERABERTO.CODMODALIDADE      ');
     SQL.Add('           WHEN 1 THEN 29      ');
     SQL.Add('           WHEN 2 THEN 8      ');
     SQL.Add('           WHEN 3 THEN 3      ');
     SQL.Add('           WHEN 4 THEN 6      ');
     SQL.Add('           WHEN 5 THEN 7      ');
     SQL.Add('           WHEN 6 THEN 9      ');
     SQL.Add('           WHEN 7 THEN 1      ');
     SQL.Add('           WHEN 8 THEN 32      ');
     SQL.Add('           ELSE 8      ');
     SQL.Add('       END AS COD_ENTIDADE,   ');
     SQL.Add('       RECEBERABERTO.NDOCUMENTO AS NUM_DOCTO,   ');
     SQL.Add('       999 AS COD_BANCO,   ');
     SQL.Add('       '''' AS DES_BANCO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(         ');
     SQL.Add('           CONCAT(         ');
     SQL.Add('               CONCAT(         ');
     SQL.Add('                   CONCAT(         ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATALANCAMENTO, 9,2), ''/''),                 ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATALANCAMENTO, 6,2), ''/''),         ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATALANCAMENTO, 1,4)), '''') AS DTA_EMISSAO,    ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(         ');
     SQL.Add('           CONCAT(         ');
     SQL.Add('               CONCAT(         ');
     SQL.Add('                   CONCAT(         ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.VENCIMENTO, 9,2), ''/''),                 ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.VENCIMENTO, 6,2), ''/''),         ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.VENCIMENTO, 1,4)), '''') AS DTA_VENCIMENTO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(RECEBERABERTO.VALOR, 0) AS VAL_PARCELA,   ');
     SQL.Add('       COALESCE(RECEBERABERTO.JURO, 0) AS VAL_JUROS,   ');
     SQL.Add('       COALESCE(RECEBERABERTO.DESCONTO, 0) AS VAL_DESCONTO,   ');
     SQL.Add('       ''N'' AS FLG_QUITADO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(         ');
     SQL.Add('           CONCAT(         ');
     SQL.Add('               CONCAT(         ');
     SQL.Add('                   CONCAT(         ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATAQUITACAO, 9,2), ''/''),                 ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATAQUITACAO, 6,2), ''/''),         ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATAQUITACAO, 1,4)), '''') AS DTA_QUITADA,    ');
     SQL.Add('          ');
     SQL.Add('       998 AS COD_CATEGORIA,   ');
     SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
     SQL.Add('       COALESCE(RECEBERABERTO.NPAGAMENTO, 1)  AS NUM_PARCELA,   ');
     SQL.Add('       COALESCE(RECEBERABERTO.QUANTIDADEPAGAMENTOS, 1) AS QTD_PARCELA,   ');
     SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE CLIENTES.FISICAJURIDICA         ');
     SQL.Add('           WHEN ''J'' THEN COALESCE(TRIM(REPLACE(REPLACE(REPLACE(CLIENTES.CNPJ, ''.'', ''''), ''-'', ''''), ''/'','''')), '''')         ');
     SQL.Add('           ELSE COALESCE(TRIM(REPLACE(REPLACE(CLIENTES.CPF, ''.'', ''''), ''-'', '''')), '''')          ');
     SQL.Add('       END AS NUM_CGC,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS NUM_BORDERO,   ');
     SQL.Add('       RECEBERABERTO.NDOCUMENTO AS NUM_NF,   ');
     SQL.Add('       '''' AS NUM_SERIE_NF,   ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN RECEBERABERTO.QUANTIDADEPAGAMENTOS > 1 THEN VALPARCELA.VAL_TOTAL_NF      ');
     SQL.Add('           ELSE RECEBERABERTO.VALOR      ');
     SQL.Add('       END AS VAL_TOTAL_NF,   ');
     SQL.Add('          ');
     SQL.Add('               CASE   ');
     SQL.Add('                   WHEN RECEBERABERTO.CODMODALIDADE IS NULL THEN ''ESTE T�TULO ORIGINALMENTE CADASTRADO SEM ENTIDADE, FOI DEFINIDO COMO BOLETO BANCARIO''   ');
     SQL.Add('                   ELSE COALESCE(RECEBERABERTO.DESCRICAO, '''')    ');
     SQL.Add('               END AS DES_OBSERVACAO,    ');
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
     SQL.Add('      ');
     SQL.Add('       COALESCE(         ');
     SQL.Add('           CONCAT(         ');
     SQL.Add('               CONCAT(         ');
     SQL.Add('                   CONCAT(         ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATALANCAMENTO, 9,2), ''/''),                 ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATALANCAMENTO, 6,2), ''/''),         ');
     SQL.Add('                       SUBSTRING(RECEBERABERTO.DATALANCAMENTO, 1,4)), '''') AS DTA_ENTRADA,    ');
     SQL.Add('          ');
     SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
     SQL.Add('       '''' AS COD_BARRA,   ');
     SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
     SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
     SQL.Add('       '''' AS DES_TITULAR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       0 AS VAL_CREDITO,   ');
     SQL.Add('       002 AS COD_BANCO_PGTO,   ');
     SQL.Add('       ''RECEBTO'' AS DES_CC,   ');
     SQL.Add('       0 AS COD_BANDEIRA,   ');
     SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
     SQL.Add('       1 AS NUM_SEQ_FIN,   ');
     SQL.Add('       0 AS COD_COBRANCA,   ');
     SQL.Add('       '''' AS DTA_COBRANCA,   ');
     SQL.Add('       ''N'' AS FLG_ACEITE,   ');
     SQL.Add('       0 AS TIPO_ACEITE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CONTASARECEBER AS RECEBERABERTO   ');
     SQL.Add('   LEFT JOIN CLIENTES ON RECEBERABERTO.CODIGO = CLIENTES.CODIGO   ');
     SQL.Add('   LEFT JOIN      ');
     SQL.Add('   (      ');
     SQL.Add('       SELECT      ');
     SQL.Add('           CODIGO,      ');
     SQL.Add('           NDOCUMENTO,      ');
     SQL.Add('           SUM(VALOR) AS VAL_TOTAL_NF      ');
     SQL.Add('       FROM      ');
     SQL.Add('           CONTASARECEBER   ');
     SQL.Add('       GROUP BY      ');
     SQL.Add('           CODIGO, NDOCUMENTO      ');
     SQL.Add('   ) AS VALPARCELA      ');
     SQL.Add('   ON      ');
     SQL.Add('       RECEBERABERTO.CODIGO = VALPARCELA.CODIGO      ');
     SQL.Add('   AND      ');
     SQL.Add('       RECEBERABERTO.NDOCUMENTO = VALPARCELA.NDOCUMENTO     ');
     SQL.Add('   WHERE RECEBERABERTO.QUITADO = 0   ');
     SQL.Add('   AND CLIENTES.TIPO IN (''C'',''E'', ''F'')   ');
     SQL.Add('   AND RECEBERABERTO.CANCELADA IS NULL   ');
     // SQL.Add('   AND RECEBERABERTO.CODMODALIDADE NOT IN (2, 4, 5)   ');
     SQL.Add('   AND RECEBERABERTO.CODIGO <> 1 ');
     SQL.Add('AND RECEBERABERTO.EMPRESA = '+CbxLoja.Text+' ');
     SQL.Add('AND');
     SQL.Add(' RECEBERABERTO.DATALANCAMENTO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('AND');
     SQL.Add(' RECEBERABERTO.DATALANCAMENTO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');


//     SQL.Add('AND');

//     SQL.Add(' PAGARABERTO.VENCIMENTO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
//     SQL.Add('AND');
//     SQL.Add(' PAGARABERTO.VENCIMENTO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
    end
    else
    begin
    //QUITADO
     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('       CASE WHEN CLIENTES.TIPO = ''F'' THEN 1 ELSE 0 END AS TIPO_PARCEIRO,   ');
     SQL.Add('       RECEBERQUITADO.CODIGO AS COD_PARCEIRO,   ');
     SQL.Add('       1 AS TIPO_CONTA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE RECEBERQUITADO.CODMODALIDADE      ');
     SQL.Add('           WHEN 1 THEN 29      ');
     SQL.Add('           WHEN 2 THEN 8      ');
     SQL.Add('           WHEN 3 THEN 3      ');
     SQL.Add('           WHEN 4 THEN 6      ');
     SQL.Add('           WHEN 5 THEN 7      ');
     SQL.Add('           WHEN 6 THEN 9      ');
     SQL.Add('           WHEN 7 THEN 1      ');
     SQL.Add('           WHEN 8 THEN 32      ');
     SQL.Add('           ELSE 1      ');
     SQL.Add('       END AS COD_ENTIDADE,   ');
     SQL.Add('      ');
     SQL.Add('       RECEBERQUITADO.NDOCUMENTO AS NUM_DOCTO,   ');
     SQL.Add('       999 AS COD_BANCO,   ');
     SQL.Add('       '''' AS DES_BANCO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(         ');
     SQL.Add('           CONCAT(         ');
     SQL.Add('               CONCAT(         ');
     SQL.Add('                   CONCAT(         ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATALANCAMENTO, 9,2), ''/''),                 ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATALANCAMENTO, 6,2), ''/''),         ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATALANCAMENTO, 1,4)), '''') AS DTA_EMISSAO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(         ');
     SQL.Add('           CONCAT(         ');
     SQL.Add('               CONCAT(         ');
     SQL.Add('                   CONCAT(         ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.VENCIMENTO, 9,2), ''/''),                 ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.VENCIMENTO, 6,2), ''/''),         ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.VENCIMENTO, 1,4)), '''')  AS DTA_VENCIMENTO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(RECEBERQUITADO.VALOR, 0) AS VAL_PARCELA,   ');
     SQL.Add('       COALESCE(RECEBERQUITADO.JURO, 0) AS VAL_JUROS,   ');
     SQL.Add('       COALESCE(RECEBERQUITADO.DESCONTO, 0) AS VAL_DESCONTO,   ');
     SQL.Add('       ''S'' AS FLG_QUITADO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(         ');
     SQL.Add('           CONCAT(         ');
     SQL.Add('               CONCAT(         ');
     SQL.Add('                   CONCAT(         ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATAQUITACAO, 9,2), ''/''),                 ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATAQUITACAO, 6,2), ''/''),         ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATAQUITACAO, 1,4)), '''')  AS DTA_QUITADA,   ');
     SQL.Add('          ');
     SQL.Add('       998 AS COD_CATEGORIA,   ');
     SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
     SQL.Add('       COALESCE(RECEBERQUITADO.NPAGAMENTO, 1)  AS NUM_PARCELA,   ');
     SQL.Add('       COALESCE(RECEBERQUITADO.QUANTIDADEPAGAMENTOS, 1) AS QTD_PARCELA,   ');
     SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
     SQL.Add('              ');
     SQL.Add('       CASE CLIENTES.FISICAJURIDICA         ');
     SQL.Add('           WHEN ''J'' THEN COALESCE(TRIM(REPLACE(REPLACE(REPLACE(CLIENTES.CNPJ, ''.'', ''''), ''-'', ''''), ''/'','''')), '''')         ');
     SQL.Add('           ELSE COALESCE(TRIM(REPLACE(REPLACE(CLIENTES.CPF, ''.'', ''''), ''-'', '''')), '''')          ');
     SQL.Add('       END AS NUM_CGC,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS NUM_BORDERO,   ');
     SQL.Add('       CAST(COALESCE(SUBSTRING(RECEBERQUITADO.DESCRICAO, 13, 7), '''') AS INTEGER) AS NUM_NF,   ');
     SQL.Add('       '''' AS NUM_SERIE_NF,   ');
     SQL.Add('              ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN RECEBERQUITADO.QUANTIDADEPAGAMENTOS > 1 THEN VALPARCELA.VAL_TOTAL_NF      ');
     SQL.Add('           ELSE RECEBERQUITADO.VALOR      ');
     SQL.Add('       END AS VAL_TOTAL_NF,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(RECEBERQUITADO.DESCRICAO, '''') AS DES_OBSERVACAO,   ');
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
     SQL.Add('          ');
     SQL.Add('       COALESCE(         ');
     SQL.Add('           CONCAT(         ');
     SQL.Add('               CONCAT(         ');
     SQL.Add('                   CONCAT(         ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATALANCAMENTO, 9,2), ''/''),                 ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATALANCAMENTO, 6,2), ''/''),         ');
     SQL.Add('                       SUBSTRING(RECEBERQUITADO.DATALANCAMENTO, 1,4)), '''')  AS DTA_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
     SQL.Add('       '''' AS COD_BARRA,   ');
     SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
     SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
     SQL.Add('       '''' AS DES_TITULAR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       0 AS VAL_CREDITO,   ');
     SQL.Add('       002 AS COD_BANCO_PGTO,   ');
     SQL.Add('       ''RECEBTO'' AS DES_CC,   ');
     SQL.Add('       0 AS COD_BANDEIRA,   ');
     SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
     SQL.Add('       1 AS NUM_SEQ_FIN,   ');
     SQL.Add('       0 AS COD_COBRANCA,   ');
     SQL.Add('       '''' AS DTA_COBRANCA,   ');
     SQL.Add('       ''N'' AS FLG_ACEITE,   ');
     SQL.Add('       0 AS TIPO_ACEITE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CONTASARECEBER AS RECEBERQUITADO   ');
     SQL.Add('   LEFT JOIN CLIENTES ON RECEBERQUITADO.CODIGO = CLIENTES.CODIGO   ');
     SQL.Add('   LEFT JOIN      ');
     SQL.Add('   (      ');
     SQL.Add('       SELECT      ');
     SQL.Add('           CODIGO,      ');
     SQL.Add('           NDOCUMENTO,      ');
     SQL.Add('           SUM(VALOR) AS VAL_TOTAL_NF      ');
     SQL.Add('       FROM      ');
     SQL.Add('           CONTASARECEBER   ');
     SQL.Add('       GROUP BY      ');
     SQL.Add('           CODIGO, NDOCUMENTO      ');
     SQL.Add('   ) AS VALPARCELA      ');
     SQL.Add('   ON      ');
     SQL.Add('       RECEBERQUITADO.CODIGO = VALPARCELA.CODIGO      ');
     SQL.Add('   AND      ');
     SQL.Add('       RECEBERQUITADO.NDOCUMENTO = VALPARCELA.NDOCUMENTO     ');
     SQL.Add('   WHERE RECEBERQUITADO.QUITADO = 1   ');
     SQL.Add('   AND CLIENTES.TIPO IN (''C'',''E'', ''F'')   ');
     SQL.Add('   AND RECEBERQUITADO.CANCELADA IS NULL   ');
     //SQL.Add('   AND RECEBERQUITADO.CODMODALIDADE NOT IN (2, 4, 5)   ');
     SQL.Add('   AND RECEBERQUITADO.CODIGO <> 1 ');
     SQL.Add('AND');
     SQL.Add(' RECEBERQUITADO.VENCIMENTO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('AND');
     SQL.Add(' RECEBERQUITADO.VENCIMENTO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add('AND RECEBERQUITADO.EMPRESA = '+CbxLoja.Text+' ');
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

procedure TFrmMyCommercePredileto.GerarFinanceiroReceberCartao;
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

procedure TFrmMyCommercePredileto.GerarFornecedor;
var
   observacao, email, inscEst : string;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT   ');
    SQL.Add('    FORNECEDOR.CODIGO AS COD_FORNECEDOR,   ');
    SQL.Add('    COALESCE(FORNECEDOR.RAZAOSOCIAL, ''A DEFINIR'') AS DES_FORNECEDOR,   ');
    SQL.Add('    COALESCE(FORNECEDOR.NOMEFANTASIA, '''') AS DES_FANTASIA,   ');
    SQL.Add('   ');
    SQL.Add('    FORNECEDOR.CGC AS NUM_CGC,   ');
    SQL.Add('       ');
    SQL.Add('    CASE FORNECEDOR.FISICAJURIDICA   ');
    SQL.Add('        WHEN ''J'' THEN CASE FORNECEDOR.IE   ');
    SQL.Add('                        WHEN ''000000000000'' THEN ''ISENTO''   ');
    SQL.Add('                        WHEN ''00000000'' THEN ''ISENTO''   ');
    SQL.Add('                        ELSE COALESCE(TRIM(REPLACE(REPLACE(REPLACE(FORNECEDOR.IE, ''.'', ''''), ''-'', ''''), ''/'', '''')), ''ISENTO'')    ');
    SQL.Add('                      END   ');
    SQL.Add('        WHEN ''P'' THEN ''ISENTO''');
    SQL.Add('        ELSE ''''   ');
    SQL.Add('    END AS NUM_INSC_EST,   ');
    SQL.Add('       ');
    SQL.Add('    COALESCE(FORNECEDOR.ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,   ');
    SQL.Add('    COALESCE(FORNECEDOR.BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,   ');
    SQL.Add('    COALESCE(FORNECEDOR.CIDADE, ''A DEFINIR'') AS DES_CIDADE,   ');
    SQL.Add('    FORNECEDOR.UF AS DES_SIGLA,   ');
    SQL.Add('    FORNECEDOR.CEP AS NUM_CEP,   ');
    SQL.Add('    COALESCE(FORNECEDOR.TELEFONE1, '''') AS NUM_FONE,   ');
    SQL.Add('    COALESCE(FORNECEDOR.FAX, '''') AS NUM_FAX,   ');
    SQL.Add('    COALESCE(FORNECEDOR.RAZAOSOCIAL, ''A DEFINIR'') AS DES_CONTATO,   ');
    SQL.Add('    0 AS QTD_DIA_CARENCIA,   ');
    SQL.Add('    0 AS NUM_FREQ_VISITA,   ');
    SQL.Add('    0 AS VAL_DESCONTO,   ');
    SQL.Add('    0 AS NUM_PRAZO,   ');
    SQL.Add('    ''N'' AS ACEITA_DEVOL_MER,   ');
    SQL.Add('    ''N'' AS CAL_IPI_VAL_BRUTO,   ');
    SQL.Add('    ''N'' AS CAL_ICMS_ENC_FIN,   ');
    SQL.Add('    ''N'' AS CAL_ICMS_VAL_IPI,   ');
    SQL.Add('    ''N'' AS MICRO_EMPRESA,   ');
    SQL.Add('    0 AS COD_FORNECEDOR_ANT,   ');
    SQL.Add('   ');
    SQL.Add('    CASE FORNECEDOR.NUMERO       ');
    SQL.Add('        WHEN ''S/N'' THEN ''''      ');
    SQL.Add('        WHEN ''SN'' THEN ''''      ');
    SQL.Add('        WHEN '''' THEN ''''     ');
    SQL.Add('        WHEN ''.'' THEN ''''      ');
    SQL.Add('        WHEN NULL THEN ''''      ');
    SQL.Add('        ELSE COALESCE(FORNECEDOR.NUMERO, '''')      ');
    SQL.Add('    END AS NUM_ENDERECO,   ');
    SQL.Add('   ');
    SQL.Add('	CASE');
    SQL.Add('		WHEN LENGTH(FORNECEDOR.TELEFONE2) = 13 THEN FORNECEDOR.TELEFONE2');
    SQL.Add('		ELSE COALESCE(FORNECEDOR.OBSERVACAO, '''')');
    SQL.Add('	END AS DES_OBSERVACAO,   ');
    SQL.Add('');
    SQL.Add('    COALESCE(FORNECEDOR.EMAIL, '''') AS DES_EMAIL,   ');
    SQL.Add('    FORNECEDOR.WEBSITE AS DES_WEB_SITE,   ');
    SQL.Add('    ''N'' AS FABRICANTE,   ');
    SQL.Add('       ');
    SQL.Add('    CASE FORNECEDOR.FISICAJURIDICA   ');
    SQL.Add('        WHEN ''P'' THEN ''S''   ');
    SQL.Add('        ELSE ''N''   ');
    SQL.Add('    END AS FLG_PRODUTOR_RURAL ,     ');
    SQL.Add('   ');
    SQL.Add('    0 AS TIPO_FRETE,   ');
    SQL.Add('    ''N'' AS FLG_SIMPLES,   ');
    SQL.Add('    ''N'' AS FLG_SUBSTITUTO_TRIB,   ');
    SQL.Add('    0 AS COD_CONTACCFORN,   ');
    SQL.Add('   ');
    SQL.Add('    ''N'' AS INATIVO,   ');
    SQL.Add('   ');
    SQL.Add('    0 AS COD_CLASSIF,   ');
    SQL.Add('       ');
    SQL.Add('    FORNECEDOR.DATACADASTRO AS DTA_CADASTRO,   ');
    SQL.Add('       ');
    SQL.Add('    0 AS VAL_CREDITO,   ');
    SQL.Add('    0 AS VAL_DEBITO,   ');
    SQL.Add('    1 AS PED_MIN_VAL,   ');
    SQL.Add('    '''' AS DES_EMAIL_VEND,   ');
    SQL.Add('    '''' AS SENHA_COTACAO,');
    SQL.Add('    ');
    SQL.Add('    CASE FORNECEDOR.FISICAJURIDICA');
    SQL.Add('        WHEN ''P'' THEN ');
    SQL.Add('            CASE FORNECEDOR.FISICAJURIDICA');
    SQL.Add('                WHEN ''J'' THEN 0');
    SQL.Add('                ELSE 1');
    SQL.Add('            END');
    SQL.Add('        ELSE -1');
    SQL.Add('    END AS TIPO_PRODUTOR,   ');
    SQL.Add('');
    SQL.Add('	CASE');
    SQL.Add('		WHEN LENGTH(FORNECEDOR.TELEFONE2) >= 13 THEN ''''');
    SQL.Add('		ELSE COALESCE(FORNECEDOR.TELEFONE2, '''')');
    SQL.Add('	END AS NUM_CELULAR   ');
    SQL.Add('FROM CLIENTES AS FORNECEDOR ');
    SQL.Add('WHERE TIPO IN (''F'', ''P'')');


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

      if Layout.FieldByName('NUM_CEP').AsString = '' then
        Layout.FieldByName('NUM_CEP').AsString := '28922270';

      Layout.FieldByName('DES_OBSERVACAO').AsString := observacao;
      Layout.FieldByName('DES_EMAIL').AsString := email;
      Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;

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

procedure TFrmMyCommercePredileto.GerarGrupo;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT');
    SQL.Add('    COALESCE(PRODUTOS.CODIGOSECAO, 999) AS COD_SECAO,');
    SQL.Add('    COALESCE(PRODUTOS.CODIGOGRUPO, 999) AS COD_GRUPO,');
    SQL.Add('    COALESCE(PRODUTOS.GRUPO, ''A DEFINIR'') AS DES_GRUPO,');
    SQL.Add('    0 AS VAL_META');
    SQL.Add('FROM PRODUTOS');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
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

procedure TFrmMyCommercePredileto.GerarInfoNutricionais;
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

procedure TFrmMyCommercePredileto.GerarNCM;
var
 count : Integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT');
    SQL.Add('    0 AS COD_NCM,');
    SQL.Add('    COALESCE(TABELANCM.DESCRICAO, ''A DEFINIR'') AS DES_NCM,');
    SQL.Add('    COALESCE(REPLACE(PRODUTOS.NCM, ''.'', ''''), ''99999999'') AS NUM_NCM,');
    SQL.Add('');
    SQL.Add('    PRODUTOS.CST_PIS,');
    SQL.Add('    PRODUTOS.CST_COFINS,');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''04'' AND PRODUTOS.CST_COFINS = ''04'' THEN ''S''');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''01'' AND PRODUTOS.CST_COFINS = ''01'' THEN ''N''');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''06'' AND PRODUTOS.CST_COFINS = ''06'' THEN ''S''');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''49'' AND PRODUTOS.CST_COFINS = ''49'' THEN ''S''');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''05'' AND PRODUTOS.CST_COFINS = ''05'' THEN ''S''');
    SQL.Add('        ELSE ''N''');
    SQL.Add('	END AS FLG_NAO_PIS_COFINS,');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''04'' AND PRODUTOS.CST_COFINS = ''04'' THEN 1');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''01'' AND PRODUTOS.CST_COFINS = ''01'' THEN -1');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''06'' AND PRODUTOS.CST_COFINS = ''06'' THEN 0');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''49'' AND PRODUTOS.CST_COFINS = ''49'' THEN 0');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''05'' AND PRODUTOS.CST_COFINS = ''05'' THEN 2');
    SQL.Add('        ELSE -1');
    SQL.Add('	END AS TIPO_NAO_PIS_COFINS,');
    SQL.Add('');
    SQL.Add('    COALESCE(PRODUTOS.CODNATUREZAPIS, 0) AS COD_TAB_SPED,');
    SQL.Add('    CASE WHEN COALESCE(PRODUTOS.CEST, '''') = '''' THEN ''9999999'' ELSE PRODUTOS.CEST END AS NUM_CEST,');
    SQL.Add('    ''RJ'' AS DES_SIGLA,');
    SQL.Add('');
    SQL.Add('    CASE   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4         ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25       ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22    ');
    //
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33 ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4 ');
    SQL.Add('    END AS COD_TRIB_ENTRADA,');
    SQL.Add('');
    SQL.Add('    CASE   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4         ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25       ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22    ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33 ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4 ');
    SQL.Add('    END AS COD_TRIB_SAIDA,');
    SQL.Add('');
    SQL.Add('    0 AS PER_IVA,');
    SQL.Add('    0 AS PER_FCP_ST');
    SQL.Add('FROM PRODUTOS');
    SQL.Add('LEFT JOIN TABELANCM');
    SQL.Add('ON REPLACE(PRODUTOS.NCM, ''.'', '''') = TABELANCM.NCM');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
    SQL.Add('ORDER BY NUM_NCM, NUM_CEST, COD_TRIB_ENTRADA');



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

procedure TFrmMyCommercePredileto.GerarNCMUF;
var
 count : Integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT');
    SQL.Add('    0 AS COD_NCM,');
    SQL.Add('    COALESCE(TABELANCM.DESCRICAO, ''A DEFINIR'') AS DES_NCM,');
    SQL.Add('    COALESCE(REPLACE(PRODUTOS.NCM, ''.'', ''''), ''99999999'') AS NUM_NCM,');
    SQL.Add('');
    SQL.Add('    PRODUTOS.CST_PIS,');
    SQL.Add('    PRODUTOS.CST_COFINS,');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''04'' AND PRODUTOS.CST_COFINS = ''04'' THEN ''S''');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''01'' AND PRODUTOS.CST_COFINS = ''01'' THEN ''N''');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''06'' AND PRODUTOS.CST_COFINS = ''06'' THEN ''S''');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''49'' AND PRODUTOS.CST_COFINS = ''49'' THEN ''S''');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''05'' AND PRODUTOS.CST_COFINS = ''05'' THEN ''S''');
    SQL.Add('        ELSE ''N''');
    SQL.Add('	END AS FLG_NAO_PIS_COFINS,');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''04'' AND PRODUTOS.CST_COFINS = ''04'' THEN 1');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''01'' AND PRODUTOS.CST_COFINS = ''01'' THEN -1');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''06'' AND PRODUTOS.CST_COFINS = ''06'' THEN 0');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''49'' AND PRODUTOS.CST_COFINS = ''49'' THEN 0');
    SQL.Add('		WHEN PRODUTOS.CST_PIS = ''05'' AND PRODUTOS.CST_COFINS = ''05'' THEN 2');
    SQL.Add('        ELSE -1');
    SQL.Add('	END AS TIPO_NAO_PIS_COFINS,');
    SQL.Add('');
    SQL.Add('    COALESCE(PRODUTOS.CODNATUREZAPIS, 0) AS COD_TAB_SPED,');
    SQL.Add('    CASE WHEN COALESCE(PRODUTOS.CEST, '''') = '''' THEN ''9999999'' ELSE PRODUTOS.CEST END AS NUM_CEST,');
    SQL.Add('    ''RJ'' AS DES_SIGLA,');
    SQL.Add('');
    SQL.Add('    CASE   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4         ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25       ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22    ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33 ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4 ');
    SQL.Add('    END AS COD_TRIB_ENTRADA,');
    SQL.Add('');
    SQL.Add('    CASE   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4         ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25       ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22    ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33 ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4 ');
    SQL.Add('    END AS COD_TRIB_SAIDA,');
    SQL.Add('');
    SQL.Add('    0 AS PER_IVA,');
    SQL.Add('    0 AS PER_FCP_ST');
    SQL.Add('FROM PRODUTOS');
    SQL.Add('LEFT JOIN TABELANCM');
    SQL.Add('ON REPLACE(PRODUTOS.NCM, ''.'', '''') = TABELANCM.NCM');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
    SQL.Add('ORDER BY NUM_NCM, NUM_CEST, COD_TRIB_ENTRADA');



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

procedure TFrmMyCommercePredileto.GerarNFClientes;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CAPA.CODIGOCLIENTE AS COD_CLIENTE,   ');
     SQL.Add('       CAPA.NF AS NUM_NF_CLI,   ');
     SQL.Add('       CAPA.SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('       REPLACE(CAPA.CFOP, ''.'', '''') AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('          ');
     SQL.Add('       CASE CAPA.MODELONF   ');
     SQL.Add('           WHEN NULL THEN ''NFE''   ');
     SQL.Add('           WHEN 65 THEN ''NFCE''   ');
     SQL.Add('           WHEN 55 THEN ''NFE''   ');
     SQL.Add('           ELSE ''NFE''   ');
     SQL.Add('       END AS DES_ESPECIE,   ');
     SQL.Add('          ');
     SQL.Add('       CAPA.TOTALNF AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.DATASAIDA AS DTA_EMISSAO,   ');
     SQL.Add('       CAPA.DATA AS DTA_ENTRADA,   ');
     SQL.Add('       CAPA.TOTALIPI AS VAL_TOTAL_IPI,   ');
     SQL.Add('       CAPA.TOTALFRETE AS VAL_FRETE,   ');
     SQL.Add('       0 AS VAL_ENC_FINANC,   ');
     SQL.Add('       0 AS VAL_DESC_FINANC,   ');
     SQL.Add('       COALESCE(TRIM(REPLACE(REPLACE(REPLACE(CLIENTES.CGC, ''.'', ''''), ''-'', ''''), ''/'','''')), '''') AS NUM_CGC,   ');
     SQL.Add('       '''' AS DES_NATUREZA,   ');
     SQL.Add('       COALESCE(CAPA.OBSVENDA, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('          ');
     SQL.Add('       ''N'' AS FLG_CANCELADA,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(CAPA.CHAVENFE, '''') AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       NOTASSAIDAS AS CAPA   ');
     SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CODIGO = CAPA.CODIGOCLIENTE   ');
     SQL.Add('   WHERE CLIENTES.TIPO IN (''C'', ''E'')   ');
     SQL.Add('   AND CAPA.EMPRESA = 1 ');
     SQL.Add('   AND CAPA.MODELONF IS NULL');
     SQL.Add('   AND CAPA.CANCELADA IS NULL ');
     SQL.Add('   AND    ');
     SQL.Add('    CAPA.DATA >= :INI ');
     SQL.Add('   AND    ');
     SQL.Add('    CAPA.DATA <= :FIM ');
     SQL.Add('     ');

     Parameters.ParamByName('INI').Value := FormatDateTime('yyyy-mm-dd', DtpInicial.Date);
     Parameters.ParamByName('FIM').Value := FormatDateTime('yyyy-mm-dd', DtpFinal.Date);

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

procedure TFrmMyCommercePredileto.GerarNFFornec;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

   SQL.Add('   SELECT   ');
   SQL.Add('       CAPA.CODIGOFORNECEDOR AS COD_FORNECEDOR,   ');
   SQL.Add('       COALESCE(CAPA.NUMERONOTA, 0) AS NUM_NF_FORN,   ');
   SQL.Add('       COALESCE(CAPA.MODELO_SERIE, 0) AS NUM_SERIE_NF,   ');
   SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
   SQL.Add('       COALESCE(REPLACE(CAPA.CFOP, ''.'', ''''), '''') AS CFOP,   ');
   SQL.Add('       0 AS TIPO_NF,   ');
   SQL.Add('       CASE ');
   SQL.Add('          WHEN CAPA.MODELO = 55 THEN''NFE''');
   SQL.Add('          ELSE ''NF''');
   SQL.Add('       END AS DES_ESPECIE,');
   SQL.Add('       CAPA.VALORTOTALNOTA AS VAL_TOTAL_NF,   ');
   SQL.Add('          ');
   SQL.Add('       CAPA.DATAEMISSAO AS DTA_EMISSAO,');
   SQL.Add('          ');
   SQL.Add('       CAPA.DATAENTRADA AS DTA_ENTRADA,');
   SQL.Add('          ');
   SQL.Add('       COALESCE(CAPA.VALORTOTALIPI, 0) AS VAL_TOTAL_IPI,   ');
   SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
   SQL.Add('       COALESCE(CAPA.VALORFRETE, 0) AS VAL_FRETE,   ');
   SQL.Add('       COALESCE(CAPA.VALORACRESCIMO, 0) AS VAL_ACRESCIMO,   ');
   SQL.Add('       COALESCE(CAPA.VALORDESCONTO, 0) AS VAL_DESCONTO,   ');
   SQL.Add('       COALESCE(TRIM(REPLACE(REPLACE(REPLACE(CAPA.CNPJFORNECEDOR, ''.'', ''''), ''-'', ''''), ''/'','''')), '''') AS NUM_CGC,   ');
   SQL.Add('       COALESCE(CAPA.BASECALCULOICMS, 0) AS VAL_TOTAL_BC,   ');
   SQL.Add('       COALESCE(CAPA.VALORICMS, 0) AS VAL_TOTAL_ICMS,   ');
   SQL.Add('       COALESCE(CAPA.BASECALCULOICMSSUBSTITUICAO, 0) AS VAL_BC_SUBST,   ');
   SQL.Add('       COALESCE(CAPA.VALORICMSSUBSTITUICAO, 0) AS VAL_ICMS_SUBST,   ');
   SQL.Add('       0 AS VAL_FUNRURAL,   ');
   SQL.Add('       1 AS COD_PERFIL,   ');
   SQL.Add('       0 AS VAL_DESP_ACESS,   ');
   SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
   SQL.Add('       COALESCE(CAPA.OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
   SQL.Add('       COALESCE(CAPA.CHAVENFE, 0) AS NUM_CHAVE_ACESSO   ');
   SQL.Add('   FROM   ');
   SQL.Add('       ENTRADAS AS CAPA   ');
   SQL.Add('   LEFT JOIN CLIENTES ON CAPA.CODIGOFORNECEDOR = CLIENTES.CODIGO   ');
   SQL.Add('WHERE');
   SQL.Add('    CAPA.EMPRESA = '+ CbxLoja.Text +'');
   SQL.Add('   AND CLIENTES.TIPO IN (''F'', ''P'')   ');
   SQL.Add('   AND CAPA.CANCELADO IS NULL');
   SQL.Add('AND');
   SQL.Add(' CAPA.DATAEMISSAO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
   SQL.Add('AND');
   SQL.Add(' CAPA.DATAEMISSAO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
   SQL.Add(' ORDER BY CAPA.NUMERONOTA, CAPA.CODIGOFORNECEDOR, CAPA.MODELO_SERIE ');

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

procedure TFrmMyCommercePredileto.GerarNFitensClientes;
var
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
     SQL.Add('       CAPA.CODIGOCLIENTE AS COD_CLIENTE,   ');
     SQL.Add('       CAPA.NF AS NUM_NF_CLI,   ');
     SQL.Add('       CAPA.SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN LENGTH(CAST(PRODUTOS.CODIGOBARRAS AS INTEGER)) < 8 THEN PRODUTOS.CODIGO   ');
     SQL.Add('           ELSE 30000 + PRODUTOS.CODIGO   ');
     SQL.Add('       END  AS COD_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4            ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25          ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 4      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33    ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4    ');
     SQL.Add('           ELSE 1      ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(ITENS.QTDE, 1) AS QTD_EMBALAGEM,   ');
     SQL.Add('       COALESCE(ITENS.QTDE, 1) AS QTD_ENTRADA,   ');
     SQL.Add('       COALESCE(ITENS.UN, ''UN'') AS DES_UNIDADE,   ');
     SQL.Add('       ITENS.VALORTABELA AS VAL_TABELA,   ');
     SQL.Add('       ITENS.VALORDESCONTO AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       0 AS VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       ITENS.VALORIPI AS VAL_IPI_ITEM,   ');
     SQL.Add('       ITENS.VALORICMS AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       ITENS.VALORTOTAL AS VAL_TABELA_LIQ,   ');
     SQL.Add('       ITENS.VALORCUSTO AS VAL_CUSTO_REP,   ');
     SQL.Add('       REPLACE(REPLACE(REPLACE(CLIENTES.CGC, ''/'', ''''), ''.'', ''''), ''-'', '''') AS NUM_CGC,   ');
     SQL.Add('       ITENS.BASECALCULOICMS AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('       REPLACE(CAPA.CFOP, ''.'', '''') AS COD_FISCAL,   ');
     SQL.Add('       0 AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI   ');
     SQL.Add('   FROM   ');
     SQL.Add('       NOTASSAIDAS_PRODUTOS AS ITENS   ');
     SQL.Add('   LEFT JOIN NOTASSAIDAS AS CAPA ON ITENS.NF = CAPA.NF   ');
     SQL.Add('   LEFT JOIN PRODUTOS ON ITENS.CODIGOPRODUTO = PRODUTOS.CODIGO   ');
     SQL.Add('   LEFT JOIN CLIENTES ON CAPA.CODIGOCLIENTE = CLIENTES.CODIGO   ');
     SQL.Add('   WHERE CLIENTES.TIPO IN (''C'', ''E'')   ');
     SQL.Add('   AND CAPA.EMPRESA = 1   ');
     SQL.Add('   AND CAPA.MODELONF IS NULL');
     SQL.Add('   AND ITENS.REF IS NOT NULL   ');
     SQL.Add('   AND CAPA.CANCELADA IS NULL   ');
     SQL.Add('   AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
     SQL.Add('   AND PRODUTOS.DESCRICAO IS NOT NULL');
     SQL.Add('   AND    ');
     SQL.Add('    CAPA.DATA >= :INI ');
     SQL.Add('   AND    ');
     SQL.Add('    CAPA.DATA <= :FIM ');
     SQL.Add('   ORDER BY CAPA.NF, CAPA.CODIGOCLIENTE, CAPA.SERIE ');

     Parameters.ParamByName('INI').Value := FormatDateTime('yyyy-mm-dd', DtpInicial.Date);
     Parameters.ParamByName('FIM').Value := FormatDateTime('yyyy-mm-dd', DtpFinal.Date);


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

      if( (Layout.FieldByName('COD_CLIENTE').AsString = fornecedor) and
        (Layout.FieldByName('NUM_NF_CLI').AsString = nota) and
        (Layout.FieldByName('NUM_SERIE_NF').AsString = serie) ) then
      begin
          inc(count);
      end
      else
      begin
        fornecedor := Layout.FieldByName('COD_CLIENTE').AsString;
        nota := Layout.FieldByName('NUM_NF_CLI').AsString;
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

procedure TFrmMyCommercePredileto.GerarNFitensFornec;
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

   SQL.Add('   SELECT   ');
   SQL.Add('       CAPA.CODIGOFORNECEDOR AS COD_FORNECEDOR,   ');
   SQL.Add('       COALESCE(CAPA.NUMERONOTA, 0) AS NUM_NF_FORN,   ');
   SQL.Add('       COALESCE(CAPA.MODELO_SERIE, 0) AS NUM_SERIE_NF,   ');
   SQL.Add('	CASE');
   SQL.Add('		WHEN LENGTH(CAST(PRODUTOS.CODIGOBARRAS AS INTEGER)) < 8 THEN PRODUTOS.CODIGO');
   SQL.Add('		ELSE 30000 + PRODUTOS.CODIGO');
   SQL.Add('	END AS COD_PRODUTO,');
   SQL.Add('          ');
   SQL.Add('       CASE      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 40      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 40            ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 40      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 40      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 40      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25          ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 40      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 40      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 40      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22      ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22       ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33 ');
   SQL.Add('           WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4 ');
   SQL.Add('           ELSE 1');
   SQL.Add('       END AS COD_TRIBUTACAO,   ');
   SQL.Add('          ');
   SQL.Add('       COALESCE(ITENS.QUANTIDADEENTRADA, 1) AS QTD_EMBALAGEM,   ');
   SQL.Add('       COALESCE(ITENS.QUANTIDADENF, 1) AS QTD_ENTRADA,   ');
   SQL.Add('       COALESCE(ITENS.UNCOMPRA, ''UN'') AS DES_UNIDADE,   ');
   SQL.Add('       ITENS.CUSTOFISCAL AS VAL_TABELA,   ');
   SQL.Add('       COALESCE(ITENS.DESCONTO, 0) AS VAL_DESCONTO_ITEM,   ');
   SQL.Add('       COALESCE(ITENS.ACRESCIMO, 0) AS VAL_ACRESCIMO_ITEM,   ');
   SQL.Add('       ITENS.IPI AS VAL_IPI_ITEM,   ');
   SQL.Add('       0 AS VAL_SUBST_ITEM,   ');
   SQL.Add('       ITENS.FRETE AS VAL_FRETE_ITEM,   ');
   SQL.Add('       0 AS VAL_CREDITO_ICMS,   ');
   SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
   SQL.Add('       ITENS.VALORTOTAL AS VAL_TABELA_LIQ,   ');
   SQL.Add('       COALESCE(TRIM(REPLACE(REPLACE(REPLACE(CAPA.CNPJFORNECEDOR, ''.'', ''''), ''-'', ''''), ''/'','''')), '''') AS NUM_CGC,   ');
   SQL.Add('       COALESCE(ITENS.BASECALCULOICMS, 0) AS VAL_TOT_BC_ICMS,   ');
   SQL.Add('       COALESCE(ITENS.OUTROS_ICMSST, 0) AS VAL_TOT_OUTROS_ICMS,   ');
   SQL.Add('       COALESCE(REPLACE(CAPA.CFOP, ''.'', ''''), '''') AS CFOP,   ');
   SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
   SQL.Add('       0 AS VAL_TOT_BC_ST,   ');
   SQL.Add('       0 AS VAL_TOT_ST,   ');
   SQL.Add('       1 AS NUM_ITEM,   ');
   SQL.Add('       0 AS TIPO_IPI,   ');
   SQL.Add('       REPLACE(ITENS.NCM, ''.'', '''') AS NUM_NCM,   ');
   SQL.Add('       COALESCE(ITENS.REFERENCIA, '''') AS DES_REFERENCIA   ');
   SQL.Add('   FROM   ');
   SQL.Add('       ENTRADASPRODUTOS AS ITENS   ');
   SQL.Add('   LEFT JOIN ENTRADAS AS CAPA ON ITENS.CODIGOENTRADA = CAPA.CODIGO   ');
   SQL.Add('   LEFT JOIN PRODUTOS ON ITENS.CODIGO = PRODUTOS.CODIGO   ');
   SQL.Add('   LEFT JOIN CLIENTES ON CAPA.CODIGOFORNECEDOR = CLIENTES.CODIGO   ');
   SQL.Add('WHERE    ');
   SQL.Add('   CAPA.EMPRESA = '+ CbxLoja.Text +'');
   SQL.Add('   AND PRODUTOS.DESCRICAO IS NOT NULL   ');
   SQL.Add('   AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''   ');
   SQL.Add('   AND CLIENTES.TIPO IN (''F'', ''P'')   ');
   SQL.Add('   AND CAPA.CANCELADO IS NULL');
   SQL.Add('AND');
   SQL.Add(' CAPA.DATAEMISSAO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
   SQL.Add('AND');
   SQL.Add(' CAPA.DATAEMISSAO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
   SQL.Add(' ORDER BY CAPA.NUMERONOTA, CAPA.CODIGOFORNECEDOR, CAPA.MODELO_SERIE ');



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

procedure TFrmMyCommercePredileto.GerarProdForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('		WHEN LENGTH(CAST(PRODUTOS.CODIGOBARRAS AS INTEGER)) < 8 THEN PRODUTOS.CODIGO');
    SQL.Add('		ELSE 30000 + PRODUTOS.CODIGO');
    SQL.Add('	END AS COD_PRODUTO,');
    SQL.Add('');
    SQL.Add('    PRODUTOSFORNECEDOR.IDFORNECEDOR AS COD_FORNECEDOR,');
    SQL.Add('    '''' AS DES_REFERENCIA,');
    SQL.Add('    '''' AS NUM_CGC,');
    SQL.Add('    0 AS COD_DIVISAO,');
    SQL.Add('    PRODUTOS.UNCOMPRA AS DES_UNIDADE_COMPRA,');
    SQL.Add('    1 AS QTD_EMBALAGEM_COMPRA');
    SQL.Add('FROM PRODUTOSFORNECEDOR');
    SQL.Add('INNER JOIN PRODUTOS');
    SQL.Add('ON PRODUTOSFORNECEDOR.IDPRODUTOS = PRODUTOS.CODIGO');
    SQL.Add('INNER JOIN CLIENTES');
    SQL.Add('ON PRODUTOSFORNECEDOR.IDFORNECEDOR = CLIENTES.CODIGO');
    SQL.Add('AND CLIENTES.TIPO IN (''F'', ''P'')');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
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

procedure TFrmMyCommercePredileto.GerarProdLoja;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT      ');
    SQL.Add('    CASE');
    SQL.Add('        WHEN LENGTH(CAST(PRODUTOS.CODIGOBARRAS AS INTEGER)) < 8 THEN PRODUTOS.CODIGO');
    SQL.Add('        ELSE 30000 + PRODUTOS.CODIGO');
    SQL.Add('    END AS COD_PRODUTO,  ');
    SQL.Add('                ');
    SQL.Add('    COALESCE(PRODUTOS.CUSTOFINAL, 0) AS VAL_CUSTO_REP,      ');
    SQL.Add('    COALESCE(PRODUTOS.VENDAT1, 0) AS VAL_VENDA,       ');
    SQL.Add('    COALESCE(PRODUTOS.VALORPROMOCAO, 0) AS VAL_OFERTA,       ');
    SQL.Add('    COALESCE(PRODUTOSESTOQUE.ESTOQUE, 1) AS QTD_EST_VDA,       ');
    SQL.Add('    COALESCE(PRODUTOS.TECLABALANCA, '''') AS TECLA_BALANCA,      ');
    SQL.Add('    CASE   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4         ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25       ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33 ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4 ');
    SQL.Add('        ELSE 1   ');
    SQL.Add('    END AS COD_TRIBUTACAO, ');
    SQL.Add('');
    SQL.Add('    0 AS VAL_MARGEM,       ');
    SQL.Add('    1 AS QTD_ETIQUETA,       ');
    SQL.Add('');
    SQL.Add('    CASE   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''38.89'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''040'' THEN 1   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4         ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''14'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''13'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''0'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''000'' THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 25       ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''060'' THEN 25   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''19'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''400'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''000'' THEN 2   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS IS NULL AND PRODUTOS.BASECALCULOICMS IS NULL AND PRODUTOS.CODIGOCF IS NULL THEN 11   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''12'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF IS NULL THEN 3   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''38.89'' AND PRODUTOS.BASECALCULOICMS = ''18'' AND PRODUTOS.CODIGOCF = ''020'' THEN 33   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''041'' THEN 23   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''020'' THEN 4   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''0'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22   ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''20'' AND PRODUTOS.BASECALCULOICMS = ''100'' AND PRODUTOS.CODIGOCF = ''090'' THEN 22    ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''7'' AND  PRODUTOS.BASECALCULOICMS IS NULL  AND  PRODUTOS.CODIGOCF = ''020'' THEN 33 ');
    SQL.Add('        WHEN PRODUTOS.ALIQUOTAICMS = ''18'' AND  PRODUTOS.BASECALCULOICMS = ''0''  AND  PRODUTOS.CODIGOCF = ''020'' THEN 4 ');
    SQL.Add('    END AS COD_TRIB_ENTRADA,      ');
    SQL.Add('    ''N'' AS FLG_INATIVO,       ');
    SQL.Add('    PRODUTOS.CODIGO AS COD_PRODUTO_ANT,       ');
    SQL.Add('    REPLACE(PRODUTOS.NCM, ''.'', '''') AS NUM_NCM,      ');
    SQL.Add('    0 AS TIPO_NCM,       ');
    SQL.Add('    0 AS VAL_VENDA_2,       ');
    SQL.Add('    PRODUTOS.DATAPROMOCAO AS DTA_VALIDA_OFERTA,   ');
    SQL.Add('');
    SQL.Add('    COALESCE(PRODUTOS.ESTOQUEMINIMO, 1) AS QTD_EST_MINIMO,       ');
    SQL.Add('    COALESCE(PRODUTOS.CODIGOVASILHAME, NULL) AS COD_VASILHAME,       ');
    SQL.Add('    ''N'' AS FORA_LINHA,       ');
    SQL.Add('    0 AS QTD_PRECO_DIF,       ');
    SQL.Add('    0 AS VAL_FORCA_VDA,   ');
    SQL.Add('    CASE WHEN COALESCE(PRODUTOS.CEST, '''') = '''' THEN ''9999999'' ELSE PRODUTOS.CEST END AS NUM_CEST,');
    SQL.Add('    0 AS PER_IVA,');
    SQL.Add('    0 AS PER_FCP_ST  ');
    SQL.Add('   ');
    SQL.Add('FROM PRODUTOS AS PRODUTOS      ');
    SQL.Add('LEFT JOIN PRODUTOSESTOQUE ');
    SQL.Add('ON PRODUTOS.CODIGO = PRODUTOSESTOQUE.CODIGOPRODUTO');
    SQL.Add('WHERE PRODUTOS.DESCRICAO IS NOT NULL');
    SQL.Add('AND PRODUTOS.CODIGOBARRAS <> ''INATIVO''');
   // SQL.Add('ORDER BY PRODUTOS.ATIVO');



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
       Layout.FieldByName('COD_PRODUTO_ANT').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO_ANT').AsString);

//      if( Layout.FieldByName('DTA_VALIDA_OFERTA').AsString <> '' ) then
         Layout.FieldByName('DTA_VALIDA_OFERTA').AsDateTime := FieldByName('DTA_VALIDA_OFERTA').AsDateTime;


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

procedure TFrmMyCommercePredileto.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('     FAMILIAS.ID AS COD_PRODUTO_SIMILAR,');
    SQL.Add('     FAMILIAS.DESCRITIVO AS DES_PRODUTO_SIMILAR,');
    SQL.Add('     0 AS VAL_META');
    SQL.Add('FROM');
    SQL.Add('     FAMILIAS');


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
