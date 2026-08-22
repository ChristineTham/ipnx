for i in $*
do
	echo $i:
	eqn $i  >foo1
	a.out $i  >foo2
	troff foo1 >foo11
	troff foo2 >foo22
	if cmp foo11 foo22
	then
		echo good
	else
		diff foo1 foo2 | ind
	fi
done
