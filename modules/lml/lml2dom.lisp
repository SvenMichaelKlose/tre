(fn lml2dom-element (x doc)
  (element-extend (doc.create-element (downcase (string x.)))))

(fn lml2dom-atom (parent x doc)
  (when x
    (!= (? (| (string? x)
              (number? x))
           (new *text-node (string x) :doc doc)
           x)
      (? parent
         (parent.add !)
         !))))

(fn lml2dom-body (parent x doc)
  (@ (i x)
    (lml2dom i :doc doc :parent parent)))

(fn lml2dom-exec-function (x)
  (!= .x.
    (? (function? !)
       !
       (symbol-function !))))

(fn lml2dom-attr-exec (elm name x)
  (?
    (%exec? x)
      (aprog1 ...x.
        (~> (lml2dom-exec-function x) name (lml2dom-exec-param x) elm !))
    (keyword? x)
      (list-string (camel-notation (string-list (symbol-name x))))
    x))

(fn lml2dom-attr (elm x doc)
  (let name (lml-attr-string x.)
    (elm.attr name (string (lml2dom-attr-exec elm name .x.)))
    (lml2dom-attr-or-body elm ..x doc)))

(fn lml2dom-attr-or-body (e x doc)
  (? (lml-attr? x)
     (lml2dom-attr e x doc)
     (lml2dom-body e x doc)))

(fn lml2dom-exec (parent x doc)
  (when ...x
    (error "%EXEC expects a single child only."))
  (aprog1 (lml2dom ..x. :doc doc :parent parent)
    (~> (lml2dom-exec-function x) parent !)))

(fn lml2dom-expr-component (parent x doc)
  (with (attrs     (%make-json-object)
         children  nil
         f  [& _
               (? (lml-attr? _)
                  (progn
                    (=-%aref (? (keyword? ._.)
                                (list-string (camel-notation (string-list (symbol-name ._.))))
                                ._.)
                             attrs (lml-attr-string _.))
                    (f .._))
                  (= children (@ [lml2dom _ :doc doc] _)))])
    (f .x)
    (=-%aref children attrs "children")
    (aprog1 (make-lml-component x. attrs)
      (when parent
        (parent.add !)))))

(fn lml2dom-expr (parent x doc)
  (?
    (cons? x.)
      (lml2xml-error-tagname x)
    (%exec? x)
      (lml2dom-exec parent x doc)
    (progn
      (? (& (function? (symbol-function 'lml-component))
            (lml-component-name? x.))
         (awhen (lml2dom-expr-component parent x doc)
           (return-from lml2dom-expr !)))
      (aprog1 (lml2dom-element x doc)
        (when parent
          (parent.add !))
        (lml2dom-attr-or-body ! .x doc)))))

(fn lml2dom (x &key (parent nil) (doc document))
  (? (cons? x)
     (lml2dom-expr parent x doc)
     (lml2dom-atom parent x doc)))
