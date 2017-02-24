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
      default: (aoBody)->
        @[ipoBody] = aoBody
        return

    @public getBody: Function,
      default: -> @[ipoBody]

    @public setType: Function,
      default: (asType)->
        @[ipsType] = asType
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

    constructor: (asName, aoBody, asType)->
      @[ipsName] = asName
      @[ipoBody] = aoBody
      @[ipsType] = asType



  return LeanRC::Notification.initialize()
