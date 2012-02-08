unit u_qip_plugin;

interface

uses
  u_plugin_info, u_plugin_msg, u_common, u_BasePlugin, Classes,SysUtils, unitMessage,Dynamic_Bass;

const
  PLUGIN_VER_MAJOR = 1;
  PLUGIN_VER_MINOR = 0;
  PLUGIN_NAME      : WideString = 'Говорун';
  PLUGIN_HINT      : WideString = 'Птица-говорун для QIP';
  PLUGIN_AUTHOR    : WideString = 'CkEsc';
  PLUGIN_DESC      : WideString = 'Проговаривает всё происходящее в QIP';
  DOWNLOAD_ATTEMPTS = 5;
  DOWNLOAD_ATTEMPTS_DELAY = 500;
  TTS_URL: WideString ='http://translate.google.com/translate_tts?tl=ru&q=';

type
  TQipPlugin = class(TBaseQipPlugin)
  private
    phraseCounter:Integer;
  public
    procedure GetPluginInformation(var VersionMajor: Word; var VersionMinor: Word;
                                   var PluginName: PWideChar; var Creator: PWideChar;
                                   var Description: PWideChar; var Hint: PWideChar); override;
    procedure InitPlugin;override;
    procedure FinalPlugin;override;
    function MessageReceived(const AMessage: TQipMsgPlugin; var ChangeMessageText: WideString): Boolean;override;
    procedure Say(Text: WideString);
  end;

implementation

procedure TQipPlugin.InitPlugin;
var
  BassInfo: BASS_INFO;
begin
  inherited;
  //инициализация звука
  Load_BASSDLL('bass.dll');
  BASS_Init(1, 44100, BASS_DEVICE_3D, 0, nil);
  BASS_Start;
  BASS_GetInfo(BassInfo);

end;

procedure TQipPlugin.FinalPlugin;
begin
  inherited;
  BASS_Stop;
  BASS_Free;
  Unload_BASSDLL;
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

function TQipPlugin.MessageReceived(const AMessage: TQipMsgPlugin;
  var ChangeMessageText: WideString): Boolean;
begin
  Say(ChangeMessageText);
  result:=True;
end;

procedure TQipPlugin.Say(Text: WideString);
var
  phrase:TPhrase;
  thread:TPhraseThread;
  id:string;
begin
  id:= IntToStr(phraseCounter);
  inc(phraseCounter);

  phrase:=TPhrase.Create(Text);
  thread:=TPhraseThread.Create(id,phrase);
  thread.Priority:=tpLower;
  thread.FreeOnTerminate:=true;
  thread.Resume;
end;


end.