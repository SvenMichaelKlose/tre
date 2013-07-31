;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *php-goto?* t) ; PHP version <5.3 has no 'goto'.

(defun php-prologue ()
  (+ (format nil "<?php // tré revision ~A~%" *tre-revision*)
     (? *php-goto?*
        ""
        "$_I_ = 0; while (1) { switch ($_I_) { case 0:")))

(defun php-epilogue ()
  (+ (? *php-goto?*
        ""
        "} break; }")
     "?>"))

(defvar *php-native-environment*
        ,(apply #'+ (mapcar [fetch-file (+ "environment/transpiler/targets/php/environment/native/" _ ".php")]
                            '("settings" "error" "character" "cons" "lexical" "closure" "symbol" "array"))))

(defun php-print-native-environment (out)
  (princ *php-native-environment* out))

(defun php-prepare (tr)
  (with-string-stream out
    (format out (+ "mb_internal_encoding ('UTF-8');~%"
                   "if (get_magic_quotes_gpc ()) {~%"
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

(defun php-decls (tr)
  (transpiler-make-code tr (transpiler-frontend tr (transpiler-compiled-inits tr))))

(defun php-transpile (sources &key (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (with-temporary *opt-inline-max-size* 16
    (transpiler-add-defined-variable transpiler '*KEYWORD-PACKAGE*)
    (+ (php-prologue)
	   (php-prepare transpiler)
   	   (target-transpile transpiler
           :decl-gen #'(()
                          (php-decls transpiler))
           :files-before-deps `((base1 . ,*php-base*))
           :files-after-deps (+ `((base2 . ,*php-base2*))
                                (& (eq t *have-environment-tests*)
                                   (list (cons 'env-tests (make-environment-tests))))
                                sources)
           :files-to-update files-to-update
           :obfuscate? obfuscate?
           :print-obfuscations? print-obfuscations?)
   (php-epilogue))))
