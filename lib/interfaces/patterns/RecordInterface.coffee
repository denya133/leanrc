RC = require 'RC'

# так как рекорд будет работать с простыми структурами данных в памяти, он не зависит от платформы.
# если ему надо будет взаимодействовать с платформозависимой логикой - он будет делать это через прокси, но не напрямую (как в эмбере со стором)

module.exports = (LeanRC)->
  class LeanRC::RecordInterface extends RC::Interface
    @inheritProtected()
    @include LeanRC::TransformInterface

    @Module: LeanRC

    @public @virtual collection: LeanRC::CollectionInterface

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
      args: [[RC::Class, RC::Constants.NILL]]
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
      return: RC::Constants.NILL
    @public @static @virtual attr: Function,
      args: [Object, Object] #typeDefinition, opts
      return: RC::Constants.NILL
    @public @static @virtual computed: Function,
      args: [Object, Object] #typeDefinition, opts
      return: RC::Constants.NILL
    @public @static @virtual comp: Function,
      args: [Object, Object] #typeDefinition, opts
      return: RC::Constants.NILL

    @public @static @virtual new: Function,
      args: [Object] #attributes
      return: LeanRC::RecordInterface

    @public @virtual save: Function,
      args: []
      return: RecordInterface
    @public @virtual create: Function,
      args: []
      return: RecordInterface
    @public @virtual update: Function,
      args: []
      return: RecordInterface
    @public @virtual delete: Function,
      args: []
      return: RecordInterface
    @public @virtual destroy: Function,
      args: []
      return: RecordInterface

    @public @virtual attributes: Function, # метод должен вернуть список атрибутов данного рекорда.
      args: []
      return: Array
    @public @virtual clone: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual copy: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual decrement: Function,
      args: [String, [Number, RC::Constants.NILL]] #attribute, step
      return: LeanRC::RecordInterface
    @public @virtual increment: Function,
      args: [String, [Number, RC::Constants.NILL]] #attribute, step
      return: LeanRC::RecordInterface
    @public @virtual toggle: Function,
      args: [String] #attribute
      return: LeanRC::RecordInterface
    @public @virtual touch: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual updateAttribute: Function,
      args: [String, RC::Constants.ANY] #name, value
      return: LeanRC::RecordInterface
    @public @virtual updateAttributes: Function,
      args: [Object] #attributes
      return: LeanRC::RecordInterface
    @public @virtual isNew: Function,
      args: []
      return: Boolean
    @public @virtual reload: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual changedAttributes: Function,
      args: []
      return: Object # { isAdmin: [undefined, true], name: [undefined, 'Tomster'] }
    @public @virtual resetAttribute: Function,
      args: [String]
      return: RC::Constants.NILL
    @public @virtual rollbackAttributes: Function,
      args: []
      return: RC::Constants.NILL


  return LeanRC::RecordInterface.initialize()
