<!-- gf-brief source=46db078e0ff9d75c5720fabf9cada5550d6332f62a4ab172d0d92f1f57237974 written=2026-09-26T01:15:10+03:00 -->
# Modello

## What it is
Modello is a small studio for learning makers by eye. You save museum paintings, hang one as a study, then mate it by tapping the tile painted by the same hand. It is for anyone who wants a quiet, on-device drill with Frick Collection works and personal twin and break marks.

## Launch and onboarding
On a cold launch the app may briefly show splash art while the studio loads. The system may also ask for notification permission at this time.

If onboarding is not finished, four pages appear in order. Each page has a large image, a title, body copy, a top-right **"Skip"**, and a bottom primary button.

1. **"Hang a study"** — "Save museum paintings, then pin one as the hanging study." Button: **"Next"**.
2. **"Mate same hand"** — "Tap the painting by the same maker. A miss cools that tile." Button: **"Next"**.
3. **"File the twin"** — "A mate writes a twin. Misses stay reviewable on Saved." Button: **"Next"**.
4. **"Stay on device"** — "The Frick Collection shelf fills the crate when search is quiet." Button: **"Start"**.

**"Skip"** or **"Start"** finishes onboarding and opens the home studio. On later launches, finished onboarding goes straight to home.

## Screens

### Home studio
There is no tab bar. Home is the studio canvas. The title and subtitle change with state.

Chrome (always):
- Icon buttons with VoiceOver labels **"Open Explore"**, **"Open Saved"**, **"Open Settings"** (magnifying glass, stacked rectangles, gear). They open those sheets.

**Idle — title "Hang a study"**
- Subtitle if nothing installable: "Save a pair, then install a hanging painting."
- Subtitle if a pair is ready: "Install a hanging painting, then tap its sibling."
- Empty art, headline **"The studio is waiting"**.
- Body if empty: "Save two paintings by one maker, then sit the quiz."
- Body if a pair is ready: "Install pins a free painting and lays four unlabeled tiles."
- **"Install"** — hangs a study and four unlabeled trial tiles when the pool allows; disabled when no installable pair exists.
- **"Open Explore"** — only when the install pool is empty; opens Explore.

**Installed — title "Mate this study"**
- Subtitle: "Tap the trial painted by the same hand."
- Large hanging study image with that work’s title and maker.
- On wider layout, line: "Four paintings. One shares this hand."
- Four unlabeled image tiles. Tap one to attempt a mate. A wrong tile shows **"Cooled"** and stays disabled. VoiceOver: **"Mate this tile"** or **"Cooled tile"**.
- Stat **"Twins"** with a count.
- Card **"How mate works"** / **"Install then mate"** — opens the Install then mate sheet.

**Twinned — title "This pair is filed"**
- Subtitle: "Install another study when you like."
- Success mark, headline **"Twinned"**, and the study title.
- **"Twins today"** with today’s twin count.
- **"Install next"** — same as Install; disabled when nothing installable remains.

**Restore banner** (when a load notice is present):
- **"Crate needed a restore"**
- Notice text: **"Restored the last good crate."** or **"Started a fresh crate."**
- **"Keep going"** — dismisses the banner.

### Explore
Sheet titled **"Explore"**. Close control (VoiceOver **"Close Explore"**).

- Search field placeholder: **"Search a maker or title"**. Keyboard **"Done"** dismisses the keyboard.
- Empty: **"Search the crate"** / "Type a maker. The Frick shelf answers when the line is quiet." / **"Browse Bellini"** (fills search with Bellini).
- No hits: **"No painting for that word"** / "Try a maker from the shelf, such as Bellini." / **"Browse Bellini"**.
- Loading: a progress spinner.
- Results: rows with title, maker, and **"Save"** or **"Saved"**. Tap saves (or re-focuses) that painting into your crate.
- Failure: **"Search did not finish"** / "Search could not reach the crate. Try again, or use a shelf name." / **"Try again"**.

### Saved
Sheet titled **"Saved"**. Close control (VoiceOver **"Close Saved"**).

- Empty: **"No marks yet"** / "Mate a sibling on Quiz. Misses land here so you can read them." / **"Open Explore"**.
- Populated: counts **"Twins"** and **"Breaks"**; a medium-style date for today; section **"Twinned studies"** with badge **"Twin"** and detail like "Mated to [title]. [date]"; section **"Reviewable misses"** with badge **"Break"** and detail like "Missed [title]. [date]"; **"Retract newest"** removes the latest twin or break mark.
- Load failure with an empty crate: **"Saved could not load"** plus the notice and **"Close"**.

