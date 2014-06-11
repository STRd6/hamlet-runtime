describe "real world cases", ->
  template = makeTemplate """
    .node
      - subtemplate = @subtemplate
      - each @items, ->
        .row
          - if @items
            = subtemplate items: @items
          - else
            .item
              %input.key(value=@key)
              %input.value(value=@value)
  """

  it "should render fine", ->
  #-> # TODO!
    model =
      subtemplate: template
      items: Observable [
        {key: Observable("wat"), value: Observable("teh")}
        {key: Observable("duder"), value: Observable("yo")}
        {items: Observable([
          {key: Observable("yolo"), value: Observable("heyo")}
        ])}
      ]

    behave template(model), ->
      assert.equal Q(".key").value, "wat"
      assert.equal all(".node").length, 2
      assert.equal all(".key").length, 3
