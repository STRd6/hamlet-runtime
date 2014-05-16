describe "multiple bindings", ->
  template = makeTemplate """
    %input(type="text" value=@value)
    %select(value=@value options=[1..@max])
    %hr
    %input(type="range" value=@value min="1" max=@max)
    %hr
    %progress(value=@value max=@max)
  """
  model =
    max: 10
    value: Observable 5

  it "should be initialized to the right values", ->
    behave template(model), ->
      select = document.querySelector("select")

      ["text", "range"].forEach (type) ->
        assert.equal document.querySelector("input[type='#{type}']").value, 5

      assert.equal document.querySelector("progress").value, 5
      assert.equal select.value, 5

      # TODO: Wonder if there is a better way to simulate change events
      select.value = 1
      select.onchange()

      assert.equal select.value, 1

      ["text", "range"].forEach (type) ->
        assert.equal document.querySelector("input[type='#{type}']").value, 1

      assert.equal document.querySelector("progress").value, 1
