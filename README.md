## 🇧🇷 Worker-Delphi-Wrapper 🇧🇷

Wrapper for Delphi to application that will be monitored by [`Worker Control`](https://github.com/MurilloLazzaretti/Worker-Control) With this wrapper your application will start and finish by Worker Control and monitored if it crashes.

## ⚙️ Installation

Installation is done using the [`boss install`](https://github.com/HashLoad/boss) command:
``` sh
$ boss install https://github.com/MurilloLazzaretti/Worker-Delphi-Wrapper.git
```

## ⚡️ First step

You need to start the Wrapper and provide the IP and Port of the ZapMQ service and the Handler for KeepAlive and for SafeStop.

```delphi
uses WorkerWrapper.Core,;

begin  
  TWorkerWrapper.Start('localhost', 5679, KeepAliveHandler, SafeStopHandler);
end;
```

Before your application finish, stop the wrapper.

```delphi
begin  
  TWorkerWrapper.Stop;
end;  
```

## 🧬 Resources

📞  _Keep Alive_

This resource tell`s to the Worker Control that your app is alive, so just copy and paste the code bellow and its done.

```delphi
uses
    ZapMQ.Message.JSON, JSON, Windows;

function KeepAliveHandler(pMessage : TZapJSONMessage; var pProcessing : boolean) : TJSONObject;
begin
    Result := TJSONObject.Create;
    Result.AddPair('ProcessId', GetCurrentProcessId.ToString);
    pProcessing := False;
end;
```

🔈  _IMPORTANT_ 

Implement the Keep Alive handler in your main thread, this will prove if your app is crashed or not.

🔐 _Safe Stop_

This handler will be raised in your app when Worker Control needs to close the app safely. implement this as you want but dont forget to make sure that your app will be closed. After this, Worker Control will not monitore this instace any more.

```delphi
uses
    ZapMQ.Message.JSON, JSON;

function SafeStopHandler(pMessage : TZapJSONMessage; var pProcessing : boolean) : TJSONObject;
begin
    pProcessing := False;
    Result := nil;
    TThread.Queue(nil, procedure
    begin
        Application.MainForm.Close;
    end);
end;
```

💎 _Trace App_ 

Coming Soon