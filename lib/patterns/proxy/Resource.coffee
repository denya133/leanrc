RC = require 'RC'

# класс Resource нужен чтобы от него инстанцировать прокси ресурсов в клиентских ядрах с нужным миксином (например с использованием HttpCollectionMixin)

module.exports = (LeanRC)->
  class LeanRC::Resource extends LeanRC::Collection
    @inheritProtected()
    @implements LeanRC::ResourceInterface # может и не нужен

    @Module: LeanRC


  return LeanRC::Resource.initialize()
