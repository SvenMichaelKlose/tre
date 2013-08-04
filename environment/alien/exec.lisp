;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun fork ()
  (alet (alien-dlopen *libc-path*)
	(prog1
	  (alien-call (alien-dlsym ! "fork"))
      (alien-dlclose !))))

(defun wait ()
  (with (libc	(alien-dlopen *libc-path*)
	     fun	(alien-dlsym libc "wait")
		 status (%malloc *pointer-size*))
    (alet (make-c-call :funptr fun)
      (c-call-add-arg ! status)
      (c-call-do !)
      (alien-dlclose libc))
	(prog1
	  (%get-dword status)
	  (%free status))))

(defun execve (path args &optional (environment nil) &key (wait? t))
  (with (libc     (alien-dlopen *libc-path*)
         cexecve  (alien-dlsym libc "execve")
         cperror  (alien-dlsym libc "perror")
         cpath    (%malloc-string path :null-terminated t)
         argptrs  (filter [%malloc-string _ :null-terminated t] args)
         argv     (%malloc (* *pointer-size* (++ (length args))))
         environv (? environment
                     (%malloc (* *pointer-size* (++ (length environment))))
                      0)
         envptrs  (& environment
                     (filter [%malloc-string (string-concat _. "=" ._) :null-terminated t]
                             environment)))
	(%put-pointer-list argv argptrs :null-terminated t)
	(& environment
	   (%put-pointer-list environv envptrs :null-terminated t))
	(& (== 0 (fork))
       (alet (make-c-call :funptr cexecve)
         (c-call-add-arg ! cpath)
         (c-call-add-arg ! argv)
         (c-call-add-arg ! environv)
         (c-call-do !)
	     (print 'execve-error)
	     (quit)))
    (%free-list argptrs)
    (%free cpath)
    (%free argv)
	(when environment
      (%free-list envptrs)
	  (%free environv))
    (alien-dlclose libc)
	(& wait? (wait))))

(defun exec (bin args)
  (execve bin (cons bin args) nil))
