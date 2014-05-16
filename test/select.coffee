describe "SELECT", ->
  afterEach ->
    empty document.body

  template = makeTemplate """
    %select(value=@value options=@options)
  """
  describe "with an array of basic types for options", ->
    model =
      options: [1, 2, 3]
      value: 2
    it "should generate options", ->
      behave template(model), ->
        assert.equal all("option").length, model.options.length
    it "should have it's value set", ->
      behave template(model), ->
        assert.equal Q("select").value, model.value

  describe "with an array of objects for options", ->
    options = [
        {name: "yolo", value: "badical"}
        {name: "wat", value: "noice"}
      ]
    model =
      options: options
      value: options[0]
    it "should generate options", ->
      behave template(model), ->
        assert.equal all("option").length, model.options.length
    it "option names should be the name property of the object", ->
      behave template(model), ->
        names = Array::map.call all("option"), (o) -> o.text

        names.forEach (name, i) ->
          assert.equal name, model.options[i].name

    it "option values should be the value property of the object", ->
      behave template(model), ->
        values = Array::map.call all("option"), (o) -> o.value

        values.forEach (value, i) ->
          assert.equal value, model.options[i].value
    it "should have it's value set", ->
      behave template(model), ->
        # TODO: This isn't a great check
        assert.equal Q("select")._value, model.value

  describe "with an observable array for options", ->
    it "should add options added to the observable array"
    it "should remove options removed from the observable array"
  describe "with an object for options", ->
    it "should have an option for each key"

