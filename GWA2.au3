; This Version is specified for scripts coming from MrJambix, If it doesn't work for you check your functions vs this one.

; Require admin privileges
#RequireAdmin


#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_type=a3x
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /tl
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include "GWA2_Headers.au3"

If @AutoItX64 Then
	MsgBox(16, "Error!", "Please run all bots in 32-bit (x86) mode.")
	Exit
EndIf

#Region Declarations
; General settings and handles
Global $mGWA2Version = '0.0.0'
Global $mKernelHandle, $mGWProcHandle, $mMemory
Global $mBase = 0x00C50000
Global $mASMString, $mASMSize, $mASMCodeOffset
Global $SecondInject, $Rendering = True

; GUI elements
Global $mGUI = GUICreate('GWA2')
GUIRegisterMsg(0x501, 'Event')

; Structs for logging
Global $mSkillLogStruct = DllStructCreate('dword;dword;dword;float')
Global $mSkillLogStructPtr = DllStructGetPtr($mSkillLogStruct)
Global $mChatLogStruct = DllStructCreate('dword;wchar[256]')
Global $mChatLogStructPtr = DllStructGetPtr($mChatLogStruct)

; Game-related variables
Global $mQueueCounter, $mQueueSize, $mQueueBase
Global $mGWWindowHandle
Global $mTargetLogBase, $mStringLogBase, $mSkillBase
Global $mEnsureEnglish
Global $mCurrentTarget ;,$mMyID
Global $packetlocation
Global $mAgentBase, $mBasePointer, $mAgentArray
Global $mRegion ;, $mLanguage
Global $mPing, $mCharname ;, $mMapID
Global $mMaxAgents, $mMapLoading, $mMapIsLoaded, $mLoggedIn
Global $mStringHandlerPtr, $mWriteChatSender
Global $mTraderQuoteID, $mTraderCostID, $mTraderCostValue
Global $mSkillTimer, $mBuildNumber
Global $lTemp
Global $mZoomStill, $mZoomMoving
Global $mDisableRendering, $mAgentCopyCount, $mAgentCopyBase
Global $mCurrentStatus, $mLastDialogID
Global $mUseStringLog, $mUseEventSystem
Global $mCharslots
Global $mInstanceInfo, $mAreaInfo
Global $mAttributeInfo
Global $mWorldConst
#EndRegion Declarations

#Region CommandStructs
Global $mInviteGuild = DllStructCreate('ptr;dword;dword header;dword counter;wchar name[32];dword type')
Global $mInviteGuildPtr = DllStructGetPtr($mInviteGuild)

Global $mUseSkill = DllStructCreate('ptr;dword;dword;dword')
Global $mUseSkillPtr = DllStructGetPtr($mUseSkill)

Global $mMove = DllStructCreate('ptr;float;float;float')
Global $mMovePtr = DllStructGetPtr($mMove)

Global $mChangeTarget = DllStructCreate('ptr;dword')
Global $mChangeTargetPtr = DllStructGetPtr($mChangeTarget)

Global $mPacket = DllStructCreate('ptr;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword')
Global $mPacketPtr = DllStructGetPtr($mPacket)

Global $mWriteChat = DllStructCreate('ptr')
Global $mWriteChatPtr = DllStructGetPtr($mWriteChat)

Global $mSellItem = DllStructCreate('ptr;dword;dword;dword')
Global $mSellItemPtr = DllStructGetPtr($mSellItem)

Global $mAction = DllStructCreate('ptr;dword;dword;')
Global $mActionPtr = DllStructGetPtr($mAction)

Global $mToggleLanguage = DllStructCreate('ptr;dword')
Global $mToggleLanguagePtr = DllStructGetPtr($mToggleLanguage)

Global $mUseHeroSkill = DllStructCreate('ptr;dword;dword;dword')
Global $mUseHeroSkillPtr = DllStructGetPtr($mUseHeroSkill)

Global $mBuyItem = DllStructCreate('ptr;dword;dword;dword;dword')
Global $mBuyItemPtr = DllStructGetPtr($mBuyItem)

Global $mCraftItemEx = DllStructCreate('ptr;dword;dword;ptr;dword;dword')
Global $mCraftItemExPtr = DllStructGetPtr($mCraftItemEx)

Global $mSendChat = DllStructCreate('ptr;dword')
Global $mSendChatPtr = DllStructGetPtr($mSendChat)

Global $mRequestQuote = DllStructCreate('ptr;dword')
Global $mRequestQuotePtr = DllStructGetPtr($mRequestQuote)

Global $mRequestQuoteSell = DllStructCreate('ptr;dword')
Global $mRequestQuoteSellPtr = DllStructGetPtr($mRequestQuoteSell)

Global $mTraderBuy = DllStructCreate('ptr')
Global $mTraderBuyPtr = DllStructGetPtr($mTraderBuy)

Global $mTraderSell = DllStructCreate('ptr')
Global $mTraderSellPtr = DllStructGetPtr($mTraderSell)

Global $mSalvage = DllStructCreate('ptr;dword;dword;dword')
Global $mSalvagePtr = DllStructGetPtr($mSalvage)

Global $mIncreaseAttribute = DllStructCreate('ptr;dword;dword')
Global $mIncreaseAttributePtr = DllStructGetPtr($mIncreaseAttribute)

Global $mDecreaseAttribute = DllStructCreate('ptr;dword;dword')
Global $mDecreaseAttributePtr = DllStructGetPtr($mDecreaseAttribute)

Global $mMaxAttributes = DllStructCreate("ptr;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword")
Global $mMaxAttributesPtr = DllStructGetPtr($mMaxAttributes)

Global $mSetAttributes = DllStructCreate("ptr;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword;dword")
Global $mSetAttributesPtr = DllStructGetPtr($mSetAttributes)

Global $mMakeAgentArray = DllStructCreate('ptr;dword')
Global $mMakeAgentArrayPtr = DllStructGetPtr($mMakeAgentArray)

Global $mChangeStatus = DllStructCreate('ptr;dword')
Global $mChangeStatusPtr = DllStructGetPtr($mChangeStatus)

Global $MTradeHackAddress
Global $mLabels[1][2] = [[0]]
#EndRegion CommandStructs

#Region Gwa2 Structs
Global $g_AgentStruct = DllStructCreate('ptr vtable;dword h0004[4];dword timer;dword timer2;dword h0018[4];long Id;float Z;float width1;float height1;float width2;float height2;float width3;float height3;float Rotation;float rotation_cos;float rotation_sin;dword NameProperties;dword ground;dword h0060;float terrain_normal_x;float terrain_normal_y;dword terrain_normal_z;byte h0070[4];float X;float Y;dword plane;byte h0080[4];float NameTagX;float NameTagY;float NameTagZ;short visual_effects;short h0092;dword h0094[2];long Type;float MoveX;float MoveY;dword h00A8;float rotation_cos2;float rotation_sin2;dword h00B4[4];long Owner;dword ItemID;dword ExtraType;dword GadgetID;dword h00D4[3];float animation_type;dword h00E4[2];float AttackSpeed;float AttackSpeedModifier;short PlayerNumber;short agent_model_type;dword transmog_npc_id;ptr Equip;dword h0100;ptr tags;short h0108;byte Primary;byte Secondary;byte Level;byte Team;byte h010E[2];dword h0110;float energy_regen;float overcast;float EnergyPercent;dword MaxEnergy;dword h0124;float HPPips;dword h012C;float HP;dword MaxHP;dword Effects;dword h013C;byte Hex;byte h0141[19];dword ModelState;dword TypeMap;dword h015C[4];dword InSpiritRange;dword visible_effects;dword visible_effects_ID;dword visible_effects_has_ended;dword h017C;dword LoginNumber;float animation_speed;dword animation_code;dword animation_id;byte h0190[32];byte LastStrike;byte Allegiance;short WeaponType;short Skill;short h01B6;byte weapon_item_type;byte offhand_item_type;short WeaponItemId;short OffhandItemId')
Global $g_ItemStruct = DllStructCreate('long Id;long AgentId;ptr BagEquiped;ptr Bag;ptr ModStruct;long ModStructSize;ptr Customized;long ModelFileID;byte Type;byte unknown4;short ExtraId;short Value;short Unknown1;short Interaction;long ModelId;ptr InfoString;ptr NameEnc;ptr CompleteNameEnc;ptr SingleItemName;long Unknown2[2];short ItemFormula;byte IsMaterialSalvageable;byte Unknown3;short Quantity;byte Equiped;byte Profession;byte Slot')
Global $g_BuffStruct = DllStructCreate('long SkillId;long unknown1;long BuffId;long TargetId')
Global $g_EffectStruct = DllStructCreate('long SkillId;long AttributeLevel;long EffectId;long AgentId;float Duration;long TimeStamp')
Global $g_BagStruct = DllStructCreate('long TypeBag;long index;long unknown1;ptr containerItem;long ItemsCount;ptr bagArray;ptr itemArray;long fakeSlots;long slots')
Global $g_SkillbarStruct = DllStructCreate('long AgentId;long AdrenalineA1;long AdrenalineB1;dword Recharge1;dword Id1;dword Event1;long AdrenalineA2;long AdrenalineB2;dword Recharge2;dword Id2;dword Event2;long AdrenalineA3;long AdrenalineB3;dword Recharge3;dword Id3;dword Event3;long AdrenalineA4;long AdrenalineB4;dword Recharge4;dword Id4;dword Event4;long AdrenalineA5;long AdrenalineB5;dword Recharge5;dword Id5;dword Event5;long AdrenalineA6;long AdrenalineB6;dword Recharge6;dword Id6;dword Event6;long AdrenalineA7;long AdrenalineB7;dword Recharge7;dword Id7;dword Event7;long AdrenalineA8;long AdrenalineB8;dword Recharge8;dword Id8;dword Event8;dword disabled;long unknown1[2];dword Casting;long unknown2[2]')
Global $g_SkillStruct = DllStructCreate('long ID;long Unknown1;long campaign;long Type;long Special;long ComboReq;long Effect1;long Condition;long Effect2;long WeaponReq;byte Profession;byte Attribute;short Title;long PvPID;byte Combo;byte Target;byte unknown3;byte EquipType;byte Overcast;byte EnergyCost;byte HealthCost;byte unknown4;dword Adrenaline;float Activation;float Aftercast;long Duration0;long Duration15;long Recharge;long Unknown5[4];dword SkillArguments;long Scale0;long Scale15;long BonusScale0;long BonusScale15;float AoERange;float ConstEffect;dword caster_overhead_animation_id;dword caster_body_animation_id;dword target_body_animation_id;dword target_overhead_animation_id;dword projectile_animation_1_id;dword projectile_animation_2_id;dword icon_file_id;dword icon_file_id_2;dword name;dword concise;dword description')
Global $g_AttributeStruct = DllStructCreate('dword profession_id;dword attribute_id;dword name_id;dword desc_id;dword is_pve')
Global $g_AreaInfoStruct = DllStructCreate("dword campaign;dword continent;dword region;dword regiontype;dword flags;dword thumbnail_id;dword min_party_size;dword max_party_size;dword min_player_size;dword max_player_size;dword controlled_outpost_id;dword fraction_mission;dword min_level;dword max_level;dword needed_pq;dword mission_maps_to;dword x;dword y;dword icon_start_x;dword icon_start_y;dword icon_end_x;dword icon_end_y;dword icon_start_x_dupe;dword icon_start_y_dupe;dword icon_end_x_dupe;dword icon_end_y_dupe;dword file_id;dword mission_chronology;dword ha_map_chronology;dword name_id;dword description_id")
Global $g_QuestStruct = DllStructCreate('long id;long LogState;ptr Location;ptr Name;ptr NPC;long MapFrom;float X;float Y;long Z;long unlnown1;long MapTo;ptr Description;ptr Objective')
Global $g_WorldStruct = DllStructCreate('long MinGridWidth;long MinGridHeight;long MaxGridWidth;long MaxGridHeight;long Flags;long Type;long SubGridWidth;long SubGridHeight;long StartPosX;long StartPosY;long MapWidth;long MapHeight')
#EndRegion Gwa2 Structs

#Region Memory
;~ Description: Internal use only.
Func MemoryOpen($aPID)
	$mKernelHandle = DllOpen('kernel32.dll')
	Local $lOpenProcess = DllCall($mKernelHandle, 'int', 'OpenProcess', 'int', 0x1F0FFF, 'int', 1, 'int', $aPID)
	$mGWProcHandle = $lOpenProcess[0]
EndFunc   ;==>MemoryOpen

;~ Description: Internal use only.
Func MemoryClose()
	DllCall($mKernelHandle, 'int', 'CloseHandle', 'int', $mGWProcHandle)
	DllClose($mKernelHandle)
EndFunc   ;==>MemoryClose

;~ Description: Internal use only.
Func WriteBinary($aBinaryString, $aAddress)
	Local $lData = DllStructCreate('byte[' & 0.5 * StringLen($aBinaryString) & ']'), $i
	For $i = 1 To DllStructGetSize($lData)
		DllStructSetData($lData, 1, Dec(StringMid($aBinaryString, 2 * $i - 1, 2)), $i)
	Next
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'ptr', $aAddress, 'ptr', DllStructGetPtr($lData), 'int', DllStructGetSize($lData), 'int', 0)
EndFunc   ;==>WriteBinary

;~ Description: Internal use only.
Func MemoryWrite($aAddress, $aData, $aType = 'dword')
	Local $lBuffer = DllStructCreate($aType)
	DllStructSetData($lBuffer, 1, $aData)
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
EndFunc   ;==>MemoryWrite

;~ Description: Internal use only.
Func MemoryRead($aAddress, $aType = 'dword')
	Local $lBuffer = DllStructCreate($aType)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
	Return DllStructGetData($lBuffer, 1)
EndFunc   ;==>MemoryRead

;~ Description: Internal use only.
Func MemoryReadPtr($aAddress, $aOffset, $aType = 'dword')
	Local $lPointerCount = UBound($aOffset) - 2
	Local $lBuffer = DllStructCreate('dword')
	For $i = 0 To $lPointerCount
		$aAddress += $aOffset[$i]
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
		$aAddress = DllStructGetData($lBuffer, 1)
		If $aAddress == 0 Then
			Local $lData[2] = [0, 0]
			Return $lData
		EndIf
	Next
	$aAddress += $aOffset[$lPointerCount + 1]
	$lBuffer = DllStructCreate($aType)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $aAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
	Local $lData[2] = [Ptr($aAddress), DllStructGetData($lBuffer, 1)]
	Return $lData
EndFunc   ;==>MemoryReadPtr

;~ Description: Internal use only.
Func SwapEndian($aHex)
	Return StringMid($aHex, 7, 2) & StringMid($aHex, 5, 2) & StringMid($aHex, 3, 2) & StringMid($aHex, 1, 2)
EndFunc   ;==>SwapEndian
#EndRegion Memory

#Region Initialisation
;~ Description: Returns a list of logged characters
Func GetLoggedCharNames()
	Local $array = ScanGW()
	If $array[0] == 0 Then Return '' ; No characters logged
	Local $ret = $array[1] ; Start with the first character name
	For $i = 2 To $array[0] ; Concatenate remaining names, if any
		$ret &= "|" & $array[$i]
	Next
	Return $ret
EndFunc   ;==>GetLoggedCharNames

;~ Description: Returns an array of logged characters of gw windows (at pos 0 there is the size of the array)
Func ScanGW()
	Local $lProcessList = ProcessList("gw.exe")
	Local $lReturnArray[1] = [0]

	For $i = 1 To $lProcessList[0][0]
		MemoryOpen($lProcessList[$i][1])

		If $mGWProcHandle Then
			$lReturnArray[0] += 1
			ReDim $lReturnArray[$lReturnArray[0] + 1]
			$lReturnArray[$lReturnArray[0]] = ScanForCharname()
		EndIf

		MemoryClose()

		$mGWProcHandle = 0
	Next

	Return $lReturnArray
EndFunc   ;==>ScanGW

Func GetHwnd($aProc)
	Local $wins = WinList()
	For $i = 1 To UBound($wins) - 1
		If (WinGetProcess($wins[$i][1]) == $aProc) And (BitAND(WinGetState($wins[$i][1]), 2)) Then Return $wins[$i][1]
	Next
EndFunc   ;==>GetHwnd

;~ Description: Injects GWA² into the game client.
Func Initialize($aGW, $bChangeTitle = True, $aUseStringLog = False, $aUseEventSystem = True)
	; Initialize variables
	Local $mGWProcessId
	$mUseStringLog = $aUseStringLog
	$mUseEventSystem = $aUseEventSystem

	; Check if $aGW is a string or a process ID
	If IsString($aGW) Then
		; Find the process ID of the game client
		Local $lProcessList = ProcessList("gw.exe")
		For $i = 1 To $lProcessList[0][0]
			$mGWProcessId = $lProcessList[$i][1]
			$mGWWindowHandle = GetHwnd($mGWProcessId)
			MemoryOpen($mGWProcessId)
			If $mGWProcHandle Then
				; Check if the character name matches
				If StringRegExp(ScanForCharname(), $aGW) = 1 Then
					ExitLoop
				EndIf
			EndIf
			MemoryClose()
			$mGWProcHandle = 0
		Next
	Else
		; Use the provided process ID
		$mGWProcessId = $aGW
		$mGWWindowHandle = GetHwnd($mGWProcessId)
		MemoryOpen($aGW)
		ScanForCharname()
	EndIf

	Scan()

	; Read Memory Values for Game Data
	$mBasePointer = MemoryRead(GetScannedAddress('ScanBasePointer', 8))
	SetValue('BasePointer', '0x' & Hex($mBasePointer, 8))

	$mAgentBase = MemoryRead(GetScannedAddress('ScanAgentBasePointer', 8) + 0xC - 7)
	SetValue('AgentBase', '0x' & Hex($mAgentBase, 8))

	$mMaxAgents = $mAgentBase + 8
	SetValue('MaxAgents', '0x' & Hex($mMaxAgents, 8))

	$mAgentArray = MemoryRead(GetScannedAddress('ScanAgentArray', -0x3))

;~    $mMyID = MemoryRead(GetScannedAddress('ScanMyID', -3))
;~    SetValue('MyID', '0x' & Hex($mMyID, 8))

	$mCurrentTarget = MemoryRead(GetScannedAddress('ScanCurrentTarget', -14))

	$packetlocation = Hex(MemoryRead(GetScannedAddress('ScanBaseOffset', 11)), 8)
	SetValue('PacketLocation', '0x' & $packetlocation)

	$mPing = MemoryRead(GetScannedAddress('ScanPing', -0x14))

;~    $mMapID = MemoryRead(GetScannedAddress('ScanMapID', 28))

;~    $mMapLoading = MemoryRead(GetScannedAddress('ScanMapLoading', 0xB))

	$mLoggedIn = MemoryRead(GetScannedAddress('ScanLoggedIn', 0x3))

;~    $mLanguage = MemoryRead(GetScannedAddress('ScanMapInfo', 11)) + 0xC
;~    $mRegion = $mLanguage + 4
	$mRegion = MemoryRead(GetScannedAddress('ScanRegion', -0x3))


	$mSkillBase = MemoryRead(GetScannedAddress('ScanSkillBase', 8))
	$mSkillTimer = MemoryRead(GetScannedAddress('ScanSkillTimer', -3))

	$lTemp = GetScannedAddress('ScanBuildNumber', 0x2C)
	$mBuildNumber = MemoryRead($lTemp + MemoryRead($lTemp) + 5)

	$mZoomStill = GetScannedAddress("ScanZoomStill", 0x33)
	$mZoomMoving = GetScannedAddress("ScanZoomMoving", 0x21)

	$mCurrentStatus = MemoryRead(GetScannedAddress('ScanChangeStatusFunction', 35))
	$mCharslots = MemoryRead(GetScannedAddress('ScanCharslots', 22))

	$mInstanceInfo = MemoryRead(GetScannedAddress('ScanInstanceInfo', 0xE))
	$mAreaInfo = MemoryRead(GetScannedAddress('ScanAreaInfo', 0x6))


	$mAttributeInfo = MemoryRead(GetScannedAddress('ScanAttributeInfo', -0x3))

	$mWorldConst = MemoryRead(GetScannedAddress('ScanWorldConst', 8))

	$lTemp = GetScannedAddress('ScanEngine', -0x22)
	SetValue('MainStart', '0x' & Hex($lTemp, 8))
	SetValue('MainReturn', '0x' & Hex($lTemp + 5, 8))

	$lTemp = GetScannedAddress('ScanRenderFunc', -0x67)
	SetValue('RenderingMod', '0x' & Hex($lTemp, 8))
	SetValue('RenderingModReturn', '0x' & Hex($lTemp + 10, 8))

	$lTemp = GetScannedAddress('ScanTargetLog', 1)
	SetValue('TargetLogStart', '0x' & Hex($lTemp, 8))
	SetValue('TargetLogReturn', '0x' & Hex($lTemp + 5, 8))

	$lTemp = GetScannedAddress('ScanSkillLog', 1)
	SetValue('SkillLogStart', '0x' & Hex($lTemp, 8))
	SetValue('SkillLogReturn', '0x' & Hex($lTemp + 5, 8))

	$lTemp = GetScannedAddress('ScanSkillCompleteLog', -4)
	SetValue('SkillCompleteLogStart', '0x' & Hex($lTemp, 8))
	SetValue('SkillCompleteLogReturn', '0x' & Hex($lTemp + 5, 8))

	$lTemp = GetScannedAddress('ScanSkillCancelLog', 5)
	SetValue('SkillCancelLogStart', '0x' & Hex($lTemp, 8))
	SetValue('SkillCancelLogReturn', '0x' & Hex($lTemp + 6, 8))

	$lTemp = GetScannedAddress('ScanChatLog', 18)
	SetValue('ChatLogStart', '0x' & Hex($lTemp, 8))
	SetValue('ChatLogReturn', '0x' & Hex($lTemp + 6, 8))

	$lTemp = GetScannedAddress('ScanTraderHook', -0x2F)
	SetValue('TraderHookStart', '0x' & Hex($lTemp, 8))
	SetValue('TraderHookReturn', '0x' & Hex($lTemp + 5, 8))

	$lTemp = GetScannedAddress('ScanDialogLog', -4)
	SetValue('DialogLogStart', '0x' & Hex($lTemp, 8))
	SetValue('DialogLogReturn', '0x' & Hex($lTemp + 5, 8))

	$lTemp = GetScannedAddress('ScanStringFilter1', -5)
	SetValue('StringFilter1Start', '0x' & Hex($lTemp, 8))
	SetValue('StringFilter1Return', '0x' & Hex($lTemp + 5, 8))

	$lTemp = GetScannedAddress('ScanStringFilter2', 0x16)
	SetValue('StringFilter2Start', '0x' & Hex($lTemp, 8))
	SetValue('StringFilter2Return', '0x' & Hex($lTemp + 5, 8))

	SetValue('StringLogStart', '0x' & Hex(GetScannedAddress('ScanStringLog', 0x16), 8))

	SetValue('LoadFinishedStart', '0x' & Hex(GetScannedAddress('ScanLoadFinished', 1), 8))
	SetValue('LoadFinishedReturn', '0x' & Hex(GetScannedAddress('ScanLoadFinished', 6), 8))

	SetValue('PostMessage', '0x' & Hex(MemoryRead(GetScannedAddress('ScanPostMessage', 11)), 8))
	SetValue('Sleep', MemoryRead(MemoryRead(GetValue('ScanSleep') + 8) + 3))

	SetValue('SalvageFunction', '0x' & Hex(GetScannedAddress('ScanSalvageFunction', -10), 8))
	SetValue('SalvageGlobal', '0x' & Hex(MemoryRead(GetScannedAddress('ScanSalvageGlobal', 1) - 0x4), 8))

	SetValue('IncreaseAttributeFunction', '0x' & Hex(GetScannedAddress('ScanIncreaseAttributeFunction', -0x5A), 8))
	SetValue("DecreaseAttributeFunction", "0x" & Hex(GetScannedAddress("ScanDecreaseAttributeFunction", 25), 8))

	SetValue('MoveFunction', '0x' & Hex(GetScannedAddress('ScanMoveFunction', 1), 8))
	SetValue('UseSkillFunction', '0x' & Hex(GetScannedAddress('ScanUseSkillFunction', -0x125), 8))

	;SetValue('ChangeTargetFunction', '0x' & Hex(GetScannedAddress('ScanChangeTargetFunction', -0x0089) + 1, 8))
	SetValue('ChangeTargetFunction', '0x' & Hex(GetScannedAddress('ScanChangeTargetFunction', -0x0086) + 1, 8))
	SetValue('WriteChatFunction', '0x' & Hex(GetScannedAddress('ScanWriteChatFunction', -0x3D), 8))

	SetValue('SellItemFunction', '0x' & Hex(GetScannedAddress('ScanSellItemFunction', -85), 8))
	SetValue('PacketSendFunction', '0x' & Hex(GetScannedAddress('ScanPacketSendFunction', -0x50), 8))

	SetValue('ActionBase', '0x' & Hex(MemoryRead(GetScannedAddress('ScanActionBase', -3)), 8))
	SetValue('ActionFunction', '0x' & Hex(GetScannedAddress('ScanActionFunction', -3), 8))

	SetValue('UseHeroSkillFunction', '0x' & Hex(GetScannedAddress('ScanUseHeroSkillFunction', -0x59), 8))

	SetValue('BuyItemBase', '0x' & Hex(MemoryRead(GetScannedAddress('ScanBuyItemBase', 15)), 8))

	SetValue('TransactionFunction', '0x' & Hex(GetScannedAddress('ScanTransactionFunction', -0x7E), 8))
	SetValue('RequestQuoteFunction', '0x' & Hex(GetScannedAddress('ScanRequestQuoteFunction', -0x34), 8))

	SetValue('TraderFunction', '0x' & Hex(GetScannedAddress('ScanTraderFunction', -0x1E), 8))
	SetValue('ClickToMoveFix', '0x' & Hex(GetScannedAddress("ScanClickToMoveFix", 1), 8))

	SetValue('ChangeStatusFunction', '0x' & Hex(GetScannedAddress("ScanChangeStatusFunction", 1), 8))

	SetValue('QueueSize', '0x00000010')
	SetValue('SkillLogSize', '0x00000010')
	SetValue('ChatLogSize', '0x00000010')
	SetValue('TargetLogSize', '0x00000200')
	SetValue('StringLogSize', '0x00000200')
	SetValue('CallbackEvent', '0x00000501')
	$MTradeHackAddress = GetScannedAddress("ScanTradeHack", 0)

	ModifyMemory()

	$mQueueCounter = MemoryRead(GetValue('QueueCounter'))
	$mQueueSize = GetValue('QueueSize') - 1
	$mQueueBase = GetValue('QueueBase')
	$mTargetLogBase = GetValue('TargetLogBase')
	$mStringLogBase = GetValue('StringLogBase')
	$mMapIsLoaded = GetValue('MapIsLoaded')
	$mEnsureEnglish = GetValue('EnsureEnglish')
	$mTraderQuoteID = GetValue('TraderQuoteID')
	$mTraderCostID = GetValue('TraderCostID')
	$mTraderCostValue = GetValue('TraderCostValue')
	$mDisableRendering = GetValue('DisableRendering')
	$mAgentCopyCount = GetValue('AgentCopyCount')
	$mAgentCopyBase = GetValue('AgentCopyBase')
	$mLastDialogID = GetValue('LastDialogID')

	If $mUseEventSystem Then
		MemoryWrite(GetValue('CallbackHandle'), $mGUI)
	EndIf

	DllStructSetData($mInviteGuild, 1, GetValue('CommandPacketSend'))
	DllStructSetData($mInviteGuild, 2, 0x4C)
	DllStructSetData($mUseSkill, 1, GetValue('CommandUseSkill'))
	DllStructSetData($mMove, 1, GetValue('CommandMove'))
	DllStructSetData($mChangeTarget, 1, GetValue('CommandChangeTarget'))
	DllStructSetData($mPacket, 1, GetValue('CommandPacketSend'))
	DllStructSetData($mSellItem, 1, GetValue('CommandSellItem'))
	DllStructSetData($mAction, 1, GetValue('CommandAction'))
	DllStructSetData($mToggleLanguage, 1, GetValue('CommandToggleLanguage'))
	DllStructSetData($mUseHeroSkill, 1, GetValue('CommandUseHeroSkill'))
	DllStructSetData($mBuyItem, 1, GetValue('CommandBuyItem'))
	DllStructSetData($mSendChat, 1, GetValue('CommandSendChat'))
	DllStructSetData($mSendChat, 2, $HEADER_SEND_CHAT_MESSAGE)
	DllStructSetData($mWriteChat, 1, GetValue('CommandWriteChat'))
	DllStructSetData($mRequestQuote, 1, GetValue('CommandRequestQuote'))
	DllStructSetData($mRequestQuoteSell, 1, GetValue('CommandRequestQuoteSell'))
	DllStructSetData($mTraderBuy, 1, GetValue('CommandTraderBuy'))
	DllStructSetData($mTraderSell, 1, GetValue('CommandTraderSell'))
	DllStructSetData($mSalvage, 1, GetValue('CommandSalvage'))
	DllStructSetData($mIncreaseAttribute, 1, GetValue('CommandIncreaseAttribute'))
	DllStructSetData($mDecreaseAttribute, 1, GetValue('CommandDecreaseAttribute'))
	DllStructSetData($mMakeAgentArray, 1, GetValue('CommandMakeAgentArray'))
	DllStructSetData($mChangeStatus, 1, GetValue('CommandChangeStatus'))

	If $bChangeTitle Then
		WinSetTitle($mGWWindowHandle, '', 'Guild Wars - ' & GetCharname())
	EndIf
	SetMaxMemory()

	Return $mGWWindowHandle
EndFunc   ;==>Initialize


;~ Description: Internal use only.
Func GetValue($aKey)
	For $i = 1 To $mLabels[0][0]
		If $mLabels[$i][0] = $aKey Then Return Number($mLabels[$i][1])
	Next
	Return -1
EndFunc   ;==>GetValue

;~ Description: Internal use only.
Func SetValue($aKey, $aValue)
	$mLabels[0][0] += 1
	ReDim $mLabels[$mLabels[0][0] + 1][2]
	$mLabels[$mLabels[0][0]][0] = $aKey
	$mLabels[$mLabels[0][0]][1] = $aValue
EndFunc   ;==>SetValue

;~ Description: Internal use only.
;~ Description: Scan patterns for Guild Wars game client.
Func Scan()
	Local $lGwBase = ScanForProcess()
	$mASMSize = 0
	$mASMCodeOffset = 0
	$mASMString = ''

	_('MainModPtr/4')

	; Scan patterns
	_('ScanBasePointer:')
	AddPattern('506A0F6A00FF35') ;85C0750F8BCE CHECKED ; STILL UPDATED 23.12.24

	_('ScanAgentBase:') ; Still in use? (16/06-2023)
	;AddPattern('FF50104783C6043BFB75E1') ; Still in use? (16/06-2023)
	AddPattern('FF501083C6043BF775E2') ; UPDATED 23.12.24

	_('ScanAgentBasePointer:')
	AddPattern('FF501083C6043BF775E28B35') ;UPDATED 26.12.24

	_('ScanAgentArray:')
	AddPattern('8B0C9085C97419')

	_('ScanCurrentTarget:')
	AddPattern('83C4085F8BE55DC3CCCCCCCCCCCCCCCCCCCCCC55') ;UPDATED 23.12.24

;~ 	_('ScanMyID:')
;~ 	AddPattern('83EC08568BF13B15') ; STILL WORKING 23.12.24

	_('ScanEngine:')
	AddPattern('568B3085F67478EB038D4900D9460C') ; UPDATED 23.12.24 NEEDS TO GET UPDATED EACH PATCH

	_('ScanRenderFunc:')
	AddPattern('F6C401741C68B1010000BA') ; STILL WORKING 23.12.24

	_('ScanLoadFinished:')
	AddPattern('8B561C8BCF52E8') ; COULD NOT UPDATE! 23.12.24

	_('ScanPostMessage:')
	AddPattern('6A00680080000051FF15') ; COULD NOT UPDATE! 23.12.24

	_('ScanTargetLog:')
	AddPattern('5356578BFA894DF4E8') ; COULD NOT UPDATE! 23.12.24

	_('ScanChangeTargetFunction:')
	AddPattern('3BDF0F95') ; STILL WORKING 23.12.24, 33C03BDA0F95C033

	_('ScanMoveFunction:')
	AddPattern('558BEC83EC208D45F0') ; STILL WORKING 23.12.24, 558BEC83EC2056578BF98D4DF0

	_('ScanPing:')
	AddPattern('E874651600') ; UPDATED 23.12.24

;~ 	_('ScanMapID:')
;~ 	AddPattern('558BEC8B450885C074078B') ;STILL WORKING 23.12.24, B07F8D55

;~ 	_('ScanMapLoading:')
;~ 	AddPattern('2480ED0000000000') ; UPDATED 25.12.24, 6A2C50E8

	_('ScanLoggedIn:')
	AddPattern('C705ACDE740000000000C3CCCCCCCC') ; UPDATED 26.12.24, NEED TO GET UPDATED EACH PATCH OLD:BFFFC70580 85C07411B807

	_('ScanRegion:')
	AddPattern('6A548D46248908') ; STILL WORKING 23.12.24

;~ 	_('ScanMapInfo:')
;~ 	AddPattern('8BF0EB038B750C3B') ; STILL WORKING 23.12.24, 83F9FD7406

