;###########################
;#                          #
;# GWCA Update By 3vcloud  #
;# C+ to Au3   By MrJambix #
;###########################

;GWCA: https://github.com/gwdevhub/GWCA

#region Model IDs and Settings
;Global Enum $Hero_Merc1 = 28, $Hero_Merc2, $Hero_Merc3, $Hero_Merc4
;Global Enum $Hero_Merc5 = 32, $Hero_Merc6, $Hero_Merc7, $Hero_Merc8
##EndRegion Model IDs and Settings

#include-once
; GAME_CMSG_ - Trade related
Global Const $HEADER_TRADE_ACKNOWLEDGE = 0x0000 ; Acknowledges a trade request or action
Global Const $HEADER_TRADE_CANCEL = 0x0001 ; Cancels an ongoing trade
Global Const $HEADER_TRADE_ADD_ITEM = 0x0002 ; Adds an item to the trade window
Global Const $HEADER_TRADE_SEND_OFFER = 0x0003 ; Sends a trade offer to the other party
Global Const $HEADER_TRADE_REMOVE_ITEM = 0x0005 ; Removes an item from the trade window
Global Const $HEADER_TRADE_CANCEL_OFFER = 0x0006 ; Cancels a previously sent trade offer
Global Const $HEADER_TRADE_ACCEPT = 0x0007 ; Accepts a trade offer
Global Const $HEADER_TRADE_INITIATE = 0x0047 ; Initiates a trade with another player
Global Const $HEADER_REQUEST_QUOTE = 0x004A ; Requests a quote or price for an item
Global Const $HEADER_TRANSACT_ITEMS = 0x004B ; Confirms a transaction involving items

; GAME_CMSG_ - Connection and Ping
Global Const $HEADER_DISCONNECT = 0x0008 ; Disconnects from the server or session
Global Const $HEADER_PING_REPLY = 0x0009 ; Sends a reply to a ping request
Global Const $HEADER_HEARTBEAT = 0x000A ; Sends a heartbeat signal to maintain connection
Global Const $HEADER_PING_REQUEST = 0x000B ; Requests a ping to check the connection status

; GAME_CMSG_ - Attributes and Skills
Global Const $HEADER_ATTRIBUTE_DECREASE = 0x000C ; Decreases a player's attribute level
Global Const $HEADER_ATTRIBUTE_INCREASE = 0x000D ; Increases a player's attribute level
Global Const $HEADER_ATTRIBUTE_LOAD = 0x000E ; Loads a set of player attributes
Global Const $HEADER_SKILLBAR_SKILL_SET = 0x005A ; Sets a skill in the player's skill bar
Global Const $HEADER_SKILLBAR_LOAD = 0x005B ; Loads a complete skill bar setup
Global Const $HEADER_SKILLBAR_SKILL_REPLACE = 0x005C ; Replaces a skill in the skill bar

; GAME_CMSG_ - Quests
Global Const $HEADER_QUEST_ABANDON = 0x000F ; Abandons a selected quest
Global Const $HEADER_QUEST_REQUEST_INFOS = 0x0010 ; Requests information about a quest
Global Const $HEADER_QUEST_SET_ACTIVE_CONFIRMED = 0x0012 ; Confirms setting a quest as active

; GAME_CMSG_ - Heroes and NPCs
Global Const $HEADER_HERO_BEHAVIOR = 0x0013 ; Sets the behavior/aggression level of a hero
Global Const $HEADER_HERO_LOCK_TARGET = 0x0014 ; Locks a target for the hero
Global Const $HEADER_HERO_SKILL_TOGGLE = 0x0017 ; Toggles a hero's skill on or off
Global Const $HEADER_HERO_FLAG_SINGLE = 0x0018 ; Sets a position flag for a single hero
Global Const $HEADER_HERO_FLAG_ALL = 0x0019 ; Sets a position flag for all heroes
Global Const $HEADER_HERO_USE_SKILL = 0x001A ; Uses a skill as a hero
Global Const $HEADER_HERO_ADD = 0x001C ; Adds a hero to the party
Global Const $HEADER_HERO_KICK = 0x001D ; Removes a hero from the party

; GAME_CMSG_ - Targeting and Movement
Global Const $HEADER_ATTACK_AGENT = 0x0024 ; Initiates an attack on a selected agent
Global Const $HEADER_CANCEL_MOVEMENT = 0x0026 ; Cancels the current movement or action
Global Const $HEADER_MOVE_TO_COORD = 0x003C ; Moves to specified coordinates
Global Const $HEADER_INTERACT_ITEM = 0x003D ; Interacts with an item in the environment
Global Const $HEADER_ROTATE_PLAYER = 0x003E ; Rotates the player character
Global Const $HEADER_DRAW_MAP = 0x0029 ; Draws on the map (for map pinging/markers)

