unit model.clienteJuridico;

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
  [Table('clientesJuridico', '')]
  [PrimaryKey('codigo', TAutoIncType.NotInc,
                        TGeneratorType.NoneInc,
                        TSortingOrder.NoSort,
                        True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('codigo')]
  TclienteJuridico = class
  private
    Fcodigo: Integer;
    Frazao: String;
    Ffantasia: String;
    Fcnpj: String;
    Floja: Integer;
    Fsite: nullable<String>;
    Ffacebook: nullable<String>;
    Finstagram: nullable<String>;
    Flogradouro: nullable<String>;
    Fnumero: nullable<String>;
    Fcomplemento: nullable<String>;
    Fbairro: nullable<String>;
    Fcidade: nullable<String>;
    Festado: nullable<String>;
    Fcep: nullable<String>;
    Fpais: nullable<String>;
    FcpfResponsavel: String;
    Fsincronizado: nullable<TDateTime>;
    Femail: nullable<String>;

  public
    constructor Create;
    destructor Destroy;  override;

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

    [Column('loja', ftInteger)]
    [Dictionary('loja', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property loja: Integer read Floja write Floja;

    [Column('site', ftString, 120)]
    [Dictionary('site', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property site: nullable<String> read Fsite write Fsite;

    [Column('facebook', ftString, 120)]
    [Dictionary('facebook', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property facebook: nullable<String> read Ffacebook write Ffacebook;

    [Column('instagram', ftString, 120)]
    [Dictionary('instagram', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property instagram: nullable<String> read Finstagram write Finstagram;

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

    [Column('pais', ftString, 50)]
    [Dictionary('pais', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property pais: nullable<String> read Fpais write Fpais;

    [Column('cpfResponsavel', ftString, 11)]
    [Dictionary('cpfResponsavel', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cpfResponsavel: String read FcpfResponsavel write FcpfResponsavel;

    [Column('email', ftString, 120)]
    [Dictionary('email', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property email: nullable<String> read Femail write Femail;

    [Column('sincronizado', ftDateTime)]
    [Dictionary('sincronizado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property sincronizado: nullable<TDateTime> read Fsincronizado
      write Fsincronizado;
  end;

implementation

{ TclienteJuridico }

constructor TclienteJuridico.Create;
begin
  //
end;

destructor TclienteJuridico.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(TclienteJuridico)

end.
