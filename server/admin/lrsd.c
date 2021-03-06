/* hey emacs! -*- Mode: C; c-file-style: "k&r"; indent-tabs-mode: nil -*- */
/*
 * $Id$
 *
 *  Linbox Rescue Server
 *  Copyright (C) 2002-2005 Linbox FAS, Free & Alter Soft
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *
 *
 * LRS Daemon 
 *
 * TODO:
 * - real deamon (double fork)
 */

#include <stdio.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <math.h>
#include <errno.h>
#include <ctype.h>
#include <syslog.h>
#include <time.h>
#include <dirent.h>
#ifdef S_SPLINT_S
# include "/usr/local/splint/include/arpa/inet.h"
#else
# include <arpa/inet.h>
#endif
#include <netinet/in.h>


#define BUFLEN 1532
#define PORT 1001

#include "iniparser.h"

unsigned char gBuff[80];
unsigned char basedir[255];
dictionary *ini;
unsigned int lic_number;
char etherpath[255];
char logtxt[256];

void initlog(void)
{
    openlog("lrsd", 0, LOG_DAEMON | LOG_LOCAL3);
}

/*
 * logging
 */
void mysyslog( char *smac, int priority, const char *format_str, ... )
{
    va_list ap;
    FILE *f;
    char buf[1024], path[256];

    /* write some info */
    va_start( ap, format_str );
    vsnprintf( buf, 1023, format_str, ap );
    va_end(ap);

    snprintf(path, 255, "%s/images/%s/log", basedir, smac);
    if (f = fopen(path, "a")) 
    {
         time_t now;
         char tm[64];

	time(&now);
	strcpy(tm, ctime(&now));
	tm[strlen(tm) - 1] = '\000';
	fprintf(f, "%s: %s\n", tm, buf);
	fclose(f);
	
        /* log the last restoration */
        if (strstr(buf, "restoration comp") != NULL) {
             snprintf(path, 255, "%s/images/%s/log.lastrestore", basedir, smac);
             if (f = fopen(path, "w")) 
             {
                  fprintf(f, "%s: %s\n", tm, buf);
                  fclose(f);             
             }
        }

	syslog(priority, buf);

	/* keep only the last 20 lines of the log */
	snprintf(buf, 1023, "%s/bin/rotatelog %s", basedir, path);
	system(buf);

      }
    else
      {
	syslog(priority, buf);
      }
}


void hex2char(char *ptr, char *val)
{
    if ((ptr[1] >= 'A') && (ptr[1] <= 'F'))
	*val = ptr[1] - 'A' + 10;
    else if ((ptr[1] >= 'a') && (ptr[1] <= 'f'))
	*val = ptr[1] - 'a' + 10;
    else if ((ptr[1] >= '0') && (ptr[1] <= '9'))
	*val = ptr[1] - '0';
    else {
	*val = 0;
	return;
    }

    if ((ptr[0] >= 'A') && (ptr[0] <= 'F'))
	*val += (16 * (ptr[0] - 'A' + 10));
    else if ((ptr[0] >= 'a') && (ptr[0] <= 'f'))
	*val += (16 * (ptr[0] - 'a' + 10));
    else if ((ptr[0] >= '0') && (ptr[0] <= '9'))
	*val += (16 * (ptr[0] - '0'));
    else {
	*val = 0;
	return;
    }
}

void diep(char *s)
{
    time_t now;
    char *ts;

    time(&now);
    ts = ctime(&now) + 4;
    ts[20] = '\0';

    if (errno) {
	perror(s);
    } else {
	puts(s);
    }
    syslog(LOG_ERR, s);
    exit(1);
}

/*
 * system() func with logging
 */
int mysystem(const char *s)
{
    char cmd[1024];

    snprintf(cmd, 1023, "echo \"`date`: %.900s\" 1>>%s 2>&1", s, logtxt);
    system(cmd);

    snprintf(cmd, 1023, "%.900s 1>>%s 2>&1", s, logtxt);
    return (system(cmd));
}


/*
 * Get the number of entries
 */
unsigned int getentries(unsigned char *file)
{
    FILE *fi;
    unsigned int s = 0;
    unsigned char buf[100];

    fi = fopen(file, "r");
    if (!fi)
	return 0;
    while (fgets(buf, 100, fi))
	if ((buf[0] != '#') && (buf[0] != ';') && (strlen(buf) > 10))
	    s++;
    fclose(fi);

    return s;
}

/*
 * get the name corresponding to a MAC addr
 */
