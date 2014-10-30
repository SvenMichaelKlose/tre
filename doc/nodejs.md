# Compiling to JavaScript for node.js

## Switching to the node.js environment of the JS target:

By default the JS target compiles for use in browsers.  Switch
to node.js switch the ENVIRONMENT transpiler configuration from
BROWSER to NODEJS.  Like so:

```
(make-project "My node.js project"
              my-files
              :transpiler (aprog1 (copy-transpiler *js-transpiler*)
                            (= (transpiler-configuration ! 'environment)
                               'nodejs))
              :emitter [put-file "nodejs-project.js" _])
```

## Specifying node.js packages

The transpiler configuration NODEJS-REQUIREMENTS takes a list of
package names.

This example…

```
(make-project "My node.js project with packages"
              my-files
              :transpiler (aprog1 (copy-transpiler *js-transpiler*)
                            (= (transpiler-configuration ! 'environment)
                               'nodejs)
                            (= (transpiler-configuration ! 'nodejs-requirements)
                               '("fs" "http" "formaline")))
              :emitter [put-file "nodejs-project.js" _])
```

…will generate a prologue like this:

```
var fs = require ("fs");
var http = require ("http");
var formaline = require ("formaline");
```
