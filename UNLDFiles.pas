{WXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXW}
(*                                                                                               *)
(* Unitname:            UNLDFiles.pas                                                            *)
(*                                                                                               *)
(* Description:         Unit with the following classes and types                                *)
(*                                                                                               *)
(* Classes:             TNLDFileMerger                                                           *)
(*                      TNLDFileSplitter                                                         *)
(*                                                                                               *)
(* Types:               TSplitCount                                                              *)
(*                      TSplitOptions                                                            *)
(*                      TSplitError                                                              *)
(*                      TSplitErrorEvent                                                         *)
(*                      TMergeOptions                                                            *)
(*                      TMergeError                                                              *)
(*                      TMergeErrorEvent                                                         *)
(*                                                                                               *)
(* Author:              Henkie                                                                   *)
(*                                                                                               *)
{WXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXWXW}

{
 TODO:
      -Er moet nog een DCR-bestand gemaakt worden om de componenten makkelijker te kunnen
        onderscheiden op de Component Palette
      -Splitten op Address is nog niet geïmplementeerd
      -Helpbestand moet nog gemaakt worden
}

{
 UITLEG COMPONENTEN:
            -TNLDFileSplitter:
              //Component dat gebruikt wordt om een bestand te splitsen in een bepaald aantal stukken
              //of om een bestand te splitsen in stukken van een bepaalde grootte uitgedrukt in bytes
            -TNLDFileMerger:
              //Component dat gebruikt wordt om meerdere bestanden aan elkaar te plakken.
              //Dit kan zowel aan het begin als aan het einde van het bestand gebeuren
}

unit UNLDFiles;

interface

uses
  Windows, Classes, SysUtils;

type

  TSplitCount = 2..100;                  //minimum en maximum aantal stukken

  TSplitOptions = (soNumberOfPieces,     //splitten in X aantal stukken
                   soSizeOfPieces);      //splitten in stukken van minstens X bytes groot

  TSplitError = (seNoFileName,           //geen bestand opgegeven of bestand bestaat niet
                 seNoDestDir,            //geen DestDir opgegeven
                                         //AutoCreateDir is false en DestDir bestaat niet
                 seInvalidNumberOfPieces,//het aantal stukken is niet correct
                 seIvalidSizeOfPieces,   //de opgegeven grootte van de stukken is te groot
//                 seInvalidAddress,       //het opgegeven adres is ongeldig
                 seCannotCreateDestDir,  //kan de DestDir niet aanmaken
                 seCannotCreateFiles);   //kan de gesplitte bestanden niet aanmaken

  TSplitErrorEvent = procedure (Sender:TObject; aSplitError:TSplitError) of object;

  TNLDFileSplitter = class(TComponent)
  private
    fAutoCreateDir: boolean;
//    fAddress: cardinal;
    fSizeOfPieces: cardinal;
    fDestDir: string;
    fFileName: TFileName;
    fNumberOfPieces: TSplitCount;
    fOnSplitError: TSplitErrorEvent;
    fSplitOptions: TSplitOptions;
    fOnAfterSplit: TNotifyEvent;
    fOnBeforeSplit: TNotifyEvent;
    procedure readcopyright(reader:treader);
    procedure writecopyright(writer:twriter);
//    procedure SetAddress(const Value: cardinal);
    procedure SetDestDir(const Value: string);
    procedure SetFileName(const Value: TFileName);
    procedure SetSizeOfPieces(const Value: cardinal);
    function GetFileName: TFileName;
  protected
    procedure DefineProperties(filer:TFiler);override;
    procedure DoBeforeSplit;virtual;
    procedure DoSplit;virtual;
    procedure DoAfterSplit;virtual;
    procedure DoSplitError(aError:TSplitError);virtual;
  public
    constructor Create(AOwner:TComponent);override;
    procedure Split;
  published
    //moet de opgegeven DestDir aangemaakt worden indien deze niet bestaat
    property AutoCreateDir:boolean read fAutoCreateDir write fAutoCreateDir default true;
    //het te splitten bestand
    property FileName:TFileName read GetFileName write SetFileName;
    //de map waarin de gesplitte delen komen
    property DestDir:string read fDestDir write SetDestDir;
    //hoeveel stukken
    property NumberOfPieces:TSplitCount read fNumberOfPieces write fNumberOfPieces default 2;
    //grootte van de stukken
    property SizeOfPieces:cardinal read fSizeOfPieces write SetSizeOfPieces default 1;
    //splitten op adres
