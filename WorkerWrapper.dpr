program WorkerWrapper;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ZapMQ.Message.JSON,
  JSON,
  Windows,
  WorkerWrapper.Core in 'src\WorkerWrapper.Core.pas';

function QueueHandler(pMessage: TZapJSONMessage; var pProcessing: boolean): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ProcessId', GetCurrentProcessId.ToString);
  pProcessing := False;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  //TWorkerWrapper.Start('localhost', 5679, QueueHandler);
  Readln;
  TWorkerWrapper.Stop;
end.
