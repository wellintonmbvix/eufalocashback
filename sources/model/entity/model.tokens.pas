unit model.tokens;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,

  // ormbr
  ormbr.types.blob,
  ormbr.types.lazy,
  ormbr.objects.helper,
  dbcbr.types.mapping,
  ormbr.types.nullable,
  dbcbr.mapping.Classes,
  dbcbr.mapping.register,
  dbcbr.mapping.attributes;

type

  [Entity]
  [Table('tokens', '')]
  [PrimaryKey('userId', TAutoIncType.NotInc,
                        TGeneratorType.NoneInc,
                        TSortingOrder.NoSort,
                        True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('userId')]
  Ttoken = class
  private
    FuserId: String;
    Ftoken: nullable<String>;
    Fexpiration: nullable<TDateTime>;
  public
    constructor Create;
    destructor Destroy; override;

    [Restrictions([TRestriction.NotNull])]
    [Column('userId', ftString, 50)]
    [Dictionary('userId', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property userId: String read FuserId write FuserId;

    [Column('token', ftMemo)]
    [Dictionary('token', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property token: nullable<String> read Ftoken write Ftoken;

    [Column('expiration', ftDateTime)]
    [Dictionary('expiration', 'Mensagem de validação', '', '', '!##/##/####;1;_', taLeftJustify)]
    property expiration: nullable<TDateTime> read Fexpiration write Fexpiration;
  end;

implementation

{ Ttoken }

constructor Ttoken.Create;
begin
  //
end;

destructor Ttoken.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Ttoken)

end.
