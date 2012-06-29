;;;; nix operating system project
;;;; lisp compiler
;;;; (c) 2005,2011 Sven Klose <pixel@copei.de>
;;;;
;;;; Tree transformation
;;;;
;;;; This is a pattern matching and substitution tool.
;;;;
;;;; Tree transformations are defined with DEFINE-TREE-TRANSFORM which is
;;;; a convenient way to set a variable to a new TREE-TRANSFORM structure.
;;;; It requires four arguments: the name of the variable that whill
;;;; hold the tree transformation, a list of placeholder symbols, a matching
;;;; form and an expression describing the transformation.
;;;;
;;;; Placeholders are symbols used to mark and copy parts of expressions in
;;;; the transformation process.
;;;;
;;;; The matching pattern must be a quoted list to circumvent its
;;;; evaluation. It is a list or tree that is matched atom wise.
;;;;
;;;; If a symbol in the expression matches a placeholder, the element
;;;; is stored with the placeholder and matching is continued.
;;;; Some special symbols instruct the matching algorithm to test on
;;;; special cases:
;;;;
;;;;     *rest name	Rest of list. An error is issued if something
;;;;			follows the placeholder 'name'.
;;;;     *any           Marks end of match.
;;;;
;;;; The conversion is a LISP expression which is evaluated after a complete
;;;; match. Placeholders are provided as variables.
;;;;
;;;;     (define-tree-transform progn-fold
;;;;       '(x1)                         
;;;;       '((progn x1) *any)
;;;;       `(,@x1))

(defvar *tree-transforms*)

(defstruct tree-transform
  compiled-match
  placeholders
  match
  conversion
  clips)

(defmacro define-tree-transform (name placeholders match conversion)
  `(progn
    (setq ,name
      (make-tree-transform :placeholders ,placeholders
                           :match ,match
			   :conversion #'((&key ,@(cadr placeholders))
					 ,conversion)))
    (tree-transform-compile ,name)))

(defun tree-transform-conversion-args (trn)
  "Make key argument list for call to conversion function."
  (let args (make-queue)
    ; Make list of keyword/value pairs.
    (dolist (i (tree-transform-placeholders trn) (queue-list args))
      (enqueue args (list (intern (symbol-name i) "") (assoc i (tree-transform-clips trn)))))))

(defun tree-transform-compile-r (match trn)
  "Match tree-transform against expression and return first toplevel cons after
   match."
  ; Match cons.
  (let form (make-queue)
    (do ((m match (cdr m)))
        ((endp m) (queue-list form))
      (let mcar (car m)
        (cond
          ((eq mcar '*rest)	; Rest of current list.
            (enqueue form
              `(progn
                 (push (cons ',(cadr m) e) (tree-transform-clips trn))
                 (return t)))
            (return-from tree-transform-compile-r (queue-list form)))

          ; Take element if match is a placeholder.
          ((member mcar (tree-transform-placeholders trn))
            (enqueue form `(push (cons ',mcar (car e)) (tree-transform-clips trn))))

          (t
            ; If any of the elements is a cons, the match fails.
            (? (cons? mcar)
              (awhen (tree-transform-compile-r mcar trn)
                (enqueue form '(cons? (car e)))
                (enqueue form `(#'((e) (block nil (& ,@!))) (car e))))
              (? (number? mcar)
                (enqueue form `(== (car e) ,mcar))
                (enqueue form `(eq (car e) ',mcar))))))

        ; If next is an any match, return its first element or T.
        (when (& (cdr m) (eq (cadr m) '*any))
          (enqueue form '(? (cdr e) (cdr e) t))
          (return-from tree-transform-compile-r (queue-list form)))

        ; Return T if end of lists match.
        (? (not (cdr m))
          (progn
            (enqueue form '(not (cdr e)))
            (return-from tree-transform-compile-r (queue-list form)))
          (enqueue form '(setq e (cdr e))))))))

(defun tree-transform-compile (trn)
  "Match a pattern and return first toplevel cons after match."
  (= (tree-transform-clips trn) nil)
  (let form (tree-transform-compile-r (tree-transform-match trn) trn)
    (= (tree-transform-compiled-match trn)
      (eval (macroexpand `#'((e trn)
        (& ,@form)))))))

(defun tree-transform! (trn e)
  (when (cons? e)
    (= (tree-transform-clips trn) nil)
    ; If expression matches, get toplevel cons after match.
    (awhen (funcall (tree-transform-compiled-match trn) e trn)
      ; Get arguments to conversion function and call the conversion function.
      (let* ((a (tree-transform-conversion-args trn))
             (c (apply (tree-transform-conversion trn) (apply #'nconc a))))
        (& ! (not (eq ! t))	; Append rest to conversion.
           (= c (nconc c !)))
        (rplac-cons e c)	; Replace expression by conversion.
        expr))))
