

module.exports = (Module)->
  {
    Resource
    Utils: { _, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'

  Module.defineMixin 'EditableResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @beforeHook 'protectEditable',        only: ['create', 'update', 'delete']
      @beforeHook 'setCurrentUserOnCreate', only: ['create']
      @beforeHook 'setCurrentUserOnUpdate', only: ['update']
      @beforeHook 'setCurrentUserOnDelete', only: ['delete']

      @public @async setCurrentUserOnCreate: Function,
        default: (args...)->
          @recordBody.creatorId = @currentUser?.id ? null
          @recordBody.editorId = @recordBody.creatorId
          yield return args

      @public @async setCurrentUserOnUpdate: Function,
        default: (args...)->
          @recordBody.editorId = @currentUser?.id ? null
          yield return args

      @public @async setCurrentUserOnDelete: Function,
        default: (args...)->
          @recordBody.editorId = @currentUser?.id ? null
          @recordBody.removerId = @recordBody.editorId
          yield return args

      @public @async protectEditable: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['creatorId', 'editorId', 'removerId']
          yield return args


      @initializeMixin()
