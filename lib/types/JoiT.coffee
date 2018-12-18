

module.exports = (Module)->
  {
    ObjectT
    SubtypeG
  } = Module::

  Module.defineType SubtypeG ObjectT, 'JoiT', (x)-> x.isJoi is yes and x._type?
