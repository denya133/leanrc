_             = require 'lodash'
inflect       = do require 'i'


module.exports = (Module)->
  {
    Serializer
    Cursor
  } = Module::

  Module.defineMixin Serializer, (BaseClass) ->
    class HttpSerializerMixin extends BaseClass
      @inheritProtected()

      @public normalize: Function,
        default: (acRecord, ahPayload)->
          console.log '>>> IN HttpSerializerMixin::normalize', ahPayload, _.isString ahPayload
          recordName = acRecord.name.replace /Record$/, ''
          singular = inflect.singularize inflect.underscore recordName
          plural = inflect.pluralize singular
          console.log '>>> IN HttpSerializerMixin::normalize singular, plural', singular, plural
          if ahPayload[singular]?
            console.log '>>> IN HttpSerializerMixin::normalize if singular'
            return acRecord.normalize ahPayload[singular], @collection
          else if ahPayload[plural]?
            console.log '>>> IN HttpSerializerMixin::normalize if plural'
            return Cursor.new @, ahPayload[plural]
          else
            console.log '>>> IN HttpSerializerMixin::normalize other'
            return acRecord.normalize ahPayload, @collection

      @public serialize: Function,
        default: (aoRecord, options = null)->
          vcRecord = aoRecord.constructor
          recordName = vcRecord.name.replace /Record$/, ''
          singular = inflect.singularize inflect.underscore recordName
          return {
            "#{singular}": vcRecord.serialize aoRecord, options
          }

    HttpSerializerMixin.initializeMixin()
