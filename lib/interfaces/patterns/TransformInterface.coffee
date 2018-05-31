# данный интерфейс нужен для объявления классов, которые должны описывать конвертацию одних структур данных в другие.
# ключевые имена трансформов (в т.ч. базовых) будут использоваться в объявлениях атрибутов рекордов на ряду с joi дефинициями и сопутствующими параметрами.


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'TransformInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @static @virtual normalize: Function,
        args: [ANY] # data
        return: [ANY, NILL]
      @public @static @virtual serialize:   Function,
        args: [ANY] # data
        return: [ANY, NILL]
      @public @static @virtual objectize:   Function,
        args: [ANY] # data
        return: [ANY, NILL]


      @initializeInterface()
