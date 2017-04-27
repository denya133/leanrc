# так как рекорд будет работать с простыми структурами данных в памяти, он не зависит от платформы.
# если ему надо будет взаимодействовать с платформозависимой логикой - он будет делать это через прокси, но не напрямую (как в эмбере со стором)


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class RecordInterface extends BaseClass
      @inheritProtected()
      @include Module::TransformInterface

      @public @virtual collection: Module::CollectionInterface

      @public @static @virtual schema: Object

      @public @static @virtual parseRecordName: Function,
        args: [String]
        return: Array

      @public @virtual parseRecordName: Function,
        args: [String]
        return: Array

      # # под вопросом ?????? возможно надо искать через (из) модуля
      # @public @static findModelByName: Function, [String], -> Array
      # @public findModelByName: Function, [String], -> Array

      # # под вопросом ??????
      # @public updateEdges: Function, [ANY], -> ANY # any type


      @public @static @virtual parentClassNames: Function,
        args: [[Module::Class, NILL]]
        return: Array

      @public @static @virtual attributes: Function,
        args: []
        return: Object
      @public @static @virtual edges: Function,
        args: []
        return: Object
      @public @static @virtual computeds: Function,
        args: []
        return: Object

      @public @static @virtual attribute: Function,
        args: [Object, Object] #typeDefinition, opts
        return: NILL
      @public @static @virtual attr: Function,
        args: [Object, Object] #typeDefinition, opts
        return: NILL
      @public @static @virtual computed: Function,
        args: [Object, Object] #typeDefinition, opts
        return: NILL
      @public @static @virtual comp: Function,
        args: [Object, Object] #typeDefinition, opts
        return: NILL

      @public @static @virtual new: Function,
        args: [Object] #attributes
        return: Module::RecordInterface

      @public @async @virtual save: Function,
        args: []
        return: RecordInterface
      @public @async @virtual create: Function,
        args: []
        return: RecordInterface
      @public @async @virtual update: Function,
        args: []
        return: RecordInterface
      @public @async @virtual delete: Function,
        args: []
        return: RecordInterface
      @public @async @virtual destroy: Function,
        args: []
        return: RecordInterface

      @public @virtual attributes: Function, # метод должен вернуть список атрибутов данного рекорда.
        args: []
        return: Array
      @public @virtual clone: Function,
        args: []
        return: Module::RecordInterface
      @public @async @virtual copy: Function,
        args: []
        return: Module::RecordInterface
      @public @async @virtual decrement: Function,
        args: [String, [Number, NILL]] #attribute, step
        return: Module::RecordInterface
      @public @async @virtual increment: Function,
        args: [String, [Number, NILL]] #attribute, step
        return: Module::RecordInterface
      @public @async @virtual toggle: Function,
        args: [String] #attribute
        return: Module::RecordInterface
      @public @async @virtual touch: Function,
        args: []
        return: Module::RecordInterface
      @public @async @virtual updateAttribute: Function,
        args: [String, ANY] #name, value
        return: Module::RecordInterface
      @public @async @virtual updateAttributes: Function,
        args: [Object] #attributes
        return: Module::RecordInterface
      @public @async @virtual isNew: Function,
        args: []
        return: Boolean
      @public @async @virtual reload: Function,
        args: []
        return: Module::RecordInterface
      @public @virtual changedAttributes: Function,
        args: []
        return: Object # { isAdmin: [undefined, true], name: [undefined, 'Tomster'] }
      @public @virtual resetAttribute: Function,
        args: [String]
        return: NILL
      @public @virtual rollbackAttributes: Function,
        args: []
        return: NILL


    RecordInterface.initializeInterface()
