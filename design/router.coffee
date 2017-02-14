{SELF, NILL} = FoxxMC::Constants

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

  # must be defined by including mixin or direct definition
  @public @virtual createNativeRoute: Function, [String, String, String, String], -> NILL

  @public map: Function, [lambda], -> SELF
  @public root: Function, [Object], -> NILL
  @public defineMethod: Function, [Array, String, String, Object], -> NILL
  @public get: Function, [String, Object], -> NILL
  @public post: Function, [String, Object], -> NILL
  @public put: Function, [String, Object], -> NILL
  @public patch: Function, [String, Object], -> NILL
  @public delete: Function, [String, Object], -> NILL

  @public resource: Function, [String, Object, Function], -> NILL
  @public namespace: Function, [String, Object, Function], -> NILL
  @public member: Function, [Function], -> NILL
  @public collection: Function, [Function], -> NILL


class Router extends CoreObject
  @implements RouterInterface


# example in use
###
```coffee
  Test.context.use Basis::SessionsUtil.middleware

  class Test::ApplicationRouter extends FoxxMC::Router
    @include FoxxRouterMixin
    @Module: Test
    @map ->
      @namespace 'version', module: '', prefix: ':v', ->
        @resource 'invitations', except: 'delete', ->
          @post 'confirm', at: 'collection'
          @member ->
            @post 'sendInvite'
            @resource 'descendants', only: 'list', ->
              @get 'count', at: 'collection'
  module.exports = Test::ApplicationRouter.initialize()
```
###
