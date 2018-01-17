

module.exports = (Module) ->
  Module::Utils.genRandomAlphaNumbers = (length) ->
    isArango = Module::Utils.isArangoDB()
    crypto = if isArango
      require '@arangodb/crypto'
    else
      require 'crypto'
    if isArango
      # Is ArangoDB !!!
      return crypto.genRandomAlphaNumbers length
    else
      # Is Node.js !!!
      return crypto.randomBytes(length).toString 'hex'

  Module::Utils.hashPassword = (password, opts = {}) ->
    isArango = Module::Utils.isArangoDB()
    {hashMethod, saltLength} = opts
    hashMethod ?= 'sha256'
    saltLength ?= 16
    method = hashMethod
    crypto = if isArango
      require '@arangodb/crypto'
    else
      require 'crypto'
    if isArango
      # Is ArangoDB !!!
      salt = crypto.genRandomAlphaNumbers saltLength
      hash = crypto[method] salt + password
      return {method, salt, hash}
    else
      # Is Node.js !!!
      salt = crypto.randomBytes(saltLength).toString 'hex'
      hash = crypto.createHash(method).update(salt + password).digest 'hex'
      return {method, salt, hash}

  Module::Utils.verifyPassword = (authData, password)->
    isArango = Module::Utils.isArangoDB()
    method = authData.method ? 'sha256'
    salt = authData.salt ? ''
    storedHash = authData.hash ? ''
    crypto = if isArango
      require '@arangodb/crypto'
    else
      require 'crypto'
    if isArango
      # Is ArangoDB !!!
      generatedHash = crypto[method] salt + password
      return crypto.constantEquals storedHash, generatedHash
    else
      # Is Node.js !!!
      generatedHash = crypto.createHash(method).update(salt + password).digest 'hex'
      return storedHash is generatedHash
