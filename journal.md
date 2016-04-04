
**4/4/2016, 12:23:38 AM**: Been researching how to convert the toggle view into a pane instead of a modal panel. Here're some hints from the minimap package:

  getActiveMinimap () {
     return this.minimapForEditor(atom.workspace.getActiveTextEditor())
  }
and...

  attach (parent) {
      if (this.attached) { return }
      (parent || this.getTextEditorElementRoot()).appendChild(this)
  }

So let's see if we can do this with our authors view.

**4/4/2016, 1:37:46 AM**: Turns out these were not required. I just had to create a non-modal panel.