; GAME_CMSG_ - Inventory and Items
Global Const $HEADER_DROP_ITEM = 0x002A ; Drops an item from the inventory to the ground
Global Const $HEADER_DROP_GOLD = 0x002D ; Drops gold from the inventory
Global Const $HEADER_EQUIP_ITEM = 0x002E ; Equips an item from the inventory
Global Const $HEADER_UNEQUIP_ITEM = 0x004D ; Unequips an item
Global Const $HEADER_INTERACT_GADGET = 0x004F ; Interacts with a gadget or device in the game
Global Const $HEADER_SEND_SIGNPOST_DIALOG = 0x0051 ; Sends a dialog or interaction to a signpost
Global Const $HEADER_EQUIP_VISIBILITY = 0x0055 ; Toggles the visibility of equipped items
Global Const $HEADER_ITEM_APPLY_DYE = 0x0068 ; Applies dye to an item
Global Const $HEADER_ITEM_IDENTIFY = 0x006A ; Identifies an item
Global Const $HEADER_TOME_UNLOCK_SKILL = 0x006B ; Unlocks a skill using a tome
Global Const $HEADER_ITEM_MOVE = 0x0070 ; Moves an item within the inventory
Global Const $HEADER_ITEM_ACCEPT_ALL = 0x0071 ; Accepts all items in a loot or reward screen
Global Const $HEADER_ITEM_SPLIT_STACK = 0x0073 ; Splits a stack of items
;Global Const $HEADER_ITEM_SALVAGE_SESSION_OPEN = 0x0075 ; Opens a salvage session
;Global Const $HEADER_ITEM_SALVAGE_SESSION_CANCEL = 0x0076 ; Cancels a salvage session
;Global Const $HEADER_ITEM_SALVAGE_SESSION_DONE = 0x0077 ; Completes a salvage session
;Global Const $HEADER_ITEM_SALVAGE_MATERIALS = 0x0078 ; Salvages materials from an item
;Global Const $HEADER_ITEM_SALVAGE_UPGRADE = 0x0079 ; Salvages upgrades from an item
Global Const $HEADER_ITEM_CHANGE_GOLD = 0x007A ; Moves gold between the player and storage

; GAME_CMSG_ - Instance Management
Global Const $HEADER_INSTANCE_LOAD_REQUEST_SPAWN = 0x0086 ; Requests spawn in an instance
Global Const $HEADER_INSTANCE_LOAD_REQUEST_PLAYERS = 0x008E ; Requests player information in an instance
Global Const $HEADER_INSTANCE_LOAD_REQUEST_ITEMS = 0x008F ; Requests item information in an instance
;Global Const $HEADER_PARTY_SET_DIFFICULTY = 0x0099 ; Sets the difficulty level for a party
;Global Const $HEADER_PARTY_SET_DIFFICULTY = 0x01BD ; Sets the difficulty for a party
Global Const $HEADER_PARTY_ACCEPT_INVITE = 0x009A ; Accepts a party invitation
Global Const $HEADER_PARTY_ACCEPT_CANCEL = 0x009B ; Cancels an acceptance of a party invite
Global Const $HEADER_PARTY_ACCEPT_REFUSE = 0x009C ; Refuses a party invitation
Global Const $HEADER_PARTY_INVITE_NPC = 0x009D ; Invites an NPC to the party
Global Const $HEADER_PARTY_INVITE_PLAYER = 0x009E ; Invites a player to the party
Global Const $HEADER_PARTY_INVITE_PLAYER_NAME = 0x009F ; Invites a player to the party by name
Global Const $HEADER_PARTY_LEAVE_GROUP = 0x00A0 ; Leaves the current party or group
Global Const $HEADER_PARTY_CANCEL_ENTER_CHALLENGE = 0x00A1 ; Cancels entry into a challenge or mission
Global Const $HEADER_PARTY_ENTER_CHALLENGE = 0x00A3 ; Enters a challenge or mission
Global Const $HEADER_PARTY_RETURN_TO_OUTPOST = 0x00A5 ; Returns the party to the outpost
Global Const $HEADER_PARTY_KICK_NPC = 0x00A6 ; Removes an NPC from the party
Global Const $HEADER_PARTY_KICK_PLAYER = 0x00A7 ; Kicks a player from the party
Global Const $HEADER_PARTY_SEARCH_SEEK = 0x00A8 ; Seeks members for party formation
Global Const $HEADER_PARTY_SEARCH_CANCEL = 0x00A9 ; Cancels a party search
Global Const $HEADER_PARTY_SEARCH_REQUEST_JOIN = 0x00AA ; Requests to join a party search
Global Const $HEADER_PARTY_SEARCH_REQUEST_REPLY = 0x00AB ; Replies to a party search join request
Global Const $HEADER_PARTY_SEARCH_TYPE = 0x00AC ; Sets the type of party search
Global Const $HEADER_PARTY_READY_STATUS = 0x00AD ; Indicates ready status in a party
Global Const $HEADER_PARTY_ENTER_GUILD_HALL = 0x00AE ; Enters a guild hall
Global Const $HEADER_PARTY_TRAVEL = 0x00AF ; Travels to a different location
Global Const $HEADER_PARTY_LEAVE_GUILD_HALL = 0x00B0 ; Leaves

;====================NO CHANGES FROM HERE DOWN=======================================

;=QUEST=
Global Const $HEADER_QUEST_ACCEPT = 0x39 ;Accepts a quest from the NPC
Global Const $HEADER_QUEST_REWARD = 0x39 ;Retrieves Quest reward from NPC

