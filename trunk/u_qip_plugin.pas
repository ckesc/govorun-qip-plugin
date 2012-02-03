unit u_qip_plugin;

interface

uses
  u_plugin_info, u_plugin_msg, u_common, u_BasePlugin, Classes, unitMessage,bass;

const
  PLUGIN_VER_MAJOR = 1;
  PLUGIN_VER_MINOR = 0;
  PLUGIN_NAME      : WideString = 'Говорун';
  PLUGIN_HINT      : WideString = 'Птица-говорун для QIP';
  PLUGIN_AUTHOR    : WideString = 'CkEsc';
  PLUGIN_DESC      : WideString = 'Проговаривает всё происходящее в QIP';

type
  TQipPlugin = class(TBaseQipPlugin)
  private
    // Для воспроизвдения
    Channel: DWORD;

    PhraseQueue:TList;
    function BASS_PlaySoundFile(const FileName: string): Boolean;
  public
    procedure PlayQueue;
    procedure GetPluginInformation(var VersionMajor: Word; var VersionMinor: Word;
                                   var PluginName: PWideChar; var Creator: PWideChar;
                                   var Description: PWideChar; var Hint: PWideChar); override;
    procedure InitPlugin;override;
    procedure FinalPlugin;override;
    function MessageReceived(const AMessage: TQipMsgPlugin; var ChangeMessageText: WideString): Boolean;override;

  end;

implementation

procedure TQipPlugin.FinalPlugin;
begin
  inherited;
  BASS_Stop;
  BASS_Free;
//  Unload_BASSDLL;
end;

procedure TQipPlugin.GetPluginInformation(var VersionMajor,
  VersionMinor: Word; var PluginName, Creator, Description,
  Hint: PWideChar);
begin
  inherited;
  VersionMajor := PLUGIN_VER_MAJOR;
  VersionMinor := PLUGIN_VER_MINOR;
  Creator      := PWideChar(PLUGIN_AUTHOR);
  PluginName   := PWideChar(PLUGIN_NAME);
  Hint         := PWideChar(PLUGIN_HINT);
  Description  := PWideChar(PLUGIN_DESC);
end;

procedure TQipPlugin.InitPlugin;
var
  BassInfo: BASS_INFO;
begin
  inherited;
  //инициализация звука
//  Load_BASSDLL('bass.dll');
  BASS_Init(1, 44100, BASS_DEVICE_3D, MyHandle, nil);
  BASS_Start;
  BASS_GetInfo(BassInfo);
end;

function TQipPlugin.MessageReceived(const AMessage: TQipMsgPlugin;
  var ChangeMessageText: WideString): Boolean;
begin
  BASS_PlaySoundFile('M:\test.mp3');
  Result:=True;
//  PhraseQueue.Add(TPhrase.Create(ChangeMessageText));
//  PlayQueue;
end;

function TQipPlugin.BASS_PlaySoundFile(const FileName: string): Boolean;
begin
  Result:= False;
  Channel:= BASS_StreamCreateFile(False, PChar(FileName), 0, 0, 0);

  if (Channel <> 0) then
  begin
    BASS_ChannelPlay(Channel, False);
  end;
  Result:= Channel <> 0;
end;

procedure TQipPlugin.PlayQueue;
var
 i:Integer;
 currentPhrase:TPhrase;
begin
  for i := 0 to PhraseQueue.Count - 1 do
    begin
      currentPhrase:=TPhrase(PhraseQueue.Items[i]);
      BASS_PlaySoundFile('test.mp3');
    end;
end;

end.