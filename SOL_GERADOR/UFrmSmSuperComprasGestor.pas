unit UFrmSmSuperComprasGestor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrmModelo, Data.DBXOracle, Data.DB,
  Data.SqlExpr, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DBXFirebird, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.Provider, Datasnap.DBClient, //dxGDIPlusClasses,
  Math;

type
  TFrmSmSuperComprasGestor = class(TFrmModeloSis)
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
  FrmSmSuperComprasGestor: TFrmSmSuperComprasGestor;
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


procedure TFrmSmSuperComprasGestor.GerarProducao;
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

procedure TFrmSmSuperComprasGestor.GerarProduto;
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


     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTO.COD AS COD_PRODUTO,   ');
     SQL.Add('       COALESCE(COD_BARRAS.BARRAS, PRODUTO.COD) AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       PRODUTO.RDZ AS DES_REDUZIDA,   ');
     SQL.Add('       PRODUTO.DSC AS DES_PRODUTO,   ');
     SQL.Add('       COALESCE(PRODUTO.DA_UND_EMBALAGEM, 1) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_UNIDADE_COMPRA, ''UN'') AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       COALESCE(PRODUTO.DA_UND_EMBALAGEM, 1) AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_UNIDADE, ''UN'') AS DES_UNIDADE_VENDA,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       0 AS VAL_IPI,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_DEPARTAMENTO, 999) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_GRUPO, 999) AS COD_GRUPO,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_SUB_GRUPO, 999) AS COD_SUB_GRUPO,   ');
     SQL.Add('       COALESCE(P_SIMILAR.CHV, 0) AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PD_UNIDADE = ''KG'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('              ');
     SQL.Add('       COALESCE(PRODUTO.DA_VALIDADE, 0) AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.PD_BALANCA = 1 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('          ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       COALESCE(ASSOC.COD_VINCULADO, 0) AS COD_ASSOCIADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_TABELA_NUTRICIONAL, 0) AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
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
     SQL.Add('       COALESCE(P_LOJA.FORNECEDOR, 0) AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       CAST(PRODUTO.DATA_C AS DATE) AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       PRODUTO.DSC AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PRODUTO.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM AS P_LOJA ON P_LOJA.COD = PRODUTO.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_VINC AS ASSOC ON ASSOC.COD = PRODUTO.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_SIM AS P_SIMILAR ON P_SIMILAR.COD = PRODUTO.COD   ');
     SQL.Add('   WHERE CHAR_LENGTH(COD_BARRAS.BARRAS) < 14   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTO_LJ2.COD + 2000000 AS COD_PRODUTO,   ');
     SQL.Add('       COALESCE(COD_BARRAS_LJ2.BARRAS, PRODUTO_LJ2.COD) AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       PRODUTO_LJ2.RDZ AS DES_REDUZIDA,   ');
     SQL.Add('       PRODUTO_LJ2.DSC AS DES_PRODUTO,   ');
     SQL.Add('       COALESCE(PRODUTO_LJ2.DA_UND_EMBALAGEM, 1) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       COALESCE(PRODUTO_LJ2.PD_UNIDADE_COMPRA, ''UN'') AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       COALESCE(PRODUTO_LJ2.DA_UND_EMBALAGEM, 1) AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       COALESCE(PRODUTO_LJ2.PD_UNIDADE, ''UN'') AS DES_UNIDADE_VENDA,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       0 AS VAL_IPI,   ');
     SQL.Add('       COALESCE(999||PRODUTO_LJ2.PD_DEPARTAMENTO, 999) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(999||PRODUTO_LJ2.PD_GRUPO, 999) AS COD_GRUPO,   ');
     SQL.Add('       COALESCE(999||PRODUTO_LJ2.PD_SUB_GRUPO, 999) AS COD_SUB_GRUPO,   ');
     SQL.Add('       COALESCE(999||P_SIMILAR_LJ2.CHV, 0) AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO_LJ2.PD_UNIDADE = ''KG'' THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('              ');
     SQL.Add('       COALESCE(PRODUTO_LJ2.DA_VALIDADE, 0) AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO_LJ2.PD_BALANCA = 1 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('          ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       COALESCE(ASSOC_LJ2.COD_VINCULADO, 0) AS COD_ASSOCIADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       COALESCE(PRODUTO_LJ2.PD_TABELA_NUTRICIONAL, 0) AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
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
     SQL.Add('       COALESCE(P_LOJA_LJ2.FORNECEDOR, 0) AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       CAST(PRODUTO_LJ2.DATA_C AS DATE) AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       PRODUTO_LJ2.DSC AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR_LJ2 AS COD_BARRAS_LJ2 ON COD_BARRAS_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM_LJ2 AS P_LOJA_LJ2 ON P_LOJA_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_VINC_LJ2 AS ASSOC_LJ2 ON ASSOC_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_SIM_LJ2 AS P_SIMILAR_LJ2 ON P_SIMILAR_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   WHERE COD_BARRAS_LJ2.BARRAS NOT IN (SELECT COD_BARRAS.BARRAS FROM SM_CD_ES_PRODUTO_BAR COD_BARRAS)   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) >= 8');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) < 14   ');





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

procedure TFrmSmSuperComprasGestor.GerarReceitas;
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

procedure TFrmSmSuperComprasGestor.GerarScriptAmarrarCEST;
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

procedure TFrmSmSuperComprasGestor.GerarScriptCEST;
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

procedure TFrmSmSuperComprasGestor.GerarSecao;
var
   TotalCount : integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       COALESCE(SECAO.COD, 999) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(SECAO.DSC, ''A DEFINIR'') AS DES_SECAO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_DEPARTAMENTO AS SECAO   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT   ');
     SQL.Add('       COALESCE(999||SECAO_LJ2.COD, 999) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(''LJ2''||'' ''||SECAO_LJ2.DSC, ''A DEFINIR'') AS DES_SECAO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_DEPARTAMENTO_LJ2 AS SECAO_LJ2   ');
     SQL.Add('   WHERE ''LJ2''||'' ''||SECAO_LJ2.DSC NOT IN (SELECT SECAO.DSC FROM SM_CD_ES_DEPARTAMENTO SECAO)   ');


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

procedure TFrmSmSuperComprasGestor.GerarSubGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(PRODUTO.PD_DEPARTAMENTO, 999) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_GRUPO, 999) AS COD_GRUPO,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_SUB_GRUPO, 999) AS COD_SUB_GRUPO,   ');
     SQL.Add('       COALESCE(SUBGRUPO.DSC, ''A DEFINIR'') AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 AS VAL_META,   ');
     SQL.Add('       0 AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_SUB_GRUPO AS SUBGRUPO ON SUBGRUPO.COD = PRODUTO.PD_SUB_GRUPO   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(999||PRODUTO_LJ2.PD_DEPARTAMENTO, 999) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(999||PRODUTO_LJ2.PD_GRUPO, 999) AS COD_GRUPO,   ');
     SQL.Add('       COALESCE(999||PRODUTO_LJ2.PD_SUB_GRUPO, 999) AS COD_SUB_GRUPO,   ');
     SQL.Add('       COALESCE(''LJ2''||'' ''||SUBGRUPO_LJ2.DSC, ''A DEFINIR'') AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 AS VAL_META,   ');
     SQL.Add('       0 AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_SUB_GRUPO_LJ2 AS SUBGRUPO_LJ2 ON SUBGRUPO_LJ2.COD = PRODUTO_LJ2.PD_SUB_GRUPO   ');
     SQL.Add('   WHERE ''LJ2''||'' ''||SUBGRUPO_LJ2.DSC NOT IN (SELECT SUBGRUPO.DSC FROM SM_CD_ES_SUB_GRUPO SUBGRUPO)   ');


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

procedure TFrmSmSuperComprasGestor.GerarTransportadora;
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

procedure TFrmSmSuperComprasGestor.GerarValorVenda;
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

procedure TFrmSmSuperComprasGestor.GerarVenda;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT         ');
     SQL.Add('       PDV.PRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       1 AS COD_LOJA,   ');
     SQL.Add('       0 AS IND_TIPO,         ');
     SQL.Add('       PDV.PDV AS NUM_PDV,   ');
     SQL.Add('       PDV.QUANTIDADE AS QTD_TOTAL_PRODUTO,   ');
     SQL.Add('       PDV.VALOR_REAL AS VAL_TOTAL_PRODUTO,   ');
     SQL.Add('       PDV.VLR_UNT AS VAL_PRECO_VENDA,   ');
     SQL.Add('       PDV.PR_CUSTO AS VAL_CUSTO_REP,   ');
     SQL.Add('       PDV.DATA AS DTA_SAIDA,   ');
     SQL.Add('       REPLACE(SUBSTRING(PDV.DATA FROM 6 FOR 2), ''-'', '''') || REPLACE(SUBSTRING(PDV.DATA FROM 1 FOR 5), ''-'', '''') AS DTA_MENSAL,   ');
     SQL.Add('       PDV.ITEM AS NUM_IDENT,   ');
     SQL.Add('       COALESCE(PDV.PRODUTO_BARRAS, PDV.PRODUTO) AS COD_EAN,   ');
     SQL.Add('       ''0000'' AS DES_HORA,      ');
     SQL.Add('       ''202790'' AS COD_CLIENTE,   ');
     SQL.Add('       1 AS COD_ENTIDADE,         ');
     SQL.Add('       0 AS VAL_BASE_ICMS,         ');
     SQL.Add('       '''' AS DES_SITUACAO_TRIB,         ');
     SQL.Add('       0 AS VAL_ICMS,         ');
     SQL.Add('       PDV.CUPOM AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       PDV.VLR_UNT AS VAL_VENDA_PDV,   ');
     SQL.Add('       1 AS COD_TRIBUTACAO,         ');
     SQL.Add('       ''N'' AS FLG_CUPOM_CANCELADO,         ');
     SQL.Add('        ');
     SQL.Add('       CASE     ');
     SQL.Add('           WHEN P_FISCAL.NCM = '''' THEN ''99999999''    ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''00000000'' THEN ''99999999''     ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''0'' THEN ''99999999''     ');
     SQL.Add('           ELSE COALESCE(P_FISCAL.NCM, ''99999999'')      ');
     SQL.Add('       END AS NUM_NCM,         ');
     SQL.Add('        ');
     SQL.Add('       999 AS COD_TAB_SPED,         ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,         ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,         ');
     SQL.Add('       ''N'' AS FLG_ONLINE,         ');
     SQL.Add('       ''N'' AS FLG_OFERTA,         ');
     SQL.Add('       0 AS COD_ASSOCIADO         ');
     SQL.Add('   FROM         ');
     SQL.Add('       SM_MV_PDV_IT_CUP AS PDV   ');
//     SQL.Add('   --LEFT JOIN SM_MV_ES_IT_CP_NM AS PROD_VENDA ON PROD_VENDA.CUPOM_CUP = VENDA.CUPOM AND PROD_VENDA.EMPRESA = VENDA.EMPRESA   ');
//     SQL.Add('   --LEFT JOIN SM_MV_PDV_RD_CUP AS VENDA ON VENDA.CUPOM = PDV.CUPOM AND VENDA.EMPRESA = PDV.EMPRESA   ');
//     SQL.Add('   --INNER JOIN SM_CD_ES_PRODUTO AS PRODUTOS ON PRODUTOS.COD = PDV.PRODUTO   ');
//     SQL.Add('   --LEFT JOIN SM_CD_ES_PRODUTO_DNM AS P_LOJA ON P_LOJA.COD = PROD_VENDA.PRODUTO AND P_LOJA.EMPRESA = VENDA.EMPRESA   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FISCAL AS P_FISCAL ON P_FISCAL.COD = PDV.PRODUTO AND P_FISCAL.EMPRESA = PDV.EMPRESA   ');
//     SQL.Add('   --INNER JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PDV.PRODUTO AND COD_BARRAS.BARRAS = PDV.PRODUTO_BARRAS   ');
     SQL.Add('   WHERE PDV.DATA > ''31.03.2021''   ');
     SQL.Add('   AND PDV.DATA >= :INI   ');
     SQL.Add('   AND PDV.DATA <= :FIM   ');



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

procedure TFrmSmSuperComprasGestor.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmSuperComprasGestor.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmSuperComprasGestor.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmSuperComprasGestor.BtnGerarClick(Sender: TObject);
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

procedure TFrmSmSuperComprasGestor.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmSuperComprasGestor.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmSuperComprasGestor.CkbProdLojaClick(Sender: TObject);
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

procedure TFrmSmSuperComprasGestor.EdtCamBancoExit(Sender: TObject);
begin
  inherited;
  CriarFB(EdtCamBanco);
end;

