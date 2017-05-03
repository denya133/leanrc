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
  @const MEM_RESQUE_EXEC:  Symbol 'MemoryResqueExecutor'

  require('./interfaces/patterns/TransformInterface') LeanRC #does not need testing
  require('./interfaces/patterns/NotificationInterface') LeanRC #does not need testing
  require('./interfaces/patterns/NotifierInterface') LeanRC #does not need testing
  require('./interfaces/patterns/ObserverInterface') LeanRC #does not need testing
  require('./interfaces/patterns/CommandInterface') LeanRC #does not need testing
  require('./interfaces/patterns/MediatorInterface') LeanRC #does not need testing
  require('./interfaces/patterns/ProxyInterface') LeanRC #does not need testing
  require('./interfaces/patterns/SerializerInterface') LeanRC #does not need testing
  require('./interfaces/patterns/FacadeInterface') LeanRC #does not need testing
  require('./interfaces/patterns/RecordInterface') LeanRC #does not need testing
  require('./interfaces/patterns/CollectionInterface') LeanRC #does not need testing
  require('./interfaces/patterns/QueryInterface') LeanRC #does not need testing
  require('./interfaces/patterns/CursorInterface') LeanRC #does not need testing
  require('./interfaces/patterns/EndpointInterface') LeanRC #does not need testing
  require('./interfaces/patterns/GatewayInterface') LeanRC #does not need testing
  require('./interfaces/patterns/RendererInterface') LeanRC #does not need testing
  # require('./interfaces/patterns/ResourceInterface') LeanRC # empty #does not need testing
  require('./interfaces/patterns/StockInterface') LeanRC #does not need testing
  require('./interfaces/patterns/RouterInterface') LeanRC #does not need testing
  # require('./interfaces/patterns/RouteInterface') LeanRC # empty #does not need testing
  require('./interfaces/patterns/SwitchInterface') LeanRC #does not need testing

  require('./interfaces/mixins/CrudEndpointsMixinInterface') LeanRC #does not need testing
  require('./interfaces/mixins/IterableMixinInterface') LeanRC #does not need testing
  require('./interfaces/mixins/QueryableMixinInterface') LeanRC #does not need testing
  require('./interfaces/mixins/RelationsMixinInterface') LeanRC #does not need testing
  require('./interfaces/patterns/MigrationInterface') LeanRC #does not need testing
  require('./interfaces/patterns/DelayedQueueInterface') LeanRC #does not need testing
  require('./interfaces/patterns/ResqueInterface') LeanRC #does not need testing
  require('./interfaces/mixins/DelayableMixinInterface') LeanRC #does not need testing
  require('./interfaces/patterns/ScriptInterface') LeanRC #does not need testing

  require('./interfaces/core/ControllerInterface') LeanRC #does not need testing
  require('./interfaces/core/ModelInterface') LeanRC #does not need testing
  require('./interfaces/core/ViewInterface') LeanRC #does not need testing

  require('./mixins/ConfigurableMixin') LeanRC
  require('./mixins/CrudEndpointsMixin') LeanRC
  require('./mixins/HttpCollectionMixin') LeanRC #tested
  require('./mixins/MemoryCollectionMixin') LeanRC
  require('./mixins/MemoryMigrationMixin') LeanRC
  require('./mixins/MemoryResqueMixin') LeanRC
  require('./mixins/IterableMixin') LeanRC #tested
  # require('./mixins/PipesSwitchMixin') LeanRC # empty
  require('./mixins/QueryableMixin') LeanRC #tested
  require('./mixins/RecordMixin') LeanRC #tested
  require('./mixins/RelationsMixin') LeanRC #tested
  require('./mixins/DelayableMixin') LeanRC #tested

  require('./patterns/data_mapper/Transform') LeanRC #tested
  require('./patterns/data_mapper/StringTransform') LeanRC #tested
  require('./patterns/data_mapper/NumberTransform') LeanRC #tested
  require('./patterns/data_mapper/DateTransform') LeanRC #tested
  require('./patterns/data_mapper/BooleanTransform') LeanRC #tested
  require('./patterns/data_mapper/Serializer') LeanRC #tested
  require('./patterns/data_mapper/Record') LeanRC #tested
  require('./patterns/data_mapper/Entry') LeanRC # tested
  require('./patterns/data_mapper/DelayedQueue') LeanRC

  require('./patterns/query_object/Query') LeanRC #tested

  require('./patterns/observer/Notification') LeanRC #tested
  require('./patterns/observer/Notifier') LeanRC #tested
  require('./patterns/observer/Observer') LeanRC #tested

  require('./patterns/proxy/Proxy') LeanRC #tested
  require('./patterns/proxy/Collection') LeanRC #tested
  require('./patterns/proxy/Configuration') LeanRC
  require('./patterns/proxy/Gateway') LeanRC #tested
  require('./patterns/proxy/Renderer') LeanRC #needs update tests
  require('./patterns/proxy/Resource') LeanRC #tested
  require('./patterns/proxy/Router') LeanRC #tested
  require('./patterns/proxy/Resque') LeanRC

  require('./patterns/mediator/Mediator') LeanRC #tested
  require('./patterns/mediator/Switch') LeanRC #needs update tests
  require('./patterns/mediator/MemoryResqueExecutor') LeanRC

  require('./patterns/command/SimpleCommand') LeanRC #tested
  require('./patterns/command/MacroCommand') LeanRC #tested
  require('./patterns/command/Stock') LeanRC
  require('./patterns/command/MigrateCommand') LeanRC
  require('./patterns/command/RollbackCommand') LeanRC
  require('./patterns/command/Script') LeanRC
  require('./patterns/command/DelayedJobScript') LeanRC

  require('./patterns/migration/Migration') LeanRC

  require('./patterns/gateway/Endpoint') LeanRC #tested

  require('./patterns/iterator/Cursor') LeanRC #tested

  require('./patterns/facade/Facade') LeanRC #tested
  require('./patterns/facade/Application') LeanRC

  require('./core/View') LeanRC #tested
  require('./core/Model') LeanRC #tested
  require('./core/Controller') LeanRC #tested


LeanRC.initialize()

class Pipes extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./interfaces/patterns/PipeAwareInterface') Pipes #does not need testing
  require('./interfaces/patterns/PipeFittingInterface') Pipes #does not need testing
  require('./interfaces/patterns/PipeMessageInterface') Pipes #does not need testing

  require('./patterns/pipes/Pipe') Pipes #tested
  require('./patterns/pipes/PipeMessage') Pipes #tested
  require('./patterns/pipes/PipeListener') Pipes #tested
  require('./patterns/pipes/FilterControlMessage') Pipes #tested
  require('./patterns/pipes/Filter') Pipes #tested
  require('./patterns/pipes/Junction') Pipes #tested
  require('./patterns/pipes/JunctionMediator') Pipes #tested
  require('./patterns/pipes/PipeAwareModule') Pipes #tested
  require('./patterns/pipes/QueueControlMessage') Pipes #tested
  require('./patterns/pipes/Queue') Pipes #tested
  require('./patterns/pipes/TeeMerge') Pipes #tested
  require('./patterns/pipes/TeeSplit') Pipes #tested

Pipes.initialize()

LeanRC.const Pipes: Pipes.freeze()

module.exports = LeanRC.freeze()
