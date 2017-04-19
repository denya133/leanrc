RC = require 'RC'


class RequestApp extends RC::Module
  @inheritProtected()

  require('./AppConstants') RequestApp

  require('./controller/command/StartupCommand') RequestApp
  require('./controller/command/PrepareControllerCommand') RequestApp
  require('./controller/command/PrepareViewCommand') RequestApp
  require('./controller/command/PrepareModelCommand') RequestApp
  require('./controller/command/SendRequestCommand') RequestApp

  require('./view/component/ConsoleComponent') RequestApp
  require('./view/mediator/ConsoleComponentMediator') RequestApp

  require('./model/proxy/RequestProxy') RequestApp

  require('./AppFacade') RequestApp


module.exports = RequestApp.initialize()
