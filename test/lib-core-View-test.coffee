{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
View = LeanRC::View
Notification = LeanRC::Notification

describe 'View', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of View', ->
      expect ->
        controller = View.getInstance 'TEST'
        unless controller instanceof View
          throw new Error 'The `controller` is not an instance of View'
      .to.not.throw Error
  describe '.removeView', ->
    it 'should get new instance of View, remove it and get new one', ->
      expect ->
        controller = View.getInstance 'TEST'
        View.removeView 'TEST'
        newView = View.getInstance 'TEST'
        if controller is newView
          throw new Error 'View instance didn\'t renewed'
      .to.not.throw Error
