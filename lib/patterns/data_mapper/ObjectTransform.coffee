

module.exports = (Module)->
  {
    CoreObject
    Utils: { _, inflect }
  } = Module::

  class ObjectTransform extends CoreObject
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
          yield return {}
        result = {}
        for own key, value of serialized
          result[key] = switch
            when _.isString value
              yield Module::StringTransform.normalize value
            when _.isDate value
              yield Module::DateTransform.normalize value
            when _.isNumber value
              yield Module::NumberTransform.normalize value
            when _.isBoolean value
              yield Module::BooleanTransform.normalize value
            when _.isPlainObject(value) and /.{2,}[:][:].{2,}/.test value.type
              RecordClass = @findRecordByName value.type
              yield RecordClass.normalize value
            when _.isPlainObject value
              yield Module::ObjectTransform.normalize value
            when _.isArray value
              yield Module::ArrayTransform.normalize value
            else
              yield Module::Transform.normalize value

        yield return result

    @public @static @async serialize: Function,
      default: (deserialized)->
        unless deserialized?
          yield return {}
        result = {}
        for own key, value of deserialized
          result[key] = switch
            when _.isString value
              yield Module::StringTransform.serialize value
            when _.isDate value
              yield Module::DateTransform.serialize value
            when _.isNumber value
              yield Module::NumberTransform.serialize value
            when _.isBoolean value
              yield Module::BooleanTransform.serialize value
            when _.isPlainObject(value) and /.{2,}[:][:].{2,}/.test value.type
              RecordClass = @findRecordByName value.type
              yield RecordClass.serialize value
            when _.isPlainObject value
              yield Module::ObjectTransform.serialize value
            when _.isArray value
              yield Module::ArrayTransform.serialize value
            else
              yield Module::Transform.serialize value

        yield return result

    @public @static objectize: Function,
      default: (deserialized)->
        unless deserialized?
          return {}
        result = {}
        for own key, value of deserialized
          result[key] = switch
            when _.isString value
              Module::StringTransform.objectize value
            when _.isDate value
              Module::DateTransform.objectize value
            when _.isNumber value
              Module::NumberTransform.objectize value
            when _.isBoolean value
              Module::BooleanTransform.objectize value
            when _.isPlainObject(value) and /.{2,}[:][:].{2,}/.test value.type
              RecordClass = @findRecordByName value.type
              RecordClass.objectize value
            when _.isPlainObject value
              Module::ObjectTransform.objectize value
            when _.isArray value
              Module::ArrayTransform.objectize value
            else
              Module::Transform.objectize value

        return result

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


  ObjectTransform.initialize()
