program Backupper;

uses
  Forms,
  FrmPrincipal in 'FrmPrincipal.pas' {frmMain},
  frmWait in 'frmWait.pas' {frmEspera};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmEspera, frmEspera);
  Application.Run;
end.
