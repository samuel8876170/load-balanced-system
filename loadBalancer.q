args:.Q.def[`name`port!("loadBalancer";8080);].Q.opt .z.x

/ remove this line when using in production
/ loadBalancer:localhost:8080::
{ if[not x=0; @[x;"\\\\";()]]; value"\\p 8080"; } @[hopen;`:localhost:8080;0];

services: ([address:`:localhost:5000`:localhost:5001] name:`rdb`rdb; avail:11b);

requestQueue: ()!();
addRequest: {[h;qid;serv] requestQueue[serv]::requestQueue[serv],enlist(h;qid); };
popRequest: {[serv] res: first requestQueue serv; requestQueue[serv]:: 1_ requestQueue serv; res };

/ send the requested service address to h
allocService: {[h;qid;addr]
	0N!"allocService: ", " ; " sv string (h; qid; addr);
	update avail:0b from `services where address=addr;
	neg[h](`receiveService; qid; addr);
 };

/ function for process to request service address
requestService: {[qid; serv]
	res: exec first address from services where name = serv, avail;
	$[null res;
		addRequest[.z.w; qid; serv];
		allocService[.z.w; qid; res]
	];
 };

/ release service by address
releaseService: {[addr] 
	update avail:1b from `services where address=addr;

	/ if there are some waiting query for the service just released
	if[0 < count requestQueue services[addr;`name];
		res: exec first address from services where name = services[addr;`name], avail;

		/ if there is no available services with same serviceName as addr (not possible though)
		if[not null res; 
			q: popRequest services[addr]`name;
			0N!q;
			allocService[q 0; q 1; res];
		];
	]
 };