procedure TFrmSmSuperComprasGestor.GeraCustoRep;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO.COD AS COD_PRODUTO,   ');
     SQL.Add('       P_LOJA.CUSTO_REPOSICAO AS VAL_CUSTO_REP   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM AS P_LOJA ON P_LOJA.COD = PRODUTO.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PRODUTO.COD   ');
     SQL.Add('   WHERE P_LOJA.CUSTO_REPOSICAO > 0   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS.BARRAS) < 14   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO_LJ2.COD + 2000000 AS COD_PRODUTO,   ');
     SQL.Add('       P_LOJA_LJ2.CUSTO_REPOSICAO AS VAL_CUSTO_REP   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM_LJ2 AS P_LOJA_LJ2 ON P_LOJA_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR_LJ2 AS COD_BARRAS_LJ2 ON COD_BARRAS_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   WHERE COD_BARRAS_LJ2.BARRAS NOT IN (SELECT COD_BARRAS.BARRAS FROM SM_CD_ES_PRODUTO_BAR COD_BARRAS)   ');
     SQL.Add('   AND P_LOJA_LJ2.CUSTO_REPOSICAO > 0   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) >= 8');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) < 14   ');





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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_CUSTO_REP = '''+QryPrincipal.FieldByName('VAL_CUSTO_REP').AsString+''' WHERE COD_PRODUTO = '''+COD_PRODUTO+''' AND COD_LOJA = '+CbxLoja.Text+' ; ');

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

procedure TFrmSmSuperComprasGestor.GeraEstoqueVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO.COD AS COD_PRODUTO,   ');
     SQL.Add('       P_LOJA.ESTOQUE AS QTD_EST_ATUAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM AS P_LOJA ON P_LOJA.COD = PRODUTO.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PRODUTO.COD   ');
     SQL.Add('   WHERE P_LOJA.ESTOQUE > 0   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS.BARRAS) < 14   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO_LJ2.COD + 2000000 AS COD_PRODUTO,   ');
     SQL.Add('       P_LOJA_LJ2.ESTOQUE AS QTD_EST_ATUAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM_LJ2 AS P_LOJA_LJ2 ON P_LOJA_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR_LJ2 AS COD_BARRAS_LJ2 ON COD_BARRAS_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   WHERE COD_BARRAS_LJ2.BARRAS NOT IN (SELECT COD_BARRAS.BARRAS FROM SM_CD_ES_PRODUTO_BAR COD_BARRAS)   ');
     SQL.Add('   AND P_LOJA_LJ2.ESTOQUE > 0   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) >= 8');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) < 14   ');




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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET QTD_EST_ATUAL = '''+QryPrincipal.FieldByName('QTD_EST_ATUAL').AsString+''' WHERE COD_PRODUTO = '+COD_PRODUTO+' AND COD_LOJA = '+CbxLoja.Text+' ; ');

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

procedure TFrmSmSuperComprasGestor.GerarCest;
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
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN TBCEST.CONTA = '''' THEN ''9999999''      ');
     SQL.Add('           WHEN TBCEST.CONTA = ''0000000'' THEN ''9999999''      ');
     SQL.Add('           ELSE COALESCE(TBCEST.CONTA, ''9999999'')       ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(TBCEST.DSC, ''A DEFINIR'') AS DES_CEST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_EF_CEST AS TBCEST   ');
     SQL.Add('   --LEFT JOIN SM_CD_ES_PRODUTO_FISCAL AS P_FISCAL ON P_FISCAL.CEST = TBCEST.CONTA   ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       0 AS COD_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN TBCEST_LJ2.CONTA = '''' THEN ''9999999''      ');
     SQL.Add('           WHEN TBCEST_LJ2.CONTA = ''0000000'' THEN ''9999999''      ');
     SQL.Add('           ELSE COALESCE(TBCEST_LJ2.CONTA, ''9999999'')       ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(TBCEST_LJ2.DSC, ''A DEFINIR'') AS DES_CEST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_EF_CEST_LJ2 AS TBCEST_LJ2   ');
     SQL.Add('   WHERE TBCEST_LJ2.CONTA NOT IN (SELECT TBCEST.CONTA FROM SM_CD_EF_CEST TBCEST)   ');



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

