' =============================================================================
' fusion_place Excel-Link  名前定義 関連ソース抜粋
' =============================================================================
' 本ファイルは、Excel-Link がシート設定をローカル「名前」へ保存・復元する
' 処理に直接関係する 4 モジュールを抜粋したものです。
' （Loader / Saver / PERSISTENCE / KeyAssignment）
'
' 添付の名前定義リファレンス（excel_link/excel_link_named_ranges.md）の一次的な根拠として、
' またAIがExcel-Linkシートを生成・解読する際の参照用として提供します。
'
' 注意:
'  - これは Excel-Link 全体のごく一部であり、サーバ通信・認証等は含みません。
'  - 記述内容は将来変更される可能性があり、互換性は保証されません。
'  - フュージョンズが保証する安定仕様ではありません。
' =============================================================================

' ===========================================================================
' Module: PERSISTENCE (標準モジュール)
' ===========================================================================
Option Private Module
Option Explicit

Private Const FP_PREFIX = "FUSIONPLACE"

Public Const LABEL_PASSWORD = "SPELL"
Public Const LABEL_RETRIEVAL_DATE_TIME_RANGE = "RETRIEVALDATETIMERANGE"
Public Const LABEL_MAX_REFLECTION_COUNT_RANGE = "MAXREFLECTIONCOUNTRANGE"
Public Const LABEL_REFLECTION_CHECK_RANGE = "REFLECTIONCHECKRANGE"
Public Const LABEL_VALIDATION_ENABLED = "VALIDATIONENABLED"


Public Const LABEL_ZERO_AS_BLANK = "ZEROASBLANK"

Public Const LABEL_KEYITR = "KEYITR"
Public Const LABEL_TEMPLATE_RANGE = "TEMPLATERANGE"
Public Const LABEL_SEQ_CELL = "SEQCELL"

Public Const LABEL_SHOW_ALL_COMBIBATIONS_CELL = "SHOWALLCOMBIBATIONSCELL"

Public Const LABEL_FILTERING_CELL = "FILTERINGCELL"
Public Const LABEL_IS_FORMULA_TO_PASTE = "ISFORMULATOPASTE"
Public Const LABEL_IS_FORMAT_TO_PASTE = "ISFORMATTOPASTE"
Public Const LABEL_IS_DATA_VALIDATION_TO_PASTE = "ISDATAVALIDATIONTOPASTE"
Public Const LABEL_ENABLE_SWITCH_LOCK = "ENABLESWITCHLOCK"
Public Const LABEL_AUTOFILTER = "AUTOFILTER"

Public Const LABEL_RESULT_AREA_PREV_ROW = "RESULTAREAPREVROW"
Public Const LABEL_TEMPLATE_PROCESSING_SUPPRESSED = "TPSUPPRESSED"
Public Const LABEL_RB = "RB"
Public Const LABEL_RB_DIM = "RBDIM"
Public Const LABEL_RB_KEY_COL = "RBKEYCOL"
Public Const LABEL_RB_MEMLIST = "RBMEMLIST"

Public Const LABEL_RB_PEGMEMRANGE = "RBPEGMEMRANGE"

Public Const LABEL_REGION_NAME = "REGIONNAME"
Public Const LABEL_RANGE = "RANGE"

Public Const LABEL_APP_LABEL_RANGE = "APPLABELRANGE"

Public Const LABEL_PARTICIPANT_LABEL_RANGE = "PARTICIPANTLABELRANGE"

Public Const LABEL_EDITION_KEY_RANGE = "EDITIONKEYRANGE"


Public Const LABEL_REGION_TYPE = "REGIONTYPE"

Public Const LABEL_UNIT_RANGE = "UNITRANGE"


Public Const LABEL_LEDGER_LABEL = "LEDGERLABEL"
Public Const LABEL_APPLICABLE_ACTION = "APPLICABLEACTION"
Public Const LABEL_ROUNDING = "ROUNDING"
Public Const LABEL_IGNORED_IN_DATA_EXISTENCE_JDGMNT = "IGNOREDDEJDGMNT"
Public Const LABEL_RAISE_ERROR_IF_CELL_TO_UPDATE_IS_CLOSED = "RAISEERIFCLOSED"
Public Const LABEL_DATATYPE_CHECK_ENABLED = "TYPECHKENABLD"
Public Const LABEL_ENUM_DESCRIPTIVE = "ENUMDESCRIPTIVE"
Public Const LABEL_TO_CONVERT_DATETIME_TEXT = "TOCONVERTDATETIMETEXT"
Public Const LABEL_SIGN = "SIGN"
Public Const LABEL_DECIMAL_PLACES = "DECIMALPLACES"
Public Const LABEL_SWITCH_CELL_LOCKING = "SWITCHCELLLOCKING"

Public Const LABEL_LOCKED_COLOR_RANGE = "LOCKEDCOLORRANGE"

Public Const LABEL_DIMENSION = "DIMENSION"
Public Const LABEL_TEXT_FORMULA = "TEXTFORMULA"

Public Const LABEL_KB = "KB"
Public Const LABEL_KEY_DIM = "KEYDIM"
Public Const LABEL_KEY_RANGE = "KEYRANGE"

Public Const NAME_VISIBILITY = False

Public Type DelimitedNameType
    SheetName As String
    Words() As String
End Type

Function ModifiedPrefix(Sheet As Worksheet) As String
    ModifiedPrefix = "'" & ToInternalSheetName(Sheet.name) & "'!_" & FP_PREFIX & "_"
End Function


Function RangePrefix(RegionDef As RegionDef, RangeSeq As Integer) As String
    RangePrefix = ModifiedPrefix(RegionDef.Worksheet) & Format(RangeSeq, "000") & "_"
End Function

Function KeyAssignmentPrefix(RangePrefix As String, KeyAssignmentSeq As Integer) As String
    KeyAssignmentPrefix = RangePrefix & LABEL_KB & "_" & ToSeqString(KeyAssignmentSeq) & "_"
End Function

Function ToSeqString(Seq As Integer) As String
    ToSeqString = Format(Seq, "000")
End Function

