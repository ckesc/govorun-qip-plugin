{
  BASSCD v2.4.5 - 12/5/2011 Delphi API, copyright (c) 2003-2006 Ian Luck.
  Requires BASS 2.4 - available from www.un4seen.com

  See the BASSCD.CHM file for more complete documentation

  written by Wishmaster
}


unit Dynamic_Basscd;

interface

uses Windows, Dynamic_Bass;

const
  // Additional error codes returned by BASS_ErrorGetCode
  BASS_ERROR_NOCD       = 12; // no CD in drive
  BASS_ERROR_CDTRACK    = 13; // invalid track number
  BASS_ERROR_NOTAUDIO   = 17; // not an audio track

  // Additional BASS_SetConfig options
  BASS_CONFIG_CD_FREEOLD        = $10200;
  BASS_CONFIG_CD_RETRY          = $10201;
  BASS_CONFIG_CD_AUTOSPEED      = $10202;
  BASS_CONFIG_CD_SKIPERROR      = $10203;

  // additional BASS_SetConfigPtr options
  BASS_CONFIG_CD_CDDB_SERVER    = $10204;


  // BASS_CD_SetInterface options
  BASS_CD_IF_AUTO               = 0;
  BASS_CD_IF_SPTI               = 1;
  BASS_CD_IF_ASPI               = 2;
  BASS_CD_IF_WIO                = 3;
  BASS_CD_IF_LINUX              = 4;

  // "rwflag" read capability flags
  BASS_CD_RWFLAG_READCDR        = 1;
  BASS_CD_RWFLAG_READCDRW       = 2;
  BASS_CD_RWFLAG_READCDRW2      = 4;
  BASS_CD_RWFLAG_READDVD        = 8;
  BASS_CD_RWFLAG_READDVDR       = 16;
  BASS_CD_RWFLAG_READDVDRAM     = 32;
  BASS_CD_RWFLAG_READANALOG     = $10000;
  BASS_CD_RWFLAG_READM2F1       = $100000;
  BASS_CD_RWFLAG_READM2F2       = $200000;
  BASS_CD_RWFLAG_READMULTI      = $400000;
  BASS_CD_RWFLAG_READCDDA       = $1000000;
  BASS_CD_RWFLAG_READCDDASIA    = $2000000;
  BASS_CD_RWFLAG_READSUBCHAN    = $4000000;
  BASS_CD_RWFLAG_READSUBCHANDI  = $8000000;
  BASS_CD_RWFLAG_READISRC       = $20000000;
  BASS_CD_RWFLAG_READUPC        = $40000000;

  // additional BASS_CD_StreamCreate/File flags
  BASS_CD_SUBCHANNEL            = $200;
  BASS_CD_SUBCHANNEL_NOHW       = $400;
  BASS_CD_C2ERRORS              = $800;                                  // Added v2.4.2    (Support for C2 error info)

  // additional CD sync type
  BASS_SYNC_CD_ERROR            = 1000;
  BASS_SYNC_CD_SPEED            = 1002;

  // BASS_CD_Door actions
  BASS_CD_DOOR_CLOSE            = 0;
  BASS_CD_DOOR_OPEN             = 1;
  BASS_CD_DOOR_LOCK             = 2;
  BASS_CD_DOOR_UNLOCK           = 3;

  // BASS_CD_GetID flags
  BASS_CDID_UPC                 = 1;
  BASS_CDID_CDDB                = 2;
  BASS_CDID_CDDB2               = 3;
  BASS_CDID_TEXT                = 4;
  BASS_CDID_CDPLAYER            = 5;
  BASS_CDID_MUSICBRAINZ         = 6;
  BASS_CDID_ISRC                = $100; // + track #
  BASS_CDID_CDDB_QUERY          = $200;
  BASS_CDID_CDDB_READ           = $201; // + entry #
  BASS_CDID_CDDB_READ_CACHE     = $2FF;

  // BASS_CD_GetTOC modes
  BASS_CD_TOC_TIME              = $100;

  // BASS_CD_TOC_TRACK "adrcon" flags
  BASS_CD_TOC_CON_PRE           = 1;
  BASS_CD_TOC_CON_COPY          = 2;
  BASS_CD_TOC_CON_DATA          = 4;


    // CDDATAPROC "type" values
  BASS_CD_DATA_SUBCHANNEL       = 0;
  BASS_CD_DATA_C2               = 1;


  // BASS_CHANNELINFO type
  BASS_CTYPE_STREAM_CD          = $10200;


