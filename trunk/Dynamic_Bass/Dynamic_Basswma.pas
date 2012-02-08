{
  BASSWMA 2.4.4 Delphi API, copyright (c) 2002-2007 Ian Luck.
  Requires BASS, available from www.un4seen.com
  DOWNLOADPROC support for streams in ASX files (requires BASS 2.4.3)

  See the BASSWMA.CHM file for more complete documentation

  written by Wishmaster
}


unit Dynamic_Basswma;

interface

uses Windows, Dynamic_Bass;

const

  // Additional error codes returned by BASS_ErrorGetCode
  BASS_ERROR_WMA_LICENSE     = 1000; // the file is protected
  BASS_ERROR_WMA             = 1001; // Windows Media (9 or above) is not installed
  BASS_ERROR_WMA_WM9         = BASS_ERROR_WMA;
  BASS_ERROR_WMA_DENIED      = 1002; // access denied (user/pass is invalid)
  BASS_ERROR_WMA_INDIVIDUAL  = 1004; // individualization is needed
  BASS_ERROR_WMA_PUBINIT     = 1005; // publishing point initialization problem

  // Additional BASS_SetConfig options
  BASS_CONFIG_WMA_PRECHECK   = $10100;
  BASS_CONFIG_WMA_PREBUF     = $10101;
  BASS_CONFIG_WMA_BASSFILE   = $10103;
  BASS_CONFIG_WMA_NETSEEK    = $10104;
  BASS_CONFIG_WMA_VIDEO      = $10105;

  // additional WMA sync types
  BASS_SYNC_WMA_CHANGE       = $10100;
  BASS_SYNC_WMA_META         = $10101;

  // additional BASS_StreamGetFilePosition WMA mode
  BASS_FILEPOS_WMA_BUFFER    = 1000; // internet buffering progress (0-100%)

  // Additional flags for use with BASS_WMA_EncodeOpen/File/Network/Publish
  BASS_WMA_ENCODE_STANDARD   = $2000;  // standard WMA
  BASS_WMA_ENCODE_PRO        = $4000;  // WMA Pro
  BASS_WMA_ENCODE_24BIT      = $8000;  // 24-bit
  BASS_WMA_ENCODE_PCM        = $10000; // uncompressed PCM
  BASS_WMA_ENCODE_SCRIPT     = $20000; // set script (mid-stream tags) in the WMA encoding

  // Additional flag for use with BASS_WMA_EncodeGetRates
  BASS_WMA_ENCODE_RATES_VBR  = $10000; // get available VBR quality settings

  // WMENCODEPROC "type" values
  BASS_WMA_ENCODE_HEAD       = 0;
  BASS_WMA_ENCODE_DATA       = 1;
  BASS_WMA_ENCODE_DONE       = 2;

  // BASS_WMA_EncodeSetTag "type" values
  BASS_WMA_TAG_ANSI          = 0;
  BASS_WMA_TAG_UNICODE       = 1;
  BASS_WMA_TAG_UTF8          = 2;
  BASS_WMA_TAG_BINARY        = $100; // FLAG: binary tag (HIWORD=length)

  // BASS_CHANNELINFO type
  BASS_CTYPE_STREAM_WMA      = $10300;
  BASS_CTYPE_STREAM_WMA_MP3  = $10301;

  // Additional BASS_ChannelGetTags type
  BASS_TAG_WMA               = 8;  // WMA header tags : series of null-terminated UTF-8 strings
  BASS_TAG_WMA_META          = 11; // WMA mid-stream tag : UTF-8 string
  BASS_TAG_WMA_CODEC         = 12; // WMA codec




type
  HWMENCODE = DWORD;		// WMA encoding handle

  CLIENTCONNECTPROC = procedure(handle:HWMENCODE; connect:BOOL; ip:PChar; user:Pointer); stdcall;
  {
    Client connection notification callback function.
    handle : The encoder
    connect: TRUE=client is connecting, FALSE=disconnecting
    ip     : The client's IP (xxx.xxx.xxx.xxx:port)
    user   : The 'user' parameter value given when calling BASS_WMA_EncodeSetNotify
  }

  WMENCODEPROC = procedure(handle:HWMENCODE; dtype:DWORD; buffer:Pointer; length:DWORD; user:Pointer); stdcall;
  {
    Encoder callback function.
    handle : The encoder handle
    dtype  : The type of data, one of BASS_WMA_ENCODE_xxx values
    buffer : The encoded data
    length : Length of the data
    user   : The 'user' parameter value given when calling BASS_WMA_EncodeOpen
  }


