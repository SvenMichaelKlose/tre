MACROS

	<para>
		TRE expands macros of READ expressions before they're evaluated.
		Macros are expanded towards the expression root, so arguments to
		macros are always expanded. Imagine what would happen if the
		following expression would be expanded towards the leaves:
	</para>

	(setf (unsettable-place-maker x) y)

	<para>
		Macros are usually expressions, but TRE also allows atomic macros.
	</para>

	(defmacro (atom plc)
	  `(place-setter-item x))

	<para>
		WITH macros use them to provide settable places:
	</para>

	(defun mystruct-set-pos (x y)
	  (with-mystruct x
	    (setf x new-x
			  y new-y)))
