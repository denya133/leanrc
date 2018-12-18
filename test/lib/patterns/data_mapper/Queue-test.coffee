{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  AnyT, NilT
  FuncG, MaybeG, ListG, UnionG
  Utils: { co }
}= LeanRC::

describe 'Queue', ->
  describe '.new', ->
    it 'should create delayed queue instance', ->
      co ->
        RESQUE = 'RESQUE'
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new RESQUE
        assert.property queue, 'name', 'TEST_QUEUE', 'No correct `id` property'
        assert.property queue, 'concurrency', 4, 'No correct `rev` property'
        assert.instanceOf queue.resque, TestResque, '`resque` is not a Resque instance'
        yield return
  describe '#push', ->
    it 'should push job into queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return 42
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async pushJob: FuncG([String, String, AnyT, MaybeG Number], UnionG String, Number),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        job = yield queue.push 'TEST_SCRIPT', { data: 'data' }, UNTIL_DATE
        assert.equal job, 42
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        assert.deepEqual spyMethod.args[0][2], data: 'data'
        assert.equal spyMethod.args[0][3], UNTIL_DATE
        yield return
  describe '#get', ->
    it 'should get job from queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return JOB
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async getJob: FuncG([String, UnionG String, Number], MaybeG Object),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        job = yield queue.get '42'
        assert.equal job, JOB
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], '42'
        yield return
  describe '#delete', ->
    it 'should remove job from queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return yes
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async deleteJob: FuncG([String, UnionG String, Number], Boolean),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        job = yield queue.delete '42'
        assert.equal job, yes
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], '42'
        yield return
  describe '#abort', ->
    it 'should stop job from queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async abortJob: FuncG([String, UnionG String, Number], NilT),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        job = yield queue.abort '42'
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], '42'
        yield return
  describe '#all', ->
    it 'should get all jobs from queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return [ JOB ]
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async allJobs: FuncG([String, MaybeG String], ListG Object),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        jobs = yield queue.all 'TEST_SCRIPT'
        assert.deepEqual jobs, [ JOB ]
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        yield return
  describe '#pending', ->
    it 'should get pending jobs from queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return [ JOB ]
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async pendingJobs: FuncG([String, MaybeG String], ListG Object),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        jobs = yield queue.pending 'TEST_SCRIPT'
        assert.deepEqual jobs, [ JOB ]
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        yield return
  describe '#progress', ->
    it 'should get processing jobs from queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return [ JOB ]
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async progressJobs: FuncG([String, MaybeG String], ListG Object),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        jobs = yield queue.progress 'TEST_SCRIPT'
        assert.deepEqual jobs, [ JOB ]
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        yield return
  describe '#completed', ->
    it 'should get completed jobs from queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return [ JOB ]
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async completedJobs: FuncG([String, MaybeG String], ListG Object),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        jobs = yield queue.completed 'TEST_SCRIPT'
        assert.deepEqual jobs, [ JOB ]
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        yield return
  describe '#failed', ->
    it 'should get failed jobs from queue', ->
      co ->
        RESQUE = 'RESQUE'
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return [ JOB ]
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @public @async failedJobs: FuncG([String, MaybeG String], ListG Object),
            default: spyMethod
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        queue = MyQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , TestResque.new(RESQUE)
        UNTIL_DATE = new Date()
        jobs = yield queue.failed 'TEST_SCRIPT'
        assert.deepEqual jobs, [ JOB ]
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        yield return
  describe '.replicateObject', ->
    facade = null
    KEY = 'TEST_DELAYED_QUEUE_001'
    after -> facade?.remove?()
    it 'should create replica for delayed queue', ->
      co ->
        RESQUE = 'RESQUE'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestResque.new RESQUE
        resque = facade.retrieveProxy RESQUE
        NAME = 'TEST_QUEUE'
        queue = yield resque.create NAME, 4
        replica = yield MyQueue.replicateObject queue
        assert.deepEqual replica,
          type: 'instance'
          class: 'Queue'
          multitonKey: KEY
          resqueName: RESQUE
          name: NAME
        yield return
  describe '.restoreObject', ->
    facade = null
    KEY = 'TEST_DELAYED_QUEUE_002'
    after -> facade?.remove?()
    it 'should restore delayed queue from replica', ->
      co ->
        RESQUE = 'RESQUE'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MyQueue extends LeanRC::Queue
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestResque.new RESQUE
        resque = facade.retrieveProxy RESQUE
        NAME = 'TEST_QUEUE'
        queue = yield resque.create NAME, 4
        restoredQueue = yield MyQueue.restoreObject Test,
          type: 'instance'
          class: 'Queue'
          multitonKey: KEY
          resqueName: RESQUE
          name: NAME
        assert.deepEqual queue, restoredQueue
        yield return
