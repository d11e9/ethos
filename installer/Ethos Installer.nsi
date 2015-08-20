;NSIS Modern User Interface
;Basic Example Script
;Written by Joost Verburg

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

  ;Name and file
  Name "Ethos"
  OutFile "Ethos Installer.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\Ethos"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\Ethos" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_ICON "..\app\images\logo.ico"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "..\app\images\icon.png"
  !define MUI_HEADERIMAGE_RIGHT

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_TEXT "Run Ethos"
  !define MUI_FINISHPAGE_RUN_FUNCTION "Launch"
  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Ethos"
  SetShellVarContext all

  SectionIn RO
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  File /r "..\dist\Ethos\win32\*"
  WriteUninstaller $INSTDIR\Uninstall.exe

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Ethos" \
    "DisplayName" "Ethos"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Ethos" \
    "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""

SectionEnd


Section "Start Menu Shortcut"

  CreateShortCut "$SMPROGRAMS\Ethos.lnk" "$INSTDIR\Ethos.exe"

SectionEnd

Section "Desktop Shortcut"

  CreateShortCut "$DESKTOP\Ethos.lnk" "$INSTDIR\Ethos.exe"

SectionEnd


Section "Launch at Startup"

   WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Run" "Ethos" "$INSTDIR\Ethos.exe"

SectionEnd

Function Launch
  ExecShell "" "$INSTDIR\Ethos.exe"
FunctionEnd

;--------------------------------
;Descriptions


;--------------------------------
;Uninstaller Section

Section "Uninstall"
  SetShellVarContext all

  Delete "$INSTDIR\Uninstall.exe"
  Delete "$DESKTOP\Ethos.lnk"
  Delete "$SMPROGRAMS\Ethos.lnk"

  RMDir /r "$INSTDIR"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Ethos"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Run" "Ethos" ""

  DeleteRegKey /ifempty HKCU "Software\Ethos"

SectionEnd