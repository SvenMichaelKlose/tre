;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun unassigned-%stackarg? (x)
  (& (%stackarg? x) ..x))

(defun unassigned-%stack? (x)
  (& (%stack? x) ..x))

(defun unassigned-%vec? (x)
  (& (%vec? x) ...x))

(defun unassigned-%set-vec? (x)
  (& (%set-vec? x) ....x))

(defun place-assign-error (x v)
  (error "can't assign place because the find index in lexicals for ~A in ~A.~%" v x))

(defun place-assign-stackarg (x)
  (let fi (get-funinfo-by-sym .x.)
    (? (transpiler-arguments-on-stack? *current-transpiler*)
       (+ (length (funinfo-env fi)) (funinfo-arg-pos fi ..x.))
       (error "cannot assign stack argument ~A" ..x.))))

(define-tree-filter place-assign (x)
  (| (%quote? x)
     (%transpiler-native? x)) x
  (unassigned-%stackarg? x)    `(%stack ,(place-assign-stackarg (print x)))
  (unassigned-%stack? x)       `(%stack ,(| (funinfosym-env-pos .x. ..x.)
                                            (place-assign-stackarg x)))
  (unassigned-%vec? x)         `(%vec ,(place-assign .x.)
		                              ,(| (funinfosym-lexical-pos ..x. ...x.)
                                          (place-assign-error x ...x.)))
  (unassigned-%set-vec? x)     `(%set-vec ,(place-assign .x.)
		                                  ,(| (funinfosym-lexical-pos ..x. ...x.)
                                              (place-assign-error x ...x.))
                                          ,(place-assign ....x.))
  (lambda? x)                  (copy-lambda x :body (place-assign (lambda-body x)))
  (%slot-value? x)             `(%slot-value ,(place-assign .x.) ,..x.))
