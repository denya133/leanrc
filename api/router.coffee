{
  Router
  classes
  sessions
} = require 'FoxxMC'

module.context.use sessions

class ApplicationRouter extends Router
  @classes: classes
  @map ()->


module.exports = ApplicationRouter.initialize()
