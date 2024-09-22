; Set boundary limits (22x26 area)
minX := 100  ; Minimum X boundary
maxX := 800  ; Maximum X boundary
minY := 100  ; Minimum Y boundary
maxY := 600  ; Maximum Y boundary

; Toggle auto-click when pressing "F"
$f::
    isAutoClicking := !isAutoClicking  ; Toggle the state
    if isAutoClicking
    {
        ToolTip Auto-clicking Enabled
        SetTimer, AutoClick, 100  ; Set the auto-click interval (100ms)
    }
    else
    {
        ToolTip Auto-clicking Disabled
        SetTimer, AutoClick, Off  ; Turn off auto-clicking
    }
    Sleep 1000
    ToolTip  ; Clear tooltip
    return

; Auto-click logic
AutoClick:
    Click
    return

; Toggle automatic movement when pressing "Z"
$z::
    isAutoMoving := !isAutoMoving  ; Toggle the state
    if isAutoMoving
    {
        ToolTip Auto-moving Enabled
        SetTimer, AutoMove, 2000  ; Set the movement interval (2s)
    }
    else
    {
        ToolTip Auto-moving Disabled
        SetTimer, AutoMove, Off  ; Turn off movement
    }
    Sleep 1000
    ToolTip  ; Clear tooltip
    return

; Movement pattern logic
AutoMove:
    Random, moveDir, 1, 4  ; Randomize movement direction
    MoveInDirection(moveDir)
    return

; Function for directional movement using W, A, S, D while staying within boundary
MoveInDirection(dir) {
    MouseGetPos, currentX, currentY  ; Get current position of the character

    ; Check if the character is within the boundary before moving
    if (dir = 1 && currentY > minY)  ; Move forward (W) only if within boundary
        Send {w down}, Sleep 1000, Send {w up}
    else if (dir = 2 && currentX > minX)  ; Move left (A) only if within boundary
        Send {a down}, Sleep 1000, Send {a up}
    else if (dir = 3 && currentY < maxY)  ; Move backward (S) only if within boundary
        Send {s down}, Sleep 1000, Send {s up}
    else if (dir = 4 && currentX < maxX)  ; Move right (D) only if within boundary
        Send {d down}, Sleep 1000, Send {d up}
}

; Toggle auto-collect buffs and auto-click when pressing "C"
$c::
    isAutoCollecting := !isAutoCollecting  ; Toggle the state
    if isAutoCollecting
    {
        ToolTip Auto-collect and Auto-click Enabled
        SetTimer, AutoCollectBuffs, 500  ; Search for buffs every 500ms
        SetTimer, RotateCamera, 100  ; Rotate camera while searching
        SetTimer, AutoClick, 100  ; Enable auto-clicking every 100ms
    }
    else
    {
        ToolTip Auto-collect and Auto-click Disabled
        SetTimer, AutoCollectBuffs, Off
        SetTimer, RotateCamera, Off
        SetTimer, AutoClick, Off  ; Turn off auto-clicking
    }
    Sleep 1000
    ToolTip  ; Clear tooltip
    return

; Function to search for buffs and right-click
SearchAndClick(imagePath, tolerance := 100) {
    ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%tolerance% %imagePath%
    if (ErrorLevel = 0)  ; Image found
    {
        MouseMove, foundX, foundY  ; Move mouse to the found location
        Click right  ; Right-click to collect the buff
        return true  ; Return true if image was found and clicked
    }
    return false  ; Return false if image was not found
}

; Logic to auto-collect buffs
AutoCollectBuffs:
    ; List of buffs to search for
    images := ["Buff 1.png", "Buff 2.png"]  ; Add more as needed

    ; Loop through each buff image and search
    for index, image in images
    {
        fullPath := A_ScriptDir . "\" . image  ; Build the full path to the image
        if (SearchAndClick(fullPath))  ; Call the function for each image
        {
            ; If a buff is found, stop rotating the camera
            SetTimer, RotateCamera, Off
            return  ; Exit if any buff was found and clicked
        }
    }

    ; If no buffs are found, move using W, A, S, D, and return to the original position
    MoveInWASDAndReturn()
    return

; Function to move in random W, A, S, D directions and return to original position
MoveInWASDAndReturn() {
    ; Save the current mouse position
    MouseGetPos, initialX, initialY

    ; Choose a random movement direction (W, A, S, D)
    Random, moveDir, 1, 4
    MoveInDirection(moveDir)  ; Move within boundary

    ; After moving, return to the original mouse position
    MouseMove, initialX, initialY, 50  ; Move back to the original position
}

; Function to rotate the camera view with a single right-click
RotateCamera:
    ; Simulate a single right-click without holding it down
    Click right
    MouseMove, 10, 0, 0, R  ; Move the mouse slightly to the right (adjust as needed)
    Sleep 10  ; Adjust the speed of rotation
    return

; Stop all actions when pressing "X"
$x::
    isAutoClicking := false
    isAutoMoving := false
    isAutoCollecting := false
    SetTimer, AutoClick, Off
    SetTimer, AutoMove, Off
    SetTimer, AutoCollectBuffs, Off
    SetTimer, RotateCamera, Off
    ToolTip Script Stopped
    Sleep 1000
    ToolTip  ; Clear tooltip
    return
