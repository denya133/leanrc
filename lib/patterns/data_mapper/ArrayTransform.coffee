# NOTE: от этого класса можно унаследовать отдельный класс с кастомным определением схемы и использовать его внутри объявления атрибутов рекорда


module.exports = (Module)->
  {
    CoreObject
    Utils: { _, inflect, joi, moment }
  } = Module::

  class ArrayTransform extends CoreObject
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

    @public @static schema: Object,
      get: -> joi.array().items joi.any()

    @public @static parseRecordName: Function,
      default: (asName)->
        if /.*[:][:].*/.test(asName)
          [vsModuleName, vsRecordName] = asName.split '::'
        else
          [vsModuleName, vsRecordName] = [@moduleName(), inflect.camelize inflect.underscore inflect.singularize asName]
        unless /(Record$)|(Migration$)/.test vsRecordName
          vsRecordName += 'Record'
        [vsModuleName, vsRecordName]

    @public @static findRecordByName: Function,
      args: [String]
      return: Module::Class
      default: (asName)->
        [vsModuleName, vsRecordName] = @parseRecordName asName
        (@Module.NS ? @Module::)[vsRecordName]

    @public @static @async normalize: Function,
      default: (serialized)->
        unless serialized?
          yield return []
        result = for item in serialized
          switch
            when _.isString(item) and moment(item, moment.ISO_8601).isValid()
              yield Module::DateTransform.normalize item
            when _.isString item
              yield Module::StringTransform.normalize item
            when _.isNumber item
              yield Module::NumberTransform.normalize item
            when _.isBoolean item
              yield Module::BooleanTransform.normalize item
            when _.isPlainObject(item) and /.{2,}[:][:].{2,}/.test item.type
              RecordClass = @findRecordByName item.type
              # NOTE: в правильном использовании вторым аргументом должна передаваться ссылка на коллекцию, то тут мы не можем ее получить
              # а так как рекорды в этом случае используются ТОЛЬКО для оформления структуры и хранения данных внутри родительского рекорда, то коллекции физически просто нет.
              yield RecordClass.normalize item
            when _.isPlainObject item
              yield Module::ObjectTransform.normalize item
            when _.isArray item
              yield Module::ArrayTransform.normalize item
            else
              yield Module::Transform.normalize item

        yield return result

    @public @static @async serialize: Function,
      default: (deserialized)->
        unless deserialized?
          yield return []
        result = for item in deserialized
          switch
            when _.isString item
              yield Module::StringTransform.serialize item
            when _.isNumber item
              yield Module::NumberTransform.serialize item
            when _.isBoolean item
              yield Module::BooleanTransform.serialize item
            when _.isDate item
              yield Module::DateTransform.serialize item
            when _.isObject(item) and /.{2,}[:][:].{2,}/.test item.type
              RecordClass = @findRecordByName item.type
              yield RecordClass.serialize item
            when _.isPlainObject item
              yield Module::ObjectTransform.serialize item
            when _.isArray item
              yield Module::ArrayTransform.serialize item
            else
              yield Module::Transform.serialize item

        yield return result

    @public @static objectize: Function,
      default: (deserialized)->
        unless deserialized?
          return []
        result = for item in deserialized
          switch
            when _.isString item
              Module::StringTransform.objectize item
            when _.isNumber item
              Module::NumberTransform.objectize item
            when _.isBoolean item
              Module::BooleanTransform.objectize item
            when _.isDate item
              Module::DateTransform.objectize item
            when _.isObject(item) and /.{2,}[:][:].{2,}/.test item.type
              RecordClass = @findRecordByName item.type
              RecordClass.objectize item
            when _.isPlainObject item
              Module::ObjectTransform.objectize item
            when _.isArray item
              Module::ArrayTransform.objectize item
            else
              Module::Transform.objectize item

        return result

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
