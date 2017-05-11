# _         = require 'lodash'
# fs        = require 'fs'
RC = require 'RC'


class LeanRC extends RC
  @inheritProtected()

  @root __dirname

  @const HANDLER_RESULT:  0
  @const RECORD_CHANGED:  1
  @const CONFIGURATION:  Symbol 'ConfigurationProxy'
  @const STARTUP: Symbol 'startup' # для сигнала
  @const MIGRATE: Symbol 'migrate' # для сигнала
  @const ROLLBACK: Symbol 'rollback' # для сигнала
  @const MIGRATIONS: Symbol 'MigrationsCollection'
  @const RESQUE: Symbol 'ResqueProxy'
  @const START_RESQUE: Symbol 'start_resque'
  @const DELAYED_JOBS_QUEUE: 'delayed_jobs'
  @const DELAYED_JOBS_SCRIPT: 'DelayedJobScript'
  @const JOB_RESULT:  Symbol 'JOB_RESULT'
  @const SHELL:  Symbol 'ShellApplication'
  @const APPLICATION_MEDIATOR:  Symbol 'ApplicationMediator'
  @const APPLICATION_ROUTER:  Symbol 'ApplicationRouter'
  @const APPLICATION_RENDERER:  Symbol 'ApplicationRenderer'
  @const MEM_RESQUE_EXEC:  Symbol 'MemoryResqueExecutor'
  @const LOG_MSG: Symbol 'logMessage'

  require('./interfaces/patterns/TransformInterface') LeanRC
  require('./interfaces/patterns/NotificationInterface') LeanRC
  require('./interfaces/patterns/NotifierInterface') LeanRC
  require('./interfaces/patterns/ObserverInterface') LeanRC
  require('./interfaces/patterns/CommandInterface') LeanRC
  require('./interfaces/patterns/MediatorInterface') LeanRC
  require('./interfaces/patterns/ProxyInterface') LeanRC
  require('./interfaces/patterns/SerializerInterface') LeanRC
  require('./interfaces/patterns/FacadeInterface') LeanRC
  require('./interfaces/patterns/RecordInterface') LeanRC
  require('./interfaces/patterns/CollectionInterface') LeanRC
  require('./interfaces/patterns/QueryInterface') LeanRC
  require('./interfaces/patterns/CursorInterface') LeanRC
  require('./interfaces/patterns/EndpointInterface') LeanRC
  require('./interfaces/patterns/GatewayInterface') LeanRC
  require('./interfaces/patterns/RendererInterface') LeanRC
  # require('./interfaces/patterns/ResourceInterface') LeanRC # empty
  require('./interfaces/patterns/StockInterface') LeanRC
  require('./interfaces/patterns/RouterInterface') LeanRC
  # require('./interfaces/patterns/RouteInterface') LeanRC # empty
  require('./interfaces/patterns/SwitchInterface') LeanRC

  require('./interfaces/mixins/CrudEndpointsMixinInterface') LeanRC
  require('./interfaces/mixins/IterableMixinInterface') LeanRC
  require('./interfaces/mixins/QueryableMixinInterface') LeanRC
  require('./interfaces/mixins/RelationsMixinInterface') LeanRC
  require('./interfaces/patterns/MigrationInterface') LeanRC
  require('./interfaces/patterns/DelayedQueueInterface') LeanRC
  require('./interfaces/patterns/ResqueInterface') LeanRC
  require('./interfaces/mixins/DelayableMixinInterface') LeanRC
  require('./interfaces/patterns/ScriptInterface') LeanRC

  require('./interfaces/core/ControllerInterface') LeanRC
  require('./interfaces/core/ModelInterface') LeanRC
  require('./interfaces/core/ViewInterface') LeanRC

  require('./mixins/ConfigurableMixin') LeanRC
  require('./mixins/CrudEndpointsMixin') LeanRC
  require('./mixins/HttpCollectionMixin') LeanRC
  require('./mixins/MemoryCollectionMixin') LeanRC
  require('./mixins/MemoryMigrationMixin') LeanRC
  require('./mixins/MemoryResqueMixin') LeanRC
  require('./mixins/MemoryConfigurationMixin') LeanRC
  require('./mixins/IterableMixin') LeanRC
  # require('./mixins/PipesSwitchMixin') LeanRC # empty
  require('./mixins/QueryableMixin') LeanRC
  require('./mixins/RecordMixin') LeanRC
  require('./mixins/RelationsMixin') LeanRC
  require('./mixins/DelayableMixin') LeanRC
  require('./mixins/BulkActionsStockMixin') LeanRC

  require('./patterns/data_mapper/Transform') LeanRC
  require('./patterns/data_mapper/StringTransform') LeanRC
  require('./patterns/data_mapper/NumberTransform') LeanRC
  require('./patterns/data_mapper/DateTransform') LeanRC
  require('./patterns/data_mapper/BooleanTransform') LeanRC
  require('./patterns/data_mapper/Serializer') LeanRC
  require('./patterns/data_mapper/Record') LeanRC
  require('./patterns/data_mapper/Entry') LeanRC
  require('./patterns/data_mapper/DelayedQueue') LeanRC

  require('./patterns/query_object/Query') LeanRC

  require('./patterns/observer/Notification') LeanRC
  require('./patterns/observer/Notifier') LeanRC
  require('./patterns/observer/Observer') LeanRC

  require('./patterns/proxy/Proxy') LeanRC
  require('./patterns/proxy/Collection') LeanRC
  require('./patterns/proxy/Configuration') LeanRC
  require('./patterns/proxy/Gateway') LeanRC
  require('./patterns/proxy/Renderer') LeanRC
  require('./patterns/proxy/Resource') LeanRC
  require('./patterns/proxy/Router') LeanRC
  require('./patterns/proxy/Resque') LeanRC

  require('./patterns/mediator/Mediator') LeanRC
  require('./patterns/mediator/Switch') LeanRC
  require('./patterns/mediator/MemoryResqueExecutor') LeanRC #needs tests

  require('./patterns/command/SimpleCommand') LeanRC
  require('./patterns/command/MacroCommand') LeanRC
  require('./patterns/command/Stock') LeanRC
  require('./patterns/command/MigrateCommand') LeanRC
  require('./patterns/command/RollbackCommand') LeanRC
  require('./patterns/command/Script') LeanRC
  require('./patterns/command/DelayedJobScript') LeanRC

  require('./patterns/migration/Migration') LeanRC

  require('./patterns/gateway/Endpoint') LeanRC

  require('./patterns/iterator/Cursor') LeanRC

  require('./patterns/facade/Facade') LeanRC

  require('./core/View') LeanRC
  require('./core/Model') LeanRC
  require('./core/Controller') LeanRC


