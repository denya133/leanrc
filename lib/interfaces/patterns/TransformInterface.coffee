# данный интерфейс нужен для объявления классов, которые должны описывать конвертацию одних структур данных в другие.
# ключевые имена трансформов (в т.ч. базовых) будут использоваться в объявлениях атрибутов рекордов на ряду с joi дефинициями и сопутствующими параметрами.

RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::TransformInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @static @virtual normalize: Function,
      args: [ANY] # data
      return: [ANY, NILL]
    @public @static @virtual serialize:   Function,
      args: [ANY] # data
      return: [ANY, NILL]


  return LeanRC::TransformInterface.initialize()
