// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __character {
	public function __construct ($num)
	{
		$this->v =& $num;
	}

	public function __toString ()
	{
        return "#\\" . chr ($this->v) . " ";
	}
}
