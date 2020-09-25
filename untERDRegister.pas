{
  untERDRegister - Register ERDesigns UCC Components
  for Delphi 2010 - 10.4 by Ernst Reidinga
  https://erdesigns.eu

  This unit is part of the ERDesigns UCC Components Pack.

  (c) Copyright 2020 Ernst Reidinga <ernst@erdesigns.eu>

}

unit untERDRegister;

interface

uses
  System.Classes, untERDToolBar, untERDButtonBar, untERDNavigationIndicator,
  untERDButtonPanel, untERDColumnList, untERDPhotoCamera;

procedure Register;

implementation

(******************************************************************************)
(*
(*  Register ERDesigns Audio Toolkit Components
(*
(******************************************************************************)

procedure Register;
begin
  RegisterComponents('ERDesigns UCC', [
    TERDTopNavigationBar,
    TERDBottomNavigationBar,
    TERDButtonBar,
    TERDNavigationIndicator,
    TERDButtonPanel,
    TERDVehicleList,
    TERDSimpleList,
    TERDSubList,
    TERDDTCList,
    TERDFreezeFrameList,
    TERDPhotoCamera
  ]);
end;


end.
