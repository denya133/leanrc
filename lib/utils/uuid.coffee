crypto = require '@arangodb/crypto'

uuid =
  v4: ()->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)->
      r = Number(crypto.genRandomNumbers 16) %% 16
      v = if c == 'x' then r else r & 0x3 | 0x8
      v.toString 16


module.exports = uuid
