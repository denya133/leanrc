# _         = require 'lodash'
# fs        = require 'fs'
RC = require 'RC'


class LeanRC extends RC::Module
  @inheritProtected()
  # Utils: {}
  # Scripts: {}
  Constants:    require './Constants'

  require('./interfaces/patterns/TransformInterface') LeanRC # done
  require('./interfaces/patterns/NotificationInterface') LeanRC # done
  require('./interfaces/patterns/NotifierInterface') LeanRC # done
  require('./interfaces/patterns/ObserverInterface') LeanRC # done
  require('./interfaces/patterns/CommandInterface') LeanRC
  require('./interfaces/patterns/MediatorInterface') LeanRC # done
  require('./interfaces/patterns/ProxyInterface') LeanRC
  require('./interfaces/patterns/PromiseInterface') LeanRC
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
  require('./interfaces/patterns/StockInterface') LeanRC

  require('./interfaces/core/ControllerInterface') LeanRC
  require('./interfaces/core/ModelInterface') LeanRC
  require('./interfaces/core/ViewInterface') LeanRC

  require('./mixins/RecordMixin') LeanRC

  require('./patterns/data_mapper/Transform') LeanRC # done
  require('./patterns/data_mapper/StringTransform') LeanRC # done
  require('./patterns/data_mapper/NumberTransform') LeanRC # done
  require('./patterns/data_mapper/DateTransform') LeanRC # done
  require('./patterns/data_mapper/BooleanTransform') LeanRC # done
  require('./patterns/data_mapper/Serializer') LeanRC # done
  require('./patterns/data_mapper/Record') LeanRC # done
  require('./patterns/data_mapper/Entry') LeanRC # done

  require('./patterns/query_object/Query') LeanRC # done

  require('./patterns/observer/Notification') LeanRC # done
  require('./patterns/observer/Notifier') LeanRC # done
  require('./patterns/observer/Observer') LeanRC # done

  require('./patterns/proxy/Proxy') LeanRC
  require('./patterns/proxy/Collection') LeanRC

  require('./patterns/mediator/Mediator') LeanRC # done

  require('./patterns/command/SimpleCommand') LeanRC
  require('./patterns/command/MacroCommand') LeanRC

  require('./patterns/facade/Facade') LeanRC

  require('./core/View') LeanRC
  require('./core/Model') LeanRC
  require('./core/Controller') LeanRC




module.exports = LeanRC.initialize()
