(*==============================================================================
  ���������  : ������� ������� ���������
  ������     : 
  ������     : ������� �.�.
  ���������� :
==============================================================================*)
unit SWIFT_UUtils;

////////////////////////////////////////////////////////////////////////////////
interface///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

uses  Db, SysUtils, synautil;

////////////////////////////////////////////////////////////////////////////////
type
  SubjectSWIFTInfo = packed record
    siName    : String;
    siAddr    : String;
    siSWIFT   : String;
    siBIC     : String;
    siUNN     : String;
    siINN     : String;
    siCorrAcc : String;
  end;

  FAccInfo = packed record
    PayID      : Integer;
    Acc        : String;
    AccCurr    : Integer;
    BIC_Code   : String;
    Swift_Code : String;
    Address    : String;
    BankName   : String;
  end;

const
  cEditableFields: array [0..1] of string = (
    'CONFDET.FIA.70E.FIAN', 'CONFDET.70E' );

const
  SWIFT_MrkRefId = 30001;                                       // ��������� ����������
  cMessagesLinkKind = 70000;                                    // ��� ����� ������ � ����������
  cMessagesLinkByRefKind = 70001;                               // ����� ��������� � ���������� �� ���������
  cMessagesToMessagesLinkKind = 70003;                          // ����� ��������� � ������������ ����������
  PaySystems: array[0..1] of String = ('SWIFT', 'TELEX');       // ��������� �������
  ItemPathName = '������������������� ��������';                // ����� � ���

  cnSwiftItemPath = '����� swift ���������';                    // ����� ������ SWIFT ��������� � ���

const
  cnSWIFTMsgText = 'MsgText';
  cnSWIFTType = 'SWIFTType';
  cnSWIFTMandatoryFields = 'SWIFTMandatoryFields';
  cnSWIFTMandatoryFieldsPlainText = 'SWIFTMandatoryFieldsPlainText';

