unit UFrmSmVia;

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
  TFrmSmVia = class(TFrmModeloSis)
    CbxLoja: TComboBox;
    lblLoja: TLabel;
    ADOMySQL: TADOConnection;
    QryPrincipal2: TADOQuery;
    QryAux: TADOQuery;
    Label11: TLabel;
    btnGeraValorVenda: TButton;
    btnGeraCustoRep: TButton;
    btnGerarEstoqueAtual: TButton;
    btnGeraPromocao: TButton;
    btnGeraUpdateInativo: TButton;
    procedure btnGeraCestClick(Sender: TObject);
    procedure BtnAmarrarCestClick(Sender: TObject);
    procedure BtnGerarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGeraValorVendaClick(Sender: TObject);
    procedure btnGeraCustoRepClick(Sender: TObject);
    procedure btnGerarEstoqueAtualClick(Sender: TObject);
    procedure CkbProdLojaClick(Sender: TObject);
    procedure btnGeraPromocaoClick(Sender: TObject);
    procedure btnGeraUpdateInativoClick(Sender: TObject);
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
    procedure GeraPromocao;
    procedure GeraUpdateInativo;

  end;

var
  FrmSmVia: TFrmSmVia;
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
  FlgAtualizaPromocao : Boolean = False;
  FlgAtualizaInativo  : Boolean = False;

implementation

{$R *.dfm}

uses xProc, UUtilidades, UProgresso;


procedure TFrmSmVia.GerarProducao;
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

procedure TFrmSmVia.GerarProduto;
var
  NEW_CODPROD, TotalCount : Integer;
  QryGeraCodigoProduto : TSQLQuery;
begin
  inherited;

  //Cria coluna na tabela para auxiliar no c�digo PLU

//  QryGeraCodigoProduto := TSQLQuery.Create(FrmProgresso);
//  with QryGeraCodigoProduto do
//  begin
//    SQLConnection := ScnBanco;
//
//    SQL.Clear;
//    SQL.Add('ALTER TABLE PRODUTO');
//    SQL.Add('ADD CODIGO_PRODUTO INT DEFAULT NULL;');
//
//    try
//      ExecSQL();
//    except
//    end;
//
//    SQL.Clear;
//    SQL.Add('UPDATE PRODUTO');
//    SQL.Add('SET CODIGO_PRODUTO = :COD_PRODUTO');
//    SQL.Add('WHERE EAN = :COD_BARRA_PRINCIPAL');
//    SQL.Add('AND CHAR_LENGTH(CODIGO) > 7');
//
//    try
//      ExecSQL;
//    except
//    end;
//  end;



  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT      ');
     //SQL.Add('       PRODUTO.CODIGO AS COD_PRODUTO,      ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')     ');
     SQL.Add('   		     ELSE PRODUTO.CODIGO   ');
     SQL.Add('   	   END AS COD_PRODUTO,  ');
     SQL.Add('       PRODUTO.EAN AS COD_BARRA_PRINCIPAL,      ');
     SQL.Add('       PRODUTO.NOMEECF AS DES_REDUZIDA,      ');
     SQL.Add('       PRODUTO.NOME AS DES_PRODUTO,      ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,      ');
     SQL.Add('       COALESCE(PRODUTO.UNIDADEMEDIDA, ''UN'') AS DES_UNIDADE_COMPRA,      ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,      ');
     SQL.Add('       COALESCE(PRODUTO.UNIDADEMEDIDA, ''UN'') AS DES_UNIDADE_VENDA,      ');
     SQL.Add('       0 AS TIPO_IPI,      ');
     SQL.Add('       PRODUTO.IPI AS VAL_IPI,      ');
     SQL.Add('   	   COALESCE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 5, 2)), ''999'') AS COD_SECAO,   ');
     SQL.Add('       ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN TRIM(SUBSTRING(HIERARQUIA.CODIGO, 10, 3)) = '''' THEN ''999''   ');
     SQL.Add('   		     ELSE COALESCE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 10, 3)), ''999'')    ');
     SQL.Add('   	   END AS COD_GRUPO,   ');
     SQL.Add('   	   ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN REPLACE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 14, 11)), '' '', '''') = '''' THEN ''999''   ');
     SQL.Add('   		     ELSE COALESCE(REPLACE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 14, 11)), '' '', ''''), ''999'')    ');
     SQL.Add('   	   END AS COD_SUB_GRUPO,   ');
     SQL.Add('       ');
     SQL.Add('   	   ');
     SQL.Add('       COALESCE(PRODUTO.IDFAMILIA, 0) AS COD_PRODUTO_SIMILAR,      ');
     SQL.Add('         ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTO.PESAVEL = 1 THEN ''S''      ');
     SQL.Add('           ELSE ''N''       ');
     SQL.Add('       END AS IPV,      ');
     SQL.Add('         ');
     SQL.Add('       COALESCE(produto.diasvencimento, 0) AS DIAS_VALIDADE,      ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''08'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''      ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTO.PESAVEL = 1 THEN ''S''      ');
     SQL.Add('           ELSE ''N''       ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,      ');
     SQL.Add('         ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''04'' THEN 1   ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''06'' THEN 0   ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''08'' THEN 3   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,      ');
     SQL.Add('          ');
     SQL.Add('       0 AS TIPO_EVENTO,      ');
     SQL.Add('       0 AS COD_ASSOCIADO,      ');
     SQL.Add('       COALESCE(PRODUTO.OBSERVACAO, '''') AS DES_OBSERVACAO,      ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,      ');
     SQL.Add('       COALESCE(COALESCE(PRODUTO.naturezareceita, PRODUTO.codigoreceitasemcontribuicao), ''999'') AS COD_TAB_SPED,      ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO,      ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.TIPOPRODUTO = ''01'' THEN 4   ');
     SQL.Add('           WHEN PRODUTO.TIPOPRODUTO = ''08'' THEN 2   ');
     SQL.Add('           WHEN PRODUTO.TIPOPRODUTO = ''10'' THEN 4   ');
     SQL.Add('           ELSE 0   ');
     SQL.Add('       END AS TIPO_ESPECIE,      ');
     SQL.Add('      ');
     SQL.Add('       0 AS COD_CLASSIF,      ');
     SQL.Add('       1 AS VAL_VDA_PESO_BRUTO,      ');
     SQL.Add('       1 AS VAL_PESO_EMB,      ');
     SQL.Add('       0 AS TIPO_EXPLOSAO_COMPRA,      ');
     SQL.Add('       '''' AS DTA_INI_OPER,      ');
     SQL.Add('       '''' AS DES_PLAQUETA,      ');
     SQL.Add('       '''' AS MES_ANO_INI_DEPREC,      ');
     SQL.Add('       0 AS TIPO_BEM,      ');
     SQL.Add('       COALESCE(FORNECEDOR.CODIGO, ''0'') AS COD_FORNECEDOR,      ');
     SQL.Add('       0 AS NUM_NF,      ');
     SQL.Add('       PRODUTO.DATACADASTRO AS DTA_ENTRADA,      ');
     SQL.Add('       0 AS COD_NAT_BEM,      ');
     SQL.Add('       0 AS VAL_ORIG_BEM,      ');
     SQL.Add('       PRODUTO.NOME AS DES_PRODUTO_ANT      ');
     SQL.Add('   FROM      ');
     SQL.Add('       PRODUTO      ');
     SQL.Add('   LEFT JOIN ENTIDADE AS FORNECEDOR ON FORNECEDOR.ID = PRODUTO.IDFORNECEDOR      ');
     SQL.Add('   LEFT JOIN UNIDADEMEDIDA ON UNIDADEMEDIDA.ID = PRODUTO.IDUNIDADEMEDIDA      ');
     SQL.Add('   LEFT JOIN HIERARQUIA ON HIERARQUIA.ID = PRODUTO.IDHIERARQUIA   ');
//     SQL.Add('   		WHERE PRODUTO.CODIGO_PRODUTO >= ''354580''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO <= ''354639''   ');

     //SQL.Add('   ORDER BY PRODUTO.INATIVO   ');






    Open;

    First;
    NumLinha := 0;
//    NEW_CODPROD := 100000;

//    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      //Inc(NEW_CODPROD);
      Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);


//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        with QryGeraCodigoProduto do
//        begin
//          Params.ParamByName('COD_PRODUTO').Value := NEW_CODPROD;
//          Params.ParamByName('COD_BARRA_PRINCIPAL').Value := Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString;
//          Layout.FieldByName('COD_PRODUTO').AsInteger := Params.ParamByName('COD_PRODUTO').Value;
//          ExecSQL();
//        end;
//      end;

//        if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//        begin
//          Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
//        end;

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


procedure TFrmSmVia.GerarSecao;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

//     SQL.Add('   SELECT   ');
//     SQL.Add('   	TRIM(HIERARQUIA.CODIGO) AS COD_SECAO,    ');
//     SQL.Add('   	HIERARQUIA.NOME AS DES_SECAO,   ');
     //SQL.Add('   	''A DEFINIR'' AS DES_SECAO,   ');
//     SQL.Add('   	0 AS VAL_META   ');
//     SQL.Add('   FROM    ');
//     SQL.Add('       HIERARQUIA   ');
//     SQL.Add('   WHERE LENGTH(TRIM(HIERARQUIA.CODIGO)) IN (1,2)   ');
//     SQL.Add('   --ORDER BY HIERARQUIA.CODIGO   ');


       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('   	  COALESCE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 5, 2)), ''999'') AS COD_SECAO,   ');
       SQL.Add('   	  COALESCE(HIERARQUIA.NOME, ''A DEFINIR'') AS DES_SECAO,   ');
       SQL.Add('   	  0 AS VAL_META   ');
       SQL.Add('   FROM   ');
       SQL.Add('   	  HIERARQUIA   ');
       SQL.Add('   WHERE HIERARQUIA.CLASSE = 1   ');







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

procedure TFrmSmVia.GerarSubGrupo;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

//     SQL.Add('   SELECT DISTINCT   ');
//     SQL.Add('   	  COALESCE(SUBSTRING(TRIM(HIERARQUIA.CODIGO), 1, 2), ''999'') AS COD_SECAO,   ');
//     SQL.Add('   	   CASE   ');
//     SQL.Add('   		     WHEN COALESCE(SUBSTRING(TRIM(HIERARQUIA.CODIGO), 5, 6), ''999'') = '''' THEN ''999''   ');
//     SQL.Add('           ELSE CAST(COALESCE(SUBSTRING(TRIM(HIERARQUIA.CODIGO), 5, 6), ''999'') AS INTEGER)    ');
//     SQL.Add('   	   END AS COD_GRUPO,   ');
//     SQL.Add('       CASE   ');
//     SQL.Add('   		     WHEN COALESCE(SUBSTRING(TRIM(HIERARQUIA.CODIGO), 9, 7), ''999'') = '''' THEN ''999''   ');
//     SQL.Add('       	   ELSE CAST(COALESCE(SUBSTRING(TRIM(HIERARQUIA.CODIGO), 9, 7), ''999'') AS INTEGER)   ');
//     SQL.Add('   	   END AS COD_SUB_GRUPO,   ');
//     SQL.Add('      COALESCE(HIERARQUIA.NOME, ''A DEFINIR'') AS DES_SUB_GRUPO,   ');
     //SQL.Add('      ''A DEFINIR'' AS DES_SUB_GRUPO,   ');
