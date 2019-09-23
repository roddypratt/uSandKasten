type
  TRGBx = packed record R, G, B, x: byte; end;


function ColorLightness(AColor: TColor): byte;
begin
  Result := Round(0.299*TRGBx(AColor).R +
                  0.587*TRGBx(AColor).G +
                  0.114*TRGBx(AColor).B);
end;

function  HSVToColor(H,S,V: single): TColor;
var t : THSVColor;
begin
  t.h := H;
  t.s := S;
  t.v := V;
  Result := HSVToColor(t);
end;

function HSVToColor(AHSVColor: THSVColor): TColor;
var r, g, b, h, f: single;
    p, q, t      : single;
    i            : integer;
begin
  if AHSVColor.S = 0.0
  then begin
       if AHSVColor.H < 0 then
         begin
         r := AHSVColor.V;
         g := AHSVColor.V;
         b := AHSVColor.V;
         end;
       end
  else begin
       if AHSVColor.H = 360.0 then h := 0.0 else h := AHSVColor.H;
       h := h / 60;
       i := Trunc(h);
       f := h - i;

       p := AHSVColor.V * (1.0 - AHSVColor.S);
       q := AHSVCOlor.V * (1.0 - (AHSVColor.S * f));
       t := AHSVCOlor.V * (1.0 - (AHSVColor.S * (1.0 - f)));

       case i of
         0 : begin r := AHSVColor.V; g := t;           b := p; end;
         1 : begin r := q;           g := AHSVColor.V; b := p; end;
         2 : begin r := p;           g := AHSVColor.V; b := t; end;
         3 : begin r := p;           g := q;           b := AHSVColor.V; end;
         4 : begin r := t;           g := p;           b := AHSVColor.V; end;
         5 : begin r := AHSVColor.V; g := p;           b := q; end;
       end;
       end;

  Result := TColor(Round(255*b) * 65536 +
                   Round(255*g) * 256 +
                   Round(255*r));

end;

function ColorToHSV(ARGBColor: TColor): THSVColor;
var min  : byte;
    delta: single;
begin
  min := byte(-1);
  Result.V := 0;
  if TRGBx(ARGBColor).R < min then min := TRGBx(ARGBColor).R;
  if TRGBx(ARGBColor).G < min then min := TRGBx(ARGBColor).G;
  if TRGBx(ARGBColor).B < min then min := TRGBx(ARGBColor).B;

  if TRGBx(ARGBColor).R > Result.V then Result.V := TRGBx(ARGBColor).R;
  if TRGBx(ARGBColor).G > Result.V then Result.V := TRGBx(ARGBColor).G;
  if TRGBx(ARGBColor).B > Result.V then Result.V := TRGBx(ARGBColor).B;

  delta := Result.V - min;

  if Result.V = 0.0 then Result.S := 0
                    else Result.S := delta / Result.V;

  if Result.S = 0.0
    then Result.H := -1
    else if TRGBx(ARGBColor).R = Result.V then
      Result.H := 60.0 * (TRGBx(ARGBColor).G-TRGBx(ARGBColor).B)/Delta // yellow-magenta
    else if TRGBx(ARGBColor).G = Result.V then
      Result.H := 120.0 + 60.0 * (TRGBx(ARGBColor).B-TRGBx(ARGBColor).R)/Delta // cyan-yellow
    else if TRGBx(ARGBColor).B = Result.V then
      Result.H := 240.0 + 60.0 * (TRGBx(ARGBColor).R-TRGBx(ARGBColor).G)/Delta; // magenta-cyan

  if Result.H < 0.0 then Result.H := 260.0 + Result.H;

  Result.V := Result.V / 255;
end;

function ColorToHexStr(AColor: TColor): string;
begin
  Result := Format('%.2x%.2x%.2x', [TRGBx(AColor).R,TRGBx(AColor).G,TRGBx(AColor).B]);
end;

function HexStrToColor(AHexstr: string): TColor;
var r,g,b: integer; l: longint;
begin
  Result := clBlack;
  if (length(AHexstr) > 0) and (AHexstr[1] = '#') then Delete(AHexstr,1,1);
  if length(AHexstr) <> 6 then EXIT;
  r := StrToInt('$' + Copy(AHexstr,1,2));
  g := StrToInt('$' + Copy(AHexstr,3,2));
  b := StrToInt('$' + Copy(AHexstr,5,2));
  l := b shl 16 + g shl 8 + r;
  Result := TColor(l);
end;


procedure ShowMyMessage(const AMessage: string; ATitle : string = '');
begin
  if Assigned(Application)
    then begin
         if ATitle = '' then ATitle := Application.Title;
         FlashWindow(Application.Handle, TRUE);
         MessageBox(Application.Handle, PChar(AMessage), PChar(ATitle), MB_OK or MB_APPLMODAL);
         end
    else begin
         MessageBox(0, PChar(AMessage), PChar(ATitle), MB_OK or MB_TASKMODAL);
         end;
end;

function  MyMessageBox(AMessage : string;
                       ATitle   : string;
                       AHandle  : integer = 0;
                       AType    : integer = MB_OK): integer;
begin
  if AHandle = 0 then AType := AType or MB_TASKMODAL
                 else AType := AType or MB_APPLMODAL;
  Result := MessageBox(AHandle, PChar(AMessage), PChar(ATitle), AType)
end;


function GetRTF(ARichEdit: TRichEdit): string;
var S: TStringStream;
begin
  S := TStringStream.Create('');
  try
    ARichEdit.Lines.SaveToStream(S);
    Result := S.DataString;
  finally
    S.Free;
  end;
end;

procedure SetRTF(ARichEdit: TRichEdit; var AString: string); overload;
var S: TStringStream;
begin
  S := TStringStream.Create(AString);
  try
    ARichEdit.Lines.LoadFromStream(S);
  finally
    S.Free;
  end;
end;

procedure SetRTF(ARichedit: TRichEdit; AStream: TStream); overload;
var S : TStringStream;
begin
  if AStream is TStringStream
  then ARichEdit.Lines.LoadFromStream(AStream)
  else begin
       S := TStringStream.Create('');
       try
          AStream.Position := 0;
          S.CopyFrom(AStream, AStream.Size);
          ARichEdit.Lines.LoadFromStream(S);
        finally
          S.Free;
        end;
       end;
end;

