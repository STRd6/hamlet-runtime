extend = (target, sources...) ->
  for source in sources
    for name of source
      target[name] = source[name]

{compile} = require "hamlet-compiler"
Runtime = require "../source/runtime"
Observable = Runtime.Observable

{jsdom} = require("jsdom")

extend global,
  assert: require "assert"
  extend: extend
  Observable: Observable
  document: jsdom()

  Q: (args...) ->
    document.querySelector(args...)

  all: (args...) ->
    document.querySelectorAll(args...)

  makeTemplate: (code) ->
    compiled = compile code, runtime: "Runtime"
    Function("Runtime", "return " + compiled)(Runtime)

  empty: (node) ->
    while child = node.firstChild
      node.removeChild child

  click: (element) ->
    event = document.createEvent("MouseEvents")
    event.initMouseEvent "click"
    element.dispatchEvent event

    return event

  behave: (fragment, fn) ->
    document.body.appendChild fragment
    try
      fn()
    finally
      empty document.body
