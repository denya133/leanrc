# _         = require 'lodash'
# fs        = require 'fs'


class LeanRC
  # Utils: {}
  # Scripts: {}

  require('./interfaces/NotificationInterface') LeanRC
  require('./interfaces/NotifierInterface') LeanRC
  require('./interfaces/ObserverInterface') LeanRC
  require('./interfaces/CommandInterface') LeanRC
  require('./interfaces/MediatorInterface') LeanRC
  require('./interfaces/ProxyInterface') LeanRC
  require('./interfaces/ControllerInterface') LeanRC
  require('./interfaces/ModelInterface') LeanRC
  require('./interfaces/ViewInterface') LeanRC
  require('./interfaces/FacadeInterface') LeanRC




module.exports = LeanRC
