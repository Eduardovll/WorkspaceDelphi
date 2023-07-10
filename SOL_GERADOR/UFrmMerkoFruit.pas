unit UFrmMerkoFruit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrmModelo, Data.DBXOracle, Data.DB,
  Data.SqlExpr, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DBXFirebird, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.Provider, Datasnap.DBClient, //dxGDIPlusClasses,
  Math;

type
  TFrmMerkoFruit = class(TFrmModeloSis)
    btnGeraCest: TButton;
    BtnAmarrarCest: TButton;
    CbxLoja: TComboBox;
    lblLoja: TLabel;
    procedure btnGeraCestClick(Sender: TObject);
    procedure BtnAmarrarCestClick(Sender: TObject);
    procedure EdtCamBancoExit(Sender: TObject);
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

  end;

var
  FrmMerkoFruit: TFrmMerkoFruit;
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


procedure TFrmMerkoFruit.GerarProducao;
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

procedure TFrmMerkoFruit.GerarProduto;
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

//    SQL.Clear;
//    SQL.Add('ALTER TABLE CED001 ');
//    SQL.Add('ADD CODIGO_PRODUTO INT DEFAULT NULL; ');
//
//    try
//      ExecSQL;
//    except
//    end;
//
//    SQL.Clear;
//    SQL.Add('UPDATE TAB_PRODUTO_AUX ');
//    SQL.Add('SET COD_PRODUTO = :COD_PRODUTO  ');
//    SQL.Add('WHERE COD_BARRA_PRINCIPAL = :COD_BARRA_PRINCIPAL ');
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
     SQL.Add('       PRODUTO.COD_PRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTO.COD_BARRA_PRINCIPAL AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       PRODUTO.DES_REDUZIDA AS DES_REDUZIDA,   ');
     SQL.Add('       PRODUTO.DES_PRODUTO AS DES_PRODUTO,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       ''UN'' AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       ''UN'' AS DES_UNIDADE_VENDA,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       0 AS VAL_IPI,   ');
     SQL.Add('       999 AS COD_SECAO,   ');
     SQL.Add('       999 AS COD_GRUPO,   ');
     SQL.Add('       999 AS COD_SUB_GRUPO,   ');
     SQL.Add('       0 AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('       ''N'' AS IPV,   ');
     SQL.Add('       0 AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       ''N'' AS FLG_ENVIA_BALANCA,   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       0 AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       0 AS COD_INFO_RECEITA,   ');
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
     SQL.Add('       0 AS COD_FORNECEDOR,   ');
     SQL.Add('       0 AS NUM_NF,   ');
     SQL.Add('       '''' AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       PRODUTO.DES_PRODUTO AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX AS PRODUTO   ');


    Open;
    First;
    NumLinha := 0;
    //NEW_CODPROD := 195000;
    NEW_CODPROD := 1963427;
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

//      TIPO := QryPrincipal.FieldByName('TIPO').AsString;
//
//      if TIPO <> 'B' then
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

procedure TFrmMerkoFruit.GerarScriptAmarrarCEST;
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

procedure TFrmMerkoFruit.GerarScriptCEST;
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

procedure TFrmMerkoFruit.GerarSecao;
var
   TotalCount : integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       999 AS COD_SECAO,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_SECAO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX   ');


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

procedure TFrmMerkoFruit.GerarSubGrupo;
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
     SQL.Add('       999 AS COD_SUB_GRUPO,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_SUB_GRUPO,   ');
     SQL.Add('       0 AS VAL_META,   ');
     SQL.Add('       0 AS VAL_MARGEM_REF,   ');
     SQL.Add('       0 AS QTD_DIA_SEGURANCA,   ');
     SQL.Add('       ''N'' AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX   ');



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

procedure TFrmMerkoFruit.GerarTransportadora;
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

procedure TFrmMerkoFruit.GerarVenda;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.TIPO = ''B'' THEN PRODUTOS.CODIGO   ');
     SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO      ');
     SQL.Add('       END AS COD_PRODUTO, -- JOIN   ');
     SQL.Add('          ');
     SQL.Add('       1 AS COD_LOJA,   ');
     SQL.Add('       0 AS IND_TIPO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN VENDA.CAIXA IS NULL THEN 9   ');
     SQL.Add('           WHEN VENDA.CAIXA = ''00'' THEN 9   ');
     SQL.Add('           ELSE COALESCE(VENDA.CAIXA, 9)    ');
     SQL.Add('       END AS NUM_PDV,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(VENDA.QTDE, 1) AS QTD_TOTAL_PRODUTO,   ');
     SQL.Add('       (COALESCE(VENDA.QTDE, 1) * VENDA.VALOR) AS VAL_TOTAL_PRODUTO,   ');
     SQL.Add('       VENDA.VALOR AS VAL_PRECO_VENDA,   ');
     SQL.Add('       VENDA.CUSTO AS VAL_CUSTO_REP,   ');
     SQL.Add('       VENDA.DATA AS DTA_SAIDA,   ');
     SQL.Add('       REPLACE((SUBSTRING(VENDA.DATA FROM 6 FOR 2) || SUBSTRING(VENDA.DATA FROM 1 FOR 4)), ''-'', '''') AS DTA_MENSAL, -- MES E ANO 012020 SUBSELECT   ');
     SQL.Add('       CAST(VENDA.DOCUMENTO_CAIXA AS INTEGER) AS NUM_IDENT,   ');
     SQL.Add('       VENDA.CBARRA AS COD_EAN, -- JOIN   ');
     SQL.Add('       SUBSTRING(REPLACE(REPLACE(VENDA.HORARIO, '':'', ''''), ''.'', '''') FROM 1 FOR 4) AS DES_HORA,   ');
     SQL.Add('       8285 AS COD_CLIENTE, -- CADASTRAR    ');
     SQL.Add('       1 AS COD_ENTIDADE, -- TAB CRD013   ');
     SQL.Add('       COALESCE(VENDA.BASEICMS, 0) AS VAL_BASE_ICMS,   ');
     SQL.Add('       '''' AS DES_SITUACAO_TRIB,   ');
     SQL.Add('       COALESCE(VENDA.VRICMS, 0) AS VAL_ICMS,   ');
     SQL.Add('       VENDA.DOCUMENTO AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       (COALESCE(VENDA.QTDE, 1) * VENDA.VALOR) AS VAL_VENDA_PDV,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA IS NULL AND PRODUTOS.ICMS_SAIDA IS NULL AND PRODUTOS.CT IS NULL AND PRODUTOS.PERC_REDUCAO IS NULL THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = '''' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''00'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''010'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''041'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''051'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 20   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''090'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''160'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''201'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''051'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''1.25'' AND PRODUTOS.ICMS_SAIDA = ''1.25'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''1.62'' AND PRODUTOS.ICMS_SAIDA = ''1.62'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''1.86'' AND PRODUTOS.ICMS_SAIDA = ''1.86'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''1.90'' AND PRODUTOS.ICMS_SAIDA = ''1.90'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''3.45'' AND PRODUTOS.ICMS_SAIDA = ''3.45'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''3.58'' AND PRODUTOS.ICMS_SAIDA = ''3.58'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''4.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''4.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''7.00'' AND PRODUTOS.ICMS_SAIDA = ''7.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''7.00'' AND PRODUTOS.ICMS_SAIDA = ''7.00'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''7.00'' AND PRODUTOS.ICMS_SAIDA = ''7.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''7.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''010'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''41.66'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''070'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''010'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''30.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 31   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''010'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''33.30'' THEN 7   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 7   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''070'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''070'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''070'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''090'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''100'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''203'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''20.00'' AND PRODUTOS.ICMS_SAIDA = ''20.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 29   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''25.00'' AND PRODUTOS.ICMS_SAIDA = ''25.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''30.00'' AND PRODUTOS.ICMS_SAIDA = ''30.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 31   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''32.00'' AND PRODUTOS.ICMS_SAIDA = ''32.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 32   ');
     SQL.Add('           ELSE 23   ');
     SQL.Add('       END AS COD_TRIBUTACAO, --   ');
     SQL.Add('      ');
     SQL.Add('       ''N'' AS FLG_CUPOM_CANCELADO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CF = '''' THEN ''99999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.CF, ''99999999'')    ');
     SQL.Add('       END  AS NUM_NCM,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.NAT_REC = '''' THEN 999   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.NAT_REC, 999)   ');
     SQL.Add('       END AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA IS NULL AND PRODUTOS.PIS_COFINS_SAIDA IS NULL THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = '''' AND PRODUTOS.PIS_COFINS_SAIDA = '''' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''50'' AND PRODUTOS.PIS_COFINS_SAIDA = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''50'' AND PRODUTOS.PIS_COFINS_SAIDA = ''49'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''60'' AND PRODUTOS.PIS_COFINS_SAIDA = ''01'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''70'' AND PRODUTOS.PIS_COFINS_SAIDA = ''04'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''73'' AND PRODUTOS.PIS_COFINS_SAIDA = ''06'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''75'' AND PRODUTOS.PIS_COFINS_SAIDA = ''05'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''99'' AND PRODUTOS.PIS_COFINS_SAIDA = ''49'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''    ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA IS NULL AND PRODUTOS.PIS_COFINS_SAIDA IS NULL THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = '''' AND PRODUTOS.PIS_COFINS_SAIDA = '''' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''50'' AND PRODUTOS.PIS_COFINS_SAIDA = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''50'' AND PRODUTOS.PIS_COFINS_SAIDA = ''49'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''60'' AND PRODUTOS.PIS_COFINS_SAIDA = ''01'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''70'' AND PRODUTOS.PIS_COFINS_SAIDA = ''04'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''73'' AND PRODUTOS.PIS_COFINS_SAIDA = ''06'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''75'' AND PRODUTOS.PIS_COFINS_SAIDA = ''05'' THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.PIS_COFINS_ENTRADA = ''99'' AND PRODUTOS.PIS_COFINS_SAIDA = ''49'' THEN -1   ');
     SQL.Add('           ELSE -1   ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       ''N'' AS FLG_ONLINE,   ');
     SQL.Add('       ''N'' AS FLG_OFERTA,   ');
     SQL.Add('       0 AS COD_ASSOCIADO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CED004 AS VENDA   ');
     SQL.Add('   LEFT JOIN CED001 AS PRODUTOS ON PRODUTOS.CODIGO = VENDA.PRODUTO   ');
     SQL.Add('   WHERE VENDA.EOUS = ''S''   ');
     SQL.Add('   AND VENDA.TIPO = 11   ');
     SQL.Add('   AND VENDA.DATA >= :INI');
     SQL.Add('   AND VENDA.DATA <= :FIM');


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

procedure TFrmMerkoFruit.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmMerkoFruit.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmMerkoFruit.EdtCamBancoExit(Sender: TObject);
begin
  inherited;
  CriarFB(EdtCamBanco);
end;

procedure TFrmMerkoFruit.GerarCest;
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
     SQL.Add('       1 AS COD_CEST,   ');
     SQL.Add('       ''99999999'' AS NUM_CEST,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_CEST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX   ');

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

      //Layout.FieldByName('COD_CEST').AsInteger := count;
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

procedure TFrmMerkoFruit.GerarCliente;
var
  QryGeraCodigoCliente : TSQLQuery;
  CODIGO_CLIENTE : Integer;
begin
  inherited;

  QryGeraCodigoCliente := TSQLQuery.Create(FrmProgresso);
  with QryGeraCodigoCliente do
  begin
    SQLConnection := ScnBanco;

    SQL.Clear;
    SQL.Add('ALTER TABLE EMD105 ');
    SQL.Add('ADD CODIGO_CLIENTE INT DEFAULT NULL; ');

    try
      //ExecSQL;
    except
    end;

    SQL.Clear;
    SQL.Add('UPDATE EMD105');
    SQL.Add('SET CODIGO_CLIENTE = :COD_CLIENTE ');
    SQL.Add('WHERE COALESCE(REPLACE(REPLACE(REPLACE(CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') = :NUM_CGC ');

    try
      //ExecSQL;
    except
    end;

  end;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTE.CODIGO_CLIENTE AS COD_CLIENTE,   ');
     SQL.Add('       CLIENTE.NOME AS DES_CLIENTE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTE.CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       ''ISENTO'' AS NUM_INSC_EST,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_ENDERECO,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_BAIRRO,   ');
     SQL.Add('       ''PITANGUEIRAS'' AS DES_CIDADE,   ');
     SQL.Add('       ''SP'' AS DES_SIGLA,   ');
     SQL.Add('       ''14750000'' AS NUM_CEP,   ');
     SQL.Add('       '''' AS NUM_FONE,   ');
     SQL.Add('       '''' AS NUM_FAX,   ');
     SQL.Add('       CLIENTE.NOME AS DES_CONTATO,   ');
     SQL.Add('       0 AS FLG_SEXO,   ');
     SQL.Add('       0 AS VAL_LIMITE_CRETID,   ');
     SQL.Add('       0 AS VAL_LIMITE_CONV,   ');
     SQL.Add('       0 AS VAL_DEBITO,   ');
     SQL.Add('       0 AS VAL_RENDA,   ');
     SQL.Add('       0 AS COD_CONVENIO,   ');
     SQL.Add('       0 AS COD_STATUS_PDV,   ');
     SQL.Add('       ''N'' AS FLG_EMPRESA,   ');
     SQL.Add('       ''N'' AS FLG_CONVENIO,   ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,   ');
     SQL.Add('       '''' AS DTA_CADASTRO,   ');
     SQL.Add('       ''S/N'' AS NUM_ENDERECO,   ');
     SQL.Add('       '''' AS NUM_RG,   ');
     SQL.Add('       0 AS FLG_EST_CIVIL,   ');
     SQL.Add('       '''' AS NUM_CELULAR,   ');
     SQL.Add('       '''' AS DTA_ALTERACAO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       '''' AS DES_COMPLEMENTO,   ');
     SQL.Add('       '''' AS DES_EMAIL,   ');
     SQL.Add('       '''' AS DES_FANTASIA,   ');
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
     SQL.Add('       EMD105 AS CLIENTE   ');
     SQL.Add('   ORDER BY NOME   ');



    Open;
    First;
    NumLinha := 0;
    CODIGO_CLIENTE := 0;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);


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

procedure TFrmMerkoFruit.GerarCodigoBarras;
var
 count, NEW_CODPROD : Integer;
 cod_antigo, codbarras : string;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTO.COD_PRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTO.COD_BARRA_PRINCIPAL AS COD_EAN   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX AS PRODUTO   ');




    Open;
    First;
    NumLinha := 0;
    NEW_CODPROD := 195000;

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(NEW_CODPROD);

      Layout.SetValues(QryPrincipal, NumLinha, RecordCount);

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

procedure TFrmMerkoFruit.GerarComposicao;
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

procedure TFrmMerkoFruit.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTE.CODIGO_CLIENTE AS COD_CLIENTE,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       EMD105 AS CLIENTE   ');
     SQL.Add('   ORDER BY NOME   ');



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

procedure TFrmMerkoFruit.GerarCondPagForn;
var
  COD_FORNECEDOR : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDORES.CODIGO_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('       EMD101 AS FORNECEDORES   ');
     SQL.Add('   WHERE NOME NOT LIKE ''%CONS.%''   ');
     SQL.Add('   AND NOME NOT LIKE ''%CONSUMIDOR%''   ');
     SQL.Add('   ORDER BY NOME   ');



    Open;

    First;

    NumLinha := 0;
    COD_FORNECEDOR := 0;

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

procedure TFrmMerkoFruit.GerarDecomposicao;
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

procedure TFrmMerkoFruit.GerarDivisaoForn;
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

procedure TFrmMerkoFruit.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmMerkoFruit.GerarFinanceiroPagar(Aberto: String);
var
   TotalCount : Integer;
   cgc: string;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT');
    SQL.Add('    1 AS TIPO_PARCEIRO,');
    SQL.Add('    PAGAR.COD_FORNEC AS COD_PARCEIRO,');
    SQL.Add('    0 AS TIPO_CONTA,');
    SQL.Add('    8 AS COD_ENTIDADE,');
    SQL.Add('    PAGAR.NR_DOCUMENTO AS NUM_DOCTO,');
    SQL.Add('    999 AS COD_BANCO,');
    SQL.Add('    0 AS DES_BANCO,');
    SQL.Add('    PAGAR.EMISSAO AS DTA_EMISSAO,');
    SQL.Add('    PAGAR.VENCIMENTO AS DTA_VENCIMENTO,');
    SQL.Add('    PAGAR.VALOR AS VAL_PARCELA,');
    SQL.Add('    COALESCE(PAGAR.JUROS, 0) AS VAL_JUROS,');
    SQL.Add('    COALESCE(PAGAR.DESCONTO, 0) AS VAL_DESCONTO,');
    SQL.Add('');
    SQL.Add('    CASE ');
    SQL.Add('        WHEN PAGAR.BAIXADO = ''S'' THEN ''S''');
    SQL.Add('        ELSE ''N''');
    SQL.Add('    END AS FLG_QUITADO,');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('        WHEN PAGAR.BAIXADO = ''S'' THEN LPAD(EXTRACT(DAY FROM PAGAR.DT_PGTO), 2, ''0'') || ''/'' || LPAD(EXTRACT(MONTH FROM PAGAR.DT_PGTO), 2, ''0'')|| ''/'' || LPAD(EXTRACT(YEAR FROM PAGAR.DT_PGTO), 4, ''0'')');
    SQL.Add('        ELSE ''''');
    SQL.Add('    END AS DTA_QUITADA,    ');
    SQL.Add('');
    SQL.Add('    998 AS COD_CATEGORIA,');
    SQL.Add('    998 AS COD_SUBCATEGORIA,');
    SQL.Add('    ');
    SQL.Add('    SUBSTRING(PAGAR.PRESTACAO FROM 1 FOR (POSITION(''/'' IN PAGAR.PRESTACAO) - 1)) AS NUM_PARCELA,');
    SQL.Add('');
    SQL.Add('    PARCELAS.QTD_PARCELA AS QTD_PARCELA,');
    SQL.Add('    1 AS COD_LOJA,');
    SQL.Add('    FORNEC.CGC AS NUM_CGC,');
    SQL.Add('    0 AS NUM_BORDERO,');
    SQL.Add('    PAGAR.NR_DOCUMENTO AS NUM_NF,');
    SQL.Add('    '''' AS NUM_SERIE_NF,');
    SQL.Add('    PARCELAS.VAL_TOTAL_NF AS VAL_TOTAL_NF,');
    SQL.Add('    ''HISTORICO: '' || PAGAR.HISTORICO || '' OBSERVACAO:'' || PAGAR.OBSERVACAO AS DES_OBSERVACAO,');
    SQL.Add('    0 AS NUM_PDV,');
    SQL.Add('    PAGAR.NUM_OPER AS NUM_CUPOM_FISCAL,');
    SQL.Add('    0 AS COD_MOTIVO,');
    SQL.Add('    0 AS COD_CONVENIO,');
    SQL.Add('    0 AS COD_BIN,');
    SQL.Add('    '''' AS DES_BANDEIRA,');
    SQL.Add('    '''' AS DES_REDE_TEF,');
    SQL.Add('    0 AS VAL_RETENCAO,');
    SQL.Add('    0 AS COD_CONDICAO,');
    SQL.Add('');
    SQL.Add('    CASE');
    SQL.Add('        WHEN PAGAR.BAIXADO = ''S'' THEN LPAD(EXTRACT(DAY FROM PAGAR.DT_PGTO), 2, ''0'') || ''/'' || LPAD(EXTRACT(MONTH FROM PAGAR.DT_PGTO), 2, ''0'')|| ''/'' || LPAD(EXTRACT(YEAR FROM PAGAR.DT_PGTO), 4, ''0'')');
    SQL.Add('        ELSE ''''');
    SQL.Add('    END AS DTA_PAGTO,');
    SQL.Add('');
    SQL.Add('    PAGAR.EMISSAO AS DTA_ENTRADA,    ');
    SQL.Add('    '''' AS NUM_NOSSO_NUMERO,');
    SQL.Add('    '''' AS COD_BARRA,');
    SQL.Add('    ''N'' AS FLG_BOLETO_EMIT,');
    SQL.Add('    '''' AS NUM_CGC_CPF_TITULAR,');
    SQL.Add('    '''' AS DES_TITULAR,');
    SQL.Add('    30 AS NUM_CONDICAO,');
    SQL.Add('    0 AS VAL_CREDITO,');
    SQL.Add('    ''999'' AS COD_BANCO_PGTO,');
    SQL.Add('    ''PAGTO-1'' AS DES_CC,');
    SQL.Add('    0 AS COD_BANDEIRA,');
    SQL.Add('    '''' AS DTA_PRORROGACAO,');
    SQL.Add('    1 AS NUM_SEQ_FIN,');
    SQL.Add('    0 AS COD_COBRANCA,');
    SQL.Add('    '''' AS DTA_COBRANCA,');
    SQL.Add('    ''N'' AS FLG_ACEITE,');
    SQL.Add('    0 AS TIPO_ACEITE');
    SQL.Add('FROM     ');
    SQL.Add('    PAGAR ');
    SQL.Add('LEFT JOIN');
    SQL.Add('    (');
    SQL.Add('        SELECT');
    SQL.Add('            NR_DOCUMENTO,');
    SQL.Add('            COD_FORNEC,');
    SQL.Add('            COUNT(*) AS QTD_PARCELA,');
    SQL.Add('            SUM(PAGAR.VALOR) AS VAL_TOTAL_NF');
    SQL.Add('        FROM');
    SQL.Add('            PAGAR');
    SQL.Add('        WHERE');
    SQL.Add('            COALESCE(PAGAR.NR_DOCUMENTO, '''') <> ''''');
    SQL.Add('        GROUP by');
    SQL.Add('            NR_DOCUMENTO,');
    SQL.Add('            COD_FORNEC');
    SQL.Add('    ) AS PARCELAS');
    SQL.Add('ON');
    SQL.Add('    PAGAR.NR_DOCUMENTO = PARCELAS.NR_DOCUMENTO');
    SQL.Add('AND');
    SQL.Add('    PAGAR.COD_FORNEC = PARCELAS.COD_FORNEC');
    SQL.Add('LEFT JOIN');
    SQL.Add('    FORNEC');
    SQL.Add('ON');
    SQL.Add('    PAGAR.COD_FORNEC = FORNEC.CODIGO');
    SQL.Add('WHERE');

    if Aberto = '1' then
    begin
        SQL.Add('    PAGAR.BAIXADO <> ''S''');
    end
    else
    begin
        SQL.Add('    PAGAR.BAIXADO = ''S''');
        SQL.Add('AND');
        SQL.Add('    PAGAR.DT_PGTO >= :INI ');
        SQL.Add('AND');
        SQL.Add('    PAGAR.DT_PGTO <= :FIM ');
        ParamByName('INI').AsDate := DtpInicial.Date;
        ParamByName('FIM').AsDate := DtpFinal.Date;
    end;

    SQL.Add('ORDER BY');
    SQL.Add('    PAGAR.NR_DOCUMENTO,');
    SQL.Add('    PAGAR.COD_FORNEC,');
    SQL.Add('    PAGAR.EMISSAO     ');

    Open;
    First;

    if( Aberto = '1' ) then
      TotalCount := SetCountTotal(SQL.Text)
    else
      TotalCount := SetCountTotal(SQL.Text, ParamByName('INI').AsString, ParamByName('FIM').AsString );


    NumLinha := 0;

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
            Layout.FieldByName('COD_PARCEIRO').AsInteger := Layout.FieldByName('COD_PARCEIRO').AsInteger + 1000
           else
            Layout.FieldByName('COD_PARCEIRO').AsInteger := 0;
         end
         else
         begin
            if( not CPFEValido(cgc) ) then
               Layout.FieldByName('COD_PARCEIRO').AsInteger := Layout.FieldByName('COD_PARCEIRO').AsInteger + 1000
            else
               Layout.FieldByName('COD_PARCEIRO').AsInteger := 0;
         end;
      end;

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

procedure TFrmMerkoFruit.GerarFinanceiroReceber(Aberto: String);
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

procedure TFrmMerkoFruit.GerarFinanceiroReceberCartao;
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

procedure TFrmMerkoFruit.GerarFornecedor;
var
   observacao, email : string;
   COD_FORNECEDOR : Integer;
   QryGeraCodigoFornecedor : TSQLQuery;
begin
  inherited;

  QryGeraCodigoFornecedor := TSQLQuery.Create(FrmProgresso);
  with QryGeraCodigoFornecedor do
  begin
    SQLConnection := ScnBanco;

    SQL.Clear;
    SQL.Add('ALTER TABLE EMD101 ');
    SQL.Add('ADD CODIGO_FORNECEDOR INT DEFAULT NULL; ');

    try
      ExecSQL;
    except
    end;

    SQL.Clear;
    SQL.Add('UPDATE EMD101');
    SQL.Add('SET CODIGO_FORNECEDOR = :COD_FORNECEDOR ');
    SQL.Add('WHERE COALESCE(REPLACE(REPLACE(REPLACE(CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') = :NUM_CGC ');
    SQL.Add('AND NOME NOT LIKE ''%CONS.%''');
    SQL.Add('AND NOME NOT LIKE ''%CONSUMIDOR%''');

    try
      ExecSQL;
    except
    end;

  end;


  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDORES.CODIGO_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       FORNECEDORES.NOME AS DES_FORNECEDOR,   ');
     SQL.Add('       COALESCE(FORNECEDORES.NOME2, '''') AS DES_FANTASIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN FORNECEDORES.INSC_RG = '''' THEN ''ISENTO''   ');
     SQL.Add('           ELSE COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.INSC_RG, ''.'', ''''), ''/'', ''''), ''-'', ''''), ''ISENTO'')    ');
     SQL.Add('       END AS NUM_INSC_EST,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(FORNECEDORES.ENDERECO, ''A DEFINIR'') AS DES_ENDERECO,   ');
     SQL.Add('       COALESCE(FORNECEDORES.BAIRRO, ''A DEFINIR'') AS DES_BAIRRO,   ');
     SQL.Add('       COALESCE(FORNECEDORES.CIDADE, '''') AS DES_CIDADE,   ');
     SQL.Add('       COALESCE(FORNECEDORES.ESTADO, '''') AS DES_SIGLA,   ');
     SQL.Add('       COALESCE(FORNECEDORES.CEP, '''') AS NUM_CEP,   ');
     SQL.Add('       COALESCE(FORNECEDORES.FONE1, '''') AS NUM_FONE,   ');
     SQL.Add('       COALESCE(FORNECEDORES.FAX, '''') AS NUM_FAX,   ');
     SQL.Add('       '''' AS DES_CONTATO,   ');
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
     SQL.Add('       ''S/N'' AS NUM_ENDERECO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('          WHEN CHAR_LENGTH(FORNECEDORES.EMAIL) > 50 THEN FORNECEDORES.EMAIL   ');
     SQL.Add('          ELSE ''''   ');
     SQL.Add('       END AS DES_OBSERVACAO,   ');
     SQL.Add('       COALESCE(FORNECEDORES.EMAIL, '''') AS DES_EMAIL,   ');
     SQL.Add('       '''' AS DES_WEB_SITE,   ');
     SQL.Add('       ''N'' AS FABRICANTE,   ');
     SQL.Add('       ''N'' AS FLG_PRODUTOR_RURAL,   ');
     SQL.Add('       0 AS TIPO_FRETE,   ');
     SQL.Add('       ''N'' AS FLG_SIMPLES,   ');
     SQL.Add('       ''N'' AS FLG_SUBSTITUTO_TRIB,   ');
     SQL.Add('       0 AS COD_CONTACCFORN,   ');
     SQL.Add('       ''N'' AS INATIVO,   ');
     SQL.Add('       0 AS COD_CLASSIF,   ');
     SQL.Add('       COALESCE(FORNECEDORES.DT_CADASTRO, '''') AS DTA_CADASTRO,   ');
     SQL.Add('       0 AS VAL_CREDITO,   ');
     SQL.Add('       0 AS VAL_DEBITO,   ');
     SQL.Add('       1 AS PED_MIN_VAL,   ');
     SQL.Add('       COALESCE(FORNECEDORES.EMAIL, '''') AS DES_EMAIL_VEND,   ');
     SQL.Add('       '''' AS SENHA_COTACAO,   ');
     SQL.Add('       -1 AS TIPO_PRODUTOR,   ');
     SQL.Add('       COALESCE(FORNECEDORES.CELULAR, '''') AS NUM_CELULAR   ');
     SQL.Add('   FROM   ');
     SQL.Add('       EMD101 AS FORNECEDORES   ');
     SQL.Add('   WHERE NOME NOT LIKE ''%CONS.%''   ');
     SQL.Add('   AND NOME NOT LIKE ''%CONSUMIDOR%''   ');
     SQL.Add('   ORDER BY DES_FORNECEDOR   ');


    Open;

    First;
    NumLinha := 0;
    COD_FORNECEDOR := 0;

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
      Layout.FieldByName('NUM_INSC_EST').AsString := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);
      Layout.FieldByName('NUM_CEP').AsString := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

