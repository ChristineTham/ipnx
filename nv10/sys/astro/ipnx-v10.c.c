/*
 * config data
 */

#include "sys/param.h"
#include "sys/conf.h"
#include "sys/vtimes.h"
#include "sys/proc.h"
#include "sys/inode.h"
#include "sys/file.h"
#include "sys/text.h"
#include "sys/callout.h"
#include "sys/buf.h"
#include "sys/map.h"
#include "sys/stream.h"
#include "sys/mba.h"
#include "sys/mbaddr.h"
#include "sys/nxaddr.h"
#include "sys/nexus.h"
#include "sys/ubaddr.h"
#include "sys/uba.h"
#include "sys/uda.h"
#include "sys/inet/in.h"
#include "sys/inet/ip_var.h"
#include "sys/inet/udp.h"
#include "sys/inet/tcp.h"
#include "sys/inet/tcp_timer.h"
#include "sys/inet/tcp_var.h"
#include "sys/subaddr.h"
#include "sys/dz.h"
#include "sys/kmc.h"
#include "sys/kdi.h"
#include "sys/mscp.h"
#include "sys/ni1010a.h"
#include "sys/udaioc.h"
#include "sys/ra.h"
#include "sys/ta.h"
#include "sys/te16.h"
#include "sys/hp.h"
#include "sys/bad144.h"
#include "sys/ttyio.h"
#include "sys/ttyld.h"
#include "sys/xttyld.h"
#include "sys/bufld.h"
#include "sys/mesg.h"
#include "sys/dkp.h"
#include "sys/nttyio.h"
#include "sys/nttyld.h"
#include "sys/mount.h"
extern struct bdevsw hpbdev;
extern struct bdevsw te16bdev;
extern struct bdevsw swbdev;
extern struct bdevsw rabdev;
extern struct bdevsw tabdev;
int nblkdev = 11;
extern struct cdevsw cncdev;
extern struct cdevsw dzcdev;
extern struct cdevsw mmcdev;
extern struct cdevsw hpcdev;
extern struct cdevsw te16cdev;
extern struct cdevsw clkcdev;
extern struct cdevsw swcdev;
extern struct cdevsw cbscdev;
extern struct cdevsw spcdev;
extern struct cdevsw dncdev;
extern struct cdevsw kmccdev;
extern struct cdevsw racdev;
extern struct cdevsw kdicdev;
extern struct cdevsw fdcdev;
extern struct cdevsw ipcdev;
extern struct cdevsw tcpcdev;
extern struct cdevsw ilcdev;
extern struct cdevsw udpcdev;
extern struct cdevsw tacdev;
int nchrdev = 60;
extern struct fstypsw fsfs;
extern struct fstypsw nafs;
extern struct fstypsw prfs;
extern struct fstypsw msfs;
extern struct fstypsw nbfs;
extern struct fstypsw erfs;
extern struct fstypsw pipfs;
int nfstyp = 7;
extern struct streamtab ttystream;
extern struct streamtab cdkpstream;
extern struct streamtab rdkstream;
extern struct streamtab msgstream;
extern struct streamtab dkpstream;
extern struct streamtab nttystream;
extern struct streamtab bufldstream;
extern struct streamtab rmsgstream;
extern struct streamtab ipstream;
extern struct streamtab tcpstream;
extern struct streamtab udpstream;
extern struct streamtab connstream;
extern struct streamtab xpstream;
extern struct streamtab adkstream;
extern struct streamtab xttystream;
int nstreamtab = 22;

