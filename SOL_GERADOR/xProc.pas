unit xProc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, StdCtrls, ComCtrls, DB, SqlExpr, FMTBcd, ADODB,
  ExtCtrls, DateUtils, jpeg, TabNotBk, ShellAPI, IniFiles, WideStrings,
  DBXFirebird, DBXMsSQL, Filectrl, Math, Provider, DBClient;

procedure AbrirBancoAccess(Form: TForm; Edt: TEdit); overload;
procedure AbrirBancoAccess(Form: TForm; Edt: TEdit; NomeConexao: String); overload;
procedure AbrirBancoFB(Form: TForm; Edt: TEdit); overload;
procedure AbrirBancoFB(Form: TForm; Edt: TEdit; NomeConexao: String); overload;
procedure CriarOracle(EdtSenha, EdtSchema, EdtInst, EdtIp: TEdit);
procedure CriarFB(Edt: TEdit);
function  CriarConexaoFB(Edt: TEdit) : TSQLConnection;
procedure CriarAccess(Edt: TEdit);
function CriarConexaoAccess(Edt: TEdit) : TADOConnection;
procedure CriarMySql(EdtHost, EdtPorta, EdtBD, EdtUser, EdtSenha : TEdit);
procedure CriarSQLServer(EdtSenhaSqlSer, EdtUsuarioSqlSer, EdtIpSqlSer, EdtBancoSqlSer : TEdit);
procedure CriarPostGre(UserEdt, PasswordEdt, DataBaseEdt, HostNameEdt: TEdit);
Procedure AbrirBancoDBF(Form: TForm; Edt: TEdit);
Function ExtractName(const Filename: String): String;
Function DelZeroLeft(const S: string): string;
function strLeft(const S: string; Len: Integer): string;
function Split(aValue: string; aDelimiter: Char): TStringList;

implementation

uses UFrmModelo, UProgresso;

Function ExtractName(const Filename: String): String;
{Retorna o nome do Arquivo sem extens�o}
var
aExt : String;
aPos : Integer;
begin
aExt := ExtractFileExt(Filename);
Result := ExtractFileName(Filename);
if aExt <> '' then
   begin
   aPos := Pos(aExt,Result);
   if aPos > 0 then
      begin
      Delete(Result,aPos,Length(aExt));
      end;
   end;
end;


procedure AbrirBancoAccess(Form: TForm; Edt: TEdit); overload;
var
  OpdBanco: TOpenDialog;
begin
  OpdBanco := TOpenDialog.Create(Form);
  with OpdBanco do
  begin
    DefaultExt := 'accdb';
    Filter := 'Arquivo do Access 2007(accdb)|*.accdb';
    Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
    //InitialDir := ExtractFilePath(ArqConf.ReadString(Nome, 'Banco', ''));
    if Execute then
    begin
      Edt.Text := FileName;
      ArqConf := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'gerador.ini');
      ArqConf.WriteString(Nome, Edt.Name, Edt.Text);
    end;
  end;
end;

procedure AbrirBancoAccess(Form: TForm; Edt: TEdit; NomeConexao: String); overload;
var
  OpdBanco: TOpenDialog;
begin
  OpdBanco := TOpenDialog.Create(Form);
  with OpdBanco do
  begin
    DefaultExt := 'accdb';
    Filter := 'Arquivo do Access 2007(accdb)|*.accdb';
    Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
    //InitialDir := ExtractFilePath(ArqConf.ReadString(Nome, 'Banco', ''));
    if Execute then
    begin
      Edt.Text := FileName;
      ArqConf := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'gerador.ini');
      ArqConf.WriteString(Nome, 'Banco' + NomeConexao, Edt.Text);
    end;
  end;
end;

procedure CriarAccess(Edt: TEdit);
begin
  TipoBD := 2;
  AcoBanco := TADOConnection.Create(FrmProgresso);
  with AcoBanco do
  begin
    ConnectionString := 'Provider=Microsoft.ACE.OLEDB.12.0;Data Source='
     + Edt.Text + ';Persist Security Info=False';
    LoginPrompt := False;
    Open;
  end;
  ArqConf.WriteInteger(Nome, 'BD', TipoBD);
end;

function CriarConexaoAccess(Edt: TEdit) : TADOConnection;
var Conexao : TADOConnection;
begin
  Conexao := TADOConnection.Create(FrmProgresso);
  with Conexao do
  begin
    ConnectionString := 'Provider=Microsoft.ACE.OLEDB.12.0;Data Source='
     + Edt.Text + ';Persist Security Info=False';
    LoginPrompt := False;
    Open;
  end;
  Result := Conexao;
