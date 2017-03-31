_             = require 'lodash'
joi           = require 'joi'
inflect       = require('i')()
RC            = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::CrudEndpointsMixinInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual keyName: String

    @public @virtual itemEntityName: String

    @public @virtual listEntityName: String

    @public @virtual schema: Object

    @public @virtual listSchema: Object

    @public @virtual itemSchema: Object

    @public @virtual keySchema: Object

    @public @virtual querySchema: Object

    @public @virtual versionSchema: Object

    @public @virtual onRegister: Function,
      args: []
      return: RC::Constants.NILL


  return LeanRC::CrudEndpointsMixinInterface.initialize()
