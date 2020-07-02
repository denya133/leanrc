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
