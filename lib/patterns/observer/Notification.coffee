

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

    @public @static @async restoreObject: Function,
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          {name, body, type} = replica.notification
          instance = @new name, body, type
          yield return instance
        else
          return yield @super Module, replica

    @public @static @async replicateObject: Function,
      default: (instance)->
        replica = yield @super instance
        replica.notification =
          name: instance.getName()
          body: instance.getBody()
          type: instance.getType()
        yield return replica

    @public init: Function,
      default: (asName, aoBody, asType)->
        @super arguments...
        @[ipsName] = asName
        @[ipoBody] = aoBody
        @[ipsType] = asType



  Notification.initialize()
