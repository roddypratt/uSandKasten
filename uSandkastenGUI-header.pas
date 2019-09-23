type
  THSVColor = packed record H, S, V: single; end;


function  ColorLightness(AColor: TColor): byte;
function  ColorToHexStr(AColor: TColor): string;
function  ColorToHSV(ARGBColor: TColor): THSVColor;
function  HexStrToColor(AHexstr: string): TColor;
function  GetRTF(ARichEdit: TRichEdit): string;
function  HSVToColor(AHSVColor: THSVColor): TColor; overload;
function  HSVToColor(H,S,V: single): TColor; overload;
procedure SetRTF(ARichEdit   : TRichEdit;
                 var AString : string); overload;
procedure SetRTF(ARichedit : TRichEdit;
                 AStream   : TStream); overload;
procedure ShowMyMessage(const AMessage : string;
                        ATitle         : string = '');
function  MyMessageBox(AMessage : string;
                       ATitle   : string;
                       AHandle  : integer = 0;
                       AType    : integer = MB_OK): integer;

