describe "Computed", ->
  template = makeTemplate """
    %h2= @name
    %input(value=@first)
    %input(value=@last)
  """

  it "should compute automatically with the correct scope", ->
    model =
      name: ->
        @first() + " " + @last()
      first: Observable("Mr.")
      last: Observable("Doberman")

    behave template(model), ->
      assert.equal Q("h2").textContent, "Mr. Doberman"

  it "should work on special bindings", ->
    template = makeTemplate """
      %input(checked=@checked)
    """
    model =
      checked: ->
        @name() is "Duder"
      name: Observable "Mang"

    behave template(model), ->
      assert.equal Q("input").checked, false

      model.name "Duder"

      assert.equal Q("input").checked, true
