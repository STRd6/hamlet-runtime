describe "subrender", ->
  template = makeTemplate """
    %div
      = @generateItem()
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
