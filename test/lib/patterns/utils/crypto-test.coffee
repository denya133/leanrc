{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'Utils.crypto*', ->
  describe 'Utils.genRandomAlphaNumbers', ->
    it 'should generate random alphanumeric string', ->
      co ->
        NUMBER = 12000
        LENGTH = 16
        codes = []
        for i in [ 1 .. NUMBER ]
          code = LeanRC::Utils.genRandomAlphaNumbers LENGTH
          assert.isFalse code in codes, 'Collision detected'
          codes.push code
        assert.lengthOf codes, NUMBER
        yield return
