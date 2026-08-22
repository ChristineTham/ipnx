echo hiding stderr unless it is different 1>&2
for i in $*
do
	echo $i:
	/usr/bwk/grap/a.out  $i | pic >foo1 2>foo1.2
	/usr/bin/grap $i | pic >foo2 2>foo2.2
	diff -b foo2 foo1 | ind
	diff -b foo2.2 foo1.2 | ind
done
