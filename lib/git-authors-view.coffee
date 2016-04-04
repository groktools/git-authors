path = require "path"
{BufferedProcess} = require "atom"

module.exports =
class GitAuthorsView
  @message: null,

  constructor: (serializedState) ->
    # Create root element
    @element = @makeHTMLElement('div', 'git-authors')

    # Create message element
    @message = @makeHTMLElement('div','message',"Getting authors..")
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
    lineCount = 0
    authFreq = {}

    success = (stdout) ->
      # console.log stdout
      lines = stdout.split('\n')
      lineCount += lines.length
      authNames = lines.map (l) ->
        # console.log "l:#{l}"
        if l
          nm = l.match(/.+ \((.+) +\d{4}-.+/)
          # console.log "nm:#{nm}"
          nm[1]

      # console.log "authNames: #{authNames.length}"

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

    finish = (err) ->
      if err !=0
        console.log err
        panel.getItem().textContent = "Failed to get author list. Something went wrong."

      console.log lineCount, authFreq
      sortedByFreq = Object.keys(authFreq).sort((a,b) -> authFreq[b]-authFreq[a])
      console.log sortedByFreq

      panel.getItem().removeChild(panel.getItem().firstChild)
      for author in sortedByFreq
        # console.log "AA #{author} AA: #{authFreq[author]}"
        authLine = document.createElement("div");authLine.classList.add "authLine"
        nameCol = document.createElement("div");pcCol = document.createElement("div");
        nameCol.classList.add "authorName"; pcCol.classList.add "authorFreq";
        nameCol.textContent = author; pcCol.textContent = (authFreq[author] / lineCount * 100).toFixed(2) + "%"
        authLine.appendChild nameCol; authLine.appendChild pcCol
        panel.getItem().appendChild authLine

    failure = (err) ->
      console.log err
      panel.getItem().textContent = "Failed to get author list. Is this a git repo?"

    currFile = atom.workspace.getActiveTextEditor()?.getPath()
    new BufferedProcess ({
      command: "git",
      # args: ["-C", path.dirname(currFile), "blame", "--line-porcelain", currFile]
      args: ["-C", path.dirname(currFile), "blame", currFile]
      stdout: success,
      stderr: failure,
      exit: finish
    })

  makeHTMLElement: (t,s,content) ->
    el = document.createElement(t)
    el.classList.add(s)
    if content != undefined
      el.textContent = content
    el
