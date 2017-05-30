

module.exports = (Module) ->
  isArango = Module::Utils.isArangoDB()
  Module::Utils.hashPassword = (password, opts = {}) ->
    {hashMethod, saltLength} = opts
    hashMethod ?= 'sha256'
    saltLength ?= 16
    method = hashMethod
    if isArango
      # Is ArangoDB !!!
      crypto = require '@arangodb/crypto'
      salt = crypto.genRandomAlphaNumbers saltLength
      hash = crypto[method] salt + password
      return {method, salt, hash}
    else
      # Is Node.js !!!
      crypto = require 'crypto'
      salt = crypto.randomBytes(saltLength).toString 'hex'
      hash = crypto.createHash(method).update(salt + password).digest 'hex'
      return {method, salt, hash}


  Module::Utils.verifyPassword = (authData, password)->
    method = authData.method ? 'sha256'
    salt = authData.salt ? ''
    storedHash = authData.hash ? ''
    if isArango
      # Is ArangoDB !!!
      crypto = require '@arangodb/crypto'
      generatedHash = crypto[method] salt + password
      return crypto.constantEquals storedHash, generatedHash
    else
      # Is Node.js !!!
      crypto = require 'crypto'
      generatedHash = crypto.createHash(method).update(salt + password).digest 'hex'
      return storedHash is generatedHash
