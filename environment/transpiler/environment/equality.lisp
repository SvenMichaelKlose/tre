(fn eql (a b)
  (| a (setq a nil))
  (| b (setq b nil))
  (| (eq a b)
     (?
       (& (number? a)
          (number? b))      (== a b)
       (& (string? a)
          (string? b))      (string== a b)
       (& (character? a)
          (character? b))   (character== a b))))

(defmacro eql (a b)
  (?
    (| (string? a)
       (string? b))          `(string== ,a ,b)
    (| (literal-symbol? a)
       (literal-symbol? b))  `(eq ,a ,b)
    `(eql ,a ,b)))
