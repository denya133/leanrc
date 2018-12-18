

module.exports = (Module)->
  {
    FuncG
    Collection, Mixin
  } = Module::

  Module.defineMixin Mixin 'BulkMethodsCollectionMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()

      @public @async bulkDelete: FuncG(String),
        default: (query)->
          {
            LogMessage: {
              SEND_TO_LOG
              LEVELS
              DEBUG
            }
          } = Module::
          { deletedAt, removerId, filter, offset = 0 } = JSON.parse query
          batchSize = 1000
          fetchQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter filter
            .sort {'@doc.createdAt': 'ASC'}
            .offset offset
            .limit batchSize
            .count '@doc'

          @sendNotification(SEND_TO_LOG, "BulkMethodsCollectionMixin::bulkDelete fetchQuery = #{JSON.stringify fetchQuery}", LEVELS[DEBUG])

          count = yield (yield @query fetchQuery).first()

          if count > 0
            updatedAt = deletedAt
            isHidden = yes
            editorId = removerId
            deleteQuery = Module::Query.new()
              .forIn '@doc': @collectionFullName()
              .filter filter
              .sort {'@doc.createdAt': 'ASC'}
              .offset offset
              .limit batchSize
              .patch { updatedAt, deletedAt, isHidden, editorId, removerId }
              .into @collectionFullName()

            @sendNotification(SEND_TO_LOG, "BulkMethodsCollectionMixin::bulkDelete deleteQuery = #{JSON.stringify deleteQuery}", LEVELS[DEBUG])

            yield @query deleteQuery

            if count is batchSize
              yield @delay @facade
                .bulkDelete JSON.stringify {
                  deletedAt
                  removerId
                  filter
                  offset: offset + batchSize
                }
          yield return

      @public @async bulkDestroy: FuncG(String),
        default: (query)->
          {
            LogMessage: {
              SEND_TO_LOG
              LEVELS
              DEBUG
            }
          } = Module::
          { filter } = JSON.parse query
          batchSize = 1000
          fetchQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter filter
            .sort {'@doc.createdAt': 'ASC'}
            .offset 0
            .limit batchSize
            .count '@doc'

          @sendNotification(SEND_TO_LOG, "BulkMethodsCollectionMixin::bulkDestroy fetchQuery = #{JSON.stringify fetchQuery}", LEVELS[DEBUG])

          count = yield (yield @query fetchQuery).first()

          if count > 0
            removeQuery = Module::Query.new()
              .forIn '@doc': @collectionFullName()
              .filter filter
              .sort {'@doc.createdAt': 'ASC'}
              .offset 0
              .limit batchSize
              .remove 'all'
              .into @collectionFullName()

            @sendNotification(SEND_TO_LOG, "BulkMethodsCollectionMixin::bulkDestroy removeQuery = #{JSON.stringify removeQuery}", LEVELS[DEBUG])

            yield @query removeQuery

            if count is batchSize
              yield @delay @facade
                .bulkDestroy JSON.stringify { filter }
          yield return


      @initializeMixin()
