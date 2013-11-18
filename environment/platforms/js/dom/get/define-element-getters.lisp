;;;;; tré – Copyright (c) 2008–2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-element-getters (&key name (plural-name nil) (class nil) (tag nil) (test nil))
  (| plural-name (= plural-name ($ name 's)))
  (with (loop-decl `(defmacro ,($ 'do- plural-name) ((iter elm &optional (result nil)) &body body))
         continued-loop-decl `(defmacro ,($ 'continued-do- plural-name '-cont) (continuer next iter elm result &body body))
         aos-name ($ 'ancestor-or-self- name)
         type (? class 'class
                 tag   'tag
                 test  'if)
         value (| class tag test))
    `(progn
       (,($ 'def-aos- type) ,aos-name ,@(& test '(nil)) ,value)
       (defun ,($ 'ancestor- name) (x)
         (,aos-name (parent-node x)))
       (defun ,($ 'get- plural-name) (x)
         (,($ 'caroshi-element-get-by- type) x ,value))
       (defun ,($ 'get-first- name) (x)
         (,($ 'caroshi-element-get-first-by- type) x ,value))
       (,@loop-decl
         `(dolist (,,iter (,($ 'caroshi-element-get-by- type) ,,elm ,value) ,,result)
            ,,@body))
       ,(& (| class tag)
           `(,@continued-loop-decl
              `(,($ 'continued-do-by- type '-cont) ,,continuer ,,next ,,iter ,,elm ,value ,,result
                 ,,@body)))
       ,(& test
           `(,@continued-loop-decl
              `(continued-dolist-cont ,,continuer ,,next
                                      ,,iter (caroshi-element-get-if ,,elm ,value) ,,result
                 ,,@body)))
       (defun ,($ 'map- plural-name) (fun elm)
         (mapcar fun (,($ 'caroshi-element-get-by- type) elm ,value)))
        ,@(mapcan (fn with (fun-name ($ _. '- name)
                            dom-if ($ 'dom- ._ '-if))
                       `((defun ,fun-name (x)
                           (,dom-if ,(?
                                       class `(fn _.has-class? ,value)
                                       tag   `(fn _.has-tag-name? ,value)
                                       test  value)
                                    x))))
                  '((previous . backward)
                    (next . forward))))))