;~ 	_('ScanLanguage:')
;~ 	AddPattern('C38B75FC8B04B5') ; COULD NOT UPDATE! 23.12.24

	_('ScanUseSkillFunction:')
	AddPattern('85F6745B83FE1174') ; STILL WORKING 23.12.24, 558BEC83EC1053568BD9578BF2895DF0

	_('ScanPacketSendFunction:')
	AddPattern('C747540000000081E6') ;UPDATED 28.12.24 old: F7D9C74754010000001BC981, 558BEC83EC2C5356578BF985

	_('ScanBaseOffset:')
	AddPattern('83C40433C08BE55DC3A1') ; STILL WORKING 23.12.24, 5633F63BCE740E5633D2

	_('ScanWriteChatFunction:')
	AddPattern('8D85E0FEFFFF50681C01') ;STILL WORKING 23.12.24, 558BEC5153894DFC8B4D0856578B

	_('ScanSkillLog:')
	AddPattern('408946105E5B5D') ; COULD NOT UPDATE! 23.12.24

	_('ScanSkillCompleteLog:')
	AddPattern('741D6A006A40') ; COULD NOT UPDATE! 23.12.24

	_('ScanSkillCancelLog:')
	AddPattern('741D6A006A48') ; COULD NOT UPDATE! 23.12.24

	_('ScanChatLog:')
	AddPattern('8B45F48B138B4DEC50') ; COULD NOT UPDATE! 23.12.24

	_('ScanSellItemFunction:')
	AddPattern('8B4D2085C90F858E') ; COULD NOT UPDATE! 23.12.24

	_('ScanStringLog:')
	AddPattern('893E8B7D10895E04397E08') ; COULD NOT UPDATE! 23.12.24

	_('ScanStringFilter1:')
	AddPattern('8B368B4F2C6A006A008B06') ; COULD NOT UPDATE! 23.12.24

	_('ScanStringFilter2:')
	AddPattern('515356578BF933D28B4F2C') ; COULD NOT UPDATE! 23.12.24

	_('ScanActionFunction:')
	AddPattern('8B7508578BF983FE09750C6876') ;STILL WORKING 23.12.24, ;8B7D0883FF098BF175116876010000

	_('ScanActionBase:')
	AddPattern('8D1C87899DF4') ; UPDATED 24.12.24, OLD: 8D1C87899DF4FEFFFF8BC32BC7C1F802, 8B4208A80175418B4A08

	_('ScanSkillBase:')
	AddPattern('8D04B6C1E00505') ;STILL WORKING 23.12.24 ;8D 04 B6 C1 E0 05 05

	_('ScanUseHeroSkillFunction:')
	AddPattern('BA02000000B954080000') ;STILL WORKING 23.12.24

	_('ScanTransactionFunction:')
	AddPattern('85FF741D8B4D14EB08') ;STILL WORKING 23.12.24 ;558BEC81ECC000000053568B75085783FE108BFA8BD97614

	_('ScanBuyItemFunction:') ; Still in use? (16/06-2023)
	AddPattern('D9EED9580CC74004') ;STILL WORKING 23.12.24 ; Still in use? (16/06-2023)

	_('ScanBuyItemBase:')
	AddPattern('D9EED9580CC74004') ;STILL WORKING 23.12.24

	_('ScanRequestQuoteFunction:')
	AddPattern('8B752083FE107614')  ;STILL WORKING 23.12.24;8B750C5783FE107614 ;53568B750C5783FE10

	_('ScanTraderFunction:')
	;AddPattern('8B45188B551085') ;83FF10761468
	AddPattern('83FF10761468D2210000') ;STILL WORKING 23.12.24

	_('ScanTraderHook:')
	AddPattern('50516A466A06')

	_('ScanSleep:')
	AddPattern('6A0057FF15D8408A006860EA0000') ; UPDATED 24.12.24, OLD:5F5E5B741A6860EA0000

	_('ScanSalvageFunction:')
	AddPattern('33C58945FC8B45088945F08B450C8945F48B45108945F88D45EC506A10C745EC76') ; UPDATED 24.12.24 OLD:33C58945FC8B45088945F08B450C8945F48B45108945F88D45EC506A10C745EC75
	;AddPattern('8BFA8BD9897DF0895DF4')

	_('ScanSalvageGlobal:')
	AddPattern('8B4A04538945F48B4208') ; UPDATED 24.12.24, OLD: 8B5104538945F48B4108568945E88B410C578945EC8B4110528955E48945F0
	;AddPattern('8B018B4904A3')

	_('ScanIncreaseAttributeFunction:')
	AddPattern('8B7D088B702C8B1F3B9E00050000') ;STILL WORKING 23.12.24, 8B702C8B3B8B86

	_("ScanDecreaseAttributeFunction:")
	AddPattern("8B8AA800000089480C5DC3CC") ;STILL WORKING 23.12.24, 8B402C8BCE059C0000008B1089118B50

	_('ScanSkillTimer:')
	AddPattern('FFD68B4DF08BD88B4708') ;STILL WORKING 23.12.24, 85c974158bd62bd183fa64

	_('ScanClickToMoveFix:')
	AddPattern('3DD301000074') ;STILL WORKING 23.12.24,

	_('ScanZoomStill:')
	AddPattern('558BEC8B41085685C0') ; COULD NOT UPDATE! 23.12.24

	_('ScanZoomMoving:')
	AddPattern('EB358B4304') ; COULD NOT UPDATE! 23.12.24

	_('ScanBuildNumber:')
	AddPattern('558BEC83EC4053568BD9') ; COULD NOT UPDATE! 23.12.24

	_('ScanChangeStatusFunction:')
	AddPattern('558BEC568B750883FE047C14') ;STILL WORKING 23.12.24, 568BF183FE047C14682F020000

	_('ScanCharslots:')
	AddPattern('8B551041897E38897E3C897E34897E48897E4C890D') ; COULD NOT UPDATE! 23.12.24

	_('ScanReadChatFunction:')
	AddPattern('A128B6EB00') ; COULD NOT UPDATE! 23.12.24

	_('ScanDialogLog:')
	AddPattern('8B45088945FC8D45F8506A08C745F841') ;STILL WORKING 23.12.24, 558BEC83EC285356578BF28BD9

	_("ScanTradeHack:")
	AddPattern("8BEC8B450883F846") ;STILL WORKING 23.12.24

	_("ScanClickCoords:")
	AddPattern("8B451C85C0741CD945F8") ;STILL WORKING 23.12.24

	_("ScanInstanceInfo:")
	AddPattern("6A2C50E80000000083C408C7") ;Added by Greg76 to get Instance Info

	_("ScanAreaInfo:")
	AddPattern("6BC67C5E05") ;Added by Greg76 to get Area Info

	_("ScanAttributeInfo:")
	AddPattern("BA3300000089088d4004") ;Added by Greg76 to get Attribute Info

	_("ScanWorldConst:")
	AddPattern("8D0476C1E00405") ;Added by Greg76 to get World Info

	_('ScanProc:') ; Label for the scan procedure
	_('pushad') ; Push all general-purpose registers onto the stack to save their values
	_('mov ecx,' & Hex($lGwBase, 8)) ; Move the base address of the Guild Wars process into the ECX register
	_('mov esi,ScanProc') ; Move the address of the ScanProc label into the ESI register
	_('ScanLoop:') ; Label for the scan loop
	_('inc ecx') ; Increment the value in the ECX register by 1
	_('mov al,byte[ecx]') ; Move the byte value at the address stored in ECX into the AL register
	_('mov edx,ScanBasePointer') ; Move the address of the ScanBasePointer into the EDX register


	_('ScanInnerLoop:') ; Label for the inner scan loop
	_('mov ebx,dword[edx]') ; Move the 4-byte value at the address stored in EDX into the EBX register
	_('cmp ebx,-1') ; Compare the value in EBX to -1
	_('jnz ScanContinue') ; Jump to the ScanContinue label if the comparison is not zero
	_('add edx,50') ; Add 50 to the value in the EDX register
	_('cmp edx,esi') ; Compare the value in EDX to the value in ESI
	_('jnz ScanInnerLoop') ; Jump to the ScanInnerLoop label if the comparison is not zero
	_('cmp ecx,' & SwapEndian(Hex($lGwBase + 5238784, 8))) ; Compare the value in ECX to a specific address (+4FF000)
	_('jnz ScanLoop') ; Jump to the ScanLoop label if the comparison is not zero
	_('jmp ScanExit') ; Jump to the ScanExit label


	_('ScanContinue:') ; Label for the scan continue section
	_('lea edi,dword[edx+ebx]') ; Load the effective address of the value at EDX + EBX into the EDI register
	_('add edi,C') ; Add the value of C to the address in EDI
	_('mov ah,byte[edi]') ; Move the byte value at the address stored in EDI into the AH register
	_('cmp al,ah') ; Compare the value in AL to the value in AH
	_('jz ScanMatched') ; Jump to the ScanMatched label if the comparison is zero (i.e., the values match)
	_('cmp ah,00')    ;Added by Greg76 for scan wildcards
	_('jz ScanMatched')    ;Added by Greg76 for scan wildcards
	_('mov dword[edx],0') ; Move the value 0 into the 4-byte location at the address stored in EDX
	_('add edx,50') ; Add 50 to the value in the EDX register
	_('cmp edx,esi') ; Compare the value in EDX to the value in ESI
	_('jnz ScanInnerLoop') ; Jump to the ScanInnerLoop label if the comparison is not zero
	_('cmp ecx,' & SwapEndian(Hex($lGwBase + 5238784, 8))) ; Compare the value in ECX to a specific address (+4FF000)
	_('jnz ScanLoop') ; Jump to the ScanLoop label if the comparison is not zero
	_('jmp ScanExit') ; Jump to the ScanExit label


	_('ScanMatched:') ; Label for the scan matched section
	_('inc ebx') ; Increment the value in the EBX register by 1
	_('mov edi,dword[edx+4]') ; Move the 4-byte value at the address EDX + 4 into the EDI register
	_('cmp ebx,edi') ; Compare the value in EBX to the value in EDI
	_('jz ScanFound') ; Jump to the ScanFound label if the comparison is zero (i.e., the values match)
	_('mov dword[edx],ebx') ; Move the value in EBX into the 4-byte location at the address stored in EDX
	_('add edx,50') ; Add 50 to the value in the EDX register
	_('cmp edx,esi') ; Compare the value in EDX to the value in ESI
	_('jnz ScanInnerLoop') ; Jump to the ScanInnerLoop label if the comparison is not zero
	_('cmp ecx,' & SwapEndian(Hex($lGwBase + 5238784, 8))) ; Compare the value in ECX to a specific address (+4FF000)
	_('jnz ScanLoop') ; Jump to the ScanLoop label if the comparison is not zero
	_('jmp ScanExit') ; Jump to the ScanExit label


	_('ScanFound:') ; Label for the scan found section
	_('lea edi,dword[edx+8]') ; Load the effective address of the value at EDX + 8 into the EDI register
	_('mov dword[edi],ecx') ; Move the value in ECX into the 4-byte location at the address stored in EDI
	_('mov dword[edx],-1') ; Move the value -1 into the 4-byte location at the address stored in EDX (mark as found)
	_('add edx,50') ; Add 50 to the value in the EDX register
	_('cmp edx,esi') ; Compare the value in EDX to the value in ESI
	_('jnz ScanInnerLoop') ; Jump to the ScanInnerLoop label if the comparison is not zero
	_('cmp ecx,' & SwapEndian(Hex($lGwBase + 5238784, 8))) ; Compare the value in ECX to a specific address (+4FF000)
	_('jnz ScanLoop') ; Jump to the ScanLoop label if the comparison is not zero

	_('ScanExit:') ; Label for the scan exit section
	_('popad') ; Pop all general-purpose registers from the stack to restore their original values
	_('retn') ; Return from the current function (exit the scan routine)


	$mBase = $lGwBase + 0x9DF000
	Local $lScanMemory = MemoryRead($mBase, 'ptr')

	; Check if the scan memory address is empty (no previous injection)
	If $lScanMemory = 0 Then
		; Allocate a new block of memory for the scan routine
		$mMemory = DllCall($mKernelHandle, 'ptr', 'VirtualAllocEx', 'handle', $mGWProcHandle, 'ptr', 0, 'ulong_ptr', $mASMSize, 'dword', 0x1000, 'dword', 0x40)
		$mMemory = $mMemory[0] ; Get the allocated memory address

		; Write the allocated memory address to the scan memory location
		MemoryWrite($mBase, $mMemory)

;~ out("First Inject: " & $mMemory)
	Else
		; If the scan memory address is not empty, use the existing memory address
		$mMemory = $lScanMemory
	EndIf


	; Complete the assembly code for the scan routine
	CompleteASMCode()

	; Check if this is the first injection (no previous scan memory address)
	If $lScanMemory = 0 Then
		; Write the assembly code to the allocated memory address
		WriteBinary($mASMString, $mMemory + $mASMCodeOffset)

		; Create a new thread in the target process to execute the scan routine
		Local $lThread = DllCall($mKernelHandle, 'int', 'CreateRemoteThread', 'int', $mGWProcHandle, 'ptr', 0, 'int', 0, 'int', GetLabelInfo('ScanProc'), 'ptr', 0, 'int', 0, 'int', 0)
		$lThread = $lThread[0] ; Get the thread ID

		; Wait for the thread to finish executing
		Local $lResult
		Do
			; Wait for up to 50ms for the thread to finish
			$lResult = DllCall($mKernelHandle, 'int', 'WaitForSingleObject', 'int', $lThread, 'int', 50)
		Until $lResult[0] <> 258 ; Wait until the thread is no longer waiting (258 is the WAIT_TIMEOUT constant)

		; Close the thread handle to free up system resources
		DllCall($mKernelHandle, 'int', 'CloseHandle', 'int', $lThread)
	EndIf
EndFunc   ;==>Scan

; **Function to Retrieve Guild Wars Process Base Address**
Func GetGWBase()
	; **Scan for Guild Wars Process and Get Base Address**
	Local $lGwBase = ScanForProcess() - 4096 ; Subtract 4096 from the process address to get the base address

	; **Convert Base Address to Hexadecimal String**
	$lGwBase = "0x" & Hex($lGwBase) ; Prefix the hexadecimal value with "0x"

	; **Return Base Address as Hexadecimal String**
	Return $lGwBase
EndFunc   ;==>GetGWBase

Func ScanForProcess()
	Local $lCharNameCode = BinaryToString('0x558BEC83EC105356578B7D0833F63BFE')
	Local $lCurrentSearchAddress = 0x00000000
	Local $lMBI[7], $lMBIBuffer = DllStructCreate('dword;dword;dword;dword;dword;dword;dword')
	Local $lSearch, $lTmpMemData

	While $lCurrentSearchAddress < 0x01F00000
		Local $lMBI[7]
		DllCall($mKernelHandle, 'int', 'VirtualQueryEx', 'int', $mGWProcHandle, 'int', $lCurrentSearchAddress, 'ptr', DllStructGetPtr($lMBIBuffer), 'int', DllStructGetSize($lMBIBuffer))
		For $i = 0 To 6
			$lMBI[$i] = StringStripWS(DllStructGetData($lMBIBuffer, ($i + 1)), 3)
		Next
		If $lMBI[4] = 4096 Then
			Local $lBuffer = DllStructCreate('byte[' & $lMBI[3] & ']')
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lCurrentSearchAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')

			$lTmpMemData = DllStructGetData($lBuffer, 1)
			$lTmpMemData = BinaryToString($lTmpMemData)

			$lSearch = StringInStr($lTmpMemData, $lCharNameCode, 2)
			If $lSearch > 0 Then
				Return $lMBI[0]
			EndIf
		EndIf
		$lCurrentSearchAddress += $lMBI[3]
	WEnd
	Return ''
EndFunc   ;==>ScanForProcess

;~ Description: Internal use only.
Func AddPattern($aPattern) ;modified by Greg76 for scan wildcards
	Local $lSize = Int(0.5 * StringLen($aPattern))
	Local $pattern_header = "00000000" & _
			SwapEndian(Hex($lSize, 8)) & _
			"00000000"

	$mASMString &= $pattern_header & $aPattern
	$mASMSize += $lSize + 12

	Local $padding_count = 68 - $lSize
	For $i = 1 To $padding_count
		$mASMSize += 1
		$mASMString &= "00"
	Next
EndFunc   ;==>AddPattern

;~ Description: Internal use only.
Func GetScannedAddress($aLabel, $aOffset)
	Return MemoryRead(GetLabelInfo($aLabel) + 8) - MemoryRead(GetLabelInfo($aLabel) + 4) + $aOffset
EndFunc   ;==>GetScannedAddress

;~ Description: Internal use only.
Func ScanForCharname()
	Local $lCharNameCode = BinaryToString('0x6A14FF751868') ;0x90909066C705
	Local $lCurrentSearchAddress = 0x00000000 ;0x00401000
	Local $lMBI[7], $lMBIBuffer = DllStructCreate('dword;dword;dword;dword;dword;dword;dword')
	Local $lSearch, $lTmpMemData, $lTmpAddress, $lTmpBuffer = DllStructCreate('ptr')

	While $lCurrentSearchAddress < 0x01F00000
		Local $lMBI[7]
		DllCall($mKernelHandle, 'int', 'VirtualQueryEx', 'int', $mGWProcHandle, 'int', $lCurrentSearchAddress, 'ptr', DllStructGetPtr($lMBIBuffer), 'int', DllStructGetSize($lMBIBuffer))
		For $i = 0 To 6
			$lMBI[$i] = StringStripWS(DllStructGetData($lMBIBuffer, ($i + 1)), 3)
		Next
		If $lMBI[4] = 4096 Then
			Local $lBuffer = DllStructCreate('byte[' & $lMBI[3] & ']')
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lCurrentSearchAddress, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')

			$lTmpMemData = DllStructGetData($lBuffer, 1)
			$lTmpMemData = BinaryToString($lTmpMemData)

			$lSearch = StringInStr($lTmpMemData, $lCharNameCode, 2)
			If $lSearch > 0 Then
				$lTmpAddress = $lCurrentSearchAddress + $lSearch - 1
				DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lTmpAddress + 6, 'ptr', DllStructGetPtr($lTmpBuffer), 'int', DllStructGetSize($lTmpBuffer), 'int', '')
				$mCharname = DllStructGetData($lTmpBuffer, 1)
				Return GetCharname()
			EndIf
		EndIf
		$lCurrentSearchAddress += $lMBI[3]
	WEnd
	Return ''
EndFunc   ;==>ScanForCharname
#EndRegion Initialisation

#Region Item
Func ItemID($aItem)
	If IsPtr($aItem) Then
		Return MemoryRead($aItem, "long")
	ElseIf IsDllStruct($aItem) Then
		Return DllStructGetData($aItem, "ID")
	Else
		Return $aItem
	EndIf
EndFunc   ;==>ItemID

Func GetItemPtr($aItem)
	If IsPtr($aItem) Then Return $aItem
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0x4 * ItemID($aItem)]
	Local $lItemStructAddress = MemoryReadPtr($mBasePointer, $lOffset, 'ptr')
	Return $lItemStructAddress[1]
EndFunc   ;==>GetItemPtr

;~ Description: Returns Itemptr by agentid.
Func GetItemPtrByAgentID($aAgentID)
	Return GetItemPtr(MemoryRead(GetAgentPtr($aAgentID) + 200))
EndFunc   ;==>GetItemPtrByAgentID

;~ Description: Returns item struct.
Func GetItemByItemID($aItemID)
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0x4 * ItemID($aItemID)]
	Local $lItemPtr = MemoryReadPtr($mBasePointer, $lOffset)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($g_ItemStruct), 'int', DllStructGetSize($g_ItemStruct), 'int', '')
	Return $g_ItemStruct
EndFunc   ;==>GetItemByItemID

;~ Description: Returns item by agent ID.
Func GetItemByAgentID($aAgentID)
	Local $lOffset[4] = [0, 0x18, 0x40, 0xC0]
	Local $lItemArraySize = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0]
	Local $lItemPtr, $lItemID
	Local $lAgentID = ConvertID($aAgentID)

	For $lItemID = 1 To $lItemArraySize[1]
		$lOffset[4] = 0x4 * $lItemID
		$lItemPtr = MemoryReadPtr($mBasePointer, $lOffset)
		If $lItemPtr[1] = 0 Then ContinueLoop

		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($g_ItemStruct), 'int', DllStructGetSize($g_ItemStruct), 'int', '')
		If DllStructGetData($g_ItemStruct, 'AgentID') = $lAgentID Then Return $g_ItemStruct
	Next
EndFunc   ;==>GetItemByAgentID

Func GetItemExists($aItemID)
	Return GetItemPtr($aItemID) <> 0
EndFunc   ;==>GetItemExists

;~ Description: Returns the AgentID of Item; $aItem = Ptr/Struct/ID
Func GetItemAgentID($aItem) 
	Return MemoryRead(GetItemPtr($aItem) + 4, 'long')
EndFunc ;==>GetItemAgentID

;~ Description: Returns the Type of Item; $aItem = Ptr/Struct/ID
Func GetItemType($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 32, 'byte')
EndFunc ;==>GetItemType

;~ Description: Returns the ExtraID of Item; $aItem = Ptr/Struct/ID
Func GetItemExtraID($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 34, 'short')
EndFunc ;==>GetItemExtraID

;~ Description: Returns the Value of Item; $aItem = Ptr/Struct/ID
Func GetItemValue($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 36, 'short')
EndFunc ;==>GetItemValue

;~ Description: Returns the ModelID of Item; $aItem = Ptr/Struct/ID
Func GetItemModelID($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 44, 'long')
EndFunc ;==>GetItemModelID

;~ Description: Returns rarity (name color) of an item; $aItem = Ptr/Struct/ID
Func GetRarity($aItem)
	Local $lNameString = MemoryRead(GetItemPtr($aItem) + 56, "ptr")
	If $lNameString = 0 Then Return
	Return MemoryRead($lNameString, "ushort")
EndFunc   ;==>GetRarity

;~ Description: Returns quantity of an item; $aItem = Ptr/Struct/ID
Func GetItemQuantity($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 76, 'byte')
EndFunc ;==>GetQuantity

;~ Description: Tests if an item is identified.
Func GetIsIDed($aItem)
	Return BitAND(MemoryRead(GetItemPtr($aItem) + 40, 'long'), 1) > 0
EndFunc ;==>GetIsIDed

;~ Description: Tests if an item is identified. (duplicate)
Func GetIsIdentified($aItem)
	Return BitAND(MemoryRead(GetItemPtr($aItem) + 40, 'long'), 1) > 0
EndFunc   ;==>GetIsIdentified

;~ Descriptions: Tests if an item is unidentfied and can be identified.
Func GetIsUnIDed($aItem)
	Return BitAND(MemoryRead(GetItemPtr($aItem) + 40, 'long'), 8388608) > 0
EndFunc ;==>GetIsUnIDed

;~ Description: Returns True if item has a suffix, prefix or inscription in it that isnt fixed.
Func GetIsUpgraded($lItemPtr)
	Return BitAND(MemoryRead($lItemPtr + 40, 'long'), 68222976) > 0
EndFunc ;==>GetIsUpgraded

;~ Description: Returns if material is Rare.
Func GetIsRareMaterial($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	If DllStructGetData($aItem, "Type") <> 11 Then Return False
	Return Not GetIsCommonMaterial($aItem)
EndFunc   ;==>GetIsRareMaterial

;~ Description: Returns if material is Common.
Func GetIsCommonMaterial($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Return BitAND(DllStructGetData($aItem, "Interaction"), 0x20) <> 0
EndFunc   ;==>GetIsCommonMaterial

Func GetItemPtrBySlot($aBag, $aSlot)
	Local $lBagPtr = GetBagPtr($aBag)
	Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	Return MemoryRead($lItemArrayPtr + 4 * ($aSlot - 1), 'ptr')
EndFunc   ;==>GetItemPtrBySlot

;~ Description: Returns item by slot.
Func GetItemBySlot($aBag, $aSlot)
	Local $lItemPtr = GetItemPtrBySlot($aBag, $aSlot)
	Local $lItemStruct = DllStructCreate('long Id;long AgentId;byte Unknown1[4];ptr Bag;ptr ModStruct;long ModStructSize;ptr Customized;byte unknown2[4];byte Type;byte unknown4;short ExtraId;short Value;byte unknown4[2];short Interaction;long ModelId;ptr ModString;byte unknown5[4];ptr NameString;ptr SingleItemName;byte Unknown4[10];byte IsSalvageable;byte Unknown6;byte Quantity;byte Equiped;byte Profession;byte Type2;byte Slot')
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr, 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
	Return $lItemStruct
EndFunc   ;==>GetItemBySlot

; Return first ItemPtr by ModelID in specified bags. Zero if no Item is found.
Func GetItemPtrByModelID($aModelID, $aFirstBag = 1, $aLastBag = 16, $aIncludeEquipmentPack = False, $aIncludeMats = False)
	Local $lItemPtr, $lBagPtr, $lItemArrayPtr, $lModelID, $lCount = 0
	
	If IsArray($aModelID) Then
		Local $lReturnPtr[UBound($aModelID)]
		For $i = 0 To UBound($aModelID) - 1
			$lReturnPtr[$i] = 0
		Next
	Else
		Local $lReturnPtr = 0
	EndIf
	
	If IsArray($aModelID) Then
		For $bag = $aFirstBag To $aLastBag
			If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
			If $bag = 6 And Not $aIncludeMats Then ContinueLoop
			If $bag = 7 Then ContinueLoop
			$lBagPtr = GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop
			$lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 0 To GetMaxSlots($lBagPtr) - 1
				$lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
				If $lItemPtr = 0 Then ContinueLoop
				$lModelID = GetItemModelID($lItemPtr)
				For $i = 0 To UBound($aModelID) - 1
					If $lReturnPtr[$i] <> 0 Or $lModelID <> $aModelID[$i] Then ContinueLoop
					$lReturnPtr[$i] = $lItemPtr
					$lCount += 1
					If $lCount = UBound($aModelID) Then
						Return $lReturnPtr
					EndIf
					ExitLoop
				Next				
			Next
		Next	
	Else
		For $bag = $aFirstBag To $aLastBag
			If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
			If $bag = 6 And Not $aIncludeMats Then ContinueLoop
			If $bag = 7 Then ContinueLoop
			$lBagPtr = GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop
			$lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 0 To GetMaxSlots($lBagPtr) - 1
				$lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
				If $lItemPtr = 0 Then ContinueLoop
				If GetItemModelID($lItemPtr) = $aModelID Then
					Return $lItemPtr
				EndIf
			Next
		Next
	EndIf
	Return $lReturnPtr
EndFunc ;==>GetItemPtrByModelID

; Returns the first Item by ModelID found in Inventory; If no Item is found Returns Zero
Func GetItemInInventory($aModelID)
	Return GetItemPtrByModelID($aModelID, 1, 4)
EndFunc ;==>GetItemInInventory

; Returns the first Item by ModelID found in Storage; If no Item is found Returns Zero
Func GetItemInChest($aModelID)
	Return GetItemPtrByModelID($aModelID, 8, 12)
EndFunc ;==>GetItemInChest

;~ Description: Returns amount of items of $aModelID in selected bags.
Func CountItemByModelID($aModelID, $aFirstBag = 1, $aLastBag = 16, $aCountSlotsOnly = False, $aIncludeEquipmentPack = False, $aIncludeMats = False)
	Local $lItemPtr, $lBagPtr, $lItemArrayPtr, $lModelID
	If IsArray($aModelID) Then
		Local $lCount[UBound($aModelID)]
		For $i = 0 To UBound($aModelID) - 1
			$lCount[$i] = 0
		Next
	Else
		Local $lCount = 0
	EndIf
	
	If IsArray($aModelID) Then
		For $bag = $aFirstBag To $aLastBag
			If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
			If $bag = 6 And Not $aIncludeMats Then ContinueLoop
			If $bag = 7 Then ContinueLoop
			$lBagPtr = GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop
			$lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 0 To GetMaxSlots($lBagPtr) - 1
				$lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
				If $lItemPtr = 0 Then ContinueLoop
				$lModelID = GetItemModelID($lItemPtr)
				For $i = 0 To UBound($aModelID) - 1
					If $lModelID = $aModelID[$i] Then
						If $aCountSlotsOnly Then
							$lCount[$i] += 1
						Else
							$lCount[$i] += GetItemQuantity($lItemPtr)
						EndIf
					EndIf
				Next
			Next
		Next	
	Else
		For $bag = $aFirstBag To $aLastBag
			If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
			If $bag = 6 And Not $aIncludeMats Then ContinueLoop
			If $bag = 7 Then ContinueLoop
			$lBagPtr = GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop
			$lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 0 To GetMaxSlots($lBagPtr) - 1
				$lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
				If $lItemPtr = 0 Then ContinueLoop
				If GetItemModelID($lItemPtr) = $aModelID Then
					If $aCountSlotsOnly Then
						$lCount += 1
					Else
						$lCount += GetItemQuantity($lItemPtr)
					EndIf
				EndIf
			Next
		Next	
	EndIf
	Return $lCount
EndFunc ;==>CountItemByModelID

; Returns the amount of an Item in Inventory by ModelID
Func GetQuantityInventory($aModelID, $aCountSlotsOnly = False)
	Return CountItemByModelID($aModelID, 1, 4, $aCountSlotsOnly)
EndFunc ;==>GetQuantityInventory

; Return the amount of an Item in Chest by ModelID
Func GetQuantityChest($aModelID, $aCountSlotsOnly = False)
	Return CountItemByModelID($aModelID, 8, 12, $aCountSlotsOnly)
EndFunc ;==>GetQuantityChest

; Returns the amount of an Item by ModelID in Inventory+Chest
Func GetQuantity($aModelID, $aCountSlotsOnly = False)
	Return CountItemByModelID($aModelID, 1, 12, $aCountSlotsOnly)
EndFunc ;==>GetQuantity

;~ Description: Accepts unclaimed items after a mission.
Func AcceptAllItems()
	Return SendPacket(0x8, $HEADER_ITEMS_ACCEPT_UNCLAIMED, BagID(GetBagPtr(7)))
EndFunc   ;==>AcceptAllItems

;~ Description: Uses an item.
Func UseItem($aItem)
	Return SendPacket(0x8, $HEADER_ITEM_USE, ItemID($aItem))
EndFunc   ;==>UseItem

Func UseItemByModelID($aModelID)
	Local $lItemPtr = GetItemInInventory($aModelID)
	If $lItemPtr = 0 Then Return False
	
	UseItem($lItemPtr)
	PingSleep(100)
	Return True
EndFunc ;==>UseItemByModelID

;~ Description: Picks up an item.
Func PickUpItem($aItem)
	Return SendPacket(0xC, $HEADER_ITEM_PICKUP, ItemID($aItem), 0)
EndFunc   ;==>PickUpItem

;~ Description: Drops an item.
Func DropItem($aItem, $aAmount = 0)
	Local $lQuantity = GetItemQuantity($aItem)
	If $aAmount = 0 Or $aAmount > $lQuantity Then $aAmount = $lQuantity
	Return SendPacket(0xC, $HEADER_DROP_ITEM, ItemID($aItem), $aAmount)
EndFunc   ;==>DropItem

;Drops all Items to ground, if in explorable
Func DropAll()
	If GetInstanceType() <> 1 Then Return 0
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			DropItem($lItemPtr)
			PingSleep(100)
		Next
	Next
	Return 1
EndFunc ;==>DropAll

;Drops all Items of given Type to ground, if in explorable
Func DropItemsByType($aType)
	If GetInstanceType() <> 1 Then Return 0
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemType($lItemPtr) <> $aType Then ContinueLoop
			DropItem($lItemPtr)
			PingSleep(100)
		Next
	Next
	Return 1
EndFunc ;==>DropItemsByType

;Drops all Items of given ModelID to ground, if in explorable
Func DropItemsByModelID($aModelID, $aFullStack = False)
	If GetInstanceType() <> 1 Then Return 0
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemModelID($lItemPtr) <> $aModelID Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			DropItem($lItemPtr)
			PingSleep(100)
		Next
	Next
EndFunc ;==>DropItemsByModelID

;Description: Destroys an Item
Func DestroyItem($aItem, $aAmount = 0)
	Local $lQuantity = GetItemQuantity($aItem)
	If $aAmount = 0 Or $aAmount > $lQuantity Then $aAmount = $lQuantity
	Return SendPacket(0xC, $HEADER_ITEM_DESTROY, ItemID($aItem), $aAmount)
EndFunc   ;==>DestroyItem

;~ Description: Moves an item.
Func MoveItem($aItem, $aBag, $aSlot)
	Return SendPacket(0x10, $HEADER_ITEM_MOVE, ItemID($aItem), BagID($aBag), $aSlot - 1)
EndFunc   ;==>MoveItem

;~ Description: Moves an Item and can split up a Stack
Func MoveItemEx($aItem, $aBag, $aSlot, $aAmount = 0)
	Local $lQuantity = GetItemQuantity($aItem)
	If $aAmount = 0 Or $aAmount > $lQuantity Then $aAmount = $lQuantity
	If $aAmount >= $lQuantity Then
		SendPacket(0x10, $HEADER_ITEM_MOVE, ItemID($aItem), BagID($aBag), $aSlot - 1)
	Else
		SendPacket(0x14, $HEADER_ITEM_SPLIT_STACK, ItemID($aItem), $aAmount, BagID($aBag), $aSlot - 1)
	EndIf
EndFunc ;==>MoveItemEx

;~ Description: Looks for free Slot and moves Item to Chest.
;~ If $aStackItem=True, it will try to stack Items with same ModelID
Func MoveItemToChest($aItem, $aStackItem = False)
	Local $lItemPtr, $lBagPtr
	Local $lMoveItem = False
	For $bag = 8 To 12
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then
				$lMoveItem = True
				ExitLoop 2
			EndIf
			If $aStackItem And GetItemModelID($lItemPtr) = GetItemModelID($aItem) Then
				If (GetItemQuantity($lItemPtr) + GetItemQuantity($aItem)) <= 250 Then
					$lMoveItem = True
					ExitLoop 2
				EndIf
			EndIf
		Next
	Next
	
	If $lMoveItem = False Then Return False
	MoveItem($aItem, $bag, $slot)
	PingSleep(200)
	Return True
EndFunc ;==>MoveItemToChest

;~ Description: Looks for free Slot and moves Item to Inventory
Func MoveItemToInventory($aItem)
	Local $lBagPtr, $lMoveItem = False
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			If GetItemPtrBySlot($lBagPtr, $slot) = 0 Then
				$lMoveItem = True
				ExitLoop 2
			EndIf
		Next
	Next
	
	If $lMoveItem = False Then Return False
	MoveItem($aItem, $bag, $slot)
	PingSleep(200)
	Return True
EndFunc ;==>MoveItemToInventory

Func StoreItemsByModelID($aModelID, $aFullStack = False)
	If GetInstanceType() <> 0 Then Return False
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemModelID($lItemPtr) <> $aModelID Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			If MoveItemToChest($lItemPtr) = False Then Return
		Next
	Next
EndFunc ;==>StoreItemsByModelID

;Stores all Items of given Type
Func StoreItemsByType($aType, $aFullStack = False)
	If GetInstanceType() <> 0 Then Return False
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemType($lItemPtr) <> $aType Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			If MoveItemToChest($lItemPtr) = False Then Return
		Next
	Next
EndFunc ;==>StoreItemsByType

Func WithdrawItemsByModelID($aModelID, $aFullStack = False)
	If GetInstanceType() <> 0 Then Return False
	Local $lItemPtr, $lBagPtr
	For $bag = 8 To 12
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemModelID($lItemPtr) <> $aModelID Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			If MoveItemToInventory($lItemPtr) = False Then Return
		Next
	Next
EndFunc ;==>WithdrawItemsByModelID

;Stores all Items of given Type
Func WithdrawItemsByType($aType, $aFullStack = False)
	If GetInstanceType() <> 0 Then Return False
	Local $lItemPtr, $lBagPtr
	For $bag = 8 To 12
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemType($lItemPtr) <> $aType Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			If MoveItemToInventory($lItemPtr) = False Then Return
		Next
	Next
EndFunc ;==>WithdrawItemsByType

;~ Description: Equips an item.
Func EquipItem($aItem)
	Return SendPacket(0x8, $HEADER_ITEM_EQUIP, ItemID($aItem))
EndFunc   ;==>EquipItem

;~ Description: Unequips item to $abag, $aslot (1-based).
;~ Equipmentslots:	1 -> Mainhand/Two-hand	2 -> Offhand	3 -> Chestpiece	4 -> Leggings
;~					5 -> Headpiece			6 -> Boots		7 -> Gloves
Func UnequipItem($aEquipmentSlot, $aBag, $aSlot)
	Return SendPacket(0x10, $HEADER_ITEM_UNEQUIP, $aEquipmentSlot - 1, BagID($aBag), $aSlot - 1)
EndFunc   ;==>UnequipItem

;~ Description: Sells an item.
Func SellItem($aItem, $aQuantity = 0)
	Local $lQuantity = MemoryRead(GetItemPtr($aItem) + 76, 'short')
	Local $lValue = MemoryRead(GetItemPtr($aItem) + 36, 'short')

	If $aQuantity = 0 Or $aQuantity > $lQuantity Then $aQuantity = $lQuantity
	DllStructSetData($mSellItem, 2, $aQuantity * $lValue)
	DllStructSetData($mSellItem, 3, ItemID($aItem))
	Return Enqueue($mSellItemPtr, 12)
EndFunc   ;==>SellItem

;~ Description: Buys an item.
Func BuyItem($aItem, $aQuantity, $aValue)
	Local $lMerchantItemsBase = GetMerchantItemsBase()

	If Not $lMerchantItemsBase Then Return
	If $aItem < 1 Or $aItem > GetMerchantItemsSize() Then Return

	DllStructSetData($mBuyItem, 2, $aQuantity)
	DllStructSetData($mBuyItem, 3, MemoryRead($lMerchantItemsBase + 4 * ($aItem - 1)))
	DllStructSetData($mBuyItem, 4, $aQuantity * $aValue)
	DllStructSetData($mBuyItem, 5, MemoryRead(GetScannedAddress('ScanBuyItemBase', 15)))
	Enqueue($mBuyItemPtr, 20)
EndFunc   ;==>BuyItem

;~ Description: Buys an ID kit.
Func BuyIDKit()
	BuyItem(5, 1, 100)
	PingSleep(1000)
EndFunc   ;==>BuyIDKit

;~ Description: Buys an ID kit, use only in Embark Beach
Func BuyIDKitEmbark()
	BuyItem(6, 1, 100)
	PingSleep(1000)
EndFunc   ;==>BuyIDKit

; Buys Superior ID kit.
Func BuySuperiorIDKit()
	BuyItem(6, 1, 500)
	PingSleep(1000)
EndFunc

; Buys Superior ID kit, use only in Embark Beach
Func BuySuperiorIDKitEmbark()
	BuyItem(7, 1, 500)
	PingSleep(1000)
EndFunc

; Buys the cheapest Salvage Kit
Func BuySalvageKit()
	BuyItem(2, 1, 100)
	PingSleep(1000)
EndFunc ;==>BuySalvageKit

; Buys the cheapest Salvage Kit, use only in Embark Beach
Func BuySalvageKitEmbark()
	BuyItem(3, 1, 100)
	PingSleep(1000)
EndFunc ;==>BuySalvageKitEmbark

; Buys the cheapest Salvage Kit
Func BuyExpertSalvageKit()
	BuyItem(3, 1, 400)
	PingSleep(1000)
EndFunc ;==>BuySalvageKit

; Buys the cheapest Salvage Kit, use only in Embark Beach
Func BuyExpertSalvageKitEmbark()
	BuyItem(4, 1, 400)
	PingSleep(1000)
EndFunc ;==>BuySalvageKitEmbark

; Buys the cheapest Salvage Kit
Func BuySuperiorSalvageKit()
	BuyItem(4, 1, 2000)
	PingSleep(1000)
EndFunc ;==>BuySalvageKit

; Buys the cheapest Salvage Kit, use only in Embark Beach
Func BuySuperiorSalvageKitEmbark()
	BuyItem(5, 1, 2000)
	PingSleep(1000)
EndFunc ;==>BuySalvageKitEmbark

Func StartSalvage($aItem, $aSalvageKit = 0, $aCheap = True)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x690]
	Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lSalvageKit = 0

	If IsPtr($aSalvageKit) Then
		$lSalvageKit = $aSalvageKit
	ElseIf $aCheap Then
		$lSalvageKit = FindCheapSalvageKit()
	Else
		$lSalvageKit = FindExpertSalvageKit()
	EndIf
	If $lSalvageKit = 0 Then Return 0

	DllStructSetData($mSalvage, 2, ItemID($aItem))
	DllStructSetData($mSalvage, 3, ItemID($lSalvageKit))
	DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])
	Enqueue($mSalvagePtr, 16)
	Return 1
EndFunc   ;==>StartSalvage

;~ Description: Returns ItemPtr of cheap Salvage Kit in inventory. Return 0, if no Kit found.
Func FindCheapSalvageKit($aCheckUses = False)
	Local $lItemPtr, $lValue, $lKitPtr = 0, $lUses = 101
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 to GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lValue = GetItemValue($lItemPtr)
			Switch GetItemModelID($lItemPtr)
				Case 2992
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 2) < $lUses Then
						$lUses = $lValue / 2
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindCheapSalvageKit

Func FindExpertSalvageKit($aCheckUses = False)
	Local $lItemPtr, $lValue, $lKitPtr = 0, $lUses = 101
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 to GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lValue = GetItemValue($lItemPtr)
			Switch GetItemModelID($lItemPtr)
				Case 2991
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 8) < $lUses Then
						$lUses = $lValue / 8
						$lKitPtr = $lItemPtr
					EndIf
				; Case 2992
					; If $aCheckUses = False Then Return $lItemPtr
					; If ($lValue / 2) < $lUses Then
						; $lUses = $lValue / 2
						; $lKitPtr = $lItemPtr
					; EndIf
				Case 5900
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 10) < $lUses Then
						$lUses = $lValue / 10
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindExpertSalvageKit

;~ Description: Salvage the materials out of an item.
Func SalvageMaterials()
	Return SendPacket(0x4, $HEADER_ITEM_SALVAGE_MATERIALS)
EndFunc   ;==>SalvageMaterials

;~ Description: Salvages a mod out of an item.
Func SalvageMod($aModIndex)
	Return SendPacket(0x8, $HEADER_ITEM_SALVAGE_UPGRADE, $aModIndex)
EndFunc   ;==>SalvageMod

;~ Description: Identifies an item.
Func IdentifyItem($aItem, $aIdKit = FindIdentificationKit())
	If GetIsIdentified($aItem) Then Return 1
	
	Local $lIdKit = 0
	If IsPtr($aIDKit) Then
		$lIdKit = $aIdKit
	Else
		$lIdKit = FindIdentificationKit()
	EndIf
	If $lIDKit = 0 Then Return 0

	SendPacket(0xC, $HEADER_ITEM_IDENTIFY, ItemID($lIdKit), ItemID($aItem))

	Local $lDeadlock = TimerInit()
	Do
		Sleep(50)
	Until GetIsIdentified($aItem) Or TimerDiff($lDeadlock) > 5000
	If TimerDiff($lDeadlock) > 5000 Then Return 0
	Return 1
EndFunc   ;==>IdentifyItem

;~ Description: Legacy function, use FindIdentificationKit instead.
Func FindIDKit()
	Return FindIdentificationKit()
EndFunc   ;==>FindIDKit

;~ Description: Returns item ID of ID kit in inventory.
Func FindIdentificationKit($aCheckUses = False)
	Local $lItemPtr, $lValue, $lKitPtr = 0, $lUses = 101
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 to GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lValue = GetItemValue($lItemPtr)
			Switch GetItemModelID($lItemPtr)
				Case 2989
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 2) < $lUses Then
						$lUses = $lValue / 2
						$lKitPtr = $lItemPtr
					EndIf
				Case 5899
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 2.5) < $lUses Then
						$lUses = $lValue / 2.5
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindIdentificationKit

