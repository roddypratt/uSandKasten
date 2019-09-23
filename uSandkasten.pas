unit uSandkasten;
{
  Author : Stefan M. Huber
  Date   : 2005-09-01
  Update : 2007-05-25
  Purpose: Collection of useful routines. If you don't need all routines, use
           the other Units: uSandkastenBase, uGetopt, uSandkastenGUI

  Credits: I did not author all these routines myself. Most of them are the
      result of news group discussions (especially de.comp.lang.delphi.misc)
      and I want to express my thankfuless.
      If a complete routine is somebody else's, credit is given in the procedure
      itself.
}

interface

uses windows, classes, Sysutils, graphics, comctrls, inifiles, registry, forms;

{$I uSandkastenBase-header.pas}
{$I uSandkastenGUI-header.pas}
{$I uSandkastenNet-header.pas}

implementation

uses winsock;

{$I uSandkastenBase-impl.pas}
{$I uSandkastenGUI-impl.pas}
{$I uSandkastenNet-impl.pas}



end.