end;

procedure AbrirBancoFB(Form: TForm; Edt: TEdit); overload;
var
  OpdBanco: TOpenDialog;
begin
  with Form do
  begin
    OpdBanco := TOpenDialog.Create(Form);
    with OpdBanco do
    begin
      DefaultExt := 'fdb';
      Filter := 'Firebird Database|*.fdb|InterBase 7.0 database|*.ib|InterBase database|*.gdb|Todos os arquivos|*.*';
      Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
      //InitialDir := ExtractFilePath(ArqConf.ReadString(Nome, 'Banco', ''));
      if Execute then
      begin
        Edt.Text := FileName;
        ArqConf := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'gerador.ini');
        ArqConf.WriteString(Nome, Edt.Name, FileName);
      end;
    end; //OpdBanco
  end; //with FrmPrincipal
end;

procedure AbrirBancoFB(Form: TForm; Edt: TEdit; NomeConexao: String); overload;
var
  OpdBanco: TOpenDialog;
begin
  with Form do
  begin
    OpdBanco := TOpenDialog.Create(Form);
    with OpdBanco do
    begin
      DefaultExt := 'fdb';
      Filter := 'Firebird Database|*.fdb|InterBase 7.0 database|*.ib|InterBase database|*.gdb|Todos os arquivos|*.*';
      Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
      //InitialDir := ExtractFilePath(ArqConf.ReadString(Nome, 'Banco', ''));
      if Execute then
      begin
        Edt.Text := FileName;
        ArqConf := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'gerador.ini');
        ArqConf.WriteString(Nome, Edt.Name, FileName);
      end;
    end; //OpdBanco
  end; //with FrmPrincipal
end;

procedure CriarFB(Edt: TEdit);
begin
  TipoBD := 1;
  ScnBanco := TSQLConnection.Create(FrmProgresso);
  with ScnBanco do
  begin
    Close;
    LibraryName := 'dbxfb.dll';
    GetDriverFunc := 'getSQLDriverINTERBASE';
    DriverName := 'Firebird';
    VendorLib := 'fbclient.dll';
    LoadParamsOnConnect := False;
    LoginPrompt := False;
    Params.Values['DriverName'] := 'Firebird';
//    Params.Values['DriverName'] := 'Interbase';
    Params.Values['DataBase'] := Edt.Text;
    Params.Values['RoleName'] := '';
    Params.Values['User_Name'] := 'SYSDBA';
    Params.Values['Password'] := 'masterkey'; //masterkey  nardos
    Params.Values['ServerCharSet'] := '';
    Params.Values['SQLDialect'] := '3';
    Params.Values['ErrorResourceFile'] := '';
    Params.Values['LocaleCode'] := '0000';
    Params.Values['BlobSize'] := '-1';
    Params.Values['CommitRetain'] := 'False';
    Params.Values['WaitOnLocks'] := 'True';
    Params.Values['InterBase TransIsolation'] := 'ReadCommited';
    Params.Values['Trim Char'] := 'False';
    Open;
  end;
  ArqConf.WriteInteger(Nome, 'BD', TipoBD);
end;

function  CriarConexaoFB(Edt: TEdit) : TSQLConnection;
var Conexao : TSQLConnection;
begin
  Conexao := TSQLConnection.Create(FrmProgresso);
  with Conexao do
  begin
    Close;
    LibraryName := 'dbxfb.dll';
    GetDriverFunc := 'getSQLDriverINTERBASE';
    DriverName := 'Firebird';
    VendorLib := 'fbclient.dll';
    LoadParamsOnConnect := False;
    LoginPrompt := False;
    Params.Values['DriverName'] := 'Firebird';
//    Params.Values['DriverName'] := 'Interbase';
    Params.Values['DataBase'] := Edt.Text;
    Params.Values['RoleName'] := '';
    Params.Values['User_Name'] := 'sysdba';
    Params.Values['Password'] := 'masterkey'; //masterkey  nardos
    Params.Values['ServerCharSet'] := '';
    Params.Values['SQLDialect'] := '3';
    Params.Values['ErrorResourceFile'] := '';
    Params.Values['LocaleCode'] := '0000';
    Params.Values['BlobSize'] := '-1';
    Params.Values['CommitRetain'] := 'False';
    Params.Values['WaitOnLocks'] := 'True';
    Params.Values['InterBase TransIsolation'] := 'ReadCommited';
    Params.Values['Trim Char'] := 'False';
    Open;
  end;
  Result := Conexao;
