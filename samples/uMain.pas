unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, WorkerWrapper.Core, ZapMQ.Message.JSON, JSON;

type
  TForm2 = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    function KeepAliveHandler(pMessage : TZapJSONMessage;
      var pProcessing : boolean) : TJSONObject;
    function SafeStopHandler(pMessage : TZapJSONMessage;
      var pProcessing : boolean) : TJSONObject;
  public
    SimulateCrash : boolean;
  end;

var
  Form2: TForm2;

implementation


{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  SimulateCrash := True;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TWorkerWrapper.Stop;
  Action := caFree;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  TWorkerWrapper.Start('localhost', 5679, KeepAliveHandler, SafeStopHandler);
  SimulateCrash := False;
  Label2.Caption := 'Process ID :' + GetCurrentProcessId.ToString;
end;

function TForm2.KeepAliveHandler(pMessage: TZapJSONMessage;
  var pProcessing: boolean): TJSONObject;
begin
  if SimulateCrash then
  begin
    Sleep(INFINITE);
    Result := nil;
  end
  else
  begin
    TWorkerWrapper.Trace('KEEP ALIVE RECIVED');
    Memo1.Lines.Add('***** KEEP ALIVE RECIVED *****');
    Sleep(StrToInt(Edit1.Text));
    Result := TJSONObject.Create;
    Result.AddPair('ProcessId', GetCurrentProcessId.ToString);
    pProcessing := False;
    Memo1.Lines.Add('----- KEEP ALIVE ANSERED -----');
    TWorkerWrapper.Trace('KEEP ALIVE ANSERED');
  end;
end;

function TForm2.SafeStopHandler(pMessage: TZapJSONMessage;
  var pProcessing: boolean): TJSONObject;
begin
  TWorkerWrapper.Trace('SAFE STOP RECIVED');
  pProcessing := False;
  Result := nil;
  TThread.Queue(nil, procedure
  begin
    Application.MainForm.Close;
  end);
end;

end.