;~ Description: Returns ItemPtr of ID kit in inventory. Return 0, if no Kit found.
Func FindSuperiorIDKit($aCheckUses = False)
	Local $lItemPtr, $lValue, $lKitPtr = 0, $lUses = 101
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 to GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lValue = GetItemValue($lItemPtr)
			Switch GetItemModelID($lItemPtr)
				Case 5899
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 2.5) < $lUses Then
						$lUses = $lValue / 2.5
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindSuperiorIDKit

;~ Description: Identifies all items in a bag.
Func IdentifyBag($aBag, $aWhites = False, $aGolds = True)
	Local $lItemPtr, $lBagPtr = GetBagPtr($aBag), $lRarity
	If $lBagPtr = 0 Then Return 0
	For $slot = 1 To GetMaxSlots($lBagPtr)
		$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		If $lItemPtr = 0 Then ContinueLoop
		$lRarity = GetRarity($lItemPtr)
		If $lRarity = 2621 And $aWhites = False Then ContinueLoop
		If $lRarity = 2624 And $aGolds = False Then ContinueLoop
		If IdentifyItem($lItemPtr) = 0 Then Return 0
		PingSleep(50)
	Next
	Return 1
EndFunc   ;==>IdentifyBag

Func GetCraftMatsString($aModelID, $aAmount)
	Local $lCount = 0
	Local $lQuantity = 0
	Local $lMatString = ''
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop ; no valid bag
		For $slot = 1 To MemoryRead($lBagPtr + 32, 'long')
			$lSlotPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lSlotPtr = 0 Then ContinueLoop ; empty slot
			If MemoryRead($lSlotPtr + 44, 'long') = $aModelID Then
				$lMatString &= MemoryRead($lSlotPtr, 'long') & ';'
				$lCount += 1
				$lQuantity += MemoryRead($lSlotPtr + 75, 'byte')
				If $lQuantity >= $aAmount Then
					Return SetExtended($lCount, $lMatString)
				EndIf
			EndIf
		Next
	Next
EndFunc   ;==>GetCraftMatsString

Func GetMerchantItemPtrByModelId($nModelId)
	Local $aOffsets[5] = [0, 0x18, 0x40, 0xB8]
	Local $pMerchantBase = GetMerchantItemsBase()
	Local $nItemId = 0
	Local $nItemPtr = 0

	For $i = 0 To GetMerchantItemsSize() -1
		$nItemId = MemoryRead($pMerchantBase + 4 * $i)

		If ($nItemId) Then
			$aOffsets[4] = 4 * $nItemId
			$nItemPtr = MemoryReadPtr($mBasePointer, $aOffsets)[1]

			If (MemoryRead($nItemPtr + 0x2C) = $nModelId) Then
				Return Ptr($nItemPtr)
			EndIf
		EndIf
	Next
EndFunc   ;==>GetMerchantItemPtrByModelId

;~ Description: Request a quote to buy an item from a trader. Returns true if successful.
Func TraderRequest($aModelID, $aExtraID = -1)
	Local $lOffset[4] = [0, 0x18, 0x40, 0xC0]
	Local $lItemArraySize = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lOffset[5] = [0, 0x18, 0x40, 0xB8, 0]
	Local $lItemPtr, $lItemID
	Local $lFound = False
	Local $lQuoteID = MemoryRead($mTraderQuoteID)

	For $lItemID = 1 To $lItemArraySize[1]
		$lOffset[4] = 0x4 * $lItemID
		$lItemPtr = MemoryReadPtr($mBasePointer, $lOffset)
		If $lItemPtr[1] = 0 Then ContinueLoop

		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($g_ItemStruct), 'int', DllStructGetSize($g_ItemStruct), 'int', '')

		If DllStructGetData($g_ItemStruct, 'ModelID') = $aModelID And DllStructGetData($g_ItemStruct, 'bag') = 0 And DllStructGetData($g_ItemStruct, 'AgentID') == 0 Then
			If $aExtraID = -1 Or DllStructGetData($g_ItemStruct, 'ExtraID') = $aExtraID Then
				$lFound = True
				ExitLoop
			EndIf
		EndIf
	Next

	If Not $lFound Then Return False

	DllStructSetData($mRequestQuote, 2, DllStructGetData($g_ItemStruct, 'ID'))
	Enqueue($mRequestQuotePtr, 8)

	Local $lDeadlock = TimerInit()
	$lFound = False
	Do
		Sleep(20)
		$lFound = MemoryRead($mTraderQuoteID) <> $lQuoteID
	Until $lFound Or TimerDiff($lDeadlock) > GetPing() + 5000

	Return $lFound
EndFunc   ;==>TraderRequest

;~ Description: Buy the requested item.
Func TraderBuy()
	If Not GetTraderCostID() Or Not GetTraderCostValue() Then Return False
	Enqueue($mTraderBuyPtr, 4)
	Return True
EndFunc   ;==>TraderBuy

;~ Description: This shit might not work as intended :3
Func TraderRequestBuy($aItem)
	Local $lItemID
	Local $lFound = False
	Local $lQuoteID = MemoryRead($mTraderQuoteID)

	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	DllStructSetData($mRequestQuote, 1, $HEADER_REQUEST_QUOTE)
	DllStructSetData($mRequestQuote, 2, $lItemID)
	Enqueue($mRequestQuotePtr, 8)

	Local $lDeadlock = TimerInit()
	$lFound = False
	Do
		Sleep(20)
		$lFound = MemoryRead($mTraderQuoteID) <> $lQuoteID
	Until $lFound Or TimerDiff($lDeadlock) > GetPing() + 5000

	Return $lFound
EndFunc   ;==>TraderRequestBuy

;~ Description: Request a quote to sell an item to the trader
Func TraderRequestSell($aItem)
	Local $lItemID
	Local $lFound = False
	Local $lQuoteID = MemoryRead($mTraderQuoteID)

	If IsDllStruct($aItem) = 0 Then
		$lItemID = $aItem
	Else
		$lItemID = DllStructGetData($aItem, 'ID')
	EndIf

	DllStructSetData($mRequestQuoteSell, 1, $HEADER_REQUEST_QUOTE)
	DllStructSetData($mRequestQuoteSell, 2, $lItemID)
	Enqueue($mRequestQuoteSellPtr, 8)

	Local $lDeadlock = TimerInit()
	Do
		Sleep(20)
		$lFound = MemoryRead($mTraderQuoteID) <> $lQuoteID
	Until $lFound Or TimerDiff($lDeadlock) > GetPing() + 5000

	Return $lFound
EndFunc   ;==>TraderRequestSell

;~ Description: ID of the item item being sold.
Func TraderSell()
	If Not GetTraderCostID() Or Not GetTraderCostValue() Then Return False
	Enqueue($mTraderSellPtr, 4)
	Return True
EndFunc   ;==>TraderSell

;~ Description: Have always Platin in inventory, but not to much
Func MinMaxGold()
	If GetInstanceType() <> 0 Then Return 0
	Local $lCharacter = GetGoldCharacter()
	
	If $lCharacter < 20000 Then
		WithdrawGold(20000)
	ElseIf $lCharacter > 50000 Then
		DepositGold(25000)
	EndIf
	Return 1
EndFunc ;==>MinMaxGold

;~ Description: Returns amount of gold being carried.
Func GetGoldCharacter()
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x90]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGoldCharacter

;~ Description: Returns amount of gold in storage.
Func GetGoldStorage()
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x94]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGoldStorage

;~ Description: Drop gold on the ground.
Func DropGold($aAmount = 0)
	Local $lAmount = GetGoldCharacter()
	If $aAmount = 0 Or $aAmount > $lAmount Then $aAmount = $lAmount
	Return SendPacket(0x8, $HEADER_DROP_GOLD, $aAmount)
EndFunc ;==>DropGold

;~ Description: Deposit gold into storage.
Func DepositGold($aAmount = 0)
	Local $lAmount
	Local $lStorage = GetGoldStorage()
	Local $lCharacter = GetGoldCharacter()

	If $aAmount > 0 And $lCharacter >= $aAmount Then
		$lAmount = $aAmount
	Else
		$lAmount = $lCharacter
	EndIf

	If $lStorage + $lAmount > 1000000 Then $lAmount = 1000000 - $lStorage

	ChangeGold($lCharacter - $lAmount, $lStorage + $lAmount)
EndFunc   ;==>DepositGold

;~ Description: Withdraw gold from storage.
Func WithdrawGold($aAmount = 0)
	Local $lAmount
	Local $lStorage = GetGoldStorage()
	Local $lCharacter = GetGoldCharacter()

	If $aAmount > 0 And $lStorage >= $aAmount Then
		$lAmount = $aAmount
	Else
		$lAmount = $lStorage
	EndIf

	If $lCharacter + $lAmount > 100000 Then $lAmount = 100000 - $lCharacter

	ChangeGold($lCharacter + $lAmount, $lStorage - $lAmount)
EndFunc   ;==>WithdrawGold

;~ Description: Internal use for moving gold.
Func ChangeGold($aCharacter, $aStorage)
	Return SendPacket(0xC, $HEADER_ITEM_CHANGE_GOLD, $aCharacter, $aStorage) ;0x75
EndFunc   ;==>ChangeGold

;~ Description: Returns a weapon or shield's minimum required attribute.
Func GetItemReq($aItem)
	Local $lMod = GetModByIdentifier($aItem, "9827")
	Return $lMod[0]
EndFunc   ;==>GetItemReq

;~ Description: Returns a weapon or shield's required attribute.
Func GetItemAttribute($aItem)
	Local $lMod = GetModByIdentifier($aItem, "9827")
	Return $lMod[1]
EndFunc   ;==>GetItemAttribute

;~ Description: Returns an array of a the requested mod.
Func GetModByIdentifier($aItem, $aIdentifier)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lReturn[2]
	Local $lString = StringTrimLeft(GetModStruct($aItem), 2)
	For $i = 0 To StringLen($lString) / 8 - 2
		If StringMid($lString, 8 * $i + 5, 4) == $aIdentifier Then
			$lReturn[0] = Int("0x" & StringMid($lString, 8 * $i + 1, 2))
			$lReturn[1] = Int("0x" & StringMid($lString, 8 * $i + 3, 2))
			ExitLoop
		EndIf
	Next
	Return $lReturn
EndFunc   ;==>GetModByIdentifier

;~ Description: Returns modstruct of an item.
Func GetModStruct($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	If DllStructGetData($aItem, 'modstruct') = 0 Then Return
	Return MemoryRead(DllStructGetData($aItem, 'modstruct'), 'Byte[' & DllStructGetData($aItem, 'modstructsize') * 4 & ']')
EndFunc   ;==>GetModStruct

;~ Description: Tests if an item is assigned to you.
Func GetAssignedToMe($aAgent)
	Return (GetAgentInfo($aAgent, 'Owner') = GetMyID())
EndFunc   ;==>GetAssignedToMe

;~ Description: Tests if you can pick up an item.
Func GetCanPickUp($aAgent)
	If GetAssignedToMe($aAgent) Or GetAgentInfo($aAgent, 'Owner') = 0 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>GetCanPickUp

;~ Description: Returns the item ID of the quoted item.
Func GetTraderCostID()
	Return MemoryRead($mTraderCostID)
EndFunc   ;==>GetTraderCostID

;~ Description: Returns the cost of the requested item.
Func GetTraderCostValue()
	Return MemoryRead($mTraderCostValue)
EndFunc   ;==>GetTraderCostValue

;~ Description: Internal use for BuyItem()
Func GetMerchantItemsBase()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x24]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMerchantItemsBase

;~ Description: Internal use for BuyItem()
Func GetMerchantItemsSize()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x28]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMerchantItemsSize
#EndRegion Item

#Region Bag
Func BagID($aBag)
	If IsPtr($aBag) Then
		Return MemoryRead($aBag + 8, "long")
	ElseIf IsDllStruct($aBag) Then
		Return DllStructGetData($aBag, "ID")
	Else
		Return MemoryRead(GetBagPtr($aBag) + 8, "long")
	EndIf
EndFunc   ;==>BagID

Func GetBagPtr($aBagNumber)
	If IsPtr($aBagNumber) Then Return $aBagNumber
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x4 * $aBagNumber]
	Local $lItemStructAddress = MemoryReadPtr($mBasePointer, $lOffset, 'ptr')
	Return $lItemStructAddress[1]
EndFunc   ;==>GetBagPtr

;~ Description: Returns struct of an inventory bag.
Func GetBag($aBagNumber)
	Local $lBagPtr = GetBagPtr($aBagNumber)
	If $lBagPtr = 0 Then Return 0

	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBagPtr, 'ptr', DllStructGetPtr($g_BagStruct), 'int', DllStructGetSize($g_BagStruct), 'int', '')
	Return $g_BagStruct
EndFunc   ;==>GetBag

;~ Description: Returns the Bag of an item by ItemID/ItemPtr/ItemStruct
Func GetBagPtrByItem($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 12, 'ptr')
EndFunc   ;==>GetBagPtrByItem

;~ Description: Returns the Bag Index of an item by ItemID/ItemPtr/ItemStruct
Func GetBagNumberByItem($aItem)
	Local $lBagPtr = GetBagPtrByItem($aItem)
	Return MemoryRead($lBagPtr + 4, "long") + 1
EndFunc   ;==>GetBagNumberByItem

;~ Description: Returns amount of slots of bag.
Func GetMaxSlots($aBag)
	Local $lBagPtr = GetBagPtr($aBag)
	If $lBagPtr = 0 Then Return 0
	Return MemoryRead($lBagPtr + 32, 'long')
EndFunc   ;==>GetMaxSlots

;~ Description: Returns number of free slots in inventory
Func CountFreeSlots()
	Local $lCount = 0, $lBagPtr
	For $lBag = 1 To 4
		$lBagPtr = GetBagPtr($lBag)
		If $lBagPtr = 0 Then ContinueLoop
		$lCount += MemoryRead($lBagPtr + 32, "long") - MemoryRead($lBagPtr + 16, "long")
	Next
	Return $lCount
EndFunc   ;==>CountFreeSlots

;~ Description: Retursn number of free slots in storage
Func CountFreeSlotsStorage()
	Local $lCount = 0, $lBagPtr
	For $lBag = 8 To 12
		$lBagPtr = GetBagPtr($lBag)
		If $lBagPtr = 0 Then ContinueLoop
		$lCount += MemoryRead($lBagPtr + 32, "long") - MemoryRead($lBagPtr + 16, "long")
	Next
	Return $lCount
EndFunc ;==>CountFreeSlotsStorage
#EndRegion Bag

#Region H&H
;~ Description: Adds a hero to the party.
Func AddHero($aHeroId)
	Return SendPacket(0x8, $HEADER_HERO_ADD, $aHeroId)
EndFunc   ;==>AddHero

;~ Description: Kicks a hero from the party.
Func KickHero($aHeroId)
	Return SendPacket(0x8, $HEADER_HERO_KICK, $aHeroId)
EndFunc   ;==>KickHero

;~ Description: Kicks all heroes from the party.
Func KickAllHeroes()
	Return SendPacket(0x8, $HEADER_HERO_KICK, 0x26)
EndFunc   ;==>KickAllHeroes

;~ Description: Add a henchman to the party.
Func AddNpc($aNpcId)
	Return SendPacket(0x8, $HEADER_PARTY_INVITE_NPC, $aNpcId)
EndFunc   ;==>AddNpc

;~ Description: Kick a henchman from the party.
Func KickNpc($aNpcId)
	Return SendPacket(0x8, $HEADER_PARTY_KICK_NPC, $aNpcId)
EndFunc   ;==>KickNpc

;~ Description: Clear the position flag from a hero.
Func CancelHero($aHeroNumber)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Return SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, $lAgentID, 0x7F800000, 0x7F800000, 0)
EndFunc   ;==>CancelHero

;~ Description: Clear the position flag from all heroes.
Func CancelAll()
	Return SendPacket(0x10, $HEADER_HERO_FLAG_ALL, 0x7F800000, 0x7F800000, 0)
EndFunc   ;==>CancelAll

;~ Description: Place a hero's position flag.
Func CommandHero($aHeroNumber, $aX, $aY)
	Return SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, GetHeroID($aHeroNumber), FloatToInt($aX), FloatToInt($aY), 0)
EndFunc   ;==>CommandHero

;~ Description: Place the full-party position flag.
Func CommandAll($aX, $aY)
	Return SendPacket(0x10, $HEADER_HERO_FLAG_ALL, FloatToInt($aX), FloatToInt($aY), 0)
EndFunc   ;==>CommandAll

;~ Description: Lock a hero onto a target.
Func LockHeroTarget($aHeroNumber, $aAgentID = 0) ;$aAgentID=0 Cancels Lock
	Local $lHeroID = GetHeroID($aHeroNumber)
	Return SendPacket(0xC, $HEADER_HERO_LOCK_TARGET, $lHeroID, $aAgentID)
EndFunc   ;==>LockHeroTarget

;~ Description: Change a hero's aggression level.
Func SetHeroAggression($aHeroNumber, $aAggression) ;0=Fight, 1=Guard, 2=Avoid
	Local $lHeroID = GetHeroID($aHeroNumber)
	Return SendPacket(0xC, $HEADER_HERO_BEHAVIOR, $lHeroID, $aAggression)
EndFunc   ;==>SetHeroAggression

;~ Description: Disable a skill on a hero's skill bar.
Func DisableHeroSkillSlot($aHeroNumber, $aSkillSlot)
	If Not GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot) Then ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
EndFunc   ;==>DisableHeroSkillSlot

;~ Description: Enable a skill on a hero's skill bar.
Func EnableHeroSkillSlot($aHeroNumber, $aSkillSlot)
	If GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot) Then ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
EndFunc   ;==>EnableHeroSkillSlot

;~ Description: Internal use for enabling or disabling hero skills
Func ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
	Return SendPacket(0xC, $HEADER_HERO_SKILL_TOGGLE, GetHeroID($aHeroNumber), $aSkillSlot - 1)
EndFunc   ;==>ChangeHeroSkillSlotState

;~ Description: Order a hero to use a skill.
Func UseHeroSkill($aHero, $aSkillSlot, $aTarget = -2)
	DllStructSetData($mUseHeroSkill, 2, GetHeroID($aHero))
	DllStructSetData($mUseHeroSkill, 3, ConvertID($aTarget))
	DllStructSetData($mUseHeroSkill, 4, $aSkillSlot - 1)
	Enqueue($mUseHeroSkillPtr, 16)
EndFunc   ;==>UseHeroSkill
#EndRegion H&H

#Region Interaction
;~ Description: Cancel current action.
Func CancelAction()
	Return SendPacket(0x4, $HEADER_ACTION_CANCEL)
EndFunc   ;==>CancelAction

;~ Description: Attack an agent.
Func Attack($aAgent, $aCallTarget = False)
	Return SendPacket(0xC, $HEADER_ACTION_ATTACK, ConvertID($aAgent), $aCallTarget)
EndFunc   ;==>Attack

;~ Description: Run to or follow a player.
Func GoPlayer($aAgent)
	Return SendPacket(0x8, $HEADER_INTERACT_PLAYER, ConvertID($aAgent))
EndFunc   ;==>GoPlayer

;~ Description: Talk to an NPC
Func GoNPC($aAgent)
	Return SendPacket(0xC, $HEADER_INTERACT_LIVING, ConvertID($aAgent))
EndFunc   ;==>GoNPC

;~ Description: Run to a signpost.
Func GoSignpost($aAgent)
	Return SendPacket(0xC, $HEADER_GADGET_INTERACT, ConvertID($aAgent), 0)
EndFunc   ;==>GoSignpost

;~ Description: Open a chest with key.
Func OpenChestNoLockpick()
	Return SendPacket(0x8, $HEADER_CHEST_OPEN, 1)
EndFunc   ;==>OpenChestNoLockpick

;~ Description: Open a chest with lockpick.
Func OpenChest()
	Return SendPacket(0x8, $HEADER_CHEST_OPEN, 2)
EndFunc   ;==>OpenChest
#EndRegion Interaction

#Region Movement
;~ Description: Move to a location.
Func Move($aX, $aY, $aRandom = 50)
	If Not GetAgentExists(-2) Then Return 0
	DllStructSetData($mMove, 2, $aX + Random(-$aRandom, $aRandom))
	DllStructSetData($mMove, 3, $aY + Random(-$aRandom, $aRandom))
	Enqueue($mMovePtr, 16)
	Return 1
EndFunc   ;==>Move

;~ Description: Move to a location and wait until you reach it.
Func MoveTo($aX, $aY, $aRandom = 50)
	Local $lBlocked = 0, $lMe = GetAgentPtr(-2)
	Local $lMapLoading = GetInstanceType(), $lMapLoadingOld
	Local $lDestX = $aX + Random(-$aRandom, $aRandom)
	Local $lDestY = $aY + Random(-$aRandom, $aRandom)

	Move($lDestX, $lDestY, 0)
	Do
		Sleep(100)
		If GetIsDead($lMe) Then Return 0

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetInstanceType()
		If $lMapLoading <> $lMapLoadingOld Then Return 0

		If MoveX($lMe) = 0 And MoveY($lMe) = 0 Then
			$lBlocked += 1
			$lDestX = $aX + Random(-$aRandom, $aRandom)
			$lDestY = $aY + Random(-$aRandom, $aRandom)
			Move($lDestX, $lDestY, 0)
		EndIf
	Until GetDistanceToXY($lDestX, $lDestY, $lMe) < 25 Or $lBlocked > 14
	Return 1
EndFunc   ;==>MoveTo

;~ Description: Talks to NPC and waits until you reach them.
Func GoToNPC($aAgent)
	Local $lMe = GetAgentPtr(-2)
	Local $lBlocked = 0
	Local $lMapLoading = GetInstanceType(), $lMapLoadingOld

	Move(X($aAgent), Y($aAgent), 100)
	Do
		Sleep(100)
		If GetIsDead($lMe) Then Return 0

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetInstanceType()
		If $lMapLoading <> $lMapLoadingOld Then Return 0

		If Not GetIsMoving($lMe) Then
			$lBlocked += 1
			Move(X($aAgent), Y($aAgent), 100)
		EndIf
	Until GetDistance($aAgent, $lMe) < 200 Or $lBlocked > 14
	GoNPC($aAgent)
	PingSleep(1000)
EndFunc   ;==>GoToNPC

;~ Description: Go to signpost and waits until you reach it.
Func GoToSignpost($aAgent)
	Local $lMe = GetAgentPtr(-2)
	Local $lBlocked = 0
	Local $lMapLoading = GetInstanceType(), $lMapLoadingOld

	Move(X($aAgent), Y($aAgent), 100)
	Do
		Sleep(100)
		If GetIsDead($lMe) Then Return 0

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetInstanceType()
		If $lMapLoading <> $lMapLoadingOld Then Return 0

		If Not GetIsMoving($lMe) Then
			$lBlocked += 1
			Move(X($aAgent), Y($aAgent), 100)
		EndIf
	Until GetDistance($aAgent, $lMe) < 200 Or $lBlocked > 14
	GoSignpost($aAgent)
	Pingsleep(1000)
EndFunc   ;==>GoToSignpost

;~ Description: Turn character to the left.
Func TurnLeft($aTurn)
	If $aTurn Then
		Return PerformAction(0xA2, 0x1E)
	Else
		Return PerformAction(0xA2, 0x20)
	EndIf
EndFunc   ;==>TurnLeft

;~ Description: Turn character to the right.
Func TurnRight($aTurn)
	If $aTurn Then
		Return PerformAction(0xA3, 0x1E)
	Else
		Return PerformAction(0xA3, 0x20)
	EndIf
EndFunc   ;==>TurnRight

;~ Description: Move backwards.
Func MoveBackward($aMove)
	If $aMove Then
		Return PerformAction(0xAC, 0x1E)
	Else
		Return PerformAction(0xAC, 0x20)
	EndIf
EndFunc   ;==>MoveBackward

;~ Description: Run forwards.
Func MoveForward($aMove)
	If $aMove Then
		Return PerformAction(0xAD, 0x1E)
	Else
		Return PerformAction(0xAD, 0x20)
	EndIf
EndFunc   ;==>MoveForward

;~ Description: Strafe to the left.
Func StrafeLeft($aStrafe)
	If $aStrafe Then
		Return PerformAction(0x91, 0x1E)
	Else
		Return PerformAction(0x91, 0x20)
	EndIf
EndFunc   ;==>StrafeLeft

;~ Description: Strafe to the right.
Func StrafeRight($aStrafe)
	If $aStrafe Then
		Return PerformAction(0x92, 0x1E)
	Else
		Return PerformAction(0x92, 0x20)
	EndIf
EndFunc   ;==>StrafeRight

;~ Description: Auto-run.
Func ToggleAutoRun()
	Return PerformAction(0xB7, 0x1E)
EndFunc   ;==>ToggleAutoRun

;~ Description: Turn around.
Func ReverseDirection()
	Return PerformAction(0xB1, 0x1E)
EndFunc   ;==>ReverseDirection
#EndRegion Movement

#Region Travel
;~ Description: Map travel to an outpost.
Func TravelTo($aMapID, $aDis = 0)
	;returns true if successful
	If GetMapID() = $aMapID And $aDis = 0 And GetInstanceType() = 0 Then Return True
	ZoneMap($aMapID, $aDis)
	Return WaitMapLoading($aMapID)
EndFunc   ;==>TravelTo

Func TravelToEx($aMapID, $aDis = 0)
	;returns true if successful
	If GetMapID() = $aMapID And $aDis = 0 And GetInstanceType() = 0 Then Return True
	ZoneMap($aMapID, $aDis)
	Return WaitMapLoading($aMapID)
EndFunc   ;==>TravelToEx

;~ Description: Internal use for map travel.
Func ZoneMap($aMapID, $aDistrict = 0)
	MoveMap($aMapID, GetRegion(), $aDistrict, GetLanguage()) ;
EndFunc   ;==>ZoneMap

;~ Description: Internal use for map travel.
Func MoveMap($aMapID, $aRegion, $aDistrict, $aLanguage)
	Return SendPacket(0x18, $HEADER_PARTY_TRAVEL, $aMapID, $aRegion, $aDistrict, $aLanguage, False)
EndFunc   ;==>MoveMap

;~ Description: Returns to outpost after resigning/failure.
Func ReturnToOutpost()
	Return SendPacket(0x4, $HEADER_PARTY_RETURN_TO_OUTPOST)
EndFunc   ;==>ReturnToOutpost

;~ Description: Enter a challenge mission/pvp.
Func EnterChallenge()
	Return SendPacket(0x8, $HEADER_PARTY_ENTER_CHALLENGE, 1)
EndFunc   ;==>EnterChallenge

;~ Description: Enter a foreign challenge mission/pvp.
; Func EnterChallengeForeign()
; Return SendPacket(0x8, $HEADER_PARTY_ENTER_FOREIGN_CHALLENGE, 0)
; EndFunc   ;==>EnterChallengeForeign

;~ Description: Travel to your guild hall.
Func TravelGH()
	Local $lOffset[3] = [0, 0x18, 0x3C]
	Local $lGH = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x18, $HEADER_PARTY_ENTER_GUILD_HALL, MemoryRead($lGH[1] + 0x64), MemoryRead($lGH[1] + 0x68), MemoryRead($lGH[1] + 0x6C), MemoryRead($lGH[1] + 0x70), 1)
	Return WaitMapLoading()
EndFunc   ;==>TravelGH

;~ Description: Leave your guild hall.
Func LeaveGH()
	SendPacket(0x8, $HEADER_PARTY_LEAVE_GUILD_HALL, 1)
	Return WaitMapLoading()
EndFunc   ;==>LeaveGH
#EndRegion Travel

#Region Quest
;~ Description: Accept a quest from an NPC.
Func AcceptQuest($aQuestID)
	Return SendPacket(0x8, $HEADER_DIALOG_SEND, '0x008' & Hex($aQuestID, 3) & '01')
EndFunc   ;==>AcceptQuest

;~ Description: Accept the reward for a quest.
Func QuestReward($aQuestID)
	Return SendPacket(0x8, $HEADER_DIALOG_SEND, '0x008' & Hex($aQuestID, 3) & '07')
EndFunc   ;==>QuestReward

;~ Description: Abandon a quest.
Func AbandonQuest($aQuestID)
	Return SendPacket(0x8, $HEADER_QUEST_ABANDON, $aQuestID)
EndFunc   ;==>AbandonQuest
#EndRegion Quest

#Region Windows
;~ Description: Close all in-game windows.
Func CloseAllPanels()
	Return PerformAction(0x85, 0x1E)
EndFunc   ;==>CloseAllPanels

;~ Description: Toggle hero window.
Func ToggleHeroWindow()
	Return PerformAction(0x8A, 0x1E)
EndFunc   ;==>ToggleHeroWindow

;~ Description: Toggle inventory window.
Func ToggleInventory()
	Return PerformAction(0x8B, 0x1E)
EndFunc   ;==>ToggleInventory

;~ Description: Toggle all bags window.
Func ToggleAllBags()
	Return PerformAction(0xB8, 0x1E)
EndFunc   ;==>ToggleAllBags

;~ Description: Toggle world map.
Func ToggleWorldMap()
	Return PerformAction(0x8C, 0x1E)
EndFunc   ;==>ToggleWorldMap

;~ Description: Toggle options window.
Func ToggleOptions()
	Return PerformAction(0x8D, 0x1E)
EndFunc   ;==>ToggleOptions

;~ Description: Toggle quest window.
Func ToggleQuestWindow()
	Return PerformAction(0x8E, 0x1E)
EndFunc   ;==>ToggleQuestWindow

;~ Description: Toggle skills window.
Func ToggleSkillWindow()
	Return PerformAction(0x8F, 0x1E)
EndFunc   ;==>ToggleSkillWindow

;~ Description: Toggle mission map.
Func ToggleMissionMap()
	Return PerformAction(0xB6, 0x1E)
EndFunc   ;==>ToggleMissionMap

;~ Description: Toggle friends list window.
Func ToggleFriendList()
	Return PerformAction(0xB9, 0x1E)
EndFunc   ;==>ToggleFriendList

;~ Description: Toggle guild window.
Func ToggleGuildWindow()
	Return PerformAction(0xBA, 0x1E)
EndFunc   ;==>ToggleGuildWindow

;~ Description: Toggle party window.
Func TogglePartyWindow()
	Return PerformAction(0xBF, 0x1E)
EndFunc   ;==>TogglePartyWindow

;~ Description: Toggle score chart.
Func ToggleScoreChart()
	Return PerformAction(0xBD, 0x1E)
EndFunc   ;==>ToggleScoreChart

;~ Description: Toggle layout window.
Func ToggleLayoutWindow()
	Return PerformAction(0xC1, 0x1E)
EndFunc   ;==>ToggleLayoutWindow

;~ Description: Toggle minions window.
Func ToggleMinionList()
	Return PerformAction(0xC2, 0x1E)
EndFunc   ;==>ToggleMinionList

;~ Description: Toggle a hero panel.
Func ToggleHeroPanel($aHero)
	If $aHero < 4 Then
		Return PerformAction(0xDB + $aHero, 0x1E)
	ElseIf $aHero < 8 Then
		Return PerformAction(0xFE + $aHero, 0x1E)
	EndIf
EndFunc   ;==>ToggleHeroPanel

;~ Description: Toggle hero's pet panel.
Func ToggleHeroPetPanel($aHero)
	If $aHero < 4 Then
		Return PerformAction(0xDF + $aHero, 0x1E)
	ElseIf $aHero < 8 Then
		Return PerformAction(0xFA + $aHero, 0x1E)
	EndIf
EndFunc   ;==>ToggleHeroPetPanel

;~ Description: Toggle pet panel.
Func TogglePetPanel()
	Return PerformAction(0xDF, 0x1E)
EndFunc   ;==>TogglePetPanel

;~ Description: Toggle help window.
Func ToggleHelpWindow()
	Return PerformAction(0xE4, 0x1E)
EndFunc   ;==>ToggleHelpWindow
#EndRegion Windows

#Region Targeting
;~ Description: Target an agent.
Func ChangeTarget($aAgent)
	DllStructSetData($mChangeTarget, 2, ConvertID($aAgent))
	Enqueue($mChangeTargetPtr, 8)
EndFunc   ;==>ChangeTarget

;~ Description: Call target.
Func CallTarget($aTarget)
	Return SendPacket(0xC, $HEADER_CALL_TARGET, 0xA, ConvertID($aTarget))
EndFunc   ;==>CallTarget

;~ Description: Clear current target.
Func ClearTarget()
	Return PerformAction(0xE3, 0x1E)
EndFunc   ;==>ClearTarget

;~ Description: Target the nearest enemy.
Func TargetNearestEnemy()
	Return PerformAction(0x93, 0x1E)
EndFunc   ;==>TargetNearestEnemy

;~ Description: Target the next enemy.
Func TargetNextEnemy()
	Return PerformAction(0x95, 0x1E)
EndFunc   ;==>TargetNextEnemy

;~ Description: Target the next party member.
Func TargetPartyMember($aNumber)
	If $aNumber > 0 And $aNumber < 13 Then Return PerformAction(0x95 + $aNumber, 0x1E)
EndFunc   ;==>TargetPartyMember

;~ Description: Target the previous enemy.
Func TargetPreviousEnemy()
	Return PerformAction(0x9E, 0x1E)
EndFunc   ;==>TargetPreviousEnemy

;~ Description: Target the called target.
Func TargetCalledTarget()
	Return PerformAction(0x9F, 0x1E)
EndFunc   ;==>TargetCalledTarget

;~ Description: Target yourself.
Func TargetSelf()
	Return PerformAction(0xA0, 0x1E)
EndFunc   ;==>TargetSelf

;~ Description: Target the nearest ally.
Func TargetNearestAlly()
	Return PerformAction(0xBC, 0x1E)
EndFunc   ;==>TargetNearestAlly

;~ Description: Target the nearest item.
Func TargetNearestItem()
	Return PerformAction(0xC3, 0x1E)
EndFunc   ;==>TargetNearestItem

;~ Description: Target the next item.
Func TargetNextItem()
	Return PerformAction(0xC4, 0x1E) ;PerformAction(0xC4, 0x18)
EndFunc   ;==>TargetNextItem

;~ Description: Target the previous item.
Func TargetPreviousItem()
	Return PerformAction(0xC5, 0x1E)
EndFunc   ;==>TargetPreviousItem

;~ Description: Target the next party member.
Func TargetNextPartyMember()
	Return PerformAction(0xCA, 0x1E)
EndFunc   ;==>TargetNextPartyMember

;~ Description: Target the previous party member.
Func TargetPreviousPartyMember()
	Return PerformAction(0xCB, 0x1E)
EndFunc   ;==>TargetPreviousPartyMember
#EndRegion Targeting

#Region Display
;~ Description: Enable graphics rendering.
Func EnableRendering($aShowWindow = True)
	Local $lWindowHandle = GetWindowHandle(), $lPrevGWState = WinGetState($lWindowHandle), $lPrevWindow = WinGetHandle("[ACTIVE]", ""), $lPrevWindowState = WinGetState($lPrevWindow)
	If $aShowWindow And $lPrevGWState Then
		If BitAND($lPrevGWState, 16) Then
			WinSetState($lWindowHandle, "", @SW_RESTORE)
		ElseIf Not BitAND($lPrevGWState, 2) Then
			WinSetState($lWindowHandle, "", @SW_SHOW)
		EndIf
		If $lWindowHandle <> $lPrevWindow And $lPrevWindow Then RestoreWindowState($lPrevWindow, $lPrevWindowState)
	EndIf
	If Not GetIsRendering() Then
		$mRendering = True
		If Not MemoryWrite($mDisableRendering, 0) Then Return SetError(@error, False)
		Sleep(250)
	EndIf
	Return 1
EndFunc   ;==>EnableRendering

;~ Description: Disable graphics rendering.
Func DisableRendering($aHideWindow = True)
	Local $lWindowHandle = GetWindowHandle()
	If $aHideWindow And WinGetState($lWindowHandle) Then WinSetState($lWindowHandle, "", @SW_HIDE)
	If GetIsRendering() Then
		$mRendering = True
		If Not MemoryWrite($mDisableRendering, 1) Then Return SetError(@error, False)
		Sleep(250)
	EndIf
	Return 1
EndFunc   ;==>DisableRendering

;Toggles graphics rendering
Func ToggleRendering()
	Return GetIsRendering() ? DisableRendering() : EnableRendering()
EndFunc   ;==>ToggleRendering

Func GetIsRendering()
	Return MemoryRead($mDisableRendering) <> 1
EndFunc   ;==>GetIsRendering

;Internally used - restores a window to previous state.
Func RestoreWindowState($aWindowHandle, $aPreviousWindowState)
	If Not $aWindowHandle Or Not $aPreviousWindowState Then Return 0

	Local $lStates[6] = [1, 2, 4, 8, 16, 32], $lCurrentWindowState = WinGetState($aWindowHandle)
	For $i = 0 To UBound($lStates) - 1
		If BitAND($aPreviousWindowState, $lStates[$i]) And Not BitAND($lCurrentWindowState, $lStates[$i]) Then WinSetState($aWindowHandle, "", $lStates[$i])
	Next
EndFunc   ;==>RestoreWindowState

;~ Description: Display all names.
Func DisplayAll($aDisplay)
	DisplayAllies($aDisplay)
	DisplayEnemies($aDisplay)
EndFunc   ;==>DisplayAll

;~ Description: Display the names of allies.
Func DisplayAllies($aDisplay)
	If $aDisplay Then
		Return PerformAction(0x89, 0x1E)
	Else
		Return PerformAction(0x89, 0x20)
	EndIf
EndFunc   ;==>DisplayAllies

;~ Description: Display the names of enemies.
Func DisplayEnemies($aDisplay)
	If $aDisplay Then
		Return PerformAction(0x94, 0x1E)
	Else
		Return PerformAction(0x94, 0x20)
	EndIf
EndFunc   ;==>DisplayEnemies
#EndRegion Display