//     SQL.Add('      0 AS VAL_META,   ');
//     SQL.Add('      0 AS VAL_MARGEM_REF,   ');
//     SQL.Add('      0 AS QTD_DIA_SEGURANCA,   ');
//     SQL.Add('      ''N'' AS FLG_ALCOOLICO   ');
//     SQL.Add('   FROM    ');
//     SQL.Add('   	  HIERARQUIA   ');
//     SQL.Add('   WHERE SUBSTRING(TRIM(HIERARQUIA.CODIGO), 5, 6) <> ''''   ');
//     SQL.Add('   AND SUBSTRING(TRIM(HIERARQUIA.CODIGO), 9, 7) <> ''''   ');


       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('   	  COALESCE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 5, 2)), ''999'') AS COD_SECAO,   ');
       SQL.Add('       ');
       SQL.Add('   	  CASE   ');
       SQL.Add('   		  WHEN TRIM(SUBSTRING(HIERARQUIA.CODIGO, 10, 3)) = '''' THEN ''999''   ');
       SQL.Add('   		  ELSE COALESCE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 10, 3)), ''999'')    ');
       SQL.Add('   	  END AS COD_GRUPO,   ');
       SQL.Add('   	   ');
       SQL.Add('   	  CASE   ');
       SQL.Add('   		  WHEN REPLACE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 14, 11)), '' '', '''') = '''' THEN ''999''   ');
       SQL.Add('   		  ELSE COALESCE(REPLACE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 14, 11)), '' '', ''''), ''999'')    ');
       SQL.Add('   	  END AS COD_SUB_GRUPO,   ');
       SQL.Add('       ');
       SQL.Add('   	  COALESCE(HIERARQUIA.NOME, ''A DEFINIR'') AS DES_SUB_GRUPO,   ');
       SQL.Add('   	  0 AS VAL_META,   ');
       SQL.Add('   	  0 AS VAL_MARGEM_REF,   ');
       SQL.Add('    	0 AS QTD_DIA_SEGURANCA,   ');
       SQL.Add('   	  ''N'' AS FLG_ALCOOLICO   ');
       SQL.Add('   FROM   ');
       SQL.Add('   	  HIERARQUIA   ');
       SQL.Add('   WHERE HIERARQUIA.CLASSE = 3   ');


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

procedure TFrmSmVia.GerarValorVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('     PROG.IDFILIAL AS COD_LOJA,   ');
     SQL.Add('     --SQL2.IDPROGRAMACAO,   ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')     ');
     SQL.Add('   		     ELSE PRODUTO.CODIGO   ');
     SQL.Add('   	   END AS COD_PRODUTO,  ');
     SQL.Add('     PROGITEM.NOVOPRECOPRODUTO AS VAL_VENDA   ');
     SQL.Add('     --PROG.DATAPRECOALTERADO   ');
     SQL.Add('   FROM (   ');
     SQL.Add('     SELECT   ');
     SQL.Add('       MAX(id) AS IDPROGRAMACAO,   ');
     SQL.Add('       IDPRODUTO   ');
     SQL.Add('     FROM (   ');
     SQL.Add('       SELECT   ');
     SQL.Add('         IDPRODUTO,   ');
     SQL.Add('         PROG.ID,   ');
     SQL.Add('         PROG.IDFILIAL,   ');
     SQL.Add('         PROG.DATAPRECOALTERADO   ');
     SQL.Add('       FROM programacaoalteracaoprecoitem AS PROGITEM   ');
     SQL.Add('       INNER JOIN programacaoalteracaopreco AS PROG    ');
     SQL.Add('       ON PROGITEM.IDPROGRAMACAO = PROG.ID   ');
     SQL.Add('       WHERE PROG.STATUS = 3    ');
     SQL.Add('       -- AND  IDPRODUTO = ''110669''   ');
     SQL.Add('     ) SQL1   ');
     SQL.Add('     GROUP BY IDFILIAL, IDPRODUTO   ');
     SQL.Add('   ) SQL2   ');
     SQL.Add('   INNER JOIN programacaoalteracaopreco AS PROG    ');
     SQL.Add('   ON SQL2.IDPROGRAMACAO = PROG.ID   ');
     SQL.Add('   INNER JOIN programacaoalteracaoprecoitem AS PROGITEM   ');
     SQL.Add('   ON SQL2.IDPROGRAMACAO = PROGITEM.IDPROGRAMACAO   ');
     SQL.Add('   AND SQL2.IDPRODUTO = PROGITEM.IDPRODUTO   ');
     SQL.Add('   INNER JOIN PRODUTO    ');
     SQL.Add('   ON PROGITEM.IDPRODUTO = PRODUTO.ID   ');
     SQL.Add('   WHERE   ');
     SQL.Add('   PRODUTO.INATIVO = 0   ');
     SQL.Add('   AND PROG.IDFILIAL = '''+CbxLoja.Text+'''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO >= ''354580''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO <= ''354639''   ');
     SQL.Add('   ORDER BY PRODUTO.CODIGO, PROG.IDFILIAL   ');





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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_VENDA = '''+QryPrincipal2.FieldByName('VAL_VENDA').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' AND COD_LOJA = '+CbxLoja.Text+' ; ');


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

procedure TFrmSmVia.GerarVenda;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')      ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')        ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')        ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')        ');
     SQL.Add('           ELSE PRODUTO.CODIGO      ');
     SQL.Add('       END AS COD_PRODUTO,     ');
     SQL.Add('      ');
     SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
     SQL.Add('       0 AS IND_TIPO,   ');
     SQL.Add('       COALESCE(VENDAS.PDV, 0) AS NUM_PDV,   ');
     SQL.Add('       VENDAS.QUANTIDADE AS QTD_TOTAL_PRODUTO,   ');
     SQL.Add('       VENDAS.TOTAL AS VAL_TOTAL_PRODUTO,   ');
     SQL.Add('       VENDAS.PRECOUNITARIO AS VAL_PRECO_VENDA,   ');
     SQL.Add('       COALESCE(TOTAL_ESTOQUE_VIEW.PRECOCUSTO, 0) AS VAL_CUSTO_REP,   ');
     SQL.Add('       VENDAS.EMISSAO AS DTA_SAIDA,   ');
     SQL.Add('       COALESCE(SUBSTRING(CAST(VENDAS.EMISSAO AS VARCHAR), 6, 2) || SUBSTRING(CAST(VENDAS.EMISSAO AS VARCHAR), 1, 4), '''') AS DTA_MENSAL,   ');
     SQL.Add('       VENDAS.IDITEM AS NUM_IDENT,   ');
     SQL.Add('       PRODUTO.EAN AS COD_EAN,   ');
     SQL.Add('       COALESCE(SUBSTRING(CAST(VENDAS.DATAHORAEMISSAO AS VARCHAR), 12, 2) || SUBSTRING(CAST(VENDAS.DATAHORAEMISSAO AS VARCHAR), 15, 2), '''') AS DES_HORA,   ');
     SQL.Add('       99999 AS COD_CLIENTE,   ');
     SQL.Add('       1 AS COD_ENTIDADE,   ');
     SQL.Add('       0 AS VAL_BASE_ICMS,   ');
     SQL.Add('       '''' AS DES_SITUACAO_TRIB,   ');
     SQL.Add('       0 AS VAL_ICMS,   ');
     SQL.Add('       VENDAS.DOCUMENTO AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       VENDAS.PRECOUNITARIO AS VAL_VENDA_PDV,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA IS NULL THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 3      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8300'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 50      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''48.2400'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 42      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6700'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 2      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''4.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''82.3500'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 40      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''27.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 45      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 46      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''29.4100'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 47      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 39      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 48      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 51      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 5      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 39      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 48      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''67.0600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 49      ');
     SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 5      ');
     SQL.Add('           ELSE 1   ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       ''N'' AS FLG_CUPOM_CANCELADO,   ');
     SQL.Add('       PRODUTO.NCM AS NUM_NCM,   ');
     SQL.Add('       COALESCE(COALESCE(PRODUTO.naturezareceita, PRODUTO.codigoreceitasemcontribuicao), ''999'') AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''04'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''06'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''08'' THEN ''S''      ');
     SQL.Add('           ELSE ''N''         ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''04'' THEN 1      ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''06'' THEN 0      ');
     SQL.Add('           WHEN PRODUTO.CSTPIS = ''08'' THEN 3      ');
     SQL.Add('           ELSE -1      ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       ''S'' AS FLG_ONLINE,   ');
     SQL.Add('       ''N'' AS FLG_OFERTA,   ');
     SQL.Add('       0 AS COD_ASSOCIADO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       VENDAS_ITENS_VIEW AS VENDAS   ');
     SQL.Add('   LEFT JOIN PRODUTO ON PRODUTO.CODIGO = VENDAS.PRODUTO   ');
     SQL.Add('   LEFT JOIN TOTAL_ESTOQUE_VIEW ON TOTAL_ESTOQUE_VIEW.IDPRODUTO = PRODUTO.ID   ');
     SQL.Add('   WHERE VENDAS.FILIAL = '''+CbxLoja.Text+'''   ');
     SQL.Add('   AND TOTAL_ESTOQUE_VIEW.IDFILIAL = '''+CbxLoja.Text+'''   ');
     SQL.Add('   AND');
     SQL.Add('      VENDAS.EMISSAO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('   AND');
     SQL.Add('      VENDAS.EMISSAO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

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

procedure TFrmSmVia.GeraUpdateInativo;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('   SELECT DISTINCT   ');
    SQL.Add('   	  CASE      ');
    SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')      ');
    SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')        ');
    SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')        ');
    SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')        ');
    SQL.Add('           ELSE PRODUTO.CODIGO      ');
    SQL.Add('       END AS COD_PRODUTO,     ');
    SQL.Add('      ');
    SQL.Add('   	  CASE    ');
    SQL.Add('           WHEN PRODUTO.INATIVO = 0 THEN ''N''    ');
    SQL.Add('           ELSE ''S''    ');
    SQL.Add('       END AS FLG_INATIVO   ');
    SQL.Add('   FROM   ');
    SQL.Add('   	  PRODUTO   ');
    SQL.Add('   WHERE INATIVO <> 0   ');


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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET INATIVO = '''+QryPrincipal2.FieldByName('FLG_INATIVO').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+'; ');

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
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
    Writeln(Arquivo, 'COMMIT WORK;');
    Close;
  end;
end;

procedure TFrmSmVia.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmVia.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmVia.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmVia.btnGeraPromocaoClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaPromocao := True;
  BtnGerar.Click;
  FlgAtualizaPromocao := False;
end;

procedure TFrmSmVia.BtnGerarClick(Sender: TObject);
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
     AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_ESTOQUE.TXT' );
     Rewrite(Arquivo);
     CkbProdLoja.Checked := True;
   end;

   if FlgAtualizaPromocao then
   begin
     AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_PROMOCAO.TXT' );
     Rewrite(Arquivo);
     CkbProdLoja.Checked := True;
   end;

   if FlgAtualizaInativo then
   begin
     AssignFile(Arquivo, EdtCamArquivo.Text + '\SCRIPT_ATUALIZA_INATIVOS.TXT' );
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

  if FlgAtualizaPromocao then
    CloseFile(Arquivo);

  if FlgAtualizaInativo then
    CloseFile(Arquivo);
//
//   ADOSQLServer.Connected := false;
end;



procedure TFrmSmVia.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmVia.btnGeraUpdateInativoClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaInativo := True;
  BtnGerar.Click;
  FlgAtualizaInativo := False;
end;

