;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defstruct trecode
  fun
  pos
  (funstack     nil)
  (stack        (make-array 16384))
  (stack-pos    16384)
  (interrupt    nil))

(defun trecode-fetch (tc)
  (prog1
    (aref (trecode-fun tc) (+ 3 (trecode-pos tc)))
    (1+! (trecode-pos tc))))

(defun trecode-get-stack (tc index)
  (aref (trecode-stack tc) index))

(defun trecode-set-stack (tc index value)
  (= (aref (trecode-stack tc) index) value))

(defun trecode-push (tc v)
  (1-! (trecode-stack-pos tc))
  (trecode-set-stack tc (trecode-stack-pos tc) v))

(defun trecode-push-many (tc v)
  (adolist v
    (trecode-push tc !)))

(defun trecode-pop (tc &optional (num 1))
  (-! (trecode-stack tc) num))

(defun trecode-get-closure (tc)
  (with (fun (trecode-fetch tc)
         lex (trecode-get tc))
    (cons '%%closure (cons fun lex))))

(defun trecode-get-args (tc)
  (with-queue q
    (adotimes ((trecode-fetch tc) (queue-list q))
      (enqueue q (trecode-get tc)))))

(defun trecode-get-call (tc fun)
  (apply fun (trecode-get-args tc)))

(defun trecode-function? (tc x))

(defun trecode-get (tc)
  (awhen (trecode-fetch tc)
    (?
      (number? !)              (trecode-get-stack tc !)
      (eq '%quote !)           (trecode-fetch !)
      (eq '%vec !)             (aref (trecode-get tc) (trecode-fetch tc))
      (eq '%closure !)         (trecode-get-closure tc)
      (trecode-function? tc !) (trecode-call tc ! (trecode-get-args tc))
      !)))

(defun trecode-exec-jump (tc)
  (= (trecode-pos tc) (trecode-fetch tc)))

(defun trecode-exec-cond (tc)
  (alet (trecode-fetch tc)
    (unless (trecode-get tc)
      (= (trecode-pos tc) !))))

(defun trecode-exec-set-vec (tc)
    (= (aref (trecode-get tc) (trecode-get tc)) (trecode-get tc)))

(defun trecode-exec-set-place (tc value place)
  (?
    (number? place) (trecode-set-stack tc place value)
    (= (symbol-value place) value)))

(defun trecode-exec-set (tc)
  (trecode-exec-set-place tc (trecode-get tc) (trecode-get tc)))

(defun trecode-exec (tc)
    (loop
      (awhen (trecode-interrupt tc)
        (& (funcall ! tc)
           (return)))
      (case (trecode-fetch tc) :test #'eq
        '%%go      (| (trecode-exec-cond tc)
                      (return))
        '%%go-nil  (trecode-exec-jump tc)
        '%%set-vec (trecode-exec-set-vec tc)
        (trecode-exec-set tc))))

(defun trecode-push-fun (tc fun args num-locals)
  (push (cons fun (cons args num-locals)) (trecode-funstack tc)))

(defun trecode-pop-fun (tc)
  (pop (trecode-funstack tc)))

(defun trecode-call (tc sym args)
  (| (symbol? sym)
     (error "Symbol expected instead of ~A."))
  (let fun (symbol-function sym)
    (| (function? fun)
       (macrop fun)
       (error "No function bound to symbol ~A." sym))
    (| (function-bytecode fun)
       (error "Function ~A has no bytecode." sym))
    (trecode-push-many tc args)
    (let bytecode (function-bytecode fun)
      (| (array? bytecode)
         (error "Bytecode for ~A is not an array." fun))
      (let num-locals (aref bytecode 2)
        (= (trecode-fun tc) bytecode)
        (adotimes num-locals
          (trecode-push tc nil))
        (trecode-push-fun tc fun args num-locals)))))

(defun trecode-return (tc)
  (alet (trecode-pop-fun tc)
    (trecode-pop (+ (length .!.) ..!))))
