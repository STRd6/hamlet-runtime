!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.Hamlet=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(_dereq_,module,exports){
// Generated by CoffeeScript 1.7.1
(function() {
  "use strict";
  var Observable, Runtime, bindEvent, bindObservable, bufferTo, classes, createElement, empty, eventNames, get, id, isEvent, isFragment, makeElement, observeAttribute, observeAttributes, observeContent, specialBindings, valueBind, valueIndexOf;

  Observable = _dereq_("o_0");

  eventNames = "abort\nblur\nchange\nclick\ndblclick\ndrag\ndragend\ndragenter\ndragleave\ndragover\ndragstart\ndrop\nerror\nfocus\ninput\nkeydown\nkeypress\nkeyup\nload\nmousedown\nmousemove\nmouseout\nmouseover\nmouseup\nreset\nresize\nscroll\nselect\nsubmit\ntouchcancel\ntouchend\ntouchenter\ntouchleave\ntouchmove\ntouchstart\nunload".split("\n");

  isEvent = function(name) {
    return eventNames.indexOf(name) !== -1;
  };

  isFragment = function(node) {
    return (node != null ? node.nodeType : void 0) === 11;
  };

  valueBind = function(element, value, context) {
    Observable(function() {
      var update;
      value = Observable(value, context);
      switch (element.nodeName) {
        case "SELECT":
          element.oninput = element.onchange = function() {
            var optionValue, _ref, _value;
            _ref = this.children[this.selectedIndex], optionValue = _ref.value, _value = _ref._value;
            return value(_value || optionValue);
          };
          update = function(newValue) {
            var options;
            element._value = newValue;
            if ((options = element._options)) {
              if (newValue.value != null) {
                return element.value = (typeof newValue.value === "function" ? newValue.value() : void 0) || newValue.value;
              } else {
                return element.selectedIndex = valueIndexOf(options, newValue);
              }
            } else {
              return element.value = newValue;
            }
          };
          return bindObservable(element, value, context, update);
        default:
          element.oninput = element.onchange = function() {
            return value(element.value);
          };
          if (typeof element.attachEvent === "function") {
            element.attachEvent("onkeydown", function() {
              return setTimeout(function() {
                return value(element.value);
              }, 0);
            });
          }
          return bindObservable(element, value, context, function(newValue) {
            if (element.value !== newValue) {
              return element.value = newValue;
            }
          });
      }
    });
  };

  specialBindings = {
    INPUT: {
      checked: function(element, value, context) {
        element.onchange = function() {
          return typeof value === "function" ? value(element.checked) : void 0;
        };
        return bindObservable(element, value, context, function(newValue) {
          return element.checked = newValue;
        });
      }
    },
    SELECT: {
      options: function(element, values, context) {
        var updateValues;
        values = Observable(values, context);
        updateValues = function(values) {
          empty(element);
          element._options = values;
          return values.map(function(value, index) {
            var option, optionName, optionValue;
            option = createElement("option");
            option._value = value;
            if (typeof value === "object") {
              optionValue = (value != null ? value.value : void 0) || index;
            } else {
              optionValue = value.toString();
            }
            bindObservable(option, optionValue, value, function(newValue) {
              return option.value = newValue;
            });
            optionName = (value != null ? value.name : void 0) || value;
            bindObservable(option, optionName, value, function(newValue) {
              return option.textContent = option.innerText = newValue;
            });
            element.appendChild(option);
            if (value === element._value) {
              element.selectedIndex = index;
            }
            return option;
          });
        };
        return bindObservable(element, values, context, updateValues);
      }
    }
  };

  observeAttribute = function(element, context, name, value) {
    var binding, nodeName, _ref;
    nodeName = element.nodeName;
    if (name === "value") {
      valueBind(element, value);
    } else if (binding = (_ref = specialBindings[nodeName]) != null ? _ref[name] : void 0) {
      binding(element, value, context);
    } else if (name.match(/^on/) && isEvent(name.substr(2))) {
      bindEvent(element, name, value, context);
    } else if (isEvent(name)) {
      bindEvent(element, "on" + name, value, context);
    } else {
      bindObservable(element, value, context, function(newValue) {
        if ((newValue != null) && newValue !== false) {
          return element.setAttribute(name, newValue);
        } else {
          return element.removeAttribute(name);
        }
      });
    }
    return element;
  };

  observeAttributes = function(element, context, attributes) {
    return Object.keys(attributes).forEach(function(name) {
      var value;
      value = attributes[name];
      return observeAttribute(element, context, name, value);
    });
  };

  bindObservable = function(element, value, context, update) {
    var observable, observe, unobserve;
    observable = Observable(value, context);
    observe = function() {
      observable.observe(update);
      return update(observable());
    };
    unobserve = function() {
      return observable.stopObserving(update);
    };
    observe();
    return element;
  };

  bindEvent = function(element, name, fn, context) {
    return element[name] = function() {
      return fn.apply(context, arguments);
    };
  };

  id = function(element, context, sources) {
    var lastId, update, value;
    value = Observable.concat.apply(Observable, sources.map(function(source) {
      return Observable(source, context);
    }));
    update = function(newId) {
      return element.id = newId;
    };
    lastId = function() {
      return value.last();
    };
    return bindObservable(element, lastId, context, update);
  };

  classes = function(element, context, sources) {
    var classNames, update, value;
    value = Observable.concat.apply(Observable, sources.map(function(source) {
      return Observable(source, context);
    }));
    update = function(classNames) {
      return element.className = classNames;
    };
    classNames = function() {
      return value.join(" ");
    };
    return bindObservable(element, classNames, context, update);
  };

  createElement = function(name) {
    return document.createElement(name);
  };

  observeContent = function(element, context, contentFn) {
    var append, contents, update;
    contents = [];
    contentFn.call(context, {
      buffer: bufferTo(context, contents),
      element: makeElement
    });
    append = function(item) {
      if (typeof item === "string") {
        return element.appendChild(document.createTextNode(item));
      } else if (typeof item === "number") {
        return element.appendChild(document.createTextNode(item));
      } else if (typeof item === "boolean") {
        return element.appendChild(document.createTextNode(item));
      } else if (typeof item.each === "function") {
        return item.each(append);
      } else if (typeof item.forEach === "function") {
        return item.forEach(append);
      } else {
        return element.appendChild(item);
      }
    };
    update = function(contents) {
      empty(element);
      return contents.forEach(append);
    };
    return update(contents);
  };

  bufferTo = function(context, collection) {
    return function(content) {
      if (typeof content === 'function') {
        content = Observable(content, context);
      }
      collection.push(content);
      return content;
    };
  };

  makeElement = function(name, context, attributes, fn) {
    var element;
    if (attributes == null) {
      attributes = {};
    }
    element = createElement(name);
    Observable(function() {
      if (attributes.id != null) {
        id(element, context, attributes.id);
        return delete attributes.id;
      }
    });
    Observable(function() {
      if (attributes["class"] != null) {
        classes(element, context, attributes["class"]);
        return delete attributes["class"];
      }
    });
    Observable(function() {
      return observeAttributes(element, context, attributes);
    }, context);
    if (element.nodeName !== "SELECT") {
      Observable(function() {
        return observeContent(element, context, fn);
      }, context);
    }
    return element;
  };

  Runtime = function(context) {
    var self;
    self = {
      buffer: function(content) {
        if (self.root) {
          throw "Cannot have multiple root elements";
        }
        return self.root = content;
      },
      element: makeElement,
      filter: function(name, content) {}
    };
    return self;
  };

  Runtime.VERSION = _dereq_("../package.json").version;

  Runtime.Observable = Observable;

  module.exports = Runtime;

  empty = function(node) {
    var child, _results;
    _results = [];
    while (child = node.firstChild) {
      _results.push(node.removeChild(child));
    }
    return _results;
  };

  valueIndexOf = function(options, value) {
    if (typeof value === "object") {
      return options.indexOf(value);
    } else {
      return options.map(function(option) {
        return option.toString();
      }).indexOf(value.toString());
    }
  };

  get = function(x) {
    if (typeof x === 'function') {
      return x();
    } else {
      return x;
    }
  };

}).call(this);

},{"../package.json":3,"o_0":2}],2:[function(_dereq_,module,exports){
(function (global){
// Generated by CoffeeScript 1.8.0
(function() {
  var Observable, autoDeps, computeDependencies, copy, extend, flatten, get, last, magicDependency, remove, splat, withBase,
    __slice = [].slice;

  Observable = function(value, context) {
    var changed, fn, listeners, notify, notifyReturning, self;
    if (typeof (value != null ? value.observe : void 0) === "function") {
      return value;
    }
    listeners = [];
    notify = function(newValue) {
      return copy(listeners).forEach(function(listener) {
        return listener(newValue);
      });
    };
    if (typeof value === 'function') {
      fn = value;
      self = function() {
        magicDependency(self);
        return value;
      };
      changed = function() {
        value = computeDependencies(self, fn, changed, context);
        return notify(value);
      };
      value = computeDependencies(self, fn, changed, context);
    } else {
      self = function(newValue) {
        if (arguments.length > 0) {
          if (value !== newValue) {
            value = newValue;
            notify(newValue);
          }
        } else {
          magicDependency(self);
        }
        return value;
      };
    }
    self.each = function(callback) {
      magicDependency(self);
      if (value != null) {
        [value].forEach(function(item) {
          return callback.call(item, item);
        });
      }
      return self;
    };
    if (Array.isArray(value)) {
      ["concat", "every", "filter", "forEach", "indexOf", "join", "lastIndexOf", "map", "reduce", "reduceRight", "slice", "some"].forEach(function(method) {
        return self[method] = function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          magicDependency(self);
          return value[method].apply(value, args);
        };
      });
      ["pop", "push", "reverse", "shift", "splice", "sort", "unshift"].forEach(function(method) {
        return self[method] = function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return notifyReturning(value[method].apply(value, args));
        };
      });
      notifyReturning = function(returnValue) {
        notify(value);
        return returnValue;
      };
      extend(self, {
        each: function(callback) {
          self.forEach(function(item, index) {
            return callback.call(item, item, index, self);
          });
          return self;
        },
        remove: function(object) {
          var index;
          index = value.indexOf(object);
          if (index >= 0) {
            return notifyReturning(value.splice(index, 1)[0]);
          }
        },
        get: function(index) {
          magicDependency(self);
          return value[index];
        },
        first: function() {
          magicDependency(self);
          return value[0];
        },
        last: function() {
          magicDependency(self);
          return value[value.length - 1];
        },
        size: function() {
          magicDependency(self);
          return value.length;
        }
      });
    }
    extend(self, {
      listeners: listeners,
      observe: function(listener) {
        return listeners.push(listener);
      },
      stopObserving: function(fn) {
        return remove(listeners, fn);
      },
      toggle: function() {
        return self(!value);
      },
      increment: function(n) {
        return self(value + n);
      },
      decrement: function(n) {
        return self(value - n);
      },
      toString: function() {
        return "Observable(" + value + ")";
      }
    });
    return self;
  };

  Observable.concat = function() {
    var args, o;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    args = Observable(args);
    o = Observable(function() {
      return flatten(args.map(splat));
    });
    o.push = args.push;
    return o;
  };

  module.exports = Observable;

  extend = function() {
    var name, source, sources, target, _i, _len;
    target = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_i = 0, _len = sources.length; _i < _len; _i++) {
      source = sources[_i];
      for (name in source) {
        target[name] = source[name];
      }
    }
    return target;
  };

  global.OBSERVABLE_ROOT_HACK = [];

  autoDeps = function() {
    return last(global.OBSERVABLE_ROOT_HACK);
  };

  magicDependency = function(self) {
    var observerStack;
    if (observerStack = autoDeps()) {
      return observerStack.push(self);
    }
  };

  withBase = function(self, update, fn) {
    var deps, value, _ref;
    global.OBSERVABLE_ROOT_HACK.push(deps = []);
    try {
      value = fn();
      if ((_ref = self._deps) != null) {
        _ref.forEach(function(observable) {
          return observable.stopObserving(update);
        });
      }
      self._deps = deps;
      deps.forEach(function(observable) {
        return observable.observe(update);
      });
    } finally {
      global.OBSERVABLE_ROOT_HACK.pop();
    }
    return value;
  };

  computeDependencies = function(self, fn, update, context) {
    return withBase(self, update, function() {
      return fn.call(context);
    });
  };

  remove = function(array, value) {
    var index;
    index = array.indexOf(value);
    if (index >= 0) {
      return array.splice(index, 1)[0];
    }
  };

  copy = function(array) {
    return array.concat([]);
  };

  get = function(arg) {
    if (typeof arg === "function") {
      return arg();
    } else {
      return arg;
    }
  };

  splat = function(item) {
    var result, results;
    results = [];
    if (item == null) {
      return results;
    }
    if (typeof item.forEach === "function") {
      item.forEach(function(i) {
        return results.push(i);
      });
    } else {
      result = get(item);
      if (result != null) {
        results.push(result);
      }
    }
    return results;
  };

  last = function(array) {
    return array[array.length - 1];
  };

  flatten = function(array) {
    return array.reduce(function(a, b) {
      return a.concat(b);
    }, []);
  };

}).call(this);

}).call(this,typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}],3:[function(_dereq_,module,exports){
module.exports={
  "name": "hamlet-runtime",
  "version": "0.7.0-pre.2",
  "devDependencies": {
    "browserify": "^4.1.11",
    "coffee-script": "~1.7.1",
    "hamlet-compiler": "0.7.0-pre.0",
    "jsdom": "^0.10.5",
    "mocha": "~1.12.0",
    "uglify-js": "~2.3.6"
  },
  "dependencies": {
    "o_0": "0.3.3"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/dr-coffee-labs/hamlet-compiler.git"
  },
  "scripts": {
    "prepublish": "script/prepublish",
    "test": "script/test"
  },
  "files": [
    "dist/"
  ],
  "main": "dist/runtime.js"
}

},{}]},{},[1])
(1)
});