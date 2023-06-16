# Steam Auto Login

#### Description
This script allows easy switching between Steam accounts on the local machine.

![Steam Auto Login Screenshot](https://github.com/uniflare/SteamAutoLogin/blob/master/screenshot.jpg?raw=true)

#### Features
* Simple Batch file for less dependencies
  * Paths and settings should be configured at the beginning of the script file
* Easily add and remove accounts
  * Accounts listed inside the batch file
* Choice of raw passwords or the [Dashlane CLI](https://github.com/uniflare/dashlane-c-cli) for secure password retrieval
  * Dashlane must be configured with `save-master-password` and the vault must be synchronized already
* Generates an AutoHotkey script that is called to write the username and password directly in the Steam login window

#### Requirements
* [Dashlane CLI](https://github.com/uniflare/dashlane-c-cli)
* [AutoHotkey](https://www.autohotkey.com/)