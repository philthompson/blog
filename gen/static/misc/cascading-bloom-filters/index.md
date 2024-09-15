
[//]: # (gen-title: Cascading Bloom Filters - philthompson.me)

[//]: # (gen-keywords: Cascading Bloom Filters, Security Now)

[//]: # (gen-description: JavaScript app for testing the concept of a trio of cascading bloom filters that are free of false positives")

[//]: # (gen-meta-end)

  <h1>Cascading Bloom Filters</h1>
  <p>Given some large set of items, a subset of which will be inserted into the cascading bloom filters,
  find how many levels of cascading are needed to achieve zero false positives.</p>
  <p>See:<ul>
    <li><a target="_blank" href="https://blog.mozilla.org/security/2020/01/09/crlite-part-2-end-to-end-design/">Mozilla's post about CRLite, built on cascading bloom filters</a>,</li>
    <li><a target="_blank" href="https://obj.umiacs.umd.edu/papers_for_stories/crlite_oakland17.pdf">the related paper</a>, and</li>
    <li><a target="_blank" href="https://www.grc.com/sn/sn-989-notes.pdf">the Security Now! podcast show notes (PDF), episode 989</a></li>
  </ul>
  </p>
  <input type="range" min="6" max="22" value="12" class="slider" id="supset-size-pwr">
  <span id="supset-size-display"></span>
  <span>items in set to test</span><br/>
  <input type="range" min="1" max="100" value="22" class="slider" id="subset-size-pct">
  <span id="subset-size-display"></span>
  <span>of items to insert in cascading bloom filter</span><br/>
  <input type="range" min="6" max="32" value="16" class="slider" id="bf1-bits">
  <span id="bf1-bits-display"></span>
  <span>level 1 bloom filter bits (power of 2)</span><br/>
  <input type="range" min="1" max="16" value="5" class="slider" id="hash-funcs">
  <span id="hash-funcs-display"></span>
  <span>bits set per item using separate hash functions</span><br/>
  <p>Depending on settings, many false positives may be produced.  This may cause quite a few levels of bloom filters to
  be created, and may require a few seconds to run.</p>
  <button id="run-button">Run</button><br/>
  <div id="p" style="margin-top:1.0rem;"></div>

<script type="text/javascript">

/*
https://github.com/6502/sha256/ Copyright 2022 Andrea Griffini

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// sha256(data) returns the digest
// sha256() returns an object you can call .add(data) zero or more time and .digest() at the end
// digest is a 32-byte Uint8Array instance with an added .hex() function.
// Input should be either a string (that will be encoded as UTF-8) or an array-like object with values 0..255.
function sha256(data) {
    let h0 = 0x6a09e667, h1 = 0xbb67ae85, h2 = 0x3c6ef372, h3 = 0xa54ff53a,
        h4 = 0x510e527f, h5 = 0x9b05688c, h6 = 0x1f83d9ab, h7 = 0x5be0cd19,
        tsz = 0, bp = 0;
    const k = [0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
               0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
               0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
               0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
               0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
               0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
               0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
               0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2],
          rrot = (x, n) => (x >>> n) | (x << (32-n)),
          w = new Uint32Array(64),
          buf = new Uint8Array(64),
          process = () => {
              for (let j=0,r=0; j<16; j++,r+=4) {
                  w[j] = (buf[r]<<24) | (buf[r+1]<<16) | (buf[r+2]<<8) | buf[r+3];
              }
              for (let j=16; j<64; j++) {
                  let s0 = rrot(w[j-15], 7) ^ rrot(w[j-15], 18) ^ (w[j-15] >>> 3);
                  let s1 = rrot(w[j-2], 17) ^ rrot(w[j-2], 19) ^ (w[j-2] >>> 10);
                  w[j] = (w[j-16] + s0 + w[j-7] + s1) | 0;
              }
              let a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;
              for (let j=0; j<64; j++) {
                  let S1 = rrot(e, 6) ^ rrot(e, 11) ^ rrot(e, 25),
                      ch = (e & f) ^ ((~e) & g),
                      t1 = (h + S1 + ch + k[j] + w[j]) | 0,
                      S0 = rrot(a, 2) ^ rrot(a, 13) ^ rrot(a, 22),
                      maj = (a & b) ^ (a & c) ^ (b & c),
                      t2 = (S0 + maj) | 0;
                  h = g; g = f; f = e; e = (d + t1)|0; d = c; c = b; b = a; a = (t1 + t2)|0;
              }
              h0 = (h0 + a)|0; h1 = (h1 + b)|0; h2 = (h2 + c)|0; h3 = (h3 + d)|0;
              h4 = (h4 + e)|0; h5 = (h5 + f)|0; h6 = (h6 + g)|0; h7 = (h7 + h)|0;
              bp = 0;
          },
          add = data => {
              if (typeof data === "string") {
                  data = typeof TextEncoder === "undefined" ? Buffer.from(data) : (new TextEncoder).encode(data);
              }
              for (let i=0; i<data.length; i++) {
                  buf[bp++] = data[i];
                  if (bp === 64) process();
              }
              tsz += data.length;
          },
          digest = () => {
              buf[bp++] = 0x80; if (bp == 64) process();
              if (bp + 8 > 64) {
                  while (bp < 64) buf[bp++] = 0x00;
                  process();
              }
              while (bp < 58) buf[bp++] = 0x00;
              // Max number of bytes is 35,184,372,088,831
              let L = tsz * 8;
              buf[bp++] = (L / 1099511627776.) & 255;
              buf[bp++] = (L / 4294967296.) & 255;
              buf[bp++] = L >>> 24;
              buf[bp++] = (L >>> 16) & 255;
              buf[bp++] = (L >>> 8) & 255;
              buf[bp++] = L & 255;
              process();
              let reply = new Uint8Array(32);
              reply[ 0] = h0 >>> 24; reply[ 1] = (h0 >>> 16) & 255; reply[ 2] = (h0 >>> 8) & 255; reply[ 3] = h0 & 255;
              reply[ 4] = h1 >>> 24; reply[ 5] = (h1 >>> 16) & 255; reply[ 6] = (h1 >>> 8) & 255; reply[ 7] = h1 & 255;
              reply[ 8] = h2 >>> 24; reply[ 9] = (h2 >>> 16) & 255; reply[10] = (h2 >>> 8) & 255; reply[11] = h2 & 255;
              reply[12] = h3 >>> 24; reply[13] = (h3 >>> 16) & 255; reply[14] = (h3 >>> 8) & 255; reply[15] = h3 & 255;
              reply[16] = h4 >>> 24; reply[17] = (h4 >>> 16) & 255; reply[18] = (h4 >>> 8) & 255; reply[19] = h4 & 255;
              reply[20] = h5 >>> 24; reply[21] = (h5 >>> 16) & 255; reply[22] = (h5 >>> 8) & 255; reply[23] = h5 & 255;
              reply[24] = h6 >>> 24; reply[25] = (h6 >>> 16) & 255; reply[26] = (h6 >>> 8) & 255; reply[27] = h6 & 255;
              reply[28] = h7 >>> 24; reply[29] = (h7 >>> 16) & 255; reply[30] = (h7 >>> 8) & 255; reply[31] = h7 & 255;
              //reply.hex = () => {
              //    let res = "";
              //    reply.forEach(x => res += ("0" + x.toString(16)).slice(-2));
              //    return res;
              //};
              return reply;
          };
    if (data === undefined) return {add, digest};
    add(data);
    return digest();
}

function sha256ToBinaryStr(data) {
  const hash = sha256(data);
  let binary = "";
  hash.forEach(b => binary += ("00000000" + b.toString(2)).slice(-8));
  return binary;
}

// thanks to https://gist.github.com/vaiorabbit/5657561
// 32 bit FNV-1a hash
// Ref.: http://isthe.com/chongo/tech/comp/fnv/
const FNV1_32A_INIT = 0x811c9dc5;
function fnv32a(str) {
  let hval = FNV1_32A_INIT;
  for (let i = 0; i < str.length; ++i) {
    hval ^= str.charCodeAt(i);
    hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
  }
  return hval >>> 0;
}
// version of above FNV-1a that doesn't take string
//   input -- instead it takes one 32-bit input,
//   mixes in each byte separately, and returns another
//   32-bit output
const MASK_32B_1 = 0b11111111000000000000000000000000;
const MASK_32B_2 = 0b00000000111111110000000000000000;
const MASK_32B_3 = 0b00000000000000001111111100000000;
const MASK_32B_4 = 0b00000000000000000000000011111111;
function fnv32a_32bitint(int32b) {
  let hval = FNV1_32A_INIT;
  hval ^= (int32b & MASK_32B_1);
  hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
  hval ^= (int32b & MASK_32B_2);
  hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
  hval ^= (int32b & MASK_32B_3);
  hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
  hval ^= (int32b & MASK_32B_4);
  hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
  return hval >>> 0;
}

let fasterRandomUsage = 2000000;
let fasterRandomHash = null;
// since bit shifting clamps number values to 32-bit unsigned
//   values, the maximum value the hash can have is this
const MAX_UNSIGNED_HASH = 0b11111111111111111111111111111111;
function fasterRandom32bit() {
  if (fasterRandomUsage++ > 1000000) {
    fasterRandomUsage = 0;
    fasterRandomHash = fnv32a(Date.now().toString());
    //console.log("re-seeded FNV-1a PRNG with the current time");
  }
  fasterRandomHash = fnv32a_32bitint(fasterRandomHash);
  return fasterRandomHash;
}
function fasterRandom(minInclusive, maxExclusive) {
  if (fasterRandomUsage++ > 1000000) {
    fasterRandomUsage = 0;
    fasterRandomHash = fnv32a(Date.now().toString());
    //console.log("re-seeded FNV-1a PRNG with the current time");
  }
  fasterRandomHash = fnv32a_32bitint(fasterRandomHash);
  const valueAsFrac = fasterRandomHash / MAX_UNSIGNED_HASH;
  return minInclusive + (valueAsFrac * (maxExclusive - minInclusive));
}

function insertItemIntoBloomFilter(intItem, hashFuncs, hashBits, hashMask, bloomFilter) {
  let theHash = sha256ToBinaryStr(intItem.toString());
  //console.log("inserting", intItem, "which has hash", theHash);
  for (let i = 0; i < hashFuncs; i++) {
    let nthRunOfBits = parseInt(theHash.slice(-hashBits), 2); // binary string of last few chars to int
    bloomFilter[nthRunOfBits] = 1;
    theHash = theHash.slice(0, -hashBits); // delete consumed bits from the end of the string
  }
}

function isItemInBloomFilter(intItem, hashFuncs, hashBits, hashMask, bloomFilter) {
  let theHash = sha256ToBinaryStr(intItem.toString());
  for (let i = 0; i < hashFuncs; i++) {
    //let nthRunOfBits = theHash & hashMask;
    let nthRunOfBits = parseInt(theHash.slice(-hashBits), 2); // binary string of last few chars to int
    if (bloomFilter[nthRunOfBits] === 0) {
      return false; // if any bit is zero, we know for certain the item is not in the set
    }
    //theHash >>= hashBits; // shift at the end of the loop
    theHash = theHash.slice(0, -hashBits); // delete consumed bits from the end of the string
  }
  return true; // if all bits are set, the item is either in the set or we have a false positive
}

let p = document.getElementById('p');

let supSetSizeSlider = document.getElementById('supset-size-pwr');
let supSetSizeSpan = document.getElementById('supset-size-display');
let subSetSizeSlider = document.getElementById('subset-size-pct');
let subSetSizeSpan = document.getElementById('subset-size-display');
let bf1bitsSlider = document.getElementById('bf1-bits');
let bf1bitsSpan = document.getElementById('bf1-bits-display');
let hashFuncsSlider = document.getElementById('hash-funcs');
let hashFuncsSpan = document.getElementById('hash-funcs-display');

let runButton = document.getElementById('run-button');

bf1bitsSlider.oninput = function() { bf1bitsSpan.innerHTML = this.value + "&nbsp;"; };
supSetSizeSlider.oninput = function() { supSetSizeSpan.innerHTML = Math.pow(2, this.value) + "&nbsp;"; };
subSetSizeSlider.oninput = function() { subSetSizeSpan.innerHTML = this.value + "%&nbsp;"; };
hashFuncsSlider.oninput = function() { hashFuncsSpan.innerHTML = this.value + "&nbsp;"; };

/*
let bf1bitsSliderUpd = function() { bf1bitsSpan.innerHTML = this.value + "&nbsp;"; }; bf1bitsSlider.oninput = bf1bitsSliderUpd;
let supSetSizeSliderUpd = function() { supSetSizeSpan.innerHTML = Math.pow(2, this.value) + "&nbsp;"; }; supSetSizeSlider.oninput = supSetSizeSliderUpd;
let subSetSizeSliderUpd = function() { subSetSizeSpan.innerHTML = this.value + "%&nbsp;"; }; subSetSizeSlider.oninput = subSetSizeSliderUpd;
*/

let bloomFilter1Hashes = 5; // number of "hash functions" to use

window.addEventListener("load", function() {
  const e = new Event("input", { bubbles: true, cancelable: false });
  supSetSizeSlider.dispatchEvent(e);
  subSetSizeSlider.dispatchEvent(e);
  bf1bitsSlider.dispatchEvent(e);
  hashFuncsSlider.dispatchEvent(e);
});

let runFilters = function() {

  let randomSeed = 'hello world';

  let randomSeedHash = fnv32a(randomSeed);

  let supSetSize = Math.pow(2, supSetSizeSlider.value);           // number of items in the superset
  let subSetSize = supSetSize * (subSetSizeSlider.value / 100.0); // number of items in the subset, taken as percentage of superset

  let bloomFilter1Size = bf1bitsSlider.value;//16; // number of bits in first level bloom filter (some power of two)
  let bloomFilter1 = []; // first level bloom filter

  bloomFilter1Hashes = hashFuncsSlider.value;

  p.innerHTML = '<hr/>';

  if (bloomFilter1Hashes * bloomFilter1Size > 256) {
    p.innerHTML += '<br/>[' + bloomFilter1Size + '] bits per hash times [' + bloomFilter1Hashes + '] hashes = [' + (bloomFilter1Hashes * bloomFilter1Size) + '], which exceeds the 256 bits available in SHA-256 output';
    runButton.innerHTML = "Run";
    return;
  }

  ////////////////////////////////////////////////////////////
  // populate the set with unique random ints
  let supSet = new Set();
  let subSet = new Set();
  for (let i = 0; i < supSetSize; i++) {
    const x = fasterRandom32bit();
    supSet.add(x);
    if (i < subSetSize) {
      subSet.add(x);
    }
  }
  // in case we tried to insert a duplicate, add more values
  while (supSet.size < supSetSize) {
    const x = fasterRandom32bit();
    supSet.add(x);
    if (subSet.size < subSetSize) {
      subSet.add(x);
    }
  }

  let bfLevel = 1;
  let setData = {'knownHits': supSet, 'falsePositives': subSet};
  let bfBits = bloomFilter1Size;
  while (setData['falsePositives'].size > 0 && bfBits > 4) {
    setData = testBloomFilter(bfLevel, setData['knownHits'], setData['falsePositives'], bfBits);
    bfLevel++;
    bfBits--;
  }

  if (setData['falsePositives'].size > 0) {
    p.innerHTML += '<br>after [' + bfLevel + "] levels of bloom filters, there were still [" + setData['falsePositives'].size + "] false positives";
  }

  runButton.innerHTML = "Run";
}

function testBloomFilter(bfLevel, setToTest, setToInsert, bfHashBits) {

  bfBits = Math.pow(2, bfHashBits);

  p.innerHTML += "<br/>level [" + bfLevel + "]: creating bloom filter with 2^" + bfHashBits + " (" + bfBits + ") bits";
  p.innerHTML += "<br/>level [" + bfLevel + "]: inserting [" + setToInsert.size + "] of [" + setToTest.size + "] items";

  let bfArray = []; // bloom filter

  ////////////////////////////////////////////////////////////
  // no need to do bitwise stuff, right?  plus, bitwise
  //   operations in JavaScript are/were limited to 32-bit ints
  // fill with zeroes
  for (let i = 0; i < bfBits; i++) {
    bfArray.push(0);
  }

  ////////////////////////////////////////////////////////////
  // create bit mask with 1s only in the last few bits
  let bloomFilterMask = 0;
  for (let i = 0; i < bfHashBits; i++) {
    bloomFilterMask <<= 1; // shift left 1 bit
    bloomFilterMask |= 1; // use OR to set the last bit to 1
  }

  ////////////////////////////////////////////////////////////
  // insert all items from the set into the bloom filter
  for (const item of setToInsert) {
    insertItemIntoBloomFilter(item, bloomFilter1Hashes, bfHashBits, bloomFilterMask, bfArray);
  }

  ////////////////////////////////////////////////////////////
  // try some random numbers, and see whether any are false positives
  // (can also check to see if actually in theSet)
  let falsePositives = new Set();
  for (const testItem of setToTest) {
    const result = isItemInBloomFilter(testItem, bloomFilter1Hashes, bfHashBits, bloomFilterMask, bfArray);
    if (result && !setToInsert.has(testItem)) {
      falsePositives.add(testItem);
    }
  }

  p.innerHTML += "<br/>level [" + bfLevel + "]: [" + falsePositives.size + "] false positives found when testing [" + setToTest.size + "] items in the super set";

  ////////////////////////////////////////////////////////////
  // try some members of theSet to ensure they actually are all found
  let testedCount = 0;
  let foundCount = 0;
  for (const testItem of setToInsert) {
    testedCount++;
    const result = isItemInBloomFilter(testItem, bloomFilter1Hashes, bfHashBits, bloomFilterMask, bfArray);
    if (result) {
      foundCount++;
    } else {
      p.innerHTML += "<br/>level [" + bfLevel + "]: subSet item [" + testItem + "] was not found, which should be impossible";
    }
  }

  //p.innerHTML += "<br/>level [" + bfLevel + "]: found [" + foundCount + "] of [" + setToInsert.size + "] items in the subset";

  return {'knownHits': setToInsert, 'falsePositives': falsePositives};
}

runButton.onclick = function() {
  runButton.innerHTML = "Running...";
  setTimeout(runFilters, 50);
}

</script>
