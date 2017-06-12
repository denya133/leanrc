{ expect, assert } = require 'chai'
sinon = require 'sinon'
crypto = require 'crypto'
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
  describe 'Utils.hashPassword', ->
    it 'should get password hash and salt', ->
      co ->
        password = 'PASSWORD'
        { method, salt, hash } = LeanRC::Utils.hashPassword password
        assert.equal hash, crypto.createHash(method).update(salt + password).digest 'hex'
        { method, salt, hash } = LeanRC::Utils.hashPassword password, hashMethod: 'sha512'
        assert.equal hash, crypto.createHash(method).update(salt + password).digest 'hex'
        { method, salt, hash } = LeanRC::Utils.hashPassword password,
          hashMethod: 'sha512'
          saltLength: 32
        assert.equal hash, crypto.createHash(method).update(salt + password).digest 'hex'
        yield return
  describe 'Utils.verifyPassword', ->
    it 'should verify password with auth data', ->
      co ->
        password = 'PASSWORD'
        authData = LeanRC::Utils.hashPassword password
        assert.isTrue LeanRC::Utils.verifyPassword authData, password
        assert.isFalse LeanRC::Utils.verifyPassword authData, 'password'
        authData = LeanRC::Utils.hashPassword password, hashMethod: 'sha512'
        assert.isTrue LeanRC::Utils.verifyPassword authData, password
        assert.isFalse LeanRC::Utils.verifyPassword authData, 'password'
        authData = LeanRC::Utils.hashPassword password,
          hashMethod: 'sha512'
          saltLength: 32
        assert.isTrue LeanRC::Utils.verifyPassword authData, password
        assert.isFalse LeanRC::Utils.verifyPassword authData, 'password'
        yield return
