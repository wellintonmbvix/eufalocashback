unit model.service.interfaces.impl;

interface

uses
  dbebr.factory.interfaces,
  dbebr.factory.firedac,
  ormbr.dml.generator.postgresql,
  ormbr.dml.generator.mssql,
  ormbr.container.objectset.interfaces,
  ormbr.container.objectset,

  System.Generics.Collections,
  model.resource.interfaces,
  model.service.interfaces;

type
  TServiceORMBr<T: class, constructor> = class(TInterfacedObject, IService<T>)
  private
    FParent: T;
    FConnection: IConnection;
    FConnectionORM: IDBConnection;
    FORMBrContainer: IContainerObjectSet<T>;
  public
    constructor Create(aParent: T);
    destructor Destroy; override;
    class function New(aParent: T): IService<T>;

    function ListAll(aFilter: String; out aList: TObjectList<T>; const aOrderBy: String = ''): IService<T>;
    function ListById(aField: String; aId: Integer; out aList: TObjectList<T>): IService<T>; overload;
    function ListById(aField: String; aId: Integer; out oEntity: T): IService<T>; overload;
    function ListByFieldStr(aField: String; aStr: String; out oEntity: T): IService<T>;
    function ListByCode(aCode: Integer): IService<T>;
    function Insert: IService<T>;
    function Modify(AValue: T): IService<T>;
    function Update: IService<T>;
    function Delete: IService<T>;
    function This: T;
  end;

implementation

uses
  model.resource.impl.factory,
  SysUtils;

{ TServiceORMBr<T> }

constructor TServiceORMBr<T>.Create(aParent: T);
begin
  FParent := aParent;

  FConnection := TResource.New.Connection;
  FConnectionORM := TFactoryFiredac.Create(FConnection.Connect, dnMSSQL);
  FORMBrContainer := TContainerObjectSet<T>.Create(FConnectionORM);
end;

function TServiceORMBr<T>.Delete: IService<T>;
begin
  Result := Self;
  FORMBrContainer.Delete(FParent);
end;

destructor TServiceORMBr<T>.Destroy;
begin
  inherited;
end;

function TServiceORMBr<T>.Insert: IService<T>;
begin
  Result := Self;
  FORMBrContainer.Insert(FParent);
end;

function TServiceORMBr<T>.ListAll(aFilter: String; out aList: TObjectList<T>;
  const aOrderBy: String): IService<T>;
begin
  Result := Self;
  aList := FORMBrContainer.FindWhere(AFilter, AOrderBy);
end;

function TServiceORMBr<T>.ListByCode(aCode: Integer): IService<T>;
begin
  Result := Self;
  var LList := FORMBrContainer.FindWhere(Format('CODIGO = %d', [aCode]));
  if Assigned(LList) and (LList.Count > 0) then
    FParent := LList.First;
end;

function TServiceORMBr<T>.ListByFieldStr(aField, aStr: String;
  out oEntity: T): IService<T>;
var
  internalObjlist: TObjectList<T>;
begin
  Result := Self;
  internalObjlist := FORMBrContainer.FindWhere(Format(aField+' = %s', [QuotedStr(aStr)]));
  oEntity := internalObjlist.First;
  if Assigned(oEntity) then
    FParent := oEntity;
  FreeAndNil(internalObjlist);
end;

function TServiceORMBr<T>.ListById(aField: String; aId: Integer;
  out oEntity: T): IService<T>;
begin
  Result := Self;
  oEntity := FORMBrContainer.Find(aId);
  if Assigned(oEntity) then
    FParent := oEntity;
end;

function TServiceORMBr<T>.ListById(aField: String; aId: Integer; out aList: TObjectList<T>): IService<T>;
begin
  Result := Self;
  aList := FORMBrContainer.FindWhere(Format(aField+' = %d', [aId]));
  if Assigned(aList) and (aList.Count > 0) then
    FParent := aList.First;
end;

function TServiceORMBr<T>.Modify(AValue: T): IService<T>;
begin
  Result := Self;
  FORMBrContainer.Modify(FParent);
end;

class function TServiceORMBr<T>.New(aParent: T): IService<T>;
begin
  Result := Self.Create(aParent);
end;

function TServiceORMBr<T>.This: T;
begin
  Result := FParent;
end;

function TServiceORMBr<T>.Update: IService<T>;
begin
  Result := Self;
  FORMBrContainer.Update(FParent);
end;

end.

