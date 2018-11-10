

module.exports = (Module)->
  {
    Resource, Mixin
    Utils: { _, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'

  Module.defineMixin Mixin 'PersoningResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @beforeHook 'limitByUserSpace', only: ['list']
      @beforeHook 'setSpaces',      only: ['create']
      @beforeHook 'setOwnerId',     only: ['create']
      @beforeHook 'protectSpaces',  only: ['update']
      @beforeHook 'protectOwnerId', only: ['update']

      @public @async limitByUserSpace: Function,
        default: (args...)->
          @listQuery ?= {}
          currentUserSpace = @session.userSpaceId
          if @listQuery.$filter?
            @listQuery.$filter = $and: [
              @listQuery.$filter
            ,
              '@doc.spaces': $all: [currentUserSpace]
            ]
          else
            @listQuery.$filter = '@doc.spaces': $all: [currentUserSpace]
          yield return args

      @public @async checkExistence: Function,
        default: (args...)->
          currentUserSpace = @session.userSpaceId
          unless @recordId?
            @context.throw HTTP_NOT_FOUND
          unless (yield @collection.exists
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: [currentUserSpace]
          )
            @context.throw HTTP_NOT_FOUND
          yield return args

      @public @async setSpaces: Function,
        default: (args...)->
          @recordBody.spaces ?= []
          unless _.includes @recordBody.spaces, '_internal'
            @recordBody.spaces.push '_internal'
          unless _.includes @recordBody.spaces, @session.userSpaceId
            @recordBody.spaces.push @session.userSpaceId
          yield return args

      @public @async protectSpaces: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['spaces']
          yield return args


      @initializeMixin()