end;

procedure CriarOracle(EdtSenha, EdtSchema, EdtInst, EdtIp: TEdit);
begin
  TipoBD := 3;
  {OrclBanco := TADOConnection.Create(FrmProgresso);
  with OrclBanco do
  begin
  ConnectionString := 'Provider=MSDAORA.1;Password='+ EdtSenha.Text +';' +
                       'User ID='+ EdtSchema.Text + ';Data Source='+ EdtInst.Text +
                       ';Persist Security Info=True';
  Open;
  end;}
  OrclBanco := TSQLConnection.Create(FrmProgresso);
  with OrclBanco do
  begin
    Close;

      ConnectionName := 'OracleConnection';
      LibraryName := 'dbxora30.dll';
//        LibraryName := 'dbxora.dll';
//        LibraryName := 'oci.dll';
      GetDriverFunc := 'getSQLDriverORACLE';
      DriverName := 'Oracle';
      VendorLib := 'oci.dll';
      Params.Values['DriverName'] := 'Oracle';
      if LowerCase(EdtIp.Text) = 'localhost' then
        Params.Values['DataBase'] := EdtInst.Text
      else
        Params.Values['DataBase']    := EdtIp.Text;
      LoginPrompt                    := False;
      Params.Values['RoleName']      := '';
      Params.Values['User_Name']     := EdtSchema.Text;
      Params.Values['Password']      := EdtSenha.Text;
      Params.Values['ServerCharSet'] := '';
      Params.Values['SQLDialect']    := '3';
      Params.Values['ErrorResourceFile'] := '';
      Params.Values['LocaleCode'] := '0000';
      Params.Values['BlobSize'] := '-1';
      Params.Values['CommitRetain'] := 'False';
      Params.Values['WaitOnLocks'] := 'True';
      Params.Values['InterBase TransIsolation'] := 'ReadCommited';
      Params.Values['Trim Char'] := 'False';

      {
      DriverName                             := 'DevartOracle';
      GetDriverFunc                          := 'getSQLDriverORA';
      LoginPrompt                            := False;
      Params.Values['BlobSize']              := '-1';
      Params.Values['ErrorResourceFile']     := '';
      Params.Values['LocaleCode']            := '0000';
      Params.Values['Oracle TransIsolation'] := 'ReadCommited';
      Params.Values['RoleName']              := 'Normal';
      Params.Values['LongStrings']           := 'True';
      Params.Values['UseQuoteChar']          := 'True';
      Params.Values['FetchAll']              := 'False';
      Params.Values['CharLength']            := '0';
      // Os par�metros abaixo permitem configurar o NUMBER(38) do ORACLE para INTEGER!!! EXTREMAMENTE IMPORTANTE, SEN�O OS DATAFIELDS DEVER�O SER TODOS FLOAT!!
      Params.Values['BCDPrecision']          := '0';
      Params.Values['FloatPrecision']        := '38';
      Params.Values['IntegerPrecision']      := '38';
      Params.Values['User_Name']             := EdtSchema.Text;
      Params.Values['Password']              := EdtSenha.Text;
      if UpperCase( EdtIp.Text ) = 'LOCALHOST' then
        Params.Values['DataBase'] := EdtInst.Text
      else
        Params.Values['DataBase'] := EdtIp.Text+ ':' + EdtInst.Text;}
      Open;
  end;
  ArqConf.WriteInteger(Nome, 'BD', TipoBD);
end;

procedure CriarMySql(EdtHost, EdtPorta, EdtBD, EdtUser, EdtSenha: TEdit);
begin
  TipoBD := 4;
  MySqlBanco := TSQLConnection.Create(FrmProgresso);
  with MySqlBanco do
  begin
   Close;
    ConnectionName := 'MSSQLConnection';
    LibraryName := 'dbxmys.dll';
    GetDriverFunc := 'getSQLDriverMSSQL';
    DriverName := 'MySQL';
    VendorLib := 'libmysql.dll';
    Params.Values['DriverName'] := 'MySQL';
    Params.Values['HostName'] := EdtHost.Text;
    Params.Values['DataBase'] := EdtBD.Text;
    Params.Values['RoleName'] := '';
    Params.Values['User_Name'] := EdtUser.Text;
    Params.Values['Password'] := EdtSenha.Text;
    Params.Values['ServerCharSet'] := '';
    Params.Values['SQLDialect'] := '3';
    Params.Values['ErrorResourceFile'] := '';
    Params.Values['LocaleCode'] := '0000';
    Params.Values['BlobSize'] := '-1';
    Params.Values['CommitRetain'] := 'False';
    Params.Values['WaitOnLocks'] := 'True';
    Params.Values['InterBase TransIsolation'] := 'ReadCommited';
    Params.Values['Trim Char'] := 'False';
    LoginPrompt := False;
    Open;
  end;
  ArqConf.WriteInteger(Nome, 'BD', TipoBD);
