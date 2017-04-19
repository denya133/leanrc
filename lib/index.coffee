# _         = require 'lodash'
# fs        = require 'fs'
RC = require 'RC'


class LeanRC extends RC::Module
  @inheritProtected()

  @const HANDLER_RESULT:  0
  @const RECORD_CHANGED:  1
  @const CONFIGURATION:  2

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
  require('./interfaces/patterns/PipeAwareInterface') LeanRC
  require('./interfaces/patterns/PipeFittingInterface') LeanRC
  require('./interfaces/patterns/PipeMessageInterface') LeanRC
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

  require('./interfaces/core/ControllerInterface') LeanRC
  require('./interfaces/core/ModelInterface') LeanRC
  require('./interfaces/core/ViewInterface') LeanRC

  require('./mixins/CrudEndpointsMixin') LeanRC
  require('./mixins/HttpCollectionMixin') LeanRC
  require('./mixins/IterableMixin') LeanRC
  # require('./mixins/PipesSwitchMixin') LeanRC # empty
  require('./mixins/QueryableMixin') LeanRC
  require('./mixins/RecordMixin') LeanRC #tested
  require('./mixins/RelationsMixin') LeanRC #tested

  require('./patterns/data_mapper/Transform') LeanRC #tested
  require('./patterns/data_mapper/StringTransform') LeanRC #tested
  require('./patterns/data_mapper/NumberTransform') LeanRC #tested
  require('./patterns/data_mapper/DateTransform') LeanRC #tested
  require('./patterns/data_mapper/BooleanTransform') LeanRC #tested
  require('./patterns/data_mapper/Serializer') LeanRC
  require('./patterns/data_mapper/Record') LeanRC
  require('./patterns/data_mapper/Entry') LeanRC

  require('./patterns/query_object/Query') LeanRC #tested

  require('./patterns/observer/Notification') LeanRC #tested
  require('./patterns/observer/Notifier') LeanRC #tested
  require('./patterns/observer/Observer') LeanRC #tested

  require('./patterns/proxy/Proxy') LeanRC #tested
  require('./patterns/proxy/Collection') LeanRC #tested
  # require('./patterns/proxy/Configuration') LeanRC # empty
  require('./patterns/proxy/Gateway') LeanRC #tested
  require('./patterns/proxy/Renderer') LeanRC #tested
  require('./patterns/proxy/Resource') LeanRC
  require('./patterns/proxy/Router') LeanRC #tested

  require('./patterns/mediator/Mediator') LeanRC #tested
  require('./patterns/mediator/Switch') LeanRC #tested

  require('./patterns/command/SimpleCommand') LeanRC #tested
  require('./patterns/command/MacroCommand') LeanRC #tested
  require('./patterns/command/Stock') LeanRC
  # require('./patterns/command/MigrateCommand') LeanRC # empty
  # require('./patterns/command/Migration') LeanRC # empty
  # require('./patterns/command/Rollback') LeanRC # empty

  require('./patterns/gateway/Endpoint') LeanRC #tested

  require('./patterns/iterator/Cursor') LeanRC

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

  # require('./patterns/renderer/Template') LeanRC # empty

  require('./patterns/facade/Facade') LeanRC #tested
  require('./patterns/facade/Application') LeanRC

  require('./core/View') LeanRC #tested
  require('./core/Model') LeanRC #tested
  require('./core/Controller') LeanRC #tested


module.exports = LeanRC.initialize()
