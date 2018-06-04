# NOTE: through источники для relatedTo и belongsTo связей с опцией through НАДО ОБЪЯВЛЯТЬ ЧЕРЕЗ hasEmbed чтобы корректно отрабатывал сеттер сохраняющий данные об айдишнике подвязанного объекта в промежуточную коллекцию


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

            for own asAttr, ahValue of @computeds
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
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.embedding = 'hasEmbed'
            # valuable: valuable # в этом нет смысла, они по умолчанию должны быть уже normalized и objectized
            # sortable: sortable # если это вложенные-проксируемые объекты, которые в базе в этом рекорде даже не хранятся, каким образом выходной массив рекордов должен быть отсортирован по этой фигне?
            # groupable: groupable # аналогичный вопрос
            # filterable: filterable
          opts.recordName ?= ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= ->
            "#{
              inflect.pluralize opts.recordName.replace /Record$/, ''
            }Collection"
          # opts.transform ?= ->
          #   [vsModuleName, vsRecordName] = @parseRecordName vsAttr
          #   (@Module.NS ? @Module::)[vsRecordName]
          opts.validate = ->
            EmbedRecord = @findRecordByName opts.recordName
            return EmbedRecord.schema.empty(null).default(null)
          opts.load = co.wrap ->
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName
            # NOTE: может быть ситуация, что hasOne связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)
            unless opts.through
              return yield (yield EmbedsCollection.takeBy(
                "@doc.#{opts.inverse}": @[opts.refKey]
              ,
                $limit: 1
              )).first()
            else
              # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
              through = @constructor.embeddings[opts.through[0]]
              unless through?
                throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName
              ThroughRecord = @findRecordByName through.recordName
              inverse = ThroughRecord.relations[opts.through[1].by]
              embedId = (yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[opts.refKey]
              ,
                $limit: 1
              )).first())[opts.through[1].by]
              return yield (yield EmbedsCollection.takeBy(
                "@doc.#{inverse.refKey}": embedId
              ,
                $limit: 1
              )).first()

          opts.put = co.wrap ->
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName
            aoRecord = @[vsAttr]
            if aoRecord?
              unless opts.through
                aoRecord[opts.inverse] = @[opts.refKey]
                aoRecord.spaces = @spaces
                aoRecord.creatorId = @creatorId
                aoRecord.editorId = @editorId
                aoRecord.ownerId = @ownerId
                savedRecord = yield aoRecord.save()
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{opts.inverse}": @[opts.refKey]
                  $not: "@doc.id": savedRecord.id # NOTE: проверяем по айдишнику только-что сохраненного
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
              else
                # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
                through = @constructor.embeddings[opts.through[0]]
                unless through?
                  throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName
                ThroughRecord = @findRecordByName through.recordName
                inverse = ThroughRecord.relations[opts.through[1].by]
                aoRecord.spaces = @spaces
                aoRecord.creatorId = @creatorId
                aoRecord.editorId = @editorId
                aoRecord.ownerId = @ownerId
                if yield aoRecord.isNew()
                  savedRecord = yield aoRecord.save()
                  yield ThroughCollection.create(
                    "#{through.inverse}": @[opts.refKey]
                    "#{opts.through[1].by}": savedRecord[inverse.refKey]
                    spaces: @spaces
                    creatorId: @creatorId
                    editorId: @editorId
                    ownerId: @ownerId
                  )
                else
                  savedRecord = yield aoRecord.save()
                embedIds = yield (yield ThroughCollection.takeBy(
                  "@doc.#{through.inverse}": @[opts.refKey]
                  $not: "@doc.#{opts.through[1].by}": savedRecord[inverse.refKey]
                )).map co.wrap (voRecord)->
                  id = voRecord[opts.through[1].by]
                  yield voRecord.destroy()
                  yield return id
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{inverse.refKey}": $in: embedIds
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
            else
              unless opts.through
                voRecord = yield (yield EmbedsCollection.takeBy(
                  "@doc.#{opts.inverse}": @[opts.refKey]
                ,
                  $limit: 1
                )).first()
                if voRecord?
                  yield voRecord.destroy()
              else
                # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
                through = @constructor.embeddings[opts.through[0]]
                unless through?
                  throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName
                ThroughRecord = @findRecordByName through.recordName
                inverse = ThroughRecord.relations[opts.through[1].by]
                embedIds = yield (yield ThroughCollection.takeBy(
                  "@doc.#{through.inverse}": @[opts.refKey]
                ,
                  $limit: 1
                )).map co.wrap (voRecord)->
                  id = voRecord[opts.through[1].by]
                  yield voRecord.destroy()
                  yield return id
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{inverse.refKey}": $in: embedIds
                ,
                  $limit: 1
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
            yield return

          opts.restore = (replica)->
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName
            EmbedRecord = @findRecordByName opts.recordName
            if replica?
              EmbedRecord.new replica, EmbedsCollection
            else
              null

          opts.replicate = ->
            aoRecord = @[vsAttr]
            EmbedRecord = aoRecord.constructor
            EmbedRecord.objectize aoRecord

          @metaObject.addMetaData 'embeddings', vsAttr, opts
          @public "#{vsAttr}": RecordInterface
          # @public @async "#{vsAttr}Embed": RecordInterface, opts
          return

      @public @static hasEmbeds: Array,
        default: (typeDefinition, opts={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.embedding = 'hasEmbeds'
            # TODO: вопрос - КАК по массиву можно сортировать, группировать или фильтровать (понятное дело, что фильтрацию можно расширить за счет customFilters на самом рекорде их указав, но зачем это указывать в атрибуте-массиве)
            # sortable: sortable # если это вложенные-проксируемые объекты, которые в базе в этом рекорде даже не хранятся, каким образом выходной массив рекордов должен быть отсортирован по этой фигне?
            # groupable: groupable # аналогичный вопрос
            # filterable: filterable
          opts.recordName ?= ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= ->
            "#{
              inflect.pluralize opts.recordName.replace /Record$/, ''
            }Collection"
          # opts.transform ?= ->
          #   # TODO: сдесь надо добавить обертку на основе ArrayTransform потому что может быть вызван normalize метод
          #   [vsModuleName, vsRecordName] = @parseRecordName vsAttr
          #   (@Module.NS ? @Module::)[vsRecordName]
          opts.validate = ->
            EmbedRecord = @findRecordByName opts.recordName
            return joi.array().items EmbedRecord.schema, joi.any().strip()
          # opts.validate = -> opts.transform.call(@).schema
          # opts.transform = ->
          #   EmbedRecord = @findRecordByName opts.recordName
          #
          #   schema: joi.array().items EmbedRecord.schema, joi.any().strip()
          #   normalize: ->
          opts.load = co.wrap ->
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName
            unless opts.through
              return yield (yield EmbedsCollection.takeBy(
                "@doc.#{opts.inverse}": @[opts.refKey]
              )).toArray()
            else
              through = @constructor.embeddings[opts.through[0]] ? @constructor.relations?[opts.through[0]]
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName
              ThroughRecord = @findRecordByName through.recordName
              inverse = ThroughRecord.relations[opts.through[1].by]
              embedIds = yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[opts.refKey]
              )).map (voRecord)-> voRecord[opts.through[1].by]
              return yield (yield EmbedsCollection.takeBy(
                "@doc.#{inverse.refKey}": $in: embedIds
              )).toArray()

          opts.put = co.wrap ->
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName
            alRecords = @[vsAttr]
            if alRecords.length > 0
              unless opts.through
                alRecordIds = []
                for aoRecord in alRecords
                  aoRecord[opts.inverse] = @[opts.refKey]
                  aoRecord.spaces = @spaces
                  aoRecord.creatorId = @creatorId
                  aoRecord.editorId = @editorId
                  aoRecord.ownerId = @ownerId
                  { id } = yield aoRecord.save()
                  alRecordIds.push id
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{opts.inverse}": @[opts.refKey]
                  $not: "@doc.id": $in: alRecordIds # NOTE: проверяем айдишники всех только-что сохраненных
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
              else
                through = @constructor.embeddings[opts.through[0]] ? @constructor.relations?[opts.through[0]]
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName
                ThroughRecord = @findRecordByName through.recordName
                inverse = ThroughRecord.relations[opts.through[1].by]
                alRecordIds = []
                newRecordIds = []
                for aoRecord in alRecords
                  aoRecord.spaces = @spaces
                  aoRecord.creatorId = @creatorId
                  aoRecord.editorId = @editorId
                  aoRecord.ownerId = @ownerId
                  if yield aoRecord.isNew()
                    savedRecord = yield aoRecord.save()
                    alRecordIds.push savedRecord[inverse.refKey]
                    newRecordIds.push savedRecord[inverse.refKey]
                  else
                    savedRecord = yield aoRecord.save()
                    alRecordIds.push savedRecord[inverse.refKey]
                embedIds = yield (yield ThroughCollection.takeBy(
                  "@doc.#{through.inverse}": @[opts.refKey]
                  $not: "@doc.#{opts.through[1].by}": $in: alRecordIds
                )).map co.wrap (voRecord)->
                  id = voRecord[opts.through[1].by]
                  yield voRecord.destroy()
                  yield return id
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{inverse.refKey}": $in: embedIds
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
                for newRecordId in newRecordIds
                  yield ThroughCollection.create(
                    "#{through.inverse}": @[opts.refKey]
                    "#{opts.through[1].by}": newRecordId
                    spaces: @spaces
                    creatorId: @creatorId
                    editorId: @editorId
                    ownerId: @ownerId
                  )
            else
              unless opts.through
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{opts.inverse}": @[opts.refKey]
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
              else
                through = @constructor.embeddings[opts.through[0]] ? @constructor.relations?[opts.through[0]]
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName
                ThroughRecord = @findRecordByName through.recordName
                inverse = ThroughRecord.relations[opts.through[1].by]
                embedIds = yield (yield ThroughCollection.takeBy(
                  "@doc.#{through.inverse}": @[opts.refKey]
                )).map co.wrap (voRecord)->
                  id = voRecord[opts.through[1].by]
                  yield voRecord.destroy()
                  yield return id
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{inverse.refKey}": $in: embedIds
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
            yield return

          opts.restore = (replica)->
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName
            EmbedRecord = @findRecordByName opts.recordName
            if replica? and replica.length > 0
              for item in replica
                EmbedRecord.new item, EmbedsCollection
            else
              []

          opts.replicate = ->
            alRecords = @[vsAttr]
            for item in alRecords
              EmbedRecord = item.constructor
              EmbedRecord.objectize item

          @metaObject.addMetaData 'embeddings', vsAttr, opts
          @public "#{vsAttr}": Array
          # @public @async "#{vsAttr}Embeds": Module::CursorInterface, opts
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

          voRecord = RecordClass.new vhAttributes, aoCollection

          for own asAttr, { load } of RecordClass.embeddings
            voRecord[asAttr] = yield load.call voRecord

          # TODO: так как vhAttributes может содержать атрибуты сложных типов (массивы, объекты, другие рекорды), НО глубокого копирования не происходит, то в `ipoInternalRecord` атрибуты так же будут ссылаться на эти же структуры, а следовательно `changedAttributes`, `resetAttribute` и `rollbackAttributes` - не смогут отатить их изменения или вернуть дельты изменений
          # TODO: для того, чтобы `ipoInternalRecord` имел валидный слепок с рекорда, в него надо записывать результат objectize'а рекорда
          voRecord[ipoInternalRecord] = RecordClass.objectize voRecord

          yield return voRecord

      @public @static @async serialize:   Function,
        default: (aoRecord)->
          unless aoRecord?
            return null

          unless aoRecord.type?
            throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

          vhResult = {}
          for own asAttr, { transform } of aoRecord.constructor.attributes
            vhResult[asAttr] = yield transform.call(@).serialize aoRecord[asAttr]
          # NOTE: по примеру normalize метода видно что этот миксин просто расширяет методы трансформации стандартного Record-"трансформа"
          # NOTE: поэтому здесь нельзя вызывать укороченную запись методtransform.call(@).serialize
          for own asAttr, { put } of aoRecord.constructor.embeddings
            yield put.call aoRecord

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
          for own asAttr, { transform } of aoRecord.constructor.computeds
            vhResult[asAttr] = transform.call(@).objectize aoRecord[asAttr]
          for own asAttr, { replicate } of aoRecord.constructor.embeddings
            vhResult[asAttr] = replicate.call aoRecord
          vhResult

      # TODO: не учтены установки значений, которые раньше не были установлены
      @public changedAttributes: Function,
        default: ->
          vhResult = {}
          for own vsAttrName, { transform } of @constructor.attributes
            voOldValue = @[ipoInternalRecord][vsAttrName]
            voNewValue = transform.call(@constructor).objectize @[vsAttrName]
            unless _.isEqual voNewValue, voOldValue
              vhResult[vsAttrName] = [voOldValue, voNewValue]
          for own vsAttrName, { replicate } of @constructor.embeddings
            voOldValue = @[ipoInternalRecord][vsAttrName]
            voNewValue = replicate.call aoRecord
            unless _.isEqual voNewValue, voOldValue
              vhResult[vsAttrName] = [voOldValue, voNewValue]
          vhResult

      @public resetAttribute: Function,
        default: (asAttribute)->
          voOldValue = @[ipoInternalRecord][asAttribute]
          if (attrConf = @constructor.attributes[asAttribute])?
            { transform } = attrConf
            @[asAttribute] = transform.call(@constructor).normalize voOldValue
          else if (attrConf = @constructor.embeddings[asAttribute])?
            { restore } = attrConf
            @[asAttribute] = restore.call @, voOldValue
          return

      @public rollbackAttributes: Function,
        default: ->
          for own vsAttrName, { transform } of @constructor.attributes
            voOldValue = @[ipoInternalRecord][vsAttrName]
            @[vsAttrName] = transform.call(@constructor).normalize voOldValue
          for own vsAttrName, { restore } of @constructor.embeddings
            voOldValue = @[ipoInternalRecord][vsAttrName]
            @[vsAttrName] = restore.call @, voOldValue
          return

      @public init: Function,
        default: (aoProperties, aoCollection) ->
          @super arguments...
          for own asAttr, { restore } of @constructor.embeddings
            @[asAttr] = restore.call @, aoProperties[asAttr]
          return


      @initializeMixin()
