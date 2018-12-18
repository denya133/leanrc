

module.exports = (Module)->
  {
    AnyT, PointerT
    FuncG, MaybeG, SubsetG
    NotificationInterface
    CoreObject
  } = Module::

  class Notification extends CoreObject
    @inheritProtected()
    @implements NotificationInterface
    @module Module

    ipsName = PointerT @private name: String
    ipoBody = PointerT @private body: MaybeG AnyT
    ipsType = PointerT @private type: MaybeG String

    @public getName: FuncG([], String),
      default: -> @[ipsName]

    @public setBody: FuncG([MaybeG AnyT]),
      default: (aoBody)->
        @[ipoBody] = aoBody
        return

    @public getBody: FuncG([], MaybeG AnyT),
      default: -> @[ipoBody]

    @public setType: FuncG(String),
      default: (asType)->
        @[ipsType] = asType
        return

    @public getType: FuncG([], MaybeG String),
      default: -> @[ipsType]

    @public toString: FuncG([], String),
      default: ->
        """
          Notification Name: #{@getName()}
          Body: #{if @getBody()? then @getBody().toString() else 'null'}
          Type: #{if @getType()? then @getType() else 'null'}
        """

    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], NotificationInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          {name, body, type} = replica.notification
          instance = @new name, body, type
          yield return instance
        else
          return yield @super Module, replica

    @public @static @async replicateObject: FuncG(NotificationInterface, Object),
      default: (instance)->
        replica = yield @super instance
        replica.notification =
          name: instance.getName()
          body: instance.getBody()
          type: instance.getType()
        yield return replica

    @public init: FuncG([String, MaybeG(AnyT), MaybeG String]),
      default: (asName, aoBody, asType)->
        @super arguments...
        @[ipsName] = asName
        @[ipoBody] = aoBody
        @[ipsType] = asType if asType?
        return


    @initialize()
