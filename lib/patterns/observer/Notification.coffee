

module.exports = (Module)->

  class Notification extends Module::CoreObject
    @inheritProtected()
    @implements Module::NotificationInterface

    @module Module

    ipsName = @private name: String
    ipoBody = @private body: Module::ANY
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



  Notification.initialize()