//    property Address:cardinal read fAddress write SetAddress;
    //de opties
    property SplitOptions:TSplitOptions read fSplitOptions write fSplitOptions default soNumberOfPieces;
    //de events
    property OnBeforeSplit:TNotifyEvent read fOnBeforeSplit write fOnBeforeSplit;
    property OnAfterSplit:TNotifyEvent read fOnAfterSplit write fOnAfterSplit;
    property OnSpliterror:TSplitErrorEvent read fOnSplitError write fOnSplitError;
  end;

  TMergeOptions = (moAtBeginningOfFile,           //toevoegen aan het begin van het bestand
                   moAtEndOfFile);                //toevoegen aan einde van het bestand

  TMergeError = (meInvalidSourceFile,             //SourceFile bestaat niet of niet opgegeven
                 meInvalidMergeFile,              //MergeFile bestaat niet of niet opgegeven
                 meCannotConcatFiles);            //kan MergeFile en SourceFile niet aan elkaar plakken :)

  TMergeErrorEvent = procedure (Sender:TObject; aMergeError:TMergeError) of object;

  TNLDFileMerger = class(TComponent)
  private
    fMergeFile: TFileName;
    fSourceFile: TFileName;
    fOnMergeError: TMergeErrorEvent;
    fMergeOptions: TMergeOptions;
    fOnMerge: TNotifyEvent;
    procedure readcopyright(reader:treader);
    procedure writecopyright(writer:twriter);
    procedure SetMergeFile(const Value: TFileName);
    procedure SetSourceFile(const Value: TFileName);
  protected
    procedure DefineProperties(filer:TFiler);override;
    procedure DoMerge;virtual;
    procedure DoMergeError(aError:TMergeError);virtual;
  public
    constructor Create(AOwner:TComponent);override;
    procedure Merge;
  published
    //het bestand welke wordt aangepast door er MergeFile voor/achter te schrijven
    //bij dit bestand moet je acheraf de bestandextensie veranderen
    property SourceFile:TFileName read fSourceFile write SetSourceFile;
    //het bestand welke aan SourceFile wordt geschreven
    property MergeFile:TFileName read fMergeFile write SetMergeFile;
    //de opties
    property MergeOptions:TMergeOptions read fMergeOptions write fMergeOptions default moAtEndOfFile;
    //de events
    property OnMerge:TNotifyEvent read fOnMerge write fOnMerge;
    property OnMergeError:TMergeErrorEvent read fOnMergeError write fOnMergeError;
  end;

const
  //format voor bestandsnaam die gebruikt wordt om het bestand te saven na het splitten
  formatStr = '%s%s.%.3d';
  //OpenSourceURL komt altijd in de DFM te staan (OpenSourceURL = TFile(Merger/Splitter)Copyright
  //beetje reklame maken :)
  sOpenSourceURL = 'OpenSourceURL';

procedure Register;

implementation

uses
  StrUtils;

var
  TFileMergerCopyright :string = 'TNLDFileMerger - NLDelphi-OpenSource (www.NLDelphi.com)'#13#10'Made by Henkie';
  TFileSplitterCopyright :string = 'TNLDFileSplitter - NLDelphi-OpenSource (www.NLDelphi.com)'#13#10'Made by Henkie';

procedure Register;
begin
  RegisterComponents('NLDelphi',[TNLDFileSplitter, TNLDFileMerger]);
end;

//functie GetFileSize: gevonden op NLDelphi (www.nldelphi.com/forum/showthread.php?s=&threadid=13534)
function GetFileSize(aFileName:string):int64;
var
  sr:TSearchrec;
begin
  result:=-1;
  if FindFirst(aFileName,faAnyFile,sr) = 0 then
    result:=int64(sr.size);
  findclose(sr);
end;

function GetWinDir:string;
var
  buf:string;
  lengte:integer;
begin
  setlength(buf,max_path);
  lengte:=getwindowsdirectory(pchar(buf),max_path);
  if lengte <> 0 then
    result:=buf
  else
    result:='';
  setlength(result,lengte);
  result:=trim(result);
  if trim(rightstr(result,1)) <> '\' then
    result:=result + '\';
end;

{ TNLDFileSplitter }

constructor TNLDFileSplitter.Create(AOwner: TComponent);
begin
  inherited;
  fAutoCreateDir:=true;
  fFileName:='';
  SetDestDir(GetWinDir);
  fSizeOfPieces:=1;
  fNumberOfPieces:=2;
//  fAddress:=0;
  fSplitOptions:=soNumberOfPieces;
end;

procedure TNLDFileSplitter.DefineProperties(filer: TFiler);
begin
  inherited;
  //copyright-melding wegschrijven in DFM
  filer.defineproperty(sOpenSourceURL,readcopyright,writecopyright,true);//altijd wegschrijven
end;

procedure TNLDFileSplitter.DoAfterSplit;
begin
  if assigned(fOnAfterSplit) then
    fOnAfterSplit(self);
end;

procedure TNLDFileSplitter.DoBeforeSplit;
begin
  if assigned(fOnBeforeSplit) then
    fOnBeforeSplit(self);
