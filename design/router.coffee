{SELF, NULL} = FoxxMC::Constants

# надо решить вопрос с тем, как отдельно на разных платформах определять адаптеры для роутера (для nodejs чтобы был экспрессный адаптер, который будет создавать экспрессные роуты, а для arangodb - отдельный адаптер, который будет создавать Foxx роуты)

class RouterInterface extends Interface
  @private _path: String
  @private _name: String
  @private _module: String
  @private _only: Array
  @private _via: Array
  @private _except: Array
  @private _at: String
  @private _controller: String

  @public map: Function, [lambda], -> SELF
  @public root: Function, [Object], -> NULL
  @public defineMethod: Function, [Array, String, String, Object], -> NULL
  @public get: Function, [String, Object], -> NULL
  @public post: Function, [String, Object], -> NULL
  @public put: Function, [String, Object], -> NULL
  @public patch: Function, [String, Object], -> NULL
  @public delete: Function, [String, Object], -> NULL

  @public resource: Function, [String, Object, Function], -> NULL
  @public namespace: Function, [String, Object, Function], -> NULL
  @public member: Function, [Function], -> NULL
  @public collection: Function, [Function], -> NULL


class Router extends CoreObject
  @implements RouterInterface
