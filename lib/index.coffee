# _         = require 'lodash'
# fs        = require 'fs'
RC = require 'RC'


class LeanRC extends RC::Module
  @inheritProtected()
  # Utils: {}
  # Scripts: {}
  Constants:    require './Constants'

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
  # require('./interfaces/patterns/ResourceInterface') LeanRC
  require('./interfaces/patterns/StockInterface') LeanRC
  require('./interfaces/patterns/RouterInterface') LeanRC
  # require('./interfaces/patterns/RouteInterface') LeanRC

  require('./interfaces/core/ControllerInterface') LeanRC
  require('./interfaces/core/ModelInterface') LeanRC
  require('./interfaces/core/ViewInterface') LeanRC

  require('./mixins/RecordMixin') LeanRC

  require('./patterns/data_mapper/Transform') LeanRC
  require('./patterns/data_mapper/StringTransform') LeanRC
  require('./patterns/data_mapper/NumberTransform') LeanRC
  require('./patterns/data_mapper/DateTransform') LeanRC
  require('./patterns/data_mapper/BooleanTransform') LeanRC
  require('./patterns/data_mapper/Serializer') LeanRC
  require('./patterns/data_mapper/Record') LeanRC
  require('./patterns/data_mapper/Entry') LeanRC

  require('./patterns/query_object/Query') LeanRC

  require('./patterns/observer/Notification') LeanRC
  require('./patterns/observer/Notifier') LeanRC
  require('./patterns/observer/Observer') LeanRC

  require('./patterns/proxy/Proxy') LeanRC
  require('./patterns/proxy/Collection') LeanRC
  require('./patterns/proxy/Gateway') LeanRC
  require('./patterns/proxy/Renderer') LeanRC
  require('./patterns/proxy/Resource') LeanRC
  require('./patterns/proxy/Router') LeanRC

  require('./patterns/mediator/Mediator') LeanRC

  require('./patterns/command/SimpleCommand') LeanRC
  require('./patterns/command/MacroCommand') LeanRC
  require('./patterns/command/Stock') LeanRC

  require('./patterns/gateway/Endpoint') LeanRC

  require('./patterns/pipes/Pipe') LeanRC
  require('./patterns/pipes/PipeMessage') LeanRC
  require('./patterns/pipes/PipeListener') LeanRC
  require('./patterns/pipes/FilterControlMessage') LeanRC
  require('./patterns/pipes/Filter') LeanRC
  require('./patterns/pipes/Junction') LeanRC
  require('./patterns/pipes/JunctionMediator') LeanRC
  require('./patterns/pipes/PipeAwareModule') LeanRC
  require('./patterns/pipes/QueueControlMessage') LeanRC
  require('./patterns/pipes/Queue') LeanRC
  require('./patterns/pipes/TeeMerge') LeanRC
  require('./patterns/pipes/TeeSplit') LeanRC


  require('./patterns/facade/Facade') LeanRC
  require('./patterns/facade/Application') LeanRC

  require('./core/View') LeanRC
  require('./core/Model') LeanRC
  require('./core/Controller') LeanRC




module.exports = LeanRC.initialize()
