unit unitMessage;

interface

uses Classes, Dynamic_Bass,WinInet,SysUtils;

type
  TStatus = (sJustRecieved, sDownloading, sReady, sError);

  TPhrase = class
    public
      Text:WideString;
      Status:TStatus;
      constructor Create(Text: WideString);
  end;

  TPhraseThread = class(TThread)
  private
    function BASS_PlaySoundFile(const FileName: string): Boolean;
    function GetInetFile(const fileURL, FileName: String): boolean;
    protected
      phrase:TPhrase;
      procedure execute; override;
  public
    Id:string;
    constructor Create(Id: string; phrase: TPhrase);
  end;

implementation

uses u_qip_plugin;

constructor TPhrase.Create(Text: WideString);
begin
  Self.Text:=Text;
  Status:=sJustRecieved;
end;

{ TPhraseThread }

constructor TPhraseThread.Create(Id: string; phrase: TPhrase);
begin
  inherited Create(true);
  Self.phrase:=phrase;
  Self.Id:=Id;
end;

procedure TPhraseThread.execute;
var
  attemptCouter:integer;
  outputFileName:String;
  url:string;
begin
  inherited;
  phrase.Status:=sDownloading;
  //Генерируем URL и путь к файлу
  outputFileName:='M:\'+Id+'.mp3';
  url:=TTS_URL+phrase.Text;

  //Загружаем звук
  attemptCouter:=0;
  repeat
    if GetInetFile(url,outputFileName)
    then
      begin
        phrase.Status:=sReady;
        Break;
      end;
    inc(attemptCouter);
    Sleep(DOWNLOAD_ATTEMPTS_DELAY);
  until (attemptCouter>DOWNLOAD_ATTEMPTS);
  if (attemptCouter>DOWNLOAD_ATTEMPTS) then
  begin
    phrase.Status:=sError;
    Exit;
  end;

  //воспроизводим
  BASS_PlaySoundFile(outputFileName);
end;

function TPhraseThread.BASS_PlaySoundFile(const FileName: string): Boolean;
var
  Channel: DWORD;
begin
  Result:= False;
  Channel:= BASS_StreamCreateFile(False, PChar(FileName), 0, 0, 0);

  if (Channel <> 0) then
  begin
    BASS_ChannelPlay(Channel, False);
  end;
  Result:= Channel <> 0;
end;

function TPhraseThread.GetInetFile(const fileURL, FileName: String): boolean;
const BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array[1..BufferSize] of Byte;
  BufferLen: DWORD;
  f: File;
  sAppName: String;
begin
  Result:=False;
  sAppName := 'Govorun plugin';
  hSession :=InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    hURL := InternetOpenURL(hSession, PChar(AnsiToUtf8(fileURL)), nil, 0, 0, 0);
    try
      AssignFile(f, FileName);
      Rewrite(f,1);
      repeat
        InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);
        BlockWrite(f, Buffer, BufferLen)
      until BufferLen = 0;
      CloseFile(f);
      Result:=True;
    finally
      InternetCloseHandle(hURL)
    end
  finally
    InternetCloseHandle(hSession)
  end
end;

end.
