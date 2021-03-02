unit WorkerWrapper.Core;

interface

uses
  ZapMQ.Wrapper, ZapMQ.Message.JSON, JSON, ZapMQ.Handler;

type
  TWorkerWrapper = class
  private
    FZapMQWrapper : TZapMQWrapper;
    FProcessID : Cardinal;
    procedure BindQueue;
    function QueueHandler(pMessage: TZapJSONMessage; var pProcessing: boolean): TJSONObject;
  protected
    constructor Create(const pHostZapMQ : string; const pPortZapMQ : integer); overload;
  public
    class procedure Start(const pHostZapMQ : string; const pPortZapMQ : integer);
    class procedure Stop;
    destructor Destroy; override;
  end;

  var WorkerWrapper : TWorkerWrapper;

implementation

uses
  Windows, System.SysUtils, ZapMQ.Queue;

{ TWorkerWrapper }

procedure TWorkerWrapper.BindQueue;
begin
  FZapMQWrapper.Bind(FProcessID.ToString, QueueHandler, TZapMQQueuePriority.mqpLow)
end;

constructor TWorkerWrapper.Create(const pHostZapMQ: string; const pPortZapMQ : integer);
begin
  FZapMQWrapper := TZapMQWrapper.Create(pHostZapMQ, pPortZapMQ);
  FProcessID := GetCurrentProcessId;
  BindQueue;
end;

destructor TWorkerWrapper.Destroy;
begin
  FZapMQWrapper.Free;
  inherited;
end;

function TWorkerWrapper.QueueHandler(pMessage: TZapJSONMessage;
  var pProcessing: boolean): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ProcessId', FProcessId.ToString);
  pProcessing := False;
end;

class procedure TWorkerWrapper.Start(const pHostZapMQ : string; const pPortZapMQ : integer);
begin
  if not Assigned(WorkerWrapper) then
    WorkerWrapper := TWorkerWrapper.Create(pHostZapMQ, pPortZapMQ);
end;

class procedure TWorkerWrapper.Stop;
begin
  if Assigned(WorkerWrapper) then
    WorkerWrapper.Free;
end;

end.
