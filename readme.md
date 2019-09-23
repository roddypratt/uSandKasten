# Sandkasten: useful routines for Delphi programmes

From https://stefan.huberdoc.at/en/sandkasten-useful-routines-for-delphi-programmes/
## Abstract
Collection of Delphi (I am using Version 5) routines by Stefan Kügler (né Huber)
## Licence
uSandkasten is freeware that comes without any warranty or support. Thus you use it at your own risk. You may even use it in commercial products as long as you don’t charge your customers for the added value.
Not all routines are written by myself. Credit is given in the source file where it is due.
Important note: The current version fixes a bug in TGetOpt when treating long options that have short equivalences. And another one when creating TLogFileStreams and truncating files.

## Installation
No installation needed: Just copy the units to your Delphi library directories or into your project directory. I recommend using a dedicated directory for the Sandkasten, though. You’ll have to add the path to it to Delpih’s or your project’s library paths.

Note: I split the unit up into several pieces. The reasoning behind this was that I wrote a console application where I didn’t want to have the forms and comctrls units. If you need specific parts, just use the subunits:

* `uSandkastenBase` for basic routines without user interface stuff. Like the GNU-getopt-like command line parsing class TGetopt.
* `uSandkastenGUI` for routines requiring the units forms and comctrls.
* `uSandkastenNet` for routines requiring winsock.

Or just use uSandkasten which combines all of them, if you’re in a large project with all those units anyway.

## Contents
These are the routines that are implemented in my uSandkasten, grouped by their appearance in the various sub-units.

### `uSandkastenBase`
* `CreateTempfile`: The recommended way to create a temporary file
* `DigitStrToDigitWords`
* `EscapeString` and `UnescapeString`: Encode and unencode strings like you know it from Unix (\a, \b, \t, \n, \v, \f, \r, \\ and \xXX (hex notation))
* `ExpressStringPart` handles strings that are separated by a specific character or string and returns a given part
* `GetBuildInfo` retrieves the version numbers from a file
* `GetComputerName`
* `GetEnvironmentString`
* `HTMLEntityDecode` and `HTMLEntityEncode` handles potentially dangerous (for HTML) characters
* `LanguageNameFromCode` looks into the registry and returns the local name of the language determined by an ISO shortcut (en -> English)
* `NumberToStr`, `StrToNumber`: Convert numbers from/to any number system with a basis from 1 to 36. Thanks to Christian Nineberry Schwarz.
* `UrlEncode`, `UrlDecode`
* `RandomPassword`: create easily rememberable passwords. This is the same algorithm as shown on my randompassword web site.
* `StringToStream` and `StreamToString`
* `WinExecAndWait32`: Execute a program and wait for its return. A routine that improves some routines that I found on the internet.
* `TLogFileStream`: file stream to create log files without buffering
* German variants to convert numbers into words: 10 → zehn
* `RearMatch`: checks, if a string ends with a given substring
* `TGetOpt` implements a getopt variant for Delphi. It is nearly POSIX compatible, supporting long options, required, optional and no arguments

### `uSandkastenGUI`
* `ColorLightness`: Get lightness of colour
* Set and Load RTF source for/from a `TRichEdit`
* `ColorToHexStr` and `HexStrToColor`: convert TColor into a hex representation of it and vice versa
* `ColorToHSV` and `HSVToColor`
* `ShowMyMessage`: Replacement for `ShowMessage`: Without using dialogs.pas
* `MyMessageBox`: Replacement for MessageBox: Accepts strings and has `MB_APPLMODAL` or `MB_TASKMODAL` as default setting. The reason I use this is GNU gettext and the problems when having PChars for that.

### `uSandkastenNet`
* easy `getHostByName` and `getHostByAddr`
