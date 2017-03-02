# данный интерфейс нужен для объявления классов, которые должны описывать конвертацию одних структур данных в другие.
# ключевые имена трансформов (в т.ч. базовых) будут использоваться в объявлениях атрибутов рекордов на ряду с joi дефинициями и сопутствующими параметрами.

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::TransformInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual deserialize: Function, # virtual declaration of method
      args: [RC::Constants.ANY, Object] # data, options
      return: [RC::Constants.ANY, RC::Constants.NILL]
    @public @virtual serialize:   Function, # virtual declaration of method
      args: [RC::Constants.ANY, Object] # data, options
      return: [RC::Constants.ANY, RC::Constants.NILL]


  return LeanRC::TransformInterface.initialize()
