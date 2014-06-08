Getting Started
===============

Compiler
--------

Install Hamlet CLI tool to compile templates

    npm install -g hamlet-cli

Here's an example of a bash script you can use to compile all haml files in your templates directory.

    #! /bin/bash

    cd templates

    for file in *.haml; do
      hamlet < $file > ${file/.haml}.js
    done

Runtime
-------

Add hamlet-runtime to your package.json

    npm install --save-dev hamlet-runtime

To use the templates in a Node.js style project built with browserify you can require them normally.

    mainTemplate = require "./templates/main"

    document.body.appendChild mainTemplate(data)

Gotchas
-------

Templates that lack root elements or root elements in iterators can be problematic.

Problematic Example:

    .row
      - each @items, ->
        .first
        .second

Safe solution:

    .row
      - each @items, ->
        .item
          .first
          .second

Problematic example:

    .one
    .two
    .three
    .four

Safe solution:

    .root
      .one
      .two
      .three
      .four

Some of the problematic examples may work in simple situations, but if they are used as subtemplates or as observable changes take effect errors may occur. In theory it will be possible to correct this in a later version, but for now it remains a concern.

TLDR: If you are experiencing unexpected behavior in your templates make sure you have a root element,
and any each iteration has a root element.
