# вычленяем из Record'а все что связано с релейшенами, т.к. Рекорды на основе key-value базы данных (Redis-like) не смогут поддерживать связи - т.к. на фундаментальном уровне кроме поиска по id в них нереализован поиск по НЕ-первичным ключам или сложным условиям
_ = require 'lodash'
joi = require 'joi'
inflect = do require 'i'


# миксин для подмешивания в классы унаследованные от Module::Record
# если в этих классах необходим функционал релейшенов.


module.exports = (Module)->
  Module.defineMixin Module::CoreObject, (BaseClass) ->
    class RelationsMixin extends BaseClass
      @inheritProtected()
      @implements Module::RelationsMixinInterface

      @public @static belongsTo: Function,
        default: (typeDefinition, {attr, refKey, get, set, transform, through, inverse, valuable, sortable, groupable, filterable}={})->
          # TODO: возможно для фильтрации по этому полю, если оно valuable надо как-то зайдествовать customFilters
          [vsAttr] = Object.keys typeDefinition
          attr ?= "#{vsAttr}Id"
          refKey ?= 'id'
          @attribute "#{attr}": String
          if attr isnt "#{vsAttr}Id"
            @computed "#{vsAttr}Id": String,
              valuable: "#{vsAttr}Id"
              filterable: "#{vsAttr}Id"
              set: (aoData)->
                aoData = set?.apply(@, [aoData]) ? aoData
                @[attr] = aoData
                return
              get: ->
                get?.apply(@, [@[attr]]) ? @[attr]
          opts =
            valuable: valuable
            sortable: sortable
            groupable: groupable
            filterable: filterable
            transform: transform ? ->
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
              @Module::[vsRecordName]
            validate: -> opts.transform.call(@).schema
            inverse: inverse ? "#{inflect.pluralize inflect.camelize @name, no}"
            relation: 'belongsTo'
            set: (aoData)->
              if (id = aoData?[refKey])?
                @[attr] = set?.apply(@, [id]) ? id #id
                return
              else
                @[attr] = set?.apply(@, [null]) ? null #null
                return
            get: ->
              Module::Utils.co =>
                vcRecord = opts.transform.call(@)
                vsCollectionName = "#{inflect.pluralize vcRecord.name.replace /Record$/, ''}Collection"
                vsCollectionName = switch vsCollectionName
                  when 'UsersCollection'
                    Module::USERS
                  when 'SessionsCollection'
                    Module::SESSIONS
                  when 'SpacesCollection'
                    Module::SPACES
                  when 'MigrationsCollection'
                    Module::MIGRATIONS
                  when 'RolesCollection'
                    Module::ROLES
                  when 'UploadsCollection'
                    Module::UPLOADS
                  else
                    vsCollectionName
                voCollection = @collection.facade.retrieveProxy vsCollectionName
                unless through
                  cursor = yield voCollection.takeBy "@doc.#{refKey}": get?.apply(@, [@[attr]]) ? @[attr]
                  cursor.first()
                else
                  if @[through[0]]?[0]?
                    yield voCollection.take @[through[0]][0][through[1].by]
                  else
                    null
          @computed @async "#{vsAttr}": Module::RecordInterface, opts
          @metaObject.addMetaData 'relations', vsAttr, opts
          return

      @public @static hasMany: Function,
        default: (typeDefinition, opts={})->
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.relation = 'hasMany'
          opts.transform ?= ->
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
              @Module::[vsRecordName]
          opts.validate = -> joi.array().items opts.transform.call(@).schema
          opts.get = ->
            Module::Utils.co =>
              vcRecord = opts.transform.call(@)
              vsCollectionName = "#{inflect.pluralize vcRecord.name.replace /Record$/, ''}Collection"
              vsCollectionName = switch vsCollectionName
                when 'UsersCollection'
                  Module::USERS
                when 'SessionsCollection'
                  Module::SESSIONS
                when 'SpacesCollection'
                  Module::SPACES
                when 'MigrationsCollection'
                  Module::MIGRATIONS
                when 'RolesCollection'
                  Module::ROLES
                when 'UploadsCollection'
                  Module::UPLOADS
                else
                  vsCollectionName
              voCollection = @collection.facade.retrieveProxy vsCollectionName
              unless opts.through
                yield voCollection.takeBy "@doc.#{opts.inverse}": @[opts.refKey]
              else
                if @[opts.through[0]]?
                  throughItems = yield @[opts.through[0]]
                  yield voCollection.takeMany throughItems.map (i)->
                    i[opts.through[1].by]
                else
                  null
          @computed @async "#{vsAttr}": Module::CursorInterface, opts
          @metaObject.addMetaData 'relations', vsAttr, opts
          return

      @public @static hasOne: Function,
        default: (typeDefinition, opts={})->
          # TODO: возможно для фильтрации по этому полю, если оно valuable надо как-то зайдествовать customFilters
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.relation = 'hasOne'
          opts.transform ?= ->
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
              @Module::[vsRecordName]
          opts.validate = -> opts.transform.call(@).schema
          opts.get = ->
            Module::Utils.co =>
              vcRecord = opts.transform.call(@)
              vsCollectionName = "#{inflect.pluralize vcRecord.name.replace /Record$/, ''}Collection"
              vsCollectionName = switch vsCollectionName
                when 'UsersCollection'
                  Module::USERS
                when 'SessionsCollection'
                  Module::SESSIONS
                when 'SpacesCollection'
                  Module::SPACES
                when 'MigrationsCollection'
                  Module::MIGRATIONS
                when 'RolesCollection'
                  Module::ROLES
                when 'UploadsCollection'
                  Module::UPLOADS
                else
                  vsCollectionName
              voCollection = @collection.facade.retrieveProxy vsCollectionName
              cursor = yield voCollection.takeBy "@doc.#{opts.inverse}": @[opts.refKey]
              cursor.first()
          @computed @async typeDefinition, opts
          @metaObject.addMetaData 'relations', vsAttr, opts
          return

      # Cucumber.inverseFor 'tomato' #-> {recordClass: App::Tomato, attrName: 'cucumbers', relation: 'hasMany'}
      @public @static inverseFor: Function,
        default: (asAttrName)->
          vhRelationConfig = @relations[asAttrName]
          recordClass = vhRelationConfig.transform.call(@)
          {inverse:attrName} = vhRelationConfig
          {relation} = recordClass.relations[attrName]
          return {recordClass, attrName, relation}

      @public @static relations: Object,
        get: -> @metaObject.getGroup 'relations'



    RelationsMixin.initializeMixin()
