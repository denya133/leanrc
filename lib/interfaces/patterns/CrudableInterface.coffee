

module.exports = (Module)->
  {
    JoiT
    Interface
  } = Module::

  class CrudableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual keyName: String
    @virtual itemEntityName: String
    @virtual listEntityName: String
    @virtual schema: JoiT
    @virtual listSchema: JoiT
    @virtual itemSchema: JoiT
    @virtual keySchema: JoiT
    @virtual querySchema: JoiT
    @virtual executeQuerySchema: JoiT
    @virtual bulkResponseSchema: JoiT
    @virtual versionSchema: JoiT


    @initialize()