type
  BASS_CD_INFO = record
  vendor: PAnsiChar;      // manufacturer
  product: PAnsiChar;     // model
  rev: PAnsiChar;         // revision
  letter: Integer;    // drive letter
	rwflags: DWORD;     // read/write capability flags
	canopen: BOOL;      // BASS_CD_DOOR_OPEN/CLOSE is supported?
	canlock: BOOL;      // BASS_CD_DOOR_LOCK/UNLOCK is supported?
	maxspeed: DWORD;    // max read speed (KB/s)
	cache: DWORD;       // cache size (KB)
	cdtext: BOOL;       // can read CD-TEXT
  end;

type
  // TOC structures
  BASS_CD_TOC_TRACK = record
    res1: Byte;
    adrcon: Byte;       // ADR + control
    track: Byte;        // track number
    res2: Byte;
   case Integer of
    0 : (lba : DWORD);   // start address (logical block address)
    1 : (hmsf : Array[0..3] of BYTE); // start address (hours/minutes/seconds/frames)
   end;

type
  BASS_CD_TOC = record
    size: Word;         // size of TOC
    first: Byte;        // first track
    last: Byte;         // last track
    tracks: Array[0..99] of BASS_CD_TOC_TRACK; // up to 100 tracks
  end;




  CDDATAPROC = procedure(handle: HSTREAM; pos: Integer; type_: DWORD; buffer: Pointer; length: DWORD; user: Pointer); stdcall;
  {
    Sub-channel/C2 reading callback function.
    handle : The CD stream handle
    pos    : The position of the data
    type   : The type of data (BASS_CD_DATA_xxx)
    buffer : Buffer containing the data.
    length : Number of bytes in the buffer
    user   : The 'user' parameter value given when calling BASS_CD_StreamCreate/FileEx
  }



var 
 BASS_CD_SetInterface:function(iface:DWORD): DWORD; stdcall;
 BASS_CD_GetInfo:function(drive:DWORD; var info:BASS_CD_INFO): BOOL; stdcall;
 BASS_CD_Door:function(drive,action:DWORD): BOOL; stdcall;
 BASS_CD_DoorIsOpen:function(drive:DWORD): BOOL; stdcall;
 BASS_CD_DoorIsLocked:function(drive:DWORD): BOOL; stdcall;
 BASS_CD_IsReady:function(drive:DWORD): BOOL; stdcall;
 BASS_CD_GetTracks:function(drive:DWORD): DWORD; stdcall;
 BASS_CD_GetTrackLength:function(drive,track:DWORD): DWORD; stdcall;
 BASS_CD_GetTrackPregap:function(drive,track:DWORD): DWORD; stdcall;
 BASS_CD_GetTOC:function(drive,mode:DWORD; var toc:BASS_CD_TOC): BOOL; stdcall;
 BASS_CD_GetID:function(drive,id:DWORD): PAnsiChar; stdcall;
 BASS_CD_GetSpeed:function(drive:DWORD): DWORD; stdcall;
 BASS_CD_SetSpeed:function(drive,speed:DWORD): BOOL; stdcall;
 BASS_CD_SetOffset:function(drive:DWORD; offset:Integer): BOOL; stdcall;
 BASS_CD_Release:function(drive:DWORD): BOOL; stdcall;

 BASS_CD_StreamCreate:function(drive,track,flags:DWORD): HSTREAM; stdcall;
 BASS_CD_StreamCreateFile:function(f:PChar; flags:DWORD): HSTREAM; stdcall;
 BASS_CD_StreamCreateEx:function(drive,track,flags:DWORD; proc:CDDATAPROC; user:Pointer): HSTREAM; stdcall;
 BASS_CD_StreamCreateFileEx:function(f:PChar; flags:DWORD; proc:CDDATAPROC; user:Pointer): HSTREAM; stdcall;
 BASS_CD_StreamGetTrack:function(handle:HSTREAM): DWORD; stdcall;
 BASS_CD_StreamSetTrack:function(handle:HSTREAM; track:DWORD): BOOL; stdcall;

 BASS_CD_Analog_Play:function(drive,track,pos:DWORD): BOOL; stdcall;
 BASS_CD_Analog_PlayFile:function(f:pchar; pos:DWORD): DWORD; stdcall;
 BASS_CD_Analog_Stop:function(drive:DWORD): BOOL; stdcall;
 BASS_CD_Analog_IsActive:function(drive:DWORD): DWORD; stdcall;
 BASS_CD_Analog_GetPosition:function(drive:DWORD): DWORD; stdcall;

