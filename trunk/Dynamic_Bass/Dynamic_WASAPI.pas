{
written by Wishmaster
}


unit Dynamic_WASAPI;

interface

uses Windows, Dynamic_Bass;


const
  // Additional error codes returned by BASS_ErrorGetCode
  BASS_ERROR_BUSY        = 46;   // the device is busy
  BASS_ERROR_WASAPI      = 5000; // no WASAPI

  // BASS_WASAPI_DEVICEINFO "type"
  BASS_WASAPI_TYPE_NETWORKDEVICE   = 0;
  BASS_WASAPI_TYPE_SPEAKERS        = 1;
  BASS_WASAPI_TYPE_LINELEVEL       = 2;
  BASS_WASAPI_TYPE_HEADPHONES      = 3;
  BASS_WASAPI_TYPE_MICROPHONE      = 4;
  BASS_WASAPI_TYPE_HEADSET         = 5;
  BASS_WASAPI_TYPE_HANDSET         = 6;
  BASS_WASAPI_TYPE_DIGITAL         = 7;
  BASS_WASAPI_TYPE_SPDIF           = 8;
  BASS_WASAPI_TYPE_HDMI            = 9;
  BASS_WASAPI_TYPE_UNKNOWN         = 10;

  // BASS_WASAPI_DEVICEINFO flags
  BASS_DEVICE_ENABLED              = 1;
  BASS_DEVICE_DEFAULT              = 2;
  BASS_DEVICE_INIT                 = 4;
  BASS_DEVICE_LOOPBACK             = 8;
  BASS_DEVICE_INPUT                = 16;

  // BASS_WASAPI_Init flags
  BASS_WASAPI_EXCLUSIVE            = 1;
  BASS_WASAPI_AUTOFORMAT           = 2;
  BASS_WASAPI_BUFFER               = 4;

  // BASS_WASAPI_INFO "format"
  BASS_WASAPI_FORMAT_FLOAT         = 0;
  BASS_WASAPI_FORMAT_8BIT          = 1;
  BASS_WASAPI_FORMAT_16BIT         = 2;
  BASS_WASAPI_FORMAT_24BIT         = 3;
  BASS_WASAPI_FORMAT_32BIT         = 4;


type
  // Device info structure
  BASS_WASAPI_DEVICEINFO = record
    name: PAnsiChar;
    id: PAnsiChar;
    &type: DWORD;
    flags: DWORD;
    minperiod: Single;
    defperiod: Single;
    mixfreq: DWORD;
    mixchans: DWORD;
  end;

  BASS_WASAPI_INFO = record
	initflags: DWORD;
	freq: DWORD;
	chans: DWORD;
	format: DWORD;
	buflen: DWORD;
	volmax: Single;
	volmin: Single;
	volstep: Single;
  end;

  WASAPIPROC = function(buffer:Pointer; length:DWORD; user:Pointer): DWORD; stdcall;
  {
    WASAPI callback function.
    buffer : Buffer containing the sample data
    length : Number of bytes
    user   : The 'user' parameter given when calling BASS_WASAPI_Init
    RETURN : The number of bytes written (ignored with input devices)
  }


var
 BASS_WASAPI_GetVersion:function(): DWORD; stdcall;
 BASS_WASAPI_GetDeviceInfo:function(device:DWORD; var info:BASS_WASAPI_DEVICEINFO): BOOL; stdcall;
 BASS_WASAPI_GetDeviceLevel:function(device:DWORD; chan:Integer): single; stdcall;
 BASS_WASAPI_SetDevice:function(device:DWORD): BOOL; stdcall;
 BASS_WASAPI_GetDevice:function(): DWORD; stdcall;
 BASS_WASAPI_CheckFormat:function(device:Integer; freq,chans,flags:DWORD): DWORD; stdcall;
 BASS_WASAPI_Init:function(device:Integer; freq,chans,flags:DWORD; buffer,period:Single; proc:WASAPIPROC; user:Pointer): BOOL; stdcall;
 BASS_WASAPI_Free:function(): BOOL; stdcall;
 BASS_WASAPI_GetInfo:function(var info:BASS_WASAPI_INFO): BOOL; stdcall;
 BASS_WASAPI_GetCPU:function(): float; stdcall;
 BASS_WASAPI_Lock:function(lock:BOOL): BOOL; stdcall;
 BASS_WASAPI_Start:function(): BOOL; stdcall;
 BASS_WASAPI_Stop:function(reset:BOOL): BOOL; stdcall;
 BASS_WASAPI_IsStarted:function(): BOOL; stdcall;
 BASS_WASAPI_SetVolume:function(linear:BOOL; volume:single): BOOL; stdcall;
 BASS_WASAPI_GetVolume:function(linear:BOOL): single; stdcall;
 BASS_WASAPI_SetMute:function(mute:BOOL): BOOL; stdcall;
 BASS_WASAPI_GetMute:function(): BOOL; stdcall;
 BASS_WASAPI_PutData:function(buffer: Pointer; length: DWORD): DWORD; stdcall;
 BASS_WASAPI_GetData:function(buffer: Pointer; length: DWORD): DWORD; stdcall;
 BASS_WASAPI_GetLevel:function(): DWORD; stdcall;


