if(typeof importScripts==="function"){let scriptAppVersion=null;if(!appVersion){scriptAppVersion=function(){let urlParams=new URLSearchParams(self.location.search);return urlParams.has("v")?urlParams.get("v"):"unk"}()}importScripts("infnum.js?v="+(appVersion||scriptAppVersion));importScripts("floatexp.js?v="+(appVersion||scriptAppVersion))}const windowCalcBackgroundColor=-1;const windowCalcIgnorePointColor=-2;const plots=[{name:"Mandelbrot-set",pageTitle:"Mandelbrot set",calcFrom:"window",desc:"The Mandelbrot set is the set of complex numbers, that when repeatedly plugged into the following "+"simple function, does <i>not</i> run away to infinity.  The function is z<sub>n+1</sub> = z<sub>n</sub><sup>2</sup> + c.<br/>"+"For each plotted point <code>c</code>, we repeat the above function many times.<br/>"+"If the value jumps off toward infinity after say 10 iterations, we display a color at the pixel for point <code>c</code>.<br/>"+"If the value doesn't go off toward infinity until say 50 iterations, we pick a quite different color for that point.<br/>"+"If, after our alloted number of iterations has been computed, the value still hasn't gone off to infinity, we color that pixel the backgrond color (defaulting to black)."+"<br/><br/>Wikipedia has a terrific <a target='_blank' href='https://en.wikipedia.org/wiki/Mandelbrot_set'>article with pictures</a>."+"<br/><br/>My favorite explanation I've found so far is <a target='_blank' href='https://www.youtube.com/watch?v=FFftmWSzgmk'>this Numberphile video on YouTube</a>."+"<br/><br/><b>Tips for using this Mandelbrot set viewer</b>:"+"<br/>- When not zoomed in very far, keep the <code>n</code> (iterations) parameter low for faster calculation (use N and M keys to decrease/increase the <code>n</code> value)."+"<br/>- To see more detail when zoomed in, increase the <code>n</code> (iterations) parameter with the M key.  Calculations will be slower.",gradientType:"mod",computeBoundPointColor:function(n,precis,algorithm,x,y,useSmooth){const maxIter=n;if(algorithm.includes("basic")&&algorithm.includes("float")){const bailoutSquared=useSmooth?32*32:4;let ix=0;let iy=0;let ixSq=0;let iySq=0;let ixTemp=0;let iter=0;while(iter<maxIter){ixSq=ix*ix;iySq=iy*iy;if(ixSq+iySq>bailoutSquared){break}ixTemp=x+(ixSq-iySq);iy=y+2*ix*iy;ix=ixTemp;iter++}if(iter>=maxIter){return windowCalcBackgroundColor}else{if(useSmooth){let fracIter=Math.log(ixSq+iySq)/2;fracIter=Math.log(fracIter/Math.LN2)/Math.LN2;iter+=1-fracIter}return iter}}const math=selectMathInterfaceFromAlgorithm(algorithm);const xConv=math.createFromInfNum(x);const yConv=math.createFromInfNum(y);var ix=structuredClone(math.zero);var iy=structuredClone(math.zero);var ixSq=structuredClone(math.zero);var iySq=structuredClone(math.zero);var ixTemp=structuredClone(math.zero);var iter=0;try{while(iter<maxIter){ixSq=math.mul(ix,ix);iySq=math.mul(iy,iy);if(math.gt(math.add(ixSq,iySq),math.four)){break}ixTemp=math.add(xConv,math.sub(ixSq,iySq));iy=math.add(yConv,math.mul(math.two,math.mul(ix,iy)));ix=ixTemp;ix=math.truncateToSigDig(ix,precis);iy=math.truncateToSigDig(iy,precis);iter++}if(iter==maxIter){return windowCalcBackgroundColor}else{return iter}}catch(e){console.log("ERROR CAUGHT when processing point (x, y, iter, maxIter): ["+math.toExpString(x)+", "+math.toExpString(y)+", "+iter+", "+maxIter+"]:");console.log(e.name+": "+e.message+":\n"+e.stack.split("\n").slice(0,5).join("\n"));return windowCalcIgnorePointColor}},computeReferenceOrbit:function(n,precis,algorithm,x,y,period,useSmooth,fnContext){const outputMath=selectMathInterfaceFromAlgorithm(algorithm);const outputIsFloatExp=outputMath.name=="floatexp";const periodLessThanN=period!==null&&period>0&&period<n;const maxIter=periodLessThanN?period:n;const two=infNum(2n,0n);const four=infNum(4n,0n);const sixteen=infNum(16n,0n);const bailoutSquared=useSmooth?infNum(32n*32n*2n,0n):sixteen;if(fnContext===null){fnContext={ix:infNum(0n,0n),iy:infNum(0n,0n),iter:0,orbit:[],status:"",done:false}}var ixSq=infNum(0n,0n);var iySq=infNum(0n,0n);var ixTemp=infNum(0n,0n);var statusIterCounter=0;try{while(fnContext.iter<maxIter){ixSq=infNumMul(fnContext.ix,fnContext.ix);iySq=infNumMul(fnContext.iy,fnContext.iy);if(infNumGt(infNumAdd(ixSq,iySq),bailoutSquared)){break}fnContext.orbit.push({x:outputMath.createFromInfNum(fnContext.ix),y:outputMath.createFromInfNum(fnContext.iy),xfxp:outputIsFloatExp?null:floatExpMath.createFromInfNum(fnContext.ix),yfxp:outputIsFloatExp?null:floatExpMath.createFromInfNum(fnContext.iy)});ixTemp=infNumAdd(x,infNumSub(ixSq,iySq));fnContext.iy=infNumAdd(y,infNumMul(two,infNumMul(fnContext.ix,fnContext.iy)));fnContext.ix=copyInfNum(ixTemp);fnContext.ix=infNumTruncateToLen(fnContext.ix,precis);fnContext.iy=infNumTruncateToLen(fnContext.iy,precis);fnContext.iter++;statusIterCounter++;if(statusIterCounter>=5e3){statusIterCounter=0;fnContext.status="computed "+Math.round(fnContext.iter*1e4/maxIter)/100+"% of reference orbit";console.log(fnContext.status);return fnContext}}if(periodLessThanN&&fnContext.iter>=maxIter){for(let i=0;i<n-period;i++){fnContext.orbit.push(structuredClone(fnContext.orbit[i%period]))}}fnContext.done=true;return fnContext}catch(e){console.log("ERROR CAUGHT when computing reference orbit at point (x, y, iter, maxIter): ["+infNumToString(x)+", "+infNumToString(y)+", "+iter+", "+maxIter+"]:");console.log(e.name+": "+e.message+":\n"+e.stack.split("\n").slice(0,5).join("\n"));fnContext.done=true;return fnContext}},computeReferencePeriod:function(n,precis,algorithm,x,y,boxDelta,fnContext){const outputMath=selectMathInterfaceFromAlgorithm(algorithm);const outputIsFloatExp=outputMath.name=="floatexp";const maxIter=n;const two=infNum(2n,0n);const four=infNum(4n,0n);const sixteen=infNum(16n,0n);const bailoutSquared=four;if(fnContext===null){fnContext={x:[infNumAdd(x,boxDelta),infNumAdd(x,boxDelta),infNumSub(x,boxDelta),infNumSub(x,boxDelta)],y:[infNumAdd(y,boxDelta),infNumSub(y,boxDelta),infNumSub(y,boxDelta),infNumAdd(y,boxDelta)],ix:[infNum(0n,0n),infNum(0n,0n),infNum(0n,0n),infNum(0n,0n)],iy:[infNum(0n,0n),infNum(0n,0n),infNum(0n,0n),infNum(0n,0n)],iter:0,period:-1,status:"",done:false}}var ixSq=infNum(0n,0n);var iySq=infNum(0n,0n);var ixTemp=infNum(0n,0n);var statusIterCounter=0;try{while(fnContext.iter<maxIter){for(let i=0;i<4;i++){ixSq=infNumMul(fnContext.ix[i],fnContext.ix[i]);iySq=infNumMul(fnContext.iy[i],fnContext.iy[i]);if(infNumGt(infNumAdd(ixSq,iySq),bailoutSquared)){fnContext.done=true;fnContext.period=-1;return fnContext}ixTemp=infNumAdd(fnContext.x[i],infNumSub(ixSq,iySq));fnContext.iy[i]=infNumAdd(fnContext.y[i],infNumMul(two,infNumMul(fnContext.ix[i],fnContext.iy[i])));fnContext.ix[i]=copyInfNum(ixTemp);fnContext.ix[i]=infNumTruncateToLen(fnContext.ix[i],precis);fnContext.iy[i]=infNumTruncateToLen(fnContext.iy[i],precis)}fnContext.iter++;let edgesMeetingCriterion=0;for(let a=0;a<4;a++){let b=a==3?0:a+1;if(fnContext.ix[a].v>0n&&fnContext.ix[b].v>0n&&(fnContext.iy[a].v>0n&&fnContext.iy[b].v<0n||fnContext.iy[a].v<0n&&fnContext.iy[b].v>0n)){edgesMeetingCriterion++}}if(edgesMeetingCriterion==1||edgesMeetingCriterion==3){fnContext.done=true;fnContext.period=fnContext.iter;return fnContext}statusIterCounter++;if(statusIterCounter>=1e3){statusIterCounter=0;fnContext.status="computed "+Math.round(fnContext.iter*1e4/maxIter)/100+"% of period orbit";console.log(fnContext.status);return fnContext}}}catch(e){console.log("ERROR CAUGHT when computing reference period at point (x, y, iter, maxIter): ["+infNumToString(x)+", "+infNumToString(y)+", "+iter+", "+maxIter+"]:");console.log(e.name+": "+e.message+":\n"+e.stack.split("\n").slice(0,5).join("\n"))}fnContext.done=true;fnContext.period=-1;return fnContext},computeSaCoefficients:function(precision,algorithm,referenceX,referenceY,referenceOrbit,windowEdges,fnContext){const math=floatExpMath;const algoMath=selectMathInterfaceFromAlgorithm(algorithm);const algoMathIsFloatExp=algoMath.name=="floatexp";if(fnContext===null){let nTerms=3;let dimDiv=3;try{let sapx=algorithm.split("-").find((e=>e.startsWith("sapx"))).substring(4).split(".");nTerms=Math.max(3,Math.min(128,parseInt(BigInt(sapx[0]).toString())));dimDiv=Math.max(1,Math.min(7,parseInt(BigInt(sapx[1]).toString())))}catch{}let testPoints=[];let py=windowEdges.top;let xStep=infNumDiv(infNumSub(windowEdges.right,windowEdges.left),infNum(BigInt(dimDiv),0n),precision);let yStep=infNumDiv(infNumSub(windowEdges.top,windowEdges.bottom),infNum(BigInt(dimDiv),0n),precision);for(let i=0;i<=dimDiv;i++){let px=windowEdges.left;for(let j=0;j<=dimDiv;j++){testPoints.push({x:copyInfNum(px),y:copyInfNum(py)});px=infNumAdd(px,xStep)}py=infNumAdd(py,yStep)}let terms=new Array(nTerms).fill({x:math.zero,y:math.zero});terms[0]={x:math.one,y:math.zero};fnContext={nTerms:nTerms,termShrinkCutoff:math.createFromNumber(1e3*1e3),testPoints:testPoints,terms:terms,itersToSkip:-1,refOrbitIter:0,saCoefficients:{itersToSkip:0,coefficients:[]},status:"",done:false}}if(fnContext.nTerms<=0){console.log("series approximation has 0 or fewer terms in the algorithm name ["+algorithm+"], so NOT doing SA");fnContext.done=true;return fnContext}let twoRefIter=null;const nextTerms=new Array(fnContext.nTerms);let i=fnContext.refOrbitIter;let statusIterCounter=0;for(;i<referenceOrbit.length-3;i++){twoRefIter=algoMathIsFloatExp?math.complexRealMul(referenceOrbit[i],math.two):math.complexRealMul({x:referenceOrbit[i].xfxp,y:referenceOrbit[i].yfxp},math.two);for(let k=0;k<fnContext.nTerms;k++){if(k===0){nextTerms[k]=math.complexRealAdd(math.complexMul(twoRefIter,fnContext.terms[k]),math.one)}else if(k%2===0){nextTerms[k]=math.complexMul(twoRefIter,fnContext.terms[k]);for(let up=0,dn=k-1;up<dn;up++,dn--){nextTerms[k]=math.complexAdd(nextTerms[k],math.complexRealMul(math.complexMul(fnContext.terms[up],fnContext.terms[dn]),math.two))}}else{nextTerms[k]=math.complexMul(twoRefIter,fnContext.terms[k]);for(let up=0,dn=k-1;up<=dn;up++,dn--){if(up===dn){nextTerms[k]=math.complexAdd(nextTerms[k],math.complexMul(fnContext.terms[up],fnContext.terms[dn]))}else{nextTerms[k]=math.complexAdd(nextTerms[k],math.complexRealMul(math.complexMul(fnContext.terms[up],fnContext.terms[dn]),math.two))}}}}let validTestPoints=0;for(let p=0;p<fnContext.testPoints.length;p++){let deltaC={x:math.createFromInfNum(infNumSub(fnContext.testPoints[p].x,referenceX)),y:math.createFromInfNum(infNumSub(fnContext.testPoints[p].y,referenceY))};let coefTermsAreValid=false;for(let j=1;j<fnContext.nTerms;j++){let deltaCpower=structuredClone(deltaC);let firstSmallest=null;let secondLargest=null;for(let k=0;k<j;k++){let wholeTerm=math.complexAbsSquared(math.complexMul(deltaCpower,nextTerms[k]));if(firstSmallest===null||math.lt(wholeTerm,firstSmallest)){firstSmallest=structuredClone(wholeTerm)}deltaCpower=math.complexMul(deltaCpower,deltaC)}for(let k=j;k<fnContext.nTerms;k++){let wholeTerm=math.complexAbsSquared(math.complexMul(deltaCpower,nextTerms[k]));if(secondLargest===null||math.gt(wholeTerm,secondLargest)){secondLargest=structuredClone(wholeTerm)}deltaCpower=math.complexMul(deltaCpower,deltaC)}if(secondLargest.v===0n){coefTermsAreValid=true;break}let ratio=math.div(firstSmallest,secondLargest);if(math.gt(ratio,fnContext.termShrinkCutoff)){coefTermsAreValid=true;break}}if(coefTermsAreValid){validTestPoints++}else{console.log("SA test point ["+p+"] is not valid at iteraition ["+i+"]");break}}if(validTestPoints<fnContext.testPoints.length){fnContext.itersToSkip=i;fnContext.done=true;console.log("SA stopping with ["+i+"] valid iterations");break}for(let j=0;j<fnContext.nTerms;j++){fnContext.terms[j]=nextTerms[j]}statusIterCounter++;if(statusIterCounter>=5e3){fnContext.status="can skip "+Math.round(i*1e4/referenceOrbit.length)/100+"% of reference orbit";console.log("all test points are valid for skipping ["+i.toLocaleString()+"] iterations");fnContext.refOrbitIter=i+1;return fnContext}}fnContext.done=true;if(fnContext.itersToSkip<0){console.log("able to skip ALL ["+i+"/"+referenceOrbit.length+"] iterations of the reference orbit with ["+fnContext.nTerms+"]-term SA... hmm... perhaps N is set too low");fnContext.saCoefficients={itersToSkip:i,coefficients:fnContext.terms}}else{console.log("able to skip ["+fnContext.itersToSkip+"] iterations with ["+fnContext.nTerms+"]-term SA");fnContext.saCoefficients={itersToSkip:fnContext.itersToSkip,coefficients:fnContext.terms}}return fnContext},computeBlaTables:function(algorithm,referenceOrbit,fnContext){const math=selectMathInterfaceFromAlgorithm(algorithm);if(fnContext===null){fnContext={epsilon:math.createFromInfNum(infNum(1n,-340n)),blaTables:{coefTable:new Map,epsilonRefAbsTable:new Map},blaCoeffIterM:0,epsRefOrbitIter:0,status:"",done:false};console.log("using epsilon: "+math.toExpString(fnContext.epsilon))}let maxIter=referenceOrbit.length-3;let m=fnContext.blaCoeffIterM;let statusIterCounter=0;for(;m<maxIter;m++){fnContext.blaTables.coefTable.set(m,new Map);let a={x:math.one,y:math.zero};let b={x:math.zero,y:math.zero};let refDoubled=null;let l=1;for(;l<maxIter-m-2&&l<513;l++){refDoubled=math.complexRealMul(referenceOrbit[m+l],math.two);if(l==1){a=refDoubled;b={x:math.one,y:math.zero}}else{a=math.complexMul(refDoubled,a);b=math.complexAdd(math.complexMul(refDoubled,b),{x:math.one,y:math.zero})}if(l==2||l==4||l==8||l==16||l==32||l==64||l==128||l==256||l==512||l==1024||l%2048==0){fnContext.blaTables.coefTable.get(m).set(l,{a:structuredClone(a),b:structuredClone(b)})}}statusIterCounter++;if(statusIterCounter>=1e3){fnContext.blaCoeffIterM=m+1;let doneIters=maxIter*m-(m-1)/2*(m-1)+(m-1)/2;let totalIters=maxIter/2*maxIter+maxIter/2;fnContext.status="computed "+Math.round(doneIters*1e4/totalIters)/100+"% of BLA coefficients (m ["+m+"] of ["+maxIter+"])";console.log(fnContext.status);return fnContext}}fnContext.blaCoeffIterM=m;statusIterCounter=0;maxIter=referenceOrbit.length;let i=fnContext.epsRefOrbitIter;for(;i<maxIter;i++){fnContext.blaTables.epsilonRefAbsTable.set(i,math.mul(math.complexAbs(math.complexRealMul(referenceOrbit[i],math.two)),fnContext.epsilon));statusIterCounter++;if(statusIterCounter>=1e4){fnContext.epsRefOrbitIter=i+1;fnContext.status="computed "+Math.round(i*1e4/maxIter)/100+"% of BLA epsilon criteria";console.log(fnContext.status);return fnContext}}fnContext.epsRefOrbitIter=i;fnContext.done=true;return fnContext},computeBoundPointColorPerturbOrBla:function(n,precis,dx,dy,algorithm,referenceX,referenceY,referenceOrbit,blaTables,saCoefficients,useSmooth){const math=selectMathInterfaceFromAlgorithm(algorithm);const bailoutSquared=useSmooth?math.createFromNumber(32*32):math.four;const useBla=algorithm.includes("bla-");const useSa=algorithm.includes("sapx");const maxIter=n;let deltaC={x:dx,y:dy};const deltaCAbs=math.complexAbs(deltaC);let iter=0;const maxReferenceIter=referenceOrbit.length-2;let referenceIter=0;let deltaZ={x:math.zero,y:math.zero};let z=null;let zAbs=null;let deltaZAbs=null;if(useSa&&saCoefficients!==null&&saCoefficients.itersToSkip>0){let deltaCFloatExp={x:math.name=="floatexp"?structuredClone(deltaC.x):floatExpMath.createFromExpString(math.toExpString(deltaC.x)),y:math.name=="floatexp"?structuredClone(deltaC.y):floatExpMath.createFromExpString(math.toExpString(deltaC.y))};let deltaZFloatExp={x:floatExpMath.zero,y:floatExpMath.zero};let deltaCpower=structuredClone(deltaCFloatExp);for(let i=0;i<saCoefficients.coefficients.length;i++){deltaZFloatExp=floatExpMath.complexAdd(deltaZFloatExp,floatExpMath.complexMul(saCoefficients.coefficients[i],deltaCpower));deltaCpower=floatExpMath.complexMul(deltaCpower,deltaCFloatExp)}iter+=saCoefficients.itersToSkip;referenceIter+=saCoefficients.itersToSkip;if(math.name=="floatexp"){deltaZ=deltaZFloatExp}else{deltaZ={x:math.createFromExpString(floatExpMath.toExpString(deltaZFloatExp.x)),y:math.createFromExpString(floatExpMath.toExpString(deltaZFloatExp.y))}}}let blaItersSkipped=0;let blaSkips=0;try{while(iter<maxIter){deltaZ=math.complexAdd(math.complexAdd(math.complexMul(math.complexRealMul(referenceOrbit[referenceIter],math.two),deltaZ),math.complexMul(deltaZ,deltaZ)),deltaC);iter++;referenceIter++;z=math.complexAdd(referenceOrbit[referenceIter],deltaZ);zAbs=math.complexAbsSquared(z);if(math.gt(zAbs,bailoutSquared)){iter--;break}deltaZAbs=math.complexAbsSquared(deltaZ);if(math.lt(zAbs,deltaZAbs)||referenceIter==maxReferenceIter){deltaZ=z;referenceIter=0}else if(useBla){let goodL=null;if(referenceIter/maxReferenceIter<.95){let blaL=null;let epsilonRefAbs=null;let coefTable=blaTables.coefTable.get(referenceIter);for(const entry of coefTable){epsilonRefAbs=blaTables.epsilonRefAbsTable.get(referenceIter+entry[0]);if(math.lt(math.complexAbs(math.complexAdd(math.complexMul(entry[1].a,deltaZ),math.complexMul(entry[1].b,deltaC))),epsilonRefAbs)){goodL=entry[0]}else{break}}}if(goodL!==null){deltaZ=math.complexAdd(math.complexMul(blaTables.coefTable.get(referenceIter).get(goodL).a,deltaZ),math.complexMul(blaTables.coefTable.get(referenceIter).get(goodL).b,deltaC));iter+=goodL;referenceIter+=goodL;blaItersSkipped+=goodL;blaSkips++;if(referenceIter>=maxReferenceIter){console.log("somehow we have to re-base to beginning of ref orbit");deltaZ=math.complexAdd(referenceOrbit[referenceIter],deltaZ);referenceIter=0}}}}if(iter==maxIter){return{colorpct:windowCalcBackgroundColor,blaItersSkipped:blaItersSkipped,blaSkips:blaSkips}}else{if(useSmooth){let fracIter=math.log(math.complexAbsSquared(z))/2;fracIter=Math.log(fracIter/Math.LN2)/Math.LN2;iter+=1-fracIter}return{colorpct:iter,blaItersSkipped:blaItersSkipped,blaSkips:blaSkips}}}catch(e){console.log("ERROR CAUGHT when calculating ["+algorithm+"] pixel color",{x:infNumToString(x),y:infNumToString(y),iter:iter,maxIter:maxIter,refIter:referenceIter,maxRefIter:maxReferenceIter});console.log(e.name+": "+e.message+":\n"+e.stack.split("\n").slice(0,5).join("\n"));return{colorpct:windowCalcIgnorePointColor,blaItersSkipped:blaItersSkipped,blaSkips:blaSkips}}},forcedDefaults:{n:100,mag:infNum(1n,0n),centerX:createInfNum("-0.65"),centerY:infNum(0n,0n)},magnificationFactor:infNum(3n,0n),privContext:{usesImaginaryCoordinates:true,adjustPrecision:function(scale,usingWorkers){const precisScale=infNumTruncateToLen(scale,8);const ret={roughScale:infNumExpString(precisScale),precision:12,algorithm:"basic-float"};if(infNumGe(precisScale,createInfNum("1e800"))){ret.algorithm="perturb-sapx32-floatexp"}else if(infNumGe(precisScale,createInfNum("1e500"))){ret.algorithm="perturb-sapx16-floatexp"}else if(infNumGe(precisScale,createInfNum("1e304"))){ret.algorithm="perturb-sapx8-floatexp"}else if(infNumGe(precisScale,createInfNum("1e200"))){ret.algorithm="perturb-sapx6-float"}else if(infNumGe(precisScale,createInfNum("1e100"))){ret.algorithm="perturb-sapx4-float"}else if(infNumGe(precisScale,createInfNum("3e13"))){ret.algorithm="perturb-float"}if(infNumLt(precisScale,createInfNum("1e3"))){ret.precision=12}else if(infNumLt(precisScale,createInfNum("2e6"))){ret.precision=12}else if(infNumLt(precisScale,createInfNum("3e13"))){ret.precision=20}else if(infNumLt(precisScale,createInfNum("1e40"))){ret.precision=Math.floor(infNumMagnitude(precisScale)*1.7)}else if(infNumLt(precisScale,createInfNum("1e60"))){ret.precision=Math.floor(infNumMagnitude(precisScale)*1.5)}else if(infNumLt(precisScale,createInfNum("1e100"))){ret.precision=Math.floor(infNumMagnitude(precisScale)*1.4)}else if(infNumLt(precisScale,createInfNum("1e150"))){ret.precision=Math.floor(infNumMagnitude(precisScale)*1.25)}else if(infNumLt(precisScale,createInfNum("1e200"))){ret.precision=Math.floor(infNumMagnitude(precisScale)*1.1)}else{ret.precision=Math.floor(infNumMagnitude(precisScale)*1.01)}if(!usingWorkers){if(infNumGe(precisScale,createInfNum("1e304"))){ret.algorithm="perturb-floatexp"}else if(infNumGe(precisScale,createInfNum("3e13"))){ret.algorithm="perturb-float"}else{ret.algorithm="basic-float"}}console.log("default mandelbrot settings for scale:",ret);return ret},listAlgorithms:function(){return[{algorithm:"auto",name:"automatic"},{algorithm:"basic-float",name:"basic escape time, floating point"},{algorithm:"basic-floatexp",name:"basic escape time, floatexp"},{algorithm:"perturb-float",name:"perturbation theory, floating point"},{algorithm:"perturb-floatexp",name:"perturbation theory, floatexp"},{algorithm:"perturb-sapx4-float",name:"perturb. w/series approx., floating point"},{algorithm:"perturb-sapx8-floatexp",name:"perturb. w/series approx., floatexp"},{algorithm:"perturb-sapx6.4-floatexp-sigdig64",name:"custom"}]},minScale:createInfNum("20")}},{name:"Primes-1-Step-90-turn",pageTitle:"Primes",calcFrom:"sequence",desc:'Drawn with a simple <a target="blank" href="https://en.wikipedia.org/wiki/Turtle_graphics">'+"turtle graphics</a> pattern: move 1 step forward per integer, but for primes, turn 90 degrees clockwise before moving.",gradientType:"pct",computePointsAndLength:function(privContext){var resultPoints=[];var resultLength=0;if(historyParams.n>5e6){historyParams.n=5e6}const params=historyParams;resultPoints.push(getPoint(0,0));var nextPoint=getPoint(0,0);privContext.direction=0;for(var i=1;i<params.n;i++){if(isPrime(i)){nextPoint.v={prime:i.toLocaleString()};resultPoints.push(nextPoint);privContext.direction=privContext.changeDirection(privContext.direction)}nextPoint=privContext.computeNextPoint(privContext.direction,i,nextPoint.x,nextPoint.y,{last:(i+1).toLocaleString()});resultLength+=1}if(isPrime(parseInt(nextPoint.v.last))){nextPoint.v={prime:nextPoint.v.last}}resultPoints.push(nextPoint);return{points:resultPoints,length:resultLength}},forcedDefaults:{n:6e4,mag:infNum(1n,0n),centerX:createInfNum("-240"),centerY:createInfNum("288")},magnificationFactor:infNum(850n,0n),privContext:{direction:0,changeDirection:function(dir){return changeDirectionDegrees(dir,90)},computeNextPoint:function(dir,n,x,y,v){return computeNextPointDegrees(dir,1,x,y,v)}}},{name:"Primes-1-Step-45-turn",pageTitle:"Primes",calcFrom:"sequence",desc:'Drawn with a simple <a target="blank" href="https://en.wikipedia.org/wiki/Turtle_graphics">'+"turtle graphics</a> pattern: move 1 step forward per integer, but for primes, turn 45 degrees "+"clockwise before moving. When moving diagonally, we move 1 step on both the x and y axes, so we're "+"actually moving ~1.414 steps diagonally.",gradientType:"pct",computePointsAndLength:function(privContext){var resultPoints=[];var resultLength=0;if(historyParams.n>5e6){historyParams.n=5e6}const params=historyParams;resultPoints.push(getPoint(0,0));var nextPoint=getPoint(0,0);privContext.direction=315;for(var i=1;i<params.n;i++){if(isPrime(i)){nextPoint.v={prime:i.toLocaleString()};resultPoints.push(nextPoint);privContext.direction=privContext.changeDirection(privContext.direction)}nextPoint=privContext.computeNextPoint(privContext.direction,i,nextPoint.x,nextPoint.y,{last:(i+1).toLocaleString()});resultLength+=1}if(isPrime(parseInt(nextPoint.v.last))){nextPoint.v={prime:nextPoint.v.last}}resultPoints.push(nextPoint);return{points:resultPoints,length:resultLength}},forcedDefaults:{n:6e4,mag:infNum(1n,0n),centerX:infNum(0n,0n),centerY:infNum(415n,0n)},magnificationFactor:infNum(1600n,0n),privContext:{direction:0,changeDirection:function(dir){return changeDirectionDegrees(dir,45)},computeNextPoint:function(dir,n,x,y,v){return computeNextPointDegrees(dir,1,x,y,v)}}},{name:"Squares-1-Step-90-turn",pageTitle:"Squares",calcFrom:"sequence",desc:'Drawn with a simple <a target="blank" href="https://en.wikipedia.org/wiki/Turtle_graphics">'+"turtle graphics</a> pattern: move 1 step forward per integer, but for perfect squares, turn 90 "+"degrees clockwise before moving.",gradientType:"pct",computePointsAndLength:function(privContext){var resultPoints=[];var resultLength=0;if(historyParams.n>1e6){historyParams.n=1e6}const params=historyParams;var nextPoint=getPoint(0,0);privContext.direction=270;for(var i=1;i<params.n;i+=1){if(privContext.isSquare(i)){resultPoints.push(nextPoint);privContext.direction=privContext.changeDirection(privContext.direction)}nextPoint=privContext.computeNextPoint(privContext.direction,i,nextPoint.x,nextPoint.y,{square:(i+1).toLocaleString()});resultLength+=1}if(!privContext.isSquare(parseInt(nextPoint.v.square))){nextPoint.v={last:nextPoint.v.square}}resultPoints.push(nextPoint);return{points:resultPoints,length:resultLength}},forcedDefaults:{n:5e3,mag:infNum(1n,0n),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},magnificationFactor:infNum(175n,0n),privContext:{direction:0,changeDirection:function(dir){return changeDirectionDegrees(dir,90)},computeNextPoint:function(dir,n,x,y,v){return computeNextPointDegrees(dir,1,x,y,v)},isSquare:function(n){const sqrt=Math.sqrt(n);return sqrt==Math.trunc(sqrt)}}},{name:"Squares-1-Step-45-turn",pageTitle:"Squares",calcFrom:"sequence",desc:'Drawn with a simple <a target="blank" href="https://en.wikipedia.org/wiki/Turtle_graphics">'+"turtle graphics</a> pattern: move 1 step forward per integer, but for perfect squares, turn 45 "+"degrees clockwise before moving.  When moving diagonally, we move 1 step on both the x and y axes, "+"so we're actually moving ~1.414 steps diagonally.",gradientType:"pct",computePointsAndLength:function(privContext){var resultPoints=[];var resultLength=0;const diagHypot=Math.sqrt(2);if(historyParams.n>1e6){historyParams.n=1e6}const params=historyParams;var nextPoint=getPoint(0,0);privContext.direction=270;for(var i=1;i<params.n;i+=1){if(privContext.isSquare(i)){resultPoints.push(nextPoint);privContext.direction=privContext.changeDirection(privContext.direction)}nextPoint=privContext.computeNextPoint(privContext.direction,i,nextPoint.x,nextPoint.y,{square:(i+1).toLocaleString()});resultLength+=privContext.direction%90==0?1:diagHypot}if(!privContext.isSquare(parseInt(nextPoint.v.square))){nextPoint.v={last:nextPoint.v.square}}resultPoints.push(nextPoint);return{points:resultPoints,length:resultLength}},forcedDefaults:{n:5e3,mag:infNum(1n,0n),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},magnificationFactor:infNum(500n,0n),privContext:{direction:0,changeDirection:function(dir){return changeDirectionDegrees(dir,45)},computeNextPoint:function(dir,n,x,y,v){return computeNextPointDegrees(dir,1,x,y,v)},isSquare:function(n){const sqrt=Math.sqrt(n);return sqrt==Math.trunc(sqrt)}}},{name:"Primes-X-Y-neg-mod-3",pageTitle:"Primes",calcFrom:"sequence",desc:"Where each plotted point <code>(x,y)</code> consists of the primes, in order.  "+"Those points are (2,3), (5,7), (11,13), and so on.<br/><br/>"+"Then we take the sum of the digits of both the <code>x</code> and <code>y</code> of each point.<br/>"+"If that sum, mod 3, is 1, the <code>x</code> is negated.<br/>"+"If that sum, mod 3, is 2, the <code>y</code> is negated.<br/><br/>"+"After applying the negation rule, the first three plotted points become:<br/>"+"<code>(2,3)&nbsp;&nbsp;→ sum digits = 5&nbsp;&nbsp;mod 3 = 2 → -y → (2,-3)</code><br/>"+"<code>(5,7)&nbsp;&nbsp;→ sum digits = 12 mod 3 = 0 →&nbsp;&nbsp;&nbsp;&nbsp;→ (5,7)</code><br/>"+"<code>(11,13)→ sum digits = 6&nbsp;&nbsp;mod 3 = 0 →&nbsp;&nbsp;&nbsp;&nbsp;→ (11,13)</code>",gradientType:"pct",computePointsAndLength:function(privContext){var resultPoints=[];var resultLength=0;if(historyParams.n>1e6){historyParams.n=1e6}const params=historyParams;var lastX=-1;var lastPoint=getPoint(0,0);resultPoints.push(lastPoint);for(var i=1;i<params.n;i+=1){if(!isPrime(i)){continue}if(lastX==-1){lastX=i}else{var thisY=i;const digits=(lastX.toString()+thisY.toString()).split("");var digitsSum=0;for(var j=0;j<digits.length;j++){digitsSum+=digits[j]}const digitsSumMod4=digitsSum%3;if(digitsSumMod4==1){lastX=lastX*-1}else if(digitsSumMod4==2){thisY=thisY*-1}const nextPoint=getPoint(parseFloat(lastX),parseFloat(thisY),{prime:i.toLocaleString()});resultLength+=Math.hypot(nextPoint.x-lastPoint.x,nextPoint.y-lastPoint.y);resultPoints.push(nextPoint);lastX=-1;lastPoint=nextPoint}}return{points:resultPoints,length:resultLength}},forcedDefaults:{n:5e3,mag:infNum(1n,0n),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},magnificationFactor:infNum(12000n,0n),privContext:{}},{name:"Trapped-Knight",pageTitle:"Trapped Knight",calcFrom:"sequence",desc:"On a chessboard, where the squares are numbered in a spiral, "+"find the squares a knight can jump to in sequence where the "+"smallest-numbered square must always be taken.  Previously-"+"visited squares cannot be returned to again.  After more than "+"2,000 jumps the knight has no valid squares to jump to, so the "+"sequence ends.<br/><br/>"+"Credit to The Online Encyclopedia of Integer Sequences:<br/>"+"<a target='_blank' href='https://oeis.org/A316667'>https://oeis.org/A316667</a><br/>"+"and to Numberphile:<br/>"+"<a target='_blank' href='https://www.youtube.com/watch?v=RGQe8waGJ4w'>https://www.youtube.com/watch?v=RGQe8waGJ4w</a>",gradientType:"pct",computePointsAndLength:function(privContext){var resultPoints=[];var resultLength=0;privContext.visitedSquares={};const params=historyParams;var nextPoint=getPoint(0,0);if(!privContext.isNumberedSquare(privContext,nextPoint)){let testPoint=nextPoint;privContext.trackNumberedSquare(privContext,0,nextPoint);let testDirection=0;let direction=90;for(let i=1;i<3562;i+=1){testDirection=privContext.changeDirection(direction);testPoint=privContext.computeNextPoint(testDirection,1,nextPoint.x,nextPoint.y);if(!privContext.isNumberedSquare(privContext,testPoint)){direction=testDirection;nextPoint=testPoint}else{nextPoint=privContext.computeNextPoint(direction,1,nextPoint.x,nextPoint.y)}privContext.trackNumberedSquare(privContext,i,nextPoint)}}var lastPoint=getPoint(0,0);resultPoints.push(lastPoint);privContext.visitSquare(privContext,0,lastPoint);var reachable=[];var lowestReachableN=-1;var lowestReachableP=null;for(let i=0;i<params.n;i+=1){reachable=privContext.reachableSquares(lastPoint);for(let j=0;j<reachable.length;j++){if(lowestReachableN==-1||privContext.getSquareNumber(privContext,reachable[j])<lowestReachableN){if(!privContext.isVisited(privContext,reachable[j])){lowestReachableP=reachable[j];lowestReachableN=privContext.getSquareNumber(privContext,lowestReachableP)}}}if(lowestReachableN==-1){break}resultLength+=Math.hypot(lowestReachableP.x-lastPoint.x,lowestReachableP.y-lastPoint.y);lastPoint=lowestReachableP;resultPoints.push(getPoint(lastPoint.x,-1*lastPoint.y));privContext.visitSquare(privContext,lowestReachableN,lastPoint);lowestReachableN=-1}return{points:resultPoints,length:resultLength}},forcedDefaults:{n:2016,mag:infNum(1n,0n),centerX:infNum(0n,0n),centerY:infNum(0n,0n)},magnificationFactor:infNum(60n,0n),privContext:{boardPoints:{},visitedSquares:{},trackNumberedSquare:function(privContext,n,point){privContext.boardPoints[point.x+"-"+point.y]=n},isNumberedSquare:function(privContext,point){return point.x+"-"+point.y in privContext.boardPoints},getSquareNumber:function(privContext,point){const id=point.x+"-"+point.y;if(!privContext.boardPoints.hasOwnProperty(id)){console.log("MISSING SQUARE - "+id)}return privContext.boardPoints[id]},visitSquare:function(privContext,n,point){privContext.visitedSquares[point.x+"-"+point.y]=n},isVisited:function(privContext,point){return point.x+"-"+point.y in privContext.visitedSquares},changeDirection:function(dir){return changeDirectionDegrees(dir,-90)},computeNextPoint:function(dir,n,x,y){return computeNextPointDegrees(dir,n,x,y)},reachableSquares:function(s){return[getPoint(s.x+1,s.y-2),getPoint(s.x+2,s.y-1),getPoint(s.x+2,s.y+1),getPoint(s.x+1,s.y+2),getPoint(s.x-1,s.y-2),getPoint(s.x-2,s.y-1),getPoint(s.x-2,s.y+1),getPoint(s.x-1,s.y+2)]},isSquare:function(n){const sqrt=Math.sqrt(n);return sqrt==Math.trunc(sqrt)}}}];