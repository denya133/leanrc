_ = require 'lodash'
# Module = require 'Module'
# Module = require.main.require 'lib'
Feed = require 'feed'

module.exports = (Module) ->
  class AtomRenderer extends Module::Renderer
    @inheritProtected()

    @Module: Module

    @public render: Function,
      default: (aoData, aoOptions) ->
        vhData = Module::Utils.extend {}, aoData ? {}
        feed = new Feed
          id: vhData.id ? Module::Utils.uuid.v4()
          title: vhData.title ? ''
          author: vhData.author
          updated: vhData.updated
          link: vhData.link
          feed: vhData.feed
          hub: vhData.hub
          description: vhData.description
          image: vhData.image
          copyright: vhData.copyright
        if _.isArray vhData.categories
          feed.addCategory category  for category in vhData.categories
        if _.isArray vhData.contributors
          feed.addCategory contributor  for contributor in vhData.contributors
        if _.isArray vhData.items
          feed.addCategory item  for item in vhData.items
        feed.atom1()

  AtomRenderer.initialize()
