if(!self.structuredClone){BigInt.prototype.toJSON=function(){return this.toString()};self.structuredClone=function(obj){return JSON.parse(JSON.stringify(obj))}}const forceWorkerReloadUrlParam="force-worker-reload=true";const forceWorkerReload=self.location.toString().includes(forceWorkerReloadUrlParam);const urlParams=new URLSearchParams(self.location.search);const appVersion=urlParams.has("v")?urlParams.get("v"):"unk";if(forceWorkerReload){importScripts("infnum.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now());importScripts("floatexp.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now());importScripts("mathiface.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now());importScripts("plots.js?v="+appVersion+"&"+forceWorkerReloadUrlParam+"&t="+Date.now())}else{importScripts("infnum.js?v="+appVersion);importScripts("floatexp.js?v="+appVersion);importScripts("mathiface.js?v="+appVersion);importScripts("plots.js?v="+appVersion)}const plotsByName={};for(let i=0;i<plots.length;i++){plotsByName[plots[i].name]=plots[i]}var lastComputeChunkMsg=null;var referencePx=null;var referencePy=null;var referenceOrbit=null;var referencePlotId=null;var referenceBlaTables=null;var saCoefficients=null;var mathPlotId=null;var math=null;var algorithm=null;var smooth=null;self.onmessage=function(e){if(e.data.t=="compute-chunk"){lastComputeChunkMsg=e.data.v;algorithm=lastComputeChunkMsg.algorithm;smooth=lastComputeChunkMsg.smooth;if(referencePlotId!==null&&lastComputeChunkMsg.chunk.plotId!==referencePlotId){referenceOrbit=null;referenceBlaTables=null;saCoefficients=null}if(math===null||lastComputeChunkMsg.chunk.plotId!==mathPlotId){math=selectMathInterfaceFromAlgorithm(lastComputeChunkMsg.algorithm);mathPlotId=lastComputeChunkMsg.referencePlotId}}else if(e.data.t=="reference-orbit"){referencePx=e.data.v.referencePx;referencePy=e.data.v.referencePy;referenceOrbit=e.data.v.referenceOrbit;referencePlotId=e.data.v.referencePlotId}else if(e.data.t=="bla-tables"){referencePx=e.data.v.referencePx;referencePy=e.data.v.referencePy;referenceBlaTables=e.data.v.referenceBlaTables;referencePlotId=e.data.v.referencePlotId}else if(e.data.t=="sa-coefficients"){referencePx=e.data.v.referencePx;referencePy=e.data.v.referencePy;saCoefficients=e.data.v.saCoefficients;referencePlotId=e.data.v.referencePlotId}else{console.log("subworker received unknown message:",e)}if(lastComputeChunkMsg===null){return}if(referenceOrbit===null&&(lastComputeChunkMsg.algorithm.includes("perturb-")||lastComputeChunkMsg.algorithm.includes("bla-")||lastComputeChunkMsg.algorithm.includes("sapx"))){postMessage({t:"send-reference-orbit",v:0})}else if(referenceBlaTables===null&&lastComputeChunkMsg.algorithm.includes("bla-")){postMessage({t:"send-bla-tables",v:0})}else if(saCoefficients===null&&lastComputeChunkMsg.algorithm.includes("sapx")){postMessage({t:"send-sa-coefficients",v:0})}else{let chunk=lastComputeChunkMsg;lastComputeChunkMsg=null;computeChunk(chunk.plotId,chunk.chunk,chunk.cachedIndices)}};var computeChunk=function(plotId,chunk,cachedIndices){let blaPixelsCount=0;let blaIterationsSkipped=0;let blaSkips=0;if(cachedIndices.length===1&&cachedIndices[0]===-1){chunk.results=[];chunk.plotId=plotId;chunk.blaPixelsCount=blaPixelsCount;chunk.blaIterationsSkipped=blaIterationsSkipped;chunk.blaSkips=blaSkips;postMessage({t:"completed-chunk",v:chunk});return}const results=new Array(chunk.chunkLen);if(cachedIndices.length<chunk.chunkLen){if(algorithm.includes("basic-")){const computeFn=algorithm.includes("stripes-")?plotsByName[chunk.plot].computeBoundPointColorStripes:plotsByName[chunk.plot].computeBoundPointColor;const px=chunk.chunkPos.x;let py,incY;const isInfNum=math.name=="arbprecis";if(isInfNum){let norm=normInfNum(chunk.chunkPos.y,chunk.chunkInc.y);py=norm[0];incY=norm[1]}else{py=chunk.chunkPos.y;incY=chunk.chunkInc.y}for(let i=0;i<chunk.chunkLen;i++){if(!binarySearchIncludesNumber(cachedIndices,i)){results[i]=computeFn(chunk.chunkN,chunk.chunkPrecision,algorithm,px,py,smooth)}py=isInfNum?infNumAddNorm(py,incY):math.add(py,incY)}}else if(algorithm.includes("perturb-")){const perturbFn=plotsByName[chunk.plot].computeBoundPointColorPerturbOrBla;const dx=chunk.chunkPos.x;let dy=chunk.chunkPos.y;const incY=chunk.chunkInc.y;for(let i=0;i<chunk.chunkLen;i++){if(!binarySearchIncludesNumber(cachedIndices,i)){results[i]=perturbFn(chunk.chunkN,chunk.chunkPrecision,dx,dy,algorithm,referencePx,referencePy,referenceOrbit,referenceBlaTables,saCoefficients,smooth).colorpct}dy=math.add(dy,incY)}}else if(algorithm.includes("bla-")){const blaFn=plotsByName[chunk.plot].computeBoundPointColorPerturbOrBla;const dx=chunk.chunkPos.x;let dy=chunk.chunkPos.y;const incY=chunk.chunkInc.y;for(let i=0;i<chunk.chunkLen;i++){if(!binarySearchIncludesNumber(cachedIndices,i)){let pixelResult=blaFn(chunk.chunkN,chunk.chunkPrecision,dx,dy,algorithm,referencePx,referencePy,referenceOrbit,referenceBlaTables,saCoefficients,smooth);results[i]=pixelResult.colorpct;blaPixelsCount++;blaIterationsSkipped+=pixelResult.blaItersSkipped;blaSkips+=pixelResult.blaSkips}dy=math.add(dy,incY)}}}chunk.results=results;chunk.plotId=plotId;chunk.blaPixelsCount=blaPixelsCount;chunk.blaIterationsSkipped=blaIterationsSkipped;chunk.blaSkips=blaSkips;postMessage({t:"completed-chunk",v:chunk})};function binarySearchIncludesNumber(sortedArray,target){let lo=0;let hi=sortedArray.length-1;let x=null;let diff=null;while(lo<=hi){x=lo+hi>>1;diff=target-sortedArray[x];if(diff>0){lo=x+1}else if(diff<0){hi=x-1}else{return true}}return false}function fnv32a(str){var FNV1_32A_INIT=2166136261;var hval=FNV1_32A_INIT;for(var i=0;i<str.length;++i){hval^=str.charCodeAt(i);hval+=(hval<<1)+(hval<<4)+(hval<<7)+(hval<<8)+(hval<<24)}return hval>>>0}