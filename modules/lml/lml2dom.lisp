,(progn
   (var *have-lml-components?* nil)
   nil)

(fn lml2dom-element (x doc)
  (make-extended-element (downcase (string x.)) :doc doc))

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
        (funcall (lml2dom-exec-function x) name (lml2dom-exec-param x) elm !))
    (keyword? x)
      (list-string (camel-notation (string-list (symbol-name x))))
    x))

(fn lml2dom-attr (elm x doc)
  (let name (lml-attr-string x.)
    (elm.write-attribute name (string (lml2dom-attr-exec elm name .x.)))
    (lml2dom-attr-or-body elm ..x doc)))

(fn lml2dom-attr-or-body (e x doc)
  (? (lml-attr? x)
     (lml2dom-attr e x doc)
     (lml2dom-body e x doc)))

(fn lml2dom-exec (parent x doc)
  (& ...x
     (error "%EXEC expects a single child only."))
  (aprog1 (lml2dom ..x. :doc doc :parent parent)
    (funcall (lml2dom-exec-function x) parent !)))

(fn lml2dom-expr (parent x doc)
  (| (atom x.)
     (lml2xml-error-tagname x))
  (? (%exec? x)
     (lml2dom-exec parent x doc)
     (progn
       ,(& *have-lml-components?*
           '(when (lml-component-name? x.)
              (with (attrs     (%%%make-object)
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
                (!= (make-lml-component x. attrs)
                  (& parent
                     (parent.add !))
                  (return-from lml2dom-expr !)))))
       (let e (lml2dom-element x doc)
         (& parent
            (parent.add e))
         (lml2dom-attr-or-body e .x doc)
         e))))

(fn lml2dom (x &key (parent nil) (doc document))
  (? (cons? x)
     (lml2dom-expr parent x doc)
     (lml2dom-atom parent x doc)))
