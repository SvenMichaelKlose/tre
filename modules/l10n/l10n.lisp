(var *l10ns* (make-hash-table :test #'eq))
(var *l10n-package* nil)
,(unless (transpiler-defined-variable *transpiler* '*l10n-text-filter*)
   '(var *l10n-text-filter* #'identity))

(@ (i *available-languages*)
  (= (href *l10ns* (make-keyword i)) (make-hash-table :test #'eq)))

(defmacro def-l10n (lang id args &body body)
  (= lang (make-keyword lang))
  (= id (make-keyword id))
  (print-definition `(def-l10n ,lang ,id))
  (| *l10n-package*
     (error "*L10N-PACKAGE* is unset. Use macro IN-L10N-PACKAGE."))
  (| (href *compile-time-l10ns* lang)
     (error "Language ~A is not defined. Available languages: ~A"
            lang (hashkeys *compile-time-l10ns*)))
  (!= (packaged-l10n-id id)
    (& (href (href *compile-time-l10ns* lang) !)
       (error "Localisation ~A ~A is already defined." lang !))
    (= (href (href *compile-time-l10ns* lang) !) (list args))
    (& (not (eq lang :en))
       (not (href (href *compile-time-l10ns* :en) !))
       (error "Localisation ~A ~A is not in EN." lang !))
    `(= (href (href *l10ns* ',lang) ',!) #'(,args ,@body))))

(fn get-localiser (id)
  (href (href *l10ns* *language*) (make-keyword id)))

(fn call-localiser (id &rest args)
  (funcall *l10n-text-filter* (apply (get-localiser id) args)))

(defmacro l10n (id &rest args)
  (= id (make-keyword id))
  (| *l10n-package*
     (error "*L10N-PACKAGE* is unset. Use macro IN-L10N-PACKAGE."))
  (| (href (href *compile-time-l10ns* :en) (packaged-l10n-id id))
     (error "Localisation ~A is not defined." id))
  (!= (packaged-l10n-id id)
    (= (href *used-l10ns* !) t)
    `(call-localiser ',! ,@args)))
