;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun file-exists? (pathname) pathname (error "Not implemented."))

(defun %malloc (num-bytes) num-bytes (error "Not implemented."))
(defun %malloc-exec (num-bytes) num-bytes (error "Not implemented."))
(defun %free (address) address (error "Not implemented."))
(defun %free-exec (address) address (error "Not implemented."))
(defun %%set (address byte) address byte (error "Not implemented."))
(defun %%get (address) address (error "Not implemented."))

(defun function-bytecode (x) x (error "Not implemented."))
(defun =-function-bytecode (v x) v x (error "Not implemented."))

(defun << (x num-bits-to-left) x num-bits-to-left (error "Not implemented."))
(defun >> (x num-bits-to-right) x num-bits-to-right (error "Not implemented."))

(defun =-symbol-value (x) x (error "Not implemented."))
(defun %setq-atom-value (value symbol) value symbol (error "Not implemented."))
(defun =-symbol-function (x) x (error "Not implemented."))

(defun %set-elt (object sequence index) object sequence index (error "Not implemented."))

(defun %directory (pathname) pathname (error "Not implemented."))
(defun %stat (pathname) pathname (error "Not implemented."))
(defun readlink (pathname) pathname (error "Not implemented."))

(defun %terminal-raw () (error "Not implemented."))
(defun %terminal-normal () (error "Not implemented."))
(defun end-debug () (error "Not implemented."))

(defun alien-dlopen (path-to-shared-library) path-to-shared-library (error "Not implemented."))
(defun alien-dlsym (handle) handle (error "Not implemented."))
(defun alien-call (address) address (error "Not implemented."))

(defun open-socket (port-number) port-number (error "Not implemented."))
(defun accept () (error "Not implemented."))
(defun recv () (error "Not implemented."))
(defun send (string) string (error "Not implemented."))
(defun close-connection () (error "Not implemented."))
(defun close-socket () (error "Not implemented."))

(defun %type-id (x) x (error "Not implemented."))
(defun %%id (x) x (error "Not implemented."))
(defun %error (x) x (error x))
(defun %strerror (x) x (error "Not implemented."))
(defun atan2 (x) x (error "Not implemented."))
(defun pow (x) x (error "Not implemented."))