;=HERO=
Global Const $HEADER_HERO_AGGRESSION = 0x13 ;Sets the heroes aggression level
Global Const $HEADER_HERO_LOCK = 0x14 ;Locks the heroes target
Global Const $HEADER_HERO_TOGGLE_SKILL = 0x17 ;Enables or disables the heroes skill
Global Const $HEADER_HERO_PLACE_FLAG = 0x18 ;Sets the heroes position flag, hero runs to position
Global Const $HEADER_HERO_CLEAR_FLAG = 0x18 ;Clears the heroes position flag
Global Const $HEADER_USE_HERO_SKILL = 0x1A ;For use with UseHeroSkillByPacket() only

;=PARTY=
Global Const $HEADER_PARTY_PLACE_FLAG = 0x19 ;Sets the party position flag, all party-npcs runs to position
Global Const $HEADER_PARTY_CLEAR_FLAG = 0x19 ;Clears the party position flag
Global Const $HEADER_HENCHMAN_ADD = 0x9D ;Adds henchman to party
Global Const $HEADER_PARTY_LEAVE = 0xA0 ;Leaves the party
Global Const $HEADER_HENCHMAN_KICK = 0xA6 ;Kicks a henchman from party
Global Const $HEADER_INVITE_TARGET = 0x9E ;Invite target player to party
Global Const $HEADER_INVITE_CANCEL = 0x9B ;Cancel invitation of player
Global Const $HEADER_INVITE_ACCEPT = 0x9A ;Accept invitation to party

;=TARGET (Enemies or NPC)=
Global Const $HEADER_CALL_TARGET = 0x21 ;Calls the target without attacking (Ctrl+Shift+Space)
Global Const $HEADER_CANCEL_ACTION = 0x26 ;Cancels the current action
Global Const $HEADER_AGENT_FOLLOW = 0x31 ;Follows the agent/npc. Ctrl+Click triggers "I am following Person" in chat
Global Const $HEADER_NPC_TALK = 0x37 ;talks/goes to npc
Global Const $HEADER_SIGNPOST_RUN = 0x4F ;Runs to signpost

Global Const $HEADER_OPEN_CHEST = 0x0051

;=DROP=
Global Const $HEADER_ITEM_DROP = 0x2A ;Drops item from inventory to ground
Global Const $HEADER_GOLD_DROP = 0x2D ;Drops gold from inventory to ground

;=BUFFS=
Global Const $HEADER_STOP_MAINTAIN_ENCH = 0x27 ;Drops buff, cancel enchantmant, whatever you call it

;=ITEMS=
Global Const $HEADER_ITEM_EQUIP = 0x2E ;Equips item from inventory/chest/no idea
Global Const $HEADER_ITEM_PICKUP = 0x3D ;Picks up an item from ground
Global Const $HEADER_ITEM_DESTROY = 0x67 ;Destroys the item
Global Const $HEADER_ITEM_ID = 0x6A ;Identifies item in inventory
Global Const $HEADER_ITEMS_ACCEPT_UNCLAIMED = 0x71 ;Accepts ITEMS not picked up in missions
Global Const $HEADER_ITEM_MOVE_EX = 0x73 ;Moves an item, with amount to be moved.
Global Const $HEADER_SALVAGE_MATS = 0x78 ;Salvages materials from item
Global Const $HEADER_SALVAGE_MODS = 0x79 ;Salvages mods from item
Global Const $HEADER_SALVAGE_SESSION = 0x75 ;Salvages mods from item
Global Const $HEADER_ITEM_USE = 0x7C ;Uses item from inventory/chest
Global Const $HEADER_ITEM_UNEQUIP = 0x4D ;Unequip item
Global Const $HEADER_UPGRADE = 0x86 ;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_UPGRADE_ARMOR_1 = 0x83 ;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_UPGRADE_ARMOR_2 = 0x86 ;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_EQUIP_BAG = 0x70
;Global Const $HEADER_USE_ITEM = 0x85

;=TRADE=
Global Const $HEADER_TRADE_PLAYER = 0x47 ;Send trade request to player
Global Const $HEADER_TRADE_OFFER_ITEM = 0x02 ;Add item to trade window
Global Const $HEADER_TRADE_SUBMIT_OFFER = 0x03 ;Submit offer
;Global Const $HEADER_TRADE_CHANGE_OFFER = 0x06 ;Change offer

;=TRAVEL=
Global Const $HEADER_MAP_TRAVEL = 0xAF ;Travels to outpost via worldmap
Global Const $HEADER_GUILDHALL_TRAVEL = 0xAE ;Travels to guild hall
Global Const $HEADER_GUILDHALL_LEAVE = 0xB0 ;Leaves Guildhall

;=FACTION=
Global Const $HEADER_FACTION_DONATE = 0x0033 ;Donates kurzick/luxon faction to ally

;=DIALOG=
Global Const $HEADER_DIALOG = 0x39 ;Sends a dialog to NPC
Global Const $HEADER_CINEMATIC_SKIP = 0x61 ;Skips the cinematic
Global Const $HEADER_HOM_DIALOG = 0x58

;=SKILL / BUILD=
Global Const $HEADER_SET_SKILLBAR_SKILL = 0x5C ;Changes a skill on the skillbar
Global Const $HEADER_LOAD_SKILLBAR = 0x5B ;Loads a complete build
Global Const $HEADER_CHANGE_SECONDARY = 0x48 ;Changes Secondary class (from Build window, not class changer)
Global Const $HEADER_SKILL_USE_ALLY = 0x4B ;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_FOE = 0x4B ;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_ID = 0x4B ;
Global Const $HEADER_SET_ATTRIBUTES = 0x0E ;hidden in init stuff like sendchat
Global Const $HEADER_OPEN_SKILLS = 0x40
Global Const $HEADER_USE_SKILL = 0x44
Global Const $HEADER_PROFESSION_ULOCK = 0x40