//      if QryPrincipal.FieldByName('NUM_INSC_EST').AsString = '0' then
//         Layout.FieldByName('NUM_INSC_EST').AsString := 'ISENTO';
//
//      if QryPrincipal.FieldByName('NUM_INSC_EST').AsString <> 'ISENTO' then
//         Layout.FieldByName('NUM_INSC_EST').AsString := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);

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

procedure TFrmMerkoFruit.GerarGrupo;
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
     SQL.Add('       ''A DEFINIR'' AS DES_GRUPO,   ');
     SQL.Add('       0 AS VAL_META   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX   ');



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

procedure TFrmMerkoFruit.GerarInfoNutricionais;
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

procedure TFrmMerkoFruit.GerarNCM;
var
 count, TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       1 AS COD_NCM,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_NCM,   ');
     SQL.Add('       ''99999999'' AS NUM_NCM,   ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
     SQL.Add('       ''RJ'' AS DES_SIGLA,   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
     SQL.Add('       1 AS COD_TRIB_SAIDA,   ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX   ');



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

      //Layout.FieldByName('COD_NCM').AsInteger := count;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmMerkoFruit.GerarNCMUF;
var
 count, TotalCount : Integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       1 AS COD_NCM,   ');
     SQL.Add('       ''A DEFINIR'' AS DES_NCM,   ');
     SQL.Add('       ''99999999'' AS NUM_NCM,   ');
     SQL.Add('       ''N'' AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       -1 AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
     SQL.Add('       ''RJ'' AS DES_SIGLA,   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
     SQL.Add('       1 AS COD_TRIB_SAIDA,   ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX   ');



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

      //Layout.FieldByName('COD_NCM').AsInteger := count;

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmMerkoFruit.GerarNFClientes;
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

procedure TFrmMerkoFruit.GerarNFFornec;
var
   TotalCount : integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDOR.CODIGO_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       CAPA.DOCUMENTO AS NUM_NF_FORN,   ');
     SQL.Add('       CAPA.SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
     SQL.Add('       '''' AS CFOP,   ');
     SQL.Add('       0 AS TIPO_NF,   ');
     SQL.Add('       COALESCE(CAPA.TIPO_NF, ''NFE'') AS DES_ESPECIE,   ');
     SQL.Add('       CAPA.VRLIQUIDO AS VAL_TOTAL_NF,   ');
     SQL.Add('       CAPA.EMISSAO AS DTA_EMISSAO,   ');
     SQL.Add('       CAPA.DIGITOU AS DTA_ENTRADA,   ');
     SQL.Add('       COALESCE(CAPA.VRIPI, 0) AS VAL_TOTAL_IPI,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       COALESCE(CAPA.FRETES, 0) AS VAL_FRETE,   ');
     SQL.Add('       COALESCE(CAPA.ACRESCIMOS, 0) AS VAL_ACRESCIMO,   ');
     SQL.Add('       COALESCE(CAPA.DESCONTOS, 0) AS VAL_DESCONTO,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       COALESCE(CAPA.BASEICMS_COMPRA, 0) AS VAL_TOTAL_BC,   ');
     SQL.Add('       COALESCE(CAPA.VRICMS_COMPRA, 0) AS VAL_TOTAL_ICMS,   ');
     SQL.Add('       COALESCE(CAPA.BASEICMS_SUBST, 0) AS VAL_BC_SUBST,   ');
     SQL.Add('       COALESCE(CAPA.VRICMS_SUBST, 0) AS VAL_ICMS_SUBST,   ');
     SQL.Add('       0 AS VAL_FUNRURAL,   ');
     SQL.Add('       1 AS COD_PERFIL,   ');
     SQL.Add('       0 AS VAL_DESP_ACESS,   ');
     SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
     SQL.Add('       CAPA.OBS AS DES_OBSERVACAO,   ');
     SQL.Add('       CAPA.CHAVE_NFE AS NUM_CHAVE_ACESSO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CED003 AS CAPA   ');
     SQL.Add('   LEFT JOIN EMD101 AS FORNECEDOR ON FORNECEDOR.CGC_CPF = CAPA.CGC_CPF   ');
     SQL.Add('   WHERE CAPA.EOUS = ''E''   ');
     SQL.Add('   AND CAPA.TIPO IN (21,22) ');
     //SQL.Add('   AND CAPA.DOCUMENTO = ''001834'' ');
     SQL.Add('   AND CAPA.EMISSAO >= :INI');
     SQL.Add('   AND CAPA.EMISSAO <= :FIM');
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

procedure TFrmMerkoFruit.GerarNFitensClientes;
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

procedure TFrmMerkoFruit.GerarNFitensFornec;
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
     SQL.Add('       FORNECEDOR.CODIGO_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       ITENS.DOCUMENTO AS NUM_NF_FORN,   ');
     SQL.Add('       CAPA.SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.TIPO = ''B'' THEN PRODUTOS.CODIGO   ');
     SQL.Add('           ELSE PRODUTOS.CODIGO_PRODUTO     ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA IS NULL AND PRODUTOS.ICMS_SAIDA IS NULL AND PRODUTOS.CT IS NULL AND PRODUTOS.PERC_REDUCAO IS NULL THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = '''' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''00'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''010'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''041'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 23   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''051'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 20   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''090'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''160'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''201'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''051'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''0.000'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''1.25'' AND PRODUTOS.ICMS_SAIDA = ''1.25'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''1.62'' AND PRODUTOS.ICMS_SAIDA = ''1.62'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''1.86'' AND PRODUTOS.ICMS_SAIDA = ''1.86'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''1.90'' AND PRODUTOS.ICMS_SAIDA = ''1.90'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''3.45'' AND PRODUTOS.ICMS_SAIDA = ''3.45'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''3.58'' AND PRODUTOS.ICMS_SAIDA = ''3.58'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''4.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''4.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''7.00'' AND PRODUTOS.ICMS_SAIDA = ''7.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''7.00'' AND PRODUTOS.ICMS_SAIDA = ''7.00'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''7.00'' AND PRODUTOS.ICMS_SAIDA = ''7.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''7.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''010'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''41.66'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''12.00'' AND PRODUTOS.CT = ''070'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''010'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''41.67'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''12.00'' AND PRODUTOS.ICMS_SAIDA = ''30.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 31   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''0.000'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''000'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''010'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''33.30'' THEN 7   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 7   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''020'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''040'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''070'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 18   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''070'' AND PRODUTOS.PERC_REDUCAO = ''33.33'' THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''070'' AND PRODUTOS.PERC_REDUCAO = ''61.11'' THEN 17   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''090'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''100'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''18.00'' AND PRODUTOS.ICMS_SAIDA = ''18.00'' AND PRODUTOS.CT = ''203'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''20.00'' AND PRODUTOS.ICMS_SAIDA = ''20.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 29   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''25.00'' AND PRODUTOS.ICMS_SAIDA = ''25.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''30.00'' AND PRODUTOS.ICMS_SAIDA = ''30.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 31   ');
     SQL.Add('           WHEN PRODUTOS.ICMS_ENTRADA = ''32.00'' AND PRODUTOS.ICMS_SAIDA = ''32.00'' AND PRODUTOS.CT = ''060'' AND PRODUTOS.PERC_REDUCAO = ''0.000'' THEN 32   ');
     SQL.Add('           ELSE 23   ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(CAST(ITENS.CONTEUDO AS INT), 1) AS QTD_EMBALAGEM,   ');
     SQL.Add('       (CAST(ITENS.QTDE AS INT) / CAST(ITENS.CONTEUDO AS INT)) AS QTD_ENTRADA,   ');
     SQL.Add('       COALESCE(ITENS.UNIDADE, ''UN'') AS DES_UNIDADE,   ');
     SQL.Add('       COALESCE(ITENS.VALOR, 0) AS VAL_TABELA,   ');
     SQL.Add('               CASE   ');
     SQL.Add('                   WHEN (CAST(ITENS.QTDE AS INT) / CAST(ITENS.CONTEUDO AS INT)) = 0 THEN COALESCE(ITENS.DESCONTO, 0)   ');
     SQL.Add('                   ELSE COALESCE(ITENS.DESCONTO, 0) / (CAST(ITENS.QTDE AS INT) / CAST(ITENS.CONTEUDO AS INT))   ');
     SQL.Add('               END AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       COALESCE(ITENS.ACRESCIMO, 0) AS VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       COALESCE(ITENS.VRIPI, 0) AS VAL_IPI_ITEM,   ');
     SQL.Add('       COALESCE(ITENS.ICMS_SUBST, 0) AS VAL_SUBST_ITEM,   ');
     SQL.Add('       COALESCE(ITENS.FRETE, 0) AS VAL_FRETE_ITEM,   ');
     SQL.Add('       COALESCE(ITENS.CRED_ICMS, 0) AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       (ITENS.VALOR * ((CAST(ITENS.QTDE AS INT) / CAST(ITENS.CONTEUDO AS INT)))) + COALESCE(ITENS.ACRESCIMO, 0) + COALESCE(ITENS.FRETE, 0) -  COALESCE(ITENS.DESCONTO, 0) AS VAL_TABELA_LIQ,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       COALESCE(ITENS.BASEICMS_COMPRA, 0) AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('       COALESCE(ITENS.CFOP_ENTRADA, ''1102'') AS CFOP,   ');
     SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
     SQL.Add('       COALESCE(ITENS.BASE_SUBST_COMPRA, 0) AS VAL_TOT_BC_ST,   ');
     SQL.Add('       COALESCE(ITENS.VRICMS_SUBST_COMPRA, 0) AS  VAL_TOT_ST,   ');
     SQL.Add('       1 AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       ITENS.NCM AS NUM_NCM,   ');
     SQL.Add('       '''' AS DES_REFERENCIA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CED004 AS ITENS   ');
     SQL.Add('   LEFT JOIN EMD101 AS FORNECEDOR ON FORNECEDOR.CGC_CPF = ITENS.CGC_CPF   ');
     SQL.Add('   LEFT JOIN CED001 AS PRODUTOS ON PRODUTOS.CODIGO = ITENS.PRODUTO   ');
     SQL.Add('   LEFT JOIN CED003 AS CAPA ON CAPA.DOCUMENTO = ITENS.DOCUMENTO  AND CAPA.CGC_CPF = ITENS.CGC_CPF   ');
     SQL.Add('   WHERE CAPA.EOUS = ''E''   ');
     SQL.Add('   AND CAPA.TIPO IN (21,22) ');
     //SQL.Add('   AND CAPA.DOCUMENTO = ''001834'' ');
     SQL.Add('   AND ITENS.DATA >= :INI  ');
     SQL.Add('   AND ITENS.DATA <= :FIM  ');
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
//
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

procedure TFrmMerkoFruit.GerarProdForn;
var
   TotalCount : Integer;
begin
  inherited;

  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTO.TIPO = ''B'' THEN PRODUTO.CODIGO   ');
     SQL.Add('           ELSE PRODUTO.CODIGO_PRODUTO   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('       FORNECEDOR.CODIGO_FORNECEDOR AS COD_FORNECEDOR,   ');
     SQL.Add('       COALESCE(PRODFORNEC.CBARRA_FORNECEDOR, '''') AS DES_REFERENCIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDOR.CGC_CPF, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('       COALESCE(PRODUTO.UNIDADE, ''UN'') AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       COALESCE(PRODUTO.QTDE_EMBALAGEM, 1) AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       1 AS QTD_TROCA,   ');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CED001 AS PRODUTO   ');
     SQL.Add('   LEFT JOIN EMD101 AS FORNECEDOR ON FORNECEDOR.CGC_CPF = PRODUTO.FORNEC1   ');
     SQL.Add('   LEFT JOIN CED009 AS PRODFORNEC ON PRODFORNEC.CBARRA_CADASTRO = PRODUTO.CODIGO AND PRODFORNEC.FORNECEDOR = PRODUTO.FORNEC1   ');
     SQL.Add('   WHERE PRODUTO.FORNEC1 IS NOT NULL   ');
     SQL.Add('   AND PRODUTO.FORNEC1 <> ''''   ');
     SQL.Add('   AND FORNECEDOR.CODIGO_FORNECEDOR IS NOT NULL   ');
     SQL.Add('   AND PRODFORNEC.CBARRA_FORNECEDOR <> '''' ');
     SQL.Add('   AND PRODFORNEC.CBARRA_FORNECEDOR IS NOT NULL ');





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

procedure TFrmMerkoFruit.GerarProdLoja;
var
   TotalCount, NEW_CODPROD : integer;
begin
  inherited;
  with QryPrincipal do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTO.COD_PRODUTO AS COD_PRODUTO,   ');
     SQL.Add('       PRODUTO.VAL_CUSTO AS VAL_CUSTO_REP,   ');
     SQL.Add('       PRODUTO.VAL_VENDA AS VAL_VENDA,   ');
     SQL.Add('       0 AS VAL_OFERTA,   ');
     SQL.Add('       1 AS QTD_EST_VDA,   ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('       1 AS COD_TRIBUTACAO,   ');
     SQL.Add('       0 AS VAL_MARGEM,   ');
     SQL.Add('       1 AS QTD_ETIQUETA,   ');
     SQL.Add('       1 AS COD_TRIB_ENTRADA,   ');
     SQL.Add('       ''N'' AS FLG_INATIVO,   ');
     SQL.Add('       PRODUTO.COD_PRODUTO AS COD_PRODUTO_ANT,   ');
     SQL.Add('       ''99999999'' AS NUM_NCM,   ');
     SQL.Add('       0 AS TIPO_NCM,   ');
     SQL.Add('       0 AS VAL_VENDA_2,   ');
     SQL.Add('       '''' AS DTA_VALIDA_OFERTA,   ');
     SQL.Add('       0 AS QTD_EST_MINIMO,   ');
     SQL.Add('       NULL AS COD_VASILHAME,   ');
     SQL.Add('       ''N'' AS FORA_LINHA,   ');
     SQL.Add('       0 AS QTD_PRECO_DIF,   ');
     SQL.Add('       0 AS VAL_FORCA_VDA,   ');
     SQL.Add('       ''9999999'' AS NUM_CEST,   ');
     SQL.Add('       0 AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST,   ');
     SQL.Add('       0 AS PER_FIDELIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       TAB_PRODUTO_AUX AS PRODUTO   ');




    Open;
    First;
    NumLinha := 0;
    NEW_CODPROD := 195000;

    TotalCount := SetCountTotal(SQL.Text);

    while not Eof do
    begin
    try
      if Cancelar then
      Break;
      Inc(NumLinha);
      Inc(NEW_CODPROD);
      Layout.SetValues(QryPrincipal, NumLinha, TotalCount);

//      if Layout.FieldByName('COD_PRODUTO').AsString = '0' then
//      begin
//        Layout.FieldByName('COD_PRODUTO').AsInteger := NEW_CODPROD;
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

procedure TFrmMerkoFruit.GerarProdSimilar;
begin
  inherited;
  with QryPrincipal do
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

end.
