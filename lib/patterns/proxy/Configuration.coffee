# надо унаследовать от Proxy
# этот класс должен будет использоваться для того, чтобы объявлять в дочерних классах конфигурационные данные.

# в файле манифеста будут поумолчанию (всегда) объявляться дефолтные конфиги
# папка configs будет указана в gitignore но в ней можно создавать файлы с конфигами, значения которых должны переопределять дефолтные значения.
# там же в configs фолдере будут примеры файлов - шаблоны с расширением .example

# для Arango платформы в конкретном приложении Configuration класс должен быть расширен миксином, который за данными должен обращаться (вместо дефолтного обращения к жесткому диску) к module.context.configuration


###
```coffee
module.exports = (Module)->
  class AppConfiguration extends Module::Configuration
    @inheritProtected()
    @include Module::ArangoConfigurationMixin

    @module Module

  return AppConfiguration.initialize()
```
###

###
```coffee
module.exports = (Module)->
  {CONFIGURATION} = Module::

  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()

    @module Module

    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy Module::AppConfiguration.new CONFIGURATION,
          environment: 'production'
        #...

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
  {extend} = Module::Utils

  class Configuration extends Module::Proxy
    @inheritProtected()

    @module Module

    # может быть переопределен в миксинах с платформенным кодом
    @public configs: Object,
      get: ->
        manifestPath = "#{@Module::ROOT}/../manifest.json"
        configFromManifest = require(manifestPath).configuration
        {env, environment} = @getData()
        vsEnv = env ? environment ? 'development'
        filePath = "#{@Module::ROOT}/../configs/#{vsEnv}"
        configFromFile = require filePath
        extend {}, configFromManifest, configFromFile


  Configuration.initialize()
