

module.exports = (Module)->
  {
    RecordInterface
    Record
    Utils: { _, inflect, joi, co }
  } = Module::

  Module.defineMixin 'EmbeddableRecordMixin', (BaseClass = Record) ->
    class extends BaseClass
      @inheritProtected()

      @public @static schema: Object,
        default: {}
        get: (_data)->
          _data[@name] ?= do =>
            vhAttrs = {}
            for own asAttr, ahValue of @attributes
              vhAttrs[asAttr] = do (asAttr, ahValue)=>
                if _.isFunction ahValue.validate
                  ahValue.validate.call(@)
                else
                  ahValue.validate

            for own asAttr, ahValue of @embeddings
              vhAttrs[asAttr] = do (asAttr, ahValue)=>
                if _.isFunction ahValue.validate
                  ahValue.validate.call(@)
                else
                  ahValue.validate
            joi.object vhAttrs
          _data[@name]

      @public @static hasEmbed: RecordInterface,
        default: (typeDefinition, opts={})->
          # TODO: возможно для фильтрации по этому полю, если оно valuable надо как-то зайдествовать customFilters
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.embedding = 'hasEmbed'
          opts.transform ?= ->
            [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            (@Module.NS ? @Module::)[vsRecordName]
          opts.validate = -> opts.transform.call(@).schema
          opts.get = ->
            self = @
            co ->
              vcRecord = opts.transform.call(self)
              vsCollectionName = "#{inflect.pluralize vcRecord.name.replace /Record$/, ''}Collection"
              voCollection = self.collection.facade.retrieveProxy vsCollectionName
              cursor = yield voCollection.takeBy "@doc.#{opts.inverse}": self[opts.refKey]
              return yield cursor.first()
          @metaObject.addMetaData 'embeddings', vsAttr, opts
          @public "#{vsAttr}": RecordInterface
          @computed @async "#{vsAttr}Embed": RecordInterface, opts
          return

      @public @static hasEmbeds: Array,
        default: (typeDefinition, opts={})->
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.embedding = 'hasEmbeds'
          opts.transform ?= ->
            # TODO: сдесь надо добавить обертку на основе ArrayTransform потому что может быть вызван normalize метод
            [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            (@Module.NS ? @Module::)[vsRecordName]
          opts.validate = -> joi.array().items opts.transform.call(@).schema
          opts.get = ->
            self = @
            co ->
              vcRecord = opts.transform.call(self)
              vsCollectionName = "#{inflect.pluralize vcRecord.name.replace /Record$/, ''}Collection"
              voCollection = self.collection.facade.retrieveProxy vsCollectionName
              unless opts.through
                yield voCollection.takeBy "@doc.#{opts.inverse}": self[opts.refKey]
              else
                if self[opts.through[0]]?
                  throughItems = yield self[opts.through[0]]
                  yield voCollection.takeMany throughItems.map (i)->
                    i[opts.through[1].by]
                else
                  null
          @metaObject.addMetaData 'embeddings', vsAttr, opts
          @public "#{vsAttr}": Array
          @public @async "#{vsAttr}Embeds": Module::CursorInterface, opts
          return

      @public @static embeddings: Object,
        get: -> @metaObject.getGroup 'embeddings', no

      @public @static @async normalize: Function,
        default: (ahPayload, aoCollection)->
          unless ahPayload?
            return null
          vhAttributes = {}

          unless ahPayload.type?
            throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

          RecordClass = if @name is ahPayload.type.split('::')[1]
            @
          else
            @findRecordByName ahPayload.type

          for own asAttr, { transform } of RecordClass.attributes
            vhAttributes[asAttr] = yield transform.call(RecordClass).normalize ahPayload[asAttr]

          vhAttributes.type = ahPayload.type
          # NOTE: vhAttributes processed before new - it for StateMachine in record (when it has)

          result = RecordClass.new vhAttributes, aoCollection

          for own asAttr, { embedding } of RecordClass.embeddings
            switch embedding
              when 'hasEmbed'
                compAttr = "#{asAttr}Embed"
                vhAttributes[asAttr] = yield result[compAttr]
              when 'hasEmbeds'
                compAttr = "#{asAttr}Embeds"
                vhAttributes[asAttr] = yield (yield result[compAttr]).toArray()
            result[asAttr] = vhAttributes[asAttr]

          result[ipoInternalRecord] = vhAttributes

          yield return result

      @public @static @async serialize:   Function,
        default: (aoRecord)->
          unless aoRecord?
            return null

          unless aoRecord.type?
            throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

          vhResult = {}
          for own asAttr, { transform } of aoRecord.constructor.attributes
            vhResult[asAttr] = yield transform.call(@).serialize aoRecord[asAttr]
          for own asAttr, { transform } of aoRecord.constructor.embeddings
            yield transform.call(@).serialize aoRecord[asAttr]
          yield return vhResult

      @public @static objectize:   Function,
        default: (aoRecord)->
          unless aoRecord?
            return null

          unless aoRecord.type?
            throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

          vhResult = {}
          # for own asAttr, ahValue of aoRecord.constructor.attributes
          #   vhResult[asAttr] = do (asAttr, {transform} = ahValue)=>
          #     transform.call(@).objectize aoRecord[asAttr]
          for own asAttr, { transform } of aoRecord.constructor.attributes
            vhResult[asAttr] = transform.call(@).objectize aoRecord[asAttr]
          for own asAttr, { transform } of aoRecord.constructor.embeddings
            vhResult[asAttr] = transform.call(@).objectize aoRecord[asAttr]
          vhResult

      # TODO: надо разобраться, что делать с changedAttributes с учетом вложенных объектов и массивов


      @initializeMixin()
