

module.exports = (Module)->
  {
    Resource
    Utils: { _, joi }
  } = Module::

  Module.defineMixin 'CountMethodsResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @chains ['count', 'length']
      @beforeHook 'getQuery', only: ['count', 'length']

      @action @async count: Function,
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
          voQuery = Module::Query.new()
            .forIn '@doc': @collection.collectionFullName()
            .filter receivedQuery.$filter
            .count '@doc'
          return yield (yield @collection.query voQuery).first()

      @action @async length: Function,
        default: ->
          return yield @collection.length()


      @initializeMixin()
