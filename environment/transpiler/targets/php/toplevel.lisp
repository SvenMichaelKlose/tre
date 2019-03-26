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

(defun php-sections-before-deps (tr)
  `((base0 . ,*php-base0*)
    ,@(& (not (transpiler-exclude-base? tr))
         `((base1 . ,*php-base*)))))

(defun php-sections-after-deps (tr)
  (+ (& (not (transpiler-exclude-base? tr))
        `((base2 . ,*php-base2*)))
     (& (eq t *have-environment-tests*)
        (list (cons 'env-tests (make-environment-tests))))))
