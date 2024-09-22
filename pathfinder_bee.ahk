; Define global variables for image boundaries
boundaryX := 0
boundaryY := 0
boundaryWidth := 0
boundaryHeight := 0
isPriorityBuffActive := false  ; Initialize the priority buff status

; Set default boundary limits
minX := 100  ; Minimum X boundary
maxX := 800  ; Maximum X boundary
minY := 100  ; Minimum Y boundary
maxY := 600  ; Maximum Y boundary

; Define a timeout variable for buff searching
buffTimeout := 5000  ; Timeout in milliseconds
buffStartTime := 0

; Timer for pressing key [1]
SetTimer, PressOne, 3500  ; Press [1] every 3.5 seconds

; Toggle auto-click when pressing "F"
$f::
    isAutoClicking := !isAutoClicking  ; Toggle state
    ToolTip % isAutoClicking ? "Auto-clicking Enabled" : "Auto-clicking Disabled"
    SetTimer, AutoClick, % isAutoClicking ? 50 : "Off"  ; Faster auto-click
    Sleep 1000
    ToolTip  ; Clear tooltip
    return

; Auto-click logic
AutoClick:
    Click
    return

; Toggle automatic movement when pressing "Z"
$z::
    isAutoMoving := !isAutoMoving  ; Toggle state
    ToolTip % isAutoMoving ? "Auto-moving Enabled" : "Auto-moving Disabled"
    SetTimer, AutoMove, % isAutoMoving ? 500 : "Off"  ; Faster auto-move
    Sleep 1000
    ToolTip  ; Clear tooltip
    return

; Random movement logic
AutoMove:
    Random, moveDir, 1, 4  ; Randomize movement direction
    MoveInDirection(moveDir)
    return

; Function for directional movement while staying within boundaries
MoveInDirection(dir) {
    MouseGetPos, currentX, currentY  ; Get current position

    ; Determine boundaries to use (image or default)
    if (boundaryWidth > 0 && boundaryHeight > 0) {  ; If image boundaries are defined
        validMove := (currentY > boundaryY) ? (dir = 1) : (currentX > boundaryX && dir = 2) ? (currentY < (boundaryY + boundaryHeight) && dir = 3) : (currentX < (boundaryX + boundaryWidth) && dir = 4)
    } else {
        validMove := (currentY > minY && dir = 1) || (currentX > minX && dir = 2) || (currentY < maxY && dir = 3) || (currentX < maxX && dir = 4)
    }

    if (validMove) {
        ; Simulate movement using W, A, S, D with faster response
        Send % (dir = 1) ? "{w down}{w up}" : (dir = 2) ? "{a down}{a up}" : (dir = 3) ? "{s down}{s up}" : "{d down}{d up}"
        Sleep 50  ; Small delay for better fluidity
    }
}

; Press key [1]
PressOne:
    Send {1}  ; Press key [1]
    return

; Toggle auto-collect buffs and auto-click when pressing "C"
$c::
    isAutoCollecting := !isAutoCollecting  ; Toggle state
    ToolTip % isAutoCollecting ? "Auto-collect and Auto-click Enabled" : "Auto-collect and Auto-click Disabled"
    SetTimer, AutoCollectBuffs, % isAutoCollecting ? 250 : "Off"  ; Faster buff collection
    SetTimer, RotateCamera, % isAutoCollecting ? 50 : "Off"  ; Faster camera rotation
    SetTimer, AutoClick, % isAutoCollecting ? 50 : "Off"  ; Faster auto-click
    buffStartTime := A_TickCount  ; Reset the timer
    Sleep 1000
    ToolTip  ; Clear tooltip
    return

