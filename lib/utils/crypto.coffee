# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

module.exports = (Module) ->
  {
    FuncG, MaybeG, StructG
  } = Module::

  Module.util genRandomAlphaNumbers: FuncG(Number, String) (length) ->
    { isArangoDB } = Module::Utils
    crypto = if isArangoDB()
      require '@arangodb/crypto'
    else
      require 'crypto'
    if isArangoDB()
      # Is ArangoDB !!!
      return crypto.genRandomAlphaNumbers length
    else
      # Is Node.js !!!
      return crypto.randomBytes(length).toString 'hex'

  Module.util hashPassword: FuncG([String, MaybeG StructG {
    hashMethod: MaybeG String
    saltLength: Number
  }], StructG {
    method: String
    salt: String
    hash: String
  }) (password, opts = {}) ->
    { isArangoDB } = Module::Utils
    {hashMethod, saltLength} = opts
    hashMethod ?= 'sha256'
    saltLength ?= 16
    method = hashMethod
    crypto = if isArangoDB()
      require '@arangodb/crypto'
    else
      require 'crypto'
    if isArangoDB()
      # Is ArangoDB !!!
      salt = crypto.genRandomAlphaNumbers saltLength
      hash = crypto[method] salt + password
      return {method, salt, hash}
    else
      # Is Node.js !!!
      salt = crypto.randomBytes(saltLength).toString 'hex'
      hash = crypto.createHash(method).update(salt + password).digest 'hex'
      return {method, salt, hash}

  Module.util verifyPassword: FuncG([StructG {
    method: String
    salt: String
    hash: String
  }, String], Boolean) (authData, password)->
    { isArangoDB } = Module::Utils
    method = authData.method ? 'sha256'
    salt = authData.salt ? ''
    storedHash = authData.hash ? ''
    crypto = if isArangoDB()
      require '@arangodb/crypto'
    else
      require 'crypto'
    if isArangoDB()
      # Is ArangoDB !!!
      generatedHash = crypto[method] salt + password
      return crypto.constantEquals storedHash, generatedHash
    else
      # Is Node.js !!!
      generatedHash = crypto.createHash(method).update(salt + password).digest 'hex'
      return storedHash is generatedHash