Function LoadPassword(Sheet As Worksheet) As String
    Dim Encoded As String
    Encoded = TruncatemPreceedingSingleQuote(LoadSheetAttribute(Sheet, LABEL_PASSWORD))
    Encoded = AppendMissingZeroes(Encoded)
    LoadPassword = Decode(Encoded)
End Function

'シートを保護解除する。
'返り値：シートが保護されていた場合、True、保護されていなければ、False
Function UnprotectSheet(Sheet As Worksheet) As Boolean
    On Error GoTo ERR_HANDLER

    UnprotectSheet = Sheet.ProtectContents
    If UnprotectSheet Then
        Sheet.Unprotect Password:=LoadPassword(Sheet)
    End If
    Exit Function
    
ERR_HANDLER:
    RaiseErr ERROR_SHEET_UNPROTECTABLE, Sheet.name
End Function


Sub SavePassword(Sheet As Worksheet, Password As String)
    Dim Encoded As String
    
    TryUnprotectSheet Sheet:=Sheet, Password:=LoadPassword(Sheet)
    RemoveSheetAttributeIfExists Sheet, LABEL_PASSWORD
    If Password <> "" Then
        Encoded = Encode(Password)
        SaveSheetAttribute Sheet, LABEL_PASSWORD, "'" & Encoded
    End If
    COMMONS.ProtectSheet Sheet, Password
End Sub

Private Sub TryUnprotectSheet(Sheet As Worksheet, Password As String)
    On Error GoTo ERR_TRAP
    Sheet.Unprotect Password:=Password
    
    Exit Sub

ERR_TRAP:
    RaiseErr ERROR_CANNOT_CHANGE_PW_BECAUSE_SHEET_IS_PROTECTED_BY_USER
End Sub

Private Function AppendMissingZeroes(s As String) As String
    Dim result  As String
    result = s
    '一文字=2バイト(s では4文字で表現）または4バイト であるため、s は 4 で割り切れないといけない。
    '割り切れない場合は末尾の zero が欠けているとみて、追加する。
    Do Until (Len(result) Mod 4 = 0)
        result = "0" & result
    Loop
    AppendMissingZeroes = result
End Function

Sub SaveValue(Sheet As Worksheet, EntryName As String, aValue As Variant)
    Sheet.Names.add name:=EntryName, RefersTo:=aValue, Visible:=NAME_VISIBILITY, NameLocal:=True
End Sub

