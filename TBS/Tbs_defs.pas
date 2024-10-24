unit Tbs_defs;

interface

uses
  windows, messages;

const
  UWM_TBS    = WM_USER + 5;

  TBSM_SET_LANG   = UWM_TBS+1;
  TBSM_CAN_PRINT  = UWM_TBS+2;
  TBSM_PRINT      = UWM_TBS+3;
  TBSM_UNIT       = UWM_TBS+4;

procedure KomunikatDoOkien(hWnd: HWND);

implementation

procedure KomunikatDoOkien(hWnd: HWND);

  function EnumerateWindows(hWnd: THandle; lParam: LPARAM): BOOL; stdcall;
  begin
    SendMessage(hWnd,TBSM_UNIT,1,1);
    KomunikatDoOkien (hWnd);
 end;

begin
 EnumChildWindows(Hwnd , @EnumerateWindows, 0);
end;


end.
