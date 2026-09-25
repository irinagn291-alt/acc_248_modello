# Modello

Modello is a studio for people who already saved museum paintings and want to mate a hanging study to the painting by the same hand. It stays on this device. There is no name chip, no shop, and no grade field.

## Architecture

The bottega is one Pendant ADT fold: Idle, Installed, or Twinned. Install writes a Study and hangs four unlabeled Trials (one same-maker sibling plus three other makers). Mate writes a TwinMark when the tapped Trial shares the Study maker and folds Installed to Twinned. A miss writes a BreakMark and keeps the Study. Views bind one `BottegaStudio`. That fold matches the product because the home verb is mate-the-trial, not a list of records.

## Install-then-mate

This is why someone picks Modello. Home is Quiz. Install pins a free saved Work that still has a same-hand sibling. Four unlabeled tiles hang on that canvas. The sibling files a TwinMark. A miss cools that tile and stays reviewable. Mate on Idle is refused. A second Install while Installed is refused. A crate without a pair writes Idle. Twinned studies leave the install pool and rest on Saved.

## Art

Style: 3D glass render, glassmorphism, frosted translucent volumes, studio daylight, soft diffusion, polished refraction, calm workshop still life, no text, no people faces as the emblem.

Image sets are named `mdl_*`. Generation is a later step. Prompts used for each set:

- `mdl_AppIcon`: A single frosted glass modello block filling the canvas edge to edge, 3D glass render, studio daylight, no text, no alpha, no rounded mask
- `mdl_Splash`: Tall quiet studio glass planes with a calm uncluttered centre band, 3D glass render, soft diffusion, no text
- `mdl_Onboarding1`: A solid oak studio modello on a stand, opaque wood, transparent corners, the product in one glance
- `mdl_Onboarding2`: A hand hovering over one of four small trial panels beside a larger study panel, mid-gesture, solid opaque subjects, transparent corners
- `mdl_Onboarding3`: Two paintings filed as a twinned pair on a studio rack, solid frames, transparent corners
- `mdl_EmptyHome`: A closed wooden modello case waiting to be opened, fully opaque wood, transparent corners, calm, not glass
- `mdl_EmptyList`: An empty wooden folio shelf with no paintings, fully opaque, transparent corners
- `mdl_CardBackdrop`: Abstract frosted glass planes filling the canvas, low contrast 3D glass render, studio daylight, no text
- `mdl_ControlFace`: A small square trial tile of frosted glass, solid centre, 3D glass render, used as the mate control face
- `mdl_TwistHero`: A large study panel beside one glowing sibling trial and three dimmer trials, 3D glass render, install-then-mate emblem, transparent corners, solid subjects
- `mdl_SuccessMark`: A solid glass seal stamped as a twin, opaque centre, transparent corners, 3D glass render
- `mdl_HeaderDecor`: A wide frosted glass lintel band, 3D glass render, studio daylight, no text

## Difference from the batch

This is not Horsserie (isolate the stray in a school). It is not Rampin or Biseau (picture to a text slip). It is not Seriation. The crate predicate is a pair, and the home tap mates the sibling.

## Build

```bash
cd apps/Modello
xcodegen generate
xcodebuild -scheme Modello -destination 'generic/platform=iOS Simulator' build
```
