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
        console.log "l:#{l}"
        if l
          nm = l.match(/.+ \((.+) +\d{4}-.+/)
          console.log "nm:#{nm}"
          nm[1]
        #  Eg, the output format is thus: "86ae4ff7 (Sindre Sorhus                  2016..."
        # l.slice(10,30).trim()
        # p1 = l.split("(")[1]
        # p2 = new String(p1).split(" ")[0]
        # l.split("(")[1].split(" ")[0]
      # authNames = []
      # for l in lines
      #   if l.search("author ") != -1
      #     authNames.push(l.substring(l.indexOf(" ")))

      console.log "authNames: #{authNames.length}"

      for n in authNames
        console.log n

      authFreq = {}
      for name in authNames
        console.log "nm: #{name}"
        if name == undefined
          continue
        if authFreq[name] != undefined
          console.log "incr nm:#{name}"
          authFreq[name]++
        else
          console.log "adding nm:#{name}"
          authFreq[name] = 1

      # authStr = ""
      for author, freq of authFreq
        console.log "AA #{author} AA: #{freq}"
        # authStr = authStr + "<p>" + author + " : " + (freq / authNames.length * 100).toFixed(2) + "%</p>"
        authDiv = document.createElement("div")
        nameSpan = document.createElement("span");pcSpan = document.createElement("span");
        nameSpan.textContent = author; pcSpan.textContent = (freq / authNames.length * 100).toFixed(2) + "%"
        authDiv.appendChild nameSpan; authDiv.appendChild pcSpan
        # authDiv.textContent = author + " : " + (freq / authNames.length * 100).toFixed(2) + "%"
        # authDiv.textContent = author + " : " + freq
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
