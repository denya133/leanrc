RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Notification extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::NotificationInterface

    @Module: LeanRC

    ipsName = @private name: String
    ipoBody = @private body: RC::ANY
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

    @public init: Function,
      default: (asName, aoBody, asType)->
        @super arguments...
        @[ipsName] = asName
        @[ipoBody] = aoBody
        @[ipsType] = asType



  return LeanRC::Notification.initialize()
