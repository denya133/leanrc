

module.exports = (Module)->
  {
    AnyT
    FuncG, SubsetG, MaybeG
    RecordInterface
    Serializer, Mixin
    Utils: { _, inflect }
  } = Module::

  Module.defineMixin Mixin 'HttpSerializerMixin', (BaseClass = Serializer) ->
    class extends BaseClass
      @inheritProtected()

      @public @async normalize: FuncG([SubsetG(RecordInterface), MaybeG AnyT], RecordInterface),
        default: (acRecord, ahPayload)->
          ahPayload = JSON.parse ahPayload if _.isString ahPayload
          return yield acRecord.normalize ahPayload, @collection

      @public @async serialize: FuncG([MaybeG(RecordInterface), MaybeG Object], MaybeG AnyT),
        default: (aoRecord, options = null)->
          vcRecord = aoRecord.constructor
          recordName = vcRecord.name.replace /Record$/, ''
          singular = inflect.singularize inflect.underscore recordName
          yield return {
            "#{singular}": yield vcRecord.serialize aoRecord, options
          }

      @initializeMixin()
