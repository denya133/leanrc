

module.exports = (Module)->
  {
    CoreObject
    Utils: { _, joi, moment }
  } = Module::

  class ObjectTransform extends CoreObject
    @inheritProtected()
    # @implements Module::TransformInterface
    @module Module

    @public @static schema: Object,
      get: -> joi.object().allow(null).optional()

    @public @static @async normalize: Function,
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: Function,
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: Function,
      default: (serialized)->
        unless serialized?
          return {}
        result = {}
        for own key, value of serialized
          result[key] = switch
            when _.isString(value) and moment(value, moment.ISO_8601).isValid()
              Module::DateTransform.normalizeSync value
            when _.isString value
              Module::StringTransform.normalizeSync value
            when _.isNumber value
              Module::NumberTransform.normalizeSync value
            when _.isBoolean value
              Module::BooleanTransform.normalizeSync value
            when _.isPlainObject value
              Module::ObjectTransform.normalizeSync value
            when _.isArray value
              Module::ArrayTransform.normalizeSync value
            else
              Module::Transform.normalizeSync value
        return result

    @public @static serializeSync: Function,
      default: (deserialized)->
        unless deserialized?
          return {}
        result = {}
        for own key, value of deserialized
          result[key] = switch
            when _.isString value
              Module::StringTransform.serializeSync value
            when _.isNumber value
              Module::NumberTransform.serializeSync value
            when _.isBoolean value
              Module::BooleanTransform.serializeSync value
            when _.isDate value
              Module::DateTransform.serializeSync value
            when _.isPlainObject value
              Module::ObjectTransform.serializeSync value
            when _.isArray value
              Module::ArrayTransform.serializeSync value
            else
              Module::Transform.serializeSync value
        return result

    @public @static objectize: Function,
      default: (deserialized)->
        unless deserialized?
          return {}
        result = {}
        for own key, value of deserialized
          result[key] = switch
            when _.isString value
              Module::StringTransform.objectize value
            when _.isNumber value
              Module::NumberTransform.objectize value
            when _.isBoolean value
              Module::BooleanTransform.objectize value
            when _.isDate value
              Module::DateTransform.objectize value
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


    @initialize()
