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
      authNames = lines.map (l) ->
        # console.log "l:#{l}"
        if l
          nm = l.match(/.+ \((.+) +\d{4}-.+/)
          # console.log "nm:#{nm}"
          nm[1]

      # console.log "authNames: #{authNames.length}"

      authFreq = {}
      for name in authNames
        # console.log "nm: #{name}"
        if name == undefined
          continue
        if authFreq[name] != undefined
          # console.log "incr nm:#{name}"
          authFreq[name]++
        else
          # console.log "adding nm:#{name}"
          authFreq[name] = 1

      for author, freq of authFreq
        console.log "AA #{author} AA: #{freq}"
        authDiv = document.createElement("div")
        nameSpan = document.createElement("span");pcSpan = document.createElement("span");
        nameSpan.textContent = author; pcSpan.textContent = (freq / authNames.length * 100).toFixed(2) + "%"
        authDiv.appendChild nameSpan; authDiv.appendChild pcSpan
        panel.getItem().appendChild authDiv

    failure = (err) ->
      console.log err
      panel.getItem().textContent = "Failed to get author list. Is this a git repo?"

    currFile = atom.workspace.getActiveTextEditor()?.getPath()
    new BufferedProcess ({
      command: "git",
      # args: ["-C", path.dirname(currFile), "blame", "--line-porcelain", currFile]
      args: ["-C", path.dirname(currFile), "blame", currFile]
      stdout: success,
      stderr: failure
    })
