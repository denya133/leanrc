RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Notification extends RC::CoreObject
    @implements LeanRC::NotificationInterface

    ipsName = @private name: String
    ipoBody = @private body: RC::Constants.ANY
    ipsType = @private type: String

    @public getName: Function,
      default: ->
        @[ipsName]

    @public setBody: Function,
      default: (body)->
        @[ipoBody] = body
        return

    @public getBody: Function,
      default: -> @[ipoBody]

    @public setType: Function,
      default: (type)->
        @[ipsType] = type
        return

    @public getType: Function,
      default: -> @[ipsType]

    @public toString: Function,
      default: ->
        """
          Notification Name: #{@getName()}
          Body: #{if @getBody()? then @getBody().toString() else 'null'}
          Type: #{if @getType()? then @getType() else 'null'}
        """

    constructor: (name, body, type)->
      @[ipsName] = name
      @[ipoBody] = body
      @[ipsType] = type



  return LeanRC::Notification.initialize()