var
   WASAPI_Handle : Thandle = 0;

   Function Load_WASAPIDLL(const dllfilename : string) : boolean;
   procedure Unload_WASAPIDLL;


implementation


Function Load_WASAPIDLL(const dllfilename : string) : boolean;
var
   oldmode : integer;
begin
 if WASAPI_Handle <> 0 then // is it already there ?
  Result:= true
 else
   begin {go & load the dll}
    oldmode := SetErrorMode($8001);
   {$IFDEF UNICODE}
     WASAPI_Handle:= LoadLibraryW(PWideChar(dllfilename));
   {$ELSE}
//     BASSCD_Handle:= LoadLibrary(PChar(dllfilename));
   {$ENDIF}
     SetErrorMode(oldmode);
    if WASAPI_Handle <> 0 then
     begin
      @BASS_WASAPI_GetVersion:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetVersion'));
      @BASS_WASAPI_GetDeviceInfo:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetDeviceInfo'));
      @BASS_WASAPI_GetDeviceLevel:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetDeviceLevel'));
      @BASS_WASAPI_SetDevice:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_SetDevice'));
      @BASS_WASAPI_GetDevice:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetDevice'));
      @BASS_WASAPI_CheckFormat:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_CheckFormat'));
      @BASS_WASAPI_Init:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_Init'));
      @BASS_WASAPI_Free:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_Free'));
      @BASS_WASAPI_GetInfo:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetInfo'));
      @BASS_WASAPI_GetCPU:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetCPU'));
      @BASS_WASAPI_Lock:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_Lock'));
      @BASS_WASAPI_Start:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_Start'));
      @BASS_WASAPI_Stop:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_Stop'));
      @BASS_WASAPI_IsStarted:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_IsStarted'));
      @BASS_WASAPI_SetVolume:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_SetVolume'));
      @BASS_WASAPI_GetVolume:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetVolume'));
      @BASS_WASAPI_SetMute:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_SetMute'));
      @BASS_WASAPI_GetMute:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetMute'));
      @BASS_WASAPI_PutData:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_PutData'));
      @BASS_WASAPI_GetData:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetData'));
      @BASS_WASAPI_GetLevel:= GetProcAddress(WASAPI_Handle, Pchar('BASS_WASAPI_GetLevel'));


  if (@BASS_WASAPI_GetVersion = nil) or
     (@BASS_WASAPI_GetDeviceInfo = nil) or
     (@BASS_WASAPI_GetDeviceLevel = nil) or
     (@BASS_WASAPI_SetDevice = nil) or
     (@BASS_WASAPI_GetDevice = nil) or
     (@BASS_WASAPI_CheckFormat = nil) or
     (@BASS_WASAPI_Init = nil) or
     (@BASS_WASAPI_Free = nil) or
     (@BASS_WASAPI_GetInfo = nil) or
     (@BASS_WASAPI_GetCPU = nil) or
     (@BASS_WASAPI_Lock = nil) or
     (@BASS_WASAPI_Start = nil) or
     (@BASS_WASAPI_Stop = nil) or
     (@BASS_WASAPI_IsStarted = nil) or
     (@BASS_WASAPI_SetVolume = nil) or
     (@BASS_WASAPI_GetVolume = nil) or
     (@BASS_WASAPI_SetMute = nil) or
     (@BASS_WASAPI_GetMute = nil) or
     (@BASS_WASAPI_PutData = nil) or
     (@BASS_WASAPI_GetData = nil) or
     (@BASS_WASAPI_GetLevel = nil) then
     begin
      FreeLibrary(WASAPI_Handle);
      WASAPI_Handle := 0;
     end;
    end;
   Result:= (WASAPI_Handle <> 0);
 end;
end;


procedure Unload_WASAPIDLL;
begin
 if WASAPI_Handle <> 0 then
  FreeLibrary(WASAPI_Handle);
  WASAPI_Handle := 0;
end;

end.