#Region Chat
;~ Description: Write a message in chat (can only be seen by botter).
Func WriteChat($aMessage, $aSender = 'GWA2')
	Local $lMessage, $lSender
	Local $lAddress = 256 * $mQueueCounter + $mQueueBase

	If $mQueueCounter = $mQueueSize Then
		$mQueueCounter = 0
	Else
		$mQueueCounter = $mQueueCounter + 1
	EndIf

	If StringLen($aSender) > 19 Then
		$lSender = StringLeft($aSender, 19)
	Else
		$lSender = $aSender
	EndIf

	MemoryWrite($lAddress + 4, $lSender, 'wchar[20]')

	If StringLen($aMessage) > 100 Then
		$lMessage = StringLeft($aMessage, 100)
	Else
		$lMessage = $aMessage
	EndIf

	MemoryWrite($lAddress + 44, $lMessage, 'wchar[101]')
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $lAddress, 'ptr', $mWriteChatPtr, 'int', 4, 'int', '')

	If StringLen($aMessage) > 100 Then WriteChat(StringTrimLeft($aMessage, 100), $aSender)
EndFunc   ;==>WriteChat

;~ Description: Send a whisper to another player.
Func SendWhisper($aReceiver, $aMessage)
	Local $lTotal = 'whisper ' & $aReceiver & ',' & $aMessage
	Local $lMessage

	If StringLen($lTotal) > 120 Then
		$lMessage = StringLeft($lTotal, 120)
	Else
		$lMessage = $lTotal
	EndIf

	SendChat($lMessage, '/')

	If StringLen($lTotal) > 120 Then SendWhisper($aReceiver, StringTrimLeft($lTotal, 120))
EndFunc   ;==>SendWhisper

;~ Description: Send a message to chat.
Func SendChat($aMessage, $aChannel = '!')
	Local $lMessage
	Local $lAddress = 256 * $mQueueCounter + $mQueueBase

	If $mQueueCounter = $mQueueSize Then
		$mQueueCounter = 0
	Else
		$mQueueCounter = $mQueueCounter + 1
	EndIf

	If StringLen($aMessage) > 120 Then
		$lMessage = StringLeft($aMessage, 120)
	Else
		$lMessage = $aMessage
	EndIf

	MemoryWrite($lAddress + 12, $aChannel & $lMessage, 'wchar[122]')
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', $lAddress, 'ptr', $mSendChatPtr, 'int', 8, 'int', '')

	If StringLen($aMessage) > 120 Then SendChat(StringTrimLeft($aMessage, 120), $aChannel)
EndFunc   ;==>SendChat
#EndRegion Chat

#Region Misc
;~ Description: Change weapon sets.
Func ChangeWeaponSet($aSet)
	Return PerformAction(0x80 + $aSet, 0x1E) ;Return PerformAction(0x80 + $aSet, 0x1E) 0x14A
EndFunc   ;==>ChangeWeaponSet

;~ Description: Same as hitting spacebar.
Func ActionInteract()
	Return PerformAction(0x80, 0x1E)
EndFunc   ;==>ActionInteract

;~ Description: Follow a player.
Func ActionFollow()
	Return PerformAction(0xCC, 0x1E)
EndFunc   ;==>ActionFollow

;~ Description: Drop environment object.
Func DropBundle()
	Return PerformAction(0xCD, 0x1E)
EndFunc   ;==>DropBundle

;~ Description: Clear all hero flags.
Func ClearPartyCommands()
	Return PerformAction(0xDB, 0x1E)
EndFunc   ;==>ClearPartyCommands

;~ Description: Suppress action.
Func SuppressAction($aSuppress)
	If $aSuppress Then
		Return PerformAction(0xD0, 0x1E)
	Else
		Return PerformAction(0xD0, 0x20)
	EndIf
EndFunc   ;==>SuppressAction

;~ Description: Stop maintaining enchantment on target.
Func DropBuff($aSkillID, $aAgentID, $aHeroNumber = 0)
	Local $lBuffCount = GetBuffCount($aHeroNumber)
	Local $lBuffStructAddress
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer

	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x4 + 0x24 * $i
			ReDim $lOffset[6]
			For $j = 0 To $lBuffCount - 1
				$lOffset[5] = 0 + 0x10 * $j
				$lBuffStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
				DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBuffStructAddress[0], 'ptr', DllStructGetPtr($g_BuffStruct), 'int', DllStructGetSize($g_BuffStruct), 'int', '')

				If (DllStructGetData($g_BuffStruct, 'SkillID') == $aSkillID) And (DllStructGetData($g_BuffStruct, 'TargetId') == ConvertID($aAgentID)) Then
					Return SendPacket(0x8, $HEADER_BUFF_DROP, DllStructGetData($g_BuffStruct, 'BuffId'))
					ExitLoop 2
				EndIf
			Next
		EndIf
	Next
EndFunc   ;==>DropBuff

;~ Description: Take a screenshot.
Func MakeScreenshot()
	Return PerformAction(0xAE, 0x1E)
EndFunc   ;==>MakeScreenshot

;~ Description: Invite a player to the party.
Func InvitePlayer($aPlayerName)
	SendChat('invite ' & $aPlayerName, '/')
EndFunc   ;==>InvitePlayer

;~ Description: Leave your party.
Func LeaveGroup($aKickHeroes = True)
	If $aKickHeroes Then KickAllHeroes()
	Return SendPacket(0x4, $HEADER_PARTY_LEAVE_GROUP)
EndFunc   ;==>LeaveGroup

;~ Description: Switches to/from Hard Mode.
Func SwitchMode($aMode)
	Return SendPacket(0x8, $HEADER_PARTY_SET_DIFFICULTY, $aMode)
EndFunc   ;==>SwitchMode

;~ Description: Resign.
Func Resign()
	SendChat('resign', '/')
EndFunc   ;==>Resign

;~ Description: Donate Kurzick or Luxon faction.
Func DonateFaction($aFaction)
	If StringLeft($aFaction, 1) = 'k' Then
		Return SendPacket(0x10, $HEADER_FACTION_DEPOSIT, 0, 0, 5000)
	Else
		Return SendPacket(0x10, $HEADER_FACTION_DEPOSIT, 0, 1, 5000)
	EndIf
EndFunc   ;==>DonateFaction

;~ Description: Open a dialog.
Func Dialog($aDialogID)
	Return SendPacket(0x8, $HEADER_DIALOG_SEND, $aDialogID)
EndFunc   ;==>Dialog

;~ Description: Open a dialog - Records your dialog entry
Func _Dialog($aDialogID)
	;_LogDialogID($aDialogID, $aAgent)
	Return SendPacket(0x8, $HEADER_DIALOG_SEND, $aDialogID)
EndFunc   ;==>_Dialog

;~ Description: Logs the given dialog ID, current map ID, and agent ID to a text file.
Func _LogDialogID($aDialogID, $aAgent)
	Local $sFilePath = @ScriptDir & "\DialogLog.txt"
	Local $hFile = FileOpen($sFilePath, 1)
	Local $mapID = GetMapID()
	Local $agentID = GetAgentInfo($aAgent, 'ID')

	If $hFile = -1 Then
		MsgBox(0, "Error", "Failed to open log file.")
		Return False
	EndIf

	FileWriteLine($hFile, "Dialog ID: " & $aDialogID & ", Map ID: " & $mapID & ", Agent ID: " & $agentID)
	FileClose($hFile)

	Return True
EndFunc   ;==>_LogDialogID

;~ Description: Skip a cinematic.
Func SkipCinematic()
	Return SendPacket(0x4, $HEADER_CINEMATIC_SKIP)
EndFunc   ;==>SkipCinematic

;~ Description: Change a skill on the skillbar.
Func SetSkillbarSkill($aSlot, $aSkillID, $aHeroNumber = 0)
	Return SendPacket(0x14, $HEADER_SKILLBAR_SKILL_SET, GetHeroID($aHeroNumber), $aSlot - 1, $aSkillID, 0)
EndFunc   ;==>SetSkillbarSkill

;~ Description: Load all skills onto a skillbar simultaneously.
Func LoadSkillBar($aSkill1 = 0, $aSkill2 = 0, $aSkill3 = 0, $aSkill4 = 0, $aSkill5 = 0, $aSkill6 = 0, $aSkill7 = 0, $aSkill8 = 0, $aHeroNumber = 0)
	SendPacket(0x2C, $HEADER_SKILLBAR_LOAD, GetHeroID($aHeroNumber), 8, $aSkill1, $aSkill2, $aSkill3, $aSkill4, $aSkill5, $aSkill6, $aSkill7, $aSkill8)
EndFunc   ;==>LoadSkillBar

Func LoadSkillTemplate($aTemplate, $aHeroNumber = 0)
	Local $lHeroID = GetHeroID($aHeroNumber)
	Local $lSplitTemplate = StringSplit($aTemplate, '')

	Local $lTemplateType ; 4 Bits
	Local $lVersionNumber ; 4 Bits
	Local $lProfBits ; 2 Bits -> P
	Local $lProfPrimary ; P Bits
	Local $lProfSecondary ; P Bits
	Local $lAttributesCount ; 4 Bits
	Local $lAttributesBits ; 4 Bits -> A
	Local $lAttributes[1][2] ; A Bits + 4 Bits (for each Attribute)
	Local $lSkillsBits ; 4 Bits -> S
	Local $lSkills[8] ; S Bits * 8
	Local $lOpTail ; 1 Bit

	$aTemplate = ''
	For $i = 1 To $lSplitTemplate[0]
		$aTemplate &= Base64ToBin64($lSplitTemplate[$i])
	Next

	$lTemplateType = Bin64ToDec(StringLeft($aTemplate, 4))
	$aTemplate = StringTrimLeft($aTemplate, 4)
	If $lTemplateType <> 14 Then Return False

	$lVersionNumber = Bin64ToDec(StringLeft($aTemplate, 4))
	$aTemplate = StringTrimLeft($aTemplate, 4)

	$lProfBits = Bin64ToDec(StringLeft($aTemplate, 2)) * 2 + 4
	$aTemplate = StringTrimLeft($aTemplate, 2)

	$lProfPrimary = Bin64ToDec(StringLeft($aTemplate, $lProfBits))
	$aTemplate = StringTrimLeft($aTemplate, $lProfBits)
	If $lProfPrimary <> GetHeroProfession($aHeroNumber) Then Return False

	$lProfSecondary = Bin64ToDec(StringLeft($aTemplate, $lProfBits))
	$aTemplate = StringTrimLeft($aTemplate, $lProfBits)

	$lAttributesCount = Bin64ToDec(StringLeft($aTemplate, 4))
	$aTemplate = StringTrimLeft($aTemplate, 4)

	$lAttributesBits = Bin64ToDec(StringLeft($aTemplate, 4)) + 4
	$aTemplate = StringTrimLeft($aTemplate, 4)

	$lAttributes[0][0] = $lAttributesCount
	For $i = 1 To $lAttributesCount
		If Bin64ToDec(StringLeft($aTemplate, $lAttributesBits)) == GetProfPrimaryAttribute($lProfPrimary) Then
			$aTemplate = StringTrimLeft($aTemplate, $lAttributesBits)
			$lAttributes[0][1] = Bin64ToDec(StringLeft($aTemplate, 4))
			$aTemplate = StringTrimLeft($aTemplate, 4)
			ContinueLoop
		EndIf
		$lAttributes[0][0] += 1
		ReDim $lAttributes[$lAttributes[0][0] + 1][2]
		$lAttributes[$i][0] = Bin64ToDec(StringLeft($aTemplate, $lAttributesBits))
		$aTemplate = StringTrimLeft($aTemplate, $lAttributesBits)
		$lAttributes[$i][1] = Bin64ToDec(StringLeft($aTemplate, 4))
		$aTemplate = StringTrimLeft($aTemplate, 4)
	Next

	$lSkillsBits = Bin64ToDec(StringLeft($aTemplate, 4)) + 8
	$aTemplate = StringTrimLeft($aTemplate, 4)

	For $i = 0 To 7
		$lSkills[$i] = Bin64ToDec(StringLeft($aTemplate, $lSkillsBits))
		$aTemplate = StringTrimLeft($aTemplate, $lSkillsBits)
	Next

	$lOpTail = Bin64ToDec($aTemplate)

	$lAttributes[0][0] = $lProfSecondary
	LoadAttributes($lAttributes, $aHeroNumber)
	LoadSkillBar($lSkills[0], $lSkills[1], $lSkills[2], $lSkills[3], $lSkills[4], $lSkills[5], $lSkills[6], $lSkills[7], $aHeroNumber)
EndFunc   ;==>LoadSkillTemplate

;~ Description: Load attributes from a two dimensional array.
Func LoadAttributes($aAttributesArray, $aHeroNumber = 0)
	Local $lPrimaryAttribute
	Local $lDeadlock = 0
	Local $lHeroID = GetHeroID($aHeroNumber)
	Local $lLevel
	Local $TestTimer = 0

	$lPrimaryAttribute = GetProfPrimaryAttribute(GetHeroProfession($aHeroNumber))

	If $aAttributesArray[0][0] <> 0 And GetHeroProfession($aHeroNumber, True) <> $aAttributesArray[0][0] And GetHeroProfession($aHeroNumber) <> $aAttributesArray[0][0] Then
		Do
			$lDeadlock = TimerInit()
			ChangeSecondProfession($aAttributesArray[0][0], $aHeroNumber)
			Do
				Sleep(16)
			Until GetHeroProfession($aHeroNumber, True) == $aAttributesArray[0][0] Or TimerDiff($lDeadlock) > 5000
		Until GetHeroProfession($aHeroNumber, True) == $aAttributesArray[0][0] Or TimerDiff($lDeadlock) > 10000
	EndIf

	$aAttributesArray[0][0] = $lPrimaryAttribute
	For $i = 0 To UBound($aAttributesArray) - 1
		If $aAttributesArray[$i][1] > 12 Then $aAttributesArray[$i][1] = 12
		If $aAttributesArray[$i][1] < 0 Then $aAttributesArray[$i][1] = 0
	Next

	While GetAttributeByID($lPrimaryAttribute, False, $aHeroNumber) > $aAttributesArray[0][1]
		$lLevel = GetAttributeByID($lPrimaryAttribute, False, $aHeroNumber)
		$lDeadlock = TimerInit()
		DecreaseAttribute($lPrimaryAttribute, $aHeroNumber)
		Do
			Sleep(16)
		Until GetAttributeByID($lPrimaryAttribute, False, $aHeroNumber) < $lLevel Or TimerDiff($lDeadlock) > 5000
		Sleep(16)
	WEnd
	For $i = 1 To UBound($aAttributesArray) - 1
		While GetAttributeByID($aAttributesArray[$i][0], False, $aHeroNumber) > $aAttributesArray[$i][1]
			$lLevel = GetAttributeByID($aAttributesArray[$i][0], False, $aHeroNumber)
			$lDeadlock = TimerInit()
			DecreaseAttribute($aAttributesArray[$i][0], $aHeroNumber)
			Do
				Sleep(16)
			Until GetAttributeByID($aAttributesArray[$i][0], False, $aHeroNumber) < $lLevel Or TimerDiff($lDeadlock) > 5000
			Sleep(16)
		WEnd
	Next
	For $i = 0 To 44
		If GetAttributeByID($i, False, $aHeroNumber) > 0 Then
			If $i = $lPrimaryAttribute Then ContinueLoop
			For $j = 1 To UBound($aAttributesArray) - 1
				If $i = $aAttributesArray[$j][0] Then ContinueLoop 2
			Next
			While GetAttributeByID($i, False, $aHeroNumber) > 0
				$lLevel = GetAttributeByID($i, False, $aHeroNumber)
				$lDeadlock = TimerInit()
				DecreaseAttribute($i, $aHeroNumber)
				Do
					Sleep(16)
				Until GetAttributeByID($i, False, $aHeroNumber) < $lLevel Or TimerDiff($lDeadlock) > 5000
				Sleep(16)
			WEnd
		EndIf
	Next

	$TestTimer = 0
	While GetAttributeByID($lPrimaryAttribute, False, $aHeroNumber) < $aAttributesArray[0][1]
		$lLevel = GetAttributeByID($lPrimaryAttribute, False, $aHeroNumber)
		$lDeadlock = TimerInit()
		IncreaseAttribute($lPrimaryAttribute, $aHeroNumber)
		Do
			Sleep(16)
			$TestTimer = $TestTimer + 1
		Until GetAttributeByID($lPrimaryAttribute, False, $aHeroNumber) > $lLevel Or TimerDiff($lDeadlock) > 5000
		Sleep(16)
		If $TestTimer > 225 Then ExitLoop
	WEnd
	For $i = 1 To UBound($aAttributesArray) - 1
		$TestTimer = 0
		While GetAttributeByID($aAttributesArray[$i][0], False, $aHeroNumber) < $aAttributesArray[$i][1]
			$lLevel = GetAttributeByID($aAttributesArray[$i][0], False, $aHeroNumber)
			$lDeadlock = TimerInit()
			IncreaseAttribute($aAttributesArray[$i][0], $aHeroNumber)
			Do
				Sleep(16)
				$TestTimer = $TestTimer + 1
			Until GetAttributeByID($aAttributesArray[$i][0], False, $aHeroNumber) > $lLevel Or TimerDiff($lDeadlock) > 5000
			Sleep(16)
			If $TestTimer > 225 Then ExitLoop
		WEnd
	Next
EndFunc   ;==>LoadAttributes

;~ Description: Increase attribute by 1
Func IncreaseAttribute($aAttributeID, $aHeroNumber = 0)
	DllStructSetData($mIncreaseAttribute, 2, $aAttributeID)
	DllStructSetData($mIncreaseAttribute, 3, GetHeroID($aHeroNumber))
	Enqueue($mIncreaseAttributePtr, 12)
EndFunc   ;==>IncreaseAttribute

;~ Description: Decrease attribute by 1
Func DecreaseAttribute($aAttributeID, $aHeroNumber = 0)
	DllStructSetData($mDecreaseAttribute, 2, $aAttributeID)
	DllStructSetData($mDecreaseAttribute, 3, GetHeroID($aHeroNumber))
	Enqueue($mDecreaseAttributePtr, 12)
EndFunc   ;==>DecreaseAttribute

;~ Description: Set all attributes to 0
Func ClearAttributes($aHeroNumber = 0)
	Local $lLevel
	If GetInstanceType() <> 0 Then Return
	For $i = 0 To 44
		If GetAttributeByID($i, False, $aHeroNumber) > 0 Then
			Do
				$lLevel = GetAttributeByID($i, False, $aHeroNumber)
				$lDeadlock = TimerInit()
				DecreaseAttribute($i, $aHeroNumber)
				Do
					Sleep(20)
				Until $lLevel > GetAttributeByID($i, False, $aHeroNumber) Or TimerDiff($lDeadlock) > 5000
				Sleep(100)
			Until GetAttributeByID($i, False, $aHeroNumber) == 0
		EndIf
	Next
EndFunc   ;==>ClearAttributes

;~ Description: Change your secondary profession.
Func ChangeSecondProfession($aProfession, $aHeroNumber = 0)
	Return SendPacket(0xC, $HEADER_PROFESSION_CHANGE, GetHeroID($aHeroNumber), $aProfession)
EndFunc   ;==>ChangeSecondProfession

;~ Description: Sets value of GetMapIsLoaded() to 0.
Func InitMapLoad()
	MemoryWrite($mMapIsLoaded, 0)
EndFunc   ;==>InitMapLoad

;~ Description: Changes game language to english.
Func EnsureEnglish($aEnsure)
	If $aEnsure Then
		MemoryWrite($mEnsureEnglish, 1)
	Else
		MemoryWrite($mEnsureEnglish, 0)
	EndIf
EndFunc   ;==>EnsureEnglish

;~ Description: Change game language.
Func ToggleLanguage()
	DllStructSetData($mToggleLanguage, 2, 0x18)
	Enqueue($mToggleLanguagePtr, 8)
EndFunc   ;==>ToggleLanguage

;~ Description: Changes the maximum distance you can zoom out.
Func ChangeMaxZoom($aZoom = 750)
	MemoryWrite($mZoomStill, $aZoom, "float")
	MemoryWrite($mZoomMoving, $aZoom, "float")
EndFunc   ;==>ChangeMaxZoom

;~ Description: Emptys Guild Wars client memory
Func ClearMemory()
	DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSize', 'int', $mGWProcHandle, 'int', -1, 'int', -1)
EndFunc   ;==>ClearMemory

;~ Description: Changes the maximum memory Guild Wars can use.
Func SetMaxMemory($aMemory = 157286400)
	DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSizeEx', 'int', $mGWProcHandle, 'int', 1, 'int', $aMemory, 'int', 6)
EndFunc   ;==>SetMaxMemory
#EndRegion Misc

;~ Description: Internal use only.
Func Enqueue($aPtr, $aSize)
	DllCall($mKernelHandle, 'int', 'WriteProcessMemory', 'int', $mGWProcHandle, 'int', 256 * $mQueueCounter + $mQueueBase, 'ptr', $aPtr, 'int', $aSize, 'int', '')
	If $mQueueCounter = $mQueueSize Then
		$mQueueCounter = 0
	Else
		$mQueueCounter = $mQueueCounter + 1
	EndIf
EndFunc   ;==>Enqueue

;~ Description: Converts float to integer.
Func FloatToInt($nFloat)
	Local $tFloat = DllStructCreate("float")
	Local $tInt = DllStructCreate("int", DllStructGetPtr($tFloat))
	DllStructSetData($tFloat, 1, $nFloat)
	Return DllStructGetData($tInt, 1)
EndFunc   ;==>FloatToInt
#EndRegion Commands

#Region Queries
#Region Titles
Func SetDisplayedTitle($aTitle = 0)
	If $aTitle Then
		Return SendPacket(0x8, $HEADER_TITLE_DISPLAY, $aTitle)
	Else
		Return SendPacket(0x4, $HEADER_TITLE_HIDE)
	EndIf
	;~ No Title = 0x00
	;~ Spearmarshall = 0x11
	;~ Lightbringer = 0x14
	;~ Asuran = 0x26
	;~ Dwarven = 0x27
	;~ Ebon Vanguard = 0x28
	;~ Norn = 0x29
EndFunc   ;==>SetDisplayedTitle

; Function to set the title to Spearmarshall
Func SetTitleSpearmarshall()
	SendPacket(0x8, $HEADER_TITLE_DISPLAY, 0x11)
EndFunc   ;==>SetTitleSpearmarshall

; Function to set the title to Lightbringer
Func SetTitleLightbringer()
	SendPacket(0x8, $HEADER_TITLE_DISPLAY, 0x14)
EndFunc   ;==>SetTitleLightbringer

; Function to set the title to Asuran
Func SetTitleAsuran()
	SendPacket(0x8, $HEADER_TITLE_DISPLAY, 0x26)
EndFunc   ;==>SetTitleAsuran

; Function to set the title to Dwarven
Func SetTitleDwarven()
	SendPacket(0x8, $HEADER_TITLE_DISPLAY, 0x27)
EndFunc   ;==>SetTitleDwarven

; Function to set the title to Ebon Vanguard
Func SetTitleEbonVanguard()
	SendPacket(0x8, $HEADER_TITLE_DISPLAY, 0x28)
EndFunc   ;==>SetTitleEbonVanguard

; Function to set the title to Norn
Func SetTitleNorn()
	SendPacket(0x8, $HEADER_TITLE_DISPLAY, 0x29)
EndFunc   ;==>SetTitleNorn

;~ Description: Returns Hero title progress.
Func GetHeroTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetHeroTitle

;~ Description: Returns Gladiator title progress.
Func GetGladiatorTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x7C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGladiatorTitle

;~ Description: Returns Codex title progress.
Func GetCodexTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x75C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetCodexTitle

;~ Description: Returns Kurzick title progress.
Func GetKurzickTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0xCC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetKurzickTitle

;~ Description: Returns Luxon title progress.
Func GetLuxonTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0xF4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLuxonTitle

;~ Description: Returns drunkard title progress.
Func GetDrunkardTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x11C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetDrunkardTitle

;~ Description: Returns survivor title progress.
Func GetSurvivorTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x16C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetSurvivorTitle

;~ Description: Returns max titles
Func GetMaxTitles()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x194]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxTitles

;~ Description: Returns lucky title progress.
Func GetLuckyTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x25C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLuckyTitle

;~ Description: Returns unlucky title progress.
Func GetUnluckyTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x284]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetUnluckyTitle

;~ Description: Returns Sunspear title progress.
Func GetSunspearTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x2AC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetSunspearTitle

;~ Description: Returns Lightbringer title progress.
Func GetLightbringerTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x324]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLightbringerTitle

;~ Description: Returns Commander title progress.
Func GetCommanderTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x374]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetCommanderTitle

;~ Description: Returns Gamer title progress.
Func GetGamerTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x39C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGamerTitle

;~ Description: Returns Legendary Guardian title progress.
Func GetLegendaryGuardianTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x4DC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLegendaryGuardianTitle

;~ Description: Returns sweets title progress.
Func GetSweetTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x554]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetSweetTitle

;~ Description: Returns Asura title progress.
Func GetAsuraTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x5F4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetAsuraTitle

;~ Description: Returns Deldrimor title progress.
Func GetDeldrimorTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x61C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetDeldrimorTitle

;~ Description: Returns Vanguard title progress.
Func GetVanguardTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x644]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetVanguardTitle

;~ Description: Returns Norn title progress.
Func GetNornTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x66C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetNornTitle

;~ Description: Returns mastery of the north title progress.
Func GetNorthMasteryTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x694]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetNorthMasteryTitle

;~ Description: Returns party title progress.
Func GetPartyTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x6BC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetPartyTitle

;~ Description: Returns Zaishen title progress.
Func GetZaishenTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x6E4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetZaishenTitle

;~ Description: Returns treasure hunter title progress.
Func GetTreasureTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x70C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetTreasureTitle

;~ Description: Returns wisdom title progress.
Func GetWisdomTitle()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x734]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetWisdomTitle

;~ Description: Returns current Tournament points.
Func GetTournamentPoints()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0, 0x18]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetTournamentPoints
#EndRegion Titles

#Region Faction
;~ Description: Returns current Kurzick faction.
Func GetKurzickFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x748]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetKurzickFaction

;~ Description: Returns max Kurzick faction.
Func GetMaxKurzickFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7B8]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxKurzickFaction

;~ Description: Returns current Luxon faction.
Func GetLuxonFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x758]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetLuxonFaction

;~ Description: Returns max Luxon faction.
Func GetMaxLuxonFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7BC]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxLuxonFaction

;~ Description: Returns current Balthazar faction.
Func GetBalthazarFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x798]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetBalthazarFaction

;~ Description: Returns max Balthazar faction.
Func GetMaxBalthazarFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7C0]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxBalthazarFaction

;~ Description: Returns current Imperial faction.
Func GetImperialFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x76C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetImperialFaction

;~ Description: Returns max Imperial faction.
Func GetMaxImperialFaction()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x7C4]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetMaxImperialFaction
#EndRegion Faction

#Region H&H
;~ Description: Returns number of heroes you control.
Func GetHeroCount()
	Local $lOffset[5]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x2C
	Local $lHeroCount = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lHeroCount[1]
EndFunc   ;==>GetHeroCount

;~ Description: Returns agent ID of a hero.
Func GetHeroID($aHeroNumber)
	If $aHeroNumber == 0 Then Return GetMyID()
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	$lOffset[5] = 0x18 * ($aHeroNumber - 1)
	Local $lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lAgentID[1]
EndFunc   ;==>GetHeroID

;~ Description: Returns hero number by agent ID.
Func GetHeroNumberByAgentID($aAgentID)
	Local $lAgentID
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	For $i = 1 To GetHeroCount()
		$lOffset[5] = 0x18 * ($i - 1)
		$lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
		If $lAgentID[1] == ConvertID($aAgentID) Then Return $i
	Next
	Return 0
EndFunc   ;==>GetHeroNumberByAgentID

;~ Description: Returns hero number by hero ID.
Func GetHeroNumberByHeroID($aHeroId)
	Local $lAgentID
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	For $i = 1 To GetHeroCount()
		$lOffset[5] = 8 + 0x18 * ($i - 1)
		$lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
		If $lAgentID[1] == ConvertID($aHeroId) Then Return $i
	Next
	Return 0
EndFunc   ;==>GetHeroNumberByHeroID

;~ Description: Returns hero's profession ID (when it can't be found by other means)
Func GetHeroProfession($aHeroNumber, $aSecondary = False)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6BC, 0]
	Local $lBuffer
	$aHeroNumber = GetHeroID($aHeroNumber)
	For $i = 0 To GetHeroCount()
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] = $aHeroNumber Then
			$lOffset[4] += 4
			If $aSecondary Then $lOffset[4] += 4
			$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
			Return $lBuffer[1]
		EndIf
		$lOffset[4] += 0x14
	Next
EndFunc   ;==>GetHeroProfession

;~ Description: Tests if a hero's skill slot is disabled.
Func GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot)
	Return BitAND(2 ^ ($aSkillSlot - 1), DllStructGetData(GetSkillbar($aHeroNumber), 'Disabled')) > 0
EndFunc   ;==>GetIsHeroSkillSlotDisabled
#EndRegion H&H

#Region Agent
Func GetAgentInfo($aAgentID, $aInfo = "")
	Local $lAgentPtr = GetAgentPtr($aAgentID)
	If $lAgentPtr = 0 Or $aInfo = "" Then Return 0

	Switch $aInfo
		Case "vtable"
			Return MemoryRead($lAgentPtr, "ptr")
		Case "h0004"
			Return MemoryRead($lAgentPtr + 0x4, "dword")
		Case "h0008"
			Return MemoryRead($lAgentPtr + 0x8, "dword")
		Case "h000C"
			Return MemoryRead($lAgentPtr + 0xC, "dword")
		Case "h0010"
			Return MemoryRead($lAgentPtr + 0x10, "dword")
		Case "Timer"
			Return MemoryRead($lAgentPtr + 0x14, "dword")
		Case "Timer2"
			Return MemoryRead($lAgentPtr + 0x18, "dword")
		Case "h0018"
			Return MemoryRead($lAgentPtr + 0x1C, "dword[4]")
		Case "ID"
			Return MemoryRead($lAgentPtr + 0x2C, "long")
		Case "Z"
			Return MemoryRead($lAgentPtr + 0x30, "float")
		Case "Width1"
			Return MemoryRead($lAgentPtr + 0x34, "float")
		Case "Height1"
			Return MemoryRead($lAgentPtr + 0x38, "float")
		Case "Width2"
			Return MemoryRead($lAgentPtr + 0x3C, "float")
		Case "Height2"
			Return MemoryRead($lAgentPtr + 0x40, "float")
		Case "Width3"
			Return MemoryRead($lAgentPtr + 0x44, "float")
		Case "Height3"
			Return MemoryRead($lAgentPtr + 0x48, "float")
		Case "Rotation"
			Return MemoryRead($lAgentPtr + 0x4C, "float")
		Case "RotationCos"
			Return MemoryRead($lAgentPtr + 0x50, "float")
		Case "RotationSin"
			Return MemoryRead($lAgentPtr + 0x54, "float")
		Case "NameProperties"
			Return MemoryRead($lAgentPtr + 0x58, "dword")
		Case "Ground"
			Return MemoryRead($lAgentPtr + 0x5C, "dword")
		Case "h0060"
			Return MemoryRead($lAgentPtr + 0x60, "dword")
		Case "TerrainNormalX"
			Return MemoryRead($lAgentPtr + 0x64, "float")
		Case "TerrainNormalY"
			Return MemoryRead($lAgentPtr + 0x68, "float")
		Case "TerrainNormalZ"
			Return MemoryRead($lAgentPtr + 0x6C, "dword")
		Case "h0070"
			Return MemoryRead($lAgentPtr + 0x70, "byte[4]")
		Case "X"
			Return MemoryRead($lAgentPtr + 0x74, "float")
		Case "Y"
			Return MemoryRead($lAgentPtr + 0x78, "float")
		Case "Plane"
			Return MemoryRead($lAgentPtr + 0x7C, "dword")
		Case "h0080"
			Return MemoryRead($lAgentPtr + 0x80, "byte[4]")
		Case "NameTagX"
			Return MemoryRead($lAgentPtr + 0x84, "float")
		Case "NameTagY"
			Return MemoryRead($lAgentPtr + 0x88, "float")
		Case "NameTagZ"
			Return MemoryRead($lAgentPtr + 0x8C, "float")
		Case "VisualEffects"
			Return MemoryRead($lAgentPtr + 0x90, "short")
		Case "h0092"
			Return MemoryRead($lAgentPtr + 0x92, "short")
		Case "h0094"
			Return MemoryRead($lAgentPtr + 0x94, "dword[2]")
		Case "Type"
			Return MemoryRead($lAgentPtr + 0x98, "long")
		Case "MoveX"
			Return MemoryRead($lAgentPtr + 0x9C, "float")
		Case "MoveY"
			Return MemoryRead($lAgentPtr + 0xA0, "float")
		Case "h00A8"
			Return MemoryRead($lAgentPtr + 0xA8, "dword")
		Case "RotationCos2"
			Return MemoryRead($lAgentPtr + 0xAC, "float")
		Case "RotationSin2"
			Return MemoryRead($lAgentPtr + 0xB0, "float")
		Case "h00B4"
			Return MemoryRead($lAgentPtr + 0xB4, "dword[4]")
		Case "Owner"
			Return MemoryRead($lAgentPtr + 0xC4, "long")
		Case "ItemID"
			Return MemoryRead($lAgentPtr + 0xC8, "dword")
		Case "ExtraType"
			Return MemoryRead($lAgentPtr + 0xCC, "dword")
		Case "GadgetID"
			Return MemoryRead($lAgentPtr + 0xD0, "dword")
		Case "h00D4"
			Return MemoryRead($lAgentPtr + 0xD4, "dword[3]")
		Case "AnimationType"
			Return MemoryRead($lAgentPtr + 0xE0, "float")
		Case "h00E4"
			Return MemoryRead($lAgentPtr + 0xE4, "dword[2]")
		Case "AttackSpeed"
			Return MemoryRead($lAgentPtr + 0xEC, "float")
		Case "AttackSpeedModifier"
			Return MemoryRead($lAgentPtr + 0xF0, "float")
		Case "PlayerNumber"
			Return MemoryRead($lAgentPtr + 0xF4, "short")
		Case "AgentModelType"
			Return MemoryRead($lAgentPtr + 0xF6, "short")
		Case "TransmogNpcId"
			Return MemoryRead($lAgentPtr + 0xF8, "dword")
		Case "Equip"
			Return MemoryRead($lAgentPtr + 0xFC, "ptr")
		Case "h0100"
			Return MemoryRead($lAgentPtr + 0x100, "dword")
		Case "Tags"
			Return MemoryRead($lAgentPtr + 0x104, "ptr")
		Case "h0108"
			Return MemoryRead($lAgentPtr + 0x108, "short")
		Case "Primary"
			Return MemoryRead($lAgentPtr + 0x10A, "byte")
		Case "Secondary"
			Return MemoryRead($lAgentPtr + 0x10B, "byte")
		Case "Level"
			Return MemoryRead($lAgentPtr + 0x10C, "byte")
		Case "Team"
			Return MemoryRead($lAgentPtr + 0x10D, "byte")
		Case "h010E"
			Return MemoryRead($lAgentPtr + 0x10E, "byte[2]")
		Case "h0110"
			Return MemoryRead($lAgentPtr + 0x110, "dword")
		Case "EnergyRegen"
			Return MemoryRead($lAgentPtr + 0x114, "float")
		Case "Overcast"
			Return MemoryRead($lAgentPtr + 0x118, "float")
		Case "EnergyPercent"
			Return MemoryRead($lAgentPtr + 0x11C, "float")
		Case "MaxEnergy"
			Return MemoryRead($lAgentPtr + 0x120, "dword")
		Case "h0124"
			Return MemoryRead($lAgentPtr + 0x124, "dword")
		Case "HPPips"
			Return MemoryRead($lAgentPtr + 0x128, "float")
		Case "h012C"
			Return MemoryRead($lAgentPtr + 0x12C, "dword")
		Case "HP"
			Return MemoryRead($lAgentPtr + 0x130, "float")
		Case "MaxHP"
			Return MemoryRead($lAgentPtr + 0x134, "dword")
		Case "Effects"
			Return MemoryRead($lAgentPtr + 0x138, "dword")
		Case "h013C"
			Return MemoryRead($lAgentPtr + 0x13C, "dword")
		Case "Hex"
			Return MemoryRead($lAgentPtr + 0x140, "byte")
		Case "h0141"
			Return MemoryRead($lAgentPtr + 0x141, "byte[19]")
		Case "ModelState"
			Return MemoryRead($lAgentPtr + 0x154, "dword")
		Case "TypeMap"
			Return MemoryRead($lAgentPtr + 0x158, "dword")
		Case "h015C"
			Return MemoryRead($lAgentPtr + 0x15C, "dword[4]")
		Case "InSpiritRange"
			Return MemoryRead($lAgentPtr + 0x16C, "dword")
		Case "VisibleEffects"
			Return MemoryRead($lAgentPtr + 0x170, "dword")
		Case "VisibleEffectsID"
			Return MemoryRead($lAgentPtr + 0x174, "dword")
		Case "VisibleEffectsHasEnded"
			Return MemoryRead($lAgentPtr + 0x178, "dword")
		Case "h017C"
			Return MemoryRead($lAgentPtr + 0x17C, "dword")
		Case "LoginNumber"
			Return MemoryRead($lAgentPtr + 0x180, "dword")
		Case "AnimationSpeed"
			Return MemoryRead($lAgentPtr + 0x184, "float")
		Case "AnimationCode"
			Return MemoryRead($lAgentPtr + 0x188, "dword")
		Case "AnimationId"
			Return MemoryRead($lAgentPtr + 0x18C, "dword")
		Case "h0190"
			Return MemoryRead($lAgentPtr + 0x190, "byte[32]")
		Case "LastStrike"
			Return MemoryRead($lAgentPtr + 0x1B0, "byte")
		Case "Allegiance"
			Return MemoryRead($lAgentPtr + 0x1B1, "byte")
		Case "WeaponType"
			Return MemoryRead($lAgentPtr + 0x1B2, "short")
		Case "Skill"
			Return MemoryRead($lAgentPtr + 0x1B4, "short")
		Case "h01B6"
			Return MemoryRead($lAgentPtr + 0x1B6, "short")
		Case "WeaponItemType"
			Return MemoryRead($lAgentPtr + 0x1B8, "byte")
		Case "OffhandItemType"
			Return MemoryRead($lAgentPtr + 0x1B9, "byte")
		Case "WeaponItemId"
			Return MemoryRead($lAgentPtr + 0x1BA, "short")
		Case "OffhandItemId"
			Return MemoryRead($lAgentPtr + 0x1BC, "short")
		Case Else
			Return 0
	EndSwitch

	Return 0
EndFunc   ;==>GetAgentInfo

