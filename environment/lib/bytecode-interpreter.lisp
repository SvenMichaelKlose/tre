;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>
;;;;;
;;;;; Non–recursive bytecode interpreter.

(defstruct process
  fun
  pos
  (funstack     nil)
  (stack        (make-array 16384))
  (stack-pos    16384)
  (interrupt    nil)
  (microstack   nil)
  (retvals      nil))

(defun process-fetch (tc)
  (prog1
    (aref (process-fun tc) (process-pos tc))
    (1+! (process-pos tc))))

(defun process-get-stack (tc index)
  (aref (process-stack tc) index))

(defun process-set-stack (tc index value)
  (= (aref (process-stack tc) index) value))

(defun process-push (tc v)
  (1-! (process-stack-pos tc))
  (process-set-stack tc (process-stack-pos tc) v))

(defun process-push-many (tc v)
  (adolist v
    (process-push tc !)))

(defun process-push-nil (tc num)
  (adotimes num
     (process-push tc nil)))

(defun process-pop (tc &optional (num 1))
  (-! (process-stack tc) num))

(defun process-push-microstack (tc fun)
  (push fun (process-microstack tc)))

(defun process-pop-microstack (tc)
  (pop (process-microstack tc)))

(defun process-get-closure (tc)
  (with (fun (process-fetch tc)
         lex (process-get tc))
    (cons '%%closure (cons fun lex))))

(defun process-fetch-args (tc)
  (with-queue q
    (adotimes ((process-fetch tc) (queue-list q))
      (enqueue q (process-get tc)))))

(defun process-get-call (tc fun)
  (apply fun (process-fetch-args tc)))

(defun process-function? (tc x))

(defun process-get (tc &key (call? nil))
  (awhen (process-fetch tc)
    (?
      (not !)                  nil
      (eq t !)                 t
      (number? !)              (process-get-stack tc !)
      (eq '%quote !)           (process-fetch !)
      (eq '%vec !)             (aref (process-get tc) (process-get tc))
      (eq '%closure !)         (process-get-closure tc)
      call?                    (process-call tc ! (process-fetch-args tc))
      (error "Illegal bytecode."))))

(defun process-exec-jump (tc)
  (= (process-pos tc) (+ 3 (process-fetch tc))))

(defun process-exec-cond (tc)
  (alet (process-fetch tc)
    (unless (process-get tc)
      (= (process-pos tc) (+ 3 !)))))

(defun process-exec-set-vec (tc)
    (= (aref (process-get tc) (process-get tc)) (process-get tc)))

(defun process-exec-set-place (tc value place)
  (?
    (number? place) (process-set-stack tc place value)
    (= (symbol-value place) value)))

(defun process-exec-set (tc)
  (process-exec-set-place tc (process-get tc :call? t) (process-get tc)))

(defun process-exec (tc)
  (loop
    (awhen (process-interrupt tc)
      (& (funcall ! tc)
         (return)))
    (!? (pop (process-microstack tc))
        (funcall ! tc)
        (case (process-fetch tc) :test #'eq
          '%%go      (process-exec-jump tc)
          '%%go-nil  (| (process-exec-cond tc)
                        (return))
          '%%set-vec (process-exec-set-vec tc)
          (process-exec-set tc)))))

(defun process-push-fun (tc fun args num-locals)
  (push (cons fun (cons args num-locals)) (process-funstack tc)))

(defun process-pop-fun (tc)
  (pop (process-funstack tc)))

(defun process-call (tc sym args)
  (| (symbol? sym)
     (error "Symbol expected instead of ~A."))
  (let fun (symbol-function sym)
    (| (function? fun)
       (macro? fun)
       (error "No function bound to symbol ~A." sym))
    (| (function-bytecode fun)
       (error "Function ~A has no bytecode." sym))
    (process-push-many tc args)
    (let bytecode (function-bytecode fun)
      (| (array? bytecode)
         (error "Bytecode for ~A is not an array." fun))
      (let num-locals (aref bytecode 2)
        (= (process-fun tc) bytecode)
        (process-push-nil tc num-locals)
        (process-push-fun tc fun args num-locals)))))

(defun process-return (tc)
  (alet (process-pop-fun tc)
    (process-pop (+ (length .!.) ..!))))
