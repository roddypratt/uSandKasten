const
    CNumbDigits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    DIGITS : Array [0..9] of string = ('null', 'eins', 'zwei', 'drei', 'vier',
                                    'fünf', 'sechs', 'sieben', 'acht', 'neun');
    COMMA = 'Komma';
    PLUS  = 'Plus';
    MINUS = 'Minus';


function  GetComputerName: string;
var buf: string[255];
    len: DWORD;
begin
  len := SizeOf(buf) - 1;
  if windows.getcomputername(@buf[1], len)
    then Result := buf
    else Result := '';
end;

function GetBuildInfo(const AFilename:String; var V1,V2,V3,V4:Word):Boolean;
var
   VerInfoSize  : Integer;
   VerValueSize : DWord;
   Dummy        : DWord;
   VerInfo      : Pointer;
   VerValue     : PVSFixedFileInfo;
begin
  VerInfoSize:=GetFileVersionInfoSize(PChar(AFilename),Dummy);
  Result:=False;
  if VerInfoSize <> 0 then
    begin
    GetMem(VerInfo,VerInfoSize);
      try
      if GetFileVersionInfo(PChar(AFilename),0,VerInfoSize,VerInfo) then
        begin
        if VerQueryValue(VerInfo,'\',Pointer(VerValue),VerValueSize) then
          begin
          with VerValue^ do
            begin
            V1 := dwFileVersionMS shr 16;
            V2 := dwFileVersionMS and $FFFF;
            V3 := dwFileVersionLS shr 16;
            V4 := dwFileVersionLS and $FFFF;
            end;
          Result:=True;
          end;
        end;
      finally
      FreeMem(VerInfo,VerInfoSize);
      end;
    end;
end; {Peter Haas}

function  HTMLEntityDecode(const AInput: string): string;
var rf: TReplaceFlags;
begin
  rf := [rfReplaceAll, rfIgnoreCase];
  Result := StringReplace(AInput, '&#39;', '''', rf);
  Result := StringReplace(Result, '&quot;', '"', rf);
  Result := StringReplace(Result, '&gt;', '>', rf);
  Result := StringReplace(Result, '&lt;', '<', rf);
  Result := StringReplace(Result, '&amp;', '&', rf);
end;

function  HTMLEntityEncode(const AInput: string): string;
var rf: TReplaceFlags;
begin
  rf := [rfReplaceAll, rfIgnoreCase];
  Result := StringReplace(AInput, '&', '&amp;', rf);
  Result := StringReplace(Result, '<', '&lt;', rf);
  Result := StringReplace(Result, '>', '&gt;', rf);
  Result := StringReplace(Result, '"', '&quot;', rf);
  Result := StringReplace(Result, '''', '&#39;', rf);
end;

function  UrlDecode(const AInputString: string): string;
var p_src, p_dst: integer;
    s           : string;
begin
  SetLength(Result, Length(AInputString));
  SetLength(s,2);
  p_src := 1;
  p_dst := 1;
  while p_src <= Length(AInputString) do
    begin
    if AInputString[p_src] = '%'
      then begin
           s[1] := AInputString[p_src+1];
           s[2] := AInputString[p_src+2];
           Result[p_dst] := Chr(StrToNumber(s, 16));
           inc(p_src, 2); // skip the two hex digits (in reality the % and the first one)
           end
      else begin
           Result[p_dst] := AInputString[p_src];
           end;
    inc(p_src); // skip the character (or the percent sign; in reality the second hex digit)
    inc(p_dst);
    end;
  SetLength(Result, p_dst-1);
end;


function  UrlEncode(const AInputString: string): string;
var i, p : integer;
    s    : string;
begin
  SetLength(Result, 3*Length(AInputString)); // worst case
  p := 1;
  for i := 1 to Length(AInputString) do
    begin
    if AInputString[i] in ['0'..'9', 'A'..'Z', 'a'..'z']
      then begin
           Result[p] := AInputString[i];
           inc(p)
           end
      else begin
           s := IntToHex(Ord(AInputString[i]), 2);
           Result[p] := '%';
           Result[p+1] := s[1];
           Result[p+2] := s[2];
           inc(p, 3);
           end;
    end;
  SetLength(Result, p-1);
end;


function EscapeString(const AString: string): string;
// replaces any character < 32 and \ I am using the same escape strings as
// you know it from Unix
var i : integer;
// TODO 1 : improve performance (SetLength)
begin
  Result := '';
 i := 1;
 while (i <= Length(AString)) do
   begin
   if AString[i] = '\' then Result := Result + '\\'
   else if AString[i] = #7 then Result := Result + '\a'
   else if AString[i] = #8 then Result := Result + '\b'
   else if AString[i] = #9 then Result := Result + '\t'
   else if AString[i] = #10 then Result := Result + '\n'
   else if AString[i] = #11 then Result := Result + '\v'
   else if AString[i] = #12 then Result := Result + '\f'
   else if AString[i] = #13 then Result := Result + '\r'
   else if (AString[i] < #32) then Result := Result + Format('\x%.2x', [Ord(AString[i])])
   else Result := Result + AString[i];
   inc(i);
   end;
end;

function UnescapeString(const AString: string): string;
var i, newpos : integer;
    tempstr   : string;
begin
  Result := '';
  i      := 1;
  newpos := 1;
  SetLength(Result, Length(AString));
    try
    while (i <= Length(AString)) do
      begin
      if AString[i] = '\' then
        begin
          if i = Length(AString) then
            raise EConvertError.Create('Single backslash at end of string');
          inc(i);
          case AString[i] of
            '\' : Result[newpos] := '\';
            'a' : Result[newpos] := #7;
            'b' : Result[newpos] := #8;
            't' : Result[newpos] := #9;
            'n' : Result[newpos] := #10;
            'v' : Result[newpos] := #11;
            'f' : Result[newpos] := #12;
            'r' : Result[newpos] := #13;
            'x' : try
                  tempstr := '$' + Copy(AString, i+1,2);
                  Result[newpos] := Chr(StrToInt(tempstr));
                  inc(i,2);
                  except
                  on E: EConvertError do
                    begin
                    Delete(tempstr, 1, 1);
                    raise EConvertError.CreateFmt('Invalid escape sequence \x%s at position %d', [tempstr, i-1])
                    end;
                  end
            else if i <= Length(AString) then
              raise EConvertError.CreateFmt('Invalid escape sequence \%s at position %d', [AString[i], i-1]);
          end;
        end
      else
        Result[newpos] := AString[i];
      inc(newpos);
      inc(i);
      end;
    SetLength(Result, newpos-1);
    except
    SetLength(Result, 0);
    raise;
    end;
end;


function NumberToStr(ANumber: LongInt; ABase: TNumbBase): String;
// Thanks to Christian NineBerry Schwarz
begin
   Result := EmptyStr;
   while ANumber > 0 do
     begin
     Result := CNumbDigits[(ANumber mod ABase) + 1] + Result;
     ANumber:= ANumber div ABase;
     end;

   if Result = EmptyStr then
     Result:= '0';
end;

function StrToNumber(AString: String; ABase: TNumbBase): LongInt;
// Thanks to Christian NineBerry Schwarz
var
  i    : Integer;
  value: Byte;
begin
  AString := Trim(AnsiUpperCase(AString));
  Result  := 0;

  for i := 1 to Length(AString) do
    begin
    value := Pos(AString[i], CNumbDigits) - 1;
    if value in [0 .. ABase-1] then
      begin
      Result := Result * ABase;
      Result := Result + value;
      end
    else
      raise EConvertError.Create(Format('StrToNumb: Fehlerhaftes Format (%s)', [AString]));
  end;
end;



procedure StringToStream(AString: string; ADest: TStream);
// Takes a string and appends it to a stream.
var len: longint;
begin
  len := Length(AString);
  ADest.WriteBuffer(len, SizeOf(len));
  ADest.WriteBuffer(AString[1], len);
end;

function StreamToString(ASource: TStream): string;
// Reads from the current position of a stream a string, interpreted as
//  sizeof(longint) bytes ... length of string and the rest is string data
// Does not cut the stream. Thanks to Marian Aldenhövel for the inspiration
var len: longint;
begin
  Result := '';
  ASource.ReadBuffer(len, SizeOf(len));
  SetLength(Result, len);
  ASource.ReadBuffer(Result[1], len)
end;


function CreateTempfile(APrefix: string; var AFilename: string): THandle;
var
   L: Integer;
   TempPath: string;
begin
   L:=GetTempPath(0, nil);
   SetLength(TempPath, L);
   GetTempPath(L, PChar(TempPath));

   SetLength(AFilename, MAX_PATH);
   GetTempFileName(PChar(TempPath), PChar(APrefix), 0, PChar(AFilename));
   SetLength(AFilename, Pos(#0, AFilename)-1);

   Result:= CreateFile(PChar(AFilename), GENERIC_READ or
     GENERIC_WRITE, 0, nil, OPEN_ALWAYS,
     FILE_ATTRIBUTE_TEMPORARY, 0);
end;


function GetEnvironmentString(AName: string): string;
begin
  SetLength(Result, GetEnvironmentVariable(PChar(AName), nil, 0)-1);
  GetEnvironmentVariable(PChar(AName), PChar(Result), Length(Result)+1);
end;


function RandomPassword(ALength: integer = 8; AUpcaseProbability: integer = 10): string;
{ Original Author: Chris Hunt, May 1999
  Original URL   : http://www.extracon.com/office/randpass.shtml
                   (domain is dead as of May 2005)

  Note: Call randomize before calling RandomPassword(). Reason: If you output
        passwords in a loop, you might receive the same passwords over and
        over again, if Randomize was called within the routine.
  Modified by Stefan Huber, May 2005
}
const Vowel : Array[0..33] of String = ('a' , 'a' , 'a' , 'e' , 'e' , 'e' , 'i' , 'i' , 'o' , 'o',
                                        'u' , 'u' , 'ae', 'ai', 'au', 'ao', 'ay', 'ea', 'ei', 'ey',
                                        'ee', 'ua', 'ia', 'ie', 'io', 'oa', 'oe', 'ou', 'oy', 'oo',
                                        '!', '1', '4', '3');
      Cons  : Array[0..20] of String = ('b' , 'c' , 'd' , 'f' , 'g' , 'h' , 'j' , 'k' , 'l' , 'm',
                                        'n' , 'p' , 'q' , 'r' , 's' , 't' , 'v' , 'w' , 'x' , 'z',
                                        '7');
var NextIsVowel: boolean;
    nextpart   : string;

begin
  Result := '';
  NextIsVowel := (Random(2) = 1);
  while Length(Result) < ALength do
    begin
    if NextIsVowel then
      nextpart := Vowel[Random(Length(Vowel))]
    else
      nextpart := Cons[Random(Length(Cons))];
    if Random(100) <= AUpcaseProbability then nextpart := UpperCase(nextpart);
    Result := Result + nextpart;
    NextIsVowel := not NextIsVowel;
    end;
end;


function WinExecAndWait32(AFileName, AParams: String): DWORD;
// collected from various sources on the net
var
  zAppName : array[0..512] of char;
  SI       : TStartupInfo;
  PI       : TProcessInformation;
  s        : string;
  begin
    s := AFileName + ' ' + AParams;
    s := Copy(s, 1, 511);
    StrPCopy(zAppName,s);
    FillChar(SI,Sizeof(SI),#0);
    SI.cb := Sizeof(SI);
    SI.dwFlags := STARTF_USESHOWWINDOW;
    SI.wShowWindow := SW_SHOWDEFAULT;
    if not CreateProcess(nil,
      zAppName,                      { pointer to command line string }
      nil,                           { pointer to process security attributes}
      nil,                           { pointer to thread security attributes }
      false,                         { handle inheritance flag }
      CREATE_NEW_CONSOLE or          { creation flags }
      NORMAL_PRIORITY_CLASS,
      nil,                           { pointer to new environment block }
      nil,                           { pointer to current directory name }
      SI,                   { pointer to STARTUPINFO }
      PI)                   { pointer to PROCESS_INF }
    then Result := DWORD(-1)
    else
       begin
         WaitforSingleObject(PI.hThread,INFINITE);
         GetExitCodeProcess(PI.hProcess,Result);
         CloseHandle( PI.hProcess );
         CloseHandle( PI.hThread );
       end;
end;

{ TLogger }

constructor TLogFileStream.Create(const AFileName: string; ATruncate: boolean);
// Thanks to Michael Winter fpr providing the basic file operaion idea
var Flags : DWORD;
    H     : THandle;
begin
  FLoglevel     := 1;
  FUseTimestamp := true;
  if ATruncate then
    Flags := CREATE_ALWAYS
  else
    Flags := OPEN_ALWAYS;

  H := Integer(CreateFile(PChar(AFileName),
                          GENERIC_READ or GENERIC_WRITE,
                          FILE_SHARE_READ,
                          nil,
                          Flags,
                          FILE_ATTRIBUTE_NORMAL or FILE_FLAG_WRITE_THROUGH,
                          0));
  if H = INVALID_HANDLE_VALUE then RaiseLastWin32Error;

  inherited Create(H);

  if not ATruncate then Position := Size;
end;

destructor TLogFileStream.Destroy;
begin
  if Handle >= 0 then FileClose(Handle);
  inherited;
end;

procedure TLogFileStream.Log(AText: string; ALevel: integer);
begin
  if ALevel <= FLoglevel then
    begin
    if FUseTimestamp then AText := FormatDateTime('yyyy-mm-dd hh:nn:ss ', now) + AText;
    AText :=  AText + #13#10;
    WriteBuffer(AText[1], Length(AText));
    end;
end;

procedure TLogFileStream.Log(AText: string);
begin
  Log(AText, 1);
end;


function  NumberToWordDE(ANumber: double; APlus: boolean = false): string;

  function Bis19(Az: longint): string;
  begin
  Result := '';
  if Az > 19 then raise Exception.Create('Bis19: Zahl zu groß: ' + IntToStr(Az));

  if Az < 10 then Result := DIGITS[Az]
  else if Az = 11 then Result := 'elf'
  else if Az = 12 then Result := 'zwölf'
  else Result := DIGITS[Az-10] + 'zehn';
  end;

  function Bis99(Az: longint): string;
  var zehner, einer : integer;
  begin
  Result := '';
  if Az > 99 then raise Exception.Create('Bis99: Zahl zu groß: ' + IntToStr(Az));
  zehner := (Az div 10) * 10;
  einer  := Az mod 10;

  if aZ < 20 then Result := Bis19(aZ)
  else begin
       if einer > 0 then Result := DIGITS[einer] + 'und'; 
       case zehner of
         20 : Result := Result + 'zwanzig';
         30 : Result := Result + 'dreißig';
         40 : Result := Result + 'vierzig';
         50 : Result := Result + 'fünfzig';
         60 : Result := Result + 'sechzig';
         70 : Result := Result + 'siebzig';
         80 : Result := Result + 'achtzig';
         90 : Result := Result + 'neunzig';
       end;
       end;
  end;

  function Bis999(Az: longint): string;
  begin
  Result := '';
  if Az > 999 then raise Exception.Create('Bis999: Zahl zu groß: ' + IntToStr(Az));
  if Az < 100 then Result := Bis99(Az)
  else begin
       if Az div 100 = 1
         then Result := 'einhundert'
         else Result := DIGITS[Az div 100] + 'hundert';
       if Az mod 100 > 0 then Result := Result +  Bis99(Az mod 100);
       end;
  end;

const SEP = ' ';
var commapos  : integer;
    hintenstr : string;
    vorkomma  : longint;
    pwr       : integer;
    tens      : longint; // powers of 10 for the thousand, million, ...
begin
  Result := '';

  // Vor dem Komma
  vorkomma := Trunc(Abs(ANumber));

  if ANumber = 0
    then begin
         Result := DIGITS[0];
         EXIT;
         end
  else if ANumber < 0
    then Result := MINUS + SEP
  else if (ANumber > 0) and (APlus)
    then Result := PLUS + SEP;

  pwr := 9;
  while (pwr >= 3) do
    begin
    tens := TenBy(pwr);
    if vorkomma div tens > 0
      then begin
           if vorkomma div tens = 1
             then begin
                  case pwr of
                    3 : Result := Result + 'Eintausend';
                    6 : Result := Result + 'Einemillion';
                    9 : Result := Result + 'Einemilliarde';
                    12 : Result := Result + 'Einebillion';
                    15 : Result := Result + 'Einebilliarde';
                  end;
                  end
             else begin
                  Result := Result + Bis999(vorkomma div tens);
                  case pwr of
                    3 : Result := Result + 'tausend';
                    6 : Result := Result + 'millionen';
                    9 : Result := Result + 'milliarden';
                    12 : Result := Result + 'billionen';
                    15 : Result := Result + 'billiarden';
                  end;
                  end;
           vorkomma := vorkomma - (vorkomma div tens) * tens;
           end;
    dec(pwr, 3);
    end;

  if vorkomma > 0
    then begin
         Result := Result + Bis999(vorkomma);
         end;


  // Hinter dem Komma
  hintenstr := FloatToStr(ANumber);
  commapos  := Pos(DecimalSeparator, hintenstr);
  if commapos > 0
    then begin
         hintenstr := Copy(hintenstr, commapos + 1, maxint);
         Result := Result + SEP + COMMA + SEP + DigitStrToDigitWords(hintenstr);
         end;
end;

function  NumberToDigitWordDE(ANumber: double): string;
const SEP = ' ';
var tempstr : string;
    i       : integer;

begin
  Result  := '';
  tempstr := FloatToStr(ANumber);
  for i := 1 to Length(tempstr) do
    begin
    if tempstr[i] = '+' then Result := Result + PLUS + SEP
    else if tempstr[i] = '-' then Result := Result + MINUS + SEP
    else if tempstr[i] = DecimalSeparator then Result := Result + COMMA + SEP
    else Result := Result + DIGITS[Ord(tempstr[i]) - Ord('0')] + SEP;
    end;
end;

function  DigitStrToDigitWords(AInputString: string): string;
// the multiple conversions are there to ensure that only valid numbers are
// passed to this routine.
begin
  Result := NumberToDigitWordDE(StrToFloat(AInputString));
end;

function  TenBy(AExponent: integer): longint;
var i: integer;
begin
  i := AExponent;
  if AExponent = 0
    then begin
         Result := 1;
         EXIT;
         end;
  Result := 10;
  while i > 1 do
    begin
    Result := Result * 10;
    dec(i);
    end;
end;

function  RearMatch(AString, ASubstring: string; AIgnoreCase: boolean = false): boolean;
var tempstr : string;
begin
  Result := false;
  if Length(AString) < Length(ASubstring) then EXIT;
  tempstr := Copy(AString, Length(AString) - Length(ASubstring) + 1, Length(ASubstring));
  if AIgnoreCase
    then begin
         tempstr    := ANSIUpperCase(tempstr);
         ASubstring := ANSIUpperCase(ASubstring);
         end;
  Result := tempstr = ASubstring;
end;


function  UnitToWordDE(AUnit: string; ASingular: boolean = false): string;

  function FirstUpper(AString: string): string;
  var tempstr : string;
  begin
    tempstr := ANSIUpperCase(Copy(AString, 1, 1));
    Result := tempstr + Copy(AString, 2, maxint);
  end;

  function Modifier(AInput: string; unitlength : integer): string;
  var m : char;
  begin
    m := AInput[Length(AInput) - unitlength];
    case m of
      'p': Result := 'Pico';
      'n': Result := 'Nano';
      'm': Result := 'Milli';
      'c': Result := 'Centi';
      'd': Result := 'Dezi';
      'k', 'K': Result := 'Kilo';
      'M': Result := 'Mega';
      'G': Result := 'Giga';
      'T': Result := 'Tera';
      'E': Result := 'Exa';
      'P': Result := 'Penta';
    end;
  end;

  type rUnits = record
                abbr     : string;
                singular : string;
                plural   : string;
                end;

  const UNITS : Array[0..3] of rUnits = (
    (abbr: 'g'; singular: 'gramm'; plural: 'gramm'),
    (abbr: 'l'; singular: 'liter'; plural: 'liter'),
    (abbr: 'm'; singular: 'meter'; plural: 'meter'),
    (abbr: '°'; singular: 'grad'; plural: 'grad')
  );
  var i : integer;
      matched : boolean;

begin
  Result  := '';
  matched := false;

  i := Low(UNITS);
  while not matched and (i <= High(UNITS)) do
    begin
    if RearMatch(AUnit, UNITS[i].abbr, true)
      then begin
           Result := Modifier(AUnit, Length(UNITS[i].abbr));
           if Result <> ''
             then if ASingular
                     then Result := Result + UNITS[i].singular
                     else Result := Result + UNITS[i].plural
             else if ASingular
                     then Result := FirstUpper(UNITS[i].singular)
                     else Result := FirstUpper(UNITS[i].plural)
           end;
    inc(i);
    end;

end;



constructor TRecode.Create(AFilename: string);
begin
  inherited Create(AFilename);
  FErrStr := '-- error --';
end;

destructor TRecode.Destroy;
begin
  inherited;
end;

function TRecode.Lookup(ASection, AValue: string): string;
// Lookup returns the specified error string instead of raising an exception.
// In case the error string is empty, the exception is raised anyway.
begin
  Result := FErrStr;
  if FErrStr <> ''
    then Result := ReadString(ASection, AValue, FErrStr)
    else begin
         if not ValueExists(ASection, AValue) then
           raise Exception.Create('[' + ASection + '] - ' + AValue + ' does not exist in the recoding table!');
         Result := ReadString(ASection, AValue, '');
         end;
end;

function TRecode.Recode(ASection, AValue: string): string;
// returns AValue, if the given
begin
  try
    Result := ReadString(ASection, AValue, AValue);
  except
    Result := AValue;
  end;
end;


function TGetopt.ArgumentType(AChar: char): TArgumentType;
var p : integer;
begin
  Result := atNone;
  p := Pos(Achar, Foptstring);
  if p > 0 then
    begin
    if (p < Length(FOptstring)) then
      begin
      if (FOptstring[p + 1] = ':') then Result := atRequired;
      if (p < Length(FOptstring) - 1) and
         (Result = atRequired) and
         (FOptstring[p + 2] = ':') then Result := atOptional;
      end;
    end;
end;

constructor TGetopt.Create(const AOptstring: string; const ALongopts: TLongopts = nil);
begin
  inherited Create;
  FLongopts  := ALongopts;
  FOptstring := AOptstring;
  Optind     := 1;
  Current    := 1;
  FRemainingArguments := TStringList.Create;
end;

destructor TGetopt.Destroy;
begin
  FRemainingArguments.Free;
  inherited;
end;

function TGetopt.getopt: boolean;
var ot       : TOptionType;
    at       : TArgumentType;
    newData  : boolean;
    longoptP : PLongopt;
    longoptname : string;
begin
  Result    := false;
  FArgument := '';
  FOption   := #0;
  newData := NextOptind;
  ot := OptionType(Current);
  if (ot = otNo) or (ParamStr(Current) = '--') or (ParamStr(Current) = '-') then
    begin
    if ot = otNo then if OptInd > 1 then dec(optind);
    MakeRemainingArguments
    end
  else
    begin
    if newData then FOption := ParamStr(Current)[Optind];

    FIsLongOption := ot = otLong;
    if FIsLongOption
      then begin
           longoptP := LongoptLookup(longoptname);
           newdata := longoptP <> nil;
           if not newdata then
             begin
             raise CreateException('Invalid long command line option encountered!',
                                   longoptname);
             end;
                        FLongOption := longoptP^.Name;
           FOption := longoptP^.EqualsShort;
           if FOption = #0
             then at := longoptP^.Argument
             else begin
                  at := ArgumentType(FOption);
                  FIsLongOption := false; // the long thing equals a short one.
                  end;
           end
      else begin
           FLongOption := '';
           if newData and not IsOption then
             begin
             raise CreateException('Invalid command line option encountered!');
             end;
           at := ArgumentType(FOption);
           end;

    if newData then
      begin
      case at of
        atNone     : if (FLongOption <> '') and
                        (OptInd <= Length(ParamStr(Current))) then
                        begin
                        raise CreateException('This long parameter expects no arguments!');
                        end;
        atRequired : begin
                     FArgument := ReadArgument(atRequired);
                     if FArgument = '' then
                       begin
                       if FLongOption <> ''
                         then raise CreateException('Required argument missing!', FLongOption)
                         else raise CreateException('Required argument missing!');
                       end;
                     end;
        atOptional : FArgument := ReadArgument(atOptional);
      end;
      end;

    if not newData then MakeRemainingArguments;
    Result := newData;
    end
end;

function TGetopt.GetProgramName: string;
begin
  Result := ParamStr(0);
end;

procedure TGetopt.MakeRemainingArguments;
var i: integer;
begin
  FRemainingArguments.Clear;
  if Current <= ParamCount then
    begin
    FRemainingArguments.Add(Copy(ParamStr(Current), Optind, maxint));
    i := Current + 1;
    while i <= ParamCount do
      begin
      FRemainingArguments.Add(ParamStr(i));
      inc(i);
      end;
    end;
end;

function TGetopt.IsOption(AOption: string = ''): boolean;
begin
  if AOption = '' then AOption := FOption;
  Result := (AOption <> ':') and (Pos(AOption, FOptstring) > 0)
end;

function TGetopt.MoveToNextParamstr: boolean;
begin
  Result := false;
  if (Current < ParamCount)
    then begin
         Inc(Current);
         Optind := 1;
         case OptionType(Current) of
           otNo    : Optind := 1;
           otShort : Optind := 2;
           otLong  : Optind := 3;
         end;
         Result := true;
         end
    else begin
         Optind := Length(ParamStr(Current))
         end;
end;

function TGetopt.OptionType(AIndex: integer): TOptionType;
var len : integer;
begin
  Result := otNo;
  len := Length(ParamStr(AIndex));
  if (len > 2) and // -- or //
     (ParamStr(AIndex)[1] in ['-', '/']) and
     (ParamStr(AIndex)[2] = ParamStr(AIndex)[1])
  then Result := otLong
  else
  if (Length(ParamStr(AIndex)) > 1) and
     (ParamStr(AIndex)[1] in ['-', '/'])
  then
    begin
    Result := otShort;
    end;
end;


function TGetopt.ReadArgument(AArgumentType: TArgumentType): string;
begin
  Result := '';
  if Current > ParamCount then EXIT;
  case AArgumentType of
    atRequired : begin
                 if Optind < Length(ParamStr(Current))
                   // For required arguments, there MUST be either remaining text
                   // in the Current ParamStr...
                   then begin
                        Result := Copy(ParamStr(Current), Optind + 1, maxint);
                        Optind := Length(ParamStr(Current));
                        end
                   else begin
                   // ...or a consequtive ParamStr
                        if Current < ParamCount then
                          begin
                          if OptionType(Current + 1) = otNo then
                            begin
                            MoveToNextParamstr;
                            Result := ParamStr(Current);
                            OptInd := Length(ParamStr(Current));
//                            MoveToNextParamstr;
                            end;
                          end;
                        end;
                 end;
    atOptional : begin
                 if Optind < Length(ParamStr(Current))
                   // if there's remaining text in the Current ParamStr, take
                   // this one and advance...
                   then begin
                        Result := Copy(ParamStr(Current), Optind + 1, maxint);
                        Optind := Length(ParamStr(Current));
                        end
                   else begin
                   // ...otherwise return the next ParamStr,
                        if Current < ParamCount then
                          begin
                          if OptionType(Current + 1) = otNo then
                            begin
                            MoveToNextParamstr;
                            Result := ParamStr(Current);
                            Optind := Length(Result) + 1;
                            end;
                          end;
                        end
                 end;
    else Result := '';
  end;
end;

function TGetopt.CreateException(const AMessage: string; AOption : string = ''): EGetoptException;
begin
  Result := EgetoptException.Create(AMessage);
  Result.Optind := Optind;
  Result.ParamStr := ParamStr(Current);
  if AOption = ''
    then Result.OffendingOption := ParamStr(Current)[OptInd]
    else Result.OffendingOption := AOption;
end;

function TGetopt.LongoptLookup(out AOptionName: string): PLongopt;
// checks if there is a long option and updates OptInd and Current if necessary
var i, p : integer;
begin
  Result := nil;
  if Length(FLongopts) = 0 then EXIT;

  p := Optind;
  // extract long name from the ParamStr until the end or until a = is reached
  while (p <= Length(ParamStr(Current))) and
        not (ParamStr(Current)[p] in [#0..#32, '=']) do inc(p);
  AOptionName := Copy(ParamStr(Current), Optind, p - Optind);
  while (Length(AOptionName) > 1) and (AOptionName[1] in ['-', '/']) do Delete(AOptionName, 1, 1); 

  i := Low(FLongopts);
  while (i <= High(FLongopts)) and (FLongopts[i].Name <> AOptionName) do inc(i);
  if i <= High(FLongopts) then
    begin
    Result := @FLongopts[i];
    if p > Length(ParamStr(Current))
      then OptInd := Length(ParamStr(Current)) + 1 // MoveToNextParamstr // no =, so move on to the next one
      else OptInd := p;
    end;
end;

function TGetopt.NextOptind: boolean;
begin
  Result := true;
  if Current > ParamCount then
    begin
    Result := false;
    EXIT;
    end;
  if Optind < Length(ParamStr(Current))
    then inc(Optind)
    else begin
         if not MoveToNextParamstr then
           begin
           Result  := false;
           Current := ParamCount + 1;
           end;
         end;
end;

procedure TGetopt.AddLongOption(const AName: string;
                                const AEqualsShort: char);
begin
  DoAddLongOption(AName, AEqualsShort, atNone);
end;

procedure TGetopt.AddLongOption(const AName: string;
                                const AArgumentType: TArgumentType);
begin
  DoAddLongOption(AName, #0, AArgumentType);
end;

procedure TGetopt.DoAddLongOption(const AName: string;
  const AEqualsShort: char; const AArgumentType: TArgumentType);
begin
  SetLength(FLongOpts, Length(FLongOpts) + 1);
  with FLongOpts[Length(FLongOpts) - 1] do
    begin
    Name        := AName;
    EqualsShort := AEqualsShort;
    Argument    := AArgumentType;
    end;
end;

function  LanguageNameFromCode(ALanguageCode: string; ATrySuperLanguages: boolean = true): string;
var reg  : TRegistry;
    sl   : TStringList;
    i    : integer;
    value: string;
begin
  Result := '';
  reg := TRegistry.Create;
  sl  := TStringList.Create;
    try
      try
      reg.Access  := KEY_READ;
      reg.RootKey := HKEY_CLASSES_ROOT;
      if reg.OpenKey('\Mime\Database\Rfc1766', false) then
        begin
        reg.GetValueNames(sl);
        i := 0;
        value := reg.ReadString(sl.Strings[i]);
        while (i < sl.Count) and
              (ANSILowerCase(ExpressStringPart(value, ';', 0)) <> ALanguageCode) do
          begin
          value := reg.ReadString(sl.Strings[i]);
          inc(i);
          end;
        if i < sl.Count then Result := ExpressStringPart(value, ';', 1);
        end;
      except
      end;
    finally
    sl.Free;
    reg.Free;
    end;

  if ATrySuperLanguages and (Result = '') then
    begin
    value := ExpressStringPart(ALanguageCode, '-', 0);
    if value <> ALanguageCode then
      begin
      Result := LanguageNameFromCode(value);
      end;
    end;
end;

function ExpressStringPart(AInputString, ADelimitingString: string; APartNumber: integer): string;
var p : integer;
begin
  Result := '';
  p      := ANSIPos(ADelimitingString, AInputString);
  while (p > 0) and (APartNumber > 0) do
    begin
    Delete(AInputString, 1, p);
    p     := ANSIPos(ADelimitingString, AInputString);
    dec(APartNumber);
    end;
  if (APartNumber >= 0) then
    if p > 0 then Result := Copy(AInputString, Length(ADelimitingString), p - Length(ADelimitingString))
             else Result := AInputString;
end;

