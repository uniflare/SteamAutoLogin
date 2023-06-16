@ECHO off
SETLOCAL ENABLEDELAYEDEXPANSION

REM This script will start and automatically pass the 
REM selected credentials to the steam application. This 
REM also allows multiple accounts (up to 243)
REM make sure your config is set correctly below

REM ======== STEAM CONFIGURATION =========
REM Path to Steam.exe - Must be surrounded with double quotes. Example: "C:\Program Files (x86)\Steam\Steam.exe"
SET SteamPath="C:\Program Files (x86)\Steam\Steam.exe"

REM Command line options to pass to steam
SET CMDLineOptions=-nofriendsui -nochatui -silent
REM ======================================

REM ======= DASHLANE CONFIGURATION =======
REM Use Dashlane instead of raw passwords
SET UseDashlane=FALSE

REM Path to dashlane-cli exe - Must be surrounded with double quotes. Example: "C:\Program Files\DashlaneCLI\dashlane-cli.exe"
SET DashlaneCLI="C:\Program Files\DashlaneCLI\dashlane-cli.exe"

REM Email for Dashlane CLI
SET DashlaneEmail=

REM Note:
REM     Using Dashlane assumes the master password
REM     is stored using the CLI keychain with: 
REM         (configure save-master-password)
REM     and that the vault has been synchronized.
REM ======================================

REM Add usernames below, increment the index by 1 for each set added
REM No gaps in the indexes and MUST start at 1. 
REM The Index is the number inside the square brackets.

REM NOTE: Careful what characters you use;
REM Check http://www.robvanderwoude.com/escapechars.php for details.

REM ======= ADD/REMOVE ACCOUNTS BELOW ========
REM ======= ADD/REMOVE ACCOUNTS BELOW ========
REM ======= ADD/REMOVE ACCOUNTS BELOW ========
REM ======= ADD/REMOVE ACCOUNTS BELOW ========

SET SteamUsernames[1]=username1
SET DashlaneTitles[1]=Dashlane Password Title 1
SET AccountDescs[1]=A short description
SET SteamPasswords[1]=

SET SteamUsernames[2]=username2
SET DashlaneTitles[2]=Dashlane Password Title 2
SET AccountDescs[2]=Another short description
SET SteamPasswords[2]=

REM ======= DO NOT MODIFY BELOW THIS LINE ========
REM ======= DO NOT MODIFY BELOW THIS LINE ========
REM ======= DO NOT MODIFY BELOW THIS LINE ========
REM ======= DO NOT MODIFY BELOW THIS LINE ========

CALL :Start
PAUSE
GOTO :EOF

:Start
CALL :Verify
SET "ErrorMessage="
IF "%1" == "" (
    CALL %0 GetScript > temp_login_script.ahk
    CALL :BeginRuntime
    ping -n 2 127.0.0.1 >nul
    DEL temp_login_script.ahk
) ELSE (
    CALL :PrintAutoHotkeyScript %0
)
GOTO :EOF

:Verify
IF NOT EXIST %SteamPath% (
    ECHO Error: Cannot find Steam executable
    ECHO Tried %SteamPath%
    PAUSE
    EXIT
)

IF "%UseDashlane%" == "TRUE" (
    IF NOT EXIST %DashlaneCLI% (
        ECHO Error: Cannot find Dashlane CLI executable
        ECHO Tried %DashlaneCLI%
		PAUSE
        EXIT
    )
    IF "%DashlaneEmail%" == "" (
        ECHO Error: Dashlane email not set
		PAUSE
        EXIT
    )
)

GOTO :EOF

:BeginRuntime
CLS
ECHO ##############################
ECHO #                            #
ECHO #   Steam Auto Login Batch   #
ECHO #                            #
ECHO ##############################
ECHO.
ECHO Registered steam accounts:
ECHO.

SET "x=1"
SET "xx=1"
SET choicestring=
:Loop
IF DEFINED SteamUsernames[%x%] (
    SET choicestring=%choicestring%%xx%
    CALL ECHO %xx%. %%SteamUsernames[%x%]%% ^(%%AccountDescs[%x%]%%^)
    SET /A "xx+=1"
    SET /A "x+=1"
    GOTO :Loop
)
SET choicestring=%choicestring%0
SET "QuitIdx=%xx%"

ECHO.
ECHO 0. Quit
ECHO.

IF NOT "%ErrorMessage%"=="" (
    ECHO Error: %ErrorMessage%
    ECHO.
)

:LoginChoice
CHOICE /c %choicestring% /n /m "Choose an account to login with: "
SET userchoice=%errorlevel%
IF %userchoice%==255 GOTO BeginRuntime
IF %userchoice%==0 GOTO BeginRuntime
IF %userchoice%==!QuitIdx! GOTO :EOF

