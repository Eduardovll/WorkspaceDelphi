unit UFrmSmDourado;

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
  TFrmSmDourado = class(TFrmModeloSis)
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
  FrmSmDourado: TFrmSmDourado;
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


procedure TFrmSmDourado.GerarProducao;
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

procedure TFrmSmDourado.GerarProduto;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTOS.CODPROD_PRODUTOS AS COD_PRODUTO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('   		    WHEN LEN(PRODUTOS.CODBARRA_PRODUTOS) = 7 THEN PRODUTOS.CODPROD_PRODUTOS   ');
     SQL.Add('   		    ELSE PRODUTOS.CODBARRA_PRODUTOS   ');
     SQL.Add('   	   END AS COD_BARRA_PRINCIPAL,   ');
     SQL.Add('       PRODUTOS.DESCRICAO_PRODUTOS AS DES_REDUZIDA,   ');
     SQL.Add('       PRODUTOS.DESCRICAO_PRODUTOS AS DES_PRODUTO,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       PRODUTOS.UNIDADE_PRODUTOS AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_VENDA,   ');
     SQL.Add('       PRODUTOS.UNIDADE_PRODUTOS AS DES_UNIDADE_VENDA,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       PRODUTOS.IPI_PRODUTOS AS VAL_IPI,   ');
     SQL.Add('       999 AS COD_SECAO,   ');
     SQL.Add('       999 AS COD_GRUPO,   ');
     SQL.Add('       999 AS COD_SUB_GRUPO,   ');
     SQL.Add('       0 AS COD_PRODUTO_SIMILAR,   ');
     SQL.Add('          ');
     SQL.Add('   CASE      ');
     SQL.Add('            WHEN LEN(PRODUTOS.CODBARRA_PRODUTOS) = 7 THEN ''S''      ');
     SQL.Add('            ELSE ''N''      ');
     SQL.Add('   END AS IPV,    ');
     SQL.Add('          ');
     SQL.Add('       PRODUTOS.PRAZOVAL_PRODUTOS AS DIAS_VALIDADE,   ');
     SQL.Add('       0 AS TIPO_PRODUTO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''0.00'' AND PRODUTOS.ALIQUOTACOFINS = ''0.00'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS IS NULL AND PRODUTOS.ALIQUOTACOFINS IS NULL THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''1.65'' AND PRODUTOS.ALIQUOTACOFINS = ''7.60'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''7.60'' AND PRODUTOS.ALIQUOTACOFINS = ''1.65'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''    ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('   CASE      ');
     SQL.Add('          WHEN LEN(PRODUTOS.CODBARRA_PRODUTOS) = 7 THEN ''S''      ');
     SQL.Add('          ELSE ''N''      ');
     SQL.Add('   END AS FLG_ENVIA_BALANCA,    ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''0.00'' AND PRODUTOS.ALIQUOTACOFINS = ''0.00'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS IS NULL AND PRODUTOS.ALIQUOTACOFINS IS NULL THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''1.65'' AND PRODUTOS.ALIQUOTACOFINS = ''7.60'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''7.60'' AND PRODUTOS.ALIQUOTACOFINS = ''1.65'' THEN -1   ');
     SQL.Add('           ELSE -1    ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       0 AS TIPO_EVENTO,   ');
     SQL.Add('       0 AS COD_ASSOCIADO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       CAST(PRODUTOS.INFONUTRI AS INT) AS COD_INFO_NUTRICIONAL,   ');
     SQL.Add('       0 AS COD_INFO_RECEITA,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE PRODUTOS.BEBIDAALCOOLICA   ');
     SQL.Add('           WHEN 1 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
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
     SQL.Add('       '''' AS DTA_ENTRADA,   ');
     SQL.Add('       0 AS COD_NAT_BEM,   ');
     SQL.Add('       0 AS VAL_ORIG_BEM,   ');
     SQL.Add('       PRODUTOS.DESCRICAO_PRODUTOS AS DES_PRODUTO_ANT   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');






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


procedure TFrmSmDourado.GerarSecao;
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
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');

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

procedure TFrmSmDourado.GerarSubGrupo;
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
     SQL.Add('      ');
     SQL.Add('       CASE PRODUTOS.BEBIDAALCOOLICA   ');
     SQL.Add('           WHEN 1 THEN ''S''   ');
     SQL.Add('           ELSE ''N''   ');
     SQL.Add('       END AS FLG_ALCOOLICO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');


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

procedure TFrmSmDourado.GerarValorVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('    PRODUTOS.CODPROD_PRODUTOS AS COD_PRODUTO,   ');
     SQL.Add('   	REPLACE(COALESCE(PRODLOJA.VENDA, 0), '','', ''.'') AS VAL_VENDA   ');
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

procedure TFrmSmDourado.GerarVenda;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT DISTINCT ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''137241'' THEN ''137207''   ');
     SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''138363'' THEN ''0138356''   ');
     SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''137713'' THEN ''138632''   ');
     SQL.Add('           ELSE PRODUTOS.CODPROD_PRODUTOS   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       VENDAS.CODEMPRESA AS COD_LOJA,   ');
     SQL.Add('       0 IND_TIPO,   ');
     SQL.Add('       VENDAS.CAIXA_MOV AS NUM_PDV,   ');
     SQL.Add('       VENDAS.QTD_MOV AS QTD_TOTAL_PRODUTO,   ');
     SQL.Add('       VENDAS.venda_mov AS VAL_TOTAL_PRODUTO,   ');
     SQL.Add('       VENDAS.VendaUn AS VAL_PRECO_VENDA,   ');
     SQL.Add('       (COALESCE(VENDAS.CUSTO_MOV, 0)/ CASE WHEN VENDAS.QTD_MOV = 0 THEN 1 ELSE VENDAS.QTD_MOV END) AS VAL_CUSTO_REP,   ');
     SQL.Add('       VENDAS.DATA_MOV AS DTA_SAIDA,   ');
     SQL.Add('   	   CASE   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''JAN'' THEN ''01'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''FEV'' THEN ''02'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''MAR'' THEN ''03'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''ABR'' THEN ''04'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''MAI'' THEN ''05'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''JUN'' THEN ''06'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''JUL'' THEN ''07'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''AGO'' THEN ''08'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''SET'' THEN ''09'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''OUT'' THEN ''10'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''NOV'' THEN ''11'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     WHEN REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''') = ''DEZ'' THEN ''12'' + REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 7,10)), '' '', '''')   ');
     SQL.Add('   		     ELSE REPLACE(LTRIM(SUBSTRING(CONVERT(VARCHAR, VENDAS.DATA, 106), 3,5)), '' '', '''')   ');
     SQL.Add('   	   END DTA_MENSAL,   ');
     SQL.Add('       COALESCE(VENDAS.SEQUENCIA, VENDAS.COD_MOV) AS NUM_IDENT,   ');
     SQL.Add('          ');
     SQL.Add('   	   '''' AS COD_EAN,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('   		    WHEN LEN(LTRIM(REPLACE(SUBSTRING(CAST(DATA_MOV AS VARCHAR), 13, 5), '':'', ''''))) = 3 THEN ''0'' + LTRIM(REPLACE(SUBSTRING(CAST(DATA_MOV AS VARCHAR), 13, 5), '':'', ''''))   ');
     SQL.Add('   		    ELSE REPLACE(SUBSTRING(CAST(DATA_MOV AS VARCHAR), 13, 5), '':'', '''')    ');
     SQL.Add('   	   END AS DES_HORA,   ');
     SQL.Add('          ');
     SQL.Add('       1 AS COD_CLIENTE,   ');
     SQL.Add('       1 AS COD_ENTIDADE,   ');
     SQL.Add('       0 AS VAL_BASE_ICMS,   ');
     SQL.Add('       '''' AS DES_SITUACAO_TRIB,   ');
     SQL.Add('       COALESCE(VENDAS.VALOR_ICMS, 0) AS VAL_ICMS,   ');
     SQL.Add('       VENDAS.COO AS NUM_CUPOM_FISCAL,   ');
     SQL.Add('       VENDAS.VendaUn AS VAL_VENDA_PDV,   ');
     SQL.Add('          ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN VENDAS.CANCELADA = 0 THEN ''N''   ');
     SQL.Add('           ELSE ''S''   ');
     SQL.Add('       END AS FLG_CUPOM_CANCELADO,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(VENDAS.NCM, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''0.00'' AND PRODUTOS.ALIQUOTACOFINS = ''0.00'' THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS IS NULL AND PRODUTOS.ALIQUOTACOFINS IS NULL THEN ''S''      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''1.65'' AND PRODUTOS.ALIQUOTACOFINS = ''7.60'' THEN ''N''      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''7.60'' AND PRODUTOS.ALIQUOTACOFINS = ''1.65'' THEN ''N''      ');
     SQL.Add('           ELSE ''N''       ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''0.00'' AND PRODUTOS.ALIQUOTACOFINS = ''0.00'' THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS IS NULL AND PRODUTOS.ALIQUOTACOFINS IS NULL THEN 0      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''1.65'' AND PRODUTOS.ALIQUOTACOFINS = ''7.60'' THEN -1      ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''7.60'' AND PRODUTOS.ALIQUOTACOFINS = ''1.65'' THEN -1      ');
     SQL.Add('           ELSE -1       ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('      ');
     SQL.Add('       ''S'' AS FLG_ONLINE,   ');
     SQL.Add('       ''N'' AS FLG_OFERTA,   ');
     SQL.Add('       0 AS COD_ASSOCIADO   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_MOVIMENTACAO AS VENDAS   ');
     SQL.Add('   INNER JOIN CE_PRODUTOS AS PRODUTOS ON PRODUTOS.CODBARRA_PRODUTOS = VENDAS.CODBARRA_MOV   ');
     SQL.Add('   LEFT JOIN CE_VendasCaixa AS CVENDAS ON CVENDAS.ChaveVenda = VENDAS.ChaveVenda AND CVENDAS.COO = VENDAS.coo  ');
     SQL.Add('   WHERE');
     SQL.Add('      CAST(VENDAS.DATA_MOV AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('   AND');
     SQL.Add('      CAST(VENDAS.DATA_MOV AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add('   AND VENDAS.CANCELADA = 0    ');
     SQL.Add('   AND CVENDAS.ESTORNADA = 0   ');

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

procedure TFrmSmDourado.BtnAmarrarCestClick(Sender: TObject);
begin
  inherited;
    inherited;
  FlgGeraAmarrarCest := True;
  BtnGerar.Click;
  FlgGeraAmarrarCest := False;
end;

procedure TFrmSmDourado.btnGeraCestClick(Sender: TObject);
begin
  inherited;
  FlgGeraCest := True;
  BtnGerar.Click;
  FlgGeraCest := False;
end;

procedure TFrmSmDourado.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmDourado.BtnGerarClick(Sender: TObject);
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
//
//   ADOSQLServer.Connected := false;
end;



procedure TFrmSmDourado.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmDourado.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;

end;

procedure TFrmSmDourado.CkbProdLojaClick(Sender: TObject);
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

procedure TFrmSmDourado.FormCreate(Sender: TObject);
begin
  inherited;

end;

//procedure Dourado.FormCreate(Sender: TObject);
//begin
//  inherited;
////  Left:=(Screen.Width-Width)  div 2;
////  Top:=(Screen.Height-Height) div 2;
//end;

procedure TFrmSmDourado.GeraCustoRep;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;


     SQL.Add('   SELECT   ');
     SQL.Add('   	PRODUTOS.CODPROD_PRODUTOS AS COD_PRODUTO,   ');
     SQL.Add('   	REPLACE(COALESCE(PRODLOJA.CUSTO, 0), '','', ''.'') AS VAL_CUSTO_REP   ');
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

procedure TFrmSmDourado.GeraEstoqueVenda;
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

procedure TFrmSmDourado.GerarCest;
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
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CEST = '''' THEN ''99999999''    ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''5'' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''.'' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''2,89'' THEN ''99999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.CEST, ''99999999'')    ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('      ');
     SQL.Add('       ''A DEFINIR'' AS DES_CEST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');

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

procedure TFrmSmDourado.GerarCliente;
begin

   inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTES.CODCLIENTE AS COD_CLIENTE,   ');
     SQL.Add('       CLIENTES.NOMECLIENTE AS DES_CLIENTE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CPFCLIENTE, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       ''ISENTO'' AS NUM_INSC_EST,   ');
     SQL.Add('       COALESCE(CLIENTES.ENDERECOCLIENTE, ''A DEFINIR'') AS DES_ENDERECO,   ');
     SQL.Add('       COALESCE(CLIENTES.BAIRROCLIENTE, ''A DEFINIR'') AS DES_BAIRRO,   ');
     SQL.Add('       COALESCE(CLIENTES.CIDADECLIENTE, ''PITANGUEIRAS'') AS DES_CIDADE,   ');
     SQL.Add('       COALESCE(CLIENTES.UF, ''SP'') AS DES_SIGLA,   ');
     SQL.Add('       COALESCE(CLIENTES.CEPCLIENTE, ''14750000'') AS NUM_CEP,   ');
     SQL.Add('       COALESCE(CLIENTES.TELCLIENTE, '''') AS NUM_FONE,   ');
     SQL.Add('       '''' AS NUM_FAX,   ');
     SQL.Add('       '''' AS DES_CONTATO,   ');
     SQL.Add('          ');
     SQL.Add('       CASE CLIENTES.SEXO    ');
     SQL.Add('           WHEN ''F'' THEN 1   ');
     SQL.Add('           WHEN ''M'' THEN 0   ');
     SQL.Add('           ELSE 0   ');
     SQL.Add('       END AS FLG_SEXO,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(CLIENTES.LIMITECLIENTE, 0) AS VAL_LIMITE_CRETID,   ');
     SQL.Add('       0 AS VAL_LIMITE_CONV,   ');
     SQL.Add('       0 AS VAL_DEBITO,   ');
     SQL.Add('       0 AS VAL_RENDA,   ');
     SQL.Add('       COALESCE(CLIENTES.CODIGOCONVENIO, 0) AS COD_CONVENIO,   ');
     SQL.Add('       0 AS COD_STATUS_PDV,   ');
     SQL.Add('       ''N'' AS FLG_EMPRESA,   ');
     SQL.Add('       ''N'' AS FLG_CONVENIO,   ');
     SQL.Add('       ''N'' AS MICRO_EMPRESA,   ');
     SQL.Add('       '''' AS DTA_CADASTRO,   ');
     SQL.Add('       COALESCE(CLIENTES.NUMERO, ''S/N'') AS NUM_ENDERECO,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.RGCLIENTE, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_RG,   ');
     SQL.Add('       0 AS FLG_EST_CIVIL,   ');
     SQL.Add('       COALESCE(CLIENTES.CELCLIENTE, '''') AS NUM_CELULAR,   ');
     SQL.Add('       '''' AS DTA_ALTERACAO,   ');
     SQL.Add('       COALESCE(CLIENTES.OBS, '''') AS DES_OBSERVACAO,   ');
     SQL.Add('       '''' AS DES_COMPLEMENTO,   ');
     SQL.Add('       COALESCE(CLIENTES.EMAIL, '''') AS DES_EMAIL,   ');
     SQL.Add('       '''' AS DES_FANTASIA,   ');
     SQL.Add('       COALESCE(CLIENTES.DATANASCIMENTO, '''') AS DTA_NASCIMENTO,   ');
     SQL.Add('       '''' AS DES_PAI,   ');
     SQL.Add('       '''' AS DES_MAE,   ');
     SQL.Add('       '''' AS DES_CONJUGE,   ');
     SQL.Add('       '''' AS NUM_CPF_CONJUGE,   ');
     SQL.Add('       0 AS VAL_DEB_CONV,   ');
     SQL.Add('       ''N'' AS INATIVO,   ');
     SQL.Add('       '''' AS DES_MATRICULA,   ');
     SQL.Add('       ''N'' AS NUM_CGC_ASSOCIADO,   ');
     SQL.Add('       ''N'' AS FLG_PROD_RURAL,   ');
     SQL.Add('       CASE CLIENTES.SITUACAO WHEN ''CLIENTE BLOQUEADO'' THEN 1 ELSE 0 END AS COD_STATUS_PDV_CONV,   ');
     SQL.Add('       ''S'' AS FLG_ENVIA_CODIGO,   ');
     SQL.Add('       '''' AS DTA_NASC_CONJUGE,   ');
     SQL.Add('       0 AS COD_CLASSIF   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CC_CLIENTES AS CLIENTES   ');


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

procedure TFrmSmDourado.GerarCodigoBarras;
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
     SQL.Add('       PRODUTOS.CODPROD_PRODUTOS AS COD_PRODUTO,   ');
     SQL.Add('       CASE   ');
     SQL.Add('   		    WHEN LEN(PRODUTOS.CODBARRA_PRODUTOS) = 7 THEN PRODUTOS.CODPROD_PRODUTOS   ');
     SQL.Add('   		    ELSE PRODUTOS.CODBARRA_PRODUTOS   ');
     SQL.Add('   	   END AS COD_EAN   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');



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

procedure TFrmSmDourado.GerarComposicao;
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

procedure TFrmSmDourado.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CLIENTES.CODCLIENTE AS COD_CLIENTE,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       1 AS COD_ENTIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CC_CLIENTES AS CLIENTES   ');




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

procedure TFrmSmDourado.GerarCondPagForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDORES.CODIGO_FORNECEDORES AS COD_FORNECEDOR,   ');
     SQL.Add('       30 AS NUM_CONDICAO,   ');
     SQL.Add('       2 AS COD_CONDICAO,   ');
     SQL.Add('       8 AS COD_ENTIDADE,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_FORNECEDORES AS FORNECEDORES   ');



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

procedure TFrmSmDourado.GerarDecomposicao;
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

procedure TFrmSmDourado.GerarDivisaoForn;
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

procedure TFrmSmDourado.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));

  if Tipo = 3 then
    GerarFinanceiroReceberCartao;

end;

procedure TFrmSmDourado.GerarFinanceiroPagar(Aberto: String);
var
  NUM_DOCTO : string;
  COD_PARCEIRO : Integer;

begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;
    if Aberto = '1' then
    begin

       SQL.Add('   SELECT DISTINCT      ');
       SQL.Add('       1 AS TIPO_PARCEIRO,   ');
       SQL.Add('      ');
       SQL.Add('       CASE      ');
       SQL.Add('           WHEN PAGAR.CODFORNECEDOR = 0 THEN 66      ');
       SQL.Add('           ELSE PAGAR.CODFORNECEDOR       ');
       SQL.Add('       END AS COD_PARCEIRO,      ');
       SQL.Add('                   ');
       SQL.Add('       0 AS TIPO_CONTA,      ');
       SQL.Add('                       ');
       SQL.Add('       CASE      ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Dinheiro'' THEN 1      ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cheque'' THEN 2      ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cartao Visa'' THEN 6      ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cartao Master'' THEN 6      ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cheque pr�prio'' THEN 2      ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cheque terceiro'' THEN 2      ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Conta Banc�ria'' THEN 12      ');
       SQL.Add('           ELSE 1      ');
       SQL.Add('       END AS COD_ENTIDADE,      ');
       SQL.Add('                       ');
       SQL.Add('       CASE         ');
       SQL.Add('           WHEN PAGAR.NUMERO NOT BETWEEN ''001'' AND ''009'' AND LEN(PAGAR.NUMERO) > 3 THEN COALESCE(PAGAR.NUMERO, ''9999'')         ');
       SQL.Add('           WHEN PAGAR.NOTAFISCAL = '''' THEN CAST(PAGAR.CODIGO AS VARCHAR)         ');
       SQL.Add('           WHEN PAGAR.NOTAFISCAL IS NULL THEN CAST(PAGAR.CODIGO AS VARCHAR) ');
       SQL.Add('           WHEN PAGAR.CODFORNECEDOR = 0 THEN CAST(PAGAR.CODIGO AS VARCHAR)                         ');
       SQL.Add('           ELSE COALESCE({fn CONCAT({fn CONCAT(PAGAR.NOTAFISCAL, ''/'')}, CAST(PAGAR.PARCELA AS VARCHAR))}, CAST({fn CONCAT({fn CONCAT(PAGAR.NOTAFISCAL, ''/'')}, CAST(PAGAR.NUMERO AS VARCHAR))} AS VARCHAR))   ');
       SQL.Add('       END AS NUM_DOCTO,     ');
       SQL.Add('                       ');
       SQL.Add('       999 AS COD_BANCO,      ');
       SQL.Add('       '''' AS DES_BANCO,      ');
       SQL.Add('       PAGAR.DATAEMISSAO AS DTA_EMISSAO,      ');
       SQL.Add('       PAGAR.DATAVENCIMENTO AS DTA_VENCIMENTO,      ');
       SQL.Add('       PAGAR.VALOR AS VAL_PARCELA,      ');
       SQL.Add('       COALESCE(PAGAR.JUROS, 0) AS VAL_JUROS,      ');
       SQL.Add('       COALESCE(PAGAR.DESCONTOS, 0) AS VAL_DESCONTO,      ');
       SQL.Add('       ''N'' AS FLG_QUITADO,      ');
       SQL.Add('       '''' AS DTA_QUITADA,      ');
       SQL.Add('       998 AS COD_CATEGORIA,      ');
       SQL.Add('       998 AS COD_SUBCATEGORIA,      ');
       SQL.Add('                       ');
       SQL.Add('       CASE      ');
       SQL.Add('           WHEN PAGAR.NUMERO BETWEEN ''001'' AND ''009'' AND LEN(PAGAR.NUMERO) = 3 THEN PAGAR.NUMERO      ');
       SQL.Add('           ELSE COALESCE(PAGAR.PARCELA, ''1'')      ');
       SQL.Add('       END AS NUM_PARCELA,      ');
       SQL.Add('                       ');
       SQL.Add('       COALESCE(QUANTIDADE.QTD_PARCELA, 1) AS QTD_PARCELA,      ');
       SQL.Add('       PAGAR.CODEMPRESA AS COD_LOJA,      ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,      ');
       SQL.Add('       0 AS NUM_BORDERO,      ');
       SQL.Add('       CASE    ');
       SQL.Add('   				WHEN PAGAR.NOTAFISCAL = '''' THEN PAGAR.NUMERO   ');
       SQL.Add('   				WHEN PAGAR.NUMERO IS NULL THEN CAST(PAGAR.CODIGO AS VARCHAR)   ');
       SQL.Add('   				WHEN PAGAR.NUMERO = '''' AND PAGAR.NOTAFISCAL IS NULL  THEN CAST(PAGAR.CODIGO AS VARCHAR)   ');
       SQL.Add('   				WHEN PAGAR.CODFORNECEDOR = 0 THEN CAST(PAGAR.CODIGO AS VARCHAR)    ');
       SQL.Add('   				ELSE  COALESCE(PAGAR.NOTAFISCAL, PAGAR.NUMERO)    ');
       SQL.Add('   		 END AS NUM_NF,   ');
       SQL.Add('       COALESCE(PAGAR.SERIE, '''') AS NUM_SERIE_NF,      ');
       SQL.Add('   		 CASE   ');
       SQL.Add('   				WHEN COALESCE(QUANTIDADE.QTD_PARCELA, 1) = 1 THEN PAGAR.VALOR   ');
       SQL.Add('   				ELSE SOMA_TOTAL.VAL_TOTAL    ');
       SQL.Add('   		 END AS VAL_TOTAL_NF,    ');
       SQL.Add('       COALESCE(PAGAR.DESCRICAOCONTA, '''') AS DES_OBSERVACAO,      ');
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
       SQL.Add('       COALESCE(PAGAR.DATALANCAMENTO, '''') AS DTA_ENTRADA,      ');
       SQL.Add('       '''' AS NUM_NOSSO_NUMERO,      ');
       SQL.Add('       '''' AS COD_BARRA,      ');
       SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,      ');
       SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,      ');
       SQL.Add('       '''' AS DES_TITULAR,      ');
       SQL.Add('       30 AS NUM_CONDICAO,      ');
       SQL.Add('       0 AS VAL_CREDITO,      ');
       SQL.Add('       ''999'' AS COD_BANCO_PGTO,      ');
       SQL.Add('       ''PAGTO'' AS DES_CC,      ');
       SQL.Add('       0 AS COD_BANDEIRA,      ');
       SQL.Add('       '''' AS DTA_PRORROGACAO,      ');
       SQL.Add('       1 AS NUM_SEQ_FIN,      ');
       SQL.Add('       0 AS COD_COBRANCA,      ');
       SQL.Add('       '''' AS DTA_COBRANCA,      ');
       SQL.Add('       ''N'' AS FLG_ACEITE,      ');
       SQL.Add('       0 AS TIPO_ACEITE      ');
       SQL.Add('   FROM      ');
       SQL.Add('       CONTAS_PAGAR AS PAGAR      ');
       SQL.Add('   LEFT JOIN CONTROLE_ESTOQUE.DBO.CE_FORNECEDORES AS FORNECEDORES ON PAGAR.CODFORNECEDOR = FORNECEDORES.CODIGO_FORNECEDORES      ');
       SQL.Add('   LEFT JOIN      ');
       SQL.Add('       (      ');
       SQL.Add('           SELECT DISTINCT      ');
       SQL.Add('               CODFORNECEDOR AS COD_FORNECEDOR,      ');
       SQL.Add('               NOTAFISCAL AS NUM_DOCTO,    ');
       SQL.Add('               COUNT(NOTAFISCAL) AS QTD_PARCELA       ');
       SQL.Add('           FROM      ');
       SQL.Add('               CONTAS_PAGAR      ');
       //SQL.Add('           WHERE CODGRUPO = 1      ');
       //SQL.Add('           AND DATAPAGAMENTO IS NULL      ');
       SQL.Add('           GROUP BY      ');
       SQL.Add('               NOTAFISCAL, CODFORNECEDOR      ');
       SQL.Add('       ) AS QUANTIDADE      ');
       SQL.Add('   ON      ');
       SQL.Add('       PAGAR.CODFORNECEDOR = QUANTIDADE.COD_FORNECEDOR      ');
       SQL.Add('   AND      ');
       SQL.Add('       PAGAR.NOTAFISCAL = QUANTIDADE.NUM_DOCTO      ');
       SQL.Add('   LEFT JOIN      ');
       SQL.Add('       (      ');
       SQL.Add('           SELECT DISTINCT      ');
       SQL.Add('               CODFORNECEDOR AS COD_FORNECEDOR,      ');
       SQL.Add('               NOTAFISCAL AS NUM_DOCTO,      ');
       SQL.Add('               SUM(VALOR) AS VAL_TOTAL      ');
       SQL.Add('           FROM      ');
       SQL.Add('               CONTAS_PAGAR      ');
       //SQL.Add('           WHERE CODGRUPO = 1      ');
       //SQL.Add('           AND DATAPAGAMENTO IS NULL      ');
       SQL.Add('           GROUP BY      ');
       SQL.Add('               NOTAFISCAL, CODFORNECEDOR      ');
       SQL.Add('       ) AS SOMA_TOTAL      ');
       SQL.Add('   ON      ');
       SQL.Add('       PAGAR.CODFORNECEDOR = SOMA_TOTAL.COD_FORNECEDOR      ');
       SQL.Add('   AND      ');
       SQL.Add('       PAGAR.NOTAFISCAL = SOMA_TOTAL.NUM_DOCTO     ');
       SQL.Add('   WHERE PAGAR.DATAPAGAMENTO IS NULL      ');
      // SQL.Add('   AND PAGAR.CODGRUPO = 1       ');


//     SQL.Add('AND');

//     SQL.Add(' PAGARABERTO.VENCIMENTO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
//     SQL.Add('AND');
//     SQL.Add(' PAGARABERTO.VENCIMENTO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
    end
    else
    begin
    //QUITADO

       SQL.Add('   SELECT DISTINCT   ');
       SQL.Add('       1 AS TIPO_PARCEIRO,   ');
       SQL.Add('      ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PAGAR.CODFORNECEDOR = 0 THEN 66   ');
       SQL.Add('           ELSE PAGAR.CODFORNECEDOR    ');
       SQL.Add('       END AS COD_PARCEIRO,   ');
       SQL.Add('      ');
       SQL.Add('       0 AS TIPO_CONTA,   ');
       SQL.Add('          ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Dinheiro'' THEN 1   ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cheque'' THEN 2   ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cartao Visa'' THEN 6   ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cartao Master'' THEN 6   ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cheque pr�prio'' THEN 2   ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Cheque terceiro'' THEN 2   ');
       SQL.Add('           WHEN PAGAR.FORMABAIXA = ''Conta Banc�ria'' THEN 12   ');
       SQL.Add('           ELSE 1   ');
       SQL.Add('       END AS COD_ENTIDADE,   ');
       SQL.Add('          ');
       SQL.Add('       CASE         ');
       SQL.Add('           WHEN PAGAR.NUMERO NOT BETWEEN ''001'' AND ''009'' AND LEN(PAGAR.NUMERO) > 3 THEN COALESCE(PAGAR.NUMERO, ''9999'')         ');
       SQL.Add('           WHEN PAGAR.NOTAFISCAL = '''' THEN CAST(PAGAR.CODIGO AS VARCHAR)           ');
       SQL.Add('           WHEN PAGAR.NOTAFISCAL IS NULL THEN CAST(PAGAR.CODIGO AS VARCHAR) ');
       SQL.Add('           WHEN PAGAR.CODFORNECEDOR = 0 THEN CAST(PAGAR.CODIGO AS VARCHAR)                         ');
       SQL.Add('           ELSE COALESCE({fn CONCAT({fn CONCAT(PAGAR.NOTAFISCAL, ''/'')}, CAST(PAGAR.PARCELA AS VARCHAR))}, CAST({fn CONCAT({fn CONCAT(PAGAR.NOTAFISCAL, ''/'')}, CAST(PAGAR.NUMERO AS VARCHAR))} AS VARCHAR))   ');
       SQL.Add('       END AS NUM_DOCTO,     ');
       SQL.Add('          ');
       SQL.Add('       999 AS COD_BANCO,   ');
       SQL.Add('       '''' AS DES_BANCO,   ');
       SQL.Add('       PAGAR.DATAEMISSAO AS DTA_EMISSAO,   ');
       SQL.Add('       PAGAR.DATAVENCIMENTO AS DTA_VENCIMENTO,   ');
       SQL.Add('       PAGAR.VALOR AS VAL_PARCELA,   ');
       SQL.Add('       COALESCE(PAGAR.JUROS, 0) AS VAL_JUROS,   ');
       SQL.Add('       0 AS VAL_DESCONTO,   ');
       SQL.Add('       ''S'' AS FLG_QUITADO,   ');
       SQL.Add('       COALESCE(PAGAR.DATAPAGAMENTO, '''') AS DTA_QUITADA,   ');
       SQL.Add('       998 AS COD_CATEGORIA,   ');
       SQL.Add('       998 AS COD_SUBCATEGORIA,   ');
       SQL.Add('          ');
       SQL.Add('       CASE   ');
       SQL.Add('   		    WHEN PAGAR.NUMERO BETWEEN ''001'' AND ''009'' AND LEN(PAGAR.NUMERO) = 3 THEN PAGAR.NUMERO   ');
       SQL.Add('   		    ELSE COALESCE(PAGAR.PARCELA, ''1'')   ');
       SQL.Add('   	   END AS NUM_PARCELA,   ');
       SQL.Add('          ');
       SQL.Add('       COALESCE(QUANTIDADE.QTD_PARCELA, 1) AS QTD_PARCELA,   ');
       SQL.Add('       PAGAR.CODEMPRESA AS COD_LOJA,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('       0 AS NUM_BORDERO,   ');
       SQL.Add('       CASE    ');
       SQL.Add('   				WHEN PAGAR.NOTAFISCAL = '''' THEN PAGAR.NUMERO   ');
       SQL.Add('   				WHEN PAGAR.NUMERO IS NULL THEN CAST(PAGAR.CODIGO AS VARCHAR)   ');
       SQL.Add('   				WHEN PAGAR.NUMERO = '''' AND PAGAR.NOTAFISCAL IS NULL  THEN CAST(PAGAR.CODIGO AS VARCHAR)   ');
       SQL.Add('   				WHEN PAGAR.CODFORNECEDOR = 0 THEN CAST(PAGAR.CODIGO AS VARCHAR)    ');
       SQL.Add('   				ELSE  COALESCE(PAGAR.NOTAFISCAL, PAGAR.NUMERO)    ');
       SQL.Add('   			  END AS NUM_NF,   ');
       SQL.Add('       COALESCE(PAGAR.SERIE, '''') AS NUM_SERIE_NF,   ');
       SQL.Add('   		 CASE   ');
       SQL.Add('   				WHEN COALESCE(QUANTIDADE.QTD_PARCELA, 1) = 1 THEN PAGAR.VALOR   ');
       SQL.Add('   				ELSE SOMA_TOTAL.VAL_TOTAL    ');
       SQL.Add('   		 END AS VAL_TOTAL_NF,    ');
       SQL.Add('       COALESCE(PAGAR.DESCRICAOCONTA, '''') AS DES_OBSERVACAO,   ');
       SQL.Add('       0 AS NUM_PDV,   ');
       SQL.Add('       0 AS NUM_CUPOM_FISCAL,   ');
       SQL.Add('       0 AS COD_MOTIVO,   ');
       SQL.Add('       0 AS COD_CONVENIO,   ');
       SQL.Add('       0 AS COD_BIN,   ');
       SQL.Add('       '''' AS DES_BANDEIRA,   ');
       SQL.Add('       '''' AS DES_REDE_TEF,   ');
       SQL.Add('       0 AS VAL_RETENCAO,   ');
       SQL.Add('       0 AS COD_CONDICAO,   ');
       SQL.Add('       COALESCE(PAGAR.DATAPAGAMENTO, '''') AS DTA_PAGTO,   ');
       SQL.Add('       '''' AS DTA_ENTRADA,   ');
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
       SQL.Add('       CONTAS_PAGAR AS PAGAR   ');
       SQL.Add('   LEFT JOIN CONTROLE_ESTOQUE.DBO.CE_FORNECEDORES AS FORNECEDORES ON PAGAR.CODFORNECEDOR = FORNECEDORES.CODIGO_FORNECEDORES   ');
       SQL.Add('   LEFT JOIN   ');
       SQL.Add('       (   ');
       SQL.Add('           SELECT DISTINCT   ');
       SQL.Add('               CODFORNECEDOR AS COD_FORNECEDOR,      ');
       SQL.Add('               NOTAFISCAL AS NUM_DOCTO,    ');
       SQL.Add('               COUNT(NOTAFISCAL) AS QTD_PARCELA      ');
       SQL.Add('           FROM   ');
       SQL.Add('               CONTAS_PAGAR   ');
       //SQL.Add('           WHERE CODGRUPO = 1   ');
       //SQL.Add('           AND DATAPAGAMENTO IS NOT NULL   ');
       SQL.Add('           GROUP BY   ');
       SQL.Add('               NOTAFISCAL, CODFORNECEDOR   ');
       SQL.Add('       ) AS QUANTIDADE   ');
       SQL.Add('   ON   ');
       SQL.Add('       PAGAR.CODFORNECEDOR = QUANTIDADE.COD_FORNECEDOR   ');
       SQL.Add('   AND   ');
       SQL.Add('       PAGAR.NOTAFISCAL = QUANTIDADE.NUM_DOCTO   ');
       SQL.Add('   LEFT JOIN      ');
       SQL.Add('       (      ');
       SQL.Add('           SELECT DISTINCT      ');
       SQL.Add('               CODFORNECEDOR AS COD_FORNECEDOR,      ');
       SQL.Add('               NOTAFISCAL AS NUM_DOCTO,      ');
       SQL.Add('               SUM(VALOR) AS VAL_TOTAL      ');
       SQL.Add('           FROM      ');
       SQL.Add('               CONTAS_PAGAR      ');
       //SQL.Add('           WHERE CODGRUPO = 1      ');
       //SQL.Add('           AND DATAPAGAMENTO IS NOT NULL      ');
       SQL.Add('           GROUP BY      ');
       SQL.Add('               NOTAFISCAL, CODFORNECEDOR      ');
       SQL.Add('       ) AS SOMA_TOTAL      ');
       SQL.Add('   ON      ');
       SQL.Add('       PAGAR.CODFORNECEDOR = SOMA_TOTAL.COD_FORNECEDOR      ');
       SQL.Add('   AND      ');
       SQL.Add('       PAGAR.NOTAFISCAL = SOMA_TOTAL.NUM_DOCTO     ');
       SQL.Add('   WHERE PAGAR.DATAPAGAMENTO IS NOT NULL   ');
       //SQL.Add('   AND PAGAR.CODGRUPO = 1 -- grupo de fornecedores   ');


     
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
      //Layout.FieldByName('NUM_CUPOM_FISCAL').AsString := StrRetNums(QryPrincipal2.FieldByName('NUM_CUPOM_FISCAL').AsString);

      //Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);
      Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);
      //Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);


        if QryPrincipal2.FieldByName('DTA_QUITADA').AsString <> '' then
          Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_PAGTO').AsString <> '' then
          Layout.FieldByName('DTA_PAGTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_PAGTO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_EMISSAO').AsString <> '' then
          Layout.FieldByName('DTA_EMISSAO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);

        //if QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsString <> '' then
          //Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_ENTRADA').AsString <> '' then
          Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime);

        if Layout.FieldByName('NUM_NF').AsString = '' then
        begin
          Layout.FieldByName('NUM_NF').AsString := Layout.FieldByName('NUM_DOCTO').AsString;
        end;

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

procedure TFrmSmDourado.GerarFinanceiroReceber(Aberto: String);
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
       SQL.Add('   SELECT DISTINCT      ');
       SQL.Add('       0 AS TIPO_PARCEIRO,      ');
       SQL.Add('       RECEBER_ABERTO.CODCLIENTE AS COD_PARCEIRO,      ');
       SQL.Add('       1 AS TIPO_CONTA,      ');
       SQL.Add('                     ');
       SQL.Add('       CASE      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Alimentacao'' THEN 7      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Amex Debito'' THEN 7      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Brasil Card'' THEN 6      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Credito'' THEN  6      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Debito'' THEN 7      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Fidelidade'' THEN 11       ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cheque'' THEN 3      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Devolu��o'' THEN 13      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Dinheiro'' THEN 1      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Ticket'' THEN 7      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Vale'' THEN 4      ');
       SQL.Add('           ELSE 1      ');
       SQL.Add('       END AS COD_ENTIDADE,       ');
       SQL.Add('      ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN RECEBER_ABERTO.DATAPAGAMENTO IS NOT NULL THEN {fn CONCAT(''PA'', CAST(RECEBER_ABERTO.CODIGO  AS VARCHAR))}   ');
       SQL.Add('           ELSE CAST(RECEBER_ABERTO.CODIGO AS VARCHAR)   ');
       SQL.Add('       END AS NUM_DOCTO,     ');
       SQL.Add('      ');
       SQL.Add('       999 AS COD_BANCO,      ');
       SQL.Add('       '''' AS DES_BANCO,      ');
       SQL.Add('       COALESCE(RECEBER_ABERTO.DATA, '''') AS DTA_EMISSAO,      ');
       SQL.Add('       COALESCE(RECEBER_ABERTO.DATAVENCIMENTO, '''') AS DTA_VENCIMENTO,      ');
       SQL.Add('       ABERTO.VALORRESTANTE AS VAL_PARCELA,      ');
       SQL.Add('       COALESCE(RECEBER_ABERTO.JUROS, 0) AS VAL_JUROS,      ');
       SQL.Add('       0 AS VAL_DESCONTO,      ');
       SQL.Add('       ''N'' AS FLG_QUITADO,      ');
       SQL.Add('       '''' AS DTA_QUITADA,      ');
       SQL.Add('       998 AS COD_CATEGORIA,      ');
       SQL.Add('       998 AS COD_SUBCATEGORIA,      ');
       SQL.Add('       1 AS NUM_PARCELA,      ');
       SQL.Add('       1 AS QTD_PARCELA,      ');
       SQL.Add('       RECEBER_ABERTO.CODEMPRESA AS COD_LOJA,      ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CPFCLIENTE, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
       SQL.Add('       0 AS NUM_BORDERO,      ');
       SQL.Add('       RECEBER_ABERTO.CODIGO AS NUM_NF,      ');
       SQL.Add('       '''' AS NUM_SERIE_NF,      ');
       SQL.Add('       ABERTO.VALOR AS VAL_TOTAL_NF,      ');
       SQL.Add('       '''' AS DES_OBSERVACAO,      ');
       SQL.Add('       RECEBER_ABERTO.NUMEROCAIXA AS NUM_PDV,      ');
       SQL.Add('       0 AS NUM_CUPOM_FISCAL,      ');
       SQL.Add('       0 AS COD_MOTIVO,      ');
       SQL.Add('       0 AS COD_CONVENIO,      ');
       SQL.Add('       0 AS COD_BIN,      ');
       SQL.Add('       CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO AS DES_BANDEIRA,      ');
       SQL.Add('       '''' AS DES_REDE_TEF,      ');
       SQL.Add('       0 AS VAL_RETENCAO,      ');
       SQL.Add('       0 AS COD_CONDICAO,      ');
       SQL.Add('       '''' AS DTA_PAGTO,      ');
       SQL.Add('       COALESCE(RECEBER_ABERTO.DATA, '''') AS DTA_ENTRADA,      ');
       SQL.Add('       '''' AS NUM_NOSSO_NUMERO,      ');
       SQL.Add('       '''' AS COD_BARRA,      ');
       SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,      ');
       SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,      ');
       SQL.Add('       '''' AS DES_TITULAR,      ');
       SQL.Add('       30 AS NUM_CONDICAO,      ');
       SQL.Add('       0 AS VAL_CREDITO,      ');
       SQL.Add('       ''999'' AS COD_BANCO_PGTO,      ');
       SQL.Add('       ''RECEBTO'' AS DES_CC,    ');
       SQL.Add('      ');
       SQL.Add('       CASE      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO = ''Cartao de Debito a Vista'' THEN 7      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO = ''Cartao Voucher a Vista'' THEN 7      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO = ''Cartao de Credito a Vista'' THEN 6      ');
       SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO = ''Cartao de Credito Parcelado Estabelecimento'' THEN 6      ');
       SQL.Add('           ELSE 0      ');
       SQL.Add('       END AS COD_BANDEIRA,      ');
       SQL.Add('                     ');
       SQL.Add('       '''' AS DTA_PRORROGACAO,      ');
       SQL.Add('       1 AS NUM_SEQ_FIN,      ');
       SQL.Add('       0 AS COD_COBRANCA,      ');
       SQL.Add('       '''' AS DTA_COBRANCA,      ');
       SQL.Add('       ''N'' AS FLG_ACEITE,      ');
       SQL.Add('       0 AS TIPO_ACEITE      ');
       SQL.Add('   FROM      ');
       SQL.Add('       PARCELASCREDIARIO AS RECEBER_ABERTO    ');
       SQL.Add('   LEFT JOIN (   ');
       SQL.Add('       SELECT   ');
       SQL.Add('           CODIGO,   ');
       SQL.Add('           VALOR,   ');
       SQL.Add('           ValorRestante   ');
       SQL.Add('       FROM   ');
       SQL.Add('           PARCELASCREDIARIO   ');
       SQL.Add('       WHERE ValorRestante > 0   ');
       SQL.Add('   ) AS ABERTO   ');
       SQL.Add('   ON RECEBER_ABERTO.CODIGO = ABERTO.CODIGO     ');
       SQL.Add('   LEFT JOIN CE_RECEBIMENTOSCAIXA ON CE_RECEBIMENTOSCAIXA.CODCLIENTE = RECEBER_ABERTO.CODCLIENTE      ');
       SQL.Add('   LEFT JOIN CONTROLE_CLIENTES.DBO.CC_CLIENTES AS CLIENTES ON RECEBER_ABERTO.CODCLIENTE = CLIENTES.CODCLIENTE      ');
       SQL.Add('   WHERE RECEBER_ABERTO.CODEMPRESA = 1      ');
       SQL.Add('   AND RECEBER_ABERTO.CODCLIENTE <> 0      ');
       SQL.Add('   AND RECEBER_ABERTO.CODCLIENTE IS NOT NULL      ');
       SQL.Add('   AND CE_RECEBIMENTOSCAIXA.DESCRICAO IN (''VALE'', ''CHEQUE'')      ');
       SQL.Add('   AND RECEBER_ABERTO.VALOR <> RECEBER_ABERTO.VALORPAGAMENTO   ');
//     SQL.Add('   CAST(RECEBER_ABERTO.DATA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
//     SQL.Add('   AND');
//     SQL.Add('   CAST(RECEBER_ABERTO.DATA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
    end
    else
    begin
    //QUITADO
         SQL.Add('   SELECT DISTINCT      ');
         SQL.Add('       0 AS TIPO_PARCEIRO,      ');
         SQL.Add('       RECEBER_QUITADO.CODCLIENTE AS COD_PARCEIRO,      ');
         SQL.Add('       1 AS TIPO_CONTA,      ');
         SQL.Add('                       ');
         SQL.Add('       CASE      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Alimentacao'' THEN 7      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Amex Debito'' THEN 7      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Brasil Card'' THEN 6      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Credito'' THEN  6      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Debito'' THEN 7      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cartao Fidelidade'' THEN 11       ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Cheque'' THEN 3      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Devolu��o'' THEN 13      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Dinheiro'' THEN 1      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Ticket'' THEN 7      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.DESCRICAO = ''Vale'' THEN 4      ');
         SQL.Add('           ELSE 1      ');
         SQL.Add('       END AS COD_ENTIDADE,      ');
         SQL.Add('                                        ');
         SQL.Add('       CASE   ');
         SQL.Add('           WHEN RECEBER_QUITADO.VALOR <> RECEBER_QUITADO.VALORPAGAMENTO THEN {fn CONCAT(''PG'', CAST(RECEBER_QUITADO.CODIGO  AS VARCHAR))}   ');
         SQL.Add('           ELSE CAST(RECEBER_QUITADO.CODIGO AS varchar)   ');
         SQL.Add('       END AS NUM_DOCTO,   ');
         SQL.Add('      ');
         SQL.Add('       999 AS COD_BANCO,      ');
         SQL.Add('       '''' AS DES_BANCO,      ');
         SQL.Add('       COALESCE(RECEBER_QUITADO.DATA, '''') AS DTA_EMISSAO,      ');
         SQL.Add('       COALESCE(RECEBER_QUITADO.DATAVENCIMENTO, '''') AS DTA_VENCIMENTO,      ');
         SQL.Add('       QUITADO.VALORPAGAMENTO AS VAL_PARCELA,      ');
         SQL.Add('       COALESCE(RECEBER_QUITADO.JUROS, 0) AS VAL_JUROS,      ');
         SQL.Add('       0 AS VAL_DESCONTO,      ');
         SQL.Add('       ''S'' AS FLG_QUITADO,      ');
         SQL.Add('       COALESCE(RECEBER_QUITADO.DATAPAGAMENTO, '''') AS DTA_QUITADA,      ');
         SQL.Add('       998 AS COD_CATEGORIA,      ');
         SQL.Add('       998 AS COD_SUBCATEGORIA,      ');
         SQL.Add('       1 AS NUM_PARCELA,      ');
         SQL.Add('       1 AS QTD_PARCELA,      ');
         SQL.Add('       RECEBER_QUITADO.CODEMPRESA AS COD_LOJA,      ');
         SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CPFCLIENTE, ''-'', ''''), ''.'', ''''), ''/'', ''''), '''') AS NUM_CGC,      ');
         SQL.Add('       0 AS NUM_BORDERO,      ');
         SQL.Add('       RECEBER_QUITADO.CODIGO AS NUM_NF,      ');
         SQL.Add('       '''' AS NUM_SERIE_NF,      ');
         SQL.Add('       QUITADO.VALOR AS VAL_TOTAL_NF,      ');
         SQL.Add('       '''' AS DES_OBSERVACAO,      ');
         SQL.Add('       RECEBER_QUITADO.NUMEROCAIXA AS NUM_PDV,      ');
         SQL.Add('       0 AS NUM_CUPOM_FISCAL,      ');
         SQL.Add('       0 AS COD_MOTIVO,      ');
         SQL.Add('       0 AS COD_CONVENIO,      ');
         SQL.Add('       0 AS COD_BIN,      ');
         SQL.Add('       CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO AS DES_BANDEIRA,      ');
         SQL.Add('       '''' AS DES_REDE_TEF,      ');
         SQL.Add('       0 AS VAL_RETENCAO,      ');
         SQL.Add('       0 AS COD_CONDICAO,      ');
         SQL.Add('       COALESCE(RECEBER_QUITADO.DATAPAGAMENTO, '''') AS DTA_PAGTO,      ');
         SQL.Add('       COALESCE(RECEBER_QUITADO.DATA, '''') AS DTA_ENTRADA,      ');
         SQL.Add('       '''' AS NUM_NOSSO_NUMERO,      ');
         SQL.Add('       '''' AS COD_BARRA,      ');
         SQL.Add('       ''N'' AS FLG_BOLETO_EMIT,      ');
         SQL.Add('       '''' AS NUM_CGC_CPF_TITULAR,      ');
         SQL.Add('       '''' AS DES_TITULAR,      ');
         SQL.Add('       30 AS NUM_CONDICAO,      ');
         SQL.Add('       0 AS VAL_CREDITO,      ');
         SQL.Add('       ''999'' AS COD_BANCO_PGTO,      ');
         SQL.Add('       ''RECEBTO'' AS DES_CC,      ');
         SQL.Add('          ');
         SQL.Add('       CASE      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO = ''Cartao de Debito a Vista'' THEN 7      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO = ''Cartao Voucher a Vista'' THEN 7      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO = ''Cartao de Credito a Vista'' THEN 6      ');
         SQL.Add('           WHEN CE_RECEBIMENTOSCAIXA.TEFDESCPAGAMENTO = ''Cartao de Credito Parcelado Estabelecimento'' THEN 6      ');
         SQL.Add('           ELSE 0      ');
         SQL.Add('       END AS COD_BANDEIRA,      ');
         SQL.Add('                       ');
         SQL.Add('       '''' AS DTA_PRORROGACAO,      ');
         SQL.Add('       1 AS NUM_SEQ_FIN,      ');
         SQL.Add('       0 AS COD_COBRANCA,      ');
         SQL.Add('       '''' AS DTA_COBRANCA,      ');
         SQL.Add('       ''N'' AS FLG_ACEITE,      ');
         SQL.Add('       0 AS TIPO_ACEITE      ');
         SQL.Add('   FROM      ');
         SQL.Add('       PARCELASCREDIARIO AS RECEBER_QUITADO      ');
         SQL.Add('   LEFT JOIN (   ');
         SQL.Add('       SELECT   ');
         SQL.Add('           CODIGO,   ');
         SQL.Add('           VALOR,   ');
         SQL.Add('           ValorPagamento   ');
         SQL.Add('       FROM   ');
         SQL.Add('           PARCELASCREDIARIO   ');
         SQL.Add('       WHERE ValorPagamento > 0   ');
         SQL.Add('   ) AS QUITADO   ');
         SQL.Add('   ON RECEBER_QUITADO.CODIGO = QUITADO.CODIGO   ');
         SQL.Add('   LEFT JOIN CE_RECEBIMENTOSCAIXA ON CE_RECEBIMENTOSCAIXA.CODCLIENTE = RECEBER_QUITADO.CODCLIENTE      ');
         SQL.Add('   LEFT JOIN CONTROLE_CLIENTES.DBO.CC_CLIENTES AS CLIENTES ON RECEBER_QUITADO.CODCLIENTE = CLIENTES.CODCLIENTE      ');
         SQL.Add('   WHERE RECEBER_QUITADO.CODEMPRESA = 1      ');
         SQL.Add('   AND RECEBER_QUITADO.CODCLIENTE <> 0      ');
         SQL.Add('   AND RECEBER_QUITADO.CODCLIENTE IS NOT NULL      ');
         SQL.Add('   AND CE_RECEBIMENTOSCAIXA.DESCRICAO IN (''VALE'', ''CHEQUE'')      ');
         SQL.Add('   AND RECEBER_QUITADO.VALORPAGAMENTO > 0   ');
//       SQL.Add('   CAST(RECEBER_QUITADO.DATA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
//       SQL.Add('   AND');
//       SQL.Add('   CAST(RECEBER_QUITADO.DATA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

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

        //if QryPrincipal2.FieldByName('DTA_ENTRADA').AsString <> '' then
          //Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime);

      Layout.WriteLine;
    except
      On E: Exception do
      FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
    end;
    Next;
    end;
  end;
end;

procedure TFrmSmDourado.GerarFinanceiroReceberCartao;
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

procedure TFrmSmDourado.GerarFornecedor;
var
   observacao, email, inscEst : string;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       FORNECEDORES.CODIGO_FORNECEDORES AS COD_FORNECEDOR,   ');
     SQL.Add('       FORNECEDORES.RAZAO_FORNECEDORES AS DES_FORNECEDOR,   ');
     SQL.Add('       COALESCE(FORNECEDORES.NOMEFANTASIA, '''') AS DES_FANTASIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       COALESCE(FORNECEDORES.IE_FORNECEDORES, ''ISENTO'') AS NUM_INSC_EST,   ');
     SQL.Add('       COALESCE(FORNECEDORES.ENDERECO_FORNECEDORES, ''A DEFINIR'') AS DES_ENDERECO,   ');
     SQL.Add('       COALESCE(FORNECEDORES.BAIRRO_FORNECEDORES, ''A DEFINIR'') AS DES_BAIRRO,   ');
     SQL.Add('       COALESCE(FORNECEDORES.CIDADE_FORNECEDORES, '''') AS DES_CIDADE,   ');
     SQL.Add('       COALESCE(FORNECEDORES.UF_FORNECEDORES, '''') AS DES_SIGLA,   ');
     SQL.Add('       COALESCE(FORNECEDORES.CEP_FORNECEDORES, '''') AS NUM_CEP,   ');
     SQL.Add('       '''' AS NUM_FONE,   ');
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
     SQL.Add('       FORNECEDORES.CODIGO_FORNECEDORES AS COD_FORNECEDOR_ANT,   ');
     SQL.Add('       COALESCE(FORNECEDORES.NUMERO, ''S/N'') AS NUM_ENDERECO,   ');
     SQL.Add('       '''' AS DES_OBSERVACAO,   ');
     SQL.Add('       COALESCE(FORNECEDORES.EMAIL1, '''') AS DES_EMAIL,   ');
     SQL.Add('       '''' AS DES_WEB_SITE,   ');
     SQL.Add('       ''N'' AS FABRICANTE,   ');
     SQL.Add('       ''N'' AS FLG_PRODUTOR_RURAL,   ');
     SQL.Add('       0 AS TIPO_FRETE,   ');
     SQL.Add('       ''N'' AS FLG_SIMPLES,   ');
     SQL.Add('       ''N'' AS FLG_SUBSTITUTO_TRIB,   ');
     SQL.Add('       0 AS COD_CONTACCFORN,   ');
     SQL.Add('       ''N'' AS INATIVO,   ');
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
     SQL.Add('       CE_FORNECEDORES AS FORNECEDORES   ');




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

procedure TFrmSmDourado.GerarGrupo;
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
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');


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

procedure TFrmSmDourado.GerarInfoNutricionais;
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

procedure TFrmSmDourado.GerarNCM;
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
     SQL.Add('       COALESCE(PRODUTOS.NCM_PRODUTOS, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''0.00'' AND PRODUTOS.ALIQUOTACOFINS = ''0.00'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS IS NULL AND PRODUTOS.ALIQUOTACOFINS IS NULL THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''1.65'' AND PRODUTOS.ALIQUOTACOFINS = ''7.60'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''7.60'' AND PRODUTOS.ALIQUOTACOFINS = ''1.65'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''    ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''0.00'' AND PRODUTOS.ALIQUOTACOFINS = ''0.00'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS IS NULL AND PRODUTOS.ALIQUOTACOFINS IS NULL THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''1.65'' AND PRODUTOS.ALIQUOTACOFINS = ''7.60'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''7.60'' AND PRODUTOS.ALIQUOTACOFINS = ''1.65'' THEN -1   ');
     SQL.Add('           ELSE -1    ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,       ');
     SQL.Add('          ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CEST = '''' THEN ''99999999''    ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''5'' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''.'' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''2,89'' THEN ''99999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.CEST, ''99999999'')    ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       ''SP'' AS DES_SIGLA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(PRODUTOS.IVA, 0) AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');
     SQL.Add('   ORDER BY   ');
     SQL.Add('       NUM_NCM,   ');
     SQL.Add('       FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       COD_TAB_SPED,   ');
     SQL.Add('       COD_TRIB_ENTRADA,   ');
     SQL.Add('       COD_TRIB_SAIDA   ');
     SQL.Add('      ');





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

procedure TFrmSmDourado.GerarNCMUF;
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
     SQL.Add('       COALESCE(PRODUTOS.NCM_PRODUTOS, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''0.00'' AND PRODUTOS.ALIQUOTACOFINS = ''0.00'' THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS IS NULL AND PRODUTOS.ALIQUOTACOFINS IS NULL THEN ''S''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''1.65'' AND PRODUTOS.ALIQUOTACOFINS = ''7.60'' THEN ''N''   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''7.60'' AND PRODUTOS.ALIQUOTACOFINS = ''1.65'' THEN ''N''   ');
     SQL.Add('           ELSE ''N''    ');
     SQL.Add('       END AS FLG_NAO_PIS_COFINS,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''0.00'' AND PRODUTOS.ALIQUOTACOFINS = ''0.00'' THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS IS NULL AND PRODUTOS.ALIQUOTACOFINS IS NULL THEN 0   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''1.65'' AND PRODUTOS.ALIQUOTACOFINS = ''7.60'' THEN -1   ');
     SQL.Add('           WHEN PRODUTOS.ALIQUOTAPIS = ''7.60'' AND PRODUTOS.ALIQUOTACOFINS = ''1.65'' THEN -1   ');
     SQL.Add('           ELSE -1    ');
     SQL.Add('       END AS TIPO_NAO_PIS_COFINS,       ');
     SQL.Add('          ');
     SQL.Add('       999 AS COD_TAB_SPED,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CEST = '''' THEN ''99999999''    ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''5'' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''.'' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''2,89'' THEN ''99999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.CEST, ''99999999'')    ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('          ');
     SQL.Add('       ''SP'' AS DES_SIGLA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIB_SAIDA,   ');
     SQL.Add('          ');
     SQL.Add('       COALESCE(PRODUTOS.IVA, 0) AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');
     SQL.Add('   ORDER BY   ');
     SQL.Add('       NUM_NCM,   ');
     SQL.Add('       FLG_NAO_PIS_COFINS,   ');
     SQL.Add('       TIPO_NAO_PIS_COFINS,   ');
     SQL.Add('       COD_TAB_SPED,   ');
     SQL.Add('       COD_TRIB_ENTRADA,   ');
     SQL.Add('       COD_TRIB_SAIDA   ');
     SQL.Add('      ');






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

procedure TFrmSmDourado.GerarNFClientes;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

       SQL.Add('   SELECT   ');
       SQL.Add('       CASE   ');
       SQL.Add('   		    WHEN EMI_DEV.NUMERONOTA = 15 THEN 105   ');
       SQL.Add('   		    WHEN EMI_DEV.CODIGOFORNECEDOR = 1 THEN 66   ');
       SQL.Add('   		    WHEN EMI_DEV.CODIGOFORNECEDOR = 51 THEN 106   ');
       SQL.Add('   		    WHEN EMI_DEV.CODIGOFORNECEDOR = 62 THEN 107   ');
       SQL.Add('   		    WHEN EMI_DEV.CODIGOFORNECEDOR = 102 THEN 108   ');
       SQL.Add('   		    ELSE EMI_DEV.CODIGOFORNECEDOR   ');
       SQL.Add('   	   END AS COD_CLIENTE,   ');
       SQL.Add('       EMI_DEV.NUMERONOTA AS NUM_NF_CLI,   ');
       SQL.Add('       EMI_DEV.SERIE AS NUM_SERIE_NF,   ');
       SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
       SQL.Add('       EMI_DEV.CODIGOOPERACAO AS CFOP,   ');
       SQL.Add('          ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN EMI_DEV.CODIGOOPERACAO = 1202 THEN 2   ');
       SQL.Add('           ELSE 0   ');
       SQL.Add('       END AS TIPO_NF,   ');
       SQL.Add('          ');
       SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
       SQL.Add('       EMI_DEV.VALORNOTA AS VAL_TOTAL_NF,   ');
       SQL.Add('       EMI_DEV.DATAEMISSAO AS DTA_EMISSAO,   ');
       SQL.Add('       EMI_DEV.DATAEMISSAO AS DTA_ENTRADA,   ');
       SQL.Add('       EMI_DEV.VALORIPI AS VAL_TOTAL_IPI,   ');
       SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
       SQL.Add('       EMI_DEV.VALORFRETE AS VAL_FRETE,   ');
       SQL.Add('       0 AS VAL_ACRESCIMO,   ');
       SQL.Add('       EMI_DEV.VALORDESCONTO AS VAL_DESCONTO,   ');
       SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CPFCLIENTE, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
       SQL.Add('       EMI_DEV.BASEICMS AS VAL_TOTAL_BC,   ');
       SQL.Add('       EMI_DEV.VALORICMS AS VAL_TOTAL_ICMS,   ');
       SQL.Add('       EMI_DEV.BASEICMSSUBST AS VAL_BC_SUBST,   ');
       SQL.Add('       EMI_DEV.VALORICMSSUBST AS VAL_ICMS_SUBST,   ');
       SQL.Add('       0 AS VAL_FUNRURAL,   ');
       SQL.Add('          ');
       SQL.Add('       CASE   ');
       SQL.Add('           WHEN EMI_DEV.CODIGOOPERACAO = 5102 THEN 8   ');
       SQL.Add('           WHEN EMI_DEV.CODIGOOPERACAO = 5929 THEN 7   ');
       SQL.Add('           WHEN EMI_DEV.CODIGOOPERACAO = 5927 THEN 41   ');
       SQL.Add('           WHEN EMI_DEV.CODIGOOPERACAO = 1202 THEN 16   ');
       SQL.Add('       END AS COD_PERFIL,   ');
       SQL.Add('          ');
       SQL.Add('       0 AS VAL_DESP_ACESS,   ');
       SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
       SQL.Add('       '''' AS DES_OBSERVACAO,   ');
       SQL.Add('       EMI_DEV.CHAVEACESSO AS NUM_CHAVE_ACESSO   ');
       SQL.Add('   FROM   ');
       SQL.Add('       CE_NOTASFISCAISSAIDA AS EMI_DEV   ');
       SQL.Add('   LEFT JOIN CONTROLE_CLIENTES.DBO.CC_CLIENTES AS CLIENTES ON CLIENTES.CODCLIENTE = EMI_DEV.CODIGOFORNECEDOR   ');
       SQL.Add('   WHERE EMI_DEV.CODIGOOPERACAO IN (5102, 5929, 5927, 1202)   ');
       SQL.Add('   ORDER BY EMI_DEV.NUMERONOTA, EMI_DEV.CODIGOFORNECEDOR, EMI_DEV.SERIE   ');

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

procedure TFrmSmDourado.GerarNFFornec;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    // ENTRADA

//   SQL.Add('   SELECT   ');
//   SQL.Add('       FORNECEDORES.CODIGO_FORNECEDORES AS COD_FORNECEDOR,   ');
//   SQL.Add('       NF_ENTRADA.IDE_NNF AS NUM_NF_FORN,   ');
//   SQL.Add('       NF_ENTRADA.IDE_SERIE AS NUM_SERIE_NF,   ');
//   SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
//   SQL.Add('       NF_ENTRADA.IDE_CFOP AS CFOP,   ');
//   SQL.Add('       0 AS TIPO_NF,   ');
//   SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
//   SQL.Add('       NF_ENTRADA.TOTAL_VNF AS VAL_TOTAL_NF,   ');
//   SQL.Add('       NF_ENTRADA.IDE_DEMI AS DTA_EMISSAO,   ');
//   SQL.Add('       NF_ENTRADA.DATALANCAMENTO AS DTA_ENTRADA,   ');
//   SQL.Add('       NF_ENTRADA.TOTAL_VIPI AS VAL_TOTAL_IPI,   ');
//   SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
//   SQL.Add('       NF_ENTRADA.TOTAL_VFRETE AS VAL_FRETE,   ');
//   SQL.Add('       0 AS VAL_ACRESCIMO,   ');
//   SQL.Add('       NF_ENTRADA.TOTAL_VDESC AS VAL_DESCONTO,   ');
//   SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(NF_ENTRADA.DESTEMIT_CNPJCPF , ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
//   SQL.Add('       NF_ENTRADA.TOTAL_VBC AS VAL_TOTAL_BC,   ');
//   SQL.Add('       NF_ENTRADA.TOTAL_VICMS AS VAL_TOTAL_ICMS,   ');
//   SQL.Add('       NF_ENTRADA.TOTAL_VBCST AS VAL_BC_SUBST,   ');
//   SQL.Add('       NF_ENTRADA.TOTAL_VST AS VAL_ICMS_SUBST,   ');
//   SQL.Add('       0 AS VAL_FUNRURAL,   ');
//   SQL.Add('       1 AS COD_PERFIL,   ');
//   SQL.Add('       0 AS VAL_DESP_ACESS,   ');
//   SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
//   SQL.Add('       '''' AS DES_OBSERVACAO,   ');
//   SQL.Add('       NF_ENTRADA.IDE_CHNFE AS NUM_CHAVE_ACESSO   ');
//   SQL.Add('   FROM   ');
//   SQL.Add('       NOTASXML AS NF_ENTRADA   ');
//   SQL.Add('   LEFT JOIN CONTROLE_ESTOQUE.DBO.CE_FORNECEDORES AS FORNECEDORES ON REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES,  ''.'', ''''), ''/'', ''''), ''-'', '''') = REPLACE(REPLACE(REPLACE(NF_ENTRADA.DESTEMIT_CNPJCPF , ''.'', ''''), ''/'', ''''), ''-'', '''')   ');
//   //SQL.Add('   --WHERE NF_ENTRADA.IDE_NNF = 3202140   ');

    // DEVOLU��O


   SQL.Add('   SELECT   ');
   SQL.Add('       CAPA_DEVOLUCAO.CODIGOFORNECEDOR AS COD_FORNECEDOR,   ');
   SQL.Add('       CAPA_DEVOLUCAO.NUMERONOTA AS NUM_NF_FORN,   ');
   SQL.Add('       CAPA_DEVOLUCAO.SERIE AS NUM_SERIE_NF,   ');
   SQL.Add('       '''' AS NUM_SUBSERIE_NF,   ');
   SQL.Add('       CAPA_DEVOLUCAO.CODIGOOPERACAO AS CFOP,   ');
   SQL.Add('       2 AS TIPO_NF,   ');
   SQL.Add('       ''NFE'' AS DES_ESPECIE,   ');
   SQL.Add('       CAPA_DEVOLUCAO.VALORNOTA AS VAL_TOTAL_NF,   ');
   SQL.Add('       CAPA_DEVOLUCAO.DATAEMISSAO AS DTA_EMISSAO,   ');
   SQL.Add('       CAPA_DEVOLUCAO.DATAEMISSAO AS DTA_ENTRADA,   ');
   SQL.Add('       CAPA_DEVOLUCAO.VALORIPI AS VAL_TOTAL_IPI,   ');
   SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
   SQL.Add('       CAPA_DEVOLUCAO.VALORFRETE AS VAL_FRETE,   ');
   SQL.Add('       0 AS VAL_ACRESCIMO,   ');
   SQL.Add('       CAPA_DEVOLUCAO.VALORDESCONTO AS VAL_DESCONTO,   ');
   SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
   SQL.Add('       CAPA_DEVOLUCAO.BASEICMS AS VAL_TOTAL_BC,   ');
   SQL.Add('       CAPA_DEVOLUCAO.VALORICMS AS VAL_TOTAL_ICMS,   ');
   SQL.Add('       CAPA_DEVOLUCAO.BASEICMSSUBST AS VAL_BC_SUBST,   ');
   SQL.Add('       CAPA_DEVOLUCAO.VALORICMSSUBST AS VAL_ICMS_SUBST,   ');
   SQL.Add('       0 AS VAL_FUNRURAL,   ');
   SQL.Add('       6 AS COD_PERFIL,   ');
   SQL.Add('       0 AS VAL_DESP_ACESS,   ');
   SQL.Add('       ''N'' AS FLG_CANCELADO,   ');
   SQL.Add('       '''' AS DES_OBSERVACAO,   ');
   SQL.Add('       CAPA_DEVOLUCAO.CHAVEACESSO AS NUM_CHAVE_ACESSO   ');
   SQL.Add('   FROM   ');
   SQL.Add('       CE_NOTASFISCAISSAIDA AS CAPA_DEVOLUCAO   ');
   SQL.Add('   LEFT JOIN CONTROLE_ESTOQUE.DBO.CE_FORNECEDORES AS FORNECEDORES ON FORNECEDORES.CODIGO_FORNECEDORES = CAPA_DEVOLUCAO.CODIGOFORNECEDOR   ');
   //SQL.Add('   WHERE CAPA_DEVOLUCAO.TIPONOTA = 1   ') ;
   SQL.Add('   WHERE CAPA_DEVOLUCAO.NUMERONOTA IN (38, 40)  ');
   SQL.Add('AND');
   SQL.Add(' CAPA_DEVOLUCAO.DATAEMISSAO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
   SQL.Add('AND');
   SQL.Add(' CAPA_DEVOLUCAO.DATAEMISSAO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
   SQL.Add('   ORDER BY CAPA_DEVOLUCAO.NUMERONOTA, CAPA_DEVOLUCAO.CODIGOFORNECEDOR, CAPA_DEVOLUCAO.SERIE   ');

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

procedure TFrmSmDourado.GerarNFitensClientes;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       CASE   ');
     SQL.Add('   		     WHEN CAPA_DEVOLUCAO.NUMERONOTA = 15 THEN 105   ');
     SQL.Add('   		     WHEN CAPA_DEVOLUCAO.CODIGOFORNECEDOR = 1 THEN 66   ');
     SQL.Add('           WHEN CAPA_DEVOLUCAO.CODIGOFORNECEDOR = 51 THEN 106   ');
     SQL.Add('           WHEN CAPA_DEVOLUCAO.CODIGOFORNECEDOR = 62 THEN 107    ');
     SQL.Add('           WHEN CAPA_DEVOLUCAO.CODIGOFORNECEDOR = 102 THEN 108   ');
     SQL.Add('           ELSE CAPA_DEVOLUCAO.CODIGOFORNECEDOR      ');
     SQL.Add('       END AS COD_CLIENTE,   ');
     SQL.Add('       CAPA_DEVOLUCAO.NUMERONOTA AS NUM_NF_CLI,   ');
     SQL.Add('       CAPA_DEVOLUCAO.SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''137241'' THEN ''137207''   ');
     SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''138363'' THEN ''0138356''   ');
     SQL.Add('           ELSE PRODUTOS.CODPROD_PRODUTOS   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       1 AS QTD_EMBALAGEM,   ');
     SQL.Add('       ITEM_DEVOLUCAO.QUANTIDADE_PRODUTOS AS QTD_ENTRADA,   ');
     SQL.Add('       ITEM_DEVOLUCAO.UNIDADE_PRODUTOS AS DES_UNIDADE,   ');
     SQL.Add('       ITEM_DEVOLUCAO.VALORUNITARIO_PRODUTOS AS VAL_TABELA,   ');
     SQL.Add('       ITEM_DEVOLUCAO.DESCONTO AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       0 AS VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       COALESCE(ITEM_DEVOLUCAO.BASECALCULOIPI, 0) AS VAL_IPI_ITEM,   ');
     SQL.Add('       COALESCE(ITEM_DEVOLUCAO.VALOR_ICMS, 0) AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       ITEM_DEVOLUCAO.VALORTOTAL_PRODUTOS AS VAL_TABELA_LIQ,   ');
     SQL.Add('       0 AS VAL_CUSTO_REP,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CLIENTES.CPFCLIENTE, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       COALESCE(ITEM_DEVOLUCAO.BASECALCULO, 0) AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('       ITEM_DEVOLUCAO.CFOP AS COD_FISCAL,   ');
     SQL.Add('       ITEM_DEVOLUCAO.LINHA AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_ITENSNOTASFISCAISSAIDA AS ITEM_DEVOLUCAO   ');
     SQL.Add('   LEFT JOIN CE_NOTASFISCAISSAIDA AS CAPA_DEVOLUCAO ON CAPA_DEVOLUCAO.NUMERONOTA = ITEM_DEVOLUCAO.CODIGO_NOTAFISCAL   ');
     SQL.Add('   LEFT JOIN CE_PRODUTOS AS PRODUTOS ON PRODUTOS.CODBARRA_PRODUTOS = ITEM_DEVOLUCAO.BARRAS_PRODUTOS   ');
     SQL.Add('   LEFT JOIN CONTROLE_CLIENTES.DBO.CC_CLIENTES AS CLIENTES ON CLIENTES.CODCLIENTE = ITEM_DEVOLUCAO.CODIGOFORNECEDOR_NOTAFISCAL   ');
     SQL.Add('   WHERE CAPA_DEVOLUCAO.CODIGOOPERACAO IN (5102, 5929, 5927, 1202)   ');
     SQL.Add('   ORDER BY CAPA_DEVOLUCAO.NUMERONOTA, CAPA_DEVOLUCAO.CODIGOFORNECEDOR, CAPA_DEVOLUCAO.SERIE   ');

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

procedure TFrmSmDourado.GerarNFitensFornec;
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

    // ENTRADA

//   SQL.Add('   SELECT   ');
//   SQL.Add('       FORNECEDORES.CODIGO_FORNECEDORES AS COD_FORNECEDOR,   ');
//   SQL.Add('       CAPA.IDE_NNF AS NUM_NF_FORN,   ');
//   SQL.Add('       CAPA.IDE_SERIE AS NUM_SERIE_NF,   ');
//   SQL.Add('       CASE   ');
//   SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''137241'' THEN ''137207''   ');
//   SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''138363'' THEN ''0138356''   ');
//   SQL.Add('           ELSE PRODUTOS.CODPROD_PRODUTOS   ');
//   SQL.Add('       END AS COD_PRODUTO,   ');
//   SQL.Add('          ');
//   SQL.Add('       CASE    ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
//   SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
//   SQL.Add('           ELSE 1    ');
//   SQL.Add('       END AS COD_TRIBUTACAO,   ');
//   SQL.Add('      ');
//   SQL.Add('       1 AS QTD_EMBALAGEM,   ');
//   SQL.Add('       NF_ITENS.QTDTOTAL AS QTD_ENTRADA,   ');
//   SQL.Add('       NF_ITENS.UCOM AS DES_UNIDADE,   ');
//   SQL.Add('       NF_ITENS.VALORUN AS VAL_TABELA,   ');
//   SQL.Add('       NF_ITENS.VDESC AS VAL_DESCONTO_ITEM,   ');
//   SQL.Add('       0 AS VAL_ACRESCIMO_ITEM,   ');
//   SQL.Add('       NF_ITENS.IPI_VALIQ AS VAL_IPI_ITEM,   ');
//   SQL.Add('       0 AS VAL_SUBST_ITEM,   ');
//   SQL.Add('       NF_ITENS.VFRETE AS VAL_FRETE_ITEM,   ');
//   SQL.Add('       NF_ITENS.ICMS_VALIQ AS VAL_CREDITO_ICMS,   ');
//   SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
//   SQL.Add('       NF_ITENS.VPROD AS VAL_TABELA_LIQ,   ');
//   SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(CAPA.DESTEMIT_CNPJCPF , ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
//   SQL.Add('       NF_ITENS.ICMS_VBC AS VAL_TOT_BC_ICMS,   ');
//   SQL.Add('       NF_ITENS.VOUTRO AS VAL_TOT_OUTROS_ICMS,   ');
//   SQL.Add('       NF_ITENS.CFOP AS CFOP,   ');
//   SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
//   SQL.Add('       NF_ITENS.ICMS_VBCST AS VAL_TOT_BC_ST,   ');
//   SQL.Add('       NF_ITENS.ICMS_VALIQST AS VAL_TOT_ST,   ');
//   SQL.Add('       NF_ITENS.POSICAO AS NUM_ITEM,   ');
//   SQL.Add('       0 AS TIPO_IPI,   ');
//   SQL.Add('       NF_ITENS.NCM AS NUM_NCM,   ');
//   SQL.Add('       '''' AS DES_REFERENCIA   ');
//   SQL.Add('   FROM   ');
//   SQL.Add('       NOTASXMLITENS AS NF_ITENS   ');
//   SQL.Add('   LEFT JOIN NOTASXML AS CAPA ON CAPA.ID = NF_ITENS.NOTA_ID   ');
//   SQL.Add('   INNER JOIN CE_PRODUTOS AS PRODUTOS ON PRODUTOS.CODBARRA_PRODUTOS = NF_ITENS.CODBARRAS   ');
//   SQL.Add('   LEFT JOIN CONTROLE_ESTOQUE.DBO.CE_FORNECEDORES AS FORNECEDORES ON REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES,  ''.'', ''''), ''/'', ''''), ''-'', '''') = REPLACE(REPLACE(REPLACE(CAPA.DESTEMIT_CNPJCPF , ''.'', ''''), ''/'', ''''), ''-'', '''')   ');
//   //SQL.Add('   --WHERE CAPA.IDE_NNF = 3202140   ');


    // DEVOLU��O

     SQL.Add('   SELECT   ');
     SQL.Add('       ITEM_DEVOLUCAO.CODIGOFORNECEDOR_NOTAFISCAL AS COD_FORNECEDOR,   ');
     SQL.Add('       CAPA_DEVOLUCAO.NUMERONOTA AS NUM_NF_FORN,   ');
     SQL.Add('       CAPA_DEVOLUCAO.SERIE AS NUM_SERIE_NF,   ');
     SQL.Add('          ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''137241'' THEN ''137207''   ');
     SQL.Add('           WHEN PRODUTOS.CODPROD_PRODUTOS = ''138363'' THEN ''0138356''   ');
     SQL.Add('           ELSE PRODUTOS.CODPROD_PRODUTOS   ');
     SQL.Add('       END AS COD_PRODUTO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       1 AS QTD_EMBALAGEM,   ');
     SQL.Add('       ITEM_DEVOLUCAO.QUANTIDADE_PRODUTOS AS QTD_ENTRADA,   ');
     SQL.Add('       ITEM_DEVOLUCAO.UNIDADE_PRODUTOS AS DES_UNIDADE,   ');
     SQL.Add('       ITEM_DEVOLUCAO.VALORUNITARIO_PRODUTOS AS VAL_TABELA,   ');
     SQL.Add('       ITEM_DEVOLUCAO.DESCONTO AS VAL_DESCONTO_ITEM,   ');
     SQL.Add('       0 AS VAL_ACRESCIMO_ITEM,   ');
     SQL.Add('       COALESCE(ITEM_DEVOLUCAO.BASECALCULOIPI, 0) AS VAL_IPI_ITEM,   ');
     SQL.Add('       0 AS VAL_SUBST_ITEM,   ');
     SQL.Add('       0 AS VAL_FRETE_ITEM,   ');
     SQL.Add('       COALESCE(ITEM_DEVOLUCAO.VALOR_ICMS, 0) AS VAL_CREDITO_ICMS,   ');
     SQL.Add('       0 AS VAL_VENDA_VAREJO,   ');
     SQL.Add('       ITEM_DEVOLUCAO.VALORTOTAL_PRODUTOS AS VAL_TABELA_LIQ,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       COALESCE(ITEM_DEVOLUCAO.BASECALCULO, 0) AS VAL_TOT_BC_ICMS,   ');
     SQL.Add('       0 AS VAL_TOT_OUTROS_ICMS,   ');
     SQL.Add('       ITEM_DEVOLUCAO.CFOP AS CFOP,   ');
     SQL.Add('       0 AS VAL_TOT_ISENTO,   ');
     SQL.Add('       COALESCE(ITEM_DEVOLUCAO.BASECALCULOICMSST, 0) AS VAL_TOT_BC_ST,   ');
     SQL.Add('       0 AS VAL_TOT_ST,   ');
     SQL.Add('       ITEM_DEVOLUCAO.LINHA AS NUM_ITEM,   ');
     SQL.Add('       0 AS TIPO_IPI,   ');
     SQL.Add('       ITEM_DEVOLUCAO.NCM AS NUM_NCM,   ');
     SQL.Add('       '''' AS DES_REFERENCIA   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_ITENSNOTASFISCAISSAIDA AS ITEM_DEVOLUCAO   ');
     SQL.Add('   LEFT JOIN CE_NOTASFISCAISSAIDA AS CAPA_DEVOLUCAO ON CAPA_DEVOLUCAO.NUMERONOTA = ITEM_DEVOLUCAO.CODIGO_NOTAFISCAL   ');
     SQL.Add('   LEFT JOIN CE_PRODUTOS AS PRODUTOS ON PRODUTOS.CODBARRA_PRODUTOS = ITEM_DEVOLUCAO.BARRAS_PRODUTOS   ');
     SQL.Add('   LEFT JOIN CONTROLE_ESTOQUE.DBO.CE_FORNECEDORES AS FORNECEDORES ON FORNECEDORES.CODIGO_FORNECEDORES = ITEM_DEVOLUCAO.CODIGOFORNECEDOR_NOTAFISCAL   ');
     //SQL.Add('   WHERE CAPA_DEVOLUCAO.TIPONOTA = 1   ');
     SQL.Add('   WHERE CAPA_DEVOLUCAO.NUMERONOTA IN (38, 40)  ');
     SQL.Add('AND');
     SQL.Add(' CAPA_DEVOLUCAO.DATAEMISSAO >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
     SQL.Add('AND');
     SQL.Add(' CAPA_DEVOLUCAO.DATAEMISSAO <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');
     SQL.Add('   ORDER BY CAPA_DEVOLUCAO.NUMERONOTA, CAPA_DEVOLUCAO.CODIGOFORNECEDOR, CAPA_DEVOLUCAO.SERIE   ');



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

procedure TFrmSmDourado.GerarProdForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

     SQL.Add('   SELECT   ');
     SQL.Add('       PRODUTOS.CODPROD_PRODUTOS AS COD_PRODUTO,   ');
     SQL.Add('       FORNECEDORES.CODIGO_FORNECEDORES AS COD_FORNECEDOR,   ');
     SQL.Add('       '''' AS DES_REFERENCIA,   ');
     SQL.Add('       COALESCE(REPLACE(REPLACE(REPLACE(FORNECEDORES.CNPJ_FORNECEDORES, ''.'', ''''), ''/'', ''''), ''-'', ''''), '''') AS NUM_CGC,   ');
     SQL.Add('       0 AS COD_DIVISAO,   ');
     SQL.Add('       COALESCE(PRODUTOS.UNIDADE_PRODUTOS, ''UN'') AS DES_UNIDADE_COMPRA,   ');
     SQL.Add('       1 AS QTD_EMBALAGEM_COMPRA,   ');
     SQL.Add('       1 AS QTD_TROCA,');
     SQL.Add('       ''S'' AS FLG_PREFERENCIAL ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');
     SQL.Add('   LEFT JOIN CE_PRODFOR AS PRODFOR ON PRODUTOS.CODBARRA_PRODUTOS = PRODFOR.CODBARRA_PRODFOR   ');
     SQL.Add('   LEFT JOIN CE_FORNECEDORES AS FORNECEDORES ON PRODFOR.CODFOR_PRODFOR = FORNECEDORES.CODIGO_FORNECEDORES   ');
     SQL.Add('   WHERE FORNECEDORES.CODIGO_FORNECEDORES IS NOT NULL   ');



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

procedure TFrmSmDourado.GerarProdLoja;
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
     SQL.Add('       PRODUTOS.CODPROD_PRODUTOS AS COD_PRODUTO,   ');
     SQL.Add('       COALESCE(PRODLOJA.CUSTO, 0) AS VAL_CUSTO_REP,   ');
     SQL.Add('       COALESCE(PRODLOJA.VENDA, 0) AS VAL_VENDA,   ');
     SQL.Add('       COALESCE(PRODUTOS.PROMOCAO_PRODUTOS, 0) AS VAL_OFERTA,   ');
     SQL.Add('       COALESCE(PRODLOJA.QUANTIDADE, 1) AS QTD_EST_VDA,   ');
     SQL.Add('       '''' AS TECLA_BALANCA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIBUTACAO,   ');
     SQL.Add('      ');
     SQL.Add('       0 AS VAL_MARGEM,   ');
     SQL.Add('       1 AS QTD_ETIQUETA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE    ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 50 THEN 21   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 102 THEN 2   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 7'' AND PRODUTOS.STICMS = 500 THEN 11   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 102 THEN 5   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 500 THEN 13   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 25'' AND PRODUTOS.STICMS = 500 THEN 14   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 18'' AND PRODUTOS.STICMS = 102 THEN 4   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 900 THEN 22   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 102 THEN 3   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ISENTO'' AND PRODUTOS.STICMS = 102 THEN 1   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS IS NULL AND PRODUTOS.STICMS = 500 THEN 25   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''ALIQUOTA 12'' AND PRODUTOS.STICMS = 500 THEN 12   ');
     SQL.Add('           WHEN PRODUTOS.TRIBTIPO_PRODUTOS = ''SUBST.TRIBUTARIA'' AND PRODUTOS.STICMS = 102 THEN 25   ');
     SQL.Add('           ELSE 1    ');
     SQL.Add('       END AS COD_TRIB_ENTRADA,   ');
     SQL.Add('          ');
     SQL.Add('       ''N'' AS FLG_INATIVO,   ');
     SQL.Add('       PRODUTOS.CODPROD_PRODUTOS AS COD_PRODUTO_ANT,   ');
     SQL.Add('       COALESCE(PRODUTOS.NCM_PRODUTOS, ''99999999'') AS NUM_NCM,   ');
     SQL.Add('       0 AS TIPO_NCM,   ');
     SQL.Add('       0 AS VAL_VENDA_2,   ');
     SQL.Add('       COALESCE(PRODUTOS.VENCPROMOCAO_PRODUTOS, '''') AS DTA_VALIDA_OFERTA,   ');
     SQL.Add('       COALESCE(PRODUTOS.QTDMINIMA_PRODUTOS, 1) AS QTD_EST_MINIMO,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CODVASILHAME = '''' THEN NULL   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.CODVASILHAME, NULL)    ');
     SQL.Add('       END AS COD_VASILHAME,   ');
     SQL.Add('          ');
     SQL.Add('       ''N'' AS FORA_LINHA,   ');
     SQL.Add('       0 AS QTD_PRECO_DIF,   ');
     SQL.Add('       0 AS VAL_FORCA_VDA,   ');
     SQL.Add('      ');
     SQL.Add('       CASE   ');
     SQL.Add('           WHEN PRODUTOS.CEST = '''' THEN ''99999999''    ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''5'' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''.'' THEN ''99999999''   ');
     SQL.Add('           WHEN PRODUTOS.CEST = ''2,89'' THEN ''99999999''   ');
     SQL.Add('           ELSE COALESCE(PRODUTOS.CEST, ''99999999'')    ');
     SQL.Add('       END AS NUM_CEST,   ');
     SQL.Add('      ');
     SQL.Add('       COALESCE(PRODUTOS.IVA, 0) AS PER_IVA,   ');
     SQL.Add('       0 AS PER_FCP_ST,   ');
     SQL.Add('       0 AS PER_FIDELIDADE   ');
     SQL.Add('   FROM   ');
     SQL.Add('       CE_PRODUTOS AS PRODUTOS   ');
     SQL.Add('   LEFT JOIN PRODUTOSEMPRESA AS PRODLOJA ON PRODUTOS.CODBARRA_PRODUTOS = PRODLOJA.BARRAS   ');







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

procedure TFrmSmDourado.GerarProdSimilar;
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
