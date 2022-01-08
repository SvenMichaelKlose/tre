(defclass timetable ()
  (= _list (make-queue))
  (clr _done?)
  this)

(defmember timetable
  _start-time
  _list
  _done?)

(define-get-alias start-time _start-time :class timetable)

(defmethod timetable done? ()
  _done?)

(defmethod timetable add (duration x)
  (enqueue _list (. duration x))
  this)

(defmethod timetable start ()
  (= _start-time ((new *date).get-time)))

(defmethod timetable update-0 (i ti)
  (? i
     (? (< ti i..)
        ((cdr i.).set (/ (* ti 100) i..))
        (update-0 .i (- ti i..)))
     (= _done? t)))

(defmethod timetable update ()
  (update-0 (queue-list _list) (- (milliseconds-since-1970) _start-time)))

(finalize-class timetable)
