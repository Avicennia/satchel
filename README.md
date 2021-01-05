# Satchel
Attempt at implementing a formspec-less inventory interface<br>


## Features:
- Access supported inventories (players and chest-like containers) in-world using inventory-rings rather than through formspecs.
- Whitelist-like system allowing control of access to inventory-rings
- Configurable (somewhat) mod settings to allow disabling and enabling of features.

## How It Works:

### Basic Inventory Manipulation
Open your inventory as a ring of items around you using the mod's wand, or with your normal inventory ("I") key (Depending on whether these are enabled in your mod config; both are on by default).<br>

With your inventory-ring now open, you can shuffle items around similarly to how you would normally, by clicking the pedestal supporting the item you want to move, and then doing the same to the pedestal at your desired destination item slot.<br>

Shift-Clicks and Right-Click transfer are supported. Shift-clicking while having an actively selected slot will transfer only one item at a time, while right-clicking will allow you to transfer half of the quantity of your currently selected slot.

##### Wand
The one tool added by this mod is a wand that allows you to open container inventory-rings (provided you have permission) with a left click, and your own personal inventory-ring with a rightclick. It's in-code name is "satchel:wand" in case you want to /give it.

### Satchel Trust/Whitelist
Satchel comes packaged with a small(WIP) "tiered-whitelist" feature that allows you to designate access to your inventory rings. There are four(4) colored hearts numbered 0 to 3. <br>

1. Access level 0 is just as good as having no permission.
1. Access level 1 allows a player to have input-only access. This player will only be able to add items to the inventory-ring.
1. Access level 2 allows a player to have both input and output access. This player can add and take from the ring like an owner.
1. Access level 3 is reserved for only one player, the owner. This allows the player all of the power of access level 2, with the added privelege of being able to control who else can gain any other access level, and also control whether the container attached to the inventory-ring is currently accepting attempts to gain access. This player is also the only non-moderator that can see the access list for the container.

- Heart 1 (Cyan) is used to grant level 1 access to your inventory-rings.
- Heart 2 (Red/Pink) is used to grant level 2 access to your inventory-rings.
- Heart 3 (Gold) is used to grant level 3 access to your inventory-rings.
- Heart 0 (Silver) is used to clear your inventory-ring's whitelist completely (including ownership access).

To claim satchel-ownership of your chest/container's inventory-rings, simply shift-click on it while holding the level 3 (golden) heart. After that, shift-clicking on your chest/container will toggle "trusting mode" on or off, which determines whether others can use the level 1 and 2 hearts to join the whitelist (you will see a message saying "now accepting new trustees!" or "no longer accepting new trustees!" to indicate open or closed state to applications) After you do this, you can shift-click with a level 1 or 2 heart to set the access level that you want to allow others to be aple to apply with (you will see a message indicating that the trust level has changed).

For your personal inventory-ring, you can use the "/satchel_whitelist" command to add others to your whitelist for your personal inventory.<br>
The command is used in the form "/satchel_whitelist [name] [level]" (level can be any number between 0 and 3)

### Commands

* "/satchel" This command allows you to change a few settings about the inventory-rings you summon. It can be used in the form "/satchel [setting] [value]" where setting is one of: Height, radius, typeface, speed or texture.
* "/satchel_mysettinglist" This command will whisper the user's setting list to them.
* "/satchel_mywhitelist" This command will whisper the user's whitelist to them. (Must have an inventory-ring open at the moment of calling to work.)
* "/satchel_whitelist_clear" This command clears the user's inventory-ring whitelist. (non-containers only, for containers like chests, use the silver heart(level 0)) also (Must have an inventory-ring open at the moment of calling to work.)
* "/satchel_whitelist" As mentioned above, this command is used to add someone to your active inventory-ring whitelist.(Must have an inventory-ring open at the moment of calling to work.)
* There are also a few admin-only commands.

### Crafting

One of the configuration settings in this mod allows you to enable or disable the ability to craft all of the items that this mod adds (Wand and all 4 trust items). If this is enabled, you must set a starter item to allow trivial crafting of the first level 0 heart. The rest of the items have builtin recipes that allow you to cyclically craft the hearts (shapeless single-item recipe) or place two level 3 (golden) hearts in a stick-like recipe to make the wand.

### Configuration and Settings

Settings:<br>
* Height - This affects the height of your inventory-ring. Max value: 2
* Radius - Controls the radius of your inventory-ring, which affects the spread of the items. Max value: 1.6
* Speed - Controls the speed at which your item entities rotate. Max value 2.4, Min value 0 (stationary)
* Typeface - The value of this setting allows you to change how your hotbar slots are labeled in your personal inventory-ring. Values range from 1 to 4.
* Texture - Like the typeface setting, this setting has a range, this setting allows you to select how your item pedestal entities look texture-wise. There are a total of 11 starting texture choices.<br><br>

Configs:<br>
Satchel comes with a small number of configurable settings that can be toggled by changing the boolean value in the "settings.lua" file (the only purpose of this file is to allow this).
The various config settings and what they do are defined in the "settingtypes.txt" file, if you are interested. Most osettings are on by default.
