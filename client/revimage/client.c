/*
 * Functions to send commands to the user interface.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <stdarg.h>

#include "easy_sock.h"

/* return string */
char uisendtmpbuf[1024];

/**
 * Handles reading errors
 */
static void
onError (int err)
{
  if (err != 0)
    printf (easy_sock_err_msg);
}

/**
 * Send a command to the UI. 
 */
char *
ui_send (char *command, int num, ...)
{
  int port1 = 7001;
  static int sock = -1;
  static int cnx = 0;
  char *s = "";
  va_list ap;

  /* Set error handler */
  easy_error (onError);

  signal (SIGPIPE, SIG_IGN);

  if (sock == -1)
    {
      sock = easy_tcp_connect ("127.0.0.1", port1);
      if (sock == -1)
	{
	  printf ("Can't connect ! ");
	  printf (easy_sock_err_msg);
	  sock = -2;
	}
      else
	{
	  cnx = 1;
	}
    }
  if (cnx)
    {
      /* write the called function */
      write_string (sock, command);
      /* number of arguments */
      write_int (sock, num);
    }
  else
    {
      printf ("DATA: %s %d", command, num);
    }

  va_start (ap, num);
  while (num)
    {
      s = va_arg (ap, char *);
      if (cnx)
	{
	  write_string (sock, s);
	}
      else
	{
	  printf (" '%s'", s);
	}
      num--;
    }
  va_end (ap);

  uisendtmpbuf[0] = 0;
  if (cnx)
    {
      s = read_string (sock);
      if (s)
	{
        /* close the connection to the UI */
//      if (strcmp(command, "close") == 0) {
	  close (sock);
	  sock = -1;
	  cnx = 0;
//      }
	  /* not optimal and thread safe */
	  strncpy (uisendtmpbuf, s, 1023);
	  free (s);
	}
    }
  else
    {
      printf ("\n");
    }
  return uisendtmpbuf;
}
