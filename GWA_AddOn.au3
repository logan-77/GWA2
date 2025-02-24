#include-once

#Region H&H
Func MoveHero($aX, $aY, $HeroID, $Random = 75); Parameter1 = heroID (1-7) reset flags $aX = 0x7F800000, $aY = 0x7F800000

	Switch $HeroID
		Case "All"
			CommandAll(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 1
			CommandHero1(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 2
			CommandHero2(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 3
			CommandHero3(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 4
			CommandHero4(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 5
			CommandHero5(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 6
			CommandHero6(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
		Case 7
			CommandHero7(_FloatToInt($aX) + Random(-$Random, $Random), _FloatToInt($aY) + Random(-$Random, $Random))
	EndSwitch
EndFunc   ;==>MoveHero

Func CommandHero1($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, MEMORYREAD($lHeroStruct[1] + 0x4), $aX, $aY, 0)
EndFunc   ;==>CommandHero1

Func CommandHero2($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, MEMORYREAD($lHeroStruct[1] + 0x28), $aX, $aY, 0)
EndFunc   ;==>CommandHero2

Func CommandHero3($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, MEMORYREAD($lHeroStruct[1] + 0x4C), $aX, $aY, 0)
EndFunc   ;==>CommandHero3

Func CommandHero4($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, MEMORYREAD($lHeroStruct[1] + 0x70), $aX, $aY, 0)
EndFunc   ;==>CommandHero4

Func CommandHero5($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, MEMORYREAD($lHeroStruct[1] + 0x94), $aX, $aY, 0)
EndFunc   ;==>CommandHero5

Func CommandHero6($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, MEMORYREAD($lHeroStruct[1] + 0xB8), $aX, $aY, 0)
EndFunc   ;==>CommandHero6

Func CommandHero7($aX = 0x7F800000, $aY = 0x7F800000)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x520]
	Local $lHeroStruct = MemoryReadPtr($mBasePointer, $lOffset)
	SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, MEMORYREAD($lHeroStruct[1] + 0xDC), $aX, $aY, 0)
EndFunc   ;==>CommandHero7


#Region chest
Func OpenChestByExtraType($ExtraType)
		OpenChest()
EndFunc   ;==>OpenChestByExtraType

Func GetAgentArraySorted($lAgentType)     ;returns a 2-dimensional array([agentID, [distance]) sorted by distance
	Local $lDistance
	Local $lAgentArray = GetAgentArray($lAgentType)
	Local $lReturnArray[1][2]
	Local $lMe = GetAgentByID(-2)
	Local $AgentID
	For $i = 1 To $lAgentArray[0]
		$lDistance = (DllStructGetData($lMe, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + (DllStructGetData($lMe, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
		$AgentID = DllStructGetData($lAgentArray[$i], 'ID')
		ReDim $lReturnArray[$i][2]
		$lReturnArray[$i - 1][0] = $AgentID
		$lReturnArray[$i - 1][1] = Sqrt($lDistance)
	Next
	_ArraySort($lReturnArray, 0, 0, 0, 1)
	Return $lReturnArray
 EndFunc   ;==>GetAgentArraySorted

  ; Function to check for chests and interact with them  
Func CheckForChest($chestRun = False)  
   ; Check if the character is dead  
   If GetIsDead(-2) Then Return  
    
   ; Get all static objects  
   Local $AgentArray = GetAgentArraySorted($STATIC_AGENT_TYPE)  
   Local $lAgent = 0  
   Local $ChestFound = False  
    
   ; Look for valid chests  
   For $i = 0 To UBound($AgentArray) - 1  
      $lAgent = GetAgentByID($AgentArray[$i][0])  
       
      ; Skip if not a chest or invalid chest ID  
      If DllStructGetData($lAgent, 'Type') <> $CHEST_TYPE Or $aChestID = "" Then  
        ContinueLoop  
      EndIf  
       
      ; Check if chest was already opened  
      If Not IsChestOpened($AgentArray[$i][0]) Then  
        ; Add chest to opened list  
        AddOpenedChest($AgentArray[$i][0])  
        $ChestFound = True  
        ExitLoop  
      EndIf  
   Next  
    
   If Not $ChestFound Then Return  
    
   ; Interact with chest  
   ChangeTarget($lAgent)  
   GoSignpost($lAgent)  
   OpenChestByExtraType($aChestID)  
   Sleep(GetPing() + 500)  
    
   ; Handle loot  
   Local $ItemArray = GetAgentArraySorted($ITEM_AGENT_TYPE)  
   If UBound($ItemArray) > 0 Then  
      ChangeTarget($ItemArray[0][0])  
      PickUpLoot()  
   EndIf  
EndFunc  
  
; Function to check if a chest has been opened  
Func IsChestOpened($chestID)  
   If UBound($OpenedChestAgentIDs) = 0 Then Return False  
   Return _ArraySearch($OpenedChestAgentIDs, $chestID) <> -1  
EndFunc  
  
; Function to add a chest to the opened list  
Func AddOpenedChest($chestID)  
   If UBound($OpenedChestAgentIDs) = 0 Then  
      ReDim $OpenedChestAgentIDs[1]  
      $OpenedChestAgentIDs[0] = $chestID  
   Else  
      _ArrayAdd($OpenedChestAgentIDs, $chestID)  
   EndIf  
EndFunc

Func GetPlayerCoords()
    Return GetAgentByID(-2) ;~ Assuming -2 is the player's unique identifier, get the agent data for the player
EndFunc

Func CheckForChest2($chestrun = False)
    Local $AgentArray, $lAgent, $lType, $playerAgent
    Local $ChestFound = False
    Local $MaxDistance = 10000  ; Maximum distance to check for chests

    If GetIsDead(-2) Then Return  ; Exit if the player is dead
    $playerAgent = GetPlayerCoords()  ; Get the player agent
    $AgentArray = GetAgentArraySorted(0x200)  ; Retrieve sorted array of static type entities
    For $i = 0 To UBound($AgentArray) - 1
        $lAgent = GetAgentByID($AgentArray[$i][0])
        If Not IsDllStruct($lAgent) Then ContinueLoop  ; Validate each agent before proceeding

        $lType = DllStructGetData($lAgent, 'Type')
        If $lType <> 512 Then ContinueLoop  ; Skip non-chest agents

        $lDistance = CalculateDistance($playerAgent, $lAgent)
        If $lDistance > $MaxDistance Then ContinueLoop  ; Skip chests out of specified range

        ; Check if chest has been opened before
        If _ArraySearch($OpenedChestAgentIDs, $AgentArray[$i][0]) <> -1 Then
            ContinueLoop  ; Skip this chest as it has already been opened
        EndIf

        ; Not found in the opened chest list, proceed
        $ChestFound = True
        ChangeTarget($lAgent)
        GoSignpost($lAgent)
        OpenChestByExtraType($aChestID)
        Sleep(GetPing() + 500)

        ; Add the chest ID to the blacklist after opening
        _ArrayAdd($OpenedChestAgentIDs, $AgentArray[$i][0])

        ; Retrieve items dropped from the chest
        $AgentArray = GetAgentArraySorted(0x400)
        ChangeTarget($AgentArray[0][0])
        PickUpLoot()
    Next

    If Not $ChestFound Then Return False  ; Return False if no chests found
    Return True  ; Indicate successful operation
EndFunc   ;==>CheckForChest2


Func CalculateDistance($agent1, $agent2)
    Local $x1 = DllStructGetData($agent1, 'X')
    Local $y1 = DllStructGetData($agent1, 'Y')
    Local $x2 = DllStructGetData($agent2, 'X')
    Local $y2 = DllStructGetData($agent2, 'Y')

    Return Sqrt(($x2 - $x1) ^ 2 + ($y2 - $y1) ^ 2)
EndFunc


Func PickUpLoot2()
    If CountSlots() < 1 Then Return ; Check if inventory is full and exit if no slots are available

    If GetIsDead(-2) Then Return ; Exit the function if the player is dead

    Local $lAgent, $lItem, $lDeadlock
    For $i = 1 To GetMaxAgents() ; Loop through all agents in the area
        $lAgent = GetAgentByID($i) ; Retrieve agent data by its ID

        If DllStructGetData($lAgent, 'Type') <> 0x400 Then ContinueLoop ; Only proceed if agent type is item (0x400)
        
        $lItem = GetItemByAgentID($i) 
        If CanPickUp($lItem) Then ; Check if the item is eligible to be picked up
            PickUpItem($lItem) ; Execute the pick up item action
            $lDeadlock = TimerInit() ; Start a timer to avoid a deadlock situation

            While GetAgentExists($i) ; Loop while the item still exists
                Sleep(100) ; Small delay to reduce CPU load and allow for server response time
                If GetIsDead(-2) Then Return ; Exit if the player dies during the process

                If TimerDiff($lDeadlock) > 15000 Then ExitLoop ; Break the loop after 15 seconds to avoid infinite loop
            WEnd
        EndIf
    Next
EndFunc   ;==>PickUpLoot2

#EndRegion Chest

;=================================================================================================
; Function:			PickUpItems($iItems = -1, $fMaxDistance = 1012)
; Description:		PickUp defined number of items in defined area around default = 1012
; Parameter(s):		$iItems:	number of items to be picked
;					$fMaxDistance:	area within items should be picked up
; Requirement(s):	GW must be running and Memory must have been scanned for pointers (see Initialize())
; Return Value(s):	On Success - Returns $iItemsPicked (number of items picked)
; Author(s):		GWCA team, recoded by ddarek, thnx to The ArkanaProject
;=================================================================================================
Func PickupItems($iItems = -1, $fMaxDistance = 506)
	Local $aItemID, $lNearestDistance, $lDistance
	$tDeadlock = TimerInit()
	Do
		$aItem = GetNearestItemToAgent(-2)
		$lDistance = @extended

		$aItemID = DllStructGetData($aItem, 'ID')
		If $aItemID = 0 Or $lDistance > $fMaxDistance Or TimerDiff($tDeadlock) > 30000 Then ExitLoop
		PickUpItem($aItem)
		$tDeadlock2 = TimerInit()
		Do
			Sleep(500)
			If TimerDiff($tDeadlock2) > 5000 Then ContinueLoop 2
		Until DllStructGetData(GetAgentById($aItemID), 'ID') == 0
		$iItems_Picked += 1
		;UpdateStatus("Picked total " & $iItems_Picked & " items")
	Until $iItems_Picked = $iItems
	Return $iItems_Picked
EndFunc   ;==>PickupItems

;=================================================================================================
; Function:			GetNearestItemToAgent($aAgent)
; Description:		Get nearest item lying on floor around $aAgent ($aAgent = -2 ourself), necessary to work with PickUpItems func
; Parameter(s):		$aAgent: ID of Agent
; Requirement(s):	GW must be running and Memory must have been scanned for pointers (see Initialize())
; Return Value(s):	On Success - Returns ID of nearest item
;					@extended  - distance to item
; Author(s):		GWCA team, recoded by ddarek
;=================================================================================================



Func GetNearestItemByModelId($ModelId, $aAgent = -2 )
Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance, $lAgentToCompare

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)

	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If DllStructGetData($lAgentToCompare, 'Type') <> 0x400 Then ContinueLoop
		If DllStructGetData(GetItemByAgentID($i), 'ModelID') <> $ModelId Then ContinueLoop
		$lDistance = (DllStructGetData($lAgentToCompare, 'Y') - DllStructGetData($aAgent, 'Y')) ^ 2 + (DllStructGetData($lAgentToCompare, 'X') - DllStructGetData($aAgent, 'X')) ^ 2
		If $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentToCompare
			$lNearestDistance = $lDistance
		EndIf

	Next
	Return $lNearestAgent; return struct of Agent not item!
EndFunc   ;==>GetNearestItemByModelId

;~ Description: Returns the nearest item by model ID to an agent.
Func GetNearestItemByModelIDToAgent($aModelID, $aAgent = -2, $aCanPickUp = True)
	Local $lNearestAgent, $lNearestDistance = 100000000
	Local $lDistance
	If GetMaxAgents() > 0 Then
		For $i = 1 To GetMaxAgents()
			Local $a = GetAgentPtr($i)
			If Not GetIsMovable($a) Then ContinueLoop
			Local $aMID = DllStructGetData(GetItemByAgentID($i), "ModelID")
			If $aMID = $aModelID Then    ;Item matches
				$lDistance = (GetAgentInfo($aAgent, 'X') - GetAgentInfo($a, 'X')) ^ 2 + (GetAgentInfo($aAgent, 'Y') - GetAgentInfo($a, 'Y')) ^ 2
				If $lDistance < $lNearestDistance Then
					$lNearestAgent = $a
					$lNearestDistance = $lDistance
				EndIf
			EndIf
		Next
		Return $lNearestAgent
	EndIf
EndFunc   ;==>GetNearestItemByModelIDToAgent

;~ Description: Returns the nearest item to an agent.
Func GetNearestItemToAgent($aAgent = -2, $aCanPickUp = True)
	Local $lNearestAgent, $lNearestDistance = 10000
	Local $lDistance
	Local $lAgentArray = GetAgentArray(0x400)

	Local $lID = GetAgentInfo($aAgent, 'ID')

	For $i = 1 To $lAgentArray[0]

		If $aCanPickUp And Not GetCanPickUp($lAgentArray[$i]) Then ContinueLoop
		$lDistance = (GetAgentInfo($aAgent, 'X') - GetAgentInfo($lAgentArray[$i], 'X')) ^ 2 + (GetAgentInfo($aAgent, 'Y') - GetAgentInfo($lAgentArray[$i], 'Y')) ^ 2
		If $lDistance < $lNearestDistance Then
			If GetAgentInfo($lAgentArray[$i], 'ID') == $lID Then ContinueLoop
			$lNearestAgent = $lAgentArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance))
	Return $lNearestAgent
EndFunc   ;==>GetNearestItemToAgent


;=================================================================================================
; Function:			Ident($bagIndex = 1, $numOfSlots)
; Description:		Idents items in $bagIndex, NEEDS ANY ID kit in inventory!
; Parameter(s):		$bagIndex -> check Global enums
;					$numOfSlots -> correspondend number of slots in $bagIndex
; Requirement(s):	GW must be running and Memory must have been scanned for pointers (see Initialize())
; Return Value(s):
; Author(s):		GWCA team, recoded by ddarek, thnx to The ArkanaProject
;=================================================================================================


;=================================================================================================
; Function:			CanSell($aItem); only part of it can do
; Description:		general precaution not to sell things we want to save; ModelId page = http://wiki.gamerevision.com/index.php/Model_IDs
; Parameter(s):		$aItem-object
;
; Requirement(s):	GW must be running and Memory must have been scanned for pointers (see Initialize())
; Return Value(s):	On Success - Returns boolean
; Author(s):		GWCA team, recoded by ddarek, thnx to The ArkanaProject
;=================================================================================================


;=================================================================================================
; Function:			Sell($bagIndex, $numOfSlots)
; Description:		Sell items in $bagIndex, need open Dialog with Trader!
; Parameter(s):		$bagIndex -> check Global enums
;					$numOfSlots -> correspondend number of slots in $bagIndex
; Requirement(s):	GW must be running and Memory must have been scanned for pointers (see Initialize())
; Return Value(s):
; Author(s):		GWCA team, recoded by ddarek, thnx to The ArkanaProject
;=================================================================================================



Func GetExtraItemInfoBySlot($aBag, $aSlot)
	$item = GetItembySlot($aBag, $aSlot)
	$lItemExtraPtr = DllStructGetData($item, "ModPtr")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
	;ConsoleWrite($rarity & @CRLF)
EndFunc   ;==>GetExtraInfoBySlot

Func GetEtraItemInfoByItemId($aItem)
	$item = GetItemByItemID($aItem)
	$lItemExtraPtr = DllStructGetData($item, "ModPtr")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
EndFunc   ;==>GetEtraInfoByItemId

Func GetEtraItemInfoByAgentId($aItem)
	$item = GetItemByAgentID($aItem)
	$lItemExtraPtr = DllStructGetData($item, "ModPtr")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
EndFunc   ;==>GetEtraInfoByAgentId

Func GetEtraItemInfoByModelId($aItem)
	$item = GetItemByModelID($aItem)
	$lItemExtraPtr = DllStructGetData($item, "ModPtr")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
	Return $lItemExtraStruct
EndFunc   ;==>GetEtraInfoByModelId

Func GetExtraItemReqBySlot($aBag, $aSlot)
	$item = GetItembySlot($aBag, $aSlot)
	$lItemExtraReqPtr = DllStructGetData($item, "extraItemReq")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraReqPtr, 'ptr', $lItemExtraReqStructPtr, 'int', $lItemExtraReqStructSize, 'int', '')
	Return $lItemExtraReqStruct
	;ConsoleWrite($rarity & @CRLF)
EndFunc   ;==>GetExtraItemReqBySlot

Func GetEtraItemReqByItemId($aItem)
	$item = GetItemByItemID($aItem)
	$lItemExtraReqPtr = DllStructGetData($item, "extraItemReq")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraReqPtr, 'ptr', $lItemExtraReqStructPtr, 'int', $lItemExtraReqStructSize, 'int', '')
	Return $lItemExtraReqStruct
EndFunc   ;==>GetEtraItemReqByItemId

Func GetEtraItemReqByAgentId($aItem)
	$item = GetItemByAgentID($aItem)
	$lItemExtraReqPtr = DllStructGetData($item, "extraItemReq")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraReqPtr, 'ptr', $lItemExtraReqStructPtr, 'int', $lItemExtraReqStructSize, 'int', '')
	Return $lItemExtraReqStruct
EndFunc   ;==>GetEtraItemReqByAgentId

Func GetEtraItemReqByModelId($aItem)
	$item = GetItemByModelID($aItem)
	$lItemExtraReqPtr = DllStructGetData($item, "extraItemReq")

	DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraReqPtr, 'ptr', $lItemExtraReqStructPtr, 'int', $lItemExtraReqStructSize, 'int', '')
	Return $lItemExtraReqStruct
EndFunc   ;==>GetEtraItemReqByModelId

Func FindEmptySlot($bagIndex) ;Parameter = bag index to start searching from. Returns integer with item slot. This function also searches the storage. If any of the returns = 0, then no empty slots were found
	Local $lItemInfo, $aSlot

	For $aSlot = 1 To DllStructGetData(GetBag($bagIndex), 'Slots')
		Sleep(40)
		ConsoleWrite("Checking: " & $bagIndex & ", " & $aSlot & @CRLF)
		$lItemInfo = GetItemBySlot($bagIndex, $aSlot)
		If DllStructGetData($lItemInfo, 'ID') = 0 Then
			ConsoleWrite($bagIndex & ", " & $aSlot & "  <-Empty! " & @CRLF)
			SetExtended($aSlot)
			ExitLoop
		EndIf
	Next
	Return 0
EndFunc   ;==>FindEmptySlot
#Region Misc

Func GetHPPips($aAgent = -2); Thnx to The Arkana Project
   If IsDllStruct($aAgent) == 0 Then $aAgent = GetAgentByID($aAgent)
   Return Round(DllStructGetData($aAgent, 'hppips') * DllStructGetData($aAgent, 'maxhp') / 2, 0)
EndFunc


Func GetTeam($aTeam); Thnx to The Arkana Project. Only works in PvP!
	Local $lTeamNumber
	Local $lTeam[1][2]
	Local $lTeamSmall[1] = [0]
	Local $lAgent
	If IsString($aTeam) Then
		Switch $aTeam
			Case "Blue"
				$lTeamNumber = 1
			Case "Red"
				$lTeamNumber = 2
			Case "Yellow"
				$lTeamNumber = 3
			Case "Purple"
				$lTeamNumber = 4
			Case "Cyan"
				$lTeamNumber = 5
			Case Else
				$lTeamNumber = 0
		EndSwitch
	Else
		$lTeamNumber = $aTeam
	EndIf
	$lTeam[0][0] = 0
	$lTeam[0][1] = $lTeamNumber
	If $lTeamNumber == 0 Then Return $lTeamSmall
	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentByID($i)
		If DllStructGetData($lAgent, 'ID') == 0 Then ContinueLoop
		If GetIsLiving($lAgent) And DllStructGetData($lAgent, 'Team') == $lTeamNumber And (DllStructGetData($lAgent, 'LoginNumber') <> 0 Or StringRight(GetAgentName($lAgent), 9) == "Henchman]") Then
			$lTeam[0][0] += 1
			ReDim $lTeam[$lTeam[0][0]+1][2]
			$lTeam[$lTeam[0][0]][0] = DllStructGetData($lAgent, 'id')
			$lTeam[$lTeam[0][0]][1] = DllStructGetData($lAgent, 'PlayerNumber')
		EndIf
	Next
	_ArraySort($lTeam, 0, 1, 0, 1)
	Redim $lTeamSmall[$lTeam[0][0]+1]
	For $i = 0 To $lTeam[0][0]
		$lTeamSmall[$i] = $lTeam[$i][0]
	Next
	Return $lTeamSmall
EndFunc

Func FormatName($aAgent); Thnx to The Arkana Project. Only works in PvP!
	If IsDllStruct($aAgent) == 0 Then $aAgent = GetAgentByID($aAgent)
	Local $lString
	Switch DllStructGetData($aAgent, 'Primary')
		Case 1
			$lString &= "W"
		Case 2
			$lString &= "R"
		Case 3
			$lString &= "Mo"
		Case 4
			$lString &= "N"
		Case 5
			$lString &= "Me"
		Case 6
			$lString &= "E"
		Case 7
			$lString &= "A"
		Case 8
			$lString &= "Rt"
		Case 9
			$lString &= "P"
		Case 10
			$lString &= "D"
	EndSwitch
	Switch DllStructGetData($aAgent, 'Secondary')
		Case 1
			$lString &= "/W"
		Case 2
			$lString &= "/R"
		Case 3
			$lString &= "/Mo"
		Case 4
			$lString &= "/N"
		Case 5
			$lString &= "/Me"
		Case 6
			$lString &= "/E"
		Case 7
			$lString &= "/A"
		Case 8
			$lString &= "/Rt"
		Case 9
			$lString &= "/P"
		Case 10
			$lString &= "/D"
	EndSwitch
	$lString &= " - "
	If DllStructGetData($aAgent, 'LoginNumber') > 0 Then
		$lString &= GetPlayerName($aAgent)
	Else
		$lString &= StringReplace(GetAgentName($aAgent), "Corpse of ", "")
	EndIf
	Return $lString
EndFunc

; #FUNCTION: Death ==============================================================================================================
; Description ...: Checks the dead
; Syntax.........: Death()
; Parameters ....:
; Author(s):		Syc0n
; ===============================================================================================================================
Func Death()
	If DllStructGetData(GetAgentByID(-2), "Effects") = 0x0010 Then
		Return 1	; Whatever you want to put here in case of death
	Else
		Return 0
	EndIf
EndFunc   ;==>Death

; #FUNCTION: RndSlp =============================================================================================================
; Description ...: RandomSleep (5% Variation) with Deathcheck
; Syntax.........: RndSlp(§wert)
; Parameters ....: $val = Sleeptime
; Author(s):		Syc0n
; ===============================================================================================================================

Func RNDSLP($val)
	$wert = Random($val * 0.95, $val * 1.05, 1)
	If $wert > 45000 Then
		For $i = 0 To 6
			Sleep($wert / 6)
			DEATH()
		Next
	ElseIf $wert > 36000 Then
		For $i = 0 To 5
			Sleep($wert / 5)
			DEATH()
		Next
	ElseIf $wert > 27000 Then
		For $i = 0 To 4
			Sleep($wert / 4)
			DEATH()
		Next
	ElseIf $wert > 18000 Then
		For $i = 0 To 3
			Sleep($wert / 3)
			DEATH()
		Next
	ElseIf $wert >= 9000 Then
		For $i = 0 To 2
			Sleep($wert / 2)
			DEATH()
		Next
	Else
		Sleep($wert)
		DEATH()
	EndIf
EndFunc   ;==>RndSlp

; #FUNCTION: Slp ================================================================================================================
; Description ...: Sleep with Deathcheck
; Syntax.........: Slp(§wert)
; Parameters ....: $wert = Sleeptime
; ===============================================================================================================================

Func SLP($val)
	If $val > 45000 Then
		For $i = 0 To 6
			Sleep($val / 6)
			DEATH()
		Next
	ElseIf $val > 36000 Then
		For $i = 0 To 5
			Sleep($val / 5)
			DEATH()
		Next
	ElseIf $val > 27000 Then
		For $i = 0 To 4
			Sleep($val / 4)
			DEATH()
		Next
	ElseIf $val > 18000 Then
		For $i = 0 To 3
			Sleep($val / 3)
			DEATH()
		Next
	ElseIf $val >= 9000 Then
		For $i = 0 To 2
			Sleep($val / 2)
			DEATH()
		Next
	Else
		Sleep($val)
		DEATH()
	EndIf
EndFunc   ;==>Slp

Func _FloatToInt($fFloat)
	Local $tFloat, $tInt

	$tFloat = DllStructCreate("float")
	$tInt = DllStructCreate("int", DllStructGetPtr($tFloat))
	DllStructSetData($tFloat, 1, $fFloat)
	Return DllStructGetData($tInt, 1)

EndFunc   ;==>_FloatToInt

Func _IntToFloat($fInt)
	Local $tFloat, $tInt

	$tInt = DllStructCreate("int")
	$tFloat = DllStructCreate("float", DllStructGetPtr($tInt))
	DllStructSetData($tInt, 1, $fInt)
	Return DllStructGetData($tFloat, 1)

EndFunc   ;==>_IntToFloat


Func PingSleep($msExtra = 0)
	$ping = GetPing()
	Sleep($ping + $msExtra)
EndFunc   ;==>PingSleep

Func ComputeDistanceEx($x1, $y1, $x2, $y2)
	Return Sqrt(($y2 - $y1) ^ 2 + ($x2 - $x1) ^ 2)
	$dist = Sqrt(($y2 - $y1) ^ 2 + ($x2 - $x1) ^ 2)
	ConsoleWrite("Distance: " & $dist & @CRLF)

EndFunc   ;==>ComputeDistanceEx

Func GoNearestNPCToCoords($aX, $aY)
	Local $NPC
	MoveTo($aX, $aY)
	$NPC = GetNearestNPCToCoords($aX, $aY)
	Do
		RndSleep(250)
		GoNPC($NPC)
	Until GetDistance($NPC, -2) < 250
	RndSleep(500)
EndFunc

Func IsBlackDye($aModelID, $aExtraID)
	If $aModelID == $model_id_dye Then
		Switch $aExtraID
			Case $item_extraid_black_dye
				Return True
			Case Else
				Return False
		EndSwitch
	EndIf
EndFunc ;==>IsBlackDye

Func IsWhiteDye($aModelID, $aExtraID)
	If $aModelID == $model_id_dye Then
		Switch $aExtraID
			Case $ITEM_ExtraID_WhiteDye
				Return True
			Case Else
				Return False
		EndSwitch
	EndIf
EndFunc ;==>IsBlackDye

#EndRegion Misc