{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Promise = LeanRC::Promise

describe 'Promise', ->
  describe '.new', ->
    it 'should create new promise (resolving)', (done) ->
      expect ->
        Promise.new (resolve, reject) ->
          console.log '1111111111111'
          resolve()
        .then ->
          done()
      .to.not.throw Error
    it 'should create new promise (rejecting)', (done) ->
      expect ->
        Promise.new (resolve, reject) ->
          console.log '2222222222222'
          reject()
        .catch (err) ->
          done()
      .to.not.throw Error
