_             = require 'lodash'
inflect       = do require 'i'


###
```coffee
module.exports = (Module)->
  class BaseConfiguration extends Module::Configuration
    @inheritProtected()
    @include Module::MemoryConfigurationMixin
    @module Module

  return BaseConfiguration.initialize()
```

```coffee
module.exports = (Module)->
  {CONFIGURATION} = Module::

  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy Module::BaseConfiguration.new CONFIGURATION,
          cookieSecret:
            description: "Cookie secret for sessions middleware."
            type: "string"
            default: "secret"
            required: yes

          secret:
            description: "Secret key for encoding and decoding tokens."
            type: "string"
            default: "secret"
            required: yes
        #...

  PrepareModelCommand.initialize()
```
###


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineMixin Module::Configuration, (BaseClass) ->
    class MemoryConfigurationMixin extends BaseClass
      @inheritProtected()

      @public ROOT: String,
        get: -> @Module::ROOT

      @public defineConfigProperties: Function,
        default: ->
          configs = @getData()
          for own key, value of configs
            do (attr = key, config = value)=>
              unless config.description?
                throw new Error "Description in config definition is required"
                return
              if config.required and not config.default?
                throw new Error "Attribute '#{attr}' is required in config"
                return
              # проверка типа
              unless config.type?
                throw new Error "Type in config definition is required"
                return
              switch config.type
                when 'string'
                  unless _.isString config.default
                    throw new Error "Default for '#{attr}' must be string"
                    return
                when 'number'
                  unless _.isNumber config.default
                    throw new Error "Default for '#{attr}' must be number"
                    return
                when 'boolean'
                  unless _.isBoolean config.default
                    throw new Error "Default for '#{attr}' must be boolean"
                    return
                when 'integer'
                  unless _.isInteger config.default
                    throw new Error "Default for '#{attr}' must be integer"
                    return
                when 'json'
                  unless _.isObject(config.default) or _.isArray(config.default)
                    throw new Error "Default for '#{attr}' must be object or array"
                    return
                when 'password' #like string but will be displayed as a masked input field in the web frontend
                  unless _.isString config.default
                    throw new Error "Default for '#{attr}' must be string"
                    return
              Reflect.defineProperty @, attr,
                enumerable: yes
                configurable: yes
                writable: no
                value: config.default
              return
          return

    MemoryConfigurationMixin.initializeMixin()
