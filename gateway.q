/ q gateway.q -p 8888

NLB: neg LB: hopen 8080;

services: ([address:`symbol$()] handle:`int$());
addService: {[addr] `services upsert (addr; hopen addr) };
/ initialize services by adding all services contained in loadBalancer
addService each LB "exec address from services";

/ function called by service after they get the result
callback: {[loadBalancerH; addr; userH; result]
	/ result: (hasError; queryResult)
	if[userH in key .z.W; -30!userH, result];				/ send back the deferred message

	loadBalancerH (`releaseService; addr);
 }[NLB];

/ function called by loadBalancer when they allocate service address to request
receiveService: {[addr] 
	receivedAddr::addr;
 };

/ function called by user to query on services
request: {[serviceName; query]
	remoteFunc: {[serviceAddr; clientHandle; query]
		neg[.z.w](`callback; serviceAddr; clientHandle; @[(0b;)value@; query; {[error](1b; error)}])
	};
	
	NLB (`requestService; serviceName);		/ TODO: Handle when `requestService doesn't send feedback since all services are busy
	neg[receiveAddr] (remoteFunc; receveAddr; .z.w; query);

	-30!(::);
 };
