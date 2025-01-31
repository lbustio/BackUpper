unit TUtils;

interface

uses
  Windows, ShellAPI, SysUtils, System.IOUtils,
  System.Generics.Collections, Vcl.ImgList, Vcl.Controls, Vcl.Forms, Vcl.Graphics;

function GetSystemIcons(): UInt64;
function GetDirectoryContents(const path: string; out directories: TList<string>;
  out files: TLIst<string>): Boolean;

implementation

function GetSystemIcons(): UInt64;
const
  shgfiFlags = SHGFI_SYSICONINDEX or SHGFI_SMALLICON;
var
  shFileInfo: TSHFileInfo;
begin
  Result := SHGetFileInfo('', 0, shFileInfo, SizeOf(shFileInfo), shgfiFlags);

  // Si result es 0, ocurri� un error
  if Result = 0 then
    raise Exception.Create('Error al obtener los �conos del sistema');
end;

function GetDirectoryContents(const path: string; out directories: TList<string>;
  out files: TList<string>): Boolean;
begin
  directories := TList<string>.Create();  // Inicializamos como listas vac�as
  files := TList<string>.Create();

  try
    // Verificar si el directorio existe
    if not TDirectory.Exists(path) then
    begin
      raise Exception.CreateFmt('El directorio no existe: %s', [path]);
    end;

    try
      // Obtener los directorios
      directories.AddRange(TDirectory.GetDirectories(path));

      // Obtener los archivos
      files.AddRange(TDirectory.GetFiles(path));

      // Si no se encontraron directorios, los dejamos como una lista vac�a (no asignamos nil)
      if directories.Count = 0 then
        directories.Clear; // Mantener como lista vac�a

      // Si no se encontraron archivos, los dejamos como una lista vac�a (no asignamos nil)
      if files.Count = 0 then
        files.Clear; // Mantener como lista vac�a

      Result := True;  // Si todo fue exitoso, devolvemos True

    except
      on E: Exception do
      begin
        // Si ocurre un error al agregar elementos a las listas, liberar la memoria
        directories.Free;
        files.Free;
        directories := nil;
        files := nil;

        // Mostrar el error y retornar False
        raise Exception.CreateFmt('Error al acceder al directorio %s: %s', [path, E.Message]);
      end;
    end;

  except
    on E: Exception do
    begin
      // Si hubo un error en la validaci�n o en la creaci�n de las listas
      directories.Free;
      files.Free;
      directories := nil;
      files := nil;

      raise Exception.CreateFmt('Error en la funci�n GetDirectoryContents: %s', [E.Message]);
    end;
  end;
end;

end.

