(fn environment-pathnames (target)
  (+@ [& (| (not ._)
            (member target ._))
         `((,(+ "environment/" _.)))]
      (reverse *environment-pathnames*)))
