/*
 * tré - Copyright (c) 2011-2012 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_NET_H
#define TRE_NET_H

treptr trenet_builtin_open_socket (treptr args);
treptr trenet_builtin_accept (treptr args);
treptr trenet_builtin_recv (treptr args);
treptr trenet_builtin_send (treptr args);
treptr trenet_builtin_close_connection (treptr args);
treptr trenet_builtin_close_socket (treptr args);

#endif /* #ifndef TRE_NET_H */
