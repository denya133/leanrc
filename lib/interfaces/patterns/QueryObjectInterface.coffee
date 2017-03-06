

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::QueryObjectInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual where: Array
    @public @virtual letBeforeWhereParams: Array
    @public @virtual letAfterWhereParams: Array
    @public @virtual letAfterCollectParams: Array
    @public @virtual sort: Array
    @public @virtual sortAfterCollectParams: Array
    @public @virtual select: String
    @public @virtual limit: String
    @public @virtual group: String
    @public @virtual aggregate: String
    @public @virtual into: String
    @public @virtual having: Array
    @public @virtual havingJoins: Array
    @public @virtual joins: Array
    @public @virtual from: String
    @public @virtual includes: Array
    @public @virtual count: String
    @public @virtual distinct: String
    @public @virtual average: String
    @public @virtual minimum: String
    @public @virtual maximum: String
    @public @virtual sum: String
    @public @virtual pluck: String


  return LeanRC::QueryObjectInterface.initialize()
