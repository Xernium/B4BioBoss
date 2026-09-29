# B4BioBoss

A MobileSubstrate tweak that gets **BioShock 1.3.5 (32-bit)** fully working on **iOS 10**

Tested on an iPhone 6 running iOS 10.2.1 with Bioshock 1.3.5.

## What it fixes

- Menu never loads (same as the community iOS 9+ fix)
- Audio halfway broken (scripted bits). Since 1.1.0 this is handled by the **FMODFix** dependency, which fixes the
  same FMOD Ex bug in every affected game (Dead Space, Mass Effect Infiltrator, ...)

## Install

Install the `.deb` from the releases page (or build it yourself). 

Since `v1.1.0` this tweak requires **FMODFix** (`com.xernium.fmodfix` >= 1.0.0).

If you applied the community patch (NOP at`0x018A4518`), you can keep it or go back to the original binary, the fix
used here doesn't interfere. You honestly don't need this tweak at all if you have that fix, only the **FMODFix** tweak.


## Build

I had Claude-Code make the build integration, did not want to do that myself.

The build uses Theos in Docker (Linux host, armv7, iPhoneOS 10.3 SDK):

```sh
docker build -t bioshock-theos docker
docker run --rm -u $(id -u):$(id -g) -e HOME=/tmp -v "$PWD":/work -w /work bioshock-theos make package FINALPACKAGE=1
```

The package ends up in `packages/`.

## Known quirks

- After quitting the game, audio can keep playing for about a second. Should be fine. Probably just iOS behavior.

## Credits

- **[u/SimSlayer72](https://www.reddit.com/user/SimSlayer72/)** found the original fix that gets BioShock running above iOS 8.3
  (patch NOPing the `stop` call in `playVideoWithURL:showControls:`) and suggested that the proper fix is to stop only when something is
  actually playing. That's more or less what was used to fix that part.
  [Original post](https://www.reddit.com/r/jailbreak/comments/1hjcvha/i_got_bioshock_working_above_ios_83/)
- **Claude Fable 5 (Anthropic)**: build integration and tooling



**BioShock is a trademark of Take-Two Interactive Software, Inc. This project is not affiliated with 2K or Take-Two, and it contains no
game code or assets.**
