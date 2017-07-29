

module.exports = (Module)->
  {
    Serializer
  } = Module::

  class ApplicationSerializer extends Serializer
    @inheritProtected()
    @module Module


  ApplicationSerializer.initialize()
