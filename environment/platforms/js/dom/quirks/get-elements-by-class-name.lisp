; tré – Copyright (c) 2010–2012,2014 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate elements class-name)

(defun get-elements-by-class-name-raw-0 (elm cls)
  (?
    (== 9 elm.node-type)
      (get-elements-by-class-name-raw-0 elm.document-element cls)
    (== 1 elm.node-type)
      (let result (make-queue)
        (do-children (i elm (queue-list result))
          (when (string-has-class? i.class-name cls)
            (enqueue result i))
          (@ (j (get-elements-by-class-name-raw-0 i cls))
            (enqueue result j))))))

(defun get-elements-by-class-name-raw (cls)
  (list-array (get-elements-by-class-name-raw-0 this cls)))

(dont-obfuscate iterate-next unshift)

(dont-obfuscate evaluate document-element namespace-u-r-i)

(defun get-elements-by-class-name-eval (elm cls)
  (document.evaluate (+ ".//*[contains(concat(' ', @class, ' '), ' " cls " ')]")
                     elm null 0 null))

(defun get-elements-by-class-name (cls)
  (with (elms (get-elements-by-class-name-eval this cls)
		 ret (make-array))
    (iterate i (elms.iterate-next) (elms.iterate-next) nil
	  (ret.unshift i))))

(unless document.get-elements-by-class-name
  (let fun (? document.evaluate
              #'get-elements-by-class-name
              #'get-elements-by-class-name-raw)
    (= document.get-elements-by-class-name fun
       caroshi-element.prototype.get-elements-by-class-name fun)))
