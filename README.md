# Superstellar Miraculous Roblox Script

Superstellar Miraculous is a Roblox script for a multiplayer space arena game where players collect stardust, use a Supernova dash ability, and compete through a generated neon-themed arena with a leaderboard and responsive HUD.

## Install

1. Open the experience in Roblox Studio.
2. Create a Script in `ServerScriptService` named `SuperstellarServer`.
3. Paste the contents of `ServerScriptService/SuperstellarServer.server.lua` into the new Script.
4. Create a LocalScript in `StarterPlayer > StarterPlayerScripts` named `SuperstellarClient`.
5. Paste the contents of `StarterPlayer/StarterPlayerScripts/SuperstellarClient.client.lua` into the new LocalScript.
6. No manual RemoteEvent setup is required. The server script creates `SuperstellarEvent` in `ReplicatedStorage` automatically.

## Use

1. Press Play in Roblox Studio.
2. The server script automatically creates the circular arena, spawn point, neon pillars, and stardust collectibles.
3. Walk into golden stardust orbs to collect them.
4. View the collected amount in the `Stardust` leaderboard value and the on-screen counter.
5. Press `Q` or activate the on-screen `SUPERNOVA` button to dash forward and upward.
6. The Supernova ability displays a glowing burst and has a server-enforced 15-second cooldown.
7. Mobile players can use the on-screen ability button.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/f9164cbe-2fcf-4e21-a414-5d6713656afd?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=f9164cbe-2fcf-4e21-a414-5d6713656afd
