

module.exports = (Module)->
  {
    Resource, Mixin
    Utils: { _, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'

  Module.defineMixin Mixin 'EditableResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @beforeHook 'protectEditable',        only: ['create', 'update', 'delete']
      @beforeHook 'setCurrentUserOnCreate', only: ['create']
      @beforeHook 'setCurrentUserOnUpdate', only: ['update']
      @beforeHook 'setCurrentUserOnDelete', only: ['delete']

      @public @async setCurrentUserOnCreate: Function,
        default: (args...)->
          @recordBody.creatorId = @session.uid ? null
          @recordBody.editorId = @recordBody.creatorId
          yield return args

      @public @async setCurrentUserOnUpdate: Function,
        default: (args...)->
          @recordBody.editorId = @session.uid ? null
          yield return args

      @public @async setCurrentUserOnDelete: Function,
        default: (args...)->
          @recordBody.editorId = @session.uid ? null
          @recordBody.removerId = @recordBody.editorId
          yield return args

      @public @async protectEditable: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['creatorId', 'editorId', 'removerId']
          yield return args


      @initializeMixin()
