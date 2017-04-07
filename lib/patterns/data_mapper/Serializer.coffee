# класс, который должен отвечать за сериализацию отдельной записи при сохранении ее через collection прокси в некоторое хранилище. т.е. за сериализацию отдельных атрибутов и их десериализацию при получении из хранилища.
# этот же класс в методах normalize и serialize осуществляет обращения к нужным трансформам, на основе метаданных объявленных в рекорде для сериализаци каждого атрибута
RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::Serializer extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::SerializerInterface

    @Module: LeanRC

    @public collection: LeanRC::CollectionInterface

    @public normalize: Function,
      default: (acRecord, ahPayload)->
        acRecord.normalize ahPayload, @collection

    @public serialize: Function,
      default: (aoRecord, options = null)->
        vcRecord = aoRecord.constructor
        vcRecord.serialize aoRecord, options


  return LeanRC::Serializer.initialize()
