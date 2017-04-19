

module.exports = (Module)->
  class PipeMessage extends Module::CoreObject
    @inheritProtected()
    @implements Module::PipeMessageInterface

    @Module: Module

    @public @static PRIORITY_HIGH: Number,
      default: 1
    @public @static PRIORITY_MED: Number,
      default: 5
    @public @static PRIORITY_LOW: Number,
      default: 10

    @public @static BASE: String,
      default: 'namespaces/pipes/messages/'
    @public @static NORMAL: String,
      get: -> "#{@BASE}normal"
    @public @static ERROR: String,
      get: -> "#{@BASE}error"

    ipsType = @protected type: String
    ipnPriority = @protected priority: Number
    ipoHeader = @protected header: Object
    ipoBody = @protected body: Object

    @public getType: Function,
      default: -> @[ipsType]

    @public setType: Function,
      default: (asType)->
        @[ipsType] = asType
        return

    @public getPriority: Function,
      default: -> @[ipnPriority]

    @public setPriority: Function,
      default: (anPriority)->
        @[ipnPriority] = anPriority
        return

    @public getHeader: Function,
      default: -> @[ipoHeader]

    @public setHeader: Function,
      default: (aoHeader)->
        @[ipoHeader] = aoHeader
        return

    @public getBody: Function,
      default: -> @[ipoBody]

    @public setBody: Function,
      default: (aoBody)->
        @[ipoBody] = aoBody
        return

    @public init: Function,
      default: (asType, aoHeader=null, aoBody=null, anPriority=5)->
        @super arguments...
        @setType asType
        @setHeader aoHeader
        @setBody aoBody
        @setPriority anPriority


  PipeMessage.initialize()