var
    BASS_WMA_StreamCreateFile:function(mem:BOOL; fl:pointer; offset,length:QWORD; flags:DWORD): HSTREAM; stdcall;
    BASS_WMA_StreamCreateFileAuth:function(mem:BOOL; fl:pointer; offset,length:QWORD; flags:DWORD; user,pass:PChar): HSTREAM; stdcall;
    BASS_WMA_StreamCreateFileUser:function(system,flags:DWORD; procs:BASS_FILEPROCS; user:Pointer): HSTREAM; stdcall;

    BASS_WMA_GetTags:function(fname:PChar; flags:DWORD): PAnsiChar; stdcall;                                         //2.4.3

    BASS_WMA_EncodeGetRates:function(freq,chans,flags:DWORD): PDWORD; stdcall;
    BASS_WMA_EncodeOpen:function(freq,chans,flags,bitrate:DWORD; proc:WMENCODEPROC; user:Pointer): HWMENCODE; stdcall;
    BASS_WMA_EncodeOpenFile:function(freq,chans,flags,bitrate:DWORD; fname:PChar): HWMENCODE; stdcall;
    BASS_WMA_EncodeOpenNetwork:function(freq,chans,flags,bitrate,port,clients:DWORD): HWMENCODE; stdcall;
    BASS_WMA_EncodeOpenNetworkMulti:function(freq,chans,flags:DWORD; bitrates:PDWORD; port,clients:DWORD): HWMENCODE; stdcall;
    BASS_WMA_EncodeOpenPublish:function(freq,chans,flags,bitrate:DWORD; url,user,pass:PChar): HWMENCODE; stdcall;
    BASS_WMA_EncodeOpenPublishMulti:function(freq,chans,flags:DWORD; bitrates:PDWORD; url,user,pass:PChar): HWMENCODE; stdcall;
    BASS_WMA_EncodeGetPort:function(handle:HWMENCODE): DWORD; stdcall;
    BASS_WMA_EncodeSetNotify:function(handle:HWMENCODE; proc:CLIENTCONNECTPROC; user:Pointer): BOOL; stdcall;
    BASS_WMA_EncodeGetClients:function(handle:HWMENCODE): DWORD; stdcall;
    BASS_WMA_EncodeSetTag:function(handle:HWMENCODE; tag,text:PChar; ttype:DWORD): BOOL; stdcall;
    BASS_WMA_EncodeWrite:function(handle:HWMENCODE; buffer:Pointer; length:DWORD): BOOL; stdcall;
    BASS_WMA_EncodeClose:function(handle:HWMENCODE): BOOL; stdcall;

    BASS_WMA_GetWMObject:function(handle:DWORD): Pointer; stdcall; 


var
   BASSWMA_Handle:Thandle = 0;

   Function Load_BASSWMADLL (const dllfilename : string) : boolean;
   Procedure Unload_BASSWMADLL;



implementation

Function Load_BASSWMADLL (const dllfilename : string) : boolean;
var
   oldmode : integer;
begin
  if BASSWMA_Handle <> 0 then // is it already there ?
   Result := true
  else
   begin {go & load the dll}
     oldmode := SetErrorMode($8001);
   {$IFDEF UNICODE}
     BASSWMA_Handle:= LoadLibraryW(PWideChar(dllfilename));
   {$ELSE}
     BASSWMA_Handle:= LoadLibrary(PChar(dllfilename));
   {$ENDIF}
     SetErrorMode(oldmode);
    if BASSWMA_Handle <> 0 then
     begin
      @BASS_WMA_StreamCreateFile:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_StreamCreateFile'));
      @BASS_WMA_StreamCreateFileAuth:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_StreamCreateFileAuth'));
      @BASS_WMA_StreamCreateFileUser:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_StreamCreateFileUser'));

      @BASS_WMA_GetTags:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_GetTags'));

      @BASS_WMA_EncodeGetRates:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeGetRates'));
      @BASS_WMA_EncodeOpen:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeOpen'));
      @BASS_WMA_EncodeOpenFile:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeOpenFile'));
      @BASS_WMA_EncodeOpenNetwork:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeOpenNetwork'));
      @BASS_WMA_EncodeOpenNetworkMulti:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeOpenNetworkMulti'));
      @BASS_WMA_EncodeOpenPublish:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeOpenPublish'));
      @BASS_WMA_EncodeOpenPublishMulti:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeOpenPublishMulti'));
      @BASS_WMA_EncodeGetPort:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeGetPort'));
      @BASS_WMA_EncodeSetNotify:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeSetNotify'));
      @BASS_WMA_EncodeGetClients:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeGetClients'));
      @BASS_WMA_EncodeSetTag:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeSetTag'));

      @BASS_WMA_EncodeWrite:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeWrite'));
      @BASS_WMA_EncodeClose:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_EncodeClose'));
      @BASS_WMA_GetWMObject:= GetProcAddress(BASSWMA_Handle, PChar('BASS_WMA_GetWMObject'));

  if (@BASS_WMA_StreamCreateFile = nil) or
     (@BASS_WMA_StreamCreateFileAuth = nil) or
     (@BASS_WMA_StreamCreateFileUser = nil) or
     (@BASS_WMA_GetTags = nil) or
     (@BASS_WMA_EncodeGetRates = nil) or
     (@BASS_WMA_EncodeOpen = nil) or
     (@BASS_WMA_EncodeOpenFile = nil) or
     (@BASS_WMA_EncodeOpenNetwork = nil) or
     (@BASS_WMA_EncodeOpenNetworkMulti = nil) or
     (@BASS_WMA_EncodeOpenPublish = nil) or
     (@BASS_WMA_EncodeOpenPublishMulti = nil) or
     (@BASS_WMA_EncodeGetPort = nil) or
     (@BASS_WMA_EncodeSetNotify = nil) or
     (@BASS_WMA_EncodeGetClients = nil) or
     (@BASS_WMA_EncodeSetTag = nil) or
     (@BASS_WMA_EncodeWrite = nil) or
     (@BASS_WMA_EncodeClose = nil) or
     (@BASS_WMA_GetWMObject = nil) then
     begin
      FreeLibrary(BASSWMA_Handle);
      BASSWMA_Handle := 0;
     end;
    end;
   Result := (BASSWMA_Handle <> 0);
  end;
end;



procedure Unload_BASSWMADLL;
begin
  if BASSWMA_Handle <> 0 then
   FreeLibrary(BASSWMA_Handle);
   BASSWMA_Handle := 0;
end;



end.
