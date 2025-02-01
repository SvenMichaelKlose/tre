(defmacro with-%= (place value x &body body)
  (with-gensym g
    `(with (,g      ,x
            ,place  (cadr ,g)
            ,value  (caddr ,g))
       ,@body)))

(fn %=-place (x)
 .x.)

(fn %=-value (x)
 ..x.)

(fn %=-atomic? (x)
  (& (%=? x)
     .x.
     (atom .x.)
     (atom ..x.)))

(fn %=-funcall? (x)
  (? (%=? x)
     (cons? ..x.)))

(fn %=-funcall-of? (x name)
  (& (%=-funcall? x)
     (eq name ..x..)))

(fn %=-modifies? (x place)
  (& (%=? x)
     (eq place (%=-place x))))

(fn %=-uses? (x value)
  (tree-find value (%=-value x) :test #'equal))
