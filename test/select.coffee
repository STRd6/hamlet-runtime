describe "SELECT", ->
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

  describe "with objects that have an observable name property", ->
    it "should observe the name as the text of the value options", ->
      options = Observable [
        {name: Observable("Napoleon"), date: "1850 AD"}
        {name: Observable("Barrack"), date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)

      behave template(model), ->
        assert.equal all("option")[0].textContent, "Napoleon"
        options.get(0).name("Yolo")
        assert.equal all("option")[0].textContent, "Yolo"

  describe "with an observable array for options", ->
    it "should add options added to the observable array", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)
      behave template(model), ->
        assert.equal all("option").length, 2
        options.push name: "Test", date: "2014 AD"
        assert.equal all("option").length, 3
    it "should remove options removed from the observable array", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)
      behave template(model), ->
        assert.equal all("option").length, 2
        options.remove options.get(0)
        assert.equal all("option").length, 1
    it "should have it's value set", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)
      behave template(model), ->
        # TODO: This isn't a great check
        assert.equal Q("select")._value, model.value
  describe "with an object for options", ->
    it "should have an option for each key"

