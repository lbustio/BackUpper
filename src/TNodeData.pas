unit TNodeData;

interface

type
  TCustomNodeData = class
  private
    FPath: string;
  public
    constructor Create(const APath: string);
    destructor Destroy; override;
    property Path: string read FPath write FPath;
  end;

implementation

{ TCustomNodeData }

constructor TCustomNodeData.Create(const APath: string);
begin
  inherited Create;
  FPath := APath;
end;

destructor TCustomNodeData.Destroy;
begin
  // Aqu� se liberar�an recursos din�micos si existieran
  inherited Destroy;
end;

end.