;~ Description: Internal use for handing -1, -2, AgentStruct and AgentPtr.
Func ConvertID($aID)
	Select
		Case $aID = -2
			Return GetMyID()
		Case $aID = -1
			Return GetCurrentTargetID()
		Case IsPtr($aID) <> 0
			Return MemoryRead($aID + 0x2C, 'long')
		Case IsDllStruct($aID) <> 0
			Return DllStructGetData($aID, 'ID')
		Case Else
			Return $aID
	EndSelect
EndFunc ;==>ConvertID

; ~ Description: Internal use for GetAgentByID/GetAgentInfo()
Func GetAgentPtr($aAgent = -2)
	If IsPtr($aAgent) Then Return $aAgent
	; Return MemoryRead(MemoryRead($mAgentBase, 'ptr') + 4 * ConvertID($aAgent), 'ptr')
	Local $lOffset[3] = [0, 4 * ConvertID($aAgent), 0]
	Local $lAgentStructAddress = MemoryReadPtr($mAgentBase, $lOffset, 'ptr')
	Return $lAgentStructAddress[0]
EndFunc   ;==>GetAgentPtr

;~ Description: Returns an agent struct.
Func GetAgentByID($aAgent = -2)
	Local $lAgentPtr = GetAgentPtr($aAgent)
	If $lAgentPtr = 0 Then Return 0

	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lAgentPtr, 'ptr', DllStructGetPtr($g_AgentStruct), 'int', DllStructGetSize($g_AgentStruct), 'int', '')

	Return $g_AgentStruct
EndFunc   ;==>GetAgentByID

;~ Description: Returns number of agents currently loaded.
Func GetMaxAgents()
	Return MemoryRead($mMaxAgents)
EndFunc   ;==>GetMaxAgents

;~ Description: Returns your agent ID.
Func GetMyID()
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x680, 0x14]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset, 'dword')
	Return $lReturn[1]
;~ 	Return MemoryRead($mMyID)
EndFunc   ;==>GetMyID

;~ Description: Returns current target AgentStruct.
Func GetCurrentTarget()
	Local $lCurrentTargetID = MemoryRead($mCurrentTarget)
	If $lCurrentTargetID = 0 Then Return 0
	Return GetAgentByID(GetCurrentTargetID())
EndFunc   ;==>GetCurrentTarget

;~ Description: Returns current target AgentPtr.
Func GetCurrentTargetPtr()
	Local $lCurrentTargetID = MemoryRead($mCurrentTarget)
	If $lCurrentTargetID = 0 Then Return 0
	Return GetAgentPtr($lCurrentTargetID)
EndFunc   ;==>GetCurrentTargetPtr

;~ Description: Returns current target ID.
Func GetCurrentTargetID()
	Return MemoryRead($mCurrentTarget)
EndFunc   ;==>GetCurrentTargetID

;~ Description: Test if an agent exists.
Func GetAgentExists($aAgent)
	Return GetAgentPtr($aAgent) <> 0
EndFunc   ;==>GetAgentExists

;~ Description: Agents X Location
Func X($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 116, 'float')
EndFunc   ;==>X

;~ Description: Agents Movevement on the X axis
Func MoveX($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 160, 'float')
EndFunc   ;==>MoveX

;~ Description: Agents Y Location
Func Y($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 120, 'float')
EndFunc   ;==>Y

;~ Description: Agents Movevement on the Y axis
Func MoveY($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 164, 'float')
EndFunc   ;==>MoveY

;~ Description: Agents PlayerNumber
Func GetPlayerNumber($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 244, "word")
EndFunc   ;==>GetPlayerNumber

;~ Description: Returns energy of an agent. (Only self/heroes)
Func GetEnergy($aAgent = -2)
	Local $lPtr = GetAgentPtr($aAgent)
	Return MemoryRead($lPtr + 284, 'float') * MemoryRead($lPtr + 288, "long")
EndFunc   ;==>GetEnergy

;~ Description: Returns health of an agent. Returns 0 for NPC's
Func GetHealth($aAgent = -2)
	Local $lPtr = GetAgentPtr($aAgent)
	Return MemoryRead($lPtr + 304, 'float') * MemoryRead($lPtr + 308, "long")
EndFunc   ;==>GetHealth

;~ Description: Returns health of an agent as % of max HP
Func GetHP($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 304, 'float')
EndFunc   ;==>GetHP

;~ Description: Returns the allegiance of an agent.
Func GetAllegiance($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 433, 'byte')
EndFunc   ;==>GetAllegiance

;~ Description: Returns the skill currently being cast by an agent.
Func GetSkillID($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 436, "word")
EndFunc   ;==>GetSkillID

;~ Description: Returns the Type of the Agent. 0xDB/0x200/0x400
Func GetAgentType($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long')
EndFunc   ;==>GetAgentType

;~ Description: Returns the target of an agent.
Func GetTarget($aAgent)
	Return MemoryRead(GetValue('TargetLogBase') + 4 * ConvertID($aAgent))
EndFunc   ;==>GetTarget

;~ Description: Returns agent by player name.
Func GetAgentByPlayerName($aPlayerName)
	For $i = 1 To GetMaxAgents()
		If GetPlayerName($i) = $aPlayerName Then
			Return GetAgentPtr($i)
		EndIf
	Next
EndFunc   ;==>GetAgentByPlayerName

;~ Description: Returns agent by name.
Func GetAgentByName($aName)
	If $mUseStringLog = False Then Return

	Local $lName, $lAddress

	For $i = 1 To GetMaxAgents()
		$lAddress = $mStringLogBase + 256 * $i
		$lName = MemoryRead($lAddress, 'wchar [128]')
		$lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
		If StringInStr($lName, $aName) > 0 Then Return GetAgentPtr($i)
	Next

	DisplayAll(True)
	Sleep(100)
	DisplayAll(False)
	DisplayAll(True)
	Sleep(100)
	DisplayAll(False)

	For $i = 1 To GetMaxAgents()
		$lAddress = $mStringLogBase + 256 * $i
		$lName = MemoryRead($lAddress, 'wchar [128]')
		$lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
		If StringInStr($lName, $aName) > 0 Then Return GetAgentPtr($i)
	Next
EndFunc   ;==>GetAgentByName

Func GetAgentByPlayerNumber($aPlayerNumber)
	Local $lAgentArray = GetAgentArray()

	For $i = 1 To $lAgentArray[0]
		If GetAgentInfo($lAgentArray[$i], "PlayerNumber") == $aPlayerNumber Then Return $lAgentArray[$i]
	Next
EndFunc   ;==>GetAgentByPlayerNumber

;~ Description: Returns array of party members
;~ Param: an array returned by GetAgentArray. This is totally optional, but can greatly improve script speed.
Func GetParty($aAgentArray = 0)
	Local $lReturnArray[1] = [0]
	If $aAgentArray == 0 Then $aAgentArray = GetAgentArray(0xDB)
	For $i = 1 To $aAgentArray[0]
		If GetAgentInfo($aAgentArray[$i], 'Allegiance') = 1 Then
			If BitAND(GetAgentInfo($aAgentArray[$i], 'TypeMap'), 131072) Then
				$lReturnArray[0] += 1
				ReDim $lReturnArray[$lReturnArray[0] + 1]
				$lReturnArray[$lReturnArray[0]] = $aAgentArray[$i]
			EndIf
		EndIf
	Next
	Return $lReturnArray
EndFunc   ;==>GetParty

; #FUNCTION# ====================================================================================================================
; Name ..........: GetAgentPtrArray
; Description ...: 	very fast method to get an array of agents in compass range
; Syntax ........: GetAgentPtrArray([$aMode = 0[, $aType = 0xDB[, $aAllegiance = 3[, $aRange = 1320[, $aAgent = GetAgentPtr(-2)[, $aPlayerNumber = 0[, $aEffect = 0[, $aX = X($aAgent)[, $aY = Y($aAgent)]]]]]]]]])
; Parameters ....: $aMode               - [optional] 0=all agents; 1=Type; 2=Type+Allegiance; 3=Type+Allegiance+Range+Agent+PlayerNumber+Effect+Xy
;                  $aType               - [optional] Type: 0xDB/0x200/0x400 (default 0xDB=living)
;                  $aAllegiance         - [optional] Allegiance (default 3=enemy)
;                  $aRange              - [optional] Range (default 1320)
;                  $aAgent              - [optional] Agent (default is GetAgentPtr(-2))
;                  $aPlayerNumber       - [optional] PlayerNumber (default is 0)
;                  $aEffect             - [optional] Effect: dead, bleeding, etc (default is 0)
;                  $aX                  - [optional] X Position (default is X($aAgent))
;                  $aY                  - [optional] Y Position (default is Y($aAgent))
; Return values .: Array of Agent Pointers
; Author ........: Blake, credit to Greg et al.
; Modified ......: 26.02.2025
; Remarks .......:
; Related .......: GetAgentArraySorted
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func GetAgentPtrArray($aMode = 0, $aType = 0xDB, $aAllegiance = 3, $aRange = 1320, $aAgent = GetAgentPtr(-2), $aPlayerNumber = 0, $aEffect = 0, $aX = X($aAgent), $aY = Y($aAgent))
	Local $lMaxAgents = GetMaxAgents()
	If $lMaxAgents <= 0 Then Return 0
	
	Local $lPtr
	Local $lAgentArray[$lMaxAgents + 1]
	$lAgentArray[0] = 0
	
	Local $lAgentBasePtr = MemoryRead($mAgentBase)
	Local $lAgentPtrBuffer = DllStructCreate("ptr[" & $lMaxAgents & "]")
	DllCall($mKernelHandle, "bool", "ReadProcessMemory", "handle", $mGWProcHandle, "ptr", $lAgentBasePtr, "struct*", $lAgentPtrBuffer, "ulong_ptr", 4 * $lMaxAgents, "ulong_ptr*", 0)

	For $i = 1 To $lMaxAgents
		$lPtr = DllStructGetData($lAgentPtrBuffer, 1, $i)
		If $lPtr = 0 Then ContinueLoop
		If $aMode >= 1 And MemoryRead($lPtr + 0x9C, 'long') <> $aType Then ContinueLoop
		If $aMode >= 2 And MemoryRead($lPtr + 0x1B1, 'byte') <> $aAllegiance Then ContinueLoop
		If $aMode >= 3 Then
			If $aEffect <> 0x0010 And GetIsDead($lPtr) Then ContinueLoop ; HP > 0
			If $aRange <> 0 And GetDistanceToXY($aX, $aY, $lPtr) > $aRange Then ContinueLoop ; is in $aRange
			If $aPlayerNumber <> 0 And $aPlayerNumber <> MemoryRead($lPtr + 0xF4, "word") Then ContinueLoop ; has PlayerNumber
			If $aEffect <> 0 And Not BitAND(MemoryRead($lPtr + 0x138, 'long'), $aEffect) Then ContinueLoop ; has $aEffect
		EndIf

		$lAgentArray[0] += 1
		$lAgentArray[$lAgentArray[0]] = $lPtr
	Next
	ReDim $lAgentArray[$lAgentArray[0] + 1]
	Return $lAgentArray
EndFunc ;==>GetAgentPtrArray

; #FUNCTION# ====================================================================================================================
; Name ..........: GetAgentArray
; Description ...: Returns Array of AgentStructs (backwards compatibility)
; Syntax ........: GetAgentArray([$aType = 0xDB[, $aAllegiance = 0]])
; Parameters ....: $aType               - [optional] Agent Type (default is 0xDB)
;                  $aAllegiance         - [optional] Agent Allegiance (default is 0)
; Return values .: Array of AgentStructs
; Author ........: Blake
; Modified ......: 26.02.2025
; Remarks .......: funtion should be deprecated, better use GetAgentPtrArray
; Related .......: GetAgentPtrArray
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func GetAgentArray($aType = 0xDB, $aAllegiance = 0)
	Local $lAgentArray = GetAgentPtrArray(1, $aType)
	If $lAgentArray = 0 Then Return 0
	
	If $aType = 0x200 Or $aType = 0x400 Then
		Local $lReturnArray[UBound($lAgentArray)]
	
		For $i = 1 To $lAgentArray[0]			
			$lReturnArray[$i] = GetAgentByID($lAgentArray[$i])
		Next
		Return $lReturnArray
	ElseIf $aType = 0xDB Then
		Local $lCount = 0, $lReturnArray[UBound($lAgentArray)]
		
		For $i = 1 To $lAgentArray[0]
			If $aAllegiance <> 0 And MemoryRead($lAgentArray[$i] + 0x1B1, "byte") <> $aAllegiance Then ContinueLoop
			
			$lCount += 1
			$lReturnArray[$lCount] = GetAgentByID($lAgentArray[$i])
		Next
		
		$lReturnArray[0] = $lCount
		ReDim $lReturnArray[$lCount + 1]
		
		Return $lReturnArray
	EndIf
EndFunc	;==>GetAgentArray

; #FUNCTION# ====================================================================================================================
; Name ..........: GetAgentArraySorted
; Description ...: Sorts an AgentPtrArray by Distance.
; Syntax ........: GetAgentArraySorted([$aAgentArray = GetAgentPtrArray(2, 0xDB, 3)])
; Parameters ....: $aAgentArray         - [optional] Array of AgentPtr (default all enemies in compass range)
; Return values .: None
; Author ........: Blake
; Modified ......: 26.02.2025
; Remarks .......:
; Related .......: GetAgentPtrArray
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func GetAgentArraySorted($aAgentArray = GetAgentPtrArray(2, 0xDB, 3))
	Local $lReturnArray[UBound($aAgentArray)][2]
	Local $lDistance, $lMe = GetAgentPtr(-2)

	For $i = 1 To UBound($aAgentArray) - 1
		$lReturnArray[$i][0] = $aAgentArray[$i]
		$lReturnArray[$i][1] = GetDistance($aAgentArray[$i], $lMe)
	Next
	$lReturnArray[0][0] = $aAgentArray[0]
	_ArraySort($lReturnArray, 0, 1, 0, 1) ; test this someday
	Return $lReturnArray
EndFunc ;==>GetAgentArraySorted

; #FUNCTION# ====================================================================================================================
; Name ..........: GetNumberOfEnemiesNearAgent
; Description ...: Returns the number of living enemies in range of an agent.
; Syntax ........: GetNumberOfEnemiesNearAgent([$aAgent = -2[, $aRange = 1250[, $aPlayerNumber = 0]]])
; Parameters ....: $aAgent              - [optional] The relevant Agent. (default is self)
;                  $aRange              - [optional] Range (default is 1250)
;                  $aPlayerNumber       - [optional] PlayerNumber (default is 0/none)
; Return values .: Number of Living enemies near agent.
; Author ........: 
; Modified ......: 26.02.2025
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func GetNumberOfEnemiesNearAgent($aAgent = -2, $aRange = 1250, $aPlayerNumber = 0)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 3, $aRange, $aAgent, $aPlayerNumber)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfEnemiesNearAgent

; duplicate of GetNumberOfEnemiesNearAgent (backwards compatibility)
Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 3, $aRange, $aAgent)
	Return UBound($lAgentPtrArray) - 1
EndFunc

; Returns the number of living enemies in range of a waypoint. optional: PlayerNumber
Func GetNumberOfEnemiesNearXY($aX, $aY, $aRange = 1250, $aPlayerNumber = 0)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 3, $aRange, -2, $aPlayerNumber, 0, $aX, $aY)
	Return UBound($lAgentPtrArray) - 1
EndFunc	;==>GetNumberOfEnemiesNearXY

;~ Returns the number of living allies in range of an agent. (include npc, pet, spirit)
Func GetNumberOfAlliesInRangeOfAgent($aAgent = -2, $aRange = 1250)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 1, $aRange, $aAgent)
	Return UBound($lAgentPtrArray) - 1
EndFunc ;==>GetNumberOfAlliesInRangeOfAgent

; Returns the number of living allies in range of an agent
Func GetNumberOfDeadAlliesInRangeOfAgent($aAgent = -2, $aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 1, $aRange, $aAgent, 0, 0x0010)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfDeadAllies

Func GetNumberOfItemsInRangeOfAgent($aAgent = -2, $aRange = 1250)
	Local $lAgentPtrArray = GetAgentPtrArray(1, 0x400)
	Local $lCount = 0, $lAgent = GetAgentPtr($aAgent)
	
	For $i = 1 To $lAgentPtrArray[0]
		If GetDistance($lAgentPtrArray($i), $lAgent) < $aRange Then $lCount += 1
	Next
	Return $lCount
EndFunc ;==>GetNumberOfItemsInRangeOfAgent

#Region GetNearestAgent
;~ Description: Returns Pointer to nearest agent to an agent or XY. optional: PlayerNumber
;~ GetNearestAgentPtr: Agent, Type, Allegiance, PlayerNumber, X, Y
Func GetNearestAgentPtr($aAgent = -2, $aType = 0xDB, $aAllegiance = 0, $aPlayerNumber = 0, $aX = X($aAgent), $aY = Y($aAgent))
	Local $lAgent = GetAgentPtr($aAgent), $lNearestAgentPtr = 0, $lNearestDistance = 25000000
	Local $lAgentPtrArray, $lDistance
	Switch $aType
		Case 0xDB
			$lAgentPtrArray = GetAgentPtrArray(2, $aType, $aAllegiance)
		Case 0x200, 0x400
			$lAgentPtrArray = GetAgentPtrArray(1, $aType)
	EndSwitch

	For $i = 1 To $lAgentPtrArray[0]
		If $lAgentPtrArray[$i] = $lAgent Then ContinueLoop
		If $aType = 0xDB And GetIsDead($lAgentPtrArray[$i]) Then ContinueLoop
		If $aPlayerNumber <> 0 And MemoryRead($lAgentPtrArray[$i] + 244, "word") <> $aPlayerNumber Then ContinueLoop
		$lDistance = GetPseudoDistanceToXY($aX, $aY, $lAgentPtrArray[$i])
		If $lDistance < $lNearestDistance Then
			$lNearestAgentPtr = $lAgentPtrArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next
	Return $lNearestAgentPtr
EndFunc ;==>GetNearestAgentPtr

;~ Desription: Returns nearest Item AgentPtr to agent. optional: PlayerNumber/ModelID IS IT THE SAME?
; GetCanPickUp?
Func GetNearestItemPtrToAgent($aAgent = -2, $aPlayerNumber = 0)
	Return GetNearestAgentPtr($aAgent, 0x400, 0, $aPlayerNumber)
EndFunc ;==>GetNearestItemPtrToAgent

;~ Desription: Returns nearest Item AgentStruct to agent. optional: PlayerNumber/ModelID IS IT THE SAME?
Func GetNearestItemToAgent($aAgent = -2, $aPlayerNumber = 0)
	Local $lAgentPtr = GetNearestAgentPtr($aAgent, 0x400, 0, $aPlayerNumber)
	Return GetAgentByID($lAgentPtr)
EndFunc ;==>GetNearestItemToAgent

;~ Description: Returns pointer variable for the nearest enemy to an agent.
Func GetNearestEnemyPtrToAgent($aAgent = -2, $aPlayerNumber = 0)
	Return GetNearestAgentPtr($aAgent, 0xDB, 3, $aPlayerNumber)
EndFunc ;==>GetNearestEnemyPtrToAgent

;(backwards compatibility)
;~ Description: Returns the nearest enemy to an agent. (AgentStruct)
Func GetNearestEnemyToAgent($aAgent = -2, $aPlayerNumber = 0)
	Local $lAgent = GetNearestEnemyPtrToAgent($aAgent, $aPlayerNumber)
	Return GetAgentByID($lAgent)
EndFunc ;==>GetNearestEnemyToAgent

Func GetNearestEnemyPtrToXY($aX = X(-2), $aY = Y(-2), $aPlayerNumber = 0)
	Return GetNearestAgentPtr(-2, 0xDB, 3, $aPlayerNumber, $aX, $aY)
EndFunc ;==>GetNearestEnemyPtrToXY

;(backwards compatibility)
;~ Description: Returns the nearest enemy to a set of coordinates. (AgentStruct)
Func GetNearestEnemyToCoords($aX, $aY, $aPlayerNumber = 0)
	Local $lAgent = GetNearestEnemyPtrToXY($aX, $aY, $aPlayerNumber)
	Return GetAgentByID($lAgent)
EndFunc   ;==>GetNearestAgentToCoords

;~ Description: Returns pointer to the nearest NPC to an agent. optional: PlayerNumber
Func GetNearestNPCPtrToAgent($aAgent = -2, $aPlayerNumber = 0)
	Return GetNearestAgentPtr($aAgent, 0xDB, 6, $aPlayerNumber)
EndFunc   ;==>GetNearestNPCPtrToAgent

;(backwards compatibility)
;~ Description: Returns the nearest NPC to an agent. (AgentStruct)
Func GetNearestNPCToAgent($aAgent = -2)
	Local $lAgent = GetNearestNPCPtrToAgent($aAgent)
	Return GetAgentByID($lAgent)
EndFunc ;==>GetNearestNPCToAgent

;~ Description: Returns pointer to the nearest NPC to XY. optional: PlayerNumber
Func GetNearestNPCPtrToXY($aX = X(-2), $aY = Y(-2), $aPlayerNumber = 0)
	Return GetNearestAgentPtr(-2, 0xDB, 6, $aPlayerNumber, $aX, $aY)
EndFunc   ;==>GetNearestNPCPtrToXY

;(backwards compatibility)
;~ Description: Returns the nearest NPC to a set of coordinates. (AgentStruct)
Func GetNearestNPCToCoords($aX, $aY)
	Local $lAgent = GetNearestNPCPtrToXY($aX, $aY)
	Return GetAgentByID($lAgent)
EndFunc   ;==>GetNearestNPCToCoords

;~ Description: Returns the pointer variable for the nearest signpost to an agent.
Func GetNearestSignpostPtrToAgent($aAgent = -2)
	Return GetNearestAgentPtr($aAgent, 0x200)
EndFunc   ;==>GetNearestSignpostPtrToAgent

;(backwards compatibility)
;~ Description: Returns the nearest signpost to an agent. (AgentStruct)
Func GetNearestSignpostToAgent($aAgent = -2)
	Local $lAgent = GetNearestSignpostPtrToAgent($aAgent)
	Return GetAgentByID($lAgent)
EndFunc ;==>GetNearestSignpostToAgent

;~ Description: Returns the pointer variable for the nearest signpost to a set of coordinates.
Func GetNearestSignpostPtrToXY($aX, $aY)
	Return GetNearestAgentPtr(-2, 0x200, 0, 0, $aX, $aY) ; look up allegiance=2
EndFunc   ;==>GetNearestSignpostPtrToXY

;(backwards compatibility)
;~ Description: Returns the nearest signpost to a set of coordinates. (AgentStruct)
Func GetNearestSignpostToCoords($aX, $aY)
	Local $lAgent = GetNearestSignpostPtrToXY($aX, $aY)
	Return GetAgentByID($lAgent)
EndFunc ;==>GetNearestSignpostToCoords

;~ Description: Returns pointer variable for the nearest ally to an agent.
Func GetNearestAllyPtrToAgent($aAgent = -2)
	Return GetNearestAgentPtr($aAgent, 0xDB, 1)
EndFunc   ;==>GetNearestAllyPtrToAgent
#EndRegion GetNearestAgent

;~ Description Returns the "danger level" of each party member
;~ Param1: an array returned by GetAgentArray(). This is totally optional, but can greatly improve script speed.
;~ Param2: an array returned by GetParty() This is totally optional, but can greatly improve script speed.
Func GetPartyDanger($aAgentArray = 0, $aParty = 0)
	If $aAgentArray == 0 Then $aAgentArray = GetAgentArray(0xDB)
	If $aParty == 0 Then $aParty = GetParty($aAgentArray)

	Local $lReturnArray[$aParty[0] + 1]
	$lReturnArray[0] = $aParty[0]
	For $i = 1 To $lReturnArray[0]
		$lReturnArray[$i] = 0
	Next

	For $i = 1 To $aAgentArray[0]
		If BitAND(GetAgentInfo($aAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop
		If GetAgentInfo($aAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If Not GetIsLiving($aAgentArray[$i]) Then ContinueLoop
		If GetAgentInfo($aAgentArray[$i], "Allegiance") > 3 Then ContinueLoop ; ignore NPCs, spirits, minions, pets

		For $j = 1 To $aParty[0]
			If GetTarget(GetAgentInfo($aAgentArray[$i], "ID")) == GetAgentInfo($aParty[$j], "ID") Then
				If GetDistance($aAgentArray[$i], $aParty[$j]) < 5000 Then
					If GetAgentInfo($aAgentArray[$i], "Team") <> 0 Then
						If GetAgentInfo($aAgentArray[$i], "Team") <> GetAgentInfo($aParty[$j], "Team") Then
							$lReturnArray[$j] += 1
						EndIf
					ElseIf GetAgentInfo($aAgentArray[$i], "Allegiance") <> GetAgentInfo($aParty[$j], "Allegiance") Then
						$lReturnArray[$j] += 1
					EndIf
				EndIf
			EndIf
		Next
	Next
	Return $lReturnArray
EndFunc   ;==>GetPartyDanger

;~ Description: Return the number of enemy agents targeting the given agent.
Func GetAgentDanger($aAgent, $aAgentArray = 0)
	Local $lCount = 0

	If $aAgentArray == 0 Then $aAgentArray = GetAgentArray(0xDB)

	For $i = 1 To $aAgentArray[0]
		If (GetIsDead($aAgentArray[$i] == True)) Then ContinueLoop
		If GetAgentInfo($aAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If Not GetIsLiving($aAgentArray[$i]) Then ContinueLoop
		If GetAgentInfo($aAgentArray[$i], "Allegiance") > 3 Then ContinueLoop ; ignore NPCs, spirits, minions, pets
		If GetTarget(GetAgentInfo($aAgentArray[$i], "ID")) == GetAgentInfo($aAgent, "ID") Then
			If GetDistance($aAgentArray[$i], $aAgent) < 5000 Then
				If GetAgentInfo($aAgentArray[$i], "Team") <> 0 Then
					If GetAgentInfo($aAgentArray[$i], "Team") <> GetAgentInfo($aAgent, "Team") Then
						$lCount += 1
					EndIf
				ElseIf GetAgentInfo($aAgentArray[$i], "Allegiance") <> GetAgentInfo($aAgent, "Allegiance") Then
					$lCount += 1
				EndIf
			EndIf
		EndIf
	Next
	Return $lCount
EndFunc   ;==>GetAgentDanger
#EndRegion Agent

#Region AgentInfo
; === Type ===
;~ Description: Tests if an agent is living.
Func GetIsLiving($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0xDB
EndFunc   ;==>GetIsLiving

;~ Description: Tests if an agent is a signpost/chest/etc.
Func GetIsStatic($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0x200
EndFunc   ;==>GetIsStatic

;~ Description: Tests if an agent is an item.
Func GetIsMovable($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0x400
EndFunc   ;==>GetIsMovable

;~ Description: Tests if an agent is moving.
Func GetIsMoving($aAgent = -2)
	If MoveX($aAgent) <> 0 Or MoveY($aAgent) <> 0 Then Return True
	Return False
EndFunc   ;==>GetIsMoving

;~ Description: Tests if an agent is casting.
Func GetIsCasting($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 436, "word") <> 0
EndFunc   ;==>GetIsCasting

;~ Description: Tests if an agent is knocked down.
Func GetIsKnocked($aAgent = -2)
	Return GetAgentInfo($aAgent, 'ModelState') = 0x450
EndFunc   ;==>GetIsKnocked

;~ Description: Tests if an agent is attacking.
Func GetIsAttacking($aAgent = -2)
	Switch GetAgentInfo($aAgent, 'ModelState')
		Case 0x60, 0x440, 0x460 ; Is Attacking
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>GetIsAttacking

;	=== Effects ===
;~ Description: Tests if an agent is bleeding.
Func GetIsBleeding($aAgent = -2)
	Return BitAND(GetAgentInfo($aAgent, 'Effects'), 0x0001) > 0
EndFunc   ;==>GetIsBleeding

;~ Description: Tests if an agent has a condition.
Func GetHasCondition($aAgent = -2)
	Return BitAND(GetAgentInfo($aAgent, 'Effects'), 0x0002) > 0
EndFunc   ;==>GetHasCondition

;~ Description: Tests if an agent is dead.
Func GetIsDead($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0010) > 0
EndFunc   ;==>GetIsDead

;~ Description: Tests if an agent has a deep wound.
Func GetHasDeepWound($aAgent = -2)
	Return BitAND(GetAgentInfo($aAgent, 'Effects'), 0x0020) > 0
EndFunc   ;==>GetHasDeepWound

;~ Description: Tests if an agent is poisoned.
Func GetIsPoisoned($aAgent = -2)
	Return BitAND(GetAgentInfo($aAgent, 'Effects'), 0x0040) > 0
EndFunc   ;==>GetIsPoisoned

;~ Description: Tests if an agent is enchanted.
Func GetIsEnchanted($aAgent = -2)
	Return BitAND(GetAgentInfo($aAgent, 'Effects'), 0x0080) > 0
EndFunc   ;==>GetIsEnchanted

;~ Description: Tests if an agent has a degen hex.
Func GetHasDegenHex($aAgent = -2)
	Return BitAND(GetAgentInfo($aAgent, 'Effects'), 0x0400) > 0
EndFunc   ;==>GetHasDegenHex

;~ Description: Tests if an agent is hexed.
Func GetHasHex($aAgent = -2)
	Return BitAND(GetAgentInfo($aAgent, 'Effects'), 0x0800) > 0
EndFunc   ;==>GetHasHex

;~ Description: Tests if an agent has a weapon spell.
Func GetHasWeaponSpell($aAgent = -2)
	Return BitAND(GetAgentInfo($aAgent, 'Effects'), 0x8000) > 0
EndFunc   ;==>GetHasWeaponSpell

;~ Description: Tests if an agent is a boss.
Func GetIsBoss($aAgent)
	Return BitAND(GetAgentInfo($aAgent, 'TypeMap'), 1024) > 0
EndFunc   ;==>GetIsBoss

;~ Description: Returns a player's name.
Func GetPlayerName($aAgent)
	Local $lLogin = GetAgentInfo($aAgent, 'LoginNumber')
	Local $lOffset[6] = [0, 0x18, 0x2C, 0x80C, 76 * $lLogin + 0x28, 0]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset, 'wchar[30]')
	Return $lReturn[1]
EndFunc   ;==>GetPlayerName

;~ Description: Returns the name of an agent.
Func GetAgentName($aAgent)
	Local $lAddress = $mStringLogBase + 256 * ConvertID($aAgent)
	Local $lName = MemoryRead($lAddress, 'wchar [128]')

	If $lName = '' Then
		DisplayAll(True)
		Sleep(100)
		DisplayAll(False)
	EndIf

	$lName = MemoryRead($lAddress, 'wchar [128]')
	$lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
	Return $lName
EndFunc   ;==>GetAgentName
#EndRegion AgentInfo

#Region Buff
;~ Description: Returns current number of buffs being maintained.
Func GetBuffCount($aHeroNumber = 0)
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset, 'long')
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset, 'long')
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			Return MemoryRead($lBuffer[0] + 0xC)
		EndIf
	Next
	Return 0
EndFunc   ;==>GetBuffCount

;~ Description: Tests if you are currently maintaining buff on target.
Func GetIsTargetBuffed($aSkillID, $aAgentID, $aHeroNumber = 0)
	Local $lBuffCount = GetBuffCount($aHeroNumber)
	Local $lBuffStructAddress
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer

	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x4 + 0x24 * $i
			ReDim $lOffset[6]
			For $j = 0 To $lBuffCount - 1
				$lOffset[5] = 0 + 0x10 * $j
				$lBuffStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
				DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBuffStructAddress[0], 'ptr', DllStructGetPtr($g_BuffStruct), 'int', DllStructGetSize($g_BuffStruct), 'int', '')

				If (DllStructGetData($g_BuffStruct, 'SkillID') == $aSkillID) And (DllStructGetData($g_BuffStruct, 'TargetId') == ConvertID($aAgentID)) Then
					Return $j + 1
				EndIf
			Next
		EndIf
	Next

	Return 0
EndFunc   ;==>GetIsTargetBuffed

;~ Description: Returns buff struct.
Func GetBuffByIndex($aBuffNumber, $aHeroNumber = 0)
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer

	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x4 + 0x24 * $i
			ReDim $lOffset[6]
			$lOffset[5] = 0 + 0x10 * ($aBuffNumber - 1)
			$lBuffStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBuffStructAddress[0], 'ptr', DllStructGetPtr($g_BuffStruct), 'int', DllStructGetSize($g_BuffStruct), 'int', '')

			Return $g_BuffStruct
		EndIf
	Next

	Return 0
EndFunc   ;==>GetBuffByIndex
#EndRegion Buff

#Region Skills
Func GetSkillInfo($aSkillID, $aInfo = "")
    Local $lPtr = GetSkillPtr($aSkillID)
    If $lPtr = 0 Or $aInfo = "" Then Return 0

    Switch $aInfo
        Case "SkillID"
            Return MemoryRead($lPtr, "long")
        Case "h0004"
            Return MemoryRead($lPtr + 0x4, "long")
        Case "Campaign"
            Return MemoryRead($lPtr + 0x8, "long")
        Case "SkillType"
            Return MemoryRead($lPtr + 0xC, "long")
        Case "Special"
            Return MemoryRead($lPtr + 0x10, "long")
        Case "ComboReq"
            Return MemoryRead($lPtr + 0x14, "long")
        Case "Effect1"
            Return MemoryRead($lPtr + 0x18, "long")
        Case "Condition"
            Return MemoryRead($lPtr + 0x1C, "long")
        Case "Effect2"
            Return MemoryRead($lPtr + 0x20, "long")
        Case "WeaponReq"
            Return MemoryRead($lPtr + 0x24, "long")
        Case "Profession"
            Return MemoryRead($lPtr + 0x28, "byte")
        Case "Attribute"
            Return MemoryRead($lPtr + 0x29, "byte")
        Case "Title"
            Return MemoryRead($lPtr + 0x2A, "word")
        Case "SkillIDPvP"
            Return MemoryRead($lPtr + 0x2C, "long")
        Case "Combo"
            Return MemoryRead($lPtr + 0x30, "byte")
        Case "Target"
            Return MemoryRead($lPtr + 0x31, "byte")
        Case "h0032"
            Return MemoryRead($lPtr + 0x32, "byte")
        Case "SkillEquipType"
            Return MemoryRead($lPtr + 0x33, "byte")
        Case "Overcast"
            Return MemoryRead($lPtr + 0x34, "byte")
        Case "EnergyCost"
            Return MemoryRead($lPtr + 0x35, "byte")
        Case "HealthCost"
            Return MemoryRead($lPtr + 0x36, "byte")
        Case "h0037"
            Return MemoryRead($lPtr + 0x37, "byte")
        Case "Adrenaline"
            Return MemoryRead($lPtr + 0x38, "dword")
        Case "Activation"
            Return MemoryRead($lPtr + 0x3C, "float")
        Case "Aftercast"
            Return MemoryRead($lPtr + 0x40, "float")
        Case "Duration0"
            Return MemoryRead($lPtr + 0x44, "dword")
        Case "Duration15"
            Return MemoryRead($lPtr + 0x48, "dword")
        Case "Recharge"
            Return MemoryRead($lPtr + 0x4C, "dword")
        Case "h0050"
            Return MemoryRead($lPtr + 0x50, "word")
        Case "h0052"
            Return MemoryRead($lPtr + 0x52, "word")
        Case "h0054"
            Return MemoryRead($lPtr + 0x54, "word")
        Case "h0056"
            Return MemoryRead($lPtr + 0x56, "word")
        Case "SkillArguments"
            Return MemoryRead($lPtr + 0x58, "dword")
        Case "Scale0"
            Return MemoryRead($lPtr + 0x5C, "dword")
        Case "Scale15"
            Return MemoryRead($lPtr + 0x60, "dword")
        Case "BonusScale0"
            Return MemoryRead($lPtr + 0x64, "dword")
        Case "BonusScale15"
            Return MemoryRead($lPtr + 0x68, "dword")
        Case "AoeRange"
            Return MemoryRead($lPtr + 0x6C, "float")
        Case "ConstEffect"
            Return MemoryRead($lPtr + 0x70, "float")
        Case "CasterOverheadAnimationID"
            Return MemoryRead($lPtr + 0x74, "dword")
        Case "CasterBodyAnimationID"
            Return MemoryRead($lPtr + 0x78, "dword")
        Case "TargetBodyAnimationID"
            Return MemoryRead($lPtr + 0x7C, "dword")
        Case "TargetOverheadAnimationID"
            Return MemoryRead($lPtr + 0x80, "dword")
        Case "ProjectileAnimation1ID"
            Return MemoryRead($lPtr + 0x84, "dword")
        Case "ProjectileAnimation2ID"
            Return MemoryRead($lPtr + 0x88, "dword")
        Case "IconFileID"
            Return MemoryRead($lPtr + 0x8C, "dword")
        Case "IconFileID2"
            Return MemoryRead($lPtr + 0x90, "dword")
        Case "Name"
            Return MemoryRead($lPtr + 0x94, "dword")
        Case "Concise"
            Return MemoryRead($lPtr + 0x98, "dword")
        Case "Description"
            Return MemoryRead($lPtr + 0x9C, "dword")
    EndSwitch

    Return 0
EndFunc ;==>GetSkillInfo

;~Description: Returns Skill Pointer, $aSkill should be SkillID
Func GetSkillPtr($aSkillID)
	If IsPtr($aSkillID) Then Return $aSkillID
	Local $lSkillptr = $mSkillBase + 160 * $aSkillID
	Return Ptr($lSkillptr)
EndFunc   ;==>GetSkillPtr

;~ Description: Returns skill struct.
Func GetSkillByID($aSkillID)
	Local $lSkillStructAddress = $mSkillBase + (160 * $aSkillID)

	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lSkillStructAddress, 'ptr', DllStructGetPtr($g_SkillStruct), 'int', DllStructGetSize($g_SkillStruct), 'int', '')

	Return $g_SkillStruct
EndFunc   ;==>GetSkillByID

;~ Description: Returns the pointer variable to a skillbar for specified hero number.
; #FUNCTION# ====================================================================================================================
; Name ..........: GetSkillbarPtr
; Description ...: Returns Pointer to Skillbar struct.
; Syntax ........: GetSkillbarPtr([$aHeroNumber = 0])
; Parameters ....: $aHeroNumber         - [optional] default is 0/self.
; Return values .: Pointer to Skillbar.
; ===============================================================================================================================
Func GetSkillbarPtr($aHeroNumber = 0)
	; Local $lOffset[5] = [0, 24, 76, 84, 44]
	Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
	Local $lHeroCount = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6F0]
	Local $lSkillbarStructAddress
	
	For $i = 0 To $lHeroCount[1]
		$lOffset[4] = $i * 188
		$lSkillbarStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
		If $lSkillbarStructAddress[1] = GetHeroID($aHeroNumber) Then Return $lSkillbarStructAddress[0]
	Next
