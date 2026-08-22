extern jerq;
closepl(){
	move(0,0);
	write(jerq, "\033A", 4);
}
