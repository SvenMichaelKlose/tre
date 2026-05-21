tré LML package
===============

# Overview

LML is Lisp-notated XML.  It can printed as XML or turned into a DOM tree,
utilizing React-like components and – rarely used – LML macros.

# Writing LML

The first element of an expression is the tag name, followed by attribute/value
pairs as keyword/value pairs.  Strings are the text.

~~~xml
<p>Hello world!</p>
~~~

becomes

~~~lisp
(p "Hello world!")
~~~

Empty elements come in two flavours:

~~~xml
<hr/> is (hr)
<hr></hr> is (hr "")
~~~

Attributes are keyword arguments:

~~~xml
<section class="highlighted">
    Some text.
</section>
~~~

becomes

~~~lisp
(section :class "highlighted"
  "Some text.")
~~~

Attributes may come without value:

~~~xml
<script defer></script>
~~~

becomes

~~~lisp
(script :defer nil "")
~~~

The tag and attribute names are converted to lowerCamelCase.

Function $$ is used to convert LML into a DOM tree.  This:

~~~lisp
(document.body.add
  ($$ `(html :lang "en"
         (head
           (title "Hello world!")
           (script :src "/main.js"
                   :defer nil  ; Attribute without value.
                   ""))        ; Ensure closing tag.
           (body
             "Hi there!"))))
~~~

will print

~~~xml
<html lang="en"
  <head>
    <title>Hello world!</title>
    <script src="/main.js" defer></script>
  </head>
  <body>
    Hi there!
  </body>
</html>
~~~


## Adding event listeners

Event listeners can be applied as attributes starting with the prefix
'on-' followed by the event name.

~~~lisp
(!= [(alert "Thanks!")
     (_.prevent-default)]
  (document.body.add ($$ `(button :on-click ,!
                            "Click me!"))))
~~~


## Macros

Macros can be defined with DEFINE-LML-MACRO.  But since &REST arguments cannot
follow &KEY arguments, they are of limited use.  Instead, you might want to use
components, which are described in the next section.

~~~lisp
(define-lml-macro my-image (&key src alt)
  `(figure
     (img :src ,src)
     (figcaption ,alt)))
~~~


## Components

Components are objects or functions that represent virtual DOM elements.
Once defined they are recognized by the $$ function.  Let's have a component
which is a function.  It takes its attributes as JSON in argument PROPS:

~~~lisp
(fn my-image (props)
  ($$ `(figure
         (img :src ,props.src)
         (figcaption ,props.alt))))

(declare-lml-component my-image)
~~~

Now $$ knows MY-IMAGE:

~~~lisp
(document.body.add ($$ `(my-image :src "img.jpg" :alt "My image")))
~~~

Components can also be classes derived from LML-COMPONENT to set up elements
with state.  Changing the state via SET-STATE will cause the component to
re-create its DOM tree via its RENDER method.

```
(class (my-image lml-component) (init-props)
  (super init-props) ; Will set member variable PROPS.
  (= state {"clicks" 0})
  this)

(defmethod my-image render ()
  ($$ `(figure :on-click [_click]
         (img :src ,props.src)
         (figcaption ,props.alt)
         (p "Clicked " ,state.clicks " times.")
         ,@props.children)))

(defmethod my-image _click (evt)
  (set-state {"state" (++ state.clicks)})
  (evt.prevent-default))

(declare-lml-component my-image)
```

At this moment LML-COMPONENT does not check if an element has to be re-rendered
at all.  (Optimizations will come last.)


# Storage

STORAGE is an interface to access, traverse and modify JSON data.  That data
may actually be stored in memory, a web session, a file, a database, and so on.
With STORAGE you can have parts of your JSON data edited using AUTOFORM.
Stores can be connected to components, so components will be re-rendered
automatically when data changed.

# Autoform

Displays JSON data based on a JSON Schema.  Editable forms can also be made using
STORAGE objects.
