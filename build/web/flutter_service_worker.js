'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "fa8edc4702a3415accd85fde5819e01c",
"assets/AssetManifest.bin.json": "a571c937ea541104d90e17caba35b022",
"assets/AssetManifest.json": "19ce3693c9c0cad2ec182127ada5d32e",
"assets/assets/audio/click.mp3": "666c7ed81314650d1e9165041815d38a",
"assets/assets/audio/confirm.wav": "c4411ea20423de069b2e8aaa035747f5",
"assets/assets/audio/damage.wav": "734c7a07ec909f631e9c11de8dc2d9c4",
"assets/assets/audio/jump.wav": "46326f7f6b7fc293f6a42d6b63ef4b63",
"assets/assets/audio/mob.wav": "e0a62a745e9a67944179b72c4626fffc",
"assets/assets/audio/music1.mp3": "4bd8e809577a311fda4729dc720f6182",
"assets/assets/audio/music2.mp3": "77fe157431c831dedf76141f49a0d7a7",
"assets/assets/audio/music3.mp3": "773038c4321d9cdd89223e3492ba3f95",
"assets/assets/audio/music4.mp3": "4c0c7fc9707bb1b11d83a106386d3f58",
"assets/assets/audio/oof.mp3": "10fc0d52352947a3f089f26b58d2026e",
"assets/assets/audio/slash.wav": "de9576ef980667371b3a458d170d3510",
"assets/assets/audio/tada.mp3": "6cca7b715b1b79e6de12b27f63d12740",
"assets/assets/fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf": "31d95e96058490552ea28f732456d002",
"assets/assets/fonts/OpenSans-VariableFont_wdth,wght.ttf": "78609089d3dad36318ae0190321e6f3e",
"assets/assets/fonts/Ribeye-Regular.ttf": "eddb3962885f04b518851bf8264a2548",
"assets/assets/fonts/WinkySans-Italic-VariableFont_wght.ttf": "9ed44b76b0dbc79b367c7fcf17283587",
"assets/assets/fonts/WinkySans-VariableFont_wght.ttf": "647cb64450887c403f5f09b85e22d969",
"assets/assets/images/backdrop.png": "9795470fd994b2ef576975843d1ed108",
"assets/assets/images/block_blue.png": "50597f96c01ee9f69f889ca99d72a757",
"assets/assets/images/block_red.png": "b4e63bce18a3351b3f9759133985844b",
"assets/assets/images/bottle.png": "7ec90071e08fce10f2ec17a17b5546f7",
"assets/assets/images/button_forward.png": "87dfe213a02e4416ce83434f1485fb6e",
"assets/assets/images/button_menu.png": "70783af1f68fc9836c2816ed144efd7f",
"assets/assets/images/button_pause.png": "e9124f111398cfdf54d2d31eee5492f2",
"assets/assets/images/button_reset.png": "50f978fd59bf585b83d3c263357a4049",
"assets/assets/images/button_resume.png": "c842808281740093c0cadcf6cae10959",
"assets/assets/images/button_start.png": "bdb78ed04946ece69d50875e3b990912",
"assets/assets/images/chromatid.png": "7f3697788c439ed8854ca53abda2aa25",
"assets/assets/images/chromatid2.png": "3fcaa81d0344bdf91a369bf0bfec4295",
"assets/assets/images/chromatid3.png": "5a7fb2b542b516034d8f1bbb2af9ed01",
"assets/assets/images/chromatid4.png": "750b84860285fa8124b89bd616b6f23f",
"assets/assets/images/chromatid5.png": "4da3db1b4b7fd35408ce4826e0306226",
"assets/assets/images/chromatid6.png": "4e5e12e627dc38acd0630515bd5d7a8b",
"assets/assets/images/chromatid7.png": "c4668c4bb7dd6416e71153a181d3c1f2",
"assets/assets/images/chromosome_art.png": "477cac23053275d0bdc83a23c21f415f",
"assets/assets/images/cloud1.png": "3e4b69b8c28aa5943f13cfdd6c69ed27",
"assets/assets/images/cloud2.png": "86d1992b903c33aaf47761866f5cb440",
"assets/assets/images/combined_chromatid.png": "e21b183504db5bb474f5e9089ec5b044",
"assets/assets/images/combined_chromatid_new.png": "d5138809da60e4bd3298b405f768f41d",
"assets/assets/images/congratulations_game_over.png": "386f64d5b1af1b4497b9d1d8fdcbc9ed",
"assets/assets/images/easy_level.png": "2a896b48f35c7d3b447ffd8ad89f0fc6",
"assets/assets/images/expert_level.png": "0fd444396ac454bf26dda6b4af6d9b82",
"assets/assets/images/Finish.svg": "f2039aff8446bdf1c06e6aa18a120038",
"assets/assets/images/flame.png": "8d64648a884d883628033faf87404751",
"assets/assets/images/hard_level.png": "db123de49dda0045ee0f47c3dd43e8f7",
"assets/assets/images/heart_empty.png": "17567925a5410886257a471c1a5498f5",
"assets/assets/images/heart_full.png": "ee49198402f506d08da7c70be58caa30",
"assets/assets/images/heart_half.png": "cd6d74e019ec2d1e0b57e7ae33c20525",
"assets/assets/images/Jump1.svg": "517db87e52094a558902ea0da3eb62e8",
"assets/assets/images/Jump2.svg": "efefc94f473f0e6bc7367f55e73bab5e",
"assets/assets/images/Jump3.svg": "f9bd85f7d1683ebf109f34eedd13856f",
"assets/assets/images/Left.svg": "7ee104a29d0dcbd4eb30b73fcf7b8e94",
"assets/assets/images/medium_level.png": "9b1b78d670bd1c505609ff6b442d4def",
"assets/assets/images/mob.png": "9e3644b93cb67574a7c06710dc7f79e7",
"assets/assets/images/peaceful_level.png": "92927b498cf83dcbdbb49ac3423a3da9",
"assets/assets/images/pill_blue.png": "fae59c25a6033f4c1153c013e87ffb1f",
"assets/assets/images/pill_red.png": "90237c24e4cedabc4bdd07c0b4be1728",
"assets/assets/images/pipe.png": "785abc1ac5f130435dfbb4eaf73c71ba",
"assets/assets/images/platform_1.png": "12794ce541493efdf439c886c7eb852c",
"assets/assets/images/portraits/Almond_Eyes_Trait.png": "9d95f28bb86f02f5d5ab28874cfce25a",
"assets/assets/images/portraits/Black_Hair_Trait.png": "ab8d6a3ddf0d0c18853a0f096bc6e045",
"assets/assets/images/portraits/Blonde_Hair_Trait.png": "25989a468a304878f87f59eda165675c",
"assets/assets/images/portraits/Brown_Skin_Trait.png": "a5e5379c33fb62053d384c89edb2e27c",
"assets/assets/images/portraits/Fair_Skin_Trait.png": "6c3efbca76133cd3ee974d27b6e5db5c",
"assets/assets/images/portraits/Female_Brown_Skin_Almond_Eyes_Average_Height_Black_Hair.png": "ed675dbd6d1e0f0f753926881f97f1c5",
"assets/assets/images/portraits/Female_Brown_Skin_Almond_Eyes_Average_Height_Blonde_Hair.png": "ce295fbeaea405807f45891142d08c5d",
"assets/assets/images/portraits/Female_Brown_Skin_Almond_Eyes_Tall_Height_Black_Hair.png": "050cd4b51c865ffd89f2dcb8f9e73952",
"assets/assets/images/portraits/Female_Brown_Skin_Almond_Eyes_Tall_Height_Blonde_Hair.png": "96ba8586107b0691ed2b099092427434",
"assets/assets/images/portraits/Female_Brown_Skin_Round_Eyes_Average_Height_Black_Hair.png": "379af08a67e5988b8e15aebbada0089d",
"assets/assets/images/portraits/Female_Brown_Skin_Round_Eyes_Average_Height_Blonde_Hair.png": "d1364909d5b078626bc7e7ee7b624ee8",
"assets/assets/images/portraits/Female_Brown_Skin_Round_Eyes_Tall_Height_Black_Hair.png": "bb4faa1e3b1b7cece1ba56031a710ef0",
"assets/assets/images/portraits/Female_Brown_Skin_Round_Eyes_Tall_Height_Blonde_Hair.png": "b94962dbd625f18ac3faa834f180c3f7",
"assets/assets/images/portraits/Female_Fair_Skin_Almond_Eyes_Average_Height_Black_Hair.png": "173c7be8967ee77d6d485d79a1478cce",
"assets/assets/images/portraits/Female_Fair_Skin_Almond_Eyes_Average_Height_Blonde_Hair.png": "37e57eb0b37d10ef3f5a37277751e44c",
"assets/assets/images/portraits/Female_Fair_Skin_Almond_Eyes_Tall_Height_Black_Hair.png": "ed0ee2de4c6be41b2f6926bdde62d2ef",
"assets/assets/images/portraits/Female_Fair_Skin_Almond_Eyes_Tall_Height_Blonde_Hair.png": "91f110dcb938aad75af709fea5312a63",
"assets/assets/images/portraits/Female_Fair_Skin_Round_Eyes_Average_Height_Black_Hair.png": "52e049a3d2b01d696730e3d89e1c9207",
"assets/assets/images/portraits/Female_Fair_Skin_Round_Eyes_Average_Height_Blonde_Hair.png": "f08ed78bb255c606c7a03c7dfeb11fe8",
"assets/assets/images/portraits/Female_Fair_Skin_Round_Eyes_Tall_Height_Black_Hair.png": "808220dbfcd56ab263e4ad2a0c04a05a",
"assets/assets/images/portraits/Female_Fair_Skin_Round_Eyes_Tall_Height_Blonde_Hair.png": "6219a0bb076da70077acf944807f50f9",
"assets/assets/images/portraits/Female_Trait.png": "afda11d3509b7154cc33685a050e441a",
"assets/assets/images/portraits/Male_Brown_Skin_Almond_Eyes_Average_Height_Black_Hair.png": "f110284a6f2602eac62581f5fcefcd95",
"assets/assets/images/portraits/Male_Brown_Skin_Almond_Eyes_Average_Height_Blonde_Hair.png": "df755030fe09385743916d48aebc2348",
"assets/assets/images/portraits/Male_Brown_Skin_Almond_Eyes_Tall_Height_Black_Hair.png": "d8314ba4b597a6061814f4a12d32d4f4",
"assets/assets/images/portraits/Male_Brown_Skin_Almond_Eyes_Tall_Height_Blonde_Hair.png": "44f15c07d240f750c05c7ab2615ae83a",
"assets/assets/images/portraits/Male_Brown_Skin_Round_Eyes_Average_Height_Black_Hair.png": "72e0185a4d64ccbdcf8babaca56961b1",
"assets/assets/images/portraits/Male_Brown_Skin_Round_Eyes_Average_Height_Blonde_Hair.png": "c703ce09cb489dd5747fcdb3fa20efa7",
"assets/assets/images/portraits/Male_Brown_Skin_Round_Eyes_Tall_Height_Black_Hair.png": "4cd7ef5f9761a643ed857e9bdc00f930",
"assets/assets/images/portraits/Male_Brown_Skin_Round_Eyes_Tall_Height_Blonde_Hair.png": "872981515e189d807188f36f1bcfc64c",
"assets/assets/images/portraits/Male_Fair_Skin_Almond_Eyes_Average_Height_Black_Hair.png": "ec12cfdee351a51afadb0d369e40cea4",
"assets/assets/images/portraits/Male_Fair_Skin_Almond_Eyes_Average_Height_Blonde_Hair.png": "dd7b86deb18c1aa8916ea299ae354dc1",
"assets/assets/images/portraits/Male_Fair_Skin_Almond_Eyes_Tall_Height_Black_Hair.png": "53c1aaaaad08ec975424a1d89aab59b6",
"assets/assets/images/portraits/Male_Fair_Skin_Almond_Eyes_Tall_Height_Blonde_Hair.png": "8629b4237ab0ea42bc2e21d0e372a910",
"assets/assets/images/portraits/Male_Fair_Skin_Round_Eyes_Average_Height_Black_Hair.png": "8f750650736bcb42ff016bd67c6cc6da",
"assets/assets/images/portraits/Male_Fair_Skin_Round_Eyes_Average_Height_Blonde_Hair.png": "c2944562fdf7f4ec99c0fd7a0de53563",
"assets/assets/images/portraits/Male_Fair_Skin_Round_Eyes_Tall_Height_Black_Hair.png": "f8068bb5d2035480e0f2c7213ebac7b9",
"assets/assets/images/portraits/Male_Fair_Skin_Round_Eyes_Tall_Height_Blonde_Hair.png": "8a9a26b00c2ab84c8756863fe26b9623",
"assets/assets/images/portraits/Male_Trait.png": "b6d7b0d0fdd376518ce277193821dbd6",
"assets/assets/images/portraits/Round_Eyes_Trait.png": "ca9f61714c361729104c99bcb52f26d3",
"assets/assets/images/portraits/Short_Height_Trait.png": "6e7f274280b6739997aefda7f9fa6f40",
"assets/assets/images/portraits/Tall_Height_Trait.png": "4b1bb3fce969c484d339ee49b537303f",
"assets/assets/images/red_button.png": "2bb34d1a35b0bbf655c0b9917e58ddd0",
"assets/assets/images/Right.svg": "5b0bc4f676c9dd0498afdac5c471fb8a",
"assets/assets/images/sawblade.png": "58cdb92f7fa9b9ef52ab44c626d37e37",
"assets/assets/images/scroll.png": "88d1d491d25a034985e4942a5a6b9cce",
"assets/assets/images/select_a_level_text.png": "1b1ceeb45c45ddca7714e1412f3ef9e5",
"assets/assets/images/sister_chromatid.png": "885c37bdb0db26fb2c64130810d06de6",
"assets/assets/images/success.png": "df6d1cf01095259b41923f6e83310b90",
"assets/assets/images/tilesheet_complete.png": "178fd816380e497c10c1841528d0f10f",
"assets/assets/tiles/Level.tmx": "82f672060c52c6109d934bd0e2497a3e",
"assets/assets/tiles/Level0.tmx": "d74fec821ee83b5e3ad6e2f20ef52f2e",
"assets/assets/tiles/Level1.tmx": "536d53bc59123448275dc0e25c87fbaa",
"assets/assets/tiles/Level2.tmx": "2415443b89cd27205dba72e10cfb7ed6",
"assets/assets/tiles/Level3.tmx": "8827d641f5f3d04ee75ac4e04c3afe56",
"assets/assets/tiles/Level4.tmx": "005db04d667a436b1bd28366e6a9d7c1",
"assets/assets/tiles/tilesheet_complete.tsx": "7edfe5c256b90e01165c36e91bc9ec89",
"assets/FontManifest.json": "fffc96a997f8f7c45bd72d7fcc6fa723",
"assets/fonts/MaterialIcons-Regular.otf": "c0ad29d56cfe3890223c02da3c6e0448",
"assets/NOTICES": "29f7297a9dc4e49cedb978f3180afb7d",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "11e6631f0a3ddf7eac6312ba0803627e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "6e6aa5683212bd0bed6bf07c425d9e32",
"/": "6e6aa5683212bd0bed6bf07c425d9e32",
"main.dart.js": "10f4a2424ede45899de178e0e5ddcedb",
"manifest.json": "d4aa75818ac3fe1a8dfcec90e17b3c76",
"version.json": "7e917d5977fe86f72aab86f17840b691"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
