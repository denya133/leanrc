# Module = require 'Module'
# Module = require.main.require 'lib'
Feed = require 'feed'

module.exports = (Module) ->
  {
    AnyT
    FuncG, MaybeG, InterfaceG
    ContextInterface, ResourceInterface
    Renderer
    Utils: { _, assign, uuid }
  } = Module::

  class AtomRenderer extends Renderer
    @inheritProtected()
    @module Module

    @public @async render: FuncG([ContextInterface, AnyT, ResourceInterface, MaybeG InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: String
      entityName: String
      recordName: String
    }], MaybeG AnyT),
      default: (ctx, aoData, resource, aoOptions) ->
        vhData = assign {}, aoData ? {}
        feed = new Feed
          id: vhData.id ? uuid.v4()
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
        yield return feed.atom1()

    @initialize()
