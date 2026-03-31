/**
 * Seeds Directus groups collection with Facebook page/group URLs.
 * Skips URLs that already exist in the collection.
 *
 * Usage:
 *   bun run scripts/seed-groups.ts
 */

import * as dotenv from "dotenv";
dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";

if (!DIRECTUS_BASE_URL || !DIRECTUS_ACCESS_TOKEN) {
  console.error("Error: DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set.");
  process.exit(1);
}

const headers = {
  "Content-Type": "application/json",
  Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
};

const URLS = [
  "https://www.facebook.com/kseniamotion/events",
  "https://www.facebook.com/djmomolatino",
  "https://www.facebook.com/groups/203775583685963",
  "https://www.facebook.com/groups/322864201079023",
  "https://www.facebook.com/groups/ecstaticdancebrno",
  "https://www.facebook.com/groups/122539874422799",
  "https://www.facebook.com/groups/stolarna",
  "https://www.facebook.com/groups/dancing.brno",
  "https://www.facebook.com/groups/354024053308249",
  "https://www.facebook.com/groups/296291087095613",
  "https://www.facebook.com/groups/662728914198782",
  "https://www.facebook.com/bohemiansalseros",
  "https://www.facebook.com/profile.php?id=61575029044238",
  "https://www.facebook.com/groups/bachataczech",
  "https://www.facebook.com/bachatamagic",
  "https://www.facebook.com/groups/311048022362848",
  "https://www.facebook.com/CarlosAndFernana",
  "https://www.facebook.com/SalsaPrahaKomunita",
  "https://www.facebook.com/dancedifferent.cz",
  "https://www.facebook.com/zouktimeevents",
  "https://www.facebook.com/TanecLiberec.cz",
  "https://www.facebook.com/profile.php?id=61574584845437",
  "https://www.facebook.com/LaFamiliaSalsaBand",
  "https://www.facebook.com/pali.goga",
  "https://www.facebook.com/groups/PragueSalsaZoukSundays",
  "https://www.facebook.com/groups/3294748344123162",
  "https://www.facebook.com/profile.php?id=100063886152771",
  "https://www.facebook.com/latropicaltanecniskola",
  "https://www.facebook.com/tanecniskola.cz",
  "https://www.facebook.com/lamacumba.cz",
  "https://www.facebook.com/profile.php?id=61563836195832",
  "https://www.facebook.com/groups/1995689394186505",
  "https://www.facebook.com/DjLusithano",
  "https://www.facebook.com/profile.php?id=61575066421362",
  "https://www.facebook.com/corebachataacademy",
  "https://www.facebook.com/groups/1045421366347108",
  "https://www.facebook.com/groups/135541056493556",
  "https://www.facebook.com/groups/837271997474751",
  "https://www.facebook.com/groups/tanecniakce",
  "https://www.facebook.com/groups/466270663480596",
  "https://www.facebook.com/groups/1579756192094915",
  "https://www.facebook.com/bailamecaribic",
  "https://www.facebook.com/leon.salsa.cubana",
  "https://www.facebook.com/groups/ecstaticdanceczech",
  "https://www.facebook.com/groups/bohemiansalsa.cz",
  "https://www.facebook.com/groups/119163140518",
  "https://www.facebook.com/groups/753764099497075",
  "https://www.facebook.com/groups/tanecworkshopy",
  "https://www.facebook.com/groups/1073651101002520",
  "https://www.facebook.com/salsa.bachata.ruben.dance",
  "https://www.facebook.com/groups/1350827201640886",
  "https://www.facebook.com/groups/877980673585498",
  "https://www.facebook.com/groups/650160118342880",
  "https://www.facebook.com/profile.php?id=100084930184901",
  "https://www.facebook.com/groups/BachataDeutschland",
  "https://www.facebook.com/SalsaInPrague",
  "https://www.facebook.com/groups/httpsrubendance.czkategorieproduktutanecni",
  "https://www.facebook.com/groups/517801226301072",
  "https://www.facebook.com/groups/salsa.praha.komunita",
  "https://www.facebook.com/kizfinityevents",
  "https://www.facebook.com/lucia.kubasova",
  "https://www.facebook.com/groups/bachatapraha",
  "https://www.facebook.com/elvira.mashanlo",
  "https://www.facebook.com/groups/1107370682657492",
  "https://www.facebook.com/pavel.maximenko.733",
  "https://www.facebook.com/groups/zoukcr",
  "https://www.facebook.com/groups/765554881311939",
  "https://www.facebook.com/bachata.dominant",
  "https://www.facebook.com/carpetro",
  "https://www.facebook.com/groups/www.latropical.cz",
  "https://www.facebook.com/studiostolarna",
  "https://www.facebook.com/tanecnistudiohanserestenoz",
];

function detectType(url: string): string {
  if (url.includes("/groups/")) return "group";
  if (url.includes("/events")) return "page";
  if (url.includes("/profile.php")) return "profile";
  return "page";
}

async function main() {
  // Fetch existing group URLs
  const res = await fetch(`${DIRECTUS_BASE_URL}/items/groups?fields=url&limit=-1`, { headers });
  const json = (await res.json()) as { data: { url: string }[] };
  const existing = new Set(json.data.map((g) => g.url));

  let created = 0;
  let skipped = 0;

  for (const url of URLS) {
    if (existing.has(url)) {
      skipped++;
      continue;
    }

    const createRes = await fetch(`${DIRECTUS_BASE_URL}/items/groups`, {
      method: "POST",
      headers,
      body: JSON.stringify({ url, type: detectType(url) }),
    });

    if (createRes.ok) {
      created++;
    } else {
      const err = await createRes.text();
      console.error(`Failed to create group ${url}: ${err}`);
    }
  }

  console.log(`Done. Created: ${created}, Skipped (already exist): ${skipped}, Total: ${URLS.length}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
