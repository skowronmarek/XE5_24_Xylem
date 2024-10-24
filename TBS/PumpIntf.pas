unit Pumpintf;

interface

uses
  WinProcs, WinTypes{, VirtIntf},classes, Diagrams;

type

  IPumpCharSel = class;

  TInterface = class
    private
      FRef      :Integer;
    public
      function  GetVersion :Integer;  virtual; abstract;
      procedure Free;
      function  AddRef: Longint;      virtual;
      function  Release: Longint;      virtual;
  end;

  IPump = class (TInterface)
    public
      procedure GetName( AName :PChar; AMax :Integer );
                                    virtual;  abstract;
      function GetQMin  :Double;    virtual;  abstract;
      function GetQMax  :Double;    virtual;  abstract;
      function GetHMin  :Double;    virtual;  abstract;
      function GetHMax  :Double;    virtual;  abstract;

      function GetQn    :Double;    virtual;  abstract;
      function GetHn    :Double;    virtual;  abstract;
      function GetPn    :Double;    virtual;  abstract;

      function WorkPoint( Char :IPumpCharSel; var Qr, Hr :Double ): Boolean;
                                        virtual;  abstract;
      //procedure AddRef;             virtual;  abstract;
  end;

  IPumpCharSel = class (TInterface)
    public
      function dH( Q :Double ) :Double;      virtual;  abstract;
      function GetQw    :Double;             virtual;  abstract;
      function GetHw    :Double;             virtual;  abstract;
      //wstawka MS
      function GetNPSHu :Double;             virtual;  abstract;

      function RngQIntsect( AQMin, AQMax :Double ) :Boolean;
                                             virtual;  abstract;
      function KluczOK( KluczeWPlikuT:string;
                               Klucze:TStrings  ) :Boolean;
                                             virtual;  abstract;
      function Accept( Qr, Hr :Double; Pump :IPump ): Boolean;
                                             virtual;  abstract;
      function GetDiagFun( Owner :TDiagFunction ) :TDiagFunDrawer;
                                             virtual;
      //procedure AddRef: Longint;             virtual;  abstract;
  end;

implementation

procedure TInterface.Free;
begin
  if self <> NIL then
  begin
    Release;
  end;
end;

function  TInterface.AddRef  :Longint;
begin
  inc(FRef);
  result := FRef;
end;


function  TInterface.Release :Longint;
begin
  dec(FRef);
  result := FRef;
  if FRef <= 0 then
    Destroy;
end;

{ IPumpCharSel }

function IPumpCharSel.GetDiagFun( Owner :TDiagFunction ): TDiagFunDrawer;
begin
  result := NIL;
end;

end.