end;

procedure TNLDFileSplitter.DoSplit;
var
  fs:TFileStream;
  ms:TMemoryStream;
  gelezen, size,rest:int64;

  function ProperDir:string;
  //een directory eindigt met een backslash
  begin
    result:=fdestdir;
    if trim(rightstr(result,1)) <> '\' then
      result:=result + '\';
  end;

  procedure DoNumberOfPieces;
  //splits in x aantal stukken
  var
    i:integer;
    gemiddelde:int64;
  begin
    try
      fs:=tfilestream.create(ffilename,fmopenread or fmShareDenyNone);
      try
        size:=getfilesize(ffilename);
        fs.Position:=0;
        size:=fs.size;
        gemiddelde:=size div fNumberOfPieces;
        rest:=size;
        for i := 1 to fNumberOfPieces do
        begin
          ms:=tmemorystream.create;
          try
            if not (i = fNumberOfPieces) then
            begin
              gelezen:=ms.CopyFrom(fs,gemiddelde);
              //fs.Position:=fs.Position+gelezen;
              rest:=rest-gelezen;
            end else
              ms.CopyFrom(fs,rest);
            ms.SaveToFile(format(formatStr,[properDir,extractfilename(ffilename),i]));
          finally
            Ms.free;
          end;
        end;
      finally
      end;
    except
      DoSplitError(seCannotCreateFiles);
    end;
  end;

  procedure DoSizeOfPieces;
  //splits in stukken van X bytes
  var
    i:integer;
  begin
    try
      fs:=tfilestream.Create(ffilename,fmopenread or fmShareDenyNone);
      try
        size:=getfilesize(ffilename);
//        size:=fs.Size;
        rest:=size;
        i:=1;
        repeat
          ms:=tmemorystream.create;
          try
            gelezen:=ms.CopyFrom(fs,fSizeOfPieces);
            fs.Position:=fs.Position+gelezen;
            rest:=rest-gelezen;
            ms.SaveToFile(format(formatStr,[properDir,extractfilename(ffilename),i]));
          finally
            Ms.free;
          end;
        until (rest=0);
      finally
      end;
    except
      DoSplitError(seCannotCreateFiles);
    end;
  end;

//TODO: splitten op Address moet nog gebeuren, feel free :)
begin
  if not fileexists(self.fFileName) then
  begin
    DoSplitError(seNoFileName);
    exit;
  end;
  if not DirectoryExists(self.fDestDir)then
  begin
    DoSpliterror(seNoDestDir);
    exit;
  end;
  if (self.SplitOptions = soNumberOfPieces) and (not self.fNumberOfPieces in [low(TSplitCount)..high(TSplitCount)]) then
    begin
      DoSplitError(seInvalidNumberOfPieces);
      exit;
    end;
  if (self.SplitOptions = soSizeOfPieces) and (not self.fSizeOfPieces in [0..integer(GetFileSize(self.fFileName))]) then
  begin
    DoSplitError(seInvalidNumberOfPieces);
    exit;
  end;
{  if self.fAddress >  GetFileSize(fFileName) then
  begin
    DoSplitError(seInvalidAddress);
    exit;
  end;
}  if (not DirectoryExists(self.fDestDir)) and (not (CreateDir(self.fDestDir))) then
  begin
    DoSplitError(seCannotCreateDestDir);
    exit;
  end;
  case fSplitoptions of
    soNumberOfPieces:DoNumberOfPieces;
    soSizeOfPieces:DoSizeOfPieces;
  end;//case
end;

procedure TNLDFileSplitter.DoSplitError(aError: TSplitError);
begin
  if assigned (fOnSplitError) then
    fOnSplitError(self,aError);
end;

function TNLDFileSplitter.GetFileName: TFileName;
begin
  result:=fFileName;
end;

procedure TNLDFileSplitter.readcopyright(reader: treader);
begin
  reader.readstring;
end;

{
procedure TNLDFileSplitter.SetAddress(const Value: cardinal);
var
  fSize:int64;
begin
  fSize:=GetFileSize(self.FileName);
  if (fsize > -1) then
  begin
    //splitten na einde bestand mag niet
    if (value > fsize) then
    begin
      DoSplitError(seInvalidAddress);
      exit;
    end;
    if not (Value = fAddress) then
        fAddress:=value;
  end;
end;
}

procedure TNLDFileSplitter.SetDestDir(const Value: string);
begin
  if not (fDestDir = Value) then
  begin
    if not DirectoryExists(value) then
      if AutoCreateDir then
        try
          if not sysutils.ForceDirectories(value) then
          begin
            DoSplitError(seCannotCreateDestDir);
            exit;
          end;
        except
          DoSplitError(seCannotCreateDestDir);
          exit;
        end
      else
      begin
        DoSplitError(seCannotCreateDestDir);
        exit;
      end;
      fDestDir:=value;
  end;
