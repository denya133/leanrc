# вычленяем из Record'а все что связано с релейшенами, т.к. Рекорды на основе key-value базы данных (Redis-like) не смогут поддерживать связи - т.к. на фундаментальном уровне кроме поиска по id в них нереализован поиск по НЕ-первичным ключам или сложным условиям


# миксин для подмешивания в классы унаследованные от Module::Record
# если в этих классах необходим функционал релейшенов.


module.exports = (Module)->
  {
    CoreObject
    Utils: { _, inflect, joi, co }
  } = Module::

  Module.defineMixin 'RelationsMixin', (BaseClass = CoreObject) ->
    class extends BaseClass
      @inheritProtected()
      # @implements Module::RelationsMixinInterface

      @public @static belongsTo: Function,
        default: (typeDefinition, {attr, refKey, get, set, transform, through, inverse, valuable, sortable, groupable, filterable, validate}={})->
          t1 = Date.now()
          # TODO: возможно для фильтрации по этому полю, если оно valuable надо как-то зайдествовать customFilters
          [vsAttr] = Object.keys typeDefinition
          attr ?= "#{vsAttr}Id"
          refKey ?= 'id'
          t2 = Date.now()
          @attribute "#{attr}": String,
            validate: validate ? -> joi.string()
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
          t3 = Date.now()
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
              self = @
              co ->
                vcRecord = opts.transform.call(self)
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
                voCollection = self.collection.facade.retrieveProxy vsCollectionName
                unless through
                  cursor = yield voCollection.takeBy "@doc.#{refKey}": get?.apply(self, [self[attr]]) ? self[attr]
                  return yield cursor.first()
                else
                  if self[through[0]]?[0]?
                    yield voCollection.take self[through[0]][0][through[1].by]
                  else
                    null
          @metaObject.addMetaData 'relations', vsAttr, opts
          @____dt += (Date.now() - t3) + (t2 - t1)
          @computed @async "#{vsAttr}": Module::RecordInterface, opts
          return

      @public @static hasMany: Function,
        default: (typeDefinition, opts={})->
          t1 = Date.now()
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.relation = 'hasMany'
          opts.transform ?= ->
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
              @Module::[vsRecordName]
          opts.validate = -> joi.array().items opts.transform.call(@).schema
          opts.get = ->
            self = @
            co ->
              vcRecord = opts.transform.call(self)
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
                yield voCollection.takeBy "@doc.#{opts.inverse}": self[opts.refKey]
              else
                if self[opts.through[0]]?
                  throughItems = yield self[opts.through[0]]
                  yield voCollection.takeMany throughItems.map (i)->
                    i[opts.through[1].by]
                else
                  null
          @metaObject.addMetaData 'relations', vsAttr, opts
          @____dt += Date.now() - t1
          @computed @async "#{vsAttr}": Module::CursorInterface, opts
          return

      @public @static hasOne: Function,
        default: (typeDefinition, opts={})->
          t1 = Date.now()
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
            self = @
            co ->
              vcRecord = opts.transform.call(self)
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
              voCollection = self.collection.facade.retrieveProxy vsCollectionName
              cursor = yield voCollection.takeBy "@doc.#{opts.inverse}": self[opts.refKey]
              return yield cursor.first()
          @metaObject.addMetaData 'relations', vsAttr, opts
          @____dt += Date.now() - t1
          @computed @async typeDefinition, opts
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



      @initializeMixin()
