path = require "path"
{BufferedProcess} = require "atom"

module.exports =
class GitAuthorsView
  @message: null,

  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('git-authors')

    # Create message element
    @message = document.createElement('div')
    @message.textContent = "getting authors.."
    @message.classList.add('message')
    @element.appendChild(@message)
    # @getAuthors()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  getAuthors: (panel)->
    item = panel.getItem()
    currFile = atom.workspace.getActiveTextEditor()?.getPath()
    console.log "in getAuthors: #{@message}"
    console.log "getting authors..."

    success = (stdout) ->
      # console.log stdout
      lines = stdout.split('\n')
      # authNames = lines.map (l) ->
      #   p1 = l.split("(")[1]
      #   p2 = new String(p1).split(" ")[0]
      #   # l.split("(")[1].split(" ")[0]
      authNames = lines.filter (l) ->
        l.search("author ") != -1

      authFreq = {}
      authNames.forEach (name) ->
        if authFreq[name]
          authFreq[name] = authFreq[name] + 1
        else
          authFreq[name] = 1
      authStr = ""

      for author, freq of authFreq
        authStr = authStr + author + " : " + (freq / authNames.length * 100).toFixed(2) + "%\n"

      panel.getItem().textContent = "success: #{authStr}"

    failure = (err) ->
      console.log err
      panel.getItem().textContent = "Failed to get author list. Is this a git repo?"

    currFile = atom.workspace.getActiveTextEditor()?.getPath()
    new BufferedProcess ({
      command: "git",
      args: ["-C", path.dirname(currFile), "blame", "--line-porcelain", currFile]
      stdout: success,
      stderr: failure
    })
