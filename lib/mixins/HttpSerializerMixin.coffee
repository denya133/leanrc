

module.exports = (Module)->
  {
    Serializer
    Cursor
    Utils: { _, inflect }
  } = Module::

  Module.defineMixin 'HttpSerializerMixin', (BaseClass = Serializer) ->
    class extends BaseClass
      @inheritProtected()

      @public @async normalize: Function,
        default: (acRecord, ahPayload)->
          ahPayload = JSON.parse ahPayload if _.isString ahPayload
          return yield acRecord.normalize ahPayload, @collection

      @public @async serialize: Function,
        default: (aoRecord, options = null)->
          vcRecord = aoRecord.constructor
          recordName = vcRecord.name.replace /Record$/, ''
          singular = inflect.singularize inflect.underscore recordName
          yield return {
            "#{singular}": yield vcRecord.serialize aoRecord, options
          }

      @initializeMixin()
