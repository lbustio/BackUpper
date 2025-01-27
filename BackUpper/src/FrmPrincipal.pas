unit FrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Buttons, Vcl.Imaging.GIFImg,
  System.ImageList, Vcl.ImgList, IOUtils, TUtils, System.Generics.Collections;  // Agregado System.Generics.Collections

type
  TfrmMain = class(TForm)
    lblSource: TLabel;
    edtSource: TEdit;
    btnSource: TButton;
    btnBackup: TButton;
    btnExit: TButton;
    imgBanner: TImage;
    lblDestino: TLabel;
    edtDestination: TEdit;
    btnDestination: TButton;
    mComment: TMemo;
    tvwFiles: TTreeView;
    btnOpenSource: TBitBtn;
    btnOpenDestination: TBitBtn;
    gbCompress: TGroupBox;
    chkCompress: TCheckBox;
    imgList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnSourceClick(Sender: TObject);
    procedure btnOpenSourceClick(Sender: TObject);
    procedure btnOpenDestinationClick(Sender: TObject);
    procedure btnDestinationClick(Sender: TObject);
    procedure tvwFilesExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure tvwFilesDblClick(Sender: TObject);
  private
    { Private declarations }
    function SelectFolder(const title: string; var selectedPath: string): Boolean;
    procedure ClearTreeView;
    procedure AddNodesToTreeView(rootNode: TTreeNode; directories, files: TList<string>);
    procedure ShowError(const msg: string);
    procedure ShowWarning(const msg: string);
    function NodeHasChild(ParentNode: TTreeNode; const Caption: string): Boolean;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  TNodeData, IniFiles, ShellApi, ShlObj, System.UITypes;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  init: TIniFile;
begin

  // Inicializamos imgList
  imgList := TImageList.Create(Self);

  // Configuramos las propiedades del imgList (esto puede variar según lo que necesites)
  imgList.Width := 16;  // Ancho de los íconos
  imgList.Height := 16; // Alto de los íconos

  // Asignamos el TImageList al TreeView
  tvwFiles.Images := imgList;  // Asegúrate de que este paso esté presente

  try
    // Lee el archivo de configuración
    init := TIniFile.Create(ChangeFileExt(Application.ExeName, '.INI'));
    try
      edtSource.Text := init.ReadString('Data', 'Source', '');
      edtDestination.Text := init.ReadString('Data', 'Target', '');
      chkCompress.Checked := init.ReadBool('Settings', 'Compress', False);
    finally
      init.Free; // Liberar memoria
    end;
  except
    on e: Exception do
      MessageDlg(Format('Error al cargar la configuración: %s', [e.Message]), mtError, [mbOK], 0);
  end;
end;

procedure TfrmMain.btnDestinationClick(Sender: TObject);
var
  selectedDir: string;
begin
  if SelectFolder('Seleccionar carpeta de destino', selectedDir) then
    edtDestination.Text := IncludeTrailingPathDelimiter(selectedDir)
  else
    MessageDlg('No se seleccionó ninguna carpeta. Intente nuevamente.', mtWarning, [mbOK], 0);
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
var
  init: TIniFile;
  i: Integer;
  errorMsg: string;
