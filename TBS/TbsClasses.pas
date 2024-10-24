unit TbsClasses;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics,
  KR_Sys, KR_Class, TbsU;

type
  TTbsDragObject = class (TDragObject)
  private
    FStartDragControl: TControl;
    procedure SetStartDragControl(const Value: TControl);
  protected
    FDragImageLst: TDragImageList;
    procedure SetDragImageLst(const Value: TDragImageList);
    procedure Finished( Target: TObject; X, Y: Integer;
                        Accepted: Boolean);        override;

  public
    constructor Create( AStartCtrl :TControl );
    destructor Destroy;                      override;
    function  GetDragImages :TDragImageList; override;
    procedure HideDragImage; override;
    procedure ShowDragImage; override;

    procedure SetDragImageMasked( bmp :TBitMap; X, Y :Integer;
                                  MaskColor :TColor );

    property DragImageLst :TDragImageList read FDragImageLst
                                          write SetDragImageLst;
    property StartDragControl :TControl read FStartDragControl write SetStartDragControl;
  end;

implementation

{ TTbsDragObject }

constructor TTbsDragObject.Create(AStartCtrl: TControl);
begin
  inherited Create;
  StartDragControl := AStartCtrl;
end;

destructor TTbsDragObject.Destroy;
begin
  DragImageLst := NIL;
  inherited;
end;

procedure TTbsDragObject.Finished;
begin
  FreeSoon(self);
end;

function TTbsDragObject.GetDragImages: TDragImageList;
begin
  if FDragImageLst = NIL then
  begin
    result := inherited GetDragImages;
    FDragImageLst := result
  end
  else
  begin
    result := FDragImageLst;
  end;
end;

procedure TTbsDragObject.HideDragImage;
begin
  if GetDragImages <> NIL then
  begin
    GetDragImages.HideDragImage;
  end;
end;

procedure TTbsDragObject.SetDragImageLst(const Value: TDragImageList);
begin
  if FDragImageLst <> NIL then
    if FDragImageLst.Owner = NIL then
      FDragImageLst.Free;
  FDragImageLst := Value;
end;

procedure TTbsDragObject.SetDragImageMasked(bmp: TBitMap; X, Y: Integer;
  MaskColor: TColor);
begin
  DragImageLst := TDragImageList.CreateSize(bmp.Width, bmp.Height);
  with DragImageLst do
  begin
    AddMasked( bmp, MaskColor );
    SetDragImage(0, X, Y );
  end;
end;

procedure TTbsDragObject.SetStartDragControl(const Value: TControl);
begin
  FStartDragControl := Value;
end;

procedure TTbsDragObject.ShowDragImage;
begin
  if GetDragImages <> NIL then
  begin
    GetDragImages.ShowDragImage;
  end;
end;

end.
