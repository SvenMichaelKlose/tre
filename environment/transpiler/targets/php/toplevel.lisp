;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defvar *php-goto?* t)

(defun php-print-native-environment (out)
  (princ ,(concat-stringtree
              (mapcar (fn let p (+ "environment/transpiler/targets/php/environment/native/" _ ".php")
                           (with-open-file i (open p :direction 'input)
			  	             (read-all-lines i)))
                      '("settings" "character" "cons" "lexical" "funref" "symbol")))
		 out))

(defun php-transpile-prepare (tr &key (import-universe? nil))
  (with-string-stream out
    (when import-universe?
      (transpiler-import-universe tr))
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

(defun php-transpile-decls (tr)
  (transpiler-make-code tr (transpiler-sighten tr (transpiler-compiled-inits tr))))

(defun php-transpile (sources &key (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (let tr *php-transpiler*
    (transpiler-add-defined-variable tr '*KEYWORD-PACKAGE*)
	(string-concat
        "<?php "
		(php-transpile-prepare tr)
    	(target-transpile tr
    	 	:files-before-deps (list (cons 'base1 *php-base*)
				  	                 (cons 'base2 *php-base2*))
		  	:files-after-deps (append (when (eq t *have-environment-tests*)
				   	  	                (list (cons 'env-tests (make-environment-tests))))
                                      sources)
		 	:dep-gen #'(()
				  	     (transpiler-import-from-environment tr))
            :decl-gen #'(()
                          (php-transpile-decls tr))
			:files-to-update files-to-update
            :obfuscate? obfuscate?
			:print-obfuscations? print-obfuscations?)
        "?>")))
