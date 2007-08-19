;;;;; nix list processor
;;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defstruct cblock
  code  ; Expression list.
  conditional-follower   ; Conditional next block.
  follower)    ; Unconditional next block.

;;;; Pass 1: Make blocks of SSAs. Tags initiate new blocks.

;;; Tags associated with blocks.
(defvar *tags-cblocks*)

(defun add-tags (b tags)
  (dolist (x tags)
    (acons! x b *tags-cblocks*)))

(defun tag-cblock (tag)
  (assoc tag *tags-cblocks*))

(defun split-tags-rest (l)
  "Split initial tags and rest of expressions."
  (split-if #'consp l))

(defun tree-expand-body (l)
  "Split expression list after jumps and before tags."
  (with (brk nil)
    (split-if #'((x)
                  (if (or brk (atom x))
                      t
                      (when (vm-jump? x)
                        (setf brk t)
                        nil)))
              l)))

(defun clean-code (l)
  "Remove %SETQs."
  (mapcar #'((x)
              (if (consp x)
                  (case (car x)
                    ('%setq (cdr x))
                    (t x))
                  x))
          (remove-if #'((x)
                         (and (consp x)
                              (eq (car x) 'identity)))
                     l)))

(defun tree-expand-new-block (l)
  "Make a list of CBLOCKs from expression list. Returns first block."
  (when l
    (with ((tags rest) (split-tags-rest l)
           (expr rest) (tree-expand-body rest)
           b (make-cblock :code (clean-code expr)
                          :follower (tree-expand-new-block rest)))
      (add-tags b tags)
      b)))

(defun tree-expand-make-cblocks (l)
  (setf *tags-cblocks* nil)
  (tree-expand-new-block l))

;;;; Pass 2:
;;;;
;;;; Convert the straight list of CBLOCKs to a network by analyzing jumps
;;;; at CBLOCK ends and setting CBLOCK-CONDITIONAL-FOLLOWER and
;;;; CBLOCK-FOLLOWER correctly.

(defun set-follower (b l)
  (setf (cblock-follower b) (tag-cblock (second l))))

(defun set-cond-follower (b l)
  (setf (cblock-conditional-follower b) (tag-cblock (second l))))

(defvar *traced-cblocks* nil)

(defmacro with-tracer (var lst &rest body)
   "Evaluate body if 'var' is not 'lst' and add it, or do NIL."
  `(when (and ,var (not (member ,var ,lst))
     (push ,var ,lst)
     ,@body)))

(defun link-cblocks! (b)
  (with-tracer b *traced-cblocks*
    (with (l (car (last (cblock-code b))))
      (if (vm-jump? l)
          (progn
            (if (vm-go? l)
                (set-follower b l)
                (if (vm-go-nil? l)
                    (set-cond-follower b l)
                    (error "VM-GO-NIL expected")))
            (setf (cblock-code b) (butlast (cblock-code b)))
            (link-cblocks! (cblock-follower b)))
          (link-cblocks! (cblock-follower b))))))

; ^ - value
; ! - form

;;;; Pass 3: Make code single.
;;;; 
;;;; For each block make mapping of input to unique symbols. Then,
;;;; map each further assignment to that symbol the same way.
;;;; Finally, make a mapping back to the symbol again, to describe
;;;; the output of the block.

(defun vplace? (x))

(defun treex-rename (fi p)
  (destructuring-bind (fi)
    (with-gensym g
      (unless (assoc p input-map)
        (setf (assoc p input-map) g))
      (setf (assoc p output-map) g))))

(defun treex-rename-vplaces (fi e)
  (destructuring-bind (fi)
    (when (vplace? !(car e))
      (setf ! (assoc ! output-map)))
    (treex-rename-vplaces fi (cdr e))))

(defun tree-ex-make-single! (fi)
  (destructuring-bind (fi)
    (dolist (e assignments)
      (treex-rename-vplaces fi (cdr e))
      (when (vplace? ^(car e))
	(treex-rename fi ^)))))

;;;; Pass 4: Create special nodes for joins and loops.

(defun tree-ex-join (fi)
  (dolist (target (cblock-targets origin))
    (unless (already-merged target)
      (mark-as-merged target)
      (dolist (out (cblock-outputs origin))
        (when (is-input-of target out)
          (insert-merge-node target out))))))

;;;; Toplevel

(defun tree-expand (fi l)
  (setf *traced-cblocks* nil)
  (with (b (tree-expand-make-cblocks l))
    (link-cblocks! b)
    (setf (funinfo-first-cblock fi) b)))

(defun tree-expand-reset ()
  (setf *tags-cblocks* nil))
