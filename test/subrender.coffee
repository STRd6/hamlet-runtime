describe "subrender", ->
  it "should render elements in-line", ->
    template = makeTemplate """
      %div
        = @generateItem()
    """
    model =
      generateItem: ->
        document.createElement("li")

    behave template(model), ->
      assert Q("li")
