describe "runtime", ->
  Runtime = require "../source/runtime"

  it "should have the version number", ->
    assert Runtime.VERSION
