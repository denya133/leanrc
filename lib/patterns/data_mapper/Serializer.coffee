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
        vhResult = {}
        for own asAttrName, ahAttrValue of acRecord.attributes
          do (asAttrName, {transform} = ahAttrValue)->
            vhResult[asAttrName] = transform.deserialize ahPayload[asAttrName]
        acRecord.new vhResult

    @public serialize: Function,
      default: (aoRecord, options = null)->
        vcRecord = aoRecord.constructor
        vhResult = {}
        for own asAttrName, ahAttrValue of vcRecord.attributes
          do (asAttrName, {transform} = ahAttrValue)->
            vhResult[asAttrName] = transform.serialize aoRecord[asAttrName]
        vhResult


  return LeanRC::Serializer.initialize()