int getentry(char *file, char *pktmac)
{
    FILE *fi;
    unsigned int s = 0;
    char buf[100], mac[20], name[33];

    fi = fopen(file, "r");
    if (!fi)
	return 0;
    while (fgets(buf, 100, fi)) {
	if ((buf[0] != '#') && (buf[0] != ';') && (strlen(buf) > 10)) {
	    s++;
	    if (sscanf(buf, "%19s%*s%32s", mac, name) == 2) {
		//printf("%s*%s\n", mac, name);
		if (!strncasecmp(mac, pktmac, 17)) {
		    /* return the name in the global buffer */
		    strcpy(gBuff, name);
		    fclose(fi);
		    return 1;
		}
	    }
	}
    }
    fclose(fi);

    return 0;
}

/*
 *  get mac from the ARP cache
 */
unsigned char *getmac(struct in_addr addr)
{
    FILE *fi;
    char *ptr = NULL;
    char straddr[80];
    int l;

    strcpy(straddr, inet_ntoa(addr));
    l = strlen(straddr);
    straddr[l] = ' ';
    straddr[l + 1] = '\0';

    syslog(LOG_INFO, "Warning: MAC not found in packet\n");
    fi = fopen("/proc/net/arp", "r");
    while (fgets(gBuff, 80, fi)) {
	if (strstr(gBuff, straddr)) {
	    ptr = (unsigned char *) strchr((char *) gBuff, ':') - 2;
	    ptr[17] = 0;
	    break;
	}
    }
    fclose(fi);
    return ptr;
}

/*
 *  get the mac from data embedded in the request
 *
 *  format: "Mc:xx:xx:xx:xx:xx:xx" at the end of the packet
 */
unsigned char *getmacfrompkt(char *buf, int l)
{
    if (l <= 20)
	return NULL;
    // check for a magic number and for ':' x6
    if (buf[l - 20] == 'M' && buf[l - 19] == 'c' && buf[l - 18] == ':'
	&& buf[l - 15] == ':' && buf[l - 12] == ':' && buf[l - 9] == ':'
	&& buf[l - 6] == ':' && buf[l - 3] == ':') {
	// let's copy the mac address
	strncpy(gBuff, buf + l - 17, 17);
	gBuff[17] = 0;
	return gBuff;
    }
    return NULL;
}

/*
 * Process an incoming packet
 */
int process_packet(unsigned char *buf, char *mac, char *smac,
		   struct sockaddr_in *si_other, int s)
{
    char command[256], name[256];
    FILE *fo;
    static unsigned int lastfile = 0, lasttime = 0;

    /* do not log, log requests ! */
    if (buf[0] != 'L' && buf[0] != 0xCD)
	syslog
	    (LOG_DEBUG,
	     "Packet from %s:%d, MAC Address:%s, Command: %02x\n",
	     inet_ntoa(si_other->sin_addr), ntohs(si_other->sin_port), mac,
	     buf[0]);