EndFunc   ;==>GetSkillbarPtr

;~ Description: Returns skillbar struct.
Func GetSkillbar($aHeroNumber = 0)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6F0]
	Local $lSkillbarStructAddress

	For $i = 0 To GetHeroCount()
		$lOffset[4] = $i * 0xBC
		$lSkillbarStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lSkillbarStructAddress[0], 'ptr', DllStructGetPtr($g_SkillbarStruct), 'int', DllStructGetSize($g_SkillbarStruct), 'int', '')

		If DllStructGetData($g_SkillbarStruct, 'AgentId') = GetHeroID($aHeroNumber) Then
			Return $g_SkillbarStruct
		EndIf
	Next
EndFunc   ;==>GetSkillbar

; #FUNCTION# ====================================================================================================================
; Name ..........: UseSkill
; Description ...: Use a skill.
; Syntax ........: UseSkill($aSkillSlot[, $aTarget = -2[, $aCallTarget = False]])
; Parameters ....: $aSkillSlot          - 1 to 8
;                  $aTarget             - [optional] can be AgentID/AgentPtr/AgentStruct (default is -2/self)
;                  $aCallTarget         - [optional] Call Target (default is False)
; ===============================================================================================================================
Func UseSkill($aSkillSlot, $aTarget = -2, $aCallTarget = False)
	DllStructSetData($mUseSkill, 2, $aSkillSlot)
	DllStructSetData($mUseSkill, 3, ConvertID($aTarget))
	DllStructSetData($mUseSkill, 4, $aCallTarget)
	Enqueue($mUseSkillPtr, 16)
EndFunc ;==>UseSkill

; #FUNCTION# ====================================================================================================================
; Name ..........: UseSkillEx
; Description ...: Use a skill with more checks.
; Syntax ........: UseSkillEx($aSkillSlot[, $aTarget = -2[, $aTimeout = 3000[, $aCallTarget = False[, $aSkillbarPtr = GetSkillbarPtr()]]]])
; Parameters ....: $aSkillSlot          - 
;                  $aTarget             - [optional] Default is -2.
;                  $aTimeout            - [optional] Default is 3000.
;                  $aCallTarget         - [optional] Default is False.
;                  $aSkillbarPtr        - [optional] Default is GetSkillbarPtr(0).
; ===============================================================================================================================
Func UseSkillEx($aSkillSlot, $aTarget = -2, $aTimeout = 3000, $aCallTarget = False, $aSkillbarPtr = GetSkillbarPtr(0))
	Local $lDeadlock = TimerInit(), $lAgentID = ConvertID($aTarget), $lMe = GetAgentPtr(-2)
	Local $lSkill = GetSkillPtr(GetSkillbarSkillID($aSkillSlot, 0, $aSkillbarPtr))
	If $lAgentID = 0 Or GetIsDead($lMe) Or Not IsRecharged($aSkillSlot, $aSkillbarPtr) Then Return
	If GetEnergy($lMe) < GetEnergyReq($lSkill) Then Return
	
	If $lAgentID <> GetMyID() Then ChangeTarget($lAgentID)
	UseSkill($aSkillSlot, $lAgentID, $aCallTarget)
	Do
		Sleep(50)
		If GetIsDead($lAgentID) Or GetIsDead($lMe) Then Return		
	Until Not IsRecharged($aSkillSlot, $aSkillbarPtr) Or TimerDiff($lDeadlock) > $aTimeout
	Sleep(MemoryRead($lSkill + 64, "float") * 1000) ; Aftercast
	Return True
EndFunc ;==>UseskillEx

;~ Description: Returns energy cost of a skill.
Func GetEnergyReq($aSkillID)
	Local $lEnergycost = MemoryRead(GetSkillPtr($aSkillID) + 53, "byte")
	If $lEnergycost = 11 Then Return 15
	If $lEnergycost = 12 Then Return 25
	Return $lEnergycost
EndFunc ;==>GetEnergyReq

; #FUNCTION# ====================================================================================================================
; Name ..........: IsRecharged
; Description ...: Returns if a Skill is recharged.
; Syntax ........: IsRecharged($aSkillSlot[, $aSkillbarPtr = GetSkillbarPtr()])
; Parameters ....: $aSkillSlot          - 
;                  $aSkillbarPtr        - [optional] Default is GetSkillbarPtr(0).
; ===============================================================================================================================
Func IsRecharged($aSkillSlot, $aSkillbarPtr = GetSkillbarPtr(0))
	Return GetSkillbarSkillRecharge($aSkillSlot, 0, $aSkillbarPtr) = 0
EndFunc ;==>IsRecharged

;~ Description: Checks SkillRecharge by SkillSlot; True=Recharged
Func IsRechargedHero($aSkillSlot, $aHeroNumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
	Return GetSkillbarSkillRecharge($aSkillSlot, $aHeroNumber, $aSkillbarPtr) = 0
EndFunc ;==>IsRechargedHero

; #FUNCTION# ====================================================================================================================
; Name ..........: GetSkillbarSkillRecharge
; Description ...: Returns the recharge time remaining of an equipped skill in milliseconds.
; Syntax ........: GetSkillbarSkillRecharge($aSkillSlot[, $aHeroNumber = 0[, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber)]])
; Parameters ....: $aSkillSlot          - 
;                  $aHeroNumber         - [optional] Default is 0.
;                  $aSkillbarPtr        - [optional] Default is GetSkillbarPtr($aHeroNumber).
; ===============================================================================================================================
Func GetSkillbarSkillRecharge($aSkillSlot, $aHeroNumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
	$aSkillSlot -= 1
	Local $lTimestamp = MemoryRead($aSkillbarPtr + 12 + $aSkillSlot * 20, "dword")
	If $lTimestamp = 0 Then Return 0
	Return $lTimestamp - GetSkillTimer()
EndFunc ;==>GetSkillbarSkillRecharge

;~ Description: 
; #FUNCTION# ====================================================================================================================
; Name ..........: GetSkillbarSkillID
; Description ...: Returns the skill ID of an equipped skill.
; Syntax ........: GetSkillbarSkillID($askillslot[, $aHeronumber = 0[, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber)]])
; Parameters ....: $askillslot          - 
;                  $aHeronumber         - [optional] Default is 0.
;                  $aSkillbarPtr        - [optional] Default is GetSkillbarPtr($aHeroNumber).
; Return values .: Skill ID
; ===============================================================================================================================
Func GetSkillbarSkillID($askillslot, $aHeronumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
	$askillslot -= 1
	Return MemoryRead($aSkillbarPtr + 16 + $aSkillslot * 20, "dword")
EndFunc ;==>GetSkillbarSkillID

; #FUNCTION# ====================================================================================================================
; Name ..........: GetSkillbarSkillAdrenaline
; Description ...: Returns the adrenaline charge of an equipped skill.
; Syntax ........: GetSkillbarSkillAdrenaline($aSkillSlot[, $aHeroNumber = 0[, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber)]])
; Parameters ....: $aSkillSlot          - 
;                  $aHeroNumber         - [optional] Default is 0.
;                  $aSkillbarPtr        - [optional] Default is GetSkillbarPtr($aHeroNumber).
; Return values .: Adrenaline
; ===============================================================================================================================
Func GetSkillbarSkillAdrenaline($aSkillSlot, $aHeroNumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
	$aSkillSlot -= 1
	Return MemoryRead($aSkillbarPtr + 4 + $aSkillSlot * 20, "long")
EndFunc ;==>GetSkillbarSkillAdrenaline
#EndRegion Skills

;~ Description: Returns current morale.
Func GetMorale($aHeroNumber = 0)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x638
	Local $lIndex = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x62C
	$lOffset[4] = 8 + 0xC * BitAND($lAgentID, $lIndex[1])
	$lOffset[5] = 0x18
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1] - 100
EndFunc   ;==>GetMorale

;~ Description: Returns Attribute struct.
Func GetAttributeInfoByID($aAttributeID)
	Local $lAttributeStructAddress = $mAttributeInfo + (0x14 * $aAttributeID)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lAttributeStructAddress, 'ptr', DllStructGetPtr($g_AttributeStruct), 'int', DllStructGetSize($g_AttributeStruct), 'int', '')
	Return $g_AttributeStruct
EndFunc   ;==>GetAttributeInfoByID

Func GetAttributeProfession($aAttributeID)
	Local $lAttributeInfo = GetAttributeInfoByID($aAttributeID)
	Return DllStructGetData($lAttributeInfo, "profession_id")
EndFunc   ;==>GetAttributeProfession

Func GetAttributeNameID($aAttributeID)
	Local $lAttributeInfo = GetAttributeInfoByID($aAttributeID)
	Return DllStructGetData($lAttributeInfo, "name_id")
EndFunc   ;==>GetAttributeNameID

Func GetAttributeIsPvE($aAttributeID)
	Local $lAttributeInfo = GetAttributeInfoByID($aAttributeID)
	Return DllStructGetData($lAttributeInfo, "is_pve")
EndFunc   ;==>GetAttributeIsPvE

#Region Effects
;~ Description: Returns effect struct or array of effects.
Func GetEffect($aSkillID = 0, $aHeroNumber = 0)
	Local $lEffectCount, $lEffectStructAddress
	Local $lReturnArray[1] = [0]

	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer

	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x1C + 0x24 * $i
			$lEffectCount = MemoryReadPtr($mBasePointer, $lOffset)
			ReDim $lOffset[6]
			$lOffset[4] = 0x14 + 0x24 * $i
			$lOffset[5] = 0
			$lEffectStructAddress = MemoryReadPtr($mBasePointer, $lOffset)

			If $aSkillID = 0 Then
				ReDim $lReturnArray[$lEffectCount[1] + 1]
				$lReturnArray[0] = $lEffectCount[1]

				For $i = 0 To $lEffectCount[1] - 1
					$lReturnArray[$i + 1] = DllStructCreate('long SkillId;long AttributeLevel;long EffectId;long AgentId;float Duration;long TimeStamp')
					$lEffectStructAddress[1] = $lEffectStructAddress[0] + 0x18 * $i
					DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lEffectStructAddress[1], 'ptr', DllStructGetPtr($lReturnArray[$i + 1]), 'int', 24, 'int', '')
				Next

				ExitLoop
			Else
				For $i = 0 To $lEffectCount[1] - 1
					DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lEffectStructAddress[0] + 24 * $i, 'ptr', DllStructGetPtr($g_EffectStruct), 'int', 24, 'int', '')

					If DllStructGetData($g_EffectStruct, 'SkillID') = $aSkillID Then
						Return $g_EffectStruct
					EndIf
				Next
			EndIf
		EndIf
	Next

	Return $lReturnArray
EndFunc   ;==>GetEffect

;~ Description: Returns array of effectptr on agent.
Func GetEffectsPtr($aSkillID = 0, $aHeroNumber = 0, $aHeroId = GetHeroID($aHeroNumber))
	Local $lEffectCount, $lEffectStructAddress, $lBuffer
	Local $lAmount = 0
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x510]
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] = $aHeroId Then
			$lOffset[4] = 0x1C + 0x24 * $i
			$lEffectCount = MemoryReadPtr($mBasePointer, $lOffset)
			ReDim $lOffset[6]
			$lOffset[4] = 0x14 + 0x24 * $i
			$lOffset[5] = 0
			$lEffectStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
			If $aSkillID = 0 Then
				Local $lReturnArray[$lEffectCount[1] + 1]
				$lReturnArray[0] = $lEffectCount[1]
				For $i = 1 To $lEffectCount[1]
					$lReturnArray[$i] = Ptr($lEffectStructAddress[0] + 0x18 * ($i - 1))
				Next
				Return $lReturnArray
			Else
				Local $lReturnArray[2] = [0, 0]
				For $j = 0 To $lEffectCount[1] - 1
					$lReturn = $lEffectStructAddress[0] + 0x18 * $j
					If MemoryRead($lReturn, "long") = $aSkillID Then
						$lReturnArray[0] = 1
						$lReturnArray[1] = Ptr($lReturn)
						Return $lReturnArray
					EndIf
				Next
			EndIf
		EndIf
	Next
EndFunc   ;==>GetEffectsPtr

;~ Description: 
Func GetSkillEffectPtr($aSkillID, $aHeroNumber = 0, $aHeroId = GetHeroID($aHeroNumber))
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x510]
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] = $aHeroId Then
			$lOffset[4] = 0x1C + 0x24 * $i
			Local $lEffectCount = MemoryReadPtr($mBasePointer, $lOffset)
			$lOffset[4] = 0x14 + 0x24 * $i
			Local $lEffectStructAddress = MemoryReadPtr($mBasePointer, $lOffset, 'ptr')
			For $j = 0 To $lEffectCount[1] - 1
				Local $lEffectSkillID = MemoryRead($lEffectStructAddress[1] + 0x18 * $j, 'long')
				If $lEffectSkillID = $aSkillID Then Return Ptr($lEffectStructAddress[1] + 0x18 * $j)
			Next
		EndIf
	Next
EndFunc   ;==>GetSkillEffectPtr

;~ Description: Returns time remaining before an effect expires, in milliseconds.
Func GetEffectTimeRemaining($aEffect)
	If Not IsDllStruct($aEffect) Then $aEffect = GetEffect($aEffect)
	If IsArray($aEffect) Then Return 0
	Return DllStructGetData($aEffect, 'Duration') * 1000
;~ 	Return DllStructGetData($aEffect, 'Duration') * 1000 - (GetSkillTimer() - DllStructGetData($aEffect, 'TimeStamp'))
EndFunc   ;==>GetEffectTimeRemaining
#EndRegion Effects

;~ Description: Returns the timestamp used for effects and skills (milliseconds).
Func GetSkillTimer()
	Return MemoryRead($mSkillTimer, "long")
EndFunc   ;==>GetSkillTimer

;~ Description: Returns level of an attribute.
Func GetAttributeByID($aAttributeID, $aWithRunes = False, $aHeroNumber = 0)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Local $lBuffer
	Local $lOffset[5]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0xAC
	For $i = 0 To GetHeroCount()
		$lOffset[4] = 0x43C * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == $lAgentID Then
			If $aWithRunes Then
				$lOffset[4] = 0x43C * $i + 0x14 * $aAttributeID + 0xC
			Else
				$lOffset[4] = 0x43C * $i + 0x14 * $aAttributeID + 0x8
			EndIf
			$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
			Return $lBuffer[1]
		EndIf
	Next
EndFunc   ;==>GetAttributeByID

;~ Description: Returns amount of experience.
Func GetExperience()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x740]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetExperience

;~ Description: Tests if an area has been vanquished.
Func GetAreaVanquished()
	If GetFoesToKill() = 0 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>GetAreaVanquished

;~ Description: Returns number of foes that have been killed so far.
Func GetFoesKilled()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x84C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetFoesKilled

;~ Description: Returns number of enemies left to kill for vanquish.
Func GetFoesToKill()
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x850]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetFoesToKill

;~ Description: Returns current ping.
Func GetPing()
	Return MemoryRead($mPing)
EndFunc   ;==>GetPing

;~ Description: Returns current map ID.
Func GetMapID()
	Local $lOffset[4] = [0, 0x18, 0x44, 0x22C]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
;~ 	Return MemoryRead($mMapID)
EndFunc   ;==>GetMapID

;~ Description: Returns current load-state.
;~ Func GetMapLoading()
;~ 	Return MemoryRead($mMapLoading)
;~ EndFunc   ;==>GetInstanceType

Func GetInstanceType()
	Local $lOffset[1] = [0x4]
	Local $lResult = MemoryReadPtr($mInstanceInfo, $lOffset, "dword")
	Return $lResult[1]
EndFunc   ;==>GetInstanceType

Func GetAreaInfoByID($aMapID = 0)
	If $aMapID = 0 Then $aMapID = GetMapID()

	Local $lAreaInfoAddress = $mAreaInfo + (0x7C * $aMapID)
	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lAreaInfoAddress, 'ptr', DllStructGetPtr($g_AreaInfoStruct), 'int', DllStructGetSize($g_AreaInfoStruct), 'int', '')

	Return $g_AreaInfoStruct
EndFunc   ;==>GetAreaInfoByID

Func GetMapCampaign($aMapID = 0)
	Local $lMapStruct = GetAreaInfoByID($aMapID)
	Return DllStructGetData($lMapStruct, "campaign")
EndFunc   ;==>GetMapCampaign

Func GetMapRegion($aMapID = 0)
	Local $lMapStruct = GetAreaInfoByID($aMapID)
	Return DllStructGetData($lMapStruct, "region")
EndFunc   ;==>GetMapRegion

Func GetMapRegionType($aMapID = 0)
	Local $lMapStruct = GetAreaInfoByID($aMapID)
	Return DllStructGetData($lMapStruct, "regiontype")
EndFunc   ;==>GetMapRegionType

;~ Description: Returns if map has been loaded. Reset with InitMapLoad().
Func GetMapIsLoaded()
;~ 	Return MemoryRead($mMapIsLoaded) And GetAgentExists(-2)
	Return GetAgentExists(-2)
EndFunc   ;==>GetMapIsLoaded

;~ Description: Returns current district
Func GetDistrict()
	Local $lOffset[4] = [0, 0x18, 0x44, 0x220]
	Local $lResult = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lResult[1]
EndFunc   ;==>GetDistrict

;~ Description: Internal use for travel functions.
Func GetRegion()
	Return MemoryRead($mRegion)
EndFunc   ;==>GetRegion

;~ Description: Internal use for travel functions.
Func GetLanguage()
	Local $lOffset[] = [0, 0x18, 0x44, 0x228]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
;~ 	Return MemoryRead($mLanguage)
EndFunc   ;==>GetLanguage

;~ Description: Returns quest struct.
Func GetQuestByID($aQuestID = 0)
	Local $lQuestPtr, $lQuestLogSize, $lQuestID
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x534]

	$lQuestLogSize = MemoryReadPtr($mBasePointer, $lOffset)

	If $aQuestID = 0 Then
		$lOffset[1] = 0x18
		$lOffset[2] = 0x2C
		$lOffset[3] = 0x528
		$lQuestID = MemoryReadPtr($mBasePointer, $lOffset)
		$lQuestID = $lQuestID[1]
	Else
		$lQuestID = $aQuestID
	EndIf

	Local $lOffset[5] = [0, 0x18, 0x2C, 0x52C, 0]
	For $i = 0 To $lQuestLogSize[1]
		$lOffset[4] = 0x34 * $i
		$lQuestPtr = MemoryReadPtr($mBasePointer, $lOffset)
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lQuestPtr[0], 'ptr', DllStructGetPtr($g_QuestStruct), 'int', DllStructGetSize($g_QuestStruct), 'int', '')
		If DllStructGetData($g_QuestStruct, 'ID') = $lQuestID Then Return $g_QuestStruct
	Next
EndFunc   ;==>GetQuestByID

;~ Description: Returns your characters name.
Func GetCharname()
	Return MemoryRead($mCharname, 'wchar[30]')
EndFunc   ;==>GetCharname

;~ Description: Returns if you're logged in.
Func GetLoggedIn()
	Return MemoryRead($mLoggedIn)
EndFunc   ;==>GetLoggedIn

;Currently uncommented since i dont know if it works
;~ Description: Returns the number of character slots you have. Only works on character select.
;~Func GetCharacterSlots()
;~	Return MemoryRead($mCharslots)
;~EndFunc   ;==>GetLoggedIn

;~ Description: Returns language currently being used.
Func GetDisplayLanguage()
	Local $lOffset[6] = [0, 0x18, 0x18, 0x194, 0x4C, 0x40]
	Local $lResult = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lResult[1]
EndFunc   ;==>GetDisplayLanguage

;~ Returns how long the current instance has been active, in milliseconds.
Func GetInstanceUpTime()
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x8
	$lOffset[3] = 0x1AC
	Local $lTimer = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lTimer[1]
EndFunc   ;==>GetInstanceUpTime

;~ Returns the game client's build number
Func GetBuildNumber()
	Return $mBuildNumber
EndFunc   ;==>GetBuildNumber

Func GetProfPrimaryAttribute($aProfession)
	Switch $aProfession
		Case 1
			Return 17
		Case 2
			Return 23
		Case 3
			Return 16
		Case 4
			Return 6
		Case 5
			Return 0
		Case 6
			Return 12
		Case 7
			Return 35
		Case 8
			Return 36
		Case 9
			Return 40
		Case 10
			Return 44
	EndSwitch
EndFunc   ;==>GetProfPrimaryAttribute
#EndRegion Queries

#Region Other Functions
#Region Misc
;~ Description: Sleep a random amount of time.
Func RndSleep($aAmount, $aRandom = 0.05)
	Local $lRandom = $aAmount * $aRandom
	Sleep(Random($aAmount - $lRandom, $aAmount + $lRandom))
EndFunc   ;==>RndSleep

;~ Description: Sleep a period of time, plus or minus a tolerance
Func TolSleep($aAmount = 150, $aTolerance = 50)
	Sleep(Random($aAmount - $aTolerance, $aAmount + $aTolerance))
EndFunc   ;==>TolSleep

Func Pingsleep($msExtra = 0)
	Sleep(GetPing() + $msExtra)
EndFunc   ;==>Pingsleep

;~ Description: Returns window handle of Guild Wars.
Func GetWindowHandle()
	Return $mGWWindowHandle
EndFunc   ;==>GetWindowHandle

Func InviteGuild($charName)
	If GetAgentExists(-2) Then
		DllStructSetData($mInviteGuild, 1, GetValue('CommandPacketSend'))
		DllStructSetData($mInviteGuild, 2, 0x4C)
		DllStructSetData($mInviteGuild, 3, 0xBC)
		DllStructSetData($mInviteGuild, 4, 0x01)
		DllStructSetData($mInviteGuild, 5, $charName)
		DllStructSetData($mInviteGuild, 6, 0x02)
		Enqueue(DllStructGetPtr($mInviteGuild), DllStructGetSize($mInviteGuild))
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>InviteGuild

Func InviteGuest($charName)
	If GetAgentExists(-2) Then
		DllStructSetData($mInviteGuild, 1, GetValue('CommandPacketSend'))
		DllStructSetData($mInviteGuild, 2, 0x4C)
		DllStructSetData($mInviteGuild, 3, 0xBC)
		DllStructSetData($mInviteGuild, 4, 0x01)
		DllStructSetData($mInviteGuild, 5, $charName)
		DllStructSetData($mInviteGuild, 6, 0x01)
		Enqueue(DllStructGetPtr($mInviteGuild), DllStructGetSize($mInviteGuild))
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>InviteGuest

;~ Description: Internal use only.
Func SendPacket($aSize, $aHeader, $aParam1 = 0, $aParam2 = 0, $aParam3 = 0, $aParam4 = 0, $aParam5 = 0, $aParam6 = 0, $aParam7 = 0, $aParam8 = 0, $aParam9 = 0, $aParam10 = 0)
	;If GetAgentExists(-2) Then
	DllStructSetData($mPacket, 2, $aSize)
	DllStructSetData($mPacket, 3, $aHeader)
	DllStructSetData($mPacket, 4, $aParam1)
	DllStructSetData($mPacket, 5, $aParam2)
	DllStructSetData($mPacket, 6, $aParam3)
	DllStructSetData($mPacket, 7, $aParam4)
	DllStructSetData($mPacket, 8, $aParam5)
	DllStructSetData($mPacket, 9, $aParam6)
	DllStructSetData($mPacket, 10, $aParam7)
	DllStructSetData($mPacket, 11, $aParam8)
	DllStructSetData($mPacket, 12, $aParam9)
	DllStructSetData($mPacket, 13, $aParam10)
	Enqueue($mPacketPtr, 52)
	Return True
	;Else
	;	Return False
	;EndIf
EndFunc   ;==>SendPacket

;~ Description: Internal use only.
Func PerformAction($aAction, $aFlag)
	If GetAgentExists(-2) Then
		DllStructSetData($mAction, 2, $aAction)
		DllStructSetData($mAction, 3, $aFlag)
		Enqueue($mActionPtr, 12)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>PerformAction

;~ Description: Internal use only.
Func Bin64ToDec($aBinary)
	Local $lReturn = 0

	For $i = 1 To StringLen($aBinary)
		If StringMid($aBinary, $i, 1) == 1 Then $lReturn += 2 ^ ($i - 1)
	Next

	Return $lReturn
EndFunc   ;==>Bin64ToDec

;~ Description: Internal use only.
Func Base64ToBin64($aCharacter)
	Select
		Case $aCharacter == 'A'
			Return '000000'
		Case $aCharacter == 'B'
			Return '100000'
		Case $aCharacter == 'C'
			Return '010000'
		Case $aCharacter == 'D'
			Return '110000'
		Case $aCharacter == 'E'
			Return '001000'
		Case $aCharacter == 'F'
			Return '101000'
		Case $aCharacter == 'G'
			Return '011000'
		Case $aCharacter == 'H'
			Return '111000'
		Case $aCharacter == 'I'
			Return '000100'
		Case $aCharacter == 'J'
			Return '100100'
		Case $aCharacter == 'K'
			Return '010100'
		Case $aCharacter == 'L'
			Return '110100'
		Case $aCharacter == 'M'
			Return '001100'
		Case $aCharacter == 'N'
			Return '101100'
		Case $aCharacter == 'O'
			Return '011100'
		Case $aCharacter == 'P'
			Return '111100'
		Case $aCharacter == 'Q'
			Return '000010'
		Case $aCharacter == 'R'
			Return '100010'
		Case $aCharacter == 'S'
			Return '010010'
		Case $aCharacter == 'T'
			Return '110010'
		Case $aCharacter == 'U'
			Return '001010'
		Case $aCharacter == 'V'
			Return '101010'
		Case $aCharacter == 'W'
			Return '011010'
		Case $aCharacter == 'X'
			Return '111010'
		Case $aCharacter == 'Y'
			Return '000110'
		Case $aCharacter == 'Z'
			Return '100110'
		Case $aCharacter == 'a'
			Return '010110'
		Case $aCharacter == 'b'
			Return '110110'
		Case $aCharacter == 'c'
			Return '001110'
		Case $aCharacter == 'd'
			Return '101110'
		Case $aCharacter == 'e'
			Return '011110'
		Case $aCharacter == 'f'
			Return '111110'
		Case $aCharacter == 'g'
			Return '000001'
		Case $aCharacter == 'h'
			Return '100001'
		Case $aCharacter == 'i'
			Return '010001'
		Case $aCharacter == 'j'
			Return '110001'
		Case $aCharacter == 'k'
			Return '001001'
		Case $aCharacter == 'l'
			Return '101001'
		Case $aCharacter == 'm'
			Return '011001'
		Case $aCharacter == 'n'
			Return '111001'
		Case $aCharacter == 'o'
			Return '000101'
		Case $aCharacter == 'p'
			Return '100101'
		Case $aCharacter == 'q'
			Return '010101'
		Case $aCharacter == 'r'
			Return '110101'
		Case $aCharacter == 's'
			Return '001101'
		Case $aCharacter == 't'
			Return '101101'
		Case $aCharacter == 'u'
			Return '011101'
		Case $aCharacter == 'v'
			Return '111101'
		Case $aCharacter == 'w'
			Return '000011'
		Case $aCharacter == 'x'
			Return '100011'
		Case $aCharacter == 'y'
			Return '010011'
		Case $aCharacter == 'z'
			Return '110011'
		Case $aCharacter == '0'
			Return '001011'
		Case $aCharacter == '1'
			Return '101011'
		Case $aCharacter == '2'
			Return '011011'
		Case $aCharacter == '3'
			Return '111011'
		Case $aCharacter == '4'
			Return '000111'
		Case $aCharacter == '5'
			Return '100111'
		Case $aCharacter == '6'
			Return '010111'
		Case $aCharacter == '7'
			Return '110111'
		Case $aCharacter == '8'
			Return '001111'
		Case $aCharacter == '9'
			Return '101111'
		Case $aCharacter == '+'
			Return '011111'
		Case $aCharacter == '/'
			Return '111111'
	EndSelect
EndFunc   ;==>Base64ToBin64

#EndRegion Misc

#Region Callback
;~ Description: Controls Event System.
Func SetEvent($aSkillActivate = '', $aSkillCancel = '', $aSkillComplete = '', $aChatReceive = '', $aLoadFinished = '')
	If Not $mUseEventSystem Then Return
	If $aSkillActivate <> '' Then
		WriteDetour('SkillLogStart', 'SkillLogProc')
	Else
		$mASMString = ''
		_('inc eax')
		_('mov dword[esi+10],eax')
		_('pop esi')
		WriteBinary($mASMString, GetValue('SkillLogStart'))
	EndIf

	If $aSkillCancel <> '' Then
		WriteDetour('SkillCancelLogStart', 'SkillCancelLogProc')
	Else
		$mASMString = ''
		_('push 0')
		_('push 42')
		_('mov ecx,esi')
		WriteBinary($mASMString, GetValue('SkillCancelLogStart'))
	EndIf

	If $aSkillComplete <> '' Then
		WriteDetour('SkillCompleteLogStart', 'SkillCompleteLogProc')
	Else
		$mASMString = ''
		_('mov eax,dword[edi+4]')
		_('test eax,eax')
		WriteBinary($mASMString, GetValue('SkillCompleteLogStart'))
	EndIf

	If $aChatReceive <> '' Then
		WriteDetour('ChatLogStart', 'ChatLogProc')
	Else
		$mASMString = ''
		_('add edi,E')
		_('cmp eax,B')
		WriteBinary($mASMString, GetValue('ChatLogStart'))
	EndIf

	$mSkillActivate = $aSkillActivate
	$mSkillCancel = $aSkillCancel
	$mSkillComplete = $aSkillComplete
	$mChatReceive = $aChatReceive
	$mLoadFinished = $aLoadFinished
EndFunc   ;==>SetEvent

;~ Description: Internal use for event system.
Func Event($hWnd, $msg, $wparam, $lparam)
	; Initial check for skill-related events to avoid unnecessary DllCalls for chat events
	If $lparam >= 0x1 And $lparam <= 0x3 Then
		Local $skillLogStruct = DllStructCreate("int skillID;int param1;int param2;int param3")
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', DllStructGetPtr($skillLogStruct), 'int', 16, 'int', '')
		HandleSkillEvent($lparam, $skillLogStruct)
		;DllStructDelete($skillLogStruct) ; Clean up
	ElseIf $lparam == 0x4 Then
		Local $chatLogStruct = DllStructCreate("int messageType;char message[512]")
		DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $wparam, 'ptr', DllStructGetPtr($chatLogStruct), 'int', 512, 'int', '')
		ProcessChatMessage($chatLogStruct)
		;DllStructDelete($chatLogStruct) ; Clean up
	ElseIf $lparam == 0x5 Then
		;Call($mLoadFinished)
	EndIf
EndFunc   ;==>Event

Func HandleSkillEvent($eventType, $skillLogStruct)
	Local $skillID = DllStructGetData($skillLogStruct, 1)
	Local $param1 = DllStructGetData($skillLogStruct, 2)
	Local $param2 = DllStructGetData($skillLogStruct, 3)
	Local $param3 = DllStructGetData($skillLogStruct, 4) ; Only used for activation

;~ Switch $eventType
;~ 	Case 0x1
;~ 		Call($mSkillActivate, $skillID, $param1, $param2, $param3)
;~ 	Case 0x2
;~ 		Call($mSkillCancel, $skillID, $param1, $param2)
;~ 	Case 0x3
;~ 		Call($mSkillComplete, $skillID, $param1, $param2)
;~ EndSwitch
EndFunc   ;==>HandleSkillEvent

Func ProcessChatMessage($chatLogStruct)
	Local $messageType = DllStructGetData($chatLogStruct, 1)
	Local $message = DllStructGetData($chatLogStruct, "message[512]")
	Local $channel = "Unknown"
	Local $sender = "Unknown"

	Switch $messageType
		Case 0 ; Alliance
			$channel = "Alliance"
		Case 3 ; All
			$channel = "All"
		Case 9 ; Guild
			$channel = "Guild"
		Case 11 ; Team
			$channel = "Team"
		Case 12 ; Trade
			$channel = "Trade"
		Case 10 ; Sent or Global
			If StringLeft($message, 3) == "-> " Then
				$channel = "Sent"
			Else
				$channel = "Global"
				$sender = "Guild Wars"
			EndIf
		Case 13 ; Advisory
			$channel = "Advisory"
			$sender = "Guild Wars"
		Case 14 ; Whisper
			$channel = "Whisper"
		Case Else
			$channel = "Other"
			$sender = "Other"
	EndSwitch

	If $channel <> "Global" And $channel <> "Advisory" And $channel <> "Other" Then
		$sender = StringMid($message, 6, StringInStr($message, "</a>") - 6)
		$message = StringTrimLeft($message, StringInStr($message, "<quote>") + 6)
	EndIf

	If $channel == "Sent" Then
		$sender = StringMid($message, 10, StringInStr($message, "</a>") - 10)
		$message = StringTrimLeft($message, StringInStr($message, "<quote>") + 6)
	EndIf

	;Call($mChatReceive, $channel, $sender, $message)
EndFunc   ;==>ProcessChatMessage
#EndRegion Callback

#Region Modification
;~ Description: Internal use only.
Func ModifyMemory()
	$mASMSize = 0
	$mASMCodeOffset = 0
	$mASMString = ''
	CreateData()
	CreateMain()
;~ 	CreateTargetLog()
;~ 	CreateSkillLog()
;~ 	CreateSkillCancelLog()
;~ 	CreateSkillCompleteLog()
;~ 	CreateChatLog()
	CreateTraderHook()
;~ 	CreateLoadFinished()
	CreateStringLog()
;~ 	CreateStringFilter1()
;~ 	CreateStringFilter2()
	CreateRenderingMod()
	CreateCommands()
	CreateDialogHook()
	$mMemory = MemoryRead(MemoryRead($mBase), 'ptr')

	Switch $mMemory
		Case 0
			$mMemory = DllCall($mKernelHandle, 'ptr', 'VirtualAllocEx', 'handle', $mGWProcHandle, 'ptr', 0, 'ulong_ptr', $mASMSize, 'dword', 0x1000, 'dword', 64)
			$mMemory = $mMemory[0]
			MemoryWrite(MemoryRead($mBase), $mMemory)
;~ 			MsgBox(1,1,$mASMString)
			CompleteASMCode()
			WriteBinary($mASMString, $mMemory + $mASMCodeOffset)
			$SecondInject = $mMemory + $mASMCodeOffset
;~ 			MsgBox(1,1,$mASMString)
;~ 			WriteBinary('83F8009090', GetValue('ClickToMoveFix'))
			MemoryWrite(GetValue('QueuePtr'), GetValue('QueueBase'))
;~ 			MemoryWrite(GetValue('SkillLogPtr'), GetValue('SkillLogBase'))
;~ 			MemoryWrite(GetValue('ChatRevAdr'), GetValue('ChatRevBase'))
;~ 			MemoryWrite(GetValue('ChatLogPtr'), GetValue('ChatLogBase'))
;~ 			MemoryWrite(GetValue('StringLogPtr'), GetValue('StringLogBase'))
		Case Else
			CompleteASMCode()
	EndSwitch
	WriteDetour('MainStart', 'MainProc')
	WriteDetour('TargetLogStart', 'TargetLogProc')
	WriteDetour('TraderHookStart', 'TraderHookProc')
	WriteDetour('LoadFinishedStart', 'LoadFinishedProc')
	WriteDetour('RenderingMod', 'RenderingModProc')
;~ 	WriteDetour('StringLogStart', 'StringLogProc')
;~ 	WriteDetour('StringFilter1Start', 'StringFilter1Proc')
;~ 	WriteDetour('StringFilter2Start', 'StringFilter2Proc')
	WriteDetour('DialogLogStart', 'DialogLogProc')
EndFunc   ;==>ModifyMemory

;~ Description: Internal use only.
Func WriteDetour($aFrom, $aTo)
	WriteBinary('E9' & SwapEndian(Hex(GetLabelInfo($aTo) - GetLabelInfo($aFrom) - 5)), GetLabelInfo($aFrom))
EndFunc   ;==>WriteDetour

;~ Description: Internal use only.
Func CreateData()
	_('CallbackHandle/4')
	_('QueueCounter/4')
	_('SkillLogCounter/4')
	_('ChatLogCounter/4')
	_('ChatLogLastMsg/4')
	_('MapIsLoaded/4')
	_('NextStringType/4')
	_('EnsureEnglish/4')
	_('TraderQuoteID/4')
	_('TraderCostID/4')
	_('TraderCostValue/4')
	_('DisableRendering/4')

	_('QueueBase/' & 256 * GetValue('QueueSize'))
	_('TargetLogBase/' & 4 * GetValue('TargetLogSize'))
	_('SkillLogBase/' & 16 * GetValue('SkillLogSize'))
	_('StringLogBase/' & 256 * GetValue('StringLogSize'))
	_('ChatLogBase/' & 512 * GetValue('ChatLogSize'))

	_('LastDialogID/4')

	_('AgentCopyCount/4')
	_('AgentCopyBase/' & 0x1C0 * 256)
EndFunc   ;==>CreateData

;~ Description: Internal use only.
Func CreateMain()
	_('MainProc:')
	_('nop x')
	_('pushad')
	_('mov eax,dword[EnsureEnglish]')
	_('test eax,eax')
	_('jz MainMain')
	_('mov ecx,dword[BasePointer]')
	_('mov ecx,dword[ecx+18]')
	_('mov ecx,dword[ecx+18]')
	_('mov ecx,dword[ecx+194]')
	_('mov al,byte[ecx+4f]')
	_('cmp al,f')
	_('ja MainMain')
	_('mov ecx,dword[ecx+4c]')
	_('mov al,byte[ecx+3f]')
	_('cmp al,f')
	_('ja MainMain')
	_('mov eax,dword[ecx+40]')
	_('test eax,eax')
	_('jz MainMain')

	_('MainMain:')
	_('mov eax,dword[QueueCounter]')
	_('mov ecx,eax')
	_('shl eax,8')
	_('add eax,QueueBase')
	_('mov ebx,dword[eax]')
	_('test ebx,ebx')

	_('jz MainExit')
	_('push ecx')
	_('mov dword[eax],0')
	_('jmp ebx')
	_('CommandReturn:')
	_('pop eax')
	_('inc eax')
	_('cmp eax,QueueSize')
	_('jnz MainSkipReset')
	_('xor eax,eax')
	_('MainSkipReset:')
	_('mov dword[QueueCounter],eax')
	_('MainExit:')
	_('popad')

	_('mov ebp,esp')
	_('fld st(0),dword[ebp+8]')

	_('ljmp MainReturn')