struct bdevsw *bdevsw[] = {
	&hpbdev,	/* 0 */
	&te16bdev,	/* 1 */
	NULL,
	NULL,
	&swbdev,	/* 4 */
	NULL,
	NULL,
	&rabdev,	/* 7 */
	NULL,
	NULL,
	&tabdev,	/* 10 */
};
struct cdevsw *cdevsw[] = {
	&cncdev,	/* 0 */
	&dzcdev,	/* 1 */
	NULL,
	&mmcdev,	/* 3 */
	&hpcdev,	/* 4 */
	&te16cdev,	/* 5 */
	&clkcdev,	/* 6 */
	&swcdev,	/* 7 */
	&cbscdev,	/* 8 */
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	&spcdev,	/* 18 */
	&dncdev,	/* 19 */
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	&kmccdev,	/* 26 */
	NULL,
	&racdev,	/* 28 */
	NULL,
	NULL,
	&kdicdev,	/* 31 */
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	&fdcdev,	/* 40 */
	NULL,
	&ipcdev,	/* 42 */
	&tcpcdev,	/* 43 */
	&ilcdev,	/* 44 */
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	&udpcdev,	/* 50 */
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	&tacdev,	/* 59 */
};
struct fstypsw *fstypsw[] = {
	&fsfs,	/* 0 */
	&nafs,	/* 1 */
	&prfs,	/* 2 */
	&msfs,	/* 3 */
	&nbfs,	/* 4 */
	&erfs,	/* 5 */
	&pipfs,	/* 6 */
};
struct streamtab *streamtab[] = {
	&ttystream,	/* 0 */
	&cdkpstream,	/* 1 */
	&rdkstream,	/* 2 */
	NULL,
	&msgstream,	/* 4 */
	&dkpstream,	/* 5 */
	&nttystream,	/* 6 */
	&bufldstream,	/* 7 */
	NULL,
	&rmsgstream,	/* 9 */
	&ipstream,	/* 10 */
	&tcpstream,	/* 11 */
	NULL,
	NULL,
	&udpstream,	/* 14 */
	NULL,
	NULL,
	NULL,
	&connstream,	/* 18 */
	&xpstream,	/* 19 */
	&adkstream,	/* 20 */
	&xttystream,	/* 21 */
};
int calloutcnt = 50;
struct callout callout[50];
int textcnt = 100;
struct text text[100];
int argcnt = 16;
struct map argmap[16];
int swmapcnt = 400;
struct map swapmap[400];
int kernelcnt = 600;
struct map kernelmap[600];
int swbufcnt = 50;
struct buf swapbuf[50];
struct swapinfo swapinfo[50];
int bufhcnt = 127;
struct bufhd bufhash[127];
int dstflag = 1;
int timezone = 300;
int maxtsize = 12256;

