# _         = require 'lodash'
# fs        = require 'fs'
RC = require 'RC'


class LeanRC extends RC::Module
  # Utils: {}
  # Scripts: {}

  require('./interfaces/NotificationInterface') LeanRC # done
  require('./interfaces/NotifierInterface') LeanRC # done
  require('./interfaces/ObserverInterface') LeanRC # done
  require('./interfaces/CommandInterface') LeanRC
  require('./interfaces/MediatorInterface') LeanRC # done
  require('./interfaces/ProxyInterface') LeanRC
  require('./interfaces/ControllerInterface') LeanRC
  require('./interfaces/ModelInterface') LeanRC
  require('./interfaces/ViewInterface') LeanRC
  require('./interfaces/FacadeInterface') LeanRC

  require('./patterns/observer/Notification') LeanRC # done
  require('./patterns/observer/Notifier') LeanRC # done
  require('./patterns/observer/Observer') LeanRC # done
  require('./patterns/proxy/Proxy') LeanRC
  require('./patterns/mediator/Mediator') LeanRC # done
  require('./patterns/command/SimpleCommand') LeanRC
  require('./patterns/command/MacroCommand') LeanRC
  require('./patterns/facade/Facade') LeanRC

  require('./core/View') LeanRC
  require('./core/Model') LeanRC
  require('./core/Controller') LeanRC




module.exports = LeanRC.initialize()
