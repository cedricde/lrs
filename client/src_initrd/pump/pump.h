#ifndef H_NET
#define H_NET

#include <netinet/in.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <sys/time.h>

#define MAX_GATEWAYS		3
#define MAX_DNS_SERVERS		3
#define MAX_LOG_SERVERS		3
#define MAX_LPR_SERVERS		3
#define MAX_NTP_SERVERS		3
#define MAX_XFS_SERVERS		3
#define MAX_XDM_SERVERS		3

#define PUMP_INTFINFO_HAS_IP		(1 << 0)
#define PUMP_INTFINFO_HAS_NETMASK	(1 << 1)
#define PUMP_INTFINFO_HAS_BROADCAST	(1 << 2)
#define PUMP_INTFINFO_HAS_NETWORK	(1 << 3)
#define PUMP_INTFINFO_HAS_DEVICE	(1 << 4)
#define PUMP_INTFINFO_HAS_BOOTSERVER	(1 << 5)
#define PUMP_INTFINFO_HAS_BOOTFILE	(1 << 6)
#define PUMP_INTFINFO_HAS_LEASE		(1 << 7)
#define PUMP_INTFINFO_HAS_REQLEASE	(1 << 8)
#define PUMP_INTFINFO_HAS_NEXTSERVER	(1 << 9)
#define PUMP_INTFINFO_NEEDS_NEWLEASE	(1 << 10)
#define PUMP_INTFINFO_HAS_MTU           (1 << 11)
#define PUMP_INTFINFO_HAS_PTPADDR       (1 << 12)

#define PUMP_NETINFO_HAS_LOGSRVS	(1 << 15)
#define PUMP_NETINFO_HAS_LPRSRVS	(1 << 16)
#define PUMP_NETINFO_HAS_NTPSRVS	(1 << 17)
#define PUMP_NETINFO_HAS_XFNTSRVS	(1 << 18)
#define PUMP_NETINFO_HAS_XDMSRVS	(1 << 19)
#define PUMP_NETINFO_HAS_GATEWAY	(1 << 20)
#define PUMP_NETINFO_HAS_HOSTNAME	(1 << 21)
#define PUMP_NETINFO_HAS_DOMAIN		(1 << 22)
#define PUMP_NETINFO_HAS_DNS		(1 << 23)
#define PUMP_NETINFO_HAS_NISDOMAIN	(1 << 24)

#define PUMP_NETINFO_HAS_OPTION177	(1 << 29)
#define PUMP_NETINFO_HAS_OPTION178	(1 << 30)
#define PUMP_NETINFO_HAS_OPTION179	(1 << 31)

#define PUMP_FLAG_NODAEMON	(1 << 0)
#define PUMP_FLAG_NOCONFIG	(1 << 1)
#define PUMP_FLAG_FORCEHNLOOKUP	(1 << 2)
#define PUMP_FLAG_WINCLIENTID	(1 << 3)
#define PUMP_FLAG_NOSETUP	(1 << 4)

#define PUMP_SCRIPT_NEWLEASE	1
#define PUMP_SCRIPT_RENEWAL	2
#define PUMP_SCRIPT_DOWN	3

#define OVERRIDE_FLAG_NODNS		(1 << 0)
#define OVERRIDE_FLAG_NONISDOMAIN	(1 << 1)
#define OVERRIDE_FLAG_NOGATEWAY		(1 << 2)
#define OVERRIDE_FLAG_NOBOOTP           (1 << 3)
#define OVERRIDE_FLAG_NOSETUP		(1 << 4)
#define OVERRIDE_FLAG_NORESOLVCONF	(1 << 5)

struct pumpOverrideInfo {
    char device[10];
    char searchPath[1024];
    int flags;
    int numRetries;
    int timeout;
    char script[1024];
};

/* all of these in_addr things are in network byte order! */
struct pumpNetIntf {
    char device[10];
    int ifindex;
    int set;
    struct in_addr ip, netmask, broadcast, network;
    struct in_addr bootServer, nextServer;
    char * bootFile;
    time_t leaseExpiration, renewAt;
    int reqLease;		/* in seconds */
    char * hostname, * domain;		/* dynamically allocated */
    char * nisDomain;			/* dynamically allocated */
    struct in_addr gateways[MAX_GATEWAYS];
    struct in_addr logServers[MAX_LOG_SERVERS];
    struct in_addr lprServers[MAX_LPR_SERVERS];
    struct in_addr ntpServers[MAX_NTP_SERVERS];
    struct in_addr xfntServers[MAX_XFS_SERVERS];
    struct in_addr xdmServers[MAX_XDM_SERVERS];
    struct in_addr dnsServers[MAX_DNS_SERVERS];
    int numGateways;
    int numLog;
    int numLpr;
    int numNtp;
    int numXfs;
    int numXdm;
    int numDns;
    int flags;
    char * option177, * option178, * option179;
    struct pumpOverrideInfo override;

    /* these don't really belong here, but anaconda's about the only thing 
     * that uses pump and this stuff is needed for the loader on s390 */
    int mtu;                    
    struct in_addr ptpaddr;             /* ptp address for ptp devs like ctc */
};

void pumpInitOverride(struct pumpOverrideInfo * override);
char * pumpDhcpClassRun(char * device, int flags, int lease,
                    char * reqHostname, char * class, struct pumpNetIntf * intf,
                    struct pumpOverrideInfo * override);
char * pumpDhcpRun(char * device, int flags, int lease,
		     char * reqHostname, struct pumpNetIntf * intf,
		     struct pumpOverrideInfo * override);
char * pumpSetupInterface(struct pumpNetIntf * intf);
/* setup an interface for sending a broadcast -- uses all 0's address */
char * pumpPrepareInterface(struct pumpNetIntf * intf, int s);
char * pumpDisableInterface(struct pumpNetIntf * intf);
int pumpDhcpRenew(struct pumpNetIntf * intf);
int pumpDhcpRelease(struct pumpNetIntf * intf);
int pumpSetupDefaultGateway(struct in_addr * gw);
time_t pumpUptime(void);

#define RESULT_OKAY		0
#define RESULT_FAILED		1
#define RESULT_UNKNOWNIFACE	2

extern int verbose;
#if UDEB
#define bootp_client_port htons(68)
#define bootp_server_port htons(67)
#else
extern int bootp_client_port;
extern int bootp_server_port;
#endif


#endif
