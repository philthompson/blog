// as of 2021-11-09, minify with https://codebeautify.org/minify-js
var useWorkers=!0;self.Worker||(useWorkers=!1,self.postMessage({subworkerNoWorky:!0}),self.close());const forceWorkerReloadUrlParam="force-worker-reload=true",forceWorkerReload=self.location.toString().includes(forceWorkerReloadUrlParam),urlParams=new URLSearchParams(self.location.search),appVersion=urlParams.has("v")?urlParams.get("v"):"unk";forceWorkerReload?(importScripts("infnum.js?v="+appVersion+"&"+"force-worker-reload=true&t="+Date.now()),importScripts("plots.js?v="+appVersion+"&"+"force-worker-reload=true&t="+Date.now())):(importScripts("infnum.js?v="+appVersion),importScripts("plots.js?v="+appVersion));const plotsByName={};for(let n=0;n<plots.length;n++)plotsByName[plots[n].name]=plots[n];const windowCalc={plot:null,pointCalcFunction:null,eachPixUnits:null,leftEdge:null,rightEdge:null,topEdge:null,bottomEdge:null,n:null,precision:null,algorithm:null,lineWidth:null,finalWidth:null,chunksComplete:null,canvasWidth:null,canvasHeight:null,xPixelChunks:null,pointsCache:null,cacheScannedChunks:null,cacheScannedChunksCursor:null,passTotalPoints:null,passCachedPoints:null,totalChunks:null,workersCount:null,workers:null,minWorkersCount:null,maxWorkersCount:null,plotId:null,stopped:!0,referencePx:null,referencePy:null,referenceOrbit:null};function runCalc(n){windowCalc.plotId=n.plotId,windowCalc.plot=n.plot,windowCalc.stopped=!1,windowCalc.eachPixUnits=n.eachPixUnits,windowCalc.leftEdge=n.leftEdge,windowCalc.rightEdge=n.rightEdge,windowCalc.topEdge=n.topEdge,windowCalc.bottomEdge=n.bottomEdge,windowCalc.n=n.n,windowCalc.precision=n.precision,windowCalc.algorithm=n.algorithm,windowCalc.lineWidth=2*n.startWidth,windowCalc.finalWidth=n.finalWidth,windowCalc.chunksComplete=0,windowCalc.canvasWidth=n.canvasWidth,windowCalc.canvasHeight=n.canvasHeight,null===windowCalc.pointsCache&&(windowCalc.pointsCache=new Map),windowCalc.totalChunks=null,windowCalc.workersCount=n.workers,windowCalc.workers=[],windowCalc.minWorkersCount=windowCalc.workersCount,windowCalc.maxWorkersCount=windowCalc.workersCount;for(let n=0;n<windowCalc.workersCount;n++)forceWorkerReload?windowCalc.workers.push(new Worker("calcsubworker.js?v="+appVersion+"&"+"force-worker-reload=true&t="+Date.now())):windowCalc.workers.push(new Worker("calcsubworker.js?v="+appVersion)),windowCalc.workers[n].onmessage=onSubWorkerMessage;if(windowCalc.algorithm.startsWith("perturb-")){let n=infNumAdd(windowCalc.leftEdge,infNumMul(windowCalc.eachPixUnits,infNum(BigInt(Math.floor(windowCalc.canvasWidth/2)),0n))),o=infNumAdd(windowCalc.bottomEdge,infNumMul(windowCalc.eachPixUnits,infNum(BigInt(Math.floor(windowCalc.canvasHeight/2)),0n))),e=plotsByName[windowCalc.plot].computeReferenceOrbit(windowCalc.n,windowCalc.precision,windowCalc.algorithm,n,o);console.log("calculated middle reference orbit, with ["+e.length+"] iterations, for point:"),console.log("referencePx: "+infNumToString(n)),console.log("referencePy: "+infNumToString(o));if(!1)for(let a=-5;a<6;a++)for(let l=-5;l<6;l++){let t=infNumAdd(windowCalc.leftEdge,infNumMul(windowCalc.eachPixUnits,infNum(BigInt(Math.floor(windowCalc.canvasWidth/2)+10*a),0n))),c=infNumAdd(windowCalc.bottomEdge,infNumMul(windowCalc.eachPixUnits,infNum(BigInt(Math.floor(windowCalc.canvasHeight/2)+10*l),0n))),i=plotsByName[windowCalc.plot].computeReferenceOrbit(windowCalc.n,windowCalc.precision,windowCalc.algorithm,t,c);i.length>e.length&&(n=t,o=c,e=i,console.log("calculated better reference orbit, with ["+e.length+"] iterations, for point:"),console.log("referencePx: "+infNumToString(n)),console.log("referencePy: "+infNumToString(o)))}windowCalc.referencePx=n,windowCalc.referencePy=o,windowCalc.referenceOrbit=e}else windowCalc.referencePx=null,windowCalc.referencePy=null,windowCalc.referenceOrbit=null;calculatePass()}function stopAndRemoveAllWorkers(){if(null!==windowCalc.workers){for(let n=0;n<windowCalc.workers.length;n++)windowCalc.workers[n].terminate();windowCalc.workers=null}}function updateWorkerCount(n){if(windowCalc.workersCount=n,null!==windowCalc.workers){windowCalc.minWorkersCount>windowCalc.workersCount&&(windowCalc.minWorkersCount=windowCalc.workersCount),windowCalc.maxWorkersCount<windowCalc.workersCount&&(windowCalc.maxWorkersCount=windowCalc.workersCount);for(let n=windowCalc.workers.length+1;n<=windowCalc.workersCount;n++){let n=null;n=forceWorkerReload?new Worker("calcsubworker.js?v="+appVersion+"&"+"force-worker-reload=true&t="+Date.now()):new Worker("calcsubworker.js?v="+appVersion),windowCalc.workers.push(n),n.onmessage=onSubWorkerMessage,assignChunkToWorker(n)}}}function removeWorkerIfNecessary(n){if(windowCalc.workers.length<=windowCalc.workersCount)return!1;const o=windowCalc.workers.indexOf(n);return!(o<0)&&(windowCalc.workers.splice(o,1),!0)}self.onmessage=function(n){useWorkers?(console.log("got mesage ["+n.data.t+"]"),"worker-calc"==n.data.t?runCalc(n.data.v):"workers-count"==n.data.t?updateWorkerCount(n.data.v):"wipe-cache"==n.data.t?windowCalc.pointsCache=new Map:"stop"==n.data.t&&(windowCalc.stopped=!0,stopAndRemoveAllWorkers())):self.postMessage({subworkerNoWorky:!0})};var calculatePass=function(){if(!windowCalc.stopped){calculateWindowPassChunks();for(const n of windowCalc.workers)assignChunkToWorker(n)}};function buildChunkId(n){return infNumFastStr(n.x)+","+infNumFastStr(n.y)}var assignChunkToWorker=function(n){if(windowCalc.stopped||null===windowCalc.xPixelChunks||0===windowCalc.xPixelChunks.length)return;let o=windowCalc.xPixelChunks.shift();windowCalc.cacheScannedChunksCursor--;const e=buildChunkId(o.chunkPos);let a=windowCalc.cacheScannedChunks.get(e);void 0===a&&(scanCacheForChunk(o),a=windowCalc.cacheScannedChunks.get(e));let l={plotId:windowCalc.plotId,chunk:o,cachedIndices:Array.from(a.keys()).sort(((n,o)=>n-o))};n.postMessage({t:"compute-chunk",v:l}),scanCacheForChunkBeyondCursor(),scanCacheForChunkBeyondCursor()};function scanCacheForChunkBeyondCursor(){windowCalc.cacheScannedChunksCursor>=windowCalc.xPixelChunks.length-1||0===windowCalc.xPixelChunks.length||(windowCalc.cacheScannedChunksCursor++,windowCalc.cacheScannedChunksCursor<0&&(windowCalc.cacheScannedChunksCursor=0),scanCacheForChunk(windowCalc.xPixelChunks[windowCalc.cacheScannedChunksCursor]))}function scanCacheForChunk(n){const o=infNumFastStr(n.chunkPos.x),e=o+","+infNumFastStr(n.chunkPos.y);let a=n.chunkPos.y,l=n.chunkInc.y,t=normInfNum(a,l);a=t[0],l=t[1];const c=new Map;let i=null;const r=windowCalc.pointsCache.get(o);if(void 0!==r)for(let o=0;o<n.chunkLen;o++)i=r.get(infNumFastStr(a)),void 0!==i&&c.set(o,i),a=infNumAddNorm(a,l);windowCalc.cacheScannedChunks.set(e,c)}function cacheComputedPointsInChunk(n){let o=0;const e=infNumFastStr(n.chunkPos.x);let a=windowCalc.pointsCache.get(e);void 0===a&&(windowCalc.pointsCache.set(e,new Map),a=windowCalc.pointsCache.get(e));let l=n.chunkPos.y,t=n.chunkInc.y,c=normInfNum(l,t);l=c[0],t=c[1];let i=null;for(let e=0;e<n.chunkLen;e++)i=n.results[e],void 0!==i&&(o++,a.set(infNumFastStr(l),i)),l=infNumAddNorm(l,t);return o}var onSubWorkerMessage=function(n){"completed-chunk"==n.data.t?handleSubworkerCompletedChunk(n):"send-reference-orbit"==n.data.t?handleReferenceOrbitRequest(n):console.log("worker received unknown message from subworker:",e)};function handleReferenceOrbitRequest(n){n.target.postMessage({t:"reference-orbit",v:{referencePx:windowCalc.referencePx,referencePy:windowCalc.referencePy,referenceOrbit:windowCalc.referenceOrbit,referencePlotId:windowCalc.plotId}})}function handleSubworkerCompletedChunk(n){const o=n.data.v.plotId!==windowCalc.plotId;o||windowCalc.chunksComplete++;const e=n.target,a=removeWorkerIfNecessary(e);windowCalc.stopped||(!a&&windowCalc.chunksComplete<windowCalc.totalChunks&&assignChunkToWorker(e),o||settleChunkWithCacheAndPublish({data:n.data.v}),windowCalc.chunksComplete>=windowCalc.totalChunks&&(isImageComplete()?cleanUpWindowCache():calculatePass()))}function settleChunkWithCacheAndPublish(n){let o=windowCalc.minWorkersCount.toString();windowCalc.maxWorkersCount>windowCalc.minWorkersCount&&(o+="-"+windowCalc.maxWorkersCount);const e=cacheComputedPointsInChunk(n.data),a=windowCalc.passCachedPoints;windowCalc.passTotalPoints+=e;const l=buildChunkId(n.data.chunkPos);let t=windowCalc.cacheScannedChunks.get(l);if(void 0!==t){for(const o of t)n.data.results[o[0]]=o[1];windowCalc.passCachedPoints+=t.size,windowCalc.cacheScannedChunks.delete(l)}const c=windowCalc.passCachedPoints-a;windowCalc.passTotalPoints+=c;const i={chunks:windowCalc.totalChunks,chunksComplete:windowCalc.chunksComplete,pixelWidth:windowCalc.lineWidth,running:!isImageComplete(),workersCount:o,workersNow:windowCalc.workers.length,passPoints:windowCalc.passTotalPoints,passCachedPoints:windowCalc.passCachedPoints};n.data.calcStatus=i,n.data.chunkPos.x=infNumExpString(n.data.chunkPos.x),n.data.chunkPos.y=infNumExpString(n.data.chunkPos.y),n.data.chunkInc.x=infNumExpString(n.data.chunkInc.x),n.data.chunkInc.y=infNumExpString(n.data.chunkInc.y),self.postMessage(n.data)}function isImageComplete(){return windowCalc.chunksComplete===windowCalc.totalChunks&&windowCalc.lineWidth===windowCalc.finalWidth}function shuffleArray(n){for(let o=n.length-1;o>0;o--){const e=Math.floor(Math.random()*(o+1));[n[o],n[e]]=[n[e],n[o]]}}var calculateWindowPassChunks=function(){if(windowCalc.passTotalPoints=0,windowCalc.passCachedPoints=0,windowCalc.chunksComplete=0,windowCalc.xPixelChunks=[],windowCalc.cacheScannedChunks=new Map,windowCalc.cacheScannedChunksCursor=-1,windowCalc.lineWidth===windowCalc.finalWidth)return;const n=Math.round(windowCalc.lineWidth/2);n<=windowCalc.finalWidth?windowCalc.lineWidth=windowCalc.finalWidth:windowCalc.lineWidth=n;const o=windowCalc.lineWidth,e=Math.ceil(windowCalc.canvasHeight/o)+1;for(var a=infNumMul(windowCalc.eachPixUnits,infNum(BigInt(o),0n)),l=infNumSub(windowCalc.leftEdge,a),t=0;t<windowCalc.canvasWidth;t+=o){l=infNumAdd(l,a);let n={plot:windowCalc.plot,chunkPix:{x:t,y:windowCalc.canvasHeight},chunkPixInc:{x:0,y:-1*o},chunkPos:{x:copyInfNum(l),y:copyInfNum(windowCalc.bottomEdge)},chunkInc:{x:infNum(0n,0n),y:copyInfNum(a)},chunkLen:e,chunkN:windowCalc.n,chunkPrecision:windowCalc.precision,algorithm:windowCalc.algorithm};windowCalc.xPixelChunks.push(n)}shuffleArray(windowCalc.xPixelChunks),windowCalc.totalChunks=windowCalc.xPixelChunks.length};function cleanUpWindowCache(){let n=0,o=0,e=[],a=null,l=null;for(const t of windowCalc.pointsCache)if(a=createInfNumFromFastStr(t[0]),infNumLt(a,windowCalc.leftEdge)||infNumGt(a,windowCalc.rightEdge))e.push(t[0]),n+=t[1].size;else{let e=[];for(const n of t[1].keys())l=createInfNumFromFastStr(n),infNumLt(l,windowCalc.bottomEdge)||infNumGt(l,windowCalc.topEdge)?e.push(n):o++;for(const n of e)t[1].delete(n);n+=e.length}for(const n of e)windowCalc.pointsCache.delete(n);const t=Math.round(1e4*n/(n+o))/100;console.log("deleted ["+n+"] points from the cache ("+t+"%)")}