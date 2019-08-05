

module.exports = (Module)->
  {
    AnyT
    FuncG, SubsetG
    Mixin
    CoreObject
    Utils: { isArangoDB, jsonStringify }
  } = Module::

  Module.defineMixin Mixin 'MakeSignatureMixin', FuncG(SubsetG CoreObject) (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @async makeSignature: FuncG([String, String, AnyT], String),
        default: (algorithm, secret, attributes)->
          str = jsonStringify attributes
          if isArangoDB()
            crypto = require '@arangodb/crypto'
            yield return crypto.hmac secret, str, algorithm
          else
            crypto = require 'crypto'
            yield return crypto
              .createHmac algorithm, secret
              .update str
              .digest 'hex'

      @public @async makeHash: FuncG([String, AnyT], String),
        default: (algorithm, data)->
          str = jsonStringify data
          if isArangoDB()
            crypto = require '@arangodb/crypto'
            yield return crypto[algorithm.toLowerCase()] str
          else
            crypto = require 'crypto'
            yield return crypto
              .createHash algorithm
              .update str
              .digest 'hex'


      @initializeMixin()
