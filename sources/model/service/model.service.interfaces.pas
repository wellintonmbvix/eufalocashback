unit model.service.interfaces;

interface

uses
  System.Generics.Collections;


type
  IService<T: Class> = interface
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

end.
