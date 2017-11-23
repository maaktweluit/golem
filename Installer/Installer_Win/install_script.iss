; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Golem"
#define MyAppPublisher "Golem Factory GmbH"
#define MyAppURL "https://golem.network"
#define MyAppExeName "golemapp.exe"
; NOTE: if compilation failed, make sure that this variable are set properly and golem is installed from wheel
; NOTE 2: make sure that you've got in {#Repository}\Installer\Inetaller_Win\deps:
; https://www.microsoft.com/pl-pl/download/details.aspx?id=48145 vc_redist.x64.exe
; https://www.microsoft.com/en-us/download/details.aspx?id=44266
; https://github.com/docker/toolbox/releases/download/v17.06.2-ce/DockerToolbox-17.06.2-ce.exe DockerToolbox.exe
#define Repository "C:\BuildbotWorker\buildpackage_windows\build"
#expr Exec("powershell.exe python setup.py pyinstaller", "", Repository, 1)
#expr Exec("powershell.exe python Installer\Installer_Win\version.py", "", Repository, 1)
#define MyAppVersion ReadIni(Repository+"\\.version.ini", "version", "version", "0.1.0")
#define MyAppNumber ReadIni(Repository+"\\.version.ini", "version", "number", "0.1.0")
#expr Exec("powershell.exe Remove-Item .version.ini", "", Repository, 1)
#define AppIcon "favicon.ico"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{C8E494CC-06C7-40CB-827A-20D07903013F}
AppName={#MyAppName}
AppPublisher={#MyAppPublisher}
AppVersion={#MyAppVersion}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DisableProgramGroupPage=yes
LicenseFile={#Repository}\LICENSE.txt
OutputDir={#Repository}\Installer\Installer_Win
OutputBaseFilename={#MyAppName}_win
SetupIconFile={#Repository}\Installer\{#AppIcon}
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Registry]
; Set environment variable to point to company installation
Root: "HKLM64"; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "PATH"; ValueData: "{olddata};{app}\"; Check: NeedsAddPath('Golem'); Flags: uninsdeletevalue;

; Append Docker to PATH
Root: "HKLM64"; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "PATH"; ValueData: "{olddata};{sd}\Program Files\Docker Toolbox"; Check: NeedsAddPath('Docker');

; Add OpenSSL to the PATH
Root: "HKLM64"; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "PATH"; ValueData: "{olddata};{sd}\OpenSSL"; Check: NeedsAddPath('OpenSSL');

; Add HyperG to the PATH
Root: "HKLM64"; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "PATH"; ValueData: "{olddata};{pf}\HyperG"; Check: NeedsAddPath('HyperG');

[Setup]
AlwaysRestart = yes

; @todo do we need any more languages? It can be confusing
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: "{#Repository}\dist\golem-{#MyAppNumber}\*"; DestDir: {app}; Flags: ignoreversion recursesubdirs
Source: "C:\BuildResources\win-unpacked\*"; DestDir: {app}; Flags: ignoreversion recursesubdirs
Source: "C:\BuildResources\DockerToolbox.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall;
Source: "C:\BuildResources\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall;
Source: "{#Repository}\Installer\Installer_Win\deps\OpenSSL\*"; DestDir: "{sd}\OpenSSL"; Flags: ignoreversion recursesubdirs replacesameversion;
Source: "C:\BuildResources\hyperg\*"; DestDir: "{pf}\HyperG"; Flags: ignoreversion recursesubdirs replacesameversion;
Source: "{#SetupSetting("SetupIconFile")}"; DestDir: "{app}"; Flags: ignoreversion;

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\golem.exe"; IconFilename: "{app}\{#AppIcon}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\golem.exe"; IconFilename: "{app}\{#AppIcon}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\golem.exe"; IconFilename: "{app}\{#AppIcon}"; Tasks: quicklaunchicon

[Run]
; Install runtime
Filename: "{tmp}\vc_redist.x64.exe"; StatusMsg: "Installing runtime"; Description: "Install runtime";

; Install Docker @todo is this check enough
Filename: "{tmp}\DockerToolbox.exe"; Parameters: "/VERYSILENT"; StatusMsg: "Installing Docker Toolbox"; Description: "Install Docker Toolbox"; Check: IsDockerInstalled;

[Code]
////////////////////////////////////////////////////////////////////////////////////////////////////
// This function checks the registry for an existing Docker installation
function IsDockerInstalled: boolean;
begin
   Result := not RegKeyExists(HKCU64, 'Environment\DOCKER_TOOLBOX_INSTALL_PATH' );
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
// This function will return True if the Param already exists in the system PATH
function NeedsAddPath(Param: String): Boolean;
var
  OrigPath: String;
begin
  if not RegQueryStringValue(HKLM64, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', OrigPath) then begin
    Result := True;
    exit;
  end;
  // look for the path with leading and trailing semicolon; Pos() returns 0 if not found
  Result := Pos(Param, OrigPath) = 0;
end;


////////////////////////////////////////////////////////////////////////////////////////////////////
// This method checks for presence of uninstaller entries in the registry and returns the path to the uninstaller executable.
function GetUninstallString: String;
var
  uninstallerPath: String;
  uninstallerString: String;
begin
  Result := '';
  // Get the uninstallerPath from the registry
  uninstallerPath := ExpandConstant('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{{C8E494CC-06C7-40CB-827A-20D07903013F}_is1');
  uninstallerString := '';
  // Check if uninstaller entries in registry have values in them
  if not RegQueryStringValue(HKLM64, uninstallerPath, 'UninstallString', uninstallerString) then
    RegQueryStringValue(HKCU, uninstallerPath, 'UninstallString', uninstallerString);
    // Return path of uninstaller to run
    Result := uninstallerString;
end;


////////////////////////////////////////////////////////////////////////////////////////////////////
// This method checks if a previous version has been installed
function PreviousInstallationExists : Boolean;
begin
  // Check if not equal '<>' to empty string and return result
  Result := (GetUninstallString() <> '');
end;


////////////////////////////////////////////////////////////////////////////////////////////////////
// Split string
procedure Explode(var Dest: TArrayOfString; Text: String; Separator: String);
var
  i : Integer;
  p : Integer;
begin
  i := 0;
  repeat
    SetArrayLength(Dest, i+1);
    p := Pos(Separator,Text);
    if p > 0 then begin
      Dest[i] := Copy(Text, 1, p-1);
      Text := Copy(Text, p + Length(Separator), Length(Text));
      i := i + 1;
    end else begin
      Dest[i] := Text;
      Text := '';
    end;
  until Length(Text)=0;
end;


////////////////////////////////////////////////////////////////////////////////////////////////////
// Backup path with removing Golem (fix for old bug)
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  sys_path   : String;
  tmp_string : String;
  strArray   : TArrayOfString;
  i          : Integer;
begin
  case CurUninstallStep of
    usUninstall:
      begin
        if RegQueryStringValue(HKLM64, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', sys_path) then begin
          RegWriteExpandStringValue(HKLM64, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path_backup', sys_path)
        end;
      end;
    usDone:
      begin
        if not RegValueExists(HKLM64, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path') then begin
          if RegQueryStringValue(HKLM64, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path_backup', tmp_string) then begin
            // Remove golem from backup_path
            Explode(strArray, tmp_string, ';')
            sys_path := '';
            for i:=0 to GetArrayLength(strArray)-1 do begin
              if Pos('Golem', strArray[i]) = 0 then begin
                sys_path := sys_path + strArray[i] + ';';
              end
            end;
            if RegWriteExpandStringValue(HKLM64, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', sys_path) then begin
              RegDeleteValue(HKLM64, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path_backup')
            end;
          end;
        end;
      end;
    end;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
// This Event function runs before setup is initialized
function InitializeSetup(): Boolean;
var
  uninstallChoiceResult: Boolean;
  uninstallPath : String;
  iResultCode : Integer;
  previouslyInstalledCheck : Boolean;
begin
  // Now check if previous version was installed
  previouslyInstalledCheck := PreviousInstallationExists;
  if previouslyInstalledCheck then begin
    uninstallChoiceResult := MsgBox('A previous installation was detected. Do you want to uninstall the previous version first? (Recommended)', mbInformation, MB_YESNO) = IDYES;
    // If user chooses, uninstall the previous version and wait until it has finished before allowing installation to proceed
    if uninstallChoiceResult then begin
      uninstallPath := RemoveQuotes(GetUninstallString());
      Exec(ExpandConstant(uninstallPath), '', '', SW_SHOW, ewWaitUntilTerminated, iResultCode);
      Result := True;
    end
    else begin
      Result := True;
      Exit;
    end;
  end
  else
    Result := True;
end;
