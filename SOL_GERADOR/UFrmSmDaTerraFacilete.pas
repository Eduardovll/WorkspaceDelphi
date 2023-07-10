unit UFrmSmDaTerraFacilete;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrmModelo, Data.DBXOracle, Data.DB,
  Data.SqlExpr, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DBXFirebird, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.Provider, Datasnap.DBClient, //dxGDIPlusClasses,
  Math;

type
  TFrmSmDaTerraFacilete = class(TFrmModeloSis)
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
  FrmSmDaTerraFacilete: TFrmSmDaTerraFacilete;
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


procedure TFrmSmDaTerraFacilete.GerarProducao;
begin
  inherited;
(*  with QryPrincipal do
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
  end;*)
end;

procedure TFrmSmDaTerraFacilete.GerarProduto;
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
     SQL.Add('       CAST(CAST(P.PRO_CODIGO AS INTEGER) AS VARCHAR(10)) AS COD_PRODUTO,   ');
     SQL.Add('       P.PRO_CODIGOBARRA AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       P.PRO_NOMEREDUZIDO AS DES_REDUZIDA,   ');
     SQL.Add('       P.PRO_DESCRICAO AS DES_PRODUTO,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_UNIDADE = '''') OR (P.PRO_UNIDADE IS NULL)) THEN ''UN''   ');
     SQL.Add('           ELSE P.PRO_UNIDADE   ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_UNIDADE = '''') OR (P.PRO_UNIDADE IS NULL)) THEN ''UN''   ');
     SQL.Add('           ELSE P.PRO_UNIDADE   ');
     SQL.Add('       END AS DES_UNIDADE_VENDA,   ');
     SQL.Add('       0 AS TIPO_IPI ,   ');
     SQL.Add('       0 AS VAL_IPI,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_GRUPO = '''') OR (P.PRO_GRUPO IS NULL) OR (P.PRO_GRUPO = ''.+'') ) THEN ''999''   ');
     SQL.Add('           ELSE P.PRO_GRUPO   ');
     SQL.Add('       END AS COD_SECAO,   ');
     SQL.Add('       999 AS COD_GRUPO,   ');
     SQL.Add('       999 AS COD_SUB_GRUPO,   ');
     SQL.Add('       0 AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_PESAVEL = ''True'') AND (P.PRO_UNIDADE = ''KG'')) THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS IPV,   ');
     SQL.Add('       0 AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('       ''S'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_PESAVEL = ''True'') AND (P.PRO_UNIDADE = ''KG'')) THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       0 AS TIPO_EVENTO,               ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       '''' AS COD_TAB_SPED,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO,   ');
     SQL.Add('       0 AS TIPO_ESPECIE,   ');
     SQL.Add('       0 AS  COD_CLASSIF,   ');
     SQL.Add('       1 AS VAL_VDA_PESO_BRUTO,   ');
     SQL.Add('       1 AS VAL_PESO_EMB,   ');
     SQL.Add('       0 AS TIPO_EXPLOSAO_COMPRA,   ');
     SQL.Add('       '''' AS DTA_INI_OPER,   ');
     SQL.Add('       '''' AS DES_PLAQUETA,   ');
     SQL.Add('       '''' AS MES_ANO_INI_DEPREC,   ');
     SQL.Add('       0 AS TIPO_BEM,   ');
     SQL.Add('       0 AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       CAST(COALESCE(P.PRO_DATACADASTRO, ''01.11.2022'') AS DATE) AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       P.PRO_CODIGO AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM PRODUTO P   ');
     SQL.Add('   WHERE P.PRO_DESCRICAO <> ''''   ');
     SQL.Add('   AND P.PRO_CODIGOBARRA <> ''''   ');
     SQL.Add('   ORDER BY   ');
     SQL.Add('       P.PRO_CODIGO ASC   ');




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

procedure TFrmSmDaTerraFacilete.GerarReceitas;
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

procedure TFrmSmDaTerraFacilete.GerarScriptAmarrarCEST;
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

procedure TFrmSmDaTerraFacilete.GerarScriptCEST;
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

procedure TFrmSmDaTerraFacilete.GerarSecao;
var
   TotalCount : integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT     ');
     SQL.Add('       G.GRU_CODIGO AS COD_SECAO,   ');
     SQL.Add('       G.GRU_DESCRICAO AS DES_SECAO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('      ');
     SQL.Add('   FROM GRUPO G   ');


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

procedure TFrmSmDaTerraFacilete.GerarSubGrupo;
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
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_GRUPO = '''') OR (P.PRO_GRUPO IS NULL) OR (P.PRO_GRUPO = ''.+'') ) THEN ''999''   ');
     SQL.Add('           ELSE P.PRO_GRUPO   ');
     SQL.Add('       END AS COD_SECAO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_GRUPO = '''') OR (P.PRO_GRUPO IS NULL) OR (P.PRO_GRUPO = ''.+'') ) THEN ''999''   ');
     SQL.Add('           ELSE ''999''   ');
     SQL.Add('       END AS COD_GRUPO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_SUBGRUPO = '''') OR (P.PRO_SUBGRUPO IS NULL)) THEN ''999''   ');
     SQL.Add('           ELSE ''999''   ');
     SQL.Add('       END AS COD_SUB_GRUPO,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 AS VAL_META,   ');
     SQL.Add('       0 AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('      ');
     SQL.Add('   FROM PRODUTO P   ');
     SQL.Add('   LEFT JOIN SGRUPO SG ON   ');
     SQL.Add('        (   ');
     SQL.Add('           P.PRO_SUBGRUPO = SG.SGRU_CODIGO   ');
     SQL.Add('        AND   ');
     SQL.Add('           P.PRO_GRUPO = SG.SGRU_GRUPO   ');
     SQL.Add('        )   ');



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

procedure TFrmSmDaTerraFacilete.GerarTransportadora;
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

procedure TFrmSmDaTerraFacilete.GerarValorVenda;
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

procedure TFrmSmDaTerraFacilete.GerarVenda;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CUPOMITENS.pedvi_produto AS COD_PRODUTO,   ');
     SQL.Add('       1 AS COD_LOJA,   ');
     SQL.Add('       0 AS IND_TIPO,   ');
     SQL.Add('       1 AS NUM_PDV,   ');
     SQL.Add('       CUPOMITENS.pedvi_qtde AS QTD_TOTAL_PRODUTO,   ');
     SQL.Add('       CUPOMITENS.pedvi_valortotal AS VAL_TOTAL_PRODUTO,   ');
     SQL.Add('       CUPOMITENS.pedvi_valorunit AS VAL_PRECO_VENDA,   ');
     SQL.Add('       P.pro_valorvista AS VAL_CUSTO_REP,   ');
     SQL.Add('       CUPOMCAPA.pedv_dataemissao AS DTA_SAIDA,   ');
     SQL.Add('       LPAD(EXTRACT(MONTH FROM CUPOMCAPA.pedv_dataemissao), 2, ''0'') || EXTRACT(YEAR FROM CUPOMCAPA.pedv_dataemissao) as DTA_MENSAL,   ');
     SQL.Add('       999 AS NUM_IDENT,   ');
     SQL.Add('       '''' AS COD_EAN,   ');
     SQL.Add('       '''' AS DES_HORA,   ');
     SQL.Add('       CUPOMCAPA.pedv_cliente AS COD_CLIENTE,   ');
     SQL.Add('       1 AS COD_ENTIDADE,   ');
     SQL.Add('       0 AS VAL_BASE_ICMS,   ');
     SQL.Add('       CUPOMITENS.pedvi_sittrib AS DES_SITUACAO_TRIB,   ');
     SQL.Add('       0 AS VAL_ICMS,   ');
     SQL.Add('       CUPOMITENS.pedvi_numeroped AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       CUPOMITENS.pedvi_valortotal AS VAL_VENDA_PDV,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''01'' THEN 2   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''02'' THEN 3   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''03'' THEN 4   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''04'' THEN 5   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''FF'' THEN 25   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''II'' THEN 1   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''NN'' THEN 22   ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('             WHEN ((CUPOMCAPA.pedv_status = ''C'') OR (CUPOMCAPA.pedv_status IS NULL))   THEN ''S''   ');
     SQL.Add('             ELSE ''N''    ');
     SQL.Add('       END AS FLG_CUPOM_CANCELADO,   ');
     SQL.Add('       CF.cfis_numero AS NUM_NCM,   ');
     SQL.Add('       '''' AS COD_TAB_SPED,   ');
     SQL.Add('       ''S'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_PESAVEL = ''True'') AND (P.PRO_UNIDADE = ''KG'')) THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       ''S'' AS FLG_ONLINE,   ');
     SQL.Add('       ''N'' AS FLG_OFERTA,   ');
     SQL.Add('       0 AS COD_ASSOCIADO   ');
     SQL.Add('      ');
     SQL.Add('   FROM PEDIVEI CUPOMITENS   ');
     SQL.Add('   INNER JOIN PEDIVE CUPOMCAPA ON   ');
     SQL.Add('       (CUPOMITENS.pedvi_numeroped = CUPOMCAPA.pedv_numero)   ');
     SQL.Add('      ');
     SQL.Add('   INNER JOIN PEDIVEV CUPOMFINANCEIRO ON   ');
     SQL.Add('       (CUPOMITENS.pedvi_numeroped = CUPOMFINANCEIRO.pedvv_numeroped)   ');
     SQL.Add('      ');
     SQL.Add('   INNER JOIN PRODUTO P ON   ');
     SQL.Add('       (CUPOMITENS.pedvi_produto = P.pro_codigo)   ');
     SQL.Add('   INNER JOIN CLASFIS CF ON   ');
     SQL.Add('       (P.PRO_CLASFISCAL = CF.CFIS_CODIGO)    ');
     SQL.Add('      ');
     SQL.Add('   WHERE   ');
     SQL.Add('    CUPOMCAPA.pedv_dataemissao >= :INI   ');
     SQL.Add('   AND CUPOMCAPA.pedv_dataemissao <= :FIM   ');



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


procedure TFrmSmDaTerraFacilete.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmDaTerraFacilete.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmDaTerraFacilete.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmDaTerraFacilete.BtnGerarClick(Sender: TObject);
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

procedure TFrmSmDaTerraFacilete.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmDaTerraFacilete.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmDaTerraFacilete.CkbProdLojaClick(Sender: TObject);
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

procedure TFrmSmDaTerraFacilete.EdtCamBancoExit(Sender: TObject);
begin
  inherited;
  CriarFB(EdtCamBanco);
end;


procedure TFrmSmDaTerraFacilete.GeraCustoRep;
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

procedure TFrmSmDaTerraFacilete.GeraEstoqueVenda;
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

procedure TFrmSmDaTerraFacilete.GerarCest;
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

procedure TFrmSmDaTerraFacilete.GerarCliente;
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

     SQL.Add('   SELECT      ');
     SQL.Add('       C.CLI_CODIGO AS COD_CLIENTE,      ');
     SQL.Add('       C.CLI_RAZAO AS DES_CLIENTE,      ');
     SQL.Add('       C.CLI_CGCCPF AS NUM_CGC,      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN C.CLI_TIPOCGCCPF = ''J'' THEN   ');
     SQL.Add('               CASE   ');
     SQL.Add('                   WHEN ( C.CLI_IE = '''') THEN ''ISENTO''   ');
     SQL.Add('                   ELSE C.CLI_IE   ');
     SQL.Add('               END   ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS NUM_INSC_EST,   ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN ((C.CLI_ENDERECO = '''') OR (C.CLI_ENDERECO IS NULL)) THEN ''� DEFINIR''      ');
     SQL.Add('           ELSE C.CLI_ENDERECO      ');
     SQL.Add('       END AS DES_ENDERECO,      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN ((C.CLI_BAIRRO = '''') OR (C.CLI_BAIRRO IS NULL)) THEN ''� DEFINIR''      ');
     SQL.Add('           ELSE C.CLI_BAIRRO      ');
     SQL.Add('       END AS DES_BAIRRO,      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN ((C.CLI_CIDADE = '''') OR (C.CLI_CIDADE IS NULL)) THEN ''SAO PEDRO''      ');
     SQL.Add('           ELSE REPLACE (C.CLI_CIDADE, ''�'', ''A'')      ');
     SQL.Add('       END AS DES_CIDADE,      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN ((C.CLI_ESTADO = '''') OR (C.CLI_ESTADO IS NULL)) THEN ''SP''      ');
     SQL.Add('           ELSE C.CLI_ESTADO      ');
     SQL.Add('       END AS DES_SIGLA,      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN ((C.CLI_CEP = '''') OR (C.CLI_CEP IS NULL) OR (C.CLI_CEP = ''13520'') ) THEN ''13520000''      ');
     SQL.Add('           ELSE C.CLI_CEP      ');
     SQL.Add('       END AS NUM_CEP,      ');
     SQL.Add('       C.CLI_TELEFONE AS NUM_FONE,      ');
     SQL.Add('       C.CLI_FAX AS NUM_FAX,      ');
     SQL.Add('       C.CLI_CONTATO AS DES_CONTATO,      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN ((C.CLI_SEXO = '''') OR (C.CLI_SEXO IS NULL) OR (C.CLI_SEXO = ''Feminino'')) THEN 1      ');
     SQL.Add('       END AS FLG_SEXO,      ');
     SQL.Add('       0 AS VAL_LIMITE_CRETID,      ');
     SQL.Add('       C.CLI_VALORLIMITE AS VAL_LIMITE_CONV,      ');
     SQL.Add('       0 AS VAL_DEBITO,      ');
     SQL.Add('       0 AS VAL_RENDA,      ');
     SQL.Add('       0 AS COD_CONVENIO,      ');
     SQL.Add('       0 AS COD_STATUS_PDV,      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN C.CLI_TIPOCGCCPF = ''J'' THEN ''S''      ');
     SQL.Add('           ELSE ''N''      ');
     SQL.Add('       END AS FLG_EMPRESA,      ');
     SQL.Add('       ''N'' AS FLG_CONVENIO,      ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,      ');
     SQL.Add('       CAST(COALESCE(C.CLI_DATACADASTRO, ''01.01.1899'') AS DATE) AS DTA_CADASTRO,      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN ((C.CLI_NUMERO = '''') OR (C.CLI_NUMERO IS NULL)) THEN ''S/N''      ');
     SQL.Add('           ELSE C.CLI_NUMERO      ');
     SQL.Add('       END AS NUM_ENDERECO,      ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN C.CLI_TIPOCGCCPF = ''F'' THEN C.CLI_IE   ');
     SQL.Add('           ELSE ''''   ');
     SQL.Add('       END AS NUM_RG,   ');
     SQL.Add('       '''' AS FLG_EST_CIVIL,      ');
     SQL.Add('       C.CLI_CELULAR AS NUM_CELULAR,      ');
     SQL.Add('       ''01/11/2022'' AS DTA_ALTERACAO,      ');
     SQL.Add('       C.CLI_OBSERVACAO AS DES_OBSERVACAO,      ');
     SQL.Add('       '''' AS DES_COMPLEMENTO,      ');
     SQL.Add('       C.CLI_EMAIL AS DES_EMAIL,      ');
     SQL.Add('       CASE      ');
     SQL.Add('            WHEN ((C.CLI_FANTASIA = '''') OR (C.CLI_FANTASIA IS NULL)) THEN C.CLI_RAZAO      ');
     SQL.Add('            ELSE C.CLI_FANTASIA      ');
     SQL.Add('       END AS DES_FANTASIA,      ');
     SQL.Add('       ''01/01/1899'' AS DTA_NASCIMENTO,      ');
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
     SQL.Add('       '''' AS FLG_ENVIA_CODIGO,      ');
     SQL.Add('       '''' AS DTA_NASC_CONJUGE,      ');
     SQL.Add('       0 AS COD_CLASSIF      ');
     SQL.Add('         ');
     SQL.Add('   FROM CLIENTE C      ');
     SQL.Add('   WHERE C.CLI_RAZAO <> ''''      ');
     SQL.Add('   ORDER BY      ');
     SQL.Add('        C.CLI_CODIGO ASC   ');


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

procedure TFrmSmDaTerraFacilete.GerarCodigoBarras;
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

       SQL.Add('   SELECT   ');
       SQL.Add('       P.PRO_CODIGO AS COD_PRODUTO,   ');
       SQL.Add('       P.PRO_CODIGOBARRA AS COD_EAN   ');
       SQL.Add('   FROM PRODUTO P   ');
       SQL.Add('   ORDER BY   ');
       SQL.Add('       P.PRO_CODIGO ASC   ');


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

procedure TFrmSmDaTerraFacilete.GerarComposicao;
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

procedure TFrmSmDaTerraFacilete.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT    ');
     SQL.Add('       C.CLI_CODIGO AS COD_CLIENTE,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM CLIENTE C   ');
     SQL.Add('   WHERE C.CLI_RAZAO <> ''''   ');
     SQL.Add('   ORDER BY C.CLI_CODIGO ASC   ');




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

procedure TFrmSmDaTerraFacilete.GerarCondPagForn;
//var
//  COD_FORNECEDOR : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT    ');
     SQL.Add('       F.FOR_CODIGO AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       F.FOR_CGC AS NUM_CGC   ');
     SQL.Add('      ');
     SQL.Add('   FROM FORNECE F   ');
     SQL.Add('   WHERE F.FOR_RAZAO <> ''''      ');
     SQL.Add('   AND F.FOR_CGC IS NOT NULL    ');
     SQL.Add('   ORDER BY FOR_CODIGO ASC   ');


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

procedure TFrmSmDaTerraFacilete.GerarDecomposicao;
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

procedure TFrmSmDaTerraFacilete.GerarDivisaoForn;
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

procedure TFrmSmDaTerraFacilete.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmDaTerraFacilete.GerarFinanceiroPagar(Aberto: String);
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

procedure TFrmSmDaTerraFacilete.GerarFinanceiroReceber(Aberto: String);
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
           SQL.Add('   SELECT   ');
           SQL.Add('       0 AS TIPO_PARCEIRO,   ');
           SQL.Add('       PDV.PEDVV_CLIENTE AS COD_PARCEIRO,   ');
           SQL.Add('       1 AS TIPO_CONTA,   ');
           SQL.Add('       4 AS COD_ENTIDADE,   ');
           SQL.Add('       REPLACE (PDV.PEDVV_DOCTO, ''/1'', '''') AS NUM_DOCTO,   ');
           SQL.Add('       0 AS COD_BANCO,   ');
           SQL.Add('       '''' AS DES_BANCO,   ');
           SQL.Add('       PDV.PEDVV_DATALANCTO AS DTA_EMISSAO,   ');
           SQL.Add('       PDV.PEDVV_VENCDATA AS DTA_VENCIMENTO,   ');
           SQL.Add('       PDV.PEDVV_VALOR AS VAL_PARCELA,   ');
           SQL.Add('       0 AS VAL_JUROS,   ');
           SQL.Add('       0 AS VAL_DESCONTO,   ');
           SQL.Add('       ''N'' FLG_QUITADO,   ');
           SQL.Add('       '''' AS DTA_QUITADA,   ');
           SQL.Add('       997 AS COD_CATEGORIA,   ');
           SQL.Add('       997 AS COD_SUBCATEGORIA,   ');
           SQL.Add('       1 AS NUM_PARCELA,   ');
           SQL.Add('       1 AS QTD_PARCELA,   ');
           SQL.Add('       1 AS COD_LOJA,   ');
           SQL.Add('       C.CLI_CGCCPF AS NUM_CGC,   ');
           SQL.Add('       0 AS NUM_BORDERO,   ');
           SQL.Add('       '''' AS NUM_NF,   ');
           SQL.Add('       0 AS NUM_SERIE_NF,   ');
           SQL.Add('       PDV.PEDVV_VALOR AS VAL_TOTAL_NF,   ');
           SQL.Add('       '''' AS DES_OBSERVACAO,   ');
           SQL.Add('       ''1'' AS NUM_PDV,   ');
           SQL.Add('   REPLACE (REPLACE (REPLACE (REPLACE (PDV.PEDVV_DOCTO, ''/1'', ''''), ''/2'', ''''), ''/3'', ''''), ''/4'', '''') AS NUM_CUPOM_FISCAL,   ');
           SQL.Add('       0 AS COD_MOTIVO,   ');
           SQL.Add('       0 AS COD_CONVENIO,   ');
           SQL.Add('       0 AS COD_BIN,   ');
           SQL.Add('       '''' AS DES_BANDEIRA,   ');
           SQL.Add('       '''' AS DES_REDE_TEF,   ');
           SQL.Add('       0 AS VAL_RETENCAO,   ');
           SQL.Add('       0 AS COD_CONDICAO,   ');
           SQL.Add('       '''' AS DTA_PAGTO,   ');
           SQL.Add('       PDV.PEDVV_DATALANCTO AS DTA_ENTRADA,   ');
           SQL.Add('       0 AS NUM_NOSSO_NUMERO,   ');
           SQL.Add('       '''' AS COD_BARRA,   ');
           SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
           SQL.Add('       C.CLI_CGCCPF AS NUM_CGC_CPF_TITULAR,   ');
           SQL.Add('       C.CLI_RAZAO AS DES_TITULAR,   ');
           SQL.Add('       0 AS NUM_CONDICAO,   ');
           SQL.Add('       1 AS NUM_SEQ_FIN   ');
           SQL.Add('      ');
           SQL.Add('   FROM PEDIVEV PDV   ');
           SQL.Add('   INNER JOIN CLIENTE C ON   ');
           SQL.Add('       (PDV.PEDVV_CLIENTE = C.CLI_CODIGO)   ');
           SQL.Add('   WHERE    ');
           SQL.Add('      PDV.pedvv_baixadosn = ''N''   ');

      end
      else
      begin
       //QUITADO
           SQL.Add('   SELECT   ');
           SQL.Add('       0 AS TIPO_PARCEIRO,   ');
           SQL.Add('       PDV.PEDVV_CLIENTE AS COD_PARCEIRO,   ');
           SQL.Add('       1 AS TIPO_CONTA,   ');
           SQL.Add('       4 AS COD_ENTIDADE,   ');
           SQL.Add('       REPLACE (PDV.PEDVV_DOCTO, ''/1'', '''') AS NUM_DOCTO,   ');
           SQL.Add('       0 AS COD_BANCO,   ');
           SQL.Add('       '''' AS DES_BANCO,   ');
           SQL.Add('       PDV.PEDVV_DATALANCTO AS DTA_EMISSAO,   ');
           SQL.Add('       PDV.PEDVV_VENCDATA AS DTA_VENCIMENTO,   ');
           SQL.Add('       PDV.PEDVV_VALOR AS VAL_PARCELA,   ');
           SQL.Add('       0 AS VAL_JUROS,   ');
           SQL.Add('       0 AS VAL_DESCONTO,   ');
           SQL.Add('       ''S'' FLG_QUITADO,   ');
           SQL.Add('       CASE   ');
           SQL.Add('           WHEN PDV.PEDVV_DATABAIXA = ''01/01/1900'' THEN PDV.pedvv_vencdata   ');
           SQL.Add('           ELSE PDV.PEDVV_DATABAIXA   ');
           SQL.Add('       END AS DTA_QUITADA,   ');
           SQL.Add('       997 AS COD_CATEGORIA,   ');
           SQL.Add('       997 AS COD_SUBCATEGORIA,   ');
           SQL.Add('       1 AS NUM_PARCELA,   ');
           SQL.Add('       1 AS QTD_PARCELA,   ');
           SQL.Add('       1 AS COD_LOJA,   ');
           SQL.Add('       C.CLI_CGCCPF AS NUM_CGC,   ');
           SQL.Add('       0 AS NUM_BORDERO,   ');
           SQL.Add('       '''' AS NUM_NF,   ');
           SQL.Add('       0 AS NUM_SERIE_NF,   ');
           SQL.Add('       PDV.PEDVV_VALOR AS VAL_TOTAL_NF,   ');
           SQL.Add('       '''' AS DES_OBSERVACAO,   ');
           SQL.Add('       ''1'' AS NUM_PDV,   ');
           SQL.Add('       REPLACE (REPLACE (PDV.PEDVV_DOCTO, ''/1'', ''''), ''/2'', '''') AS NUM_CUPOM_FISCAL,   ');
           SQL.Add('       0 AS COD_MOTIVO,   ');
           SQL.Add('       0 AS COD_CONVENIO,   ');
           SQL.Add('       0 AS COD_BIN,   ');
           SQL.Add('       '''' AS DES_BANDEIRA,   ');
           SQL.Add('       '''' AS DES_REDE_TEF,   ');
           SQL.Add('       0 AS VAL_RETENCAO,   ');
           SQL.Add('       0 AS COD_CONDICAO,   ');
           SQL.Add('       CASE   ');
           SQL.Add('           WHEN PDV.PEDVV_DATABAIXA = ''01/01/1900'' THEN PDV.pedvv_vencdata   ');
           SQL.Add('           ELSE PDV.PEDVV_DATABAIXA   ');
           SQL.Add('       END AS DTA_PAGTO,   ');
           SQL.Add('       PDV.PEDVV_DATALANCTO AS DTA_ENTRADA,   ');
           SQL.Add('       0 AS NUM_NOSSO_NUMERO,   ');
           SQL.Add('       '''' AS COD_BARRA,   ');
           SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,   ');
           SQL.Add('       C.CLI_CGCCPF AS NUM_CGC_CPF_TITULAR,   ');
           SQL.Add('       C.CLI_RAZAO AS DES_TITULAR,   ');
           SQL.Add('       0 AS NUM_CONDICAO,   ');
           SQL.Add('       1 AS NUM_SEQ_FIN   ');
           SQL.Add('      ');
           SQL.Add('   FROM PEDIVEV PDV   ');
           SQL.Add('   INNER JOIN CLIENTE C ON   ');
           SQL.Add('       (PDV.PEDVV_CLIENTE = C.CLI_CODIGO)   ');
           SQL.Add('   WHERE    ');
           SQL.Add('      PDV.pedvv_baixadosn = ''S''   ');
           SQL.Add('AND PDV.PEDVV_DATALANCTO >= :INI ');
           SQL.Add('AND PDV.PEDVV_DATALANCTO <= :FIM ');

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

procedure TFrmSmDaTerraFacilete.GerarFinanceiroReceberCartao;
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

procedure TFrmSmDaTerraFacilete.GerarFornecedor;
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

       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('         F.FOR_CODIGO AS COD_FORNECEDOR,   ');
       SQL.Add('         F.FOR_RAZAO AS DES_FORNECEDOR,   ');
       SQL.Add('         CASE   ');
       SQL.Add('           WHEN ((F.FOR_FANTASIA = '''') OR (F.FOR_FANTASIA IS NULL)) THEN F.FOR_RAZAO   ');
       SQL.Add('           ELSE F.FOR_FANTASIA   ');
       SQL.Add('         END AS DES_FANTASIA,   ');
       SQL.Add('         F.FOR_CGC AS NUM_CGC,   ');
       SQL.Add('         CASE   ');
       SQL.Add('           WHEN ((F.FOR_IE = '''') OR (F.FOR_IE IS NULL)) THEN ''0''   ');
       SQL.Add('           ELSE F.FOR_IE   ');
       SQL.Add('         END AS NUM_INSC_EST,   ');
       SQL.Add('         CASE   ');
       SQL.Add('           WHEN ((F.FOR_ENDERECO = '''') OR (F.FOR_ENDERECO IS NULL)) THEN ''� DEFINIR''   ');
       SQL.Add('           ELSE F.FOR_ENDERECO   ');
       SQL.Add('         END AS DES_ENDERECO,   ');
       SQL.Add('         CASE   ');
       SQL.Add('           WHEN ((F.FOR_BAIRRO = '''') OR (F.FOR_BAIRRO IS NULL)) THEN ''� DEFINIR''   ');
       SQL.Add('           ELSE F.FOR_BAIRRO   ');
       SQL.Add('         END AS DES_BAIRRO,   ');
       SQL.Add('         CASE   ');
       SQL.Add('           WHEN ((F.FOR_CIDADE = '''') OR (F.FOR_CIDADE IS NULL)) THEN ''SAO PEDRO''   ');
       SQL.Add('           ELSE F.FOR_CIDADE   ');
       SQL.Add('         END AS DES_CIDADE,   ');
       SQL.Add('         CASE   ');
       SQL.Add('           WHEN (F.FOR_ESTADO = '''') THEN ''SP''   ');
       SQL.Add('           ELSE F.FOR_ESTADO   ');
       SQL.Add('         END AS DES_SIGLA,   ');
       SQL.Add('         CASE   ');
       SQL.Add('           WHEN ((F.FOR_CEP = '''') OR (F.FOR_CEP IS NULL)) THEN ''13520000''   ');
       SQL.Add('           ELSE F.FOR_CEP   ');
       SQL.Add('         END AS NUM_CEP,   ');
       SQL.Add('         COALESCE (F.FOR_TELEFONE, '''') AS NUM_FONE,   ');
       SQL.Add('         COALESCE (F.FOR_FAX, '''') AS NUM_FAX,   ');
       SQL.Add('         COALESCE (F.FOR_CONTATO, '''') AS DES_CONTATO,   ');
       SQL.Add('         0 AS QTD_DIA_CARENCIA,   ');
       SQL.Add('         0 AS NUM_FREQ_VISITA,   ');
       SQL.Add('         0 AS VAL_DESCONTO,   ');
       SQL.Add('         0 AS NUM_PRAZO,   ');
       SQL.Add('         ''N'' AS ACEITA_DEVOL_MER,   ');
       SQL.Add('         ''N'' AS CAL_IPI_VAL_BRUTO,   ');
       SQL.Add('         ''N'' AS CAL_ICMS_ENC_FIN,   ');
       SQL.Add('         ''N'' AS CAL_ICMS_VAL_IPI,   ');
       SQL.Add('         ''N'' AS MICRO_EMPRESA,   ');
       SQL.Add('         F.FOR_CODIGO AS COD_FORNECEDOR_ANT,   ');
       SQL.Add('         CASE   ');
       SQL.Add('           WHEN ((F.FOR_NUMERO = '''') OR (F.FOR_NUMERO IS NULL)) THEN ''S/N''   ');
       SQL.Add('           ELSE F.FOR_NUMERO   ');
       SQL.Add('         END AS NUM_ENDERECO,   ');
       SQL.Add('         '''' AS DES_OBSERVACAO,   ');
       SQL.Add('         COALESCE (F.FOR_EMAIL, '''') AS DES_EMAIL,   ');
       SQL.Add('         COALESCE (F.FOR_HOMEPAGE, '''') AS DES_WEB_SITE,   ');
       SQL.Add('         ''N'' AS FABRICANTE,   ');
       SQL.Add('         ''N'' AS FLG_PRODUTOR_RURAL,   ');
       SQL.Add('         0 AS TIPO_FRETE,   ');
       SQL.Add('         ''N'' AS FLG_SIMPLES,   ');
       SQL.Add('         ''N'' AS FLG_SUBSTITUTO_TRIB,   ');
       SQL.Add('         0 AS COD_CONTACCFORN,   ');
       SQL.Add('         ''N'' AS INATIVO,   ');
       SQL.Add('         21 AS COD_CLASSIF,   ');
       SQL.Add('         0 AS VAL_CREDITO,         ');
       SQL.Add('         0 AS VAL_DEBITO,   ');
       SQL.Add('         1 AS PED_MIN_VAL,   ');
       SQL.Add('         '''' AS DES_EMAIL_VEND,   ');
       SQL.Add('         '''' AS SENHA_COTACAO,   ');
       SQL.Add('         0 AS TIPO_PRODUTOR,   ');
       SQL.Add('         COALESCE (F.FOR_TELEFONE2, '''') AS NUM_CELULAR   ');
       SQL.Add('      ');
       SQL.Add('   FROM FORNECE F   ');
       SQL.Add('   WHERE F.FOR_RAZAO <> ''''   ');
       SQL.Add('   AND F.FOR_CGC IS NOT NULL   ');
       SQL.Add('   ORDER BY   ');
       SQL.Add('       F.FOR_CODIGO ASC   ');




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

procedure TFrmSmDaTerraFacilete.GerarGrupo;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT     ');
     SQL.Add('       G.GRU_CODIGO AS COD_SECAO,   ');
     SQL.Add('       ''999'' AS COD_GRUPO,   ');
     SQL.Add('       ''� DEFINIR'' AS DES_GRUPO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('      ');
     SQL.Add('   FROM GRUPO G   ');


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

procedure TFrmSmDaTerraFacilete.GerarInfoNutricionais;
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

procedure TFrmSmDaTerraFacilete.GerarNCM;
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
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((CF.CFIS_DESCRICAO = '''') OR (CF.CFIS_DESCRICAO IS NULL)) THEN ''� DEFINIR''   ');
     SQL.Add('           ELSE CF.CFIS_DESCRICAO   ');
     SQL.Add('       END AS DES_NCM,   ');
     SQL.Add('       CF.cfis_numero AS NUM_NCM,   ');
     SQL.Add('       ''S'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       '''' AS COD_TAB_SPED,   ');
     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
     SQL.Add('       ''SP'' AS DES_SIGLA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''01'' THEN 2   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''02'' THEN 3   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''03'' THEN 4   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''04'' THEN 5   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''FF'' THEN 25   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''II'' THEN 1   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''NN'' THEN 22   ');
     SQL.Add('      END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      CASE   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''01'' THEN 2   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''02'' THEN 3   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''03'' THEN 4   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''04'' THEN 5   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''FF'' THEN 25   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''II'' THEN 1   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''NN'' THEN 22   ');
     SQL.Add('      END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      0 AS PER_IVA,      ');
     SQL.Add('      0 AS PER_FCP_ST   ');
     SQL.Add('   FROM PRODUTO P   ');
     SQL.Add('   INNER JOIN CLASFIS CF ON   ');
     SQL.Add('       (P.PRO_CLASFISCAL = CF.CFIS_CODIGO)   ');
     SQL.Add('   INNER JOIN DEPTOFIS DF ON   ');
     SQL.Add('       (P.PRO_DEPTOFIS = DF.DFIS_CODIGO)   ');


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

procedure TFrmSmDaTerraFacilete.GerarNCMUF;
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
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((CF.CFIS_DESCRICAO = '''') OR (CF.CFIS_DESCRICAO IS NULL)) THEN ''� DEFINIR''   ');
     SQL.Add('           ELSE CF.CFIS_DESCRICAO   ');
     SQL.Add('       END AS DES_NCM,   ');
     SQL.Add('       CF.cfis_numero AS NUM_NCM,   ');
     SQL.Add('       ''S'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       '''' AS COD_TAB_SPED,   ');
     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
     SQL.Add('       ''SP'' AS DES_SIGLA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''01'' THEN 2   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''02'' THEN 3   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''03'' THEN 4   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''04'' THEN 5   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''FF'' THEN 25   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''II'' THEN 1   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''NN'' THEN 22   ');
     SQL.Add('      END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      CASE   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''01'' THEN 2   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''02'' THEN 3   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''03'' THEN 4   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''04'' THEN 5   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''FF'' THEN 25   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''II'' THEN 1   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''NN'' THEN 22   ');
     SQL.Add('      END AS COD_TRIB_SAIDA,   ');
     SQL.Add('      0 AS PER_IVA,      ');
     SQL.Add('      0 AS PER_FCP_ST   ');
     SQL.Add('   FROM PRODUTO P   ');
     SQL.Add('   INNER JOIN CLASFIS CF ON   ');
     SQL.Add('       (P.PRO_CLASFISCAL = CF.CFIS_CODIGO)   ');
     SQL.Add('   INNER JOIN DEPTOFIS DF ON   ');
     SQL.Add('       (P.PRO_DEPTOFIS = DF.DFIS_CODIGO)   ');


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

procedure TFrmSmDaTerraFacilete.GerarNFClientes;
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

procedure TFrmSmDaTerraFacilete.GerarNFFornec;
var
   TotalCount : integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CNF.ENTC_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       TRIM (CNF.ENTC_NUMERODOCTO) AS NUM_NF_FORN,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN  ((CNF.ENTC_SERIE = '''') OR (CNF.ENTC_SERIE IS NULL)) THEN ''1''   ');
     SQL.Add('           ELSE CNF.ENTC_SERIE   ');
     SQL.Add('       END AS NUM_SERIE_NF,   ');
     SQL.Add('       COALESCE (CNF.ENTC_SUBSERIE, '''') AS NUM_SUBSERIE_NF,   ');
     SQL.Add('       5102 AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
     SQL.Add('       CNF.ENTC_VLRTOTALNOTA AS VAL_TOTAL_NF,   ');
     SQL.Add('       CNF.ENTC_DATACOMPRA AS DTA_EMISSAO,   ');
     SQL.Add('       CNF.ENTC_DATAENTRADA AS DTA_ENTRADA,   ');
     SQL.Add('       CNF.ENTC_VLRIPI AS VAL_TOTAL_IPI,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       CNF.ENTC_VLRFRETE AS VAL_FRETE,   ');
     SQL.Add('       CNF.entc_vfcpst AS VAL_ACRESCIMO,   ');
     SQL.Add('       0 AS VAL_DESCONTO,   ');
     SQL.Add('       F.FOR_CGC AS NUM_CGC,   ');
     SQL.Add('       CNF.ENTC_VLRBCICMS AS VAL_TOTAL_BC,   ');
     SQL.Add('       CNF.ENTC_VLRICMS AS VAL_TOTAL_ICMS,   ');
     SQL.Add('       CNF.ENTC_BASEICMSSUB AS VAL_BC_SUBST,   ');
     SQL.Add('       CNF.ENTC_ICMSSUB AS VAL_ICMS_SUBST,   ');
     SQL.Add('       0 AS VAL_FUNRURAL,   ');
     SQL.Add('       1 AS COD_PERFIL,   ');
     SQL.Add('       CNF.entc_outros AS VAL_DESP_ACESS,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       CNF.ENTC_CHAVENFE AS NUM_CHAVE_ACESSO,   ');
     SQL.Add('       CNF.entc_vfcpst AS VAL_TOT_ST_FCP   ');
     SQL.Add('      ');
     SQL.Add('   FROM ENTRAC CNF   ');
     SQL.Add('   INNER JOIN FORNECE F ON    ');
     SQL.Add('       (CNF.ENTC_FORNECEDOR = F.FOR_CODIGO)   ');
     SQL.Add('   WHERE   ');
     SQL.Add('       CNF.ENTC_DATACOMPRA BETWEEN :INI AND :FIM   ');
     SQL.Add('   ORDER BY   ');
     SQL.Add('       CNF.ENTC_NUMERODOCTO ASC   ');

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

procedure TFrmSmDaTerraFacilete.GerarNFitensClientes;
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

procedure TFrmSmDaTerraFacilete.GerarNFitensFornec;
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
     SQL.Add('       PNF.ENTP_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       TRIM(PNF.ENTP_NUMERODOCTO) AS NUM_NF_FORN,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((CNF.ENTC_SERIE = '''') OR (CNF.ENTC_SERIE IS NULL)) THEN 1   ');
     SQL.Add('           ELSE CNF.ENTC_SERIE   ');
     SQL.Add('       END AS NUM_SERIE_NF,   ');
     SQL.Add('       PNF.ENTP_PRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''01'' THEN 2   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''02'' THEN 3   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''03'' THEN 4   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''04'' THEN 5   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''FF'' THEN 25   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''II'' THEN 1   ');
     SQL.Add('           WHEN P.PRO_DEPTOFIS = ''NN'' THEN 22   ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM,   ');
     SQL.Add('       PNF.ENTP_QUANTIDADE AS QTD_ENTRADA,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN ((P.PRO_UNIDADE = '''') OR (P.PRO_UNIDADE IS NULL)) THEN ''UN''   ');
     SQL.Add('           ELSE P.PRO_UNIDADE   ');
     SQL.Add('       END AS DES_UNIDADE,   ');
     SQL.Add('       pnf.entp_vlrconf AS VAL_TABELA,   ');
     SQL.Add('       PNF.ENTP_DESCONTO AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       0 VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       (PNF.ENTP_VLRIPI / PNF.ENTP_QUANTIDADE) AS VAL_IPI_ITEM,   ');
     SQL.Add('       PNF.entp_ipi AS VAL_IPI_PER,   ');
     SQL.Add('       PNF.ENTP_RATEIOST AS VAL_SUBST_ITEM,   ');
     SQL.Add('       0 AS VAL_FRETE_ITEM,   ');
     SQL.Add('       PNF.ENTP_VLRICMS AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,      ');
     SQL.Add('       (pnf.entp_quantidade * pnf.entp_vlrconf) AS VAL_TABELA_LIQ,   ');
     SQL.Add('       F.FOR_CGC AS NUM_CGC,   ');
     SQL.Add('       PNF.ENTP_VLRBCICMS AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('       PNF.ENTP_CFOP AS CFOP,   ');
     SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
     SQL.Add('       PNF.ENTP_VLRBCICMSST AS VAL_TOT_BC_ST,   ');
     SQL.Add('       PNF.ENTP_RATEIOST AS VAL_TOT_ST,   ');
     SQL.Add('       PNF.ENTP_SEQUENCIA AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       CF.CFIS_NUMERO AS NUM_NCM,   ');
     SQL.Add('       '''' AS DES_REFERENCIA,   ');
     SQL.Add('       pnf.entp_vfcpst AS VAL_TOT_ST_FCP,');
     SQL.Add('       PNF.entp_vlrdespesasaces as VAL_DESP_ACESS_ITEM');
     SQL.Add('      ');
     SQL.Add('   FROM ENTRAP PNF   ');
     SQL.Add('   INNER JOIN ENTRAC CNF ON   ');
     SQL.Add('       (PNF.ENTP_NUMERODOCTO = CNF.ENTC_NUMERODOCTO)   ');
     SQL.Add('   INNER JOIN PRODUTO P ON   ');
     SQL.Add('       (PNF.ENTP_PRODUTO = P.PRO_CODIGO)   ');
     SQL.Add('   INNER JOIN CLASFIS CF ON   ');
     SQL.Add('       (P.PRO_CLASFISCAL = CF.CFIS_CODIGO)   ');
     SQL.Add('   INNER JOIN FORNECE F ON    ');
     SQL.Add('       (CNF.ENTC_FORNECEDOR = F.FOR_CODIGO)   ');
     SQL.Add('      ');
     SQL.Add('   WHERE   ');
     SQL.Add('       CNF.ENTC_DATACOMPRA BETWEEN :INI AND :FIM   ');
     SQL.Add('          ');
     SQL.Add('   ORDER BY   ');
     SQL.Add('       PNF.ENTP_NUMERODOCTO ASC   ');

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

procedure TFrmSmDaTerraFacilete.GerarProdForn;
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
     SQL.Add('       PF.PROF_PRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       PF.PROF_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       PF.PROF_PRODFORNEC AS DES_REFERENCIA,   ');
     SQL.Add('       F.FOR_CGC AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN (PF.PROF_UNIDADEFORNECEDOR IN (''CX'', ''CX'', ''01CX'', ''CXA'', ''CX12'', ''CX15'', ''CX25'')) THEN ''CX''   ');
     SQL.Add('           WHEN (PF.PROF_UNIDADEFORNECEDOR IN (''UN'', ''UNS'', ''UNID'', ''UNI'', ''UN'', ''15UN'', ''12UN'', ''10UN'', ''06UN'', ''01UN'' )) THEN ''UN''   ');
     SQL.Add('           WHEN (PF.PROF_UNIDADEFORNECEDOR IN (''PC'', ''PT'', ''PCT'', ''PC'')) THEN ''PC''   ');
     SQL.Add('           WHEN (PF.PROF_UNIDADEFORNECEDOR IN (''FD'', ''FD'', ''01FD'')) THEN ''FA''   ');
     SQL.Add('           ELSE COALESCE (PF.PROF_UNIDADEFORNECEDOR, ''UN'')   ');
     SQL.Add('       END AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       COALESCE (PF.PROF_UNIDADECONVERSAO, ''1'') AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       1 AS QTD_TROCA,   ');
     SQL.Add('       ''N'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM PRODUTOFORNECEDOR PF   ');
     SQL.Add('   LEFT JOIN FORNECE F ON   ');
     SQL.Add('       (PF.PROF_FORNECEDOR = F.FOR_CODIGO)   ');
     SQL.Add('   WHERE PF.PROF_FORNECEDOR <> 13   ');
     SQL.Add('   AND PF.PROF_FORNECEDOR <> 66   ');



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

procedure TFrmSmDaTerraFacilete.GerarProdLoja;
var
   TotalCount : integer;
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
       SQL.Add('       P.PRO_CODIGO AS COD_PRODUTO,   ');
       SQL.Add('       P.PRO_VALORCOMPRA AS VAL_CUSTO_REP,   ');
       SQL.Add('       P.PRO_VALORVISTA AS VAL_VENDA,   ');
       SQL.Add('       0 AS VAL_OFERTA,   ');
       SQL.Add('       COALESCE (P.PRO_ESTOQUEATUAL, 0) AS QTD_EST_VDA,   ');
       SQL.Add('       '''' AS TECLA_BALANCA,   ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''01'' THEN 2   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''02'' THEN 3   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''03'' THEN 4   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''04'' THEN 5   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''FF'' THEN 25   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''II'' THEN 1   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''NN'' THEN 22   ');
       SQL.Add('       END AS COD_TRIBUTACAO,   ');
       SQL.Add('       COALESCE (P.PRO_MARGEMV, 0) AS VAL_MARGEM,   ');
       SQL.Add('       1 AS QTD_ETIQUETA,   ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''01'' THEN 2   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''02'' THEN 3   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''03'' THEN 4   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''04'' THEN 5   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''FF'' THEN 25   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''II'' THEN 1   ');
       SQL.Add('           WHEN P.PRO_DEPTOFIS = ''NN'' THEN 22   ');
       SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
       SQL.Add('       ''N'' AS FLG_INATIVO,   ');
       SQL.Add('       P.PRO_CODIGO AS COD_PRODUTO_ANT,   ');
       SQL.Add('       CF.cfis_numero AS NUM_NCM,   ');
       SQL.Add('       0 AS TIPO_NCM,   ');
       SQL.Add('       0 AS VAL_VENDA_2,   ');
       SQL.Add('       '''' AS DTA_VALIDA_OFERTA,   ');
       SQL.Add('       1 AS QTD_EST_MINIMO,   ');
       SQL.Add('       NULL AS COD_VASILHAME,   ');
       SQL.Add('       ''N'' AS FORA_LINHA,   ');
       SQL.Add('       0 AS QTD_PRECO_DIF,   ');
       SQL.Add('       0 AS VAL_FORCA_VDA,   ');
       SQL.Add('       ''9999999'' AS NUM_CEST,   ');
       SQL.Add('       0 AS PER_IVA,   ');
       SQL.Add('       0 AS PER_FCP_ST,   ');
       SQL.Add('       0 AS PER_FIDELIDADE,   ');
       SQL.Add('       NULL AS COD_INFO_RECEITA   ');
       SQL.Add('      ');
       SQL.Add('   FROM PRODUTO P   ');
       SQL.Add('   INNER JOIN CLASFIS CF ON   ');
       SQL.Add('       (P.PRO_CLASFISCAL = CF.CFIS_CODIGO)    ');










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

procedure TFrmSmDaTerraFacilete.GerarProdSimilar;
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
