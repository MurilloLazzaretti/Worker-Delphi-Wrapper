program SimpleSample;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form2},
  WorkerWrapper.Core in '..\src\WorkerWrapper.Core.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
