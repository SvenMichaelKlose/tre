(defmacro square (&body body)
  `#'(,(? (eql 0 body.)
          (progn
            (setq body .body)
            nil)
          '(_))
        (block nil
          ,@(? (& (cons? body.)
                  (not (eq 'slot-value body..)
                       (eq '%slot-value body..)))
               body
               (list body)))))
