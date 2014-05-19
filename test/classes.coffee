describe "Classes", ->
  it "should be bound in the context of the object", ->
    template = makeTemplate """
      .duder(class=@classes)
    """

    model =
      classes: ->
        @myClass()
      myClass: ->
        "hats"

    behave template(model), ->
      assert Q(".hats")
  it "should handle observable arrays"

  it "should merge with literal classes"
