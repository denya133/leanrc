

module.exports = (Module)->
  {
    NilT
    PropertyDefinitionT, EmbedOptionsT, EmbedConfigT
    FuncG, DictG, MaybeG
    RecordInterface
    Interface
  } = Module::

  class EmbeddableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static relatedEmbed: FuncG([PropertyDefinitionT, EmbedOptionsT], NilT)

    @virtual @static relatedEmbeds: FuncG([PropertyDefinitionT, EmbedOptionsT], NilT)

    @virtual @static hasEmbed: FuncG([PropertyDefinitionT, EmbedOptionsT], NilT)

    @virtual @static hasEmbeds: FuncG([PropertyDefinitionT, EmbedOptionsT], NilT)

    @virtual @static embeddings: DictG(String, EmbedConfigT)

    @virtual @static makeSnapshotWithEmbeds: FuncG(RecordInterface, MaybeG Object)


    @initialize()
