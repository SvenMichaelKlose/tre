; tré – Copyright (c) 2005–2015 Sven Michael Klose <pixel@hugbox.org>

; TODO: Enable QUASIQUOTE in dotted pairs like `(foo . ,bar).
; TODO: Get rid of TREE-WALK.
(defun tree-walk (i &key (ascending nil) (dont-ascend-if nil) (dont-ascend-after-if nil))
  (? (atom i)
	 (funcall ascending i)
     (progn
	   (with (y i.
		      a (| (& dont-ascend-if (funcall dont-ascend-if y) y)
				   (? (& dont-ascend-after-if (funcall dont-ascend-after-if y))
					  (funcall ascending y)
	  			      (tree-walk (? ascending
					 	 		    (funcall ascending y)
					 	 		    y)
					 		     :ascending ascending
					 		     :dont-ascend-if dont-ascend-if
					 		     :dont-ascend-after-if dont-ascend-after-if))))
        (listprop-cons i a
                         (tree-walk .i :ascending ascending
						               :dont-ascend-if dont-ascend-if
						               :dont-ascend-after-if dont-ascend-after-if))))))

(defun quote-expand (x)
  (with (atomic [? (constant-literal? _)
                   _
                   `(quote ,_)]
         static [? (atom _)
                   (atomic _)
                   `(. ,(static _.)
                       ,(static ._))]
         qq     [? (any-quasiquote? (cadr _.))
                   `(. ,(backq (cadr _.))
                       ,(backq ._))
                   `(. ,(cadr _.)
                       ,(backq ._))]
         qqs    [? (any-quasiquote? (cadr _.))
                   (error "Illegal ~A as argument to ,@ (QUASIQUOTE-SPLICE)."
                          (cadr _.))
                   `(append ,(cadr _.) ,(backq ._))]
         backq  [?
                  (atom _)             (atomic _)
                  (pcase _.
                    atom               `(. ,(atomic _.)
                                           ,(backq ._))
                    quasiquote?        (qq _)
                    quasiquote-splice? (qqs _)
                    `(. ,(backq _.)
                        ,(backq ._)))]
         disp   [pcase _
                  quote?     (static ._.)
                  backquote? (backq ._.)
                  _])
    (car (tree-walk (list x) :ascending #'disp))))
