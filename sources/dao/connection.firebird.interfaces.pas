unit connection.firebird.interfaces;

interface

uses
  System.Classes;

type
  IConnectionFirebird = interface
    ['{CFFCB235-7480-4520-83DA-5B62AA8CD8C3}']
    function Connected(value: Boolean): IConnectionFirebird; overload;
    function Connected: Boolean; overload;
    function InTransaction: Boolean;
    function StartTransaction: IConnectionFirebird;
    function Commit: IConnectionFirebird;
    function Rollback: IConnectionFirebird;

    function GetQuery: TComponent;
    function GetConnection: TComponent;
    function CheckDB: String;
  end;

implementation

end.