procedure TFrmSmVia.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmVia.CkbProdLojaClick(Sender: TObject);
begin
  inherited;
  btnGeraValorVenda.Enabled := True;
  btnGeraCustoRep.Enabled := True;
  btnGerarEstoqueAtual.Enabled := True;
  btnGeraPromocao.Enabled := True;
  btnGeraUpdateInativo.Enabled := True;

  if CkbProdLoja.Checked = False then
  begin
    btnGeraValorVenda.Enabled := False;
    btnGeraCustoRep.Enabled := False;
    btnGerarEstoqueAtual.Enabled := False;
    btnGeraPromocao.Enabled := False;
    btnGeraUpdateInativo.Enabled := False;
  end;
  
end;

procedure TFrmSmVia.FormCreate(Sender: TObject);
begin
  inherited;

end;

//procedure Dourado.FormCreate(Sender: TObject);
//begin
//  inherited;
////  Left:=(Screen.Width-Width)  div 2;
////  Top:=(Screen.Height-Height) div 2;
//end;

procedure TFrmSmVia.GeraCustoRep;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;


     SQL.Add('   SELECT DISTINCT    ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')     ');
     SQL.Add('   		     ELSE PRODUTO.CODIGO   ');
     SQL.Add('   	   END AS COD_PRODUTO,  ');
     SQL.Add('      ');
     SQL.Add('   	  COALESCE(TOTAL_ESTOQUE_VIEW.PRECOCUSTO, 0) AS VAL_CUSTO_REP   ');
     SQL.Add('   FROM   ');
     SQL.Add('   	  PRODUTO   ');
     SQL.Add('   LEFT JOIN TOTAL_ESTOQUE_VIEW ON TOTAL_ESTOQUE_VIEW.IDPRODUTO = PRODUTO.ID   ');
     SQL.Add('   WHERE TOTAL_ESTOQUE_VIEW.IDFILIAL = '+CbxLoja.Text+'   ');
     SQL.Add('   AND PRODUTO.INATIVO = 0  ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO >= ''354580''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO <= ''354639''   ');



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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_CUSTO_REP = '''+QryPrincipal2.FieldByName('VAL_CUSTO_REP').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' AND COD_LOJA = '+CbxLoja.Text+' ; ');


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

procedure TFrmSmVia.GeraEstoqueVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT    ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')     ');
     SQL.Add('   		     ELSE PRODUTO.CODIGO   ');
     SQL.Add('   	   END AS COD_PRODUTO,  ');
     SQL.Add('      ');
     SQL.Add('   	  COALESCE(TOTAL_ESTOQUE_VIEW.QUANTIDADE, 0) AS QTD_EST_ATUAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('   	  PRODUTO   ');
     SQL.Add('   LEFT JOIN TOTAL_ESTOQUE_VIEW ON TOTAL_ESTOQUE_VIEW.IDPRODUTO = PRODUTO.ID   ');
     SQL.Add('   WHERE TOTAL_ESTOQUE_VIEW.IDFILIAL = '+CbxLoja.Text+'   ');
     SQL.Add('   AND PRODUTO.INATIVO = 0  ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO >= ''354580''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO <= ''354639''   ');



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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET QTD_EST_ATUAL = '''+QryPrincipal2.FieldByName('QTD_EST_ATUAL').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' AND COD_LOJA = '+CbxLoja.Text+' ; ');


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

procedure TFrmSmVia.GeraPromocao;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('   	CASE      ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')      ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')        ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')        ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')        ');
     SQL.Add('           ELSE PRODUTO.CODIGO      ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('   	PROMOCAOPRODUTO.VALOR AS VAL_OFERTA,   ');
     SQL.Add('   	PROMOCAO.DATAFINAL AS DTA_VALIDA_OFERTA   ');
     SQL.Add('   FROM   ');
     SQL.Add('   	PROMOCAOPRODUTO   ');
     SQL.Add('   LEFT JOIN PROMOCAO ON PROMOCAO.ID = PROMOCAOPRODUTO.IDPROMOCAO   ');
     SQL.Add('   LEFT JOIN PRODUTO ON PRODUTO.ID = PROMOCAOPRODUTO.IDPRODUTO   ');
     SQL.Add('   LEFT JOIN PROMOCAOFILIAL ON PROMOCAOFILIAL.CODIGO = PROMOCAOPRODUTO.CODIGO   ');
     SQL.Add('   WHERE PROMOCAOFILIAL.IDFILIAL = '+CbxLoja.Text+'   ');
     SQL.Add('   AND CAST(PROMOCAO.DATAFINAL AS DATE) > ''2021-08-31''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO >= ''354580''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO <= ''354639''   ');


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

        if QryPrincipal2.FieldByName('DTA_VALIDA_OFERTA').AsString <> '' then
          Layout.FieldByName('DTA_VALIDA_OFERTA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VALIDA_OFERTA').AsDateTime);

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_OFERTA = '''+QryPrincipal2.FieldByName('VAL_OFERTA').AsString+''', DTA_VALIDA_OFERTA = '''+QryPrincipal2.FieldByName('DTA_VALIDA_OFERTA').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' AND COD_LOJA = '+CbxLoja.Text+'; ');

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

procedure TFrmSmVia.GerarCest;
var
   count : integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('    SELECT DISTINCT      ');
     SQL.Add('       CEST.ID AS COD_CEST,      ');
     SQL.Add('                     ');
     SQL.Add('       CASE      ');
     SQL.Add('            WHEN CEST.CODIGO = '''' THEN ''9999999''      ');
     SQL.Add('            ELSE COALESCE(CEST.CODIGO, ''9999999'')       ');
     SQL.Add('       END AS NUM_CEST,      ');
     SQL.Add('                     ');
     SQL.Add('       CASE      ');
     SQL.Add('            WHEN CEST.DESCRICAO = '''' THEN ''A DEFINIR''      ');
     SQL.Add('            ELSE COALESCE(CEST.DESCRICAO, ''A DEFINIR'')       ');
     SQL.Add('       END AS DES_CEST      ');
     SQL.Add('    FROM      ');
     SQL.Add('       CEST     ');
     SQL.Add('   	ORDER BY COD_CEST   ');



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

procedure TFrmSmVia.GerarCliente;
begin

   inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTES.CODIGO AS COD_CLIENTE,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.RAZAOSOCIAL = '''' THEN CLIENTES.NOME   ');
     SQL.Add('           ELSE COALESCE(CLIENTES.RAZAOSOCIAL, CLIENTES.NOME)    ');
     SQL.Add('       END AS DES_CLIENTE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.TIPOPESSOA = 1 THEN CLIENTES.INSCRICAOESTADUAL   ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS NUM_INSC_EST,   ');
     SQL.Add('      ');
     SQL.Add('       CLIENTES.ENDERECO AS DES_ENDERECO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.BAIRRO = '''' THEN ''A DEFINIR''   ');
     SQL.Add('           ELSE COALESCE(CLIENTES.BAIRRO, ''A DEFINIR'')   ');
     SQL.Add('       END AS DES_BAIRRO,   ');
     SQL.Add('      ');
     SQL.Add('       CIDADE.NOME AS DES_CIDADE,   ');
     SQL.Add('       ESTADO.CODIGO AS DES_SIGLA,   ');
     SQL.Add('       CASE WHEN CLIENTES.CEP = '''' THEN ''29113070'' ELSE COALESCE(CLIENTES.CEP, ''29113070'') END AS NUM_CEP,   ');
     SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(CLIENTES.TELEFONE, ''-'', ''''), ''x'', ''''), '')'', ''''), ''(0'', '''') AS NUM_FONE,   ');
     SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(CLIENTES.FAX, ''-'', ''''), ''x'', ''''), '')'', ''''), ''(0'', '''') AS NUM_FAX,   ');
     SQL.Add('       COALESCE(CLIENTES.NOMECONTATO, CLIENTES.NOME) AS DES_CONTATO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.SEXO = 2 THEN 1   ');
     SQL.Add('           ELSE 0   ');
     SQL.Add('       END AS FLG_SEXO,   ');
     SQL.Add('          ');
     SQL.Add('       0 AS VAL_LIMITE_CRETID,   ');
     SQL.Add('       COALESCE(CLIENTES.LIMITECREDITO, 0) AS VAL_LIMITE_CONV,   ');
     SQL.Add('       0 AS VAL_DEBITO,   ');
     SQL.Add('       COALESCE(CLIENTES.RENDA, 0) AS VAL_RENDA,   ');
     SQL.Add('       0 AS COD_CONVENIO,   ');
     SQL.Add('       0 AS COD_STATUS_PDV,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.TIPOPESSOA = 1 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_EMPRESA,   ');
     SQL.Add('      ');
     SQL.Add('       ''N'' AS FLG_CONVENIO,   ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,   ');
     SQL.Add('       CLIENTES.DATACADASTRO AS DTA_CADASTRO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.NUMEROENDERECO = '''' THEN ''S/N''   ');
     SQL.Add('           ELSE COALESCE(CLIENTES.NUMEROENDERECO, ''S/N'')    ');
     SQL.Add('       END AS NUM_ENDERECO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(CLIENTES.RG, ''-'', ''''), ''.'', ''''), '''') AS NUM_RG,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.ESTADOCIVIL = 1 THEN 0   ');
     SQL.Add('           WHEN CLIENTES.ESTADOCIVIL = 5 THEN 4   ');
     SQL.Add('           WHEN CLIENTES.ESTADOCIVIL = 4 THEN 2   ');
     SQL.Add('           WHEN CLIENTES.ESTADOCIVIL = 2 THEN 3   ');
     SQL.Add('           WHEN CLIENTES.ESTADOCIVIL = 0 THEN 1   ');
     SQL.Add('           WHEN CLIENTES.ESTADOCIVIL = 6 THEN 0   ');
     SQL.Add('           ELSE 0   ');
     SQL.Add('       END AS FLG_EST_CIVIL,   ');
     SQL.Add('          ');
     SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(CLIENTES.CELULAR, ''-'', ''''), ''x'', ''''), '')'', ''''), ''(0'', '''') AS NUM_CELULAR,   ');
     SQL.Add('       CLIENTES.DATAHORAALTERACAO AS DTA_ALTERACAO,   ');
     SQL.Add('       COALESCE(CLIENTES.OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.COMPLEMENTO = '''' THEN ''A DEFINIR''   ');
     SQL.Add('           ELSE COALESCE(CLIENTES.COMPLEMENTO, ''A DEFINIR'')    ');
     SQL.Add('       END AS DES_COMPLEMENTO,   ');
     SQL.Add('      ');
     SQL.Add('       CLIENTES.EMAIL AS DES_EMAIL,   ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN CLIENTES.RAZAOSOCIAL = '''' THEN CLIENTES.NOME   ');
