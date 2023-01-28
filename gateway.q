args:.Q.def[`name`port!("gateway";8888);].Q.opt .z.x

/ remove this line when using in production
/ gateway:localhost:8888::
{ if[not x=0; @[x;"\\\\";()]]; value"\\p 8888"; } @[hopen;`:localhost:8888;0];

NLB: neg LB: hopen 8080;

services: ([address:`symbol$()] handle:`int$());
addService: {[addr] `services upsert (addr; hopen addr) };
/ initialize services by adding all services contained in loadBalancer
addService each LB "exec address from services";

queryTable: ([id: `guid$()]; 
				userH: `int$(); 
				recvTime: `timestamp$(); 
				sentTime: `timestamp$(); 
				returnTime: `timestamp$(); 
				userId: `$(); 
				servH: `int$(); 
				servName: `$(); 
				query: ()
			);

/ function called by service after they get the result
callback: {[loadBalancerH; addr; userH; qid; result]
	update returnTime:.z.p from queryTable where id=qid;

	/ result: (hasError; queryResult)
	if[userH in key .z.W; -30!userH, result];				/ send back the deferred message

	loadBalancerH (`releaseService; addr);
 }[NLB];

/ function called by loadBalancer when they allocate service address to request
receiveService: {[qid;addr] 
	remoteFunc: {[servAddr; userH; qid; query]
		neg[.z.w](`callback; servAddr; userH; qid; @[(0b;)value@; query; {[error](1b; error)}])
	};

	/ TODO: query service based on queryTable with qid
	if[not addr in exec address from services; services,: (addr; hopen addr)];

	h: services[addr]`handle;

	0N!(addr; h; queryTable[qid]`userH);

	neg[h] (remoteFunc; addr; queryTable[qid]`userH; qid; queryTable[qid]`query);
	update sentTime:.z.p, servH:h from `queryTable where id=qid;
 };

/ function called by user to query on services
request: {[serviceName; query]
	remoteFunc: {[serviceAddr; clientHandle; query]
		neg[.z.w](`callback; serviceAddr; clientHandle; @[(0b;)value@; query; {[error](1b; error)}])
	};

	qid: first -1?0Ng;
	queryTable,: (qid; .z.w; .z.p; 0Np; 0Np; .z.u; 0Ni; serviceName; query);

	NLB (`requestService; qid; serviceName);		/ TODO: Handle when `requestService doesn't send feedback since all services are busy

	-30!(::);
 };