    // Hardware Info...
    if (buf[0] == 0xAA) {
	snprintf(command, 255, "%s/bin/update_menu %s", basedir, smac);
	mysystem(command);
	/* write inventory to file. Must fit in one packet ! */
	snprintf(name, 255, "%s/log/%s.inf", basedir, smac);
	fo = fopen(name, "w");
	fprintf(fo, ">>>Packet from %s:%d\nMAC Address:%s\n%s\n<<<\n",
		inet_ntoa(si_other->sin_addr),
		ntohs(si_other->sin_port), mac, buf + 1);
	snprintf(command, 255, "%s/bin/info %s/log/%s.inf %s/log/%s.ini",
		basedir, basedir, smac, basedir, smac);
	fclose(fo);
	mysystem(command);
	return 0;
    }
    // identification
    if (buf[0] == 0xAD) {
	char *ptr, pass[256], hostname[256];

	snprintf(name, 255, "%s/log/ID.log", basedir);
	fo = fopen(name, "a");
	fprintf(fo, ">>>Packet from %s:%d\nMAC Address:%s\n%s\n<<<\n",
		inet_ntoa(si_other->sin_addr),
		ntohs(si_other->sin_port), mac, buf);
	fclose(fo);

	ptr = strrchr(buf + 3, ':');
	*ptr = 0;
	strcpy(pass, ptr + 1);
	strcpy(hostname, buf + 3);
	snprintf(command, 255, "%s/bin/check_add_host %s %s %s", basedir,
		mac, hostname, pass);
	mysystem(command);
	return 0;
    }
    // before a save
    if (buf[0] == 0xEC) {
	snprintf(command, 255, "%s/bin/update_dir %s %c", basedir, smac, buf[1]);
	mysystem(command);
	return 0;
    }
    // change menu default
    if (buf[0] == 0xCD) {
	snprintf(command, 255, "%s/bin/set_default %s %d", basedir,
		smac, buf[1]);
	mysystem(command);
	mysyslog(smac, LOG_INFO, "%s default set to %d", mac, buf[1]);
	return 0;
    }
    // log data
    if (buf[0] == 'L') {
	switch (buf[1]) {
	case '0':
	    mysyslog(smac, LOG_INFO, "%s booted", mac);
	    break;
	case '1':
	    mysyslog(smac, LOG_INFO, "%s executing menu entry %d",
		   mac, buf[2]);
	    break;
	case '2':
	    if (buf[2] == '-') {
		mysyslog(smac, LOG_INFO, "%s restoration started (%s)", mac, &buf[3]);
	    } else {
		mysyslog(smac, LOG_INFO, "%s restoration started", mac);
	    }
	    break;
	case '3':
	    if (buf[2] == '-') {
		mysyslog(smac, LOG_INFO, "%s restoration completed (%s)", mac, &buf[3]);
	    } else {
		mysyslog(smac, LOG_INFO, "%s restoration completed", mac);
	    }
	    lasttime = 0;	/* reset MTFTP time barriers */
	    lastfile = 0;
	    break;
	case '4':
	    if (buf[2] == '-') {
		mysyslog(smac, LOG_INFO, "%s backup started (%s)", mac, &buf[3]);
	    } else {
		mysyslog(smac, LOG_INFO, "%s backup started", mac);
	    }
	    break;
	case '5':
	    if (buf[2] == '-') {
        	int bn;
                
                mysyslog(smac, LOG_INFO, "%s backup completed (%s)", mac, &buf[3]);
                if (sscanf(&buf[3], "Local-%d", &bn) == 1) {
                        // Local backup
                        snprintf(command, 255, "chown -R 0:0 %s/images/%s/Local-%d", basedir, smac, bn);
                        system(command);
                } else if (sscanf(&buf[3], "Base-%d", &bn) == 1) {
                        // Shared backup
                        snprintf(command, 255, "chown -R 0:0 %s/imgbase/Base-%d", basedir, bn);
                        system(command);
                }
	    } else {
		mysyslog(smac, LOG_INFO, "%s backup completed", mac);
	    }
 	    break;
	case '6':
	    mysyslog(smac, LOG_INFO, "%s postinstall started", mac);
	    break;
	case '7':
	    mysyslog(smac, LOG_INFO, "%s postinstall completed", mac);
	    break;
	case '8':
	    mysyslog(smac, LOG_INFO, "%s critical error", mac);
	    break;

	}
	return 0;
    }
    // return me my LBS name
    if (buf[0] == 0x1A) {
	if (getentry(etherpath, mac)) {
	    //to.sin_family = AF_INET;
	    //to.sin_port = htons(1001);
	    //inet_aton(inet_ntoa(si_other.sin_addr), &to.sin_addr);        
	    sendto(s, gBuff, strlen(gBuff)+1, MSG_NOSIGNAL,
		   (struct sockaddr *) si_other, sizeof(*si_other));
	}
	return 0;
    }
    /* time synchro */
    if (buf[0] == 'T') {
      char pnum;
      int bnum, to;

      if (sscanf(buf, "T;%c%d;%d", &pnum, &bnum, &to) == 3) {
	unsigned int file = (pnum<<16) + bnum;
	int wait = 0;

	if (time(NULL) - lasttime > 3600) {
	    lasttime = 0;	/* reset MTFTP time barriers */
	    lastfile = 0;	  
	}

	if (file == lastfile) {
	  /* wait barrier */
	  wait = to + (lasttime - time(NULL));
	  if (wait < 0) wait = 0;
	} else if (file < lastfile) {
	  wait = 0;
	} else if (file > lastfile) {
	  /* reinit barrier */
	  wait = to;
	  if (lasttime == 0) wait=wait+10; /* 1st wait after a boot */
	  lastfile = file;
	  lasttime = time(NULL);
	}
	//printf("%c %d %d %d\n", pnum, bnum, to, wait);
	
	sprintf(buf, "%d", wait);
	sendto(s, buf, strlen(buf), MSG_NOSIGNAL,
	       (struct sockaddr *) si_other, sizeof(*si_other));
	
	return 0;
      }
    }

    return 1;
}

