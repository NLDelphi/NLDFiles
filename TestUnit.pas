{WXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXW}
(*                                                                                               *)
(* Unitname:            TestUnit.pas                                                             *)
(*                                                                                               *)
(* Description:         Test for TNLDFileSplitter and TNLDFileMerger                             *)
(*                                                                                               *)
(* Author:              Henkie                                                                   *)
(*                                                                                               *)
{WXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXW}

unit TestUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, ExtCtrls, ComCtrls, AppEvnts,
  ActnList, jpeg, UNLDFiles, StdActns;

type
  TFrmMain = class(TForm)
    GrpSplit: TGroupBox;
    LblSplitFileName: TLabel;
    EdtSplitFileName: TEdit;
    BtnSplitLoad: TButton;
    LblSplitDestDir: TLabel;
    EdtSplitDestDir: TEdit;
    BtnSplitChoose: TButton;
    ChkAutoCreateDir: TCheckBox;
    BtnSplit: TButton;
    RgSplitOptions: TRadioGroup;
    GrpPieces: TGroupBox;
    LblSplitPieces: TLabel;
    UdSplitPieces: TUpDown;
    GrpSize: TGroupBox;
    EdtSize: TEdit;
    GrpMerger: TGroupBox;
    LblMergeFileName: TLabel;
    EdtMergeFileName: TEdit;
    BtnMergeLoad: TButton;
    LblMergeFiles: TLabel;
    LbMergeFiles: TListBox;
    BtnMergeFiles: TButton;
    BtnDelSel: TButton;
    BtnMerge: TButton;
    RgMergeOptions: TRadioGroup;
    ActList: TActionList;
    ActDel: TAction;
    CdlOpen: TOpenDialog;
    ImgNLDelphi: TImage;
    BtnClose: TButton;
    Button1: TButton;
    ActHelpTOC: THelpContents;
    procedure BtnSplitLoadClick(Sender: TObject);
    procedure BtnSplitChooseClick(Sender: TObject);
    procedure BtnSplitClick(Sender: TObject);
    procedure BtnMergeLoadClick(Sender: TObject);
    procedure BtnMergeFilesClick(Sender: TObject);
    procedure BtnMergeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UdSplitPiecesChangingEx(Sender: TObject;
      var AllowChange: Boolean; NewValue: Smallint;
      Direction: TUpDownDirection);
    procedure LbMergeFilesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RgSplitOptionsClick(Sender: TObject);
    procedure ActDelExecute(Sender: TObject);
    procedure ActDelUpdate(Sender: TObject);
    procedure ImgNLDelphiClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
  private
    procedure DoeDeError(Sender: TObject; aSplitError: TSplitError);
    procedure DoeDeMergeError(Sender:TObject; aMergeError:TMergeError);
    procedure DoeVoorDeSplit(Sender:TObject);
    procedure DoeDeSplit(Sender: TObject);
    procedure DoeNaDeSplit(Sender:TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

const
  fMainCaption = 'TNLDFileSplitter/ TNLDFileMerger - testapplication by Henkie';

var
  FrmMain: TFrmMain;

implementation

uses
  StrUtils, FileCtrl, TypInfo, ShellAPI, ShlObj;

{$R *.dfm}


procedure TFrmMain.BtnSplitLoadClick(Sender: TObject);
begin
  cdlopen.options:=cdlopen.options + [ofFileMustExist];
  CdlOpen.Options:=CdlOpen.options - [ofAllowMultiSelect];
  if CdlOpen.execute then
    EdtSplitFileName.text:=CdlOpen.filename;
end;

procedure TFrmMain.BtnSplitChooseClick(Sender: TObject);

  //functie BrowseDialog: gevonden op AboutDelphi (delphi.about.com/library/weekly/aa122803a.htm)
  function BrowseDialog(const Title:string; const Flag:integer):string;
  var
    lpItemID: PItemIDList;
    BrowseInfo:TBrowseInfo;
    DisplayName: array[0 ..MAX_PATH] of char;
    TempPath: array[0 ..MAX_PATH] of char;
  begin
    result:='';
    FillChar(BrowseInfo,sizeof(TBrowseInfo),#0);
    with BrowseInfo do
    begin
      hwndowner:=Application.handle;
      pszDisplayName:=@DisplayName;
      lpszTitle:=pchar(Title);
      ulFlags:=Flag;
    end;
    lpItemID:=SHBRowseForFolder(BrowseInfo);
    if lpItemID <> nil then
    begin
      SHGetPathFromIDList(lpItemID,TempPath);
      Result:=TempPath;
      GlobalFreePtr(lpItemID);
    end;
  end;

const
  //toon hint in BrowseDialog, ontbreekt in ShlObj
  BIF_UAHINT = $100;
var
  dir:string;
begin
  //gebruik de newstyle dialog
  dir:=BrowseDialog('Select destination dir',{BIF_USENEWUI}BIF_NEWDIALOGSTYLE or BIF_UAHINT);
  if dir <> '' then
    EdtSplitDestDir.Text:=dir;
end;

procedure TFrmMain.BtnSplitClick(Sender: TObject);
var
  fs:TNLDFileSplitter;
begin
  fs:=TNLDFileSplitter.create(nil);
  try
    fs.Onspliterror:=doedeerror;
    fs.OnBeforeSplit:=doevoordesplit;
    fs.OnAfterSplit:=doenadesplit;
    fs.AutoCreateDir:=ChkAutoCreateDir.checked;
    fs.FileName:=EdtSplitFileName.Text;
    fs.DestDir:=EdtSplitDestDir.Text;
    fs.numberofpieces:=udSplitPieces.Position;
    fs.SizeOfPieces:=strtoint(edtsize.text);
    fs.SplitOptions:=TSplitoptions(rgSplitOptions.itemindex);
    fs.split;
  finally
    fs.free;
  end;
end;

procedure tFrmMain.DoeDeError(Sender:TObject; aSplitError:TSplitError);
//misschien handiger om in een array[TSplitError] of string te zetten
var
  s:string;
begin
  case aspliterror of
    seCannotCreateDestDir:s:='Cannot create Dest dir';
    seCannotCreateFiles:s:='Cannot create files';
//    seInvalidAddress:s:='Invalid address';
    seInvalidNumberOfPieces:s:='Invalid number of pieces';
    seIvalidSizeOfPieces:s:='Invalid size of pieces';
    seNoDestDir:s:='No destination directory';
    seNoFileName:s:='No filename';
  end;
  showmessage(s);
end;

procedure TFrmMain.DoeDeMergeError(Sender: TObject;
  aMergeError: TMergeError);
begin
  showmessage('oopsie, fout in Merge');
end;

procedure tFrmMain.DoeDeSplit(Sender:TObject);
begin
  //wat te doen tijdens de split?
end;


procedure TFrmMain.DoenaDeSplit(Sender: TObject);
begin
  //wat te doen na de split?
end;

procedure TFrmMain.DoeVoorDeSplit(Sender: TObject);
begin
  //wat te doen voor de split?
end;

procedure TFrmMain.BtnMergeLoadClick(Sender: TObject);
begin
  if CdlOpen.execute then
    EdtMergeFileName.text:=CdlOpen.filename;
end;

procedure TFrmMain.BtnMergeFilesClick(Sender: TObject);
var
  i:integer;
begin
  cdlopen.options:=cdlopen.options - [ofFileMustExist];
  CdlOpen.Options:=CdlOpen.options + [ofAllowMultiSelect];
  if not CdlOpen.execute then
    exit;
  for i:= 0 to pred(cdlopen.Files.Count) do
    LbMergeFiles.Items.Add(cdlopen.Files[i]);
end;

procedure TFrmMain.BtnMergeClick(Sender: TObject);
var
  fm:TNLDFilemerger;
  i:integer;
begin
  if LbMergeFiles.Count = 0 then
    exit;
  try
    fm:=TNLDFileMerger.create(nil);
    try
      fm.Onmergeerror:=doedemergeerror;
      for i:=0 to pred(LbMergeFiles.Count) do
      begin
        fm.SourceFile:=EdtMergeFileName.Text;
        fm.MergeFile:=LbMergeFiles.Items.Strings[i];
        fm.MergeOptions:=TMergeOptions(RgMergeOptions.ItemIndex);
        fm.Merge;
      end;
    finally
      fm.free;
    end;
  except
    showmessage('oops, foutje bij het Mergen');
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Caption:=fMainCaption;
  edtsize.text:='0';
  application.ShowHint:=true;
  //stel de items in van de radiogroup met splitoptions
  RgSplitOptions.Items.Add(GetEnumName(typeinfo(TSplitOPtions),0));
  RgSplitOptions.Items.Add(GetEnumName(typeinfo(TSplitOPtions),1));
  //itemindex instellen
  RgSplitOptions.ItemIndex:=getenumvalue(typeinfo(TSplitOptions),'soNumberOfPieces');
  UdSplitPieces.Min:=low(TSplitcount);
  udsplitPieces.max:=high(tsplitcount);
  udsplitPieces.position:=UdSplitPieces.Min;
  UdSplitPieces.Width:=GetsystemMetrics(SM_CXVSCROLL);
  UdSplitPieces.Height:=GetsystemMetrics(SM_CYVSCROLL)*2;
  UdSplitPieces.Top:=LblSplitPieces.Top+(LblSplitPieces.Height div 2)-GetsystemMetrics(SM_CYVSCROLL);
  EdtSplitFileName.Clear;
  EdtSplitDestDir.Clear;
  EdtMergeFileName.Clear;
  LbMergeFiles.Clear;
  ChkAutoCreateDir.Checked:=true;
  //stel de items in van de radiogroup met mergeoptions
  RgMergeOptions.Items.Add(GetEnumName(typeinfo(TMergeOPtions),0));
  RgMergeOptions.Items.Add(GetEnumName(typeinfo(TMergeOPtions),1));
  //itemindex instellen
  RgMergeOptions.ItemIndex:=getenumvalue(typeinfo(TMergeOptions),'moAtEndOfFile');
end;

procedure TFrmMain.UdSplitPiecesChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Smallint;
  Direction: TUpDownDirection);
begin
  Allowchange:=newvalue in [low(TSplitCount)..high(TSplitCount)];
  if not AllowChange then
    exit;
  LblSplitPieces.Caption:=inttostr(newvalue);
end;

procedure TFrmMain.LbMergeFilesMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  pt:tpoint;
  idx:integer;
begin
  //toon de volledige bestandsnaam als hint
  pt:=point(x,y);
  idx:=tlistbox(sender).itemAtPos(pt,true);
  if idx > -1 then
    tlistbox(sender).Hint:=tlistbox(sender).Items[idx]
  else
    tlistbox(sender).hint:='';
  application.ActivateHint(tlistbox(sender).clienttoscreen(pt));
end;

procedure TFrmMain.RgSplitOptionsClick(Sender: TObject);

  procedure EnableGrpPieces(b:boolean);
  var
    i:integer;
  begin
    case b of
      ///////
      true:
      begin
        for i := 0 to pred(GrpSize.ControlCount) do
          Grpsize.controls[i].enabled:=false;
        for i:= 0 to pred(GrpPieces.controlcount) do
          GrpPieces.Controls[i].Enabled:=true;
      end;
      ///////
      false:
      begin
        for i := 0 to pred(GrpSize.ControlCount) do
          Grpsize.controls[i].enabled:=true;
        for i:= 0 to pred(GrpPieces.controlcount) do
          GrpPieces.Controls[i].Enabled:=false;
      end;
    end;//case b
    GrpPieces.enabled:=b;
    GrpSize.enabled:=not b;
  end;

begin
  //omdat je bij het disabelen van een groupbox de items niet ziet meeveranderen, doen we het zelf
  enableGrpPieces(RgSplitOptions.itemindex = 0);
end;

procedure TFrmMain.ActDelExecute(Sender: TObject);
begin
  LbMergeFiles.DeleteSelected;
end;

procedure TFrmMain.ActDelUpdate(Sender: TObject);
begin
  ActDel.enabled:=LbMergeFiles.SelCount > 0;
end;

procedure TFrmMain.ImgNLDelphiClick(Sender: TObject);
begin
  //open site van NLDelphi in defaultbrowser
  ShellExecute(handle,'Open',pchar('www.NLDelphi.com'),nil,nil,0);
end;

procedure TFrmMain.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