Sub SaveString(Sheet As Worksheet, EntryName As String, aString As String)
    Dim SavedString     As String
    
    If IsNull(aString) Or aString = "" Then Exit Sub
    SavedString = "=""" & Replace(aString, """", """""") & """"
    
    Sheet.Names.add name:=EntryName, RefersTo:=SavedString, Visible:=NAME_VISIBILITY, NameLocal:=True
End Sub

Sub SaveRange(Sheet As Worksheet, EntryName As String, aRange As Range)
    If aRange Is Nothing Then Exit Sub
    Sheet.Names.add name:=EntryName, RefersTo:=aRange, Visible:=NAME_VISIBILITY, NameLocal:=True
End Sub


Sub SaveCell(Sheet As Worksheet, EntryName As String, aCell As Range)
    If aCell Is Nothing Then Exit Sub
    Sheet.Names.add name:=EntryName & "COL", RefersTo:=aCell.EntireColumn, Visible:=NAME_VISIBILITY, NameLocal:=True
    Sheet.Names.add name:=EntryName & "ROW", RefersTo:=aCell.EntireRow, Visible:=NAME_VISIBILITY, NameLocal:=True
End Sub

Private Function LoadSheetAttribute(Sheet As Worksheet, AttributeLabel As String) As String
    Dim name                As name
    Dim WorkingSheet        As Worksheet
    Dim WorkingCell         As Range
    
    Set name = GetSheetAttributeName(Sheet, AttributeLabel)
    If name Is Nothing Then
        LoadSheetAttribute = ""
    Else
        LoadSheetAttribute = GetStringValue(name)
    End If

End Function

Private Function GetSheetAttributeName(Sheet As Worksheet, AttributeLabel As String) As name
    Dim name                As name
    Dim SheetName           As String
    Dim DelimitedName       As DelimitedNameType
    
    SheetName = ToInternalSheetName(Sheet.name)
    
    Set GetSheetAttributeName = Nothing
    For Each name In Sheet.Names
        DelimitedName = Delimit(name.name)
        If IsFpName(DelimitedName, SheetName) Then
            If DelimitedName.Words(1) = AttributeLabel Then
                Set GetSheetAttributeName = name
                Exit For
            End If
        End If
    Next
    
End Function

Function ToInternalSheetName(SheetName As String) As String
    ToInternalSheetName = Replace(SheetName, "'", "''")
End Function

Function Delimit(name As String) As DelimitedNameType
    Dim Position        As Long
    Dim Rest            As String
    
    Position = InStr(name, "!")
    If Position > 0 Then
        Delimit.SheetName = Left(name, Position - 1)
        '
        ' Sheet name may be enclosed in single quotes.
        '
        If Left(Delimit.SheetName, 1) = "'" And Right(Delimit.SheetName, 1) = "'" Then
            Delimit.SheetName = Mid(Delimit.SheetName, 2, Len(Delimit.SheetName) - 2)
        End If
        Rest = Mid(name, Position + 1)
    Else
        Delimit.SheetName = ""
        Rest = name
    End If
    If Len(Rest) >= 1 Then
        If Left(Rest, 1) = "_" Then
            Rest = Mid(Rest, 2)
        End If
    End If
    Delimit.Words = Split(Rest, "_")
    
End Function



Private Function Encode(strText As String) As String
    Encode = Reverse(ToUTF16LEHexString(strText))
End Function

Private Function Decode(strText As String) As String
    Decode = FromUTF16LEHexString(Reverse(strText))
End Function


Function IsFpName(DelimitedName As DelimitedNameType, SheetName As String) As Boolean
    If DelimitedName.SheetName <> SheetName Or UBound(DelimitedName.Words) < 0 Then
        IsFpName = False
        Exit Function
    End If
    If DelimitedName.Words(0) <> FP_PREFIX Then
        IsFpName = False
        Exit Function
    End If
    IsFpName = True
    
End Function


Private Sub RemoveSheetAttributeIfExists(Sheet As Worksheet, AttributeLabel As String)
    Dim name                As name
    Dim DelimitedName       As DelimitedNameType
    
    
    For Each name In Sheet.Names
        DelimitedName = Delimit(name.name)
        If IsFpName(DelimitedName, Sheet.name) Then
            If DelimitedName.Words(1) = AttributeLabel Or _
               DelimitedName.Words(1) = AttributeLabel & "COL" Or _
               DelimitedName.Words(1) = AttributeLabel & "ROW" Then
                name.Delete
                'Exit For
            End If
        End If
    Next
    
End Sub

Function LoadSheetAttributeCell(Sheet As Worksheet, AttributeLabel As String) As Range
    Dim name                As name
    Dim Column              As Range
    Dim Row                 As Range
    
    Set LoadSheetAttributeCell = Nothing
    Set name = GetSheetAttributeName(Sheet, AttributeLabel)
    If Not (name Is Nothing) Then
        Set LoadSheetAttributeCell = GetAnchoringCell(GetRefersToRangeSafely(name))
        Exit Function
    End If
    
    Set name = GetSheetAttributeName(Sheet, AttributeLabel & "COL")
    If name Is Nothing Then Exit Function

    Set Column = GetRefersToRangeSafely(name)
    If Column Is Nothing Then Exit Function
    
    Set name = GetSheetAttributeName(Sheet, AttributeLabel & "ROW")
    If name Is Nothing Then Exit Function
    
    Set Row = GetRefersToRangeSafely(name)
    If Row Is Nothing Then Exit Function
    
    Set LoadSheetAttributeCell = Intersect(Column, Row)
        
End Function

Private Sub SaveSheetAttributeCell(Sheet As Worksheet, AttributeLabel As String, aCell As Range)
    SaveSheetAttribute Sheet, AttributeLabel & "COL", aCell.EntireColumn
    SaveSheetAttribute Sheet, AttributeLabel & "ROW", aCell.EntireRow
End Sub

Private Sub SaveSheetAttribute(Sheet As Worksheet, AttributeLabel As String, value As Variant)
    Sheet.Names.add name:=ModifiedPrefix(Sheet) & AttributeLabel, RefersTo:=value, Visible:=NAME_VISIBILITY, NameLocal:=True
End Sub


-------------------------------------------------------------------------------

' ===========================================================================
' Module: Saver (クラスモジュール)
' ===========================================================================
Option Explicit

Implements IVisitor
Public server               As IServer
Private MySheetDef          As SheetDef
Private Sheet               As Worksheet
Private Names               As Names
Private RangeSeq            As Integer
Private RangePrefix         As String
Private KeyAssignmentSeq       As Integer
Private KeyAssignmentPrefix    As String
Private Dimensions          As Collection
Private PrevApplicationLabel    As String
Private RowBindingSeq       As Integer
Private SheetPrefix         As String
Private KeyIterationPrefix  As String


Private Sub IVisitor_EnterSheetDefs(SheetDefs As SheetDefs)
    PrevApplicationLabel = ""
    Set Dimensions = Nothing
End Sub


Private Sub IVisitor_ExitSheetDefs(SheetDefs As SheetDefs)
    
End Sub

Private Sub IVisitor_EnterSheetDef(SheetDef As SheetDef)
    Dim name                As name
    Dim Type1               As String
    Dim SheetName           As String
    Dim DelimitedName       As DelimitedNameType
    
    Set MySheetDef = SheetDef
    Set Sheet = SheetDef.Worksheet
    Set Names = Sheet.Names
    SheetName = PERSISTENCE.ToInternalSheetName(SheetDef.Worksheet.name)
    
    For Each name In Names
        DelimitedName = PERSISTENCE.Delimit(name.name)
        If PERSISTENCE.IsFpName(DelimitedName, SheetName) Then
            name.Delete
        End If
    Next
    
    SheetPrefix = PERSISTENCE.ModifiedPrefix(Sheet)
    
    If VarType(SheetDef.Password) = vbString Then
        SaveValue Sheet, SheetPrefix & LABEL_PASSWORD, SheetDef.Password
    End If
    SaveCell Sheet, SheetPrefix & LABEL_RETRIEVAL_DATE_TIME_RANGE, SheetDef.RetrievalDateTimeCell
    SaveValue Sheet, SheetPrefix & LABEL_ZERO_AS_BLANK, SheetDef.ZeroAsBlank
    SaveCell Sheet, SheetPrefix & LABEL_MAX_REFLECTION_COUNT_RANGE, SheetDef.MaxReflectionCountCell
    SaveRange Sheet, SheetPrefix & LABEL_REFLECTION_CHECK_RANGE, SheetDef.ReflectionCheckRange
    SaveValue Sheet, SheetPrefix & LABEL_VALIDATION_ENABLED, SheetDef.IsValidationEnabled
    
    
    RangeSeq = 0
    RowBindingSeq = 0
    
    KeyIterationPrefix = SheetPrefix & LABEL_KEYITR & "_"
    
    SaveCell Sheet, KeyIterationPrefix & LABEL_APP_LABEL_RANGE, SheetDef.ApplicationLabelRange
    
    SaveRange Sheet, KeyIterationPrefix & LABEL_TEMPLATE_RANGE, SheetDef.TemplateRange
    
    SaveCell Sheet, KeyIterationPrefix & LABEL_SEQ_CELL, SheetDef.SequenceCell
    SaveCell Sheet, KeyIterationPrefix & LABEL_FILTERING_CELL, SheetDef.FilteringCell
    
    SaveCell Sheet, KeyIterationPrefix & LABEL_SHOW_ALL_COMBIBATIONS_CELL, SheetDef.ShowAllCombinationsCell
  
    SaveValue Sheet, KeyIterationPrefix & LABEL_IS_FORMULA_TO_PASTE, SheetDef.IsFormulaToPaste
    SaveValue Sheet, KeyIterationPrefix & LABEL_IS_FORMAT_TO_PASTE, SheetDef.IsFormatToPaste
    SaveValue Sheet, KeyIterationPrefix & LABEL_IS_DATA_VALIDATION_TO_PASTE, SheetDef.IsDataValidationToPaste
    SaveValue Sheet, KeyIterationPrefix & LABEL_ENABLE_SWITCH_LOCK, SheetDef.EnableSwitchLock
    SaveValue Sheet, KeyIterationPrefix & LABEL_AUTOFILTER, SheetDef.AutoFilter
    
    SaveRange Sheet, KeyIterationPrefix & LABEL_RESULT_AREA_PREV_ROW, SheetDef.ResultAreaPrevRow
    
    SaveValue Sheet, KeyIterationPrefix & LABEL_TEMPLATE_PROCESSING_SUPPRESSED, SheetDef.IsTemplateProcessingSuppressed
    
End Sub


Private Sub IVisitor_EnterRowBinding(RowBinding As RowBinding)
    Dim Prefix              As String
    
    RowBindingSeq = RowBindingSeq + 1
    Prefix = KeyIterationPrefix & LABEL_RB & "_" & Format(RowBindingSeq, "000") & "_"
    SaveString Sheet, Prefix & LABEL_RB_DIM, RowBinding.DimensionLabel
    SaveRange Sheet, Prefix & LABEL_RB_KEY_COL, RowBinding.KeyColumn
    SaveString Sheet, Prefix & LABEL_RB_MEMLIST, RowBinding.MemberListLabel
    SaveCell Sheet, Prefix & LABEL_RB_PEGMEMRANGE, RowBinding.PegMemberLabelRange
End Sub

Private Sub IVisitor_ExitRowBinding(RowBinding As RowBinding)

End Sub


Private Sub IVisitor_ExitSheetDef(SheetDef As SheetDef)

End Sub


Private Sub IVisitor_EnterRegionDef(RegionDef As RegionDef)
    Dim HexExpressions  As Variant
    Dim Seq             As Integer
    
    SetDimensions RegionDef.ApplicationLabel
    
    RangeSeq = RangeSeq + 1
    
    RangePrefix = PERSISTENCE.RangePrefix(RegionDef, RangeSeq)
    
    SaveValue Sheet, RangePrefix & LABEL_REGION_NAME, RegionDef.RegionName
    
    SaveRange Sheet, RangePrefix & LABEL_RANGE, RegionDef.Range
    SaveCell Sheet, RangePrefix & LABEL_APP_LABEL_RANGE, RegionDef.ApplicationLabelRange
    SaveCell Sheet, RangePrefix & LABEL_PARTICIPANT_LABEL_RANGE, RegionDef.ParticipantLabelRange
    SaveCell Sheet, RangePrefix & LABEL_EDITION_KEY_RANGE, RegionDef.EditionKeyRange
    
    SaveValue Sheet, RangePrefix & LABEL_REGION_TYPE, RegionDef.RegionType
    
    SaveCell Sheet, RangePrefix & LABEL_UNIT_RANGE, RegionDef.UnitRange
    
    SaveString Sheet, RangePrefix & LABEL_LEDGER_LABEL, RegionDef.LedgerLabel
    
    SaveValue Sheet, RangePrefix & LABEL_APPLICABLE_ACTION, RegionDef.ApplicableAction
    SaveValue Sheet, RangePrefix & LABEL_ROUNDING, RegionDef.Rounding
    SaveValue Sheet, RangePrefix & LABEL_IGNORED_IN_DATA_EXISTENCE_JDGMNT, RegionDef.IsIgnoredInDataExistenceJudgment
    SaveValue Sheet, RangePrefix & LABEL_RAISE_ERROR_IF_CELL_TO_UPDATE_IS_CLOSED, RegionDef.RaiseErrorIfCellToUpdateIsClosed
    SaveValue Sheet, RangePrefix & LABEL_DATATYPE_CHECK_ENABLED, RegionDef.IsDataTypeCheckEnabled
    SaveValue Sheet, RangePrefix & LABEL_ENUM_DESCRIPTIVE, RegionDef.IsEnumDescriptive
    SaveValue Sheet, RangePrefix & LABEL_TO_CONVERT_DATETIME_TEXT, RegionDef.IsToConvertDateTimeText
    SaveValue Sheet, RangePrefix & LABEL_SIGN, RegionDef.Sign
    SaveValue Sheet, RangePrefix & LABEL_DECIMAL_PLACES, RegionDef.DecimalPlaces
    SaveValue Sheet, RangePrefix & LABEL_SWITCH_CELL_LOCKING, RegionDef.SwitchCellLocking
    
    SaveCell Sheet, RangePrefix & LABEL_LOCKED_COLOR_RANGE, RegionDef.LockedColorRange
    
    SaveString Sheet, RangePrefix & LABEL_DIMENSION, RegionDef.DimensionLabel
    
    HexExpressions = STRING_UTIL.Divide(STRING_UTIL.ToUTF16LEHexString(RegionDef.TextExpression), 240)
    If Not IsNull(HexExpressions) Then
        For Seq = LBound(HexExpressions) To UBound(HexExpressions)
            'Seq begins from 0
            SaveString Sheet, RangePrefix & LABEL_TEXT_FORMULA & "_" & PERSISTENCE.ToSeqString(Seq + 1), CStr(HexExpressions(Seq))
        Next
    End If
    
    KeyAssignmentSeq = 0
End Sub

Private Sub SetDimensions(ApplicationLabel As String)
    On Error GoTo ERROR_TRAP
    If ApplicationLabel = PrevApplicationLabel Then Exit Sub
    PrevApplicationLabel = ApplicationLabel
    Set Dimensions = server.GetDimensions(PrevApplicationLabel)
    Exit Sub
    
ERROR_TRAP:
    Set Dimensions = Nothing
End Sub


Private Sub IVisitor_ExitRegionDef(RegionDef As RegionDef)

End Sub



Private Sub IVisitor_EnterKeyAssignment(KeyAssignment As KeyAssignment)
    
    If KeyAssignment.Range Is Nothing Then Exit Sub
    If Not (Dimensions Is Nothing) Then
        If FindByLabel(KeyAssignment.DimensionLabel, Dimensions) Is Nothing Then
            Exit Sub
        End If
    End If
    KeyAssignmentSeq = KeyAssignmentSeq + 1
    KeyAssignmentPrefix = PERSISTENCE.KeyAssignmentPrefix(RangePrefix, KeyAssignmentSeq)
    
    SaveString Sheet, KeyAssignmentPrefix & LABEL_KEY_DIM, KeyAssignment.DimensionLabel
    SaveRange Sheet, KeyAssignmentPrefix & LABEL_KEY_RANGE, KeyAssignment.Range

End Sub

Private Sub IVisitor_ExitKeyAssignment(KeyAssignment As KeyAssignment)
    
End Sub


-------------------------------------------------------------------------------

' ===========================================================================
' Module: Loader (クラスモジュール)
' ===========================================================================
Option Explicit
Option Base 0

Private MySheetDef                  As SheetDef
Private SheetName                   As String
Private Names                       As Names
Private RegionDefsBySeq             As New Collection
Private KeyAssignmentsBySeq         As New Collection
Private RowBindingsBySeq            As New Collection
Private HexExpressionPartColsBySeq     As New Collection


Public Sub Load(SheetDef As SheetDef)
    Dim UiSuppressor            As New UiSuppressor
    Dim name                    As name
    Dim Type1                   As String
    Dim DelimitedName       As DelimitedNameType
    Dim RegionDef           As RegionDef
    Dim i                       As Integer
    Dim j                       As Integer
    Dim HexExpressionPartCol    As Collection
    Dim RegionSeq               As String
    Dim HexExpression           As String
    
    UiSuppressor.Begin
    
    On Error GoTo WRAP_UP
    
    Set MySheetDef = SheetDef
    
    SheetName = PERSISTENCE.ToInternalSheetName(SheetDef.Worksheet.name)
    Set Names = SheetDef.Worksheet.Names
    
    For Each name In Names
        DelimitedName = PERSISTENCE.Delimit(name.name)
        If PERSISTENCE.IsFpName(DelimitedName, SheetName) Then
            Type1 = DelimitedName.Words(1)
            If IsNumeric(Type1) Then
                ProcessRangeDef name, DelimitedName, Type1
            ElseIf Type1 = LABEL_KEYITR Then
                ProcessKeyIteartionDef name, DelimitedName
            Else
                ProcessSheetAttributes name, DelimitedName
            End If
        End If
    Next
    
    If MySheetDef.IsTemplateProcessingSheet = False And MySheetDef.IsTemplateProcessingSuppressed = False Then
        MySheetDef.EnableSwitchLock = True
    End If
    
    For i = 1 To RegionDefsBySeq.Count
        RegionSeq = PERSISTENCE.ToSeqString(i)
        Set RegionDef = RegionDefsBySeq(RegionSeq)
        Set HexExpressionPartCol = GetHexExpressionPartColBySeq(RegionSeq)
        If HexExpressionPartCol.Count > 0 Then
            HexExpression = ""
            For j = 1 To HexExpressionPartCol.Count
                HexExpression = HexExpression & HexExpressionPartCol(PERSISTENCE.ToSeqString(j))
            Next
            RegionDef.TextExpression = STRING_UTIL.FromUTF16LEHexString(HexExpression)
        End If
    Next
    
    For Each RegionDef In RegionDefsBySeq
        RegionDef.RemoveInvalidKeyAssignments
        RegionDef.ClearInvalidCells
    Next
    MySheetDef.ClearInvalidCells
    
    Set SheetDef.ReflectionPostProcessSpecSheet = GetSheet(SheetDef.Worksheet.Parent, SheetDef.Worksheet.name & "_FPCTL1")
    
    
WRAP_UP:
    UiSuppressor.Restore
    Set MySheetDef = Nothing
    Set Names = Nothing
    Set RegionDefsBySeq = Nothing
    Set KeyAssignmentsBySeq = Nothing
End Sub

Private Function GetSheet(Book As Workbook, SheetName As String) As Worksheet
    On Error GoTo ERR_HANDLER
    
    Set GetSheet = Book.Worksheets(SheetName)
    Exit Function
    
ERR_HANDLER:
    Set GetSheet = Nothing
End Function


Private Sub ProcessSheetAttributes(name As name, DelimitedName As DelimitedNameType)
    Dim Type1               As String
            
    Type1 = DelimitedName.Words(1)
    
    If Type1 = LABEL_PASSWORD Then
        MySheetDef.Password = name.value
    ElseIf Type1 = LABEL_RETRIEVAL_DATE_TIME_RANGE Then
        Set MySheetDef.RetrievalDateTimeCell = GetAnchoringCell(GetRefersToRangeSafely(name))
    ElseIf BeginsWith(Type1, LABEL_RETRIEVAL_DATE_TIME_RANGE) Then
        Set MySheetDef.RetrievalDateTimeCell = Confine(MySheetDef.RetrievalDateTimeCell, GetRefersToRangeSafely(name))
    ElseIf Type1 = LABEL_ZERO_AS_BLANK Then
        MySheetDef.ZeroAsBlank = GetBooleanValue(name)
    ElseIf Type1 = LABEL_MAX_REFLECTION_COUNT_RANGE Then
        Set MySheetDef.MaxReflectionCountCell = GetAnchoringCell(GetRefersToRangeSafely(name))
    ElseIf BeginsWith(Type1, LABEL_MAX_REFLECTION_COUNT_RANGE) Then
        Set MySheetDef.MaxReflectionCountCell = Confine(MySheetDef.MaxReflectionCountCell, GetRefersToRangeSafely(name))
    ElseIf Type1 = LABEL_REFLECTION_CHECK_RANGE Then
        Set MySheetDef.ReflectionCheckRange = GetRefersToRangeSafely(name)
    ElseIf Type1 = LABEL_VALIDATION_ENABLED Then
        MySheetDef.IsValidationEnabled = GetBooleanValue(name)
    End If

End Sub

Private Sub ProcessKeyIteartionDef(name As name, DelimitedName As DelimitedNameType)
    Dim Type2               As String
    Dim Type4               As String
    Dim RowBinding          As RowBinding
    Dim RowBindingSeq       As String
    
    Type2 = DelimitedName.Words(2)

    If Type2 = LABEL_APP_LABEL_RANGE Then
        Set MySheetDef.ApplicationLabelRange = GetAnchoringCell(GetRefersToRangeSafely(name))
    ElseIf BeginsWith(Type2, LABEL_APP_LABEL_RANGE) Then
        Set MySheetDef.ApplicationLabelRange = Confine(MySheetDef.ApplicationLabelRange, GetRefersToRangeSafely(name))
    
    ElseIf Type2 = LABEL_TEMPLATE_RANGE Then
        Set MySheetDef.TemplateRange = GetRefersToRangeSafely(name)
        
    ElseIf BeginsWith(Type2, LABEL_SEQ_CELL) Then
        Set MySheetDef.SequenceCell = Confine(MySheetDef.SequenceCell, GetRefersToRangeSafely(name))
    
    ElseIf BeginsWith(Type2, LABEL_FILTERING_CELL) Then
        Set MySheetDef.FilteringCell = Confine(MySheetDef.FilteringCell, GetRefersToRangeSafely(name))
        
    ElseIf BeginsWith(Type2, LABEL_SHOW_ALL_COMBIBATIONS_CELL) Then
        Set MySheetDef.ShowAllCombinationsCell = Confine(MySheetDef.ShowAllCombinationsCell, GetRefersToRangeSafely(name))
    
    ElseIf Type2 = LABEL_RESULT_AREA_PREV_ROW Then
        Set MySheetDef.ResultAreaPrevRow = GetRefersToRangeSafely(name)
    
    ElseIf Type2 = LABEL_IS_FORMULA_TO_PASTE Then
        MySheetDef.IsFormulaToPaste = GetBooleanValue(name)
    ElseIf Type2 = LABEL_IS_FORMAT_TO_PASTE Then
        MySheetDef.IsFormatToPaste = GetBooleanValue(name)
    ElseIf Type2 = LABEL_IS_DATA_VALIDATION_TO_PASTE Then
        MySheetDef.IsDataValidationToPaste = GetBooleanValue(name)
    ElseIf Type2 = LABEL_ENABLE_SWITCH_LOCK Then
        MySheetDef.EnableSwitchLock = GetBooleanValue(name)
    ElseIf Type2 = LABEL_AUTOFILTER Then
        MySheetDef.AutoFilter = GetBooleanValue(name)
   
    ElseIf Type2 = LABEL_TEMPLATE_PROCESSING_SUPPRESSED Then
        MySheetDef.IsTemplateProcessingSuppressed = GetBooleanValue(name)
    ElseIf Type2 = LABEL_RB Then
        RowBindingSeq = DelimitedName.Words(3)
        Set RowBinding = GetRowBindingBySeq(RowBindingSeq)
        Type4 = DelimitedName.Words(4)
        If Type4 = LABEL_RB_DIM Then
            RowBinding.DimensionLabel = GetStringValue(name)
        ElseIf Type4 = LABEL_RB_KEY_COL Then
            Set RowBinding.KeyColumn = GetRefersToRangeSafely(name)
        ElseIf Type4 = LABEL_RB_MEMLIST Then
            RowBinding.MemberListLabel = GetStringValue(name)
        ElseIf Type4 = LABEL_RB_PEGMEMRANGE Then
            Set RowBinding.PegMemberLabelRange = GetAnchoringCell(GetRefersToRangeSafely(name))
        ElseIf BeginsWith(Type4, LABEL_RB_PEGMEMRANGE) Then
            Set RowBinding.PegMemberLabelRange = Confine(RowBinding.PegMemberLabelRange, GetRefersToRangeSafely(name))
        Else
            MsgBoxEx "Undefined TYPE4 label [" & Type4 & "]"
        End If
    Else
        'Thru
    End If
End Sub

Private Sub ProcessRangeDef(name As name, DelimitedName As DelimitedNameType, RangeSeq As String)
    Dim RegionDef           As RegionDef
    Dim KeyAssignment       As KeyAssignment
    Dim Type2               As String
    Dim Type4               As String
    Dim SubSeq              As String
    
    Set RegionDef = GetRegionDefBySeq(RangeSeq)
    Type2 = DelimitedName.Words(2)
    If Type2 = LABEL_REGION_NAME Then
        RegionDef.RegionName = GetStringValue(name)
    ElseIf Type2 = LABEL_RANGE Then
        Set RegionDef.Range = GetRefersToRangeSafely(name)
    
    ElseIf Type2 = LABEL_APP_LABEL_RANGE Then
        Set RegionDef.ApplicationLabelRange = GetAnchoringCell(GetRefersToRangeSafely(name))
    ElseIf BeginsWith(Type2, LABEL_APP_LABEL_RANGE) Then
        Set RegionDef.ApplicationLabelRange = Confine(RegionDef.ApplicationLabelRange, GetRefersToRangeSafely(name))
    
    ElseIf Type2 = LABEL_PARTICIPANT_LABEL_RANGE Then
        Set RegionDef.ParticipantLabelRange = GetAnchoringCell(GetRefersToRangeSafely(name))
    ElseIf BeginsWith(Type2, LABEL_PARTICIPANT_LABEL_RANGE) Then
        Set RegionDef.ParticipantLabelRange = Confine(RegionDef.ParticipantLabelRange, GetRefersToRangeSafely(name))
    
    ElseIf Type2 = LABEL_EDITION_KEY_RANGE Then
        Set RegionDef.EditionKeyRange = GetAnchoringCell(GetRefersToRangeSafely(name))
    ElseIf BeginsWith(Type2, LABEL_EDITION_KEY_RANGE) Then
        Set RegionDef.EditionKeyRange = Confine(RegionDef.EditionKeyRange, GetRefersToRangeSafely(name))
    
  
    ElseIf Type2 = LABEL_REGION_TYPE Then
        RegionDef.RegionType = GetIntValue(name)
    
    ElseIf Type2 = LABEL_UNIT_RANGE Then
        Set RegionDef.UnitRange = GetAnchoringCell(GetRefersToRangeSafely(name))
    ElseIf BeginsWith(Type2, LABEL_UNIT_RANGE) Then
        Set RegionDef.UnitRange = Confine(RegionDef.UnitRange, GetRefersToRangeSafely(name))
    
    
    ElseIf Type2 = LABEL_LEDGER_LABEL Then
        RegionDef.LedgerLabel = GetStringValue(name)
    ElseIf Type2 = LABEL_APPLICABLE_ACTION Then
        RegionDef.ApplicableAction = GetIntValue(name)
    ElseIf Type2 = LABEL_ROUNDING Then
        RegionDef.Rounding = GetIntValue(name)
    ElseIf Type2 = LABEL_IGNORED_IN_DATA_EXISTENCE_JDGMNT Then
        RegionDef.IsIgnoredInDataExistenceJudgment = GetBooleanValue(name)
    ElseIf Type2 = LABEL_RAISE_ERROR_IF_CELL_TO_UPDATE_IS_CLOSED Then
        RegionDef.RaiseErrorIfCellToUpdateIsClosed = GetBooleanValue(name)
    ElseIf Type2 = LABEL_DATATYPE_CHECK_ENABLED Then
        RegionDef.IsDataTypeCheckEnabled = GetBooleanValue(name)
    ElseIf Type2 = LABEL_ENUM_DESCRIPTIVE Then
        RegionDef.IsEnumDescriptive = GetBooleanValue(name)
    ElseIf Type2 = LABEL_TO_CONVERT_DATETIME_TEXT Then
        RegionDef.IsToConvertDateTimeText = GetBooleanValue(name)
    ElseIf Type2 = LABEL_SIGN Then
        RegionDef.Sign = GetIntValue(name)
    ElseIf Type2 = LABEL_DECIMAL_PLACES Then
        RegionDef.DecimalPlaces = GetIntValue(name)
    ElseIf Type2 = LABEL_SWITCH_CELL_LOCKING Then
        RegionDef.SwitchCellLocking = GetBooleanValue(name)
    
    ElseIf Type2 = LABEL_LOCKED_COLOR_RANGE Then
        Set RegionDef.LockedColorRange = GetAnchoringCell(GetRefersToRangeSafely(name))
    ElseIf BeginsWith(Type2, LABEL_LOCKED_COLOR_RANGE) Then
        Set RegionDef.LockedColorRange = Confine(RegionDef.LockedColorRange, GetRefersToRangeSafely(name))
    
    ElseIf Type2 = LABEL_DIMENSION Then
        RegionDef.DimensionLabel = GetStringValue(name)
    ElseIf Type2 = LABEL_TEXT_FORMULA Then
        If UBound(DelimitedName.Words) = 2 Then
            ' for backward compatibility
            RegionDef.TextExpression = GetStringValue(name)
        Else
            Dim HexExpressionPartCol As Collection
            Set HexExpressionPartCol = GetHexExpressionPartColBySeq(RangeSeq)
            SubSeq = DelimitedName.Words(3)
            HexExpressionPartCol.add Item:=GetStringValue(name), key:=SubSeq
        End If
    ElseIf Type2 = LABEL_KB Then
        SubSeq = DelimitedName.Words(3)
        Set KeyAssignment = GetKeyAssignmentBySeq(RangeSeq, SubSeq)
        Type4 = DelimitedName.Words(4)
        If Type4 = LABEL_KEY_DIM Then
            KeyAssignment.DimensionLabel = GetStringValue(name)
        ElseIf Type4 = LABEL_KEY_RANGE Then
            Set KeyAssignment.Range = GetRefersToRangeSafely(name)
        Else
            MsgBoxEx "Undefined TYPE4 label [" & Type4 & "]"
        End If
    Else
        MsgBoxEx "Undefined TYPE2 label [" & Type2 & "]"
    End If
    
End Sub




Private Function Confine(Cell As Range, RowOrCol As Range) As Range
    If Cell Is Nothing Then
        Set Confine = RowOrCol
    ElseIf RowOrCol Is Nothing Then
        Set Confine = Nothing
    Else
        Set Confine = Intersect(Cell, RowOrCol)
    End If
End Function

Private Function GetRegionDefBySeq(RangeSeq As String) As RegionDef
    On Error GoTo ERR_TRAP
    Set GetRegionDefBySeq = RegionDefsBySeq.Item(RangeSeq)
    Exit Function
ERR_TRAP:
    Set GetRegionDefBySeq = MySheetDef.AddRegionDef
    GetRegionDefBySeq.IsToConvertDateTimeText = True
    
    RegionDefsBySeq.add Item:=GetRegionDefBySeq, key:=RangeSeq
End Function

Private Function GetKeyAssignmentBySeq(RangeSeq As String, KeySeq As String) As KeyAssignment
    Dim key                 As String
    On Error GoTo ERR_TRAP
    key = RangeSeq & "_" & KeySeq
    Set GetKeyAssignmentBySeq = KeyAssignmentsBySeq.Item(key)
    
    Exit Function
    
ERR_TRAP:
    Set GetKeyAssignmentBySeq = GetRegionDefBySeq(RangeSeq).AddKeyAssignment
    KeyAssignmentsBySeq.add Item:=GetKeyAssignmentBySeq, key:=key
End Function

Private Function GetRowBindingBySeq(RowBindingSeq As String) As RowBinding
    On Error GoTo ERR_TRAP
    Set GetRowBindingBySeq = RowBindingsBySeq.Item(RowBindingSeq)
    
    Exit Function
    
ERR_TRAP:
    Set GetRowBindingBySeq = MySheetDef.AddRowBinding
    RowBindingsBySeq.add Item:=GetRowBindingBySeq, key:=RowBindingSeq
End Function

Private Function GetHexExpressionPartColBySeq(RangeSeq As String) As Collection
    On Error GoTo ERR_TRAP
    Set GetHexExpressionPartColBySeq = HexExpressionPartColsBySeq.Item(RangeSeq)
    Exit Function
ERR_TRAP:
    Set GetHexExpressionPartColBySeq = New Collection
    HexExpressionPartColsBySeq.add Item:=GetHexExpressionPartColBySeq, key:=RangeSeq
End Function
-------------------------------------------------------------------------------

' ===========================================================================
' Module: KeyAssignment (クラスモジュール)
' ===========================================================================
Option Explicit

Public Sheet As Worksheet
'-- ディメンションラベル
Public DimensionLabel As String
'-- 列または行
Private MyRange As Range


Public Property Get KeyType() As Integer
    KeyType = GetKeyType(MyRange)
End Property


Public Property Set Range(Range As Range)
    Dim KeyType             As Integer
    
    KeyType = GetKeyType(Range)
    Select Case KeyType
    Case KEY_TYPE_NOTHING
        Set MyRange = Nothing
    Case KEY_TYPE_CELL
        Set MyRange = Range
    Case KEY_TYPE_COLUMN
        Set MyRange = Range.Cells.Item(1, 1).EntireRow
    Case KEY_TYPE_ROW
        Set MyRange = Range.Cells.Item(1, 1).EntireColumn
    End Select
    
End Property

Private Function GetKeyType(aRange As Range) As Integer
    On Error GoTo ERR_HANDLER
    
    Dim EntireRowSelected As Boolean
    If aRange Is Nothing Then
        GetKeyType = KEY_TYPE_NOTHING
    ElseIf (aRange.Columns.Count = 1) And (aRange.Rows.Count = 1) Then
        GetKeyType = KEY_TYPE_CELL
    Else
        EntireRowSelected = (aRange.Columns.Count = aRange.Worksheet.Columns.Count)
        If EntireRowSelected Then
            GetKeyType = KEY_TYPE_COLUMN
        Else
            GetKeyType = KEY_TYPE_ROW
        End If
    End If
    Exit Function

ERR_HANDLER:
    GetKeyType = KEY_TYPE_NOTHING
End Function

Public Property Get Range() As Range
    Set Range = MyRange
End Property

Public Property Get ColumnRowId() As Variant
    If Application.ReferenceStyle = xlA1 Then
        ColumnRowId = ColumnRowId_A1
    Else
        ColumnRowId = ColumnRowId_R1C1
    End If

End Property

Private Property Get ColumnRowId_A1() As Variant
    Dim Address As String
    
    Select Case KeyType
    Case KEY_TYPE_NOTHING
        ColumnRowId_A1 = "-"
        
    Case KEY_TYPE_CELL
        ColumnRowId_A1 = MyRange.Address(ColumnAbsolute:=False, RowAbsolute:=False, ReferenceStyle:=xlA1)
    
    Case KEY_TYPE_ROW
        Address = MyRange.Address(ColumnAbsolute:=False, RowAbsolute:=False, ReferenceStyle:=xlA1)
        ColumnRowId_A1 = Left(Address, InStr(Address, ":") - 1)
    
    Case KEY_TYPE_COLUMN
        ColumnRowId_A1 = MyRange.Row
    End Select

End Property

Private Property Get ColumnRowId_R1C1() As Variant
    Dim Address As String
    
    Select Case KeyType
    Case KEY_TYPE_NOTHING
        ColumnRowId_R1C1 = "-"
        
    Case KEY_TYPE_CELL
        ColumnRowId_R1C1 = MyRange.Address(ReferenceStyle:=xlR1C1)
    
    Case KEY_TYPE_ROW
        ColumnRowId_R1C1 = MyRange.Column
    
    Case KEY_TYPE_COLUMN
        ColumnRowId_R1C1 = MyRange.Row
    End Select

End Property


Public Function GetRegionName(Indent As Boolean) As Variant
    GetRegionName = GetColumnOrRowCaption(KeyType, Indent) & ColumnRowId
End Function


Private Function GetColumnOrRowCaption(KeyType As Integer, Indent As Boolean) As String
    Dim Prefix   As String
    
    Select Case KeyType
    Case KEY_TYPE_NOTHING
        GetColumnOrRowCaption = ""
        
    Case KEY_TYPE_CELL
        GetColumnOrRowCaption = GetText("CAP_CELL") & " "
    
    Case KEY_TYPE_ROW
        GetColumnOrRowCaption = IIf(Indent, vbTab, "") & GetText("CAP_COL") & " "
    
    Case KEY_TYPE_COLUMN
        GetColumnOrRowCaption = IIf(Indent, vbTab & vbTab, "") & GetText("CAP_ROW") & " "
    End Select
    
End Function

Public Sub Accept(Visitor As IVisitor)
    Visitor.EnterKeyAssignment Me
    Visitor.ExitKeyAssignment Me
End Sub
'
' テンプレート処理のすべての処理単位を通じて変化しない（安定的な）行キーを供給する列である。
'
Function IsStableRowKey(RowBindings As Collection, TemplateRange) As Boolean
    IsStableRowKey = False
    
    If Me.KeyType <> KEY_TYPE_ROW Then Exit Function
    
    If TemplateRange Is Nothing Then
        IsStableRowKey = False
        Exit Function
    End If
    
    '繰返し条件に束縛されたキー列ではない
    If IsBoundRowKey(RowBindings) Then Exit Function
    
    'キー列がテンプレート範囲と重なっていないこと
    IsStableRowKey = (Intersect(Me.Range, TemplateRange) Is Nothing)
End Function

'
' 被結合行キー列ではないが、テンプレート処理のすべての処理単位を通じて変化し得る（揮発性の）行キーを供給する列である。
'
Function IsVolatileRowKey(RowBindings As Collection, TemplateRange) As Boolean
    IsVolatileRowKey = False
    
    If Me.KeyType <> KEY_TYPE_ROW Then Exit Function
    
    If TemplateRange Is Nothing Then
        IsVolatileRowKey = True
        Exit Function
    End If
    
    '繰返し条件に束縛されたキー列ではない
    If IsBoundRowKey(RowBindings) Then Exit Function
    
    'キー列がテンプレート範囲と重なっていること
    IsVolatileRowKey = Not (Intersect(Me.Range, TemplateRange) Is Nothing)

End Function

'
'テンプレート処理の各処理単位を決定づけるメンバの組に関するいずれかのディメンションのメンバに結び付けられる列である。
'
Function IsBoundRowKey(RowBindings As Collection) As Boolean
    Dim RowBinding          As RowBinding
    If Me.KeyType <> KEY_TYPE_ROW Then
        IsBoundRowKey = False
        Exit Function
    End If
    For Each RowBinding In RowBindings
        If RowBinding.DimensionLabel = Me.DimensionLabel And _
           AreSameRanges(RowBinding.KeyColumn, Me.Range) Then
            IsBoundRowKey = True
            Exit Function
        End If
    Next
    IsBoundRowKey = False
    
End Function


-------------------------------------------------------------------------------

