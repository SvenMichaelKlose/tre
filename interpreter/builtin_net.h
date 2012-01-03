/*
 * tré - Copyright (c) 2011 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_NET_H
#define TRE_NET_H

treptr trebuiltin_net_open_socket (treptr args);
treptr trebuiltin_net_accept (treptr args);
treptr trebuiltin_net_recv (treptr args);
treptr trebuiltin_net_send (treptr args);
treptr trebuiltin_net_close_connection (treptr args);
treptr trebuiltin_net_close_socket (treptr args);

#endif /* #ifndef TRE_NET_H */
