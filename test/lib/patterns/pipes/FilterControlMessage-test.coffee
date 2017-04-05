{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
FilterControlMessage = LeanRC::FilterControlMessage

describe 'FilterControlMessage', ->
  describe '.new', ->
    it 'should create new FilterControlMessage instance', ->
      expect ->
        vsName = 'TEST'
        vsType = FilterControlMessage.FILTER
        vmFilter = ->
        voParams = test: 'TEST'
        message = FilterControlMessage.new vsType, vsName, vmFilter, voParams
        assert.equal message[Symbol.for 'type'], vsType, 'Type is incorrect'
        assert.equal message[Symbol.for 'name'], vsName, 'Name is incorrect'
        assert.equal message[Symbol.for 'filter'], vmFilter, 'Filter is incorrect'
        assert.equal message[Symbol.for 'params'], voParams, 'Params is incorrect'
      .to.not.throw Error
  describe '#getName, #setName', ->
    it 'should create new message and check name', ->
      expect ->
        vsName = 'TEST'
        vsNameUpdated = 'NEW_TEST'
        message = FilterControlMessage.new FilterControlMessage.FILTER, vsName
        assert.equal message[Symbol.for 'name'], vsName, 'Name is incorrect'
        assert.equal message[Symbol.for 'name'], message.getName(), 'Name is incorrect'
        message.setName vsNameUpdated
        assert.equal message.getName(), vsNameUpdated, 'Name is incorrect'
      .to.not.throw Error
  describe '#getFilter, #setFilter', ->
    it 'should create new message and check filter', ->
      expect ->
        vmFilter = ->
        vmFilterUpdated = ->
        message = FilterControlMessage.new FilterControlMessage.FILTER, 'TEST', vmFilter
        assert.equal message[Symbol.for 'filter'], vmFilter, 'Filter is incorrect'
        assert.equal message[Symbol.for 'filter'], message.getFilter(), 'Filter is incorrect'
        message.setFilter vmFilterUpdated
        assert.equal message.getFilter(), vmFilterUpdated, 'Filter is incorrect'
      .to.not.throw Error
  describe '#getParams, #setParams', ->
    it 'should create new message and check params', ->
      expect ->
        voParams = test: 'TEST1'
        voParamsUpdated = test: 'TEST2'
        message = FilterControlMessage.new FilterControlMessage.FILTER, 'TEST', (->), voParams
        assert.equal message[Symbol.for 'params'], voParams, 'Params is incorrect'
        assert.equal message[Symbol.for 'params'], message.getParams(), 'Params is incorrect'
        message.setParams voParamsUpdated
        assert.equal message.getParams(), voParamsUpdated, 'Params is incorrect'
      .to.not.throw Error
