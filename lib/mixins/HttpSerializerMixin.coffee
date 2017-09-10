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
          ahPayload = JSON.parse ahPayload if _.isString ahPayload
          recordName = acRecord.name.replace /Record$/, ''
          singular = inflect.singularize inflect.underscore recordName
          plural = inflect.pluralize singular
          if ahPayload[singular]?
            return acRecord.normalize ahPayload[singular], @collection
          else if ahPayload[plural]?
            return Cursor.new @collection, ahPayload[plural]
          else
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
