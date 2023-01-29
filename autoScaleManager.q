/ q autoScaleManager.q -t 60000 -p 5000 rdb,cep

LB: hopen `:localhost:8080;

MAX_IDLE_COUNT: 5;      / any services idle more than MAX_IDLE_COUNT * t will be killed

targetGroup: distinct`$"," vs .z.x 0;
/ list of opening ports of slaves
slaves: ([port:enlist system"p"] pName:enlist`autoScaleManager; h:enlist 0i; idleCount:enlist 0);

/ pName: symbol
/ create a slave process of pName file
createSlave: {[pName]
    if[not pName in targetGroup; '`$"createSlave(error): ", string[pName], " not in targetGroup."];
    0N!"createSlave(info): pName=", string pName;

    p: 1 + exec last port from slaves;
    value"\\q ",string[pName],".q -p ",string p;
    if[not "w"=first string .z.o; system"sleep 1"];

    h: hopen p;
    h ".z.pc:{exit 0}";

    slaves,: (p; pName; h; 0);
 };

/ p: int / list of int
/ kill slaves with port p
killSlave: {[p]
    0N!"killSlave(info): port=", string p;

    hclose exec h from slaves where port = p;       / hclose will trigger .z.pc in slave and "exit 0" will run
    delete from `slaves where port = p;             / remove its record
 };

lastQueueLen: targetGroup!(count targetGroup)#0Wj;
checkMetric: {
    / check if over-loaded
    currQueueLen: targetGroup#LB ((';count); `requestQueue);
    if[any isOverLoad: currQueueLen >= lastQueueLen; createSlave each isOverLoad?1b];

    / check if under-loaded
    update idleCount: ?[0 < h@\:`queryNum; 0; idleCount+1] from `slaves where pName <> `autoScaleManager;
    ps: exec port from slaves where idleCount > MAX_IDLE_COUNT;
    if[0 < count ps; killSlave ps];

    lastQueueLen::currQueueLen;
 };

.z.ts: {
    0N!slaves;
    checkMetric[];
 };