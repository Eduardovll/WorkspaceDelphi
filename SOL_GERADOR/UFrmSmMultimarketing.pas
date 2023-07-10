unit UFrmSmMultimarketing;

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
  TFrmSmMultimarketing = class(TFrmModeloSis)
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
  FrmSmMultimarketing: TFrmSmMultimarketing;
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


procedure TFrmSmMultimarketing.GerarProducao;
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

procedure TFrmSmMultimarketing.GerarProduto;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('       PRODUTO.CDPRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       BARRAS.CDEAN AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       COALESCE(S_PRODUTO.NMPRODUTOPAI, ''A DEFINIR'') AS DES_REDUZIDA,   ');
     SQL.Add('       COALESCE(S_PRODUTO.NMPRODUTOPAI, ''A DEFINIR'') AS DES_PRODUTO,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.CDUNIDADEMEDIDA = ''G'' THEN ''KG''   ');
     SQL.Add('           ELSE COALESCE(UPPER(S_PRODUTO.CDUNIDADEMEDIDA), ''UN'')    ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('      ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.CDUNIDADEMEDIDA = ''G'' THEN ''KG''   ');
     SQL.Add('           ELSE COALESCE(UPPER(S_PRODUTO.CDUNIDADEMEDIDA), ''UN'')    ');
     SQL.Add('       END AS DES_UNIDADE_VENDA,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       COALESCE(PRODUTO.EXIPI, 0) AS VAL_IPI,   ');
     SQL.Add('       CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 2, 2), ''999'') AS INT) AS COD_SECAO,   ');
     SQL.Add('       CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 4, 3), ''999'') AS INT) AS COD_GRUPO,   ');
     SQL.Add('       CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 8, 5), ''999'') AS INT) AS COD_SUB_GRUPO,   ');
     SQL.Add('       COALESCE(SIMILAR.CDSUPERPRODUTO, 0) AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN S_PRODUTO.INFRACIONADO = 1 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 4 THEN ''S''   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 6 THEN ''S''   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 9 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN S_PRODUTO.INFRACIONADO = 1 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 4 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 6 THEN 0   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 9 THEN 4   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       0 AS COD_INFO_RECEITA,   ');
     SQL.Add('       COALESCE(S_PRODUTO.CDNATRECPIS, 999) AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.INALCOOLICA = 1 THEN ''S''   ');
     SQL.Add('           ELSE ''N''    ');
     SQL.Add('       END AS FLG_ALCOOLICO,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS TIPO_ESPECIE,   ');
     SQL.Add('       0 AS COD_CLASSIF,   ');
     SQL.Add('       1 AS VAL_VDA_PESO_BRUTO,   ');
     SQL.Add('       1 AS VAL_PESO_EMB,   ');
     SQL.Add('       0 AS TIPO_EXPLOSAO_COMPRA,   ');
     SQL.Add('       '''' AS DTA_INI_OPER,   ');
     SQL.Add('       '''' AS DES_PLAQUETA,   ');
     SQL.Add('       '''' AS MES_ANO_INI_DEPREC,   ');
     SQL.Add('       0 AS TIPO_BEM,   ');
     SQL.Add('       COALESCE(PROD_FORN.CDPESSOACOMERCIAL, 0) AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       PRODUTO.DTCADASTRO AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       COALESCE(S_PRODUTO.NMPRODUTOPAI, ''A DEFINIR'') AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN TBSUPERPRODUTO AS S_PRODUTO ON S_PRODUTO.CDSUPERPRODUTO = PRODUTO.CDSUPERPRODUTO   ');
     SQL.Add('   LEFT JOIN TBPRODUTOVENDA AS BARRAS ON BARRAS.CDPRODUTO = PRODUTO.CDPRODUTO   ');
     SQL.Add('   LEFT JOIN TBCLASSIFICACAOPRODUTO ON TBCLASSIFICACAOPRODUTO.CDCLASSIFICACAOPRODUTO = S_PRODUTO.CDCLASSIFICACAOPRODUTO   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('      SELECT   ');
     SQL.Add('   		    PRODUTO.CDSUPERPRODUTO   ');
     SQL.Add('   	  FROM   ');
     SQL.Add('   		    TBPRODUTO AS PRODUTO   ');
     SQL.Add('   	  GROUP BY PRODUTO.CDSUPERPRODUTO   ');
     SQL.Add('   	  HAVING COUNT(*) > 1   ');
     SQL.Add('   ) AS SIMILAR   ');
     SQL.Add('   ON PRODUTO.CDSUPERPRODUTO = SIMILAR.CDSUPERPRODUTO   ');
     SQL.Add('   LEFT JOIN TBPRODUTOPESSOACOMERCIALNFE AS PROD_FORN ON PROD_FORN.CDPRODUTO = PRODUTO.CDPRODUTO  ');


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


procedure TFrmSmMultimarketing.GerarSecao;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT    ');
     SQL.Add('   	CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 2, 2), ''999'') AS INT) AS COD_SECAO,   ');
     SQL.Add('   	TBCLASSIFICACAOPRODUTO.NMCLASSIFICACAOPRODUTO AS DES_SECAO,   ');
     SQL.Add('   	0 AS VAL_META   ');
     SQL.Add('   FROM TBCLASSIFICACAOPRODUTO   ');
     SQL.Add('   WHERE TBCLASSIFICACAOPRODUTO.NMCLASSIFICACAOPRODUTO IN (   ');
     SQL.Add('   ''01-MERCEARIA SALGADA'',   ');
     SQL.Add('   ''02-MERCEARIA DOCE'',   ');
     SQL.Add('   ''03-MERCEARIA LIQUIDA'',   ');
     SQL.Add('   ''04-HPLU'',   ');
     SQL.Add('   ''05-ACOUGUE'',   ');
     SQL.Add('   ''06-PERECIVEIS'',   ');
     SQL.Add('   ''07-LATICINIOS'',   ');
     SQL.Add('   ''08-FLV'',   ');
     SQL.Add('   ''09-FABRICO'',   ');
     SQL.Add('   ''10-EXTRA'',   ');
     SQL.Add('   ''11-SERVICO'',   ');
     SQL.Add('   ''12-USO CONSUMO'',   ');
     SQL.Add('   ''13-EMBALAGENS'',   ');
     SQL.Add('   ''14-PRODUCAO'',   ');
     SQL.Add('   ''15-ADMINISTRATIVO'',   ');
     SQL.Add('   ''97-EM TRANSITO'',   ');
     SQL.Add('   ''98-PATRIMONIAL'',   ');
     SQL.Add('   ''99-FORA DE LINHA''   ');
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

procedure TFrmSmMultimarketing.GerarSubGrupo;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT  ');
     SQL.Add('       CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 2, 2), ''999'') AS INT) AS COD_SECAO,   ');
     SQL.Add('       CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 4, 3), ''999'') AS INT) AS COD_GRUPO,   ');
     SQL.Add('       CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 8, 5), ''999'') AS INT) AS COD_SUB_GRUPO,   ');
     SQL.Add('       TBCLASSIFICACAOPRODUTO.NMCLASSIFICACAOPRODUTO AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 AS VAL_META,   ');
     SQL.Add('       0 AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('   	''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('   	TBCLASSIFICACAOPRODUTO   ');
     SQL.Add('   WHERE LEN(TBCLASSIFICACAOPRODUTO.CDORDEM) = 12  ');




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

procedure TFrmSmMultimarketing.GerarValorVenda;
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

procedure TFrmSmMultimarketing.GerarVenda;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CUPOMPRODUTOS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
     SQL.Add('       0 AS IND_TIPO,   ');
     SQL.Add('       1 AS NUM_PDV,   ');
     SQL.Add('       CUPOMPRODUTOS.SAI_QTDE AS QTD_TOTAL_PRODUTO,   ');
     SQL.Add('       CUPOMPRODUTOS.SAI_TOTAL - CUPOMPRODUTOS.PRO_DESCONTO AS VAL_TOTAL_PRODUTO,   ');
     SQL.Add('       CUPOMPRODUTOS.PRO_VENDA AS VAL_PRECO_VENDA,   ');
     SQL.Add('       CUPOMPRODUTOS.PRO_CUSTO AS VAL_CUSTO_REP,   ');
     SQL.Add('       CUPOMFISCAL.COM_DATA AS DTA_SAIDA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN DATEPART(MONTH,CUPOMFISCAL.COM_DATA)<10 THEN ''0''+CAST(DATEPART(MONTH,CUPOMFISCAL.COM_DATA) AS VARCHAR)+CAST(DATEPART(YEAR,CUPOMFISCAL.COM_DATA) AS VARCHAR)   ');
     SQL.Add('           ELSE CAST(DATEPART(MONTH,CUPOMFISCAL.COM_DATA) AS VARCHAR)+CAST(DATEPART(YEAR,CUPOMFISCAL.COM_DATA) AS VARCHAR)         ');
     SQL.Add('       END AS DTA_MENSAL,   ');
     SQL.Add('      ');
     SQL.Add('       CUPOMPRODUTOS.SAI_REGISTRO AS NUM_IDENT,   ');
     SQL.Add('       '''' AS COD_EAN,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN DATEPART(HH,CUPOMFISCAL.COM_HORA)<10 AND DATEPART(MI,CUPOMFISCAL.COM_HORA)<10 THEN ''0''+CAST(DATEPART(HH,CUPOMFISCAL.COM_HORA) AS VARCHAR)+''0''+CAST(DATEPART(MI,CUPOMFISCAL.COM_HORA) AS VARCHAR)     ');
     SQL.Add('           WHEN DATEPART(HH,CUPOMFISCAL.COM_HORA)>10 AND DATEPART(MI,CUPOMFISCAL.COM_HORA)>10 THEN CAST(DATEPART(HH,CUPOMFISCAL.COM_HORA) AS VARCHAR)+CAST(DATEPART(MI,CUPOMFISCAL.COM_HORA) AS VARCHAR)   ');
     SQL.Add('           WHEN DATEPART(HH,CUPOMFISCAL.COM_HORA)<10 AND DATEPART(MI,CUPOMFISCAL.COM_HORA)>10 THEN ''0''+CAST(DATEPART(HH,CUPOMFISCAL.COM_HORA) AS VARCHAR)+CAST(DATEPART(MI,CUPOMFISCAL.COM_HORA) AS VARCHAR)   ');
     SQL.Add('           WHEN DATEPART(HH,CUPOMFISCAL.COM_HORA)>10 AND DATEPART(MI,CUPOMFISCAL.COM_HORA)<10 THEN CAST(DATEPART(HH,CUPOMFISCAL.COM_HORA) AS VARCHAR)+''0''+CAST(DATEPART(MI,CUPOMFISCAL.COM_HORA) AS VARCHAR)     ');
     SQL.Add('           ELSE SUBSTRING(REPLACE(CUPOMFISCAL.COM_HORA, '':'', ''''), 0, 5)   ');
     SQL.Add('       END AS DES_HORA,   ');
     SQL.Add('      ');
     SQL.Add('       CUPOMFISCAL.CLI_CODIGO AS COD_CLIENTE,   ');
     SQL.Add('       CASE');
     SQL.Add('          WHEN CUPOMFISCAL.COM_DINHEIRO <> 0 THEN 1');
     SQL.Add('          WHEN CUPOMFISCAL.COM_CHEQUE <> 0 THEN 2');
     SQL.Add('          WHEN CUPOMFISCAL.COM_CHEQUEPRE <> 0 THEN 3');
     SQL.Add('          WHEN CUPOMFISCAL.COM_PRAZO <> 0 THEN 4');
     SQL.Add('          WHEN CUPOMFISCAL.COM_DUPLICATA <> 0 THEN 9');
     SQL.Add('          WHEN CUPOMFISCAL.COM_CARTAO <> 0 THEN 14');
     SQL.Add('          WHEN CUPOMFISCAL.COM_OUTROS <> 0 THEN 16');
     SQL.Add('          WHEN CUPOMFISCAL.COM_CONTRAVALEEMI <> 0 THEN 18');
     SQL.Add('          WHEN CUPOMFISCAL.COM_TICKET <> 0 THEN 28');
     SQL.Add('          WHEN CUPOMFISCAL.COM_TECBAN <> 0 THEN 29');
     SQL.Add('          ELSE 26');
     SQL.Add('       END AS COD_ENTIDADE,   ');
     SQL.Add('       0 AS VAL_BASE_ICMS,   ');
     SQL.Add('       CUPOMPRODUTOS.PRO_SIT_TRIBUTARIA AS DES_SITUACAO_TRIB,   ');
     SQL.Add('       0 AS VAL_ICMS,   ');
     SQL.Add('       CUPOMFISCAL.COM_NCUPOM AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       CUPOMPRODUTOS.SAI_TOTAL - CUPOMPRODUTOS.PRO_DESCONTO AS VAL_VENDA_PDV,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 1 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 2 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 4 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 5 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 6 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 7 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 8 THEN 8   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 9 THEN 6   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 10 THEN 7   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 11 THEN 27   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 12 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 13 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 14 THEN 20   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 15 THEN 39   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 16 THEN 39   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 17 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_CODIGO = 18 THEN 40   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN CUPOMPRODUTOS.SAI_STATUS <> ''A''  THEN ''S''    ');
     SQL.Add('           ELSE ''N''    ');
     SQL.Add('       END AS FLG_CUPOM_CANCELADO,   ');
     SQL.Add('      ');
     SQL.Add('       CUPOMPRODUTOS.PRO_CLASFISCAL AS NUM_NCM,   ');
     SQL.Add('       COALESCE(PRODUTOS.NATR_CODIGO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA IS NULL AND PRODUTOS.PRO_CST_COFINS IS NULL THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = '''' AND PRODUTOS.PRO_CST_COFINS = '''' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''50'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''04'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''05'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''73'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''53'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''03'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''74'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''75'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN ''N''      ');
     SQL.Add('           ELSE ''N''      ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,      ');
     SQL.Add('      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA IS NULL AND PRODUTOS.PRO_CST_COFINS IS NULL THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = '''' AND PRODUTOS.PRO_CST_COFINS = '''' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''50'' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''04'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''05'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''73'' THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1       ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''53'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''03'' THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''74'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''75'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN 2      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN -1      ');
     SQL.Add('           ELSE -1      ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,     ');
     SQL.Add('      ');
     SQL.Add('       ''S'' AS FLG_ONLINE,   ');
     SQL.Add('       ''N'' AS FLG_OFERTA,   ');
     SQL.Add('       0 AS COD_ASSOCIADO   ');
     SQL.Add('   FROM       ');
     SQL.Add('       DBO.SP_'+FORMATDATETIME('MM_YYYY',DTPINICIAL.DATE)+' AS CUPOMPRODUTOS   ');
     SQL.Add('   LEFT JOIN    ');
     SQL.Add('       DBO.CP_'+FORMATDATETIME('MM_YYYY',DTPINICIAL.DATE)+' AS CUPOMFISCAL    ');
     SQL.Add('   ON   ');
     SQL.Add('       CUPOMPRODUTOS.COM_REGISTRO = CUPOMFISCAL.COM_REGISTRO   ');
     SQL.Add('   LEFT JOIN    ');
     SQL.Add('       DBO.PRODUTOS AS PRODUTOS    ');
     SQL.Add('   ON   ');
     SQL.Add('       CUPOMPRODUTOS.PRO_CODIGO = PRODUTOS.PRO_CODIGO    ');
//     SQL.Add('   WHERE');
//     SQL.Add('      CUPOMFISCAL.COM_DATA >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
//     SQL.Add('   AND');
//     SQL.Add('      CUPOMFISCAL.COM_DATA <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

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

procedure TFrmSmMultimarketing.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmMultimarketing.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmMultimarketing.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmMultimarketing.BtnGerarClick(Sender: TObject);
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



procedure TFrmSmMultimarketing.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmMultimarketing.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmMultimarketing.CkbProdLojaClick(Sender: TObject);
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

procedure TFrmSmMultimarketing.FormCreate(Sender: TObject);
begin
  inherited;

end;

//procedure Dourado.FormCreate(Sender: TObject);
//begin
//  inherited;
////  Left:=(Screen.Width-Width)  div 2;
////  Top:=(Screen.Height-Height) div 2;
//end;

procedure TFrmSmMultimarketing.GeraCustoRep;
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

procedure TFrmSmMultimarketing.GeraEstoqueVenda;
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

procedure TFrmSmMultimarketing.GerarCest;
var
   count : integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       0 AS COD_CEST,   ');
     SQL.Add('       COALESCE(CEST.CEST, ''9999999'') AS NUM_CEST,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_CEST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPRODUTO AS CEST   ');




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

procedure TFrmSmMultimarketing.GerarCliente;
begin

   inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('           SELECT DISTINCT      ');
     SQL.Add('               CLIENTES.CDPESSOA AS COD_CLIENTE,      ');
     SQL.Add('               P_FISICA.NMCOMPLETO AS DES_CLIENTE,      ');
     SQL.Add('               P_FISICA.CPF + P_FISICA.CPFDV AS NUM_CGC,      ');
     SQL.Add('               COALESCE(P_FISICA.INSCRICAOESTADUAL, '''') AS NUM_INSC_EST,      ');
     SQL.Add('               ENDERECO.LOGRADOURO AS DES_ENDERECO,      ');
     SQL.Add('               ENDERECO.BAIRRO AS DES_BAIRRO,      ');
     SQL.Add('               COALESCE(ENDERECO.CIDADE, '''') AS DES_CIDADE,      ');
     SQL.Add('               COALESCE(ENDERECO.CDESTADO, ''RJ'') AS DES_SIGLA,      ');
     SQL.Add('               ENDERECO.CEP AS NUM_CEP,      ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN LEN(COALESCE(TEL.DDD + TEL.NUMERO, '''')) < 11 THEN COALESCE(TEL.DDD + TEL.NUMERO, '''')      ');
     SQL.Add('                   ELSE ''''      ');
     SQL.Add('               END AS NUM_FONE,      ');
     SQL.Add('               '''' AS NUM_FAX,      ');
     SQL.Add('               '''' AS DES_CONTATO,      ');
     SQL.Add('               0 AS FLG_SEXO,      ');
     SQL.Add('               0 AS VAL_LIMITE_CRETID,      ');
     SQL.Add('               0 AS VAL_LIMITE_CONV,      ');
     SQL.Add('               0 AS VAL_DEBITO,      ');
     SQL.Add('               0 AS VAL_RENDA,      ');
     SQL.Add('               0 AS COD_CONVENIO,      ');
     SQL.Add('               0 AS COD_STATUS_PDV,      ');
     SQL.Add('               ''N'' AS FLG_EMPRESA,      ');
     SQL.Add('               ''N'' AS FLG_CONVENIO,      ');
     SQL.Add('               ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('               CLIENTES.DTCADASTRO AS DTA_CADASTRO,      ');
     SQL.Add('               ENDERECO.NUMERO AS NUM_ENDERECO,      ');
     SQL.Add('               COALESCE(P_FISICA.IDENTIDADE, '''') AS NUM_RG,      ');
     SQL.Add('               0 AS FLG_EST_CIVIL,      ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN LEN(COALESCE(TEL.DDD + TEL.NUMERO, '''')) = 11 THEN COALESCE(TEL.DDD + TEL.NUMERO, '''')      ');
     SQL.Add('                   ELSE ''''      ');
     SQL.Add('               END AS NUM_CELULAR,      ');
     SQL.Add('               CLIENTES.DTALTERACAO AS DTA_ALTERACAO,      ');
     SQL.Add('               COALESCE(TEL.CONTATO, '''') AS DES_OBSERVACAO,      ');
     SQL.Add('               COALESCE(ENDERECO.COMPLEMENTO, ''A DEFINIR'') AS DES_COMPLEMENTO,      ');
     SQL.Add('               COALESCE(EMAIL.NMINTERNET, '''') AS DES_EMAIL,      ');
     SQL.Add('               CLIENTES.NMPESSOA AS DES_FANTASIA,      ');
     SQL.Add('               '''' AS DTA_NASCIMENTO,      ');
     SQL.Add('               '''' AS DES_PAI,      ');
     SQL.Add('               '''' AS DES_MAE,      ');
     SQL.Add('               '''' AS DES_CONJUGE,      ');
     SQL.Add('               '''' AS NUM_CPF_CONJUGE,      ');
     SQL.Add('               0 AS VAL_DEB_CONV,      ');
     SQL.Add('               ''N'' AS INATIVO,      ');
     SQL.Add('               '''' AS DES_MATRICULA,      ');
     SQL.Add('               ''N'' AS NUM_CGC_ASSOCIADO,      ');
     SQL.Add('               ''N'' AS FLG_PROD_RURAL,      ');
     SQL.Add('               0 AS COD_STATUS_PDV_CONV,      ');
     SQL.Add('               ''S'' AS FLG_ENVIA_CODIGO,      ');
     SQL.Add('               '''' AS DTA_NASC_CONJUGE,      ');
     SQL.Add('               0 AS COD_CLASSIF      ');
     SQL.Add('           FROM      ');
     SQL.Add('               TBPESSOA AS CLIENTES      ');
     SQL.Add('           LEFT JOIN TBPESSOAFISICA AS P_FISICA ON P_FISICA.CDPESSOAFISICA = CLIENTES.CDPESSOA      ');
     SQL.Add('           LEFT JOIN TBENDERECO AS ENDERECO ON ENDERECO.CDPESSOA = CLIENTES.CDPESSOA      ');
     SQL.Add('           LEFT JOIN TBTELEFONE AS TEL ON TEL.CDPESSOA = CLIENTES.CDPESSOA      ');
     SQL.Add('           LEFT JOIN TBINTERNET AS EMAIL ON EMAIL.CDPESSOA = CLIENTES.CDPESSOA   ');
     SQL.Add('           WHERE CLIENTES.INPESSOAJURIDICA = 0    ');






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
//      Layout.FieldByName('DTA_NASCIMENTO').AsDateTime := FieldByName('DTA_NASCIMENTO').AsDateTime;

      //if Layout.FieldByName('DTA_CADASTRO').AsString <> '' then
     // begin
        Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;
        //Layout.FieldByName('DTA_NASCIMENTO').AsDateTime := FieldByName('DTA_NASCIMENTO').AsDateTime;
      //end;

      //Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;
      //if Layout.FieldByName('DTA_ALTERACAO').AsString <> '' then
      //begin
        Layout.FieldByName('DTA_ALTERACAO').AsDateTime := FieldByName('DTA_ALTERACAO').AsDateTime;
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

procedure TFrmSmMultimarketing.GerarCodigoBarras;
var
 count, count1 : Integer;
 codigoBarra : string;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTO.CDPRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       BARRAS.CDEAN AS COD_EAN   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN TBPRODUTOVENDA AS BARRAS ON BARRAS.CDPRODUTO = PRODUTO.CDPRODUTO   ');



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

procedure TFrmSmMultimarketing.GerarComposicao;
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

procedure TFrmSmMultimarketing.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTES.CDPESSOA AS COD_CLIENTE,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPESSOA AS CLIENTES   ');
     SQL.Add('   WHERE CLIENTES.INPESSOAJURIDICA = 0   ');





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

procedure TFrmSmMultimarketing.GerarCondPagForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDORES.CDPESSOA AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       P_JURIDICA.CNPJEMPRESA AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPESSOA AS FORNECEDORES   ');
     SQL.Add('   LEFT JOIN TBPESSOAJURIDICA AS P_JURIDICA ON P_JURIDICA.CDPESSOAJURIDICA = FORNECEDORES.CDPESSOA   ');
     SQL.Add('   WHERE FORNECEDORES.INPESSOAJURIDICA = 1   ');






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

procedure TFrmSmMultimarketing.GerarDecomposicao;
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

procedure TFrmSmMultimarketing.GerarDivisaoForn;
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

procedure TFrmSmMultimarketing.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmMultimarketing.GerarFinanceiroPagar(Aberto: String);
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

       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       1 AS TIPO_PARCEIRO,   ');
       SQL.Add('       PAGAR_ABERTO.CDPESSOACOMERCIAL AS COD_PARCEIRO,   ');
       SQL.Add('       0 AS TIPO_CONTA,   ');
       SQL.Add('       8 AS COD_ENTIDADE,   ');
       SQL.Add('       PAGAR_ABERTO.DOCUMENTO AS NUM_DOCTO,   ');
       SQL.Add('       2 AS COD_BANCO,   ');
       SQL.Add('       '''' AS DES_BANCO,   ');
       SQL.Add('       PAGAR_ABERTO.DTINCLUSAO AS DTA_EMISSAO,   ');
       SQL.Add('       PARCELA.DTPARCELA AS DTA_VENCIMENTO,   ');
       SQL.Add('       PARCELA.VLPARCELA AS VAL_PARCELA,   ');
       SQL.Add('       COALESCE(PARCELA.VLMORA + PARCELA.VLMULTA, 0) AS VAL_JUROS,   ');
       SQL.Add('       COALESCE(PARCELA.VLDESCONTO, 0) AS VAL_DESCONTO,   ');
       SQL.Add('       ''N'' AS FLG_QUITADO,   ');
       SQL.Add('       '''' AS DTA_QUITADA,   ');
       SQL.Add('       998 AS COD_CATEGORIA,   ');
       SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
       SQL.Add('       PARCELA.CDCONTAPARCELA AS NUM_PARCELA,   ');
       SQL.Add('       PARCELAS.QTD_PARCELA AS QTD_PARCELA,   ');
       SQL.Add('       1 AS COD_LOJA,   ');
       SQL.Add('       CNPJ_1.CNPJEMPRESA + CNPJ_1.CNPJFILIAL_1 + CNPJ_1.CNPJDV_1 AS NUM_CGC,   ');
       SQL.Add('       0 AS NUM_BORDERO,   ');
       SQL.Add('       PAGAR_ABERTO.DOCUMENTO AS NUM_NF,   ');
       SQL.Add('       '''' AS NUM_SERIE_NF,   ');
       SQL.Add('       PARCELAS.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
       SQL.Add('       '''' AS DES_OBSERVACAO,   ');
       SQL.Add('       1 AS NUM_PDV,   ');
       SQL.Add('       '''' AS NUM_CUPOM_FISCAL,   ');
       SQL.Add('       0 AS COD_MOTIVO,   ');
       SQL.Add('       0 AS COD_CONVENIO,   ');
       SQL.Add('       0 AS COD_BIN,   ');
       SQL.Add('       '''' AS DES_BANDEIRA,   ');
       SQL.Add('       '''' AS DES_REDE_TEF,   ');
       SQL.Add('       0 AS VAL_RETENCAO,   ');
       SQL.Add('       2 AS COD_CONDICAO,   ');
       SQL.Add('       '''' AS DTA_PAGTO,   ');
       SQL.Add('       PAGAR_ABERTO.DTINCLUSAO AS DTA_ENTRADA,   ');
       SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
       SQL.Add('       '''' AS COD_BARRA,   ');
       SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
       SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
       SQL.Add('       '''' AS DES_TITULAR,   ');
       SQL.Add('       30 AS NUM_CONDICAO,   ');
       SQL.Add('       0 AS VAL_CREDITO,   ');
       SQL.Add('       2 AS COD_BANCO_PGTO,   ');
       SQL.Add('       ''COFRE'' AS DES_CC,   ');
       SQL.Add('       0 AS COD_BANDEIRA,   ');
       SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
       SQL.Add('       1 AS NUM_SEQ_FIN,   ');
       SQL.Add('       0 AS COD_COBRANCA,   ');
       SQL.Add('       '''' AS DTA_COBRANCA,   ');
       SQL.Add('       ''N'' AS FLG_ACEITE,   ');
       SQL.Add('       0 AS TIPO_ACEITE   ');
       SQL.Add('   FROM   ');
       SQL.Add('       TBCONTA AS PAGAR_ABERTO   ');
       SQL.Add('   LEFT JOIN TBCONTAPARCELA AS PARCELA ON PARCELA.CDCONTA = PAGAR_ABERTO.CDCONTA   ');
       SQL.Add('   LEFT JOIN (         ');
       SQL.Add('        SELECT DISTINCT         ');
       SQL.Add('             CDPESSOAJURIDICA,         ');
       SQL.Add('             CNPJEMPRESA,         ');
       SQL.Add('             CASE         ');
       SQL.Add('                  WHEN LEN(CNPJFilial) = 1 THEN ''000'' + CAST(CNPJFilial AS VARCHAR)         ');
       SQL.Add('                  WHEN LEN(CNPJFilial) = 2 THEN ''00'' + CAST(CNPJFilial AS VARCHAR)         ');
       SQL.Add('                  WHEN LEN(CNPJFilial) = 3 THEN ''0'' + CAST(CNPJFilial AS VARCHAR)         ');
       SQL.Add('                  ELSE CAST(CNPJFilial AS VARCHAR)         ');
       SQL.Add('             END AS CNPJFilial_1,         ');
       SQL.Add('             CASE         ');
       SQL.Add('                  WHEN LEN(CNPJDV) = 1 THEN ''0'' + CAST(CNPJDV AS VARCHAR)         ');
       SQL.Add('                  ELSE CAST(CNPJDV AS VARCHAR)         ');
       SQL.Add('             END AS CNPJDV_1	         ');
       SQL.Add('        FROM TBPESSOAJURIDICA         ');
       SQL.Add('   ) AS CNPJ_1         ');
       SQL.Add('   ON CNPJ_1.CDPESSOAJURIDICA = PAGAR_ABERTO.CDPESSOACOMERCIAL   ');
       SQL.Add('   LEFT JOIN (   ');
       SQL.Add('   	SELECT   ');
       SQL.Add('   		TBCONTAPARCELA.CDCONTA,   ');
       SQL.Add('   		COUNT(*) AS QTD_PARCELA,   ');
       SQL.Add('   		SUM(TBCONTAPARCELA.VLPARCELA) AS VAL_TOTAL_NF   ');
       SQL.Add('   	FROM   ');
       SQL.Add('   		TBCONTAPARCELA   ');
       SQL.Add('   	--WHERE TBCONTAPARCELA.cdConta = 55   ');
       SQL.Add('   	GROUP BY   ');
       SQL.Add('   		TBCONTAPARCELA.CDCONTA   ');
       SQL.Add('   ) AS PARCELAS   ');
       SQL.Add('   ON PAGAR_ABERTO.CDCONTA = PARCELAS.CDCONTA   ');
       SQL.Add('   WHERE PARCELA.CDCONTABAIXA IS NULL   ');
       SQL.Add('   AND PAGAR_ABERTO.CDCONTATIPO IN (1,3)   ');

      //FIM ABERTO
    end
    else
    begin
      //QUITADO

         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('       1 AS TIPO_PARCEIRO,   ');
         SQL.Add('       PAGAR_QUITADO.CDPESSOACOMERCIAL AS COD_PARCEIRO,   ');
         SQL.Add('       0 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       PAGAR_QUITADO.DOCUMENTO AS NUM_DOCTO,   ');
         SQL.Add('       2 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       PAGAR_QUITADO.DTINCLUSAO AS DTA_EMISSAO,   ');
         SQL.Add('       PARCELA.DTPARCELA AS DTA_VENCIMENTO,   ');
         SQL.Add('       PARCELA.VLPARCELA AS VAL_PARCELA,   ');
         SQL.Add('       COALESCE(PARCELA.VLMORA + PARCELA.VLMULTA, 0) AS VAL_JUROS,   ');
         SQL.Add('       COALESCE(PARCELA.VLDESCONTO, 0) AS VAL_DESCONTO,   ');
         SQL.Add('       ''S'' AS FLG_QUITADO,   ');
         SQL.Add('       BAIXA.DTCONTABAIXA AS DTA_QUITADA,   ');
         SQL.Add('       998 AS COD_CATEGORIA,   ');
         SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       PARCELA.CDCONTAPARCELA AS NUM_PARCELA,   ');
         SQL.Add('       PARCELAS.QTD_PARCELA AS QTD_PARCELA,   ');
         SQL.Add('       1 AS COD_LOJA,   ');
         SQL.Add('       CNPJ_1.CNPJEMPRESA + CNPJ_1.CNPJFILIAL_1 + CNPJ_1.CNPJDV_1 AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       PAGAR_QUITADO.DOCUMENTO AS NUM_NF,   ');
         SQL.Add('       '''' AS NUM_SERIE_NF,   ');
         SQL.Add('       PARCELAS.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
         SQL.Add('       '''' AS DES_OBSERVACAO,   ');
         SQL.Add('       1 AS NUM_PDV,   ');
         SQL.Add('       '''' AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('       0 AS COD_MOTIVO,   ');
         SQL.Add('       0 AS COD_CONVENIO,   ');
         SQL.Add('       0 AS COD_BIN,   ');
         SQL.Add('       '''' AS DES_BANDEIRA,   ');
         SQL.Add('       '''' AS DES_REDE_TEF,   ');
         SQL.Add('       0 AS VAL_RETENCAO,   ');
         SQL.Add('       2 AS COD_CONDICAO,   ');
         SQL.Add('       BAIXA.DTCONTABAIXA AS DTA_PAGTO,   ');
         SQL.Add('       PAGAR_QUITADO.DTINCLUSAO AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       '''' AS DES_TITULAR,   ');
         SQL.Add('       30 AS NUM_CONDICAO,   ');
         SQL.Add('       0 AS VAL_CREDITO,   ');
         SQL.Add('       2 AS COD_BANCO_PGTO,   ');
         SQL.Add('       ''COFRE'' AS DES_CC,   ');
         SQL.Add('       0 AS COD_BANDEIRA,   ');
         SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
         SQL.Add('       1 AS NUM_SEQ_FIN,   ');
         SQL.Add('       0 AS COD_COBRANCA,   ');
         SQL.Add('       '''' AS DTA_COBRANCA,   ');
         SQL.Add('       ''N'' AS FLG_ACEITE,   ');
         SQL.Add('       0 AS TIPO_ACEITE   ');
         SQL.Add('   FROM   ');
         SQL.Add('       TBCONTA AS PAGAR_QUITADO   ');
         SQL.Add('   LEFT JOIN TBCONTAPARCELA AS PARCELA ON PARCELA.CDCONTA = PAGAR_QUITADO.CDCONTA   ');
         SQL.Add('   LEFT JOIN TBCONTABAIXA AS BAIXA ON BAIXA.CDCONTABAIXA = PARCELA.CDCONTABAIXA   ');
         SQL.Add('   LEFT JOIN (         ');
         SQL.Add('        SELECT DISTINCT         ');
         SQL.Add('             CDPESSOAJURIDICA,         ');
         SQL.Add('             CNPJEMPRESA,         ');
         SQL.Add('             CASE         ');
         SQL.Add('                  WHEN LEN(CNPJFilial) = 1 THEN ''000'' + CAST(CNPJFilial AS VARCHAR)         ');
         SQL.Add('                  WHEN LEN(CNPJFilial) = 2 THEN ''00'' + CAST(CNPJFilial AS VARCHAR)         ');
         SQL.Add('                  WHEN LEN(CNPJFilial) = 3 THEN ''0'' + CAST(CNPJFilial AS VARCHAR)         ');
         SQL.Add('                  ELSE CAST(CNPJFilial AS VARCHAR)         ');
         SQL.Add('             END AS CNPJFilial_1,         ');
         SQL.Add('             CASE         ');
         SQL.Add('                  WHEN LEN(CNPJDV) = 1 THEN ''0'' + CAST(CNPJDV AS VARCHAR)         ');
         SQL.Add('                  ELSE CAST(CNPJDV AS VARCHAR)         ');
         SQL.Add('             END AS CNPJDV_1	         ');
         SQL.Add('        FROM TBPESSOAJURIDICA         ');
         SQL.Add('   ) AS CNPJ_1         ');
         SQL.Add('   ON CNPJ_1.CDPESSOAJURIDICA = PAGAR_QUITADO.CDPESSOACOMERCIAL   ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('   	SELECT   ');
         SQL.Add('   		TBCONTAPARCELA.CDCONTA,   ');
         SQL.Add('   		COUNT(*) AS QTD_PARCELA,   ');
         SQL.Add('   		SUM(TBCONTAPARCELA.VLPARCELA) AS VAL_TOTAL_NF   ');
         SQL.Add('   	FROM   ');
         SQL.Add('   		TBCONTAPARCELA   ');
         SQL.Add('   	--WHERE TBCONTAPARCELA.cdConta = 55   ');
         SQL.Add('   	GROUP BY   ');
         SQL.Add('   		TBCONTAPARCELA.CDCONTA   ');
         SQL.Add('   ) AS PARCELAS   ');
         SQL.Add('   ON PAGAR_QUITADO.CDCONTA = PARCELAS.CDCONTA   ');
         SQL.Add('   WHERE PARCELA.CDCONTABAIXA IS NOT NULL   ');
         SQL.Add('   AND  ');
         SQL.Add('   CAST(BAIXA.DTCONTABAIXA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
         SQL.Add('   AND');
         SQL.Add('   CAST(BAIXA.DTCONTABAIXA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
         SQL.Add('   AND PAGAR_QUITADO.CDCONTATIPO IN (1,3)   ');


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

procedure TFrmSmMultimarketing.GerarFinanceiroReceber(Aberto: String);
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
       SQL.Add('       1 AS TIPO_PARCEIRO,   ');
       SQL.Add('       PAGAR_ABERTO.CDPESSOACOMERCIAL AS COD_PARCEIRO,   ');
       SQL.Add('       1 AS TIPO_CONTA,   ');
       SQL.Add('       8 AS COD_ENTIDADE,   ');
       SQL.Add('       PAGAR_ABERTO.DOCUMENTO AS NUM_DOCTO,   ');
       SQL.Add('       2 AS COD_BANCO,   ');
       SQL.Add('       '''' AS DES_BANCO,   ');
       SQL.Add('       PAGAR_ABERTO.DTINCLUSAO AS DTA_EMISSAO,   ');
       SQL.Add('       PARCELA.DTPARCELA AS DTA_VENCIMENTO,   ');
       SQL.Add('       PARCELA.VLPARCELA AS VAL_PARCELA,   ');
       SQL.Add('       COALESCE(PARCELA.VLMORA + PARCELA.VLMULTA, 0) AS VAL_JUROS,   ');
       SQL.Add('       COALESCE(PARCELA.VLDESCONTO, 0) AS VAL_DESCONTO,   ');
       SQL.Add('       ''N'' AS FLG_QUITADO,   ');
       SQL.Add('       '''' AS DTA_QUITADA,   ');
       SQL.Add('       998 AS COD_CATEGORIA,   ');
       SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
       SQL.Add('       PARCELA.CDCONTAPARCELA AS NUM_PARCELA,   ');
       SQL.Add('       PARCELAS.QTD_PARCELA AS QTD_PARCELA,   ');
       SQL.Add('       1 AS COD_LOJA,   ');
       SQL.Add('       CNPJ_1.CNPJEMPRESA + CNPJ_1.CNPJFILIAL_1 + CNPJ_1.CNPJDV_1 AS NUM_CGC,   ');
       SQL.Add('       0 AS NUM_BORDERO,   ');
       SQL.Add('       PAGAR_ABERTO.DOCUMENTO AS NUM_NF,   ');
       SQL.Add('       '''' AS NUM_SERIE_NF,   ');
       SQL.Add('       PARCELAS.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
       SQL.Add('       '''' AS DES_OBSERVACAO,   ');
       SQL.Add('       1 AS NUM_PDV,   ');
       SQL.Add('       '''' AS NUM_CUPOM_FISCAL,   ');
       SQL.Add('       0 AS COD_MOTIVO,   ');
       SQL.Add('       0 AS COD_CONVENIO,   ');
       SQL.Add('       0 AS COD_BIN,   ');
       SQL.Add('       '''' AS DES_BANDEIRA,   ');
       SQL.Add('       '''' AS DES_REDE_TEF,   ');
       SQL.Add('       0 AS VAL_RETENCAO,   ');
       SQL.Add('       2 AS COD_CONDICAO,   ');
       SQL.Add('       '''' AS DTA_PAGTO,   ');
       SQL.Add('       PAGAR_ABERTO.DTINCLUSAO AS DTA_ENTRADA,   ');
       SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
       SQL.Add('       '''' AS COD_BARRA,   ');
       SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
       SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
       SQL.Add('       '''' AS DES_TITULAR,   ');
       SQL.Add('       30 AS NUM_CONDICAO,   ');
       SQL.Add('       0 AS VAL_CREDITO,   ');
       SQL.Add('       2 AS COD_BANCO_PGTO,   ');
       SQL.Add('       ''COFRE'' AS DES_CC,   ');
       SQL.Add('       0 AS COD_BANDEIRA,   ');
       SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
       SQL.Add('       1 AS NUM_SEQ_FIN,   ');
       SQL.Add('       0 AS COD_COBRANCA,   ');
       SQL.Add('       '''' AS DTA_COBRANCA,   ');
       SQL.Add('       ''N'' AS FLG_ACEITE,   ');
       SQL.Add('       0 AS TIPO_ACEITE   ');
       SQL.Add('   FROM   ');
       SQL.Add('       TBCONTA AS PAGAR_ABERTO   ');
       SQL.Add('   LEFT JOIN TBCONTAPARCELA AS PARCELA ON PARCELA.CDCONTA = PAGAR_ABERTO.CDCONTA   ');
       SQL.Add('   LEFT JOIN (         ');
       SQL.Add('        SELECT DISTINCT         ');
       SQL.Add('             CDPESSOAJURIDICA,         ');
       SQL.Add('             CNPJEMPRESA,         ');
       SQL.Add('             CASE         ');
       SQL.Add('                  WHEN LEN(CNPJFilial) = 1 THEN ''000'' + CAST(CNPJFilial AS VARCHAR)         ');
       SQL.Add('                  WHEN LEN(CNPJFilial) = 2 THEN ''00'' + CAST(CNPJFilial AS VARCHAR)         ');
       SQL.Add('                  WHEN LEN(CNPJFilial) = 3 THEN ''0'' + CAST(CNPJFilial AS VARCHAR)         ');
       SQL.Add('                  ELSE CAST(CNPJFilial AS VARCHAR)         ');
       SQL.Add('             END AS CNPJFilial_1,         ');
       SQL.Add('             CASE         ');
       SQL.Add('                  WHEN LEN(CNPJDV) = 1 THEN ''0'' + CAST(CNPJDV AS VARCHAR)         ');
       SQL.Add('                  ELSE CAST(CNPJDV AS VARCHAR)         ');
       SQL.Add('             END AS CNPJDV_1	         ');
       SQL.Add('        FROM TBPESSOAJURIDICA         ');
       SQL.Add('   ) AS CNPJ_1         ');
       SQL.Add('   ON CNPJ_1.CDPESSOAJURIDICA = PAGAR_ABERTO.CDPESSOACOMERCIAL   ');
       SQL.Add('   LEFT JOIN (   ');
       SQL.Add('   	SELECT   ');
       SQL.Add('   		TBCONTAPARCELA.CDCONTA,   ');
       SQL.Add('   		COUNT(*) AS QTD_PARCELA,   ');
       SQL.Add('   		SUM(TBCONTAPARCELA.VLPARCELA) AS VAL_TOTAL_NF   ');
       SQL.Add('   	FROM   ');
       SQL.Add('   		TBCONTAPARCELA   ');
       SQL.Add('   	--WHERE TBCONTAPARCELA.cdConta = 55   ');
       SQL.Add('   	GROUP BY   ');
       SQL.Add('   		TBCONTAPARCELA.CDCONTA   ');
       SQL.Add('   ) AS PARCELAS   ');
       SQL.Add('   ON PAGAR_ABERTO.CDCONTA = PARCELAS.CDCONTA   ');
       SQL.Add('   WHERE PARCELA.CDCONTABAIXA IS NULL   ');
       SQL.Add('   AND PAGAR_ABERTO.CDCONTATIPO IN (2,4)   ');

      //FIM ABERTO
    end
    else
    begin
      // QUITADO

         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('       1 AS TIPO_PARCEIRO,   ');
         SQL.Add('       PAGAR_QUITADO.CDPESSOACOMERCIAL AS COD_PARCEIRO,   ');
         SQL.Add('       1 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       PAGAR_QUITADO.DOCUMENTO AS NUM_DOCTO,   ');
         SQL.Add('       2 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       PAGAR_QUITADO.DTINCLUSAO AS DTA_EMISSAO,   ');
         SQL.Add('       PARCELA.DTPARCELA AS DTA_VENCIMENTO,   ');
         SQL.Add('       PARCELA.VLPARCELA AS VAL_PARCELA,   ');
         SQL.Add('       COALESCE(PARCELA.VLMORA + PARCELA.VLMULTA, 0) AS VAL_JUROS,   ');
         SQL.Add('       COALESCE(PARCELA.VLDESCONTO, 0) AS VAL_DESCONTO,   ');
         SQL.Add('       ''S'' AS FLG_QUITADO,   ');
         SQL.Add('       BAIXA.DTCONTABAIXA AS DTA_QUITADA,   ');
         SQL.Add('       998 AS COD_CATEGORIA,   ');
         SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       PARCELA.CDCONTAPARCELA AS NUM_PARCELA,   ');
         SQL.Add('       PARCELAS.QTD_PARCELA AS QTD_PARCELA,   ');
         SQL.Add('       1 AS COD_LOJA,   ');
         SQL.Add('       CNPJ_1.CNPJEMPRESA + CNPJ_1.CNPJFILIAL_1 + CNPJ_1.CNPJDV_1 AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       PAGAR_QUITADO.DOCUMENTO AS NUM_NF,   ');
         SQL.Add('       '''' AS NUM_SERIE_NF,   ');
         SQL.Add('       PARCELAS.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
         SQL.Add('       '''' AS DES_OBSERVACAO,   ');
         SQL.Add('       1 AS NUM_PDV,   ');
         SQL.Add('       '''' AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('       0 AS COD_MOTIVO,   ');
         SQL.Add('       0 AS COD_CONVENIO,   ');
         SQL.Add('       0 AS COD_BIN,   ');
         SQL.Add('       '''' AS DES_BANDEIRA,   ');
         SQL.Add('       '''' AS DES_REDE_TEF,   ');
         SQL.Add('       0 AS VAL_RETENCAO,   ');
         SQL.Add('       2 AS COD_CONDICAO,   ');
         SQL.Add('       BAIXA.DTCONTABAIXA AS DTA_PAGTO,   ');
         SQL.Add('       PAGAR_QUITADO.DTINCLUSAO AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       '''' AS DES_TITULAR,   ');
         SQL.Add('       30 AS NUM_CONDICAO,   ');
         SQL.Add('       0 AS VAL_CREDITO,   ');
         SQL.Add('       2 AS COD_BANCO_PGTO,   ');
         SQL.Add('       ''COFRE'' AS DES_CC,   ');
         SQL.Add('       0 AS COD_BANDEIRA,   ');
         SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
         SQL.Add('       1 AS NUM_SEQ_FIN,   ');
         SQL.Add('       0 AS COD_COBRANCA,   ');
         SQL.Add('       '''' AS DTA_COBRANCA,   ');
         SQL.Add('       ''N'' AS FLG_ACEITE,   ');
         SQL.Add('       0 AS TIPO_ACEITE   ');
         SQL.Add('   FROM   ');
         SQL.Add('       TBCONTA AS PAGAR_QUITADO   ');
         SQL.Add('   LEFT JOIN TBCONTAPARCELA AS PARCELA ON PARCELA.CDCONTA = PAGAR_QUITADO.CDCONTA   ');
         SQL.Add('   LEFT JOIN TBCONTABAIXA AS BAIXA ON BAIXA.CDCONTABAIXA = PARCELA.CDCONTABAIXA   ');
         SQL.Add('   LEFT JOIN (         ');
         SQL.Add('        SELECT DISTINCT         ');
         SQL.Add('             CDPESSOAJURIDICA,         ');
         SQL.Add('             CNPJEMPRESA,         ');
         SQL.Add('             CASE         ');
         SQL.Add('                  WHEN LEN(CNPJFilial) = 1 THEN ''000'' + CAST(CNPJFilial AS VARCHAR)         ');
         SQL.Add('                  WHEN LEN(CNPJFilial) = 2 THEN ''00'' + CAST(CNPJFilial AS VARCHAR)         ');
         SQL.Add('                  WHEN LEN(CNPJFilial) = 3 THEN ''0'' + CAST(CNPJFilial AS VARCHAR)         ');
         SQL.Add('                  ELSE CAST(CNPJFilial AS VARCHAR)         ');
         SQL.Add('             END AS CNPJFilial_1,         ');
         SQL.Add('             CASE         ');
         SQL.Add('                  WHEN LEN(CNPJDV) = 1 THEN ''0'' + CAST(CNPJDV AS VARCHAR)         ');
         SQL.Add('                  ELSE CAST(CNPJDV AS VARCHAR)         ');
         SQL.Add('             END AS CNPJDV_1	         ');
         SQL.Add('        FROM TBPESSOAJURIDICA         ');
         SQL.Add('   ) AS CNPJ_1         ');
         SQL.Add('   ON CNPJ_1.CDPESSOAJURIDICA = PAGAR_QUITADO.CDPESSOACOMERCIAL   ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('   	SELECT   ');
         SQL.Add('   		TBCONTAPARCELA.CDCONTA,   ');
         SQL.Add('   		COUNT(*) AS QTD_PARCELA,   ');
         SQL.Add('   		SUM(TBCONTAPARCELA.VLPARCELA) AS VAL_TOTAL_NF   ');
         SQL.Add('   	FROM   ');
         SQL.Add('   		TBCONTAPARCELA   ');
         SQL.Add('   	--WHERE TBCONTAPARCELA.cdConta = 55   ');
         SQL.Add('   	GROUP BY   ');
         SQL.Add('   		TBCONTAPARCELA.CDCONTA   ');
         SQL.Add('   ) AS PARCELAS   ');
         SQL.Add('   ON PAGAR_QUITADO.CDCONTA = PARCELAS.CDCONTA   ');
         SQL.Add('   WHERE PARCELA.CDCONTABAIXA IS NOT NULL   ');
         SQL.Add('   AND PAGAR_QUITADO.CDCONTATIPO IN (2,4)   ');
         SQL.Add('   AND  ');
         SQL.Add('   CAST(BAIXA.DTCONTABAIXA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
         SQL.Add('   AND');
         SQL.Add('   CAST(BAIXA.DTCONTABAIXA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

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

procedure TFrmSmMultimarketing.GerarFinanceiroReceberCartao;
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

procedure TFrmSmMultimarketing.GerarFornecedor;
var
   observacao, email, inscEst : string;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('                   SELECT DISTINCT         ');
     SQL.Add('                        FORNECEDORES.CDPESSOA AS COD_FORNECEDOR,         ');
     SQL.Add('                        P_JURIDICA.RAZAOSOCIAL AS DES_FORNECEDOR,         ');
     SQL.Add('                        FORNECEDORES.NMPESSOA AS DES_FANTASIA,         ');
     SQL.Add('                        CNPJ_1.CNPJEMPRESA + CNPJ_1.CNPJFILIAL_1 + CNPJ_1.CNPJDV_1  AS NUM_CGC,         ');
     SQL.Add('                        COALESCE(P_JURIDICA.INSCRICAOESTADUAL, ''ISENTO'') AS NUM_INSC_EST,         ');
     SQL.Add('                           ');
     SQL.Add('                        CASE   ');
     SQL.Add('   						WHEN ENDERECO.COMPLEMENTO IS NULL THEN ENDERECO.LOGRADOURO   ');
     SQL.Add('   						ELSE ENDERECO.LOGRADOURO + ENDERECO.COMPLEMENTO   ');
     SQL.Add('                        END AS DES_ENDERECO,         ');
     SQL.Add('                           ');
     SQL.Add('                        COALESCE(ENDERECO.BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,         ');
     SQL.Add('                        COALESCE(ENDERECO.CIDADE, '''') AS DES_CIDADE,         ');
     SQL.Add('                        COALESCE(ENDERECO.CDESTADO, ''RJ'') AS DES_SIGLA,         ');
     SQL.Add('                        ENDERECO.CEP AS NUM_CEP,         ');
     SQL.Add('                        COALESCE(TEL.DDD + TEL.NUMERO, '''') AS NUM_FONE,         ');
     SQL.Add('                        '''' AS NUM_FAX,         ');
     SQL.Add('                        '''' AS DES_CONTATO,         ');
     SQL.Add('                        0 AS QTD_DIA_CARENCIA,         ');
     SQL.Add('                        0 AS NUM_FREQ_VISITA,         ');
     SQL.Add('                        0 AS VAL_DESCONTO,         ');
     SQL.Add('                        0 AS NUM_PRAZO,         ');
     SQL.Add('                        ''N'' AS ACEITA_DEVOL_MER,         ');
     SQL.Add('                        ''N'' AS CAL_IPI_VAL_BRUTO,         ');
     SQL.Add('                        ''N'' AS CAL_ICMS_ENC_FIN,         ');
     SQL.Add('                        ''N'' AS CAL_ICMS_VAL_IPI,         ');
     SQL.Add('                        ''N'' AS MICRO_EMPRESA,         ');
     SQL.Add('                        FORNECEDORES.CDPESSOA AS COD_FORNECEDOR_ANT,         ');
     SQL.Add('                        ENDERECO.NUMERO AS NUM_ENDERECO,         ');
     SQL.Add('                        COALESCE(TEL.CONTATO, '''') AS DES_OBSERVACAO,         ');
     SQL.Add('                        COALESCE(EMAIL.NMINTERNET, '''') AS DES_EMAIL,         ');
     SQL.Add('                        '''' AS DES_WEB_SITE,         ');
     SQL.Add('                        ''N'' AS FABRICANTE,         ');
     SQL.Add('                        ''N'' AS FLG_PRODUTOR_RURAL,         ');
     SQL.Add('                        0 AS TIPO_FRETE,         ');
     SQL.Add('                        ''N'' AS FLG_SIMPLES,         ');
     SQL.Add('                        ''N'' AS FLG_SUBSTITUTO_TRIB,         ');
     SQL.Add('                        0 AS COD_CONTACCFORN,         ');
     SQL.Add('                        ''N'' AS INATIVO,         ');
     SQL.Add('                        0 AS COD_CLASSIF,         ');
     SQL.Add('                        COALESCE(FORNECEDORES.DTCADASTRO, '''') AS DTA_CADASTRO,         ');
     SQL.Add('                        0 AS VAL_CREDITO,         ');
     SQL.Add('                        0 AS VAL_DEBITO,         ');
     SQL.Add('                        1 AS PED_MIN_VAL,         ');
     SQL.Add('                        '''' AS DES_EMAIL_VEND,         ');
     SQL.Add('                        '''' AS SENHA_COTACAO,         ');
     SQL.Add('                        -1 AS TIPO_PRODUTOR,         ');
     SQL.Add('                        '''' AS NUM_CELULAR         ');
     SQL.Add('                   FROM          ');
     SQL.Add('                        TBPESSOA AS FORNECEDORES         ');
     SQL.Add('                   LEFT JOIN TBPESSOAJURIDICA AS P_JURIDICA ON P_JURIDICA.CDPESSOAJURIDICA = FORNECEDORES.CDPESSOA         ');
     SQL.Add('                   LEFT JOIN TBENDERECO AS ENDERECO ON ENDERECO.CDPESSOA = FORNECEDORES.CDPESSOA         ');
     SQL.Add('                   LEFT JOIN TBTELEFONE AS TEL ON TEL.CDPESSOA = FORNECEDORES.CDPESSOA         ');
     SQL.Add('                   LEFT JOIN TBINTERNET AS EMAIL ON EMAIL.CDPESSOA = FORNECEDORES.CDPESSOA      ');
     SQL.Add('                   LEFT JOIN (      ');
     SQL.Add('           			    SELECT DISTINCT      ');
     SQL.Add('           				      CDPESSOAJURIDICA,      ');
     SQL.Add('           				      CNPJEMPRESA,      ');
     SQL.Add('           				      CASE      ');
     SQL.Add('           					        WHEN LEN(CNPJFilial) = 1 THEN ''000'' + CAST(CNPJFilial AS VARCHAR)      ');
     SQL.Add('           					        WHEN LEN(CNPJFilial) = 2 THEN ''00'' + CAST(CNPJFilial AS VARCHAR)      ');
     SQL.Add('           					        WHEN LEN(CNPJFilial) = 3 THEN ''0'' + CAST(CNPJFilial AS VARCHAR)      ');
     SQL.Add('           					        ELSE CAST(CNPJFilial AS VARCHAR)      ');
     SQL.Add('           				      END AS CNPJFilial_1,      ');
     SQL.Add('           				      CASE      ');
     SQL.Add('           					        WHEN LEN(CNPJDV) = 1 THEN ''0'' + CAST(CNPJDV AS VARCHAR)      ');
     SQL.Add('           					        ELSE CAST(CNPJDV AS VARCHAR)      ');
     SQL.Add('           				      END AS CNPJDV_1	      ');
     SQL.Add('           			    FROM TBPESSOAJURIDICA      ');
     SQL.Add('                   ) AS CNPJ_1      ');
     SQL.Add('                   ON CNPJ_1.CDPESSOAJURIDICA = FORNECEDORES.CDPESSOA      ');
     SQL.Add('                   WHERE   ');
     SQL.Add('                   FORNECEDORES.INPESSOAJURIDICA = 1       ');



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

procedure TFrmSmMultimarketing.GerarGrupo;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('        CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 2, 2), ''999'') AS INT) AS COD_SECAO,   ');
     SQL.Add('        CAST(COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 4, 3), ''999'') AS INT) AS COD_GRUPO,   ');
     SQL.Add('        TBCLASSIFICACAOPRODUTO.NMCLASSIFICACAOPRODUTO AS DES_GRUPO,   ');
     SQL.Add('        0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('   	TBCLASSIFICACAOPRODUTO   ');
     SQL.Add('   WHERE COALESCE(SUBSTRING(TBCLASSIFICACAOPRODUTO.CDORDEM, 4, 3), ''999'') <> ''''   ');
     SQL.Add('   AND TBCLASSIFICACAOPRODUTO.NMCLASSIFICACAOPRODUTO IN (   ');
     SQL.Add('   ''01-CEREAIS'',   ');
     SQL.Add('   ''02-GORDUROSOS'',   ');
     SQL.Add('   ''03-CONSERVAS'',   ');
     SQL.Add('   ''04-MASSAS'',   ');
     SQL.Add('   ''05-CESTAS'',   ');
     SQL.Add('   ''01-BISCOITOS'',   ');
     SQL.Add('   ''02-PANIFICACAO'',   ');
     SQL.Add('   ''03-MATINAIS'',   ');
     SQL.Add('   ''04-DOCES E COMPOTAS'',   ');
     SQL.Add('   ''05-BOMBONIERE'',   ');
     SQL.Add('   ''06-VIDA SAUDAVEL'',   ');
     SQL.Add('   ''01-NAO ALCOOLICAS'',   ');
     SQL.Add('   ''02-ALCOOLICAS'',   ');
     SQL.Add('   ''03-VINHOS'',   ');
     SQL.Add('   ''01-HIGIENE PESSOAL'',   ');
     SQL.Add('   ''02-SAUDE'',   ');
     SQL.Add('   ''03-PERFUMARIA'',   ');
     SQL.Add('   ''04-LIMPEZA'',   ');
     SQL.Add('   ''05-UTILIDADES'',   ');
     SQL.Add('   ''06-PET SHOP'',   ');
     SQL.Add('   ''07-ORNAMENTACAO'',   ');
     SQL.Add('   ''08-TABACARIA'',   ');
     SQL.Add('   ''01-BOVINO'',   ');
     SQL.Add('   ''02-AVES'',   ');
     SQL.Add('   ''03-SUINO'',   ');
     SQL.Add('   ''04-EXOTICOS'',   ');
     SQL.Add('   ''05-EMBUTIDO'',   ');
     SQL.Add('   ''06-SALGADO'',   ');
     SQL.Add('   ''01-PEIXARIA'',   ');
     SQL.Add('   ''02-CONGELADO'',   ');
     SQL.Add('   ''03-GELADOS'',   ');
     SQL.Add('   ''04-SUPER CONGELADOS'',   ');
     SQL.Add('   ''01-BALCAO'',   ');
     SQL.Add('   ''02-REFRIGERADOS'',   ');
     SQL.Add('   ''03-LEITE'',   ');
     SQL.Add('   ''01-FRUTAS'',   ');
     SQL.Add('   ''02-LEGUMES'',   ');
     SQL.Add('   ''03-VERDURAS'',   ');
     SQL.Add('   ''04-TEMPEROS'',   ');
     SQL.Add('   ''05-FUNGOS'',   ');
     SQL.Add('   ''06-OVOS'',   ');
     SQL.Add('   ''01-PADARIA'',   ');
     SQL.Add('   ''02-CONFEITARIA'',   ');
     SQL.Add('   ''03-LANCHERIA'',   ');
     SQL.Add('   ''01-FOOD'',   ');
     SQL.Add('   ''02-DOCERIA'',   ');
     SQL.Add('   ''01-LOGISTICA'',   ');
     SQL.Add('   ''02-RECICLAVEIS'',   ');
     SQL.Add('   ''03-VENDAS'',   ');
     SQL.Add('   ''04-PET SHOP'',   ');
     SQL.Add('   ''01-LOJA'',   ');
     SQL.Add('   ''02-VEICULOS'',   ');
     SQL.Add('   ''01-LOJA'',   ');
     SQL.Add('   ''02-CD'',   ');
     SQL.Add('   ''01-MATERIA PRIMA'',   ');
     SQL.Add('   ''02-EMBALAGENS'',   ');
     SQL.Add('   ''01-OPERACIONAL'',   ');
     SQL.Add('   ''02-COMERCIAL'',   ');
     SQL.Add('   ''03-GESTAO'',   ');
     SQL.Add('   ''04-FINANCEIRO'',   ');
     SQL.Add('   ''01-EM TRANSITO'',   ');
     SQL.Add('   ''01-IMOBILIZADO'',   ');
     SQL.Add('   ''01-FORA DE LINHA''   ');
     SQL.Add('   )   ');


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

procedure TFrmSmMultimarketing.GerarInfoNutricionais;
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

procedure TFrmSmMultimarketing.GerarNCM;
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
     SQL.Add('       ''A DEFINIR'' AS DES_NCM,   ');
     SQL.Add('       COALESCE(NCM.NCM, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 4 THEN ''S''   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 6 THEN ''S''   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 9 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 4 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 6 THEN 0   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 9 THEN 4   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(S_PRODUTO.CDNATRECPIS, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       COALESCE(NCM.CEST, ''9999999'') AS NUM_CEST,   ');
     SQL.Add('       ''RJ'' AS DES_SIGLA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 1 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''18.00'' THEN 13   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''27.00'' THEN 56   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST IS NULL THEN 25   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''14.00'' THEN 54   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''20.00'' THEN 29   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''19.00'' THEN 55   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 3 THEN 20   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 4 THEN 6   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 5 THEN 8   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 6 THEN 51   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 7 THEN 2   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 9 THEN 52   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 10 THEN 4   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 11 THEN 39   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 12 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 13 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 14 THEN 51   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 1 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''18.00'' THEN 13   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''27.00'' THEN 56   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST IS NULL THEN 25   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''14.00'' THEN 54   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''20.00'' THEN 29   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''19.00'' THEN 55   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 3 THEN 20   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 4 THEN 6   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 5 THEN 8   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 6 THEN 51   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 7 THEN 2   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 9 THEN 52   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 10 THEN 4   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 11 THEN 39   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 12 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 13 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 14 THEN 51   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPRODUTO AS NCM   ');
     SQL.Add('   LEFT JOIN TBSUPERPRODUTO AS S_PRODUTO ON S_PRODUTO.CDSUPERPRODUTO = NCM.CDSUPERPRODUTO   ');




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

procedure TFrmSmMultimarketing.GerarNCMUF;
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
     SQL.Add('       ''A DEFINIR'' AS DES_NCM,   ');
     SQL.Add('       COALESCE(NCM.NCM, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 4 THEN ''S''   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 6 THEN ''S''   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 9 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 4 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 6 THEN 0   ');
     SQL.Add('           WHEN S_PRODUTO.CSTPIS = 9 THEN 4   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(S_PRODUTO.CDNATRECPIS, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       COALESCE(NCM.CEST, ''9999999'') AS NUM_CEST,   ');
     SQL.Add('       ''RJ'' AS DES_SIGLA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 1 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''18.00'' THEN 13   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''27.00'' THEN 56   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST IS NULL THEN 25   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''14.00'' THEN 54   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''20.00'' THEN 29   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''19.00'' THEN 55   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 3 THEN 20   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 4 THEN 6   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 5 THEN 8   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 6 THEN 51   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 7 THEN 2   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 9 THEN 52   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 10 THEN 4   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 11 THEN 39   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 12 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 13 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 14 THEN 51   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 1 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''18.00'' THEN 13   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''27.00'' THEN 56   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST IS NULL THEN 25   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''14.00'' THEN 54   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''20.00'' THEN 29   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''19.00'' THEN 55   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 3 THEN 20   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 4 THEN 6   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 5 THEN 8   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 6 THEN 51   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 7 THEN 2   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 9 THEN 52   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 10 THEN 4   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 11 THEN 39   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 12 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 13 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 14 THEN 51   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPRODUTO AS NCM   ');
     SQL.Add('   LEFT JOIN TBSUPERPRODUTO AS S_PRODUTO ON S_PRODUTO.CDSUPERPRODUTO = NCM.CDSUPERPRODUTO   ');

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

procedure TFrmSmMultimarketing.GerarNFClientes;
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

procedure TFrmSmMultimarketing.GerarNFFornec;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('        CAPA.CDPESSOACOMERCIAL AS COD_FORNECEDOR,   ');
     SQL.Add('        CAPA.NUMERO AS NUM_NF_FORN,   ');
     SQL.Add('        COALESCE(CAPA.SERIE, 1) AS NUM_SERIE_NF,   ');
     SQL.Add('        '''' AS NUM_SUBSERIE_NF,   ');
     SQL.Add('        CAPA.COF AS CFOP,   ');
     SQL.Add('        0 AS TIPO_NF,   ');
     SQL.Add('        ''NFE'' AS DES_ESPECIE,   ');
     SQL.Add('        CAPA.VLTOTAL AS VAL_TOTAL_NF,   ');
     SQL.Add('        CAPA.DTEMISSAO AS DTA_EMISSAO,   ');
     SQL.Add('        CAPA.DTMOVIMENTO AS DTA_ENTRADA,   ');
     SQL.Add('        VAL.VAL_TOTAL_IPI AS VAL_TOTAL_IPI,   ');
     SQL.Add('        0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('        VAL.VAL_FRETE AS VAL_FRETE,   ');
     SQL.Add('        0 AS VAL_ACRESCIMO,   ');
     SQL.Add('        VAL.VAL_DESCONTO AS VAL_DESCONTO,   ');
     SQL.Add('        CNPJ_1.CNPJEMPRESA + CNPJ_1.CNPJFILIAL_1 + CNPJ_1.CNPJDV_1 AS NUM_CGC,   ');
     SQL.Add('        VAL.VAL_TOTAL_BC AS VAL_TOTAL_BC,   ');
     SQL.Add('        VAL.VAL_TOTAL_ICMS AS VAL_TOTAL_ICMS,   ');
     SQL.Add('        VAL.VAL_BC_SUBST AS VAL_BC_SUBST,   ');
     SQL.Add('        VAL.VAL_ICMS_SUBST AS VAL_ICMS_SUBST,   ');
     SQL.Add('        0 AS VAL_FUNRURAL,   ');
     SQL.Add('        1 AS COD_PERFIL,   ');
     SQL.Add('        0 AS VAL_DESP_ACESS,   ');
     SQL.Add('        ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('        '''' AS DES_OBSERVACAO,   ');
     SQL.Add('        CAPA.NFECHAVE AS NUM_CHAVE_ACESSO    ');
     SQL.Add('   FROM   ');
     SQL.Add('   	    TBNOTA AS CAPA   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('   	    SELECT DISTINCT   ');
     SQL.Add('   		      CDNOTA,   ');
     SQL.Add('   		      COALESCE(SUM(TBNOTAITEM.IPIVIPI), 0) AS VAL_TOTAL_IPI,   ');
     SQL.Add('   		      COALESCE(SUM(TBNOTAITEM.VFRETE), 0) AS VAL_FRETE,   ');
     SQL.Add('   		      COALESCE(SUM(TBNOTAITEM.VDESC), 0) AS VAL_DESCONTO,   ');
     SQL.Add('   		      COALESCE(SUM(TBNOTAITEM.ICMSVBC), 0) AS VAL_TOTAL_BC,   ');
     SQL.Add('   		      COALESCE(SUM(TBNOTAITEM.ICMSVICMS), 0) AS VAL_TOTAL_ICMS,   ');
     SQL.Add('   		      COALESCE(SUM(TBNOTAITEM.ICMSVBCST), 0) AS VAL_BC_SUBST,   ');
     SQL.Add('   		      COALESCE(SUM(TBNOTAITEM.ICMSVICMSST), 0) AS VAL_ICMS_SUBST   ');
     SQL.Add('   	    FROM   ');
     SQL.Add('   		      TBNOTAITEM   ');
     SQL.Add('   	    GROUP BY   ');
     SQL.Add('   		      TBNOTAITEM.CDNOTA   ');
     SQL.Add('   ) AS VAL   ');
     SQL.Add('   ON CAPA.CDNOTA = VAL.CDNOTA   ');
     SQL.Add('   LEFT JOIN (         ');
     SQL.Add('        SELECT DISTINCT         ');
     SQL.Add('             CDPESSOAJURIDICA,         ');
     SQL.Add('             CNPJEMPRESA,         ');
     SQL.Add('             CASE         ');
     SQL.Add('                  WHEN LEN(CNPJFilial) = 1 THEN ''000'' + CAST(CNPJFilial AS VARCHAR)         ');
     SQL.Add('                  WHEN LEN(CNPJFilial) = 2 THEN ''00'' + CAST(CNPJFilial AS VARCHAR)         ');
     SQL.Add('                  WHEN LEN(CNPJFilial) = 3 THEN ''0'' + CAST(CNPJFilial AS VARCHAR)         ');
     SQL.Add('                  ELSE CAST(CNPJFilial AS VARCHAR)         ');
     SQL.Add('             END AS CNPJFilial_1,         ');
     SQL.Add('             CASE         ');
     SQL.Add('                  WHEN LEN(CNPJDV) = 1 THEN ''0'' + CAST(CNPJDV AS VARCHAR)         ');
     SQL.Add('                  ELSE CAST(CNPJDV AS VARCHAR)         ');
     SQL.Add('             END AS CNPJDV_1	         ');
     SQL.Add('        FROM TBPESSOAJURIDICA         ');
     SQL.Add('   ) AS CNPJ_1         ');
     SQL.Add('   ON CNPJ_1.CDPESSOAJURIDICA = CAPA.CDPESSOACOMERCIAL   ');
     SQL.Add('   LEFT JOIN TBPESSOACOMERCIAL AS P_COMERCIAL ON P_COMERCIAL.CDPESSOACOMERCIAL = CAPA.CDPESSOACOMERCIAL   ');
     SQL.Add('   WHERE');
     SQL.Add('      CAST(CAPA.DTMOVIMENTO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('   AND');
     SQL.Add('      CAST(CAPA.DTMOVIMENTO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add('   AND P_COMERCIAL.CDPESSOACOMERCIAL IN (   ');
     SQL.Add('   	SELECT   ');
     SQL.Add('   		CDPESSOAJURIDICA AS CDPESSOACOMERCIAL   ');
     SQL.Add('   	FROM   ');
     SQL.Add('   		TBPESSOAJURIDICA   ');
     SQL.Add('   )    ');
     SQL.Add('   AND CAPA.COF NOT LIKE ''5%''  ');
     SQL.Add('   AND CAPA.COF NOT LIKE ''6%''  ');
     SQL.Add('   ORDER BY CAPA.NUMERO, CAPA.CDPESSOACOMERCIAL, COALESCE(CAPA.SERIE, 1) ');

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

procedure TFrmSmMultimarketing.GerarNFitensClientes;
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

procedure TFrmSmMultimarketing.GerarNFitensFornec;
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
       SQL.Add('        CAPA.COD_FORNECEDOR AS COD_FORNECEDOR,   ');
       SQL.Add('        CAPA.NUM_NF_FORN AS NUM_NF_FORN,   ');
       SQL.Add('        COALESCE(CAPA.NUM_SERIE_NF, 1) AS NUM_SERIE_NF,   ');
       SQL.Add('        ITEM.CDPRODUTO AS COD_PRODUTO,   ');
       SQL.Add('           ');
       SQL.Add('        CASE    ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 1 THEN 1   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''18.00'' THEN 13   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''27.00'' THEN 56   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST IS NULL THEN 25   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''14.00'' THEN 54   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''20.00'' THEN 29   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''19.00'' THEN 55   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 3 THEN 20   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 4 THEN 6   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 5 THEN 8   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 6 THEN 51   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 7 THEN 2   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 9 THEN 52   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 10 THEN 4   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 11 THEN 39   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 12 THEN 53   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 13 THEN 53   ');
       SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 14 THEN 51   ');
       SQL.Add('           ELSE 1   ');
       SQL.Add('        END AS COD_TRIBUTACAO,   ');
       SQL.Add('      ');
       SQL.Add('        ITEM.QTEMBALAGEM AS QTD_EMBALAGEM,   ');
       SQL.Add('        ITEM.QTITEMNOTA AS QTD_ENTRADA,   ');
       SQL.Add('        COALESCE(ITEM.CDEMBALAGEM, ''UN'') AS DES_UNIDADE,   ');
       SQL.Add('        ITEM.VLITEMNOTA AS VAL_TABELA,   ');
       SQL.Add('        COALESCE(ITEM.VDESC, 0) AS VAL_DESCONTO_ITEM,   ');
       SQL.Add('        0 AS VAL_ACRESCIMO_ITEM,   ');
       SQL.Add('        COALESCE(ITEM.IPIVIPI, 0) AS VAL_IPI_ITEM,   ');
       SQL.Add('        COALESCE(ITEM.ICMSVICMSST, 0) AS VAL_SUBST_ITEM,   ');
       SQL.Add('        COALESCE(ITEM.VFRETE, 0) AS VAL_FRETE_ITEM,   ');
       SQL.Add('        COALESCE(ITEM.ICMSVICMS, 0) AS VAL_CREDITO_ICMS,   ');
       SQL.Add('        0 AS VAL_VENDA_VAREJO,   ');
       SQL.Add('        ITEM.CUSTOUNITARIO AS VAL_TABELA_LIQ,   ');
       SQL.Add('        CNPJ_1.CNPJEMPRESA + CNPJ_1.CNPJFILIAL_1 + CNPJ_1.CNPJDV_1 AS NUM_CGC,   ');
       SQL.Add('        COALESCE(ITEM.ICMSVBC, 0) AS VAL_TOT_BC_ICMS,   ');
       SQL.Add('        0 AS VAL_TOT_OUTROS_ICMS,   ');
       SQL.Add('        ITEM.CFOP AS CFOP,   ');
       SQL.Add('        0 AS VAL_TOT_ISENTO,   ');
       SQL.Add('        COALESCE(ITEM.ICMSVBCST, 0) AS VAL_TOT_BC_ST,   ');
       SQL.Add('        COALESCE(ITEM.ICMSVICMSST, 0) AS VAL_TOT_ST,   ');
       SQL.Add('        ITEM.CDNOTAITEM AS NUM_ITEM,   ');
       SQL.Add('        0 AS TIPO_IPI,   ');
       SQL.Add('        ITEM.NCM AS NUM_NCM,   ');
       SQL.Add('        '''' AS DES_REFERENCIA   ');
       SQL.Add('   FROM   ');
       SQL.Add('        TBNOTAITEM AS ITEM   ');
       SQL.Add('   LEFT JOIN (   ');
       SQL.Add('        SELECT DISTINCT   ');
       SQL.Add('             TBNOTA.CDPESSOAFILIAL,   ');
       SQL.Add('             TBNOTA.CDNOTA,   ');
       SQL.Add('             TBNOTA.CDPESSOACOMERCIAL AS COD_FORNECEDOR,   ');
       SQL.Add('             TBNOTA.NUMERO AS NUM_NF_FORN,   ');
       SQL.Add('             TBNOTA.SERIE AS NUM_SERIE_NF,   ');
       SQL.Add('             TBNOTA.CDPESSOACOMERCIAL,   ');
       SQL.Add('             TBNOTA.DTEMISSAO AS DTA_EMISSAO,   ');
       SQL.Add('             COF   ');
       SQL.Add('        FROM   ');
       SQL.Add('             TBNOTA   ');
       SQL.Add('        GROUP BY   ');
       SQL.Add('             TBNOTA.CDPESSOAFILIAL,   ');
       SQL.Add('             TBNOTA.CDNOTA,   ');
       SQL.Add('             TBNOTA.CDPESSOACOMERCIAL,   ');
       SQL.Add('             TBNOTA.NUMERO,   ');
       SQL.Add('             TBNOTA.SERIE,   ');
       SQL.Add('             TBNOTA.CDPESSOACOMERCIAL,   ');
       SQL.Add('             TBNOTA.DTEMISSAO,   ');
       SQL.Add('             COF   ');
       SQL.Add('   ) AS CAPA   ');
       SQL.Add('   ON ITEM.CDPESSOAFILIAL = CAPA.CDPESSOAFILIAL AND ITEM.CDNOTA = CAPA.CDNOTA   ');
       SQL.Add('   LEFT JOIN TBPRODUTO AS PRODUTO ON PRODUTO.CDPRODUTO = ITEM.CDPRODUTO   ');
       SQL.Add('   LEFT JOIN TBSUPERPRODUTO AS S_PRODUTO ON S_PRODUTO.CDSUPERPRODUTO = PRODUTO.CDSUPERPRODUTO   ');
       SQL.Add('   LEFT JOIN (         ');
       SQL.Add('        SELECT DISTINCT         ');
       SQL.Add('             CDPESSOAJURIDICA,         ');
       SQL.Add('             CNPJEMPRESA,         ');
       SQL.Add('             CASE         ');
       SQL.Add('                  WHEN LEN(CNPJFILIAL) = 1 THEN ''000'' + CAST(CNPJFILIAL AS VARCHAR)         ');
       SQL.Add('                  WHEN LEN(CNPJFILIAL) = 2 THEN ''00'' + CAST(CNPJFILIAL AS VARCHAR)         ');
       SQL.Add('                  WHEN LEN(CNPJFILIAL) = 3 THEN ''0'' + CAST(CNPJFILIAL AS VARCHAR)         ');
       SQL.Add('                  ELSE CAST(CNPJFILIAL AS VARCHAR)         ');
       SQL.Add('             END AS CNPJFILIAL_1,         ');
       SQL.Add('             CASE         ');
       SQL.Add('                  WHEN LEN(CNPJDV) = 1 THEN ''0'' + CAST(CNPJDV AS VARCHAR)         ');
       SQL.Add('                  ELSE CAST(CNPJDV AS VARCHAR)         ');
       SQL.Add('             END AS CNPJDV_1	         ');
       SQL.Add('        FROM TBPESSOAJURIDICA         ');
       SQL.Add('   ) AS CNPJ_1         ');
       SQL.Add('   ON CNPJ_1.CDPESSOAJURIDICA = CAPA.COD_FORNECEDOR   ');
       SQL.Add('   LEFT JOIN TBPESSOACOMERCIAL AS P_COMERCIAL ON P_COMERCIAL.CDPESSOACOMERCIAL = CAPA.CDPESSOACOMERCIAL   ');
       SQL.Add('   WHERE');
       SQL.Add('      CAST(CAPA.DTA_EMISSAO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
       SQL.Add('   AND');
       SQL.Add('      CAST(CAPA.DTA_EMISSAO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
       SQL.Add('   AND P_COMERCIAL.CDPESSOACOMERCIAL IN (   ');
       SQL.Add('   	SELECT   ');
       SQL.Add('   		CDPESSOAJURIDICA AS CDPESSOACOMERCIAL   ');
       SQL.Add('   	FROM   ');
       SQL.Add('   		TBPESSOAJURIDICA   ');
       SQL.Add('   )    ');
       SQL.Add('   AND CAPA.COF NOT LIKE ''5%''  ');
       SQL.Add('   AND CAPA.COF NOT LIKE ''6%''  ');
       SQL.Add('   ORDER BY CAPA.NUM_NF_FORN, CAPA.COD_FORNECEDOR, CAPA.NUM_SERIE_NF   ');



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
////
//      Layout.FieldByName('NUM_ITEM').AsInteger := count;
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

procedure TFrmSmMultimarketing.GerarProdForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PROD_FORN.CDPRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       PROD_FORN.CDPESSOACOMERCIAL AS COD_FORNECEDOR,   ');
     SQL.Add('       PROD_FORN.CDPRODNFE AS DES_REFERENCIA,   ');
     SQL.Add('       CNPJ_1.CNPJEMPRESA + CNPJ_1.CNPJFILIAL_1 + CNPJ_1.CNPJDV_1 AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE PROD_FORN.UCOMNFE   ');
     SQL.Add('           WHEN ''AM'' THEN ''UN''   ');
     SQL.Add('           WHEN ''BAL'' THEN ''BD''   ');
     SQL.Add('           WHEN ''BALDE'' THEN ''BD''   ');
     SQL.Add('           WHEN ''BANDEJ'' THEN ''BD''   ');
     SQL.Add('           WHEN ''BB'' THEN ''UN''   ');
     SQL.Add('           WHEN ''BD'' THEN ''BD''   ');
     SQL.Add('           WHEN ''BJ'' THEN ''BJ''   ');
     SQL.Add('           WHEN ''BL'' THEN ''UN''   ');
     SQL.Add('           WHEN ''BLD1'' THEN ''BD''   ');
     SQL.Add('           WHEN ''BOMB'' THEN ''UN''   ');
     SQL.Add('           WHEN ''BR'' THEN ''UN''   ');
     SQL.Add('           WHEN ''CD'' THEN ''UN''   ');
     SQL.Add('           WHEN ''CENTO'' THEN ''CT''   ');
     SQL.Add('           WHEN ''CJ'' THEN ''CJ''   ');
     SQL.Add('           WHEN ''CJT'' THEN ''CJ''   ');
     SQL.Add('           WHEN ''CP'' THEN ''UN''   ');
     SQL.Add('           WHEN ''CR'' THEN ''UN''   ');
     SQL.Add('           WHEN ''CRT'' THEN ''UN''   ');
     SQL.Add('           WHEN ''CRT2'' THEN ''UN''   ');
     SQL.Add('           WHEN ''CT'' THEN ''CT''   ');
     SQL.Add('           WHEN ''CT1'' THEN ''CT''   ');
     SQL.Add('           WHEN ''CT10'' THEN ''CT''   ');
     SQL.Add('           WHEN ''CT12'' THEN ''CT''   ');
     SQL.Add('           WHEN ''CX'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX.'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX10'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX12'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX15'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX20'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX21'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX24'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX25'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX3'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX30'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX4'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX48'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX50'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX6'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX60'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX8'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX9'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CX96'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CXA'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CXA1'' THEN ''CX''   ');
     SQL.Add('           WHEN ''CXS'' THEN ''CX''   ');
     SQL.Add('           WHEN ''DP'' THEN ''DP''   ');
     SQL.Add('           WHEN ''DP10'' THEN ''DP''   ');
     SQL.Add('           WHEN ''DP12'' THEN ''DP''   ');
     SQL.Add('           WHEN ''DP24'' THEN ''DP''   ');
     SQL.Add('           WHEN ''DP9'' THEN ''DP''   ');
     SQL.Add('           WHEN ''DS'' THEN ''DS''   ');
     SQL.Add('           WHEN ''DY'' THEN ''DY''   ');
     SQL.Add('           WHEN ''DZ'' THEN ''DZ''   ');
     SQL.Add('           WHEN ''DZ12'' THEN ''DZ''   ');
     SQL.Add('           WHEN ''EB'' THEN ''EB''   ');
     SQL.Add('           WHEN ''EE'' THEN ''UN''   ');
     SQL.Add('           WHEN ''EMB'' THEN ''UN''   ');
     SQL.Add('           WHEN ''EMB4'' THEN ''UN''   ');
     SQL.Add('           WHEN ''EMB5'' THEN ''UN''   ');
     SQL.Add('           WHEN ''EN'' THEN ''EN''   ');
     SQL.Add('           WHEN ''ES'' THEN ''UN''   ');
     SQL.Add('           WHEN ''EXB'' THEN ''UN''   ');
     SQL.Add('           WHEN ''FA'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FAR'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FARDO'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD16'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD2'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD3'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD30'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD4'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD6'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD8'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FD9'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FDO1'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FDS'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FR'' THEN ''FD''   ');
     SQL.Add('           WHEN ''FRD'' THEN ''FD''   ');
     SQL.Add('           WHEN ''GF'' THEN ''UN''   ');
     SQL.Add('           WHEN ''GL'' THEN ''UN''   ');
     SQL.Add('           WHEN ''GR'' THEN ''KG''   ');
     SQL.Add('           WHEN ''KG'' THEN ''KG''   ');
     SQL.Add('           WHEN ''KIT'' THEN ''CX''   ');
     SQL.Add('           WHEN ''L'' THEN ''LT''   ');
     SQL.Add('           WHEN ''LAT'' THEN ''LT''   ');
     SQL.Add('           WHEN ''LITRO'' THEN ''LT''   ');
     SQL.Add('           WHEN ''LT'' THEN ''LT''   ');
     SQL.Add('           WHEN ''M'' THEN ''ML''   ');
     SQL.Add('           WHEN ''MI'' THEN ''ML''   ');
     SQL.Add('           WHEN ''MIL'' THEN ''ML''   ');
     SQL.Add('           WHEN ''ML'' THEN ''ML''   ');
     SQL.Add('           WHEN ''PAC'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PAR'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PC'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PC12'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PC20'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PC5'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PCT'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PCT2'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PECA'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PK'' THEN ''PC''   ');
     SQL.Add('           WHEN ''PL'' THEN ''UN''   ');
     SQL.Add('           WHEN ''PLAC18'' THEN ''UN''   ');
     SQL.Add('           WHEN ''POT'' THEN ''PT''   ');
     SQL.Add('           WHEN ''PR'' THEN ''PR''   ');
     SQL.Add('           WHEN ''PT'' THEN ''PR''   ');
     SQL.Add('           WHEN ''RL'' THEN ''RL''   ');
     SQL.Add('           WHEN ''SAC'' THEN ''SC''   ');
     SQL.Add('           WHEN ''SACO'' THEN ''SC''   ');
     SQL.Add('           WHEN ''SC'' THEN ''SC''   ');
     SQL.Add('           WHEN ''SH'' THEN ''UN''   ');
     SQL.Add('           WHEN ''TB'' THEN ''UN''   ');
     SQL.Add('           WHEN ''UN'' THEN ''UN''   ');
     SQL.Add('           WHEN ''UN1'' THEN ''UN''   ');
     SQL.Add('           WHEN ''UND'' THEN ''UN''   ');
     SQL.Add('           WHEN ''UND9'' THEN ''UN''   ');
     SQL.Add('           WHEN ''UNI'' THEN ''UN''   ');
     SQL.Add('           WHEN ''UNID'' THEN ''UN''   ');
     SQL.Add('           WHEN ''VARAS'' THEN ''UN''   ');
     SQL.Add('           WHEN ''VD'' THEN ''UN''       ');
     SQL.Add('           ELSE ''UN''  ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(PROD_FORN.QTEMBALAGEM, 0) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       1 AS QTD_TROCA,   ');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPRODUTOPESSOACOMERCIALNFE AS PROD_FORN   ');
     SQL.Add('   LEFT JOIN TBPESSOA AS FORNECEDOR ON FORNECEDOR.CDPESSOA = PROD_FORN.CDPESSOACOMERCIAL   ');
     SQL.Add('   LEFT JOIN (         ');
     SQL.Add('       SELECT DISTINCT         ');
     SQL.Add('           CDPESSOAJURIDICA,         ');
     SQL.Add('           CNPJEMPRESA,         ');
     SQL.Add('           CASE         ');
     SQL.Add('               WHEN LEN(CNPJFilial) = 1 THEN ''000'' + CAST(CNPJFilial AS VARCHAR)         ');
     SQL.Add('               WHEN LEN(CNPJFilial) = 2 THEN ''00'' + CAST(CNPJFilial AS VARCHAR)         ');
     SQL.Add('               WHEN LEN(CNPJFilial) = 3 THEN ''0'' + CAST(CNPJFilial AS VARCHAR)         ');
     SQL.Add('               ELSE CAST(CNPJFilial AS VARCHAR)         ');
     SQL.Add('           END AS CNPJFilial_1,         ');
     SQL.Add('           CASE         ');
     SQL.Add('               WHEN LEN(CNPJDV) = 1 THEN ''0'' + CAST(CNPJDV AS VARCHAR)         ');
     SQL.Add('               ELSE CAST(CNPJDV AS VARCHAR)         ');
     SQL.Add('           END AS CNPJDV_1	         ');
     SQL.Add('       FROM TBPESSOAJURIDICA         ');
     SQL.Add('   ) AS CNPJ_1         ');
     SQL.Add('   ON CNPJ_1.CDPESSOAJURIDICA = PROD_FORN.CDPESSOACOMERCIAL   ');




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

procedure TFrmSmMultimarketing.GerarProdLoja;
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

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO.CDPRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       COALESCE(CUSTO.VLULTIMACOMPRA, 0) AS VAL_CUSTO_REP,   ');
     SQL.Add('       COALESCE(P_VENDA.VLVENDA, 0) AS VAL_VENDA,   ');
     SQL.Add('       0 AS VAL_OFERTA,   ');
     SQL.Add('       COALESCE(ESTOQUE.QTESTOQUEFISICO, 0) AS QTD_EST_VDA,   ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 1 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''18.00'' THEN 13   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''27.00'' THEN 56   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST IS NULL THEN 25   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''14.00'' THEN 54   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''20.00'' THEN 29   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''19.00'' THEN 55   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 3 THEN 20   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 4 THEN 6   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 5 THEN 8   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 6 THEN 51   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 7 THEN 2   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 9 THEN 52   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 10 THEN 4   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 11 THEN 39   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 12 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 13 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 14 THEN 51   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(P_VENDA.PRMARGEM, 0) AS VAL_MARGEM,   ');
     SQL.Add('       1 AS QTD_ETIQUETA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 1 THEN 1   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''18.00'' THEN 13   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''27.00'' THEN 56   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST IS NULL THEN 25   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''14.00'' THEN 54   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''20.00'' THEN 29   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 2 AND S_PRODUTO.PRICMSST = ''19.00'' THEN 55   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 3 THEN 20   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 4 THEN 6   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 5 THEN 8   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 6 THEN 51   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 7 THEN 2   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 9 THEN 52   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 10 THEN 4   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 11 THEN 39   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 12 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 13 THEN 53   ');
     SQL.Add('           WHEN S_PRODUTO.CDTRIBUTACAO = 14 THEN 51   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       ''N'' AS FLG_INATIVO,   ');
     SQL.Add('       PRODUTO.CDPRODUTO AS COD_PRODUTO_ANT,   ');
     SQL.Add('       COALESCE(PRODUTO.NCM, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('       0 AS TIPO_NCM,   ');
     SQL.Add('       0 AS VAL_VENDA_2,   ');
     SQL.Add('       '''' AS DTA_VALIDA_OFERTA,   ');
     SQL.Add('       1 AS QTD_EST_MINIMO,   ');
     SQL.Add('       NULL AS COD_VASILHAME,   ');
     SQL.Add('       ''N'' AS FORA_LINHA,   ');
     SQL.Add('       0 AS QTD_PRECO_DIF,   ');
     SQL.Add('       0 AS VAL_FORCA_VDA,   ');
     SQL.Add('       COALESCE(PRODUTO.CEST, ''9999999'') AS NUM_CEST,   ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST,   ');
     SQL.Add('       0 AS PER_FIDELIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TBPRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN TBSUPERPRODUTOVENDA AS P_VENDA ON P_VENDA.CDSUPERPRODUTO = PRODUTO.CDSUPERPRODUTO   ');
//     SQL.Add('   LEFT JOIN TBPROMOCAOITEM AS PROMO_ITEM ON PROMO_ITEM.CDSUPERPRODUTO = PRODUTO.CDSUPERPRODUTO   ');
//     SQL.Add('   LEFT JOIN TBPROMOCAO AS PROMO ON PROMO.CDPROMOCAO = PROMO_ITEM.CDPROMOCAO   ');
     SQL.Add('   LEFT JOIN TBESTOQUEFISICO AS ESTOQUE ON ESTOQUE.CDPRODUTO = PRODUTO.CDPRODUTO   ');
     SQL.Add('   LEFT JOIN TBSUPERPRODUTO AS S_PRODUTO ON S_PRODUTO.CDSUPERPRODUTO = PRODUTO.CDSUPERPRODUTO   ');
     SQL.Add('   LEFT JOIN TBESTOQUECONTABIL AS CUSTO ON CUSTO.CDSUPERPRODUTO = PRODUTO.CDSUPERPRODUTO  ');


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

//       Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//       Layout.FieldByName('COD_PRODUTO_ANT').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO_ANT').AsString);

      //if( Layout.FieldByName('DTA_VALIDA_OFERTA').AsString <> '' ) then
//         Layout.FieldByName('DTA_VALIDA_OFERTA').AsDateTime := FieldByName('DTA_VALIDA_OFERTA').AsDateTime;

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

procedure TFrmSmMultimarketing.GerarProdSimilar;
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
