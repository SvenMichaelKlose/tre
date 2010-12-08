;;;;; TRE transpiler/middle-end
;;;;; (c) 2005-2010 Sven Klose <pixel@copei.de>

(env-load "transpiler/middle-end/global-funinfo.lisp")

(env-load "transpiler/middle-end/graph/metacode-to-cblock.lisp")
(env-load "transpiler/middle-end/update-funinfos.lisp")
(env-load "transpiler/middle-end/opt-places.lisp")
(env-load "transpiler/middle-end/opt-peephole.lisp")
(env-load "transpiler/middle-end/opt-tailcall.lisp")
(env-load "transpiler/middle-end/cps.lisp")
(env-load "transpiler/middle-end/named-functions.lisp")
(env-load "transpiler/middle-end/quote-keywords.lisp")

;(env-load "transpiler/middle-end/cblock.lisp")
;(env-load "transpiler/middle-end/metacode-fblock.lisp")
;(env-load "transpiler/middle-end/fblock-metacode.lisp")

(env-load "transpiler/middle-end/toplevel.lisp")
