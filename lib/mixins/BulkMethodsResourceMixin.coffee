

module.exports = (Module)->
  {
    Resource, Mixin
    Utils: { _, joi, moment }
  } = Module::

  Module.defineMixin Mixin 'BulkMethodsResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @chains ['bulkDelete', 'bulkDestroy']
      @beforeHook 'getQuery', only: ['bulkDelete', 'bulkDestroy']

      @action @async bulkDelete: Function,
        default: ->
          receivedQuery = _.pick @listQuery, [
            '$filter'
          ]
          unless receivedQuery.$filter
            @context.throw 400, 'ValidationError: `$filter` must be defined'

          do =>
            { error } = joi.validate receivedQuery.$filter, joi.object()
            if error?
              @context.throw 400, 'ValidationError: `$filter` must be an object', error.stack
          deletedAt = moment().utc().toISOString()
          removerId = @session.uid ? 'system'
          yield @collection.delay @facade
            .bulkDelete JSON.stringify {
              deletedAt
              removerId
              filter: receivedQuery.$filter
            }
          @context.status = 204
          yield return

      @action @async bulkDestroy: Function,
        default: ->
          receivedQuery = _.pick @listQuery, [
            '$filter'
          ]
          unless receivedQuery.$filter
            @context.throw 400, 'ValidationError: `$filter` must be defined'

          do =>
            { error } = joi.validate receivedQuery.$filter, joi.object()
            if error?
              @context.throw 400, 'ValidationError: `$filter` must be an object', error.stack
          yield @collection.delay @facade
            .bulkDestroy JSON.stringify filter: receivedQuery.$filter
          @context.status = 204
          yield return


      @initializeMixin()
