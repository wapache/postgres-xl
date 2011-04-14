/*-------------------------------------------------------------------------
 *
 * path.h
 *
 *
 * Portions Copyright (c) 1996-2009, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 * Portions Copyright (c) 2010-2011 Nippon Telegraph and Telephone Corporation
 *
 * $PostgreSQL$
 *
 *-------------------------------------------------------------------------
 */
#ifndef _PATH_H
#define _PATH_H

#include "gtm/gtm_c.h"

extern void canonicalize_path(char *path);
extern char *make_absolute_path(const char *path);
#endif
