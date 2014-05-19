describe "Filters", ->
  it "should provide :coffeescript", ->
    template = makeTemplate """
      :coffeescript
        a = "jawsome"
      %div(type=a)
    """

    behave template(), ->
      assert.equal Q("div").getAttribute("type"), "jawsome"

  it "should provide :javascript", ->
    template = makeTemplate """
      :javascript
        a = "jawsome";
      %div(type=a)
    """

    behave template(), ->
      assert.equal Q("div").getAttribute("type"), "jawsome"

  describe ":verbatim", ->
    it "should keep text verbatim", ->
      template = makeTemplate """
        %textarea
          :verbatim
            <I> am <verbatim> </text>
      """

      behave template(), ->
        assert.equal Q("textarea").value, "<I> am <verbatim> </text>"

    it "should work with indentation", ->
      template = makeTemplate """
        :verbatim
          Hey
            It's
              Indented

      """

      behave template(), ->
        # TODO: This probably shouldn't have a trailing \n
        assert.equal Q("body").textContent, "Hey\n  It's\n    Indented\n"

    it "should work with indentation without extra trailing whitespace"
    # TODO
    ->
      template = makeTemplate """
        :verbatim
          Hey
            It's
              Indented
      """

      behave template(), ->
        assert.equal Q("body").textContent, "Hey\n  It's\n    Indented"

    it "should work with \"\"\"", ->
      template = makeTemplate """
        :verbatim
          sample = \"\"\"
            Hey
          \"\"\"

      """

      behave template(), ->
        assert.equal Q("body").textContent, "sample = \"\"\"\n  Hey\n\"\"\"\n"
