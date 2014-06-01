Observable = require "o_0"

eventNames = """
  abort
  blur
  change
  click
  dblclick
  drag
  dragend
  dragenter
  dragleave
  dragover
  dragstart
  drop
  error
  focus
  input
  keydown
  keypress
  keyup
  load
  mousedown
  mousemove
  mouseout
  mouseover
  mouseup
  reset
  resize
  scroll
  select
  submit
  touchcancel
  touchend
  touchenter
  touchleave
  touchmove
  touchstart
  unload
""".split("\n")

isEvent = (name) ->
  eventNames.indexOf(name) != -1

isFragment = (node) ->
  node?.nodeType is 11

# TODO: Make sure to handle rendering multiple sibling contents correctly
# currently just crushes the others
contentBind = (element, value, context) ->
  update = ->
    empty(element)
    # Attach contents
    value.each (item) ->
      element.appendChild(item)

  bindObservable element, value, context, update

valueBind = (element, value, context) ->
  value = Observable value, context

  switch element.nodeName
    when "SELECT"
      element.oninput = element.onchange = ->
        {value:optionValue, _value} = @children[@selectedIndex]

        value(_value or optionValue)

      update = (newValue) ->
        # This is so we can hold a non-string object as a value of the select element
        element._value = newValue

        if (options = element._options)
          if newValue.value?
            # TODO: Handle observable value attributes
            element.value = newValue.value?() or newValue.value
          else
            element.selectedIndex = valueIndexOf options, newValue
        else
          element.value = newValue

      bindObservable element, value, context, update
    else
      # Because firing twice with the same value is idempotent just binding both
      # oninput and onchange handles the widest range of inputs and browser
      # inconsistencies.
      element.oninput = element.onchange = ->
        value(element.value)

      bindObservable element, value, context, (newValue) ->
        element.value = newValue

  return

specialBindings =
  INPUT:
    checked: (element, value, context) ->
      element.onchange = ->
        value? element.checked

      bindObservable element, value, context, (newValue) ->
        element.checked = newValue
  SELECT:
    options: (element, values, context) ->
      values = Observable values, context

      updateValues = (values) ->
        empty(element)
        element._options = values

        # TODO: Handle key: value... style options
        values.map (value, index) ->
          option = document.createElement("option")
          option._value = value
          if typeof value is "object"
            optionValue = value?.value or index
          else
            optionValue = value.toString()

          bindObservable option, optionValue, value, (newValue) ->
            option.value = newValue

          optionName = value?.name or value
          bindObservable option, optionName, value, (newValue) ->
            option.textContent = newValue

          element.appendChild option
          element.selectedIndex = index if value is element._value

          return option

      bindObservable element, values, context, updateValues

bindObservable = (element, value, context, update) ->
  observable = Observable(value, context)

  observe = ->
    observable.observe update
    update observable()

  unobserve = ->
    observable.stopObserving update

  observe()

  (element._hamlet_cleanup ||= []).push unobserve

  return element

bindEvent = (element, name, fn, context) ->
  element[name] = ->
    fn.apply(context, arguments)

cleanup = (element) ->
  Array::forEach.call element.children, cleanup

  element._hamlet_cleanup?.forEach (method) ->
    method()

  delete element._hamlet_cleanup

  return