end;

procedure TNLDFileSplitter.SetFileName(const Value: TFileName);
begin
  if not (fFileName = Value) then
  begin
    if not fileexists(value) then
    begin
      DoSplitError(seNoFileName);
      exit;
    end;
    fFileName:=value;
  end;
end;

procedure TNLDFileSplitter.SetSizeOfPieces(const Value: cardinal);
var
  fSize:int64;
begin
  fSize:=GetFileSize(self.FileName);
  //de stukken mogen maximum de bestandsgrootte zijn
  if (fsize < 0) or (value > fsize) then
  begin
    DoSplitError(seIvalidSizeOfPieces);
    exit;
  end;
  if not (fSizeOfPieces = value) then
    fSizeOfPieces:=value;
end;

procedure TNLDFileSplitter.Split;
begin
  DoBeforeSplit;
  DoSplit;
  DoAfterSplit;
end;

procedure TNLDFileSplitter.writecopyright(writer: twriter);
begin
  writer.writestring(tFileSplittercopyright);
end;

{ TNLDFileMerger }

constructor TNLDFileMerger.Create(AOwner: TComponent);
begin
  inherited;
  fSourceFile:='';
  fMergeFile:='';
  fMergeOptions:=moAtEndOfFile;
end;

procedure TNLDFileMerger.DefineProperties(filer: TFiler);
begin
  inherited;
  //schrijf copyright-melding in DFM
  filer.defineproperty(sOpenSourceURL,readcopyright,writecopyright,true);//altijd wegschrijven
end;

procedure TNLDFileMerger.DoMerge;
var
  dummy, fs, ms:TMemorystream;

  //volgende 2 sub-procedures kunnen evengoed in 1 sub-procedure geschreven worden

  procedure MergeAtBeginning;
  begin
    try
      fs:=tmemorystream.create;
      try
        fs.LoadFromFile(fsourcefile);
        ms:=tmemorystream.Create;
        try
          ms.LoadFromFile(fMergeFile);
          dummy:=tmemorystream.create;
          try
            dummy.CopyFrom(ms,ms.size);
            dummy.CopyFrom(fs,fs.size);
            DeleteFile(fSourceFile);
            dummy.SaveToFile(fSourceFile);
          finally
            dummy.free;
          end;
        finally
          ms.Free;
        end;
      finally
        fs.free;
      end;
    except
      DoMergeError(meCannotConcatFiles);
    end;
  end;

  procedure MergeAtEnd;
  begin
    try
      fs:=tmemorystream.create;
      try
        fs.LoadFromFile(fsourcefile);
        ms:=tmemorystream.Create;
        try
          ms.LoadFromFile(fMergeFile);
          dummy:=tmemorystream.create;
          try
            dummy.CopyFrom(fs,fs.size);
            dummy.CopyFrom(ms,ms.size);
            DeleteFile(fSourceFile);
            dummy.SaveToFile(fSourceFile);
          finally
            dummy.free;
          end;
        finally
          ms.Free;
        end;
      finally
        fs.free;
      end;
    except
      DoMergeError(meCannotConcatFiles);
    end;
  end;

begin
  if not fileexists(self.fSourceFile) then
  begin
    DoMergeError(meInvalidSourceFile);
    exit;
  end;
  if not fileexists(self.fMergeFile) then
  begin
    DoMergeError(meInvalidMergeFile);
    exit
  end;
  if assigned(fOnMerge) then
    fOnMerge(self);
  case fMergeOptions of
    moAtBeginningOfFile:MergeAtBeginning;
    moAtEndOfFile:MergeAtEnd;
  end;//case
end;

procedure TNLDFileMerger.DoMergeError(aError: TMergeError);
begin
  if assigned(fOnMergeError) then
    fOnMergeError(self,aError);
end;

procedure TNLDFileMerger.Merge;
begin
  DoMerge;
end;

procedure TNLDFileMerger.readcopyright(reader: treader);
begin
  reader.readstring;
end;

procedure TNLDFileMerger.SetMergeFile(const Value: TFileName);
begin
  if not (fMergeFile = Value) then
  begin
    if not FileExists(value) then
    begin
      DoMergeError(meInvalidMergeFile);
      exit;
    end;
    fMergeFile:=value;
  end;
end;

procedure TNLDFileMerger.SetSourceFile(const Value: TFileName);
begin
  if not (fSourceFile = Value) then
  begin
    if not fileexists(value) then
    begin
      DoMergeError(meInvalidSourceFile);
      exit;
    end;
    fSourceFile:=value;
  end;
end;

procedure TNLDFileMerger.writecopyright(writer: twriter);
begin
  writer.writestring(tFileMergercopyright);
end;

end.
