(fn transpiler-translate-symbol (tr from to)
  (acons! from to (transpiler-symbol-translations tr)))

(fn transpiler-special-char? (x)
  (not (~> (identifier-char?) x)))

(fn global-variable-notation? (x)
  (!= (length x)
    (& (< 2 !)
       (eql (elt x 0) #\*)
       (eql (elt x (-- !)) #\*))))

(fn camel-notation (x &optional (pos 0))
  (with (bump? [& ._
                  (| (& (eql #\- _.)
                        (alpha-char? ._.))
                     (& ._
                        (eql #\* _.)
                        (alpha-char? ._.)
                        (== 0 pos)))])
    (& x
       (? (bump? x)
          (. (char-upcase .x.)
             (camel-notation ..x (++ pos)))
          (. (char-downcase x.)
             (camel-notation .x (++ pos)))))))
 
(fn convert-identifier-r (s)
  (with (corrected-chars
           #'((x pos)
               (with (char-synonym
                        [? (& ._ (eql #\- _.))
                           (… #\_)
                           (. #\_
                              (string-list (print-hexbyte (char-code _.)
                                                          nil)))])
                 (& x
                    (? (| (& (== 0 pos)
                             (digit? x.))
                          (transpiler-special-char? x.))
                       (+ (char-synonym x) (corrected-chars .x (++ pos)))
                       (. x. (corrected-chars .x (++ pos)))))))
         capitals
           [remove #\- (string-list (upcase (subseq _ 1 (-- (length _)))))
                   :test #'character==])
    (? (| (string? s)
          (number? s)
          (character? s))
       (string s)
       (list-string (!= (symbol-name s)
                      (corrected-chars (? (global-variable-notation? !)
                                          (capitals !)
                                          (camel-notation (string-list !)))
                                       0))))))

(fn convert-identifier (s)
  (| (href (identifiers) s)
     (let n (!= (symbol-name (symbol-package s))
              (? (| (eql "TRE" !)
                    (eql "TRE-CORE" !)
                    (eql "COMMON-LISP" !))
                 (convert-identifier-r s)
                 (convert-identifier-r ($ ! "_P_" (symbol-name s)))))
       (awhen (href (converted-identifiers) n)
         (error "Identifier clash: symbol ~A and ~A are both converted to ~A."
                s ! n))
       (= (href (identifiers) s) n)
       (= (href (converted-identifiers) n) s)
       n)))

(fn convert-identifiers (x)
  (maptree [?
             (string? _)
               _
             (| (number? _)
                (character? _))
               (princ _ nil)
             (symbol? _)
               (| (assoc-value _ (symbol-translations) :test #'eq)
                  (convert-identifier _))
             (%string? _)
               (~> (gen-string) ._.)
             (%native? _)
               (convert-identifiers ._)
             (cons? _)
               _
             (error "Cannot translate ~A to string." _)]
           x))
