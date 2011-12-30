/*
 * tré - Copyright (c) 2011 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_NET_H
#define TRE_NET_H

treptr trenet_open_socket (treptr args);
treptr trenet_listen (treptr args);
treptr trenet_send (treptr args);
treptr trenet_close_connection (treptr args);
treptr trenet_close_socket (treptr args);

#endif /* #ifndef TRE_NET_H */
