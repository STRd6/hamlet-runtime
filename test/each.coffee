describe "each", ->
  describe "iterating", ->
    template = makeTemplate """
      %ul
        - @items.forEach (item) ->
          %li= item.name
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
        = @items.map(@itemView)
    """

    it "should work", ->
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

  describe "efficiency", ->
    it "should render the template once when the observable changes", ->
      template = makeTemplate """
        .awesome
          - @renderedOuter()
          %ul
            - renderedItem = @renderedItem
            - @renderedTemplate()
            - @items.each (item) ->
              .item
              - renderedItem()
      """

      oCount = 0
      tCount = 0
      iCount = 0

      model =
        items: Observable [
          "A"
          "B"
          "C"
        ]
        renderedOuter: ->
          oCount += 1
        renderedTemplate: ->
          tCount += 1
        renderedItem: ->
          iCount += 1

      behave template(model), ->
        assert.equal oCount, 1
        assert.equal tCount, 1
        assert.equal iCount, 3

        model.items.push "D"
        assert.equal oCount, 1
        assert.equal tCount, 2
        assert.equal iCount, 7

        model.items.push "E"
        assert.equal oCount, 1
        assert.equal tCount, 3
        assert.equal iCount, 12
