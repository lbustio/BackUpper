program Backupper;

uses
  Forms,
  FrmPrincipal in 'FrmPrincipal.pas' {frmMain},
  frmWait in 'frmWait.pas' {frmEspera},
  TUtils in 'TUtils.pas',
  TNodeData in 'TNodeData.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmEspera, frmEspera);
  Application.Run;
end.
