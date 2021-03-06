unit uJMDBCom;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.IBBase,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TJMDBCom = class
    FDDriver : TFDPhysFBDriverLink;
    conn     : TFDConnection;
    qry      : TFDQuery;
  private

  public
    constructor Create(AOwner: TComponent);
    destructor Destroy;

    function DBConnection(ADatabasePath : String; AVendorLibPath : String):Boolean;
    procedure ReleaseConnection;

    function CreateQuery(AConnection : TFDConnection):TFDQuery;
    procedure ReleaseQuery;

  end;

implementation

{ TJMDBCom }

constructor TJMDBCom.Create(AOwner: TComponent);
begin
  conn      := TFDConnection.Create(nil);
  FDDriver  := TFDPhysFBDriverLink.Create(nil);
end;

function TJMDBCom.CreateQuery(aConnection : TFDConnection): TFDQuery;
begin
  if not AConnection.Connected then
  begin
    ShowMessage('Database is not connected');
    exit;
  end;

  try
    qry := TFDQuery.Create(AConnection);
    qry.Connection := AConnection;
    Result := qry;
  except
    on E:Exception do
    begin
      ShowMessage('Following error occurs while creating Query : ' + E.Message );
      Result := nil;
    end;
  end;
end;

function TJMDBCom.DBConnection(ADatabasePath : String; AVendorLibPath : String): Boolean;
begin
  if Assigned(FDDriver) then
    FDDriver.VendorLib := AVendorLibPath;

  if Assigned(conn) then
  begin
    with conn.Params do
    begin
      Clear;
      Add('DriverID=FB');
      Add('Server=localhost');
      Add('Database=' + ADatabasePath);
      Add('User_Name=sysdba');
      Add('Password=masterkey');
    end;

    try
      if not conn.Connected then
      begin
        conn.Connected := True;
        Result := True;
      end;

    except
      on E:Exception do
      begin
        ShowMessage('Following  error occurs while trying to connect to database : ' + E.Message );
        Result := False;
      end;
    end;
  end;
end;

destructor TJMDBCom.Destroy;
begin

  if Assigned(FDDriver) then FreeAndNil(FDDriver);
  if conn.Connected then conn.Connected := False;
  if Assigned(conn) then FreeAndNil(conn);

end;

procedure TJMDBCom.ReleaseConnection;
begin
  if Assigned(FDDriver) then FreeAndNil(FDDriver);
  if conn.Connected then conn.Connected := False;
  if Assigned(conn) then FreeAndNil(conn);
end;

procedure TJMDBCom.ReleaseQuery;
begin
  if Assigned(qry) then FreeAndNil(qry);
end;

end.
