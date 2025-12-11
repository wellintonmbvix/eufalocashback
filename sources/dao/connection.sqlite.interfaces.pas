unit connection.sqlite.interfaces;

interface

uses
  System.Classes;

type
  IConnectionSQLite = interface
    ['{E66E4B9E-B697-47A5-84CD-60859D668408}']
    function Connected(value: Boolean): IConnectionSQLite; overload;
    function Connected: Boolean; overload;
    function InTransaction: Boolean;
    function StartTransaction: IConnectionSQLite;
    function Commit: IConnectionSQLite;
    function Rollback: IConnectionSQLite;

    function GetQuery: TComponent;
    function GetConnection: TComponent;
    function CheckDB: String;
  end;

implementation

end.
