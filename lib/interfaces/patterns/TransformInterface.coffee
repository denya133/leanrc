# данный интерфейс нужен для объявления классов, которые должны описывать конвертацию одних структур данных в другие.
# ключевые имена трансформов (в т.ч. базовых) будут использоваться в объявлениях атрибутов рекордов на ряду с joi дефинициями и сопутствующими параметрами.


module.exports = (Module)->
  {
    AnyT, JoiT
    FuncG, MaybeG
    Interface
  } = Module::

  class TransformInterface extends Interface
    @inheritProtected()
    @module Module

    @public @static schema: JoiT

    @virtual @static @async normalize: FuncG [MaybeG AnyT], MaybeG AnyT
    @virtual @static @async serialize: FuncG [MaybeG AnyT], MaybeG AnyT
    @virtual @static objectize: FuncG [MaybeG AnyT], MaybeG AnyT


    @initialize()
