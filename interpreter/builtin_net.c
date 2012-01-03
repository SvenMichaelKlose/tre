/*
 * tré - Copyright (c) 2011-2012 Sven Michael Klose <pixel@copei.de>
 */

#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "ptr.h"
#include "alloc.h"
#include "atom.h"
#include "argument.h"
#include "string2.h"
#include "error.h"
#include "number.h"
#include "builtin_net.h"

#define MAX_CLIENTS 1000
#define MAX_DATA 1024

int    trenet_socket;
int    trenet_connection;
struct sockaddr_in server;
struct sockaddr_in client;

treptr
trebuiltin_net_open_socket (treptr args)
{
    socklen_t sockaddr_len = sizeof (struct sockaddr_in);
    treptr port = trearg_get (args);

    if ((trenet_socket = socket (AF_INET, SOCK_STREAM, 0)) == -1)
        treerror_norecover (treptr_nil, "Cannot create socket");

    server.sin_family = AF_INET;
    server.sin_port = htons(TRENUMBER_VAL(port));
    server.sin_addr.s_addr = INADDR_ANY;
    bzero (&server.sin_zero, 8);

    if (bind (trenet_socket, (struct sockaddr *) &server, sockaddr_len) == -1)
        treerror_norecover (treptr_nil, "Cannot bind socket");

    if (listen (trenet_socket, MAX_CLIENTS) == -1)
        treerror_norecover (treptr_nil, "Cannot listen to socket");

    trenet_connection = -1;
    return treptr_nil;
}

treptr
trebuiltin_net_accept (treptr args)
{    
    socklen_t sockaddr_len = sizeof (struct sockaddr_in);

    if ((trenet_connection = accept (trenet_socket, (struct sockaddr *) &client, &sockaddr_len)) == -1)
        treerror_norecover (treptr_nil, "Cannot accept connection to socket");

    return treptr_nil;
}

treptr
trebuiltin_net_recv (treptr args)
{    
    char      * data = trealloc (MAX_DATA);
    treptr    result;
    size_t    len;

    len = recv (trenet_connection, data, MAX_DATA, 0);
    result = trestring_get_binary (data, len);
    trealloc_free (data);

    return result;
}

treptr
trebuiltin_net_send (treptr args)
{
    treptr  data = trearg_get (args);
    char    * s = TREATOM_STRING(data);

    send (trenet_connection, TRESTRING_DATA(s), TRESTRING_LEN(s), 0);    

    return treptr_nil;
}

treptr
trebuiltin_net_close_connection (treptr args)
{
    close (trenet_connection);
    trenet_connection = -1;
    return treptr_nil;
}

treptr
trebuiltin_net_close_socket (treptr args)
{
    close (trenet_socket);
    return treptr_nil;
}
