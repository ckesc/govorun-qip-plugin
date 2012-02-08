{
  BASSMIX v2.4.2 Delphi API, copyright (c) 2003-2006 Ian Luck.
  Requires BASS 2.4 - available from www.un4seen.com

  See the BASSMIX.CHM file for more complete documentation

  written by Wishmaster
}


unit Dynamic_Bassmix;

interface
uses Windows, Dynamic_Bass;

const
  // additional BASS_SetConfig option
  BASS_CONFIG_MIXER_FILTER  = $10600;
  BASS_CONFIG_MIXER_BUFFER  = $10601;
  BASS_CONFIG_MIXER_POSEX   = $10602;
  BASS_CONFIG_SPLIT_BUFFER  = $10610;

  // BASS_Mixer_StreamCreate flags
  BASS_MIXER_END     = $10000;  // end the stream when there are no sources
  BASS_MIXER_NONSTOP = $20000;  // don't stall when there are no sources
  BASS_MIXER_RESUME  = $1000;   // resume stalled immediately upon new/unpaused source
  BASS_MIXER_POSEX   = $2000;   // enable BASS_Mixer_ChannelGetPositionEx support


  // source flags
  BASS_MIXER_FILTER   = $1000;    // resampling filter
  BASS_MIXER_BUFFER   = $2000;    // buffer data for BASS_Mixer_ChannelGetData/Level
  BASS_MIXER_LIMIT	  = $4000;  	// limit mixer processing to the amount available from this source
  BASS_MIXER_MATRIX   = $10000;   // matrix mixing
  BASS_MIXER_PAUSE    = $20000;   // don't process the source
  BASS_MIXER_DOWNMIX  = $400000;  // downmix to stereo/mono
  BASS_MIXER_NORAMPIN = $800000;  // don't ramp-in the start

  // envelope types
  BASS_MIXER_ENV_FREQ = 1;
  BASS_MIXER_ENV_VOL  = 2;
  BASS_MIXER_ENV_PAN  = 3;
  BASS_MIXER_ENV_LOOP = $10000; // FLAG: loop

  // additional sync type
  BASS_SYNC_MIXER_ENVELOPE = $10200;

  // BASS_CHANNELINFO type
  BASS_CTYPE_STREAM_MIXER = $10800;
  BASS_CTYPE_STREAM_SPLIT = $10801;

type
  // envelope node
  BASS_MIXER_NODE = record
	pos: QWORD;
	value: Single;
  end;


var
   BASS_Mixer_GetVersion:function : DWORD; stdcall;

   BASS_Mixer_StreamCreate:function(freq, chans, flags: DWORD): HSTREAM; stdcall;
   BASS_Mixer_StreamAddChannel:function(handle: HSTREAM; channel, flags: DWORD): BOOL; stdcall;
   BASS_Mixer_StreamAddChannelEx:function(handle: HSTREAM; channel, flags: DWORD; start, length: QWORD): BOOL; stdcall;

   BASS_Mixer_ChannelGetMixer:function(handle: DWORD): HSTREAM; stdcall;
   BASS_Mixer_ChannelFlags:function(handle, flags, mask: DWORD): DWORD; stdcall;
   BASS_Mixer_ChannelRemove:function(handle: DWORD): BOOL; stdcall;
   BASS_Mixer_ChannelSetPosition:function(handle: DWORD; pos: QWORD; mode: DWORD): BOOL; stdcall;
   BASS_Mixer_ChannelGetPosition:function(handle, mode: DWORD): QWORD; stdcall;

   BASS_Mixer_ChannelGetLevel:function(handle: DWORD): DWORD; stdcall;
   BASS_Mixer_ChannelGetData:function(handle: DWORD; buffer: Pointer; length: DWORD): DWORD; stdcall;

   BASS_Mixer_ChannelSetSync:function(handle: DWORD; type_: DWORD; param: QWORD; proc: SYNCPROC; user: Pointer): HSYNC; stdcall;
   BASS_Mixer_ChannelRemoveSync:function(handle: DWORD; sync: HSYNC): BOOL; stdcall;
   BASS_Mixer_ChannelSetMatrix:function(handle: DWORD; matrix: Pointer): BOOL; stdcall;
   BASS_Mixer_ChannelGetMatrix:function(handle: DWORD; matrix: Pointer): BOOL; stdcall;
   BASS_Mixer_ChannelSetEnvelope:function(handle, type_: DWORD; var nodes: BASS_MIXER_NODE; count: DWORD): BOOL; stdcall;
   BASS_Mixer_ChannelSetEnvelopePos:function(handle, type_: DWORD; pos: QWORD): BOOL; stdcall;
   BASS_Mixer_ChannelGetEnvelopePos:function(handle, type_: DWORD; value: Single): QWORD; stdcall;

   BASS_Split_StreamCreate:function(channel, flags: DWORD; chanmap: PLongInt) : HSTREAM; stdcall;
   BASS_Split_StreamGetSource:function(handle: HSTREAM): DWORD; stdcall;
   BASS_Split_StreamReset:function(handle: DWORD): BOOL; stdcall;
   BASS_Split_StreamResetEx:function(handle, offset: DWORD): BOOL; stdcall;
   BASS_Split_StreamGetAvailable:function(handle: DWORD): DWORD; stdcall;


