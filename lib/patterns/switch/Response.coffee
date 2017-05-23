

module.exports = (Module)->
  {
    NILL

    CoreObject
    ResponseInterface
  } = Module::

  class Response extends CoreObject
    @inheritProtected()
    @implements ResponseInterface
    @module Module

    ipoRes = @protected res: Object
    @public body: [String, Buffer]
    @public locals: Object
    @public headers: Object
    @public statusCode: Number

    @public attachment: Function,
      default: (filename)->

    @public cookie: Function,
      default: (name, value, options = null)->

    @public download: Function,
      default: (path, filename)->

    @public getHeader: Function,
      default: (name)->

    @public get: Function,
      default: (args...)-> @getHeader args...

    @public json: Function,
      default: (data)->

    @public redirect: Function,
      default: (status, ...,  path)->
        if arguments.length is 1
          status = 302

    @public removeHeader: Function,
      default: (name)->

    @public send: Function,
      args: [[Buffer, String, Object, Array, Number, Boolean]]
      default: (data)->

    @public sendFile: Function,
      default: (path, options = null)->

    @public sendStatus: Function,
      default: (status)->

    @public setHeader: Function,
      default: (name, value)->

    @public set: Function,
      default: (args...)-> @setHeader args...

    @public status: Function,
      default: (status)->

    @public throw: Function,
      return: NILL
      default: (status, reason, options = null)->

    @public type: Function,
      default: (type)->

    @public vary: Function,
      default: (name)->

    @public write: Function,
      args: [[String, Buffer]]
      default: (data)->

    @public init: Function,
      default: (res)->
        @super()
        @[ipoRes] = res
        return


  Response.initialize()
