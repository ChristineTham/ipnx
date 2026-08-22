extern jerq;
move(xi,yi){
	char buf[10];
	buf[0]='\033';
	buf[1]='o';
	xsc(xi, &buf[2]);
	ysc(yi, &buf[4]);
	write(jerq, buf, 6);
}
