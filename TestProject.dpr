program TestProject;

uses
  Forms,
  TestUnit in 'TestUnit.pas' {FrmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.HelpFile := 'C:\Program Files\Borland\Delphi7\Projects\NLD\TFileMergerSplitter\UNLDFilesHelp.hlp';
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
