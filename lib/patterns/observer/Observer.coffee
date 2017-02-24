RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Observer extends RC::CoreObject
    @implements LeanRC::ObserverInterface

    @public setNotifyMethod: Function,
      default: (notifyMethod)->
        @notify = notifyMethod
        return

    @public setNotifyContext: Function,
      default: (notifyContext)->
        @context = notifyContext
        return

    @public getNotifyMethod: Function,
      default: -> @notify

    @public getNotifyContext: Function,
      default: -> @context

    @public compareNotifyContext: Function,
      default: (object)->
        object is @context

    @public notifyObserver: Function,
      default: (notification)->
        @getNotifyMethod().call @getNotifyContext(), notification
        return


    @private notify: Function,
      args: RC::Constants.ANY
      return: RC::Constants.ANY
    @private context: RC::Constants.ANY

    constructor: (notifyMethod, notifyContext)->
      @setNotifyMethod notifyMethod
      @setNotifyContext notifyContext



  return LeanRC::Observer.initialize()
