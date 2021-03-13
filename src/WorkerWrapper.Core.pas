unit WorkerWrapper.Core;

interface

uses
  ZapMQ.Wrapper, ZapMQ.Message.JSON, JSON, ZapMQ.Handler, System.Win.ScktComp;

type
  TWorkerWrapper = class
  private
    FZapMQWrapper : TZapMQWrapper;
    FProcessID : Cardinal;
    FKeepAliveHandler: TZapMQHanlder;
    FSafeStopHandler: TZapMQHanlder;
    FTraceOnline : boolean;
    FClientSocket : TClientSocket;
    FErrorSocket : boolean;
    procedure BindKeepAliveQueue;
    procedure BindSafeStopQueue;
    procedure BindTraceOnlineQueue;
    procedure SetKeepAliveHandler(const Value: TZapMQHanlder);
    procedure SetSafeStopHandler(const Value: TZapMQHanlder);
    function StartTraceOnline(pMessage : TZapJSONMessage;
      var pProcessing : boolean) : TJSONObject;
    procedure SocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  protected
    procedure DoTrace(const pTraceText : string);
    constructor Create(const pHostZapMQ : string; const pPortZapMQ : integer;
      const pKeepAliveHandler : TZapMQHanlder; const pSafeStopHandler : TZapMQHanlder); overload;
  public
    property KeepAliveHandler : TZapMQHanlder read FKeepAliveHandler write SetKeepAliveHandler;
    property SafeStopHandler : TZapMQHanlder read FSafeStopHandler write SetSafeStopHandler;
    class procedure Start(const pHostZapMQ : string; const pPortZapMQ : integer;
      const pKeepAliveHandler : TZapMQHanlder; const pSafeStopHandler : TZapMQHanlder);
    class procedure Stop;
    class procedure Trace(const pTraceText : string);
    destructor Destroy; override;
  end;

  var WorkerWrapper : TWorkerWrapper;

implementation

uses
  Windows, System.SysUtils, ZapMQ.Queue, Vcl.Forms, Classes;

{ TWorkerWrapper }

procedure TWorkerWrapper.BindKeepAliveQueue;
begin
  FZapMQWrapper.Bind(FProcessID.ToString, KeepAliveHandler, TZapMQQueuePriority.mqpLow)
end;

procedure TWorkerWrapper.BindSafeStopQueue;
begin
  FZapMQWrapper.Bind(FProcessID.ToString + 'SS', SafeStopHandler, TZapMQQueuePriority.mqpLow)
end;

procedure TWorkerWrapper.BindTraceOnlineQueue;
begin
  FZapMQWrapper.Bind(FProcessID.ToString + 'TR', StartTraceOnline, TZapMQQueuePriority.mqpLow)
end;

constructor TWorkerWrapper.Create(const pHostZapMQ: string; const pPortZapMQ : integer;
  const pKeepAliveHandler : TZapMQHanlder; const pSafeStopHandler : TZapMQHanlder);
begin
  FErrorSocket := False;
  FTraceOnline := False;
  FZapMQWrapper := TZapMQWrapper.Create(pHostZapMQ, pPortZapMQ);
  FProcessID := GetCurrentProcessId;
  FKeepAliveHandler := pKeepAliveHandler;
  FSafeStopHandler := pSafeStopHandler;
  BindKeepAliveQueue;
  BindSafeStopQueue;
  BindTraceOnlineQueue;
end;

destructor TWorkerWrapper.Destroy;
begin
  FZapMQWrapper.SafeStop;
  FZapMQWrapper.Free;
  inherited;
end;

procedure TWorkerWrapper.SetKeepAliveHandler(const Value: TZapMQHanlder);
begin
  FKeepAliveHandler := Value;
end;

procedure TWorkerWrapper.SetSafeStopHandler(const Value: TZapMQHanlder);
begin
  FSafeStopHandler := Value;
end;

procedure TWorkerWrapper.SocketError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
  FErrorSocket := True;
end;

class procedure TWorkerWrapper.Start(const pHostZapMQ : string; const pPortZapMQ : integer;
  const pKeepAliveHandler : TZapMQHanlder; const pSafeStopHandler : TZapMQHanlder);
begin
  if not Assigned(WorkerWrapper) then
    WorkerWrapper := TWorkerWrapper.Create(pHostZapMQ, pPortZapMQ,
      pKeepAliveHandler, pSafeStopHandler);
end;

function TWorkerWrapper.StartTraceOnline(pMessage: TZapJSONMessage;
  var pProcessing: boolean): TJSONObject;
var
  Json : TJSONObject;
begin
  Json := TJSONObject.Create;
  Result := Json;
  if pMessage.Body.GetValue<string>('message') = 'start trace' then
  begin
    FTraceOnline := True;
    FClientSocket := TClientSocket.Create(nil);
    FClientSocket.OnError := SocketError;
    FClientSocket.Host := '127.0.0.1';
    FClientSocket.Port := pMessage.Body.GetValue<integer>('port');
    FErrorSocket := False;
    FClientSocket.Open;
    while (not FErrorSocket) and (not FClientSocket.Active) do
    begin
      Application.ProcessMessages;
      Sleep(20);
    end;
    if not FClientSocket.Active then
    begin
      FTraceOnline := False;
      FClientSocket.Close;
      FClientSocket.Free;
      Json.AddPair('message', 'cannot connect to the server');
    end
    else
    begin
      Json.AddPair('message', 'on');
    end;
  end
  else
  begin
    FTraceOnline := False;
    if Assigned(FClientSocket) then
    begin
      FClientSocket.Close;
      FClientSocket.Free;
      Json.AddPair('message', 'off');
    end;
  end;
  pProcessing := False;
end;

class procedure TWorkerWrapper.Stop;
begin
  if Assigned(WorkerWrapper) then
    WorkerWrapper.Free;
end;

class procedure TWorkerWrapper.Trace(const pTraceText: string);
begin
  if Assigned(WorkerWrapper) then
    WorkerWrapper.DoTrace(pTraceText);
end;

procedure TWorkerWrapper.DoTrace(const pTraceText: string);
begin
  if FTraceOnline and Assigned(FClientSocket) and (FClientSocket.Active) then
  begin
    FClientSocket.Socket.SendText(AnsiString(pTraceText));
    if FErrorSocket then
    begin
      FTraceOnline := False;
      FClientSocket.Close;
      FClientSocket.Free;
    end;
  end;
end;

end.
