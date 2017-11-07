_             = require 'lodash'
statuses      = require 'statuses'

HTTP_NOT_FOUND    = statuses 'not found'


module.exports = (Module)->
  {
    Resource
  } = Module::

  Module.defineMixin Resource, (BaseClass) ->
    class AdminingResourceMixin extends BaseClass
      @inheritProtected()

      @public @async limitBySpace: Function,
        default: (args...)->
          @listQuery ?= {}
          currentSpace = @context.pathParams.space
          if @listQuery.$filter?
            @listQuery.$filter = $and: [
              @listQuery.$filter
            ,
              '@doc.spaces': $all: [currentSpace]
            ]
          else
            @listQuery.$filter = '@doc.spaces': $all: [currentSpace]
          yield return args

      @public @async checkExistence: Function,
        default: (args...)->
          currentSpace = @context.pathParams.space
          unless @recordId?
            @context.throw HTTP_NOT_FOUND
          unless (yield @collection.exists
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: [currentSpace]
          )
            @context.throw HTTP_NOT_FOUND
          yield return args


    AdminingResourceMixin.initializeMixin()
