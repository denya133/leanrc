class FoxxMC
  CoreObject:       require './CoreObject'
  Cursor:           require './Cursor'
  Mixin:            require './Mixin'
  Query:            require './Query'
  Controller:       require './Controller'
  Model:            require './Model'
  Router:           require './Router'

  Utils:
    cleanConfig:    require './cleanConfig'
    runJob:         require './runJob'
    sendEmail:      require './sendEmail'
    uuid:           require './uuid'
    extend:         require './extend'
    defineClasses:  require './defineClasses'
    sessions:       require './sessions'
    auth:           require './auth'


module.exports = global['FoxxMC'] = FoxxMC
