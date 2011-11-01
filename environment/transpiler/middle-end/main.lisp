;;;;; TRE transpiler/middle-end - (c) 2005-2011 Sven Klose <pixel@copei.de>

(when nil
    (env-load "transpiler/middle-end/graph/cblock.lisp")
    (env-load "transpiler/middle-end/graph/traverse.lisp")
    (env-load "transpiler/middle-end/graph/print.lisp")
    (env-load "transpiler/middle-end/graph/make-cblock-taglist.lisp")
    (env-load "transpiler/middle-end/graph/make-cblock-links.lisp")
    (env-load "transpiler/middle-end/graph/metacode-to-cblocks.lisp")
    (env-load "transpiler/middle-end/graph/cblocks-to-metacode.lisp")
    (env-load "transpiler/middle-end/graph/dataflow.lisp")
    (env-load "transpiler/middle-end/graph/ssa.lisp")
    (env-load "transpiler/middle-end/graph/opt-remove-doubles.lisp")
    (env-load "transpiler/middle-end/graph/toplevel.lisp"))

(env-load "transpiler/middle-end/update-funinfos.lisp")
(env-load "transpiler/middle-end/opt-places.lisp")
(env-load "transpiler/middle-end/opt-peephole.lisp")
(env-load "transpiler/middle-end/opt-tailcall.lisp")
(env-load "transpiler/middle-end/cps.lisp")
(env-load "transpiler/middle-end/named-functions.lisp")
(env-load "transpiler/middle-end/quote-keywords.lisp")
(env-load "transpiler/middle-end/package.lisp")

(env-load "transpiler/middle-end/toplevel.lisp")
