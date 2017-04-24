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
  require('./interfaces/patterns/PipeAwareInterface') LeanRC #does not need testing
  require('./interfaces/patterns/PipeFittingInterface') LeanRC #does not need testing
  require('./interfaces/patterns/PipeMessageInterface') LeanRC #does not need testing
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

  require('./interfaces/core/ControllerInterface') LeanRC #does not need testing
  require('./interfaces/core/ModelInterface') LeanRC #does not need testing
  require('./interfaces/core/ViewInterface') LeanRC #does not need testing

  require('./mixins/CrudEndpointsMixin') LeanRC
  require('./mixins/HttpCollectionMixin') LeanRC
  require('./mixins/IterableMixin') LeanRC #tested
  # require('./mixins/PipesSwitchMixin') LeanRC # empty
  require('./mixins/QueryableMixin') LeanRC #tested
  require('./mixins/RecordMixin') LeanRC #tested
  require('./mixins/RelationsMixin') LeanRC #tested

  require('./patterns/data_mapper/Transform') LeanRC #tested
  require('./patterns/data_mapper/StringTransform') LeanRC #tested
  require('./patterns/data_mapper/NumberTransform') LeanRC #tested
  require('./patterns/data_mapper/DateTransform') LeanRC #tested
  require('./patterns/data_mapper/BooleanTransform') LeanRC #tested
  require('./patterns/data_mapper/Serializer') LeanRC #tested
  require('./patterns/data_mapper/Record') LeanRC #tested
  require('./patterns/data_mapper/Entry') LeanRC # tested

  require('./patterns/query_object/Query') LeanRC #tested

  require('./patterns/observer/Notification') LeanRC #tested
  require('./patterns/observer/Notifier') LeanRC #tested
  require('./patterns/observer/Observer') LeanRC #tested

  require('./patterns/proxy/Proxy') LeanRC #tested
  require('./patterns/proxy/Collection') LeanRC #tested
  require('./patterns/proxy/Configuration') LeanRC
  require('./patterns/proxy/Gateway') LeanRC #tested
  require('./patterns/proxy/Renderer') LeanRC #tested
  require('./patterns/proxy/Resource') LeanRC #tested
  require('./patterns/proxy/Router') LeanRC #tested

  require('./patterns/mediator/Mediator') LeanRC #tested
  require('./patterns/mediator/Switch') LeanRC #tested

  require('./patterns/command/SimpleCommand') LeanRC #tested
  require('./patterns/command/MacroCommand') LeanRC #tested
  require('./patterns/command/Stock') LeanRC
  require('./patterns/command/MigrateCommand') LeanRC
  require('./patterns/command/RollbackCommand') LeanRC

  require('./patterns/migration/Migration') LeanRC

  require('./patterns/gateway/Endpoint') LeanRC #tested

  require('./patterns/iterator/Cursor') LeanRC #tested

  require('./patterns/pipes/Pipe') LeanRC #tested
  require('./patterns/pipes/PipeMessage') LeanRC #tested
  require('./patterns/pipes/PipeListener') LeanRC #tested
  require('./patterns/pipes/FilterControlMessage') LeanRC #tested
  require('./patterns/pipes/Filter') LeanRC #tested
  require('./patterns/pipes/Junction') LeanRC #tested
  require('./patterns/pipes/JunctionMediator') LeanRC #tested
  require('./patterns/pipes/PipeAwareModule') LeanRC #tested
  require('./patterns/pipes/QueueControlMessage') LeanRC #tested
  require('./patterns/pipes/Queue') LeanRC #tested
  require('./patterns/pipes/TeeMerge') LeanRC #tested
  require('./patterns/pipes/TeeSplit') LeanRC #tested

  require('./patterns/facade/Facade') LeanRC #tested
  require('./patterns/facade/Application') LeanRC

  require('./core/View') LeanRC #tested
  require('./core/Model') LeanRC #tested
  require('./core/Controller') LeanRC #tested


module.exports = LeanRC.initialize().freeze()
