# EdgeChromium - Disable First Run Experience (mark First Run Experiance FRU as Seen)
# Gunnar Haslinger, 12.11.2019 - tested width EdgeChromium Beta 79

# Define LocalAppData Folder
$LocalAppData = $null; if ( $env:localappdata -ne $null) { $LocalAppData = $env:localappdata }

# Config: Which Edge Branch? => "Edge Beta" or "Edge" or "Edge Dev"
$EdgeBranch="Edge Beta"

# Edge-Settings, starting with empty Hash - Import existing Settings if present
$data = @{} 

# Path to EdgeChromium Settings, create Edge-Settings-Folder if not present
if (Test-Path $LocalAppData) {
   $JSON_File_Path = "$LocalAppData\Microsoft\$EdgeBranch\User Data"; if (!(Test-Path $JSON_File_Path)) { "Creating ""$EdgeBranch"" Profile-Directory: ""$JSON_File_Path""" | Out-String; New-Item -ItemType Directory -Path $JSON_File_Path | Out-Null }
   $JSON_File_Path = "$JSON_File_Path\Local State"
} else { "ERROR: LocalAppData: ""$LocalAppData"" missing!" | Out-String; exit 1; }

if   (!(Test-Path -Path $JSON_File_Path)) { "Edge-Settings-File ""$JSON_File_Path"" does not exist, starting empty." | Out-String }
else { "Reading existing Settings-File: $JSON_File_Path" | Out-String 
       $data = Get-content $JSON_File_Path -Encoding Default | ConvertFrom-Json
     }

if ($data.Count -gt 0) {
	"# --- Existing Edge Settings --- " | Out-String
	$data | Out-String
	"-------------------------------- " | Out-String
}

if ($data.fre.has_user_seen_fre -eq "true") 
     { "Edge First Run Experience (FRE) already done, no modification needed" | Out-String 
     }
else 
     { "Edge First Run Experience (FRE) Setting is missing => Configuring: Set has_user_seen_fre=true" | Out-String

       # Whole node "fre" is Missing? => Add
       if ($data.fre -eq $null) { $data | Add-Member -Name fre -MemberType NoteProperty -Value @{has_user_seen_fre=$true} }

       # Node "fre" is present, but SubEntry "has_user_seen_fre" is missing?
       if ($data.fre.has_user_seen_fre -eq $null) { $data.fre | Add-Member -Name has_user_seen_fre -MemberType NoteProperty -Value $true; } 
       else { $data.fre.has_user_seen_fre=$true } # SubEntry "has_user_seen_fre" is present but not true => set $true

       "Writing Settings-File: $JSON_File_Path" | Out-String 
       $data | ConvertTo-Json -Depth 99 | Out-File -FilePath $JSON_File_Path -Encoding default
     }
