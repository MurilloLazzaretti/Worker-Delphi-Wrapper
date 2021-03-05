unit WorkerWrapper.Core;

interface

uses
  ZapMQ.Wrapper, ZapMQ.Message.JSON, JSON, ZapMQ.Handler;

type
  TWorkerWrapper = class
  private
    FZapMQWrapper : TZapMQWrapper;
    FProcessID : Cardinal;
    FKeepAliveHandler: TZapMQHanlder;
    FSafeStopHandler: TZapMQHanlder;
    procedure BindKeepAliveQueue;
    procedure BindSafeStopQueue;
    procedure SetKeepAliveHandler(const Value: TZapMQHanlder);
    procedure SetSafeStopHandler(const Value: TZapMQHanlder);
  protected
    constructor Create(const pHostZapMQ : string; const pPortZapMQ : integer;
      const pKeepAliveHandler : TZapMQHanlder; const pSafeStopHandler : TZapMQHanlder); overload;
  public
    property KeepAliveHandler : TZapMQHanlder read FKeepAliveHandler write SetKeepAliveHandler;
    property SafeStopHandler : TZapMQHanlder read FSafeStopHandler write SetSafeStopHandler;
    class procedure Start(const pHostZapMQ : string; const pPortZapMQ : integer;
      const pKeepAliveHandler : TZapMQHanlder; const pSafeStopHandler : TZapMQHanlder);
    class procedure Stop;
    destructor Destroy; override;
  end;

  var WorkerWrapper : TWorkerWrapper;

implementation

uses
  Windows, System.SysUtils, ZapMQ.Queue, Vcl.Forms;

{ TWorkerWrapper }

procedure TWorkerWrapper.BindKeepAliveQueue;
begin
  FZapMQWrapper.Bind(FProcessID.ToString, KeepAliveHandler, TZapMQQueuePriority.mqpLow)
end;

procedure TWorkerWrapper.BindSafeStopQueue;
begin
  FZapMQWrapper.Bind(FProcessID.ToString + 'SS', SafeStopHandler, TZapMQQueuePriority.mqpLow)
end;

constructor TWorkerWrapper.Create(const pHostZapMQ: string; const pPortZapMQ : integer;
  const pKeepAliveHandler : TZapMQHanlder; const pSafeStopHandler : TZapMQHanlder);
begin
  FZapMQWrapper := TZapMQWrapper.Create(pHostZapMQ, pPortZapMQ);
  FProcessID := GetCurrentProcessId;
  FKeepAliveHandler := pKeepAliveHandler;
  FSafeStopHandler := pSafeStopHandler;
  BindKeepAliveQueue;
  BindSafeStopQueue;
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

class procedure TWorkerWrapper.Start(const pHostZapMQ : string; const pPortZapMQ : integer;
  const pKeepAliveHandler : TZapMQHanlder; const pSafeStopHandler : TZapMQHanlder);
begin
  if not Assigned(WorkerWrapper) then
    WorkerWrapper := TWorkerWrapper.Create(pHostZapMQ, pPortZapMQ,
      pKeepAliveHandler, pSafeStopHandler);
end;

class procedure TWorkerWrapper.Stop;
begin
  if Assigned(WorkerWrapper) then
    WorkerWrapper.Free;
end;

end.