; Set boundary from image
SetBoundaryFromImage(imagePath, tolerance := 100) {
    ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%tolerance% %imagePath%
    if (ErrorLevel = 0) {  ; Image found
        ; Assuming you know the size of the image
        imageWidth := 500  ; Replace with actual width
        imageHeight := 400  ; Replace with actual height
        
        ; Set boundary values
        global boundaryX, boundaryY, boundaryWidth, boundaryHeight  ; Make variables global
        boundaryX := foundX
        boundaryY := foundY
        boundaryWidth := imageWidth
        boundaryHeight := imageHeight
        return true
    }
    return false
}

; Function to search for buffs and determine movement direction
SearchAndClick(imagePath, tolerance := 100) {
    ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%tolerance% %imagePath%
    if (ErrorLevel = 0) {  ; Image found
        ; Check if the found image is "notbuff.png"
        if (imagePath = A_ScriptDir . "\notbuff.png") {
            return false  ; Ignore this buff
        }
        
        ; Hover over the buff for a maximum of 5 seconds
        HoverOverBuff(foundX, foundY)
        Click right  ; Right-click to collect buff
        return true
    }
    return false
}

; Hover over the buff for up to 5 seconds
HoverOverBuff(foundX, foundY) {
    MouseGetPos, initialX, initialY  ; Get the original position
    MouseMove, foundX, foundY, 0  ; Move to the buff
    Sleep 5000  ; Wait for 5 seconds or until the buff disappears
    MouseMove, initialX, initialY, 0  ; Return to original position
}

; Logic to auto-collect buffs
AutoCollectBuffs:
    ; Check for timeout
    if (A_TickCount - buffStartTime > buffTimeout) {
        MoveInWASDAndReturn()  ; Move randomly if timeout reached
        buffStartTime := A_TickCount  ; Reset the timer
        return
    }

    ; Search for boundary image first
    boundaryImage := "boundary.webp"  ; Image used for boundaries
    SetBoundaryFromImage(boundaryImage)

    ; Priority image to search for
    priorityImage := "PriorityBuff.png"
    images := ["Buff 1.png", "Buff 2.png", "Buff 3.png", "Buff 4.png", "Buff 5.png", "Buff 6.png", "Buff 7.png", "Buff 8.png", "Buff 9.png", "Buff 10.png", "Buff 11.png", "Buff 12.png", "Buff 13.png", "Buff 14.png", "Buff 15.png"]  ; Other buff images

    ; Check if priority buff is found
    fullPath := A_ScriptDir . "\" . priorityImage
    if (SearchAndClick(fullPath)) {  ; If priority buff is found
        isPriorityBuffActive := true  ; Set flag to indicate the priority buff is active
        SetTimer, RotateCamera, Off
        buffStartTime := A_TickCount  ; Reset the timer
        return
    }

    ; If the priority buff is not found, check if it was previously active
    if (isPriorityBuffActive) {
        ; If the priority buff was active and is no longer found, search for other buffs
        isPriorityBuffActive := false  ; Reset the flag
        ; Search for other buffs if the priority is not found
        for index, image in images {
            fullPath := A_ScriptDir . "\" . image
            if (SearchAndClick(fullPath)) {  ; If any buff is found
                SetTimer, RotateCamera, Off
                buffStartTime := A_TickCount  ; Reset the timer
                return
            }
        }
    }

    ; If no buffs are found, move randomly
    MoveInWASDAndReturn()
    return

; Move in random W, A, S, D directions and return to original position
MoveInWASDAndReturn() {
    MouseGetPos, initialX, initialY  ; Save current mouse position
    Random, moveDir, 1, 4
    MoveInDirection(moveDir)  ; Move within boundary
    MouseMove, initialX, initialY, 0  ; Return to original position
}

; Rotate camera view with a single right-click
RotateCamera:
    Click right  ; Simulate right-click
    MouseMove, 10, 0, 0, R  ; Move slightly to the right
    Sleep 5  ; Adjust speed of rotation
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
    SetTimer, PressOne, Off
    ToolTip Script Stopped
    Sleep 1000
    ToolTip  ; Clear tooltip
    return