//     SQL.Add('           ELSE COALESCE(CLIENTES.RAZAOSOCIAL, CLIENTES.NOME)    ');
     SQL.Add('       CLIENTES.NOME AS DES_FANTASIA,   ');
     SQL.Add('          ');
     SQL.Add('       CLIENTES.NASCIMENTO AS DTA_NASCIMENTO,   ');
     SQL.Add('       COALESCE(CLIENTES.PAI, '''') AS DES_PAI,   ');
     SQL.Add('       COALESCE(CLIENTES.MAE, '''') AS DES_MAE,   ');
     SQL.Add('       COALESCE(CLIENTES.CONJUGE, '''') AS DES_CONJUGE,   ');
     SQL.Add('       '''' AS NUM_CPF_CONJUGE,   ');
     SQL.Add('       0 AS VAL_DEB_CONV,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN CLIENTES.INATIVO = 0 THEN ''N''   ');
     SQL.Add('           ELSE ''S''   ');
     SQL.Add('       END AS INATIVO,   ');
     SQL.Add('          ');
     SQL.Add('       '''' AS DES_MATRICULA,   ');
     SQL.Add('       ''N'' AS NUM_CGC_ASSOCIADO,   ');
     SQL.Add('       ''N'' AS FLG_PROD_RURAL,   ');
     SQL.Add('       CASE WHEN CLIENTES.creditorestrito = 1 THEN 1 ELSE 0 END AS COD_STATUS_PDV_CONV,   ');
     SQL.Add('       ''S'' AS FLG_ENVIA_CODIGO,   ');
     SQL.Add('       '''' AS DTA_NASC_CONJUGE,   ');
     SQL.Add('       0 AS COD_CLASSIF   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTIDADE AS CLIENTES   ');
     SQL.Add('   LEFT JOIN CIDADE ON CIDADE.ID = CLIENTES.IDCIDADE   ');
     SQL.Add('   LEFT JOIN ESTADO ON ESTADO.ID = CLIENTES.IDESTADO   ');
     SQL.Add('   WHERE CLIENTES.CLIENTE = 1   ');



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

