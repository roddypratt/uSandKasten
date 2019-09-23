
function GetHostByHelpers(const HostEnt         : PHostEnt;
                          const AIPAddresses    : TStrings = nil;
                          const AAlternateNames : TStrings = nil;
                          AReturnIP             : boolean = true): string;
type PPInAddr= ^PInAddr;
var addr     : PPInAddr;
    pTmp     : Pointer;
begin
  Result := '';
  if hostent <> nil then
    begin
    // take care for the IP addresses. Return the first one as function result
    // and optionally other IP addresses, if a TStrings object was handed over
    Addr := Pointer(hostent^.h_addr_list);
    if AReturnIP and (addr <> nil) and (addr^ <> nil)
      then Result := StrPas(inet_ntoa(addr^^));

    if Assigned(AIPAddresses) then
      while (addr <> nil) and (addr^ <> nil) do
        begin
        AIPAddresses.Add(StrPas(inet_ntoa(addr^^))) ;
        inc(Addr);
        end;

    // Return the host name as result and optionally fill the TStrings object
    // with alternate names
    if not AReturnIP and (hostent^.h_name <> nil)
      then Result := StrPas(PChar(hostent^.h_name));
    if Assigned(AAlternateNames) and (hostent^.h_aliases <> nil) then
      begin
      pTmp := hostent^.h_aliases;
      while (PChar(pTmp^) <> nil) do
        begin
        AAlternateNames.Add(StrPas(PChar(pTmp^)));
        Inc(PChar(pTmp), SizeOf(PChar));
        end;
      end
    end
end;

function  GetHostByAddr(AAddr                 : string;
                        const AIPAddresses    : TStrings = nil;
                        const AAlternateNames : TStrings = nil): string;
var WSAData  : TWSAData;
    hostent  : PHostEnt;
    pAddr    : PChar;
    lIP      : longint;
begin
  Result := '';
  if WSAStartUp(MAKEWORD(2,0), WSAData) = 0 then
    try
      lIP   := inet_addr( @AAddr[1] );
      pAddr := PChar( @lIP );
      hostent := Winsock.getHostByAddr(PChar(pAddr), 4, AF_INET);
      Result := GetHostByHelpers(hostent, AIPAddresses, AAlternateNames, false);
    finally
     WSACleanup;
    end;
end;


function GetHostByName(AHostname: string; const AIPAddresses: TStrings = nil; const AAlternateNames : TStrings = nil): string;
var WSAData  : TWSAData;
    hostent  : PHostEnt;
begin
  Result := '';
  if WSAStartUp(MAKEWORD(2,0), WSAData) = 0 then
    try
      hostent := Winsock.getHostByName(PChar(AHostname));
      Result := GetHostByHelpers(hostent, AIPAddresses, AAlternateNames);
    finally
     WSACleanup;
    end;
end;
