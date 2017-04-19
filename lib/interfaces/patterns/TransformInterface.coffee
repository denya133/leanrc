# данный интерфейс нужен для объявления классов, которые должны описывать конвертацию одних структур данных в другие.
# ключевые имена трансформов (в т.ч. базовых) будут использоваться в объявлениях атрибутов рекордов на ряду с joi дефинициями и сопутствующими параметрами.


module.exports = (Module)->
  {ANY, NILL} = Module::

  class TransformInterface extends Module::Interface
    @inheritProtected()

    @Module: Module

    @public @static @virtual normalize: Function,
      args: [ANY] # data
      return: [ANY, NILL]
    @public @static @virtual serialize:   Function,
      args: [ANY] # data
      return: [ANY, NILL]


  TransformInterface.initialize()
