_ = require 'lodash'

# миксин подмешивается к классам унаследованным от Module::Resource
# если необходимо переопределить экшен list так чтобы он принимал квери (из браузера) и отдавал не все рекорды в коллекции, а только отфильтрованные
# а также для добавления экшена query который будет использоваться из HttpCollectionMixin'а


module.exports = (Module)->
  Module.defineMixin Module::Resource, (BaseClass) ->
    class QueryableResourceMixin extends BaseClass
      @inheritProtected()

      MAX_LIMIT   = 50

      @action @async list: Function,
        default: ->
          receivedQuery = _.pick @query, [
            '$filter', '$sort', '$limit', '$offset'
          ]
          voQuery = Module::Query.new()
            .forIn '@doc': @collection.collectionFullName()
            .return '@doc'
          if receivedQuery.$filter
            voQuery.filter receivedQuery.$filter
          if receivedQuery.$sort
            voQuery.sort receivedQuery.$sort
          if receivedQuery.$limit
            voQuery.limit receivedQuery.$limit
          if receivedQuery.$offset
            voQuery.offset receivedQuery.$offset

          limit = Number voQuery.$limit
          voQuery.limit = switch
            when limit > MAX_LIMIT, limit < 0, isNaN limit then MAX_LIMIT
            else limit
          skip = Number voQuery.$offset
          voQuery.offset = switch
            when skip < 0, isNaN skip then 0
            else skip

          vlItems = yield (yield @collection.query voQuery).toArray()
          return {
            meta:
              pagination:
                total: 'not defined'
                limit: 'not defined'
                offset: 'not defined'
            items: vlItems
          }

      @action @async executeQuery: Function,
        default: ->
          receivedQuery = _.omit @body.query, [
            '$insert', '$update', '$replace'
          ]
          ipsMultitonKey = Symbol.for '~multitonKey'
          multitonKey = @collection[ipsMultitonKey]
          collectionName = @collection.getProxyName()
          switch
            when @body.query.$insert?
              replica = @body.query.$insert
              replica.multitonKey = multitonKey
              replica.collectionName = collectionName
              voRecord = @collection.delegate.restoreObject @Module, replica
              receivedQuery.$insert = voRecord
            when @body.query.$update?
              replica = @body.query.$update
              replica.multitonKey = multitonKey
              replica.collectionName = collectionName
              voRecord = @collection.delegate.restoreObject @Module, replica
              receivedQuery.$update = voRecord
            when @body.query.$replace?
              replica = @body.query.$replace
              replica.multitonKey = multitonKey
              replica.collectionName = collectionName
              voRecord = @collection.delegate.restoreObject @Module, replica
              receivedQuery.$replace = voRecord

          # isCustomReturn = (
          #   receivedQuery.$collect? or
          #   receivedQuery.$count? or
          #   receivedQuery.$sum? or
          #   receivedQuery.$min? or
          #   receivedQuery.$max? or
          #   receivedQuery.$avg? or
          #   receivedQuery.$remove? or
          #   receivedQuery.$return isnt '@doc' and not receivedQuery.$insert?
          # )
          return yield (yield @collection.query receivedQuery).toArray()

      # ------------ Chains definitions ---------
      @chains ['executeQuery']

      @initialHook 'adminOnly', only: ['executeQuery']
      @initialHook 'parseBody', only: ['executeQuery']
      @beforeHook 'getRecordBody', only: ['executeQuery']


    QueryableResourceMixin.initializeMixin()
