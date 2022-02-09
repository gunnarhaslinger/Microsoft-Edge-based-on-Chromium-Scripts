### Read Microsoft Edge (based on Chromium) Bookmarks (JSON File) and Export/Backup to HTML-File (Edge/Firefox/Chrome compatible Format)
### Gunnar Haslinger,  works at least width Edge (based on Chromium) Beta 78 (tested on 30.10.2019) up to Edge Stable v98 (tested on 09.02.2022)
### Contributions by: SCCMOG - Richie Schuster, https://github.com/SCCMOG - SCCMOG.com
### Latest Version and a list of all contributors, see: https://github.com/gunnarhaslinger/Microsoft-Edge-based-on-Chromium-Scripts

### Definitions
$EdgeStable="Edge"
$EdgeBeta="Edge Beta"
$EdgeDev="Edge Dev"
$ExportedTime = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'

### Choose the Edge Release ($EdgeStable, $EdgeBeta, $EdgeDev) you like to Backup:
$EdgeRelease=$EdgeStable

### Path to Edge Bookmarks Source-File
$JSON_File_Path = "$($env:localappdata)\Microsoft\$($EdgeRelease)\User Data\Default\Bookmarks"

### Directory where to store HTML-Export (Backup-Destination-Directory)
#$HTML_File_Dir = "C:\Temp"
#$HTML_File_Dir = "$($env:userprofile)\backup"
#$HTML_File_Dir = "$($env:userprofile)"
$HTML_File_Dir = "$($env:userprofile)\Documents"

### Filename of HTML-Export (Backup-Filename), choose with YYYY-MM-DD_HH-MM-SS Date-Suffix or fixed Filename
#$HTML_File_Path = "$($HTML_File_Dir)\EdgeChromium-Bookmarks.backup.html"
$HTML_File_Path = "$($HTML_File_Dir)\EdgeChromium-Bookmarks.backup_$($ExportedTime).html"

## Reference-Timestamp needed to convert Timestamps of JSON (Milliseconds / Ticks since LDAP / NT epoch 01.01.1601 00:00:00 UTC) to Unix-Timestamp (Epoch)
$Date_LDAP_NT_EPOCH = Get-Date -Year 1601 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0

if (!(Test-Path -Path $JSON_File_Path -PathType Leaf)) {
    throw "Source-File Path $JSON_File_Path does not exist!" 
}
if (!(Test-Path -Path $HTML_File_Dir -PathType Container)) { 
    throw "Destination-Directory Path $HTML_File_Dir does not exist!" 
}

# ---- HTML Header ----
$BookmarksHTML_Header = @'
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
'@

$BookmarksHTML_Header | Out-File -FilePath $HTML_File_Path -Force -Encoding utf8

# ---- Enumerate Bookmarks Folders ----
Function Get-BookmarkFolder {
    [cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        $Node 
    )
    function ConvertTo-UnixTimeStamp {
        param(
            [Parameter(Position = 0, ValueFromPipeline = $True)]
            $TimeStamp 
        )
        $date = [Decimal] $TimeStamp
        if ($date -gt 0) { 
            # Timestamp Conversion: JSON-File uses Timestamp-Format "Ticks-Offset since LDAP/NT-Epoch" (reference Timestamp, Epoch since 1601 see above), HTML-File uses Unix-Timestamp (Epoch, since 1970)																																																   
            $date = $Date_LDAP_NT_EPOCH.AddTicks($date * 10) # Convert the JSON-Timestamp to a valid PowerShell date
            # $DateAdded # Show Timestamp in Human-Readable-Format (Debugging-purposes only)																					
            $date = $date | Get-Date -UFormat %s # Convert to Unix-Timestamp
            $unixTimeStamp = [int][double]::Parse($date) - 1 # Cut off the Milliseconds
            return $unixTimeStamp
        }
    }   
    if ($node.name -like "Favorites Bar") {
        $DateAdded = [Decimal] $node.date_added | ConvertTo-UnixTimeStamp
        $DateModified = [Decimal] $node.date_modified | ConvertTo-UnixTimeStamp
        "        <DT><H3 FOLDED ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`" PERSONAL_TOOLBAR_FOLDER=`"true`">$($node.name )</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
        "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
    }
    foreach ($child in $node.children) {
        $DateAdded = [Decimal] $child.date_added | ConvertTo-UnixTimeStamp    
        $DateModified = [Decimal] $child.date_modified | ConvertTo-UnixTimeStamp
        if ($child.type -eq 'folder') {
            "        <DT><H3 ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`">$($child.name)</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
            "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
            Get-BookmarkFolder $child # Recursive call in case of Folders / SubFolders
            "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
        }
        else {
            # Type not Folder => URL
            "        <DT><A HREF=`"$($child.url)`" ADD_DATE=`"$($DateAdded)`">$($child.name)</A>" | Out-File -FilePath $HTML_File_Path -Append -Encoding utf8
        }
    }
    if ($node.name -like "Favorites Bar") {
        "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
    }
}

# ---- Convert the JSON Contens (recursive) ----
$data = Get-content $JSON_File_Path -Encoding UTF8 | out-string | ConvertFrom-Json
$sections = $data.roots.PSObject.Properties | Select-Object -ExpandProperty name
ForEach ($entry in $sections) { 
    $data.roots.$entry | Get-BookmarkFolder
}

# ---- HTML Footer ----
'</DL>' | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
