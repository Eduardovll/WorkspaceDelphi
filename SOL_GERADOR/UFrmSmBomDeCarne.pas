(* SISTEMA INFOTOTAL *)

unit UFrmSmBomDeCarne;

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
  TFrmSmBomDeCarne = class(TFrmModeloSis)
    CbxLoja: TComboBox;
    lblLoja: TLabel;
    ADOSQLServer: TADOConnection;
    QryPrincipal2: TADOQuery;
    QryAux: TADOQuery;
    QryAuxNF: TADOQuery;
    Memo1: TMemo;
    Label11: TLabel;
    btnGeraValorVenda: TButton;
    btnGeraCustoRep: TButton;
    btnGerarEstoqueAtual: TButton;
    procedure BtnGerarClick(Sender: TObject);
    procedure QryPrincipal2AfterOpen(DataSet: TDataSet);
    procedure btnGeraValorVendaClick(Sender: TObject);
    procedure btnGeraCustoRepClick(Sender: TObject);
    procedure btnGerarEstoqueAtualClick(Sender: TObject);
    procedure CkbProdLojaClick(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
    procedure GerarCliente;           Override; (* OK *)
    procedure GerarCondPagCli;        Override; (* OK *)

    procedure GerarFornecedor;        Override; (* OK *)
    procedure GerarCondPagForn;       Override; (* OK *)

    procedure GerarSecao;             Override;  (* OK *)
    procedure GerarGrupo;             Override;  (* OK *)
    procedure GerarSubGrupo;          Override;  (* OK *)

    procedure GerarProduto;           Override;  (* OK *)

    procedure GerarCodigoBarras;      Override;  (* OK *)

    procedure GerarCest;              Override;  (* OK *)
    procedure GerarNCM;               Override;  (* FALTA IMPOSTO *)
    procedure GerarNCMUF;             Override;  (* FALTA IMPOSTO *)

    procedure GerarProdLoja;          Override;  (* FALTA IMPOSTO *)

    procedure GerarProdForn;          Override;  (* VERIFICAR SE DA PRA ABSTRAIR DAS NOTAS *)

    procedure GerarNFFornec;          Override;  (* FALTA IMPOSTO *)
    procedure GerarNFitensFornec;     Override;  (* FALTA IMPOSTO *)

    procedure GerarVenda;             Override;  (* OK *)

    procedure GerarFinanceiro( Tipo, Situacao :Integer ); Override; (* OK *)
    procedure GerarFinanceiroReceber(Aberto:String);      Override; (* OK *)
    procedure GerarFinanceiroPagar(Aberto:String);        Override; (* OK *)

    function RetSQLAliquotaProduto: String;
    function RetSQLAliquotaNF: String;

    procedure GerarValorVenda;
    procedure GeraCustoRep;
    procedure GeraEstoqueVenda;

  end;

var
  FrmSmBomDeCarne: TFrmSmBomDeCarne;
  NumLinha : Integer;
  Arquivo: TextFile;

  FlgAtualizaValVenda : Boolean = False;
  FlgAtualizaCustoRep : Boolean = False;
  FlgAtualizaEstoque  : Boolean = False;

implementation

{$R *.dfm}

uses xProc, UUtilidades, UProgresso;

procedure TFrmSmBomDeCarne.GerarProduto;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  PROD.IDPRODUTO AS COD_PRODUTO, ');
    SQL.Add(' ');
    SQL.Add('  (SELECT TOP 1 CODIGOBARRAS FROM TOTAL_CODIGO_BARRAS WHERE IDPRODUTO = PROD.IDPRODUTO) AS COD_BARRA_PRINCIPAL, ');
    SQL.Add(' ');
    SQL.Add('  PROD.DESCRICAO AS DES_REDUZIDA, ');
    SQL.Add('  PROD.DESCRICAO AS DES_PRODUTO, ');
    SQL.Add('  1 AS QTD_EMBALAGEM_COMPRA, --UNID.UN AS QTD_EMBALAGEM_COMPRA, ');
    SQL.Add('  UNID.DESCRICAO AS DES_UNIDADE_COMPRA, ');
    SQL.Add('  1 AS QTD_EMBALAGEM_VENDA, --UNID.UN AS QTD_EMBALAGEM_VENDA, ');
    SQL.Add('  UNID.DESCRICAO AS DES_UNIDADE_VENDA, ');
    SQL.Add('  0 AS TIPO_IPI, ');
    SQL.Add('  0 AS VAL_IPI, ');
    SQL.Add('  SECAOGRUPO.IDGRUPO AS COD_SECAO, ');
    SQL.Add('  SECAOGRUPO.IDGRUPO AS COD_GRUPO, ');
    SQL.Add('  SUBGRUPO.IDSUBGRUPO AS COD_SUB_GRUPO, ');
    SQL.Add('  0 AS COD_PRODUTO_SIMILAR, ');
    SQL.Add('  CASE WHEN PROD.PERMITEFRACIONAMENTO = 1 THEN ''S'' ELSE ''N'' END AS IPV, ');
    SQL.Add('  PROD.VALIDADE AS DIAS_VALIDADE, ');
    SQL.Add('  0 AS TIPO_PRODUTO, ');
    SQL.Add('  CASE WHEN PROD.pisAliquota <> 0.00 THEN ''N'' ELSE ''S'' END AS FLG_NAO_PIS_COFINS,  ');
    SQL.Add('  CASE WHEN PROD.BALANCA = 1 THEN ''S'' ELSE ''N'' END AS FLG_ENVIA_BALANCA, ');
    SQL.Add(' ');
    SQL.Add('  CASE    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 73) AND (PROD.PISCST = 06))THEN 0   ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 70) AND (PROD.PISCST = 04))THEN 1   ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 75) AND (PROD.PISCST = 05))THEN 2   ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 74) AND (PROD.PISCST = 09))THEN 3   ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 99) AND (PROD.PISCST = 49))THEN 3   ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 72) AND (PROD.PISCST = 09))THEN 4   ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 50) AND (PROD.PISCST = 01))THEN 0   ');
    SQL.Add('  ELSE -1 END AS TIPO_NAO_PIS_COFINS,   ');
    SQL.Add(' ');
    SQL.Add('  0 AS TIPO_EVENTO,   ');
    SQL.Add('  NULL AS COD_ASSOCIADO,   ');
    SQL.Add('  PROD.observacoesApp AS DES_OBSERVACAO,   ');
    SQL.Add('  0 AS COD_INFO_NUTRICIONAL,     ');
    SQL.Add('  0 AS COD_TAB_SPED,   ');
    SQL.Add('  ''N'' AS FLG_ALCOOLICO,    ');
    SQL.Add('  0 AS TIPO_MERCADORIA,    ');
    SQL.Add('  0 AS COD_CLASSIF, ');
    SQL.Add('  1 AS VAL_VDA_PESO_BRUTO, ');
    SQL.Add('  1 AS VAL_PESO_EMB, ');
    SQL.Add('  0 AS TIPO_EXPLOSAO_COMPRA, ');
    SQL.Add('  '''' AS DTA_INI_OPER,       ');
    SQL.Add('  '''' AS DES_PLAQUETA,       ');
    SQL.Add('  '''' AS MES_ANO_INI_DEPREC,       ');
    SQL.Add('  0 AS TIPO_BEM,       ');
    SQL.Add('  0 AS COD_FORNECEDOR,       ');
    SQL.Add('  0 AS NUM_NF,       ');
    SQL.Add('  NULL AS DTA_ENTRADA,       ');
    SQL.Add('  0 AS COD_NAT_BEM,       ');
    SQL.Add('  0 AS VAL_ORIG_BEM,       ');
    SQL.Add('  COALESCE(PROD.DESCRICAO, ''A DEFINIR'') AS DES_PRODUTO_ANT    ');
    SQL.Add('    ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_PRODUTO AS PROD ');
    SQL.Add('    LEFT JOIN TOTAL_UNIDADE UNID ON PROD.IDUNIDADE = UNID.IDUNIDADE ');
    SQL.Add('	   LEFT JOIN TOTAL_SUBGRUPO SUBGRUPO ON SUBGRUPO.IDSUBGRUPO = PROD.IDSUBGRUPO ');
    SQL.Add('	   LEFT JOIN TOTAL_GRUPO SECAOGRUPO ON SECAOGRUPO.IDGRUPO = SUBGRUPO.IDGRUPO ');
    SQL.Add('  --WHERE PROD.IDPRODUTO = 2968 ');

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

        if QryPrincipal2.FieldByName('COD_BARRA_PRINCIPAL').AsString = '' then
          Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := Layout.FieldByName('COD_PRODUTO').AsString;

        Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

        Layout.FieldByName('DES_OBSERVACAO').AsString  := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');

        if (Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString = '000000000000') or
          (Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString = '0000') or
          (Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString = '0')  then
          Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := '';

        if QryPrincipal2.FieldByName('COD_PRODUTO').AsString = '73354' then
          Layout.FieldByName('COD_BARRA_PRINCIPAL').AsString := Layout.FieldByName('COD_PRODUTO').AsString;

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

procedure TFrmSmBomDeCarne.GerarSecao;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  IDGRUPO AS COD_SECAO,   ');
    SQL.Add('  DESCRICAO AS DES_SECAO,   ');
    SQL.Add('  0 AS VAL_META   ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_GRUPO AS SECAO ');

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

procedure TFrmSmBomDeCarne.GerarGrupo;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT    ');
    SQL.Add('  IDGRUPO AS COD_SECAO,    ');
    SQL.Add('  IDGRUPO AS COD_GRUPO,   ');
    SQL.Add('  DESCRICAO AS DES_GRUPO,   ');
    SQL.Add('  0 AS VAL_META    ');
    SQL.Add('FROM    ');
    SQL.Add('  TOTAL_GRUPO AS GRUPO ');

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

procedure TFrmSmBomDeCarne.GerarSubGrupo;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT   ');
    SQL.Add('  GRUPO.IDGRUPO AS COD_SECAO,   ');
    SQL.Add('  GRUPO.IDGRUPO AS COD_GRUPO,   ');
    SQL.Add('  SUBGRUPO.IDSUBGRUPO AS COD_SUB_GRUPO,   ');
    SQL.Add('  SUBGRUPO.DESCRICAO AS DES_SUB_GRUPO,   ');
    SQL.Add('  0 AS VAL_META,   ');
    SQL.Add('  0 AS VAL_MARGEM_REF,   ');
    SQL.Add('  0 AS QTD_DIA_SEGURANCA,   ');
    SQL.Add('  ''N'' AS FLG_ALCOOLICO   ');
    SQL.Add('FROM   ');
    SQL.Add('  TOTAL_SUBGRUPO AS SUBGRUPO   ');
    SQL.Add('    LEFT JOIN TOTAL_GRUPO AS GRUPO ON SUBGRUPO.IDGRUPO = GRUPO.IDGRUPO  ');

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

procedure TFrmSmBomDeCarne.GerarVenda;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  ITMVENDA.IDPRODUTO AS COD_PRODUTO, ');
    SQL.Add('  1 AS COD_LOJA, ');
    SQL.Add('  0 AS IND_TIPO, ');
    SQL.Add('  1 AS NUM_PDV, ');
    SQL.Add('  ITMVENDA.QUANTIDADE AS QTD_TOTAL_PRODUTO, ');
    SQL.Add('  ITMVENDA.VALORTOTAL AS VAL_TOTAL_PRODUTO, ');
    SQL.Add('  ITMVENDA.VALORUNITARIO AS VAL_PRECO_VENDA, ');
    SQL.Add('  ITMVENDA.CUSTOUNITARIO AS VAL_CUSTO_REP, ');
//    SQL.Add('  CAST(VENDA.DATAABERTURA AS DATE) AS DTA_SAIDA, ');
    SQL.Add('  VENDA.DATAABERTURA AS DTA_SAIDA, ');
    SQL.Add('  RIGHT(''0'' + CONVERT(VARCHAR(2), MONTH(VENDA.DATAABERTURA)), 2) + CONVERT(CHAR(4), YEAR(VENDA.DATAABERTURA)) AS DTA_MENSAL, ');
    SQL.Add('  1 AS NUM_IDENT, ');
    SQL.Add('  NULL AS COD_EAN, ');
    SQL.Add('     ');
    SQL.Add('  RIGHT(''0'' + CAST(DATEPART(HH,VENDA.DATAABERTURA) AS VARCHAR), 2) +  ');
    SQL.Add('  RIGHT(''0'' + CAST(DATEPART(MI,VENDA.DATAABERTURA) AS VARCHAR), 2) AS DES_HORA, ');
    SQL.Add(' ');
    SQL.Add('  0 AS COD_CLIENTE, ');
    SQL.Add('  1 AS COD_ENTIDADE, ');
    SQL.Add('  0 AS VAL_BASE_ICMS, ');
    SQL.Add('  '''' AS DES_SITUACAO_TRIB,  ');
    SQL.Add('  0 AS VAL_ICMS,  ');
    SQL.Add('  COALESCE(VENDA.NUMCOMANDA, 1) AS NUM_CUPOM_FISCAL, ');
    SQL.Add('  1 AS NUM_CUPOM_FISCAL, ');
    SQL.Add('  ITMVENDA.VALORUNITARIO AS VAL_VENDA_PDV, ');
    SQL.Add(' ');
    SQL.Add('  1 AS COD_TRIBUTACAO, ');
    SQL.Add(' ');
    SQL.Add('  CASE WHEN VENDA.DATACANCELAMENTO IS NOT NULL THEN ''S'' ELSE ''N'' END AS FLG_CUPOM_CANCELADO, ');
    SQL.Add('  COALESCE(ITMVENDA.NCMITEM, ''99999999'') AS NUM_NCM, ');
    SQL.Add('  0 AS COD_TAB_SPED, ');
    SQL.Add('  CASE WHEN ITMVENDA.pisAliquotaItem <> 0.00 THEN ''N'' ELSE ''S'' END AS FLG_NAO_PIS_COFINS, ');
    SQL.Add(' ');
    SQL.Add('  CASE     ');
    SQL.Add('    WHEN ((ITMVENDA.cofinsCSTItem = 73) AND (ITMVENDA.pisCSTItem = 06))THEN 0    ');
    SQL.Add('    WHEN ((ITMVENDA.cofinsCSTItem = 70) AND (ITMVENDA.pisCSTItem = 04))THEN 1    ');
    SQL.Add('    WHEN ((ITMVENDA.cofinsCSTItem = 75) AND (ITMVENDA.pisCSTItem = 05))THEN 2    ');
    SQL.Add('    WHEN ((ITMVENDA.cofinsCSTItem = 74) AND (ITMVENDA.pisCSTItem = 09))THEN 3    ');
    SQL.Add('    WHEN ((ITMVENDA.cofinsCSTItem = 99) AND (ITMVENDA.pisCSTItem = 49))THEN 3    ');
    SQL.Add('    WHEN ((ITMVENDA.cofinsCSTItem = 72) AND (ITMVENDA.pisCSTItem = 09))THEN 4    ');
    SQL.Add('    WHEN ((ITMVENDA.cofinsCSTItem = 50) AND (ITMVENDA.pisCSTItem = 01))THEN 0    ');
    SQL.Add('  ELSE -1 END AS TIPO_NAO_PIS_COFINS, ');
    SQL.Add('      ');
    SQL.Add('  ''N'' AS FLG_ONLINE,  ');
    SQL.Add('  ''N'' AS FLG_OFERTA,  ');
    SQL.Add('  NULL AS COD_ASSOCIADO  ');
    SQL.Add(' ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_VENDA VENDA ');
    SQL.Add('    INNER JOIN TOTAL_ITENS_VENDA ITMVENDA ON VENDA.IDVENDA = ITMVENDA.IDVENDA ');
    SQL.Add('WHERE ');
    SQL.Add('  CAST(VENDA.DATAABERTURA AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
    SQL.Add('  AND');
    SQL.Add('  CAST(VENDA.DATAABERTURA AS DATE) <= '''+FormatDAteTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

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

        Layout.FieldByName('NUM_NCM').AsString       := StrRetNums(Layout.FieldByName('NUM_NCM').AsString);

        Layout.FieldByName('COD_PRODUTO').AsString   := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

        if QryPrincipal2.FieldByName('DTA_SAIDA').AsString <> '' then
          Layout.FieldByName('DTA_SAIDA').AsString := FormatDateTime('dd/mm/yyyy', QryPrincipal2.FieldByName('DTA_SAIDA').AsDateTime);

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.QryPrincipal2AfterOpen(DataSet: TDataSet);
begin
  inherited;
  Memo1.Lines.Add('------------------------');
  Memo1.Lines.Add(QryPrincipal2.SQL.Text);
end;

function TFrmSmBomDeCarne.RetSQLAliquotaNF: String;
begin
  Result := '';
  Result := QryAuxNF.SQL.Text;
end;

function TFrmSmBomDeCarne.RetSQLAliquotaProduto: String;
begin
  Result := '';
  Result := QryAux.SQL.Text;
end;

procedure TFrmSmBomDeCarne.btnGeraCustoRepClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaCustoRep := True;
  BtnGerar.Click;
  FlgAtualizaCustoRep := False;
end;

procedure TFrmSmBomDeCarne.BtnGerarClick(Sender: TObject);
begin
  ADOSQLServer.Connected := False;
//  ADOSQLServer.ConnectionString := 'Provider=MSDASQL.1;Password="'+edtSenhaOracle.Text+'";ID='+edtInst.Text+';Data Source='+edtSchema.Text+';Persist Security Info=False';
   ADOSQLServer.ConnectionString := 'Provider=MSDASQL.1;Persist Security Info=False;Data Source='+edtSchema.Text+';User ID='+edtInst.Text+';Password='+edtSenhaOracle.Text+'';
  ADOSQLServer.Connected := True;

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
end;

procedure TFrmSmBomDeCarne.btnGerarEstoqueAtualClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaEstoque := True;
  BtnGerar.Click;
  FlgAtualizaEstoque := False;
end;

procedure TFrmSmBomDeCarne.btnGeraValorVendaClick(Sender: TObject);
begin
  inherited;
  FlgAtualizaValVenda := True;
  BtnGerar.Click;
  FlgAtualizaValVenda := False;
end;

procedure TFrmSmBomDeCarne.CkbProdLojaClick(Sender: TObject);
begin
  inherited;
  btnGeraValorVenda.Enabled    := CkbProdLoja.Checked;
  btnGeraCustoRep.Enabled      := CkbProdLoja.Checked;
  btnGerarEstoqueAtual.Enabled := CkbProdLoja.Checked;
end;

procedure TFrmSmBomDeCarne.GerarValorVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT  ');
    SQL.Add('  PROD.IDPRODUTO AS COD_PRODUTO,  ');
//    SQL.Add('  (SELECT AVG(PRECOVENDA) FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO) AS VAL_VENDA ');
    SQL.Add('  (SELECT PRECOVENDA FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO AND STATUS = 1) AS VAL_VENDA ');
    SQL.Add('FROM  ');
    SQL.Add('  TOTAL_PRODUTO PROD  ');
    SQL.Add('    INNER JOIN TOTAL_ESTOQUE ESTOQUE ON PROD.IDPRODUTO = ESTOQUE.IDPRODUTO AND ESTOQUE.STATUS = 1  ');

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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_VENDA = ''' +
          QryPrincipal2.FieldByName('VAL_VENDA').AsString + ''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');

        if (NumLinha mod 500) = 0 then
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

procedure TFrmSmBomDeCarne.GeraCustoRep;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT  ');
    SQL.Add('  PROD.IDPRODUTO AS COD_PRODUTO,  ');
//    SQL.Add('  (SELECT AVG(CUSTO) FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO) AS VAL_CUSTO_REP   ');
    SQL.Add('  (SELECT CUSTO FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO AND STATUS = 1) AS VAL_CUSTO_REP   ');
    SQL.Add('FROM  ');
    SQL.Add('  TOTAL_PRODUTO PROD  ');
    SQL.Add('    INNER JOIN TOTAL_ESTOQUE ESTOQUE ON PROD.IDPRODUTO = ESTOQUE.IDPRODUTO AND ESTOQUE.STATUS = 1  ');

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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET VAL_CUSTO_REP = ''' +
          QryPrincipal2.FieldByName('VAL_CUSTO_REP').AsString + ''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');

        if (NumLinha mod 500) = 0 then
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

procedure TFrmSmBomDeCarne.GeraEstoqueVenda;
var
  COD_PRODUTO : string;
begin
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT  ');
    SQL.Add('  PROD.IDPRODUTO AS COD_PRODUTO,  ');
    SQL.Add('  (SELECT SUM(QTDEVENDA) FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO) AS QTD_EST_VDA ');
    SQL.Add('FROM  ');
    SQL.Add('  TOTAL_PRODUTO PROD  ');
    SQL.Add('    LEFT JOIN TOTAL_ESTOQUE ESTOQUE ON PROD.IDPRODUTO = ESTOQUE.IDPRODUTO  ');

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

        Writeln(Arquivo, 'UPDATE TAB_PRODUTO_LOJA SET QTD_EST_ATUAL = ''' +
          QryPrincipal2.FieldByName('QTD_EST_VDA').AsString + ''' WHERE COD_PRODUTO = '+COD_PRODUTO+' ; ');

        if (NumLinha mod 500) = 0 then
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

procedure TFrmSmBomDeCarne.GerarCest;
var
  Count: integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT ');
    SQL.Add('  0 AS COD_CEST, ');
    SQL.Add('  ''A DEFINIR'' AS DES_CEST, ');
    SQL.Add('  CASE WHEN COALESCE(CEST, '''') = '''' OR CEST IS NULL THEN ''9999999'' ELSE CEST END AS NUM_CEST ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_PRODUTO PROD ');

    Open;
    First;

    Count    := 0;
    NumLinha := 0;

    while not EoF do
    begin
      try
        if Cancelar then
          Break;

        Inc(NumLinha);
        Inc(Count);

        Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

        Layout.FieldByName('COD_CEST').AsInteger := Count;

        Layout.FieldByName('NUM_CEST').AsString  := StrRetNums(Layout.FieldByName('NUM_CEST').AsString);

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.GerarCliente;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT  ');
    SQL.Add('  CLIENTE.IDCLIENTE AS COD_CLIENTE, ');
    SQL.Add('  CASE WHEN RAZAOSOCIAL <> '''' THEN RAZAOSOCIAL ELSE NOMECOMPLETO END AS DES_CLIENTE, ');
    SQL.Add('  CASE  ');
    SQL.Add('    WHEN REPLACE(REPLACE(REPLACE(CNPJ, ''.'', ''''), ''-'', ''''), ''/'', '''') <> '''' THEN  ');
    SQL.Add('	  REPLACE(REPLACE(REPLACE(CNPJ, ''.'', ''''), ''-'', ''''), ''/'', '''')  ');
    SQL.Add('	ELSE  ');
    SQL.Add('	  REPLACE(REPLACE(REPLACE(CPF, ''.'', ''''), ''-'', ''''), ''/'', '''')  ');
    SQL.Add('	END AS NUM_CGC,  ');
    SQL.Add('  INSCRICAOESTADUAL AS NUM_INSC_EST, ');
    SQL.Add('  ENDERECO AS DES_ENDERECO, ');
    SQL.Add('  BAIRRO AS DES_BAIRRO, ');
    SQL.Add('  UPPER(CIDADE.NOME) AS DES_CIDADE, ');
    SQL.Add('  UPPER(ESTADO.UF) AS DES_SIGLA, ');
    SQL.Add('  REPLACE(REPLACE(CEP, ''.'', ''''), ''-'', '''') AS NUM_CEP, ');
    SQL.Add('  REPLACE(REPLACE(REPLACE((SELECT TOP 1 NUMERO FROM DBO.TOTAL_TELEFONES WHERE IDCLIENTE = CLIENTE.IDCLIENTE AND UPPER(TIPO) <> ''CELULAR''), ''('', ''''), '')'', ''''), ''-'', '''') AS NUM_FONE, ');
    SQL.Add('  FAX AS NUM_FAX, ');
    SQL.Add('  CONTATOCOBRANCA AS DES_CONTATO, ');
    SQL.Add('  CASE UPPER(SEXO)  ');
    SQL.Add('    WHEN ''MASCULINO'' THEN 0 ');
    SQL.Add('	WHEN ''FEMININO'' THEN 1   ');
    SQL.Add('  END AS FLG_SEXO, ');
    SQL.Add(' ');
    SQL.Add('  0 AS VAL_LIMITE_CRED, ');
    SQL.Add('  LIMITE AS VAL_LIMITE_CONV, ');
    SQL.Add('  0 AS VAL_DEBITO,   ');
    SQL.Add('  0 AS VAL_RENDA, ');
//    SQL.Add('  CASE WHEN LIMITE > 0 THEN 99999 ELSE 0 END AS COD_CONVENIO, ');
    SQL.Add('  99999 AS COD_CONVENIO, ');
    SQL.Add('  0 AS COD_STATUS_PDV, ');
    SQL.Add('  CASE WHEN REPLACE(REPLACE(REPLACE(CNPJ, ''.'', ''''), ''-'', ''''), ''/'', '''') <> '''' THEN ''S'' ELSE ''N'' END AS FLG_EMPRESA, ');
    SQL.Add('  ''N'' AS FLG_CONVENIO,  ');
    SQL.Add('  ''N'' AS MICRO_EMPRESA,  ');
    SQL.Add('  DATACADASTRO AS DTA_CADASTRO, ');
    SQL.Add('  ENDERECONUMERO AS NUM_ENDERECO, ');
    SQL.Add('  REPLACE(REPLACE(REPLACE(RG, ''.'', ''''), ''-'', ''''), ''/'', '''') AS NUM_RG, ');
    SQL.Add('  0 AS FLG_EST_CIVIL, ');
    SQL.Add('  REPLACE(REPLACE(REPLACE((SELECT TOP 1 NUMERO FROM DBO.TOTAL_TELEFONES WHERE IDCLIENTE = CLIENTE.IDCLIENTE AND UPPER(TIPO) = ''CELULAR''), ''('', ''''), '')'', ''''), ''-'', '''') AS NUM_CELULAR, ');
    SQL.Add('  NULL AS DTA_ALTERACAO, ');
    SQL.Add('  OBSERVACOES AS DES_OBSERVACAO, ');
    SQL.Add('  COMPLEMENTO AS DES_COMPLEMENTO, ');
    SQL.Add('  EMAIL AS DES_EMAIL, ');
    SQL.Add('  NOMEFANTASIA AS DES_FANTASIA, ');
    SQL.Add('  CAST(DATANASCIMENTO AS DATETIME) AS DTA_NASCIMENTO, ');
    SQL.Add('  '''' AS DES_PAI, ');
    SQL.Add('  '''' AS DES_MAE, ');
    SQL.Add('  '''' AS DES_CONJUGE, ');
    SQL.Add('  '''' AS NUM_CPF_CONJUGE, ');
    SQL.Add('  0 AS VAL_DEB_CONV, ');
    SQL.Add('  ''N'' AS INATIVO, ');
    SQL.Add('  0 AS DES_MATRICULA, ');
    SQL.Add('  ''N'' AS NUM_CGC_ASSOCIADO, ');
    SQL.Add('  ''N'' AS FLG_PROD_RURAL, ');
    SQL.Add('  0 AS COD_STATUS_PDV_CONV, ');
    SQL.Add('  ''N'' AS FLG_ENVIA_CODIGO, ');
    SQL.Add('  NULL AS DTA_NASC_CONJUGE, ');
    SQL.Add('  CASE WHEN  ');
    SQL.Add('    (SELECT COUNT(*) FROM TOTAL_COLABORADOR WHERE CPF = CLIENTE.CPF AND CNPJ = CLIENTE.CNPJ) = 1 THEN 28 ELSE 0 END AS COD_CLASSIF ');
//    SQL.Add('  0 AS COD_CLASSIF      ');
    SQL.Add('FROM  ');
    SQL.Add('  TOTAL_CLIENTE AS CLIENTE ');
    SQL.Add('    LEFT JOIN TOTAL_CIDADE AS CIDADE ON CLIENTE.IDCIDADE = CIDADE.IDCIDADE ');
    SQL.Add('	   LEFT JOIN TOTAL_ESTADO AS ESTADO ON ESTADO.IDESTADO = CIDADE.IDESTADO	 ');
    SQL.Add(' ');
    SQL.Add('WHERE ');
    SQL.Add('  --CLIENTE.IDCLIENTE = 120 AND ');
    SQL.Add('  (RAZAOSOCIAL <> '''' OR NOMECOMPLETO <> '''') ');

    Open;
    First;

    NumLinha := 0;

    while not EoF do
    begin
      try
        if Cancelar then
          Break;
        Inc(NumLinha);

        Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

        Layout.FieldByName('NUM_CGC').AsString := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

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

        Layout.FieldByName('NUM_CEP').AsString  := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);

        if QryPrincipal2.FieldByName('DTA_CADASTRO').AsString <> '' then
          Layout.FieldByName('DTA_CADASTRO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_CADASTRO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_NASCIMENTO').AsString <> '' then
          Layout.FieldByName('DTA_NASCIMENTO').AsString := FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_NASCIMENTO').AsDateTime);

        Layout.FieldByName('NUM_FONE').AsString        := StrRetNums( FieldByName('NUM_FONE').AsString );
        Layout.FieldByName('NUM_FAX').AsString        := StrRetNums( FieldByName('NUM_FAX').AsString );
        Layout.FieldByName('NUM_CELULAR').AsString        := StrRetNums( FieldByName('NUM_CELULAR').AsString );

        if Length(Layout.FieldByName('NUM_CGC').AsString) > 11 then
        begin
          if not ValidaCGC(Layout.FieldByName('NUM_CGC').AsString) then
            Layout.FieldByName('NUM_CGC').AsString := '';
        end
        else
          if not ValidaCpf(Layout.FieldByName('NUM_CGC').AsString) then
            Layout.FieldByName('NUM_CGC').AsString := '';

        Layout.FieldByName('DES_EMAIL').AsString      := StrReplace(StrLBReplace(FieldByName('DES_EMAIL').AsString), '\n', '');
        Layout.FieldByName('DES_ENDERECO').AsString   := StrReplace(StrLBReplace(FieldByName('DES_ENDERECO').AsString), '\n', '');
        Layout.FieldByName('DES_OBSERVACAO').AsString := StrReplace(StrLBReplace(FieldByName('DES_OBSERVACAO').AsString), '\n', '');

        if Layout.FieldByName('DES_EMAIL').AsString= ';' then
          Layout.FieldByName('DES_EMAIL').AsString := '';

        if Layout.FieldByName('FLG_EMPRESA').AsString = 'N' then
          Layout.FieldByName('NUM_INSC_EST').AsString := '';

        Layout.FieldByName('DES_CLIENTE').AsString  := StrRemPont(Layout.FieldByName('DES_CLIENTE').AsString);
        Layout.FieldByName('DES_ENDERECO').AsString := StrRemPont(Layout.FieldByName('DES_ENDERECO').AsString);
        Layout.FieldByName('DES_BAIRRO').AsString   := StrRemPont(Layout.FieldByName('DES_BAIRRO').AsString);
        Layout.FieldByName('DES_CIDADE').AsString   := StrRemPont(Layout.FieldByName('DES_CIDADE').AsString);

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.GerarCondPagCli;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT                 ');
    SQL.Add('  IDCLIENTE AS COD_CLIENTE, ');
    SQL.Add('  40 AS NUM_CONDICAO, ');
    SQL.Add('  2 AS  COD_CONDICAO,      ');
    SQL.Add('  1 AS COD_ENTIDADE ');
    SQL.Add('FROM');
    SQL.Add('  TOTAL_CLIENTE ');

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

procedure TFrmSmBomDeCarne.GerarCodigoBarras;
var
  count, count1 : Integer;
  CodPrincipal : string;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT   ');
    SQL.Add('  PROD.IDPRODUTO AS COD_PRODUTO,  ');
    SQL.Add('  COALESCE(BARRA.CODIGOBARRAS, '''') AS COD_EAN   ');
    SQL.Add('FROM   ');
    SQL.Add('  TOTAL_PRODUTO PROD ');
    SQL.Add('    LEFT JOIN TOTAL_CODIGO_BARRAS BARRA ON PROD.IDPRODUTO = BARRA.IDPRODUTO ');
    SQL.Add('  --WHERE PROD.IDPRODUTO = 2968  ');

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

        if QryPrincipal2.FieldByName('COD_EAN').AsString = '' then
          Layout.FieldByName('COD_EAN').AsString := QryPrincipal2.FieldByName('COD_PRODUTO').AsString;

        Layout.FieldByName('COD_PRODUTO').AsString := GerarPLU(QryPrincipal2.FieldByName('COD_PRODUTO').AsString);

        if Length(StrLBReplace(Trim(StrRetNums( FieldByName('COD_EAN').AsString) ))) < 8 then
         Layout.FieldByName('COD_EAN').AsString := GerarPLU(Layout.FieldByName('COD_EAN').AsString);

        if not CodBarrasValido(Layout.FieldByName('COD_EAN').AsString) then
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

procedure TFrmSmBomDeCarne.GerarFinanceiro(Tipo, Situacao: Integer);
begin
  inherited;
  if Tipo = 1 then
    GerarFinanceiroPagar(IntToStr(Situacao));

  if Tipo = 2 then
    GerarFinanceiroReceber(IntToStr(Situacao));
end;

procedure TFrmSmBomDeCarne.GerarFinanceiroPagar(Aberto: String);
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  1 AS TIPO_PARCEIRO, ');
    SQL.Add('  NOTA.idEmpresaEmitente AS COD_PARCEIRO, ');
    SQL.Add('  0 AS TIPO_CONTA, ');
    SQL.Add('  8 AS COD_ENTIDADE, ');
    SQL.Add('  NOTA.NUMERONOTA AS NUM_DOCTO, ');
    SQL.Add('  999 AS COD_BANCO, ');
    SQL.Add('  '''' AS DES_BANCO, ');
    SQL.Add('  TITULO.DATAMOVIMENTO AS DTA_EMISSAO, ');
    SQL.Add('  TITULO.DATAVENCIMENTO AS DTA_VENCIMENTO, ');
//    SQL.Add('  TITULO.VALOR AS VAL_PARCELA,  ');
    SQL.Add('  CASE WHEN TITULO.valor = TITULO.valorpago THEN TITULO.valor else TITULO.valor - TITULO.valorpago END AS VAL_PARCELA, ');
    SQL.Add('  TITULO.valorJuros AS VAL_JUROS, ');
    SQL.Add('  TITULO.desconto AS VAL_DESCONTO, ');
    SQL.Add('  CASE WHEN TITULO.valor = TITULO.valorpago THEN ''S'' ELSE ''N'' END AS FLG_QUITADO, ');
    SQL.Add('  TITULO.dataPagamento AS DTA_QUITADA, ');
    SQL.Add('  998 AS COD_CATEGORIA,  ');
    SQL.Add('  998 AS COD_SUBCATEGORIA,  ');
    SQL.Add('  TITULO.parcela AS NUM_PARCELA, ');
    SQL.Add('  TITULO.totalParcelas AS QTD_PARCELA, ');
    SQL.Add('  1 AS COD_LOJA, ');
    SQL.Add('  '''' AS NUM_CGC, ');
    SQL.Add('  0 AS NUM_BORDERO, ');
    SQL.Add('  NOTA.numeroNota AS NUM_NF, ');
    SQL.Add('  NOTA.serieDocumentoFiscal AS NUM_SERIE_NF, ');
    SQL.Add('  NOTA.valorPago AS VAL_TOTAL_NF, ');
    SQL.Add('  TITULO.observacoes AS DES_OBSERVACAO, ');
    SQL.Add('  1 AS NUM_PDV, ');
    SQL.Add('  NULL AS NUM_CUPOM_FISCAL, ');
    SQL.Add('  0 AS COD_MOTIVO,  ');
    SQL.Add('  0 AS COD_CONVENIO,  ');
    SQL.Add('  0 AS COD_BIN,  ');
    SQL.Add('  '''' AS DES_BANDEIRA,  ');
    SQL.Add('  '''' AS DES_REDE_TEF,  ');
    SQL.Add('  0 AS VAL_RETENCAO,  ');
    SQL.Add('  2 AS COD_CONDICAO,  ');
    SQL.Add('  TITULO.dataPagamento AS DTA_PAGTO, ');
    SQL.Add('  TITULO.dataMovimento AS DTA_ENTRADA, ');
    SQL.Add('  0 AS NUM_NOSSO_NUMERO,  ');
    SQL.Add('  '''' AS COD_BARRA,  ');
    SQL.Add('  ''N'' AS FLG_BOLETO_EMIT,  ');
    SQL.Add('  NULL AS NUM_CGC_CPF_TITULAR,  ');
    SQL.Add('  NULL AS DES_TITULAR,  ');
    SQL.Add('  30 AS NUM_CONDICAO,  ');
    SQL.Add('  0 AS VAL_CREDITO,  ');
    SQL.Add('  999 AS COD_BANCO_PGTO,       ');
    SQL.Add('  ''PAGTO'' AS DES_CC,    ');
    SQL.Add('  0 AS COD_BANDEIRA,       ');
    SQL.Add('  '''' AS DTA_PRORROGACAO,    ');
    SQL.Add('  1 AS NUM_SEQ_FIN,       ');
    SQL.Add('  0 AS COD_COBRANCA,       ');
    SQL.Add('  '''' AS DTA_COBRANCA,    ');
    SQL.Add('  ''N'' AS FLG_ACEITE,    ');
    SQL.Add('  0 AS TIPO_ACEITE  ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_FINANCEIRO TITULO ');
    SQL.Add('    LEFT JOIN TOTAL_NFE NOTA ON TITULO.IDNFE = NOTA.IDNFE ');
    SQL.Add('WHERE ');
    SQL.Add('  TITULO.IDNFE IS NOT NULL ');
    SQL.Add('  AND ');
    SQL.Add('  NOTA.idEmpresaEmitente <> 1 ');
    SQL.Add('  AND ');
    SQL.Add('  NOTA.tipoOperacao = 1 ');
    SQL.Add('  AND ');
    SQL.Add('  CAST(TITULO.DATAMOVIMENTO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
    SQL.Add('  AND');
    SQL.Add('  CAST(TITULO.DATAMOVIMENTO AS DATE) <= '''+FormatDateTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

    // ABERTO = 1 : ABERTO ELSE QUITADO

    if Aberto = '1' then
      SQL.Add(' AND TITULO.valor <> TITULO.valorpago') //SQL.Add(' AND TITULO.dataPagamento IS NULL ')
    else
      SQL.Add(' AND TITULO.valor = TITULO.valorpago'); //SQL.Add(' AND TITULO.dataPagamento IS NOT NULL ');

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
        Layout.FieldByName('NUM_NF').AsString         := StrRetNums(QryPrincipal2.FieldByName('NUM_NF').AsString);
        Layout.FieldByName('NUM_CGC').AsString        := StrRetNums(QryPrincipal2.FieldByName('NUM_CGC').AsString);

        if QryPrincipal2.FieldByName('DTA_EMISSAO').AsString <> '' then
          Layout.FieldByName('DTA_EMISSAO').AsString := FormatDateTime('dd/mm/yyyy', QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsString <> '' then
          Layout.FieldByName('DTA_VENCIMENTO').AsString:= FormatDateTime('dd/mm/yyyy', QryPrincipal2.FieldByName('DTA_VENCIMENTO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_QUITADA').AsString <> '' then
          Layout.FieldByName('DTA_QUITADA').AsString:= FormatDateTime('dd/mm/yyyy', QryPrincipal2.FieldByName('DTA_QUITADA').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_PAGTO').AsString <> '' then
          Layout.FieldByName('DTA_PAGTO').AsString:= FormatDateTime('dd/mm/yyyy', QryPrincipal2.FieldByName('DTA_PAGTO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_ENTRADA').AsString <> '' then
          Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy', QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime);

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.GerarFinanceiroReceber(Aberto: String);
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT  ');
    SQL.Add('  0 AS TIPO_PARCEIRO,  ');
    SQL.Add('  TITULO.IDCLIENTE AS COD_PARCEIRO,  ');
    SQL.Add('  1 AS TIPO_CONTA,  ');
    SQL.Add('  4 AS COD_ENTIDADE,  ');
    SQL.Add('  VENDA.NUMCOMANDA AS NUM_DOCTO,  ');
    SQL.Add('  999 AS COD_BANCO,  ');
    SQL.Add('  '''' AS DES_BANCO,  ');
    SQL.Add('  TITULO.DATAMOVIMENTO AS DTA_EMISSAO,  ');
    SQL.Add('  TITULO.DATAVENCIMENTO AS DTA_VENCIMENTO,  ');
//    SQL.Add('  TITULO.VALOR AS VAL_PARCELA,  ');
    SQL.Add('  CASE WHEN TITULO.valor = TITULO.valorpago THEN TITULO.valor else TITULO.valor - TITULO.valorpago END AS VAL_PARCELA, ');
    SQL.Add('  TITULO.valorJuros AS VAL_JUROS,  ');
    SQL.Add('  TITULO.desconto AS VAL_DESCONTO,  ');
    SQL.Add('  CASE WHEN TITULO.valor = TITULO.valorpago THEN ''S'' ELSE ''N'' END AS FLG_QUITADO, ');
    SQL.Add('  TITULO.dataPagamento AS DTA_QUITADA,  ');
    SQL.Add('  997 AS COD_CATEGORIA,   ');
    SQL.Add('  997 AS COD_SUBCATEGORIA,   ');
    SQL.Add('  TITULO.parcela AS NUM_PARCELA,  ');
    SQL.Add('  TITULO.totalParcelas AS QTD_PARCELA,  ');
    SQL.Add('  1 AS COD_LOJA,  ');
    SQL.Add('  '''' AS NUM_CGC,  ');
    SQL.Add('  0 AS NUM_BORDERO,  ');
    SQL.Add('  0 AS NUM_NF,  ');
    SQL.Add('  0 AS NUM_SERIE_NF,  ');
    SQL.Add('  0 AS VAL_TOTAL_NF,  ');
    SQL.Add('  TITULO.observacoes AS DES_OBSERVACAO,  ');
    SQL.Add('  1 AS NUM_PDV,  ');
    SQL.Add('  NULL AS NUM_CUPOM_FISCAL,  ');
    SQL.Add('  0 AS COD_MOTIVO,   ');
//    SQL.Add('  0 AS COD_CONVENIO,   ');
    SQL.Add('  99999 AS COD_CONVENIO,   ');
    SQL.Add('  0 AS COD_BIN,   ');
    SQL.Add('  '''' AS DES_BANDEIRA,   ');
    SQL.Add('  '''' AS DES_REDE_TEF,   ');
    SQL.Add('  0 AS VAL_RETENCAO,   ');
    SQL.Add('  2 AS COD_CONDICAO,   ');
    SQL.Add('  TITULO.dataPagamento AS DTA_PAGTO,  ');
    SQL.Add('  TITULO.dataMovimento AS DTA_ENTRADA,  ');
    SQL.Add('  0 AS NUM_NOSSO_NUMERO,   ');
    SQL.Add('  '''' AS COD_BARRA,   ');
    SQL.Add('  ''N'' AS FLG_BOLETO_EMIT,   ');
    SQL.Add('  NULL AS NUM_CGC_CPF_TITULAR,   ');
    SQL.Add('  NULL AS DES_TITULAR,   ');
    SQL.Add('  30 AS NUM_CONDICAO,   ');
    SQL.Add('  0 AS VAL_CREDITO,   ');
    SQL.Add('  999 AS COD_BANCO_PGTO,        ');
    SQL.Add('  ''RECEBTO-1'' AS DES_CC,     ');
    SQL.Add('  0 AS COD_BANDEIRA,        ');
    SQL.Add('  '''' AS DTA_PRORROGACAO,     ');
    SQL.Add('  1 AS NUM_SEQ_FIN,        ');
    SQL.Add('  0 AS COD_COBRANCA,        ');
    SQL.Add('  '''' AS DTA_COBRANCA,     ');
    SQL.Add('  ''N'' AS FLG_ACEITE,     ');
    SQL.Add('  0 AS TIPO_ACEITE   ');
    SQL.Add('FROM  ');
    SQL.Add('  TOTAL_FINANCEIRO TITULO  ');
    SQL.Add('    LEFT JOIN TOTAL_VENDA VENDA ON TITULO.IDVENDA = VENDA.IDVENDA AND TITULO.IDCLIENTE = VENDA.IDCLIENTE ');
    SQL.Add('WHERE  ');
    SQL.Add('  TITULO.IDVENDA IS NOT NULL ');
    SQL.Add('  AND ');
    SQL.Add('  TITULO.IDCLIENTE IS NOT NULL ');
    SQL.Add('  AND ');
    SQL.Add('  CAST(TITULO.DATAMOVIMENTO AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
    SQL.Add('  AND');
    SQL.Add('  CAST(TITULO.DATAMOVIMENTO AS DATE) <= '''+FormatDateTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

    // ABERTO = 1 : ABERTO ELSE QUITADO
    if Aberto = '1' then
      SQL.Add(' AND TITULO.valor <> TITULO.valorpago') //SQL.Add(' AND TITULO.dataPagamento IS NULL ')
    else
      SQL.Add(' AND TITULO.valor = TITULO.valorpago'); //SQL.Add(' AND TITULO.dataPagamento IS NOT NULL ');

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

        Layout.FieldByName('DES_OBSERVACAO').AsString   := StrLBReplace(QryPrincipal2.FieldByName('DES_OBSERVACAO').AsString);
        Layout.FieldByName('NUM_NF').AsString           := StrRetNums(QryPrincipal2.FieldByName('NUM_NF').AsString);
        Layout.FieldByName('NUM_CUPOM_FISCAL').AsString := StrRetNums(QryPrincipal2.FieldByName('NUM_CUPOM_FISCAL').AsString);
        Layout.FieldByName('NUM_CGC').AsString          := StrRetNums(QryPrincipal2.FieldByName('NUM_CGC').AsString);

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

        //ShowMessage(FormatFloat('#,##0.00', QryPrincipal2.FieldByName('VAL_PARCELA').AsFloat));

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.GerarFornecedor;
var
  inscEst: String;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  IDEMPRESA AS COD_FORNECEDOR, ');
    SQL.Add('  CASE WHEN RAZAOSOCIAL <> '''' THEN RAZAOSOCIAL ELSE NOMECOMPLETO END AS DES_FORNECEDOR, ');
    SQL.Add('  CASE WHEN NOMEFANTASIA <> '''' THEN NOMEFANTASIA ELSE RAZAOSOCIAL END AS DES_FANTASIA, ');
    SQL.Add(' ');
    SQL.Add('  CASE   ');
    SQL.Add('    WHEN REPLACE(REPLACE(REPLACE(CNPJ, ''.'', ''''), ''-'', ''''), ''/'', '''') <> '''' THEN   ');
    SQL.Add('	  REPLACE(REPLACE(REPLACE(CNPJ, ''.'', ''''), ''-'', ''''), ''/'', '''')   ');
    SQL.Add('	ELSE   ');
    SQL.Add('	  REPLACE(REPLACE(REPLACE(CPF, ''.'', ''''), ''-'', ''''), ''/'', '''')   ');
    SQL.Add('	END AS NUM_CGC, ');
    SQL.Add(' ');
    SQL.Add('  REPLACE(REPLACE(INSCRICAOESTADUAL, ''.'', ''''), ''-'', '''') AS NUM_INSC_EST, ');
    SQL.Add('  ENDERECO AS DES_ENDERECO, ');
    SQL.Add('  BAIRRO AS DES_BAIRRO, ');
    SQL.Add('  UPPER(CIDADE.NOME) AS DES_CIDADE,  ');
    SQL.Add('  UPPER(ESTADO.UF) AS DES_SIGLA,  ');
    SQL.Add('  REPLACE(REPLACE(CEP, ''.'', ''''), ''-'', '''') AS NUM_CEP,  ');
    SQL.Add('  TELEFONE AS NUM_FONE, ');
    SQL.Add('  '''' AS NUM_FAX, ');
    SQL.Add('  '''' AS DES_CONTATO, ');
    SQL.Add('  0 AS QTD_DIA_CARENCIA, ');
    SQL.Add('  0 AS NUM_FREQ_VISITA, ');
    SQL.Add('  0 AS VAL_DESCONTO, ');
    SQL.Add('  0 AS NUM_PRAZO, ');
    SQL.Add('  ''N'' AS ACEITA_DEVOL_MER,  ');
    SQL.Add('  ''N'' AS CAL_IPI_VAL_BRUTO,  ');
    SQL.Add('  ''N'' AS CAL_ICMS_ENC_FIN,  ');
    SQL.Add('  ''N'' AS CAL_ICMS_VAL_IPI,  ');
    SQL.Add('  ''N'' AS MICRO_EMPRESA, ');
    SQL.Add('  0 AS COD_FORNECEDOR_ANT, ');
    SQL.Add('  '''' AS NUM_ENDERECO, ');
    SQL.Add('  '''' AS DES_OBSERVACAO, ');
    SQL.Add('  EMAIL AS DES_EMAIL, ');
    SQL.Add('  '''' AS DES_WEB_SITE, ');
    SQL.Add('  ''N'' AS FABRICANTE, ');
    SQL.Add('  '''' AS FLG_PRODUTOR_RURAL, ');
    SQL.Add('  0 AS TIPO_FRETE, ');
    SQL.Add('  ''N'' AS FLG_SIMPLES, ');
    SQL.Add('  ''N'' AS FLG_SUBSTITUTO_TRIB,    ');
    SQL.Add('  0 AS COD_CONTACCFORN,  ');
    SQL.Add('  ''N'' AS INATIVO,      ');
    SQL.Add('  0 AS COD_CLASSIF,  ');
    SQL.Add('  NULL  AS DTA_CADASTRO,  ');
    SQL.Add('  0 AS VAL_CREDITO,  ');
    SQL.Add('  0 AS VAL_DEBITO,  ');
    SQL.Add('  0 AS PED_MIN_VAL,  ');
    SQL.Add('  EMAIL AS DES_EMAIL_VEND,  ');
    SQL.Add('  '''' AS SENHA_COTACAO,  ');
    SQL.Add('  -1 AS TIPO_PRODUTOR,   ');
    SQL.Add('  '''' AS NUM_CELULAR       ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_EMPRESA FORN     ');
    SQL.Add('    LEFT JOIN TOTAL_CIDADE AS CIDADE ON FORN.IDCIDADE = CIDADE.IDCIDADE  ');
    SQL.Add('    LEFT JOIN TOTAL_ESTADO AS ESTADO ON ESTADO.IDESTADO = CIDADE.IDESTADO	  ');

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

        Layout.FieldByName('DES_FORNECEDOR').AsString := StrSubstLtsAct(Layout.FieldByName('DES_FORNECEDOR').AsString);
        Layout.FieldByName('DES_FANTASIA').AsString   := StrSubstLtsAct(Layout.FieldByName('DES_FANTASIA').AsString);
        Layout.FieldByName('DES_BAIRRO').AsString     := StrSubstLtsAct(Layout.FieldByName('DES_BAIRRO').AsString);
        Layout.FieldByName('DES_ENDERECO').AsString   := StrSubstLtsAct(Layout.FieldByName('DES_ENDERECO').AsString);

        Layout.FieldByName('NUM_CGC').AsString        := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);
        Layout.FieldByName('NUM_CEP').AsString        := StrRetNums(Layout.FieldByName('NUM_CEP').AsString);
        Layout.FieldByName('NUM_ENDERECO').AsString   := StrRetNums(Layout.FieldByName('NUM_ENDERECO').AsString);

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
        Layout.FieldByName('NUM_FAX').AsString  := StrRetNums( FieldByName('NUM_FAX').AsString );

        inscEst    := StrRetNums(Layout.FieldByName('NUM_INSC_EST').AsString);

        if( inscEst = '' ) then
          Layout.FieldByName('NUM_INSC_EST').AsString := 'ISENTO'
        else begin
           if StrToFloat(inscEst) = 0 then
             Layout.FieldByName('NUM_INSC_EST').AsString := ''
           else
             Layout.FieldByName('NUM_INSC_EST').AsString := inscEst;
        end;

        Layout.FieldByName('DTA_CADASTRO').AsDateTime := Date;

        if Layout.FieldByName('NUM_CEP').AsString = '' then
          Layout.FieldByName('NUM_CEP').AsString := '19806170';

        if Layout.FieldByName('DES_ENDERECO').AsString = '' then
          Layout.FieldByName('DES_ENDERECO').AsString := 'A DEFINIR';

        if Layout.FieldByName('DES_BAIRRO').AsString = '' then
          Layout.FieldByName('DES_BAIRRO').AsString := 'A DEFINIR';

        if Layout.FieldByName('DES_CIDADE').AsString = '' then
          Layout.FieldByName('DES_CIDADE').AsString := 'ASSIS';

        if Layout.FieldByName('DES_SIGLA').AsString = '' then
          Layout.FieldByName('DES_SIGLA').AsString := 'SP';

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

procedure TFrmSmBomDeCarne.GerarCondPagForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  IDEMPRESA AS COD_FORNECEDOR, ');
    SQL.Add('  30 AS NUM_CONDICAO,  ');
    SQL.Add('  2 AS COD_CONDICAO,  ');
    SQL.Add('  8 AS COD_ENTIDADE,  ');
    SQL.Add('  '''' AS NUM_CGC    ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_EMPRESA FORN ');

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

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.GerarNCM;
var
 Count : Integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT DISTINCT ');
    SQL.Add('  0 AS COD_NCM, ');
    SQL.Add('  ''A DEFINIR'' AS DES_NCM, ');
    SQL.Add('  PROD.NCM AS NUM_NCM,   ');
    SQL.Add('  CASE WHEN PROD.PISALIQUOTA <> 0.00 THEN ''N'' ELSE ''S'' END AS FLG_NAO_PIS_COFINS,    ');
    SQL.Add(' ');
    SQL.Add('  CASE     ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 73) AND (PROD.PISCST = 06))THEN 0    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 70) AND (PROD.PISCST = 04))THEN 1    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 75) AND (PROD.PISCST = 05))THEN 2    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 74) AND (PROD.PISCST = 09))THEN 3    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 99) AND (PROD.PISCST = 49))THEN 3    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 72) AND (PROD.PISCST = 09))THEN 4    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 50) AND (PROD.PISCST = 01))THEN 0    ');
    SQL.Add('  ELSE -1 END AS TIPO_NAO_PIS_COFINS,    ');
    SQL.Add(' ');
    SQL.Add('  0 AS COD_TAB_SPED, ');
    SQL.Add(' ');
    SQL.Add('  PROD.CEST AS NUM_CEST, ');
    SQL.Add(' ');
    SQL.Add('  ''SP'' AS DES_SIGLA, ');
    SQL.Add(' ');
    SQL.Add(RetSQLAliquotaProduto + ' AS COD_TRIB_ENTRADA, ');
    SQL.Add(RetSQLAliquotaProduto + ' AS COD_TRIB_SAIDA, ');
    SQL.Add(' ');
    SQL.Add('  0 AS PER_IVA,   ');
    SQL.Add('  0 AS PER_FCP_ST  ');
    SQL.Add(' ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_PRODUTO PROD ');
    SQL.Add('    LEFT JOIN TOTAL_NCM NCM ON PROD.NCM = NCM.CODIGO ');
    SQL.Add('	LEFT JOIN TOTAL_NCM_CEST CEST ON PROD.NCM = CEST.NCM AND PROD.CEST = CEST.CEST ');


    Open;
    First;

    Count := 0;

    NumLinha := 0;

    while not Eof do
    begin
      try
        if Cancelar then
          Break;

        Inc(NumLinha);
        Inc(Count);
        Layout.SetValues(QryPrincipal2, NumLinha, RecordCount);

        Layout.FieldByName('COD_NCM').AsInteger := Count;

        if (Layout.FieldByName('DES_NCM').AsString = '')  then
          Layout.FieldByName('DES_NCM').AsString := 'A DEFINIR'
        else
          Layout.FieldByName('DES_NCM').AsString := Layout.FieldByName('DES_NCM').AsString;

        Layout.FieldByName('NUM_NCM').AsString  := StrRetNums(Layout.FieldByName('NUM_NCM').AsString);
        Layout.FieldByName('NUM_CEST').AsString := StrRetNums(Layout.FieldByName('NUM_CEST').AsString);

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.GerarNCMUF;
var
 count : Integer;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;


    SQL.Add('SELECT DISTINCT ');
    SQL.Add('  0 AS COD_NCM, ');
    SQL.Add('  ''A DEFINIR'' AS DES_NCM, ');
    SQL.Add('  PROD.NCM AS NUM_NCM,   ');
    SQL.Add('  CASE WHEN PROD.PISALIQUOTA <> 0.00 THEN ''N'' ELSE ''S'' END AS FLG_NAO_PIS_COFINS,    ');
    SQL.Add(' ');
    SQL.Add('  CASE     ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 73) AND (PROD.PISCST = 06))THEN 0    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 70) AND (PROD.PISCST = 04))THEN 1    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 75) AND (PROD.PISCST = 05))THEN 2    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 74) AND (PROD.PISCST = 09))THEN 3    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 99) AND (PROD.PISCST = 49))THEN 3    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 72) AND (PROD.PISCST = 09))THEN 4    ');
    SQL.Add('    WHEN ((PROD.COFINSCST = 50) AND (PROD.PISCST = 01))THEN 0    ');
    SQL.Add('  ELSE -1 END AS TIPO_NAO_PIS_COFINS,    ');
    SQL.Add(' ');
    SQL.Add('  0 AS COD_TAB_SPED, ');
    SQL.Add(' ');
    SQL.Add('  PROD.CEST AS NUM_CEST, ');
    SQL.Add(' ');
    SQL.Add('  ''SP'' AS DES_SIGLA, ');
    SQL.Add(' ');
    SQL.Add(RetSQLAliquotaProduto + ' AS COD_TRIB_ENTRADA, ');
    SQL.Add(RetSQLAliquotaProduto + ' AS COD_TRIB_SAIDA, ');
    SQL.Add(' ');
    SQL.Add('  0 AS PER_IVA,   ');
    SQL.Add('  0 AS PER_FCP_ST  ');
    SQL.Add(' ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_PRODUTO PROD ');
    SQL.Add('    LEFT JOIN TOTAL_NCM NCM ON PROD.NCM = NCM.CODIGO ');
    SQL.Add('	LEFT JOIN TOTAL_NCM_CEST CEST ON PROD.NCM = CEST.NCM AND PROD.CEST = CEST.CEST ');

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

procedure TFrmSmBomDeCarne.GerarNFFornec;
begin
  inherited;
  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  idEmpresaEmitente AS COD_FORNECEDOR, ');
    SQL.Add('  numeroNota AS NUM_NF_FORN, ');
    SQL.Add('  serieDocumentoFiscal AS NUM_SERIE_NF, ');
    SQL.Add('  serieDocumentoFiscal AS NUM_SUBSERIE_NF, ');
    SQL.Add('  cfop AS CFOP, ');
    SQL.Add('  0 AS TIPO_NF, ');
    SQL.Add('  ''NFE'' AS DES_ESPECIE, ');
    SQL.Add('  NOTA.valorPago AS VAL_TOTAL_NF, ');
    SQL.Add('  NOTA.dataEmissao AS DTA_EMISSAO, ');
    SQL.Add('  NOTA.dataSaidaOuEntrada AS DTA_ENTRADA, ');
    SQL.Add('  NOTA.ICMS_valorTotalIPI AS VAL_TOTAL_IPI, ');
    SQL.Add('  0 AS VAL_VENDA_VAREJO, ');
    SQL.Add('  NOTA.ICMS_valorTotalFrete AS VAL_FRETE, ');
    SQL.Add('  0 AS VAL_ACRESCIMO, ');
    SQL.Add('  0 AS VAL_DESCONTO, ');
    SQL.Add('  NULL AS NUM_CGC, ');
    SQL.Add('  NOTA.ICMS_baseCalculo AS VAL_TOTAL_BC, ');
    SQL.Add('  NOTA.ICMS_valorTotal AS VAL_TOTAL_ICMS, ');
    SQL.Add('  NOTA.ICMS_baseCalculoST AS VAL_BC_SUBST, ');
    SQL.Add('  NOTA.ICMS_valorTotalST AS VAL_ICMS_SUBST, ');
    SQL.Add('  0 AS VAL_FUNRURAL, ');
    SQL.Add(' ');
    SQL.Add('  CASE WHEN UPPER(NOTA.naturaOperacao) LIKE ''%BONIFICACAO%'' THEN 5 ELSE 1 END AS COD_PERFIL, ');
    SQL.Add(' ');
    SQL.Add('  0 AS VAL_DESP_ACESS,  ');
    SQL.Add('  CASE WHEN NOTA.dataCancelamento IS NOT NULL THEN ''S'' ELSE ''N'' END AS FLG_CANCELADO,  ');
    SQL.Add('  NOTA.observacoes AS DES_OBSERVACAO,  ');
    SQL.Add('  NOTA.chaveAcesso AS NUM_CHAVE_ACESSO ');
    SQL.Add('    ');
    SQL.Add(' ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_NFE NOTA ');
    SQL.Add('where ');
    SQL.Add('  tipoOperacao = 1 -- entrada ');
    SQL.Add('  AND ');
    SQL.Add('  idEmpresaEmitente <> 1 ');
    SQL.Add('  AND ');
    SQL.Add('  CAST(NOTA.dataSaidaOuEntrada AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
    SQL.Add('  AND  ');
    SQL.Add('  CAST(NOTA.dataSaidaOuEntrada AS DATE) <= '''+FormatDateTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

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

        if QryPrincipal2.FieldByName('DTA_EMISSAO').AsString <> '' then
          Layout.FieldByName('DTA_EMISSAO').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_EMISSAO').AsDateTime);

        if QryPrincipal2.FieldByName('DTA_ENTRADA').AsString <> '' then
          Layout.FieldByName('DTA_ENTRADA').AsString:= FormatDateTime('dd/mm/yyyy',QryPrincipal2.FieldByName('DTA_ENTRADA').AsDateTime);

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

procedure TFrmSmBomDeCarne.GerarNFitensFornec;
var
   NumLinha, TotalReg  :Integer;
   nota, serie, fornecedor, CodNf : string;
   count : integer;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  idEmpresaEmitente AS COD_FORNECEDOR, ');
    SQL.Add('  numeroNota AS NUM_NF_FORN, ');
    SQL.Add('  serieDocumentoFiscal AS NUM_SERIE_NF, ');
    SQL.Add('  NFITEM.idProdutoSistema as COD_PRODUTO, ');
    SQL.Add(' ');
    SQL.Add(RetSQLAliquotaNF + ' AS COD_TRIBUTACAO, ');
    SQL.Add(' ');
    SQL.Add('  NFITEM.quantidadeTrib / NFITEM.quantidade AS QTD_EMBALAGEM, ');
    SQL.Add('  NFITEM.quantidadeTrib AS QTD_ENTRADA, ');
    SQL.Add('  NFITEM.unidade AS DES_UNIDADE, ');
    SQL.Add('  NFITEM.valorUnitario AS VAL_TABELA, ');
    SQL.Add('  NFITEM.valorDesconto AS VAL_DESCONTO_ITEM, ');
    SQL.Add('  0 AS VAL_ACRESCIMO_ITEM, ');
    SQL.Add('  NFITEM.IPI_valor AS VAL_IPI_ITEM, ');
    SQL.Add('  NFITEM.ICMSST_valor AS VAL_SUBST_ITEM, ');
    SQL.Add('  NFITEM.valorFrete AS VAL_FRETE_ITEM, ');
    SQL.Add('  NFITEM.ICMS_valor AS VAL_CREDITO_ICMS, ');
    SQL.Add('  0 AS VAL_VENDA_VAREJO, ');
    SQL.Add('  NFITEM.valorTotalBruto AS VAL_TABELA_LIQ, ');
    SQL.Add('  NULL AS NUM_CGC, ');
    SQL.Add('  NFITEM.ICMS_baseCalculo AS VAL_TOT_BC_ICMS, ');
    SQL.Add('  0 AS VAL_TOT_OUTROS_ICMS, ');
    SQL.Add('  NFITEM.cfop AS CFOP, ');
    SQL.Add('  0 AS VAL_TOT_ISENTO, ');
    SQL.Add('  NFITEM.ICMSST_baseCalculo AS VAL_TOT_BC_ST, ');
    SQL.Add('  NFITEM.ICMSST_valor AS VAL_TOT_ST, ');
    SQL.Add('  NFITEM.numeroItem AS NUM_ITEM, ');
    SQL.Add('  0 AS TIPO_IPI, ');
    SQL.Add('  NFITEM.ncm AS NUM_NCM, ');
    SQL.Add('  NULL AS DES_REFERENCIA, ');
    SQL.Add('  0 AS VAL_DESP_ACESS_ITEM    ');
    SQL.Add(' ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_NFE NOTA ');
    SQL.Add('    LEFT JOIN TOTAL_NFE_ITEM NFITEM ON NOTA.idNfe = NFITEM.idNfe ');
    SQL.Add('where ');
    SQL.Add('  tipoOperacao = 1 -- entrada ');
    SQL.Add('  AND ');
    SQL.Add('  idEmpresaEmitente <> 1 ');
    SQL.Add('  AND ');
    SQL.Add('  CAST(NOTA.dataSaidaOuEntrada AS DATE) >= '''+FormatDateTime('yyyy-mm-dd',DtpInicial.Date)+''' ');
    SQL.Add('  AND  ');
    SQL.Add('  CAST(NOTA.dataSaidaOuEntrada AS DATE) <= '''+FormatDateTime('yyyy-mm-dd',DtpFinal.Date)+''' ');

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
        Layout.FieldByName('NUM_NCM').AsString     := StrRetNums(Layout.FieldByName('NUM_NCM').AsString);

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.GerarProdForn;
begin
  inherited;

  with QryPrincipal2 do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT ');
    SQL.Add('  PRODREF.CODPROD AS COD_PRODUTO, ');
    SQL.Add('  PRODREF.CODFORNEC AS COD_FORNECEDOR, ');
    SQL.Add('  PRODREF.CODREF AS DES_REFERENCIA, ');
    SQL.Add('  FORNECEDORES.CNPJ_CPF AS NUM_CGC, ');
    SQL.Add('  NULL AS COD_DIVISAO, ');
    SQL.Add('  ''UN'' AS DES_UNIDADE_COMPRA, ');
    SQL.Add('  1 AS QTD_EMBALAGEM_COMPRA, ');
    SQL.Add('  1 AS QTD_TROCA, ');
    SQL.Add('  ''N'' AS FLG_PREFERENCIAL ');
    SQL.Add('FROM  ');
    SQL.Add('  PRODREF ');
    SQL.Add('    LEFT JOIN FORNECEDORES ON(FORNECEDORES.CODFORNEC = PRODREF.CODFORNEC) ');
    SQL.Add('    LEFT JOIN PRODUTOS ON(PRODUTOS.CODPROD = PRODREF.CODPROD) ');

    SQL.Add('WHERE  ');
    SQL.Add('  PRODUTOS.IMPORTAR_PRODUTO = ''S'' ');

    SQL.Add('ORDER BY 1 ');

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
        Layout.FieldByName('NUM_CGC').AsString     := StrRetNums(Layout.FieldByName('NUM_CGC').AsString);

        Layout.WriteLine;
      except
        On E: Exception do
        FrmProgresso.AdicionarLog(QryPrincipal2.RecNo, 'E', E.Message);
      end;
      Next;
    end;
  end;
end;

procedure TFrmSmBomDeCarne.GerarProdLoja;
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

    SQL.Add('SELECT DISTINCT ');
    SQL.Add('  PROD.IDPRODUTO AS COD_PRODUTO, ');
    SQL.Add('  (SELECT AVG(CUSTO) FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO) AS VAL_CUSTO_REP,   ');
    SQL.Add('  (SELECT AVG(PRECOVENDA) FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO) AS VAL_VENDA, ');
    SQL.Add('  0.00 AS VAL_OFERTA, ');
    SQL.Add('  (SELECT SUM(QTDEVENDA) FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO) AS QTD_EST_VDA, ');
    SQL.Add('  '''' AS TECLA_BALANCA, ');

    SQL.Add(RetSQLAliquotaProduto + ' AS COD_TRIBUTACAO, ');

    SQL.Add('  (SELECT AVG(MARGEMLUCRO) FROM TOTAL_ESTOQUE WHERE IDPRODUTO = PROD.IDPRODUTO) AS VAL_MARGEM,   ');
    SQL.Add('  1 AS QTD_ETIQUETA, ');

    SQL.Add(RetSQLAliquotaProduto + ' AS COD_TRIB_ENTRADA, ');

    SQL.Add('  ''N'' AS FLG_INATIVO, ');
    SQL.Add('  PROD.IDPRODUTO AS COD_PRODUTO_ANT, ');
    SQL.Add('  PROD.NCM AS NUM_NCM, ');
    SQL.Add('  1 AS TIPO_NCM, ');
    SQL.Add('  0.00 AS VAL_VENDA_2, ');
    SQL.Add('  NULL AS DTA_VALIDA_OFERTA, ');
    SQL.Add('  ESTOQUE.ESTOQUEMINIMOVENDA AS QTD_EST_MINIMO, ');
    SQL.Add('  NULL AS COD_VASILHAME, ');
    SQL.Add('  0 AS FORA_LINHA,   ');
    SQL.Add('  0 AS QTD_PRECO_DIF,   ');
    SQL.Add('  0 AS VAL_FORCA_VDA,     ');
    SQL.Add('  PROD.CEST AS NUM_CEST, ');
    SQL.Add('  0 AS PER_IVA,       ');
    SQL.Add('  0 AS PER_FCP_ST,       ');
    SQL.Add('  0 AS PER_FIDELIDADE,       ');
    SQL.Add('  0 AS COD_INFO_RECEITA     ');
    SQL.Add('FROM ');
    SQL.Add('  TOTAL_PRODUTO PROD ');
    SQL.Add('    LEFT JOIN TOTAL_ESTOQUE ESTOQUE ON PROD.IDPRODUTO = ESTOQUE.IDPRODUTO ');

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
        Layout.FieldByName('COD_PRODUTO').AsString := Layout.FieldByName('COD_PRODUTO').AsString;
        Layout.FieldByName('NUM_NCM').AsString     := StrRetNums(Layout.FieldByName('NUM_NCM').AsString);
        Layout.FieldByName('NUM_CEST').AsString    := StrRetNums(Layout.FieldByName('NUM_CEST').AsString);

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

end.
