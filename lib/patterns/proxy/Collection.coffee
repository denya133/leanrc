# так как в этом репозитории нельзя давать платформозависимый код,
# данный класс (миксин) нужен 1 - для примера реализации интерфейса, 2 - так как ориентирован на хранение данных в оперативной памяти - то является платформонезависимым решением, 3 - может быть полезен при написании конкретных программ где данные должны храниться в оперативной памяти.

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Collection extends LeanRC::Proxy
    @inheritProtected()
    @implements LeanRC::CollectionInterface

    @Module: LeanRC

    @public generateId: Function,
      default: -> return
    @public create: Function,
      default: (properties)->
        return record
    @public createDirectly: Function,
      default: (properties)->
        return record
    @public delete: Function,
      default: (id)->
        return record
    @public deleteBy: Function,
      default: (query)->
        return record
    @public destroy: Function,
      default: (id)->
        return
    @public destroyBy: Function,
      default: (query)->
        return
    @public find: Function,
      default: (id)->
        return record
    @public findBy: Function,
      default: (query)->
        return record
    @public filter: Function,
      default: (query)->
        return records
    @public update: Function,
      default: (id, properties)->
        return record
    @public updateBy: Function,
      default: (query, properties)->
        return record
    @public query: Function,
      default: (query)->
        return result
    @public copy: Function,
      default: (id)->
        return record
    @public deepCopy: Function,
      default: (id)->
        return record
    @public forEach: Function,
      default: (lambda)->
        return
    @public map: Function,
      default: (lambda)->
        return results
    @public reduce: Function,
      default: (lambda, initialValue)->
        return result
    @public sortBy: Function,
      default: (params)->
        return results
    @public groupBy: Function,
      default: (params)->
        return results
    @public includes: Function,
      default: (id)->
        return isInclude
    @public exists: Function,
      default: (query)->
        return isExist
    @public length: Function, # количество объектов в коллекции
      default: ->
        return length
    @public push: Function,
      default: (data)->
        return isPushed
    @public normalize: Function,
      default: (data)->
        return data
    @public serialize: Function,
      default: (id, options)->
        return data
    @public unload: Function,
      default: (id)->
        return
    @public unloadBy: Function,
      default: (query)->
        return
    @public parseQuery: Function,
      default: (query)->
        return query
    @public executeQuery: Function,
      default: (query, options)->
        return result


  return LeanRC::Collection.initialize()
