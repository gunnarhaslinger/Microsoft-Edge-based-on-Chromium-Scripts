# Read EdgeChromium Bookmarks (JSON File) and Export/Backup to HTML File
# Gunnar Haslinger, 30.10.2019 - tested width EdgeChromium Beta 78

# Path to EdgeChromium Bookmarks File and HTML Export
$JSON_File_Path = "$env:localappdata\Microsoft\Edge Beta\User Data\Default\Bookmarks"
if (!(Test-Path -Path $JSON_File_Path)) { throw "Source-File Path $JSON_File_Path does not exist!" }

$HTML_File_Path = "$env:userprofile\backup"
if (!(Test-Path -Path $HTML_File_Path)) { throw "Destination-Path $HTML_File_Path does not exist!" }
$HTML_File_Path = "$HTML_File_Path\EdgeChromium-Bookmarks.backup.html"

# Reference-Timestamp needed to convert Timestamps of JSON (Milliseconds / Ticks since LDAP / NT epoch 01.01.1601 00:00:00 UTC) to Unix-Timestamp (Epoch)
$Date_LDAP_NT_EPOCH = Get-Date -Year 1601 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0

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
[cmdletbinding()] Param( [Parameter(Position=0,ValueFromPipeline=$True)] $Node )

  Process {
     foreach ($child in $node.children) { 
       $DateAdded = [Decimal] $child.date_added
           if ($DateAdded -gt 0) { 
                # Timestamp Conversion: JSON-File uses Timestamp-Format "Ticks-Offset since LDAP/NT-Epoch" (reference Timestamp, Epoch since 1601 see above), HTML-File uses Unix-Timestamp (Epoch, since 1970)
                $DateAdded = $Date_LDAP_NT_EPOCH.AddTicks($DateAdded * 10) # Get the JSON-Timestamp to a valid PowerShell DATE
                # $DateAdded # Show Timestamp in Human-Readable-Format (Debugging-purposes only)
                $DateAdded = $DateAdded | Get-Date -UFormat %s # Convert to Unix-Timestamp
                $DateAdded = [int][double]::Parse($DateAdded) - 1 # Cut off the Milliseconds
            }

       $DateModified = [Decimal] $child.date_modified
           if ($DateModified -gt 0) { # same conversion needed as above
                $DateModified = $Date_LDAP_NT_EPOCH.AddTicks($DateModified * 10)
                # $DateModified # Show Timestamp in Human-Readable-Format (Debugging-purposes only)
                $DateModified = $DateModified | Get-Date -UFormat %s
                $DateModified = [int][double]::Parse($DateModified) - 1
            }

       # Type folder or url?
       if ($child.type -eq 'folder') 
           { "        <DT><H3 FOLDED ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`">$($child.name)</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
             "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
             Get-BookmarkFolder $child # Recursive call in case of Folders / SubFolders
             "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
           }
       else # Type not Folder => URL
           { "        <DT><A HREF=`"$($child.url)`" ADD_DATE=`"$($DateAdded)`">$($child.name)</A>" | Out-File -FilePath $HTML_File_Path -Append -Encoding utf8
           }
     } # foreach
  } # Process
} # Function

# ---- Convert the JSON Contens (recursive) ----
$data = Get-content $JSON_File_Path -Encoding UTF8 | out-string | ConvertFrom-Json
$sections = $data.roots.PSObject.Properties | select -ExpandProperty name
ForEach ($entry in $sections) { $data.roots.$entry | Get-BookmarkFolder }

# ---- HTML Footer ----
'</DL>' | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
