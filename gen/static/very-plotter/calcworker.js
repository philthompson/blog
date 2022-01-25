var useWorkers=true;if(!self.Worker){useWorkers=false;self.postMessage({subworkerNoWorky:true});self.close()}if(!self.structuredClone){BigInt.prototype.toJSON=function(){return this.toString()};self.structuredClone=function(obj){return JSON.parse(JSON.stringify(obj))}}const forceWorkerReloadUrlParam="force-worker-reload=true";const forceWorkerReload=self.location.toString().includes(forceWorkerReloadUrlParam);const urlParams=new URLSearchParams(self.location.search);const appVersion=urlParams.has("v")?urlParams.get("v"):"unk";if(forceWorkerReload){importScripts("infnum.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now());importScripts("floatexp.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now());importScripts("mathiface.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now());importScripts("plots.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now())}else{importScripts("infnum.js?v="+appVersion);importScripts("floatexp.js?v="+appVersion);importScripts("mathiface.js?v="+appVersion);importScripts("plots.js?v="+appVersion)}const plotsByName={};for(let i=0;i<plots.length;i++){plotsByName[plots[i].name]=plots[i]}const allCachedIndicesArray=[-1];const startPassNumber=0;const windowCalc={timeout:null,plot:null,pointCalcFunction:null,eachPixUnits:null,edges:null,edgesM:null,n:null,precision:null,algorithm:null,math:null,passNumber:null,lineWidth:null,finalWidth:null,chunksComplete:null,canvasWidth:null,canvasHeight:null,xPixelChunks:null,pointsCache:null,pointsCacheAlgorithm:null,cacheScannedChunks:null,cacheScannedChunksCursor:null,passTotalPoints:null,passCachedPoints:null,totalChunks:null,workersCount:null,workers:null,minWorkersCount:null,maxWorkersCount:null,plotId:null,stopped:true,referencePx:null,referencePy:null,referencePeriod:null,referenceOrbit:null,referenceOrbitPrecision:null,referenceOrbitN:null,referenceBlaTables:null,referenceBlaN:null,referenceBottomLeftDeltaX:null,referenceBottomLeftDeltaY:null,saCoefficients:null,saCoefficientsN:null,saCoefficientsEdges:null,saCoefficientsParams:null,passBlaPixels:null,passBlaIterationsSkipped:null,passBlaSkips:null,setupStage:null,setupStageState:null,setupStageIsStarted:null,setupStageIsFinished:null,caching:null};const setupStages={checkRefOrbit:0,calcRefOrbit:1,checkBlaCoeff:2,calcBlaCoeff:3,checkSaCoeff:4,calcSaCoeff:5,done:6};self.onmessage=function(e){if(!useWorkers){self.postMessage({subworkerNoWorky:true});return}console.log("got mesage ["+e.data.t+"]");if(e.data.t=="worker-calc"){runCalc(e.data.v)}else if(e.data.t=="workers-count"){updateWorkerCount(e.data.v)}else if(e.data.t=="wipe-cache"){windowCalc.pointsCache=new Map}else if(e.data.t=="wipe-ref-orbit"){wipeReferenceOrbitStuff()}else if(e.data.t=="stop"){windowCalc.stopped=true;stopAndRemoveAllWorkers()}};function runCalc(msg){windowCalc.plotId=msg.plotId;windowCalc.plot=msg.plot;windowCalc.stopped=false;windowCalc.eachPixUnits=msg.eachPixUnits;windowCalc.eachPixUnitsM=msg.eachPixUnitsM;windowCalc.edges={left:msg.leftEdge,right:msg.rightEdge,top:msg.topEdge,bottom:msg.bottomEdge};windowCalc.edgesM={left:msg.leftEdgeM,right:msg.rightEdgeM,top:msg.topEdgeM,bottom:msg.bottomEdgeM};windowCalc.n=msg.n;windowCalc.precision=msg.precision;windowCalc.algorithm=msg.algorithm;windowCalc.math=selectMathInterfaceFromAlgorithm(windowCalc.algorithm);windowCalc.passNumber=startPassNumber-1;windowCalc.lineWidth=msg.startWidth*2;windowCalc.finalWidth=msg.finalWidth;windowCalc.chunksComplete=0;windowCalc.canvasWidth=msg.canvasWidth;windowCalc.canvasHeight=msg.canvasHeight;windowCalc.caching=false;if(windowCalc.pointsCache===null||!windowCalc.caching||windowCalc.pointsCacheAlgorithm!==null&&windowCalc.pointsCacheAlgorithm!=windowCalc.algorithm){windowCalc.pointsCache=new Map}windowCalc.pointsCacheAlgorithm=windowCalc.algorithm;windowCalc.totalChunks=null;windowCalc.workersCount=msg.workers;windowCalc.workers=[];windowCalc.minWorkersCount=windowCalc.workersCount;windowCalc.maxWorkersCount=windowCalc.workersCount;for(let i=0;i<windowCalc.workersCount;i++){if(forceWorkerReload){windowCalc.workers.push(new Worker("calcsubworker.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now()))}else{windowCalc.workers.push(new Worker("calcsubworker.js?v="+appVersion))}windowCalc.workers[i].onmessage=onSubWorkerMessage}if(windowCalc.algorithm.includes("basic-")){windowCalc.referencePx=null;windowCalc.referencePy=null;windowCalc.referenceOrbit=null;windowCalc.referenceBlaTables=null;windowCalc.saCoefficients=null;calculatePass()}else{if(windowCalc.timeout!=null){clearTimeout(windowCalc.timeout)}windowCalc.timeout=setTimeout(kickoffSetupTasks,250)}}function wipeReferenceOrbitStuff(){windowCalc.referenceOrbit=null;windowCalc.saCoefficients=null;windowCalc.referenceBlaTables=null}function setupCheckReferenceOrbit(){sendStatusMessage("Finding reference point");let newReferencePx=infNumAdd(windowCalc.edges.left,infNumMul(windowCalc.eachPixUnits,infNum(BigInt(Math.floor(windowCalc.canvasWidth/2)),0n)));let newReferencePy=infNumAdd(windowCalc.edges.bottom,infNumMul(windowCalc.eachPixUnits,infNum(BigInt(Math.floor(windowCalc.canvasHeight/2)),0n)));let refPointHasMoved=false;if(windowCalc.referencePx===null||windowCalc.referencePy===null){refPointHasMoved=true}else{let xDiff=infNumSub(windowCalc.referencePx,newReferencePx);let yDiff=infNumSub(windowCalc.referencePy,newReferencePy);let squaredDiff=infNumAdd(infNumMul(xDiff,xDiff),infNumMul(yDiff,yDiff));let maxAllowablePixelsMove=Math.ceil(windowCalc.canvasWidth*.05);let maxAllowableMove=infNumMul(windowCalc.eachPixUnits,infNum(BigInt(maxAllowablePixelsMove),0n));maxAllowableMove=infNumMul(maxAllowableMove,maxAllowableMove);if(infNumGt(squaredDiff,maxAllowableMove)){refPointHasMoved=true;console.log("the previous ref orbit is NOT within ["+maxAllowablePixelsMove+"] pixels, so we need a new ref orbit")}else{console.log("the previous ref orbit is within ["+maxAllowablePixelsMove+"] pixels, so it's still valid")}}if(windowCalc.referenceOrbitN===null||windowCalc.referenceOrbitN<windowCalc.n||windowCalc.referenceOrbitPrecision===null||windowCalc.referenceOrbitPrecision/windowCalc.precision<.98||windowCalc.referenceOrbit===null||refPointHasMoved){windowCalc.referencePx=newReferencePx;windowCalc.referencePy=newReferencePy;wipeReferenceOrbitStuff()}else{console.log("re-using previously-calculated reference orbit, with ["+windowCalc.referenceOrbit.length+"] iterations, for point:");console.log("referencePx: "+infNumToString(windowCalc.referencePx));console.log("referencePy: "+infNumToString(windowCalc.referencePy));return false}return true}function setupReferenceOrbit(state){if(state===null||!state.done){const findPeriod=false;if(!findPeriod){windowCalc.referencePeriod=-1}else if(state===null){let refPeriodState=null;let pixelsPercent=Math.floor(.05*Math.max(windowCalc.canvasHeight,windowCalc.canvasWidth));let boxDelta=infNumMul(windowCalc.eachPixUnits,infNum(BigInt(pixelsPercent),0n));while(refPeriodState===null||!refPeriodState.done){refPeriodState=plotsByName[windowCalc.plot].computeReferencePeriod(windowCalc.n,windowCalc.precision,windowCalc.algorithm,windowCalc.referencePx,windowCalc.referencePy,boxDelta,refPeriodState);sendStatusMessage(refPeriodState.status)}console.log("computed ref PERIOD to be "+refPeriodState.period);windowCalc.referencePeriod=refPeriodState.period}state=plotsByName[windowCalc.plot].computeReferenceOrbit(windowCalc.n,windowCalc.precision,windowCalc.algorithm,windowCalc.referencePx,windowCalc.referencePy,windowCalc.referencePeriod,state);sendStatusMessage(state.status)}if(state.done){windowCalc.referenceOrbit=state.orbit;windowCalc.referenceOrbitN=windowCalc.n;windowCalc.referenceOrbitPrecision=windowCalc.precision;console.log("calculated new middle reference orbit, with ["+windowCalc.referenceOrbit.length+"] iterations, for point:");console.log("referencePx: "+infNumToString(windowCalc.referencePx));console.log("referencePy: "+infNumToString(windowCalc.referencePy))}return state}function setupCheckBlaCoefficients(){if(windowCalc.algorithm.includes("bla-")){if(windowCalc.referenceBlaTables===null||windowCalc.n!==windowCalc.referenceBlaN){return true}else{console.log("re-using previously-calculated BLA coefficient tables")}}return false}function setupBlaCoefficients(state){if(state===null||!state.done){if(state===null){windowCalc.referenceBlaTables=null;sendStatusMessage("Calculating BLA coefficient tables")}state=plotsByName[windowCalc.plot].computeBlaTables(windowCalc.algorithm,windowCalc.referenceOrbit,state);sendStatusMessage(state.status)}if(state.done){windowCalc.referenceBlaN=windowCalc.n;windowCalc.referenceBlaTables=state.blaTables}return state}function setupCheckSaCoefficients(){if(windowCalc.algorithm.includes("sapx")){let sapxParams=windowCalc.algorithm.split("-").find((e=>e.startsWith("sapx")));if(windowCalc.saCoefficients===null||windowCalc.saCoefficientsEdges===null||windowCalc.n!==windowCalc.saCoefficientsN||windowCalc.saCoefficientsParams===null||windowCalc.saCoefficientsParams!=sapxParams||!infNumEq(windowCalc.edges.left,windowCalc.saCoefficientsEdges.left)||!infNumEq(windowCalc.edges.right,windowCalc.saCoefficientsEdges.right)||!infNumEq(windowCalc.edges.top,windowCalc.saCoefficientsEdges.top)||!infNumEq(windowCalc.edges.bottom,windowCalc.saCoefficientsEdges.bottom)){return true}else{console.log("re-using previously-calculated SA coefficients")}}else{}return false}function setupSaCoefficients(state){if(state===null||!state.done){if(state===null){windowCalc.saCoefficients=null;sendStatusMessage("Calculating and testing SA coefficients")}state=plotsByName[windowCalc.plot].computeSaCoefficients(windowCalc.precision,windowCalc.algorithm,windowCalc.referencePx,windowCalc.referencePy,windowCalc.referenceOrbit,windowCalc.edges,state);sendStatusMessage(state.status)}if(state.done){windowCalc.saCoefficientsN=windowCalc.n;windowCalc.saCoefficientsEdges=structuredClone(windowCalc.edges);windowCalc.saCoefficients=state.saCoefficients;windowCalc.saCoefficientsParams=windowCalc.algorithm.split("-").find((e=>e.startsWith("sapx")))}return state}function kickoffSetupTasks(){if(windowCalc.timeout!=null){clearTimeout(windowCalc.timeout)}windowCalc.setupStage=0;windowCalc.timeout=setInterval(runSetupTasks,5)}function runSetupTasks(){if(windowCalc.stopped||windowCalc.setupStage>=setupStages.done){if(windowCalc.timeout!=null){clearTimeout(windowCalc.timeout)}if(!windowCalc.stopped){setupPixelPositionDelta();calculatePass()}return}else if(windowCalc.setupStage===setupStages.checkRefOrbit){if(!setupCheckReferenceOrbit()){windowCalc.setupStage++}windowCalc.setupStageIsFinished=true}else if(windowCalc.setupStage===setupStages.calcRefOrbit){if(!windowCalc.setupStageIsStarted){windowCalc.setupStageState=null;windowCalc.setupStageIsStarted=true}if(!windowCalc.setupStageIsFinished){windowCalc.setupStageState=setupReferenceOrbit(windowCalc.setupStageState)}if(windowCalc.setupStageState.done){windowCalc.setupStageIsFinished=true}}else if(windowCalc.setupStage===setupStages.checkBlaCoeff){if(!setupCheckBlaCoefficients()){windowCalc.setupStage++}windowCalc.setupStageIsFinished=true}else if(windowCalc.setupStage===setupStages.calcBlaCoeff){if(!windowCalc.setupStageIsStarted){windowCalc.setupStageState=null;windowCalc.setupStageIsStarted=true}if(!windowCalc.setupStageIsFinished){windowCalc.setupStageState=setupBlaCoefficients(windowCalc.setupStageState)}if(windowCalc.setupStageState.done){windowCalc.setupStageIsFinished=true}}else if(windowCalc.setupStage===setupStages.checkSaCoeff){if(!setupCheckSaCoefficients()){windowCalc.setupStage++}windowCalc.setupStageIsFinished=true}else if(windowCalc.setupStage===setupStages.calcSaCoeff){if(!windowCalc.setupStageIsStarted){windowCalc.setupStageState=null;windowCalc.setupStageIsStarted=true}if(!windowCalc.setupStageIsFinished){windowCalc.setupStageState=setupSaCoefficients(windowCalc.setupStageState)}if(windowCalc.setupStageState.done){windowCalc.setupStageIsFinished=true}}else{console.log("unexpected calcworker setup stage ["+windowCalc.setupStage+"]... stopping setup");windowCalc.setupStage=setupStages.done}if(windowCalc.setupStageIsFinished){windowCalc.setupStageIsStarted=false;windowCalc.setupStageIsFinished=false;windowCalc.setupStage++}}function stopAndRemoveAllWorkers(){if(windowCalc.timeout!=null){clearTimeout(windowCalc.timeout)}if(windowCalc.workers===null){return}for(let i=0;i<windowCalc.workers.length;i++){windowCalc.workers[i].terminate()}windowCalc.workers=null}function updateWorkerCount(msg){windowCalc.workersCount=msg;if(windowCalc.workers===null){return}if(windowCalc.minWorkersCount>windowCalc.workersCount){windowCalc.minWorkersCount=windowCalc.workersCount}if(windowCalc.maxWorkersCount<windowCalc.workersCount){windowCalc.maxWorkersCount=windowCalc.workersCount}for(let i=windowCalc.workers.length+1;i<=windowCalc.workersCount;i++){let newWorker=null;if(forceWorkerReload){newWorker=new Worker("calcsubworker.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now())}else{newWorker=new Worker("calcsubworker.js?v="+appVersion)}windowCalc.workers.push(newWorker);newWorker.onmessage=onSubWorkerMessage;assignChunkToWorker(newWorker)}}function removeWorkerIfNecessary(worker){if(windowCalc.workers.length<=windowCalc.workersCount){return false}const index=windowCalc.workers.indexOf(worker);if(index<0){return false}windowCalc.workers.splice(index,1);return true}var calculatePass=function(){if(windowCalc.stopped){return}calculateWindowPassChunks();for(const worker of windowCalc.workers){assignChunkToWorker(worker)}};function setupPixelPositionDelta(){windowCalc.referenceBottomLeftDeltaX=null;windowCalc.referenceBottomLeftDeltaY=null;if(windowCalc.algorithm.includes("basic")||windowCalc.referencePx===null||windowCalc.referencePy===null){return}windowCalc.referenceBottomLeftDeltaX=windowCalc.math.createFromInfNum(infNumSub(windowCalc.edges.left,windowCalc.referencePx));windowCalc.referenceBottomLeftDeltaY=windowCalc.math.createFromInfNum(infNumSub(windowCalc.edges.bottom,windowCalc.referencePy))}function buildChunkId(chunkPos){return infNumFastStr(chunkPos.x)+","+infNumFastStr(chunkPos.y)}var assignChunkToWorker=function(worker){if(windowCalc.stopped||windowCalc.xPixelChunks===null||windowCalc.xPixelChunks.length===0){return}if(!windowCalc.caching){let nextChunk=windowCalc.xPixelChunks.shift();let subWorkerMsg={plotId:windowCalc.plotId,chunk:nextChunk,cachedIndices:[]};worker.postMessage({t:"compute-chunk",v:subWorkerMsg});return}let nextChunk=windowCalc.xPixelChunks.shift();windowCalc.cacheScannedChunksCursor--;const chunkId=buildChunkId(nextChunk.chunkPos);let cacheScan=windowCalc.cacheScannedChunks.get(chunkId);if(cacheScan===undefined){scanCacheForChunk(nextChunk);cacheScan=windowCalc.cacheScannedChunks.get(chunkId)}let subWorkerMsg={plotId:windowCalc.plotId,chunk:nextChunk,cachedIndices:cacheScan.size===nextChunk.chunkLen?allCachedIndicesArray:Array.from(cacheScan.keys()).sort(((a,b)=>a-b))};worker.postMessage({t:"compute-chunk",v:subWorkerMsg});scanCacheForChunkBeyondCursor();scanCacheForChunkBeyondCursor()};function scanCacheForChunkBeyondCursor(){if(windowCalc.cacheScannedChunksCursor>=windowCalc.xPixelChunks.length-1||windowCalc.xPixelChunks.length===0){return}windowCalc.cacheScannedChunksCursor++;if(windowCalc.cacheScannedChunksCursor<0){windowCalc.cacheScannedChunksCursor=0}scanCacheForChunk(windowCalc.xPixelChunks[windowCalc.cacheScannedChunksCursor])}function scanCacheForChunk(chunk){const pxStr=infNumFastStr(chunk.chunkPos.x);const pyStr=infNumFastStr(chunk.chunkPos.y);const id=pxStr+","+pyStr;let py=chunk.chunkPos.y;let incY=chunk.chunkInc.y;let norm=normInfNum(py,incY);py=norm[0];incY=norm[1];const cachedValues=new Map;let cachedValue=null;const xCache=windowCalc.pointsCache.get(pxStr);if(xCache!==undefined){for(let i=0;i<chunk.chunkLen;i++){cachedValue=xCache.get(infNumFastStr(py));if(cachedValue!==undefined){cachedValues.set(i,cachedValue)}py=infNumAddNorm(py,incY)}}windowCalc.cacheScannedChunks.set(id,cachedValues)}function cacheComputedPointsInChunk(chunk){if(chunk.results.length===0){return 0}if(!windowCalc.caching){return chunk.results.length}let count=0;const pxStr=infNumFastStr(chunk.chunkPos.x);let xCache=windowCalc.pointsCache.get(pxStr);if(xCache===undefined){windowCalc.pointsCache.set(pxStr,new Map);xCache=windowCalc.pointsCache.get(pxStr)}let py=chunk.chunkPos.y;let incY=chunk.chunkInc.y;let norm=normInfNum(py,incY);py=norm[0];incY=norm[1];let calculatedValue=null;for(let i=0;i<chunk.chunkLen;i++){calculatedValue=chunk.results[i];if(calculatedValue!==undefined){count++;xCache.set(infNumFastStr(py),calculatedValue)}py=infNumAddNorm(py,incY)}return count}var onSubWorkerMessage=function(msg){if(msg.data.t=="completed-chunk"){handleSubworkerCompletedChunk(msg)}else if(msg.data.t=="send-reference-orbit"){handleReferenceOrbitRequest(msg)}else if(msg.data.t=="send-bla-tables"){handleBlaTablesRequest(msg)}else if(msg.data.t=="send-sa-coefficients"){handleSaCoefficientsRequest(msg)}else{console.log("worker received unknown message from subworker:",e)}};function handleReferenceOrbitRequest(msg){const worker=msg.target;worker.postMessage({t:"reference-orbit",v:{referencePx:windowCalc.referencePx,referencePy:windowCalc.referencePy,referenceOrbit:windowCalc.referenceOrbit,referencePlotId:windowCalc.plotId}})}function handleBlaTablesRequest(msg){const worker=msg.target;worker.postMessage({t:"bla-tables",v:{referencePx:windowCalc.referencePx,referencePy:windowCalc.referencePy,referenceBlaTables:windowCalc.referenceBlaTables,referencePlotId:windowCalc.plotId}})}function handleSaCoefficientsRequest(msg){const worker=msg.target;worker.postMessage({t:"sa-coefficients",v:{referencePx:windowCalc.referencePx,referencePy:windowCalc.referencePy,saCoefficients:windowCalc.saCoefficients,referencePlotId:windowCalc.plotId}})}function handleSubworkerCompletedChunk(msg){const isOutdatedWorker=msg.data.v.plotId!==windowCalc.plotId;if(!isOutdatedWorker){windowCalc.chunksComplete++}const worker=msg.target;const wasWorkerRemoved=removeWorkerIfNecessary(worker);if(windowCalc.stopped){return}if(!wasWorkerRemoved&&windowCalc.chunksComplete<windowCalc.totalChunks){assignChunkToWorker(worker)}if(!isOutdatedWorker){settleChunkWithCacheAndPublish({data:msg.data.v})}if(windowCalc.chunksComplete>=windowCalc.totalChunks){if(windowCalc.passBlaPixels>0){if(windowCalc.passBlaIterationsSkipped>0){console.log("for entire pass, ["+windowCalc.passBlaPixels.toLocaleString()+"] pixels skipped ["+windowCalc.passBlaIterationsSkipped.toLocaleString()+"] iters with BLA, avgs: ["+Math.floor(windowCalc.passBlaIterationsSkipped/windowCalc.passBlaPixels)+"] per pixel, ["+Math.floor(windowCalc.passBlaIterationsSkipped/windowCalc.passBlaSkips)+"] per skip")}else{console.log("for entire pass, no pixels had BLA iteration skips")}}if(isImageComplete()){cleanUpWindowCache()}else{calculatePass()}}}function settleChunkWithCacheAndPublish(msg){let workersCountToReport=windowCalc.minWorkersCount.toString();if(windowCalc.maxWorkersCount>windowCalc.minWorkersCount){workersCountToReport+="-"+windowCalc.maxWorkersCount}const computedPoints=cacheComputedPointsInChunk(msg.data);const prevCachedCount=windowCalc.passCachedPoints;windowCalc.passTotalPoints+=computedPoints;if(windowCalc.caching){const chunkId=buildChunkId(msg.data.chunkPos);let cacheScan=windowCalc.cacheScannedChunks.get(chunkId);if(cacheScan!==undefined){if(msg.data.results.length===0){msg.data.results=new Array(msg.data.chunkLen)}for(const entry of cacheScan){msg.data.results[entry[0]]=entry[1]}windowCalc.passCachedPoints+=cacheScan.size;windowCalc.cacheScannedChunks.delete(chunkId)}const newlySeenCachedPoints=windowCalc.passCachedPoints-prevCachedCount;windowCalc.passTotalPoints+=newlySeenCachedPoints}if("blaPixelsCount"in msg.data){windowCalc.passBlaPixels+=msg.data.blaPixelsCount;windowCalc.passBlaIterationsSkipped+=msg.data.blaIterationsSkipped;windowCalc.passBlaSkips+=msg.data.blaSkips}const status={chunks:windowCalc.totalChunks,chunksComplete:windowCalc.chunksComplete,pixelWidth:windowCalc.lineWidth,running:!isImageComplete(),workersCount:workersCountToReport,workersNow:windowCalc.workers.length,passPoints:windowCalc.passTotalPoints,passCachedPoints:windowCalc.passCachedPoints};if(windowCalc.saCoefficients!==null){status.saItersSkipped=windowCalc.saCoefficients.itersToSkip}msg.data.calcStatus=status;self.postMessage(msg.data)}function isImageComplete(){return windowCalc.chunksComplete===windowCalc.totalChunks&&windowCalc.lineWidth===windowCalc.finalWidth}function shuffleArray(array){for(let i=array.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[array[i],array[j]]=[array[j],array[i]]}}var calculateWindowPassChunks=function(){windowCalc.passNumber++;windowCalc.passBlaPixels=0;windowCalc.passBlaIterationsSkipped=0;windowCalc.passBlaSkips=0;windowCalc.passTotalPoints=0;windowCalc.passCachedPoints=0;windowCalc.chunksComplete=0;windowCalc.xPixelChunks=[];windowCalc.cacheScannedChunks=new Map;windowCalc.cacheScannedChunksCursor=-1;if(windowCalc.lineWidth===windowCalc.finalWidth){return}const potentialTempLineWidth=Math.round(windowCalc.lineWidth/2);if(potentialTempLineWidth<=windowCalc.finalWidth){windowCalc.lineWidth=windowCalc.finalWidth}else{windowCalc.lineWidth=potentialTempLineWidth}sendStatusMessage("Calculating pixels for "+windowCalc.lineWidth+"-wide pass");const pixelSize=windowCalc.lineWidth;const skipPrevPixels=!windowCalc.caching&&windowCalc.passNumber>startPassNumber;const yPointsPerChunk=Math.ceil(windowCalc.canvasHeight/pixelSize)+1;const yPointsPerChunkHalf=Math.ceil(yPointsPerChunk/2);const isBasic=windowCalc.algorithm.includes("basic");const incX=windowCalc.math.mul(windowCalc.eachPixUnitsM,windowCalc.math.createFromNumber(pixelSize));const incXTwice=windowCalc.math.mul(incX,windowCalc.math.createFromNumber(2));const zero=windowCalc.math.createFromNumber(0);let cursorX,yBottom;if(isBasic){cursorX=structuredClone(windowCalc.edgesM.left);yBottom=structuredClone(windowCalc.edgesM.bottom)}else{cursorX=structuredClone(windowCalc.referenceBottomLeftDeltaX);yBottom=structuredClone(windowCalc.referenceBottomLeftDeltaY)}const yBottomSkip=windowCalc.math.add(yBottom,incX);let chunkNum=0;for(let x=0;x<windowCalc.canvasWidth;x+=pixelSize){let chunk={plot:windowCalc.plot,chunkN:windowCalc.n,chunkPrecision:windowCalc.precision,algorithm:windowCalc.algorithm};if(skipPrevPixels&&chunkNum%2==0){Object.assign(chunk,{chunkPix:{x:x,y:windowCalc.canvasHeight-pixelSize},chunkPixInc:{x:0,y:-2*pixelSize},chunkPos:{x:structuredClone(cursorX),y:structuredClone(yBottomSkip)},chunkInc:{x:structuredClone(zero),y:structuredClone(incXTwice)},chunkLen:yPointsPerChunkHalf})}else{Object.assign(chunk,{chunkPix:{x:x,y:windowCalc.canvasHeight},chunkPixInc:{x:0,y:-1*pixelSize},chunkPos:{x:structuredClone(cursorX),y:structuredClone(yBottom)},chunkInc:{x:structuredClone(zero),y:structuredClone(incX)},chunkLen:yPointsPerChunk})}windowCalc.xPixelChunks.push(chunk);cursorX=windowCalc.math.add(cursorX,incX);chunkNum++}shuffleArray(windowCalc.xPixelChunks);windowCalc.totalChunks=windowCalc.xPixelChunks.length};function sendStatusMessage(message){self.postMessage({plotId:windowCalc.plotId,statusMessage:message})}function cleanUpWindowCache(){if(!windowCalc.caching){return}let cachedPointsDeleted=0;let cachedPointsKept=0;let cachedPxToDelete=[];let px=null;let py=null;for(const pxEntry of windowCalc.pointsCache){px=createInfNumFromFastStr(pxEntry[0]);if(infNumLt(px,windowCalc.edges.left)||infNumGt(px,windowCalc.edges.right)){cachedPxToDelete.push(pxEntry[0]);cachedPointsDeleted+=pxEntry[1].size}else{let cachedPyToDelete=[];for(const pyStr of pxEntry[1].keys()){py=createInfNumFromFastStr(pyStr);if(infNumLt(py,windowCalc.edges.bottom)||infNumGt(py,windowCalc.edges.top)){cachedPyToDelete.push(pyStr)}else{cachedPointsKept++}}for(const pyStr of cachedPyToDelete){pxEntry[1].delete(pyStr)}cachedPointsDeleted+=cachedPyToDelete.length}}for(const px of cachedPxToDelete){windowCalc.pointsCache.delete(px)}const deletedPct=Math.round(cachedPointsDeleted*1e4/(cachedPointsDeleted+cachedPointsKept))/100;console.log("deleted ["+cachedPointsDeleted+"] points from the cache ("+deletedPct+"%)")}