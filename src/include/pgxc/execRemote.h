/*-------------------------------------------------------------------------
 *
 * execRemote.h
 *
 *	  Functions to execute commands on multiple Data Nodes
 *
 *
 * Portions Copyright (c) 1996-2009, PostgreSQL Global Development Group ?
 * Portions Copyright (c) 2010 Nippon Telegraph and Telephone Corporation
 *
 * IDENTIFICATION
 *	  $$
 *
 *-------------------------------------------------------------------------
 */

#ifndef EXECREMOTE_H
#define EXECREMOTE_H
#include "datanode.h"
#include "locator.h"
#include "planner.h"
#include "access/tupdesc.h"
#include "executor/tuptable.h"
#include "nodes/execnodes.h"
#include "nodes/pg_list.h"
#include "tcop/dest.h"
#include "utils/snapshot.h"

/* Outputs of handle_response() */
#define RESPONSE_EOF EOF
#define RESPONSE_COMPLETE 0
#define RESPONSE_TUPDESC 1
#define RESPONSE_DATAROW 2
#define RESPONSE_COPY 3

typedef enum
{
	REQUEST_TYPE_NOT_DEFINED,	/* not determined yet */
	REQUEST_TYPE_COMMAND,		/* OK or row count response */
	REQUEST_TYPE_QUERY,			/* Row description response */
	REQUEST_TYPE_COPY_IN,		/* Copy In response */
	REQUEST_TYPE_COPY_OUT		/* Copy Out response */
}	RequestType;


typedef struct RemoteQueryState
{
	ScanState	ss;						/* its first field is NodeTag */
	int			node_count;				/* total count of participating nodes */
	DataNodeHandle **connections;		/* data node connections being combined */
	int			conn_count;				/* count of active connections */
	int			current_conn;			/* used to balance load when reading from connections */
	CombineType combine_type;			/* see CombineType enum */
	int			command_complete_count; /* count of received CommandComplete messages */
	RequestType request_type;			/* see RequestType enum */
	TupleDesc	tuple_desc;				/* tuple descriptor to be referenced by emitted tuples */
	int			description_count;		/* count of received RowDescription messages */
	int			copy_in_count;			/* count of received CopyIn messages */
	int			copy_out_count;			/* count of received CopyOut messages */
	char		errorCode[5];			/* error code to send back to client */
	char	   *errorMessage;			/* error message to send back to client */
	bool		query_Done;				/* query has been sent down to data nodes */
	char	   *msg;					/* last data row message */
	int 		msglen;					/* length of the data row message */
	/*
	 * While we are not supporting grouping use this flag to indicate we need
	 * to initialize collecting of aggregates from the DNs
	 */
	bool		initAggregates;
	List	   *simple_aggregates;		/* description of aggregate functions */
	void	   *tuplesortstate;			/* for merge sort */
	/* Simple DISTINCT support */
	FmgrInfo   *eqfunctions; 			/* functions to compare tuples */
	MemoryContext tmp_ctx;				/* separate context is needed to compare tuples */
	FILE	   *copy_file;      		/* used if copy_dest == COPY_FILE */
	uint64		processed;				/* count of data rows when running CopyOut */
}	RemoteQueryState;

/* Multinode Executor */
extern void DataNodeBegin(void);
extern void	DataNodeCommit(void);
extern int	DataNodeRollback(void);
extern int	DataNodePrepare(char *gid);
extern void	DataNodeRollbackPrepared(char *gid);
extern void	DataNodeCommitPrepared(char *gid);

extern DataNodeHandle** DataNodeCopyBegin(const char *query, List *nodelist, Snapshot snapshot, bool is_from);
extern int DataNodeCopyIn(char *data_row, int len, ExecNodes *exec_nodes, DataNodeHandle** copy_connections);
extern uint64 DataNodeCopyOut(ExecNodes *exec_nodes, DataNodeHandle** copy_connections, FILE* copy_file);
extern void DataNodeCopyFinish(DataNodeHandle** copy_connections, int primary_data_node, CombineType combine_type);

extern int ExecCountSlotsRemoteQuery(RemoteQuery *node);
extern RemoteQueryState *ExecInitRemoteQuery(RemoteQuery *node, EState *estate, int eflags);
extern TupleTableSlot* ExecRemoteQuery(RemoteQueryState *step);
extern void ExecEndRemoteQuery(RemoteQueryState *step);
extern void ExecRemoteUtility(RemoteQuery *node);

extern int handle_response(DataNodeHandle * conn, RemoteQueryState *combiner);
extern bool FetchTuple(RemoteQueryState *combiner, TupleTableSlot *slot);

extern void ExecRemoteQueryReScan(RemoteQueryState *node, ExprContext *exprCtxt);
extern void DataNodeConsumeMessages(void);

extern int primary_data_node;
#endif