SET SteamUsername=!SteamUsernames[%userchoice%]!
SET DashlaneTitle="!DashlaneTitles[%userchoice%]!"

IF "%SteamUsername%"=="" (
    SET "ErrorMessage=Invalid user choice."
    GOTO :BeginRuntime
)

REM Use Dashlane if the Dashlane email has been set
IF "%UseDashlane%"=="TRUE" (
    SET Command=%DashlaneCLI% --email %DashlaneEmail% p --output password %DashlaneTitle%
    FOR /F "TOKENS=* USEBACKQ" %%g IN (`"!Command!"`) do ( SET "SteamPassword=%%g" )
) ELSE (
	SET SteamPassword=!SteamPasswords[%userchoice%]!
)

IF "!SteamPassword!"=="" (
    SET "ErrorMessage=Password not found for user %SteamUsername%."
    GOTO :BeginRuntime
)

CALL temp_login_script.ahk %SteamPath% "%SteamUsername%" "%SteamPassword%" "%CMDLineOptions%"

GOTO :EOF

:PrintAutoHotkeyScript
ECHO.WindowTitle = Sign in to Steam
ECHO.SteamPath = %%1%%
ECHO.Username = %%2%%
ECHO.Password = %%3%%
ECHO.CMDLine = %%4%%
ECHO.
ECHO.if (SteamPath = "" or Username = "" or Password = "") {
ECHO.    MsgBox,Missing One or more of Steam Path/Username/Password input.`nDo not execute this script directly.
ECHO.    exit
ECHO.}
ECHO.
ECHO.if (^^!TryRestartSteamExe(SteamPath, WindowTitle, Username, Password, CMDLine)) {
ECHO.    MsgBox,Failed to start steam
ECHO.    Tooltip
ECHO.}
ECHO.
ECHO.TryRestartSteamExe(exePath, WindowTitle, Username, Password, CMDLine) {
ECHO.    canStartSteam := false
ECHO.    startedSteam := false
ECHO.    if (IsSteamRunning()) {
ECHO.        if (TryShutdownSteam(exePath)) {
ECHO.            canStartSteam := true
ECHO.        }
ECHO.    } else {
ECHO.        canStartSteam = true
ECHO.    }
ECHO.    
ECHO.    if (canStartSteam) {
ECHO.        startedSteam := TryStartSteam(exePath, WindowTitle, CMDLine)
ECHO.    }
ECHO.    
ECHO.    if (startedSteam) {
ECHO.        WinActivate,%%WindowTitle%%
ECHO.        Send {Text}%%Username%%
ECHO.        Send {Tab}
ECHO.        Send {Text}%%Password%%
ECHO.        Send {Tab}
ECHO.        Send {Tab}
ECHO.        Send {Enter}
ECHO.        
ECHO.        return true
ECHO.    }
ECHO.    
ECHO.    return false
ECHO.}
ECHO.
ECHO.IsSteamRunning() {
ECHO.    if (ProcessExists("Steam.exe")) {
ECHO.        return true
ECHO.    }
ECHO.    
ECHO.    if (ProcessExists("steamwebhelper.exe")) {
ECHO.        return true
ECHO.    }
ECHO.    
ECHO.    return false
ECHO.}
ECHO.
ECHO.ProcessExists(processName) {
ECHO.    Process, Exist, %%processName%%
ECHO.    if (errorlevel == 0) {
ECHO.        return false
ECHO.    }
ECHO.    
ECHO.    return true
ECHO.}
ECHO.
ECHO.TryShutdownSteam(exePath) {
ECHO.    Tooltip, Waiting for Steam to shut down...
ECHO.    run,%%exePath%% -shutdown
ECHO.    
ECHO.    numSecondsTimeout := 15
ECHO.    while(IsSteamRunning()) {
ECHO.        if (numSecondsTimeout ^< 0) {
ECHO.            return false
ECHO.        }
ECHO.        sleep,1000
ECHO.        numSecondsTimeout -= 1
ECHO.    }
ECHO.    
ECHO.    return true
ECHO.}
ECHO.
ECHO.TryStartSteam(exePath, expectedWindowTitle, CMDLine) {
ECHO.    Run, %%exePath%% %%CMDLine%%
ECHO.    Tooltip, Waiting for Steam to start...
ECHO.    WinWait,%%expectedWindowTitle%%,,15
ECHO.    if (errorlevel) {
ECHO.        return false
ECHO.    } else {
ECHO.        return true
ECHO.    }
ECHO.}
GOTO :EOF