{
  Tags.dll written by Wraith, 2k5-2k6
  Delphi Wrapper written by Chris Troesken
  Dynamic_Tags.pas ritten by Wishmaster
}

unit Dynamic_Tags;

interface

uses
  Windows;

var
   TAGS_Read:function(handle: DWORD; const fmt: PAnsiChar): PAnsiChar; stdcall;
   TAGS_GetLastErrorDesc:function: PAnsiChar; stdcall;
   TAGS_GetVersion:function(): DWORD; stdcall;

var
   BASSTAGS_Handle:Thandle = 0;

   Function Load_BASSTAGSDLL(const dllfilename : string) : boolean;
   Procedure Unload_BASSTAGSDLL;

implementation

Function Load_BASSTAGSDLL(const dllfilename : string) : boolean;
var
   oldmode : integer;
begin
  if BASSTAGS_Handle <> 0 then // is it already there ?
   Result := true
  else
   begin {go & load the dll}
     oldmode := SetErrorMode($8001);
   {$IFDEF UNICODE}
     BASSTAGS_Handle:= LoadLibraryW(PWideChar(dllfilename));
   {$ELSE}
     BASSTAGS_Handle:= LoadLibrary(PChar(dllfilename));
   {$ENDIF}
     SetErrorMode(oldmode);
    if BASSTAGS_Handle <> 0 then
     begin
      @TAGS_Read:= GetProcAddress(BASSTAGS_Handle, Pchar('TAGS_Read'));
      @TAGS_GetLastErrorDesc:= GetProcAddress(BASSTAGS_Handle, Pchar('TAGS_GetLastErrorDesc'));
      @TAGS_GetVersion:= GetProcAddress(BASSTAGS_Handle, Pchar('TAGS_GetVersion'));

  if (@TAGS_Read = nil) or
     (@TAGS_GetLastErrorDesc = nil) or
     (@TAGS_GetVersion = nil) then
     begin
      FreeLibrary(BASSTAGS_Handle);
      BASSTAGS_Handle := 0;
     end;
    end;
   result := (BASSTAGS_Handle <> 0);
 end;
end;


Procedure Unload_BASSTAGSDLL;
begin
  if BASSTAGS_Handle <> 0 then
  FreeLibrary(BASSTAGS_Handle);
  BASSTAGS_Handle := 0;
end;



end.

