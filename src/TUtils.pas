unit TUtils;

interface

uses
  Windows, ShellAPI, SysUtils, System.IOUtils, System.Generics.Collections,
  Vcl.ImgList, Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls,
  System.Classes, Winapi.ShlObj, Winapi.CommCtrl;

function GetSystemFileIcons: TImageList;
function GetDirectoryContents(const path: string; out directories: TList<string>;
  out files: TList<string>): Boolean;
function GetIconByFileType(const filePath: string; isDirectory: Boolean; imgList: TImageList): Integer;

implementation

function GetSystemFileIcons: TImageList;
var
  SHFileInfo: TSHFileInfo;
  ImageListHandle: HIMAGELIST;
begin
  Result := TImageList.Create(nil);
  Result.Width := GetSystemMetrics(SM_CXSMICON); // Tamaño estándar de icono
  Result.Height := GetSystemMetrics(SM_CYSMICON);

  // Obtener el ImageList del sistema con iconos de archivos
  ImageListHandle := SHGetFileInfo('', 0, SHFileInfo, SizeOf(TSHFileInfo),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON);

  if ImageListHandle <> 0 then
  begin
    Result.Handle := ImageListHandle;
  end;
end;

// Obtener los contenidos del directorio
function GetDirectoryContents(const path: string; out directories: TList<string>;
  out files: TList<string>): Boolean;
begin
  directories := TList<string>.Create();
  files := TList<string>.Create();

  try
    if not TDirectory.Exists(path) then
    begin
      raise Exception.CreateFmt('El directorio no existe: %s', [path]);
    end;

    directories.AddRange(TDirectory.GetDirectories(path));
    files.AddRange(TDirectory.GetFiles(path));

    Result := True;
  except
    on E: Exception do
    begin
      directories.Free;
      files.Free;
      directories := nil;
      files := nil;
      raise Exception.CreateFmt('Error al acceder al directorio %s: %s', [path, E.Message]);
    end;
  end;
end;


function GetIconByFileType(const filePath: string; isDirectory: Boolean; imgList: TImageList): Integer;
var
  SHFileInfo: TSHFileInfo;
  flags: UINT;
begin
  flags := SHGFI_SYSICONINDEX or SHGFI_SMALLICON;
  if SHGetFileInfo(PChar(filePath), 0, SHFileInfo, SizeOf(TSHFileInfo), flags) <> 0 then
    Result := SHFileInfo.iIcon
  else
    Result := -1; // Error o ícono no encontrado
end;

end.

