Stream = require 'stream'


module.exports = (Module)->
  {
    ANY
    NILL
    SwitchInterface
  } = Module::

  Module.defineInterface 'ResponseInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @virtual res: Object
      @public @virtual switch: SwitchInterface

      @public @virtual socket: Object
      @public @virtual header: Object
      @public @virtual headers: Object

      @public @virtual status: Number
      @public @virtual message: String
      @public @virtual body: [String, Buffer, Object, Stream]
      @public @virtual length: Number
      @public @virtual headerSent: Boolean
      @public @virtual vary: Function,
        args: [String]
        return: NILL
      @public @virtual redirect: Function,
        args: [String, String]
        return: NILL
      @public @virtual attachment: Function,
        args: [String]
        return: NILL
      @public @virtual lastModified: Date
      @public @virtual etag: String
      @public @virtual type: String
      @public @virtual is: Function,
        args: [[String, Array]]
        return: [String, Boolean, NILL]
      @public @virtual get: Function,
        args: [String]
        return: String
      @public @virtual set: Function,
        args: [[String, Object, Array], String]
        return: NILL
      @public @virtual append: Function,
        args: [String, [String, Array]]
        return: [String, Array]
      @public @virtual remove: Function,
        args: [String]
        return: NILL
      @public @virtual writable: Function,
        args: []
        return: Boolean

      @public @virtual toJSON: Function,
        args: []
        return: Object

      @public @virtual inspect: Function,
        args: []
        return: Object


      @initializeInterface()
