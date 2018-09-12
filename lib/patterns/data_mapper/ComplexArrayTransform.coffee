# NOTE: от этого класса можно унаследовать отдельный класс с кастомным определением схемы и использовать его внутри объявления атрибутов рекорда


module.exports = (Module)->
  {
    ArrayTransform
    Utils: { _, inflect, moment }
  } = Module::

  class ComplexArrayTransform extends ArrayTransform
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

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
              Module::DateTransform.normalizeSync item
            when _.isString item
              Module::StringTransform.normalizeSync item
            when _.isNumber item
              Module::NumberTransform.normalizeSync item
            when _.isBoolean item
              Module::BooleanTransform.normalizeSync item
            when _.isPlainObject(item) and /.{2,}[:][:].{2,}/.test item.type
              RecordClass = @findRecordByName item.type
              # NOTE: в правильном использовании вторым аргументом должна передаваться ссылка на коллекцию, то тут мы не можем ее получить
              # а так как рекорды в этом случае используются ТОЛЬКО для оформления структуры и хранения данных внутри родительского рекорда, то коллекции физически просто нет.
              yield RecordClass.normalize item
            when _.isPlainObject item
              yield Module::ComplexObjectTransform.normalize item
            when _.isArray item
              yield Module::ComplexArrayTransform.normalize item
            else
              Module::Transform.normalizeSync item
        yield return result

    @public @static @async serialize: Function,
      default: (deserialized)->
        unless deserialized?
          yield return []
        result = for item in deserialized
          switch
            when _.isString item
              Module::StringTransform.serializeSync item
            when _.isNumber item
              Module::NumberTransform.serializeSync item
            when _.isBoolean item
              Module::BooleanTransform.serializeSync item
            when _.isDate item
              Module::DateTransform.serializeSync item
            when _.isObject(item) and /.{2,}[:][:].{2,}/.test item.type
              RecordClass = @findRecordByName item.type
              yield RecordClass.serialize item
            when _.isPlainObject item
              yield Module::ComplexObjectTransform.serialize item
            when _.isArray item
              yield Module::ComplexArrayTransform.serialize item
            else
              Module::Transform.serializeSync item
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
              Module::ComplexObjectTransform.objectize item
            when _.isArray item
              Module::ComplexArrayTransform.objectize item
            else
              Module::Transform.objectize item
        return result


    @initialize()
