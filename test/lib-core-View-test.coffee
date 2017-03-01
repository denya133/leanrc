{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
View = LeanRC::View
Notification = LeanRC::Notification

describe 'View', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of View', ->
      expect ->
        view = View.getInstance 'TEST'
        assert view instanceof View, 'The `view` is not an instance of View'
      .to.not.throw Error
  describe '.removeView', ->
    it 'should get new instance of View, remove it and get new one', ->
      expect ->
        view = View.getInstance 'TEST'
        oldView = View.getInstance 'TEST'
        assert view is oldView, 'View is not saved'
        View.removeView 'TEST'
        newView = View.getInstance 'TEST'
        assert view isnt newView, 'View instance didn\'t renewed'
      .to.not.throw Error