/* MAIN */
int main(void)
{
    struct sockaddr_in si_me, si_other, si_tcp;
    int s, i, slen = sizeof(si_other), plen, stcp;
    unsigned char buf[BUFLEN];
    unsigned char lic_mac[] = "00:00:00:00:00:00", lic_eth[] =
	"eth0\0\0\0";
    unsigned char if_mac[] = "00:00:00:00:00:00";
    unsigned int nb;
    FILE *fi;
    char smac[20], command[255], lic_key[64];
    char *mac;
    char *str;
    fd_set fds;
    int on = 1;

    basedir[0] = 0;

    initlog();

    ini = iniparser_load("/etc/lbs.conf");
    if (ini == NULL) {
	diep("cannot parse file /etc/lbs.conf");
    }
    /* iniparser_dump(ini, stderr); */

    if ((str = iniparser_getstr(ini, ":basedir"))) {
	strncpy(basedir, str, 254);
	sprintf(logtxt, "%.220s/log/Response.log", basedir);
    } else {
	diep("Basedir not found in lbs.conf");
    }

    if ((str = iniparser_getstr(ini, ":key"))) {
	strncpy(lic_key, str, 63);
    } else {
	diep("No license key found...");
    }

    if ((str = iniparser_getstr(ini, ":license"))) {
	sscanf(str, "%d", &lic_number);
    } else {
	diep("No 'license' keyword found...");
    }

    if ((str = iniparser_getstr(ini, ":hwmac"))) {
	strncpy(lic_mac, str, 17);
    } else {
	diep("No 'hwmac' keyword found...");
    }

    if ((str = iniparser_getstr(ini, ":iface"))) {
	strncpy(lic_eth, str, 5);
    } else {
	diep("No 'iface' keyword found...");
    }

    /* */
    sprintf(etherpath, "%s/etc/ether", basedir);

    /* compare the mac in the config file with the real one */
    sprintf(command, "ifconfig %s | head -1 ", lic_eth);
    fi = popen(command, "r");
    if (!fi)
	diep("Cannot determine iface HW mac address");
    fgets(buf, 80, fi);
    pclose(fi);
    buf[strlen(buf) - 1] = 0;
    if (!strstr(buf, "HWaddr "))
	diep("Cannot retrieve HWaddr");
    strcpy(if_mac, strstr(buf, "HWaddr ") + 7);
    /*printf("IFCONFIG : %s / LBS.CONF : %s\n", if_mac, lic_mac); */

    syslog(LOG_INFO, "LRSD $Revision$. Copyright (C) 2000-2005 Linbox FAS\n");

    if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
	diep("udp socket");
    if ((stcp = socket(AF_INET, SOCK_STREAM, 0)) == -1)
	diep("tcp socket");

    /* UDP sock */
    memset((char *) &si_me, sizeof(si_me), 0);
    si_me.sin_family = AF_INET;
    si_me.sin_port = htons(PORT);
    si_me.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind(s, (struct sockaddr *) &si_me, sizeof(si_me)) == -1)
	diep("bind");

    /* TCP sock */
    if (setsockopt (stcp, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) != 0) {
      syslog (LOG_DEBUG, "SO_REUSEADDR failed");
    }
    memset((char *) &si_tcp, sizeof(si_tcp), 0);
    si_tcp.sin_family = AF_INET;
    si_tcp.sin_port = htons(PORT);
    si_tcp.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind(stcp, (struct sockaddr *) &si_tcp, sizeof(si_tcp)) == -1)
	diep("bind");
    listen(stcp, 1000);

    while (1) {
	int so;			/* tcp/udp stream FD */
	/* select */
	FD_ZERO(&fds);
	FD_SET(s, &fds);
	FD_SET(stcp, &fds);

	select(stcp + 1, &fds, NULL, NULL, NULL);
	if (FD_ISSET(stcp, &fds)) {
	    so = accept(stcp, (struct sockaddr *) &si_other, &slen);
	    if (so == -1)
		continue;
	    if ((plen =
		 recvfrom(so, buf, BUFLEN, 0,
			  (struct sockaddr *) NULL, NULL)) == -1)
		diep("recvfrom()");
	} else if (FD_ISSET(s, &fds)) {
	    so = s;
	    if ((plen =
		 recvfrom(so, buf, BUFLEN, 0,
			  (struct sockaddr *) &si_other, &slen)) == -1)
		diep("recvfrom()");

	} else {
	    continue;
	}

	/* UDP only */
	if ((mac = getmacfrompkt(buf, plen))) {
	    // got it from the request ! good !
	} else {
	    // Pas beau...(utilise le cache ARP) (for backward compatibility)
	    mac = getmac(si_other.sin_addr);
	}
	if (!mac) {
	    strcpy(gBuff, "?");
	    mac = gBuff;
	}
	/* client port must be 1001 ! */
	if (ntohs(si_other.sin_port) != 1001) {
	  if (so != s)
	    close(so);	  
	  continue;
	}

	/* short mac */
	sprintf(smac, "%c%c%c%c%c%c%c%c%c%c%c%c", mac[0], mac[1], mac[3],
		mac[4], mac[6], mac[7], mac[9], mac[10], mac[12], mac[13],
		mac[15], mac[16]);

	/* process */
	process_packet(buf, mac, smac, &si_other, so);

	/* eventually close the tcp stream */
	if (so != s)
	    close(so);

    }

    close(s);
    return 0;
}