procedure TFrmSmSuperComprasGestor.GerarCliente;
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


     SQL.Add('           --LOJA1      ');
     SQL.Add('           SELECT      ');
     SQL.Add('               CLIENTE.COD AS COD_CLIENTE,      ');
     SQL.Add('               CLIENTE.PD_NOME AS DES_CLIENTE,      ');
     SQL.Add('                       CASE   ');
     SQL.Add('                           WHEN CLIENTE.PD_IE_ISENTO = 0 THEN LPAD(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(CLIENTE.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), ''''), 11, 0)   ');
     SQL.Add('                           WHEN CLIENTE.PD_IE_ISENTO = 1 THEN LPAD(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(CLIENTE.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), ''''), 14, 0)   ');
     SQL.Add('                           ELSE COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(CLIENTE.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''')   ');
     SQL.Add('                       END AS NUM_CGC,   ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTE.PD_IE_ISENTO = 1 THEN ''''      ');
     SQL.Add('                   ELSE COALESCE(CLIENTE.PD_IE, ''ISENTO'')      ');
     SQL.Add('               END AS NUM_INSC_EST,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE WHEN CLIENTE.PD_ENDERECO = '''' THEN ''A DEFINIR'' ELSE COALESCE(TRIM(CLIENTE.PD_ENDERECO), ''A DEFINIR'') END AS DES_ENDERECO,   ');
     SQL.Add('               CASE WHEN CLIENTE.PD_BAIRRO = '''' THEN ''A DEFINIR'' ELSE COALESCE(TRIM(CLIENTE.PD_BAIRRO), ''A DEFINIR'') END AS DES_BAIRRO,   ');
     SQL.Add('               CIDADES.NOME AS DES_CIDADE,      ');
     SQL.Add('               CIDADES.UF AS DES_SIGLA,      ');
     SQL.Add('               CLIENTE.PD_CEP AS NUM_CEP,      ');
     SQL.Add('               CLIENTE.PD_FONE AS NUM_FONE,      ');
     SQL.Add('               CLIENTE.PD_FAX AS NUM_FAX,      ');
     SQL.Add('               '''' AS DES_CONTATO,   ');
     SQL.Add('               CASE WHEN CLI.IP_SEXO = 1 THEN 1 ELSE 0 END AS FLG_SEXO,   ');
     SQL.Add('               0 AS VAL_LIMITE_CRETID,   ');
     SQL.Add('               COALESCE(CLI.IC_CO_LIMITE, 0) AS VAL_LIMITE_CONV,      ');
     SQL.Add('               0 AS VAL_DEBITO,      ');
     SQL.Add('               0 AS VAL_RENDA,      ');
     SQL.Add('               0 AS COD_CONVENIO,      ');
     SQL.Add('               0 AS COD_STATUS_PDV,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTE.PD_IE_ISENTO = 0 THEN ''N''      ');
     SQL.Add('                   ELSE ''S''      ');
     SQL.Add('               END AS FLG_EMPRESA,      ');
     SQL.Add('                     ');
     SQL.Add('               ''N'' AS FLG_CONVENIO,      ');
     SQL.Add('               ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('               CLIENTE.PD_DATA AS DTA_CADASTRO,      ');
     SQL.Add('               CASE WHEN CLIENTE.PD_NUMERO = '''' THEN ''S/N'' ELSE COALESCE(TRIM(UPPER(CLIENTE.PD_NUMERO)), ''S/N'') END AS NUM_ENDERECO,   ');
     SQL.Add('               CLIENTE.PD_RG AS NUM_RG,      ');
     SQL.Add('      ');
     SQL.Add('               CASE CLI.IP_ESTADOCIVIL   ');
     SQL.Add('                   WHEN 0 THEN 1   ');
     SQL.Add('                   WHEN 1 THEN 0   ');
     SQL.Add('                   WHEN 2 THEN 3   ');
     SQL.Add('                   WHEN 3 THEN 2   ');
     SQL.Add('                   WHEN 4 THEN 0   ');
     SQL.Add('                   ELSE 0   ');
     SQL.Add('               END AS FLG_EST_CIVIL,   ');
     SQL.Add('      ');
     SQL.Add('               CLIENTE.PD_MOVEL AS NUM_CELULAR,      ');
     SQL.Add('               CAST(CLIENTE.DATA_M AS DATE) AS DTA_ALTERACAO,      ');
     SQL.Add('               COALESCE(CAST(CLIENTE.OB_OBSERVACAO AS VARCHAR(500)), '''') AS DES_OBSERVACAO,      ');
     SQL.Add('               COALESCE(CLIENTE.PD_COMPLEMENTO, ''A DEFINIR'') AS DES_COMPLEMENTO,      ');
     SQL.Add('               CLIENTE.PD_EMAIL AS DES_EMAIL,      ');
     SQL.Add('               COALESCE(CLIENTE.PD_FANTASIA, CLIENTE.PD_NOME) AS DES_FANTASIA,      ');
     SQL.Add('               CLIENTE.PD_DTANASCCONST AS DTA_NASCIMENTO,      ');
     SQL.Add('               CASE WHEN POSITION(''/'', CLI.IP_PAI) = 27 THEN SUBSTRING(TRIM(CLI.IP_PAI) FROM 1 FOR 26) ELSE '''' END AS DES_PAI,   ');
     SQL.Add('               CASE WHEN POSITION(''/'', CLI.IP_PAI) = 27 THEN SUBSTRING(TRIM(CLI.IP_PAI) FROM 28 FOR 40) ELSE COALESCE(TRIM(CLI.IP_MAE), '''') END AS DES_MAE,   ');
     SQL.Add('               COALESCE(TRIM(CLI.IP_CONJ_NOME), '''') AS DES_CONJUGE,   ');
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
     SQL.Add('               SM_CD_MO_MOVIMENTADOR AS CLIENTE      ');
     SQL.Add('           LEFT JOIN (      ');
     SQL.Add('               SELECT DISTINCT      ');
     SQL.Add('                   CODIGO,      ');
     SQL.Add('                   NOME,      ');
     SQL.Add('                   UF      ');
     SQL.Add('               FROM      ');
     SQL.Add('                   ST_CD_CIDADES      ');
     SQL.Add('               GROUP BY CODIGO, NOME, UF      ');
     SQL.Add('           ) AS CIDADES      ');
     SQL.Add('           ON CLIENTE.PD_CIDADE = CIDADES.CODIGO      ');
     SQL.Add('           LEFT JOIN SM_CD_MO_MOVIMENTADOR_CL AS CLI ON CLI.COD = CLIENTE.COD   ');
     SQL.Add('           WHERE CLIENTE.TIPO = ''0''  ');
     SQL.Add('                 ');
     SQL.Add('           UNION ALL   ');
     SQL.Add('           --LOJA2      ');
     SQL.Add('           SELECT   ');
     SQL.Add('               CLIENTE_LJ2.COD + 200000 AS COD_CLIENTE_LJ2,      ');
     SQL.Add('               CLIENTE_LJ2.PD_NOME AS DES_CLIENTE_LJ2,      ');
     SQL.Add('                       CASE   ');
     SQL.Add('                           WHEN CLIENTE_LJ2.PD_IE_ISENTO = 0 THEN LPAD(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(CLIENTE_LJ2.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), ''''), 11, 0)   ');
     SQL.Add('                           WHEN CLIENTE_LJ2.PD_IE_ISENTO = 1 THEN LPAD(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(CLIENTE_LJ2.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), ''''), 14, 0)   ');
     SQL.Add('                           ELSE COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(CLIENTE_LJ2.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''')   ');
     SQL.Add('                       END AS NUM_CGC,   ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTE_LJ2.PD_IE_ISENTO = 1 THEN ''''      ');
     SQL.Add('                   ELSE COALESCE(CLIENTE_LJ2.PD_IE, ''ISENTO'')      ');
     SQL.Add('               END AS NUM_INSC_EST,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE WHEN CLIENTE_LJ2.PD_ENDERECO = '''' THEN ''A DEFINIR'' ELSE COALESCE(TRIM(CLIENTE_LJ2.PD_ENDERECO), ''A DEFINIR'') END AS DES_ENDERECO,   ');
     SQL.Add('               CASE WHEN CLIENTE_LJ2.PD_BAIRRO = '''' THEN ''A DEFINIR'' ELSE COALESCE(TRIM(CLIENTE_LJ2.PD_BAIRRO), ''A DEFINIR'') END AS DES_BAIRRO,   ');
     SQL.Add('               CIDADES_LJ2.NOME AS DES_CIDADE,      ');
     SQL.Add('               CIDADES_LJ2.UF AS DES_SIGLA,      ');
     SQL.Add('               CLIENTE_LJ2.PD_CEP AS NUM_CEP,      ');
     SQL.Add('               CLIENTE_LJ2.PD_FONE AS NUM_FONE,      ');
     SQL.Add('               CLIENTE_LJ2.PD_FAX AS NUM_FAX,      ');
     SQL.Add('               '''' AS DES_CONTATO,   ');
     SQL.Add('               CASE WHEN CLI_LJ2.IP_SEXO = 0 THEN 1 ELSE 0 END AS FLG_SEXO,   ');
     SQL.Add('               0 AS VAL_LIMITE_CRETID,      ');
     SQL.Add('               COALESCE(CLI_LJ2.IC_CO_LIMITE, 0) AS VAL_LIMITE_CONV,      ');
     SQL.Add('               0 AS VAL_DEBITO,      ');
     SQL.Add('               0 AS VAL_RENDA,      ');
     SQL.Add('               0 AS COD_CONVENIO,      ');
     SQL.Add('               0 AS COD_STATUS_PDV,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN CLIENTE_LJ2.PD_IE_ISENTO = 0 THEN ''N''      ');
     SQL.Add('                   ELSE ''S''      ');
     SQL.Add('               END AS FLG_EMPRESA,      ');
     SQL.Add('                     ');
     SQL.Add('               ''N'' AS FLG_CONVENIO,      ');
     SQL.Add('               ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('               CLIENTE_LJ2.PD_DATA AS DTA_CADASTRO,      ');
     SQL.Add('               CASE WHEN CLIENTE_LJ2.PD_NUMERO = '''' THEN ''S/N'' ELSE COALESCE(TRIM(UPPER(CLIENTE_LJ2.PD_NUMERO)), ''S/N'') END AS NUM_ENDERECO,   ');
     SQL.Add('               CLIENTE_LJ2.PD_RG AS NUM_RG,      ');
     SQL.Add('      ');
     SQL.Add('               CASE CLI_LJ2.IP_ESTADOCIVIL   ');
     SQL.Add('                   WHEN 0 THEN 1   ');
     SQL.Add('                   WHEN 1 THEN 0   ');
     SQL.Add('                   WHEN 2 THEN 3   ');
     SQL.Add('                   WHEN 3 THEN 2   ');
     SQL.Add('                   WHEN 4 THEN 0   ');
     SQL.Add('                   ELSE 0   ');
     SQL.Add('               END AS FLG_EST_CIVIL,   ');
     SQL.Add('      ');
     SQL.Add('               CLIENTE_LJ2.PD_MOVEL AS NUM_CELULAR,      ');
     SQL.Add('               CAST(CLIENTE_LJ2.DATA_M AS DATE) AS DTA_ALTERACAO,      ');
     SQL.Add('               COALESCE(CAST(CLIENTE_LJ2.OB_OBSERVACAO AS VARCHAR(500)), '''') AS DES_OBSERVACAO,      ');
     SQL.Add('               COALESCE(CLIENTE_LJ2.PD_COMPLEMENTO, ''A DEFINIR'') AS DES_COMPLEMENTO,      ');
     SQL.Add('               CLIENTE_LJ2.PD_EMAIL AS DES_EMAIL,      ');
     SQL.Add('               COALESCE(CLIENTE_LJ2.PD_FANTASIA, CLIENTE_LJ2.PD_NOME) AS DES_FANTASIA,      ');
     SQL.Add('               CLIENTE_LJ2.PD_DTANASCCONST AS DTA_NASCIMENTO,      ');
     SQL.Add('               CASE WHEN POSITION(''/'', CLI_LJ2.IP_PAI) = 27 THEN SUBSTRING(TRIM(CLI_LJ2.IP_PAI) FROM 1 FOR 26) ELSE '''' END AS DES_PAI,   ');
     SQL.Add('               CASE WHEN POSITION(''/'', CLI_LJ2.IP_PAI) = 27 THEN SUBSTRING(TRIM(CLI_LJ2.IP_PAI) FROM 28 FOR 40) ELSE COALESCE(TRIM(CLI_LJ2.IP_MAE), '''') END AS DES_MAE,   ');
     SQL.Add('               COALESCE(TRIM(CLI_LJ2.IP_CONJ_NOME), '''') AS DES_CONJUGE,   ');
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
     SQL.Add('               SM_CD_MO_MOVIMENTADOR_LJ2 AS CLIENTE_LJ2      ');
     SQL.Add('           LEFT JOIN (      ');
     SQL.Add('               SELECT DISTINCT      ');
     SQL.Add('                   CODIGO,      ');
     SQL.Add('                   NOME,      ');
     SQL.Add('                   UF      ');
     SQL.Add('               FROM      ');
     SQL.Add('                   ST_CD_CIDADES_LJ2      ');
     SQL.Add('               GROUP BY CODIGO, NOME, UF      ');
     SQL.Add('           ) AS CIDADES_LJ2      ');
     SQL.Add('           ON CLIENTE_LJ2.PD_CIDADE = CIDADES_LJ2.CODIGO      ');
     SQL.Add('           LEFT JOIN SM_CD_MO_MOVIMENTADOR_CL_LJ2 AS CLI_LJ2 ON CLI_LJ2.COD = CLIENTE_LJ2.COD   ');
     SQL.Add('           WHERE CLIENTE_LJ2.TIPO = ''0''     ');
     SQL.Add('           AND CLIENTE_LJ2.PD_CNPJ_CPF NOT IN (SELECT CLIENTE_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR CLIENTE_LJ1 WHERE CLIENTE_LJ1.TIPO = ''0'')   ');
     SQL.Add('      ');







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

procedure TFrmSmSuperComprasGestor.GerarCodigoBarras;
var
 count, NEW_CODPROD, TotalCount : Integer;
 cod_antigo, codbarras : string;
 QryGeraCodigoProduto : TSQLQuery;

begin
  inherited;

//  QryGeraCodigoProduto := TSQLQuery.Create(FrmProgresso);
//  with QryGeraCodigoProduto do
//  begin
//    SQLConnection := ScnBanco;

//    SQL.Clear;
//    SQL.Add('ALTER TABLE TAB_BARRAS_AUX ');
//    SQL.Add('ADD CODIGO_PRODUTO INT DEFAULT NULL; ');
//
//    try
//      ExecSQL;
//    except
//    end;

//    SQL.Clear;
//    SQL.Add('UPDATE PRODUTO_LJ1 ');
//    SQL.Add('SET CODIGO_PRODUTO = :COD_PRODUTO  ');
//    SQL.Add('WHERE COD_BARRA_AUX = :COD_EAN ');
//    SQL.Add('WHERE ATIVO = ''S'' ');

//    try
//      ExecSQL;
//    except
//    end;

//  end;




  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO.COD AS COD_PRODUTO,   ');
     SQL.Add('       COALESCE(COD_BARRAS.BARRAS, PRODUTO.COD) AS COD_EAN   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PRODUTO.COD   ');
     SQL.Add('   WHERE CHAR_LENGTH(COD_BARRAS.BARRAS) < 14   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO_LJ2.COD + 2000000 AS COD_PRODUTO,   ');
     SQL.Add('       COALESCE(COD_BARRAS_LJ2.BARRAS, PRODUTO_LJ2.COD) AS COD_EAN   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR_LJ2 AS COD_BARRAS_LJ2 ON COD_BARRAS_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   WHERE COD_BARRAS_LJ2.BARRAS NOT IN (SELECT COD_BARRAS.BARRAS FROM SM_CD_ES_PRODUTO_BAR COD_BARRAS)   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) >= 8');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) < 14   ');









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

procedure TFrmSmSuperComprasGestor.GerarComposicao;
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

procedure TFrmSmSuperComprasGestor.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

 SQL.Add('           SELECT      ');
 SQL.Add('               CLIENTE.COD AS COD_CLIENTE,      ');
 SQL.Add('               30 AS NUM_CONDICAO,      ');
 SQL.Add('               CASE CONDICAO.IC_CO_TIPO   ');
 SQL.Add('                  WHEN 0 THEN 13   ');
 SQL.Add('                  WHEN 1 THEN 2   ');
 SQL.Add('                  ELSE 2    ');
 SQL.Add('               END AS COD_CONDICAO,      ');
 SQL.Add('               4 AS COD_ENTIDADE      ');
 SQL.Add('           FROM      ');
 SQL.Add('               SM_CD_MO_MOVIMENTADOR AS CLIENTE      ');
 SQL.Add('           LEFT JOIN SM_CD_MO_MOVIMENTADOR_CL AS CONDICAO ON CONDICAO.COD = CLIENTE.COD      ');
 SQL.Add('           WHERE CLIENTE.TIPO = ''0'' ');
 SQL.Add('                 ');
 SQL.Add('           UNION ALL      ');
 SQL.Add('                 ');
 SQL.Add('           SELECT      ');
 SQL.Add('               CLIENTE_LJ2.COD + 200000 AS COD_CLIENTE,      ');
 SQL.Add('               30 AS NUM_CONDICAO,      ');
 SQL.Add('               CASE CONDICAO_LJ2.IC_CO_TIPO   ');
 SQL.Add('                  WHEN 0 THEN 13    ');
 SQL.Add('                  WHEN 1 THEN 2    ');
 SQL.Add('                  ELSE 2    ');
 SQL.Add('               END AS COD_CONDICAO,      ');
 SQL.Add('               4 AS COD_ENTIDADE      ');
 SQL.Add('           FROM      ');
 SQL.Add('               SM_CD_MO_MOVIMENTADOR_LJ2 AS CLIENTE_LJ2      ');
 SQL.Add('           LEFT JOIN SM_CD_MO_MOVIMENTADOR_CL_LJ2 AS CONDICAO_LJ2 ON CONDICAO_LJ2.COD = CLIENTE_LJ2.COD      ');
 SQL.Add('           WHERE CLIENTE_LJ2.TIPO = ''0''   ');
 SQL.Add('           AND CLIENTE_LJ2.PD_CNPJ_CPF NOT IN (SELECT CLIENTE_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR CLIENTE_LJ1 WHERE CLIENTE_LJ1.TIPO = ''0'')      ');
 SQL.Add('      ');



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

procedure TFrmSmSuperComprasGestor.GerarCondPagForn;
//var
//  COD_FORNECEDOR : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDOR.COD AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDOR.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_MO_MOVIMENTADOR AS FORNECEDOR   ');
     SQL.Add('   WHERE FORNECEDOR.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDOR_LJ2.COD + 200000 AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDOR_LJ2.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_MO_MOVIMENTADOR_LJ2 AS FORNECEDOR_LJ2   ');
     SQL.Add('   WHERE FORNECEDOR_LJ2.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')   ');
     SQL.Add('           AND FORNECEDOR_LJ2.PD_CNPJ_CPF NOT IN (SELECT FORNECEDOR_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR FORNECEDOR_LJ1 WHERE FORNECEDOR_LJ1.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5''))   ');



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

procedure TFrmSmSuperComprasGestor.GerarDecomposicao;
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

procedure TFrmSmSuperComprasGestor.GerarDivisaoForn;
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

procedure TFrmSmSuperComprasGestor.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmSuperComprasGestor.GerarFinanceiroPagar(Aberto: String);
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
           SQL.Add('   SELECT   ');
           SQL.Add('       1 AS TIPO_PARCEIRO,   ');
           SQL.Add('       CASE WHEN '+CbxLoja.Text+' = 1 THEN PAGAR.MOVIMENTADOR ELSE 0 END AS COD_PARCEIRO,   ');
           SQL.Add('       0 AS TIPO_CONTA,   ');
           SQL.Add('       8 AS COD_ENTIDADE,   ');
           SQL.Add('       P_PAGAR.LANCTO AS NUM_DOCTO,   ');
           SQL.Add('       999 AS COD_BANCO,   ');
           SQL.Add('       '''' AS DES_BANCO,   ');
           SQL.Add('       PAGAR.EMISSAO AS DTA_EMISSAO,   ');
           SQL.Add('       P_PAGAR.VENCIMENTO AS DTA_VENCIMENTO,   ');
           SQL.Add('       P_PAGAR.VALOR AS VAL_PARCELA,   ');
           SQL.Add('       (P_PAGAR.MULTA + P_PAGAR.JURO) AS VAL_JUROS,   ');
           SQL.Add('       P_PAGAR.DESCONTO AS VAL_DESCONTO,   ');
           SQL.Add('       ''N'' AS FLG_QUITADO,   ');
           SQL.Add('       '''' AS DTA_QUITADA,   ');
           SQL.Add('       998 AS COD_CATEGORIA,   ');
           SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
           SQL.Add('       P_PAGAR.PARCELA AS NUM_PARCELA,   ');
           SQL.Add('       1 AS QTD_PARCELA,   ');
           SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
           SQL.Add('       CASE   ');
           SQL.Add('           WHEN FORNEC.PD_CNPJ_CPF_TIPO = 0 THEN LPAD(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNEC.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), ''''), 14, 0)   ');
           SQL.Add('           ELSE LPAD(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNEC.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), ''''), 11, 0)   ');
           SQL.Add('       END AS NUM_CGC,   ');
           SQL.Add('       0 AS NUM_BORDERO,   ');
           SQL.Add('       P_PAGAR.LANCTO AS NUM_NF,   ');
           SQL.Add('       1 AS NUM_SERIE_NF,   ');
           SQL.Add('       VAL_NF.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
           SQL.Add('       PAGAR.OBSERVACAO AS DES_OBSERVACAO,   ');
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
           SQL.Add('       PAGAR.EMISSAO AS DTA_ENTRADA,   ');
           SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
           SQL.Add('       '''' AS COD_BARRA,   ');
           SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
           SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
           SQL.Add('       FORNEC.PD_NOME AS DES_TITULAR,   ');
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
           SQL.Add('       SM_MV_FI_TL_CB_TITULO AS PAGAR   ');
           SQL.Add('   LEFT JOIN SM_MV_FI_TL_PA_TITULO AS P_PAGAR ON PAGAR.LANCTO = P_PAGAR.LANCTO AND PAGAR.EMPRESA = P_PAGAR.EMPRESA   ');
           SQL.Add('   LEFT JOIN SM_CD_MO_MOVIMENTADOR AS FORNEC ON FORNEC.COD = PAGAR.MOVIMENTADOR   ');
           SQL.Add('   LEFT JOIN (   ');
           SQL.Add('       SELECT   ');
           SQL.Add('           LANCTO,   ');
           SQL.Add('           EMPRESA,   ');
           SQL.Add('           SUM(PARCELA + MULTA - DESCONTO) AS VAL_TOTAL_NF   ');
           SQL.Add('       FROM   ');
           SQL.Add('           SM_MV_FI_TL_PA_TITULO   ');
           SQL.Add('       GROUP BY LANCTO, EMPRESA           ');
           SQL.Add('   ) AS VAL_NF   ');
           SQL.Add('   ON PAGAR.LANCTO = VAL_NF.LANCTO AND PAGAR.EMPRESA = VAL_NF.EMPRESA  ');
           SQL.Add('   WHERE PAGAR.TIPO = 1   ');
           SQL.Add('   AND FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')  ');
//           SQL.Add('       (   ');
//           SQL.Add('           (   ');
//           SQL.Add('               '+CbxLoja.Text+' = 1 AND (FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5''))   ');
//           SQL.Add('               OR   ');
//           SQL.Add('               '+CbxLoja.Text+' = 2 AND (FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'') ');
//           SQL.Add('               AND FORNEC.PD_CNPJ_CPF NOT IN (SELECT FORNECEDOR_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR_LJ1 FORNECEDOR_LJ1 WHERE FORNECEDOR_LJ1.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'') ))   ');
//           SQL.Add('           )   ');
//           SQL.Add('       )    ');
           SQL.Add('   AND P_PAGAR.BAIXA IS NULL   ');
//           SQL.Add('AND');
//           SQL.Add('    PAGAR.EMISSAO >= :INI ');
//           SQL.Add('AND');
//           SQL.Add('    PAGAR.EMISSAO <= :FIM ');
//           ParamByName('INI').AsDate := DtpInicial.Date;
//           ParamByName('FIM').AsDate := DtpFinal.Date;


      end
      else
      begin
        //QUITADO
         SQL.Add('   SELECT   ');
         SQL.Add('       1 AS TIPO_PARCEIRO,   ');
         SQL.Add('       CASE WHEN '+CbxLoja.Text+' = 1 THEN PAGAR.MOVIMENTADOR ELSE 0 END AS COD_PARCEIRO,   ');
         SQL.Add('       0 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       P_PAGAR.LANCTO AS NUM_DOCTO,   ');
         SQL.Add('       999 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       PAGAR.EMISSAO AS DTA_EMISSAO,   ');
         SQL.Add('       P_PAGAR.VENCIMENTO AS DTA_VENCIMENTO,   ');
         SQL.Add('       P_PAGAR.VALOR AS VAL_PARCELA,   ');
         SQL.Add('       (P_PAGAR.MULTA + P_PAGAR.JURO) AS VAL_JUROS,   ');
         SQL.Add('       P_PAGAR.DESCONTO AS VAL_DESCONTO,   ');
         SQL.Add('       ''S'' AS FLG_QUITADO,   ');
         SQL.Add('       CASE WHEN P_PAGAR.BAIXA < PAGAR.EMISSAO THEN P_PAGAR.VENCIMENTO ELSE P_PAGAR.BAIXA END AS DTA_QUITADA,   ');
         SQL.Add('       998 AS COD_CATEGORIA,   ');
         SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       P_PAGAR.PARCELA AS NUM_PARCELA,   ');
         SQL.Add('       1 AS QTD_PARCELA,   ');
         SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
         SQL.Add('       CASE   ');
         SQL.Add('           WHEN FORNEC.PD_CNPJ_CPF_TIPO = 0 THEN LPAD(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNEC.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), ''''), 14, 0)   ');
         SQL.Add('           ELSE LPAD(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNEC.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), ''''), 11, 0)   ');
         SQL.Add('       END AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       P_PAGAR.LANCTO AS NUM_NF,   ');
         SQL.Add('       1 AS NUM_SERIE_NF,   ');
         SQL.Add('       VAL_NF.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
         SQL.Add('       PAGAR.OBSERVACAO AS DES_OBSERVACAO,   ');
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
         SQL.Add('       PAGAR.EMISSAO AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       FORNEC.PD_NOME AS DES_TITULAR,   ');
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
         SQL.Add('       SM_MV_FI_TL_CB_TITULO AS PAGAR   ');
         SQL.Add('   LEFT JOIN SM_MV_FI_TL_PA_TITULO AS P_PAGAR ON PAGAR.LANCTO = P_PAGAR.LANCTO AND PAGAR.EMPRESA = P_PAGAR.EMPRESA   ');
         SQL.Add('   LEFT JOIN SM_CD_MO_MOVIMENTADOR AS FORNEC ON FORNEC.COD = PAGAR.MOVIMENTADOR   ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('       SELECT   ');
         SQL.Add('           LANCTO,   ');
         SQL.Add('           EMPRESA,   ');
         SQL.Add('           SUM(PARCELA + MULTA - DESCONTO) AS VAL_TOTAL_NF   ');
         SQL.Add('       FROM   ');
         SQL.Add('           SM_MV_FI_TL_PA_TITULO   ');
         SQL.Add('       GROUP BY LANCTO, EMPRESA           ');
         SQL.Add('   ) AS VAL_NF   ');
         SQL.Add('   ON PAGAR.LANCTO = VAL_NF.LANCTO AND PAGAR.EMPRESA = VAL_NF.EMPRESA  ');
         SQL.Add('   WHERE PAGAR.TIPO = 1   ');
         SQL.Add('   AND FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')   ');
//         SQL.Add('       (   ');
//         SQL.Add('           (   ');
//         SQL.Add('               '+CbxLoja.Text+' = 1 AND (FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5''))   ');
//         SQL.Add('               OR   ');
//         SQL.Add('               '+CbxLoja.Text+' = 2 AND (FORNEC.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'') ');
//         SQL.Add('               AND FORNEC.PD_CNPJ_CPF NOT IN (SELECT FORNECEDOR_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR_LJ1 FORNECEDOR_LJ1 WHERE FORNECEDOR_LJ1.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'') ))   ');
//         SQL.Add('           )   ');
//         SQL.Add('       )    ');
         SQL.Add('   AND P_PAGAR.BAIXA IS NOT NULL   ');
         SQL.Add('AND');
         SQL.Add('    PAGAR.EMISSAO >= :INI ');
         SQL.Add('AND');
         SQL.Add('    PAGAR.EMISSAO <= :FIM ');
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

procedure TFrmSmSuperComprasGestor.GerarFinanceiroReceber(Aberto: String);
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
         SQL.Add('   SELECT   ');
         SQL.Add('       0 AS TIPO_PARCEIRO,   ');
         SQL.Add('       CASE WHEN '+CbxLoja.Text+' = 1 THEN RECEBER.MOVIMENTADOR ELSE 0 END AS COD_PARCEIRO,   ');
         SQL.Add('       1 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       R_RECEBER.LANCTO AS NUM_DOCTO,   ');
         SQL.Add('       999 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       RECEBER.EMISSAO AS DTA_EMISSAO,   ');
         SQL.Add('       R_RECEBER.VENCIMENTO AS DTA_VENCIMENTO,   ');
         SQL.Add('       R_RECEBER.VALOR AS VAL_PARCELA,   ');
         SQL.Add('       (R_RECEBER.MULTA + R_RECEBER.JURO) AS VAL_JUROS,   ');
         SQL.Add('       R_RECEBER.DESCONTO AS VAL_DESCONTO,   ');
         SQL.Add('       ''N'' AS FLG_QUITADO,   ');
         SQL.Add('       '''' AS DTA_QUITADA,   ');
         SQL.Add('       997 AS COD_CATEGORIA,   ');
         SQL.Add('       997 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       R_RECEBER.PARCELA AS NUM_PARCELA,   ');
         SQL.Add('       1 AS QTD_PARCELA,   ');
         SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(CLI.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       R_RECEBER.LANCTO AS NUM_NF,   ');
         SQL.Add('       1 AS NUM_SERIE_NF,   ');
         SQL.Add('       VAL_NF.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
         SQL.Add('       RECEBER.OBSERVACAO AS DES_OBSERVACAO,   ');
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
         SQL.Add('       RECEBER.EMISSAO AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       CLI.PD_NOME AS DES_TITULAR,   ');
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
         SQL.Add('       SM_MV_FI_TL_CB_TITULO AS RECEBER   ');
         SQL.Add('   LEFT JOIN SM_MV_FI_TL_PA_TITULO AS R_RECEBER ON RECEBER.LANCTO = R_RECEBER.LANCTO AND RECEBER.EMPRESA = R_RECEBER.EMPRESA  ');
         SQL.Add('   LEFT JOIN SM_CD_MO_MOVIMENTADOR AS CLI ON CLI.COD = RECEBER.MOVIMENTADOR   ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('       SELECT   ');
         SQL.Add('           LANCTO,   ');
         SQL.Add('           EMPRESA,   ');
         SQL.Add('           SUM(PARCELA + MULTA - DESCONTO) AS VAL_TOTAL_NF   ');
         SQL.Add('       FROM   ');
         SQL.Add('           SM_MV_FI_TL_PA_TITULO   ');
         SQL.Add('       GROUP BY LANCTO, EMPRESA           ');
         SQL.Add('   ) AS VAL_NF   ');
         SQL.Add('   ON RECEBER.LANCTO = VAL_NF.LANCTO AND RECEBER.EMPRESA = VAL_NF.EMPRESA  ');
         SQL.Add('   WHERE RECEBER.TIPO = 0   ');
         SQL.Add('   AND CLI.TIPO = ''0''   ');
//         SQL.Add('       (   ');
//         SQL.Add('           (   ');
//         SQL.Add('               '+CbxLoja.Text+' = 1 AND (CLI.TIPO = ''0'') ');
//         SQL.Add('               OR   ');
//         SQL.Add('               '+CbxLoja.Text+' = 2 AND (CLI.TIPO = ''0'' AND CLI.PD_CNPJ_CPF NOT IN (SELECT CLI_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR_LJ1 CLI_LJ1 WHERE CLI_LJ1.TIPO = ''0'' ))   ');
//         SQL.Add('           )   ');
//         SQL.Add('       )    ');
         SQL.Add('   AND R_RECEBER.BAIXA IS NULL   ');
//         SQL.Add('AND R_RECEBER.BAIXA >= :INI ');
//         SQL.Add('AND R_RECEBER.BAIXA <= :FIM ');
//
//      ParamByName('INI').AsDate := DtpInicial.Date;
//      ParamByName('FIM').AsDate := DtpFinal.Date;


      end
      else
      begin
       //QUITADO
         SQL.Add('   SELECT   ');
         SQL.Add('       0 AS TIPO_PARCEIRO,   ');
         SQL.Add('       CASE WHEN '+CbxLoja.Text+' = 1 THEN RECEBER.MOVIMENTADOR ELSE 0 END AS COD_PARCEIRO,   ');
         SQL.Add('       1 AS TIPO_CONTA,   ');
         SQL.Add('       8 AS COD_ENTIDADE,   ');
         SQL.Add('       R_RECEBER.LANCTO AS NUM_DOCTO,   ');
         SQL.Add('       999 AS COD_BANCO,   ');
         SQL.Add('       '''' AS DES_BANCO,   ');
         SQL.Add('       RECEBER.EMISSAO AS DTA_EMISSAO,   ');
         SQL.Add('       R_RECEBER.VENCIMENTO AS DTA_VENCIMENTO,   ');
         SQL.Add('       R_RECEBER.VALOR AS VAL_PARCELA,   ');
         SQL.Add('       (R_RECEBER.MULTA + R_RECEBER.JURO) AS VAL_JUROS,   ');
         SQL.Add('       R_RECEBER.DESCONTO AS VAL_DESCONTO,   ');
         SQL.Add('       ''S'' AS FLG_QUITADO,   ');
         SQL.Add('       CASE WHEN R_RECEBER.BAIXA < RECEBER.EMISSAO THEN R_RECEBER.VENCIMENTO ELSE R_RECEBER.BAIXA END AS DTA_QUITADA,   ');
         SQL.Add('       997 AS COD_CATEGORIA,   ');
         SQL.Add('       997 AS COD_SUBCATEGORIA,   ');
         SQL.Add('       R_RECEBER.PARCELA AS NUM_PARCELA,   ');
         SQL.Add('       1 AS QTD_PARCELA,   ');
         SQL.Add('       '+CbxLoja.Text+' AS COD_LOJA,   ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(CLI.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
         SQL.Add('       0 AS NUM_BORDERO,   ');
         SQL.Add('       R_RECEBER.LANCTO AS NUM_NF,   ');
         SQL.Add('       1 AS NUM_SERIE_NF,   ');
         SQL.Add('       VAL_NF.VAL_TOTAL_NF AS VAL_TOTAL_NF,   ');
         SQL.Add('       RECEBER.OBSERVACAO AS DES_OBSERVACAO,   ');
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
         SQL.Add('       RECEBER.EMISSAO AS DTA_ENTRADA,   ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,   ');
         SQL.Add('       '''' AS COD_BARRA,   ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,   ');
         SQL.Add('       CLI.PD_NOME AS DES_TITULAR,   ');
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
         SQL.Add('       SM_MV_FI_TL_CB_TITULO AS RECEBER   ');
         SQL.Add('   LEFT JOIN SM_MV_FI_TL_PA_TITULO AS R_RECEBER ON RECEBER.LANCTO = R_RECEBER.LANCTO AND RECEBER.EMPRESA = R_RECEBER.EMPRESA  ');
         SQL.Add('   LEFT JOIN SM_CD_MO_MOVIMENTADOR AS CLI ON CLI.COD = RECEBER.MOVIMENTADOR   ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('       SELECT   ');
         SQL.Add('           LANCTO,   ');
         SQL.Add('           EMPRESA,   ');
         SQL.Add('           SUM(PARCELA + MULTA - DESCONTO) AS VAL_TOTAL_NF   ');
         SQL.Add('       FROM   ');
         SQL.Add('           SM_MV_FI_TL_PA_TITULO   ');
         SQL.Add('       GROUP BY LANCTO, EMPRESA     ');
         SQL.Add('   ) AS VAL_NF   ');
         SQL.Add('   ON RECEBER.LANCTO = VAL_NF.LANCTO AND RECEBER.EMPRESA = VAL_NF.EMPRESA   ');
         SQL.Add('   WHERE RECEBER.TIPO = 0   ');
         SQL.Add('   AND CLI.TIPO = ''0''   ');
//         SQL.Add('       (   ');
//         SQL.Add('           (   ');
//         SQL.Add('               '+CbxLoja.Text+' = 1 AND (CLI.TIPO = ''0'') ');
//         SQL.Add('               OR   ');
//         SQL.Add('               '+CbxLoja.Text+' = 2 AND (CLI.TIPO = ''0'' AND CLI.PD_CNPJ_CPF NOT IN (SELECT CLI_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR_LJ1 CLI_LJ1 WHERE CLI_LJ1.TIPO = ''0'' ))   ');
//         SQL.Add('           )   ');
//         SQL.Add('       )    ');
         SQL.Add('   AND R_RECEBER.BAIXA IS NOT NULL   ');
         SQL.Add('AND R_RECEBER.BAIXA >= :INI ');
         SQL.Add('AND R_RECEBER.BAIXA <= :FIM ');

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

procedure TFrmSmSuperComprasGestor.GerarFinanceiroReceberCartao;
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

procedure TFrmSmSuperComprasGestor.GerarFornecedor;
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

     SQL.Add('           SELECT      ');
     SQL.Add('               FORNECEDOR.COD AS COD_FORNECEDOR,      ');
     SQL.Add('               FORNECEDOR.PD_NOME AS DES_FORNECEDOR,      ');
     SQL.Add('               FORNECEDOR.PD_FANTASIA AS DES_FANTASIA,      ');
     SQL.Add('               COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDOR.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN FORNECEDOR.PD_IE_ISENTO = 1 THEN ''ISENTO''      ');
     SQL.Add('                   ELSE COALESCE(FORNECEDOR.PD_IE, ''ISENTO'')      ');
     SQL.Add('               END AS NUM_INSC_EST,      ');
     SQL.Add('                     ');
     SQL.Add('               COALESCE(FORNECEDOR.PD_ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,      ');
     SQL.Add('               COALESCE(FORNECEDOR.PD_BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,      ');
     SQL.Add('               CIDADES.NOME AS DES_CIDADE,      ');
     SQL.Add('               CIDADES.UF AS DES_SIGLA,      ');
     SQL.Add('               FORNECEDOR.PD_CEP AS NUM_CEP,      ');
     SQL.Add('               FORNECEDOR.PD_FONE AS NUM_FONE,      ');
     SQL.Add('               FORNECEDOR.PD_FAX AS NUM_FAX,      ');
     SQL.Add('               '''' AS DES_CONTATO,      ');
     SQL.Add('               0 AS QTD_DIA_CARENCIA,      ');
     SQL.Add('               0 AS NUM_FREQ_VISITA,      ');
     SQL.Add('               0 AS VAL_DESCONTO,      ');
     SQL.Add('               0 AS NUM_PRAZO,      ');
     SQL.Add('               ''N'' AS ACEITA_DEVOL_MER,      ');
     SQL.Add('               ''N'' AS CAL_IPI_VAL_BRUTO,      ');
     SQL.Add('               ''N'' AS CAL_ICMS_ENC_FIN,      ');
     SQL.Add('               ''N'' AS CAL_ICMS_VAL_IPI,      ');
     SQL.Add('               ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('               FORNECEDOR.COD AS COD_FORNECEDOR_ANT,      ');
     SQL.Add('               COALESCE(TRIM(UPPER(FORNECEDOR.PD_NUMERO)), ''S/N'') AS NUM_ENDERECO,      ');
     SQL.Add('               COALESCE(CAST(TRIM(FORNECEDOR.OB_OBSERVACAO) AS VARCHAR(500)), '''') || '' '' || TRIM(FORNECEDOR.PD_COMPLEMENTO) AS DES_OBSERVACAO,   ');
     SQL.Add('               COALESCE(FORNECEDOR.PD_EMAIL, '''') AS DES_EMAIL,      ');
     SQL.Add('               COALESCE(FORNECEDOR.PD_SITE, '''') AS DES_WEB_SITE,      ');
     SQL.Add('               ''N'' AS FABRICANTE,      ');
     SQL.Add('               ''N'' AS FLG_PRODUTOR_RURAL,      ');
     SQL.Add('               0 AS TIPO_FRETE,      ');
     SQL.Add('               CASE WHEN FORN.IM_REGIME = 2 THEN ''S'' ELSE ''N'' END AS FLG_SIMPLES,   ');
     SQL.Add('               ''N'' AS FLG_SUBSTITUTO_TRIB,      ');
     SQL.Add('               0 AS COD_CONTACCFORN,      ');
     SQL.Add('               ''N'' AS INATIVO,      ');
     SQL.Add('               0 AS COD_CLASSIF,      ');
     SQL.Add('               FORNECEDOR.PD_DATA AS DTA_CADASTRO,      ');
     SQL.Add('               0 AS VAL_CREDITO,      ');
     SQL.Add('               0 AS VAL_DEBITO,      ');
     SQL.Add('               1 AS PED_MIN_VAL,      ');
     SQL.Add('               '''' AS DES_EMAIL_VEND,      ');
     SQL.Add('               '''' AS SENHA_COTACAO,      ');
     SQL.Add('               -1 AS TIPO_PRODUTOR,      ');
     SQL.Add('               FORNECEDOR.PD_MOVEL AS NUM_CELULAR      ');
     SQL.Add('           FROM      ');
     SQL.Add('               SM_CD_MO_MOVIMENTADOR AS FORNECEDOR      ');
     SQL.Add('           LEFT JOIN (      ');
     SQL.Add('               SELECT DISTINCT      ');
     SQL.Add('                   CODIGO,      ');
     SQL.Add('                   NOME,      ');
     SQL.Add('                   UF      ');
     SQL.Add('               FROM      ');
     SQL.Add('                   ST_CD_CIDADES      ');
     SQL.Add('               GROUP BY CODIGO, NOME, UF      ');
     SQL.Add('           ) AS CIDADES      ');
     SQL.Add('           ON FORNECEDOR.PD_CIDADE = CIDADES.CODIGO      ');
     SQL.Add('           LEFT JOIN SM_CD_MO_MOVIMENTADOR_FO_E AS FORN ON FORN.COD = FORNECEDOR.COD   ');
     SQL.Add('           WHERE FORNECEDOR.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')      ');
     SQL.Add('                 ');
     SQL.Add('           UNION ALL      ');
     SQL.Add('                 ');
     SQL.Add('           SELECT      ');
     SQL.Add('               FORNECEDOR_LJ2.COD + 200000 AS COD_FORNECEDOR_LJ2,      ');
     SQL.Add('               FORNECEDOR_LJ2.PD_NOME AS DES_FORNECEDOR_LJ2,      ');
     SQL.Add('               FORNECEDOR_LJ2.PD_FANTASIA AS DES_FANTASIA,      ');
     SQL.Add('               COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDOR_LJ2.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
     SQL.Add('                     ');
     SQL.Add('               CASE      ');
     SQL.Add('                   WHEN FORNECEDOR_LJ2.PD_IE_ISENTO = 1 THEN ''ISENTO''      ');
     SQL.Add('                   ELSE COALESCE(FORNECEDOR_LJ2.PD_IE, ''ISENTO'')      ');
     SQL.Add('               END AS NUM_INSC_EST,      ');
     SQL.Add('                     ');
     SQL.Add('               COALESCE(FORNECEDOR_LJ2.PD_ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,      ');
     SQL.Add('               COALESCE(FORNECEDOR_LJ2.PD_BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,      ');
     SQL.Add('               CIDADES_LJ2.NOME AS DES_CIDADE,      ');
     SQL.Add('               CIDADES_LJ2.UF AS DES_SIGLA,      ');
     SQL.Add('               FORNECEDOR_LJ2.PD_CEP AS NUM_CEP,      ');
     SQL.Add('               FORNECEDOR_LJ2.PD_FONE AS NUM_FONE,      ');
     SQL.Add('               FORNECEDOR_LJ2.PD_FAX AS NUM_FAX,      ');
     SQL.Add('               '''' AS DES_CONTATO,      ');
     SQL.Add('               0 AS QTD_DIA_CARENCIA,      ');
     SQL.Add('               0 AS NUM_FREQ_VISITA,      ');
     SQL.Add('               0 AS VAL_DESCONTO,      ');
     SQL.Add('               0 AS NUM_PRAZO,      ');
     SQL.Add('               ''N'' AS ACEITA_DEVOL_MER,      ');
     SQL.Add('               ''N'' AS CAL_IPI_VAL_BRUTO,      ');
     SQL.Add('               ''N'' AS CAL_ICMS_ENC_FIN,      ');
     SQL.Add('               ''N'' AS CAL_ICMS_VAL_IPI,      ');
     SQL.Add('               ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('               FORNECEDOR_LJ2.COD AS COD_FORNECEDOR_ANT,      ');
     SQL.Add('               COALESCE(TRIM(UPPER(FORNECEDOR_LJ2.PD_NUMERO)), ''S/N'') AS NUM_ENDERECO,      ');
     SQL.Add('               COALESCE(CAST(TRIM(FORNECEDOR_LJ2.OB_OBSERVACAO) AS VARCHAR(500)), '''') || '' '' || TRIM(FORNECEDOR_LJ2.PD_COMPLEMENTO) AS DES_OBSERVACAO,   ');
     SQL.Add('               COALESCE(FORNECEDOR_LJ2.PD_EMAIL, '''') AS DES_EMAIL,      ');
     SQL.Add('               COALESCE(FORNECEDOR_LJ2.PD_SITE, '''') AS DES_WEB_SITE,      ');
     SQL.Add('               ''N'' AS FABRICANTE,      ');
     SQL.Add('               ''N'' AS FLG_PRODUTOR_RURAL,      ');
     SQL.Add('               0 AS TIPO_FRETE,      ');
     SQL.Add('               CASE WHEN FORN_LJ2.IM_REGIME = 2 THEN ''S'' ELSE ''N'' END AS FLG_SIMPLES,   ');
     SQL.Add('               ''N'' AS FLG_SUBSTITUTO_TRIB,      ');
     SQL.Add('               0 AS COD_CONTACCFORN,      ');
     SQL.Add('               ''N'' AS INATIVO,      ');
     SQL.Add('               0 AS COD_CLASSIF,      ');
     SQL.Add('               FORNECEDOR_LJ2.PD_DATA AS DTA_CADASTRO,      ');
     SQL.Add('               0 AS VAL_CREDITO,      ');
     SQL.Add('               0 AS VAL_DEBITO,      ');
     SQL.Add('               1 AS PED_MIN_VAL,      ');
     SQL.Add('               '''' AS DES_EMAIL_VEND,      ');
     SQL.Add('               '''' AS SENHA_COTACAO,      ');
     SQL.Add('               -1 AS TIPO_PRODUTOR,      ');
     SQL.Add('               FORNECEDOR_LJ2.PD_MOVEL AS NUM_CELULAR      ');
     SQL.Add('           FROM      ');
     SQL.Add('               SM_CD_MO_MOVIMENTADOR_LJ2 AS FORNECEDOR_LJ2      ');
     SQL.Add('           LEFT JOIN (      ');
     SQL.Add('               SELECT DISTINCT      ');
     SQL.Add('                   CODIGO,      ');
     SQL.Add('                   NOME,      ');
     SQL.Add('                   UF      ');
     SQL.Add('               FROM      ');
     SQL.Add('                   ST_CD_CIDADES_LJ2      ');
     SQL.Add('               GROUP BY CODIGO, NOME, UF      ');
     SQL.Add('           ) AS CIDADES_LJ2      ');
     SQL.Add('           ON FORNECEDOR_LJ2.PD_CIDADE = CIDADES_LJ2.CODIGO      ');
     SQL.Add('           LEFT JOIN SM_CD_MO_MOVIMENTADOR_FO_E_LJ2 AS FORN_LJ2 ON FORN_LJ2.COD = FORNECEDOR_LJ2.COD   ');
     SQL.Add('           WHERE FORNECEDOR_LJ2.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')      ');
     SQL.Add('           AND FORNECEDOR_LJ2.PD_CNPJ_CPF NOT IN (SELECT FORNECEDOR_LJ1.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR FORNECEDOR_LJ1 WHERE FORNECEDOR_LJ1.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5''))   ');



//         SQL.Add('   SELECT      ');
//         SQL.Add('               FORNECEDOR.COD AS COD_FORNECEDOR,      ');
//         SQL.Add('               FORNECEDOR.PD_NOME AS DES_FORNECEDOR,      ');
//         SQL.Add('               FORNECEDOR.PD_FANTASIA AS DES_FANTASIA,      ');
//         SQL.Add('               COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDOR.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
//         SQL.Add('                     ');
//         SQL.Add('               CASE      ');
//         SQL.Add('                   WHEN FORNECEDOR.PD_IE_ISENTO = 1 THEN ''ISENTO''      ');
//         SQL.Add('                   ELSE COALESCE(FORNECEDOR.PD_IE, ''ISENTO'')      ');
//         SQL.Add('               END AS NUM_INSC_EST,      ');
//         SQL.Add('                     ');
//         SQL.Add('               COALESCE(FORNECEDOR.PD_ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,      ');
//         SQL.Add('               COALESCE(FORNECEDOR.PD_BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,      ');
//         SQL.Add('               CIDADES.NOME AS DES_CIDADE,      ');
//         SQL.Add('               CIDADES.UF AS DES_SIGLA,      ');
//         SQL.Add('               FORNECEDOR.PD_CEP AS NUM_CEP,      ');
//         SQL.Add('               FORNECEDOR.PD_FONE AS NUM_FONE,      ');
//         SQL.Add('               FORNECEDOR.PD_FAX AS NUM_FAX,      ');
//         SQL.Add('               FORNECEDOR.PD_NOME AS DES_CONTATO,      ');
//         SQL.Add('               0 AS QTD_DIA_CARENCIA,      ');
//         SQL.Add('               0 AS NUM_FREQ_VISITA,      ');
//         SQL.Add('               0 AS VAL_DESCONTO,      ');
//         SQL.Add('               0 AS NUM_PRAZO,      ');
//         SQL.Add('               ''N'' AS ACEITA_DEVOL_MER,      ');
//         SQL.Add('               ''N'' AS CAL_IPI_VAL_BRUTO,      ');
//         SQL.Add('               ''N'' AS CAL_ICMS_ENC_FIN,      ');
//         SQL.Add('               ''N'' AS CAL_ICMS_VAL_IPI,      ');
//         SQL.Add('               ''N'' AS MICRO_EMPRESA,      ');
//         SQL.Add('               FORNECEDOR.COD AS COD_FORNECEDOR_ANT,      ');
//         SQL.Add('               COALESCE(TRIM(UPPER(FORNECEDOR.PD_NUMERO)), ''S/N'') AS NUM_ENDERECO,      ');
//         SQL.Add('               COALESCE(CAST(FORNECEDOR.OB_OBSERVACAO AS VARCHAR(500)), '''') AS DES_OBSERVACAO,      ');
//         SQL.Add('               COALESCE(FORNECEDOR.PD_EMAIL, '''') AS DES_EMAIL,      ');
//         SQL.Add('               COALESCE(FORNECEDOR.PD_SITE, '''') AS DES_WEB_SITE,      ');
//         SQL.Add('               ''N'' AS FABRICANTE,      ');
//         SQL.Add('               ''N'' AS FLG_PRODUTOR_RURAL,      ');
//         SQL.Add('               0 AS TIPO_FRETE,      ');
//         SQL.Add('               ''N'' AS FLG_SIMPLES,      ');
//         SQL.Add('               ''N'' AS FLG_SUBSTITUTO_TRIB,      ');
//         SQL.Add('               0 AS COD_CONTACCFORN,      ');
//         SQL.Add('               ''N'' AS INATIVO,      ');
//         SQL.Add('               0 AS COD_CLASSIF,      ');
//         SQL.Add('               FORNECEDOR.PD_DATA AS DTA_CADASTRO,      ');
//         SQL.Add('               0 AS VAL_CREDITO,      ');
//         SQL.Add('               0 AS VAL_DEBITO,      ');
//         SQL.Add('               1 AS PED_MIN_VAL,      ');
//         SQL.Add('               '''' AS DES_EMAIL_VEND,      ');
//         SQL.Add('               '''' AS SENHA_COTACAO,      ');
//         SQL.Add('               -1 AS TIPO_PRODUTOR,      ');
//         SQL.Add('               FORNECEDOR.PD_MOVEL AS NUM_CELULAR      ');
//         SQL.Add('           FROM      ');
//         SQL.Add('               SM_CD_MO_MOVIMENTADOR AS FORNECEDOR      ');
//         SQL.Add('           LEFT JOIN (      ');
//         SQL.Add('               SELECT DISTINCT      ');
//         SQL.Add('                   CODIGO,      ');
//         SQL.Add('                   NOME,      ');
//         SQL.Add('                   UF      ');
//         SQL.Add('               FROM      ');
//         SQL.Add('                   ST_CD_CIDADES      ');
//         SQL.Add('               GROUP BY CODIGO, NOME, UF      ');
//         SQL.Add('           ) AS CIDADES      ');
//         SQL.Add('           ON FORNECEDOR.PD_CIDADE = CIDADES.CODIGO      ');
//         SQL.Add('           WHERE FORNECEDOR.TIPO IN (''1'', ''1,2'', ''3'')      ');
//         SQL.Add('           AND FORNECEDOR.COD IN (300441,   ');
//         SQL.Add('   301177,   ');
//         SQL.Add('   301180,   ');
//         SQL.Add('   301182,   ');
//         SQL.Add('   301190,   ');
//         SQL.Add('   301191,   ');
//         SQL.Add('   301202,   ');
//         SQL.Add('   301207,   ');
//         SQL.Add('   301214,   ');
//         SQL.Add('   301215,   ');
//         SQL.Add('   301218,   ');
//         SQL.Add('   301226,   ');
//         SQL.Add('   301227,   ');
//         SQL.Add('   301233,   ');
//         SQL.Add('   301236,   ');
//         SQL.Add('   301241,   ');
//         SQL.Add('   301244,   ');
//         SQL.Add('   301257,   ');
//         SQL.Add('   301258,   ');
//         SQL.Add('   301261,   ');
//         SQL.Add('   301275,   ');
//         SQL.Add('   301281,   ');
//         SQL.Add('   301291,   ');
//         SQL.Add('   301299,   ');
//         SQL.Add('   301312,   ');
//         SQL.Add('   301315,   ');
//         SQL.Add('   301329,   ');
//         SQL.Add('   301336,   ');
//         SQL.Add('   301341,   ');
//         SQL.Add('   301372,   ');
//         SQL.Add('   301390,   ');
//         SQL.Add('   301393,   ');
//         SQL.Add('   301394,   ');
//         SQL.Add('   301403,   ');
//         SQL.Add('   301406,   ');
//         SQL.Add('   301414,   ');
//         SQL.Add('   301415,   ');
//         SQL.Add('   301422,   ');
//         SQL.Add('   301438,   ');
//         SQL.Add('   301443,   ');
//         SQL.Add('   301444,   ');
//         SQL.Add('   301455,   ');
//         SQL.Add('   301465,   ');
//         SQL.Add('   301469,   ');
//         SQL.Add('   301476,   ');
//         SQL.Add('   301481,   ');
//         SQL.Add('   301496,   ');
//         SQL.Add('   301505,   ');
//         SQL.Add('   301513,   ');
//         SQL.Add('   301515,   ');
//         SQL.Add('   301536,   ');
//         SQL.Add('   301542,   ');
//         SQL.Add('   301547,   ');
//         SQL.Add('   301558,   ');
//         SQL.Add('   301579,   ');
//         SQL.Add('   301581,   ');
//         SQL.Add('   301595,   ');
//         SQL.Add('   301606,   ');
//         SQL.Add('   301615,   ');
//         SQL.Add('   301631,   ');
//         SQL.Add('   301638,   ');
//         SQL.Add('   301639,   ');
//         SQL.Add('   301640,   ');
//         SQL.Add('   301641,   ');
//         SQL.Add('   301642,   ');
//         SQL.Add('   301643,   ');
//         SQL.Add('   301646,   ');
//         SQL.Add('   301647)   ');





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

procedure TFrmSmSuperComprasGestor.GerarGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(GRUPO.DEP, 999) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(GRUPO.COD, 999) AS COD_GRUPO,   ');
     SQL.Add('       COALESCE(GRUPO.DSC, ''A DEFINIR'') AS DES_GRUPO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_GRUPO AS GRUPO   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       COALESCE(999||GRUPO_LJ2.DEP, 999) AS COD_SECAO,   ');
     SQL.Add('       COALESCE(999||GRUPO_LJ2.COD, 999) AS COD_GRUPO,   ');
     SQL.Add('       COALESCE(''LJ2''||'' ''||GRUPO_LJ2.DSC, ''A DEFINIR'') AS DES_GRUPO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_GRUPO_LJ2 AS GRUPO_LJ2   ');
     SQL.Add('   WHERE ''LJ2''||'' ''||GRUPO_LJ2.DSC NOT IN (SELECT GRUPO.DSC FROM SM_CD_ES_GRUPO GRUPO)   ');


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

procedure TFrmSmSuperComprasGestor.GerarInfoNutricionais;
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

procedure TFrmSmSuperComprasGestor.GerarNCM;
var
 count, TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT      ');
     SQL.Add('       0 AS COD_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN NCM.DSC = '''' THEN ''A DEFINIR''      ');
     SQL.Add('           ELSE COALESCE(NCM.DSC, ''A DEFINIR'')       ');
     SQL.Add('       END AS DES_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN P_FISCAL.NCM = '''' THEN ''99999999''      ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''00000000'' THEN ''99999999''       ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''0'' THEN ''99999999''       ');
     SQL.Add('           ELSE COALESCE(P_FISCAL.NCM, ''99999999'')        ');
     SQL.Add('       END AS NUM_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,      ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,      ');
     SQL.Add('       999 AS COD_TAB_SPED,      ');
     SQL.Add('             ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN P_FISCAL.CEST = '''' THEN ''9999999''         ');
     SQL.Add('           WHEN P_FISCAL.CEST = ''0000000'' THEN ''9999999''         ');
     SQL.Add('           ELSE COALESCE(P_FISCAL.CEST, ''9999999'')          ');
     SQL.Add('       END AS NUM_CEST,      ');
     SQL.Add('             ');
     SQL.Add('       ''MT'' AS DES_SIGLA,      ');
     SQL.Add('          ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''41'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''90'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''4.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''67.0600'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''5'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''7'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''25.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''35.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,      ');
     SQL.Add('          ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''41'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''90'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''4.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''67.0600'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''5'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''7'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''25.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''35.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_SAIDA,      ');
     SQL.Add('          ');
     SQL.Add('       0 AS PER_IVA,      ');
     SQL.Add('       0 AS PER_FCP_ST      ');
     SQL.Add('   FROM      ');
     SQL.Add('       SM_CD_EF_NCM_SH AS NCM      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FISCAL AS P_FISCAL ON P_FISCAL.NCM = NCM.CONTA   ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           TAB_PROD_ICMS.ALIQUOTA AS VAL_ICMS,   ');
//     SQL.Add('           TAB_PROD_ICMS.BASE_CALCULO AS VAL_REDUCAO_BASE_CALCULO,   ');
//     SQL.Add('           CAST(TAB_PROD_ICMS.ORIGEM AS INT) + CAST(TAB_PROD_ICMS.ICMS AS INT) AS COD_SIT_TRIBUTARIA,   ');
//     SQL.Add('           TAB_PROD_ICMS.NCM   ');
//     SQL.Add('               FROM   ');
//     SQL.Add('           SM_CD_EF_NCM_ICMS AS TAB_PROD_ICMS   ');
//     SQL.Add('           WHERE TAB_PROD_ICMS.DESTINO_UF = ''MT''   ');
//     SQL.Add('   ) AS TRIB_LJ1   ');
//     SQL.Add('   ON P_FISCAL.NCM = TRIB_LJ1.NCM     ');
     SQL.Add('         ');
     SQL.Add('   UNION ALL      ');
     SQL.Add('         ');
     SQL.Add('   SELECT DISTINCT      ');
     SQL.Add('       0 AS COD_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN NCM_LJ2.DSC = '''' THEN ''A DEFINIR''      ');
     SQL.Add('           ELSE COALESCE(NCM_LJ2.DSC, ''A DEFINIR'')       ');
     SQL.Add('       END AS DES_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = '''' THEN ''99999999''      ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = ''00000000'' THEN ''99999999''       ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = ''0'' THEN ''99999999''       ');
     SQL.Add('           ELSE COALESCE(P_FISCAL_LJ2.NCM, ''99999999'')        ');
     SQL.Add('       END AS NUM_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,      ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,      ');
     SQL.Add('       999 AS COD_TAB_SPED,      ');
     SQL.Add('             ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN P_FISCAL_LJ2.CEST = '''' THEN ''9999999''         ');
     SQL.Add('           WHEN P_FISCAL_LJ2.CEST = ''0000000'' THEN ''9999999''         ');
     SQL.Add('           ELSE COALESCE(P_FISCAL_LJ2.CEST, ''9999999'')          ');
     SQL.Add('       END AS NUM_CEST,      ');
     SQL.Add('             ');
     SQL.Add('       ''MT'' AS DES_SIGLA,      ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''40'' THEN 1   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''41'' THEN 23   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 22   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''4.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 27   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 6   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 3   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 39   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 40   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 41   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 42   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''25.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 5   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,      ');
     SQL.Add('          ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''40'' THEN 1   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''41'' THEN 23   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 22   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''4.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 27   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 6   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 3   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 39   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 40   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 41   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 42   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''25.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 5   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_SAIDA,      ');
     SQL.Add('          ');
     SQL.Add('       0 AS PER_IVA,      ');
     SQL.Add('       0 AS PER_FCP_ST      ');
     SQL.Add('   FROM      ');
     SQL.Add('       SM_CD_EF_NCM_SH_LJ2 AS NCM_LJ2      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FISCAL_LJ2 AS P_FISCAL_LJ2 ON P_FISCAL_LJ2.NCM = NCM_LJ2.CONTA      ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.ALIQUOTA AS VAL_ICMS,   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.BASE_CALCULO AS VAL_REDUCAO_BASE_CALCULO,   ');
//     SQL.Add('           CAST(TAB_PROD_ICMS_LJ2.ORIGEM AS INT) + CAST(TAB_PROD_ICMS_LJ2.ICMS AS INT) AS COD_SIT_TRIBUTARIA,   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.NCM   ');
//     SQL.Add('               FROM   ');
//     SQL.Add('           SM_CD_EF_NCM_ICMS_LJ2 AS TAB_PROD_ICMS_LJ2   ');
//     SQL.Add('           WHERE TAB_PROD_ICMS_LJ2.DESTINO_UF = ''MT''   ');
//     SQL.Add('   ) AS TRIB_LJ2   ');
//     SQL.Add('   ON P_FISCAL_LJ2.NCM = TRIB_LJ2.NCM   ');
     SQL.Add('   WHERE P_FISCAL_LJ2.NCM NOT IN (SELECT P_FISCAL.NCM FROM SM_CD_ES_PRODUTO_FISCAL P_FISCAL)   ');





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

procedure TFrmSmSuperComprasGestor.GerarNCMUF;
var
 count, TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT      ');
     SQL.Add('       0 AS COD_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN NCM.DSC = '''' THEN ''A DEFINIR''      ');
     SQL.Add('           ELSE COALESCE(NCM.DSC, ''A DEFINIR'')       ');
     SQL.Add('       END AS DES_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN P_FISCAL.NCM = '''' THEN ''99999999''      ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''00000000'' THEN ''99999999''       ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''0'' THEN ''99999999''       ');
     SQL.Add('           ELSE COALESCE(P_FISCAL.NCM, ''99999999'')        ');
     SQL.Add('       END AS NUM_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,      ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,      ');
     SQL.Add('       999 AS COD_TAB_SPED,      ');
     SQL.Add('             ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN P_FISCAL.CEST = '''' THEN ''9999999''         ');
     SQL.Add('           WHEN P_FISCAL.CEST = ''0000000'' THEN ''9999999''         ');
     SQL.Add('           ELSE COALESCE(P_FISCAL.CEST, ''9999999'')          ');
     SQL.Add('       END AS NUM_CEST,      ');
     SQL.Add('             ');
     SQL.Add('       ''MT'' AS DES_SIGLA,      ');
     SQL.Add('          ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''41'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''90'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''4.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''67.0600'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''5'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''7'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''25.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''35.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,      ');
     SQL.Add('          ');
//     SQL.Add('       CASE    ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''41'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''90'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''4.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''67.0600'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''5'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''7'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''25.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''35.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_SAIDA,      ');
     SQL.Add('          ');
     SQL.Add('       0 AS PER_IVA,      ');
     SQL.Add('       0 AS PER_FCP_ST      ');
     SQL.Add('   FROM      ');
     SQL.Add('       SM_CD_EF_NCM_SH AS NCM      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FISCAL AS P_FISCAL ON P_FISCAL.NCM = NCM.CONTA   ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           TAB_PROD_ICMS.ALIQUOTA AS VAL_ICMS,   ');
//     SQL.Add('           TAB_PROD_ICMS.BASE_CALCULO AS VAL_REDUCAO_BASE_CALCULO,   ');
//     SQL.Add('           CAST(TAB_PROD_ICMS.ORIGEM AS INT) + CAST(TAB_PROD_ICMS.ICMS AS INT) AS COD_SIT_TRIBUTARIA,   ');
//     SQL.Add('           TAB_PROD_ICMS.NCM   ');
//     SQL.Add('               FROM   ');
//     SQL.Add('           SM_CD_EF_NCM_ICMS AS TAB_PROD_ICMS   ');
//     SQL.Add('           WHERE TAB_PROD_ICMS.DESTINO_UF = ''MT''   ');
//     SQL.Add('   ) AS TRIB_LJ1   ');
//     SQL.Add('   ON P_FISCAL.NCM = TRIB_LJ1.NCM     ');
     SQL.Add('         ');
     SQL.Add('   UNION ALL      ');
     SQL.Add('         ');
     SQL.Add('   SELECT DISTINCT      ');
     SQL.Add('       0 AS COD_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN NCM_LJ2.DSC = '''' THEN ''A DEFINIR''      ');
     SQL.Add('           ELSE COALESCE(NCM_LJ2.DSC, ''A DEFINIR'')       ');
     SQL.Add('       END AS DES_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = '''' THEN ''99999999''      ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = ''00000000'' THEN ''99999999''       ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = ''0'' THEN ''99999999''       ');
     SQL.Add('           ELSE COALESCE(P_FISCAL_LJ2.NCM, ''99999999'')        ');
     SQL.Add('       END AS NUM_NCM,      ');
     SQL.Add('             ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,      ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,      ');
     SQL.Add('       999 AS COD_TAB_SPED,      ');
     SQL.Add('             ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN P_FISCAL_LJ2.CEST = '''' THEN ''9999999''         ');
     SQL.Add('           WHEN P_FISCAL_LJ2.CEST = ''0000000'' THEN ''9999999''         ');
     SQL.Add('           ELSE COALESCE(P_FISCAL_LJ2.CEST, ''9999999'')          ');
     SQL.Add('       END AS NUM_CEST,      ');
     SQL.Add('             ');
     SQL.Add('       ''MT'' AS DES_SIGLA,      ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''40'' THEN 1   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''41'' THEN 23   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 22   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''4.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 27   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 6   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 3   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 39   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 40   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 41   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 42   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''25.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 5   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,      ');
     SQL.Add('          ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''40'' THEN 1   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''41'' THEN 23   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 22   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''4.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 27   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 6   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 3   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 39   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 40   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 41   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 42   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''25.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 5   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_SAIDA,      ');
     SQL.Add('          ');
     SQL.Add('       0 AS PER_IVA,      ');
     SQL.Add('       0 AS PER_FCP_ST      ');
     SQL.Add('   FROM      ');
     SQL.Add('       SM_CD_EF_NCM_SH_LJ2 AS NCM_LJ2      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FISCAL_LJ2 AS P_FISCAL_LJ2 ON P_FISCAL_LJ2.NCM = NCM_LJ2.CONTA      ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.ALIQUOTA AS VAL_ICMS,   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.BASE_CALCULO AS VAL_REDUCAO_BASE_CALCULO,   ');
//     SQL.Add('           CAST(TAB_PROD_ICMS_LJ2.ORIGEM AS INT) + CAST(TAB_PROD_ICMS_LJ2.ICMS AS INT) AS COD_SIT_TRIBUTARIA,   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.NCM   ');
//     SQL.Add('               FROM   ');
//     SQL.Add('           SM_CD_EF_NCM_ICMS_LJ2 AS TAB_PROD_ICMS_LJ2   ');
//     SQL.Add('           WHERE TAB_PROD_ICMS_LJ2.DESTINO_UF = ''MT''   ');
//     SQL.Add('   ) AS TRIB_LJ2   ');
//     SQL.Add('   ON P_FISCAL_LJ2.NCM = TRIB_LJ2.NCM   ');
     SQL.Add('   WHERE P_FISCAL_LJ2.NCM NOT IN (SELECT P_FISCAL.NCM FROM SM_CD_ES_PRODUTO_FISCAL P_FISCAL)   ');






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

procedure TFrmSmSuperComprasGestor.GerarNFClientes;
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

procedure TFrmSmSuperComprasGestor.GerarNFFornec;
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
     SQL.Add('       C_CAPA.NOTA AS NUM_NF_FORN,   ');
     SQL.Add('       COALESCE(C_CAPA.SERIE, 1) AS NUM_SERIE_NF,   ');
     SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
     SQL.Add('       '''' AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
     SQL.Add('       CAPA.PD_TOTAL AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.PD_EMISSAO AS DTA_EMISSAO,   ');
     SQL.Add('       CAPA.PD_RECEPCAO AS DTA_ENTRADA,   ');
     SQL.Add('       COALESCE(CC_CAPA.IC_VLR_IPI_TOTAL, 0) AS VAL_TOTAL_IPI,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       COALESCE(CC_CAPA.IC_VLR_FRETE, 0) AS VAL_FRETE,   ');
     SQL.Add('       COALESCE(CC_CAPA.IC_VLR_ACRESCIMO, 0) AS VAL_ACRESCIMO,   ');
     SQL.Add('       COALESCE(CC_CAPA.IC_VLR_DESCONTO, 0) AS VAL_DESCONTO,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNEC.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       COALESCE(CC_CAPA.IC_BASE_ICMS, 0) AS VAL_TOTAL_BC,   ');
     SQL.Add('       COALESCE(CC_CAPA.IC_VLR_ICMS, 0) AS VAL_TOTAL_ICMS,   ');
     SQL.Add('       COALESCE(CC_CAPA.IC_BASE_SUBST, 0) AS VAL_BC_SUBST,   ');
     SQL.Add('       COALESCE(CC_CAPA.IC_VLR_SUBST, 0) AS VAL_ICMS_SUBST,   ');
     SQL.Add('       0 AS VAL_FUNRURAL,   ');
     SQL.Add('       1 AS COD_PERFIL,   ');
     SQL.Add('       0 AS VAL_DESP_ACESS,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       COALESCE(C_CAPA.CHAVE, '''') AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_MV_ES_CB_NR AS CAPA   ');
     SQL.Add('   LEFT JOIN SM_MV_ES_EF_NR AS C_CAPA ON C_CAPA.LANCTO = CAPA.LANCTO AND C_CAPA.EMPRESA = CAPA.EMPRESA   ');
     SQL.Add('   LEFT JOIN SM_MV_ES_CB_IC_NR AS CC_CAPA ON CC_CAPA.LANCTO = CAPA.LANCTO AND CC_CAPA.EMPRESA = CAPA.EMPRESA   ');
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

procedure TFrmSmSuperComprasGestor.GerarNFitensClientes;
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

procedure TFrmSmSuperComprasGestor.GerarNFitensFornec;
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
     SQL.Add('       C_CAPA.NOTA AS NUM_NF_FORN,   ');
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

procedure TFrmSmSuperComprasGestor.GerarProdForn;
var
   TotalCount, NEW_CODPROD : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO.COD AS COD_PRODUTO,   ');
     SQL.Add('       PROD_FORN.FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       COALESCE(PROD_FORN_REF.REF, '''') AS DES_REFERENCIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDOR.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('       COALESCE(PRODUTO.PD_UNIDADE_COMPRA, ''UN'') AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       COALESCE(PRODUTO.DA_UND_EMBALAGEM, 1) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       0 AS QTD_TROCA,   ');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FO AS PROD_FORN ON PROD_FORN.COD = PRODUTO.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_MO_MOVIMENTADOR AS FORNECEDOR ON FORNECEDOR.COD = PROD_FORN.FORNECEDOR   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_REF AS PROD_FORN_REF ON PROD_FORN_REF.COD = PRODUTO.COD AND PROD_FORN_REF.FORNECEDOR = PROD_FORN.FORNECEDOR   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PRODUTO.COD   ');
     SQL.Add('   WHERE FORNECEDOR.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS.BARRAS) < 14   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       PRODUTO_LJ2.COD + 2000000 AS COD_PRODUTO,   ');
     SQL.Add('       PROD_FORN_LJ2.FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       COALESCE(PROD_FORN_REF_LJ2.REF, '''') AS DES_REFERENCIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(FORNECEDOR_LJ2.PD_CNPJ_CPF, '','', ''''), ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('       COALESCE(PRODUTO_LJ2.PD_UNIDADE_COMPRA, ''UN'') AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       COALESCE(PRODUTO_LJ2.DA_UND_EMBALAGEM, 1) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       0 AS QTD_TROCA,   ');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FO_LJ2 AS PROD_FORN_LJ2 ON PROD_FORN_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   LEFT JOIN SM_CD_MO_MOVIMENTADOR_LJ2 AS FORNECEDOR_LJ2 ON FORNECEDOR_LJ2.COD = PROD_FORN_LJ2.FORNECEDOR   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_REF_LJ2 AS PROD_FORN_REF_LJ2 ON PROD_FORN_REF_LJ2.COD = PRODUTO_LJ2.COD AND PROD_FORN_REF_LJ2.FORNECEDOR = PROD_FORN_LJ2.FORNECEDOR   ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR_LJ2 AS COD_BARRAS_LJ2 ON COD_BARRAS_LJ2.COD = PRODUTO_LJ2.COD   ');
     SQL.Add('   WHERE FORNECEDOR_LJ2.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5'')   ');
     SQL.Add('   AND FORNECEDOR_LJ2.PD_CNPJ_CPF NOT IN (SELECT FORNECEDOR.PD_CNPJ_CPF FROM SM_CD_MO_MOVIMENTADOR FORNECEDOR WHERE FORNECEDOR.TIPO IN (''1'', ''0,1'', ''0,1,2,3'', ''0,1,2,3,4,5'', ''0,1,2,4,5'', ''0,3'', ''0,5''))   ');
     SQL.Add('   AND COD_BARRAS_LJ2.BARRAS NOT IN (SELECT COD_BARRAS.BARRAS FROM SM_CD_ES_PRODUTO_BAR COD_BARRAS)   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) >= 8');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) < 14   ');



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

procedure TFrmSmSuperComprasGestor.GerarProdLoja;
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

     SQL.Add('   SELECT DISTINCT      ');
     SQL.Add('       PRODUTO.COD AS COD_PRODUTO,      ');
     SQL.Add('       P_LOJA.CUSTO_REPOSICAO AS VAL_CUSTO_REP,      ');
     SQL.Add('       P_LOJA.PRECO_PDV AS VAL_VENDA,      ');
     SQL.Add('       0 AS VAL_OFERTA,      ');
     SQL.Add('       P_LOJA.ESTOQUE AS QTD_EST_VDA,      ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('      ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''41'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''90'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''4.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''67.0600'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''5'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''7'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''25.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''35.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       P_LOJA.MARGEM_ATUAL AS VAL_MARGEM,      ');
     SQL.Add('       1 AS QTD_ETIQUETA,      ');
     SQL.Add('      ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''40'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''41'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''0.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''90'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''4.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''12.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''67.0600'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''5'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''7'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''20'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''17.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''60'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''25.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           WHEN TRIB_LJ1.VAL_ICMS = ''35.0000'' AND TRIB_LJ1.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ1.COD_SIT_TRIBUTARIA = ''0'' THEN ''KK''   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE WHEN P_LOJA.INATIVO = 0 THEN ''N'' ELSE ''S'' END AS FLG_INATIVO,      ');
     SQL.Add('       PRODUTO.COD AS COD_PRODUTO_ANT,      ');
     SQL.Add('             ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN P_FISCAL.NCM = '''' THEN ''99999999''      ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''00000000'' THEN ''99999999''       ');
     SQL.Add('           WHEN P_FISCAL.NCM = ''0'' THEN ''99999999''       ');
     SQL.Add('           ELSE COALESCE(P_FISCAL.NCM, ''99999999'')        ');
     SQL.Add('       END AS NUM_NCM,         ');
     SQL.Add('         ');
     SQL.Add('       0 AS TIPO_NCM,      ');
     SQL.Add('       0 AS VAL_VENDA_2,      ');
     SQL.Add('       '''' AS DTA_VALIDA_OFERTA,      ');
     SQL.Add('       CASE WHEN P_LOJA.ESTOQUE_MINIMO = 0 THEN 1 ELSE COALESCE(P_LOJA.ESTOQUE_MINIMO, 1) END AS QTD_EST_MINIMO,      ');
     SQL.Add('       NULL AS COD_VASILHAME,      ');
     SQL.Add('       ''N'' AS FORA_LINHA,      ');
     SQL.Add('       0 AS QTD_PRECO_DIF,      ');
     SQL.Add('       0 AS VAL_FORCA_VDA,      ');
     SQL.Add('         ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN P_FISCAL.CEST = '''' THEN ''9999999''         ');
     SQL.Add('           WHEN P_FISCAL.CEST = ''0000000'' THEN ''9999999''         ');
     SQL.Add('           ELSE COALESCE(P_FISCAL.CEST, ''9999999'')          ');
     SQL.Add('       END AS NUM_CEST,      ');
     SQL.Add('         ');
     SQL.Add('       0 AS PER_IVA,      ');
     SQL.Add('       0 AS PER_FCP_ST,      ');
     SQL.Add('       COALESCE(P_LOJA.FIDELIDADE, 0) AS PER_FIDELIDADE,      ');
     SQL.Add('       0 AS COD_INFO_RECEITA      ');
     SQL.Add('   FROM      ');
     SQL.Add('       SM_CD_ES_PRODUTO AS PRODUTO      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM AS P_LOJA ON P_LOJA.COD = PRODUTO.COD      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FISCAL AS P_FISCAL ON P_FISCAL.COD = PRODUTO.COD      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR AS COD_BARRAS ON COD_BARRAS.COD = PRODUTO.COD      ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           TAB_PROD_ICMS.ALIQUOTA AS VAL_ICMS,   ');
//     SQL.Add('           TAB_PROD_ICMS.BASE_CALCULO AS VAL_REDUCAO_BASE_CALCULO,   ');
//     SQL.Add('           CAST(TAB_PROD_ICMS.ORIGEM AS INT) + CAST(TAB_PROD_ICMS.ICMS AS INT) AS COD_SIT_TRIBUTARIA,   ');
//     SQL.Add('           TAB_PROD_ICMS.NCM   ');
//     SQL.Add('               FROM   ');
//     SQL.Add('           SM_CD_EF_NCM_ICMS AS TAB_PROD_ICMS   ');
//     SQL.Add('           WHERE TAB_PROD_ICMS.DESTINO_UF = ''MT''   ');
//     SQL.Add('   ) AS TRIB_LJ1   ');
//     SQL.Add('   ON P_FISCAL.NCM = TRIB_LJ1.NCM   ');
     SQL.Add('   WHERE CHAR_LENGTH(COD_BARRAS.BARRAS) < 14      ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL      ');
     SQL.Add('         ');
     SQL.Add('   SELECT DISTINCT      ');
     SQL.Add('       PRODUTO_LJ2.COD + 2000000 AS COD_PRODUTO,      ');
     SQL.Add('       P_LOJA_LJ2.CUSTO_REPOSICAO AS VAL_CUSTO_REP,      ');
     SQL.Add('       P_LOJA_LJ2.PRECO_PDV AS VAL_VENDA,      ');
     SQL.Add('       0 AS VAL_OFERTA,      ');
     SQL.Add('       P_LOJA_LJ2.ESTOQUE AS QTD_EST_VDA,      ');
     SQL.Add('       '''' AS TECLA_BALANCA,      ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''40'' THEN 1   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''41'' THEN 23   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 22   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''4.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 27   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 6   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 3   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 39   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 40   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 41   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 42   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''25.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 5   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIBUTACAO,    ');
     SQL.Add('      ');
     SQL.Add('       P_LOJA_LJ2.MARGEM_ATUAL AS VAL_MARGEM,      ');
     SQL.Add('       1 AS QTD_ETIQUETA,      ');
     SQL.Add('          ');
//     SQL.Add('       CASE   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''0.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''40'' THEN 1   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''41'' THEN 23   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''60'' THEN 25   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''0.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 22   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''4.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 27   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''41.6700'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 6   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''12.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 3   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''58.8200'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 39   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 40   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''20'' THEN 41   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''17.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''90'' THEN 42   ');
//     SQL.Add('           WHEN TRIB_LJ2.VAL_ICMS = ''25.0000'' AND TRIB_LJ2.VAL_REDUCAO_BASE_CALCULO = ''100.0000'' AND TRIB_LJ2.COD_SIT_TRIBUTARIA = ''0'' THEN 5   ');
//     SQL.Add('           ELSE 1   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,      ');
     SQL.Add('          ');
     SQL.Add('       CASE WHEN P_LOJA_LJ2.INATIVO = 0 THEN ''N'' ELSE ''S'' END AS FLG_INATIVO,      ');
     SQL.Add('       PRODUTO_LJ2.COD AS COD_PRODUTO_ANT,      ');
     SQL.Add('             ');
     SQL.Add('       CASE       ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = '''' THEN ''99999999''      ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = ''00000000'' THEN ''99999999''       ');
     SQL.Add('           WHEN P_FISCAL_LJ2.NCM = ''0'' THEN ''99999999''       ');
     SQL.Add('           ELSE COALESCE(P_FISCAL_LJ2.NCM, ''99999999'')        ');
     SQL.Add('       END AS NUM_NCM,         ');
     SQL.Add('         ');
     SQL.Add('       0 AS TIPO_NCM,      ');
     SQL.Add('       0 AS VAL_VENDA_2,      ');
     SQL.Add('       '''' AS DTA_VALIDA_OFERTA,      ');
     SQL.Add('       CASE WHEN P_LOJA_LJ2.ESTOQUE_MINIMO = 0 THEN 1 ELSE COALESCE(P_LOJA_LJ2.ESTOQUE_MINIMO, 1) END AS QTD_EST_MINIMO,      ');
     SQL.Add('       NULL AS COD_VASILHAME,      ');
     SQL.Add('       ''N'' AS FORA_LINHA,      ');
     SQL.Add('       0 AS QTD_PRECO_DIF,      ');
     SQL.Add('       0 AS VAL_FORCA_VDA,      ');
     SQL.Add('         ');
     SQL.Add('       CASE         ');
     SQL.Add('           WHEN P_FISCAL_LJ2.CEST = '''' THEN ''9999999''         ');
     SQL.Add('           WHEN P_FISCAL_LJ2.CEST = ''0000000'' THEN ''9999999''         ');
     SQL.Add('           ELSE COALESCE(P_FISCAL_LJ2.CEST, ''9999999'')          ');
     SQL.Add('       END AS NUM_CEST,      ');
     SQL.Add('         ');
     SQL.Add('       0 AS PER_IVA,      ');
     SQL.Add('       0 AS PER_FCP_ST,      ');
     SQL.Add('       COALESCE(P_LOJA_LJ2.FIDELIDADE, 0) AS PER_FIDELIDADE,      ');
     SQL.Add('       0 AS COD_INFO_RECEITA      ');
     SQL.Add('   FROM      ');
     SQL.Add('       SM_CD_ES_PRODUTO_LJ2 AS PRODUTO_LJ2      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_DNM_LJ2 AS P_LOJA_LJ2 ON P_LOJA_LJ2.COD = PRODUTO_LJ2.COD      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_FISCAL_LJ2 AS P_FISCAL_LJ2 ON P_FISCAL_LJ2.COD = PRODUTO_LJ2.COD      ');
     SQL.Add('   LEFT JOIN SM_CD_ES_PRODUTO_BAR_LJ2 AS COD_BARRAS_LJ2 ON COD_BARRAS_LJ2.COD = PRODUTO_LJ2.COD      ');
//     SQL.Add('   LEFT JOIN(   ');
//     SQL.Add('       SELECT DISTINCT   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.ALIQUOTA AS VAL_ICMS,   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.BASE_CALCULO AS VAL_REDUCAO_BASE_CALCULO,   ');
//     SQL.Add('           CAST(TAB_PROD_ICMS_LJ2.ORIGEM AS INT) + CAST(TAB_PROD_ICMS_LJ2.ICMS AS INT) AS COD_SIT_TRIBUTARIA,   ');
//     SQL.Add('           TAB_PROD_ICMS_LJ2.NCM   ');
//     SQL.Add('               FROM   ');
//     SQL.Add('           SM_CD_EF_NCM_ICMS_LJ2 AS TAB_PROD_ICMS_LJ2   ');
//     SQL.Add('           WHERE TAB_PROD_ICMS_LJ2.DESTINO_UF = ''MT''   ');
//     SQL.Add('   ) AS TRIB_LJ2   ');
//     SQL.Add('   ON P_FISCAL_LJ2.NCM = TRIB_LJ2.NCM   ');
     SQL.Add('   WHERE COD_BARRAS_LJ2.BARRAS NOT IN (SELECT COD_BARRAS.BARRAS FROM SM_CD_ES_PRODUTO_BAR COD_BARRAS)      ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) >= 8   ');
     SQL.Add('   AND CHAR_LENGTH(COD_BARRAS_LJ2.BARRAS) < 14   ');








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

procedure TFrmSmSuperComprasGestor.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       P_SIMILAR.CHV AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('       P_SIMILAR.CHV AS DES_PRODUTO_SIMILAR,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_SIM AS P_SIMILAR   ');
     SQL.Add('      ');
     SQL.Add('   UNION ALL   ');
     SQL.Add('      ');
     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       999||P_SIMILAR_LJ2.CHV AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('       P_SIMILAR_LJ2.CHV AS DES_PRODUTO_SIMILAR,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       SM_CD_ES_PRODUTO_SIM_LJ2 AS P_SIMILAR_LJ2   ');




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