EndFunc   ;==>CreateMain

;~ Description: Internal use only.
Func CreateTargetLog()
	_('TargetLogProc:')
	_('cmp ecx,4')
	_('jz TargetLogMain')
	_('cmp ecx,32')
	_('jz TargetLogMain')
	_('cmp ecx,3C')
	_('jz TargetLogMain')
	_('jmp TargetLogExit')

	_('TargetLogMain:')
	_('pushad')
	_('mov ecx,dword[ebp+8]')
	_('test ecx,ecx')
	_('jnz TargetLogStore')
	_('mov ecx,edx')

	_('TargetLogStore:')
	_('lea eax,dword[edx*4+TargetLogBase]')
	_('mov dword[eax],ecx')
	_('popad')

	_('TargetLogExit:')
	_('push ebx')
	_('push esi')
	_('push edi')
	_('mov edi,edx')
	_('ljmp TargetLogReturn')
EndFunc   ;==>CreateTargetLog

;~ Description: Internal use only.
Func CreateSkillLog()
	_('SkillLogProc:')
	_('pushad')

	_('mov eax,dword[SkillLogCounter]')
	_('push eax')
	_('shl eax,4')
	_('add eax,SkillLogBase')

	_('mov ecx,dword[edi]')
	_('mov dword[eax],ecx')
	_('mov ecx,dword[ecx*4+TargetLogBase]')
	_('mov dword[eax+4],ecx')
	_('mov ecx,dword[edi+4]')
	_('mov dword[eax+8],ecx')
	_('mov ecx,dword[edi+8]')
	_('mov dword[eax+c],ecx')

	_('push 1')
	_('push eax')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('pop eax')
	_('inc eax')
	_('cmp eax,SkillLogSize')
	_('jnz SkillLogSkipReset')
	_('xor eax,eax')
	_('SkillLogSkipReset:')
	_('mov dword[SkillLogCounter],eax')

	_('popad')
	_('inc eax')
	_('mov dword[esi+10],eax')
	_('pop esi')
	_('ljmp SkillLogReturn')
EndFunc   ;==>CreateSkillLog

;~ Description: Internal use only.
Func CreateSkillCancelLog()
	_('SkillCancelLogProc:')
	_('pushad')

	_('mov eax,dword[SkillLogCounter]')
	_('push eax')
	_('shl eax,4')
	_('add eax,SkillLogBase')

	_('mov ecx,dword[edi]')
	_('mov dword[eax],ecx')
	_('mov ecx,dword[ecx*4+TargetLogBase]')
	_('mov dword[eax+4],ecx')
	_('mov ecx,dword[edi+4]')
	_('mov dword[eax+8],ecx')

	_('push 2')
	_('push eax')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('pop eax')
	_('inc eax')
	_('cmp eax,SkillLogSize')
	_('jnz SkillCancelLogSkipReset')
	_('xor eax,eax')
	_('SkillCancelLogSkipReset:')
	_('mov dword[SkillLogCounter],eax')

	_('popad')
	_('push 0')
	_('push 48')
	_('mov ecx,esi')
	_('ljmp SkillCancelLogReturn')
EndFunc   ;==>CreateSkillCancelLog

;~ Description: Internal use only.
Func CreateSkillCompleteLog()
	_('SkillCompleteLogProc:')
	_('pushad')

	_('mov eax,dword[SkillLogCounter]')
	_('push eax')
	_('shl eax,4')
	_('add eax,SkillLogBase')

	_('mov ecx,dword[edi]')
	_('mov dword[eax],ecx')
	_('mov ecx,dword[ecx*4+TargetLogBase]')
	_('mov dword[eax+4],ecx')
	_('mov ecx,dword[edi+4]')
	_('mov dword[eax+8],ecx')

	_('push 3')
	_('push eax')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('pop eax')
	_('inc eax')
	_('cmp eax,SkillLogSize')
	_('jnz SkillCompleteLogSkipReset')
	_('xor eax,eax')
	_('SkillCompleteLogSkipReset:')
	_('mov dword[SkillLogCounter],eax')

	_('popad')
	_('mov eax,dword[edi+4]')
	_('test eax,eax')
	_('ljmp SkillCompleteLogReturn')
EndFunc   ;==>CreateSkillCompleteLog

;~ Description: Internal use only.
Func CreateChatLog()
	_('ChatLogProc:')

	_('pushad')
	_('mov ecx,dword[esp+1F4]')
	_('mov ebx,eax')
	_('mov eax,dword[ChatLogCounter]')
	_('push eax')
	_('shl eax,9')
	_('add eax,ChatLogBase')
	_('mov dword[eax],ebx')

	_('mov edi,eax')
	_('add eax,4')
	_('xor ebx,ebx')

	_('ChatLogCopyLoop:')
	_('mov dx,word[ecx]')
	_('mov word[eax],dx')
	_('add ecx,2')
	_('add eax,2')
	_('inc ebx')
	_('cmp ebx,FF')
	_('jz ChatLogCopyExit')
	_('test dx,dx')
	_('jnz ChatLogCopyLoop')

	_('ChatLogCopyExit:')
	_('push 4')
	_('push edi')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('pop eax')
	_('inc eax')
	_('cmp eax,ChatLogSize')
	_('jnz ChatLogSkipReset')
	_('xor eax,eax')
	_('ChatLogSkipReset:')
	_('mov dword[ChatLogCounter],eax')
	_('popad')

	_('ChatLogExit:')
	_('add edi,E')
	_('cmp eax,B')
	_('ljmp ChatLogReturn')
EndFunc   ;==>CreateChatLog

;~ Description: Internal use only.
Func CreateTraderHook()
	_('TraderHookProc:')
	_('push eax')
	_('mov eax,dword[ebx+28] -> 8b 43 28')
	_('mov eax,[eax] -> 8b 00')
	_('mov dword[TraderCostID],eax')
	_('mov eax,dword[ebx+28] -> 8b 43 28')
	_('mov eax,[eax+4] -> 8b 40 04')
	_('mov dword[TraderCostValue],eax')
	_('pop eax')
	_('mov ebx,dword[ebp+C] -> 8B 5D 0C')
	_('mov esi,eax')
	_('push eax')
	_('mov eax,dword[TraderQuoteID]')
	_('inc eax')
	_('cmp eax,200')
	_('jnz TraderSkipReset')
	_('xor eax,eax')
	_('TraderSkipReset:')
	_('mov dword[TraderQuoteID],eax')
	_('pop eax')
	_('ljmp TraderHookReturn')
EndFunc   ;==>CreateTraderHook

;~ Description: Internal use only.
Func CreateDialogHook()
	_('DialogLogProc:')
	_('push ecx')
	_('mov ecx,esp')
	_('add ecx,C')
	_('mov ecx,dword[ecx]')
	_('mov dword[LastDialogID],ecx')
	_('pop ecx')
	_('mov ebp,esp')
	_('sub esp,8')
	_('ljmp DialogLogReturn')
EndFunc   ;==>CreateDialogHook

;~ Description: Internal use only.
Func CreateLoadFinished()
	_('LoadFinishedProc:')
	_('pushad')

	_('mov eax,1')
	_('mov dword[MapIsLoaded],eax')

	_('xor ebx,ebx')
	_('mov eax,StringLogBase')
	_('LoadClearStringsLoop:')
	_('mov dword[eax],0')
	_('inc ebx')
	_('add eax,100')
	_('cmp ebx,StringLogSize')
	_('jnz LoadClearStringsLoop')

	_('xor ebx,ebx')
	_('mov eax,TargetLogBase')
	_('LoadClearTargetsLoop:')
	_('mov dword[eax],0')
	_('inc ebx')
	_('add eax,4')
	_('cmp ebx,TargetLogSize')
	_('jnz LoadClearTargetsLoop')

	_('push 5')
	_('push 0')
	_('push CallbackEvent')
	_('push dword[CallbackHandle]')
	_('call dword[PostMessage]')

	_('popad')
	_('mov edx,dword[esi+1C]')
	_('mov ecx,edi')
	_('ljmp LoadFinishedReturn')
EndFunc   ;==>CreateLoadFinished

;~ Description: Internal use only.
Func CreateStringLog()
	_('StringLogProc:')
	_('pushad')
	_('mov eax,dword[NextStringType]')
	_('test eax,eax')
	_('jz StringLogExit')

	_('cmp eax,1')
	_('jnz StringLogFilter2')
	_('mov eax,dword[ebp+37c]')
	_('jmp StringLogRangeCheck')

	_('StringLogFilter2:')
	_('cmp eax,2')
	_('jnz StringLogExit')
	_('mov eax,dword[ebp+338]')

	_('StringLogRangeCheck:')
	_('mov dword[NextStringType],0')
	_('cmp eax,0')
	_('jbe StringLogExit')
	_('cmp eax,StringLogSize')
	_('jae StringLogExit')

	_('shl eax,8')
	_('add eax,StringLogBase')

	_('xor ebx,ebx')
	_('StringLogCopyLoop:')
	_('mov dx,word[ecx]')
	_('mov word[eax],dx')
	_('add ecx,2')
	_('add eax,2')
	_('inc ebx')
	_('cmp ebx,80')
	_('jz StringLogExit')
	_('test dx,dx')
	_('jnz StringLogCopyLoop')

	_('StringLogExit:')
	_('popad')
	_('mov esp,ebp')
	_('pop ebp')
	_('retn 10')
EndFunc   ;==>CreateStringLog

;~ Description: Internal use only.
Func CreateStringFilter1()
	_('StringFilter1Proc:')
	_('mov dword[NextStringType],1')

	_('push ebp')
	_('mov ebp,esp')
	_('push ecx')
	_('push esi')
	_('ljmp StringFilter1Return')
EndFunc   ;==>CreateStringFilter1

;~ Description: Internal use only.
Func CreateStringFilter2()
	_('StringFilter2Proc:')
	_('mov dword[NextStringType],2')

	_('push ebp')
	_('mov ebp,esp')
	_('push ecx')
	_('push esi')
	_('ljmp StringFilter2Return')
EndFunc   ;==>CreateStringFilter2

;~ Description: Internal use only.
Func CreateRenderingMod()
;~ 	_('RenderingModProc:')
;~ 	_('cmp dword[DisableRendering],1')
;~ 	_('jz RenderingModSkipCompare')
;~ 	_('cmp eax,ebx')
;~ 	_('ljne RenderingModReturn')
;~ 	_('RenderingModSkipCompare:')

;~ 	$mASMSize += 17
;~ 	$mASMString &= StringTrimLeft(MemoryRead(GetValue("RenderingMod") + 4, "byte[17]"), 2)

;~ 	_('cmp dword[DisableRendering],1')
;~ 	_('jz DisableRenderingProc')
;~ 	_('retn')

;~ 	_('DisableRenderingProc:')
;~ 	_('push 1')
;~ 	_('call dword[Sleep]')
;~ 	_('retn')

	_("RenderingModProc:")
	_("add esp,4")
	_("cmp dword[DisableRendering],1")
	_("ljmp RenderingModReturn")
EndFunc   ;==>CreateRenderingMod

;~ Description: Internal use only.
Func CreateCommands()
	_('CommandUseSkill:')
	_('mov ecx,dword[eax+C]')
	_('push ecx')
	_('mov ebx,dword[eax+8]')
	_('push ebx')
	_('mov edx,dword[eax+4]')
	_('dec edx')
	_('push edx')
	_('mov eax,dword[MyID]')
	_('push eax')
	_('call UseSkillFunction')
	_('pop eax')
	_('pop edx')
	_('pop ebx')
	_('pop ecx')
	_('ljmp CommandReturn')

	_('CommandMove:')
	_('lea eax,dword[eax+4]')
	_('push eax')
	_('call MoveFunction')
	_('pop eax')
	_('ljmp CommandReturn')

	_("CommandChangeTarget:")
	_("xor edx,edx")
	_("push edx")
	_("mov eax,dword[eax+4]")
	_("push eax")
	_("call ChangeTargetFunction")
	_("pop eax")
	_("pop edx")
	_("ljmp CommandReturn")

	_('CommandPacketSend:')
	_('lea edx,dword[eax+8]')
	_('push edx')
	_('mov ebx,dword[eax+4]')
	_('push ebx')
	;_('push edx')
	;_('push ebx')
	_('mov eax,dword[PacketLocation]')
	_('push eax')
	_('call PacketSendFunction')
	_('pop eax')
	_('pop ebx')
	_('pop edx')
	_('ljmp CommandReturn')

	_('CommandChangeStatus:')
	_('mov eax,dword[eax+4]')
	_('push eax')
	_('call ChangeStatusFunction')
	_('pop eax')
	_('ljmp CommandReturn')

	_("CommandWriteChat:")
	_("push 0")    ; new from April update
	_("add eax,4")
	_("push eax")
	_("call WriteChatFunction")
	_("add esp,8")                ; was _('pop eax') before April change
	_("ljmp CommandReturn")

	_('CommandSellItem:')
	_('mov esi,eax')
	_('add esi,C')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push dword[eax+4]')
	_('push 0')
	_('add eax,8')
	_('push eax')
	_('push 1')
	_('push 0')
	_('push B')
	_('call TransactionFunction')
	_('add esp,24')
	_('ljmp CommandReturn')

	_('CommandBuyItem:')
	_('mov esi,eax')
	_('add esi,10') ;01239A20
	_('mov ecx,eax')
	_('add ecx,4')
	_('push ecx')
	_('mov edx,eax')
	_('add edx,8')
	_('push edx')
	_('push 1')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('mov eax,dword[eax+C]')
	_('push eax')
	_('push 1')
	_('call TransactionFunction')
	_('add esp,24')
	_('ljmp CommandReturn')

	_('CommandCraftItemEx:')
	_('add eax,4')
	_('push eax')
	_('add eax,4')
	_('push eax')
	_('push 1')
	_('push 0')
	_('push 0')
	_('mov ecx,dword[TradeID]')
	_('mov ecx,dword[ecx]')
	;_('mov ebx,dword[ecx+148]')
	_('mov edx,dword[eax+4]')
	;_('mov ecx,dword[ecx+edx]')
	;_('lea ecx,dword[ecx+ecx*2]')
	_('lea ecx,dword[ebx+ecx*4]')
	_('push ecx')
	_('push 1')
	_('push dword[eax+8]')
	_('push dword[eax+C]')
	_('call TraderFunction')
	_('add esp,24')
	_('mov dword[TraderCostID],0')
	_('ljmp CommandReturn')

	_("CommandAction:")
	_("mov ecx,dword[ActionBase]")
	_("mov ecx,dword[ecx+c]")    ; was _("mov ecx,dword[ecx+!]")
	_("add ecx,A0")
	_("push 0")
	_("add eax,4")
	_("push eax")
	_("push dword[eax+4]")
	_("mov edx,0")
	_("call ActionFunction")
	_("ljmp CommandReturn")

	_('CommandUseHeroSkill:')
	_('mov ecx,dword[eax+8]')
	_('push ecx')
	_('mov ecx,dword[eax+c]')
	_('push ecx')
	_('mov ecx,dword[eax+4]')
	_('push ecx')
	_('call UseHeroSkillFunction')
	_('add esp,C')
	_('ljmp CommandReturn')