begin
  try
    // Crea o abre el archivo INI
    init := TIniFile.Create(ChangeFileExt(Application.ExeName, '.INI'));
    try
      // Guarda los valores de configuración en el archivo INI
      init.WriteString('Data', 'Source', edtSource.Text);
      init.WriteString('Data', 'Target', edtDestination.Text);
      init.WriteBool('Settings', 'Compress', chkCompress.Checked);
    finally
      init.Free;  // Libera el objeto INI
    end;

    // Liberar cualquier memoria dinámica que se haya asignado con 'GetMem' para cada directorio
    for i := 0 to tvwFiles.Items.Count - 1 do
    begin
      if Assigned(tvwFiles.Items.Item[i].Data) then
      begin
        // Liberar memoria solo si Data no es nil
        TCustomNodeData(tvwFiles.Items.Item[i].Data).Free;
        tvwFiles.Items.Item[i].Data := nil; // Evitar el uso posterior de un puntero invalidado
      end;
    end;

    // Finalmente, cerrar la aplicación
    Self.Close;
  except
    on e: EInOutError do
    begin
      errorMsg := 'Error al acceder a los archivos o carpetas durante el cierre. Verifique los permisos.';
      MessageDlg(errorMsg, mtError, [mbOK], 0);
    end;
    on e: Exception do
    begin
      errorMsg := 'Ocurrió un error inesperado al intentar cerrar la aplicación. ' + e.Message;
      MessageDlg(errorMsg, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfrmMain.btnOpenDestinationClick(Sender: TObject);
begin
  if SysUtils.DirectoryExists(edtDestination.Text) then
    ShellExecute(0, 'open', PChar(edtDestination.Text), nil, nil, SW_SHOWNORMAL)
  else
    ShowMessage('La carpeta de destino especificada no existe. Verifique la ruta e intente nuevamente.');
end;

procedure TfrmMain.btnOpenSourceClick(Sender: TObject);
begin
  if SysUtils.DirectoryExists(edtSource.Text) then
    ShellExecute(0, 'open', PChar(edtSource.Text), nil, nil, SW_SHOWNORMAL)
  else
    ShowMessage('La carpeta de origen especificada no existe. Verifique la ruta e intente nuevamente.');
end;

procedure TfrmMain.btnSourceClick(Sender: TObject);
var
  selectedDir: string;
  rootNode: TTreeNode;
  directories, files: TList<string>;
  path: string;
begin
  try
    // Seleccionamos la carpeta de origen
    if SelectFolder('Seleccionar carpeta de origen', selectedDir) then
    begin
      edtSource.Text := IncludeTrailingPathDelimiter(selectedDir);  // Mostrar la carpeta seleccionada en el TEdit
      ClearTreeView;  // Limpiar TreeView

      path := edtSource.Text;
      rootNode := tvwFiles.Items.Add(nil, path);  // Nodo raíz
      rootNode.Data := TCustomNodeData.Create(path); // Asignar ruta al nodo

      if DirectoryExists(path) then
      begin
        directories := TList<string>.Create();
        files := TList<string>.Create();
        try
          if GetDirectoryContents(path, directories, files) then
          begin
            AddNodesToTreeView(rootNode, directories, files);
          end
          else
            ShowError('No se pudo acceder al contenido de la carpeta: ' + edtSource.Text);
        finally
          directories.Free;
          files.Free;
        end;
      end
      else
        ShowError('La carpeta "' + edtSource.Text + '" no existe.');
    end
    else
      ShowWarning('No se seleccionó ninguna carpeta. Por favor, intente nuevamente.');
  except
    on e: EInOutError do
      ShowError('Error al acceder al sistema de archivos. Verifique los permisos.');
    on e: Exception do
      ShowError('Ocurrió un error inesperado: ' + e.Message);
  end;
end;

procedure TfrmMain.ClearTreeView;
var
  i: Integer;
begin
  // Liberar memoria asociada a los nodos antes de limpiar el TreeView
  for i := 0 to tvwFiles.Items.Count - 1 do
  begin
    if Assigned(tvwFiles.Items[i].Data) then
    begin
      TCustomNodeData(tvwFiles.Items[i].Data).Free; // Liberar los datos asociados al nodo
      tvwFiles.Items[i].Data := nil;                // Evitar referencias colgantes
    end;
  end;

  // Limpiar todos los nodos del TreeView
  tvwFiles.Items.Clear;
end;

procedure TfrmMain.AddNodesToTreeView(rootNode: TTreeNode; directories, files: TList<string>);
var
  i: Integer;
  childNode: TTreeNode;
  filePath, caption: string;
begin
  // Añadir directorios como nodos hijos
  for i := 0 to directories.Count - 1 do
  begin
    filePath := IncludeTrailingPathDelimiter(directories[i]);
    caption := ExtractFileName(ExcludeTrailingPathDelimiter(filePath));

    // Obtén el índice del ícono para el directorio
    //iconIndex := GetIconByFileType(filePath, True, imgList);  // imgList es el TImageList

    childNode := tvwFiles.Items.AddChild(rootNode, caption);
    childNode.Data := TCustomNodeData.Create(filePath);
    //childNode.ImageIndex := iconIndex;
    //childNode.SelectedIndex := iconIndex; // Para cambiar el ícono al seleccionar el nodo
    childNode.HasChildren := True; // Puede expandirse
  end;

  // Añadir archivos como nodos hijos
  for i := 0 to files.Count - 1 do
  begin
    filePath := files[i];
    caption := ExtractFileName(ExcludeTrailingPathDelimiter(filePath));

    // Obtén el índice del ícono para el archivo
    //iconIndex := GetIconByFileType(filePath, False, imgList);  // imgList es el TImageList

    childNode := tvwFiles.Items.AddChild(rootNode, caption);
    childNode.Data := TCustomNodeData.Create(filePath);
    //childNode.ImageIndex := iconIndex;
    //childNode.SelectedIndex := iconIndex; // Para cambiar el ícono al seleccionar el nodo
  end;
end;

procedure TfrmMain.ShowError(const msg: string);
begin
  MessageDlg(msg, mtError, [mbOK], 0);
end;

procedure TfrmMain.ShowWarning(const msg: string);
begin
  MessageDlg(msg, mtWarning, [mbOK], 0);
end;

function TfrmMain.SelectFolder(const title: string; var selectedPath: string): Boolean;
var
  dialog: TFileOpenDialog;
begin
  result := False;
  selectedPath := '';
  dialog := TFileOpenDialog.Create(Self);
  try
    dialog.Title := title;
    dialog.Options := [fdoPickFolders];
    if dialog.Execute then
    begin
      selectedPath := dialog.FileName;
      result := True;
    end;
  finally
    dialog.Free;
  end;
end;

procedure TfrmMain.tvwFilesDblClick(Sender: TObject);
var
  currentNode: TTreeNode;
  path: string;
begin
  // Obtener el nodo seleccionado
  currentNode := tvwFiles.Selected;

  // Verificar que hay un nodo seleccionado y que contiene datos válidos
  if Assigned(currentNode) and Assigned(currentNode.Data) then
  begin
    // Intentar convertir Node.Data al tipo esperado
    path := TCustomNodeData(currentNode.Data).Path;

    // Verificar que el path sea válido y exista
    if FileExists(path) or DirectoryExists(path) then
    begin
      // Abrir el archivo o carpeta con la función del sistema
      if ShellExecute(0, 'open', PChar(path), nil, nil, SW_SHOWNORMAL) <= 32 then
        MessageDlg('No se pudo abrir el archivo o carpeta: ' + path, mtError, [mbOK], 0);
      end
    else
      MessageDlg('El archivo o carpeta ya no existe: ' + path, mtError, [mbOK], 0);
    end
  else
    MessageDlg('El nodo seleccionado no contiene datos válidos.', mtError, [mbOK], 0);
end;

procedure TfrmMain.tvwFilesExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
var
  nodePath: string;
  directories: TList<string>;
  files: TList<string>;
  dir: string;
  f: string;
  newNode: TTreeNode;
  caption: string;
  path: string;
begin
  directories := nil;
  files := nil;

  try
    // Obtener la ruta del nodo
    nodePath := IncludeTrailingPathDelimiter(TCustomNodeData(Node.Data).Path);

    // Crear listas para almacenar directorios y archivos
    directories := TList<string>.Create();
    files := TList<string>.Create();

    // Intentar obtener el contenido del directorio
    if GetDirectoryContents(nodePath, directories, files) then
    begin
      // Añadir directorios como nodos hijos
      for dir in directories do
      begin
        path := IncludeTrailingPathDelimiter(dir);
        caption := ExtractFileName(ExcludeTrailingPathDelimiter(path));

        // Verificar si el nodo ya existe
        if not NodeHasChild(Node, caption) then
        begin
          newNode := tvwFiles.Items.AddChild(Node, caption);
          newNode.Data := TCustomNodeData.Create(path);
          newNode.HasChildren := True; // Marcar como expandible
        end;
      end;

      // Añadir archivos como nodos hijos
      for f in files do
      begin
        path := f;
        caption := ExtractFileName(path);

        // Verificar si el nodo ya existe
        if not NodeHasChild(Node, caption) then
        begin
          newNode := tvwFiles.Items.AddChild(Node, caption);
          newNode.Data := TCustomNodeData.Create(path);
        end;
      end;
    end;

    // Permitir expansión si todo fue exitoso
    AllowExpansion := True;
  except
    on E: EInOutError do
    begin
      // Liberar memoria si ocurre un error
      if Assigned(directories) then
        directories.Free;
      if Assigned(files) then
        files.Free;

      // Mostrar mensaje de error y prevenir la expansión
      ShowError('Error al expandir el nodo: ' + E.Message);
      AllowExpansion := False;
    end;
    on E: Exception do
    begin
      // Liberar memoria si ocurre un error
      if Assigned(directories) then
        directories.Free;
      if Assigned(files) then
        files.Free;

      ShowError('Ocurrió un error inesperado al intentar expandir el nodo: ' + E.Message);
      AllowExpansion := False;
    end;
  end;

  // Liberar listas al finalizar, si no se liberaron previamente
  directories.Free;
  files.Free;
end;


// Función para verificar si un nodo hijo ya existe
function TfrmMain.NodeHasChild(ParentNode: TTreeNode; const Caption: string): Boolean;
var
  ChildNode: TTreeNode;
begin
  Result := False;

  // Iterar sobre los nodos hijos utilizando GetFirstChild y GetNextSibling
  ChildNode := ParentNode.GetFirstChild;
  while Assigned(ChildNode) do
  begin
    if ChildNode.Text = Caption then
    begin
      Result := True;
      Break;
    end;
    ChildNode := ChildNode.GetNextSibling; // Obtener el siguiente hermano del nodo
  end;
end;

end.