LeanRC.initialize()

class Pipes extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./interfaces/patterns/PipeAwareInterface') Pipes
  require('./interfaces/patterns/PipeFittingInterface') Pipes
  require('./interfaces/patterns/PipeMessageInterface') Pipes

  require('./patterns/pipes/Pipe') Pipes
  require('./patterns/pipes/PipeMessage') Pipes
  require('./patterns/pipes/PipeListener') Pipes
  require('./patterns/pipes/FilterControlMessage') Pipes
  require('./patterns/pipes/Filter') Pipes
  require('./patterns/pipes/Junction') Pipes
  require('./patterns/pipes/JunctionMediator') Pipes
  require('./patterns/pipes/PipeAwareModule') Pipes
  require('./patterns/pipes/QueueControlMessage') Pipes
  require('./patterns/pipes/Queue') Pipes
  require('./patterns/pipes/TeeMerge') Pipes
  require('./patterns/pipes/TeeSplit') Pipes

Pipes.initialize()

LeanRC.const Pipes: Pipes.freeze()

require('./patterns/facade/Application') LeanRC #needs tests
require('./patterns/command/LogMessageCommand') LeanRC #needs tests
require('./patterns/data_mapper/LogMessage') LeanRC #needs tests
require('./patterns/data_mapper/LogFilterMessage') LeanRC #needs tests
require('./mixins/LoggingJunctionMixin') LeanRC #needs tests

module.exports = LeanRC.freeze()
