

module.exports = (Module)->
  {
    Resource, Mixin
    Utils: { _, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'

  Module.defineMixin Mixin 'GuestingResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @public namespace: String,
        default: 'guesting'

      @public currentSpaceId: String,
        default: '_external'

      @beforeHook 'limitByExternalSpace', only: ['list']

      @public @async limitByExternalSpace: Function,
        default: (args...)->
          @listQuery ?= {}
          if @listQuery.$filter?
            @listQuery.$filter = $and: [
              @listQuery.$filter
            ,
              '@doc.spaces': $all: [@currentSpaceId]
            ]
          else
            @listQuery.$filter = '@doc.spaces': $all: [@currentSpaceId]
          yield return args

      @public @async checkExistence: Function,
        default: (args...)->
          unless @recordId?
            @context.throw HTTP_NOT_FOUND
          unless (yield @collection.exists(
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: [@currentSpaceId]
          ))
            @context.throw HTTP_NOT_FOUND
          yield return args


      @initializeMixin()
