# Psychonauts Chaos Mod
Causes random, wacky effects to occur while you play. Compatible with Vanilla game, Randomizer, or Archipelago.

## Changing Settings

Currently, changing settings requires modifying code in "ChaosController.lua". You can adjust two major variables:

`Ob.chaosStartTime` is the time between loading into a level and the first chaos effect to happen. Default is 5 seconds.

`Ob.chaosTime` is the time between each chaos effect. Default is 30 seconds, minimum of 5 seconds.

You can also remove specific effects from the effect table by commenting them out using `--` before the line. Example: `--"InstantDeath",`

If you want to test out one specific effect, or play with only one repeating effect, you can change `Ob.debug` to 1 and change `Ob.debugEffect` to the effect you want.

Requires Astralathe to run, download and installation instructions found here:
https://gitlab.com/scrunguscrungus/astralathe/-/wikis/Installing%20Astralathe