_             = require 'lodash'
statuses      = require 'statuses'

HTTP_NOT_FOUND    = statuses 'not found'


module.exports = (Module)->
  {
    Resource
  } = Module::

  Module.defineMixin Resource, (BaseClass) ->
    class PersoningResourceMixin extends BaseClass
      @inheritProtected()

      @public @async limitByUserSpace: Function,
        default: (args...)->
          @listQuery ?= {}
          currentUserSpace = @currentUser.spaceId
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
          currentUserSpace = @currentUser.spaceId
          unless @recordId?
            @context.throw HTTP_NOT_FOUND
          unless (yield @collection.exists
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: [currentUserSpace]
          )
            @context.throw HTTP_NOT_FOUND
          yield return args


    PersoningResourceMixin.initializeMixin()