end;

procedure CriarSQLServer(EdtSenhaSqlSer, EdtUsuarioSqlSer, EdtIpSqlSer, EdtBancoSqlSer : TEdit);
begin
  TipoBD := 5;
  SqlServerBanco := TSQLConnection.Create(FrmProgresso);
  with SqlServerBanco do
  begin
    Close;
    ConnectionName := 'MSSQLConnection';
    LibraryName := 'dbxmss.dll';
    GetDriverFunc := 'getSQLDriverMSSQL';
    DriverName := 'MSSQL';
    VendorLib := 'sqlncli10.dll';
    Params.Values['DriverName'] := 'MSSQL';
    Params.Values['HostName'] := EdtIpSqlSer.Text;
    Params.Values['DataBase'] := EdtBancoSqlSer.Text;
    Params.Values['RoleName'] := '';
    Params.Values['User_Name'] := EdtUsuarioSqlSer.Text;
    Params.Values['Password'] := EdtSenhaSqlSer.Text;
    Params.Values['ServerCharSet'] := '';
    Params.Values['SQLDialect'] := '3';
    Params.Values['ErrorResourceFile'] := '';
    Params.Values['LocaleCode'] := '0000';
    Params.Values['BlobSize'] := '-1';
    Params.Values['CommitRetain'] := 'False';
    Params.Values['WaitOnLocks'] := 'True';
    Params.Values['InterBase TransIsolation'] := 'ReadCommited';
    Params.Values['Trim Char'] := 'False';
    LoginPrompt := False;
    Open;
  end;
  ArqConf.WriteInteger(Nome, 'BD', TipoBD);
end;

procedure CriarPostGre(UserEdt, PasswordEdt, DataBaseEdt, HostNameEdt: TEdit);
begin
  TipoBD := 6;
  {ZcoBanco := TZConnection.Create(FrmProgresso);
  with ZcoBanco do
  begin
    //configura a conecx�o com o banco
    Protocol    := '7.4';
    User        := UserEdt.Text;
    Password    := PasswordEdt.Text;
    Port        := 5432;
    DataBase    := DataBaseEdt.Text;
    HostName    := HostNameEdt.Text;
    LoginPrompt := False;
    Connect;
  end;}
  ArqConf.WriteInteger(Nome, 'BD', TipoBD);
end;

Procedure AbrirBancoDBF(Form: TForm; Edt: TEdit);
var
  OpdBanco: TOpenDialog;
begin
  TipoBD := 7;
  OpdBanco := TOpenDialog.Create(Form);
  with OpdBanco do
  begin
    DefaultExt := 'dbf';
    Filter := '*.dbf';
    //Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
    //InitialDir := ExtractFilePath(ArqConf.ReadString(Nome, 'Banco', ''));
    if Execute then
    begin
      Edt.Text := ExtractFilePath(FileName);
      ArqConf := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'gerador.ini');
     // ArqConf.WriteString(Nome, 'Banco', Edt.Text);
     ArqConf.WriteInteger(Nome, 'BD', TipoBD);
    end;
  end;
end;
Function DelZeroLeft(const S: string): string;
begin
  Result := S;
  repeat
    if StrLeft(Result, 1) = '0' then
      Delete(Result, 1, 1);
  until StrLeft(Result, 1) <> '0';
end;

function strLeft(const S: string; Len: Integer): string;
begin
  Result := Copy(S, 1, Len);
end;

function Split(aValue: string; aDelimiter: Char): TStringList;
var
  X: Integer;
  S: string;
begin
  //  if Result = nil then
  Result := TStringList.Create;
  Result.Clear;
  S := '';
  for X := 1 to Length(aValue) do
  begin
    if aValue[X] <> aDelimiter then
      S := S + aValue[X]
    else
    begin
      Result.Add(S);
      S := '';
    end;
  end;
  if S <> '' then
    Result.Add(S);
end;

end.
