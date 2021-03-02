program WorkerWrapper;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ZapMQ.Message.JSON,
  JSON,
  Windows,
  WorkerWrapper.Core in 'src\WorkerWrapper.Core.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  TWorkerWrapper.Start('localhost', 5679);
  Readln;
  TWorkerWrapper.Stop;
end.
