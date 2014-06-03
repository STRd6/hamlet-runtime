describe "subrender", ->
  describe "with root node", ->
    template = makeTemplate """
      %div
        = @generateItem
    """

    it "should render elements in-line", ->
      model =
        generateItem: ->
          document.createElement("li")

      behave template(model), ->
        assert Q("li")

    it "should render lists of nodes", ->
      model =
        generateItem: ->
          [
            document.createElement("li")
            document.createElement("li")
            document.createElement("p")
          ]

      behave template(model), ->
        assert all("li").length, 2
        assert all("p").length, 1

    it "should work with a node with children", ->
      model =
        generateItem: ->
          div = document.createElement "div"

          div.innerHTML = "<p>Yo</p><ol><li>Yolo</li><li>Broheim</li></ol>"

          div

      behave template(model), ->
        assert all("li").length, 2
        assert all("p").length, 1
        assert all("ol").length, 1

    it "should work with observables", ->
      model =
        name: Observable "wat"
        generateItem: ->
          item = document.createElement("li")

          item.textContent = @name()

          item

      behave template(model), ->
        assert.equal all("li").length, 1

        assert.equal Q("li").textContent, "wat"

        model.name "yo"

        assert.equal Q("li").textContent, "yo"

  describe "without root node", ->
    template = makeTemplate """
      = @generateItem
    """

    it "should work with observables"
    # TODO
    ->
      model =
        name: Observable "wat"
        generateItem: ->
          item = document.createElement("li")

          item.textContent = @name()

          item

      behave template(model), ->
        assert.equal all("li").length, 1

        assert.equal Q("li").textContent, "wat"

        model.name "yo"

        assert.equal Q("li").textContent, "yo"

  describe "with multiple sibling elements without a root node", ->
    template = makeTemplate """
      = @generateItem
      = @otherItem
    """

    it "should work with observables"
    # TODO
    ->
      model =
        name: Observable "wat"
        otherItem: ->
          item = document.createElement("li")

          item.textContent = @name()

          item
        generateItem: ->
          item = document.createElement("li")

          item.textContent = @name()

          item

      behave template(model), ->
        assert.equal all("li").length, 2

        assert.equal all("li")[0].textContent, "wat"

        model.name "yo"

        assert.equal Q("li")[0].textContent, "yo"
