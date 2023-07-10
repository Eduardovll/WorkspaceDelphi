unit UFrmSmZeuGrupoSuperMais;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrmModelo, Data.DBXOracle, Data.DB,
  Data.SqlExpr, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DBXFirebird, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.Provider, Datasnap.DBClient, //dxGDIPlusClasses,
  Math;

type
  TFrmSmZeuGrupoSuperMais = class(TFrmModeloSis)
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
  FrmSmZeuGrupoSuperMais: TFrmSmZeuGrupoSuperMais;
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


procedure TFrmSmZeuGrupoSuperMais.GerarProducao;
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

procedure TFrmSmZeuGrupoSuperMais.GerarProduto;
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


     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 AND BALANCA.ID IS NOT NULL THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
     SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       TRIM(LEADING ''0'' FROM COD_EAN.EAN) AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       CASE WHEN PRODUTOS.REF = '''' THEN ''A DEFINIR'' ELSE PRODUTOS.REF END AS DES_REDUZIDA,   ');
     SQL.Add('       CASE WHEN PRODUTOS.DESCRICAO = '''' THEN ''A DEFINIR'' ELSE PRODUTOS.DESCRICAO END AS DES_PRODUTO,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 17 THEN ''UN''   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 18 THEN ''KG''   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 33001 THEN ''PC''   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 34001 THEN ''FD''   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 21001 THEN ''LT''   ');
     SQL.Add('           ELSE ''UN''   ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('          ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 17 THEN ''UN''   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 18 THEN ''KG''   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 33001 THEN ''PC''   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 34001 THEN ''FD''   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 21001 THEN ''LT''   ');
     SQL.Add('           ELSE ''UN''   ');
     SQL.Add('       END AS DES_UNIDADE_VENDA,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       0 AS VAL_IPI,   ');
     SQL.Add('       COALESCE(PRODUTOS.SECAO, 999) AS COD_SECAO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.GRUPO LIKE ''%-%'' THEN 999 ELSE COALESCE(PRODUTOS.GRUPO, 999) END AS COD_GRUPO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.SUBGRUPO LIKE ''%-%'' THEN 999 ELSE COALESCE(PRODUTOS.SUBGRUPO, 999) END AS COD_SUB_GRUPO,   ');
     //SQL.Add('       COALESCE(PROD_SIMILAR.IDEQUIV, 0) AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('       COALESCE(PROD_SIMILAR.CODIGO, 0) AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.UNIDADE = 18 AND BALANCA.ID IS NOT NULL THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           --WHEN PRODUTOS.ISENTOIF = 0 THEN '''' --TRIBUTADO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 1 THEN ''S'' --ALIQ. ZERO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 2 THEN ''S'' --MONOFASICO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 3 THEN ''S'' --SUBST.   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 4 THEN ''S'' --ISENTO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 5 THEN ''S'' --SEM INCIDENCIA   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 6 THEN ''S'' --SUSPENSO   ');
//     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN BALANCA.ID IS NOT NULL THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           --WHEN PRODUTOS.ISENTOIF = 0 THEN  --TRIBUTADO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 1 THEN 0 --ALIQ. ZERO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 2 THEN 1 --MONOFASICO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 3 THEN 2 --SUBST.   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 4 THEN 0 --ISENTO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 5 THEN 0 --SEM INCIDENCIA   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 6 THEN 4 --SUSPENSO   ');
//     SQL.Add('           ELSE -1   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,   ');
     //SQL.Add('       COALESCE(COD_SPED.CODIGO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.BEBIDA_ALCOOLICA = 0 THEN ''N''   ');
     SQL.Add('           ELSE ''S''    ');
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
     SQL.Add('       0 AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       PRODUTOS.DATACADASTRO AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       PRODUTOS.DESCRICAO AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN(   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           PRODUTO,   ');
     SQL.Add('           EAN   ');
     SQL.Add('       FROM   ');
     SQL.Add('           EANS   ');
     SQL.Add('       WHERE ATIVO <> 0     ');
     SQL.Add('   ) AS COD_EAN   ');
     SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
     SQL.Add('   LEFT JOIN PRODNTPISCOFINS AS COD_SPED ON COD_SPED.ID = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           P_SIMILAR.CODIGO,   ');
     SQL.Add('           P_SIMILAR.ID   ');
     SQL.Add('       FROM   ');
     SQL.Add('           SEMELHANCAS AS P_SIMILAR   ');
     SQL.Add('       LEFT JOIN SEMELHANTES AS P_PROD_SIMILAR ON P_PROD_SIMILAR.ID = P_SIMILAR.ID    ');
     SQL.Add('   ) AS PROD_SIMILAR   ');
     SQL.Add('   ON PROD_SIMILAR.ID = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           ID   ');
     SQL.Add('       FROM   ');
     SQL.Add('           EC_EXPT_PRODUTO   ');
     SQL.Add('       WHERE BALANCA_CODIGO IS NOT NULL   ');
     SQL.Add('   ) AS BALANCA   ');
     SQL.Add('   ON BALANCA.ID = PRODUTOS.ID   ');
     //SQL.Add('   WHERE PRODUTOS.ATIVO = 1   ');








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

      if QryPrincipal.FieldByName('DTA_ENTRADA').AsString <> '' then
        Layout.FieldByName('DTA_ENTRADA').AsDateTime := FieldByName('DTA_ENTRADA').AsDateTime;



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

procedure TFrmSmZeuGrupoSuperMais.GerarReceitas;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    //aaa

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

        //aaaa

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmZeuGrupoSuperMais.GerarScriptAmarrarCEST;
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

procedure TFrmSmZeuGrupoSuperMais.GerarScriptCEST;
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

procedure TFrmSmZeuGrupoSuperMais.GerarSecao;
var
   TotalCount : integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT     ');
       SQL.Add('      COD_SECAO,   ');
       SQL.Add('      DES_SECAO,   ');
       SQL.Add('      VAL_META   ');
       SQL.Add('      ');
       SQL.Add('   FROM SECAO   ');

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

procedure TFrmSmZeuGrupoSuperMais.GerarSubGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(PRODUTOS.SECAO, 999) AS COD_SECAO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.GRUPO LIKE ''%-%'' THEN 999 ELSE COALESCE(PRODUTOS.GRUPO, 999) END AS COD_GRUPO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.SUBGRUPO LIKE ''%-%'' THEN 999 ELSE COALESCE(PRODUTOS.SUBGRUPO, 999) END AS COD_SUB_GRUPO,   ');
     SQL.Add('       COALESCE(OBJETOS.DESCRICAO, ''A DEFINIR'') AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 AS VAL_META,   ');
     SQL.Add('       0 AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN OBJETOS ON OBJETOS.ID = PRODUTOS.SUBGRUPO   ');



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

procedure TFrmSmZeuGrupoSuperMais.GerarTransportadora;
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

procedure TFrmSmZeuGrupoSuperMais.GerarValorVenda;
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
     //SQL.Add('       CASE   ');
     //SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
     //SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
     //SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTOS.ID AS COD_PRODUTO_ANT,   ');
     SQL.Add('       VALORESPROD.PRECO AS VAL_VENDA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN VALORESPROD ON VALORESPROD.IDPROD = PRODUTOS.ID   ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           PRODUTO,   ');
//     SQL.Add('           EAN   ');
//     SQL.Add('       FROM   ');
//     SQL.Add('           EANS   ');
//     SQL.Add('       --WHERE PRINCIPAL = 0 ');
//     SQL.Add('   ) AS COD_EAN   ');
//     SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
     SQL.Add('   WHERE VALORESPROD.PRECO > 0 ');
     SQL.Add('   AND VALORESPROD.EMPRESA = 1 ');
  
    end
    else
    if CbxLoja.Text = '2' then
    begin
       SQL.Add('   SELECT DISTINCT   ');
//       SQL.Add('       CASE   ');
//       SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
//       SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
//       SQL.Add('       END AS COD_PRODUTO,   ');
       SQL.Add('       PRODUTOS.ID AS COD_PRODUTO_ANT,   ');
       SQL.Add('       VALORESPROD.PRECO AS VAL_VENDA   ');
       SQL.Add('   FROM   ');
       SQL.Add('       PRODUTOS   ');
       SQL.Add('   LEFT JOIN VALORESPROD ON VALORESPROD.IDPROD = PRODUTOS.ID   ');
//       SQL.Add('   LEFT JOIN(   ');
//       SQL.Add('       SELECT DISTINCT   ');
//       SQL.Add('           PRODUTO,   ');
//       SQL.Add('           EAN   ');
//       SQL.Add('       FROM   ');
//       SQL.Add('           EANS   ');
//       SQL.Add('       --WHERE PRINCIPAL = 0 ');
//       SQL.Add('   ) AS COD_EAN   ');
//       SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
       SQL.Add('   WHERE VALORESPROD.PRECO > 0 ');
       SQL.Add('   AND VALORESPROD.EMPRESA = 2 ');
    end
    else
    if CbxLoja.Text = 'OUT-L1' then
    begin
       SQL.Add('   SELECT   ');
       SQL.Add('     PRODUTOS.ID AS COD_PRODUTO_ANT,   ');
       SQL.Add('     PRECOS.QTDE AS QTD_PRECO_DIF,   ');
       SQL.Add('     PRECOS.VALOR1 AS VAL_VENDA_ATACADO   ');
       SQL.Add('   FROM      ');
       SQL.Add('     PRODUTOS   ');
       SQL.Add('   INNER JOIN (   ');
       SQL.Add('     SELECT DISTINCT   ');
       SQL.Add('       EC_EXPT_PROD_PRECOXQTDE.ID,   ');
       SQL.Add('       EC_EXPT_PROD_PRECOXQTDE.IDPROD,   ');
       SQL.Add('       QTDE,   ');
       SQL.Add('       VALOR1   ');
       SQL.Add('     FROM      ');
       SQL.Add('       EC_EXPT_PROD_PRECOXQTDE   ');
       SQL.Add('     INNER JOIN (   ');
       SQL.Add('       SELECT    ');
       SQL.Add('         MAX(ID) ID,   ');
       SQL.Add('         IDPROD   ');
       SQL.Add('       FROM EC_EXPT_PROD_PRECOXQTDE   ');
       SQL.Add('       WHERE EMPRESA = 1   ');
       SQL.Add('       GROUP BY IDPROD   ');
       SQL.Add('     ) AS SUB   ');
       SQL.Add('     ON EC_EXPT_PROD_PRECOXQTDE.ID = SUB.ID   ');
       SQL.Add('     WHERE EMPRESA = 1   ');
       SQL.Add('   ) PRECOS   ');
       SQL.Add('   ON PRODUTOS.ID = PRECOS.IDPROD   ');

    end
    else
    if CbxLoja.Text = 'OUT-L2' then
    begin
       SQL.Add('   SELECT   ');
       SQL.Add('     PRODUTOS.ID AS COD_PRODUTO_ANT,   ');
       SQL.Add('     PRECOS.QTDE AS QTD_PRECO_DIF,   ');
       SQL.Add('     PRECOS.VALOR1 AS VAL_VENDA_ATACADO   ');
       SQL.Add('   FROM      ');
       SQL.Add('     PRODUTOS   ');
       SQL.Add('   INNER JOIN (   ');
       SQL.Add('     SELECT DISTINCT   ');
       SQL.Add('       EC_EXPT_PROD_PRECOXQTDE.ID,   ');
       SQL.Add('       EC_EXPT_PROD_PRECOXQTDE.IDPROD,   ');
       SQL.Add('       QTDE,   ');
       SQL.Add('       VALOR1   ');
       SQL.Add('     FROM      ');
       SQL.Add('       EC_EXPT_PROD_PRECOXQTDE   ');
       SQL.Add('     INNER JOIN (   ');
       SQL.Add('       SELECT    ');
       SQL.Add('         MAX(ID) ID,   ');
       SQL.Add('         IDPROD   ');
       SQL.Add('       FROM EC_EXPT_PROD_PRECOXQTDE   ');
       SQL.Add('       WHERE EMPRESA = 2   ');
       SQL.Add('       GROUP BY IDPROD   ');
       SQL.Add('     ) AS SUB   ');
       SQL.Add('     ON EC_EXPT_PROD_PRECOXQTDE.ID = SUB.ID   ');
       SQL.Add('     WHERE EMPRESA = 2   ');
       SQL.Add('   ) PRECOS   ');
       SQL.Add('   ON PRODUTOS.ID = PRECOS.IDPROD   ');
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

//        COD_PRODUTO := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);
          COD_PRODUTO := QryPrincipal.FieldByName('COD_PRODUTO_ANT').AsString;
          if CbxLoja.Text = '1' then
          begin
            Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_VENDA = '''+QryPrincipal.FieldByName('VAL_VENDA').AsString+''' WHERE COD_PRODUTO_ANT = '+COD_PRODUTO+' AND COD_LOJA = 1 ; ');
          end
          else if CbxLoja.Text = '2' then
          begin
            Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_VENDA = '''+QryPrincipal.FieldByName('VAL_VENDA').AsString+''' WHERE COD_PRODUTO_ANT = '+COD_PRODUTO+' AND COD_LOJA = 2 ; ');
          end
          else if CbxLoja.Text = 'OUT-L1' then
          begin
             Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET QTD_PRECO_DIF = '''+QryPrincipal.FieldByName('QTD_PRECO_DIF').AsString+''', VAL_VENDA_ATACADO = '''+QryPrincipal.FieldByName('VAL_VENDA_ATACADO').AsString+''' WHERE COD_PRODUTO_ANT = '+COD_PRODUTO+' AND COD_LOJA = 1 ; ');
          end
          else if CbxLoja.Text = 'OUT-L2' then
          begin
             Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET QTD_PRECO_DIF = '''+QryPrincipal.FieldByName('QTD_PRECO_DIF').AsString+''', VAL_VENDA_ATACADO = '''+QryPrincipal.FieldByName('VAL_VENDA_ATACADO').AsString+''' WHERE COD_PRODUTO_ANT = '+COD_PRODUTO+' AND COD_LOJA = 2 ; ');
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

procedure TFrmSmZeuGrupoSuperMais.GerarVenda;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT     ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN PRODUTOS.COD_PRODUTO LIKE ''0%'' THEN CAST(PRODUTOS.COD_PRODUTO AS INT)         ');
     SQL.Add('           ELSE PRODUTOS.COD_PRODUTO         ');
     SQL.Add('       END AS COD_PRODUTO,         ');
     SQL.Add('         ');
     SQL.Add('       1 AS COD_LOJA,      ');
     SQL.Add('       0 AS IND_TIPO,      ');
     SQL.Add('       1 AS NUM_PDV,      ');
     SQL.Add('       VENDAS_ITENS.QTD AS QTD_TOTAL_PRODUTO,      ');
     SQL.Add('       (VENDAS_ITENS.VR_UNITARIO * VENDAS_ITENS.QTD) - VENDAS_ITENS.VR_DESCONTO_VENDA + VENDAS_ITENS.VR_ACRESCIMO_VENDA AS VAL_TOTAL_PRODUTO,      ');
     //SQL.Add('       (VENDAS_ITENS.VR_UNITARIO * VENDAS_ITENS.QTD) AS VAL_TOTAL_PRODUTO,      ');
     SQL.Add('       VENDAS_ITENS.VR_UNITARIO - VENDAS_ITENS.VR_DESCONTO_VENDA + VENDAS_ITENS.VR_ACRESCIMO_VENDA AS VAL_PRECO_VENDA,      ');
     //SQL.Add('       VENDAS_ITENS.VR_UNITARIO AS VAL_PRECO_VENDA,      ');
     SQL.Add('       VENDAS_ITENS.PRECO_CUSTO AS VAL_CUSTO_REP,      ');
     SQL.Add('       VENDAS.DATA AS DTA_SAIDA,      ');
     SQL.Add('       REPLACE(SUBSTRING(VENDAS.DATA FROM 6 FOR 2), ''-'', '''') || REPLACE(SUBSTRING(VENDAS.DATA FROM 1 FOR 5), ''-'', '''') AS DTA_MENSAL,      ');
     SQL.Add('       VENDAS_ITENS.COD_ITEM AS NUM_IDENT,      ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%B%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%E%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%I%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%L%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%M%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%R%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%T%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%N%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%,%'' THEN ''''      ');
     SQL.Add('           WHEN EAN.APELIDO LIKE ''%A%'' THEN REPLACE(EAN.APELIDO, ''A'', '''')      ');
     SQL.Add('           ELSE COALESCE(EAN.APELIDO, '''')      ');
     SQL.Add('       END AS COD_EAN,   ');
     SQL.Add('          ');
     SQL.Add('       SUBSTRING(REPLACE(VENDAS.HORA, '':'', '''') FROM 12 FOR 4) AS DES_HORA,      ');
     SQL.Add('       VENDAS.COD_CLIENTE AS COD_CLIENTE,      ');
     SQL.Add('       1 AS COD_ENTIDADE,      ');
     SQL.Add('       0 AS VAL_BASE_ICMS,      ');
     SQL.Add('       '''' AS DES_SITUACAO_TRIB,      ');
     SQL.Add('       0 AS VAL_ICMS,      ');
     SQL.Add('       VENDAS.COD_VENDA AS NUM_CUPOM_FISCAL,      ');
     SQL.Add('       (VENDAS_ITENS.VR_UNITARIO - VENDAS_ITENS.VR_DESCONTO_VENDA) AS VAL_VENDA_PDV,      ');
     SQL.Add('          ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN PRODUTOS.COD_IMPOSTO = 1 THEN 13         ');
     SQL.Add('           WHEN PRODUTOS.COD_IMPOSTO = 2 THEN 1         ');
     SQL.Add('           WHEN PRODUTOS.COD_IMPOSTO = 3 THEN 4         ');
     SQL.Add('           ELSE 1         ');
     SQL.Add('       END AS COD_TRIBUTACAO,         ');
     SQL.Add('        ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN VENDAS_ITENS.FLAG_CANCELADO = 0 THEN ''N''      ');
     SQL.Add('           ELSE ''S''      ');
     SQL.Add('       END AS FLG_CUPOM_CANCELADO,      ');
     SQL.Add('             ');
     SQL.Add('       CASE     ');
     SQL.Add('           WHEN PRODUTOS.COD_CLASS = '''' THEN ''99999999''    ');
     SQL.Add('           WHEN PRODUTOS.COD_CLASS = ''00000000'' THEN ''99999999''     ');
     SQL.Add('           WHEN PRODUTOS.COD_CLASS = ''0'' THEN ''99999999''     ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.COD_CLASS, ''99999999'')      ');
     SQL.Add('       END AS NUM_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       999 AS COD_TAB_SPED,      ');
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.COD_IMPOSTO = 1 THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.COD_IMPOSTO = 3 THEN ''S''      ');
     SQL.Add('           ELSE ''N''      ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,        ');
     SQL.Add('        ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.COD_IMPOSTO = 1 THEN 1      ');
     SQL.Add('           WHEN PRODUTOS.COD_IMPOSTO = 3 THEN 0      ');
     SQL.Add('           ELSE -1       ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,        ');
     SQL.Add('        ');
     SQL.Add('       ''N'' AS FLG_ONLINE,      ');
     SQL.Add('       ''N'' AS FLG_OFERTA,      ');
     SQL.Add('       0 AS COD_ASSOCIADO      ');
     SQL.Add('   FROM      ');
     SQL.Add('       VENDAS      ');
     SQL.Add('   LEFT JOIN VENDAS_ITENS ON VENDAS_ITENS.COD_VENDA = VENDAS.COD_VENDA      ');
     SQL.Add('   AND VENDAS_ITENS.COD_EMPRESA = VENDAS.COD_EMPRESA      ');
     SQL.Add('   LEFT JOIN PRODUTOS ON PRODUTOS.COD_PRODUTO = VENDAS_ITENS.COD_PRODUTO   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT      ');
     SQL.Add('           COD_PRODUTO,      ');
     SQL.Add('           APELIDO      ');
     SQL.Add('       FROM      ');
     SQL.Add('           PRODUTOS_APELIDOS_PROD      ');
     SQL.Add('       WHERE COD_APELIDO = 2      ');
     SQL.Add('   ) AS EAN      ');
     SQL.Add('   ON EAN.COD_PRODUTO = PRODUTOS.COD_PRODUTO   ');
     SQL.Add('   WHERE PRODUTOS.COD_PRODUTO NOT LIKE ''%BASE TRACTA 0%''      ');
     SQL.Add('   AND VENDAS.COD_EMPRESA = 1      ');
     SQL.Add('   AND VENDAS.DATA >= :INI   ');
     SQL.Add('   AND VENDAS.DATA <= :FIM   ');




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

procedure TFrmSmZeuGrupoSuperMais.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmZeuGrupoSuperMais.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmZeuGrupoSuperMais.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmZeuGrupoSuperMais.BtnGerarClick(Sender: TObject);
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
        AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_VALOR_VENDA.TXT' );
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

procedure TFrmSmZeuGrupoSuperMais.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmZeuGrupoSuperMais.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmZeuGrupoSuperMais.CkbProdLojaClick(Sender: TObject);
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

procedure TFrmSmZeuGrupoSuperMais.EdtCamBancoExit(Sender: TObject);
begin
  inherited;
  CriarFB(EdtCamBanco);
end;

procedure TFrmSmZeuGrupoSuperMais.GeraCustoRep;
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
//       SQL.Add('       CASE   ');
//       SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
//       SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
//       SQL.Add('       END AS COD_PRODUTO,   ');
SQL.Add('       PRODUTOS.ID AS COD_PRODUTO_ANT,   ');
       SQL.Add('       VALORESPROD.CUSTO AS VAL_CUSTO_REP   ');
       SQL.Add('   FROM   ');
       SQL.Add('       PRODUTOS   ');
       SQL.Add('   LEFT JOIN VALORESPROD ON VALORESPROD.IDPROD = PRODUTOS.ID   ');
//       SQL.Add('   LEFT JOIN(   ');
//       SQL.Add('       SELECT DISTINCT   ');
//       SQL.Add('           PRODUTO,   ');
//       SQL.Add('           EAN   ');
//       SQL.Add('       FROM   ');
//       SQL.Add('           EANS   ');
//       SQL.Add('       --WHERE PRINCIPAL = 0 ');
//       SQL.Add('   ) AS COD_EAN   ');
//       SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
       SQL.Add('   WHERE VALORESPROD.CUSTO > 0 ');
       SQL.Add('   AND VALORESPROD.EMPRESA = 1 ');
     end
     else
     begin
       SQL.Add('   SELECT DISTINCT   ');
//       SQL.Add('       CASE   ');
//       SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
//       SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
//       SQL.Add('       END AS COD_PRODUTO,   ');
SQL.Add('       PRODUTOS.ID AS COD_PRODUTO_ANT,   ');
       SQL.Add('       VALORESPROD.CUSTO AS VAL_CUSTO_REP   ');
       SQL.Add('   FROM   ');
       SQL.Add('       PRODUTOS   ');
       SQL.Add('   LEFT JOIN VALORESPROD ON VALORESPROD.IDPROD = PRODUTOS.ID   ');
//       SQL.Add('   LEFT JOIN(   ');
//       SQL.Add('       SELECT DISTINCT   ');
//       SQL.Add('           PRODUTO,   ');
//       SQL.Add('           EAN   ');
//       SQL.Add('       FROM   ');
//       SQL.Add('           EANS   ');
//       SQL.Add('       --WHERE PRINCIPAL = 0 ');
//       SQL.Add('   ) AS COD_EAN   ');
//       SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
       SQL.Add('   WHERE VALORESPROD.CUSTO > 0 ');
       SQL.Add('   AND VALORESPROD.EMPRESA = 2 ');
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

//        COD_PRODUTO := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);
          COD_PRODUTO := QryPrincipal.FieldByName('COD_PRODUTO_ANT').AsString;

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_CUSTO_REP = '''+QryPrincipal.FieldByName('VAL_CUSTO_REP').AsString+''' WHERE COD_PRODUTO_ANT = '''+COD_PRODUTO+''' AND COD_LOJA = '+CbxLoja.Text+' ; ');

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

procedure TFrmSmZeuGrupoSuperMais.GeraEstoqueVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
//     SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
//     SQL.Add('       END AS COD_PRODUTO,   ');
SQL.Add('       PRODUTOS.ID AS COD_PRODUTO_ANT,   ');
     SQL.Add('       COALESCE(EST.QTDE_EST, 1) AS QTD_EST_ATUAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           IDPROD AS ID_PROD_EST,   ');
     SQL.Add('           EMPRESA,   ');
     SQL.Add('           DEPOSITO,   ');
     SQL.Add('           QTDE AS QTDE_EST   ');
     SQL.Add('       FROM   ');
     SQL.Add('           ESTOQUE   ');
     SQL.Add('       WHERE ESTOQUE.EMPRESA = 1   ');
     SQL.Add('       AND ESTOQUE.DEPOSITO = 1   ');
     SQL.Add('   ) AS EST   ');
     SQL.Add('   ON EST.ID_PROD_EST = PRODUTOS.ID   ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           PRODUTO,   ');
//     SQL.Add('           EAN   ');
//     SQL.Add('       FROM   ');
//     SQL.Add('           EANS   ');
//     SQL.Add('       --WHERE PRINCIPAL = 0 ');
//     SQL.Add('   ) AS COD_EAN   ');
//     SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
     SQL.Add('   WHERE EST.QTDE_EST > 0 ');




    Open;
    First;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
        Break;

        Inc(NumLinha);

//        COD_PRODUTO := GerarPLU(QryPrincipal.FieldByName('COD_PRODUTO').AsString);
          COD_PRODUTO := QryPrincipal.FieldByName('COD_PRODUTO_ANT').AsString;

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET QTD_EST_ATUAL = '''+QryPrincipal.FieldByName('QTD_EST_ATUAL').AsString+''' WHERE COD_PRODUTO_ANT = '+COD_PRODUTO+' AND COD_LOJA = '+CbxLoja.Text+' ; ');

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

procedure TFrmSmZeuGrupoSuperMais.GerarCest;
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
     SQL.Add('       0 AS COD_CEST,   ');
//     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
     SQL.Add('       COALESCE(REPLACE(PRODST.COD_CEST, ''.'', ''''), ''9999999'') AS NUM_CEST,   ');
     SQL.Add('       COALESCE(CEST.DESCRICAO, ''A DEFINIR'') AS DES_CEST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODST   ');
     SQL.Add('   LEFT JOIN CEST ON CEST.CEST = PRODST.COD_CEST   ');


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

procedure TFrmSmZeuGrupoSuperMais.GerarCliente;
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
//    SQL.Add('UPDATE AGENTES');
//    SQL.Add('SET CODIGO_CLIENTE = :COD_CLIENTE ');
//    SQL.Add('WHERE COALESCE(REPLACE(REPLACE(REPLACE(CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') = :NUM_CGC ');
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


     SQL.Add('   SELECT DISTINCT      ');
     SQL.Add('       COALESCE(AGENTES.CODIGO_PESSOA, 99999) AS COD_CLIENTE,      ');
     SQL.Add('       CLIENTE.NOME AS DES_CLIENTE,      ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTE.DOC, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,        ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN AGENTES.TIPO = ''J'' AND CHAR_LENGTH(RG_INSC.DOC) > 9 THEN RG_INSC.DOC   ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS NUM_INSC_EST,      ');
     SQL.Add('             ');
     SQL.Add('       COALESCE(SUB_EN.LOGRADOURO, ''A DEFINIR'') AS DES_ENDERECO,   ');
     SQL.Add('       COALESCE(SUB_EN.BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,   ');
     SQL.Add('       CIDADES.CIDADE AS DES_CIDADE,      ');
     SQL.Add('       CIDADES.UF AS DES_SIGLA,      ');
     SQL.Add('       SUB_EN.CEP AS NUM_CEP,   ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN TE_LEFONE.IDTIPOTEL = 36 THEN TE_LEFONE.TEL      ');
     SQL.Add('           ELSE ''''      ');
     SQL.Add('       END AS NUM_FONE,      ');
     SQL.Add('             ');
     SQL.Add('       '''' AS NUM_FAX,      ');
     SQL.Add('       CLIENTE.NOME AS DES_CONTATO,      ');
     SQL.Add('       0 AS FLG_SEXO,      ');
     SQL.Add('       COALESCE(CLIENTES.LIMITE, 0) AS VAL_LIMITE_CRETID,      ');
     SQL.Add('       0 AS VAL_LIMITE_CONV,      ');
     SQL.Add('       0 AS VAL_DEBITO,      ');
     SQL.Add('       COALESCE(CLIENTE.CLIENTE_RENDA, 0) AS VAL_RENDA,      ');
     SQL.Add('       0 AS COD_CONVENIO,      ');
     SQL.Add('       0 AS COD_STATUS_PDV,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN AGENTES.TIPO = ''J'' THEN ''S''      ');
     SQL.Add('           ELSE ''N''      ');
     SQL.Add('       END AS FLG_EMPRESA,      ');
     SQL.Add('             ');
     SQL.Add('       ''N'' AS FLG_CONVENIO,      ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('       CAST(CLIENTES.DATACAD AS DATE) AS DTA_CADASTRO,   ');
     SQL.Add('       COALESCE(SUB_EN.NUMERO, ''S/N'') AS NUM_ENDERECO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(RG_INSC.DOC) <= 9 THEN RG_INSC.DOC   ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS NUM_RG,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS FLG_EST_CIVIL,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN CELULAR.IDTIPOTEL = 38 THEN COALESCE(CELULAR.TEL, '''')      ');
     SQL.Add('           ELSE ''''       ');
     SQL.Add('       END AS NUM_CELULAR,      ');
     SQL.Add('             ');
     SQL.Add('       '''' AS DTA_ALTERACAO,      ');
     SQL.Add('       '''' AS DES_OBSERVACAO,      ');
     SQL.Add('       COALESCE(SUB_EN.COMPLEMENTO, '''') AS DES_COMPLEMENTO,   ');
     SQL.Add('       COALESCE(EMAIL.EMAIL, '''') AS DES_EMAIL,      ');
     SQL.Add('             ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN CLIENTE.FANTASIA = '''' THEN CLIENTE.NOME      ');
     SQL.Add('           ELSE COALESCE(CLIENTE.FANTASIA, CLIENTE.NOME)       ');
     SQL.Add('       END AS DES_FANTASIA,      ');
     SQL.Add('             ');
     SQL.Add('       CLIENTE.NASCIMENTO AS DTA_NASCIMENTO,      ');
     SQL.Add('       '''' AS DES_PAI,      ');
     SQL.Add('       '''' AS DES_MAE,      ');
     SQL.Add('       '''' AS DES_CONJUGE,      ');
     SQL.Add('       '''' AS NUM_CPF_CONJUGE,      ');
     SQL.Add('       0 AS VAL_DEB_CONV,      ');
     SQL.Add('       ''N'' AS INATIVO,      ');
     SQL.Add('       '''' AS DES_MATRICULA,      ');
     SQL.Add('       ''N'' AS NUM_CGC_ASSOCIADO,      ');
     SQL.Add('       ''N'' AS FLG_PROD_RURAL,      ');
     SQL.Add('       0 AS COD_STATUS_PDV_CONV,      ');
     SQL.Add('       ''S'' AS FLG_ENVIA_CODIGO,      ');
     SQL.Add('       '''' AS DTA_NASC_CONJUGE,      ');
     SQL.Add('       0 AS COD_CLASSIF      ');
     SQL.Add('   FROM      ');
     SQL.Add('       VW_EC_EXPT_AG_CLIENTE AS CLIENTE      ');
     SQL.Add('   LEFT JOIN AGENTES ON AGENTES.ID = CLIENTE.IDAGENTE   ');
     SQL.Add('   LEFT JOIN CLIENTES ON CLIENTES.ID = CLIENTE.IDAGENTE   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           CODAG,   ');
     SQL.Add('           DOC   ');
//     SQL.Add('           TIPO   ');
     SQL.Add('       FROM   ');
     SQL.Add('           DOCS   ');
     SQL.Add('       WHERE   ');
     SQL.Add('           TIPO IN (66, 67)   ');
     SQL.Add('   ) AS RG_INSC   ');
     SQL.Add('   ON RG_INSC.CODAG = CLIENTE.IDAGENTE   ');
     SQL.Add('   --LEFT JOIN (      ');
     SQL.Add('   --    SELECT DISTINCT      ');
     SQL.Add('   --ENDERECOS.AGENTE,      ');
     SQL.Add('   --SUB_EN.LOGRADOURO,      ');
     SQL.Add('   --SUB_EN.BAIRRO,      ');
     SQL.Add('   --SUB_EN.CEP,      ');
     SQL.Add('   --SUB_EN.NUMERO,      ');
     SQL.Add('   --SUB_EN.COMPLEMENTO,      ');
     SQL.Add('   --SUB_EN.CIDADE      ');
     SQL.Add('   --    FROM      ');
     SQL.Add('   --ENDERECOS      ');
     SQL.Add('   LEFT JOIN (      ');
     SQL.Add('       SELECT DISTINCT      ');
     SQL.Add('           EN.AGENTE AS AGENTE,      ');
     SQL.Add('           EN.LOGRADOURO AS LOGRADOURO,      ');
     SQL.Add('           EN.BAIRRO AS BAIRRO,      ');
     SQL.Add('           REPLACE(EN.CEP, ''-'', '''') AS CEP,      ');
     SQL.Add('           COALESCE(EN.NUMERO, ''S/N'') AS NUMERO,      ');
     SQL.Add('           EN.COMPLEMENTO AS COMPLEMENTO,      ');
     SQL.Add('           EN.CIDADE      ');
     SQL.Add('       FROM      ');
     SQL.Add('           ENDERECOS AS EN      ');
     SQL.Add('       WHERE (EN.LOGRADOURO IS NOT NULL AND EN.BAIRRO IS NOT NULL AND EN.COMPLEMENTO IS NOT NULL)   ');
     SQL.Add('       AND EN.TIPO = 14001   ');
     SQL.Add('   ) AS SUB_EN      ');
     SQL.Add('   ON SUB_EN.AGENTE = CLIENTE.IDAGENTE   ');
     SQL.Add('   --    WHERE (SUB_EN.LOGRADOURO <> '''' AND SUB_EN.BAIRRO <> '''' AND SUB_EN.COMPLEMENTO <> '''')   ');
     SQL.Add('   --) AS SUB_SUB_EN      ');
     SQL.Add('   --ON CLIENTE.IDAGENTE = SUB_SUB_EN.AGENTE   ');
     SQL.Add('   LEFT JOIN CIDADES ON CIDADES.ID = SUB_EN.CIDADE   ');
     SQL.Add('   LEFT JOIN (      ');
     SQL.Add('       SELECT DISTINCT      ');
     SQL.Add('           IDAGENTE,      ');
     SQL.Add('           IDTIPOTEL,      ');
     SQL.Add('           CASE   ');
     SQL.Add('              WHEN CHAR_LENGTH(TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))) = 10 THEN DDD || TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('              WHEN DDD || TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', '''')) LIKE ''3838%'' THEN TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('              ELSE TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('           END AS TEL   ');
     SQL.Add('       FROM      ');
     SQL.Add('           EC_EXPT_AG_TELEFONE      ');
     SQL.Add('       WHERE TEL <> ''''      ');
     SQL.Add('       AND IDTIPOTEL = 36    ');
     SQL.Add('   ) AS TE_LEFONE      ');
     SQL.Add('   ON CLIENTE.IDAGENTE = TE_LEFONE.IDAGENTE   ');
     SQL.Add('   LEFT JOIN (      ');
     SQL.Add('       SELECT DISTINCT      ');
     SQL.Add('           IDAGENTE,      ');
     SQL.Add('           IDTIPOTEL,      ');
     SQL.Add('           CASE   ');
     SQL.Add('              WHEN CHAR_LENGTH(TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))) = 9 THEN DDD || TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('              WHEN DDD || TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', '''')) LIKE ''3838%'' THEN TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('              ELSE TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('           END AS TEL   ');
     SQL.Add('       FROM      ');
     SQL.Add('           EC_EXPT_AG_TELEFONE      ');
     SQL.Add('       WHERE TEL <> ''''      ');
     SQL.Add('       AND IDTIPOTEL = 38    ');
     SQL.Add('   ) AS CELULAR      ');
     SQL.Add('   ON CLIENTE.IDAGENTE = CELULAR.IDAGENTE      ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT      ');
     SQL.Add('           IDAGENTE,      ');
     SQL.Add('           EMAIL,      ');
     SQL.Add('           PADRAO,      ');
     SQL.Add('           EMPRESA      ');
     SQL.Add('       FROM      ');
     SQL.Add('           EC_EXPT_AG_EMAIL      ');
     SQL.Add('       WHERE      ');
     SQL.Add('           EMPRESA = 1      ');
     SQL.Add('       AND      ');
     SQL.Add('           PADRAO = 1      ');
     SQL.Add('   ) AS EMAIL      ');
     SQL.Add('   ON EMAIL.IDAGENTE = CLIENTE.IDAGENTE   ');






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

procedure TFrmSmZeuGrupoSuperMais.GerarCodigoBarras;
var
 count, NEW_CODPROD, TotalCount, NEW_CODPESSOA : Integer;
 cod_antigo, codbarras : string;
 QryGeraCodigoProduto : TSQLQuery;

begin
  inherited;

  QryGeraCodigoProduto := TSQLQuery.Create(FrmProgresso);
  with QryGeraCodigoProduto do
  begin
    SQLConnection := ScnBanco;
//
//    SQL.Clear;
//    SQL.Add('ALTER TABLE PRODUTOS ');
//    SQL.Add('ADD CODIGO_PRODUTO INT DEFAULT NULL; ');
//
//    try
//      ExecSQL;
//    except
//    end;
//
    if CbxLoja.Text = 'G-BALANCA' then
    begin
      SQL.Clear;
      SQL.Add('UPDATE PRODUTOS ');
      SQL.Add('SET CODIGO_PRODUTO = :COD_PRODUTO  ');
      SQL.Add('WHERE ID = :COD_EAN ');
      //SQL.Add('AND PRODUTOS.ATIVO = 1   ');
//
      try
        ExecSQL;
      except
      end;
    end
    else if CbxLoja.Text = 'G-PRODUTO' then
    begin
      SQL.Clear;
      SQL.Add('UPDATE PRODUTOS ');
      SQL.Add('SET CODIGO_PRODUTO = :COD_PRODUTO  ');
      SQL.Add('WHERE ID = :COD_EAN ');
      //SQL.Add('AND PRODUTOS.ATIVO = 1   ');
//
      try
        ExecSQL;
      except
      end;
    end;



      //INICIO - ABAIXO - CRIADO EXCLUSIVAMENTE PARA CONVERSAO SM ZEU APAGAR AP�S USO [14/07/2022]
      //SQL.Clear;
      //SQL.Add('UPDATE AGENTES');
      //SQL.Add('SET CODIGO_PESSOA = :COD_PRODUTO');
      //SQL.Add('WHERE ID = :COD_EAN');

      //try
        //ExecSQL;
      //except
      //end;
      //FIM - ABAIXO - CRIADO EXCLUSIVAMENTE PARA CONVERSAO SM ZEU APAGAR AP�S USO [14/07/2022]
//
  end;




  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

       //INICIO - ABAIXO - CRIADO EXCLUSIVAMENTE PARA CONVERSAO SM ZEU APAGAR AP�S USO [14/07/2022]
       //SQL.Add('   SELECT DISTINCT   ');
       //SQL.Add('       0 AS COD_PRODUTO,   ');
       //SQL.Add('       ID AS COD_EAN --CODIGO_AGENTE   ');
       //SQL.Add('   FROM   ');
       //SQL.Add('       AGENTES   ');
       //FIM - ABAIXO - CRIADO EXCLUSIVAMENTE PARA CONVERSAO SM ZEU APAGAR AP�S USO [14/07/2022]

    {       BARRAS OFICIAL
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
     SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     //SQL.Add('       PRODUTOS.ID AS COD_EAN   ');
     SQL.Add('      ');
     SQL.Add('       TRIM(LEADING ''0'' FROM COD_EAN.EAN) AS COD_EAN   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN(   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           PRODUTO,   ');
     SQL.Add('           EAN   ');
     SQL.Add('       FROM   ');
     SQL.Add('           EANS   ');
     SQL.Add('       --WHERE PRINCIPAL = 0 ');
     SQL.Add('   ) AS COD_EAN   ');
     SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');    }


    if CbxLoja.Text = 'G-BALANCA' then
    begin
       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       0 AS COD_PRODUTO,   ');
       SQL.Add('       PRODUTOS.ID AS COD_EAN   ');
       SQL.Add('   FROM   ');
       SQL.Add('       PRODUTOS   ');
       SQL.Add('   LEFT JOIN EC_EXPT_PRODUTO AS BALANCA ON BALANCA.ID = PRODUTOS.ID   ');
       SQL.Add('             WHERE BALANCA.BALANCA_CODIGO IS NOT NULL   ');
//        SQL.Add('             LEFT JOIN(   ');
// SQL.Add('                 SELECT DISTINCT      ');
// SQL.Add('                     PRODUTO,      ');
// SQL.Add('                     EAN      ');
// SQL.Add('                 FROM      ');
// SQL.Add('                     EANS      ');
// SQL.Add('                 WHERE ATIVO <> 0    ');
// SQL.Add('             ) AS COD_EAN      ');
// SQL.Add('             ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
// SQL.Add('             WHERE BALANCA.BALANCA_CODIGO IS NOT NULL   ');
// SQL.Add('             AND CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5   ');


    end
    else if CbxLoja.Text = 'G-PRODUTO' then
    begin
       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       0 AS COD_PRODUTO,   ');
       SQL.Add('       PRODUTOS.ID AS COD_EAN   ');
       SQL.Add('   FROM   ');
       SQL.Add('       PRODUTOS   ');
       SQL.Add('   LEFT JOIN EC_EXPT_PRODUTO AS BALANCA ON BALANCA.ID = PRODUTOS.ID   ');
       SQL.Add('   WHERE BALANCA.BALANCA_CODIGO IS NULL   ');
       //SQL.Add('   AND PRODUTOS.ATIVO = 1   ');
    end
    else
    begin
       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('          ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 AND BALANCA.ID IS NOT NULL THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
       SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
       SQL.Add('       END AS COD_PRODUTO,   ');
       SQL.Add('      ');
       SQL.Add('       TRIM(LEADING ''0'' FROM COD_EAN.EAN) AS COD_EAN   ');
       SQL.Add('   FROM   ');
       SQL.Add('       PRODUTOS   ');
       SQL.Add('   LEFT JOIN(   ');
       SQL.Add('       SELECT DISTINCT   ');
       SQL.Add('           PRODUTO,   ');
       SQL.Add('           EAN   ');
       SQL.Add('       FROM   ');
       SQL.Add('           EANS   ');
       SQL.Add('       WHERE ATIVO <> 0 ');
       SQL.Add('   ) AS COD_EAN   ');
       SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
       SQL.Add('   LEFT JOIN (   ');
       SQL.Add('       SELECT DISTINCT   ');
       SQL.Add('           ID   ');
       SQL.Add('       FROM   ');
       SQL.Add('           EC_EXPT_PRODUTO   ');
       SQL.Add('       WHERE BALANCA_CODIGO IS NOT NULL   ');
       SQL.Add('   ) AS BALANCA   ');
       SQL.Add('   ON BALANCA.ID = PRODUTOS.ID   ');
       //SQL.Add('   WHERE PRODUTOS.ATIVO = 1   ');
    end;




    Open;
    First;
    NumLinha := 0;
    TotalCount := SetCountTotal(SQL.Text);


    if CbxLoja.Text = 'G-BALANCA' then
    begin
       NEW_CODPROD := 0;
    end
    else if CbxLoja.Text = 'G-PRODUTO' then
    begin
       NEW_CODPROD := 9999;
    end;

    //NEW_CODPROD := 9999;



    //NEW_CODPESSOA := 0;
    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

      if CbxLoja.Text = 'G-BALANCA' then
      begin
        if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
        begin
          with QryGeraCodigoProduto do
          begin
            Inc(NEW_CODPROD);
  //          ShowMessage(IntToStr(NEW_CODPROD));
            Params.ParamByName('COD_PRODUTO').Value := NEW_CODPROD;
            Params.ParamByName('COD_EAN').Value := Layout.FieldByName('COD_EAN').AsString;
            Layout.FieldByName('COD_PRODUTO').AsInteger := Params.ParamByName('COD_PRODUTO').Value;
            ExecSQL();
          end;
        end;
      end
      else if CbxLoja.Text = 'G-PRODUTO' then
      begin
        if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
        begin
          with QryGeraCodigoProduto do
          begin
            Inc(NEW_CODPROD);
  //          ShowMessage(IntToStr(NEW_CODPROD));
            Params.ParamByName('COD_PRODUTO').Value := NEW_CODPROD;
            Params.ParamByName('COD_EAN').Value := Layout.FieldByName('COD_EAN').AsString;
            Layout.FieldByName('COD_PRODUTO').AsInteger := Params.ParamByName('COD_PRODUTO').Value;
            ExecSQL();
          end;
        end;
      end;


      //INICIO - ABAIXO - CRIADO EXCLUSIVAMENTE PARA CONVERSAO SM ZEU APAGAR AP�S USO [14/07/2022]
      //if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
      //begin
        //with QryGeraCodigoProduto do
        //begin
          //Inc(NEW_CODPESSOA);
          //Params.ParamByName('COD_PRODUTO').Value := NEW_CODPESSOA;
          //Params.ParamByName('COD_EAN').Value := Layout.FieldByName('COD_EAN').AsString;
          //Layout.FieldByName('COD_PRODUTO').AsInteger := Params.ParamByName('COD_PRODUTO').Value;
          //ExecSQL();
        //end;
      //end;
      //FIM - ABAIXO - CRIADO EXCLUSIVAMENTE PARA CONVERSAO SM ZEU APAGAR AP�S USO [14/07/2022]
//


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

procedure TFrmSmZeuGrupoSuperMais.GerarComposicao;
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

procedure TFrmSmZeuGrupoSuperMais.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(AGENTES.CODIGO_PESSOA, 99999) AS COD_CLIENTE,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       VW_EC_EXPT_AG_CLIENTE AS CLIENTE   ');
     SQL.Add('   LEFT JOIN AGENTES ON AGENTES.ID = CLIENTE.IDAGENTE   ');





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

procedure TFrmSmZeuGrupoSuperMais.GerarCondPagForn;
//var
//  COD_FORNECEDOR : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(AGENTES.CODIGO_PESSOA, 99999) AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.DOC, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('       VFORNS AS FORNECEDOR   ');
     SQL.Add('   LEFT JOIN AGENTES ON AGENTES.ID = FORNECEDOR.ID   ');




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

procedure TFrmSmZeuGrupoSuperMais.GerarDecomposicao;
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

procedure TFrmSmZeuGrupoSuperMais.GerarDivisaoForn;
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

procedure TFrmSmZeuGrupoSuperMais.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmZeuGrupoSuperMais.GerarFinanceiroPagar(Aberto: String);
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
             SQL.Add('   SELECT DISTINCT  ');
             SQL.Add('       1 AS TIPO_PARCEIRO,   ');
             SQL.Add('       PAGAR.COD_FORNECEDOR AS COD_PARCEIRO,   ');
             SQL.Add('       0 AS TIPO_CONTA,   ');
             SQL.Add('       8 AS COD_ENTIDADE,   ');
             SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(PAGAR.DOCUMENTO, ''''), ''/'', ''''), ''.'', ''''), '','', ''''), ''-'', '''') AS NUM_DOCTO,   ');
             SQL.Add('       999 AS COD_BANCO,   ');
             SQL.Add('       '''' AS DES_BANCO,   ');
             SQL.Add('       PAGAR.DATA_EMISSAO AS DTA_EMISSAO,   ');
             SQL.Add('       P_PARCELA.DATA_VENCIMENTO AS DTA_VENCIMENTO,   ');
             SQL.Add('       P_PARCELA.VR_PARCELA AS VAL_PARCELA,   ');
             SQL.Add('       0 AS VAL_JUROS,   ');
             SQL.Add('       0 AS VAL_DESCONTO,   ');
             SQL.Add('       ''N'' AS FLG_QUITADO,   ');
             SQL.Add('       '''' AS DTA_QUITADA,   ');
             SQL.Add('       COALESCE(FATURAS_PAGAR_RATEIO.COD_PC, 999) AS COD_CATEGORIA,   ');
             SQL.Add('       999 AS COD_SUBCATEGORIA,   ');
             SQL.Add('       COALESCE(REPLACE(REPLACE(SUBSTRING(P_PARCELA.COD_PARC FROM 1 FOR 2), ''/'', ''''), ''O'', ''0''), 1) AS NUM_PARCELA,   ');
             SQL.Add('       COALESCE(QTD.QTD_PARCELA, 1) AS QTD_PARCELA,   ');
             SQL.Add('       1 AS COD_LOJA,   ');
             SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(PESSOAS.CNPJ_CPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
             SQL.Add('       0 AS NUM_BORDERO,   ');
             SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(PAGAR.DOCUMENTO, ''''), ''/'', ''''), ''.'', ''''), '','', ''''), ''-'', '''') AS NUM_NF,   ');
             SQL.Add('       1 AS NUM_SERIE_NF,   ');
             SQL.Add('       ((PAGAR.VR_BRUTO - PAGAR.VR_ACRESCIMOS) - PAGAR.VR_DESCONTOS) AS VAL_TOTAL_NF,   ');
             SQL.Add('       COALESCE(P_PARCELA.OBS, '''') AS DES_OBSERVACAO,   ');
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
             SQL.Add('       PAGAR.DATA_ENTRADA AS DTA_ENTRADA,   ');
             SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
             SQL.Add('       '''' AS COD_BARRA,   ');
             SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
             SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
             SQL.Add('       PESSOAS.RAZAO_SOCIAL AS DES_TITULAR,   ');
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
             SQL.Add('       FATURAS_PAGAR AS PAGAR   ');
             SQL.Add('   LEFT JOIN FATURAS_PAGAR_PARCELAS AS P_PARCELA ON P_PARCELA.COD_SEQUENCIA = PAGAR.COD_SEQUENCIA   ');
             SQL.Add('   AND P_PARCELA.COD_EMPRESA = PAGAR.COD_EMPRESA   ');
             SQL.Add('   LEFT JOIN PESSOAS ON PESSOAS.COD_PESSOA = PAGAR.COD_FORNECEDOR   ');
             SQL.Add('   LEFT JOIN FATURAS_PAGAR_RATEIO ON FATURAS_PAGAR_RATEIO.COD_SEQUENCIA = PAGAR.COD_SEQUENCIA   ');
             SQL.Add('   AND FATURAS_PAGAR_RATEIO.COD_EMPRESA = PAGAR.COD_EMPRESA   ');
             SQL.Add('   LEFT JOIN (   ');
             SQL.Add('       SELECT   ');
             SQL.Add('           COD_SEQUENCIA,   ');
             SQL.Add('           COUNT(COD_SEQUENCIA) AS QTD_PARCELA   ');
             SQL.Add('       FROM   ');
             SQL.Add('           FATURAS_PAGAR_PARCELAS   ');
             SQL.Add('       WHERE COD_EMPRESA = 1   ');
             SQL.Add('       GROUP BY   ');
             SQL.Add('           COD_SEQUENCIA   ');
             SQL.Add('   ) AS QTD   ');
             SQL.Add('   ON QTD.COD_SEQUENCIA = PAGAR.COD_SEQUENCIA    ');
             SQL.Add('   WHERE P_PARCELA.DATA_PAGAMENTO IS NULL   ');
             SQL.Add('   AND PESSOAS.FLAG_FORNECEDOR = 1   ');
             SQL.Add('   AND PAGAR.COD_EMPRESA = 1   ');
             SQL.Add('AND');
             SQL.Add('    PAGAR.DATA_EMISSAO >= ''01.01.2021'' ');

      end
      else
      begin
        //QUITADO
         SQL.Add('   SELECT DISTINCT  ');
         SQL.Add('       1 AS TIPO_PARCEIRO,   ');
         SQL.Add('       PAGAR.COD_FORNECEDOR AS COD_PARCEIRO,   ');
         SQL.Add('       0 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(PAGAR.DOCUMENTO, ''''), ''/'', ''''), ''.'', ''''), '','', ''''), ''-'', '''') AS NUM_DOCTO,   ');
         SQL.Add('       999 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       PAGAR.DATA_EMISSAO AS DTA_EMISSAO,   ');
         SQL.Add('       P_PARCELA.DATA_VENCIMENTO AS DTA_VENCIMENTO,   ');
         SQL.Add('       P_PARCELA.VR_PARCELA AS VAL_PARCELA,   ');
         SQL.Add('       0 AS VAL_JUROS,   ');
         SQL.Add('       0 AS VAL_DESCONTO,   ');
         SQL.Add('       ''S'' AS FLG_QUITADO,   ');
         SQL.Add('       CASE WHEN P_PARCELA.DATA_PAGAMENTO < PAGAR.DATA_EMISSAO THEN PAGAR.DATA_EMISSAO ELSE P_PARCELA.DATA_PAGAMENTO END AS DTA_QUITADA,   ');
         SQL.Add('       COALESCE(FATURAS_PAGAR_RATEIO.COD_PC, 999) AS COD_CATEGORIA,   ');
         SQL.Add('       999 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(SUBSTRING(P_PARCELA.COD_PARC FROM 1 FOR 2), ''/'', ''''), ''O'', ''0''), 1) AS NUM_PARCELA,   ');
         SQL.Add('       COALESCE(QTD.QTD_PARCELA, 1) AS QTD_PARCELA,   ');
         SQL.Add('       1 AS COD_LOJA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(PESSOAS.CNPJ_CPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(PAGAR.DOCUMENTO, ''''), ''/'', ''''), ''.'', ''''), '','', ''''), ''-'', '''') AS NUM_NF,   ');
         SQL.Add('       1 AS NUM_SERIE_NF,   ');
         SQL.Add('       ((PAGAR.VR_BRUTO - PAGAR.VR_ACRESCIMOS) - PAGAR.VR_DESCONTOS) AS VAL_TOTAL_NF,   ');
         SQL.Add('       COALESCE(P_PARCELA.OBS, '''') AS DES_OBSERVACAO,   ');
         SQL.Add('       0 AS NUM_PDV,   ');
         SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('       0 AS COD_MOTIVO,   ');
         SQL.Add('       0 AS COD_CONVENIO,   ');
         SQL.Add('       0 AS COD_BIN,   ');
         SQL.Add('       '''' AS DES_BANDEIRA,   ');
         SQL.Add('       '''' AS DES_REDE_TEF,   ');
         SQL.Add('       0 AS VAL_RETENCAO,   ');
         SQL.Add('       0 AS COD_CONDICAO,   ');
         SQL.Add('       P_PARCELA.DATA_PAGAMENTO AS DTA_PAGTO,   ');
         SQL.Add('       PAGAR.DATA_ENTRADA AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       PESSOAS.RAZAO_SOCIAL AS DES_TITULAR,   ');
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
         SQL.Add('       FATURAS_PAGAR AS PAGAR   ');
         SQL.Add('   LEFT JOIN FATURAS_PAGAR_PARCELAS AS P_PARCELA ON P_PARCELA.COD_SEQUENCIA = PAGAR.COD_SEQUENCIA   ');
         SQL.Add('   AND P_PARCELA.COD_EMPRESA = PAGAR.COD_EMPRESA   ');
         SQL.Add('   LEFT JOIN PESSOAS ON PESSOAS.COD_PESSOA = PAGAR.COD_FORNECEDOR   ');
         SQL.Add('   LEFT JOIN FATURAS_PAGAR_RATEIO ON FATURAS_PAGAR_RATEIO.COD_SEQUENCIA = PAGAR.COD_SEQUENCIA   ');
         SQL.Add('   AND FATURAS_PAGAR_RATEIO.COD_EMPRESA = PAGAR.COD_EMPRESA   ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('       SELECT   ');
         SQL.Add('           COD_SEQUENCIA,   ');
         SQL.Add('           COUNT(COD_SEQUENCIA) AS QTD_PARCELA   ');
         SQL.Add('       FROM   ');
         SQL.Add('           FATURAS_PAGAR_PARCELAS   ');
         SQL.Add('       WHERE COD_EMPRESA = 1   ');
         SQL.Add('       GROUP BY   ');
         SQL.Add('           COD_SEQUENCIA   ');
         SQL.Add('   ) AS QTD   ');
         SQL.Add('   ON QTD.COD_SEQUENCIA = PAGAR.COD_SEQUENCIA    ');
         SQL.Add('   WHERE P_PARCELA.DATA_PAGAMENTO IS NOT NULL   ');
         SQL.Add('   AND PESSOAS.FLAG_FORNECEDOR = 1   ');
         SQL.Add('   AND PAGAR.COD_EMPRESA = 1   ');
         SQL.Add('AND');
         SQL.Add('    PAGAR.DATA_EMISSAO >= :INI ');
         SQL.Add('AND');
         SQL.Add('    PAGAR.DATA_EMISSAO <= :FIM ');
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
            //if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
            //begin
                Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
            //end;
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
            //if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
            //begin
                Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
            //end;
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

procedure TFrmSmZeuGrupoSuperMais.GerarFinanceiroReceber(Aberto: String);
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
         SQL.Add('   SELECT DISTINCT  ');
         SQL.Add('       0 AS TIPO_PARCEIRO,   ');
         SQL.Add('       RECEBER.COD_CLIENTE AS COD_PARCEIRO,   ');
         SQL.Add('       1 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       COALESCE(RECEBER.COD_FATURA, '''') AS NUM_DOCTO,   ');
         SQL.Add('       999 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       RECEBER.DATA_EMISSAO AS DTA_EMISSAO,   ');
         SQL.Add('       P_PARCELA.DATA_VENCIMENTO AS DTA_VENCIMENTO,   ');
         SQL.Add('       P_PARCELA.VR_PARCELA AS VAL_PARCELA,   ');
         SQL.Add('       0 AS VAL_JUROS,   ');
         SQL.Add('       0 AS VAL_DESCONTO,   ');
         SQL.Add('       ''N'' AS FLG_QUITADO,   ');
         SQL.Add('       '''' AS DTA_QUITADA,   ');
         SQL.Add('       997 AS COD_CATEGORIA,   ');
         SQL.Add('       997 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(SUBSTRING(P_PARCELA.COD_PARC FROM 1 FOR 2), ''/'', ''''), ''O'', ''0''), 1) AS NUM_PARCELA,   ');
         SQL.Add('       COALESCE(QTD.QTD_PARCELA, 1) AS QTD_PARCELA,   ');
         SQL.Add('       1 AS COD_LOJA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(PESSOAS.CNPJ_CPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       COALESCE(RECEBER.COD_FATURA, '''') AS NUM_NF,   ');
         SQL.Add('       1 AS NUM_SERIE_NF,   ');
         SQL.Add('       ((RECEBER.VR_BRUTO - RECEBER.VR_ACRESCIMOS) - RECEBER.VR_DESCONTOS) AS VAL_TOTAL_NF,   ');
         SQL.Add('       COALESCE(P_PARCELA.OBS, '''') AS DES_OBSERVACAO,   ');
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
         SQL.Add('       RECEBER.DATA_EMISSAO AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       PESSOAS.RAZAO_SOCIAL AS DES_TITULAR,   ');
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
         SQL.Add('       FATURAS_RECEBER AS RECEBER   ');
         SQL.Add('   LEFT JOIN FATURAS_RECEBER_PARCELAS AS P_PARCELA ON P_PARCELA.COD_FATURA = RECEBER.COD_FATURA   ');
         SQL.Add('   AND P_PARCELA.COD_EMPRESA = RECEBER.COD_EMPRESA   ');
         SQL.Add('   LEFT JOIN PESSOAS ON PESSOAS.COD_PESSOA = RECEBER.COD_CLIENTE   ');
         //SQL.Add('   LEFT JOIN FATURAS_RECEBER_RATEIO ON FATURAS_RECEBER_RATEIO.COD_FATURA = RECEBER.COD_FATURA   ');
         //SQL.Add('   AND FATURAS_RECEBER_RATEIO.COD_EMPRESA = RECEBER.COD_EMPRESA   ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('       SELECT   ');
         SQL.Add('           COD_FATURA,   ');
         SQL.Add('           COUNT(COD_FATURA) AS QTD_PARCELA   ');
         SQL.Add('       FROM   ');
         SQL.Add('           FATURAS_RECEBER_PARCELAS   ');
         SQL.Add('       WHERE COD_EMPRESA = 1   ');
         SQL.Add('       GROUP BY   ');
         SQL.Add('           COD_FATURA   ');
         SQL.Add('   ) AS QTD   ');
         SQL.Add('   ON QTD.COD_FATURA = RECEBER.COD_FATURA    ');
         SQL.Add('   WHERE P_PARCELA.DATA_RECEBIMENTO IS NULL   ');
         SQL.Add('   AND PESSOAS.FLAG_CLIENTE = 1   ');
         SQL.Add('   AND RECEBER.COD_EMPRESA = 1   ');



      end
      else
      begin
       //QUITADO
         SQL.Add('   SELECT DISTINCT  ');
         SQL.Add('       0 AS TIPO_PARCEIRO,   ');
         SQL.Add('       RECEBER.COD_CLIENTE AS COD_PARCEIRO,   ');
         SQL.Add('       1 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       COALESCE(RECEBER.COD_FATURA, '''') AS NUM_DOCTO,   ');
         SQL.Add('       999 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       RECEBER.DATA_EMISSAO AS DTA_EMISSAO,   ');
         SQL.Add('       P_PARCELA.DATA_VENCIMENTO AS DTA_VENCIMENTO,   ');
         SQL.Add('       P_PARCELA.VR_PARCELA AS VAL_PARCELA,   ');
         SQL.Add('       0 AS VAL_JUROS,   ');
         SQL.Add('       0 AS VAL_DESCONTO,   ');
         SQL.Add('       ''S'' AS FLG_QUITADO,   ');
         SQL.Add('       P_PARCELA.DATA_RECEBIMENTO AS DTA_QUITADA,   ');
         SQL.Add('       997 AS COD_CATEGORIA,   ');
         SQL.Add('       997 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(SUBSTRING(P_PARCELA.COD_PARC FROM 1 FOR 2), ''/'', ''''), ''O'', ''0''), 1) AS NUM_PARCELA,   ');
         SQL.Add('       COALESCE(QTD.QTD_PARCELA, 1) AS QTD_PARCELA,   ');
         SQL.Add('       1 AS COD_LOJA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(PESSOAS.CNPJ_CPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       COALESCE(RECEBER.COD_FATURA, '''') AS NUM_NF,   ');
         SQL.Add('       1 AS NUM_SERIE_NF,   ');
         SQL.Add('       ((RECEBER.VR_BRUTO - RECEBER.VR_ACRESCIMOS) - RECEBER.VR_DESCONTOS) AS VAL_TOTAL_NF,   ');
         SQL.Add('       COALESCE(P_PARCELA.OBS, '''') AS DES_OBSERVACAO,   ');
         SQL.Add('       0 AS NUM_PDV,   ');
         SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
         SQL.Add('       0 AS COD_MOTIVO,   ');
         SQL.Add('       0 AS COD_CONVENIO,   ');
         SQL.Add('       0 AS COD_BIN,   ');
         SQL.Add('       '''' AS DES_BANDEIRA,   ');
         SQL.Add('       '''' AS DES_REDE_TEF,   ');
         SQL.Add('       0 AS VAL_RETENCAO,   ');
         SQL.Add('       0 AS COD_CONDICAO,   ');
         SQL.Add('       P_PARCELA.DATA_RECEBIMENTO AS DTA_PAGTO,   ');
         SQL.Add('       RECEBER.DATA_EMISSAO AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       PESSOAS.RAZAO_SOCIAL AS DES_TITULAR,   ');
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
         SQL.Add('       FATURAS_RECEBER AS RECEBER   ');
         SQL.Add('   LEFT JOIN FATURAS_RECEBER_PARCELAS AS P_PARCELA ON P_PARCELA.COD_FATURA = RECEBER.COD_FATURA   ');
         SQL.Add('   AND P_PARCELA.COD_EMPRESA = RECEBER.COD_EMPRESA   ');
         SQL.Add('   LEFT JOIN PESSOAS ON PESSOAS.COD_PESSOA = RECEBER.COD_CLIENTE   ');
         //SQL.Add('   LEFT JOIN FATURAS_RECEBER_RATEIO ON FATURAS_RECEBER_RATEIO.COD_FATURA = RECEBER.COD_FATURA   ');
         //SQL.Add('   AND FATURAS_RECEBER_RATEIO.COD_EMPRESA = RECEBER.COD_EMPRESA   ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('       SELECT   ');
         SQL.Add('           COD_FATURA,   ');
         SQL.Add('           COUNT(COD_FATURA) AS QTD_PARCELA   ');
         SQL.Add('       FROM   ');
         SQL.Add('           FATURAS_RECEBER_PARCELAS   ');
         SQL.Add('       WHERE COD_EMPRESA = 1   ');
         SQL.Add('       GROUP BY   ');
         SQL.Add('           COD_FATURA   ');
         SQL.Add('   ) AS QTD   ');
         SQL.Add('   ON QTD.COD_FATURA = RECEBER.COD_FATURA    ');
         SQL.Add('   WHERE P_PARCELA.DATA_RECEBIMENTO IS NOT NULL   ');
         SQL.Add('   AND PESSOAS.FLAG_CLIENTE = 1   ');
         SQL.Add('   AND RECEBER.COD_EMPRESA = 1   ');
         SQL.Add('AND RECEBER.DATA_EMISSAO >= :INI ');
         SQL.Add('AND RECEBER.DATA_EMISSAO <= :FIM ');

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
            //if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
            //begin
                Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
            //end;
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
            //if Layout.FieldByName('DTA_ENTRADA').AsString <> '' then
            //begin
                Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal.FieldByName('DTA_ENTRADA').AsDateTime);
            //end;
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

procedure TFrmSmZeuGrupoSuperMais.GerarFinanceiroReceberCartao;
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

procedure TFrmSmZeuGrupoSuperMais.GerarFornecedor;
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

     SQL.Add('   SELECT DISTINCT      ');
     SQL.Add('       COALESCE(AGENTES.CODIGO_PESSOA, 99999) AS COD_FORNECEDOR,      ');
     SQL.Add('       FORNECEDOR.NOME AS DES_FORNECEDOR,      ');
     SQL.Add('       FORNECEDOR.FANTASIA AS DES_FANTASIA,      ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.DOC, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(RG_INSC.DOC) > 9 THEN RG_INSC.DOC   ');
     SQL.Add('           ELSE ''ISENTO''    ');
     SQL.Add('       END AS NUM_INSC_EST,      ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(SUB_EN.LOGRADOURO, ''A DEFINIR'') AS DES_ENDERECO,      ');
     SQL.Add('       COALESCE(SUB_EN.BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,      ');
     SQL.Add('       CIDADES.CIDADE AS DES_CIDADE,      ');
     SQL.Add('       CIDADES.UF AS DES_SIGLA,      ');
     SQL.Add('       SUB_EN.CEP AS NUM_CEP,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN TE_LEFONE.IDTIPOTEL = 36 THEN TE_LEFONE.TEL      ');
     SQL.Add('           ELSE ''''      ');
     SQL.Add('       END AS NUM_FONE,      ');
     SQL.Add('             ');
     SQL.Add('       '''' AS NUM_FAX,      ');
     SQL.Add('       FORNECEDOR.NOME AS DES_CONTATO,      ');
     SQL.Add('       0 AS QTD_DIA_CARENCIA,      ');
     SQL.Add('       0 AS NUM_FREQ_VISITA,      ');
     SQL.Add('       0 AS VAL_DESCONTO,      ');
     SQL.Add('       0 AS NUM_PRAZO,      ');
     SQL.Add('       ''N'' AS ACEITA_DEVOL_MER,      ');
     SQL.Add('       ''N'' AS CAL_IPI_VAL_BRUTO,      ');
     SQL.Add('       ''N'' AS CAL_ICMS_ENC_FIN,      ');
     SQL.Add('       ''N'' AS CAL_ICMS_VAL_IPI,      ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('       FORNECEDOR.ID AS COD_FORNECEDOR_ANT,      ');
     SQL.Add('       COALESCE(SUB_EN.NUMERO, ''S/N'') AS NUM_ENDERECO,      ');
     SQL.Add('       '''' AS DES_OBSERVACAO,      ');
     SQL.Add('       COALESCE(EMAIL.EMAIL, '''') AS DES_EMAIL,      ');
     SQL.Add('       COALESCE(FORNECEDOR.SITE, '''') AS DES_WEB_SITE,      ');
     SQL.Add('       ''N'' AS FABRICANTE,      ');
     SQL.Add('       ''N'' AS FLG_PRODUTOR_RURAL,      ');
     SQL.Add('       0 AS TIPO_FRETE,      ');
     SQL.Add('       ''N'' AS FLG_SIMPLES,      ');
     SQL.Add('       ''N'' AS FLG_SUBSTITUTO_TRIB,      ');
     SQL.Add('       0 AS COD_CONTACCFORN,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN FORNS.ATIVO = 1 THEN ''N''      ');
     SQL.Add('           ELSE ''S''       ');
     SQL.Add('       END AS INATIVO,      ');
     SQL.Add('             ');
     SQL.Add('       0 AS COD_CLASSIF,      ');
     SQL.Add('       '''' AS DTA_CADASTRO,      ');
     SQL.Add('       0 AS VAL_CREDITO,      ');
     SQL.Add('       0 AS VAL_DEBITO,      ');
     SQL.Add('       1 AS PED_MIN_VAL,      ');
     SQL.Add('       '''' AS DES_EMAIL_VEND,      ');
     SQL.Add('       '''' AS SENHA_COTACAO,      ');
     SQL.Add('       -1 AS TIPO_PRODUTOR,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN CELULAR.IDTIPOTEL = 38 THEN COALESCE(CELULAR.TEL, '''')      ');
     SQL.Add('           ELSE ''''       ');
     SQL.Add('       END AS NUM_CELULAR      ');
     SQL.Add('   FROM      ');
     SQL.Add('       VFORNS AS FORNECEDOR      ');
     SQL.Add('   LEFT JOIN AGENTES ON AGENTES.ID = FORNECEDOR.ID      ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           CODAG,   ');
     SQL.Add('           DOC,   ');
     SQL.Add('           TIPO   ');
     SQL.Add('       FROM   ');
     SQL.Add('           DOCS   ');
     SQL.Add('       WHERE   ');
     SQL.Add('           TIPO = 66   ');
     SQL.Add('   ) AS RG_INSC   ');
     SQL.Add('   ON RG_INSC.CODAG = FORNECEDOR.ID   ');
     SQL.Add('   -- LEFT JOIN (      ');
     SQL.Add('   --     SELECT DISTINCT      ');
     SQL.Add('   -- ENDERECOS.AGENTE,      ');
     SQL.Add('   -- SUB_EN.LOGRADOURO,      ');
     SQL.Add('   -- SUB_EN.BAIRRO,      ');
     SQL.Add('   -- SUB_EN.CEP,      ');
     SQL.Add('   -- SUB_EN.NUMERO,      ');
     SQL.Add('   -- SUB_EN.COMPLEMENTO,      ');
     SQL.Add('   -- SUB_EN.CIDADE      ');
     SQL.Add('   --     FROM      ');
     SQL.Add('   -- ENDERECOS      ');
     SQL.Add('   LEFT JOIN (      ');
     SQL.Add('       SELECT DISTINCT      ');
     SQL.Add('           EN.AGENTE AS AGENTE,      ');
     SQL.Add('           EN.LOGRADOURO AS LOGRADOURO,      ');
     SQL.Add('           EN.BAIRRO AS BAIRRO,      ');
     SQL.Add('           REPLACE(EN.CEP, ''-'', '''') AS CEP,      ');
     SQL.Add('           COALESCE(EN.NUMERO, ''S/N'') AS NUMERO,      ');
     SQL.Add('           EN.COMPLEMENTO AS COMPLEMENTO,      ');
     SQL.Add('           EN.CIDADE      ');
     SQL.Add('       FROM      ');
     SQL.Add('           ENDERECOS AS EN      ');
     SQL.Add('       WHERE (EN.LOGRADOURO IS NOT NULL AND EN.BAIRRO IS NOT NULL AND EN.COMPLEMENTO IS NOT NULL)      ');
     SQL.Add('       AND EN.TIPO = 14001   ');
     SQL.Add('   ) AS SUB_EN      ');
     SQL.Add('   ON SUB_EN.AGENTE = FORNECEDOR.ID      ');
     SQL.Add('   --     WHERE (SUB_EN.LOGRADOURO <> '''' AND SUB_EN.BAIRRO <> '''' AND SUB_EN.COMPLEMENTO <> '''')      ');
     SQL.Add('   -- ) AS SUB_SUB_EN      ');
     SQL.Add('   -- ON FORNECEDOR.ID = SUB_SUB_EN.AGENTE      ');
     SQL.Add('   LEFT JOIN CIDADES ON CIDADES.ID = SUB_EN.CIDADE   ');
     SQL.Add('   LEFT JOIN (      ');
     SQL.Add('       SELECT DISTINCT      ');
     SQL.Add('           IDAGENTE,      ');
     SQL.Add('           IDTIPOTEL,      ');
     SQL.Add('           CASE   ');
     SQL.Add('              WHEN CHAR_LENGTH(TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))) = 10 THEN DDD || TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('              WHEN DDD || TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', '''')) LIKE ''3838%'' THEN TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('              ELSE TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('           END AS TEL   ');
     SQL.Add('       FROM      ');
     SQL.Add('           EC_EXPT_AG_TELEFONE      ');
     SQL.Add('       WHERE TEL <> ''''      ');
     SQL.Add('       AND IDTIPOTEL = 36      ');
     SQL.Add('   ) AS TE_LEFONE      ');
     SQL.Add('   ON FORNECEDOR.ID = TE_LEFONE.IDAGENTE      ');
     SQL.Add('   LEFT JOIN (      ');
     SQL.Add('       SELECT DISTINCT      ');
     SQL.Add('           IDAGENTE,      ');
     SQL.Add('           IDTIPOTEL,      ');
     SQL.Add('           CASE   ');
     SQL.Add('              WHEN CHAR_LENGTH(TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))) = 9 THEN DDD || TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('              WHEN DDD || TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', '''')) LIKE ''3838%'' THEN TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('              ELSE TRIM(REPLACE(REPLACE(REPLACE(TEL, ''-'', ''''), ''('', ''''), '')'', ''''))   ');
     SQL.Add('           END AS TEL   ');
     SQL.Add('       FROM      ');
     SQL.Add('           EC_EXPT_AG_TELEFONE      ');
     SQL.Add('       WHERE TEL <> ''''      ');
     SQL.Add('       AND IDTIPOTEL = 38    ');
     SQL.Add('   ) AS CELULAR      ');
     SQL.Add('   ON FORNECEDOR.ID = CELULAR.IDAGENTE      ');
     SQL.Add('   LEFT JOIN FORNS ON FORNS.ID = FORNECEDOR.ID     ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           IDAGENTE,   ');
     SQL.Add('           EMAIL,   ');
     SQL.Add('           PADRAO,   ');
     SQL.Add('           EMPRESA   ');
     SQL.Add('       FROM   ');
     SQL.Add('           EC_EXPT_AG_EMAIL   ');
     SQL.Add('       WHERE   ');
     SQL.Add('           EMPRESA = 1   ');
     SQL.Add('       AND   ');
     SQL.Add('           PADRAO = 1   ');
     SQL.Add('   ) AS EMAIL   ');
     SQL.Add('   ON EMAIL.IDAGENTE = FORNECEDOR.ID   ');




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


       //Layout.FieldByName('DTA_CADASTRO').AsDateTime := FieldByName('DTA_CADASTRO').AsDateTime;

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
      Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');
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

procedure TFrmSmZeuGrupoSuperMais.GerarGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(PRODUTOS.SECAO, 999) AS COD_SECAO,   ');
     SQL.Add('       CASE WHEN PRODUTOS.GRUPO LIKE ''%-%'' THEN 999 ELSE COALESCE(PRODUTOS.GRUPO, 999) END AS COD_GRUPO,   ');
     SQL.Add('       COALESCE(OBJETOS.DESCRICAO, ''A DEFINIR'') AS DES_GRUPO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN OBJETOS ON OBJETOS.ID = PRODUTOS.GRUPO   ');



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

procedure TFrmSmZeuGrupoSuperMais.GerarInfoNutricionais;
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
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT   ');
     SQL.Add('       NUTRI_LJ2.COD + 1000 AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       CASE WHEN NUTRI_LJ2.DSC = '''' THEN ''A DEFINIR'' ELSE NUTRI_LJ2.DSC END AS DES_INFO_NUTRICIONAL,   ');
     SQL.Add('       NUTRI_LJ2.TOLEDO_PORCAO_QUANTIDADE AS PORCAO,   ');
     SQL.Add('       NUTRI_LJ2.VCALORICO AS VALOR_CALORICO,   ');
     SQL.Add('       NUTRI_LJ2.VCARBOIDRATO AS CARBOIDRATO,   ');
     SQL.Add('       NUTRI_LJ2.VPROTEINAS AS PROTEINA,   ');
     SQL.Add('       NUTRI_LJ2.VGORDURATOTAL AS GORDURA_TOTAL,   ');
     SQL.Add('       NUTRI_LJ2.VGORDURASATURADA AS GORDURA_SATURADA,   ');
     SQL.Add('       NUTRI_LJ2.VCOLESTEROL AS COLESTEROL,   ');
     SQL.Add('       NUTRI_LJ2.VFIBRAALIMENTAR AS FIBRA_ALIMENTAR,   ');
     SQL.Add('       NUTRI_LJ2.VCALCIO AS CALCIO,   ');
     SQL.Add('       NUTRI_LJ2.VFERRO AS FERRO,   ');
     SQL.Add('       NUTRI_LJ2.VSODIO AS SODIO,   ');
     SQL.Add('       (NUTRI_LJ2.VCALORICO * 100) / 2000 AS VD_VALOR_CALORICO,   ');
     SQL.Add('       (NUTRI_LJ2.VCARBOIDRATO * 100) / 300 AS VD_CARBOIDRATO,   ');
     SQL.Add('       (NUTRI_LJ2.VPROTEINAS * 100) / 75 AS VD_PROTEINA,   ');
     SQL.Add('       (NUTRI_LJ2.VGORDURATOTAL * 100) / 55 AS VD_GORDURA_TOTAL,   ');
     SQL.Add('       (NUTRI_LJ2.VGORDURASATURADA * 100) / 22 AS VD_GORDURA_SATURADA,   ');
     SQL.Add('       (NUTRI_LJ2.VCOLESTEROL * 100) / 300 AS VD_COLESTEROL,   ');
     SQL.Add('       (NUTRI_LJ2.VFIBRAALIMENTAR * 100) / 25 AS VD_FIBRA_ALIMENTAR,   ');
     SQL.Add('       (NUTRI_LJ2.VCALCIO * 100) / 1000 AS VD_CALCIO,   ');
     SQL.Add('       (NUTRI_LJ2.VFERRO * 100) / 14 AS VD_FERRO,   ');
     SQL.Add('       (NUTRI_LJ2.VSODIO * 100) / 2400 AS VD_SODIO,   ');
     SQL.Add('       NUTRI_LJ2.VGORDURATRANS AS GORDURA_TRANS,   ');
     SQL.Add('       0 AS VD_GORDURA_TRANS,   ');
     SQL.Add('       ''UN'' AS UNIDADE_PORCAO,   ');
     SQL.Add('       NUTRI_LJ2.FILIZOLA_PORCAO AS DES_PORCAO,   ');
     SQL.Add('       0 AS PARTE_INTEIRA_MED_CASEIRA,   ');
     SQL.Add('       '''' AS MED_CASEIRA_UTILIZADA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_TABELA_NUTRICIONAL_LJ2 AS NUTRI_LJ2   ');
     SQL.Add('   WHERE NUTRI_LJ2.DSC NOT IN (SELECT NUTRI.DSC FROM SM_CD_ES_TABELA_NUTRICIONAL AS NUTRI)   ');


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

procedure TFrmSmZeuGrupoSuperMais.GerarNCM;
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
     SQL.Add('       COALESCE(NCMPADRAO.DESCRICAO, ''A DEFINIR'') AS DES_NCM,   ');
     SQL.Add('       COALESCE(CFPROD.CODIGO, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           --WHEN PRODUTOS.ISENTOIF = 0 THEN '''' --TRIBUTADO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 1 THEN ''S'' --ALIQ. ZERO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 2 THEN ''S'' --MONOFASICO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 3 THEN ''S'' --SUBST.   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 4 THEN ''S'' --ISENTO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 5 THEN ''S'' --SEM INCIDENCIA   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 6 THEN ''S'' --SUSPENSO   ');
//     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           --WHEN PRODUTOS.ISENTOIF = 0 THEN  --TRIBUTADO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 1 THEN 0 --ALIQ. ZERO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 2 THEN 1 --MONOFASICO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 3 THEN 2 --SUBST.   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 4 THEN 0 --ISENTO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 5 THEN 0 --SEM INCIDENCIA   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 6 THEN 4 --SUSPENSO   ');
//     SQL.Add('           ELSE -1   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
//     SQL.Add('       COALESCE(COD_SPED.CODIGO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('       COALESCE(REPLACE(PRODST.COD_CEST, ''.'', ''''), ''9999999'') AS NUM_CEST,   ');
//     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
     SQL.Add('       ''SP'' AS DES_SIGLA,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 25   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''2.7000'' THEN 41   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 28   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 11   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.6000'' THEN 42   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 12   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 43   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 13   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''20.0000'' THEN 29   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''25.0000'' THEN 14   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''27.0000'' THEN 44   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''40.0000'' THEN 45   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''12'' AND ICMS.DES_ICMS = ''N'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 23   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 2   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 8   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 7   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 27   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 46   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 4   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 25   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''2.7000'' THEN 41   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 28   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 11   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.6000'' THEN 42   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 12   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 43   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 13   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''20.0000'' THEN 29   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''25.0000'' THEN 14   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''27.0000'' THEN 44   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''40.0000'' THEN 45   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''12'' AND ICMS.DES_ICMS = ''N'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 23   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 2   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 8   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 7   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 27   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 46   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 4   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
//     SQL.Add('       COALESCE(V_PRODS.MVA, 0) AS PER_IVA,   ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN CFPROD ON CFPROD.ID = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN VPRODS AS V_PRODS ON V_PRODS.ID = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN PRODNTPISCOFINS AS COD_SPED ON COD_SPED.ID = PRODUTOS.ID  ');
     SQL.Add('   LEFT JOIN NCMPADRAO ON NCMPADRAO.CODIGO = CFPROD.CODIGO   ');
     SQL.Add('   LEFT JOIN PRODST ON PRODST.ID = PRODUTOS.ID AND PRODST.ID = CFPROD.ID   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       --ICMS   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           OBJETOS.ID AS ID_ICMS,   ');
     SQL.Add('           OBJETOS.DESCRICAO AS DES_ICMS,   ');
     SQL.Add('           VPRODS.VALIQ AS VAL_ICMS,   ');
     SQL.Add('           VPRODS.ID AS ID_PROD   ');
     SQL.Add('       FROM    ');
     SQL.Add('           OBJETOS   ');
     SQL.Add('       LEFT JOIN VPRODS ON VPRODS.TRIB = OBJETOS.ID   ');
     SQL.Add('       WHERE OBJETOS.ID IN (10,11,12,13,14,15)   ');
     SQL.Add('   ) AS ICMS   ');
     SQL.Add('   ON PRODUTOS.TRIB = ICMS.ID_ICMS AND PRODUTOS.ID = ICMS.ID_PROD   ');




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

procedure TFrmSmZeuGrupoSuperMais.GerarNCMUF;
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
     SQL.Add('       COALESCE(NCMPADRAO.DESCRICAO, ''A DEFINIR'') AS DES_NCM,   ');
     SQL.Add('       COALESCE(CFPROD.CODIGO, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           --WHEN PRODUTOS.ISENTOIF = 0 THEN '''' --TRIBUTADO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 1 THEN ''S'' --ALIQ. ZERO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 2 THEN ''S'' --MONOFASICO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 3 THEN ''S'' --SUBST.   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 4 THEN ''S'' --ISENTO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 5 THEN ''S'' --SEM INCIDENCIA   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 6 THEN ''S'' --SUSPENSO   ');
//     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           --WHEN PRODUTOS.ISENTOIF = 0 THEN  --TRIBUTADO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 1 THEN 0 --ALIQ. ZERO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 2 THEN 1 --MONOFASICO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 3 THEN 2 --SUBST.   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 4 THEN 0 --ISENTO   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 5 THEN 0 --SEM INCIDENCIA   ');
//     SQL.Add('           WHEN PRODUTOS.ISENTOIF = 6 THEN 4 --SUSPENSO   ');
//     SQL.Add('           ELSE -1   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
//     SQL.Add('       COALESCE(COD_SPED.CODIGO, 999) AS COD_TAB_SPED,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('       COALESCE(REPLACE(PRODST.COD_CEST, ''.'', ''''), ''9999999'') AS NUM_CEST,   ');
//     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
     SQL.Add('       ''SP'' AS DES_SIGLA,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 25   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''2.7000'' THEN 41   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 28   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 11   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.6000'' THEN 42   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 12   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 43   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 13   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''20.0000'' THEN 29   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''25.0000'' THEN 14   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''27.0000'' THEN 44   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''40.0000'' THEN 45   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''12'' AND ICMS.DES_ICMS = ''N'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 23   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 2   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 8   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 7   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 27   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 46   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 4   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 25   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''2.7000'' THEN 41   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 28   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 11   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.6000'' THEN 42   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 12   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 43   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 13   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''20.0000'' THEN 29   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''25.0000'' THEN 14   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''27.0000'' THEN 44   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''40.0000'' THEN 45   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''12'' AND ICMS.DES_ICMS = ''N'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 23   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 2   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 8   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 7   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 27   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 46   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 4   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_SAIDA,   ');
     SQL.Add('      ');
//     SQL.Add('       COALESCE(V_PRODS.MVA, 0) AS PER_IVA,   ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN CFPROD ON CFPROD.ID = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN VPRODS AS V_PRODS ON V_PRODS.ID = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN PRODNTPISCOFINS AS COD_SPED ON COD_SPED.ID = PRODUTOS.ID  ');
     SQL.Add('   LEFT JOIN NCMPADRAO ON NCMPADRAO.CODIGO = CFPROD.CODIGO   ');
     SQL.Add('   LEFT JOIN PRODST ON PRODST.ID = PRODUTOS.ID AND PRODST.ID = CFPROD.ID   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       --ICMS   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           OBJETOS.ID AS ID_ICMS,   ');
     SQL.Add('           OBJETOS.DESCRICAO AS DES_ICMS,   ');
     SQL.Add('           VPRODS.VALIQ AS VAL_ICMS,   ');
     SQL.Add('           VPRODS.ID AS ID_PROD   ');
     SQL.Add('       FROM    ');
     SQL.Add('           OBJETOS   ');
     SQL.Add('       LEFT JOIN VPRODS ON VPRODS.TRIB = OBJETOS.ID   ');
     SQL.Add('       WHERE OBJETOS.ID IN (10,11,12,13,14,15)   ');
     SQL.Add('   ) AS ICMS   ');
     SQL.Add('   ON PRODUTOS.TRIB = ICMS.ID_ICMS AND PRODUTOS.ID = ICMS.ID_PROD   ');



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

procedure TFrmSmZeuGrupoSuperMais.GerarNFClientes;
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

procedure TFrmSmZeuGrupoSuperMais.GerarNFFornec;
var
   TotalCount : integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN '+CbxLoja.Text+' = 1 THEN CAPA.PD_EMITENTE   ');
     SQL.Add('           ELSE CAPA.PD_EMITENTE + 200000   ');
     SQL.Add('       END AS COD_FORNECEDOR,   ');
     SQL.Add('          ');
     SQL.Add('       CAPA.LANCTO AS NUM_NF_FORN,   ');
     SQL.Add('       COALESCE(C_CAPA.SERIE, 1) AS NUM_SERIE_NF,   ');
     SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
     SQL.Add('       '''' AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
     SQL.Add('       CAPA.PD_TOTAL AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.PD_EMISSAO AS DTA_EMISSAO,   ');
     SQL.Add('       '''' AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS VAL_TOTAL_IPI,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       0 AS VAL_FRETE,   ');
     SQL.Add('       0 AS VAL_ACRESCIMO,   ');
     SQL.Add('       0 AS VAL_DESCONTO,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNEC.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       0 AS VAL_TOTAL_BC,   ');
     SQL.Add('       0 AS VAL_TOTAL_ICMS,   ');
     SQL.Add('       0 AS VAL_BC_SUBST,   ');
     SQL.Add('       0 AS VAL_ICMS_SUBST,   ');
     SQL.Add('       0 AS VAL_FUNRURAL,   ');
     SQL.Add('       1 AS COD_PERFIL,   ');
     SQL.Add('       0 AS VAL_DESP_ACESS,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       COALESCE(C_CAPA.CHAVE, '''') AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_MV_ES_CB_NR AS CAPA   ');
     SQL.Add('   LEFT JOIN SM_MV_ES_EF_NR AS C_CAPA ON C_CAPA.LANCTO = CAPA.LANCTO AND C_CAPA.EMPRESA = CAPA.EMPRESA   ');
     SQL.Add('   LEFT JOIN SM_CD_MO_MOVIMENTADOR AS FORNEC ON FORNEC.COD = CAPA.PD_EMITENTE   ');
     SQL.Add('   WHERE (   ');
     SQL.Add('       (   ');
     SQL.Add('           '+CbxLoja.Text+' = 1 AND (FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5''))   ');
     SQL.Add('           OR   ');
     SQL.Add('           '+CbxLoja.Text+' = 2 AND (FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')   ');
     SQL.Add('           AND FORNEC.PD_CNPJ_CPF NOT IN (SELECT FORNECEDOR_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR_LJ1 FORNECEDOR_LJ1 WHERE FORNECEDOR_LJ1.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')))   ');
     SQL.Add('       )   ');
     SQL.Add('   )   ');
     SQL.Add('   AND CAPA.PD_EMISSAO >= :INI');
     SQL.Add('   AND CAPA.PD_EMISSAO <= :FIM');
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

procedure TFrmSmZeuGrupoSuperMais.GerarNFitensClientes;
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

procedure TFrmSmZeuGrupoSuperMais.GerarNFitensFornec;
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
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN '+CbxLoja.Text+' = 1 THEN CAPA.PD_EMITENTE   ');
     SQL.Add('           ELSE CAPA.PD_EMITENTE + 200000   ');
     SQL.Add('       END AS COD_FORNECEDOR,   ');
     SQL.Add('         ');
     SQL.Add('       CAPA.LANCTO AS NUM_NF_FORN,   ');
     SQL.Add('       COALESCE(C_CAPA.SERIE, 1) AS NUM_SERIE_NF,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN '+CbxLoja.Text+' = 1 THEN PRODUTO.COD   ');
     SQL.Add('           ELSE PRODUTO.COD + 2000000    ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       1 AS COD_TRIBUTACAO,   ');
     SQL.Add('       ITENS.UNIDADE_Q AS QTD_EMBALAGEM,   ');
     SQL.Add('       ITENS.QUANTIDADE AS QTD_ENTRADA,   ');
     SQL.Add('       ITENS.UNIDADE AS DES_UNIDADE,   ');
     SQL.Add('       ITENS.VLR_UNITARIO AS VAL_TABELA,   ');
     SQL.Add('       ITENS.VLR_DESCONTO AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       ITENS.VLR_ACRESCIMO AS VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       0 AS VAL_IPI_ITEM,   ');
     SQL.Add('       0 AS VAL_SUBST_ITEM,   ');
     SQL.Add('       ITENS.VLR_FRETE AS VAL_FRETE_ITEM,   ');
     SQL.Add('       0 AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       ITENS.VLR_TOTAL_BRUTO AS VAL_TABELA_LIQ,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNEC.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       0 AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('       ITENS.CFOP AS CFOP,   ');
     SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
     SQL.Add('       0 AS VAL_TOT_BC_ST,   ');
     SQL.Add('       0 AS VAL_TOT_ST,   ');
     SQL.Add('       ITENS.ITEM AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('          ');
     SQL.Add('       CASE          ');
     SQL.Add('           WHEN P_FISCAL.NCM = '''' THEN ''99999999''         ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''00000000'' THEN ''99999999''          ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''0'' THEN ''99999999''          ');
     SQL.Add('           ELSE COALESCE(P_FISCAL.NCM, ''99999999'')           ');
     SQL.Add('       END AS NUM_NCM,            ');
     SQL.Add('      ');
     SQL.Add('       '''' AS DES_REFERENCIA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_MV_ES_IT_NR AS ITENS   ');
     SQL.Add('   LEFT JOIN SM_MV_ES_CB_NR AS CAPA ON CAPA.LANCTO = ITENS.LANCTO AND CAPA.EMPRESA = ITENS.EMPRESA   ');
     SQL.Add('   LEFT JOIN SM_MV_ES_EF_NR AS C_CAPA ON C_CAPA.LANCTO = CAPA.LANCTO AND C_CAPA.EMPRESA = CAPA.EMPRESA   ');
     SQL.Add('   LEFT JOIN SM_CD_MO_MOVIMENTADOR AS FORNEC ON FORNEC.COD = CAPA.PD_EMITENTE   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO AS PRODUTO ON PRODUTO.COD = ITENS.PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FISCAL AS P_FISCAL ON P_FISCAL.COD = ITENS.PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = ITENS.PRODUTO   ');
     SQL.Add('   WHERE (   ');
     SQL.Add('       (   ');
     SQL.Add('           '+CbxLoja.Text+' = 1 AND (FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5''))   ');
     SQL.Add('           OR   ');
     SQL.Add('           '+CbxLoja.Text+' = 2 AND (FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')   ');
     SQL.Add('           AND FORNEC.PD_CNPJ_CPF NOT IN (SELECT FORNECEDOR_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR_LJ1 FORNECEDOR_LJ1 WHERE FORNECEDOR_LJ1.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')))   ');
     SQL.Add('       )   ');
     SQL.Add('   )   ');
     SQL.Add('   AND (   ');
     SQL.Add('       (   ');
     SQL.Add('           '+CbxLoja.Text+' = 1 AND (CHAR_LENGTH(COD_BARRAS.BARRAS) < 14)   ');
     SQL.Add('           OR   ');
     SQL.Add('           '+CbxLoja.Text+' = 2 AND (   ');
     SQL.Add('               COD_BARRAS.BARRAS NOT IN (SELECT COD_BARRAS_LJ1.BARRAS FROM SM_CD_ES_PRODUTO_BAR_LJ1 COD_BARRAS_LJ1)   ');
     SQL.Add('               AND CHAR_LENGTH(COD_BARRAS.BARRAS) >= 8   ');
     SQL.Add('               AND CHAR_LENGTH(COD_BARRAS.BARRAS) < 14   ');
     SQL.Add('           )   ');
     SQL.Add('       )   ');
     SQL.Add('   )   ');
     SQL.Add('   AND CAPA.PD_EMISSAO >= :INI  ');
     SQL.Add('   AND CAPA.PD_EMISSAO <= :FIM  ');
     //SQL.Add('   ORDER BY NUM_ITEM   ');

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

procedure TFrmSmZeuGrupoSuperMais.GerarProdForn;
var
   TotalCount, NEW_CODPROD : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;
//
//     SQL.Add('   SELECT DISTINCT   ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
//     SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
//     SQL.Add('       END AS COD_PRODUTO,   ');
//     SQL.Add('       AGENTES.CODIGO_PESSOA AS COD_FORNECEDOR,   ');
//     SQL.Add('       CASE WHEN FORNXCODPROD.CODIGO = '''' THEN ''AAA999'' ELSE COALESCE(FORNXCODPROD.CODIGO, ''AAA999'' ) END AS DES_REFERENCIA,   ');
//     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.DOC, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
//     SQL.Add('       0 AS COD_DIVISAO,   ');
//     SQL.Add('      ');
//     SQL.Add('       CASE       ');
//     SQL.Add('           WHEN PRODUTOS.UNIDADE = 17 THEN ''UN''   ');
//     SQL.Add('           WHEN PRODUTOS.UNIDADE = 18 THEN ''KG''   ');
//     SQL.Add('           WHEN PRODUTOS.UNIDADE = 33001 THEN ''PC''   ');
//     SQL.Add('           WHEN PRODUTOS.UNIDADE = 34001 THEN ''FD''   ');
//     SQL.Add('           WHEN PRODUTOS.UNIDADE = 21001 THEN ''LT''   ');
//     SQL.Add('           ELSE ''UN''    ');
//     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
//     SQL.Add('      ');
//     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
//     SQL.Add('       0 AS QTD_TROCA,   ');
//     SQL.Add('       '''' AS FLG_PREFERENCIAL    ');
//     SQL.Add('   FROM   ');
//     SQL.Add('       FORNXCODPROD   ');
//     SQL.Add('   LEFT JOIN PRODUTOS ON PRODUTOS.ID = FORNXCODPROD.PROD   ');
//     SQL.Add('   LEFT JOIN VFORNS AS FORNECEDOR ON FORNECEDOR.ID = FORNXCODPROD.FORN   ');
//     SQL.Add('   LEFT JOIN AGENTES ON AGENTES.ID = FORNXCODPROD.FORN   ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           PRODUTO,   ');
//     SQL.Add('           EAN   ');
//     SQL.Add('       FROM   ');
//     SQL.Add('           EANS   ');
//     SQL.Add('       --WHERE PRINCIPAL = 0                  ');
//     SQL.Add('   ) AS COD_EAN   ');
//     SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');

       SQL.Add('           SELECT DISTINCT      ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 AND BALANCA.ID IS NOT NULL THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
       SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
       SQL.Add('       END AS COD_PRODUTO,   ');
       SQL.Add('               AGENTES.CODIGO_PESSOA AS COD_FORNECEDOR,      ');
       SQL.Add('               CASE WHEN FORNXCODPROD.CODIGO = '''' THEN ''AAA999'' ELSE COALESCE(FORNXCODPROD.CODIGO, ''AAA999'') END AS DES_REFERENCIA,   ');
       SQL.Add('               COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.DOC, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
       SQL.Add('               0 AS COD_DIVISAO,      ');
       SQL.Add('                 ');
       SQL.Add('               CASE          ');
       SQL.Add('                   WHEN PRODUTOS.UNIDADE = 17 THEN ''UN''      ');
       SQL.Add('                   WHEN PRODUTOS.UNIDADE = 18 THEN ''KG''      ');
       SQL.Add('                   WHEN PRODUTOS.UNIDADE = 33001 THEN ''PC''      ');
       SQL.Add('                   WHEN PRODUTOS.UNIDADE = 34001 THEN ''FD''      ');
       SQL.Add('                   WHEN PRODUTOS.UNIDADE = 21001 THEN ''LT''      ');
       SQL.Add('                   ELSE ''UN''       ');
       SQL.Add('               END AS DES_UNIDADE_COMPRA,      ');
       SQL.Add('                 ');
       SQL.Add('               COALESCE(QTDECXPROD_UNID_FORN.qtde_por_cx, 1) AS QTD_EMBALAGEM_COMPRA,      ');
       SQL.Add('               0 AS QTD_TROCA,      ');
       SQL.Add('               '''' AS FLG_PREFERENCIAL       ');
       SQL.Add('           FROM      ');
       SQL.Add('               QTDECXPROD_UNID_FORN   ');
       SQL.Add('           LEFT JOIN PRODUTOS ON PRODUTOS.ID = QTDECXPROD_UNID_FORN.IDPROD   ');
       SQL.Add('           LEFT JOIN VFORNS AS FORNECEDOR ON FORNECEDOR.ID = QTDECXPROD_UNID_FORN.IDFORN   ');
       SQL.Add('           LEFT JOIN AGENTES ON AGENTES.ID = QTDECXPROD_UNID_FORN.IDFORN   ');
       SQL.Add('LEFT JOIN FORNXCODPROD ON FORNXCODPROD.FORN = QTDECXPROD_UNID_FORN.IDFORN AND QTDECXPROD_UNID_FORN.IDPROD = FORNXCODPROD.PROD');
       SQL.Add('           LEFT JOIN(      ');
       SQL.Add('               SELECT DISTINCT      ');
       SQL.Add('                   PRODUTO,      ');
       SQL.Add('                   EAN      ');
       SQL.Add('               FROM      ');
       SQL.Add('                   EANS      ');
       SQL.Add('              WHERE ATIVO <> 0     ');
       SQL.Add('           ) AS COD_EAN      ');
       SQL.Add('           ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
       SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           ID   ');
     SQL.Add('       FROM   ');
     SQL.Add('           EC_EXPT_PRODUTO   ');
     SQL.Add('       WHERE BALANCA_CODIGO IS NOT NULL   ');
     SQL.Add('   ) AS BALANCA   ');
     SQL.Add('   ON BALANCA.ID = PRODUTOS.ID   ');
       SQL.Add('           WHERE QTDECXPROD_UNID_FORN.IDPROD IS NOT NULL   ');
       SQL.Add('           AND PRODUTOS.CODIGO_PRODUTO IS NOT NULL   ');
       //SQL.Add('   AND PRODUTOS.ATIVO = 1   ');






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

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;

end;

procedure TFrmSmZeuGrupoSuperMais.GerarProdLoja;
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

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CHAR_LENGTH(TRIM(LEADING ''0'' FROM COD_EAN.EAN)) <= 5 AND BALANCA.ID IS NOT NULL THEN TRIM(LEADING ''0'' FROM COD_EAN.EAN)   ');
     SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO    ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       VALORESPROD.CUSTO AS VAL_CUSTO_REP,   ');
     SQL.Add('       VALORESPROD.PRECO AS VAL_VENDA,   ');
     SQL.Add('       0 AS VAL_OFERTA,   ');
     SQL.Add('       COALESCE(EST.QTDE_EST, 1) AS QTD_EST_VDA,   ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 25   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''2.7000'' THEN 41   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 28   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 11   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.6000'' THEN 42   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 12   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 43   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 13   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''20.0000'' THEN 29   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''25.0000'' THEN 14   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''27.0000'' THEN 44   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''40.0000'' THEN 45   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''12'' AND ICMS.DES_ICMS = ''N'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 23   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 2   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 8   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 7   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 27   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 46   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 4   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIBUTACAO,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS VAL_MARGEM,   ');
     SQL.Add('       1 AS QTD_ETIQUETA,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 25   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''2.7000'' THEN 41   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 28   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 11   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''7.6000'' THEN 42   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 12   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 43   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 13   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''20.0000'' THEN 29   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''25.0000'' THEN 14   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''27.0000'' THEN 44   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''10'' AND ICMS.DES_ICMS = ''F'' AND ICMS.VAL_ICMS = ''40.0000'' THEN 45   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''11'' AND ICMS.DES_ICMS = ''I'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 1   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''12'' AND ICMS.DES_ICMS = ''N'' AND ICMS.VAL_ICMS = ''0.0000'' THEN 23   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''7.0000'' THEN 2   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''13'' AND ICMS.DES_ICMS = ''T07'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 8   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''14'' AND ICMS.DES_ICMS = ''T12'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 7   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''4.0000'' THEN 27   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''12.0000'' THEN 3   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''15.0000'' THEN 46   ');
//     SQL.Add('           WHEN ICMS.ID_ICMS = ''15'' AND ICMS.DES_ICMS = ''T18'' AND ICMS.VAL_ICMS = ''18.0000'' THEN 4   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ATIVO = 1 THEN ''N''   ');
     SQL.Add('           ELSE ''S''   ');
     SQL.Add('       END AS FLG_INATIVO,   ');
     SQL.Add('          ');
     SQL.Add('       PRODUTOS.ID AS COD_PRODUTO_ANT,   ');
//     SQL.Add('       COALESCE(CFPROD.CODIGO, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('       ''99999999'' AS NUM_NCM,   ');
     SQL.Add('       0 AS TIPO_NCM,   ');
     SQL.Add('       0 AS VAL_VENDA_2,   ');
     SQL.Add('       '''' AS DTA_VALIDA_OFERTA,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ESTQMIN = 0 THEN 1   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.ESTQMIN, 1)   ');
     SQL.Add('       END AS QTD_EST_MINIMO,   ');
     SQL.Add('          ');
     SQL.Add('       NULL AS COD_VASILHAME,   ');
     SQL.Add('       ''N'' AS FORA_LINHA,   ');
     SQL.Add('       0 AS QTD_PRECO_DIF,   ');
     SQL.Add('       0 AS VAL_FORCA_VDA,   ');
     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
//     SQL.Add('       COALESCE(REPLACE(PRODST.COD_CEST, ''.'', ''''), ''9999999'')AS NUM_CEST,   ');
//     SQL.Add('       COALESCE(V_PRODS.MVA, 0) AS PER_IVA,   ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST,   ');
     SQL.Add('       0 AS PER_FIDELIDADE,   ');
     SQL.Add('       0 AS COD_INFO_RECEITA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTOS   ');
     SQL.Add('   LEFT JOIN VPRODS AS V_PRODS ON V_PRODS.ID = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN VALORESPROD ON VALORESPROD.IDPROD = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN CFPROD ON CFPROD.ID = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN PRODST ON PRODST.ID = PRODUTOS.ID AND PRODST.ID = CFPROD.ID   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       --ICMS   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           OBJETOS.ID AS ID_ICMS,   ');
     SQL.Add('           OBJETOS.DESCRICAO AS DES_ICMS,   ');
     SQL.Add('           VPRODS.VALIQ AS VAL_ICMS,   ');
     SQL.Add('           VPRODS.ID AS ID_PROD   ');
     SQL.Add('       FROM    ');
     SQL.Add('           OBJETOS   ');
     SQL.Add('       LEFT JOIN VPRODS ON VPRODS.TRIB = OBJETOS.ID   ');
     SQL.Add('       WHERE OBJETOS.ID IN (10,11,12,13,14,15)   ');
     SQL.Add('   ) AS ICMS   ');
     SQL.Add('   ON PRODUTOS.TRIB = ICMS.ID_ICMS AND PRODUTOS.ID = ICMS.ID_PROD   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           IDPROD AS ID_PROD_EST,   ');
     SQL.Add('           EMPRESA,   ');
     SQL.Add('           DEPOSITO,   ');
     SQL.Add('           QTDE AS QTDE_EST   ');
     SQL.Add('       FROM   ');
     SQL.Add('           ESTOQUE   ');
     SQL.Add('       WHERE ESTOQUE.EMPRESA = 1   ');
     SQL.Add('       AND ESTOQUE.DEPOSITO = 1   ');
     SQL.Add('   ) AS EST   ');
     SQL.Add('   ON EST.ID_PROD_EST = PRODUTOS.ID   ');
     SQL.Add('   LEFT JOIN(   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           PRODUTO,   ');
     SQL.Add('           EAN   ');
     SQL.Add('       FROM   ');
     SQL.Add('           EANS   ');
     SQL.Add('       WHERE ATIVO <> 0      ');
     SQL.Add('   ) AS COD_EAN   ');
     SQL.Add('   ON PRODUTOS.ID = COD_EAN.PRODUTO   ');
     SQL.Add('   LEFT JOIN (   ');
     SQL.Add('       SELECT DISTINCT   ');
     SQL.Add('           ID   ');
     SQL.Add('       FROM   ');
     SQL.Add('           EC_EXPT_PRODUTO   ');
     SQL.Add('       WHERE BALANCA_CODIGO IS NOT NULL   ');
     SQL.Add('   ) AS BALANCA   ');
     SQL.Add('   ON BALANCA.ID = PRODUTOS.ID   ');
     SQL.Add('   WHERE VALORESPROD.EMPRESA = 1   ');
     SQL.Add('   AND V_PRODS.EMPRESA = 1   ');
     //SQL.Add('   AND PRODUTOS.ATIVO = 1   ');





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

procedure TFrmSmZeuGrupoSuperMais.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       P_SIMILAR.CODIGO AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('       P_SIMILAR.DESCRICAO AS DES_PRODUTO_SIMILAR,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SEMELHANCAS AS P_SIMILAR   ');
     SQL.Add('   LEFT JOIN SEMELHANTES AS P_PROD_SIMILAR ON P_PROD_SIMILAR.ID = P_SIMILAR.ID   ');
//     SQL.Add('   left join produtos on produtos.id = p_similar.id   ');
//     SQL.Add('   where produtos.ativo = 1   ');

     //SQL.Add('   WHERE P_SIMILAR.EMPRESA = 1   ');





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
