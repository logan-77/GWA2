#include <Array.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <ColorConstants.au3>  ; Include for predefined color constants

#include "GWA2.au3"  ; Ensure this is the correct relative path or adjust accordingly

; Path to the GWA2 library file
Global $sFilePath = @ScriptDir & "\GWA2.au3"

; Read the functions from the GWA2 library
Global $aFunctions = _ReadFunctions($sFilePath)
Global $aFunctionFullCode = _ReadFullFunctionCode($sFilePath)  ; Store full function code
Global $LBS_SORT, $LBS_NOTIFY

; Create the GUI
Global $hGUI = GUICreate("Function Finder", 600, 400)
Global $idCredits = GUICtrlCreateLabel("Created by MrJambix", 10, 380, 580, 20) ; Credits label at the bottom
GUICtrlSetColor($idCredits, $CLR_BLACK) ; Set text color if needed
Global $idInput = GUICtrlCreateInput("", 10, 10, 480, 20)
Global $idList = GUICtrlCreateList("", 10, 40, 580, 350, $LBS_SORT + $LBS_NOTIFY)
GUICtrlSetColor($idList, $CLR_BLACK)
Global $idSearchBtn = GUICtrlCreateButton("Search", 500, 10, 80, 20)
GUISetState(@SW_SHOW, $hGUI)

While 1
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            Exit
        Case $idSearchBtn
            _FilterFunctions(GUICtrlRead($idInput))
        Case $idList
            If GUICtrlRead($idList) <> "" Then
                _ShowFunctionCode(GUICtrlRead($idList))
            EndIf
    EndSwitch
WEnd

Func _ReadFunctions($sPath)
    Local $aLines, $aResult = []
    If _FileReadToArray($sPath, $aLines) Then
        For $i = 1 To $aLines[0]
            If StringRegExp($aLines[$i], "Func\s+(\w+)") Then
                _ArrayAdd($aResult, StringRegExpReplace($aLines[$i], ".*Func\s+(\w+).*", "$1"))
            EndIf
        Next
    EndIf
    Return $aResult
EndFunc

Func _ReadFullFunctionCode($sPath)
    Local $aLines, $aResult = [], $sFuncCode = "", $bCollecting = False
    If _FileReadToArray($sPath, $aLines) Then
        For $i = 1 To $aLines[0]
            If StringRegExp($aLines[$i], "Func\s+(\w+)") Then
                If $bCollecting Then
                    _ArrayAdd($aResult, $sFuncCode)
                    $sFuncCode = ""
                EndIf
                $bCollecting = True
                $sFuncCode &= $aLines[$i] & @CRLF
            ElseIf $bCollecting Then
                $sFuncCode &= $aLines[$i] & @CRLF
                If StringRegExp($aLines[$i], "EndFunc") Then
                    $bCollecting = False
                    _ArrayAdd($aResult, $sFuncCode)
                    $sFuncCode = ""
                EndIf
            EndIf
        Next
    EndIf
    Return $aResult
EndFunc

Func _FilterFunctions($sSearch)
    GUICtrlSetData($idList, "")  ; Clear existing list
    For $i = 0 To UBound($aFunctions) - 1
        If StringInStr($aFunctions[$i], $sSearch) Then
            GUICtrlSetData($idList, $aFunctions[$i])
        EndIf
    Next
EndFunc

Func _ShowFunctionCode($sFuncName)
    Local $sCode = ""
    For $i = 0 To UBound($aFunctions) - 1
        If $aFunctions[$i] == $sFuncName Then
            $sCode = $aFunctionFullCode[$i]
            ExitLoop
        EndIf
    Next
    If $sCode <> "" Then
        Local $aPos = WinGetPos($hGUI)
        Local $iNewX = $aPos[0] + $aPos[2]  ; X position + width of the first GUI
        Local $iNewY = $aPos[1]  ; Y position remains the same

        Local $hCodeGUI = GUICreate("Function Code: " & $sFuncName, 600, 400, $iNewX, $iNewY, $WS_OVERLAPPEDWINDOW + $WS_VSCROLL + $WS_HSCROLL)
        Local $idEdit = GUICtrlCreateEdit($sCode, 10, 10, 580, 380, $ES_READONLY + $ES_MULTILINE + $ES_AUTOVSCROLL + $ES_AUTOHSCROLL)
        GUISetState(@SW_SHOW, $hCodeGUI)
        While 1
            If GUIGetMsg() = $GUI_EVENT_CLOSE Then
                GUIDelete($hCodeGUI)
                ExitLoop
            EndIf
        WEnd
    EndIf
EndFunc
