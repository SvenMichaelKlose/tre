;;;; Expression to DOM

(fn expr2dom-type (x)
  (?
    (number? x)  (values "f" (string x))
    (string? x)  (values "s" x)
    (values "n" (symbol-name x))))

(fn expr2dom-pair (parent e x document)
  (e.set-attribute "c" "")
  (expr2dom-atom parent x document))

(fn expr2dom-seq (parent name x document)
  (aprog1 (document.create-element name)
    (while x nil
      (let e (expr2dom ! x. document)
        (? (& .x (atom .x))
           (return (expr2dom-pair ! e .x document))))
      (= x .x))
    (parent.append-child !)))

(fn expr2dom-atom (parent x document)
  (?
    (json-object? x)
      (expr2dom-seq parent "aa" (props-alist x) document)
    (array? x)
      (expr2dom-seq parent "a" (array-list x) document)
    (with ((type content) (expr2dom-type x))
      (aprog1 (document.create-element type)
        (& (eql "n" type)
           (keyword? x)
           (!.set-attribute "k" ""))
        (!.append-child (document.create-text-node content))
        (parent.append-child !)))))

(fn expr2dom (parent x &optional (document document))
  (? (atom x)
     (expr2dom-atom parent x document)
     (expr2dom-seq parent "l" x document)))


;;;; DOM to expression

(fn dom2expr-list (x)
  (& x
     (. (dom2expr x)
        (? (x.has-attribute "c")
           (dom2expr x.next-sibling)
           (dom2expr-list x.next-sibling)))))

(fn dom2expr-array (x)
  (list-array (dom2expr-list x.first-child)))

(fn dom2expr (x)
  (alet x.text-content
    (case (downcase x.tag-name) :test #'string==
      "l"  (dom2expr-list x.first-child)
      "a"  (dom2expr-array x)
      "aa" (alist-props (dom2expr-list x.first-child))
      "f"  (number !)
      "s"  !
      (let pack (& (x.has-attribute "k")
                   *keyword-package*)
        (unless (& pack (eql "NIL" !))
          (make-symbol ! pack))))))
