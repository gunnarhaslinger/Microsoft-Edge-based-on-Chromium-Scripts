# Microsoft-Edge-based-on-Chromium-Scripts
Scripts for (new) Microsoft Edge (based on Chromium): Backup Favorites / Bookmarks, Modify Settings, ...

## Backup-Script for Edge Bookmarks (Favorites) into an HTML File
* PowerShell-Script `EdgeChromium-Bookmarks-Backup-JSON-to-HTML.ps1`
* Takes the Bookmarks of the Edge (based on Chromium) Default-Profile and creates a HTML-File
* HTML-File (Backup) is compatible to import in old Edge (EdgeHTML), FireFox, Chrome, ...
* Usable to automate Edge Bookmarks Backup into a compatible HTML Format
* I tried to file a Feature-Request to Microsoft for having such thing as as Default-Feature, but up to now no luck, if you like to join the Discussion, here is the Thread: https://techcommunity.microsoft.com/t5/Discussions/Automate-Edge-Favorites-Backup-as-HTML-File/m-p/966968

## Script for Disabling the EdgeChromium "First Run Experience"
* PowerShell-Script `EdgeChromium-FirstRunExperience.ps1`
* Disables the "First Run Experience" (FRU) which shows a "Welcome, glad you are here" Screen on first Start of Edge (based on Chromium)
* This "First Run Experience" is displayed when you start your Edge Browser the first time after installation, or after Upgrading to Edge v78 or higher (this "Feature" was introduced in v78)
* Technically the "has_user_seen_fre=true" Setting in the Edge Settings-File (JSON-File) has to be set
* This scripts either creates a new (empty) Profile having this Settings configured or modifies the existing profile (if existing)
* I tried to file a Feature-Request to Microsoft for having a Policy to Configure this unwanted behaviour, but up to now no luck, if you like to join the Discussion, here is the Thread: https://techcommunity.microsoft.com/t5/Enterprise/Edge-v78-asks-User-on-first-start-which-New-Tab-Design-to-choose/m-p/909174
