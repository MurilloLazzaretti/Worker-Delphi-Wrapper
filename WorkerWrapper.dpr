program WorkerWrapper;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  WorkerWrapper.Core in 'src\WorkerWrapper.Core.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  TWorkerWrapper.Start('localhost', 5679);
  Readln;
  TWorkerWrapper.Stop;
end.
