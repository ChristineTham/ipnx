/* HARNESS STUB for V10's <sys/inet/tcp_user.h>: just the shapes 9pfs.c uses. */
#ifndef HARNESS_TCP_USER
#define HARNESS_TCP_USER
typedef unsigned long in_addr;
typedef unsigned short tcp_port;
struct tcpuser {
	int	code;
	tcp_port lport, fport;
	in_addr	laddr, faddr;
	int	param;
};
#define INADDR_ANY 0
#endif
