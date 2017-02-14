{SELF, NILL, ANY} = FoxxMC::Constants

class ArangodbSerializerInterface extends Interface
  @include SerializerInterface


class ArangodbSerializer extends Serializer
  @implements ArangodbSerializerInterface
