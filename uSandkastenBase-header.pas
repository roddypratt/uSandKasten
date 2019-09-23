type
  EGetoptException = class(Exception)
  private
    FOptind: integer;
    FParamStr: string;
    FOffendingOption: string;
  public
    property OffendingOption : string read FOffendingOption write FOffendingOption;
    property Optind          : integer read FOptind write FOptind;
    property ParamStr        : string read FParamStr write FParamStr;
  end;
  TOptionType = (otNo, otShort, otLong);
  TArgumentType = (atNone, atRequired, atOptional);
  TLongopt = record
             Name        : string;        // the long option name
             EqualsShort : char;          // the short equivalent
             Argument    : TArgumentType; // only relevant, if there is no shortopt
             end;
  PLongopt = ^TLongopt;
  TLongopts = array of TLongopt;
  TGetopt = class
  protected
    procedure DoAddLongOption(const AName: string; const AEqualsShort: char; const AArgumentType: TArgumentType);
  private
    Current            : integer; // current ParamStr
    Optind             : integer; // index of the next possible option character. Needed for -abcd options or invalid options or parameters like -d0
    FLongopts          : TLongopts;
    FOptString         : string;
    FArgument          : string;
    FOption            : char;
    FRemainingArguments: TStringList;
    FIsLongOption: boolean;
    FLongOption: string;
    function  ArgumentType(AChar: char): TArgumentType;
    function  CreateException(const AMessage: string; AOption : string = ''): EGetoptException;
    function  GetProgramName: string;
    function  IsOption(AOption: string = ''): boolean;
    function  LongoptLookup(out AOptionName: string): PLongopt;
    procedure MakeRemainingArguments;
    function  MoveToNextParamstr: boolean;
    function  NextOptind: boolean;
    function  OptionType(AIndex: integer): TOptionType;
    function  ReadArgument(AArgumentType: TArgumentType): string;
  public
    constructor Create(const AOptstring: string; const ALongopts: TLongopts = nil);
    destructor  Destroy; override;

    procedure AddLongOption(const AName: string; const AEqualsShort: char); overload;
    procedure AddLongOption(const AName: string; const AArgumentType: TArgumentType); overload;
    function  getopt: boolean; // call this function to trigger parsing

    property Argument: string read FArgument;
    property IsLongOption: boolean read FIsLongOption; // is only true, if there is no short equivalent
    property LongOption: string read FLongOption;
    property Option: char read FOption;
    property ProgramName: string read GetProgramName;
    property RemainingArguments: TStringList read FRemainingArguments;
      // this holds the rest of the passed arguments that are not options
      // or arguments to options.
  end;

  TNumbBase = 1..36;

  TLogFileStream = class(THandleStream)
  private
    FLoglevel: byte;
    FUseTimestamp: boolean;
  public
    constructor Create(const AFileName: string; ATruncate: boolean);
    destructor Destroy; override;
    procedure Log(AText: string); overload; virtual;
    procedure Log(AText: string; ALevel: integer); overload; virtual;

    property Loglevel : byte read FLoglevel write FLoglevel;
    property UseTimestamp: boolean read FUseTimestamp write FUseTimestamp;
  end;

  TRecode = class(TMemIniFile)
  private
    FErrStr: string;
  public
    constructor Create(AFilename: string);
    destructor Destroy; override;

    function Lookup(ASection, AValue: string): string;
    function Recode(ASection, AValue: string): string;

    property ErrorString: string read FErrStr write FErrStr;
  end;

function  CreateTempfile(APrefix       : string;
                         var AFilename : string): THandle;
function  DigitStrToDigitWords(AInputString: string): string;
function  EscapeString(const AString: string): string;
function  GetComputerName: string;
function  GetEnvironmentString(AName: string): AnsiString;
function  GetBuildInfo(const AFilename:String; var V1,V2,V3,V4:Word):Boolean;
function  ExpressStringPart(AInputString, ADelimitingString: string; APartNumber: integer): string;
          // returns the APartNumber-th part within AInputString. AInputString is considered delimited by ADelimitingString;
function  HTMLEntityDecode(const AInput: string): string;
function  HTMLEntityEncode(const AInput: string): string;
function  LanguageNameFromCode(ALanguageCode: string; ATrySuperLanguages: boolean = true): string;
          // returns the localized name (from the registry) of a given language code
          // If ATrySuperLanguages = true then the function tries to look up "de" when "de-notfound" is looked for initially
function  NumberToStr(ANumber : LongInt;
                      ABase   : TNumbBase): String;
function  NumberToWordDE(ANumber : double;
                         APlus   : boolean = false): string;
function  NumberToDigitWordDE(ANumber: double): string;
function  RandomPassword(ALength            : integer = 8;
                         AUpcaseProbability : integer = 10): string;
function  RearMatch(AString, ASubstring : string;
                    AIgnoreCase         : boolean = false): boolean;
procedure StringToStream(AString : string;
                         ADest   : TStream);
function  StreamToString(ASource: TStream): string;
function  StrToNumber(AString : String;
                      ABase   : TNumbBase): LongInt;
function  TenBy(AExponent: integer): longint;
function  UnescapeString(const AString: string): string;
function  UrlDecode(const AInputString: string): string;
function  UrlEncode(const AInputString: string): string;
function  UnitToWordDE(AUnit     : string;
                       ASingular : boolean = false): string;
function  WinExecAndWait32(AFileName, AParams: String): DWORD;
