GitAuthorsView = require './git-authors-view'
{CompositeDisposable} = require 'atom'

module.exports = GitAuthors =
  gitAuthorsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @gitAuthorsView = new GitAuthorsView(state.gitAuthorsViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @gitAuthorsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-authors:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @gitAuthorsView.destroy()

  serialize: ->
    gitAuthorsViewState: @gitAuthorsView.serialize()

  toggle: ->
    console.log 'GitAuthors was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @gitAuthorsView.getAuthors(@modalPanel)
      @modalPanel.show()
