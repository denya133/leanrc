

module.exports = (Module)->
  {
    ObjectT
    SubtypeG
  } = Module::

  Module.defineType SubtypeG ObjectT, 'MomentT', (x)-> x._isAMomentObject is yes
