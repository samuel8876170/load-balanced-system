/ q autoScaleManager.q -t 60000 -p 5000 rdb,cep

targetGroup: distinct`$"," vs .z.x 0;
/ list of opening ports of slaves
slaves: ([port:enlist system"p"] pName:enlist .z.f; h:enlist 0i; idleCount:enlist 0);

/ pName: symbol
/ create a slave process of pName file
createSlave: {[pName]
    if[not pName in targetGroup; '`$"createSlave(error): ", string[pName], " not in targetGroup."];

    p: 1 + exec last port from slaves;
    value"\\q ",string[pName],".q -p ",string p;
    if[not "w"=first string .z.o; system"sleep 1"];

    h: hopen p;
    h ".z.pc:{exit 0}";

    slaves,: (p; pName; h; 0);
 };

/ p: int
/ kill slave with port p
killSlave: {[p]
    hclose slaves[p]`h;     / hclose will trigger .z.pc in slave and "exit 0" will run
    p_ slaves;              / remove its record
 };

.z.ts: {

 };