const
  {�������, ���������� � ������������� SWIFT}
  SWIFTPermissible=['A'..'Z','a'..'z','0'..'9','/','-','?',':','(',')','.',#44,#39,'+',' '];

(*
//��������� ��������� � SWIFTMSGARCHIVE
function AddToSwiftArch(const aDirection: Integer; aPaySys: Integer; aFileName: String; aMsgText: String;
 iTemplId: Integer; aSender: String; aReciever : String;
 aRef20: String; aRef21: String; aValueDate: TDateTime; aDate_op: TDateTime; iUSERID:Integer): Integer;

//������� �� ������ ������� � ������� �������
function CopyNotQuote(str: String): String;
//�������������� �������������� ������ ��� ��������� ���������
function CopySwiftAdd(const str: String): String;
//������/���������� '.' �� ',' � ������
function ReplacePointStr(str: String): String;
*)
//�������� �� ������� ����� '/' � ������ � ��������� ������� ����; �� ������� ���� ���������������� ������ '//' � ����
//��������� � �������� ��� :20: � :21: ����
function CheckingForSlashes(const StrValid: string; const FieldName: string): string;
(*
//�������� ���� �� ���������� ����� � ������� ������������� ��������
function ValidLineSWIFT(const StrValid: string; const ValidLength: Integer; const FieldName: string): string;
function IsValidDate(Y, M, D: Word): Boolean;


// ���������� ���������� � ���������� ����������� ��� ��)
// ����������, ��� �� ������������ ����� ��������������� �������������� �����������
function GetBankInfoForMR(const ID: Integer; const sBIC, sSW: String; const bR: Boolean = False): SubjectSWIFTInfo;

////////////////////////////////////////////////////////////////////////////////

// ���������� ���������� � ��������
function GetSubjectInfoSwift(const SID: Integer; const bRUS: Boolean = False; const IsFullAddress: Boolean = False): SubjectSWIFTInfo;
// ���������� ���������� � �������
function GetClientInfoSwift(const CLID: Integer; const bRUS: Boolean = False; const IsFullAddress: Boolean = False): SubjectSWIFTInfo;

// ���������� ���������� � ������� �����
function GetFAccInfo(const Acc: String; const Curr: Integer; const B: String = ''; const S: String=''): FAccInfo;
// ���������� ���������� � �����
function GetAccInfo(const cAcc: String; const Curr: Integer; const BICCode: String; const SwiftCode: String): FAccInfo;

////////////////////////////////////////////////////////////////////////////////
// ���������� True ���� ���������� ������� STP
function GetSTPforBIC(const sBIC: String): Boolean;
// ���������� True ���� ���������� ������� STP
function GetSTPforSWIFT(const sSWIFT: String): Boolean;
// ���������� True ���� ���������� ������� BKE
function GetBKEforBIC(const sBIC: String): Boolean;
// ���������� True ���� ���������� ������� BKE
function GetBKEforSWIFT(const sSWIFT: String): Boolean;
//���������� ��� ����������� �������
function GetClearingCode(const sBIC: String): String;
*)
// ���������� True ���� SWIFT ��� ��������� �����������
function ValidateSWIFT(aSWIFT: String): Boolean;
(*
//����������� �������� �� �������� � ��������
function IsCorrAccIDForAtrRefID(const iAccId: Integer; const sRefid: String): Boolean;

function GetIsFullAddrr(const iAccID: Integer): Boolean;

// ������������� ��������� swift ���������
procedure LinkParentEntities(aEntID: Integer; aSwiftMsgEntID: Integer; aActID: Integer);

// �� �������� ������������
function GetRegUserID: Integer;

function GetRegFuncID: Integer;
*)

////////////////////////////////////////////////////////////////////////////////
type
  TSWIFTBuilder = class(TStringBuilder)
  private
    FMaxLineLength: Integer;
  public
    procedure AfterConstruction; override;
  public
    function AppendSWIFTLine(const aValue: string): TSWIFTBuilder; overload;
    function AppendSWIFTLine(const aValue: string; const Args: array of const): TSWIFTBuilder; overload;
    function AppendLineFmt(const aValue: string; const Args: array of const): TSWIFTBuilder;
  end;

//
function StrRightPad(const str: String; ForceLength: Integer; const strPad: String): String;

function GetBetweenEx(const PairBegin, PairEnd, Value: string): string;

function Contains(const aNumber: Integer; const aValues: array of Integer): Boolean;

//
function iff(expr: Boolean; Val1, Val2: Variant): Variant;

{���������� ������� ������� � ������ ������������ ��� S.W.I.F.T. ��������}
function IsSWIFTPermissible(const str: String; out strError: String): Boolean;


// ��������� ������������� ����������� ������� ���� SWIFT ���������
// �� ����������� ����� �������� � ���
//function IsNeedAuth(aType: Integer): Boolean;

////////////////////////////////////////////////////////////////////////////////
implementation//////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

(*
uses
  DateUtil,
  SYS_UStr,
  SYS_uDllInit,
  Sys_uDbTools,
  API_uSwiftTrans,
  SVD_UApiClientUtils,
  SVD_UAPIAccUtils,
  API_uAppSettings,
  EXP_USubjects;
*)

function Contains(const aNumber: Integer; const aValues: array of Integer): Boolean;
var
  Index: Integer;
begin
  Result := False;
  for Index := Low(aValues) to High(aValues) do
    if aNumber = aValues[Index] then
      Exit(True);
end;

function GetBetweenEx(const PairBegin, PairEnd, Value: string): string;
var
  n: integer;
  x: integer;
  s: string;
  lenBegin: integer;
  lenEnd: integer;
  str: string;
  max: integer;
begin
  lenBegin := Length(PairBegin);
  lenEnd := Length(PairEnd);
  n := Length(Value);
  if (Value = PairBegin + PairEnd) then
  begin
    Result := '';//nothing between
    exit;
  end;
  if (n < lenBegin + lenEnd) then
  begin
    Result := Value;
    exit;
  end;
  s := SeparateRight(Value, PairBegin);
  if (s = Value) then
  begin
    Result := '';
    exit;
  end;
  n := Pos(PairEnd, s);
  if (n = 0) then
  begin
    Result := '';
    exit;
  end;
  Result := '';
  x := 1;
  max := Length(s) - lenEnd + 1;
  for n := 1 to max do
  begin
    str := copy(s, n, lenEnd);
    if (str = PairEnd) then
    begin
      Dec(x);
      if (x <= 0) then
        Break;
    end;
    str := copy(s, n, lenBegin);
    if (str = PairBegin) then
      Inc(x);
    Result := Result + s[n];
  end;
end;

(*
//��������� ��������� � SWIFTMSGARCHIVE
function AddToSwiftArch(const aDirection: Integer; aPaySys: Integer; aFileName: String; aMsgText: String;
 iTemplId: Integer; aSender: String; aReciever : String;
 aRef20: String; aRef21: String; aValueDate: TDateTime; aDate_op: TDateTime; iUSERID:Integer): Integer;
  var vMsgText: String;
begin
  with TMyQuery.Create(nil) do try

    SQL.Text :=
       'Insert Into SWIFTMSGARCHIVE (SWIFTMSGID, DIRECTION, FILENAME, MSGTYPE, SENDER, RECIEVER, REFERENCE20, REFERENCE21,'#13
      +'MSGTEXT, PROCESSTIME, VALUEDATE, OPERDATE, PAYSYS, USERID)'#13
      +'values (SEQSWIFTMsgID.Nextval, :DIRECTION, :FILENAME, :MSGTYPE, :SENDER, :RECIEVER, :REFERENCE20, :REFERENCE21,'#13
      +':MSGTEXT, :PROCESSTIME, :VALUEDATE, :OPERDATE, :PAYSYS, :USERID) RETURNING SWIFTMSGID INTO :RESULT';

    ParamByName('DIRECTION').AsString := IntToStr(aDIRECTION);
    ParamByName('FILENAME').AsString  := aFileName;
    ParamByName('MSGTYPE').AsInteger  := iTemplId;
    ParamByName('SENDER').AsString    := aSender;
    if (ParamByName('SENDER').AsString='') then ParamByName('SENDER').AsString := CurrContext.GetVal(['REGISTRY','COMMON','BANK','SWIFT_CODE']);
    ParamByName('RECIEVER').AsString    := trim(copy(Subst(aReciever,''#39'',' '),1,15));;
    ParamByName('REFERENCE20').AsString := trim(copy(Subst(aRef20,''#39'',' '),1,16));
    ParamByName('REFERENCE21').AsString := trim(copy(Subst(aRef21,''#39'',' '),1,16));
    vMsgText := Subst(aMsgText,''#$D#$A'','~');
    vMsgText := Subst(vMsgText,''#39'',' ');
    vMsgText := trim(Subst(vMsgText,''#34'',' '));
    ParamByName('MSGTEXT').AsWideString := vMsgText;
    if (ParamByName('MSGTEXT').AsString='') then ParamByName('MSGTEXT').AsString := '???';
    ParamByName('PROCESSTIME').AsDateTime := now;
    ParamByName('VALUEDATE').AsDateTime := aValueDate;
    if (ParamByName('VALUEDATE').AsDateTime=0) then ParamByName('VALUEDATE').Clear;
    ParamByName('OPERDATE').AsDateTime := aDate_op;
    if (ParamByName('OPERDATE').AsDateTime=0) then ParamByName('OPERDATE').Clear;
    if (aPaySys=0) then ParamByName('PAYSYS').AsInteger := 1
    else                ParamByName('PAYSYS').AsInteger := 0;
    ParamByName('USERID').AsInteger := iUSERID;

    ParamByName('RESULT').ParamType := ptOutput;
    ParamByName('RESULT').DataType := ftInteger;

    ExecSQL;

    Result := ParamByName('RESULT').AsInteger;
  finally
    Free;
  end;
end;

////������� �� ������ ������� � ������� �������
function CopyNotQuote(str: String): String;
var
  i: Integer;
begin
  Result:='';
  for i:=1 to Length(str) do begin
    if not(str[i] in [#39,'"']) then begin
      Result := Result+ str[i];
    end;
  end;
end;

//�������������� �������������� ������ ��� ��������� ���������
function CopySwiftAdd(const str: String): String;
  var s: String;
begin
  if (str>'') then begin
    if IsTrans(str) then begin
      s := StrSWIFTTransliteration(str, 0, stRUR6);
      Result := CopySWIFT(s, 1, length(s), [#39]);
    end else begin
      Result := CopySWIFT(str, 1, length(str));
    end;
  end;
end;

//������/���������� '.' �� ',' � ������
function ReplacePointStr(str: String): String;
  var PDof: PChar;
begin
  //str := Abs(str);
  PDof := AnsiStrScan(PChar(str),'.');
  if Assigned (PDof) then
    PDof^ := ','
  else
    str := str + ',';

  if str = ',' then str := '0,';

  Result := str;
end;
*)
function CheckingForSlashes(const StrValid: string; const FieldName: string): string;
var sErr: string;
var eStrValid: string;
begin
  if Pos(':SEME//', StrValid) > 0 then
    eStrValid := SeparateRight(StrValid, ':SEME//');
  //�������� �� ������ ���������� �� �����
  if (eStrValid > '') and (Copy(eStrValid,1,1) = '/') then
    sErr := sErr + #13 + '���� ' + FieldName + ' �� ������ ���������� �� ����� "/"';

  //������������� ������
  if (eStrValid > '') and (Copy(eStrValid, length(eStrValid), 1)='/') then
    sErr := sErr + #13 + '���� ' + FieldName + ' �� ������ ������������� ������ "/"';

  //��������� ������ ������� ����
  if (eStrValid > '') and Assigned(AnsiStrPos(PChar(eStrValid), PChar('//'))) then
    sErr  := sErr + #13 + '���� ' + FieldName + ' �� ������ ��������� ������ ������� ���� "//"';

  Result := sErr;
end;

(*
function ValidLineSWIFT(const StrValid: string; const ValidLength: Integer; const FieldName: string): string;
var sErr: string;
begin
   if (length(StrValid) > ValidLength) then
     sErr := sErr+#13+Format('%s'#$9'%s - ����� (%d) ==> ���������� ����� (%d)',[FieldName, StrValid, length(StrValid), ValidLength]);

   if IsTrans(StrValid) then
     sErr := sErr+#13+Format('%s'#$9'%s ==> ������������ �������',[FieldName, StrValid]);

   Result := sErr;
end;

function IsValidDate(Y, M, D: Word): Boolean;
begin
  Result := (Y >= 1) and (Y <= 9999) and (M >= 1) and (M <= 12) and
    (D >= 1) and (D <= DaysPerMonth(Y, M));
end;


//------------------------------------------------------------------------------
// ���������� ���������� � ���������� ����������� ��� ��)
// ����������, ��� �� ������������ ����� ��������������� �������������� �����������
function GetBankInfoForMR(const ID: Integer; const sBIC, sSW: String; const bR: Boolean = False): SubjectSWIFTInfo;
begin
  //�� SWIFT-����
  if (sSW>'') then begin
    Result.siSWIFT := sSW;
    try
      with GetFBankSwiftInfo(sSW) do begin
        Result.siBIC := BIC;
        Result.siCorrAcc := CorrAcc;
        if bR then begin
          if (Name>'') then Result.siName := Name else Result.siName := NameInt;
          if (Address>'') then Result.siAddr := Address else Result.siAddr := IntAddress;
        end else begin
          if (NameInt>'') then Result.siName := NameInt else Result.siName := Name;
          if (IntAddress>'') then Result.siAddr := IntAddress else Result.siAddr := Address;
        end;
      end;
      Exit;
    except
      on E: ENoRecordFound do begin
        try
          with GetSubjectSwiftInfo(sSW) do begin
            Result.siBIC := BIC;
            Result.siCorrAcc := CorrAcc;
            if bR then begin
              if (SubjectName>'') then Result.siName := SubjectName else Result.siName := InternationalName;
              if (Domicile>'') then Result.siAddr := Domicile else Result.siAddr := InternationalDomicile;
            end else begin
              if (InternationalName>'') then Result.siName := InternationalName else Result.siName := SubjectName;
              if (InternationalDomicile>'') then Result.siAddr := InternationalDomicile else Result.siAddr := Domicile;
            end;
          end;
          Exit;
        except
          on E: ENoRecordFound do begin
          end;
        end;
      end;
    end;
  end;
  //�� BIC-����
  if (sBIC>'') then begin
    Result.siBIC := sBIC;
    try
      with GetFBankBICInfo(sBIC) do begin
        Result.siSWIFT := SWIFT;
        Result.siCorrAcc := CorrAcc;
        if bR then begin
          if (Name>'') then Result.siName := Name else Result.siName := NameInt;
          if (Address>'') then Result.siAddr := Address else Result.siAddr := IntAddress;
        end else begin
          if (NameInt>'') then Result.siName := NameInt else Result.siName := Name;
          if (IntAddress>'') then Result.siAddr := IntAddress else Result.siAddr := Address;
        end;
      end;
    except
      on E: ENoRecordFound do begin
        try
          with GetSubjectBicInfo(sBIC) do begin
            Result.siSWIFT := SWIFT;
            Result.siCorrAcc := CorrAcc;
            if bR then begin
              if (SubjectName>'') then Result.siName := SubjectName else Result.siName := InternationalName;
              if (Domicile>'') then Result.siAddr := Domicile else Result.siAddr := InternationalDomicile;
            end else begin
              if (InternationalName>'') then Result.siName := InternationalName else Result.siName := SubjectName;
              if (InternationalDomicile>'') then Result.siAddr := InternationalDomicile else Result.siAddr := Domicile;
            end;
          end;
        except
          on E: ENoRecordFound do begin
          end;
        end;
      end;
    end;
  end;
  //�� �� ��������
  if (ID>0) then begin
    try
      with GetSubjectInfo(ID) do begin
        Result.siBIC := BIC;
        Result.siSWIFT := SWIFT;
        Result.siCorrAcc := CorrAcc;
        if bR then begin
          if (SubjectName>'') then Result.siName := SubjectName else Result.siName := InternationalName;
          if (Domicile>'') then Result.siAddr := Domicile else Result.siAddr := InternationalDomicile;
        end else begin
          if (InternationalName>'') then Result.siName := InternationalName else Result.siName := SubjectName;
          if (InternationalDomicile>'') then Result.siAddr := InternationalDomicile else Result.siAddr := Domicile;
        end;
      end;
    except end;
  end;
end;

//------------------------------------------------------------------------------
function GetSubjectInfoSwift(const SID: Integer; const bRUS: Boolean = False; const IsFullAddress: Boolean = False): SubjectSWIFTInfo;
begin
  FillChar(Result, SizeOf(Result), 0);
  with Result do begin
    if (SID>0) then begin
      try
        with GetSubjectInfo(SID) do begin
          Result.siINN := INN;
          Result.siUNN := UNN;
          Result.siSWIFT := SWIFT;
          Result.siBIC := BIC;
          Result.siCorrAcc := CorrAcc;
          if (bRUS) then begin
            if (SubjectName>'') then Result.siName := SubjectName
            else if (InternationalName>'') then Result.siName := InternationalName;
            if (Domicile>'') then begin
              Result.siAddr := Domicile;
              if IsFullAddress then Result.siAddr := Result.siAddr + ' ' + DomicileExt;
            end else if (InternationalDomicile>'') then begin
              Result.siAddr := InternationalDomicile;
              if IsFullAddress then begin
                Result.siAddr := Result.siAddr + ' ' + InternationalDomicileExt;
              end;
            end;
          end else begin
            if (InternationalName>'') then Result.siName := InternationalName
            else if (SubjectName>'') then Result.siName := SubjectName;
            if (InternationalDomicile>'') then begin
              Result.siAddr := InternationalDomicile;
              if IsFullAddress then Result.siAddr := Result.siAddr + ' ' + InternationalDomicileExt;
            end else if (Domicile>'') then begin
              Result.siAddr := Domicile;
              if IsFullAddress then begin
                Result.siAddr := Result.siAddr + ' ' + DomicileExt;
              end;
            end;
          end;
        end;
      except
      end;
    end;
  end;
end;

// ���������� ���������� � �������
function GetClientInfoSwift(const CLID: Integer; const bRUS: Boolean = False; const IsFullAddress: Boolean = False): SubjectSWIFTInfo;
begin
  FillChar(Result, SizeOf(Result), 0);
  with Result do begin
    if (CLID>0) then begin
      with GetClientInfo(CLID) do begin
        Result.siSWIFT := '';
        Result.siBIC := '';
        Result.siCorrAcc := '';
        Result.siINN := INN;
        Result.siUNN := UNN;
        if (bRUS) then begin
          if (SWIFT_RusName>'') then      Result.siName := SWIFT_RusName
          else if (SWIFT_Name>'') then    Result.siName := SWIFT_Name
          else  if (ShortName>'') then    Result.siName := ShortName
          else                            Result.siName := Name;
          if (SWIFT_RusAddress>'') then   Result.siAddr := SWIFT_RusAddress
          else if (SWIFT_Address>'') then Result.siAddr := SWIFT_Address
          else                            Result.siAddr := Address;
        end else begin
          if (SWIFT_Name>'') then         Result.siName := SWIFT_Name
          else if (SWIFT_RusName>'') then Result.siName := SWIFT_RusName
          else  if (ShortName>'') then    Result.siName := ShortName
          else                            Result.siName := Name;
          if (SWIFT_Address>'') then      Result.siAddr := SWIFT_Address
          else if (SWIFT_RusAddress>'') then Result.siAddr := SWIFT_RusAddress
          else                            Result.siAddr := Address;
        end;
      end;
    end;
  end;
end;

function GetFAccInfo(const Acc: String; const Curr: Integer; const B: String = ''; const S: String=''): FAccInfo;
begin
  FillChar(Result, SizeOf(Result), 0);
  if (Acc='') then Exit;
  if (Curr=0) then Exit;
  with TMyQuery.Create(nil) do try
    SQL.Text:=
        'select PR.*, CR.ISO, CR.CURRNAME '
       +'from VPAYMENTREQS PR, CURRENCIES CR '
       +'WHERE PR.CURRID=CR.CURRID and PR.ACC=:ACC and PR.CURRID=:CURR';
    if (B<>'') and (S<>'') then begin
      SQL.Add(' and PR.BIC=:BIC and PR.SWIFT=:SWIFT');
      ParamByName('BIC').AsString:=B;
      ParamByName('SWIFT').AsString:=S;
    end;
    ParamByName('ACC').AsString:=Acc;
    ParamByName('CURR').AsInteger:=Curr;
    Active:=True;
    if not(EOF) then begin
      with Result do begin
        Acc:=Acc;
        AccCurr:=Curr;
        PayID:=FieldByName('PAYREQID').AsInteger;
        BIC_Code:=FieldByName('BIC').AsString;
        Swift_Code:=FieldByName('SWIFT').AsString;
        Address:=FieldByName('ADDRESS').AsString;
        BankName:=FieldByName('BANKNAME').AsString;
      end;
    end else begin
      raise ENoRecordFound.Create(Format('AccInfoById: ������� ���� �� ������ (%s %d).', [Acc, Curr]));
    end;
  finally
    Free;
  end;
end;

function GetAccInfo(const cAcc: String; const Curr: Integer; const BICCode: String; const SwiftCode: String): FAccInfo;
begin
  try
    with GetFAccInfo(cAcc, Curr, BICCode, SwiftCode) do begin
      Result.Acc := cAcc;
      Result.AccCurr := Curr;
      Result.BIC_Code := BICCode;
      Result.Swift_Code := SwiftCode;
      Result.Address := Address;
      Result.BankName := BankName;
    end;
  except
    on E: ENoRecordFound do begin
      with LocalAccInfo(cAcc, Curr, 1) do begin
        Result.Acc := Copy(cAcc, 1, 4)+' '+Copy(cAcc,5, Length(cAcc)-5)+' '+Copy(cAcc,Length(cAcc),1);
        Result.AccCurr := Curr;
        Result.BIC_Code := CurrContext.GetVal(['REGISTRY','COMMON','BANK','BANKID']);
        Result.Swift_Code := SwiftCode;
        with GetSubjectInfo(1) do begin
          Result.BankName := SubjectName;
          Result.Address :=  Domicile;
        end;
        if (Result.BankName='') then Result.BankName := CurrContext.GetVal(['REGISTRY','COMMON','BANK','BANKNAME']);
        if (Result.Address='') then Result.Address :=  CurrContext.GetVal(['REGISTRY','COMMON','BANK','ADDRESS']);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ���������� True ���� ���������� ������� STP
function GetSTPforBIC(const sBIC: String): Boolean;
begin
  if (sBIC>'') then begin
    with TMyQuery.Create(nil) do try
      SQL.Text := Format(
         'select nvl(to_number(Is_SWIFT_STP.AttrValue),0) as "Is_SWIFT_STP"'+
         '  from SUBJFINANCEREQS S,'+
         '       (select SubjectID, AttrValue from PaySysNAttrs where (AttrRefID = ''STP'') and (PaySys=2)) Is_SWIFT_STP'+
         ' where S.BIC = ''%s'''+
         '   and Is_SWIFT_STP.SubjectID(+) = S.SUBJECTID',[sBIC]);
      Active := True;
      Result:=(Fields[0].AsInteger=1);
    finally
      Free;
    end;
  end else begin
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
// ���������� True ���� ���������� ������� STP
function GetSTPforSWIFT(const sSWIFT: String): Boolean;
begin
  if (sSWIFT>'') then begin
    with TMyQuery.Create(nil) do try
      SQL.Text := Format(
         'select nvl(to_number(Is_SWIFT_STP.AttrValue),0) as "Is_SWIFT_STP"'+
         '  from SUBJFINANCEREQS S,'+
         '       (select SubjectID, AttrValue from PaySysNAttrs where (AttrRefID = ''STP'') and (PaySys=2)) Is_SWIFT_STP'+
         ' where S.SWIFTCODE = ''%s'''+
         '   and Is_SWIFT_STP.SubjectID(+) = S.SUBJECTID',[sSWIFT]);
      Active := True;
      Result:=(Fields[0].AsInteger=1);
    finally
      Free;
    end;
  end else begin
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
// ���������� True ���� ���������� ������� BKE
function GetBKEforBIC(const sBIC: String): Boolean;
begin
  if (sBIC>'') then begin
    with TMyQuery.Create(nil) do try
      SQL.Text := Format(
         'select nvl(to_number(Is_SWIFT_BKE.AttrValue),0) as "Is_SWIFT_BKE"'+
         '  from SUBJFINANCEREQS S,'+
         '       (select SubjectID, AttrValue from PaySysNAttrs where (AttrRefID = ''BKE'') and (PaySys=2)) Is_SWIFT_BKE'+
         ' where S.BIC = ''%s'''+
         '   and Is_SWIFT_BKE.SubjectID(+) = S.SUBJECTID',[sBIC]);
      Active := True;
      Result:=(Fields[0].AsInteger=1);
    finally
      Free;
    end;
  end else begin
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
// ���������� True ���� ���������� ������� BKE
function GetBKEforSWIFT(const sSWIFT: String): Boolean;
begin
  if (sSWIFT>'') then begin
    with TMyQuery.Create(nil) do try
      SQL.Text := Format(
         'select nvl(to_number(Is_SWIFT_BKE.AttrValue),0) as "Is_SWIFT_BKE"'+
         '  from SUBJFINANCEREQS S,'+
         '       (select SubjectID, AttrValue from PaySysNAttrs where (AttrRefID = ''BKE'') and (PaySys=2)) Is_SWIFT_BKE'+
         ' where S.SWIFTCODE = ''%s'''+
         '   and Is_SWIFT_BKE.SubjectID(+) = S.SUBJECTID',[sSWIFT]);
      Active := True;
      Result:=(Fields[0].AsInteger=1);
    finally
      Free;
    end;
  end else begin
    Result := False;
  end;
end;

//���������� ��� ����������� �������
function GetClearingCode(const sBIC: String): String;
 const
   aClearingCode: array[0..9] of String = ('RU','AT','AU','BL','CC','ES','IT','NZ','PT','SW');
 var
   i: Integer;
   bClearingCode: Boolean;
begin
  bClearingCode := False;
  for i:=0 to High(aClearingCode) do begin
    if (Copy(sBIC,1,2)=aClearingCode[i]) then begin
      bClearingCode := True;
      break;
    end;
  end;
  if not (bClearingCode) then begin
    try
      i := GetSubjectBicInfo(sBIC).StateID;
    except
      i := 0;
    end;
    if (i>0) then begin
      with TMyQuery.Create(nil) do try
        SQL.Text := Format('select CLEARINGSYSCODE from STATES where STATEID=%d',[i]);
        Active:=True;
        if not(EOF) then begin
          Result := Fields[0].AsString;
        end;
      finally
        Free;
      end;
    end;
  end;
end;
*)
// ���������� True ���� SWIFT ��� ��������� �����������
function ValidateSWIFT(aSWIFT: String): Boolean;
begin
  Result := True;
end;
(*
//����������� �������� �� �������� � ��������
function IsCorrAccIDForAtrRefID(const iAccId: Integer; const sRefid: String): Boolean;
begin
  Result := False;
  if (iAccId=0) then Exit;
  if (sRefid='') then Exit;
  with TMyQuery.Create(nil) do try
    SQL.Text:=
       'select max(T.CONFORMATTRVALUE) from ACC2ACCCONFORMATTRS T, ACC2ACCCONFORMITIES A '
      +'where A.ACCID=:ACCID and A.ACC2ACCCONFID=T.ACC2ACCCONFID and T.ACCATTRREFID=:REFID';
    ParamByName('ACCID').AsInteger:=iAccId;
    ParamByName('REFID').AsString:=sRefid;
    Active:=True;
    Result:=(Trim(Fields[0].AsString)='1');
  finally
    Free;
  end
end;

function GetIsFullAddrr(const iAccID: Integer): Boolean;
begin
  Result := False;
  if (iAccId=0) then Exit;
  with TMyQuery.Create(nil) do try
    SQL.Text:=
       'select A.ATTRVALUE '
      +'from SUBJECTS S, SUBJSATTRS A, ACCOUNTS T, SUBJ2CLIENTLINKS L '
      +'where S.SUBJECTID=A.SUBJECTID and A.ATTRREFID=''APPLYTHEFULLADDRESS'''
      +'  and T.ACCID=:ACCID and T.CLIENTID=L.CLIENTID and L.SUBJECTID=S.SUBJECTID';
    ParamByName('ACCID').AsInteger:=iAccId;
    Active:=True;
    Result:=(Trim(Fields[0].AsString)='1');
  finally
    Free;
  end
end;

procedure LinkParentEntities(aEntID: Integer; aSwiftMsgEntID: Integer; aActID: Integer);
const
  SQLText =
    'insert into ENTITIES_E2E '#13#10 +
    '  select E2E.TOPENTITYID, '#13#10 +
    '         :NewEntID, '#13#10 +
    '         :ActID, '#13#10 +
    '         :LinkKindID, '#13#10 +
    '         SEQENTLINKID.NEXTVAL '#13#10 +
    '    from ENTITIES_E2E E2E, ENTITIES E '#13#10 +
    '   where E2E.SUBENTITYID = :EntID '#13#10 +
    '     and E.ENTITYID = E2E.TOPENTITYID '#13#10 +
    '     and E.ENTREFID not like ''70%'' '#13#10 +
    '     and not exists (select 1 from ENTITIES_E2E E2E2  '#13#10 +
    '                             where E2E2.TOPENTITYID = E2E.TOPENTITYID  '#13#10 +
    '                               and E2E2.SUBENTITYID = :NewEntID '#13#10 +
    '                               and E2E2.LINKKIND = :LinkKindID)';
  SQLExtension =
    '     and exists (select 1 from ENTITIES E2 '#13#10 +
    '                         where E2.ENTITYID = :NewEntID '#13#10 +
    '                           and E2.ENTREFID like ''70%'')';
begin
  with TMyQuery.Create() do try
    // ����� ����� aSwiftMsgEntID(sub) � ��������� aEntID(top)
    ExecQuery(SQLText, [aSwiftMsgEntID, aActID, cMessagesLinkKind, aEntID]);
    // ����� ����� aEntID(sub) � ��������� aSwiftMsgEntID(top)
    ExecQuery(SQLText + SQLExtension, [aEntID, aActID, cMessagesLinkKind, aSwiftMsgEntID]);
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------
function GetRegUserID: Integer;
begin
  Result := CurrContext.GetValDef(['CFG', 'USERID'], 0);
end;

//------------------------------------------------------------------------------
function GetRegFuncID: Integer;
begin
  Result := CurrContext.GetValDef(['CFG', 'FUNCID'], 0);
end;
*)
////////////////////////////////////////////////////////////////////////////////
{ TSWIFTBuilder }

procedure TSWIFTBuilder.AfterConstruction;
begin
  inherited;
  FMaxLineLength := 35;
end;

function TSWIFTBuilder.AppendSWIFTLine(const aValue: string): TSWIFTBuilder;
begin
  Append(WrapText(aValue, FMaxLineLength));
  AppendLine;
  Result := Self;
end;

function TSWIFTBuilder.AppendLineFmt(const aValue: string;
  const Args: array of const): TSWIFTBuilder;
begin
  AppendLine(SysUtils.Format(aValue, Args));
  Result := Self;
end;

function TSWIFTBuilder.AppendSWIFTLine(const aValue: string;
  const Args: array of const): TSWIFTBuilder;
begin
  AppendSWIFTLine(SysUtils.Format(aValue, Args));
  Result := Self;
end;


function StrRightPad(const str: String; ForceLength: Integer; const strPad: String): String;
begin
  Result:=str;
  while (Length(Result) < ForceLength) do
    Result:=Result+strPad;
  Delete(Result, ForceLength+1, Length(Result)-ForceLength);
end;


function iff(expr: Boolean; Val1, Val2: Variant): Variant;
begin
  if expr then
    Result := Val1
  else
    Result := Val2;
end;

function IsSWIFTPermissible(const str: String; out strError: String): Boolean;
  var i: Integer;
begin
 Result:=False;
 for i:=1 to Length(str) do begin
   if not (str[i] in SWIFTPermissible) then begin
     Result:=True;
     strError := strError + str[i];
   end;
 end;
end;


end.////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

