/ q loadBalancer.q -p 8080

services: ([address:`:localhost:5000`:localhost:5001] name:`rdb`rdb; avail:11b);

requestQueue: ()!();
addRequest: {[h;serv] requestQueue[serv]::requestQueue[serv],enlist h; };
popRequest: {[serv] res: first requestQueue serv; requestQueue[serv]:: 1_ requestQueue serv; res };

/ send the requested service address to h
allocService: {[h;addr]
	update avail:0b from `services where address=addr;
	neg[h](`receiveService; addr);
 };

/ function for process to request service address
requestService: {[serv]
	res: exec first address from services where name = serv, avail;
	$[null res;
		addRequest[.z.w; serv];
		allocService[.z.w; res]
	];
 };

/ release service by address
releaseService: {[addr] 
	update avail:1b from `services where address=addr;
 };
