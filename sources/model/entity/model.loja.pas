unit model.loja;

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
  [Table('lojas', '')]
  [PrimaryKey('codigo', TAutoIncType.NotInc,
                        TGeneratorType.NoneInc,
                        TSortingOrder.NoSort,
                        True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('codigo')]
  Tloja = class
  private
    Fcodigo: Integer;
    Frazao: String;
    Ffantasia: String;
    Fcnpj: String;
    Flogradouro: nullable<String>;
    Fnumero: nullable<String>;
    Fcomplemento: nullable<String>;
    Fbairro: nullable<String>;
    Fcidade: nullable<String>;
    Festado: nullable<String>;
    Fcep: nullable<String>;
    FdddFixo: nullable<String>;
    FfoneFixo: nullable<String>;
    FdddCel: nullable<String>;
    FfoneCel: nullable<String>;
    Fsincronizado: nullable<TDateTime>;

  public
    constructor Create;
    destructor Destroy; override;

    [Column('codigo', ftInteger)]
    [Dictionary('codigo', 'Mensagem de validação', '', '', '', taCenter)]
    property codigo: Integer read Fcodigo write Fcodigo;

    [Column('razao', ftString, 60)]
    [Dictionary('razao', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property razao: String read Frazao write Frazao;

    [Column('fantasia', ftString, 50)]
    [Dictionary('fantasia', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property fantasia: String read Ffantasia write Ffantasia;

    [Column('cnpj', ftString, 14)]
    [Dictionary('cnpj', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cnpj: String read Fcnpj write Fcnpj;

    [Column('logradouro', ftString, 60)]
    [Dictionary('logradouro', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property logradouro: nullable<String> read Flogradouro write Flogradouro;

    [Column('numero', ftString, 7)]
    [Dictionary('numero', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property numero: nullable<String> read Fnumero write Fnumero;

    [Column('complemento', ftString, 30)]
    [Dictionary('complemento', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property complemento: nullable<String> read Fcomplemento write Fcomplemento;

    [Column('bairro', ftString, 40)]
    [Dictionary('bairro', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property bairro: nullable<String> read Fbairro write Fbairro;

    [Column('cidade', ftString, 40)]
    [Dictionary('cidade', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cidade: nullable<String> read Fcidade write Fcidade;

    [Column('estado', ftString, 2)]
    [Dictionary('estado', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property estado: nullable<String> read Festado write Festado;

    [Column('cep', ftString, 8)]
    [Dictionary('cep', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cep: nullable<String> read Fcep write Fcep;

    [Column('dddFixo', ftString, 3)]
    [Dictionary('dddFixo', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property dddFixo: nullable<String> read FdddFixo write FdddFixo;

    [Column('foneFixo', ftString, 8)]
    [Dictionary('foneFixo', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property foneFixo: nullable<String> read FfoneFixo write FfoneFixo;

    [Column('dddCel', ftString, 3)]
    [Dictionary('dddCel', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property dddCel: nullable<String> read FdddCel write FdddCel;

    [Column('foneCel', ftString, 9)]
    [Dictionary('foneCel', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property foneCel: nullable<String> read FfoneCel write FfoneCel;

    [Column('sincronizado', ftDateTime)]
    [Dictionary('sincronizado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property sincronizado: nullable<TDateTime> read Fsincronizado
      write Fsincronizado;
  end;

implementation

{ Tloja }

constructor Tloja.Create;
begin
  //
end;

destructor Tloja.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tloja)

end.
