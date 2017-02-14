{SELF, NILL, ANY} = FoxxMC::Constants

# возможно этот сериалайзер должен быть объявлен в отдельном npm модуле,
# чтобы не было ошибки в недостоющих зависимостях при прогрузке на другой платформе.


class ArangodbSerializerInterface extends Interface
  @include SerializerInterface


class ArangodbSerializer extends Serializer
  @implements ArangodbSerializerInterface
