unit unitMessage;

interface

type
  TStatus = (sJustRecieved, sDownloading, sReady);

  TPhrase = class
    public
      Text:WideString;
      Status:TStatus;
      constructor Create(Text: WideString);

  end;
  
implementation

constructor TPhrase.Create(Text: WideString);
begin
  Self.Text:=Text;
  Status:=sJustRecieved;
end;

end.
