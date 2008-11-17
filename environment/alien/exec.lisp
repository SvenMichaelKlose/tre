;;;;; TRE processor environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Program execution.

(defconstant *c-nl* (string (code-char 10)))

(defun fork ()
  "Create process copy. Returns the new process-ID to the calling process.
Returns 0 to the new process."
  (with (libc		(alien-dlopen *LIBC-PATH*))
	(prog1
	  (alien-call (alien-dlsym libc "fork"))
      (alien-dlclose libc))))

(defun wait ()
  "Waits until a child process exits.
Return a status integer. See UNIX man page wait (2)."
  (with (libc	(alien-dlopen *LIBC-PATH*)
	     fun	(alien-dlsym libc "wait")
		 status (%malloc *POINTER-SIZE*))

    (with (cc (make-c-call :funptr fun))
      (c-call-add-arg cc status)
      (c-call-do cc)
      (alien-dlclose libc))

	(prog1
	  (%get-dword status)
	  (%free status))))

(defun execve (path (&rest args) &optional (environment nil))
  "Overlays current process with a new program at 'path'.
'args' is a list of argument strings. Keep in mind that the first argument
entry is usually the path to the executable.
'environment' may be an associative list of variable/value string pairs.
Returns NIL."
  (with (libc		(alien-dlopen *LIBC-PATH*)
         cexecve	(alien-dlsym libc "execve")
         cperror	(alien-dlsym libc "perror")
		 cpath		(%malloc-string path :null-terminated t)
		 argptrs	(mapcar #'((x)
								 (%malloc-string x :null-terminated t))
						    args)
		 argv		(%malloc (* *POINTER-SIZE* (1+ (length args))))
		 environv   (if environment
		 			    (%malloc (* *POINTER-SIZE* (1+ (length environment))))
						0)
		 envptrs	(when environment
					  (mapcar #'((x)
								   (%malloc-string (string-concat (car x) "=" (cdr x))
												   :null-terminated t))
						      environment)))

	(%put-pointer-list argv argptrs :null-terminated t)
	(when environment
	  (%put-pointer-list environv envptrs :null-terminated t))

	(when (= 0 (fork))
      (with (cc (make-c-call :funptr cexecve))
        (c-call-add-arg cc cpath)
        (c-call-add-arg cc argv)
        (c-call-add-arg cc environv)
        (c-call-do cc)
	    (print 'execve-error)
	    (quit)))

    (%free-list argptrs)
    (%free cpath)
    (%free argv)

	(when environment
      (%free-list envptrs)
	  (%free environv))

    (alien-dlclose libc)
	nil))

; XXX
;(execve "/usr/bin/mplayer" ("/usr/bin/mplayer", "-quiet", "test.mp3"))
;(execve "/bin/mkdir" ("/bin/mkdir", "new_dir"))
;(wait)