procedure TFrmSmVia.GerarCodigoBarras;
//var
// count, count1 : Integer;
// codigoBarra : string;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')     ');
     SQL.Add('   		     ELSE PRODUTO.CODIGO   ');
     SQL.Add('   	   END AS COD_PRODUTO,  ');
     SQL.Add('       PRODUTO.EAN AS COD_EAN   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     SQL.Add('   WHERE PRODUTO.TIPO = ''P''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO >= ''354580''   ');
//     SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO <= ''354639''   ');
     //SQL.Add('   ORDER BY PRODUTO.INATIVO   ');
     //SQL.Add('   AND PRODUTO.EAN NOT LIKE ''%A%''   ');







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

procedure TFrmSmVia.GerarComposicao;
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

procedure TFrmSmVia.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTES.CODIGO AS COD_CLIENTE,   ');
     SQL.Add('       COALESCE(REPLACE(CONDICAOPAGAMENTO.PRAZOS, ''.'', ''''), ''30'') AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTIDADE AS CLIENTES   ');
     SQL.Add('   LEFT JOIN CONDICAOPAGAMENTO ON CONDICAOPAGAMENTO.ID = CLIENTES.IDCONDICAOPAGAMENTO   ');
     SQL.Add('   WHERE CLIENTES.CLIENTE = 1   ');



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

procedure TFrmSmVia.GerarCondPagForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDORES.CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       COALESCE(REPLACE(CONDICAOPAGAMENTO.PRAZOS, ''.'', ''''), ''30'') AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTIDADE AS FORNECEDORES   ');
     SQL.Add('   LEFT JOIN CONDICAOPAGAMENTO ON CONDICAOPAGAMENTO.ID = FORNECEDORES.IDCONDICAOPAGAMENTO   ');
     SQL.Add('   WHERE FORNECEDORES.FORNECEDOR = 1   ');



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

procedure TFrmSmVia.GerarDecomposicao;
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

procedure TFrmSmVia.GerarDivisaoForn;
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

procedure TFrmSmVia.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmVia.GerarFinanceiroPagar(Aberto: String);
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

       SQL.Add('   SELECT DISTINCT  ');
       SQL.Add('       1 AS TIPO_PARCEIRO,   ');
       SQL.Add('       FORNECEDOR.CODIGO AS COD_PARCEIRO,   ');
       SQL.Add('       0 AS TIPO_CONTA,   ');
       SQL.Add('       8 AS COD_ENTIDADE,   ');
       SQL.Add('       PAGAR.DOCUMENTO AS NUM_DOCTO,   ');
       SQL.Add('       999 AS COD_BANCO,   ');
       SQL.Add('       '''' AS DES_BANCO,   ');
       SQL.Add('       PAGAR.EMISSAO AS DTA_EMISSAO,   ');
       SQL.Add('       PAGAR.VENCIMENTO AS DTA_VENCIMENTO,   ');
       SQL.Add('       PAGAR.VALOR AS VAL_PARCELA,   ');
       SQL.Add('       PAGAR.JUROS AS VAL_JUROS,   ');
       SQL.Add('       0 AS VAL_DESCONTO,   ');
       SQL.Add('       ''N'' AS FLG_QUITADO,   ');
       SQL.Add('       '''' AS DTA_QUITADA,   ');
       SQL.Add('       998 AS COD_CATEGORIA,   ');
       SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
       SQL.Add('       PAGAR.PARCELA AS NUM_PARCELA,   ');
       SQL.Add('       CASE WHEN PARCELA.QTD_PARCELA IS NULL THEN PAGAR.PARCELA ELSE COALESCE(PARCELA.QTD_PARCELA, 1) END AS QTD_PARCELA,   ');
       SQL.Add('       PAGAR.IDFILIAL AS COD_LOJA,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('       0 AS NUM_BORDERO,   ');
       SQL.Add('       PAGAR.DOCUMENTO AS NUM_NF,   ');
       SQL.Add('       1 AS NUM_SERIE_NF,   ');
       SQL.Add('       CASE WHEN PARCELA.VAL_TOTAL_NF IS NULL THEN PAGAR.PARCELA ELSE COALESCE(PARCELA.VAL_TOTAL_NF, 1) END AS VAL_TOTAL_NF,   ');
       SQL.Add('       '''' AS DES_OBSERVACAO,   ');
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
       SQL.Add('       PAGAR.ENTRADA AS DTA_ENTRADA,   ');
       SQL.Add('       PAGAR.NOSSONUMERO AS NUM_NOSSO_NUMERO,   ');
       SQL.Add('       '''' AS COD_BARRA,   ');
       SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
       SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
       SQL.Add('       '''' AS DES_TITULAR,   ');
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
       SQL.Add('       FINANCEIRO AS PAGAR   ');
       SQL.Add('   LEFT JOIN ENTIDADE AS FORNECEDOR ON FORNECEDOR.ID = PAGAR.IDENTIDADE   ');
       SQL.Add('   LEFT JOIN (   ');
       SQL.Add('       SELECT DISTINCT   ');
       SQL.Add('           IDORIGEM,   ');
       SQL.Add('   		IDENTIDADE,   ');
       SQL.Add('   		SPLIT_PART(DOCUMENTO, ''/'', 1) AS DOCUMENTO,   ');
       SQL.Add('           COUNT(IDORIGEM) AS QTD_PARCELA,   ');
       SQL.Add('           SUM(VALOR) AS VAL_TOTAL_NF   ');
       SQL.Add('       FROM   ');
       SQL.Add('           FINANCEIRO   ');
       SQL.Add('       WHERE TIPO = ''P''   ');
       SQL.Add('       AND FINANCEIRO.IDFILIAL = '+CbxLoja.Text+'   ');
       SQL.Add('       --AND IDORIGEM = 32561   ');
       SQL.Add('       GROUP BY IDORIGEM, IDENTIDADE, SPLIT_PART(DOCUMENTO, ''/'', 1)   ');
       SQL.Add('   ) AS PARCELA   ');
       SQL.Add('   ON PAGAR.IDORIGEM = PARCELA.IDORIGEM   ');
       SQL.Add('   AND PAGAR.IDENTIDADE = PARCELA.IDENTIDADE   ');
       SQL.Add('   AND SPLIT_PART(PAGAR.DOCUMENTO, ''/'', 1) = PARCELA.DOCUMENTO   ');
       SQL.Add('   WHERE PAGAR.TIPO = ''P''   ');
       SQL.Add('   AND PAGAR.PAGAMENTO IS NULL   ');
       SQL.Add('   AND PAGAR.IDFILIAL = '+CbxLoja.Text+'   ');



      //FIM ABERTO
    end
    else
    begin
      //QUITADO

       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       1 AS TIPO_PARCEIRO,   ');
       SQL.Add('       FORNECEDOR.CODIGO AS COD_PARCEIRO,   ');
       SQL.Add('       0 AS TIPO_CONTA,   ');
       SQL.Add('       8 AS COD_ENTIDADE,   ');
       SQL.Add('       PAGAR.DOCUMENTO AS NUM_DOCTO,   ');
       SQL.Add('       999 AS COD_BANCO,   ');
       SQL.Add('       '''' AS DES_BANCO,   ');
       SQL.Add('       PAGAR.EMISSAO AS DTA_EMISSAO,   ');
       SQL.Add('       PAGAR.VENCIMENTO AS DTA_VENCIMENTO,   ');
       SQL.Add('       PAGAR.VALOR AS VAL_PARCELA,   ');
       SQL.Add('       PAGAR.JUROS AS VAL_JUROS,   ');
       SQL.Add('       0 AS VAL_DESCONTO,   ');
       SQL.Add('       ''S'' AS FLG_QUITADO,   ');
       SQL.Add('       CASE WHEN PAGAR.PAGAMENTO < PAGAR.EMISSAO THEN PAGAR.EMISSAO ELSE PAGAR.PAGAMENTO END AS DTA_QUITADA,   ');
       SQL.Add('       998 AS COD_CATEGORIA,   ');
       SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
       SQL.Add('       PAGAR.PARCELA AS NUM_PARCELA,   ');
       SQL.Add('       PARCELA.QTD_PARCELA AS QTD_PARCELA,   ');
       SQL.Add('       PAGAR.IDFILIAL AS COD_LOJA,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('       0 AS NUM_BORDERO,   ');
       SQL.Add('       PAGAR.DOCUMENTO AS NUM_NF,   ');
       SQL.Add('       1 AS NUM_SERIE_NF,   ');
       SQL.Add('       PARCELA.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
       SQL.Add('       PAGAR.PAGAMENTO AS DES_OBSERVACAO,   ');
       SQL.Add('       0 AS NUM_PDV,   ');
       SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
       SQL.Add('       0 AS COD_MOTIVO,   ');
       SQL.Add('       0 AS COD_CONVENIO,   ');
       SQL.Add('       0 AS COD_BIN,   ');
       SQL.Add('       '''' AS DES_BANDEIRA,   ');
       SQL.Add('       '''' AS DES_REDE_TEF,   ');
       SQL.Add('       0 AS VAL_RETENCAO,   ');
       SQL.Add('       0 AS COD_CONDICAO,   ');
       SQL.Add('       PAGAR.PAGAMENTO AS DTA_PAGTO,   ');
       SQL.Add('       PAGAR.ENTRADA AS DTA_ENTRADA,   ');
       SQL.Add('       PAGAR.NOSSONUMERO AS NUM_NOSSO_NUMERO,   ');
       SQL.Add('       '''' AS COD_BARRA,   ');
       SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
       SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
       SQL.Add('       '''' AS DES_TITULAR,   ');
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
       SQL.Add('       FINANCEIRO AS PAGAR   ');
       SQL.Add('   LEFT JOIN ENTIDADE AS FORNECEDOR ON FORNECEDOR.ID = PAGAR.IDENTIDADE   ');
       SQL.Add('   LEFT JOIN (   ');
       SQL.Add('       SELECT DISTINCT   ');
       SQL.Add('           IDORIGEM,   ');
       SQL.Add('   		IDENTIDADE,   ');
       SQL.Add('   		SPLIT_PART(DOCUMENTO, ''/'', 1) AS DOCUMENTO,   ');
       SQL.Add('           COUNT(IDORIGEM) AS QTD_PARCELA,   ');
       SQL.Add('           SUM(VALOR) AS VAL_TOTAL_NF   ');
       SQL.Add('       FROM   ');
       SQL.Add('           FINANCEIRO   ');
       SQL.Add('       WHERE TIPO = ''P''   ');
       SQL.Add('       AND FINANCEIRO.IDFILIAL = '+CbxLoja.Text+'   ');
       SQL.Add('       --AND IDORIGEM = 32561   ');
       SQL.Add('       GROUP BY IDORIGEM, IDENTIDADE, SPLIT_PART(DOCUMENTO, ''/'', 1)   ');
       SQL.Add('   ) AS PARCELA   ');
       SQL.Add('   ON PAGAR.IDORIGEM = PARCELA.IDORIGEM   ');
       SQL.Add('   AND PAGAR.IDENTIDADE = PARCELA.IDENTIDADE   ');
       SQL.Add('   AND SPLIT_PART(PAGAR.DOCUMENTO, ''/'', 1) = PARCELA.DOCUMENTO   ');
       SQL.Add('   WHERE PAGAR.TIPO = ''P''   ');
       SQL.Add('   AND PAGAR.PAGAMENTO IS NOT NULL   ');
       SQL.Add('   AND PAGAR.IDFILIAL = '+CbxLoja.Text+'   ');
       SQL.Add('   AND  ');
       SQL.Add('   CAST(PAGAR.PAGAMENTO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
       SQL.Add('   AND');
       SQL.Add('   CAST(PAGAR.PAGAMENTO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');



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

procedure TFrmSmVia.GerarFinanceiroReceber(Aberto: String);
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
       SQL.Add('   SELECT DISTINCT     ');
       SQL.Add('       0 AS TIPO_PARCEIRO,      ');
       SQL.Add('       CLIENTES.CODIGO AS COD_PARCEIRO,      ');
       SQL.Add('       1 AS TIPO_CONTA,      ');
       SQL.Add('       8 AS COD_ENTIDADE,      ');
       SQL.Add('       RECEBER.DOCUMENTO AS NUM_DOCTO,      ');
       SQL.Add('       999 AS COD_BANCO,      ');
       SQL.Add('       '''' AS DES_BANCO,      ');
       SQL.Add('       RECEBER.EMISSAO AS DTA_EMISSAO,      ');
       SQL.Add('       RECEBER.VENCIMENTO AS DTA_VENCIMENTO,      ');
       SQL.Add('       RECEBER.VALOR AS VAL_PARCELA,      ');
       SQL.Add('       RECEBER.JUROS AS VAL_JUROS,      ');
       SQL.Add('       0 AS VAL_DESCONTO,      ');
       SQL.Add('       ''N'' AS FLG_QUITADO,      ');
       SQL.Add('       '''' AS DTA_QUITADA,      ');
       SQL.Add('       997 AS COD_CATEGORIA,      ');
       SQL.Add('       997 AS COD_SUBCATEGORIA,      ');
       SQL.Add('       RECEBER.PARCELA AS NUM_PARCELA,      ');
       SQL.Add('       CASE WHEN PARCELA.QTD_PARCELA IS NULL THEN RECEBER.PARCELA ELSE COALESCE(PARCELA.QTD_PARCELA, 1) END AS QTD_PARCELA,      ');
       SQL.Add('       RECEBER.IDFILIAL AS COD_LOJA,      ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
       SQL.Add('       0 AS NUM_BORDERO,      ');
       SQL.Add('       RECEBER.DOCUMENTO AS NUM_NF,      ');
       SQL.Add('       1 AS NUM_SERIE_NF,      ');
       SQL.Add('       CASE WHEN PARCELA.VAL_TOTAL_NF IS NULL THEN RECEBER.PARCELA ELSE COALESCE(PARCELA.VAL_TOTAL_NF, 1) END AS VAL_TOTAL_NF,      ');
       SQL.Add('       '''' AS DES_OBSERVACAO,      ');
       SQL.Add('       0 AS NUM_PDV,      ');
       SQL.Add('       0 AS NUM_CUPOM_FISCAL,      ');
       SQL.Add('       0 AS COD_MOTIVO,      ');
       SQL.Add('       0 AS COD_CONVENIO,      ');
       SQL.Add('       0 AS COD_BIN,      ');
       SQL.Add('       '''' AS DES_BANDEIRA,      ');
       SQL.Add('       '''' AS DES_REDE_TEF,      ');
       SQL.Add('       0 AS VAL_RETENCAO,      ');
       SQL.Add('       0 AS COD_CONDICAO,      ');
       SQL.Add('       '''' AS DTA_PAGTO,      ');
       SQL.Add('       RECEBER.ENTRADA AS DTA_ENTRADA,      ');
       SQL.Add('       RECEBER.NOSSONUMERO AS NUM_NOSSO_NUMERO,      ');
       SQL.Add('       '''' AS COD_BARRA,      ');
       SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,      ');
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
       SQL.Add('       FINANCEIRO AS RECEBER      ');
       SQL.Add('   LEFT JOIN ENTIDADE AS CLIENTES ON CLIENTES.ID = RECEBER.IDENTIDADE      ');
       SQL.Add('   LEFT JOIN (      ');
       SQL.Add('        SELECT DISTINCT      ');
       SQL.Add('             IDORIGEM,      ');
       SQL.Add('   		IDENTIDADE,      ');
       SQL.Add('   		SPLIT_PART(DOCUMENTO, ''/'', 1) AS DOCUMENTO,      ');
       SQL.Add('             COUNT(IDORIGEM) AS QTD_PARCELA,      ');
       SQL.Add('             SUM(VALOR) AS VAL_TOTAL_NF      ');
       SQL.Add('        FROM      ');
       SQL.Add('             FINANCEIRO      ');
       SQL.Add('        WHERE TIPO = ''R''      ');
       SQL.Add('        AND FINANCEIRO.IDFILIAL = '+CbxLoja.Text+'      ');
       SQL.Add('        --AND IDORIGEM = 32561      ');
       SQL.Add('        GROUP BY IDORIGEM, IDENTIDADE, SPLIT_PART(DOCUMENTO, ''/'', 1)      ');
       SQL.Add('   ) AS PARCELA      ');
       SQL.Add('   ON RECEBER.IDORIGEM = PARCELA.IDORIGEM      ');
       SQL.Add('   AND RECEBER.IDENTIDADE = PARCELA.IDENTIDADE      ');
       SQL.Add('   AND SPLIT_PART(RECEBER.DOCUMENTO, ''/'', 1) = PARCELA.DOCUMENTO      ');
       SQL.Add('   WHERE RECEBER.TIPO = ''R''      ');
       SQL.Add('   AND RECEBER.PAGAMENTO IS NULL      ');
       SQL.Add('   AND RECEBER.IDFILIAL = '+CbxLoja.Text+'      ');
       SQL.Add('   AND CLIENTES.CLIENTE = 1   ');
       SQL.Add('   AND CLIENTES.CODIGO NOT IN (''4102'',''2700'',''1436'',''2018'',''2749'',''3050'',''4102'',''2743'',''5168'',''2015'',''2700'',''1450'',''2012'',''2013'',''2015'',''2021'',''2023'',''2363'',''2366'',''2367'',''2442'',''4385'',''4477'',''4483'',''4490'',''821'')   ');

//       SQL.Add('   AND CLIENTES.FORNECEDOR = 0   ');
//       SQL.Add('   AND CLIENTES.TRANSPORTADORA = 0   ');
//       SQL.Add('   AND CLIENTES.REPRESENTANTE = 0   ');



      //FIM ABERTO
    end
    else
    begin
      // QUITADO

         SQL.Add('   SELECT DISTINCT     ');
         SQL.Add('       0 AS TIPO_PARCEIRO,      ');
         SQL.Add('       CLIENTES.CODIGO AS COD_PARCEIRO,      ');
         SQL.Add('       1 AS TIPO_CONTA,      ');
         SQL.Add('       8 AS COD_ENTIDADE,      ');
         SQL.Add('       RECEBER.DOCUMENTO AS NUM_DOCTO,      ');
         SQL.Add('       999 AS COD_BANCO,      ');
         SQL.Add('       '''' AS DES_BANCO,      ');
         SQL.Add('       RECEBER.EMISSAO AS DTA_EMISSAO,      ');
         SQL.Add('       RECEBER.VENCIMENTO AS DTA_VENCIMENTO,      ');
         SQL.Add('       RECEBER.VALOR AS VAL_PARCELA,      ');
         SQL.Add('       COALESCE(RECEBER.JUROS, 0) AS VAL_JUROS,      ');
         SQL.Add('       0 AS VAL_DESCONTO,      ');
         SQL.Add('       ''S'' AS FLG_QUITADO,      ');
         SQL.Add('       CASE WHEN RECEBER.PAGAMENTO < RECEBER.EMISSAO THEN RECEBER.EMISSAO ELSE RECEBER.PAGAMENTO END AS DTA_QUITADA,      ');
         SQL.Add('       997 AS COD_CATEGORIA,      ');
         SQL.Add('       997 AS COD_SUBCATEGORIA,      ');
         SQL.Add('       COALESCE(RECEBER.PARCELA, 1) AS NUM_PARCELA,      ');
         SQL.Add('       COALESCE(PARCELA.QTD_PARCELA, 1) AS QTD_PARCELA,      ');
         SQL.Add('       RECEBER.IDFILIAL AS COD_LOJA,      ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
         SQL.Add('       0 AS NUM_BORDERO,      ');
         SQL.Add('       RECEBER.DOCUMENTO AS NUM_NF,      ');
         SQL.Add('       1 AS NUM_SERIE_NF,      ');
         SQL.Add('       COALESCE(PARCELA.VAL_TOTAL_NF, 0) AS VAL_TOTAL_NF,      ');
         SQL.Add('       RECEBER.PAGAMENTO AS DES_OBSERVACAO,      ');
         SQL.Add('       0 AS NUM_PDV,      ');
         SQL.Add('       0 AS NUM_CUPOM_FISCAL,      ');
         SQL.Add('       0 AS COD_MOTIVO,      ');
         SQL.Add('       0 AS COD_CONVENIO,      ');
         SQL.Add('       0 AS COD_BIN,      ');
         SQL.Add('       '''' AS DES_BANDEIRA,      ');
         SQL.Add('       '''' AS DES_REDE_TEF,      ');
         SQL.Add('       0 AS VAL_RETENCAO,      ');
         SQL.Add('       0 AS COD_CONDICAO,      ');
         SQL.Add('       RECEBER.PAGAMENTO AS DTA_PAGTO,      ');
         SQL.Add('       RECEBER.ENTRADA AS DTA_ENTRADA,      ');
         SQL.Add('       COALESCE(RECEBER.NOSSONUMERO, '''') AS NUM_NOSSO_NUMERO,      ');
         SQL.Add('       '''' AS COD_BARRA,      ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,      ');
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
         SQL.Add('       FINANCEIRO AS RECEBER      ');
         SQL.Add('   LEFT JOIN ENTIDADE AS CLIENTES ON CLIENTES.ID = RECEBER.IDENTIDADE      ');
         SQL.Add('   LEFT JOIN (      ');
         SQL.Add('        SELECT DISTINCT      ');
         SQL.Add('             IDORIGEM,      ');
         SQL.Add('   		IDENTIDADE,      ');
         SQL.Add('   		SPLIT_PART(DOCUMENTO, ''/'', 1) AS DOCUMENTO,      ');
         SQL.Add('             COUNT(IDORIGEM) AS QTD_PARCELA,      ');
         SQL.Add('             SUM(VALOR) AS VAL_TOTAL_NF      ');
         SQL.Add('        FROM      ');
         SQL.Add('             FINANCEIRO      ');
         SQL.Add('        WHERE TIPO = ''R''      ');
         SQL.Add('        AND FINANCEIRO.IDFILIAL = '+CbxLoja.Text+'      ');
         SQL.Add('        --AND IDORIGEM = 32561      ');
         SQL.Add('        GROUP BY IDORIGEM, IDENTIDADE, SPLIT_PART(DOCUMENTO, ''/'', 1)      ');
         SQL.Add('   ) AS PARCELA      ');
         SQL.Add('   ON RECEBER.IDORIGEM = PARCELA.IDORIGEM      ');
         SQL.Add('   AND RECEBER.IDENTIDADE = PARCELA.IDENTIDADE      ');
         SQL.Add('   AND SPLIT_PART(RECEBER.DOCUMENTO, ''/'', 1) = PARCELA.DOCUMENTO      ');
         SQL.Add('   WHERE RECEBER.TIPO = ''R''      ');
         SQL.Add('   AND RECEBER.PAGAMENTO IS NOT NULL      ');
         SQL.Add('   AND RECEBER.IDFILIAL = '+CbxLoja.Text+'     ');
         SQL.Add('   AND  ');
         SQL.Add('   CAST(RECEBER.PAGAMENTO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
         SQL.Add('   AND');
         SQL.Add('   CAST(RECEBER.PAGAMENTO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
         SQL.Add('   AND CLIENTES.CLIENTE = 1   ');
         SQL.Add('   AND CLIENTES.CODIGO NOT IN (''4102'',''2700'',''1436'',''2018'',''2749'',''3050'',''4102'',''2743'',''5168'',''2015'',''2700'',''1450'',''2012'',''2013'',''2015'',''2021'',''2023'',''2363'',''2366'',''2367'',''2442'',''4385'',''4477'',''4483'',''4490'',''821'')   ');

//         SQL.Add('   AND CLIENTES.FORNECEDOR = 0   ');
//         SQL.Add('   AND CLIENTES.TRANSPORTADORA = 0   ');
//         SQL.Add('   AND CLIENTES.REPRESENTANTE = 0   ');

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

procedure TFrmSmVia.GerarFinanceiroReceberCartao;
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

procedure TFrmSmVia.GerarFornecedor;
var
   observacao, email, inscEst : string;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDORES.CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN FORNECEDORES.RAZAOSOCIAL = '''' THEN FORNECEDORES.NOME   ');
     SQL.Add('           ELSE COALESCE(FORNECEDORES.RAZAOSOCIAL, FORNECEDORES.NOME)    ');
     SQL.Add('       END AS DES_FORNECEDOR,   ');
     SQL.Add('      ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN FORNECEDORES.RAZAOSOCIAL = '''' THEN FORNECEDORES.NOME   ');
//     SQL.Add('           ELSE COALESCE(FORNECEDORES.RAZAOSOCIAL, FORNECEDORES.NOME)    ');
     SQL.Add('       FORNECEDORES.NOME AS DES_FANTASIA,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN FORNECEDORES.TIPOPESSOA = 1 THEN    ');
     SQL.Add('               CASE    ');
     SQL.Add('                   WHEN FORNECEDORES.INSCRICAOESTADUAL = '''' THEN ''ISENTO''   ');
     SQL.Add('                   ELSE COALESCE(FORNECEDORES.INSCRICAOESTADUAL, ''ISENTO'')   ');
     SQL.Add('               END   ');
     SQL.Add('           ELSE ''ISENTO''   ');
     SQL.Add('       END AS NUM_INSC_EST,   ');
     SQL.Add('      ');
     SQL.Add('       FORNECEDORES.ENDERECO AS DES_ENDERECO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN FORNECEDORES.BAIRRO = '''' THEN ''A DEFINIR''   ');
     SQL.Add('           ELSE COALESCE(FORNECEDORES.BAIRRO, ''A DEFINIR'')   ');
     SQL.Add('       END AS DES_BAIRRO,   ');
     SQL.Add('      ');
     SQL.Add('       CIDADE.NOME AS DES_CIDADE,   ');
     SQL.Add('       ESTADO.CODIGO AS DES_SIGLA,   ');
     SQL.Add('       FORNECEDORES.CEP AS NUM_CEP,   ');
     SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDORES.TELEFONE, ''-'', ''''), ''x'', ''''), '')'', ''''), ''(0'', '''') AS NUM_FONE,   ');
     SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDORES.FAX, ''-'', ''''), ''x'', ''''), '')'', ''''), ''(0'', '''') AS NUM_FAX,   ');
     SQL.Add('       COALESCE(FORNECEDORES.NOMECONTATO, FORNECEDORES.NOME) AS DES_CONTATO,   ');
     SQL.Add('       0 AS QTD_DIA_CARENCIA,   ');
     SQL.Add('       0 AS NUM_FREQ_VISITA,   ');
     SQL.Add('       0 AS VAL_DESCONTO,   ');
     SQL.Add('       0 AS NUM_PRAZO,   ');
     SQL.Add('       ''N'' AS ACEITA_DEVOL_MER,   ');
     SQL.Add('       ''N'' AS CAL_IPI_VAL_BRUTO,   ');
     SQL.Add('       ''N'' AS CAL_ICMS_ENC_FIN,   ');
     SQL.Add('       ''N'' AS CAL_ICMS_VAL_IPI,   ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,   ');
     SQL.Add('       FORNECEDORES.CODIGO AS COD_FORNECEDOR_ANT,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN FORNECEDORES.NUMEROENDERECO = '''' THEN ''S/N''   ');
     SQL.Add('           ELSE COALESCE(FORNECEDORES.NUMEROENDERECO, ''S/N'')    ');
     SQL.Add('       END AS NUM_ENDERECO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(FORNECEDORES.OBSERVACAO, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       FORNECEDORES.EMAIL AS DES_EMAIL,   ');
     SQL.Add('       '''' AS DES_WEB_SITE,   ');
     SQL.Add('       ''N'' AS FABRICANTE,   ');
     SQL.Add('       ''N'' AS FLG_PRODUTOR_RURAL,   ');
     SQL.Add('       0 AS TIPO_FRETE,   ');
     SQL.Add('       ''N'' AS FLG_SIMPLES,   ');
     SQL.Add('       ''N'' AS FLG_SUBSTITUTO_TRIB,   ');
     SQL.Add('       0 AS COD_CONTACCFORN,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN FORNECEDORES.INATIVO = 0 THEN ''N''   ');
     SQL.Add('           ELSE ''S''   ');
     SQL.Add('       END AS INATIVO,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS COD_CLASSIF,   ');
     SQL.Add('       FORNECEDORES.DATACADASTRO AS DTA_CADASTRO,   ');
     SQL.Add('       COALESCE(FORNECEDORES.LIMITECREDITO, 0) AS VAL_CREDITO,   ');
     SQL.Add('       0 AS VAL_DEBITO,   ');
     SQL.Add('       1 AS PED_MIN_VAL,   ');
     SQL.Add('       '''' AS DES_EMAIL_VEND,   ');
     SQL.Add('       '''' AS SENHA_COTACAO,   ');
     SQL.Add('       -1 AS TIPO_PRODUTOR,   ');
     SQL.Add('       REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CELULAR, ''('', ''''), ''-'', ''''), ''x'', ''''), '')'', ''''), ''(0'', '''') AS NUM_CELULAR   ');
     SQL.Add('   FROM   ');
     SQL.Add('       ENTIDADE AS FORNECEDORES   ');
     SQL.Add('   LEFT JOIN CIDADE ON CIDADE.ID = FORNECEDORES.IDCIDADE   ');
     SQL.Add('   LEFT JOIN ESTADO ON ESTADO.ID = FORNECEDORES.IDESTADO   ');
     SQL.Add('   WHERE FORNECEDORES.FORNECEDOR = 1   ');


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

procedure TFrmSmVia.GerarGrupo;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

//     SQL.Add('   SELECT DISTINCT   ');
//     SQL.Add('   	COALESCE(SUBSTRING(TRIM(HIERARQUIA.CODIGO), 1, 2), ''999'') AS COD_SECAO,   ');
//     SQL.Add('   	   CASE   ');
//     SQL.Add('   		     WHEN COALESCE(SUBSTRING(TRIM(HIERARQUIA.CODIGO), 5, 6), ''999'') = '''' THEN ''999''   ');
//     SQL.Add('           ELSE CAST(COALESCE(SUBSTRING(TRIM(HIERARQUIA.CODIGO), 5, 6), ''999'') AS INTEGER)    ');
//     SQL.Add('   	   END AS COD_GRUPO,   ');
//     SQL.Add('   	COALESCE(HIERARQUIA.NOME, ''A DEFINIR'') AS DES_GRUPO,   ');
     //SQL.Add('   	''A DEFINIR'' AS DES_GRUPO,   ');
//     SQL.Add('   	0 AS VAL_META   ');
//     SQL.Add('   FROM    ');
//     SQL.Add('       HIERARQUIA   ');
//     SQL.Add('   WHERE SUBSTRING(TRIM(HIERARQUIA.CODIGO), 5, 6) <> ''''   ');


       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('   	  COALESCE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 5, 2)), ''999'') AS COD_SECAO,   ');
       SQL.Add('       ');
       SQL.Add('   	   CASE   ');
       SQL.Add('   		     WHEN TRIM(SUBSTRING(HIERARQUIA.CODIGO, 10, 3)) = '''' THEN ''999''   ');
       SQL.Add('   		     ELSE COALESCE(TRIM(SUBSTRING(HIERARQUIA.CODIGO, 10, 3)), ''999'')    ');
       SQL.Add('   	   END AS COD_GRUPO,   ');
       SQL.Add('   	   ');
       SQL.Add('   	  COALESCE(HIERARQUIA.NOME, ''A DEFINIR'') AS DES_GRUPO,   ');
       SQL.Add('   	  0 AS VAL_META   ');
       SQL.Add('   FROM   ');
       SQL.Add('   	  HIERARQUIA   ');
       SQL.Add('   WHERE HIERARQUIA.CLASSE = 2   ');



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

procedure TFrmSmVia.GerarInfoNutricionais;
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

procedure TFrmSmVia.GerarNCM;
var
 count : Integer;
begin
  inherited;


  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

//     SQL.Add('   SELECT DISTINCT   ');
//     SQL.Add('       NCM.ID AS COD_NCM,   ');
//     SQL.Add('       COALESCE(NCM.DESCRICAO, ''A DEFINIR'') AS DES_NCM,   ');
//     SQL.Add('       PRODUTO.NCM AS NUM_NCM,   ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''04'' THEN ''S''   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''06'' THEN ''S''   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''08'' THEN ''S''   ');
//     SQL.Add('           ELSE ''N''      ');
//     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
//     SQL.Add('            ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''04'' THEN 1   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''06'' THEN 0   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''08'' THEN 3   ');
//     SQL.Add('           ELSE -1   ');
//     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
//     SQL.Add('           ');
//     SQL.Add('       999 AS COD_TAB_SPED,   ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN PRODUTO.CEST = '''' THEN ''9999999''   ');
//     SQL.Add('           ELSE COALESCE(PRODUTO.CEST, ''9999999'')    ');
//     SQL.Add('       END AS NUM_CEST,   ');
//     SQL.Add('       ''ES'' AS DES_SIGLA,   ');
//     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
//     SQL.Add('       1 AS COD_TRIB_SAIDA,   ');
//     SQL.Add('       NCM.PERCENTUALMVA AS PER_IVA,   ');
//     SQL.Add('       0 AS PER_FCP_ST   ');
//     SQL.Add('   FROM   ');
//     SQL.Add('       PRODUTO   ');
//     SQL.Add('   LEFT JOIN NCM ON NCM.CODIGO = PRODUTO.NCM   ');

       SQL.Add('           SELECT DISTINCT      ');
       SQL.Add('               0 AS COD_NCM,      ');
       SQL.Add('               COALESCE(NCM.DESCRICAO, ''A DEFINIR'') AS DES_NCM,      ');
       SQL.Add('               NCM.CODIGO AS NUM_NCM,      ');
       SQL.Add('               CASE      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''04'' THEN ''S''      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''06'' THEN ''S''      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''08'' THEN ''S''      ');
       SQL.Add('                   ELSE ''N''         ');
       SQL.Add('               END AS FLG_NAO_PIS_COFINS,      ');
       SQL.Add('                       ');
       SQL.Add('               CASE      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''04'' THEN 1      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''06'' THEN 0      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''08'' THEN 3      ');
       SQL.Add('                   ELSE -1      ');
       SQL.Add('               END AS TIPO_NAO_PIS_COFINS,      ');
       SQL.Add('                      ');
       SQL.Add('               COALESCE(COALESCE(PRODUTO.naturezareceita, PRODUTO.codigoreceitasemcontribuicao), ''999'') AS COD_TAB_SPED,      ');
       SQL.Add('               CASE      ');
       SQL.Add('                   WHEN CEST.CODIGO = '''' THEN ''9999999''      ');
       SQL.Add('                   ELSE COALESCE(CEST.CODIGO, ''9999999'')       ');
       SQL.Add('               END AS NUM_CEST,      ');
       SQL.Add('               ''ES'' AS DES_SIGLA,      ');
       SQL.Add('   CASE   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA IS NULL THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 3   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 41   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''48.2400'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 42   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 43   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6700'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''16.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 44   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''4.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 43   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''82.3500'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 41   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 40   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''27.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 45   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 14   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''29.4100'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 47   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 11   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 5   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''10'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''67.0600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 49   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 5   ');
       SQL.Add('       ELSE 1   ');
       SQL.Add('   END AS COD_TRIB_ENTRADA,      ');
       SQL.Add('   CASE   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA IS NULL THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 3   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8300'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 50   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''48.2400'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 42   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6700'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''4.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''82.3500'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 40   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''27.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 45   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''29.4100'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 47   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 5   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''67.0600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 49   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 5   ');
       SQL.Add('       ELSE 1   ');
       SQL.Add('   END AS COD_TRIB_SAIDA,      ');
       SQL.Add('               NCM.PERCENTUALMVA AS PER_IVA,      ');
       SQL.Add('               0 AS PER_FCP_ST      ');
       SQL.Add('           FROM      ');
       SQL.Add('               NCM      ');
       SQL.Add('           LEFT JOIN PRODUTO ON PRODUTO.IDNCM = NCM.ID   ');
       SQL.Add('   		LEFT JOIN CEST ON CEST.ID = PRODUTO.IDCEST   ');
       //SQL.Add('   		ORDER BY NCM.ID   ');




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

procedure TFrmSmVia.GerarNCMUF;
var
 count : Integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

//     SQL.Add('   SELECT DISTINCT   ');
//     SQL.Add('       NCM.ID AS COD_NCM,   ');
//     SQL.Add('       COALESCE(NCM.DESCRICAO, ''A DEFINIR'') AS DES_NCM,   ');
//     SQL.Add('       PRODUTO.NCM AS NUM_NCM,   ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''04'' THEN ''S''   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''06'' THEN ''S''   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''08'' THEN ''S''   ');
//     SQL.Add('           ELSE ''N''      ');
//     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
//     SQL.Add('            ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''04'' THEN 1   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''06'' THEN 0   ');
//     SQL.Add('           WHEN PRODUTO.CSTPIS = ''08'' THEN 3   ');
//     SQL.Add('           ELSE -1   ');
//     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
//     SQL.Add('           ');
//     SQL.Add('       999 AS COD_TAB_SPED,   ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN PRODUTO.CEST = '''' THEN ''9999999''   ');
//     SQL.Add('           ELSE COALESCE(PRODUTO.CEST, ''9999999'')    ');
//     SQL.Add('       END AS NUM_CEST,   ');
//     SQL.Add('       ''ES'' AS DES_SIGLA,   ');
//     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
//     SQL.Add('       1 AS COD_TRIB_SAIDA,   ');
//     SQL.Add('       NCM.PERCENTUALMVA AS PER_IVA,   ');
//     SQL.Add('       0 AS PER_FCP_ST   ');
//     SQL.Add('   FROM   ');
//     SQL.Add('       PRODUTO   ');
//     SQL.Add('   LEFT JOIN NCM ON NCM.CODIGO = PRODUTO.NCM   ');

       SQL.Add('           SELECT DISTINCT      ');
       SQL.Add('               0 AS COD_NCM,      ');
       SQL.Add('               COALESCE(NCM.DESCRICAO, ''A DEFINIR'') AS DES_NCM,      ');
       SQL.Add('               NCM.CODIGO AS NUM_NCM,      ');
       SQL.Add('               CASE      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''04'' THEN ''S''      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''06'' THEN ''S''      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''08'' THEN ''S''      ');
       SQL.Add('                   ELSE ''N''         ');
       SQL.Add('               END AS FLG_NAO_PIS_COFINS,      ');
       SQL.Add('                       ');
       SQL.Add('               CASE      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''04'' THEN 1      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''06'' THEN 0      ');
       SQL.Add('                   WHEN PRODUTO.CSTPIS = ''08'' THEN 3      ');
       SQL.Add('                   ELSE -1      ');
       SQL.Add('               END AS TIPO_NAO_PIS_COFINS,      ');
       SQL.Add('                      ');
       SQL.Add('               COALESCE(COALESCE(PRODUTO.naturezareceita, PRODUTO.codigoreceitasemcontribuicao), ''999'') AS COD_TAB_SPED,      ');
       SQL.Add('               CASE      ');
       SQL.Add('                   WHEN CEST.CODIGO = '''' THEN ''9999999''      ');
       SQL.Add('                   ELSE COALESCE(CEST.CODIGO, ''9999999'')       ');
       SQL.Add('               END AS NUM_CEST,      ');
       SQL.Add('               ''ES'' AS DES_SIGLA,      ');
       SQL.Add('   CASE   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA IS NULL THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 3   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 41   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''48.2400'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 42   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 43   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6700'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''16.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 44   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''4.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 43   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''82.3500'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 41   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 40   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''27.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 45   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 14   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''29.4100'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 47   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 11   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 5   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''10'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''67.0600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 49   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 5   ');
       SQL.Add('       ELSE 1   ');
       SQL.Add('   END AS COD_TRIB_ENTRADA,      ');
       SQL.Add('   CASE   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA IS NULL THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 3   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8300'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 50   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''48.2400'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 42   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6700'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''4.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''82.3500'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 40   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''27.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 45   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''29.4100'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 47   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 5   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''67.0600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 49   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 5   ');
       SQL.Add('       ELSE 1   ');
       SQL.Add('   END AS COD_TRIB_SAIDA,      ');
       SQL.Add('               NCM.PERCENTUALMVA AS PER_IVA,      ');
       SQL.Add('               0 AS PER_FCP_ST      ');
       SQL.Add('           FROM      ');
       SQL.Add('               NCM      ');
       SQL.Add('           LEFT JOIN PRODUTO ON PRODUTO.IDNCM = NCM.ID   ');
       SQL.Add('   		LEFT JOIN CEST ON CEST.ID = PRODUTO.IDCEST   ');
       //SQL.Add('   		ORDER BY NCM.ID   ');




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

procedure TFrmSmVia.GerarNFClientes;
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

procedure TFrmSmVia.GerarNFFornec;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       FORNECEDOR.CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       CAPA.NUMERONOTAFISCAL AS NUM_NF_FORN,   ');
     SQL.Add('       CAPA.SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
     SQL.Add('       COALESCE(SUBSTRING(CFOP.CODIGO, 1, 4), ''1102'') AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
     SQL.Add('       CAPA.VALORTOTALNOTA AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.ENTRADASAIDA AS DTA_EMISSAO,   ');
     SQL.Add('       CAPA.EMISSAO AS DTA_ENTRADA,   ');
     SQL.Add('       CAPA.IPI AS VAL_TOTAL_IPI,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       CAPA.FRETE AS VAL_FRETE,   ');
     SQL.Add('       CAPA.ACRESCIMOSPRODUTO AS VAL_ACRESCIMO,   ');
     SQL.Add('       CAPA.DESCONTOPRODUTO AS VAL_DESCONTO,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       CAPA.BASEICMS AS VAL_TOTAL_BC,   ');
     SQL.Add('       CAPA.ICMS AS VAL_TOTAL_ICMS,   ');
     SQL.Add('       CAPA.BASEICMSSUBSTITUICAO AS VAL_BC_SUBST,   ');
     SQL.Add('       CAPA.ICMSSUBSTITUICAO AS VAL_ICMS_SUBST,   ');
     SQL.Add('       CAPA.FUNRURAL AS VAL_FUNRURAL,   ');
     SQL.Add('       1 AS COD_PERFIL,   ');
     SQL.Add('       0 AS VAL_DESP_ACESS,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       CAPA.CHAVENFE AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       NOTAFISCAL AS CAPA   ');
     SQL.Add('   LEFT JOIN ENTIDADE AS FORNECEDOR ON FORNECEDOR.ID = CAPA.IDENTIDADE   ');
     SQL.Add('   LEFT JOIN CFOP ON CFOP.ID = CAPA.IDCFOP   ');
     SQL.Add('   WHERE FORNECEDOR.FORNECEDOR = 1   ');
     SQL.Add('   AND CAPA.IDFILIAL = '+CbxLoja.Text+'   ');
     SQL.Add('   AND');
     SQL.Add('      CAST(CAPA.EMISSAO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('   AND');
     SQL.Add('      CAST(CAPA.EMISSAO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');


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

procedure TFrmSmVia.GerarNFitensClientes;
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

procedure TFrmSmVia.GerarNFitensFornec;
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
       SQL.Add('       FORNECEDOR.CODIGO AS COD_FORNECEDOR,   ');
       SQL.Add('       CAPA.NUMERONOTAFISCAL AS NUM_NF_FORN,   ');
       SQL.Add('       CAPA.SERIE AS NUM_SERIE_NF,   ');
       SQL.Add('      ');
       SQL.Add('       CASE      ');
       SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')      ');
       SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')        ');
       SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
       SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')     ');
       SQL.Add('           ELSE PRODUTO.CODIGO      ');
       SQL.Add('       END AS COD_PRODUTO,   ');
       SQL.Add('      ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA IS NULL THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 3      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8300'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 50      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''48.2400'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 42      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6700'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 2      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''4.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''82.3500'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 40      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''27.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 45      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 46      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''29.4100'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 47      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 39      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 48      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 51      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 5      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 39      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 48      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''67.0600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 49      ');
       SQL.Add('           WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 5      ');
       SQL.Add('           ELSE 1   ');
       SQL.Add('       END AS COD_TRIBUTACAO,   ');
       SQL.Add('      ');
       SQL.Add('       COALESCE(ITEM.EMBALAGEM, 1) AS QTD_EMBALAGEM,   ');
       SQL.Add('       ITEM.QUANTIDADE AS QTD_ENTRADA,   ');
       SQL.Add('       COALESCE(ITEM.UNIDADE, ''UN'') AS DES_UNIDADE,   ');
       SQL.Add('       ITEM.PRECOUNITARIO AS VAL_TABELA,   ');
       SQL.Add('       COALESCE(ITEM.DESCONTO, 0) AS VAL_DESCONTO_ITEM,   ');
       SQL.Add('       COALESCE(ITEM.ACRESCIMO, 0) AS VAL_ACRESCIMO_ITEM,   ');
       SQL.Add('       COALESCE(ITEM.IPI, 0) AS VAL_IPI_ITEM,   ');
       SQL.Add('       COALESCE(ITEM.ICMSSUBSTITUICAO, 0) AS VAL_SUBST_ITEM,   ');
       SQL.Add('       COALESCE(ITEM.FRETE, 0) AS VAL_FRETE_ITEM,   ');
       SQL.Add('       COALESCE(ITEM.ICMS, 0) AS VAL_CREDITO_ICMS,   ');
       SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
       SQL.Add('       ITEM.TOTAL AS VAL_TABELA_LIQ,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('       COALESCE(ITEM.BASEICMS, 0) AS VAL_TOT_BC_ICMS,   ');
       SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
       SQL.Add('       COALESCE(SUBSTRING(CFOP.CODIGO, 1, 4), ''1102'') AS CFOP,   ');
       SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
       SQL.Add('       COALESCE(ITEM.BASEICMSSUBSTITUICAO, 0) AS VAL_TOT_BC_ST,   ');
       SQL.Add('       0 AS VAL_TOT_ST,   ');
       SQL.Add('       ITEM.CONTADOR AS NUM_ITEM,   ');
       SQL.Add('       0 AS TIPO_IPI,   ');
       SQL.Add('       PRODUTO.NCM AS NUM_NCM,   ');
       SQL.Add('       COALESCE(ITEM.REFERENCIAFORNECEDOR, '''') AS DES_REFERENCIA   ');
       SQL.Add('   FROM   ');
       SQL.Add('       NOTAFISCALITEM AS ITEM   ');
       SQL.Add('   LEFT JOIN NOTAFISCAL AS CAPA ON CAPA.ID = ITEM.IDNOTAFISCAL   ');
       SQL.Add('   LEFT JOIN PRODUTO ON PRODUTO.ID = ITEM.IDPRODUTO AND PRODUTO.CODIGO = ITEM.PRODUTO   ');
       SQL.Add('   LEFT JOIN ENTIDADE AS FORNECEDOR ON FORNECEDOR.ID = CAPA.IDENTIDADE   ');
       SQL.Add('   LEFT JOIN CFOP ON CFOP.ID = ITEM.IDCFOP   ');
       SQL.Add('   WHERE FORNECEDOR.FORNECEDOR = 1   ');
       SQL.Add('   AND CAPA.IDFILIAL = '+CbxLoja.Text+'   ');
       SQL.Add('   AND');
       SQL.Add('      CAST(CAPA.EMISSAO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
       SQL.Add('   AND');
       SQL.Add('      CAST(CAPA.EMISSAO AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');




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

//      Layout.FieldByName('NUM_ITEM').AsInteger := count;

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

procedure TFrmSmVia.GerarProdForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')   ');
     SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
     SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')     ');
     SQL.Add('   		     ELSE PRODUTO.CODIGO   ');
     SQL.Add('   	   END AS COD_PRODUTO,  ');
     SQL.Add('       FORNECEDOR.CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       '''' AS DES_REFERENCIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.CNPJCPF, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('       COALESCE(PRODUTO.UNIDADEMEDIDA, ''UN'') AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       1 AS QTD_TROCA,   ');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       PRODUTO   ');
     SQL.Add('   LEFT JOIN ENTIDADE AS FORNECEDOR ON FORNECEDOR.ID = PRODUTO.IDFORNECEDOR   ');
     SQL.Add('   WHERE FORNECEDOR.FORNECEDOR = 1   ');
     SQL.Add('   AND PRODUTO.TIPO = ''P''   ');
     //SQL.Add('   ORDER BY PRODUTO.INATIVO   ');






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

procedure TFrmSmVia.GerarProdLoja;
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

  if FlgAtualizaPromocao then
  begin
    GeraPromocao;
    Exit;
  end;

  if FlgAtualizaInativo then
  begin
    GeraUpdateInativo;
    Exit;
  end;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;


       SQL.Add('   SELECT DISTINCT  ');
       SQL.Add('   	   CASE   ');
       SQL.Add('   		     WHEN CHAR_LENGTH(PRODUTO.EAN) >= 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')   ');
       SQL.Add('           WHEN CHAR_LENGTH(PRODUTO.CODIGO) >= 7 AND CHAR_LENGTH(PRODUTO.EAN) < 8 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
       SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) > 7 THEN COALESCE(PRODUTO.CODIGO_PRODUTO, '''')     ');
       SQL.Add('           WHEN PRODUTO.EAN = '''' AND CHAR_LENGTH(PRODUTO.CODIGO) <= 7 THEN COALESCE(PRODUTO.CODIGO, '''')     ');
       SQL.Add('   		     ELSE PRODUTO.CODIGO   ');
       SQL.Add('   	   END AS COD_PRODUTO,  ');
       SQL.Add('       PRODUTO.PRECOCUSTO AS VAL_CUSTO_REP,   ');
       SQL.Add('       PRODUTO.PRECO AS VAL_VENDA,   ');
       SQL.Add('       0 AS VAL_OFERTA,   ');
       SQL.Add('       1 AS QTD_EST_VDA,   ');
       SQL.Add('       '''' AS TECLA_BALANCA,   ');
       SQL.Add('   CASE   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA IS NULL THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 3   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8300'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 50   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''48.2400'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 42   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6700'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''4.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''82.3500'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''7.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''12.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 40   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''27.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 45   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''29.4100'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 47   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''0.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 5   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''17.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''67.0600'' AND PRODUTO.SITUACAOTRIBUTARIA = ''20'' THEN 49   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSINTERNA = ''25.00'' AND PRODUTO.ALIQUOTAREDUCAOICMSNFCESAT = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIA = ''00'' THEN 5   ');
       SQL.Add('       ELSE 1   ');
       SQL.Add('   END AS COD_TRIBUTACAO,   ');
       SQL.Add('       COALESCE(produto.lucrobrutomaximo, 0) AS VAL_MARGEM,   ');
       SQL.Add('       1 AS QTD_ETIQUETA,   ');
       SQL.Add('   CASE   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA IS NULL THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 3   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 41   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''48.2400'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 42   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 43   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6700'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 6   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''16.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 44   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 2   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''4.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 43   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''82.3500'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 4   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''12.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''41.6600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 41   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 40   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''27.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 45   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 14   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''29.4100'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 47   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 25   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''100.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 51   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''7.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''60'' THEN 11   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''40'' THEN 1   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''41'' THEN 23   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''0.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''90'' THEN 22   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 5   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 39   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''58.8200'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 48   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''10'' THEN 46   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''17.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''67.0600'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''20'' THEN 49   ');
       SQL.Add('       WHEN PRODUTO.ALIQUOTAICMSNF = ''25.00'' AND PRODUTO.PERCENTUALREDUCAOICMS = ''0.0000'' AND PRODUTO.SITUACAOTRIBUTARIAENTRADA = ''00'' THEN 5   ');
       SQL.Add('       ELSE 1   ');
       SQL.Add('   END AS COD_TRIB_ENTRADA,   ');
       SQL.Add('       CASE WHEN PRODUTO.INATIVO = 0 THEN ''N'' ELSE ''S'' END AS FLG_INATIVO,   ');
       SQL.Add('       PRODUTO.CODIGO AS COD_PRODUTO_ANT,   ');
       SQL.Add('       PRODUTO.NCM AS NUM_NCM,   ');
       SQL.Add('       0 AS TIPO_NCM,   ');
       SQL.Add('       0 AS VAL_VENDA_2,   ');
       SQL.Add('       '''' AS DTA_VALIDA_OFERTA,   ');
       SQL.Add('       COALESCE(produto.quantidademinima, 1) AS QTD_EST_MINIMO,   ');
       SQL.Add('       '''' AS COD_VASILHAME,   ');
       SQL.Add('       ''N'' AS FORA_LINHA,   ');
       SQL.Add('       0 AS QTD_PRECO_DIF,   ');
       SQL.Add('       0 AS VAL_FORCA_VDA,   ');
       SQL.Add('          ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PRODUTO.CEST = '''' THEN ''9999999''   ');
       SQL.Add('           ELSE COALESCE(PRODUTO.CEST, ''9999999'')    ');
       SQL.Add('       END AS NUM_CEST,   ');
       SQL.Add('          ');
       SQL.Add('       0 AS PER_IVA,   ');
       SQL.Add('       0 AS PER_FCP_ST,   ');
       SQL.Add('       0 AS PER_FIDELIDADE,   ');
       SQL.Add('       999 AS COD_INFO_RECEITA   ');
       SQL.Add('   FROM   ');
       SQL.Add('       PRODUTO   ');
       SQL.Add('   WHERE PRODUTO.TIPO = ''P''   ');
//       SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO >= ''354580''   ');
//       SQL.Add('   		AND PRODUTO.CODIGO_PRODUTO <= ''354639''   ');






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
//      Layout.FieldByName('COD_PRODUTO').AsString := Layout.FieldByName('COD_PRODUTO').AsString;

       //Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU( Layout.FieldByName('COD_PRODUTO').AsString );
//       Layout.FieldByName('COD_PRODUTO_ANT').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO_ANT').AsString);
//       Layout.FieldByName('COD_PRODUTO_ANT').AsString := Layout.FieldByName('COD_PRODUTO_ANT').AsString;

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

procedure TFrmSmVia.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

//     SQL.Add('   SELECT   ');
//     SQL.Add('       S_PRODUTO.CDSUPERPRODUTO AS COD_PRODUTO_SIMILAR,   ');
//     SQL.Add('       S_PRODUTO.NMPRODUTOPAI AS DES_PRODUTO_SIMILAR,   ');
//     SQL.Add('       0 AS VAL_META    ');
//     SQL.Add('   FROM   ');
//     SQL.Add('       TBSUPERPRODUTO AS S_PRODUTO   ');
//     SQL.Add('   WHERE S_PRODUTO.CDSUPERPRODUTO IN (   ');
//     SQL.Add('       SELECT   ');
//     SQL.Add('           PRODUTO.CDSUPERPRODUTO   ');
//     SQL.Add('       FROM   ');
//     SQL.Add('           TBPRODUTO AS PRODUTO   ');
//     SQL.Add('       GROUP BY PRODUTO.CDSUPERPRODUTO   ');
//     SQL.Add('       HAVING COUNT (*) > 1   ');
//     SQL.Add('   )   ');

       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       SIMILAR1.ID AS COD_PRODUTO_SIMILAR,   ');
       SQL.Add('       COALESCE(SIMILAR1.NOME, ''A DEFINIR'') AS DES_PRODUTO_SIMILAR,   ');
       SQL.Add('       0 AS VAL_META   ');
       SQL.Add('   FROM   ');
       SQL.Add('       FAMILIAPRODUTO AS SIMILAR1   ');
       //SQL.Add('   LEFT JOIN FAMILIAPRODUTO AS SIMILAR1 ON SIMILAR1.ID = PRODUTO.IDFAMILIA   ');



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
