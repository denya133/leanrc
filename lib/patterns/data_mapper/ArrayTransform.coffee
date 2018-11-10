

module.exports = (Module)->
  {
    JoiT
    FuncG, MaybeG
    TransformInterface
    CoreObject
    Utils: { _, joi, moment }
  } = Module::

  class ArrayTransform extends CoreObject
    @inheritProtected()
    @implements TransformInterface
    @module Module

    @public @static schema: JoiT,
      get: -> joi.array().items(joi.any()).allow(null).optional()

    @public @static @async normalize: FuncG([MaybeG Array], Array),
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: FuncG([MaybeG Array], Array),
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: FuncG([MaybeG Array], Array),
      default: (serialized)->
        unless serialized?
          return []
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
            when _.isPlainObject item
              Module::ObjectTransform.normalizeSync item
            when _.isArray item
              Module::ArrayTransform.normalizeSync item
            else
              Module::Transform.normalizeSync item
        return result

    @public @static serializeSync: FuncG([MaybeG Array], Array),
      default: (deserialized)->
        unless deserialized?
          return []
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
            when _.isPlainObject item
              Module::ObjectTransform.serializeSync item
            when _.isArray item
              Module::ArrayTransform.serializeSync item
            else
              Module::Transform.serializeSync item
        return result

    @public @static objectize: FuncG([MaybeG Array], Array),
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
