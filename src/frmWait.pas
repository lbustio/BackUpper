unit frmWait;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ImgList, Vcl.Imaging.GIFImg;

type
  TfrmEspera = class(TForm)
    lblInicializando: TLabel;
    lblCompactando: TLabel;
    lblSalvando: TLabel;
    imgInicializando: TImage;
    imgCompactando: TImage;
    imgSalvando: TImage;
    Image1: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEspera: TfrmEspera;

implementation

{$R *.dfm}

end.