var
   BASSMIX_Handle:Thandle = 0;

   Function Load_BASSMIXDLL (const dllfilename : string) : boolean;
   procedure Unload_BASSMIXDLL;

implementation

function Load_BASSMIXDLL(const dllfilename : string) : boolean;
var
   oldmode : integer;
begin
  if BASSMIX_Handle <> 0 then // is it already there ?
   Result := true
  else
   begin {go & load the dll}
    oldmode := SetErrorMode($8001);
   {$IFDEF UNICODE}
     BASSMIX_Handle:= LoadLibraryW(PWideChar(dllfilename));
   {$ELSE}
     BASSMIX_Handle:= LoadLibrary(PChar(dllfilename));
   {$ENDIF}
     SetErrorMode(oldmode);
    if BASSMIX_Handle <> 0 then
     begin
      @BASS_Mixer_GetVersion:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_GetVersion'));
      @BASS_Mixer_StreamCreate:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_StreamCreate'));
      @BASS_Mixer_StreamAddChannel:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_StreamAddChannel'));
      @BASS_Mixer_StreamAddChannelEx:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_StreamAddChannelEx'));
      @BASS_Mixer_ChannelGetMixer:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelGetMixer'));
      @BASS_Mixer_ChannelFlags:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelFlags'));
      @BASS_Mixer_ChannelRemove:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelRemove'));
      @BASS_Mixer_ChannelSetPosition:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelSetPosition'));
      @BASS_Mixer_ChannelGetPosition:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelGetPosition'));
      BASS_Mixer_ChannelGetLevel:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelGetLevel'));
      BASS_Mixer_ChannelGetData:= GetProcAddress(BASSMIX_Handle, 'BASS_Mixer_ChannelGetData');
      @BASS_Mixer_ChannelSetSync:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelSetSync'));
      @BASS_Mixer_ChannelRemoveSync:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelRemoveSync'));
      @BASS_Mixer_ChannelSetMatrix:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelSetMatrix'));
      @BASS_Mixer_ChannelGetMatrix:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelGetMatrix'));
      @BASS_Mixer_ChannelSetEnvelope:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelSetEnvelope'));
      @BASS_Mixer_ChannelSetEnvelopePos:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelSetEnvelopePos'));
      @BASS_Mixer_ChannelGetEnvelopePos:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Mixer_ChannelGetEnvelopePos'));

      @BASS_Split_StreamCreate:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Split_StreamCreate'));
      @BASS_Split_StreamGetSource:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Split_StreamGetSource'));
      @BASS_Split_StreamReset:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Split_StreamReset'));
      @BASS_Split_StreamResetEx:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Split_StreamResetEx'));
      @BASS_Split_StreamGetAvailable:= GetProcAddress(BASSMIX_Handle, Pchar('BASS_Split_StreamGetAvailable'));



  if (@BASS_Mixer_GetVersion = nil) or
     (@BASS_Mixer_StreamCreate = nil) or
     (@BASS_Mixer_StreamAddChannel = nil) or
     (@BASS_Mixer_StreamAddChannelEx = nil) or
     (@BASS_Mixer_ChannelGetMixer = nil) or
     (@BASS_Mixer_ChannelFlags = nil) or
     (@BASS_Mixer_ChannelRemove = nil) or
     (@BASS_Mixer_ChannelSetPosition = nil) or
     (@BASS_Mixer_ChannelGetPosition = nil) or
     (@BASS_Mixer_ChannelGetLevel = nil) or
     (@BASS_Mixer_ChannelGetData = nil) or
     (@BASS_Mixer_ChannelSetSync = nil) or
     (@BASS_Mixer_ChannelRemoveSync = nil) or
     (@BASS_Mixer_ChannelSetMatrix = nil) or
     (@BASS_Mixer_ChannelGetMatrix = nil) or
     (@BASS_Mixer_ChannelSetEnvelope = nil) or
     (@BASS_Mixer_ChannelSetEnvelopePos = nil) or
     (@BASS_Mixer_ChannelGetEnvelopePos = nil) or

     (@BASS_Split_StreamCreate = nil) or
     (@BASS_Split_StreamGetSource = nil) or
     (@BASS_Split_StreamReset = nil) or
     (@BASS_Split_StreamResetEx = nil) or
     (@BASS_Split_StreamGetAvailable = nil) Then
    begin
     FreeLibrary(BASSMIX_Handle);
     BASSMIX_Handle := 0;
    end;
   end;
   result := (BASSMIX_Handle <> 0);
 end;
end;

procedure Unload_BASSMIXDLL;
begin
  if BASSMIX_Handle <> 0 then
   FreeLibrary(BASSMIX_Handle);
   BASSMIX_Handle := 0;
end;


end.
