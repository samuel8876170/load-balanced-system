if[not system"p"; system"p 5000"];
if[not system"t"; system"t 60000"];

n: 20;
sym: `IBM`FD`NVDA`INTC;
ex: `HKEX`NYSE`LSE;

trade:([]time:n?.z.N; sym:n?sym; tradeID:string 1+til n; price:n?1000f; volume:n?50; side:n?`Buy`Sell);
quote:([]time:n?.z.N; sym:n?sym; ex:n?ex; bid:n?1000f; ask:n?1000f; bsize:n?50; asize:n?50);

queryNum: 0;
.z.pg: { queryNum::queryNum+1; value x };
.z.ps: { queryNum::queryNum+1; value x };
.z.ts: { queryNum::0; };