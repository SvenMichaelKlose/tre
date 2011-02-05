// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __funref {
	public function &__construct ($name, &$ghost)
	{
		$this->n =& $name;
		$this->g =& $ghost;
        return $this;
	}
}
