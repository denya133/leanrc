RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Notification extends RC::CoreObject
    @implements LeanRC::NotificationInterface

    @public getName: Function,
      default: ->
        @name

    @public setBody: Function,
      default: (body)->
        @body = body
        return

    @public getBody: Function,
      default: -> @body

    @public setType: Function,
      default: (type)->
        @type = type
        return

    @public getType: Function,
      default: -> @type

    @public toString: Function,
      default: ->
        """
          Notification Name: #{@getName()}
          Body: #{if @getBody()? then @getBody().toString() else 'null'}
          Type: #{if @getType()? then @getType() else 'null'}
        """


    @private name: String
    @private body: RC::Constants.ANY
    @private type: String

    constructor: (name, body, type)->
      @name = name
      @body = body
      @type = type



  return LeanRC::Notification.initialize()
