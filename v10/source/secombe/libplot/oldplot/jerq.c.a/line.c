extern jerq;
line(x0,y0,x1,y1){
	char buf[10];
	move(x0, y0);
	cont(x1, y1);
}
cont(x, y){
	char buf[10];
	buf[0]='\033';
	buf[1]='n';
	xsc(x, &buf[2]);
	ysc(y, &buf[4]);
	write(jerq, buf, 6);
}
