RC = require 'RC'

# методы `parseQuery` и `executeQuery` должны быть реализованы в миксинах в отдельных подлючаемых npm-модулях т.к. будут содержать некоторый платформозависимый код.


module.exports = (LeanRC)->
  class LeanRC::QueryableMixinInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @async @virtual deleteBy: Function,
      args: [Object]
      return: RC::Constants.NILL

    @public @async @virtual destroyBy: Function,
      args: [Object]
      return: RC::Constants.NILL
    @public @async @virtual removeBy: Function, # обращается к БД
      args: [Object]
      return: Boolean

    @public @async @virtual findBy: Function,
      args: [Object]
      return: LeanRC::CursorInterface
    @public @async @virtual takeBy: Function, # обращается к БД
      args: [Object]
      return: LeanRC::CursorInterface

    @public @async @virtual replaceBy: Function,
      args: [Object, Object]
      return: RC::Constants.NILL
    @public @async @virtual overrideBy: Function, # обращается к БД
      args: [Object, LeanRC::RecordInterface]
      return: Boolean

    @public @async @virtual updateBy: Function,
      args: [Object, Object]
      return: RC::Constants.NILL
    @public @async @virtual patchBy: Function, # обращается к БД
      args: [Object, LeanRC::RecordInterface]
      return: Boolean

    @public @async @virtual exists: Function,
      args: [Object]
      return: Boolean



    @public @async @virtual query: Function,
      args: [[Object, LeanRC::QueryInterface]]
      return: RC::Constants.ANY
    @public @virtual parseQuery: Function, # описание того как стандартный (query object) преобразовать в конкретный запрос к конкретной базе данных
      args: [[Object, LeanRC::QueryInterface]]
      return: [Object, String, LeanRC::QueryInterface]
    @public @async @virtual executeQuery: Function,
      args: [[Object, String, LeanRC::QueryInterface], Object] # query, options
      return: RC::Constants.ANY


  return LeanRC::QueryableMixinInterface.initialize()
