; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defvar *php-native-environment*
        ,(apply #'+ (mapcar [fetch-file (+ "environment/transpiler/targets/php/environment/native/" _ ".php")]
                            '("settings" "error" "character" "cons" "lexical" "closure" "symbol" "array"))))

(defun php-print-native-environment (out)
  (princ *php-native-environment* out))

(defun php-prologue ()
  (with-string-stream out
    (format out "<?php // tré revision ~A~%" *tre-revision*)
    (format out (+ "if (get_magic_quotes_gpc ()) {~%"
                   "    $vars = array (&$_GET, &$_POST, &$_COOKIE, &$_REQUEST);~%"
                   "    while (list ($key, $val) = each ($vars)) {~%"
                   "        foreach ($val as $k => $v) {~%"
                   "            unset ($vars[$key][$k]);~%"
                   "            $sk = stripslashes ($k);~%"
                   "            if (is_array ($v)) {~%"
                   "                $vars[$key][$sk] = $v;~%"
                   "                $vars[] = &$vars[$key][$sk];~%"
                   "            } else~%"
                   "                $vars[$key][$sk] = stripslashes ($v);~%"
                   "        }~%"
                   "    }~%"
                   "    unset ($vars);~%"
                   "}~%"))
    (php-print-native-environment out)))

(defun php-epilogue ()
  (format nil "?>~%"))

(defun php-decl-gen ()
  (backend (middleend (frontend (compiled-inits)))))

(defun php-frontend-init ()
  (add-defined-variable '*keyword-package*))

(defun php-sections-before-deps ()
  `((base0 . ,*php-base0*)
    ,@(& (not (exclude-base?))
         `((base1 . ,*php-base*)))))

(defun php-sections-after-deps ()
  (+ (& (not (texclude-base?))
        `((base2 . ,*php-base2*)))
     (& (eq t *have-environment-tests*)
        (list (cons 'env-tests (make-environment-tests))))))

(defun php-identifier-char? (x)
  (unless (== #\$ x)
    (c-identifier-char? x)))

(defun php-expex-initializer (ex)
  (= (expex-inline? ex)         #'%slot-value?
     (expex-setter-filter ex)   (compose [mapcar #'php-setter-filter _]
                                         #'expex-compiled-funcall)
     (expex-argument-filter ex) #'php-argument-filter))

(defun make-php-transpiler-0 ()
  (create-transpiler
      :name                     'php
      :frontend-init            #'php-frontend-init
      :prologue-gen             #'php-prologue
      :epilogue-gen             #'php-epilogue
      :decl-gen                 #'php-decl-gen
      :sections-before-deps     #'php-sections-before-deps
      :sections-after-deps      #'php-sections-after-deps
      :lambda-export?           t
      :stack-locals?            nil
      :gen-string               [literal-string _ #\" (list #\$)]
	  :identifier-char?         #'php-identifier-char?
      :literal-converter        #'expand-literal-characters
      :expex-initializer        #'php-expex-initializer))

(defun make-php-transpiler ()
  (aprog1 (make-php-transpiler-0)
    (transpiler-add-defined-function ! '%cons '(a d) nil)
    (transpiler-add-defined-function ! 'phphash-hash-table '(x) nil)
    (transpiler-add-defined-function ! 'phphash-hashkeys '(x) nil)
    (transpiler-add-plain-arg-funs ! *builtins*)))

(defvar *php-transpiler* (copy-transpiler (make-php-transpiler)))
(defvar *php-newline*    (format nil "~%"))
(defvar *php-separator*  (format nil ";~%"))
(defvar *php-indent*     "    ")
