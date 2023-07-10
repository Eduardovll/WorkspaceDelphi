unit UFrmSmAnaMara;

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
  TFrmSmAnaMara = class(TFrmModeloSis)
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
  FrmSmAnaMara: TFrmSmAnaMara;
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


procedure TFrmSmAnaMara.GerarProducao;
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

procedure TFrmSmAnaMara.GerarProduto;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTOS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.PRO_BARRA = 0 THEN PRODUTOS.PRO_CODIGO ELSE PRODUTOS.PRO_BARRA END AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       COALESCE(RTRIM(PRODUTOS.PRO_DESCRICAO2), ''A DEFINIR'') AS DES_REDUZIDA,   ');
     SQL.Add('       COALESCE(RTRIM(PRODUTOS.PRO_DESCRICAO), ''A DEFINIR'') AS DES_PRODUTO,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       CASE WHEN PRODUTOS.PRO_UNIDADE = ''KG'' THEN ''KG'' ELSE ''UN'' END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       CASE WHEN PRODUTOS.PRO_UNIDADE = ''KG'' THEN ''KG'' ELSE ''UN'' END AS DES_UNIDADE_VENDA,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       PRODUTOS.PRO_IPI AS VAL_IPI,   ');
     SQL.Add('       CASE WHEN PRODUTOS.DEP_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.DEP_CODIGO, 999) END AS COD_SECAO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.GRU_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.GRU_CODIGO, 999) END AS COD_GRUPO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.SUB_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.SUB_CODIGO, 999) END AS COD_SUB_GRUPO,   ');
     SQL.Add('       0 AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_QTDE_FRAC = ''N'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_QTDE_FRAC IS NULL THEN ''N''   ');
     SQL.Add('           ELSE ''S''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('          ');
     SQL.Add('       PRODUTOS.PRO_VALIDADE AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA IS NULL AND PRODUTOS.PRO_CST_COFINS IS NULL THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = '''' AND PRODUTOS.PRO_CST_COFINS = '''' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''50'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''04'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''05'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''73'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''53'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''03'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''74'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''75'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_BALANCA = ''N'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_BALANCA IS NULL THEN ''N''   ');
     SQL.Add('           ELSE ''S''   ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA IS NULL AND PRODUTOS.PRO_CST_COFINS IS NULL THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''''   AND PRODUTOS.PRO_CST_COFINS = '''' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''50'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''04'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''05'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''73'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1    ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''53'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''03'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''74'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''75'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN -1   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       COALESCE(PRODUTOS.PRO_OBS, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       0 AS COD_INFO_RECEITA,   ');
     SQL.Add('       COALESCE(PRODUTOS.NATR_CODIGO, 999) AS COD_TAB_SPED,   ');
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
     SQL.Add('       COALESCE(PRODUTOS.FOR_CODIGO, 0) AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       COALESCE(PRODUTOS.PRO_ULT_ENTRADA, '''') AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       COALESCE(PRODUTOS.PRO_DESCRICAO, ''A DEFINIR'') AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     //SQL.Add('   WHERE PRODUTOS.PRO_BARRA <> 0 ');

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


procedure TFrmSmAnaMara.GerarSecao;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       CASE WHEN PRODUTOS.DEP_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.DEP_CODIGO, 999) END AS COD_SECAO,   ');
     SQL.Add('       COALESCE(DEPARTAMENTO.DEP_DESCRICAO, ''A DEFINIR'') AS DES_SECAO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN DEPARTAMENTO ON DEPARTAMENTO.DEP_CODIGO = PRODUTOS.DEP_CODIGO   ');



//   SQL.Add('   WHERE TAB_MERCADORIA.COD_LOJA = '+CbxLoja.Text+'   ');

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

procedure TFrmSmAnaMara.GerarSubGrupo;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       CASE WHEN PRODUTOS.DEP_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.DEP_CODIGO, 999) END AS COD_SECAO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.GRU_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.GRU_CODIGO, 999) END AS COD_GRUPO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.SUB_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.SUB_CODIGO, 999) END AS COD_SUB_GRUPO,   ');
     SQL.Add('       COALESCE(SUBGRUPO_PRODUTOS.SUB_DESCRICAO, ''A DEFINIR'') AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 AS VAL_META,   ');
     SQL.Add('       COALESCE(SUBGRUPO_PRODUTOS.SUB_MARGEM, 0) AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN SUBGRUPO_PRODUTOS ON SUBGRUPO_PRODUTOS.SUB_CODIGO = PRODUTOS.SUB_CODIGO   ');


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

procedure TFrmSmAnaMara.GerarValorVenda;
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

procedure TFrmSmAnaMara.GerarVenda;
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

procedure TFrmSmAnaMara.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmAnaMara.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmAnaMara.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmAnaMara.BtnGerarClick(Sender: TObject);
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



procedure TFrmSmAnaMara.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmAnaMara.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmAnaMara.CkbProdLojaClick(Sender: TObject);
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

procedure TFrmSmAnaMara.FormCreate(Sender: TObject);
begin
  inherited;

end;

//procedure Dourado.FormCreate(Sender: TObject);
//begin
//  inherited;
////  Left:=(Screen.Width-Width)  div 2;
////  Top:=(Screen.Height-Height) div 2;
//end;

procedure TFrmSmAnaMara.GeraCustoRep;
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

procedure TFrmSmAnaMara.GeraEstoqueVenda;
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

procedure TFrmSmAnaMara.GerarCest;
var
   count : integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('  SELECT DISTINCT      ');
     SQL.Add('     0 AS COD_CEST,      ');
     SQL.Add('     CASE WHEN PRODUTOS.PRO_CEST = '''' THEN ''9999999'' ELSE COALESCE(PRODUTOS.PRO_CEST, ''9999999'') END AS NUM_CEST,      ');
     SQL.Add('     UPPER(COALESCE(TB_CEST.DESCRICAO, ''A DEFINIR'')) AS DES_CEST      ');
     SQL.Add('  FROM      ');
     SQL.Add('     PRODUTOS   ');
     SQL.Add('  LEFT JOIN TB_CEST ON TB_CEST.CEST = PRODUTOS.PRO_CEST   ');



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

procedure TFrmSmAnaMara.GerarCliente;
begin

   inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTES.CLI_CODIGO AS COD_CLIENTE,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_NOME, '''') AS DES_CLIENTE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CPFCGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN LEN(CLIENTES.CLI_RGINS) >= 12 THEN COALESCE(CLIENTES.CLI_RGINS, '''')    ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS NUM_INSC_EST,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(CLIENTES.CLI_ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_CIDADE, '''') AS DES_CIDADE,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_ESTADO, '''') AS DES_SIGLA,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_CEP, '''') AS NUM_CEP,   ');
     SQL.Add('       COALESCE(RTRIM({fn CONCAT(CLIENTES.CLI_DDD1, CLIENTES.CLI_TELEFONE1)}), '''') AS NUM_FONE,   ');
     SQL.Add('       COALESCE(RTRIM({fn CONCAT(CLIENTES.CLI_FAXDDD, CLIENTES.CLI_FAX)}), '''') AS NUM_FAX,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_CONTATO, '''') AS DES_CONTATO,   ');
     SQL.Add('       0 AS FLG_SEXO,   ');
     SQL.Add('       CASE WHEN CLIENTES.GRU_CODIGO = 1 THEN COALESCE(CLIENTES.CLI_LIMITE, 0) ELSE 0 END AS VAL_LIMITE_CRETID,   ');
     SQL.Add('       CASE WHEN CLIENTES.GRU_CODIGO = 3 THEN COALESCE(CLIENTES.CLI_LIMITE, 0) ELSE 0 END AS VAL_LIMITE_CONV,   ');
     SQL.Add('       0 AS VAL_DEBITO,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_RENDA, 0) AS VAL_RENDA,   ');
     SQL.Add('       0 AS COD_CONVENIO,   ');
     SQL.Add('       CASE WHEN CLIENTES.CLI_BLOQUEADO = ''S'' THEN 6 ELSE 0 END AS COD_STATUS_PDV,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.CLI_TIPO = ''J'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_EMPRESA,   ');
     SQL.Add('          ');
     SQL.Add('       ''N'' AS FLG_CONVENIO,   ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_DATA_CADASTRO, '''') AS DTA_CADASTRO,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_ENDNRO, ''S/N'') AS NUM_ENDERECO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN LEN(CLIENTES.CLI_RGINS) < 12 THEN COALESCE(CLIENTES.CLI_RGINS, '''')    ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS NUM_RG,       ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''casdo'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''asado'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''soltera'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''acasada'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''OUTROS'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''viuva'' THEN 2   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''VUIVA'' THEN 2   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''casada\'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''SOLTEIRA'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''divorciada'' THEN 3   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''soltreira'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''viuvo'' THEN 2   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''csada'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''separada'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''cassda'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''r.'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''divorciado'' THEN 3   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''scasada'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''soteira'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = '''' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''CASASA'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''SOLTEIRO'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''csado'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''1725000000'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''sal'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''scasado'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''casabo'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''casaba'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''devorsiada'' THEN 3   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''casada'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''CASADO'' THEN 1   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''separado'' THEN 0   ');
     SQL.Add('           WHEN RTRIM(CLIENTES.CLI_EST_CIVIL) = ''casdado'' THEN 1   ');
     SQL.Add('           WHEN CLIENTES.CLI_EST_CIVIL IS NULL THEN 0   ');
     SQL.Add('       END AS FLG_EST_CIVIL,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(RTRIM({fn CONCAT(CLIENTES.CLI_DDDCELULAR, CLIENTES.CLI_CELULAR)}), '''') AS NUM_CELULAR,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_ALTERACAO, '''') AS DTA_ALTERACAO,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_OBS, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       '''' AS DES_COMPLEMENTO,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_EMAIL, '''') AS DES_EMAIL,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_FANTASIA, '''') AS DES_FANTASIA,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_NASCIMENTO, '''') AS DTA_NASCIMENTO,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_PAI, '''') AS DES_PAI,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_MAE, '''') AS DES_MAE,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_CONJUGUE, '''') AS DES_CONJUGE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CON_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CPF_CONJUGE,   ');
     SQL.Add('       0 AS VAL_DEB_CONV,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.CLI_STATUS = ''A'' THEN ''N''   ');
     SQL.Add('           WHEN CLIENTES.CLI_STATUS = ''I'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS INATIVO,   ');
     SQL.Add('          ');
     SQL.Add('       '''' AS DES_MATRICULA,   ');
     SQL.Add('       ''N'' AS NUM_CGC_ASSOCIADO,   ');
     SQL.Add('       ''N'' AS FLG_PROD_RURAL,   ');
     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN CLIENTES.STA_CODIGO = 0 THEN 2   ');
//     SQL.Add('           WHEN CLIENTES.STA_CODIGO = 1 THEN 1   ');
//     SQL.Add('           WHEN CLIENTES.STA_CODIGO = 3 THEN 3   ');
//     SQL.Add('           WHEN CLIENTES.STA_CODIGO = 4 THEN 4    ');
//     SQL.Add('           WHEN CLIENTES.STA_CODIGO = 5 THEN 5    ');
     SQL.Add('           WHEN CLIENTES.CLI_BLOQUEADO = ''S'' THEN 6        ');
     SQL.Add('           ELSE 0   ');
     SQL.Add('       END AS COD_STATUS_PDV_CONV,   ');
     SQL.Add('       ''S'' AS FLG_ENVIA_CODIGO,   ');
     SQL.Add('       COALESCE(CLIENTES.CLI_CON_NASCIMENTO, '''') AS DTA_NASC_CONJUGE,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.GRU_CODIGO = 1 THEN 1   ');
     SQL.Add('           WHEN CLIENTES.GRU_CODIGO = 0 THEN 11   ');
     SQL.Add('           WHEN CLIENTES.GRU_CODIGO = 3 THEN 3   ');
     SQL.Add('           WHEN CLIENTES.GRU_CODIGO = 2 THEN 2   ');
     SQL.Add('           WHEN CLIENTES.GRU_CODIGO = 4 THEN 4   ');
     SQL.Add('           WHEN CLIENTES.GRU_CODIGO = 100 THEN 100   ');
     SQL.Add('           WHEN CLIENTES.GRU_CODIGO = 99 THEN 99   ');
     SQL.Add('           ELSE 0   ');
     SQL.Add('       END AS COD_CLASSIF   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CLIENTES   ');



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

      //Layout.FieldByName('DTA_NASCIMENTO').AsDateTime := FieldByName('DTA_NASCIMENTO').AsDateTime;
      //Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;
      //Layout.FieldByName('DTA_ALTERACAO').AsDateTime := FieldByName('DTA_ALTERACAO').AsDateTime;

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

procedure TFrmSmAnaMara.GerarCodigoBarras;
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
     SQL.Add('       PRODUTOS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.PRO_BARRA = 0 THEN PRODUTOS.PRO_CODIGO ELSE PRODUTOS.PRO_BARRA END AS COD_EAN,   ');
     SQL.Add('   	PRO_PAI   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   WHERE PRODUTOS.PRO_DESCRICAO IS NOT NULL   ');
     SQL.Add('   --AND PRO_BARRA IN (''7896094906655'', ''7891350034585'')   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTOS.PRO_PAI AS COD_PRODUTO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.PRO_BARRA = 0 THEN PRODUTOS.PRO_CODIGO ELSE PRODUTOS.PRO_BARRA END AS COD_EAN,   ');
     SQL.Add('   	PRO_PAI   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   WHERE PRODUTOS.PRO_DESCRICAO IS NULL   ');
     SQL.Add('   --AND PRO_BARRA IN (''7896094906655'', ''7891350034585'')   ');


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

procedure TFrmSmAnaMara.GerarComposicao;
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

procedure TFrmSmAnaMara.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTES.CLI_CODIGO AS COD_CLIENTE,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CLIENTES   ');




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

procedure TFrmSmAnaMara.GerarCondPagForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('       FORNECEDOR.FOR_CODIGO AS COD_FORNECEDOR,   ');
       SQL.Add('       30 AS NUM_CONDICAO,   ');
       SQL.Add('       2 AS COD_CONDICAO,   ');
       SQL.Add('       8 AS COD_ENTIDADE,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.FOR_CGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC   ');
       SQL.Add('   FROM      ');
       SQL.Add('       FORNECEDOR   ');
       SQL.Add('   WHERE FORNECEDOR.FOR_CODIGO <> 0   ');




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

procedure TFrmSmAnaMara.GerarDecomposicao;
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

procedure TFrmSmAnaMara.GerarDivisaoForn;
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

procedure TFrmSmAnaMara.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmAnaMara.GerarFinanceiroPagar(Aberto: String);
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

//     SQL.Add('             SELECT  DISTINCT      ');
//     SQL.Add('                 1 AS TIPO_PARCEIRO,         ');
//     SQL.Add('                 PAGAR.FOR_CODIGO AS COD_PARCEIRO,         ');
//     SQL.Add('                 0 AS TIPO_CONTA,      ');
//     SQL.Add('                   ');
//     SQL.Add('                 CASE            ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 1 THEN 10           ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 2 THEN 9          ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 3 THEN 11            ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 4 THEN 12           ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 5 THEN 13           ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 6 THEN 14           ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 7 THEN 15            ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 8 THEN 16         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 9 THEN 17         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 10 THEN 18         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 11 THEN 19         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 13 THEN 20         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 14 THEN 21         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 15 THEN 22         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 16 THEN 23         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 17 THEN 24         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 18 THEN 1         ');
//     SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 19 THEN 25         ');
//     SQL.Add('                     ELSE 1         ');
//     SQL.Add('                 END AS COD_ENTIDADE,               ');
//     SQL.Add('                                  ');
//     SQL.Add('                 CASE         ');
//     SQL.Add('                     WHEN PAGAR.FIN_NUMERODOC  = '''' THEN CAST(PAGAR.FIN_REGISTRO AS VARCHAR)         ');
//     SQL.Add('                     WHEN LEN(PAGAR.FIN_NUMERODOC) > 10 THEN CAST(PAGAR.FIN_REGISTRO AS VARCHAR)         ');
//     SQL.Add('                     ELSE PAGAR.FIN_NUMERODOC          ');
//     SQL.Add('                 END AS NUM_DOCTO,         ');
//     SQL.Add('                                  ');
//     SQL.Add('                 999 AS COD_BANCO,         ');
//     SQL.Add('                 '''' AS DES_BANCO,         ');
//     SQL.Add('                 COALESCE(PAGAR.FIN_DTEMISSAO, '''') AS DTA_EMISSAO,          ');
//     SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_VENCIMENTO  , '''') AS DTA_VENCIMENTO,         ');
//     SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_VALOR, PAGAR.FIN_VALORTOTAL) + FIN_FATURA.FINFAT_ACRESCIMO AS VAL_PARCELA,         ');
//     SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_JURO, 0) AS VAL_JUROS,         ');
//     SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_DESCONTO, 0) AS VAL_DESCONTO,         ');
//     SQL.Add('                 ''N'' AS FLG_QUITADO,         ');
//     SQL.Add('                 '''' AS DTA_QUITADA,         ');
//     SQL.Add('                 998 AS COD_CATEGORIA,         ');
//     SQL.Add('                 998 AS COD_SUBCATEGORIA,         ');
//     SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_PARCELA, 1) AS NUM_PARCELA,         ');
//     SQL.Add('                 COALESCE(QUANTIDADE.QTD_PARCELA, 1) AS QTD_PARCELA,         ');
//     SQL.Add('                 1 AS COD_LOJA,         ');
//     SQL.Add('                 COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.FOR_CGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,         ');
//     SQL.Add('                 0 AS NUM_BORDERO,         ');
//     SQL.Add('                              ');
//     SQL.Add('                 CASE         ');
//     SQL.Add('                     WHEN PAGAR.FIN_NUMERONOTA  = '''' THEN CAST(PAGAR.FIN_REGISTRO AS VARCHAR)         ');
//     SQL.Add('                     WHEN LEN(PAGAR.FIN_NUMERONOTA) > 10 THEN CAST(PAGAR.FIN_REGISTRO AS VARCHAR)        ');
//     SQL.Add('                     ELSE PAGAR.FIN_NUMERONOTA          ');
//     SQL.Add('                 END AS NUM_NF,         ');
//     SQL.Add('                              ');
//     SQL.Add('                 1 AS NUM_SERIE_NF,         ');
//     SQL.Add('                 COALESCE(PAGAR.FIN_VALORTOTAL, '''') + FIN_FATURA.FINFAT_ACRESCIMO AS VAL_TOTAL_NF,         ');
//     SQL.Add('                 CASE         ');
//     SQL.Add('                     WHEN PAGAR.FIN_NUMERODOC  = '''' THEN CAST(FIN_FATURA.FINFAT_NUMERODOC AS VARCHAR)         ');
//     SQL.Add('                     WHEN LEN(FIN_FATURA.FINFAT_NUMERODOC) > 10 THEN CAST(FIN_FATURA.FINFAT_NUMERODOC AS VARCHAR)         ');
//     SQL.Add('                     ELSE FIN_FATURA.FINFAT_NUMERODOC          ');
//     SQL.Add('                 END AS DES_OBSERVACAO,       ');
//     SQL.Add('                 0 AS NUM_PDV,         ');
//     SQL.Add('                 0 AS NUM_CUPOM_FISCAL,         ');
//     SQL.Add('                 0 AS COD_MOTIVO,         ');
//     SQL.Add('                 0 AS COD_CONVENIO,         ');
//     SQL.Add('                 0 AS COD_BIN,         ');
//     SQL.Add('                 '''' AS DES_BANDEIRA,         ');
//     SQL.Add('                 '''' AS DES_REDE_TEF,         ');
//     SQL.Add('                 0 AS VAL_RETENCAO,         ');
//     SQL.Add('                 0 AS COD_CONDICAO,         ');
//     SQL.Add('                 '''' AS DTA_PAGTO,         ');
//     SQL.Add('                 COALESCE(PAGAR.FIN_DTLANCAMENTO, '''') AS DTA_ENTRADA,         ');
//     SQL.Add('                 '''' AS NUM_NOSSO_NUMERO,         ');
//     SQL.Add('                 '''' AS COD_BARRA,         ');
//     SQL.Add('                 ''N'' AS FLG_BOLETO_EMIT,         ');
//     SQL.Add('                 '''' AS NUM_CGC_CPF_TITULAR,         ');
//     SQL.Add('                 '''' AS DES_TITULAR,         ');
//     SQL.Add('                 30 AS NUM_CONDICAO,         ');
//     SQL.Add('                 0 AS VAL_CREDITO,         ');
//     SQL.Add('                 999 AS COD_BANCO_PGTO,         ');
//     SQL.Add('                 ''PAGTO'' AS DES_CC,         ');
//     SQL.Add('                 0 AS COD_BANDEIRA,         ');
//     SQL.Add('                 '''' AS DTA_PRORROGACAO,         ');
//     SQL.Add('                 1 AS NUM_SEQ_FIN,         ');
//     SQL.Add('                 0 AS COD_COBRANCA,         ');
//     SQL.Add('                 '''' AS DTA_COBRANCA,         ');
//     SQL.Add('                 ''N'' AS FLG_ACEITE,         ');
//     SQL.Add('                 0 AS TIPO_ACEITE         ');
//     SQL.Add('             FROM         ');
//     SQL.Add('                 FIN_FINANCEIRO AS PAGAR         ');
//     SQL.Add('             LEFT JOIN FIN_FATURA ON FIN_FATURA.FIN_REGISTRO = PAGAR.FIN_REGISTRO         ');
//     SQL.Add('             LEFT JOIN FORNECEDOR ON FORNECEDOR.FOR_CODIGO = PAGAR.FOR_CODIGO        ');
//     SQL.Add('             LEFT JOIN FIN_CONTABIL ON  FIN_CONTABIL.FINCON_NUMERONOTA = PAGAR.FIN_NUMERONOTA      ');
//     SQL.Add('             LEFT JOIN (         ');
//     SQL.Add('                 SELECT DISTINCT         ');
//     SQL.Add('                     FIN_REGISTRO,         ');
//     SQL.Add('                     COUNT(FIN_REGISTRO) AS QTD_PARCELA         ');
//     SQL.Add('                 FROM         ');
//     SQL.Add('                     FIN_FATURA         ');
//     SQL.Add('                 GROUP BY         ');
//     SQL.Add('                     FIN_REGISTRO         ');
//     SQL.Add('                 ) AS QUANTIDADE         ');
//     SQL.Add('             ON PAGAR.FIN_REGISTRO = QUANTIDADE.FIN_REGISTRO         ');
//     SQL.Add('             WHERE FORNECEDOR.FOR_CODIGO <> 0         ');
//     SQL.Add('             AND FIN_FATURA.FINFAT_DTPAGAMENTO IS NULL        ');
//     SQL.Add('             AND PAGAR.FINTPD_CODIGO NOT IN (1, 8)      ');
//     SQL.Add('             AND FIN_CONTABIL.FINCON_TIPO = ''C''      ');
 //SQL.Add('             AND PAGAR.FINSTD_CODIGO IS NOT NULL   ');

       SQL.Add('   SELECT   ');
       SQL.Add('       1 AS TIPO_PARCEIRO,   ');
       SQL.Add('      ');
       SQL.Add('       CASE    ');
       SQL.Add('           WHEN CP.FOR_CODIGO = 0 THEN 99999    ');
       SQL.Add('           ELSE CP.FOR_CODIGO    ');
       SQL.Add('       END AS COD_PARCEIRO,   ');
       SQL.Add('      ');
       SQL.Add('       0 AS TIPO_CONTA,   ');
       SQL.Add('          ');
       SQL.Add('       CASE    ');
       SQL.Add('           WHEN CP.CON_TIPODOC = ''NF'' THEN 9   ');
       SQL.Add('           ELSE 8    ');
       SQL.Add('       END AS COD_ENTIDADE,   ');
       SQL.Add('      ');
       SQL.Add('       CP.CON_NDOC AS NUM_DOCTO,   ');
       SQL.Add('       999 AS COD_BANCO,   ');
       SQL.Add('       '''' AS DES_BANCO,   ');
       SQL.Add('       CP.CON_DLCTO AS DTA_EMISSAO,   ');
       SQL.Add('       CP.CON_VECTO AS DTA_VENCIMENTO,   ');
       SQL.Add('       CP.CON_VALOR AS VAL_PARCELA,   ');
       SQL.Add('       CP.CON_JUROS AS VAL_JUROS,   ');
       SQL.Add('       0 AS VAL_DESCONTO,   ');
       SQL.Add('        ');
       SQL.Add('       CASE    ');
       SQL.Add('           WHEN CP.CON_STATUS = ''X'' THEN ''N''   ');
       SQL.Add('           ELSE ''S''   ');
       SQL.Add('       END AS FLG_QUITADO,   ');
       SQL.Add('        ');
       SQL.Add('       CASE    ');
       SQL.Add('           WHEN CP.CON_STATUS = ''X'' THEN ''''   ');
       SQL.Add('           ELSE CP.CON_DPAGO   ');
       SQL.Add('       END AS DTA_QUITADA,   ');
       SQL.Add('        ');
       SQL.Add('       998 AS COD_CATEGORIA,   ');
       SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
       SQL.Add('       1 AS NUM_PARCELA,   ');
       SQL.Add('       COALESCE(PARCELAS.QTD_PARCELA, 1) AS QTD_PARCELA,   ');
       SQL.Add('       CP.EMP_CODIGO AS COD_LOJA,   ');
       SQL.Add('       FORNECEDOR.FOR_CGC AS NUM_CGC,   ');
       SQL.Add('       0 AS NUM_BORDERO,   ');
       SQL.Add('       CP.ENT_NNOTA AS NUM_NF,   ');
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
       SQL.Add('       0 AS COD_CONDICAO,   ');
       SQL.Add('       '''' AS DTA_PAGTO,   ');
       SQL.Add('       CP.CON_DLCTO AS DTA_ENTRADA,   ');
       SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
       SQL.Add('       CP.CON_BARRA AS COD_BARRA,   ');
       SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
       SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
       SQL.Add('       '''' AS DES_TITULAR,   ');
       SQL.Add('       30 AS NUM_CONDICAO,   ');
       SQL.Add('       0 AS VAL_CREDITO,         ');
       SQL.Add('       999 AS COD_BANCO_PGTO,         ');
       SQL.Add('       ''PAGTO'' AS DES_CC,         ');
       SQL.Add('       0 AS COD_BANDEIRA,         ');
       SQL.Add('       '''' AS DTA_PRORROGACAO,         ');
       SQL.Add('       1 AS NUM_SEQ_FIN,         ');
       SQL.Add('       0 AS COD_COBRANCA,         ');
       SQL.Add('       '''' AS DTA_COBRANCA,         ');
       SQL.Add('       ''N'' AS FLG_ACEITE,         ');
       SQL.Add('       0 AS TIPO_ACEITE         ');
       SQL.Add('   FROM   ');
       SQL.Add('       CONTABIL AS CP   ');
       SQL.Add('   INNER JOIN FORNECEDOR ON CP.FOR_CODIGO = FORNECEDOR.FOR_CODIGO   ');
       SQL.Add('   LEFT JOIN   ');
       SQL.Add('   (   ');
       SQL.Add('    	SELECT   ');
       SQL.Add('   	      CONTABIL.ENT_NNOTA,   ');
       SQL.Add('    	    CONTABIL.FOR_CODIGO,   ');
       SQL.Add('    	    COUNT(*) AS QTD_PARCELA,   ');
       SQL.Add('    	    SUM(CON_VALOR_DOC) AS VAL_TOTAL_NF   ');
       SQL.Add('    	FROM   ');
       SQL.Add('    	    CONTABIL   ');
       SQL.Add('    	WHERE COALESCE(CONTABIL.ENT_NNOTA,'''') <> ''''   ');
       SQL.Add('    	AND CON_ACAO IS NULL   ');
       SQL.Add('    	AND CON_DATA_EXCLUSAO IS NULL   ');
       SQL.Add('    	AND CON_CREDITO > CON_DEBITO   ');
       SQL.Add('    	AND EMP_CODIGO = 1   ');
       SQL.Add('    	GROUP BY   ');
       SQL.Add('    	    CONTABIL.ENT_NNOTA,   ');
       SQL.Add('    	    CONTABIL.FOR_CODIGO   ');
       SQL.Add('   ) AS PARCELAS   ');
       SQL.Add('   ON CP.FOR_CODIGO = PARCELAS.FOR_CODIGO AND CP.ENT_NNOTA = PARCELAS.ENT_NNOTA   ');
       SQL.Add('   WHERE CP.CON_STATUS = ''X''   ');
       SQL.Add('   AND CP.CON_DATA_EXCLUSAO IS NULL   ');
       SQL.Add('   AND CP.CON_CREDITO > CP.CON_DEBITO   ');
       SQL.Add('   AND CON_ACAO IS NULL   ');
       SQL.Add('   AND EMP_CODIGO = 1   ');
       SQL.Add('   ORDER BY   ');
       SQL.Add('       CP.ENT_NNOTA,   ');
       SQL.Add('       CP.FOR_CODIGO,   ');
       SQL.Add('       CP.CON_DLCTO   ');
    end
    else
    begin
    //QUITADO

// SQL.Add('             SELECT DISTINCT       ');
// SQL.Add('                 1 AS TIPO_PARCEIRO,         ');
// SQL.Add('                 PAGAR.FOR_CODIGO AS COD_PARCEIRO,         ');
// SQL.Add('                 0 AS TIPO_CONTA,      ');
// SQL.Add('                   ');
// SQL.Add('                 CASE          ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 1 THEN 10         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 2 THEN 9         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 3 THEN 11         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 4 THEN 12         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 5 THEN 13         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 6 THEN 14         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 7 THEN 15         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 8 THEN 16         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 9 THEN 17         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 11 THEN 19         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 13 THEN 20         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 14 THEN 21         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 15 THEN 22         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 17 THEN 23         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 18 THEN 1         ');
// SQL.Add('                     WHEN PAGAR.FINTPD_CODIGO = 19 THEN 25         ');
// SQL.Add('                     ELSE 1         ');
// SQL.Add('                 END AS COD_ENTIDADE,            ');
// SQL.Add('                          ');
// SQL.Add('                 CASE         ');
// SQL.Add('                     WHEN PAGAR.FIN_NUMERODOC  = '''' THEN CAST(PAGAR.FIN_REGISTRO AS VARCHAR)         ');
// SQL.Add('                     WHEN LEN(PAGAR.FIN_NUMERODOC) > 10 THEN CAST(PAGAR.FIN_REGISTRO AS VARCHAR)         ');
// SQL.Add('                     ELSE PAGAR.FIN_NUMERODOC          ');
// SQL.Add('                 END AS NUM_DOCTO,         ');
// SQL.Add('                          ');
// SQL.Add('                 999 AS COD_BANCO,         ');
// SQL.Add('                 '''' AS DES_BANCO,         ');
// SQL.Add('                 COALESCE(PAGAR.FIN_DTEMISSAO, '''') AS DTA_EMISSAO,         ');
// SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_VENCIMENTO  , '''') AS DTA_VENCIMENTO,         ');
// SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_VALOR, PAGAR.FIN_VALORTOTAL) + FIN_FATURA.FINFAT_ACRESCIMO AS VAL_PARCELA,         ');
// SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_JURO, 0) AS VAL_JUROS,         ');
// SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_DESCONTO, 0) AS VAL_DESCONTO,         ');
// SQL.Add('                 ''S'' AS FLG_QUITADO,         ');
// SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_DTPAGAMENTO, '''') AS DTA_QUITADA,         ');
// SQL.Add('                 998 AS COD_CATEGORIA,         ');
// SQL.Add('                 998 AS COD_SUBCATEGORIA,         ');
// SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_PARCELA, 1) AS NUM_PARCELA,         ');
// SQL.Add('                 COALESCE(QUANTIDADE.QTD_PARCELA, 1) AS QTD_PARCELA,         ');
// SQL.Add('                 1 AS COD_LOJA,         ');
// SQL.Add('                 COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.FOR_CGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,         ');
// SQL.Add('                 0 AS NUM_BORDERO,         ');
// SQL.Add('                      ');
// SQL.Add('                 CASE         ');
// SQL.Add('                     WHEN PAGAR.FIN_NUMERONOTA  = '''' THEN CAST(PAGAR.FIN_REGISTRO AS VARCHAR)         ');
// SQL.Add('                     WHEN LEN(PAGAR.FIN_NUMERONOTA) > 10 THEN CAST(PAGAR.FIN_REGISTRO AS VARCHAR)        ');
// SQL.Add('                     ELSE PAGAR.FIN_NUMERONOTA          ');
// SQL.Add('                 END AS NUM_NF,         ');
// SQL.Add('                      ');
// SQL.Add('                 1 AS NUM_SERIE_NF,         ');
// SQL.Add('                 COALESCE(PAGAR.FIN_VALORTOTAL, '''') + FIN_FATURA.FINFAT_ACRESCIMO AS VAL_TOTAL_NF,         ');
// SQL.Add('                 CASE         ');
// SQL.Add('                     WHEN PAGAR.FIN_NUMERODOC  = '''' THEN CAST(FIN_FATURA.FINFAT_NUMERODOC AS VARCHAR)         ');
// SQL.Add('                     WHEN LEN(FIN_FATURA.FINFAT_NUMERODOC) > 10 THEN CAST(FIN_FATURA.FINFAT_NUMERODOC AS VARCHAR)         ');
// SQL.Add('                     ELSE FIN_FATURA.FINFAT_NUMERODOC          ');
// SQL.Add('                 END AS DES_OBSERVACAO,       ');
// SQL.Add('                 0 AS NUM_PDV,         ');
// SQL.Add('                 0 AS NUM_CUPOM_FISCAL,         ');
// SQL.Add('                 0 AS COD_MOTIVO,         ');
// SQL.Add('                 0 AS COD_CONVENIO,         ');
// SQL.Add('                 0 AS COD_BIN,         ');
// SQL.Add('                 '''' AS DES_BANDEIRA,         ');
// SQL.Add('                 '''' AS DES_REDE_TEF,         ');
// SQL.Add('                 0 AS VAL_RETENCAO,         ');
// SQL.Add('                 0 AS COD_CONDICAO,         ');
// SQL.Add('                 COALESCE(FIN_FATURA.FINFAT_DTPAGAMENTO, '''') AS DTA_PAGTO,         ');
// SQL.Add('                 COALESCE(PAGAR.FIN_DTLANCAMENTO, '''') AS DTA_ENTRADA,         ');
// SQL.Add('                 '''' AS NUM_NOSSO_NUMERO,         ');
// SQL.Add('                 '''' AS COD_BARRA,         ');
// SQL.Add('                 ''N'' AS FLG_BOLETO_EMIT,         ');
// SQL.Add('                 '''' AS NUM_CGC_CPF_TITULAR,         ');
// SQL.Add('                 '''' AS DES_TITULAR,         ');
// SQL.Add('                 30 AS NUM_CONDICAO,         ');
// SQL.Add('                 0 AS VAL_CREDITO,         ');
// SQL.Add('                 999 AS COD_BANCO_PGTO,         ');
// SQL.Add('                 ''PAGTO'' AS DES_CC,         ');
// SQL.Add('                 0 AS COD_BANDEIRA,         ');
// SQL.Add('                 '''' AS DTA_PRORROGACAO,         ');
// SQL.Add('                 1 AS NUM_SEQ_FIN,         ');
// SQL.Add('                 0 AS COD_COBRANCA,         ');
// SQL.Add('                 '''' AS DTA_COBRANCA,         ');
// SQL.Add('                 ''N'' AS FLG_ACEITE,         ');
// SQL.Add('                 0 AS TIPO_ACEITE         ');
// SQL.Add('             FROM         ');
// SQL.Add('                 FIN_FINANCEIRO AS PAGAR         ');
// SQL.Add('             LEFT JOIN FIN_FATURA ON FIN_FATURA.FIN_REGISTRO = PAGAR.FIN_REGISTRO         ');
// SQL.Add('             LEFT JOIN FORNECEDOR ON FORNECEDOR.FOR_CODIGO = PAGAR.FOR_CODIGO        ');
// SQL.Add('             LEFT JOIN FIN_CONTABIL ON FIN_CONTABIL.FOR_CODIGO = PAGAR.FOR_CODIGO AND FIN_CONTABIL.FINCON_NUMERONOTA = PAGAR.FIN_NUMERONOTA       ');
// SQL.Add('             LEFT JOIN (         ');
// SQL.Add('                 SELECT DISTINCT         ');
// SQL.Add('             	    FIN_REGISTRO,         ');
// SQL.Add('                     COUNT(FIN_REGISTRO) AS QTD_PARCELA         ');
// SQL.Add('                 FROM         ');
// SQL.Add('                     FIN_FATURA         ');
// SQL.Add('                 GROUP BY         ');
// SQL.Add('                     FIN_REGISTRO         ');
// SQL.Add('             ) AS QUANTIDADE         ');
// SQL.Add('             ON PAGAR.FIN_REGISTRO = QUANTIDADE.FIN_REGISTRO         ');
// SQL.Add('             WHERE FORNECEDOR.FOR_CODIGO <> 0         ');
// SQL.Add('             AND (FIN_FATURA.FINFAT_DTPAGAMENTO IS NOT NULL      ');
// SQL.Add('             OR FIN_CONTABIL.FINCON_DTPAGAMENTO IS NULL)      ');
// SQL.Add('             AND FIN_CONTABIL.FINCON_TIPO = ''C''   ');
  //SQL.Add('             AND PAGAR.FINSTD_CODIGO IS NOT NULL   ');

     SQL.Add('   SELECT      ');
     SQL.Add('       1 AS TIPO_PARCEIRO,     ');
     SQL.Add('      ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN CP.FOR_CODIGO = 0 THEN 99999       ');
     SQL.Add('           ELSE CP.FOR_CODIGO       ');
     SQL.Add('       END AS COD_PARCEIRO,     ');
     SQL.Add('      ');
     SQL.Add('       0 AS TIPO_CONTA,      ');
     SQL.Add('      ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN CP.CON_TIPODOC = ''NF'' THEN 9      ');
     SQL.Add('           ELSE 8       ');
     SQL.Add('       END AS COD_ENTIDADE,     ');
     SQL.Add('      ');
     SQL.Add('       CP.CON_NDOC AS NUM_DOCTO,      ');
     SQL.Add('       999 AS COD_BANCO,      ');
     SQL.Add('       '''' AS DES_BANCO,      ');
     SQL.Add('       CP.CON_DLCTO AS DTA_EMISSAO,      ');
     SQL.Add('       CP.CON_VECTO AS DTA_VENCIMENTO,      ');
     SQL.Add('       CP.CON_VALOR AS VAL_PARCELA,      ');
     SQL.Add('       CP.CON_JUROS AS VAL_JUROS,      ');
     SQL.Add('       0 AS VAL_DESCONTO,      ');
     SQL.Add('       ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN CP.CON_STATUS = ''X'' THEN ''N''      ');
     SQL.Add('           ELSE ''S''      ');
     SQL.Add('       END AS FLG_QUITADO,      ');
     SQL.Add('       ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN CP.CON_STATUS = ''X'' THEN ''''      ');
     SQL.Add('           ELSE CP.CON_DPAGO      ');
     SQL.Add('       END AS DTA_QUITADA,      ');
     SQL.Add('       ');
     SQL.Add('       998 AS COD_CATEGORIA,      ');
     SQL.Add('       998 AS COD_SUBCATEGORIA,      ');
     SQL.Add('       1 AS NUM_PARCELA,      ');
     SQL.Add('       COALESCE(PARCELAS.QTD_PARCELA, 1) AS QTD_PARCELA,      ');
     SQL.Add('       CP.EMP_CODIGO AS COD_LOJA,      ');
     SQL.Add('       FORNECEDOR.FOR_CGC AS NUM_CGC,      ');
     SQL.Add('       0 AS NUM_BORDERO,      ');
     SQL.Add('       CP.ENT_NNOTA AS NUM_NF,      ');
     SQL.Add('       '''' AS NUM_SERIE_NF,      ');
     SQL.Add('       PARCELAS.VAL_TOTAL_NF AS VAL_TOTAL_NF,      ');
     SQL.Add('       '''' AS DES_OBSERVACAO,      ');
     SQL.Add('       1 AS NUM_PDV,      ');
     SQL.Add('       '''' AS NUM_CUPOM_FISCAL,      ');
     SQL.Add('       0 AS COD_MOTIVO,      ');
     SQL.Add('       0 AS COD_CONVENIO,      ');
     SQL.Add('       0 AS COD_BIN,      ');
     SQL.Add('       '''' AS DES_BANDEIRA,      ');
     SQL.Add('       '''' AS DES_REDE_TEF,      ');
     SQL.Add('       0 AS VAL_RETENCAO,      ');
     SQL.Add('       0 AS COD_CONDICAO,      ');
     SQL.Add('       '''' AS DTA_PAGTO,      ');
     SQL.Add('       CP.CON_DLCTO AS DTA_ENTRADA,      ');
     SQL.Add('       '''' AS NUM_NOSSO_NUMERO,      ');
     SQL.Add('       CP.CON_BARRA AS COD_BARRA,      ');
     SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,      ');
     SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,      ');
     SQL.Add('       '''' AS DES_TITULAR,      ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       0 AS VAL_CREDITO,         ');
     SQL.Add('       999 AS COD_BANCO_PGTO,         ');
     SQL.Add('       ''PAGTO'' AS DES_CC,         ');
     SQL.Add('       0 AS COD_BANDEIRA,         ');
     SQL.Add('       '''' AS DTA_PRORROGACAO,         ');
     SQL.Add('       1 AS NUM_SEQ_FIN,         ');
     SQL.Add('       0 AS COD_COBRANCA,         ');
     SQL.Add('       '''' AS DTA_COBRANCA,         ');
     SQL.Add('       ''N'' AS FLG_ACEITE,         ');
     SQL.Add('       0 AS TIPO_ACEITE         ');
     SQL.Add('   FROM      ');
     SQL.Add('       CONTABIL AS CP      ');
     SQL.Add('   INNER JOIN FORNECEDOR ON CP.FOR_CODIGO = FORNECEDOR.FOR_CODIGO      ');
     SQL.Add('   LEFT JOIN      ');
     SQL.Add('   (      ');
     SQL.Add('   	SELECT      ');
     SQL.Add('   	    CONTABIL.ENT_NNOTA,      ');
     SQL.Add('   	    CONTABIL.FOR_CODIGO,      ');
     SQL.Add('   	    COUNT(*) AS QTD_PARCELA,      ');
     SQL.Add('   	    SUM(CON_VALOR_DOC) AS VAL_TOTAL_NF      ');
     SQL.Add('   	FROM      ');
     SQL.Add('   	    CONTABIL      ');
     SQL.Add('   	WHERE COALESCE(CONTABIL.ENT_NNOTA,'''') <> ''''      ');
     SQL.Add('   	AND CON_ACAO IS NULL      ');
     SQL.Add('   	AND CON_DATA_EXCLUSAO IS NULL      ');
     SQL.Add('   	AND CON_CREDITO > CON_DEBITO      ');
     SQL.Add('   	AND EMP_CODIGO = 1      ');
     SQL.Add('   	GROUP BY    ');
     SQL.Add('   	    CONTABIL.ENT_NNOTA,      ');
     SQL.Add('   	    CONTABIL.FOR_CODIGO      ');
     SQL.Add('   ) AS PARCELAS      ');
     SQL.Add('   ON CP.FOR_CODIGO = PARCELAS.FOR_CODIGO AND CP.ENT_NNOTA = PARCELAS.ENT_NNOTA      ');
     SQL.Add('   WHERE CP.CON_DATA_EXCLUSAO IS NULL      ');
     SQL.Add('   AND CP.CON_CREDITO > CP.CON_DEBITO      ');
     SQL.Add('   AND CP.CON_ACAO IS NULL      ');
     SQL.Add('   AND CP.EMP_CODIGO = 1   ');
     SQL.Add('   AND   ');
     SQL.Add('      CAST(CP.CON_EMISSAO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('   AND');
     SQL.Add('      CAST(CP.CON_EMISSAO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add('   ORDER BY   ');
     SQL.Add('      CP.ENT_NNOTA,   ');
     SQL.Add('      CP.FOR_CODIGO,   ');
     SQL.Add('      CP.CON_DLCTO   ');
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
      Layout.FieldByName('DTA_VENCIMENTO').AsString := '';
      if QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsString <> '' then
        Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);
      //Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);

        Layout.FieldByName('DTA_QUITADA').AsString := '';
        if QryPrincipal2.FieldByName('DTA_QUITADA').AsString <> '' then
          Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);

        Layout.FieldByName('DTA_PAGTO').AsString := '';
        if QryPrincipal2.FieldByName('DTA_PAGTO').AsString <> '' then
          Layout.FieldByName('DTA_PAGTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_PAGTO').AsDateTime);

        Layout.FieldByName('DTA_EMISSAO').AsString := '';
        if QryPrincipal2.FieldByName('DTA_EMISSAO').AsString <> '' then
          Layout.FieldByName('DTA_EMISSAO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);

        //if QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsString <> '' then
          //Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);

        Layout.FieldByName('DTA_ENTRADA').AsString := '';
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

procedure TFrmSmAnaMara.GerarFinanceiroReceber(Aberto: String);
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

         SQL.Add('   --ABERTO   ');
         SQL.Add('   --CONVENIO   ');
         SQL.Add('   SELECT DISTINCT    ');
         SQL.Add('       0 AS TIPO_PARCEIRO,      ');
         SQL.Add('       ABERTO.CLI_CODIGO AS COD_PARCEIRO,      ');
         SQL.Add('       1 AS TIPO_CONTA,      ');
         SQL.Add('       4 AS COD_ENTIDADE,      ');
         SQL.Add('       COALESCE(ABERTO.COM_NCUPOM, ABERTO.VEN_REGISTRO) AS NUM_DOCTO,      ');
         SQL.Add('       999 AS COD_BANCO,      ');
         SQL.Add('       '''' AS DES_BANCO,      ');
         SQL.Add('       ABERTO.VEN_DATA AS DTA_EMISSAO,      ');
         SQL.Add('       ABERTO.VEN_VENCIMENTO AS DTA_VENCIMENTO,      ');
         SQL.Add('       ABERTO.PRO_VENDA AS VAL_PARCELA,      ');
         SQL.Add('       0 AS VAL_JUROS,      ');
         SQL.Add('       0 AS VAL_DESCONTO,      ');
         SQL.Add('       ''N'' AS FLG_QUITADO,      ');
         SQL.Add('       '''' AS DTA_QUITADA,      ');
         SQL.Add('       997 AS COD_CATEGORIA,      ');
         SQL.Add('       997 AS COD_SUBCATEGORIA,      ');
         SQL.Add('       COALESCE(ABERTO.VEN_REGISTRO_PDV, 1) AS NUM_PARCELA,      ');
         SQL.Add('         ');
         SQL.Add('       CASE      ');
         SQL.Add('           WHEN ABERTO.COM_REGISTRO = QUITADO.COM_REGISTRO THEN COALESCE(QTD.QTD_PARCELA, 1) + COALESCE(QTD_Q.QTD_PARCELA, 1)      ');
         SQL.Add('           ELSE COALESCE(QTD.QTD_PARCELA, 1)       ');
         SQL.Add('       END AS QTD_PARCELA,          ');
         SQL.Add('             ');
         SQL.Add('       1 AS COD_LOJA,      ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CPFCGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,      ');
         SQL.Add('       0 AS NUM_BORDERO,      ');
         SQL.Add('       COALESCE(ABERTO.COM_NCUPOM, ABERTO.VEN_REGISTRO) AS NUM_NF,      ');
         SQL.Add('       '''' AS NUM_SERIE_NF,      ');
         SQL.Add('   	      ');
         SQL.Add('   	CASE      ');
         SQL.Add('   		WHEN ABERTO.COM_REGISTRO = QUITADO.COM_REGISTRO THEN COALESCE(VAL.VAL_TOTAL_NF, ABERTO.PRO_VENDA) + QUITADO.PRO_VENDA      ');
         SQL.Add('   		ELSE COALESCE(VAL.VAL_TOTAL_NF, ABERTO.PRO_VENDA)       ');
         SQL.Add('   	END AS VAL_TOTAL_NF,      ');
         SQL.Add('         ');
         SQL.Add('       ABERTO.PRO_DESCRICAO AS DES_OBSERVACAO,      ');
         SQL.Add('       0 AS NUM_PDV,      ');
         SQL.Add('       COALESCE(ABERTO.COM_NCUPOM, ABERTO.VEN_REGISTRO) AS NUM_CUPOM_FISCAL,      ');
         SQL.Add('       0 AS COD_MOTIVO,      ');
         SQL.Add('       0 AS COD_CONVENIO,      ');
         SQL.Add('       0 AS COD_BIN,      ');
         SQL.Add('       '''' AS DES_BANDEIRA,      ');
         SQL.Add('       '''' AS DES_REDE_TEF,      ');
         SQL.Add('       0 AS VAL_RETENCAO,      ');
         SQL.Add('       0 AS COD_CONDICAO,      ');
         SQL.Add('       '''' AS DTA_PAGTO,      ');
         SQL.Add('       ABERTO.DATA_PROCESSO AS DTA_ENTRADA,      ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,      ');
         SQL.Add('       '''' AS COD_BARRA,      ');
         SQL.Add('       ''N''AS FLG_BOLETO_EMIT,      ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,      ');
         SQL.Add('       '''' AS DES_TITULAR,      ');
         SQL.Add('       30 AS NUM_CONDICAO,      ');
         SQL.Add('       0 AS VAL_CREDITO,      ');
         SQL.Add('       999 AS COD_BANCO_PGTO,      ');
         SQL.Add('       ''RECEBTO'' AS DES_CC,      ');
         SQL.Add('       0 AS COD_BANDEIRA,      ');
         SQL.Add('       '''' AS DTA_PRORROGACAO,      ');
         SQL.Add('       1 AS NUM_SEQ_FIN,      ');
         SQL.Add('       0 AS COD_COBRANCA,      ');
         SQL.Add('       '''' AS DTA_COBRANCA,      ');
         SQL.Add('       ''N'' AS FLG_ACEITE,      ');
         SQL.Add('       0 AS TIPO_ACEITE      ');
         SQL.Add('   FROM      ');
         SQL.Add('       VENDAS_PRAZO AS ABERTO      ');
         SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_CODIGO = ABERTO.CLI_CODIGO      ');
         SQL.Add('   LEFT JOIN BAIXAS_PRAZO AS QUITADO ON QUITADO.COM_REGISTRO = ABERTO.COM_REGISTRO AND QUITADO.CLI_CODIGO = ABERTO.CLI_CODIGO      ');
         SQL.Add('   LEFT JOIN (      ');
         SQL.Add('       SELECT DISTINCT      ');
         SQL.Add('           COM_REGISTRO,      ');
         SQL.Add('           COUNT(COM_REGISTRO) AS QTD_PARCELA      ');
         SQL.Add('       FROM      ');
         SQL.Add('           VENDAS_PRAZO      ');
         SQL.Add('       GROUP BY COM_REGISTRO      ');
         SQL.Add('   ) AS QTD      ');
         SQL.Add('   ON ABERTO.COM_REGISTRO = QTD.COM_REGISTRO      ');
         SQL.Add('   LEFT JOIN (      ');
         SQL.Add('       SELECT DISTINCT      ');
         SQL.Add('           COM_REGISTRO,      ');
         SQL.Add('           COUNT(COM_REGISTRO) AS QTD_PARCELA      ');
         SQL.Add('       FROM      ');
         SQL.Add('           BAIXAS_PRAZO      ');
         SQL.Add('       GROUP BY COM_REGISTRO      ');
         SQL.Add('   ) AS QTD_Q      ');
         SQL.Add('   ON ABERTO.COM_REGISTRO = QTD_Q.COM_REGISTRO      ');
         SQL.Add('   LEFT JOIN (      ');
         SQL.Add('       SELECT DISTINCT      ');
         SQL.Add('           COM_REGISTRO,      ');
         SQL.Add('           SUM(PRO_VENDA) AS VAL_TOTAL_NF      ');
         SQL.Add('       FROM      ');
         SQL.Add('           VENDAS_PRAZO      ');
         SQL.Add('       GROUP BY COM_REGISTRO      ');
         SQL.Add('   ) AS VAL      ');
         SQL.Add('   ON ABERTO.COM_REGISTRO = VAL.COM_REGISTRO      ');
         SQL.Add('   WHERE  ');
         SQL.Add('   CAST(ABERTO.VEN_DATA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
         SQL.Add('   AND');
         SQL.Add('   CAST(ABERTO.VEN_DATA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
         SQL.Add('      ');
         SQL.Add('   UNION ALL   ');
         SQL.Add('      ');
         SQL.Add('   --CHEQUES   ');
         SQL.Add('   SELECT DISTINCT   ');
         SQL.Add('       0 AS TIPO_PARCEIRO,   ');
         SQL.Add('       CHEQUE.CLI_CODIGO AS COD_PARCEIRO,   ');
         SQL.Add('       1 AS TIPO_CONTA,   ');
         SQL.Add('       11 AS COD_ENTIDADE,   ');
         SQL.Add('       CHEQUE.CHE_NUMERO AS NUM_DOCTO,   ');
         SQL.Add('       999 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       CHEQUE.CHE_DATA AS DTA_EMISSAO,   ');
         SQL.Add('       CHEQUE.CHE_VECTO AS DTA_VENCIMENTO,   ');
         SQL.Add('       CHEQUE.CHE_VALOR AS VAL_PARCELA,   ');
         SQL.Add('       0 AS VAL_JUROS,   ');
         SQL.Add('       0 AS VAL_DESCONTO,   ');
         SQL.Add('       ''N'' AS FLG_QUITADO,   ');
         SQL.Add('       '''' AS DTA_QUITADA,   ');
         SQL.Add('      ');
         SQL.Add('       CASE   ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''A'' THEN 1    ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''P'' THEN 1    ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''R'' THEN 1    ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''D'' THEN 1    ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''X'' THEN 1    ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''U'' THEN 1   ');
         SQL.Add('           ELSE 1   ');
         SQL.Add('       END AS COD_CATEGORIA,   ');
         SQL.Add('      ');
         SQL.Add('       CASE   ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''A'' THEN 45    ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''P'' THEN 46   ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''R'' THEN 47   ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''D'' THEN 48   ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''X'' THEN 49   ');
         SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''U'' THEN 50   ');
         SQL.Add('           ELSE 99   ');
         SQL.Add('       END AS COD_SUBCATEGORIA,   ');
         SQL.Add('      ');
         SQL.Add('       1 AS NUM_PARCELA,   ');
         SQL.Add('       1 AS QTD_PARCELA,   ');
         SQL.Add('       1 AS COD_LOJA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CPFCGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       0 AS NUM_NF,   ');
         SQL.Add('       '''' AS NUM_SERIE_NF,   ');
         SQL.Add('       CHEQUE.CHE_VALOR AS VAL_TOTAL_NF,   ');
         SQL.Add('       COALESCE(CHEQUE.CHE_PAGOA, '''') AS DES_OBSERVACAO,   ');
         SQL.Add('          ');
         SQL.Add('       CASE   ');
         SQL.Add('          WHEN CHEQUE.MAQ_NOME = ''PEDRO'' THEN ''0''  ');
         SQL.Add('   		    WHEN LEN(UPPER(CHEQUE.MAQ_NOME)) = 5 THEN SUBSTRING(MAQ_NOME, 4, 5)   ');
         SQL.Add('   		    ELSE 0   ');
         SQL.Add('   	   END AS NUM_PDV,   ');
         SQL.Add('      ');
         SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('       0 AS COD_MOTIVO,   ');
         SQL.Add('       0 AS COD_CONVENIO,   ');
         SQL.Add('       0 AS COD_BIN,   ');
         SQL.Add('       '''' AS DES_BANDEIRA,   ');
         SQL.Add('       '''' AS DES_REDE_TEF,   ');
         SQL.Add('       0 AS VAL_RETENCAO,   ');
         SQL.Add('       0 AS COD_CONDICAO,   ');
         SQL.Add('       '''' AS DTA_PAGTO,   ');
         SQL.Add('       CHEQUE.CHE_DATA AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       '''' AS DES_TITULAR,   ');
         SQL.Add('       30 AS NUM_CONDICAO,   ');
         SQL.Add('       0 AS VAL_CREDITO,   ');
         SQL.Add('       999 AS COD_BANCO_PGTO,   ');
         SQL.Add('       ''RECEBTO'' AS DES_CC,   ');
         SQL.Add('       0 AS COD_BANDEIRA,   ');
         SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
         SQL.Add('       1 AS NUM_SEQ_FIN,   ');
         SQL.Add('       0 AS COD_COBRANCA,   ');
         SQL.Add('       '''' AS DTA_COBRANCA,   ');
         SQL.Add('       ''N'' AS FLG_ACEITE,   ');
         SQL.Add('       0 AS TIPO_ACEITE   ');
         SQL.Add('   FROM   ');
         SQL.Add('       CHEQUE_REC AS CHEQUE   ');
         SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_CODIGO = CHEQUE.CLI_CODIGO   ');
         SQL.Add('   WHERE CHEQUE.CHE_VECTO = CHEQUE.CHE_DATA   ');
         SQL.Add('   AND  ');
         SQL.Add('   CAST(CHEQUE.CHE_DATA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
         SQL.Add('   AND');
         SQL.Add('   CAST(CHEQUE.CHE_DATA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');






//     SQL.Add('AND');

//     SQL.Add(' PAGARABERTO.VENCIMENTO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
//     SQL.Add('AND');
//     SQL.Add(' PAGARABERTO.VENCIMENTO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
    end
    else
    begin
    // QUITADO
           SQL.Add('   --QUITADO   ');
           SQL.Add('   --CONVENIO   ');
           SQL.Add('   SELECT DISTINCT       ');
           SQL.Add('       0 AS TIPO_PARCEIRO,      ');
           SQL.Add('       QUITADO.CLI_CODIGO AS COD_PARCEIRO,      ');
           SQL.Add('       1 AS TIPO_CONTA,      ');
           SQL.Add('       4 AS COD_ENTIDADE,      ');
           SQL.Add('       COALESCE(QUITADO.COM_NCUPOM, QUITADO.VEN_REGISTRO) AS NUM_DOCTO,      ');
           SQL.Add('       999 AS COD_BANCO,      ');
           SQL.Add('       '''' AS DES_BANCO,      ');
           SQL.Add('       QUITADO.VEN_DATA AS DTA_EMISSAO,      ');
           SQL.Add('       QUITADO.VEN_VENCIMENTO AS DTA_VENCIMENTO,      ');
           SQL.Add('       QUITADO.PRO_VENDA AS VAL_PARCELA,      ');
           SQL.Add('       0 AS VAL_JUROS,      ');
           SQL.Add('       0 AS VAL_DESCONTO,      ');
           SQL.Add('       ''S'' AS FLG_QUITADO,      ');
           SQL.Add('       QUITADO.VEN_VENCIMENTO AS DTA_QUITADA,      ');
           SQL.Add('       997 AS COD_CATEGORIA,      ');
           SQL.Add('       997 AS COD_SUBCATEGORIA,      ');
           SQL.Add('             ');
           SQL.Add('       CASE      ');
           SQL.Add('   		WHEN QUITADO.PRO_DESCRICAO = ''CUPOM'' THEN ''1''      ');
           SQL.Add('   		WHEN QUITADO.PRO_DESCRICAO = ''CUPOM 1/1'' THEN ''1''      ');
           SQL.Add('   		WHEN QUITADO.PRO_DESCRICAO = ''RESTANTE DO DEBITO'' THEN ''1''      ');
           SQL.Add('   		WHEN QUITADO.PRO_DESCRICAO = ''Duplicata'' THEN ''1''      ');
           SQL.Add('           ELSE SUBSTRING(QUITADO.PRO_DESCRICAO, 7,1)       ');
           SQL.Add('       END AS NUM_PARCELA,      ');
           SQL.Add('         ');
           SQL.Add('       CASE      ');
           SQL.Add('           WHEN QUITADO.COM_REGISTRO = QUITADO.COM_REGISTRO THEN COALESCE(QTD.QTD_PARCELA, 1) + COALESCE(QTD_Q.QTD_PARCELA, 1)      ');
           SQL.Add('           ELSE COALESCE(QTD.QTD_PARCELA, 1)       ');
           SQL.Add('       END AS QTD_PARCELA,          ');
           SQL.Add('             ');
           SQL.Add('       1 AS COD_LOJA,      ');
           SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CPFCGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,      ');
           SQL.Add('       0 AS NUM_BORDERO,      ');
           SQL.Add('       COALESCE(QUITADO.COM_NCUPOM, QUITADO.VEN_REGISTRO) AS NUM_NF,      ');
           SQL.Add('       '''' AS NUM_SERIE_NF,      ');
           SQL.Add('   	      ');
           SQL.Add('   	CASE      ');
           SQL.Add('   		WHEN QUITADO.COM_REGISTRO = QUITADO.COM_REGISTRO THEN COALESCE(VAL.VAL_TOTAL_NF, QUITADO.PRO_VENDA) + QUITADO.PRO_VENDA      ');
           SQL.Add('   		ELSE COALESCE(VAL.VAL_TOTAL_NF, QUITADO.PRO_VENDA)       ');
           SQL.Add('   	END AS VAL_TOTAL_NF,      ');
           SQL.Add('         ');
           SQL.Add('       QUITADO.PRO_DESCRICAO AS DES_OBSERVACAO,      ');
           SQL.Add('       0 AS NUM_PDV,      ');
           SQL.Add('       COALESCE(QUITADO.COM_NCUPOM, QUITADO.VEN_REGISTRO) AS NUM_CUPOM_FISCAL,      ');
           SQL.Add('       0 AS COD_MOTIVO,      ');
           SQL.Add('       0 AS COD_CONVENIO,      ');
           SQL.Add('       0 AS COD_BIN,      ');
           SQL.Add('       '''' AS DES_BANDEIRA,      ');
           SQL.Add('       '''' AS DES_REDE_TEF,      ');
           SQL.Add('       0 AS VAL_RETENCAO,      ');
           SQL.Add('       0 AS COD_CONDICAO,      ');
           SQL.Add('       QUITADO.VEN_VENCIMENTO AS DTA_PAGTO,      ');
           SQL.Add('       QUITADO.DATA_PROCESSO AS DTA_ENTRADA,      ');
           SQL.Add('       '''' AS NUM_NOSSO_NUMERO,      ');
           SQL.Add('       '''' AS COD_BARRA,      ');
           SQL.Add('       ''N''AS FLG_BOLETO_EMIT,      ');
           SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,      ');
           SQL.Add('       '''' AS DES_TITULAR,      ');
           SQL.Add('       30 AS NUM_CONDICAO,      ');
           SQL.Add('       0 AS VAL_CREDITO,      ');
           SQL.Add('       999 AS COD_BANCO_PGTO,      ');
           SQL.Add('       ''RECEBTO'' AS DES_CC,      ');
           SQL.Add('       0 AS COD_BANDEIRA,      ');
           SQL.Add('       '''' AS DTA_PRORROGACAO,      ');
           SQL.Add('       1 AS NUM_SEQ_FIN,      ');
           SQL.Add('       0 AS COD_COBRANCA,      ');
           SQL.Add('       '''' AS DTA_COBRANCA,      ');
           SQL.Add('       ''N'' AS FLG_ACEITE,      ');
           SQL.Add('       0 AS TIPO_ACEITE      ');
           SQL.Add('   FROM      ');
           SQL.Add('       BAIXAS_PRAZO AS QUITADO      ');
           SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_CODIGO = QUITADO.CLI_CODIGO      ');
           SQL.Add('   LEFT JOIN VENDAS_PRAZO AS ABERTO ON QUITADO.COM_REGISTRO = QUITADO.COM_REGISTRO AND QUITADO.CLI_CODIGO = QUITADO.CLI_CODIGO      ');
           SQL.Add('   LEFT JOIN (      ');
           SQL.Add('       SELECT DISTINCT      ');
           SQL.Add('           COM_REGISTRO,      ');
           SQL.Add('           COUNT(COM_REGISTRO) AS QTD_PARCELA      ');
           SQL.Add('       FROM      ');
           SQL.Add('           VENDAS_PRAZO      ');
           SQL.Add('       GROUP BY COM_REGISTRO      ');
           SQL.Add('   ) AS QTD      ');
           SQL.Add('   ON QUITADO.COM_REGISTRO = QTD.COM_REGISTRO      ');
           SQL.Add('   LEFT JOIN (      ');
           SQL.Add('       SELECT DISTINCT      ');
           SQL.Add('           COM_REGISTRO,      ');
           SQL.Add('           COUNT(COM_REGISTRO) AS QTD_PARCELA      ');
           SQL.Add('       FROM      ');
           SQL.Add('           BAIXAS_PRAZO      ');
           SQL.Add('       GROUP BY COM_REGISTRO      ');
           SQL.Add('   ) AS QTD_Q      ');
           SQL.Add('   ON QUITADO.COM_REGISTRO = QTD_Q.COM_REGISTRO      ');
           SQL.Add('   LEFT JOIN (      ');
           SQL.Add('       SELECT DISTINCT      ');
           SQL.Add('           COM_REGISTRO,      ');
           SQL.Add('           SUM(PRO_VENDA) AS VAL_TOTAL_NF      ');
           SQL.Add('       FROM      ');
           SQL.Add('           VENDAS_PRAZO      ');
           SQL.Add('       GROUP BY COM_REGISTRO      ');
           SQL.Add('   ) AS VAL      ');
           SQL.Add('   ON QUITADO.COM_REGISTRO = VAL.COM_REGISTRO      ');
           SQL.Add('   WHERE  ');
           SQL.Add('   CAST(QUITADO.DATA_PROCESSO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
           SQL.Add('   AND');
           SQL.Add('   CAST(QUITADO.DATA_PROCESSO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
           SQL.Add('      ');
           SQL.Add('   UNION ALL   ');
           SQL.Add('      ');
           SQL.Add('   --CHEQUES   ');
           SQL.Add('   SELECT DISTINCT   ');
           SQL.Add('       0 AS TIPO_PARCEIRO,   ');
           SQL.Add('       CHEQUE.CLI_CODIGO AS COD_PARCEIRO,   ');
           SQL.Add('       1 AS TIPO_CONTA,   ');
           SQL.Add('       11 AS COD_ENTIDADE,   ');
           SQL.Add('       CHEQUE.CHE_NUMERO AS NUM_DOCTO,   ');
           SQL.Add('       999 AS COD_BANCO,   ');
           SQL.Add('       '''' AS DES_BANCO,   ');
           SQL.Add('       CHEQUE.CHE_DATA AS DTA_EMISSAO,   ');
           SQL.Add('       CHEQUE.CHE_VECTO AS DTA_VENCIMENTO,   ');
           SQL.Add('       CHEQUE.CHE_VALOR AS VAL_PARCELA,   ');
           SQL.Add('       0 AS VAL_JUROS,   ');
           SQL.Add('       0 AS VAL_DESCONTO,   ');
           SQL.Add('       ''S'' AS FLG_QUITADO,   ');
           SQL.Add('       CHEQUE.CHE_VECTO AS DTA_QUITADA,   ');
           SQL.Add('      ');
           SQL.Add('       CASE   ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''A'' THEN 1    ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''P'' THEN 1    ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''R'' THEN 1    ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''D'' THEN 1    ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''X'' THEN 1    ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''U'' THEN 1   ');
           SQL.Add('           ELSE 1   ');
           SQL.Add('       END AS COD_CATEGORIA,   ');
           SQL.Add('      ');
           SQL.Add('       CASE   ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''A'' THEN 45    ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''P'' THEN 46   ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''R'' THEN 47   ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''D'' THEN 48   ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''X'' THEN 49   ');
           SQL.Add('           WHEN CHEQUE.CHE_STATUS = ''U'' THEN 50   ');
           SQL.Add('           ELSE 99   ');
           SQL.Add('       END AS COD_SUBCATEGORIA,   ');
           SQL.Add('      ');
           SQL.Add('       ''1'' AS NUM_PARCELA,   ');
           SQL.Add('       1 AS QTD_PARCELA,   ');
           SQL.Add('       1 AS COD_LOJA,   ');
           SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CLI_CPFCGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
           SQL.Add('       0 AS NUM_BORDERO,   ');
           SQL.Add('       0 AS NUM_NF,   ');
           SQL.Add('       '''' AS NUM_SERIE_NF,   ');
           SQL.Add('       CHEQUE.CHE_VALOR AS VAL_TOTAL_NF,   ');
           SQL.Add('       COALESCE(CHEQUE.CHE_PAGOA, '''') AS DES_OBSERVACAO,   ');
           SQL.Add('          ');
           SQL.Add('       CASE   ');
           SQL.Add('          WHEN CHEQUE.MAQ_NOME = ''PEDRO'' THEN ''0''  ');
           SQL.Add('   		    WHEN LEN(UPPER(CHEQUE.MAQ_NOME)) = 5 THEN SUBSTRING(MAQ_NOME, 4, 5)   ');
           SQL.Add('   		    ELSE 0   ');
           SQL.Add('   	   END AS NUM_PDV,   ');
           SQL.Add('      ');
           SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
           SQL.Add('       0 AS COD_MOTIVO,   ');
           SQL.Add('       0 AS COD_CONVENIO,   ');
           SQL.Add('       0 AS COD_BIN,   ');
           SQL.Add('       '''' AS DES_BANDEIRA,   ');
           SQL.Add('       '''' AS DES_REDE_TEF,   ');
           SQL.Add('       0 AS VAL_RETENCAO,   ');
           SQL.Add('       0 AS COD_CONDICAO,   ');
           SQL.Add('       CHEQUE.CHE_VECTO AS DTA_PAGTO,   ');
           SQL.Add('       CHEQUE.CHE_DATA AS DTA_ENTRADA,   ');
           SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
           SQL.Add('       '''' AS COD_BARRA,   ');
           SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
           SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
           SQL.Add('       '''' AS DES_TITULAR,   ');
           SQL.Add('       30 AS NUM_CONDICAO,   ');
           SQL.Add('       0 AS VAL_CREDITO,   ');
           SQL.Add('       999 AS COD_BANCO_PGTO,   ');
           SQL.Add('       ''RECEBTO'' AS DES_CC,   ');
           SQL.Add('       0 AS COD_BANDEIRA,   ');
           SQL.Add('       '''' AS DTA_PRORROGACAO,   ');
           SQL.Add('       1 AS NUM_SEQ_FIN,   ');
           SQL.Add('       0 AS COD_COBRANCA,   ');
           SQL.Add('       '''' AS DTA_COBRANCA,   ');
           SQL.Add('       ''N'' AS FLG_ACEITE,   ');
           SQL.Add('       0 AS TIPO_ACEITE   ');
           SQL.Add('   FROM   ');
           SQL.Add('       CHEQUE_REC AS CHEQUE   ');
           SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.CLI_CODIGO = CHEQUE.CLI_CODIGO   ');
           SQL.Add('   WHERE CHEQUE.CHE_VECTO <> CHEQUE.CHE_DATA   ');
           SQL.Add('   AND  ');
           SQL.Add('   CAST(CHEQUE.CHE_DATA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
           SQL.Add('   AND');
           SQL.Add('   CAST(CHEQUE.CHE_DATA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');


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

procedure TFrmSmAnaMara.GerarFinanceiroReceberCartao;
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

procedure TFrmSmAnaMara.GerarFornecedor;
var
   observacao, email, inscEst : string;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('       FORNECEDOR.FOR_CODIGO AS COD_FORNECEDOR,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_RAZAO, '''') AS DES_FORNECEDOR,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_FANTASIA, '''') AS DES_FANTASIA,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.FOR_CGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.FOR_INS, ''.'', ''''), ''/'', ''''), ''-'', ''''), ''ISENTO'') AS NUM_INSC_EST,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_BAIRRO, '''') AS DES_BAIRRO,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_CIDADE, '''') AS DES_CIDADE,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_ESTADO, '''') AS DES_SIGLA,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_CEP, '''') AS NUM_CEP,   ');
       SQL.Add('       COALESCE(RTRIM({fn CONCAT(FORNECEDOR.FOR_DDD1, FORNECEDOR.FOR_TELEFONE1)}), '''') AS NUM_FONE,   ');
       SQL.Add('       COALESCE(RTRIM({fn CONCAT(FORNECEDOR.FOR_FAXDDD, FORNECEDOR.FOR_FAX)}), '''') AS NUM_FAX,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_CONTATO, '''') AS DES_CONTATO,   ');
       SQL.Add('       0 AS QTD_DIA_CARENCIA,   ');
       SQL.Add('       0 AS NUM_FREQ_VISITA,   ');
       SQL.Add('       0 AS VAL_DESCONTO,   ');
       SQL.Add('       0 AS NUM_PRAZO,   ');
       SQL.Add('       ''N'' AS ACEITA_DEVOL_MER,   ');
       SQL.Add('       ''N'' AS CAL_IPI_VAL_BRUTO,   ');
       SQL.Add('       ''N'' AS CAL_ICMS_ENC_FIN,   ');
       SQL.Add('       ''N'' AS CAL_ICMS_VAL_IPI,   ');
       SQL.Add('       ''N'' AS MICRO_EMPRESA,   ');
       SQL.Add('       FORNECEDOR.FOR_CODIGO AS COD_FORNECEDOR_ANT,   ');
       SQL.Add('       UPPER(COALESCE(FORNECEDOR.FOR_ENDNRO, ''S/N'')) AS NUM_ENDERECO,   ');
       SQL.Add('       COALESCE(CAST(FORNECEDOR.FOR_OBS AS VARCHAR), '''') AS DES_OBSERVACAO,   ');
       SQL.Add('       COALESCE(FORNECEDOR.FOR_EMAIL, '''') AS DES_EMAIL,   ');
       SQL.Add('       '''' AS DES_WEB_SITE,   ');
       SQL.Add('       ''N'' AS FABRICANTE,   ');
       SQL.Add('       ''N'' AS FLG_PRODUTOR_RURAL,   ');
       SQL.Add('       0 AS TIPO_FRETE,   ');
       SQL.Add('       ''N'' AS FLG_SIMPLES,   ');
       SQL.Add('       ''N'' AS FLG_SUBSTITUTO_TRIB,   ');
       SQL.Add('       0 AS COD_CONTACCFORN,   ');
       SQL.Add('      ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN FORNECEDOR.FOR_STATUS = ''A'' THEN ''N''   ');
       SQL.Add('           ELSE ''N''   ');
       SQL.Add('       END AS INATIVO,   ');
       SQL.Add('      ');
       SQL.Add('       0 AS COD_CLASSIF,   ');
       SQL.Add('       '''' AS DTA_CADASTRO,   ');
       SQL.Add('       0 AS VAL_CREDITO,   ');
       SQL.Add('       0 AS VAL_DEBITO,   ');
       SQL.Add('       1 AS PED_MIN_VAL,   ');
       SQL.Add('       '''' AS DES_EMAIL_VEND,   ');
       SQL.Add('       '''' AS SENHA_COTACAO,   ');
       SQL.Add('       -1 AS TIPO_PRODUTOR,   ');
       SQL.Add('       '''' AS NUM_CELULAR   ');
       SQL.Add('   FROM   ');
       SQL.Add('       FORNECEDOR   ');
       SQL.Add('   WHERE FORNECEDOR.FOR_CODIGO <> 0   ');

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

procedure TFrmSmAnaMara.GerarGrupo;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       CASE WHEN PRODUTOS.DEP_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.DEP_CODIGO, 999) END AS COD_SECAO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.GRU_CODIGO = 0 THEN 999 ELSE COALESCE(PRODUTOS.GRU_CODIGO, 999) END AS COD_GRUPO,   ');
     SQL.Add('       COALESCE(GRU_PRODUTOS.GRU_DESCRICAO, ''A DEFINIR'') AS DES_GRUPO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN GRU_PRODUTOS ON GRU_PRODUTOS.GRU_CODIGO = PRODUTOS.GRU_CODIGO   ');

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

procedure TFrmSmAnaMara.GerarInfoNutricionais;
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

procedure TFrmSmAnaMara.GerarNCM;
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
       SQL.Add('      ');
       //SQL.Add('       CASE   ');
       //SQL.Add('           WHEN CAST(NBM_PRODUTOS.NBM_DESCRICAO AS VARCHAR) = '''' THEN ''A DEFINIR''   ');
       //SQL.Add('           WHEN NBM_PRODUTOS.NBM = ''85371990'' OR NBM_PRODUTOS.NBM = ''22029005'' THEN ''A DEFINIR''   ');
       //SQL.Add('           UPPER(COALESCE(CAST(NBM_PRODUTOS.NBM_DESCRICAO AS VARCHAR), ''A DEFINIR''))    ');
       SQL.Add('        ''A DEFINIR'' DES_NCM,   ');
       SQL.Add('          ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CLASFISCAL = '''' THEN ''99999999''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CLASFISCAL = ''00'' THEN ''99999999''   ');
       SQL.Add('           ELSE COALESCE(PRODUTOS.PRO_CLASFISCAL, ''99999999'')    ');
       SQL.Add('       END AS NUM_NCM,   ');
       SQL.Add('      ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA IS NULL AND PRODUTOS.PRO_CST_COFINS IS NULL THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = '''' AND PRODUTOS.PRO_CST_COFINS = '''' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''50'' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''04'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''05'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''73'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''53'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''03'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''74'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''75'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN ''S''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN ''N''   ');
       SQL.Add('           ELSE ''N''   ');
       SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
       SQL.Add('      ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA IS NULL AND PRODUTOS.PRO_CST_COFINS IS NULL THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = '''' AND PRODUTOS.PRO_CST_COFINS = '''' THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''50'' THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''04'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''05'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN 2   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''73'' THEN 0   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1    ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''53'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN 1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN 1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN 0   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''03'' THEN 0   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 0   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''74'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''75'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN 2   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
       SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN -1   ');
       SQL.Add('           ELSE -1   ');
       SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
       SQL.Add('      ');
       SQL.Add('       COALESCE(PRODUTOS.NATR_CODIGO, 999) AS COD_TAB_SPED,   ');
       SQL.Add('       CASE WHEN PRODUTOS.PRO_CEST = '''' THEN ''9999999'' ELSE COALESCE(PRODUTOS.PRO_CEST, ''9999999'') END AS NUM_CEST,   ');
       SQL.Add('       ''SP'' AS DES_SIGLA,   ');
       SQL.Add('      ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 1 THEN 13   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 2 THEN 1   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 4 THEN 2   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 5 THEN 3   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 6 THEN 4   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 7 THEN 5   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 8 THEN 8   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 9 THEN 6   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 10 THEN 7   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 11 THEN 27   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 12 THEN 35   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 13 THEN 35   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 14 THEN 20   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 15 THEN 39   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 16 THEN 39   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 17 THEN 35   ');
       SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 18 THEN 40   ');
       SQL.Add('           ELSE 1   ');
       SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
       SQL.Add('          ');
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
       SQL.Add('       END AS COD_TRIB_SAIDA,   ');
       SQL.Add('      ');
       SQL.Add('       COALESCE(PRODUTOS.PRO_IVAST, 0) AS PER_IVA,   ');
       SQL.Add('       0 AS PER_FCP_ST   ');
       SQL.Add('   FROM   ');
       SQL.Add('       PRODUTOS   ');
       SQL.Add('   LEFT JOIN NBM_PRODUTOS ON NBM_PRODUTOS.NBM = PRODUTOS.PRO_CLASFISCAL   ');
       SQL.Add('   ORDER BY   ');
       SQL.Add('       NUM_NCM,   ');
       SQL.Add('       DES_NCM,   ');
       SQL.Add('       FLG_NAO_PIS_COFINS,   ');
       SQL.Add('       TIPO_NAO_PIS_COFINS,   ');
       SQL.Add('       COD_TRIB_SAIDA,   ');
       SQL.Add('       COD_TRIB_ENTRADA,   ');
       SQL.Add('       PER_IVA,   ');
       SQL.Add('       PER_FCP_ST,   ');
       SQL.Add('       NUM_CEST   ');



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

procedure TFrmSmAnaMara.GerarNCMUF;
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
     SQL.Add('      ');
     //SQL.Add('       CASE   ');
     //SQL.Add('           WHEN CAST(NBM_PRODUTOS.NBM_DESCRICAO AS VARCHAR) = '''' THEN ''A DEFINIR''   ');
     //SQL.Add('           WHEN NBM_PRODUTOS.NBM = ''85371990'' OR NBM_PRODUTOS.NBM = ''22029005'' THEN ''A DEFINIR''   ');
     //SQL.Add('           ELSE UPPER(COALESCE(CAST(NBM_PRODUTOS.NBM_DESCRICAO AS VARCHAR), ''A DEFINIR''))    ');
     SQL.Add('       ''A DEFINIR'' AS DES_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CLASFISCAL = '''' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CLASFISCAL = ''00'' THEN ''99999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.PRO_CLASFISCAL, ''99999999'')    ');
     SQL.Add('       END AS NUM_NCM,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA IS NULL AND PRODUTOS.PRO_CST_COFINS IS NULL THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = '''' AND PRODUTOS.PRO_CST_COFINS = '''' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''50'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''04'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''05'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''73'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''53'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''03'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''74'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''75'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA IS NULL AND PRODUTOS.PRO_CST_COFINS IS NULL THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = '''' AND PRODUTOS.PRO_CST_COFINS = '''' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''01'' AND PRODUTOS.PRO_CST_COFINS = ''50'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''04'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''05'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''06'' AND PRODUTOS.PRO_CST_COFINS = ''73'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1    ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''50'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''53'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''60'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''70'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''03'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''04'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''73'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''74'' AND PRODUTOS.PRO_CST_COFINS = ''06'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''75'' AND PRODUTOS.PRO_CST_COFINS = ''05'' THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CST_COFINS_ENTRADA = ''98'' AND PRODUTOS.PRO_CST_COFINS = ''49'' THEN -1   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PRODUTOS.NATR_CODIGO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       CASE WHEN PRODUTOS.PRO_CEST = '''' THEN ''9999999'' ELSE COALESCE(PRODUTOS.PRO_CEST, ''9999999'') END AS NUM_CEST,   ');
     SQL.Add('       ''SP'' AS DES_SIGLA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 1 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 2 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 4 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 5 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 6 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 7 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 8 THEN 8   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 9 THEN 6   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 10 THEN 7   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 11 THEN 27   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 12 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 13 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 14 THEN 20   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 15 THEN 39   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 16 THEN 39   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 17 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 18 THEN 40   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('          ');
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
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PRODUTOS.PRO_IVAST, 0) AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN NBM_PRODUTOS ON NBM_PRODUTOS.NBM = PRODUTOS.PRO_CLASFISCAL   ');
     SQL.Add('   ORDER BY   ');
     SQL.Add('       NUM_NCM,   ');
     SQL.Add('       DES_NCM,   ');
     SQL.Add('       FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       COD_TRIB_SAIDA,   ');
     SQL.Add('       COD_TRIB_ENTRADA,   ');
     SQL.Add('       PER_IVA,   ');
     SQL.Add('       PER_FCP_ST,   ');
     SQL.Add('       NUM_CEST   ');

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

procedure TFrmSmAnaMara.GerarNFClientes;
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

procedure TFrmSmAnaMara.GerarNFFornec;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CAPA.FOR_CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       CAST(CAPA.ENT_NNOTA AS BIGINT) AS NUM_NF_FORN,   ');
     SQL.Add('       CASE WHEN CAPA.ENT_SERIE = '''' THEN ''1'' ELSE CAPA.ENT_SERIE END AS NUM_SERIE_NF,   ');
     SQL.Add('       CAPA.ENT_SUBSERIE AS NUM_SUBSERIE_NF,   ');
     SQL.Add('       ''1403'' AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       CAPA.TP_NOTA AS DES_ESPECIE,   ');
     SQL.Add('       CAPA.ENT_VALOR AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.ENT_DATA_EMISSAO AS DTA_EMISSAO,   ');
     SQL.Add('       CAPA.ENT_DATA AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS VAL_TOTAL_IPI,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       CAPA.ENT_FRETE AS VAL_FRETE,   ');
     SQL.Add('       CAPA.ENT_ACRESCIMO AS VAL_ACRESCIMO,   ');
     SQL.Add('       CAPA.ENT_DESCONTO AS VAL_DESCONTO,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.FOR_CGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       CAPA.ENT_BASECALCULO AS VAL_TOTAL_BC,   ');
     SQL.Add('       CAPA.ENT_ICMS AS VAL_TOTAL_ICMS,   ');
     SQL.Add('       0 AS VAL_BC_SUBST,   ');
     SQL.Add('       0 AS VAL_ICMS_SUBST,   ');
     SQL.Add('       0 AS VAL_FUNRURAL,   ');
     SQL.Add('       1 AS COD_PERFIL,   ');
     SQL.Add('       0 AS VAL_DESP_ACESS,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('       COALESCE(CAPA.ENT_OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       CAPA.ENT_CHAVE_NFE AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTRADA_ESTQ AS CAPA   ');
     SQL.Add('   LEFT JOIN FORNECEDOR ON FORNECEDOR.FOR_CODIGO =  CAPA.FOR_CODIGO   ');
     SQL.Add('WHERE');
     SQL.Add(' CAST(CAPA.ENT_DATA_EMISSAO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('AND');
     SQL.Add(' CAST(CAPA.ENT_DATA_EMISSAO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add(' ORDER BY CAPA.ENT_NNOTA, CAPA.FOR_CODIGO, CAPA.ENT_SERIE ');

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

procedure TFrmSmAnaMara.GerarNFitensClientes;
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

procedure TFrmSmAnaMara.GerarNFitensFornec;
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
     SQL.Add('       CAPA.FOR_CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       CAST(CAPA.ENT_NNOTA AS BIGINT) AS NUM_NF_FORN,   ');
     SQL.Add('       CASE WHEN CAPA.ENT_SERIE = '''' THEN ''1'' ELSE CAPA.ENT_SERIE END AS NUM_SERIE_NF,   ');
     SQL.Add('       ITENS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 1 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 2 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 4 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 5 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 6 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 7 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 8 THEN 8   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 9 THEN 6   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 10 THEN 7   ');
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
     SQL.Add('          ');
     SQL.Add('       COALESCE(ITENS.ENT_EMBALAGEM, 1) AS QTD_EMBALAGEM,   ');
     SQL.Add('       ITENS.ENT_QTDE_VOL AS QTD_ENTRADA,   ');
     SQL.Add('       CASE WHEN PRODUTOS.PRO_UNIDADE = ''KG'' THEN ''KG'' ELSE ''UN'' END AS DES_UNIDADE,   ');
     SQL.Add('       ITENS.ENT_CUSTO * ITENS.ENT_EMBALAGEM AS VAL_TABELA,   ');
     SQL.Add('       ITENS.ENT_DESCONTO AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       ITENS.ENT_ACRESCIMO AS VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       ITENS.ENT_IPI / ITENS.ENT_QTDE_VOL AS VAL_IPI_ITEM,   ');
     SQL.Add('       0 AS VAL_SUBST_ITEM,   ');
     SQL.Add('       0 AS VAL_FRETE_ITEM,   ');
     SQL.Add('       ITENS.ENT_ICMS AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       ITENS.ENT_TOTAL AS VAL_TABELA_LIQ,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.FOR_CGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       ITENS.ENT_BASEICMS AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       ITENS.ENT_ICMS AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('       COALESCE(ITENS.NAT_CODIGO, ''1102'') AS CFOP,   ');
     SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
     SQL.Add('       ITENS.ENT_BASEST AS VAL_TOT_BC_ST,   ');
     SQL.Add('       COALESCE(ITENS.ENT_SUB, 0) AS VAL_TOT_ST,   ');
     SQL.Add('       ITENS.ENT_ITEM AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ITENS.ENT_CLASFISCAL = '''' THEN ''99999999''   ');
     SQL.Add('           ELSE COALESCE(ITENS.ENT_CLASFISCAL, ''99999999'')    ');
     SQL.Add('       END AS NUM_NCM,   ');
     SQL.Add('      ');
     SQL.Add('       ITENS.PRO_FORCODIGO AS DES_REFERENCIA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTRADA_ITEM AS ITENS   ');
     SQL.Add('   LEFT JOIN PRODUTOS ON PRODUTOS.PRO_CODIGO = ITENS.PRO_CODIGO   ');
     SQL.Add('   LEFT JOIN ENTRADA_ESTQ AS CAPA ON CAPA.ENT_REGISTRO = ITENS.ENT_REGISTRO   ');
     SQL.Add('   LEFT JOIN FORNECEDOR ON FORNECEDOR.FOR_CODIGO =  CAPA.FOR_CODIGO   ');
     SQL.Add('WHERE');
     SQL.Add(' CAST(CAPA.ENT_DATA_EMISSAO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('AND');
     SQL.Add(' CAST(CAPA.ENT_DATA_EMISSAO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add(' ORDER BY CAPA.ENT_NNOTA, CAPA.FOR_CODIGO, CAPA.ENT_SERIE ');



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

procedure TFrmSmAnaMara.GerarProdForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTOS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTO_FOR.FOR_CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       COALESCE(PRODUTO_FOR.PRO_FORCODIGO, '''') AS DES_REFERENCIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.FOR_CGC, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_UNIDADE IS NULL THEN ''UN''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_UNIDADE = '''' THEN ''UN''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_UNIDADE = ''%AMB'' THEN ''EB''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_UNIDADE = ''1'' THEN ''UN''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_UNIDADE = ''CX'' THEN ''CX''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_UNIDADE = ''FD'' THEN ''FD''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_UNIDADE = ''KG'' THEN ''KG''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_UNIDADE = ''PC'' THEN ''PC''   ');
     SQL.Add('           WHEN RTRIM(PRODUTOS.PRO_UNIDADE) = ''UN'' THEN ''UN''   ');
     SQL.Add('           WHEN RTRIM(PRODUTOS.PRO_UNIDADE) = ''UND'' THEN ''UN''   ');
     SQL.Add('           WHEN RTRIM(PRODUTOS.PRO_UNIDADE) = ''UNI'' THEN ''UN''   ');
     SQL.Add('           WHEN RTRIM(PRODUTOS.PRO_UNIDADE) = ''UNID'' THEN ''UN''   ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PRODUTO_FOR.PRO_FOR_EMBALAGEM, 1) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       1 AS QTD_TROCA,   ');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN PRODUTO_FOR ON PRODUTO_FOR.PRO_CODIGO = PRODUTOS.PRO_CODIGO ');
     //SQL.Add('   LEFT JOIN PRODUTO_FOR ON PRODUTO_FOR.FOR_CODIGO = PRODUTOS.FOR_CODIGO AND PRODUTO_FOR.PRO_CODIGO = PRODUTOS.PRO_CODIGO   ');
     SQL.Add('   LEFT JOIN FORNECEDOR ON FORNECEDOR.FOR_CODIGO = PRODUTOS.FOR_CODIGO   ');
     SQL.Add('   WHERE FORNECEDOR.FOR_CODIGO <> 0 ');
     SQL.Add('   AND PRODUTO_FOR.FOR_CODIGO IS NOT NULL ');
     //SQL.Add('   AND PRODUTOS.PRO_BARRA IS NOT NULL ');



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

procedure TFrmSmAnaMara.GerarProdLoja;
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
     SQL.Add('       PRODUTOS.PRO_CODIGO AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTOS.PRO_CUSTOREAL AS VAL_CUSTO_REP,   ');
     SQL.Add('       PRODUTOS.PRO_VENDA AS VAL_VENDA,   ');
     SQL.Add('       0 AS VAL_OFERTA,   ');
     SQL.Add('       COALESCE(PRODUTOS.PRO_ESTOQUE, 1) AS QTD_EST_VDA,   ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('          ');
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
     SQL.Add('       COALESCE(PRODUTOS.PRO_MARGEM, 0) AS VAL_MARGEM,   ');
     SQL.Add('       1 AS QTD_ETIQUETA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 1 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 2 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 4 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 5 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 6 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 7 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 8 THEN 8   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 9 THEN 6   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 10 THEN 7   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 11 THEN 27   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 12 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 13 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 14 THEN 20   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 15 THEN 39   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 16 THEN 39   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 17 THEN 35   ');
     SQL.Add('           WHEN PRODUTOS.TRI_ENTRADA = 18 THEN 40   ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_STATUS = ''I'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_INATIVO,   ');
     SQL.Add('          ');
     SQL.Add('       PRODUTOS.PRO_CODIGO AS COD_PRODUTO_ANT,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CLASFISCAL = '''' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.PRO_CLASFISCAL = ''00'' THEN ''99999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.PRO_CLASFISCAL, ''99999999'')    ');
     SQL.Add('       END AS NUM_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS TIPO_NCM,   ');
     SQL.Add('       0 AS VAL_VENDA_2,   ');
     SQL.Add('       '''' AS DTA_VALIDA_OFERTA,   ');
     SQL.Add('       COALESCE(PRODUTOS.PRO_MINIMO, 0) AS QTD_EST_MINIMO,   ');
     SQL.Add('       NULL AS COD_VASILHAME,   ');
     SQL.Add('       ''N'' AS FORA_LINHA,   ');
     SQL.Add('       0 AS QTD_PRECO_DIF,   ');
     SQL.Add('       0 AS VAL_FORCA_VDA,   ');
     SQL.Add('       CASE WHEN PRODUTOS.PRO_CEST = '''' THEN ''9999999'' ELSE COALESCE(PRODUTOS.PRO_CEST, ''9999999'') END AS NUM_CEST,   ');
     SQL.Add('       COALESCE(PRODUTOS.PRO_IVAST, 0) AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST,   ');
     SQL.Add('       COALESCE(PRODUTOS.PRO_FIDELIDADE, 0) AS PER_FIDELIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     //SQL.Add('   WHERE PRODUTOS.PRO_BARRA <> 0 ');

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

//      if( Layout.FieldByName('DTA_VALIDA_OFERTA').AsString <> '' ) then
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

procedure TFrmSmAnaMara.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('      PRODUTOS.PRO_CODIGO AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('   	  RTRIM(PRODUTOS.PRO_DESCRICAO) AS DES_PRODUTO_SIMILAR,   ');
     SQL.Add('   	  0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('   	  PRODUTOS   ');
     SQL.Add('   WHERE PRODUTOS.PRO_CODIGO IN (   ');
     SQL.Add('   	  SELECT DISTINCT   ');
     SQL.Add('   		    PRO_PAI   ');
     SQL.Add('   	  FROM   ');
     SQL.Add('   		    PRODUTOS   ');
     SQL.Add('   	  WHERE PRO_PAI IS NOT NULL   ');
     SQL.Add('   	  AND PRO_PAI <> 0   ');
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
