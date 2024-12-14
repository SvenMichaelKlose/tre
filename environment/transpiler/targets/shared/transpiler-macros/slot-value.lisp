(def-shared-transpiler-macro (js php) slot-value (obj slot)
  (? (quote? slot)
     `(%slot-value ,obj ,.slot.)
     `(slot-value ,obj ,slot)))

(def-shared-transpiler-macro (js php) =-slot-value (val obj slot)
  (? (quote? slot)
     `(%=-slot-value ,val ,obj ,.slot.)
     `(=-slot-value ,val ,obj ,slot)))