;~ 	_('CommandToggleLanguage:')
;~ 	_('mov ecx,dword[ActionBase]')
;~ 	_('mov ecx,dword[ecx+170]')
;~ 	_('mov ecx,dword[ecx+20]')
;~ 	_('mov ecx,dword[ecx]')
;~ 	_('push 0')
;~ 	_('push 0')
;~ 	_('push bb')
;~ 	_('mov edx,esp')
;~ 	_('push 0')
;~ 	_('push edx')
;~ 	_('push dword[eax+4]')
;~ 	_('call ActionFunction')
;~ 	_('pop eax')
;~ 	_('pop ebx')
;~ 	_('pop ecx')
;~ 	_('ljmp CommandReturn')

	_('CommandSendChat:')
	_('lea edx,dword[eax+4]')
	_('push edx')
	_('mov ebx,11c')
	_('push ebx')
	_('mov eax,dword[PacketLocation]')
	_('push eax')
	_('call PacketSendFunction')
	_('pop eax')
	_('pop ebx')
	_('pop edx')
	_('ljmp CommandReturn')

	_('CommandRequestQuote:')
	_('mov dword[TraderCostID],0')
	_('mov dword[TraderCostValue],0')
	_('mov esi,eax')
	_('add esi,4')
	_('push esi')
	_('push 1')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push C')
	_('mov ecx,0')
	_('mov edx,2')
	_('call RequestQuoteFunction')
	_('add esp,20')
	_('ljmp CommandReturn')

	_('CommandRequestQuoteSell:')
	_('mov dword[TraderCostID],0')
	_('mov dword[TraderCostValue],0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('add eax,4')
	_('push eax')
	_('push 1')
	_('push 0')
	_('push 0')
	_('push D')
	_('xor edx,edx')
	_('call RequestQuoteFunction')
	_('add esp,20')
	_('ljmp CommandReturn')

	_('CommandTraderBuy:')
	_('push 0')
	_('push TraderCostID')
	_('push 1')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push 0')
	_('mov edx,dword[TraderCostValue]')
	_('push edx')
	_('push C')
	_('mov ecx,C')
	_('call TraderFunction')
	_('add esp,24')
	_('mov dword[TraderCostID],0')
	_('mov dword[TraderCostValue],0')
	_('ljmp CommandReturn')

	_('CommandTraderSell:')
	_('push 0')
	_('push 0')
	_('push 0')
	_('push dword[TraderCostValue]')
	_('push 0')
	_('push TraderCostID')
	_('push 1')
	_('push 0')
	_('push D')
	_('mov ecx,d')
	_('xor edx,edx')
	_('call TransactionFunction')  ; 	_('call TraderFunction')
	_('add esp,24')
	_('mov dword[TraderCostID],0')
	_('mov dword[TraderCostValue],0')
	_('ljmp CommandReturn')

	_('CommandSalvage:')
	_('push eax')
	_('push ecx')
	_('push ebx')
	_('mov ebx,SalvageGlobal')
	_('mov ecx,dword[eax+4]')
	_('mov dword[ebx],ecx')
	_('add ebx,4')
	_('mov ecx,dword[eax+8]')
	_('mov dword[ebx],ecx')
	_('mov ebx,dword[eax+4]')
	_('push ebx')
	_('mov ebx,dword[eax+8]')
	_('push ebx')
	_('mov ebx,dword[eax+c]')
	_('push ebx')
	_('call SalvageFunction')
	_('add esp,C')
	_('pop ebx')
	_('pop ecx')
	_('pop eax')
	_('ljmp CommandReturn')

	_("CommandCraftItemEx2:")    ; this was added
	_("add eax,4")
	_("push eax")
	_("add eax,4")
	_("push eax")
	_("push 1")
	_("push 0")
	_("push 0")
	_("mov ecx,dword[TradeID]")
	_("mov ecx,dword[ecx]")
	;_("mov ebx,dword[ecx+148]")
	_("mov edx,dword[eax+8]")
	;_("mov ecx,dword[ecx+edx]")
	;_("lea ecx,dword[ecx+ecx*2]")
	_("lea ecx,dword[ebx+ecx*4]")
	_("mov ecx,dword[ecx]")
	_("mov [eax+8],ecx")
	_("mov ecx,dword[TradeID]")
	_("mov ecx,dword[ecx]")
	_("mov ecx,dword[ecx+0xF4]")
	_("lea ecx,dword[ecx+ecx*2]")
	_("lea ecx,dword[ebx+ecx*4]")
	_("mov ecx,dword[ecx]")
	_("mov [eax+C],ecx")
	_("mov ecx,eax")
	_("add ecx,8")
	_("push ecx")
	_("push 2")
	_("push dword[eax+4]")
	_("push 3")
	_("call TransactionFunction")
	_("add esp,24")
	_("mov dword[TraderCostID],0")
	_("ljmp CommandReturn")

	_('CommandIncreaseAttribute:')
	_('mov edx,dword[eax+4]')
	_('push edx')
	_('mov ecx,dword[eax+8]')
	_('push ecx')
	_('call IncreaseAttributeFunction')
	_('pop ecx')
	_('pop edx')
	_('ljmp CommandReturn')

	_('CommandDecreaseAttribute:')
	_('mov edx,dword[eax+4]')
	_('push edx')
	_('mov ecx,dword[eax+8]')
	_('push ecx')
	_('call DecreaseAttributeFunction')
	_('pop ecx')
	_('pop edx')
	_('ljmp CommandReturn')

	_('CommandMakeAgentArray:')
	_('mov eax,dword[eax+4]')
	_('xor ebx,ebx')
	_('xor edx,edx')
	_('mov edi,AgentCopyBase')

	_('AgentCopyLoopStart:')
	_('inc ebx')
	_('cmp ebx,dword[MaxAgents]')
	_('jge AgentCopyLoopExit')

	_('mov esi,dword[AgentBase]')
	_('lea esi,dword[esi+ebx*4]')
	_('mov esi,dword[esi]')
	_('test esi,esi')
	_('jz AgentCopyLoopStart')

	_('cmp eax,0')
	_('jz CopyAgent')
	_('cmp eax,dword[esi+9C]')
	_('jnz AgentCopyLoopStart')

	_('CopyAgent:')
	_('mov ecx,1C0')
	_('clc')
	_('repe movsb')
	_('inc edx')
	_('jmp AgentCopyLoopStart')
	_('AgentCopyLoopExit:')
	_('mov dword[AgentCopyCount],edx')
	_('ljmp CommandReturn')

	_('CommandSendChatPartySearch:')
	_('lea edx,dword[eax+4]')
	_('push edx')
	_('mov ebx,4C')
	_('push ebx')
	_('mov eax,dword[PacketLocation]')
	_('push eax')
	_('call PacketSendFunction')
	_('pop eax')
	_('pop ebx')
	_('pop edx')
	_('ljmp CommandReturn')
EndFunc   ;==>CreateCommands
#EndRegion Modification

#Region Online Status
;~ Description: Change online status. 0 = Offline, 1 = Online, 2 = Do not disturb, 3 = Away
Func SetPlayerStatus($iStatus)
	If (($iStatus >= 0 And $iStatus <= 3) And (GetPlayerStatus() <> $iStatus)) Then
		DllStructSetData($mChangeStatus, 2, $iStatus)

		Enqueue($mChangeStatusPtr, 8)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SetPlayerStatus

Func GetPlayerStatus()
	Return MemoryRead($mCurrentStatus)
EndFunc   ;==>GetPlayerStatus
#EndRegion Online Status

#Region Assembler
Func _($aASM)
	Local $lBuffer
	Local $lOpCode
	Select
		Case StringInStr($aASM, ' -> ')
			Local $split = StringSplit($aASM, ' -> ', 1)
			$lOpCode = StringReplace($split[2], ' ', '')
			$mASMSize += 0.5 * StringLen($lOpCode)
			$mASMString &= $lOpCode
		Case StringLeft($aASM, 3) = 'jb '
			$mASMSize += 2
			$mASMString &= '72(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
		Case StringLeft($aASM, 3) = 'je '
			$mASMSize += 2
			$mASMString &= '74(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
		Case StringRegExp($aASM, 'cmp ebx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 6
			$mASMString &= '81FB[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'cmp edx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 6
			$mASMString &= '81FA[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRight($aASM, 1) = ':'
			SetValue('Label_' & StringLeft($aASM, StringLen($aASM) - 1), $mASMSize)
		Case StringInStr($aASM, '/') > 0
			SetValue('Label_' & StringLeft($aASM, StringInStr($aASM, '/') - 1), $mASMSize)
			Local $lOffset = StringRight($aASM, StringLen($aASM) - StringInStr($aASM, '/'))
			$mASMSize += $lOffset
			$mASMCodeOffset += $lOffset
		Case StringLeft($aASM, 5) = 'nop x'
			$lBuffer = Int(Number(StringTrimLeft($aASM, 5)))
			$mASMSize += $lBuffer
			For $i = 1 To $lBuffer
				$mASMString &= '90'
			Next
		Case StringLeft($aASM, 5) = 'ljmp '
			$mASMSize += 5
			$mASMString &= 'E9{' & StringRight($aASM, StringLen($aASM) - 5) & '}'
		Case StringLeft($aASM, 5) = 'ljne '
			$mASMSize += 6
			$mASMString &= '0F85{' & StringRight($aASM, StringLen($aASM) - 5) & '}'
		Case StringLeft($aASM, 4) = 'jmp ' And StringLen($aASM) > 7
			$mASMSize += 2
			$mASMString &= 'EB(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 4) = 'jae '
			$mASMSize += 2
			$mASMString &= '73(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 3) = 'jz '
			$mASMSize += 2
			$mASMString &= '74(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
		Case StringLeft($aASM, 4) = 'jnz '
			$mASMSize += 2
			$mASMString &= '75(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 4) = 'jbe '
			$mASMSize += 2
			$mASMString &= '76(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 3) = 'ja '
			$mASMSize += 2
			$mASMString &= '77(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
		Case StringLeft($aASM, 3) = 'jl '
			$mASMSize += 2
			$mASMString &= '7C(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
		Case StringLeft($aASM, 4) = 'jge '
			$mASMSize += 2
			$mASMString &= '7D(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringLeft($aASM, 4) = 'jle '
			$mASMSize += 2
			$mASMString &= '7E(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
		Case StringRegExp($aASM, 'mov eax,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 5
			$mASMString &= 'A1[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov ebx,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B1D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov ecx,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B0D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov edx,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B15[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov esi,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B35[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov edi,dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= '8B3D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'cmp ebx,dword\[[a-z,A-Z]{4,}\]')
			$mASMSize += 6
			$mASMString &= '3B1D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'lea eax,dword[[]ecx[*]8[+][a-z,A-Z]{4,}[]]')
			$mASMSize += 7
			$mASMString &= '8D04CD[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
		Case StringRegExp($aASM, 'lea edi,dword\[edx\+[a-z,A-Z]{4,}\]')
			$mASMSize += 7
			$mASMString &= '8D3C15[' & StringMid($aASM, 19, StringLen($aASM) - 19) & ']'
		Case StringRegExp($aASM, 'cmp dword[[][a-z,A-Z]{4,}[]],[-[:xdigit:]]')
			$lBuffer = StringInStr($aASM, ',')
			$lBuffer = ASMNumber(StringMid($aASM, $lBuffer + 1), True)
			If @extended Then
				$mASMSize += 7
				$mASMString &= '833D[' & StringMid($aASM, 11, StringInStr($aASM, ',') - 12) & ']' & $lBuffer
			Else
				$mASMSize += 10
				$mASMString &= '813D[' & StringMid($aASM, 11, StringInStr($aASM, ',') - 12) & ']' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'cmp ecx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 6
			$mASMString &= '81F9[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'cmp ebx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 6
			$mASMString &= '81FB[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'cmp eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= '3D[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'add eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= '05[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'B8[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov ebx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'BB[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov ecx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'B9[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov esi,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'BE[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov edi,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'BF[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov edx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			$mASMSize += 5
			$mASMString &= 'BA[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
		Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],ecx')
			$mASMSize += 6
			$mASMString &= '890D[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'fstp dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= 'D91D[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
		Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],edx')
			$mASMSize += 6
			$mASMString &= '8915[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],eax')
			$mASMSize += 5
			$mASMString &= 'A3[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
		Case StringRegExp($aASM, 'lea eax,dword[[]edx[*]4[+][a-z,A-Z]{4,}[]]')
			$mASMSize += 7
			$mASMString &= '8D0495[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
		Case StringRegExp($aASM, 'mov eax,dword[[]ecx[*]4[+][a-z,A-Z]{4,}[]]')
			$mASMSize += 7
			$mASMString &= '8B048D[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
		Case StringRegExp($aASM, 'mov ecx,dword[[]ecx[*]4[+][a-z,A-Z]{4,}[]]')
			$mASMSize += 7
			$mASMString &= '8B0C8D[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
		Case StringRegExp($aASM, 'push dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= 'FF35[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
		Case StringRegExp($aASM, 'push [a-z,A-Z]{4,}\z')
			$mASMSize += 5
			$mASMString &= '68[' & StringMid($aASM, 6, StringLen($aASM) - 5) & ']'
		Case StringRegExp($aASM, 'call dword[[][a-z,A-Z]{4,}[]]')
			$mASMSize += 6
			$mASMString &= 'FF15[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
		Case StringLeft($aASM, 5) = 'call ' And StringLen($aASM) > 8
			$mASMSize += 5
			$mASMString &= 'E8{' & StringMid($aASM, 6, StringLen($aASM) - 5) & '}'
		Case StringRegExp($aASM, 'mov dword\[[a-z,A-Z]{4,}\],[-[:xdigit:]]{1,8}\z')
			$lBuffer = StringInStr($aASM, ',')
			$mASMSize += 10
			$mASMString &= 'C705[' & StringMid($aASM, 11, $lBuffer - 12) & ']' & ASMNumber(StringMid($aASM, $lBuffer + 1))
		Case StringRegExp($aASM, 'push [-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 6), True)
			If @extended Then
				$mASMSize += 2
				$mASMString &= '6A' & $lBuffer
			Else
				$mASMSize += 5
				$mASMString &= '68' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'mov eax,[-[:xdigit:]]{1,8}\z')
			$mASMSize += 5
			$mASMString &= 'B8' & ASMNumber(StringMid($aASM, 9))
		Case StringRegExp($aASM, 'mov ebx,[-[:xdigit:]]{1,8}\z')
			$mASMSize += 5
			$mASMString &= 'BB' & ASMNumber(StringMid($aASM, 9))
		Case StringRegExp($aASM, 'mov ecx,[-[:xdigit:]]{1,8}\z')
			$mASMSize += 5
			$mASMString &= 'B9' & ASMNumber(StringMid($aASM, 9))
		Case StringRegExp($aASM, 'mov edx,[-[:xdigit:]]{1,8}\z')
			$mASMSize += 5
			$mASMString &= 'BA' & ASMNumber(StringMid($aASM, 9))
		Case StringRegExp($aASM, 'add eax,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C0' & $lBuffer
			Else
				$mASMSize += 5
				$mASMString &= '05' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add ebx,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C3' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C3' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add ecx,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C1' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C1' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add edx,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C2' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C2' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add edi,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C7' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C7' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add esi,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C6' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C6' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'add esp,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83C4' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81C4' & $lBuffer
			EndIf
		Case StringRegExp($aASM, 'cmp ebx,[-[:xdigit:]]{1,8}\z')
			$lBuffer = ASMNumber(StringMid($aASM, 9), True)
			If @extended Then
				$mASMSize += 3
				$mASMString &= '83FB' & $lBuffer
			Else
				$mASMSize += 6
				$mASMString &= '81FB' & $lBuffer
			EndIf
		Case StringLeft($aASM, 8) = 'cmp ecx,' And StringLen($aASM) > 10
			Local $lOpCode = '81F9' & StringMid($aASM, 9)
			$mASMSize += 0.5 * StringLen($lOpCode)
			$mASMString &= $lOpCode
		Case Else
			Local $lOpCode
			Switch $aASM
				Case 'Flag_'
					$lOpCode = '9090903434'
				Case 'nop'
					$lOpCode = '90'
				Case 'pushad'
					$lOpCode = '60'
				Case 'popad'
					$lOpCode = '61'
				Case 'mov ebx,dword[eax]'
					$lOpCode = '8B18'
				Case 'mov ebx,dword[ecx]'            ; added
					$lOpCode = '8B19'                ; added
				Case 'mov ecx,dword[ebx+ecx]'        ; added
					$lOpCode = '8B0C0B'                ; added
				Case 'test eax,eax'
					$lOpCode = '85C0'
				Case 'test ebx,ebx'
					$lOpCode = '85DB'
				Case 'test ecx,ecx'
					$lOpCode = '85C9'
				Case 'mov dword[eax],0'
					$lOpCode = 'C70000000000'
				Case 'push eax'
					$lOpCode = '50'
				Case 'push ebx'
					$lOpCode = '53'
				Case 'push ecx'
					$lOpCode = '51'
				Case 'push edx'
					$lOpCode = '52'
				Case 'push ebp'
					$lOpCode = '55'
				Case 'push esi'
					$lOpCode = '56'
				Case 'push edi'
					$lOpCode = '57'
				Case 'jmp ebx'
					$lOpCode = 'FFE3'
				Case 'pop eax'
					$lOpCode = '58'
				Case 'pop ebx'
					$lOpCode = '5B'
				Case 'pop edx'
					$lOpCode = '5A'
				Case 'pop ecx'
					$lOpCode = '59'
				Case 'pop esi'
					$lOpCode = '5E'
				Case 'inc eax'
					$lOpCode = '40'
				Case 'inc ecx'
					$lOpCode = '41'
				Case 'inc ebx'
					$lOpCode = '43'
				Case 'dec edx'
					$lOpCode = '4A'
				Case 'mov edi,edx'
					$lOpCode = '8BFA'
				Case 'mov ecx,esi'
					$lOpCode = '8BCE'
				Case 'mov ecx,edi'
					$lOpCode = '8BCF'
				Case 'mov ecx,esp'
					$lOpCode = '8BCC'
				Case 'xor eax,eax'
					$lOpCode = '33C0'
				Case 'xor ecx,ecx'
					$lOpCode = '33C9'
				Case 'xor edx,edx'
					$lOpCode = '33D2'
				Case 'xor ebx,ebx'
					$lOpCode = '33DB'
				Case 'mov edx,eax'
					$lOpCode = '8BD0'
				Case 'mov edx,ecx'
					$lOpCode = '8BD1'
				Case 'mov ebp,esp'
					$lOpCode = '8BEC'
				Case 'sub esp,8'
					$lOpCode = '83EC08'
				Case 'sub esi,4'
					$lOpCode = '83EE04'
				Case 'sub esp,14'
					$lOpCode = '83EC14'
				Case 'sub eax,C'
					$lOpCode = '83E80C'
				Case 'cmp ecx,4'
					$lOpCode = '83F904'
				Case 'cmp ecx,32'
					$lOpCode = '83F932'
				Case 'cmp ecx,3C'
					$lOpCode = '83F93C'
				Case 'mov ecx,edx'
					$lOpCode = '8BCA'
				Case 'mov eax,ecx'
					$lOpCode = '8BC1'
				Case 'mov ecx,dword[ebp+8]'
					$lOpCode = '8B4D08'
				Case 'mov ecx,dword[esp+1F4]'
					$lOpCode = '8B8C24F4010000'
				Case 'mov ecx,dword[edi+4]'
					$lOpCode = '8B4F04'
				Case 'mov ecx,dword[edi+8]'
					$lOpCode = '8B4F08'
				Case 'mov eax,dword[edi+4]'
					$lOpCode = '8B4704'
				Case 'mov dword[eax+4],ecx'
					$lOpCode = '894804'
				Case 'mov dword[eax+8],ebx'
					$lOpCode = '895808'
				Case 'mov dword[eax+8],ecx'
					$lOpCode = '894808'
				Case 'mov dword[eax+C],ecx'
					$lOpCode = '89480C'
				Case 'mov dword[esi+10],eax'
					$lOpCode = '894610'
				Case 'mov ecx,dword[edi]'
					$lOpCode = '8B0F'
				Case 'mov dword[eax],ecx'
					$lOpCode = '8908'
				Case 'mov dword[eax],ebx'
					$lOpCode = '8918'
				Case 'mov edx,dword[eax+4]'
					$lOpCode = '8B5004'
				Case 'mov edx,dword[eax+8]'
					$lOpCode = '8B5008'
				Case 'mov edx,dword[eax+c]'
					$lOpCode = '8B500C'
				Case 'mov edx,dword[esi+1c]'
					$lOpCode = '8B561C'
				Case 'push dword[eax+8]'
					$lOpCode = 'FF7008'
				Case 'lea eax,dword[eax+18]'
					$lOpCode = '8D4018'
				Case 'lea ecx,dword[eax+4]'
					$lOpCode = '8D4804'
				Case 'lea ecx,dword[eax+C]'
					$lOpCode = '8D480C'
				Case 'lea eax,dword[eax+4]'
					$lOpCode = '8D4004'
				Case 'lea edx,dword[eax]'
					$lOpCode = '8D10'
				Case 'lea edx,dword[eax+4]'
					$lOpCode = '8D5004'
				Case 'lea edx,dword[eax+8]'
					$lOpCode = '8D5008'
				Case 'mov ecx,dword[eax+4]'
					$lOpCode = '8B4804'
				Case 'mov esi,dword[eax+4]'
					$lOpCode = '8B7004'
				Case 'mov esp,dword[eax+4]'
					$lOpCode = '8B6004'
				Case 'mov ecx,dword[eax+8]'
					$lOpCode = '8B4808'
				Case 'mov eax,dword[eax+8]'
					$lOpCode = '8B4008'
				Case 'mov eax,dword[eax+C]'
					$lOpCode = '8B400C'
				Case 'mov ebx,dword[eax+4]'
					$lOpCode = '8B5804'
				Case 'mov ebx,dword[eax]'
					$lOpCode = '8B10'
				Case 'mov ebx,dword[eax+8]'
					$lOpCode = '8B5808'
				Case 'mov ebx,dword[eax+C]'
					$lOpCode = '8B580C'
				Case 'mov ebx,dword[ecx+148]'
					$lOpCode = '8B9948010000'
				Case 'mov ecx,dword[ebx+13C]'
					$lOpCode = '8B9B3C010000'
				Case 'mov ebx,dword[ebx+F0]'
					$lOpCode = '8B9BF0000000'
				Case 'mov ecx,dword[eax+C]'
					$lOpCode = '8B480C'
				Case 'mov ecx,dword[eax+10]'
					$lOpCode = '8B4810'
				Case 'mov eax,dword[eax+4]'
					$lOpCode = '8B4004'
				Case 'push dword[eax+4]'
					$lOpCode = 'FF7004'
				Case 'push dword[eax+c]'
					$lOpCode = 'FF700C'
				Case 'mov esp,ebp'
					$lOpCode = '8BE5'
				Case 'mov esp,ebp'
					$lOpCode = '8BE5'
				Case 'pop ebp'
					$lOpCode = '5D'
				Case 'retn 10'
					$lOpCode = 'C21000'
				Case 'cmp eax,2'
					$lOpCode = '83F802'
				Case 'cmp eax,0'
					$lOpCode = '83F800'
				Case 'cmp eax,B'
					$lOpCode = '83F80B'
				Case 'cmp eax,200'
					$lOpCode = '3D00020000'
				Case 'shl eax,4'
					$lOpCode = 'C1E004'
				Case 'shl eax,8'
					$lOpCode = 'C1E008'
				Case 'shl eax,6'
					$lOpCode = 'C1E006'
				Case 'shl eax,7'
					$lOpCode = 'C1E007'
				Case 'shl eax,8'
					$lOpCode = 'C1E008'
				Case 'shl eax,9'
					$lOpCode = 'C1E009'
				Case 'mov edi,eax'
					$lOpCode = '8BF8'
				Case 'mov dx,word[ecx]'
					$lOpCode = '668B11'
				Case 'mov dx,word[edx]'
					$lOpCode = '668B12'
				Case 'mov word[eax],dx'
					$lOpCode = '668910'
				Case 'test dx,dx'
					$lOpCode = '6685D2'
				Case 'cmp word[edx],0'
					$lOpCode = '66833A00'
				Case 'cmp eax,ebx'
					$lOpCode = '3BC3'
				Case 'cmp eax,ecx'
					$lOpCode = '3BC1'
				Case 'mov eax,dword[esi+8]'
					$lOpCode = '8B4608'
				Case 'mov ecx,dword[eax]'
					$lOpCode = '8B08'
				Case 'mov ebx,edi'
					$lOpCode = '8BDF'
				Case 'mov ebx,eax'
					$lOpCode = '8BD8'
				Case 'mov eax,edi'
					$lOpCode = '8BC7'
				Case 'mov al,byte[ebx]'
					$lOpCode = '8A03'
				Case 'test al,al'
					$lOpCode = '84C0'
				Case 'mov eax,dword[ecx]'
					$lOpCode = '8B01'
				Case 'lea ecx,dword[eax+180]'
					$lOpCode = '8D8880010000'
				Case 'mov ebx,dword[ecx+14]'
					$lOpCode = '8B5914'
				Case 'mov eax,dword[ebx+c]'
					$lOpCode = '8B430C'
				Case 'mov ecx,eax'
					$lOpCode = '8BC8'
				Case 'cmp eax,-1'
					$lOpCode = '83F8FF'
				Case 'mov al,byte[ecx]'
					$lOpCode = '8A01'
				Case 'mov ebx,dword[edx]'
					$lOpCode = '8B1A'
				Case 'lea edi,dword[edx+ebx]'
					$lOpCode = '8D3C1A'
				Case 'mov ah,byte[edi]'
					$lOpCode = '8A27'
				Case 'cmp al,ah'
					$lOpCode = '3AC4'
				Case 'mov dword[edx],0'
					$lOpCode = 'C70200000000'
				Case 'mov dword[ebx],ecx'
					$lOpCode = '890B'
				Case 'cmp edx,esi'
					$lOpCode = '3BD6'
				Case 'cmp ecx,1050000'
					$lOpCode = '81F900000501'
				Case 'mov edi,dword[edx+4]'
					$lOpCode = '8B7A04'
				Case 'mov edi,dword[eax+4]'
					$lOpCode = '8B7804'
				Case $aASM = 'mov ecx,dword[E1D684]'
					$lOpCode = '8B0D84D6E100'
				Case $aASM = 'mov dword[edx-0x70],ecx'
					$lOpCode = '894A90'
				Case $aASM = 'mov ecx,dword[edx+0x1C]'
					$lOpCode = '8B4A1C'
				Case $aASM = 'mov dword[edx+0x54],ecx'
					$lOpCode = '894A54'
				Case $aASM = 'mov ecx,dword[edx+4]'
					$lOpCode = '8B4A04'
				Case $aASM = 'mov dword[edx-0x14],ecx'
					$lOpCode = '894AEC'
				Case 'cmp ebx,edi'
					$lOpCode = '3BDF'
				Case 'mov dword[edx],ebx'
					$lOpCode = '891A'
				Case 'lea edi,dword[edx+8]'
					$lOpCode = '8D7A08'
				Case 'mov dword[edi],ecx'
					$lOpCode = '890F'
				Case 'retn'
					$lOpCode = 'C3'
				Case 'mov dword[edx],-1'
					$lOpCode = 'C702FFFFFFFF'
				Case 'cmp eax,1'
					$lOpCode = '83F801'
				Case 'mov eax,dword[ebp+37c]'
					$lOpCode = '8B857C030000'
				Case 'mov eax,dword[ebp+338]'
					$lOpCode = '8B8538030000'
				Case 'mov ecx,dword[ebx+250]'
					$lOpCode = '8B8B50020000'
				Case 'mov ecx,dword[ebx+194]'
					$lOpCode = '8B8B94010000'
				Case 'mov ecx,dword[ebx+18]'
					$lOpCode = '8B5918'
				Case 'mov ecx,dword[ebx+40]'
					$lOpCode = '8B5940'
				Case 'mov ebx,dword[ecx+10]'
					$lOpCode = '8B5910'
				Case 'mov ebx,dword[ecx+18]'
					$lOpCode = '8B5918'
				Case 'mov ebx,dword[ecx+4c]'
					$lOpCode = '8B594C'
				Case 'mov ecx,dword[ebx]'
					$lOpCode = '8B0B'
				Case 'mov edx,esp'
					$lOpCode = '8BD4'
				Case 'mov ecx,dword[ebx+170]'
					$lOpCode = '8B8B70010000'
				Case 'cmp eax,dword[esi+9C]'
					$lOpCode = '3B869C000000'
				Case 'mov ebx,dword[ecx+20]'
					$lOpCode = '8B5920'
				Case 'mov ecx,dword[ecx]'
					$lOpCode = '8B09'
				Case 'mov eax,dword[ecx+40]'
					$lOpCode = '8B4140'
				Case 'mov ecx,dword[ecx+4]'
					$lOpCode = '8B4904'
					;			Case 'mov ecx,dword[ecx+Ñ]'		; Removed following April update
					;				$lOpCode = '8B490C'			; Removed following April update
				Case 'mov ecx,dword[ecx+8]'
					$lOpCode = '8B4908'
				Case 'mov ecx,dword[ecx+34]'
					$lOpCode = '8B4934'
				Case 'mov ecx,dword[ecx+C]'
					$lOpCode = '8B490C'
				Case 'mov ecx,dword[ecx+10]'
					$lOpCode = '8B4910'
				Case 'mov ecx,dword[ecx+18]'
					$lOpCode = '8B4918'
				Case 'mov ecx,dword[ecx+20]'
					$lOpCode = '8B4920'
				Case 'mov ecx,dword[ecx+4c]'
					$lOpCode = '8B494C'
				Case 'mov ecx,dword[ecx+50]'
					$lOpCode = '8B4950'
				Case 'mov ecx,dword[ecx+148]'    ; this was added following April update
					$lOpCode = '8B8948010000'    ; this was added following April update
				Case 'mov ecx,dword[ecx+170]'
					$lOpCode = '8B8970010000'
				Case 'mov ecx,dword[ecx+194]'
					$lOpCode = '8B8994010000'
				Case 'mov ecx,dword[ecx+250]'
					$lOpCode = '8B8950020000'
				Case 'mov ecx,dword[ecx+134]'
					$lOpCode = '8B8934010000'
				Case 'mov ecx,dword[ecx+13C]'
					$lOpCode = '8B893C010000'
				Case 'mov al,byte[ecx+4f]'
					$lOpCode = '8A414F'
				Case 'mov al,byte[ecx+3f]'
					$lOpCode = '8A413F'
				Case 'cmp al,f'
					$lOpCode = '3C0F'
				Case 'lea esi,dword[esi+ebx*4]'
					$lOpCode = '8D349E'
				Case 'mov esi,dword[esi]'
					$lOpCode = '8B36'
				Case 'test esi,esi'
					$lOpCode = '85F6'
				Case 'clc'
					$lOpCode = 'F8'
				Case 'repe movsb'
					$lOpCode = 'F3A4'
				Case 'inc edx'
					$lOpCode = '42'
				Case 'mov eax,dword[ebp+8]'
					$lOpCode = '8B4508'
				Case 'mov eax,dword[ecx+8]'
					$lOpCode = '8B4108'
				Case 'test al,1'
					$lOpCode = 'A801'
				Case $aASM = 'mov eax,[eax+2C]'
					$lOpCode = '8B402C'
				Case $aASM = 'mov eax,[eax+680]'
					$lOpCode = '8B8080060000'
				Case $aASM = 'fld st(0),dword[ebp+8]'
					$lOpCode = 'D94508'
				Case 'mov esi,eax'
					$lOpCode = '8BF0'
				Case 'mov edx,dword[ecx]'
					$lOpCode = '8B11'
				Case 'mov dword[eax],edx'
					$lOpCode = '8910'
				Case 'test edx,edx'
					$lOpCode = '85D2'
				Case 'mov dword[eax],F'
					$lOpCode = 'C7000F000000'
				Case 'mov ebx,[ebx+0]'
					$lOpCode = '8B1B'
				Case 'mov ebx,[ebx+AC]'
					$lOpCode = '8B9BAC000000'
				Case 'mov ebx,[ebx+C]'
					$lOpCode = '8B5B0C'
				Case 'mov eax,dword[ebx+28]'
					$lOpCode = '8B4328'
				Case 'mov eax,[eax]'
					$lOpCode = '8B00'
				Case 'mov eax,[eax+4]'
					$lOpCode = '8B4004'
				Case 'mov ebx,dword[ebp+C]'
					$lOpCode = '8B5D0C'
				Case 'add ebx,ecx'
					$lOpCode = '03D9'
				Case 'lea ecx,dword[ecx+ecx*2]'
					$lOpCode = '8D0C49'
				Case 'lea ecx,dword[ebx+ecx*4]'
					$lOpCode = '8D0C8B'
				Case 'lea ecx,dword[ecx+18]'    ; this was added for crafting
					$lOpCode = '8D4918'            ; this was added for crafting
				Case 'mov ecx,dword[ecx+edx]'
					$lOpCode = '8B0C11'
				Case 'push dword[ebp+8]'
					$lOpCode = 'FF7508'
				Case 'mov dword[eax],edi'
					$lOpCode = '8938'
				Case 'mov [eax+8],ecx'             ; this was added for crafting
					$lOpCode = '894808'            ; this was added for crafting
				Case 'mov [eax+C],ecx'             ; this was added for crafting
					$lOpCode = '89480C'            ; this was added for crafting
				Case 'mov ebx,dword[ecx-C]'        ; this was added
					$lOpCode = '8B59F4'            ; this was added
				Case 'mov [eax+!],ebx'             ; this was added
					$lOpCode = '89580C'            ; this was added
				Case 'mov ecx,[eax+8]'             ; this was added
					$lOpCode = '8B4808'            ; this was added
				Case 'lea ecx,dword[ebx+18]'       ; this was added
					$lOpCode = '8D4B18'            ; this was added
				Case 'mov ebx,dword[ebx+18]'       ; this was added
					$lOpCode = '8B5B18'            ; this was added
				Case 'mov ecx,dword[ecx+0xF4]'     ; this was added for crafting
					$lOpCode = '8B89F4000000'      ; this was added for crafting
				Case 'cmp ah,00' ;Added by Greg76 for scan wildcards
					$lOpCode = '80FC00'
				Case Else
					MsgBox(0x0, 'ASM', 'Could not assemble: ' & $aASM)
					Exit
			EndSwitch
			$mASMSize += 0.5 * StringLen($lOpCode)
			$mASMString &= $lOpCode
	EndSelect
EndFunc   ;==>_

;~ Description: Internal use only.
Func CompleteASMCode()
	Local $lInExpression = False
	Local $lExpression
	Local $lTempASM = $mASMString
	Local $lCurrentOffset = Dec(Hex($mMemory)) + $mASMCodeOffset
	Local $lToken

	For $i = 1 To $mLabels[0][0]
		If StringLeft($mLabels[$i][0], 6) = 'Label_' Then
			$mLabels[$i][0] = StringTrimLeft($mLabels[$i][0], 6)
			$mLabels[$i][1] = $mMemory + $mLabels[$i][1]
		EndIf
	Next

	$mASMString = ''
	For $i = 1 To StringLen($lTempASM)
		$lToken = StringMid($lTempASM, $i, 1)
		Switch $lToken
			Case '(', '[', '{'
				$lInExpression = True
			Case ')'
				$mASMString &= Hex(GetLabelInfo($lExpression) - Int($lCurrentOffset) - 1, 2)
				$lCurrentOffset += 1
				$lInExpression = False
				$lExpression = ''
			Case ']'
				$mASMString &= SwapEndian(Hex(GetLabelInfo($lExpression), 8))
				$lCurrentOffset += 4
				$lInExpression = False
				$lExpression = ''
			Case '}'
				$mASMString &= SwapEndian(Hex(GetLabelInfo($lExpression) - Int($lCurrentOffset) - 4, 8))
				$lCurrentOffset += 4
				$lInExpression = False
				$lExpression = ''
			Case Else
				If $lInExpression Then
					$lExpression &= $lToken
				Else
					$mASMString &= $lToken
					$lCurrentOffset += 0.5
				EndIf
		EndSwitch
	Next
EndFunc   ;==>CompleteASMCode

;~ Description: Internal use only.
Func GetLabelInfo($aLab)
	Local Const $lVal = GetValue($aLab)
	Return $lVal
EndFunc   ;==>GetLabelInfo

;~ Description: Internal use only.
Func ASMNumber($aNumber, $aSmall = False)
	If $aNumber >= 0 Then
		$aNumber = Dec($aNumber)
	EndIf
	If $aSmall And $aNumber <= 127 And $aNumber >= -128 Then
		Return SetExtended(1, Hex($aNumber, 2))
	Else
		Return SetExtended(0, SwapEndian(Hex($aNumber, 8)))
	EndIf
EndFunc   ;==>ASMNumber

; #FUNCTION# ====================================================================================================================
; Name...........: _ProcessGetName
; Description ...: Returns a string containing the process name that belongs to a given PID.
; Syntax.........: _ProcessGetName( $iPID )
; Parameters ....: $iPID - The PID of a currently running process
; Return values .: Success      - The name of the process
;                  Failure      - Blank string and sets @error
;                       1 - Process doesn't exist
;                       2 - Error getting process list
;                       3 - No processes found
; Author ........: Erifash <erifash [at] gmail [dot] com>, Wouter van Kesteren.
; Remarks .......: Supplementary to ProcessExists().
; ===============================================================================================================================
Func __ProcessGetName($i_PID)
	If Not ProcessExists($i_PID) Then Return SetError(1, 0, '')
	If Not @error Then
		Local $a_Processes = ProcessList()
		For $i = 1 To $a_Processes[0][0]
			If $a_Processes[$i][1] = $i_PID Then Return $a_Processes[$i][0]
		Next
	EndIf
	Return SetError(1, 0, '')
EndFunc   ;==>__ProcessGetName

Func CheckArea($aX, $aY)
	$ret = False
	$pX = GetAgentInfo(-2, "X")
	$pY = GetAgentInfo(-2, "Y")

	If ($pX == $aX) And ($pY == $aY) Then
		$ret = True
	EndIf
	Return $ret
EndFunc   ;==>CheckArea

Func CheckAreaWRange($aX, $aY, $range)
	$ret = False
	$pX = GetAgentInfo(-2, "X")
	$pY = GetAgentInfo(-2, "Y")

	If ($pX < $aX + $range) And ($pX > $aX - $range) And ($pY < $aY + $range) And ($pY > $aY - $range) Then
		$ret = True
	EndIf
	Return $ret
EndFunc   ;==>CheckAreaWRange

Func CheckAreaRange($aX, $aY, $range)
	$ret = False
	$pX = GetAgentInfo(-2, "X")
	$pY = GetAgentInfo(-2, "Y")

	If ($pX < $aX + $range) And ($pX > $aX - $range) And ($pY < $aY + $range) And ($pY > $aY - $range) Then
		$ret = True
	EndIf
	Return $ret
EndFunc   ;==>CheckAreaRange

Func CountItemInBagsByModelID($ItemModelID)
	Local Enum $BAG_Backpack = 1, $BAG_BeltPouch, $BAG_Bag1, $BAG_Bag2, $BAG_EquipmentPack, $BAG_UnclaimedItems = 7, $BAG_Storage1, $BAG_Storage2, _
			$BAG_Storage3, $BAG_Storage4, $BAG_Storage5, $BAG_Storage6, $BAG_Storage7, $BAG_Storage8, $BAG_StorageAnniversary
	$Count = 0
	For $i = $BAG_Backpack To $BAG_Bag2
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItemInfo = GetItemBySlot($i, $j)
			If DllStructGetData($lItemInfo, 'ModelID') = $ItemModelID Then $Count += DllStructGetData($lItemInfo, 'quantity')
		Next
	Next
	Return $Count
EndFunc   ;==>CountItemInBagsByModelID

Func Disconnected()
	Local $lCheck = False
	Local $lDeadlock = TimerInit()
	Do
		Sleep(20)
		$lCheck = GetInstanceType() <> 2 And GetAgentExists(-2)
	Until $lCheck Or TimerDiff($lDeadlock) > 5000
	If $lCheck = False Then
;~ 		Out("Disconnected!")
;~ 		Out("Attempting to reconnect.")
		ControlSend(GetWindowHandle(), "", "", "{Enter}")
		$lDeadlock = TimerInit()
		Do
			Sleep(20)
			$lCheck = GetInstanceType() <> 2 And GetAgentExists(-2)
		Until $lCheck Or TimerDiff($lDeadlock) > 60000
		If $lCheck = False Then
;~ 			Out("Failed to Reconnect 1!")
;~ 			Out("Retrying.")
			ControlSend(GetWindowHandle(), "", "", "{Enter}")
			$lDeadlock = TimerInit()
			Do
				Sleep(20)
				$lCheck = GetInstanceType() <> 2 And GetAgentExists(-2)
			Until $lCheck Or TimerDiff($lDeadlock) > 60000
			If $lCheck = False Then
;~ 				Out("Failed to Reconnect 2!")
;~ 				Out("Retrying.")
				ControlSend(GetWindowHandle(), "", "", "{Enter}")
				$lDeadlock = TimerInit()
				Do
					Sleep(20)
					$lCheck = GetInstanceType() <> 2 And GetAgentExists(-2)
				Until $lCheck Or TimerDiff($lDeadlock) > 60000
				If $lCheck = False Then
;~ 					Out("Could not reconnect!")
;~ 					Out("Exiting.")
					EnableRendering()
					Exit 1
				EndIf
			EndIf
		EndIf
	EndIf
	Sleep(5000)
EndFunc   ;==>Disconnected

Func GetPartySize()
	Local $lOffset0[5] = [0, 0x18, 0x4C, 0x54, 0xC]
	Local $lplayersPtr = MemoryReadPtr($mBasePointer, $lOffset0)

	Local $lOffset1[5] = [0, 0x18, 0x4C, 0x54, 0x1C]
	Local $lhenchmenPtr = MemoryReadPtr($mBasePointer, $lOffset1)

	Local $lOffset2[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
	Local $lheroesPtr = MemoryReadPtr($mBasePointer, $lOffset2)

	Local $Party1 = MemoryRead($lplayersPtr[0], 'long') ; players
	Local $Party2 = MemoryRead($lhenchmenPtr[0], 'long') ; henchmen
	Local $Party3 = MemoryRead($lheroesPtr[0], 'long') ; heroes

	Local $lReturn = $Party1 + $Party2 + $Party3
;~ 	If $lReturn > 12 or $lReturn < 1 Then $lReturn = 8
	Return $lReturn
EndFunc   ;==>GetPartySize

Func GetPartyAlliesSize()
	Local $lOffset3[5] = [0, 0x18, 0x4C, 0x54, 0x3C]
	Local $lalliesPtr = MemoryReadPtr($mBasePointer, $lOffset3)

	Local $Party4 = MemoryRead($lalliesPtr[0], 'long') ; allies

	Local $lReturn = $Party4
	Return $lReturn
EndFunc   ;==>GetPartyAlliesSize

Func GetPartyWaitingForMission()
	Return GetPartyState(0x8)
EndFunc   ;==>GetPartyWaitingForMission

Func GetBestTarget($aRange = 1320)
	Local $lBestTarget, $lDistance, $lLowestSum = 100000000
	Local $lAgentArray = GetAgentArray(0xDB)
	For $i = 1 To $lAgentArray[0]
		Local $lSumDistances = 0
		If GetAgentInfo($lAgentArray[$i], 'Allegiance') <> 3 Then ContinueLoop
		If GetAgentInfo($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
		If GetAgentInfo($lAgentArray[$i], 'ID') = GetMyID() Then ContinueLoop
		If GetDistance($lAgentArray[$i]) > $aRange Then ContinueLoop
		For $j = 1 To $lAgentArray[0]
			If GetAgentInfo($lAgentArray[$j], 'Allegiance') <> 3 Then ContinueLoop
			If GetAgentInfo($lAgentArray[$j], 'HP') <= 0 Then ContinueLoop
			If GetAgentInfo($lAgentArray[$j], 'ID') = GetMyID() Then ContinueLoop
			If GetDistance($lAgentArray[$j]) > $aRange Then ContinueLoop
			$lDistance = GetDistance($lAgentArray[$i], $lAgentArray[$j])
			$lSumDistances += $lDistance
		Next
		If $lSumDistances < $lLowestSum Then
			$lLowestSum = $lSumDistances
			$lBestTarget = $lAgentArray[$i]
		EndIf
	Next
	Return $lBestTarget
EndFunc   ;==>GetBestTarget

;~ Description: Wait for map to load until every context are loaded.
Func WaitMapLoading($aMapID = -1, $aInstanceType = -1)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6F0, 0xBC]

	Do
		Sleep(250)
		$lSkillbarStruct = MemoryReadPtr($mBasePointer, $lOffset, 'ptr') ; Skillbar
	Until GetAgentPtr(-2) <> 0 And GetMaxAgents() <> 0 And $lSkillbarStruct[0] <> 0 And GetPartySize() <> 0 And ($aInstanceType = -1 Or GetInstanceType() = $aInstanceType) And ($aMapID = -1 Or GetMapID() = $aMapID)
EndFunc   ;==>WaitMapLoading

Func TradePlayer($aAgent)
	Return SendPacket(0x08, $HEADER_TRADE_INITIATE, ConvertID($aAgent))
EndFunc   ;==>TradePlayer

Func AcceptTrade()
	Return SendPacket(0x4, $HEADER_TRADE_ACCEPT)
EndFunc   ;==>AcceptTrade

;~ Description: Like pressing the "Accept" button in a trade. Can only be used after both players have submitted their offer.
Func SubmitOffer($aGold = 0)
	Return SendPacket(0x8, $HEADER_TRADE_SUBMIT_OFFER, $aGold)
EndFunc   ;==>SubmitOffer

;~ Description: Like pressing the "Cancel" button in a trade.
Func CancelTrade()
	Return SendPacket(0x4, $HEADER_TRADE_CANCEL)
EndFunc   ;==>CancelTrade

;~ Description: Like pressing the "Change Offer" button.
Func ChangeOffer()
	Return SendPacket(0x4, $HEADER_TRADE_CANCEL_OFFER)
EndFunc   ;==>ChangeOffer

;~ $aItemID = ID of the item or item agent, $aQuantity = Quantity
Func OfferItem($lItemID, $aQuantity = 1)
	Return SendPacket(0xC, $HEADER_TRADE_ADD_ITEM, $lItemID, $aQuantity)
EndFunc   ;==>OfferItem

; Return 1 Trade windows exist; Return 3 Offer; Return 7 Accepted Trade
Func TradeWinExist()
	Local $lOffset = [0, 0x18, 0x58, 0]
	Return MemoryReadPtr($mBasePointer, $lOffset)[1]
EndFunc   ;==>TradeWinExist

Func TradeOfferItemExist()
	Local $lOffset = [0, 0x18, 0x58, 0x28, 0]
	Return MemoryReadPtr($mBasePointer, $lOffset)[1]
EndFunc   ;==>TradeOfferItemExist

Func TradeOfferMoneyExist()
	Local $lOffset = [0, 0x18, 0x58, 0x24]
	Return MemoryReadPtr($mBasePointer, $lOffset)[1]
EndFunc   ;==>TradeOfferMoneyExist

Func ToggleTradePatch($aEnable = True)
	If $aEnable Then
		MemoryWrite($MTradeHackAddress, 0xC3, "BYTE")
	Else
		MemoryWrite($MTradeHackAddress, 0x55, "BYTE")
	EndIf
EndFunc   ;==>ToggleTradePatch

Func GetLastDialogID()
	Return MemoryRead($mLastDialogID)
EndFunc   ;==>GetLastDialogID

Func GetLastDialogIDHex(Const ByRef $aID)
	If $aID Then Return '0x' & StringReplace(Hex($aID, 8), StringRegExpReplace(Hex($aID, 8), '[^0].*', ''), '')
EndFunc   ;==>GetLastDialogIDHex

; Type
Global $TypeUnit = 0xDB ; Player/Pet/Enemy/NPC (alive units)
Global $TypeObject = 0x200 ; Signpost/HiddenStash (stationary object)
Global $TypeLooteable = 0x400 ; Looteable object
; Allegiance
Global $NoneUnitType = 0 ; should not be produced by game, and object + looteable doesn't have allegiance
Global $UnitTypePlayer = 1 ; 1 = Player(s)
Global $UnitTypePet = 2 ; 2 = Charmable Pets
Global $UnitTypeEnemy = 3 ; 3 = Enemies
Global $UnitTypePlayerPet = 4 ; 4 = Player(s) Pets
Global $UnitTypeUnknown = 5    ; 5 = ?
Global $UnitTypeNPC = 6 ; 6 = NPC(s)
; Distance
Global $DistanceCasting = 1250
Global $DistanceSpirit = 2500
Global $DistanceCompass = 5000

#Region "Agent Detection and Distance Functions"
Func GetCountInRangeOfAgent($aAgent = -2, $aRange = $DistanceCasting, $aAllegiance = $UnitTypeEnemy, $aType = $TypeUnit)
	Local $lAgent, $lDistance
	Local $lCount = 0

	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentPtr($i)

		If GetAgentInfo($lAgent, 'Type') <> $aType Then ContinueLoop
		If $aType == $TypeUnit Then
			If GetAgentInfo($lAgent, 'Allegiance') <> $aAllegiance Then ContinueLoop
			If GetAgentInfo($lAgent, 'HP') <= 0 Then ContinueLoop
			If BitAND(GetAgentInfo($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		ElseIf $aType == $TypeObject Then

		ElseIf $aType == $TypeLooteable Then

		EndIf

		$lDistance = GetDistance($lAgent, $aAgent)

		If $lDistance > $aRange Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetCountInRangeOfAgent

Func GetClosestInRangeOfAgent($aAgent = -2, $aRange = $DistanceCasting, $aAllegiance = $UnitTypeEnemy, $aType = $TypeUnit)
	Local $lAgent, $lDistance
	Local $lClosestAgent = 0
	Local $lMinDistance = 100000000 ; Arbitrarily large number to ensure any real distance is smaller.

	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentPtr($i)

		If GetAgentInfo($lAgent, 'Type') <> $aType Then ContinueLoop
		If $aType == $TypeUnit Then
			If GetAgentInfo($lAgent, 'Allegiance') <> $aAllegiance Then ContinueLoop
			If GetAgentInfo($lAgent, 'HP') <= 0 Then ContinueLoop
			If BitAND(GetAgentInfo($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		ElseIf $aType == $TypeObject Then
			; Include additional conditions specific to TypeObject if necessary
		ElseIf $aType == $TypeLooteable Then
			; Include additional conditions specific to TypeLooteable if necessary
		EndIf

		$lDistance = GetDistance($lAgent, $aAgent)
		If $lDistance <= $aRange And $lDistance < $lMinDistance Then
			$lMinDistance = $lDistance
			$lClosestAgent = $lAgent
		EndIf
	Next

	Return $lClosestAgent
EndFunc   ;==>GetClosestInRangeOfAgent

;Used for smaller range distance of enemy Detection
Func GetClosestInRangeOfAgent2($aAgent = -2, $aRange = $DistanceCasting, $aAllegiance = $UnitTypeEnemy, $aType = $TypeUnit)
	Local $lAgent, $lDistance
	Local $lClosestAgent = 0
	Local $lMinDistance = 1000 ; Arbitrarily large number to ensure any real distance is smaller.


	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentPtr($i)

		If GetAgentInfo($lAgent, 'Type') <> $aType Then ContinueLoop
		If $aType == $TypeUnit Then
			If GetAgentInfo($lAgent, 'Allegiance') <> $aAllegiance Then ContinueLoop
			If GetAgentInfo($lAgent, 'HP') <= 0 Then ContinueLoop
			If BitAND(GetAgentInfo($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		ElseIf $aType == $TypeObject Then
			; Include additional conditions specific to TypeObject if necessary
		ElseIf $aType == $TypeLooteable Then
			; Include additional conditions specific to TypeLooteable if necessary
		EndIf

		$lDistance = GetDistance($lAgent, $aAgent)
		If $lDistance <= $aRange And $lDistance < $lMinDistance Then
			$lMinDistance = $lDistance
			$lClosestAgent = $lAgent
		EndIf
	Next

	Return $lClosestAgent
EndFunc   ;==>GetClosestInRangeOfAgent2
#EndRegion "Agent Detection and Distance Functions"

#Region "Town and Party Management"
; Function to check if the player is in town.
Func CheckInTown($aTown = "null")
	Local $mapID = GetMapID()
	If ($aTown <> "null" And IsNumber($aTown)) Then
		If $aTown == $mapID Then
			Return True
		EndIf
	EndIf

	If (($mapID = 148) Or ($mapID = 163) Or ($mapID = 164) Or ($mapID = 165) Or ($mapID = 166)) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CheckInTown

; Function to handle resignation and returning to outpost.
Func ResignAndReturn()
	If (CheckInTown() == True) Then
		Sleep(500)
	Else
		Resign()
		Local $lTimeout = GetPing() + 10000, $lDeadlock = TimerInit()
		Do
			If GetPartyDefeated() Then
				Sleep(1000)
				Return ReturnToOutpost()
			EndIf
			Sleep(250)
		Until TimerDiff($lDeadlock) > $lTimeout
	EndIf
EndFunc   ;==>ResignAndReturn

Func GetPartyDefeated()
	Return GetPartyState(0x20)
EndFunc   ;==>GetPartyDefeated

Func GetPartyState($aFlag)
	Local $lOffset[4] = [0, 0x18, 0x4C, 0x14]
	Local $lBitMask = MemoryReadPtr($mBasePointer, $lOffset)
	Return BitAND($lBitMask[1], $aFlag) > 0
EndFunc   ;==>GetPartyState

Func GetIsHardMode()
	Return GetPartyState(0x10)
EndFunc   ;==>GetIsHardMode
#EndRegion "Town and Party Management"

#Region "Miscellaneous Functions"
; Function to check if the player has a specific effect.
Func HasEffect($aEffectSkillID)
	If DllStructGetData(GetEffect($aEffectSkillID), "SkillID") = 0 Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>HasEffect

Func GetIsExplorableArea()
	Return GetInstanceType() == 1
EndFunc   ;==>GetIsExplorableArea

Func _PurgeHook()
	; Code for toggling rendering or performing a hook purge.
	Sleep(Random(4000, 5000))
EndFunc   ;==>_PurgeHook
#EndRegion "Miscellaneous Functions"

#Region "Structures Definition"
; Define TitleInfo structure.
Func TitleInfo($title_id, $unk_flags, $value, $h000c, $current_rank_minimum_value, $h0014, $next_rank_minimum_value, $num_ranks, $h0020, $progress_display_enc_string, $mouseover_hint_enc_string)
	Local $struct = DllStructCreate("uint32 title_id;uint32 unk_flags;uint32 value;uint32 h000c;uint32 current_rank_minimum_value;uint32 h0014;uint32 next_rank_minimum_value;uint32 num_ranks;uint32 h0020;wchar[16] progress_display_enc_string;wchar[16] mouseover_hint_enc_string")
	DllStructSetData($struct, "title_id", $title_id)
	DllStructSetData($struct, "unk_flags", $unk_flags)
	DllStructSetData($struct, "value", $value)
	DllStructSetData($struct, "h000c", $h000c)
	DllStructSetData($struct, "current_rank_minimum_value", $current_rank_minimum_value)
	DllStructSetData($struct, "h0014", $h0014)
	DllStructSetData($struct, "next_rank_minimum_value", $next_rank_minimum_value)
	DllStructSetData($struct, "num_ranks", $num_ranks)
	DllStructSetData($struct, "h0020", $h0020)
	DllStructSetData($struct, "progress_display_enc_string", $progress_display_enc_string, 1)
	DllStructSetData($struct, "mouseover_hint_enc_string", $mouseover_hint_enc_string, 1)
	Return $struct
EndFunc   ;==>TitleInfo

; Define PlayerAttrUpdate structure.
Func PlayerAttrUpdate($attr_id, $modifier)
	Local $struct = DllStructCreate("uint32 attr_id;int32 modifier")
	DllStructSetData($struct, "attr_id", $attr_id)
	DllStructSetData($struct, "modifier", $modifier)
	Return $struct
EndFunc   ;==>PlayerAttrUpdate

; Define PlayerAttrSet structure.
Func PlayerAttrSet($experience, $kurzick_faction, $kurzick_faction_total, $luxon_faction, $luxon_faction_total, $imperial_faction, $imperial_faction_total, $hero_skill_points, $hero_skill_points_total, $level, $morale_percent, $balthazar_faction, $balthazar_faction_total, $skill_points, $skill_points_total)
	Local $struct = DllStructCreate("uint32 experience;uint32 kurzick_faction;uint32 kurzick_faction_total;uint32 luxon_faction;uint32 luxon_faction_total;uint32 imperial_faction;uint32 imperial_faction_total;uint32 hero_skill_points;uint32 hero_skill_points_total;uint32 level;uint32 morale_percent;uint32 balthazar_faction;uint32 balthazar_faction_total;uint32 skill_points;uint32 skill_points_total")
	DllStructSetData($struct, "experience", $experience)
	DllStructSetData($struct, "kurzick_faction", $kurzick_faction)
	DllStructSetData($struct, "kurzick_faction_total", $kurzick_faction_total)
	DllStructSetData($struct, "luxon_faction", $luxon_faction)
	DllStructSetData($struct, "luxon_faction_total", $luxon_faction_total)
	DllStructSetData($struct, "imperial_faction", $imperial_faction)
	DllStructSetData($struct, "imperial_faction_total", $imperial_faction_total)
	DllStructSetData($struct, "hero_skill_points", $hero_skill_points)
	DllStructSetData($struct, "hero_skill_points_total", $hero_skill_points_total)
	DllStructSetData($struct, "level", $level)
	DllStructSetData($struct, "morale_percent", $morale_percent)
	DllStructSetData($struct, "balthazar_faction", $balthazar_faction)
	DllStructSetData($struct, "balthazar_faction_total", $balthazar_faction_total)
	DllStructSetData($struct, "skill_points", $skill_points)
	DllStructSetData($struct, "skill_points_total", $skill_points_total)
	Return $struct
EndFunc   ;==>PlayerAttrSet
#EndRegion "Structures Definition"

;~ Description: Returns World struct. (from 0 to 8)
Func GetWorldInfoByID($aWorldID)
	Local $lWorldStructAddress = $mWorldConst + (0x30 * $aWorldID)

	DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lWorldStructAddress, 'ptr', DllStructGetPtr($g_WorldStruct), 'int', DllStructGetSize($g_WorldStruct), 'int', '')

	Return $g_WorldStruct
EndFunc   ;==>GetWorldInfoByID

#Region Distance
;~ Description: Returns the distance between two coordinate pairs.
Func ComputeDistance($aX1, $aY1, $aX2, $aY2)
	Return Sqrt(($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2)
EndFunc   ;==>ComputeDistance

;~ Description: Returns the square of the distance between two coordinate pairs.
Func ComputePseudoDistance($aX1, $aY1, $aX2, $aY2)
	Return ($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2
EndFunc   ;==>ComputePseudoDistance

;~ Description: Returns the distance between two agents.
Func GetDistance($aAgent1 = -1, $aAgent2 = -2)
	Return Sqrt((X($aAgent1) - X($aAgent2)) ^ 2 + (Y($aAgent1) - Y($aAgent2)) ^ 2)
EndFunc   ;==>GetDistance

;~ Description: Return the square of the distance between two agents.
Func GetPseudoDistance($aAgent1 = -1, $aAgent2 = -2)
	Return (X($aAgent1) - X($aAgent2)) ^ 2 + (Y($aAgent1) - Y($aAgent2)) ^ 2
EndFunc   ;==>GetPseudoDistance

;~ Description: Returns the distance of agent from a waypoint.
Func GetDistanceToXY($aX, $aY, $aAgent = GetAgentPtr(-2))
	Return Sqrt(($aX - X($aAgent)) ^ 2 + ($aY - Y($aAgent)) ^ 2)
EndFunc   ;==>GetDistanceToXY

;~ Description: Returns the square of the distance of agent from a waypoint.
Func GetPseudoDistanceToXY($aX, $aY, $aAgent = GetAgentPtr(-2))
	Return ($aX - X($aAgent)) ^ 2 + ($aY - Y($aAgent)) ^ 2
EndFunc   ;==>GetPseudoDistanceToXY

; Description: returns whether an Agent is moving away from a waypoint
Func GetIsMovingAwayFromXY($aX, $aY, $aAgent)
	$Distance = GetDistanceToXY($aX, $aY, $aAgent)
	Sleep(50)
	If GetDistanceToXY($aX, $aY, $aAgent) > $Distance Then Return True
	Return False
EndFunc   ;==>GetIsMovingAwayFromXY

;~ Description: Checks if a point is within a polygon defined by an array
Func GetIsPointInPolygon($aAreaCoords, $aPosX = 0, $aPosY = 0)
	Local $lEdges = UBound($aAreaCoords)
	Local $lOddNodes = False
	If $lEdges < 3 Then Return False
	If $aPosX = 0 Then
		$aPosX = X(-2)
		$aPosY = Y(-2)
	EndIf
	$j = $lEdges - 1
	For $i = 0 To $lEdges - 1
		If (($aAreaCoords[$i][1] < $aPosY And $aAreaCoords[$j][1] >= $aPosY) _
				Or ($aAreaCoords[$j][1] < $aPosY And $aAreaCoords[$i][1] >= $aPosY)) _
				And ($aAreaCoords[$i][0] <= $aPosX Or $aAreaCoords[$j][0] <= $aPosX) Then
			If ($aAreaCoords[$i][0] + ($aPosY - $aAreaCoords[$i][1]) / ($aAreaCoords[$j][1] - $aAreaCoords[$i][1]) * ($aAreaCoords[$j][0] - $aAreaCoords[$i][0]) < $aPosX) Then
				$lOddNodes = Not $lOddNodes
			EndIf
		EndIf
		$j = $i
	Next
	Return $lOddNodes
EndFunc   ;==>GetIsPointInPolygon
#EndRegion Distance
