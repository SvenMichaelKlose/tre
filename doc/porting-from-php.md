# Porting from PHP to tré

## Literal constants

Use %%NATIVE to inject native source strings:
```lisp
(some_php_function (%%native "LITERAL_CONSTANT_NAME_WITHOUT_DOLLAR"))
