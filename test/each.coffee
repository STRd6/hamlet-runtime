describe "each", ->
  describe "iterating", ->
    template = makeTemplate """
      %ul
        - each @items, ->
          %li= @name
    """

    describe "with observable arrays", ->
      it "should have an item for each element", ->
        model =
          items: Observable [
            {name: "Hello"}
            {name: "Test"}
          ]

        behave template(model), ->
          assert.equal all("li").length, 2
          assert.equal Q("li").textContent, "Hello"

      it "should add items when items are added to the array", ->
        model =
          items: Observable [
            {name: "Hello"}
            {name: "Test"}
          ]

        behave template(model), ->
          assert.equal all("li").length, 2
          model.items.push name: "yolo"
          assert.equal all("li").length, 3

      it "should remove items when they are removed", ->
        model =
          items: Observable [
            {name: "Hello"}
            {name: "Test"}
          ]

        behave template(model), ->
          assert.equal all("li").length, 2
          model.items.pop()
          model.items.pop()
          assert.equal all("li").length, 0

          model.items.push name: "wat"

          assert.equal all("li").length, 1

    describe "with regular arrays", ->
      it "should have an item for each element", ->
        model =
          items: [
            {name: "Hello"}
            {name: "Test"}
          ]

        behave template(model), ->
          assert.equal all("li").length, 2
          assert.equal Q("li").textContent, "Hello"

      it "will not add items when items are added to the array", ->
        model =
          items: [
            {name: "Hello"}
            {name: "Test"}
          ]

        behave template(model), ->
          assert.equal all("li").length, 2
          model.items.push name: "yolo"
          assert.equal all("li").length, 2

      it "will not remove items when they are removed", ->
        model =
          items: [
            {name: "Hello"}
            {name: "Test"}
          ]

        behave template(model), ->
          assert.equal all("li").length, 2
          model.items.pop()
          model.items.pop()
          assert.equal all("li").length, 2

  describe "inline", ->
    template = makeTemplate """
      %ul
        = each @items, @itemView
    """

    it "should work"
    # TODO
    ->
      model =
        items: [
          "Hello"
          "there"
          "stranger"
        ]
        itemView: makeTemplate """
          %li= this
        """

      behave template(model), ->
        assert.equal all("li").length, 3
