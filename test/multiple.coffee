describe "multiple bindings", ->
  template = makeTemplate """
    %div
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

      [2, 7, 3, 8].forEach (value) ->
        # TODO: Wonder if there is a better way to simulate change events

        select.value = value
        select.onchange()

        assert.equal select.value, value

        ["text", "range"].forEach (type) ->
          assert.equal document.querySelector("input[type='#{type}']").value, value

        assert.equal document.querySelector("progress").value, value