;=CHEST=
Global Const $HEADER_CHEST_OPEN = 0x51 ;Opens a chest (with key AFAIK)
Global Const $HEADER_CHANGE_GOLD = 0x7A ;Moves Gold (from chest to inventory, and otherway around IIRC)

;=MISSION=
Global Const $HEADER_MODE_SWITCH = 0x99 ;Toggles hard- and normal mode
Global Const $HEADER_MISSION_ENTER = 0xA3 ;Enter a mission/challenge
Global Const $HEADER_MISSION_FOREIGN_ENTER = 0xAE ;Enters a foreign mission/challenge (no idea honestly)
Global Const $HEADER_OUTPOST_RETURN = 0xA5 ;Returns to outpost after /resign

;=CHAT=
Global Const $HEADER_SEND_CHAT = 0x62 ;Needed for sending messages in chat

;=MOVEMENT=
Global Const $HEADER_MOVEMENT_TICK = 0x1E

;=OTHER CONSTANTS=
Global Const $HEADER_MAX_ATTRIBUTES_CONST_5 = 0x03 ;constant at word 5 of max attrib packet. Changed from 3 to four in most recent update
Global Const $HEADER_MAX_ATTRIBUTES_CONST_22 = 0x03 ;constant at word 22 of max attrib packet. Changed from 3 to four in most recent update
Global Const $HEADER_OPEN_GB_WINDOW = 0x9E
Global Const $HEADER_CLOSE_GB_WINDOW = 0x9F
Global Const $HEADER_START_RATING_GVG = 0xA8

;=NEW CONSTANTS=
Global Const $HEADER_TITLE_UPDATE = 0x00F4 
Global Const $HEADER_TITLE_TRACK_INFO = 0x0075 
Global Const $HEADER_PLAYER_ATTR_UPDATE = 0x0086 
Global Const $HEADER_PLAYER_ATTR_SET = 0x0097 