var
   BASSCD_Handle:Thandle = 0;

   Function Load_BASSCDDLL(const dllfilename : string) : boolean;
   procedure Unload_BASSCDDLL;


implementation

Function Load_BASSCDDLL(const dllfilename : string) : boolean;
var
   oldmode : integer;
begin
 if BASSCD_Handle <> 0 then // is it already there ?
  Result:= true
 else
   begin {go & load the dll}
    oldmode := SetErrorMode($8001);
   {$IFDEF UNICODE}
     BASSCD_Handle:= LoadLibraryW(PWideChar(dllfilename));
   {$ELSE}
     BASSCD_Handle:= LoadLibrary(PChar(dllfilename));
   {$ENDIF}
     SetErrorMode(oldmode);
    if BASSCD_Handle <> 0 then
     begin
      @BASS_CD_SetInterface:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_SetInterface'));
      @BASS_CD_GetInfo:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_GetInfo'));
      @BASS_CD_Door:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_Door'));
      @BASS_CD_DoorIsOpen:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_DoorIsOpen'));
      @BASS_CD_DoorIsLocked:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_DoorIsLocked'));
      @BASS_CD_IsReady:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_IsReady'));
      @BASS_CD_GetTracks:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_GetTracks'));
      @BASS_CD_GetTrackLength:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_GetTrackLength'));
      @BASS_CD_GetTrackPregap:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_GetTrackPregap'));
      @BASS_CD_GetTOC:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_GetTOC'));
      @BASS_CD_GetID:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_GetID'));
      @BASS_CD_GetSpeed:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_GetSpeed'));
      @BASS_CD_SetSpeed:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_SetSpeed'));
      @BASS_CD_SetOffset:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_SetOffset'));
      @BASS_CD_Release:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_Release'));
      @BASS_CD_StreamCreate:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_StreamCreate'));
      @BASS_CD_StreamCreateFile:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_StreamCreateFile'));
      @BASS_CD_StreamGetTrack:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_StreamGetTrack'));
      @BASS_CD_StreamSetTrack:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_StreamSetTrack'));
      @BASS_CD_StreamCreateEx:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_StreamCreateEx'));
      @BASS_CD_StreamCreateFileEx:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_StreamCreateFileEx'));

      @BASS_CD_Analog_Play:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_Analog_Play'));
      @BASS_CD_Analog_PlayFile:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_Analog_PlayFile'));
      @BASS_CD_Analog_Stop:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_Analog_Stop'));
      @BASS_CD_Analog_IsActive:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_Analog_IsActive'));
      @BASS_CD_Analog_GetPosition:= GetProcAddress(BASSCD_Handle, Pchar('BASS_CD_Analog_GetPosition'));


  if (@BASS_CD_SetInterface = nil) or
     (@BASS_CD_GetInfo = nil) or
     (@BASS_CD_Door = nil) or
     (@BASS_CD_DoorIsOpen = nil) or
     (@BASS_CD_DoorIsLocked = nil) or
     (@BASS_CD_IsReady = nil) or
     (@BASS_CD_GetTracks = nil) or
     (@BASS_CD_GetTrackLength = nil) or
     (@BASS_CD_GetTrackPregap = nil) or
     (@BASS_CD_GetTOC = nil) or
     (@BASS_CD_GetID = nil) or
     (@BASS_CD_GetSpeed = nil) or
     (@BASS_CD_SetSpeed = nil) or
     (@BASS_CD_SetOffset = nil) or
     (@BASS_CD_Release = nil) or
     (@BASS_CD_StreamCreate = nil) or
     (@BASS_CD_StreamCreateFile = nil) or
     (@BASS_CD_StreamCreateEx = nil) or
     (@BASS_CD_StreamCreateFileEx = nil) or

     (@BASS_CD_StreamGetTrack = nil) or
     (@BASS_CD_StreamSetTrack = nil) or
     (@BASS_CD_Analog_Play = nil) or
     (@BASS_CD_Analog_PlayFile = nil) or
     (@BASS_CD_Analog_Stop = nil) or
     (@BASS_CD_Analog_IsActive = nil) or
     (@BASS_CD_Analog_GetPosition = nil) then
     begin
      FreeLibrary(BASSCD_Handle);
      BASSCD_Handle := 0;
     end;
    end;
   Result:= (BASSCD_Handle <> 0);
 end;
end;



procedure Unload_BASSCDDLL;
begin
 if BASSCD_Handle <> 0 then
  FreeLibrary(BASSCD_Handle);
  BASSCD_Handle := 0;
end;



end.