struct nextab nextab[] = {
	0, 1,
	0, 2,
	0, 3,
	0, 8,
	0, 9,
	-1
};
struct nxaddr mcraddr[] = {
	{0, 0, 0x0},
	{1, 0, 0x0},
};
int mcrcnt = 2;
caddr_t mcrregs[2];
time_t mcrtime[2];
struct nxaddr ubaaddr[] = {
	{2, 0, 0x200},
};
int ubacnt = 1;
struct uba uba[1];
long ubazvec[1];
char *ubavoff[1];
long *ubavreg[1];
struct nxaddr mbaaddr[] = {
	{3, 0, 0x0},
	{4, 0, 0x0},
};
int mbacnt = 2;
struct mba mba[2];
extern hp0int();
extern hp0int();
extern hp0int();
extern hp0int();
extern hp0int();
extern hp0int();
extern hp0int();
extern hp0int();
extern tm030int();
char mbaid[][8] = {
 0, 1, 2, 3, 4, 5, 6, 7,
 0, 011, 012, 013, 014, 015, 016, 017,
};
int mbastray();
int (*mbavec[][8])() = {
 hp0int, hp0int, hp0int, hp0int, hp0int, hp0int, hp0int, hp0int,
 tm030int, mbastray, mbastray, mbastray, mbastray, mbastray, mbastray, mbastray,
};
struct mbaddr hpaddr[] = {
	{0, 0},
	{1, 0},
	{2, 0},
	{3, 0},
	{4, 0},
	{5, 0},
	{6, 0},
	{7, 0},
};
int hpcnt = 8;
struct hpdisk hpdisk[8];
struct buf hpbuf[8];
struct buf hpbadbuf[8];
struct bad144 hpbad[8];
struct mbaddr tm03addr[] = {
	{0, 1},
};
int tm03cnt = 1;
struct tm03 tm03[1];
struct subaddr te16addr[] = {
	{0, 0},
};
int te16cnt = 1;
struct te16 te16[1];
struct buf cte16buf[1];
struct buf rte16buf[1];
struct ubaddr udaddr[] = {
	{0772150, 0154, 0},
	{-1, -1, -1},
	{-1, -1, -1},
	{-1, -1, -1},
	{0774500, 0174, 0},
};
int udcnt = 5;
struct ud ud[5];
extern struct msportsw udport;
int nmsport = 1;
struct msportsw *msportsw[] = {
	&udport,	/* 0 */
};
struct msaddr raaddr[] = {
	{0, 0, 0},
	{0, 0, 1},
	{0, 0, 2},
	{0, 0, 3},
};
int racnt = 4;
struct radisk radisk[4];
struct buf rabuf[4];
struct msaddr taaddr[] = {
	{4, 0, 0},
};
int tacnt = 1;
struct tatape tatape[1];
struct buf tabuf[1];
struct ubaddr dzaddr[] = {
	{0760100, 0300, 0},
	{0760110, 0310, 0},
	{0760120, 0320, 0},
	{0760130, 0330, 0},
};
int dzcnt = 32;
struct dz dz[32];
struct ubaddr iladdr[] = {
	{0764000, 0350, 0},
};
int ilcnt = 1;
struct il il[1];
struct ubaddr kmcaddr[] = {
	{0760200, 0600, 0},
};
int kmccnt = 1;
struct kmc kmc[1];
struct ubaddr dnaddr[] = {
	{0775200, 0430, 0},
};
int dncnt = 1;
caddr_t dnreg[1];
struct ubaddr draddr[] = {
	{0767570, 00, 0},
};
int drcnt = 1;
caddr_t drreg[1];
int kdicnt = 2;
struct kdikmc kdikmc[2];
struct kmcdk k[2];
int cncnt = 0;
int spcnt = 64;
struct queue *spipes[64];
int proccnt = 1000;
struct proc proc[1000];
int inodecnt = 2000;
struct inode inode[2000];
int filecnt = 1536;
struct file file[1536];
int queuecnt = 4096;
struct queue queue[4096];
int blkcnt = 3200;
struct block cblock[3200];
int blkbcnt = 200;
struct buf *cblkbuf[200];
int streamcnt = 1200;
struct stdata streams[1200];
int maxdsize = 819200;
int maxssize = 819200;
int ttycnt = 480;
struct ttyld ttyld[480];
int nttycnt = 64;
struct nttyld ntty[64];
int xttycnt = 128;
struct xttyld xttyld[128];
int msgcnt = 512;
struct imesg mesg[512];
int dkpcnt = 256;
struct dkp dkp[256];
int cdkpcnt = 0;
int rdkcnt = 0;
int adkcnt = 0;
int xpcnt = 96;
int bufldcnt = 32;
struct bufld bufld[32];
int fscnt = 48;
struct mount fsmtab[48];
int ipcnt = 64;
struct ipif ipif[64];
struct ipif *ipifsort[64];
int udpcnt = 32;
struct udp udpconn[32];
int tcpcnt = 256;
struct tcpcb tcpcb[256];
int arpcnt = 128;
struct ip_arp ip_arps[128];
int rootfstyp = 0;
dev_t rootdev = makedev(7, 64);
dev_t swapdev = makedev(4, 0);
struct swdevt swdevt[] = {
	{makedev(7, 1), 20480L},
};
int nswdevt = 1;
extern int uddump();
int (*dumprout)() = uddump;
int dumpunit = 0;
long dumplow = 10240;
long dumpsize = 20480;
