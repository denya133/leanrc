RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Observer extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::ObserverInterface

    @Module: LeanRC

    ipoNotify = @private _notify: RC::Constants.ANY
    ipoContext = @private _context: RC::Constants.ANY

    @public setNotifyMethod: Function,
      default: (amNotifyMethod)->
        @[ipoNotify] = amNotifyMethod
        return

    @public setNotifyContext: Function,
      default: (aoNotifyContext)->
        @[ipoContext] = aoNotifyContext
        return

    @public getNotifyMethod: Function,
      default: -> @[ipoNotify]

    @public getNotifyContext: Function,
      default: -> @[ipoContext]

    @public compareNotifyContext: Function,
      default: (object)->
        object is @[ipoContext]

    @public notifyObserver: Function,
      default: (notification)->
        @getNotifyMethod().call @getNotifyContext(), notification
        return

    constructor: (amNotifyMethod, aoNotifyContext)->
      super arguments...
      @setNotifyMethod amNotifyMethod
      @setNotifyContext aoNotifyContext



  return LeanRC::Observer.initialize()