;==================Opcodes Translation 
Global Const $HEADER_TRADE_REQUEST = 0x0000              ; Requests a trade
Global Const $HEADER_TRADE_TERMINATE = 0x0001            ; Terminates a trade
;Global Const $HEADER_TRADE_CHANGE_OFFER = 0x0002         ; Changes an offer in trade
Global Const $HEADER_TRADE_RECEIVE_OFFER = 0x0003        ; Receives a trade offer
;Global Const $HEADER_TRADE_ADD_ITEM = 0x0004             ; Adds an item to the trade
;Global Const $HEADER_TRADE_ACKNOWLEDGE = 0x0005          ; Acknowledges trade process
;Global Const $HEADER_TRADE_ACCEPT = 0x0006               ; Accepts a trade offer
Global Const $HEADER_TRADE_OFFERED_COUNT = 0x0008        ; Counts offered trades
;Global Const $HEADER_PING_REQUEST = 0x000C               ; Requests a ping
;Global Const $HEADER_PING_REPLY = 0x000D                 ; Replies to a ping
;Global Const $HEADER_FRIENDLIST_MESSAGE = 0x000E         ; Sends a message to friendlist
;Global Const $HEADER_ACCOUNT_CURRENCY = 0x000F           ; Updates account currency
Global Const $HEADER_AGENT_MOVEMENT_TICK = 0x001E        ; Updates movement tick of an agent
Global Const $HEADER_AGENT_INSTANCE_TIMER = 0x001F       ; Sets a timer for an agent instance
Global Const $HEADER_AGENT_SPAWNED = 0x0020              ; Spawns an agent
Global Const $HEADER_AGENT_DESPAWNED = 0x0021            ; Despawns an agent
Global Const $HEADER_AGENT_SET_PLAYER = 0x0022           ; Sets an agent as player
Global Const $HEADER_AGENT_UPDATE_DIRECTION = 0x0025     ; Updates agent's direction
Global Const $HEADER_AGENT_UPDATE_SPEED_BASE = 0x0027    ; Updates base speed of an agent
Global Const $HEADER_AGENT_STOP_MOVING = 0x0028          ; Stops agent's movement
Global Const $HEADER_AGENT_MOVE_TO_POINT = 0x0029        ; Moves an agent to a specific point
Global Const $HEADER_AGENT_UPDATE_DESTINATION = 0x002A   ; Updates an agent's destination
Global Const $HEADER_AGENT_UPDATE_SPEED = 0x002B         ; Updates an agent's speed
Global Const $HEADER_AGENT_UPDATE_POSITION = 0x002C      ; Updates an agent's position
Global Const $HEADER_AGENT_PLAYER_DIE = 0x002D           ; Notifies death of a player agent
Global Const $HEADER_AGENT_UPDATE_ROTATION = 0x002E      ; Updates an agent's rotation
Global Const $HEADER_AGENT_UPDATE_ALLEGIANCE = 0x002F    ; Updates an agent's allegiance
Global Const $HEADER_HERO_ACCOUNT_NAME = 0x0031          ; Updates hero account name
Global Const $HEADER_MESSAGE_OF_THE_DAY = 0x0033         ; Displays message of the day
Global Const $HEADER_AGENT_PINGED = 0x0034               ; Pings an agent
Global Const $HEADER_AGENT_UPDATE_ATTRIBUTE = 0x003B     ; Updates attributes of an agent
Global Const $HEADER_AGENT_ALLY_DESTROY = 0x003D         ; Notifies destruction of an ally agent
Global Const $HEADER_EFFECT_UPKEEP_ADDED = 0x003E        ; Adds an upkeep effect
Global Const $HEADER_EFFECT_UPKEEP_REMOVED = 0x003F      ; Removes an upkeep effect
Global Const $HEADER_EFFECT_UPKEEP_APPLIED = 0x0040      ; Applies an upkeep effect
Global Const $HEADER_EFFECT_APPLIED = 0x0041             ; Applies an effect
Global Const $HEADER_EFFECT_RENEWED = 0x0042             ; Renews an effect
Global Const $HEADER_EFFECT_REMOVED = 0x0043             ; Removes an effect
Global Const $HEADER_SCREEN_SHAKE = 0x0045               ; Triggers a screen shake
Global Const $HEADER_AGENT_DISPLAY_CAPE = 0x0047         ; Displays a cape on an agent
Global Const $HEADER_QUEST_ADD = 0x0048                  ; Adds a quest
Global Const $HEADER_QUEST_DESCRIPTION = 0x004B          ; Describes a quest
Global Const $HEADER_QUEST_GENERAL_INFO = 0x004F         ; Provides general information about a quest
Global Const $HEADER_QUEST_UPDATE_MARKER = 0x0050        ; Updates a quest marker
Global Const $HEADER_QUEST_REMOVE = 0x0051               ; Removes a quest
Global Const $HEADER_QUEST_ADD_MARKER = 0x0052           ; Adds a marker to a quest
Global Const $HEADER_QUEST_UPDATE_NAME = 0x0053          ; Updates the name of a quest
Global Const $HEADER_NPC_UPDATE_PROPERTIES = 0x0055      ; Updates properties of an NPC
Global Const $HEADER_NPC_UPDATE_MODEL = 0x0056           ; Updates the model of an NPC
Global Const $HEADER_AGENT_CREATE_PLAYER = 0x0058        ; Creates a player agent
Global Const $HEADER_AGENT_DESTROY_PLAYER = 0x0059       ; Destroys a player agent
Global Const $HEADER_CHAT_MESSAGE_CORE = 0x005C          ; Sends a core chat message
Global Const $HEADER_CHAT_MESSAGE_SERVER = 0x005D        ; Sends a server chat message
Global Const $HEADER_CHAT_MESSAGE_NPC = 0x005E           ; Sends an NPC chat message
Global Const $HEADER_CHAT_MESSAGE_GLOBAL = 0x005F        ; Sends a global chat message
Global Const $HEADER_CHAT_MESSAGE_LOCAL = 0x0060         ; Sends a local chat message
Global Const $HEADER_HERO_SKILL_STATUS = 0x0063          ; Updates hero skill status
Global Const $HEADER_HERO_SKILL_STATUS_BITMAP = 0x0064   ; Updates hero skill status bitmap
Global Const $HEADER_POST_PROCESS = 0x006A               ; Triggers post-processing
Global Const $HEADER_DUNGEON_REWARD = 0x006B             ; Provides a dungeon reward
Global Const $HEADER_NPC_UPDATE_WEAPONS = 0x006C         ; Updates weapons of an NPC
Global Const $HEADER_MERCENARY_INFO = 0x0073             ; Provides information about mercenaries
Global Const $HEADER_DIALOG_BUTTON = 0x007D              ; Displays a dialog button
Global Const $HEADER_DIALOG_BODY = 0x007F                ; Displays a dialog body
Global Const $HEADER_DIALOG_SENDER = 0x0080              ; Identifies the sender of a dialog
Global Const $HEADER_WINDOW_OPEN = 0x0082                ; Opens a window
Global Const $HEADER_WINDOW_ADD_ITEMS = 0x0083           ; Adds items to a window
Global Const $HEADER_WINDOW_ITEMS_END = 0x0084           ; Signals end of items in a window
Global Const $HEADER_WINDOW_ITEM_STREAM_END = 0x0085     ; Signals end of item stream in a window
Global Const $HEADER_CARTOGRAPHY_DATA = 0x0089           ; Updates cartography data
Global Const $HEADER_COMPASS_DRAWING = 0x0090            ; Updates compass with drawing
Global Const $HEADER_MAPS_UNLOCKED = 0x0093              ; Unlocks maps
Global Const $HEADER_AGENT_UPDATE_SCALE = 0x0099         ; Updates the scale of an agent
Global Const $HEADER_AGENT_UPDATE_NPC_NAME = 0x009A      ; Updates the name of an NPC agent
Global Const $HEADER_AGENT_DISPLAY_DIALOG = 0x009D       ; Displays a dialog from an agent
Global Const $HEADER_AGENT_ATTR_UPDATE_INT = 0x009E      ; Updates an integer attribute of an agent
Global Const $HEADER_AGENT_ATTR_UPDATE_INT_TARGET = 0x009F; Updates an integer attribute for a target agent
Global Const $HEADER_AGENT_ATTR_PLAY_EFFECT = 0x00A0     ; Plays an effect for an agent attribute
Global Const $HEADER_AGENT_ATTR_UPDATE_FLOAT = 0x00A1    ; Updates a floating point attribute of an agent
Global Const $HEADER_AGENT_ATTR_UPDATE_FLOAT_TARGET = 0x00A2; Updates a floating point attribute for a target agent
Global Const $HEADER_AGENT_PROJECTILE_LAUNCHED = 0x00A3  ; Notifies that a projectile has been launched
Global Const $HEADER_SPEECH_BUBBLE = 0x00A4              ; Displays a speech bubble
Global Const $HEADER_AGENT_UPDATE_PROFESSION = 0x00A5    ; Updates the profession of an agent
Global Const $HEADER_AGENT_CREATE_NPC = 0x00A9           ; Creates an NPC agent
Global Const $HEADER_UPDATE_AGENT_MODEL = 0x00AD         ; Updates the model of an agent
Global Const $HEADER_UPDATE_AGENT_PARTYSIZE = 0x00AF     ; Updates the party size for an agent
Global Const $HEADER_PLAYER_UNLOCKED_PROFESSION = 0x00B5 ; Unlocks a profession for a player
Global Const $HEADER_PLAYER_UPDATE_PROFESSION = 0x00B6   ; Updates a player's profession
Global Const $HEADER_MISSION_INFOBOX_ADD = 0x00B8        ; Adds an infobox to a mission
Global Const $HEADER_MISSION_STREAM_START = 0x00B9       ; Starts a mission stream
Global Const $HEADER_MISSION_OBJECTIVE_ADD = 0x00BA      ; Adds an objective to a mission
Global Const $HEADER_MISSION_OBJECTIVE_COMPLETE = 0x00BB ; Completes a mission objective
Global Const $HEADER_MISSION_OBJECTIVE_UPDATE_STRING = 0x00BC; Updates a string in a mission objective
Global Const $HEADER_WINDOW_MERCHANT = 0x00C2            ; Opens a merchant window
Global Const $HEADER_WINDOW_OWNER = 0x00C3               ; Identifies the owner of a window
Global Const $HEADER_TRANSACTION_REJECT = 0x00C5         ; Rejects a transaction
Global Const $HEADER_TRANSACTION_DONE = 0x00CB           ; Completes a transaction
Global Const $HEADER_SKILLBAR_UPDATE_SKILL = 0x00D8      ; Updates a skill in the skillbar
Global Const $HEADER_SKILLBAR_UPDATE = 0x00D9            ; Updates the skillbar
Global Const $HEADER_SKILLS_UNLOCKED = 0x00DA            ; Unlocks skills
Global Const $HEADER_SKILL_UPDATE_SKILL_COUNT_1 = 0x00DB ; Updates the count of skills (part 1)
Global Const $HEADER_SKILL_UPDATE_SKILL_COUNT_2 = 0x00DC ; Updates the count of skills (part 2)
Global Const $HEADER_SKILL_ADD_TO_WINDOWS_DATA = 0x00DF  ; Adds skill data to a window
Global Const $HEADER_SKILL_ADD_TO_WINDOWS_END = 0x00E0   ; Signals end of adding skill data to windows
Global Const $HEADER_SKILL_INTERUPTED = 0x00E1           ; Notifies a skill interruption
Global Const $HEADER_SKILL_CANCEL = 0x00E2               ; Cancels a skill
Global Const $HEADER_SKILL_ACTIVATED = 0x00E2            ; Activates a skill
Global Const $HEADER_SKILL_ACTIVATE = 0x00E3             ; Triggers skill activation
Global Const $HEADER_SKILL_RECHARGE = 0x00E4             ; Starts skill recharge
Global Const $HEADER_SKILL_RECHARGED = 0x00E5            ; Completes skill recharge
;Global Const $HEADER_PLAYER_ATTR_SET = 0x00E8            ; Sets player attributes
Global Const $HEADER_PLAYER_ATTR_MAX_KURZICK = 0x00E9    ; Sets max Kurzick points
Global Const $HEADER_PLAYER_ATTR_MAX_LUXON = 0x00EA      ; Sets max Luxon points
Global Const $HEADER_PLAYER_ATTR_MAX_BALTHAZAR = 0x00EB  ; Sets max Balthazar points
Global Const $HEADER_PLAYER_ATTR_MAX_IMPERIAL = 0x00EC   ; Sets max Imperial points
;Global Const $HEADER_PLAYER_ATTR_UPDATE = 0x00ED         ; Updates player attributes
Global Const $HEADER_AGENT_INITIAL_EFFECTS = 0x00EF      ; Applies initial effects to an agent
Global Const $HEADER_AGENT_UPDATE_EFFECTS = 0x00F0       ; Updates effects on an agent
Global Const $HEADER_INSTANCE_LOADED = 0x00F1            ; Notifies that an instance has loaded
Global Const $HEADER_TITLE_RANK_DATA = 0x00F2            ; Provides data for title ranks
Global Const $HEADER_TITLE_RANK_DISPLAY = 0x00F3         ; Displays a title rank
;Global Const $HEADER_TITLE_UPDATE = 0x00F4               ; Updates a title
;Global Const $HEADER_TITLE_TRACK_INFO = 0x00F5           ; Provides tracking information for a title
Global Const $HEADER_ITEM_PRICE_QUOTE = 0x00F6           ; Provides a price quote for an item
Global Const $HEADER_ITEM_PRICES = 0x00F8                ; Lists item prices
Global Const $HEADER_VANQUISH_PROGRESS = 0x00F9          ; Updates progress of vanquishing
Global Const $HEADER_VANQUISH_COMPLETE = 0x00FA          ; Completes vanquishing
Global Const $HEADER_CINEMATIC_SKIP_EVERYONE = 0x00FD    ; Skips cinematic for everyone
Global Const $HEADER_CINEMATIC_SKIP_COUNT = 0x00FE       ; Counts skips in a cinematic
Global Const $HEADER_CINEMATIC_START = 0x00FF            ; Starts a cinematic
Global Const $HEADER_CINEMATIC_TEXT = 0x0101             ; Displays text during a cinematic
Global Const $HEADER_CINEMATIC_DATA_END = 0x0102         ; Ends cinematic data
Global Const $HEADER_CINEMATIC_DATA = 0x0103             ; Provides cinematic data
Global Const $HEADER_CINEMATIC_END = 0x0104              ; Ends a cinematic
Global Const $HEADER_SIGNPOST_BUTTON = 0x0109            ; Displays a button on a signpost
Global Const $HEADER_SIGNPOST_BODY = 0x010A              ; Displays body text on a signpost
Global Const $HEADER_SIGNPOST_SENDER = 0x010B            ; Identifies the sender of a signpost message
Global Const $HEADER_MANIPULATE_MAP_OBJECT = 0x010D      ; Manipulates a map object
Global Const $HEADER_MANIPULATE_MAP_OBJECT2 = 0x0110     ; Manipulates a map object (second method)
Global Const $HEADER_GUILD_PLAYER_ROLE = 0x0117          ; Updates a player's role in a guild
Global Const $HEADER_TOWN_ALLIANCE_OBJECT = 0x0119       ; Updates a town alliance object
Global Const $HEADER_GUILD_ALLIANCE_INFO = 0x011F        ; Provides info on a guild alliance
Global Const $HEADER_GUILD_GENERAL_INFO = 0x0120         ; Provides general info about a guild
Global Const $HEADER_GUILD_CHANGE_FACTION = 0x0121       ; Changes a guild's faction
Global Const $HEADER_GUILD_INVITE_RECEIVED = 0x0122      ; Notifies receipt of a guild invite
Global Const $HEADER_GUILD_PLAYER_INFO = 0x0126          ; Updates info about a guild player
Global Const $HEADER_GUILD_PLAYER_REMOVE = 0x0127        ; Removes a player from a guild
Global Const $HEADER_GUILD_PLAYER_CHANGE_COMPLETE = 0x0129; Completes a change in a guild player's status
Global Const $HEADER_GUILD_CHANGE_PLAYER_CONTEXT = 0x012A; Changes context for a guild player
Global Const $HEADER_GUILD_CHANGE_PLAYER_STATUS = 0x012B ; Changes status of a guild player
Global Const $HEADER_GUILD_CHANGE_PLAYER_TYPE = 0x012C   ; Changes type of a guild player
Global Const $HEADER_ITEM_UPDATE_OWNER = 0x0134          ; Updates the owner of an item
Global Const $HEADER_ITEM_UPDATE_QUANTITY = 0x0138       ; Updates the quantity of an item
Global Const $HEADER_ITEM_UPDATE_NAME = 0x0139           ; Updates the name of an item
Global Const $HEADER_ITEM_MOVED_TO_LOCATION = 0x013D     ; Moves an item to a location
Global Const $HEADER_INVENTORY_CREATE_BAG = 0x013E       ; Creates a bag in the inventory
Global Const $HEADER_GOLD_CHARACTER_ADD = 0x013F         ; Adds gold to a character
Global Const $HEADER_GOLD_STORAGE_ADD = 0x0140           ; Adds gold to storage
Global Const $HEADER_ITEM_STREAM_CREATE = 0x0143         ; Creates an item stream
Global Const $HEADER_ITEM_STREAM_DESTROY = 0x0144        ; Destroys an item stream
Global Const $HEADER_ITEM_WEAPON_SET = 0x0146            ; Sets a weapon for an item
Global Const $HEADER_ITEM_SET_ACTIVE_WEAPON_SET = 0x0147 ; Sets the active weapon set
Global Const $HEADER_ITEM_CHANGE_LOCATION = 0x014A       ; Changes the location of an item
Global Const $HEADER_ITEM_REMOVE = 0x014C                ; Removes an item
Global Const $HEADER_GOLD_CHARACTER_REMOVE = 0x014E      ; Removes gold from a character
Global Const $HEADER_GOLD_STORAGE_REMOVE = 0x014F        ; Removes gold from storage
Global Const $HEADER_TOME_SHOW_SKILLS = 0x0153           ; Shows skills in a tome
Global Const $HEADER_ITEM_GENERAL_INFO = 0x0160          ; Provides general info about an item
Global Const $HEADER_ITEM_REUSE_ID = 0x0161              ; Reuses an item ID
Global Const $HEADER_ITEM_SALVAGE_SESSION_START = 0x0162 ; Starts a salvage session for an item
Global Const $HEADER_ITEM_SALVAGE_SESSION_CANCEL = 0x0163; Cancels a salvage session
Global Const $HEADER_ITEM_SALVAGE_SESSION_DONE = 0x0164  ; Completes a salvage session
Global Const $HEADER_ITEM_SALVAGE_SESSION_SUCCESS = 0x0165; Indicates a successful salvage session
Global Const $HEADER_ITEM_SALVAGE_SESSION_ITEM_KEPT = 0x0166; Keeps an item after a salvage session
Global Const $HEADER_INSTANCE_SHOW_WIN = 0x017A          ; Shows a win in an instance
Global Const $HEADER_INSTANCE_LOAD_HEAD = 0x017B         ; Loads head data for an instance
Global Const $HEADER_INSTANCE_LOAD_PLAYER_NAME = 0x017C  ; Loads a player name in an instance
Global Const $HEADER_INSTANCE_COUNTDOWN_STOP = 0x017D    ; Stops a countdown in an instance
Global Const $HEADER_INSTANCE_COUNTDOWN = 0x017F         ; Starts a countdown in an instance
Global Const $HEADER_INSTANCE_LOAD_FINISH = 0x018D       ; Finishes loading an instance
Global Const $HEADER_JUMBO_MESSAGE = 0x018F              ; Sends a jumbo size message
Global Const $HEADER_INSTANCE_LOAD_SPAWN_POINT = 0x0194  ; Loads a spawn point in an instance
Global Const $HEADER_INSTANCE_LOAD_INFO = 0x0198         ; Loads info for an instance
Global Const $HEADER_CREATE_MISSION_PROGRESS = 0x019F    ; Creates progress for a mission
Global Const $HEADER_UPDATE_MISSION_PROGRESS = 0x01A1    ; Updates progress for a mission
Global Const $HEADER_TRANSFER_GAME_SERVER_INFO = 0x01A4  ; Transfers game server info
Global Const $HEADER_READY_FOR_MAP_SPAWN = 0x01AA        ; Indicates readiness for map spawn
Global Const $HEADER_DOA_COMPLETE_ZONE = 0x01AE          ; Completes a zone in DOA
Global Const $HEADER_INSTANCE_TRAVEL_TIMER = 0x01BA      ; Sets a travel timer in an instance
Global Const $HEADER_INSTANCE_CANT_ENTER = 0x01BB        ; Indicates inability to enter an instance
Global Const $HEADER_PARTY_HENCHMAN_ADD = 0x01BE         ; Adds a henchman to a party
Global Const $HEADER_PARTY_HENCHMAN_REMOVE = 0x01BF      ; Removes a henchman from a party
Global Const $HEADER_PARTY_HERO_ADD = 0x01C1             ; Adds a hero to a party
Global Const $HEADER_PARTY_HERO_REMOVE = 0x01C2          ; Removes a hero from a party
Global Const $HEADER_PARTY_INVITE_ADD = 0x01C3           ; Adds an invite to a party
Global Const $HEADER_PARTY_JOIN_REQUEST = 0x01C4         ; Requests to join a party
Global Const $HEADER_PARTY_INVITE_CANCEL = 0x01C5        ; Cancels a party invite
Global Const $HEADER_PARTY_REQUEST_CANCEL = 0x01C6       ; Cancels a party request
Global Const $HEADER_PARTY_REQUEST_RESPONSE = 0x01C7     ; Responds to a party request
Global Const $HEADER_PARTY_INVITE_RESPONSE = 0x01C8      ; Responds to a party invite
Global Const $HEADER_PARTY_YOU_ARE_LEADER = 0x01C9       ; Notifies that you are the party leader
Global Const $HEADER_PARTY_PLAYER_ADD = 0x01CA           ; Adds a player to a party
Global Const $HEADER_PARTY_PLAYER_REMOVE = 0x01CF        ; Removes a player from a party
Global Const $HEADER_PARTY_PLAYER_READY = 0x01D0         ; Indicates a player is ready in a party
Global Const $HEADER_PARTY_CREATE = 0x01D1               ; Creates a party
Global Const $HEADER_PARTY_MEMBER_STREAM_END = 0x01D2    ; Ends a party member stream
Global Const $HEADER_PARTY_DEFEATED = 0x01D7             ; Notifies a party has been defeated
Global Const $HEADER_PARTY_LOCK = 0x01D8                 ; Locks a party
;Global Const $HEADER_PARTY_SEARCH_REQUEST_JOIN = 0x01DA  ; Requests to join a party search
Global Const $HEADER_PARTY_SEARCH_REQUEST_DONE = 0x01DB  ; Completes a party search request
Global Const $HEADER_PARTY_SEARCH_ADVERTISEMENT = 0x01DC ; Advertises a party search
;Global Const $HEADER_PARTY_SEARCH_SEEK = 0x01DD          ; Seeks a party search
Global Const $HEADER_PARTY_SEARCH_REMOVE = 0x01DE        ; Removes a party search
Global Const $HEADER_PARTY_SEARCH_SIZE = 0x01DF          ; Sets the size for a party search
;Global Const $HEADER_PARTY_SEARCH_TYPE = 0x01E0          ; Sets the type for a party search