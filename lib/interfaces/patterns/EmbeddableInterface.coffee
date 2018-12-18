

module.exports = (Module)->
  {
    PropertyDefinitionT, EmbedOptionsT, EmbedConfigT
    FuncG, DictG, MaybeG
    RecordInterface
    Interface
  } = Module::

  class EmbeddableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static relatedEmbed: FuncG([PropertyDefinitionT, EmbedOptionsT])

    @virtual @static relatedEmbeds: FuncG([PropertyDefinitionT, EmbedOptionsT])

    @virtual @static hasEmbed: FuncG([PropertyDefinitionT, EmbedOptionsT])

    @virtual @static hasEmbeds: FuncG([PropertyDefinitionT, EmbedOptionsT])

    @virtual @static embeddings: DictG(String, EmbedConfigT)

    @virtual @static makeSnapshotWithEmbeds: FuncG(RecordInterface, MaybeG Object)


    @initialize()
