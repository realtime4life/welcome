describe "Welcome", ->
  editor = null

  beforeEach ->
    spyOn(atom.workspace, 'open').andCallThrough()

    waitsForPromise ->
      atom.packages.activatePackage("welcome")

    waitsFor ->
      atom.workspace.open.calls.length == 2

  describe "when activated for the first time", ->
    it "shows the welcome panes", ->
      panes = atom.workspace.getPanes()
      expect(panes).toHaveLength 2
      expect(panes[0].getItems()[0].getTitle()).toBe 'Welcome'
      expect(panes[1].getItems()[0].getTitle()).toBe 'Welcome Guide'

  describe "when activated again", ->
    beforeEach ->
      atom.workspace.getPanes().map (pane) -> pane.destroy()
      atom.packages.deactivatePackage("welcome")
      atom.workspace.open.reset()

      waitsForPromise ->
        atom.packages.activatePackage("welcome")

    it "doesn't show the welcome buffer", ->
      expect(atom.workspace.open).not.toHaveBeenCalled()

  describe "the welcome:show command", ->
    workspaceElement = null

    beforeEach ->
      workspaceElement = atom.views.getView(atom.workspace)

    it "shows the welcome buffer", ->
      atom.workspace.getPanes().map (pane) -> pane.destroy()
      expect(atom.workspace.getActivePaneItem()).toBeUndefined()
      atom.commands.dispatch(workspaceElement, 'welcome:show')

      waitsFor ->
        atom.workspace.getActivePaneItem()

      runs ->
        panes = atom.workspace.getPanes()
        expect(panes).toHaveLength 2
        expect(panes[0].getItems()[0].getTitle()).toBe 'Welcome'

  describe "deserializing the pane items", ->
    [panes, guideView, welcomeView] = []
    beforeEach ->
      panes = atom.workspace.getPanes()
      welcomeView = panes[0].getItems()[0]
      guideView = panes[1].getItems()[0]

    describe "when GuideView is deserialized", ->
      it "deserializes with no state", ->
        {deserializer, uri} = guideView.serialize()
        newGuideView = atom.deserializers.deserialize({deserializer, uri})

      it "remembers open sections", ->
        guideView.find("details[data-section=\"snippets\"]").attr('open', 'open')
        guideView.find("details[data-section=\"init-script\"]").attr('open', 'open')
        serialized = guideView.serialize()

        expect(serialized.openSections).toEqual ['init-script', 'snippets']

        newGuideView = atom.deserializers.deserialize(serialized)

        expect(newGuideView.find("details[data-section=\"packages\"]")).not.toHaveAttr 'open'
        expect(newGuideView.find("details[data-section=\"snippets\"]")).toHaveAttr 'open'
        expect(newGuideView.find("details[data-section=\"init-script\"]")).toHaveAttr 'open'
