# надо унаследовать от Proxy
# этот класс должен будет использоваться для того, чтобы объявлять в дочерних классах конфигурационные данные.

# в файле манифеста будут поумолчанию (всегда) объявляться дефолтные конфиги
# папка configs будет указана в gitignore но в ней можно создавать файлы с конфигами, значения которых должны переопределять дефолтные значения.
# там же в configs фолдере будут примеры файлов - шаблоны с расширением .example

# для Arango платформы в конкретном приложении Configuration класс должен быть расширен миксином, который за данными должен обращаться (вместо дефолтного обращения к жесткому диску) к module.context.configuration


###
```coffee
module.exports = (Module)->
  {
    Configuration
    ArangoConfigurationMixin
  } = Module::

  class AppConfiguration extends Configuration
    @inheritProtected()
    @module Module
    @include ArangoConfigurationMixin

  return AppConfiguration.initialize()
```
###

###
```coffee
module.exports = (Module)->
  {
    CONFIGURATION

    SimpleCommand
    AppConfiguration
  } = Module::

  class PrepareModelCommand extends SimpleCommand
    @inheritProtected()

    @module Module

    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy AppConfiguration.new CONFIGURATION, @Module::ROOT

  PrepareModelCommand.initialize()
```
###

###
В папке configs/
должны быть файлы:
development.coffee.example
production.coffee.example
test.coffee.example

Они же должны быть разрешены в гитигноре и быть под репозиторием, все остальные файлы должны быть в гитигноре (не под репозиторием)

Формат данных в конфиг файлах (пример)
```coffee
module.exports =
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

  apiKey:
    description: "Secret key allowing interactions between servers"
    type: "string"
    default: "c%td_tx=22Wh4k=^Gpe3ZrN+f3Ur2h%K8#qHa!zqU78Jtx7Cy95!%XAg4TngZ"

  resetTokenTTL:
    description: "Reset token time-to-live (in seconds)"
    type: "number"
    default: 86400

  adminEmail:
    description: "Admin email."
    type: "string"
    default: null
    required: yes

  #...
```
###

module.exports = (Module)->
  {
    PRODUCTION
    DEVELOPMENT
    ConfigurationInterface
    Utils: { _, assign, isArangoDB }
  } = Module::

  class Configuration extends Module::Proxy
    @inheritProtected()
    @implements ConfigurationInterface
    @module Module

    @public ROOT: String,
      get: -> @getData()

    @public environment: String,
      get: ->
        if isArangoDB()
          if module.context.isProduction
            PRODUCTION
          else
            DEVELOPMENT
        else
          if process?.env?.NODE_ENV is 'production'
            PRODUCTION
          else
            DEVELOPMENT

    @public defineConfigProperties: Function,
      default: ->
        manifestPath = "#{@ROOT}/../manifest.json"
        manifest = require manifestPath
        Reflect.defineProperty @, 'name',
          enumerable: yes
          configurable: yes
          writable: no
          value: manifest.name
        Reflect.defineProperty @, 'description',
          enumerable: yes
          configurable: yes
          writable: no
          value: manifest.description
        Reflect.defineProperty @, 'license',
          enumerable: yes
          configurable: yes
          writable: no
          value: manifest.license
        Reflect.defineProperty @, 'version',
          enumerable: yes
          configurable: yes
          writable: no
          value: manifest.version
        Reflect.defineProperty @, 'keywords',
          enumerable: yes
          configurable: yes
          writable: no
          value: manifest.keywords
        configFromManifest = manifest.configuration
        filePath = "#{@ROOT}/../configs/#{@environment}"
        configFromFile = require filePath
        configs = assign {}, configFromManifest, configFromFile
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
                unless _.isString(config.default)
                  throw new Error "Default for '#{attr}' must be JSON string"
                  return
                try
                  JSON.parse config.default
                catch err
                  throw new Error "Default for '#{attr}' is not valid JSON"
              when 'password' #like string but will be displayed as a masked input field in the web frontend
                unless _.isString config.default
                  throw new Error "Default for '#{attr}' must be string"
                  return
            value = if config.type is 'json'
              JSON.parse config.default
            else
              config.default
            Reflect.defineProperty @, attr, {
              enumerable: yes
              configurable: yes
              writable: no
              value
            }
            return
        return

    @public onRegister: Function,
      default: (args...)->
        @super args...
        @defineConfigProperties()
        return


    @initialize()
