(def-compiler-macro setq (&rest args)
  (? ..args
     `(%block
        ,@(@ [`(%= ,_. ,._.)]
             (group args 2)))
     `(%= ,@args)))
