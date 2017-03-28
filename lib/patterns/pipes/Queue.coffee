RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Queue extends LeanRC::Pipe
    @inheritProtected()

    @Module: LeanRC

    ipoOutput = Symbodl.for 'output'
    ipsMode = @protected mode: String,
      default: LeanRC::QueueControlMessage.SORT
    iplMessages = @protected messages: Array

    ipmSortMessagesByPriority = @protected sortMessagesByPriority: Function,
      args: [LeanRC::PipeMessageInterface, LeanRC::PipeMessageInterface]
      return: Number
      default: (msgA, msgB)->
        vnNum = 0
        if msgA.getPriority() < msgB.getPriority()
          vnNum = -1
        if msgA.getPriority() > msgB.getPriority()
          vnNum = 1
        return vnNum

    ipmStore = @protected store: Function,
      args: [LeanRC::PipeMessageInterface]
      return: RC::Constants.NILL
      default: (aoMessage)->
        @[iplMessages] ?= []
        @[iplMessages].push aoMessage
        if @[ipsMode] is LeanRC::QueueControlMessage.SORT
          @[iplMessages].sort @[ipmSortMessagesByPriority]
        return

    ipmFlush = @protected flush: Function,
      args: []
      return: Boolean
      default: ->
        vbSuccess = yes
        @[iplMessages] ?= []
        voMessage = @[iplMessages].shift()
        while voMessage
          ok = @[ipoOutput].write message
          unless ok
            vbSuccess = no
          voMessage = @[iplMessages].shift()
        vbSuccess

    @public write: Function,
      default: (aoMessage)->
        vbSuccess = yes
        voOutputMessage = null
        switch aoMessage.getType()
          when LeanRC::PipeMessage.NORMAL
            @[ipmStore] aoMessage
            break
          when LeanRC::QueueControlMessage.FLUSH
            vbSuccess = @[ipmFlush]()
            break
          when LeanRC::QueueControlMessage.SORT, LeanRC::QueueControlMessage.FIFO
            @[ipsMode] = aoMessage.getType()
            break
        return vbSuccess

    constructor: (aoOutput=null)->
      super aoOutput


  return LeanRC::Queue.initialize()