Runtime = (context) ->
  stack = []

  # HAX: A document fragment is not your real dad
  lastParent = ->
    i = stack.length - 1
    while (element = stack[i]) and isFragment(element)
      i -= 1

    element

  top = ->
    stack[stack.length-1]

  append = (child) ->
    parent = top()

    # TODO: This seems a little gross
    # The problem is that in each blocks our fragments are being emptied
    # because they are appended to the parent before we return
    # By appending and returning the child instead we should be able to
    # keep a reference to the actual elements
    if parent and isFragment(child) and child.childNodes.length is 1
      child = child.childNodes[0]

    # TODO: We shouldn't have to use this soak
    top()?.appendChild(child)

    return child

  push = (child) ->
    stack.push(child)

  pop = ->
    append(stack.pop())

  render = (child) ->
    push(child)
    pop()

  id = (sources...) ->
    element = top()

    update = (newValue) ->
      if typeof newValue is "function"
        newValue = newValue()

      element.id = newValue

    value = ->
      possibleValues = sources.map (source) ->
        if typeof source is "function"
          source()
        else
          source
      .filter (idValue) ->
        idValue?

      possibleValues[possibleValues.length-1]

    bindObservable(element, value, context, update)

  classes = (sources...) ->
    element = top()

    update = (newValue) ->
      if typeof newValue is "function"
        newValue = newValue()

      element.className = newValue

    do (context) ->
      value = ->
        possibleValues = sources.map (source) ->
          if typeof source is "function"
            source.call(context)
          else
            source
        .filter (sourceValue) ->
          sourceValue?

        possibleValues.join(" ")

      bindObservable(element, value, context, update)

  observeAttribute = (name, value) ->
    element = top()

    {nodeName} = element

    # TODO: Consolidate special bindings better than if/else
    if (name is "value")
      valueBind(element, value)
    else if binding = specialBindings[nodeName]?[name]
      binding(element, value, context)
    # Straight up onclicks, etc.
    else if name.match(/^on/) and isEvent(name.substr(2))
      bindEvent(element, name, value, context)
    # Handle click=@method
    else if isEvent(name)
      bindEvent(element, "on#{name}", value, context)
    else
      bindObservable element, value, context, (newValue) ->
        if newValue? and newValue != false
          element.setAttribute name, newValue
        else
          element.removeAttribute name

    return element

  # TODO: This is getting a little out of hand with complexity
  # switching out text/render would be a smart move
  observeText = (value) ->
    value = Observable value, context

    # Kind of a hack for handling sub renders
    # or adding explicit html nodes to the output
    # TODO: May want to make more sure that it's a real dom node
    #       and not some other object with a nodeType property
    # TODO: This shouldn't be inside of the observeText method
    # TODO: Think about how this should work with observable nodes
    switch value()?.nodeType
      when 1, 3, 11
        return contentBind top(), value, context

    # TODO: One more hack to handle lists of nodes
    switch value()?[0]?.nodeType
      when 1, 3, 11
        return contentBind top(), value, context

    # HACK: We don't really want to know about the document inside here.
    # Creating our text nodes in here cleans up the external call
    # so it may be worth it.
    element = document.createTextNode('')

    update = (newValue) ->
      element.nodeValue = newValue

    bindObservable element, value, context, update

    render element

  withContext = (newContext, fn) ->
    oldContext = context
    context = newContext
    try
      fn()
    finally
      context = oldContext

  self =
    # Pushing and popping creates the node tree
    push: push
    pop: pop

    id: id
    classes: classes
    attribute: observeAttribute
    text: observeText

    filter: (name, content) ->
      ; # TODO self.filters[name](content)

    each: (items, fn) ->
      items = Observable(items, context)
      elements = null
      parent = lastParent()

      # TODO: Work when rendering many sibling elements
      items.observe ->
        replace elements

      replace = (oldElements) ->
        elements = []
        items.each (item, index, array) ->
          element = null

          withContext item, ->
            element = fn.call(item, item, index, array)

          if isFragment(element)
            elements.push element.childNodes...
          else
            elements.push element

          parent.appendChild element

          return element

        oldElements?.forEach remove

      replace(null, items)

  return self

Runtime.Observable = Observable
module.exports = Runtime

empty = (node) ->
  node.removeChild(child) while child = node.firstChild

# A helper to find the index of a value in an array of options
# when the array may contain actual objects or strings, numbers, etc.

# NOTE: This may be too complicated, the core issue is that anything coming from an input
# will be a string, and anything coming from a regular observable can be any object type.
# Possible solutions:
#   Typed observables that auto-convert strings to the correct type.
#   OR
#   Always compare non-object inputs as strings.
valueIndexOf = (options, value) ->
  if typeof value is "object"
    options.indexOf(value)
  else
    options.map (option) ->
      option.toString()
    .indexOf value.toString()

remove = (element) ->
  cleanup element
  element.parentNode?.removeChild(element)

  return
