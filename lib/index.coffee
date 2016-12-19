class FoxxMC
  CoreObject:       require './CoreObject'
  Cursor:           require './Cursor'
  Mixin:            require './Mixin'
  Query:            require './Query'
  Controller:       require './Controller'
  Model:            require './Model'
  Router:           require './Router'

  Utils:
    cleanConfig:    require './utils/cleanConfig'
    runJob:         require './utils/runJob'
    sendEmail:      require './utils/sendEmail'
    uuid:           require './utils/uuid'
    extend:         require './utils/extend'
    defineClasses:  require './utils/defineClasses'
    sessions:       require './utils/sessions'
    auth:           require './utils/auth'

  Scripts:
    delayedJob:     require './scripts/delayedJob'
    migrate:        require './scripts/migrate'
    resetAdmin:     require './scripts/resetAdmin'
    rollback:       require './scripts/rollback'
    sendSignal:     require './scripts/sendSignal'
    setup:          require './scripts/setup'
    teardown:       require './scripts/teardown'
    touchQueue:     require './scripts/touchQueue'


module.exports = global['FoxxMC'] = FoxxMC
