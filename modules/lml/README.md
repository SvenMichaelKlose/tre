tré LML module
==============

On its long way to version 1.0.


# Converting LML to DOM

LML is XML stored as expressions.  If an expression is not a
text string, the first element of an expression must be the
tag name as a symbol, followed by optional attributes as
keyword arguments and then its children.

The tag and attribute names are converted to lower camel case.

Function $$ is used to convert LML into a DOM tree.  This:

```
(princ ($$ `(html :lang "en"
              (head
                (title "Hello world!")
                (script :src "/main.js"
                        :defer nil  ; Attribute without value.
                        ""))        ; Ensure closing tag.
              (body
                "Hi there!"))))
```

will print


```
<html lang="en"
  <head>
    <title>Hello world!</title>
    <script src="/main" defer></script>
  </head>
  <body>
    Hi there!
  </body>
</html>
```


## Adding event listeners

Event listeners can be applied as attributes starting with the prefix
'on-' followed by the event name.

```
(!= [(alert "Thanks!")
     (_.prevent-default)]
  (document.body.add ($$ `(button on-click ,!
                            "Click me!"))))
```


## Macros

Macros can be defined with DEFINE-LML-MACRO.

```
(define-lml-macro my-image (&key src alt)
  `(figure
     (img :src ,src)
     (figcaption ,alt)))
```

Please note that &REST arguments cannot follow &KEY arguments,
so macro expansion might be of limited use.  Instead, you might
want to use components.


## Components

Components can be functions which take a set of attributes
(called 'props') and generate a DOM tree during LML to DOM
conversion with the $$ function.

```
(fn my-image (props)
  ($$ `(figure
         (img :src ,props.src)
         (figcaption ,props.alt))))

(declare-lml-component my-image)
```

Components can also be classes derived from LML-COMPONENT) to
set up elements with state.  Changing the state will cause
the component to create its DOM tree again with its RENDER
method.

```
(class (my-image lml-component) (init-props)
  (super init-props) ; Will set member variable PROPS.
  (= state {"clicks" 0})
  this)

(defmethod my-image _click (evt)
  (set-state {"state" (++ state.clicks)})
  (evt.prevent-default))

(defmethod my-image render ()
  ($$ `(figure :on-click [_click]
         (img :src ,props.src)
         (figcaption ,props.alt)
         (p "Clicked " ,state.clicks " times.")
         ,@props.children)))

(declare-lml-component my-image)
```

At this moment LML-COMPONENT does not check if an element
has to be re-rendered at all.  (Optimizations will come last.)

# Stores

Stores (of class STORE) hide how records of key value pairs are
being updated, like just in itself, a session, DOM attributes or
in a database.  To do this, a store will remember where a record
has been read from.

Stores can be connected to components, so components will be
re-rendered automatically when data in the store changed.
LML-CONTAINER (derived from LML-COMPONENT) might help with that.

TODO: Stores can also validate the data they contain based on
JSON Schemas.

# Autoforms

AUTOFORM-RECORD and AUTOFORM-LIST generate forms for single
records (or lists of records) based on schemas describing the
data in the store passed to it.
