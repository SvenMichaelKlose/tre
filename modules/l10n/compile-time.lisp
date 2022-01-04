(var *compile-time-l10ns* (make-hash-table :test #'eq))
(var *used-l10ns* (make-hash-table :test #'eq))
(var *l10n-package* nil)

(@ (i *available-languages*)
  (= (href *compile-time-l10ns* i) (make-hash-table :test #'eq)))

(defmacro in-l10n (package)
  (print-definition `(in-l10n ,package))
  (= *l10n-package* (make-keyword package))
  nil)

(fn packaged-l10n-id (x)
  (make-keyword ($ *l10n-package* "-" x)))

(fn check-l10ns ()
  (@ (i *available-languages*)
    (let other-languages (remove i *available-languages*)
      (@ (j (hashkeys (href *compile-time-l10ns* i)))
        (@ (o other-languages)
          (unless (href (href *compile-time-l10ns* o) j)
            (format t "; L10n ~A missing in ~A.~%" j o))))))
  (awhen (remove-if [href *used-l10ns* _]
                    (hashkeys (href *compile-time-l10ns* *fallback-language*)))
    (format t "Unused L10ns:~%~A" !)))