### Settings
Sheet titled **"Settings"**. Close control (VoiceOver **"Close Settings"**).

- **"This device"** / "Works stay on this phone. One collection voice." / "[n] saved paintings".
- Or, on a fresh failed load: **"Settings opened on a fresh crate"** plus the notice.
- **"Walk onboarding again"** — closes Settings and replays onboarding (Skip/Start returns to home).
- **"Contact us"** — opens the support page.
- **"Catalog credit"** / **"The Frick Collection"** / "Tap to read the collection source." Opens a credit sheet with "Search and the local shelf draw from this collection.", link **"Open The Frick Collection"**, and **"Close"**.
- **"Reset all data"** — confirmation: **"Reset the crate? Works, TwinMarks, and BreakMarks leave this device."** with **"Reset the crate"** (destructive) or **"Keep the crate"**.

### Install then mate
Sheet titled **"Install then mate"** (also the headline). Close control (VoiceOver **"Close install then mate"**).

Copy:
- "Install pins a saved painting that still has a same-hand sibling. Four tiles hang: one sibling, three other makers."
- "Tap the sibling to file a twin. A miss files a break and keeps the hanging painting."
- "Mate while idle is refused. A second install while a painting hangs is refused."

## Features
- Hang a study from saved paintings
- Install a hanging painting and four unlabeled mate tiles
- Mate same hand to file a twin
- Miss and cool a tile; file a reviewable break
- Explore and search makers or titles
- Save / Saved paintings in the crate
- Local Frick Collection shelf when search is quiet or unreachable
- Twins and Breaks log on Saved, with Retract newest
- Twins and Twins today counts on the studio
- Onboarding walkthrough and Walk onboarding again
- Stay on this device; reset the crate
- Catalog credit for The Frick Collection
- Contact us support link
- How mate works / Install then mate explainer

## Behaviours that can look like bugs
- **"Install"** / **"Install next"** stay disabled until you have saved at least two paintings by one maker that are still free to hang. Use **"Open Explore"**, search or **"Browse Bellini"**, and **"Save"** a same-maker pair (and enough other makers for decoys) first.
- Install can appear enabled yet leave the studio idle if there are not three other-maker paintings available as decoys. Save more works from Explore, then install again.
- Mate taps do nothing while idle; hang with **"Install"** first.
- A second **"Install"** while a study already hangs is refused; mate or finish the current hang first.
- **"Cooled"** tiles stay disabled for that hang; pick another tile, or **"Retract newest"** on Saved to undo the latest miss.
- A correct mate ends the hang and shows **"Twinned"**; use **"Install next"** for another round.
- Explore stays on **"Search the crate"** until you type; vacant or failed search is cleared with **"Browse Bellini"** or **"Try again"**.
- **"Retract newest"** is disabled when there are no twins or breaks.
- Restore banner **"Crate needed a restore"** blocks nothing; **"Keep going"** clears it.
- After **"Reset the crate"**, onboarding returns and saved work is gone.

## Starter content and resume
On the Simulator only, the first launch can seed Frick Collection paintings (including Bellini, Holbein, Vermeer, and others) with an already-installed study so home is not empty. On device there is no automatic seed; the Frick shelf still answers quiet Explore search until you Save.

Unfinished work resumes: onboarding completion, saved paintings, hanging study and cooled tiles, twins, and breaks persist across launches.

## Permissions
- **Notifications** — asked at launch via the system permission dialog. No custom usage-description string in Info.plist / build settings.

## Absent
Login or accounts; in-app purchase; ads; analytics product surfaces; user-generated content feeds; account deletion flow; App Tracking Transparency prompt.

## Data and support
Works, marks, and studio state stay on this phone ("Works stay on this phone. One collection voice."). On-screen support control: **"Contact us"** (opens the support page). Catalog source: **"The Frick Collection"** / **"Open The Frick Collection"**.

## Scanning and health
None.

## Platform
Light appearance only. Portrait only on iPhone and iPad (full screen). Minimum iOS 17.0. Dates and counts follow the device locale. No special region lock beyond that.

## Category
Education.
