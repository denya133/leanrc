RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::QueryObject extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::QueryObjectInterface

    @Module: LeanRC

    @public where: Array
    @public letBeforeWhereParams: Array
    @public letAfterWhereParams: Array
    @public letAfterCollectParams: Array
    @public sort: Array
    @public sortAfterCollectParams: Array
    @public select: String
    @public limit: String
    @public group: String
    @public aggregate: String
    @public into: String
    @public having: Array
    @public havingJoins: Array
    @public joins: Array
    @public from: String
    @public includes: Array
    @public count: String
    @public distinct: String
    @public average: String
    @public minimum: String
    @public maximum: String
    @public sum: String
    @public pluck: String

    constructor: (
      {
        @where
        @letBeforeWhereParams
        @letAfterWhereParams
        @letAfterCollectParams
        @sort
        @sortAfterCollectParams
        @select
        @limit
        @offset
        @group
        @aggregate
        @into
        @having
        @havingJoins
        @joins
        @from
        @includes
        @count
        @distinct
        @average
        @minimum
        @maximum
        @sum
        @pluck
      } = {}
    )

  return LeanRC::QueryObject.initialize()
