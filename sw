'SOLIDWORKS PDM 2022 - Default Convert Task Script
'-----------------------------------------------
Dim swApp As Object
Dim swModel As SldWorks.ModelDoc2
Dim swDrawing As SldWorks.DrawingDoc
Dim swAssembly As SldWorks.AssemblyDoc
Dim swExtension As SldWorks.ModelDocExtension
Dim swConfMgr As SldWorks.ConfigurationManager
Dim swPDFExport As SldWorks.ExportPdfData
Dim swDocSpecification As SldWorks.DocumentSpecification
Dim FileSystemObj as Object
Dim errors As Long
Dim warnings As Long
Dim Is3dPDF As Boolean
Const ForAppending = 8
Const TriStateDefault = -2

Dim bUseMapping as Boolean

Dim iDXFFormatVersion as Integer
Dim iDXFFont as Integer
Dim iDXFLineStyle as Integer
Dim bEnableEndPointMerging as Boolean
Dim bHighQualityDXFExport as Boolean
Dim dEndPoinMergingDistance as Double
Dim bSplinesExport as Boolean

Dim bUseMappingOriginal as Boolean
Dim bShowMapOriginal as Boolean
Dim MapFiles As String
Dim Idx As Integer

Dim iDXFFormatVersionOriginal as Integer
Dim iDXFFontOriginal as Integer
Dim iDXFLineStyleOriginal as Integer
Dim bEnableEndPointMergingOriginal as Boolean
Dim bHighQualityDXFExportOriginal as Boolean
Dim dEndPoinMergingDistanceOriginal as Double
Dim bSplinesExportOriginal as Boolean

Dim bNeedRestore as Boolean


#If VBA7 Then
    Private Declare PtrSafe Function SHCreateDirectoryEx Lib "shell32" Alias "SHCreateDirectoryExW" (ByVal hwnd As Long, ByVal pszPath As LongPtr, ByVal psa As Any) As Long
    Private Declare PtrSafe Function PathIsRelative Lib "shlwapi.dll" Alias "PathIsRelativeW" (ByVal pszPath As LongPtr) As Long
#Else
    Private Declare Function SHCreateDirectoryEx Lib "shell32" Alias "SHCreateDirectoryExW" (ByVal hwnd As Long, ByVal pszPath As LongPtr, ByVal psa As Any) As Long
    Private Declare Function PathIsRelative Lib "shlwapi.dll" Alias "PathIsRelativeW" (ByVal pszPath As LongPtr) As Long
#End If

Function PathAppend(path, more) As String
    If Not Right(path, 1) = "\" Then
        path = path & "\"
    End If
    If Left(more, 1) = "\" Then
        more = Mid(more, 2)
    End If
    PathAppend = path & more
End Function

Sub Log(message)
    Dim errorLogFolder As String
    Dim errorLogPath As String
    ' Determine error log output path
    errorLogFolder = "[ErrorLogPath]"
    
    ' Trim \ from the start
    If Left(errorLogFolder, 1) = "\" Then
        errorLogFolder = Mid(errorLogFolder, 2)
    End If

    ' Build full root
    If PathIsRelative( StrPtr(errorLogFolder) ) = 1 Then
        errorLogPath = PathAppend("<VaultPath>", errorLogFolder)
    Else
        errorLogPath = errorLogFolder
    End If
    
    ' Create directory if not exists
    SHCreateDirectoryEx ByVal 0&, StrPtr(errorLogPath), ByVal 0&
    errorLogPath = PathAppend(errorLogPath, "<TaskInstanceGuid>.log")

    ' Write error to output file
    Set oFSO = CreateObject("Scripting.FileSystemObject")
    Set oFile = oFSO.OpenTextFile(errorLogPath, ForAppending, TriStateDefault)
    oFile.WriteLine message
    oFile.Close
End Sub

Sub CreatePath(path)
   ' Create directory if not exists
    result = SHCreateDirectoryEx(ByVal 0&, StrPtr(path), ByVal 0&)
End Sub

Function GetExtension(docType, fileFormat)
    first = InStr(1, fileFormat, "(")
    last = InStr(first, fileFormat, ")")
    extensions = Mid(fileFormat, first + 1, last - first - 1)
    
    Is3dPDF = (StrComp(Mid(fileFormat, 1, first - 1), "3D PDF - MBD ") = 0)
    
    If InStr(1, extensions, ";") > 0 Then
        Dim all As Variant
        all = Split(extensions, ";")
       
        If UBound(all) >= docType - 1 Then
            ext = all(docType - 1)
        Else
            ext = "*." ' Nothing
        End If
    Else
        ext = extensions
    End If
    
    GetExtension = Mid(Trim(ext), 2)
End Function

Sub SetConversionOptions(ext)

    bNeedRestore = true
    ' PDF options
    If LCase(ext) = ".pdf" Then
        swApp.SetUserPreferenceToggle swPDFExportInColor, [PdfInColor]
        swApp.SetUserPreferenceToggle swPDFExportEmbedFonts, [PdfEmbedFonts]
        swApp.SetUserPreferenceToggle swPDFExportHighQuality, [PdfHighQuality]
        swApp.SetUserPreferenceToggle swPDFExportPrintHeaderFooter, [PdfPrintHeaderFooter]
        swApp.SetUserPreferenceToggle swPDFExportUseCurrentPrintLineWeights, [PdfUsePrinterLineWeights]
    ' IGES
    ElseIf LCase(ext) = ".igs" Then
        swApp.SetUserPreferenceToggle swIGESExportSolidAndSurface, [IgesExportSolidSurface]
        swApp.SetUserPreferenceIntegerValue swIGESRepresentation, [IgesRepresentation]
        swApp.SetUserPreferenceToggle swIGESExportAsWireframe, [IgesExportWireframe]
        swApp.SetUserPreferenceIntegerValue swIGESCurveRepresentation, [IgesCurveRepresentation]
        swApp.SetUserPreferenceIntegerValue swIGESSystem, [IgesSystem]
        swApp.SetUserPreferenceToggle swIGESExportFreeCurves, [IgesExportFreeCurves]
        swApp.SetUserPreferenceToggle swIGESExportSketchEntities, [IgesExportSketchEntities]
        swApp.SetUserPreferenceToggle swIGESHighTrimCurveAccuracy, [IgesHighCurveAccuracy]
        swApp.SetUserPreferenceToggle swIGESComponentsIntoOneFile, [IgesComponentsIntoOneFile]
        swApp.SetUserPreferenceToggle swIGESFlattenAssemHierarchy, [IgesFlattenAssemblyHierarchy]
    ' ACIS
    ElseIf LCase(ext) = ".sat" Then
        swApp.SetUserPreferenceIntegerValue swAcisOutputGeometryPreference, [AcisGeometry]
        swApp.SetUserPreferenceIntegerValue swOutputVersion, [AcisVersion]
        swApp.SetUserPreferenceIntegerValue swAcisOutputUnits, [AcisOutputAsUnit]
    ' STEP
    ElseIf LCase(ext) = ".step" Then
        swApp.SetUserPreferenceIntegerValue swAcisOutputGeometryPreference, [StepGeometry]
        swApp.SetUserPreferenceIntegerValue swStepAP, [StepVersion]
    ' Parasolid
    ElseIf LCase(ext) = ".x_t" Or LCase(ext) = ".x_b" Then
        swApp.SetUserPreferenceIntegerValue swParasolidOutputVersion, [ParasolidVersion]
        swApp.SetUserPreferenceToggle swXTAssemSaveFormat, [ParasolidFlattenHierarchy]
    ' VRML
    ElseIf LCase(ext) = ".wrl" Then
        swApp.SetUserPreferenceIntegerValue swExportVrmlUnits, [VrmlOutputAsUnit]
        swApp.SetUserPreferenceToggle swExportVrmlAllComponentsInSingleFile, [VrmlSaveAssemblyAsOneFile]
    ' STL
    ElseIf LCase(ext) = ".stl" Then
        swApp.SetUserPreferenceToggle swSTLBinaryFormat, [StlOutputAs]
        swApp.SetUserPreferenceIntegerValue swExportStlUnits, [StlOutputAsUnit]
        swApp.SetUserPreferenceIntegerValue swSTLQuality, [StlQuality]
        swApp.SetUserPreferenceToggle swSTLDontTranslateToPositive, [StlDontTranslatePositive]
        swApp.SetUserPreferenceToggle swSTLComponentsIntoOneFile, [StlComponentsIntoOneFile]
        swApp.SetUserPreferenceToggle swSTLCheckForInterference, [StlCheckForInterferences]
    ' TIF or PSD
    ElseIf LCase(ext) = ".tif" Or LCase(ext) = ".psd" Then
        swApp.SetUserPreferenceIntegerValue swTiffImageType, [TifImageType]
        swApp.SetUserPreferenceIntegerValue swTiffCompressionScheme, [TifCompressionScheme]
    ' eDrawings
    ElseIf LCase(ext) = ".eprt" Or LCase(ext) = ".easm" Or LCase(ext) = ".edrw" Then
        swApp.SetUserPreferenceToggle swEDrawingsOkayToMeasure, [EdrwOkayToMeasure]
        swApp.SetUserPreferenceToggle swEDrawingsExportSTLOkay, [EdrwAllowExportOfSTL]
        swApp.SetUserPreferenceToggle swEDrawingsSaveShadedDataInDrawings, [EdrwSaveShadedData]
        swApp.SetUserPreferenceToggle swEDrawingsSaveBOM, [EdrwSaveBOM]
        swApp.SetUserPreferenceToggle swEDrawingsSaveAnimationOkay, [EdrwSaveMotionStudies]
        swApp.SetUserPreferenceToggle swEDrawingsSaveAnimationToAllConfigs, [EdrwSaveMotionStudiesToAllConfs]
        swApp.SetUserPreferenceToggle swEDrawingsSaveAnimationRecalculate, [EdrwRecalcMotionStudies]
    ElseIf LCase(ext) = ".dwg" Or LCase(ext) = ".dxf" Then

        iDXFFormatVersionOriginal = swApp.GetUserPreferenceIntegerValue(swDxfVersion)
        iDXFFontOriginal = swApp.GetUserPreferenceIntegerValue(swDxfOutputFonts)
        iDXFLineStyleOriginal = swApp.GetUserPreferenceIntegerValue(swDxfOutputLineStyles)
        bEnableEndPointMergingOriginal = swApp.GetUserPreferenceToggle(swDxfEndPointMerge)
        bHighQualityDXFExportOriginal = swApp.GetUserPreferenceToggle(swDXFHighQualityExport)
        dEndPoinMergingDistanceOriginal = swApp.GetUserPreferenceDoubleValue(swDxfMergingDistance)
        bSplinesExportOriginal = swApp.GetUserPreferenceToggle(swDxfEndPointMerge)

        iDXFFormatVersion = [Dxf_Version]
        iDXFFont = [Dxf_Font]
        iDXFLineStyle = [Dxf_Line_Style]
        bEnableEndPointMerging = [Dxf_Enable_Endpoint_Merging]
        bHighQualityDXFExport = [Dxf_High_Quality]
        #If (bEnableEndPointMerging) Then
            dEndPoinMergingDistance = [Dxf_End_Point_Merging]
        #endif
        bSplinesExport = [Dxf_Splines_Export]

        swApp.SetUserPreferenceIntegerValue swDxfVersion, iDXFFormatVersion
        swApp.SetUserPreferenceIntegerValue swDxfOutputFonts, iDXFFont
        swApp.SetUserPreferenceIntegerValue swDxfOutputLineStyles, iDXFLineStyle
        swApp.SetUserPreferenceToggle swDxfEndPointMerge, bEnableEndPointMerging
        swApp.SetUserPreferenceToggle swDXFHighQualityExport , bHighQualityDXFExport
        swApp.SetUserPreferenceDoubleValue swDxfMergingDistance, dEndPoinMergingDistance
        swApp.SetUserPreferenceToggle swDxfEndPointMerge, Not(bSplinesExport)

        bUseMapping = [EnableMapFile]
        If(bUseMapping = True) Then
            MapFilePath= "[MapFilePath]"
            'store original info
            bShowMapOriginal = swApp.GetUserPreferenceToggle(swDXFDontShowMap)
            bUseMappingOriginal = swApp.GetUserPreferenceToggle(swDXFMapping)
            MapFiles = swApp.GetUserPreferenceStringListValue(swDxfMappingFiles)
            Idx = swApp.GetUserPreferenceIntegerValue(swDxfMappingFileIndex)
            swApp.SetUserPreferenceToggle swDXFDontShowMap, False
            swApp.SetUserPreferenceToggle swDxfMapping, True
            swApp.SetUserPreferenceStringListValue swDxfMappingFiles, MapFilePath
            swApp.SetUserPreferenceIntegerValue swDxfMappingFileIndex, 0 'only one map file
        End If

    End If
End Sub

Sub RestoreConversionOptions (ext)
    If bNeedRestore = True Then
        If LCase(ext) = ".dwg" Or LCase(ext) = ".dxf" Then
            swApp.SetUserPreferenceIntegerValue swDxfVersion, iDXFFormatVersionOriginal
            swApp.SetUserPreferenceIntegerValue swDxfOutputFonts, iDXFFontOriginal
            swApp.SetUserPreferenceIntegerValue swDxfOutputLineStyles, iDXFLineStyleOriginal
            swApp.SetUserPreferenceToggle swDxfEndPointMerge, bEnableEndPointMergingOriginal
            swApp.SetUserPreferenceToggle swDXFHighQualityExport , bHighQualityDXFExportOriginal
            swApp.SetUserPreferenceDoubleValue swDxfMergingDistance, dEndPoinMergingDistanceOriginal
            swApp.SetUserPreferenceToggle swDxfEndPointMerge, bSplinesExportOriginal

            If(bUseMapping = True) Then
                swApp.SetUserPreferenceToggle swDXFDontShowMap, bShowMap
                swApp.SetUserPreferenceToggle swDxfMapping, bUseMapping
                swApp.SetUserPreferenceStringListValue swDxfMappingFiles, MapFiles
                swApp.SetUserPreferenceIntegerValue swDxfMappingFileIndex, Idx
            End If
        End If
    EndIf
End Sub


Function ReplaceVarTags(convFileName, conf)
Dim varDictionary: Set varDictionary = CreateObject("Scripting.Dictionary")
varDictionary.CompareMode = vbTextCompare

<VarReplacerScript>

localConf = conf

If conf = "" Or conf = "All sheets" Or conf = "All" Then
    localConf = "@"
End If

resultFileName = convFileName

If varDictionary.Exists(localConf) Then

    For Each elem In varDictionary(localConf)
        resultFileName = Replace(resultFileName, "%" & elem & "%", varDictionary(localConf).Item(elem))
    Next

End If
'replace duplicated slash and backslash that can be created if user include variables into directory path
While InStr(1,resultFileName,"\\",1) > 0 or InStr(1,resultFileName,"//",1) > 0
    resultFileName = Replace(resultFileName,"\\","\")
    resultFileName = Replace(resultFileName,"//","/")
WEnd
'SPR 1100578 for network UNC path we need \\ on the begin of path
If InStr(resultFileName, "\") = 1 Or InStr(resultFileName, "/") = 1 Then
resultFileName = Replace(resultFileName, "\", "\\", 1, 1)
resultFileName = Replace(resultFileName, "/", "//", 1, 1)
End If
ReplaceVarTags = resultFileName 

End Function

Function GetFullFileName(convFileName, conf, i, itemCount)
    ' Configuration name may include backslash. Remove it since otherwise saving will
    ' fail due a missing directory
    conf = Replace(conf, "\", "")
    conf = Replace(conf, "/", "")
    
    finalFileName = Replace(convFileName, "<Configuration>", conf)
    
    ' If no configuration
    If finalFileName = convFileName And itemCount > 0 Then
        finalFileName = Left(convFileName, InStrRev(convFileName, ".") - 1) & "_" & i & Mid(convFileName, InStrRev(convFileName, "."))
    End If

    ' SPR 1189246
    ' Replace var tags before removing illegal characters as var values could contain ones
    finalFileName =  ReplaceVarTags(finalFileName, conf)

    ' Remove illegal characters from filename
    finalFileName = Replace(finalFileName, "<", "")
    finalFileName = Replace(finalFileName, ">", "")
    finalFileName = Left(finalFileName, 2) + Replace(finalFileName, ":", "", 3) ' Don't start from begin since drive has :
    finalFileName = Replace(finalFileName, "*", "")
    finalFileName = Replace(finalFileName, "?", "")
    finalFileName = Replace(finalFileName, """", "")
    finalFileName = Replace(finalFileName, "|", "")

    convFilePath = FileSystemObj.GetParentFolderName(finalFileName)
    CreatePath convFilePath
    GetFullFileName = finalFileName
End Function

Sub Convert(docFileName)
    
    ' Constants for some SolidWorks error/warning returns that may be encountered during a convert operation.        
    Const swerr_InvalidFileExtension = 256   ' the file extension differs from the SW document type.
    Const swerr_SaveAsNotSupported = 4096    ' the options selected for this convert aren't supported, output may be incomplete.
    Const swwarn_MissingOLEObjects = 512     ' the document contains OLE objects and must be opened and converted in SolidWorks.

    ' Determine type of SolidWorks file based on file extension
    If LCase(Right(docFileName, 7)) = ".sldprt" Or LCase(Right(docFileName, 4)) = ".prt" Then
        docType = swDocPART
    ElseIf LCase(Right(docFileName, 7)) = ".sldasm" Or LCase(Right(docFileName, 4)) = ".asm" Then
        docType = swDocASSEMBLY
    ElseIf LCase(Right(docFileName, 7)) = ".slddrw" Or LCase(Right(docFileName, 4)) = ".drw" Then
        docType = swDocDRAWING
    Else
        docType = swDocNONE
         If bIsSupportedExtension(Mid(docFileName, InStrRev(docFileName, ".") + 1)) = False Then
             Log "The file extension '" & Mid(docFileName, InStrRev(docFileName, ".") + 1) & "' is not supported."
             Exit Sub
         End If        
    End If
        
    ' Open document
    If docType = swDocNONE Then
        Set swModel = swApp.LoadFile4(docFileName, "", Nothing, errors)
        docType = swModel.GetType
    Else  
        Set swDocSpecification = swApp.GetOpenDocSpec(docFileName)
        swDocSpecification.DocumentType = docType 
        swDocSpecification.ReadOnly = True
        swDocSpecification.Silent = True
        swDocSpecification.ConfigurationName = ""
        swDocSpecification.DisplayState = ""
        swDocSpecification.IgnoreHiddenComponents = True 'SPR 682792, 538578, 651998 
        Set swModel = swApp.OpenDoc7(swDocSpecification)
        errors = swDocSpecification.Error

       ' Set swModel = swApp.OpenDoc6(docFileName, docType, swOpenDocOptions_Silent Or swOpenDocOptions_ReadOnly, "", errors, warnings)
    End If
    
    If errors = swFutureVersion Then
        Log "Document '" & docFileName & "' is future version."
        Exit Sub
    End If

    ' Load failed?
    If swModel Is Nothing Then
        Log "Method call ModelDoc2::OpenDoc7 for document '" & docFileName & "' failed. Error code " & errors & " returned."
        Exit Sub
    End If
    
    If Val(Left(swApp.RevisionNumber, 2)) >= 18 Then
      swApp.Frame.KeepInVisible = True
    End If

    swApp.ActivateDoc2 docFileName, True, errors
    modelPath = swModel.GetPathName()
    If modelPath = "" Then
      modelPath = docFileName
    End If
    modelFileName = Mid(modelPath, InStrRev(modelPath, "\") + 1)
    modelFileName = Left(modelFileName, InStrRev(modelFileName, ".") - 1)
    modelExtension = Mid(modelPath, InStrRev(modelPath, ".") + 1)

    ' Build destination filenames
    convFileName = "[OutputPath]"
    
    Dim convFileName2 As String
    convFileName2 = "[OutputPath2]"
    Dim convFilePath2 As String
    Dim convFileNameTemp2 As String
    
    Dim bSecondOutput As Boolean
    bSecondOutput = False
    If (Len(convFileName2) > 0) Then
        bSecondOutput = True
    End If
        
    ext = GetExtension(docType, "[FileFormat]")
    
    If (True = Is3dPDF And docType = swDocDRAWING) Then
        Log "The file extension '" & Mid(docFileName, InStrRev(docFileName, ".") + 1) & "' is not supported."
        Exit Sub
    End If

    convFileName = Replace(convFileName, "<Filename>", modelFileName)
    convFileName = Replace(convFileName, "<Extension>", modelExtension)
    convFileName = convFileName & ext
    
    If bSecondOutput = True Then
        convFileName2 = Replace(convFileName2, "<Filename>", modelFileName)
        convFileName2 = Replace(convFileName2, "<Extension>", modelExtension)
        convFileName2 = convFileName2 & ext
    End If
    
    ' Set conversion options
    SetConversionOptions ext
    
    Set swExtension = swModel.Extension
    

    If docType = swDocDRAWING Then
        Dim vSheetNames As Variant
        Set swDrawing = swModel
        
        ' All sheets?
        If ([OutputSheets] And 2) = 2 Then
            vSheetNames = swDrawing.GetSheetNames
        ' Last active sheet?
        ElseIf ([OutputSheets] And 4) = 4 Then
            ReDim vSheetNames(0 to 0) As Variant
            vSheetNames(0) = swDrawing.GetCurrentSheet.GetName()
        ' Named sheet
        ElseIf ([OutputSheets] And 8) = 8 Then
            Dim vSheetNamesTemp As Variant
            vSheetNamesTemp = swDrawing.GetSheetNames
            removed = 0
            
            For i = 0 To UBound(vSheetNamesTemp)
                vSheetNamesTemp(i-removed) = vSheetNamesTemp(i)
                sheetName = vSheetNamesTemp(i)
                
                If Not sheetName Like "[NamedSheet]" Then
                    removed = removed + 1
                EndIf
            Next i
            
            If (UBound(vSheetNamesTemp) - removed) >= 0 Then
                ReDim Preserve vSheetNamesTemp(0 To (UBound(vSheetNamesTemp) - removed))
                vSheetNames = vSheetNamesTemp
            End If
        End If

        If Not IsEmpty(vSheetNames) Then
            ' Save sheets one per file
            If ([FileSheets] And 4) = 4 Then
                For i = 0 To UBound(vSheetNames)
                    Dim varSheetName        As Variant
                    swDrawing.ActivateSheet vSheetNames(i)

                    convFileNameTemp = GetFullFileName(convFileName, vSheetNames(i), i, UBound(vSheetNames))

                    If LCase(ext) = ".pdf" Then
                        Set swPDFExport = swApp.GetExportFileData(1)
                        varSheetName = vSheetNames(i)
                        swPDFExport.SetSheets swExportData_ExportSpecifiedSheets, varSheetName
                    ElseIf LCase(ext) = ".edrw" Then
                        swApp.SetUserPreferenceIntegerValue swEdrawingsSaveAsSelectionOption, swEdrawingSaveActive
                    ElseIf LCase(ext) = ".dxf" Or  LCase(ext) = ".dwg" Then
                        swApp.SetUserPreferenceIntegerValue swDxfMultiSheetOption, swDxfActiveSheetOnly

                        If ([FileSheets] And 8) = 8 Then
						    swApp.SetUserPreferenceToggle swDxfExportAllSheetsToPaperSpace, True
					    Else 
						    swApp.SetUserPreferenceToggle swDxfExportAllSheetsToPaperSpace, False
                        End if
                    End If

                    ' Convert the document
                    Success = swExtension.SaveAs(convFileNameTemp, swSaveAsCurrentVersion, swSaveAsOptions_Silent + swSaveAsOptions_UpdateInactiveViews, swPDFExport, errors, warnings)
                    
                    ' Save failed?
                    If Success = False Then
                        If errors = swerr_InvalidFileExtension Then
                            Log "The file '" & docFileName & "' and sheet '" &  vSheetNames(i) & "' can't be converted to the file extension '" & ext & "'."
                        Else
                            Log "Method call ModelDocExtension::SaveAs for document '" & convFileNameTemp & "' and sheet '" & vSheetNames(i) & "' failed. Error code " & errors & " returned."
                            If (((errors And swerr_SaveAsNotSupported) <> 0) And ((warnings And swwarn_MissingOLEObjects) <> 0)) Then
                                Log "This document contains OLE objects. Such objects can't be converted outside of SolidWorks. Please open the document and perform the conversion from SolidWorks."
                            End If 
                        End if  
                    End If
                    
                    If bSecondOutput = True Then
                        convFileNameTemp2 = GetFullFileName(convFileName2, vSheetNames(i), i, UBound(vSheetNames))
                        Success = swExtension.SaveAs(convFileNameTemp2, swSaveAsCurrentVersion, swSaveAsOptions_Silent + swSaveAsOptions_UpdateInactiveViews, swPDFExport, errors, warnings)
                        ' Save failed?
                        If Success = False Then
                            If errors = swerr_InvalidFileExtension Then
                                Log "The file '" & docFileName & "' and sheet '" &  vSheetNames(i) & "' can't be converted to the file extension '" & ext & "'."
                            Else
                                Log "Method call ModelDocExtension::SaveAs for document '" & convFileNameTemp2 & "' and sheet '" & vSheetNames(i) & "' failed. Error code " & errors & " returned."
                                If (((errors And swerr_SaveAsNotSupported) <> 0) And ((warnings And swwarn_MissingOLEObjects) <> 0)) Then
                                    Log "This document contains OLE objects. Such objects can't be converted outside of SolidWorks. Please open the document and perform the conversion from SolidWorks."
                                End If 
                            End if
                        End If
                    End If
                Next i
            ' Save PDF sheets to one file
            ElseIf ([FileSheets] And 2) = 2 Then
            
                If LCase(ext) = ".pdf" Then
                    Set swPDFExport = swApp.GetExportFileData(swExportPdfData)
                    swPDFExport.SetSheets swExportData_ExportSpecifiedSheets, vSheetNames
                ElseIf LCase(ext) = ".edrw" Then
                    If ([OutputSheets] And 2) = 2 Then ' All sheets?
                        swApp.SetUserPreferenceIntegerValue swEdrawingsSaveAsSelectionOption, swEdrawingSaveAll
                    ElseIf ([OutputSheets] And 4) = 4 Then ' Last active sheet?
                        swApp.SetUserPreferenceIntegerValue swEdrawingsSaveAsSelectionOption, swEdrawingSaveActive  
                    ElseIf ([OutputSheets] And 8) = 8 Then ' Named sheet
                        swApp.SetUserPreferenceIntegerValue swEdrawingsSaveAsSelectionOption, swEdrawingSaveSelected
                        selectedSheets = Join(vSheetNames, vbLf)
                        swApp.SetUserPreferenceStringListValue swEmodelSelectionList, Trim(selectedSheets)
                    End If
                 ElseIf LCase(ext) = ".dxf" Or  LCase(ext) = ".dwg" Then
                    swApp.SetUserPreferenceIntegerValue swDxfMultiSheetOption, swDxfMultiSheet
                    
                    If ([FileSheets] And 8) = 8 Then
						swApp.SetUserPreferenceToggle swDxfExportAllSheetsToPaperSpace, True
					Else 
						swApp.SetUserPreferenceToggle swDxfExportAllSheetsToPaperSpace, False
                    End if
                End If
                
                convFileNameTemp = GetFullFileName(convFileName, "All", 0, 0)
                
                ' Convert the document
                Success = swExtension.SaveAs(convFileNameTemp, swSaveAsCurrentVersion, swSaveAsOptions_Silent + swSaveAsOptions_UpdateInactiveViews, swPDFExport, errors, warnings)
                
                ' Save failed?
                If Success = False Then
                    Log "Method call ModelDocExtension::SaveAs for document '" & convFileNameTemp & "' failed. Error code " & errors & " returned."
                End If
                
                If bSecondOutput = True Then
                    convFileNameTemp2 = GetFullFileName(convFileName2, "All", 0, 0)
                    Success = swExtension.SaveAs(convFileNameTemp2, swSaveAsCurrentVersion, swSaveAsOptions_Silent + swSaveAsOptions_UpdateInactiveViews, swPDFExport, errors, warnings)
                    ' Save failed?
                    If Success = False Then
                        Log "Method call ModelDocExtension::SaveAs for document '" & convFileNameTemp2 & "' failed. Error code " & errors & " returned."
                    End If
                End If
            End If
        Else
            Log "Document '" & docFileName & "' didn't contain any sheets named '[NamedSheet]'."
        End If
     ElseIf (True = Is3dPDF) Then 
     #If ("<Supported_2017SW>") Then
        Dim swMBDPdfData As SldWorks.MBD3DPdfData
        Dim ThemeName As String
        Dim ViewsChecks As Long
        Dim PrimaryViews As Long
        
        If (swDocPART = docType) Then
            ThemeName = "[Part3DPDFThemePath]"
            ViewsChecks = [PartThemeAndViewsChecks]
            PrimaryViews = [PartPrimaryViews]
        ElseIf (swDocASSEMBLY = docType) Then
            ThemeName = "[Asm3DPDFThemePath]"
            ViewsChecks = [AsmThemeAndViewsChecks]
            PrimaryViews = [AsmPrimaryViews]
        End If
        
        Set swMBDPdfData = swExtension.GetMBD3DPdfData
        Set swConfMgr = swModel.ConfigurationManager
        Dim vConfName As Variant
        Dim convFilePathTemp As Variant

        vConfName = swConfMgr.ActiveConfiguration.Name

        If Not IsEmpty(vConfName) Then
            convFilePathTemp = GetFullFileName(convFileName, vConfName, 0, 0)
        Else
            convFilePathTemp = convFileName
        End If
        'Set output path and file name for SOLIDWORKS MBD 3D PDF
        swMBDPdfData.FilePath = convFilePathTemp
        'Dont Display SOLIDWORKS MBD 3D PDF after creation
        swMBDPdfData.ViewPdfAfterSaving = False
        'Set SOLIDWORKS MBD 3D PDF theme path
        swMBDPdfData.ThemeName = ThemeName
        
        ' IF Primary views selected
        If (ViewsChecks And 2) Then
            Dim standardViews As Variant
            Dim viewIDs(9) As Long
            Dim index As Integer
            index = 0
            'Set standard views for SOLIDWORKS MBD 3D PDF
            If (PrimaryViews And 4) Then
                viewIDs(index) = swStandardViews_e.swFrontView
                index = index + 1
            End If
            If (PrimaryViews And 8) Then
                viewIDs(index) = swStandardViews_e.swBackView
                index = index + 1
            End If
            If (PrimaryViews And 16) Then
                viewIDs(index) = swStandardViews_e.swTopView
                index = index + 1
            End If
            If (PrimaryViews And 32) Then
                viewIDs(index) = swStandardViews_e.swBottomView
                index = index + 1
            End If
            If (PrimaryViews And 64) Then
                viewIDs(index) = swStandardViews_e.swLeftView
                index = index + 1
            End If
            If (PrimaryViews And 128) Then
                viewIDs(index) = swStandardViews_e.swRightView
                index = index + 1
            End If
            If (PrimaryViews And 256) Then
                viewIDs(index) = swStandardViews_e.swIsometricView
                index = index + 1
            End If
            If (PrimaryViews And 512) Then
                viewIDs(index) = swStandardViews_e.swDimetricView
                index = index + 1
            End If
            If (PrimaryViews And 1024) Then
                viewIDs(index) = swStandardViews_e.swTrimetricView
            End If

            standardViews = viewIDs
            swMBDPdfData.SetStandardViews (standardViews)
        End If
            
        '3D views(CustomViews) selected?
        If (ViewsChecks And 4) Then
            Dim vViewNames As Variant
            Dim status As Long
            vViewNames = swExtension.Get3DViewNames
            
            'Create and set custom views for SOLIDWORKS MBD 3D PDF
            swMBDPdfData.SetMoreViews (vViewNames)
        End If 

        Dim TextAndCustomProperties As Variant
        TextAndCustomProperties = swMBDPdfData.GetTextAndCustomProperties
         
        'Create SOLIDWORKS MBD 3D PDF
        status = swExtension.PublishTo3DPDF(swMBDPdfData)
          
        If bSecondOutput = True Then
                If Not IsEmpty(vConfName) Then
                    convFilePathTemp = GetFullFileName(convFileName2, vConfName, 0, 0)
                Else
                    convFilePathTemp = convFileName2
                End If

                swMBDPdfData.FilePath = convFilePathTemp
                ' if primary saved successfully then Second Output 3DPDF
                If status = swPublishTo3DPDF_Success Then      
                    status = swExtension.PublishTo3DPDF(swMBDPdfData)
                End If
        End If
                        
        ' Save failed?
        If status = swPublishTo3DPDF_InvalidPath Then
            Log "3D PDF - Invalid path."
        ElseIf status = swPublishTo3DPDF_InvalidTheme Then
            Log "Couldn’t access Theme file"
        ElseIf status = swPublishTo3DPDF_MBDLicenseNotAvailable Then
            Log "Failed to load SOLIDWORKS MBD. Verify that SOLIDWORKS MBD is installed and necessary license is available."
        ElseIf status = swPublishTo3DPDF_UnknownError Then
            Log "3D PDF - Unknown error."
        ElseIf status = swPublishTo3DPDF_NothingToPublish Then
            Log "The source file '" & docFileName & "' does not contain any view(s) to publish."
        End If
      #Else
        Log "Unsupported SOLIDWORKS version found on the task host "
      #End If
    Else
        Dim vConfNames As Variant
        Set swConfMgr = swModel.ConfigurationManager
        
        ' All configurations?
        If ([OutputConfs] And 2) = 2 Then
            vConfNames = swModel.GetConfigurationNames
        ' Last active conf?
        ElseIf ([OutputConfs] And 4) = 4 Then
            ReDim vConfNames(0 to 0) As Variant
            vConfNames(0) = swConfMgr.ActiveConfiguration.Name
        ' Named confs
        ElseIf ([OutputConfs] And 8) = 8 Then
            Dim vConfNamesTemp As Variant
            vConfNamesTemp = swModel.GetConfigurationNames
            removed = 0
            
            For i = 0 To UBound(vConfNamesTemp)
                vConfNamesTemp(i-removed) = vConfNamesTemp(i)
                confName = vConfNamesTemp(i)
                
                If Not confName Like "[NamedConf]" Then
                    removed = removed + 1
                EndIf
            Next i
            
            If (UBound(vConfNamesTemp) - removed) >= 0 Then
                ReDim Preserve vConfNamesTemp(0 To (UBound(vConfNamesTemp) - removed))
                vConfNames = vConfNamesTemp
            End If
        End If
        
        If Not IsEmpty(vConfNames) Then
            If ([FileConfs] And 4) = 4 Then
                ' Save configurations
                For i = 0 To UBound(vConfNames)
                    swModel.ShowConfiguration vConfNames(i)

                    convFileNameTemp = GetFullFileName(convFileName, vConfNames(i), i, UBound(vConfNames))
                    DoSave convFileNameTemp, docFileName, docType, ext, vConfNames(i)
                    
                    If bSecondOutput = True Then
                        convFileNameTemp2 = GetFullFileName(convFileName2, vConfNames(i), i, UBound(vConfNames))
                        DoSave convFileNameTemp2, docFileName, docType, ext, vConfNames(i)
                    End If
                Next i
            ElseIf ([FileConfs] And 2) = 2 Then
                If LCase(ext) = ".eprt" Or LCase(ext) = ".easm" Then
                    If ([OutputConfs] And 2) = 2 Then ' All confs?
                        swApp.SetUserPreferenceIntegerValue swEdrawingsSaveAsSelectionOption, swEdrawingSaveAll
                    ElseIf ([OutputConfs] And 4) = 4 Then ' Last active conf?
                        swApp.SetUserPreferenceIntegerValue swEdrawingsSaveAsSelectionOption, swEdrawingSaveActive  
                    ElseIf ([OutputConfs] And 8) = 8 Then ' Named confs
                        swApp.SetUserPreferenceIntegerValue swEdrawingsSaveAsSelectionOption, swEdrawingSaveSelected
                        selectedConfs = Join(vConfNames, vbLf)
                        swApp.SetUserPreferenceStringListValue swEmodelSelectionList, Trim(selectedConfs)
                    End If
                End If
                
                convFileNameTemp = GetFullFileName(convFileName, "All", 0, 0)
                DoSave convFileNameTemp, docFileName, docType, ext, "All"
                
                If bSecondOutput = True Then
                    convFileNameTemp2 = GetFullFileName(convFileName2, "All", 0, 0)
                    DoSave convFileNameTemp2, docFileName, docType, ext, "All"
                End If
            End If
        Else
            Log "Document '" & docFileName & "' didn't contain any configurations named '[NamedConf]'."
        End If
    End If

    ' Process virtual components
    If docType = swDocASSEMBLY Then
        Dim vComponents As Variant
        Set swAssembly = swModel
        
        vComponents = swAssembly.GetComponents(True)
        
        If Not IsEmpty(vComponents) Then
          For i = 0 To UBound(vComponents)
              Dim swComponent As SldWorks.Component2
              Set swComponent = vComponents(i)
              
              If swComponent.IsVirtual Then
                  Convert swComponent.GetPathName()
              End If
          Next i
      End If
    End If

    RestoreConversionOptions ext
    ' Close document
    swApp.QuitDoc swModel.GetTitle
End Sub

Function DoSave(convFilePath, docFileName, docType, ext, config)
    If LCase(ext) = ".dwg" Or LCase(ext) = ".dxf" Then
        If docType = swDocPART Then 'sheet-metal
            #If ("<Supported_2018SW>") Then
                Dim dataAlignment(11) As Double
                Dim varAlignment As Variant
                Dim MultiBodyExport As Boolean
                MultiBodyExport = [SheetMetalExportAs]
                dataAlignment(0) = 0#
                dataAlignment(1) = 0#
                dataAlignment(2) = 0#
                dataAlignment(3) = 1#
                dataAlignment(4) = 0#
                dataAlignment(5) = 0#
                dataAlignment(6) = 0#
                dataAlignment(7) = 1#
                dataAlignment(8) = 0#
                dataAlignment(9) = 0#
                dataAlignment(10) = 0#
                dataAlignment(11) = 1#
                varAlignment = dataAlignment
                Set swPart = swModel
                Dim featureMgr As SldWorks.FeatureManager
                Dim flatPatternFolder As SldWorks.flatPatternFolder
                Dim feat As SldWorks.Feature
                Dim featArray As Variant
                Dim i As Long
                Set swPart = swModel
                Set featureMgr = swPart.FeatureManager
                Set swExtension = swPart.Extension
                Set flatPatternFolder = featureMgr.GetFlatPatternFolder
                If Not (flatPatternFolder Is Nothing) Then
                    featArray = flatPatternFolder.GetFlatPatterns
                    If IsArray(featArray) Then
                        For i = LBound(featArray) To UBound(featArray)
                            Set feat = featArray(i)
                            Success = swExtension.SelectByID2(feat.Name, "BODYFEATURE", 0, 0, 0, True, 0, Nothing, 0)
                        Next i
                    End If
                End If
                Options = [SheetMetalOptions]
                Success = swPart.ExportToDWG2(convFilePath, docFileName, swExportToDWG_ExportSheetMetal, Not(MultiBodyExport), varAlignment, False, False, Options, Null)
                If Success = False Then
                    If config = "All" Then
                        Log "The file '" & docFileName & "' and configuration '" & config & "' can't be converted to the file extension '" & ext & "'."
                    Else
                        Log "The file '" & docFileName & "' can't be converted to the file extension '" & ext & "'."
                    End If
                End If
            #Else
                Log "Unsupported version ( SOLIDWORKS 2017 or earlier) is found on the task host"
            #End If
        Else 
            Log "Unsupported SOLIDWORKS file extension "
        End If
    Else
    ' Convert the document
    Success = swExtension.SaveAs(convFilePath, swSaveAsCurrentVersion, swSaveAsOptions_Silent, Nothing, errors, warnings)
    'restore original values
    ' Save failed?
    If Success = False Then
        If config = "All" Then
            If errors = swerr_InvalidFileExtension Then
                Log "The file '" & docFileName & "' and configuration '" & config & "' can't be converted to the file extension '" & ext & "'."
            Else
                Log "Method call ModelDocExtension::SaveAs for document '" & docFileName & "' and configuration '" & config & "' failed. Error code " & errors & " returned."
                If (((errors And swerr_SaveAsNotSupported) <> 0) And ((warnings And swwarn_MissingOLEObjects) <> 0)) Then
                    Log "This document contains OLE objects. Such objects can't be converted outside of SolidWorks. Please open the document and perform the conversion from SolidWorks."
                End If 
            End If
        Else
            Log "Method call ModelDocExtension::SaveAs for document '" & docFileName & "' failed. Error code " & errors & " returned."
        End If
    End If
End If

DoSave = Success
End Function

Function bIsSupportedExtension(oExtension) As Boolean
    
    oExtension = LCase( oExtension )
    
    If oExtension = "prt" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "asm" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "drw" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "dxf" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "dwg" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "psd" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "ai" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "lfp" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "sldlfp" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "prtdot" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "asmdot" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "drwdot" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "x_t" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "x_b" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "xmt_txt" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "xmt_bin" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "igs" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "iges" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "step" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "stp" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "sat" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "vda" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "wrl" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "stl" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "cgr" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "wrl" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "xpr" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "xas" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "ipt" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "iam" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "par" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "psm" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "ckd" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "emn" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "brd" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "bdf" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "idb" Then
       bIsSupportedExtension = True
    ElseIf oExtension = "3dm" Then
       bIsSupportedExtension = True
    Else
        bIsSupportedExtension = False
    End If
       
End Function

Sub main()
    bNeedRestore = false
    On Error GoTo Fail:

    Set FileSystemObj = CreateObject("Scripting.FileSystemObject")
    docFileName = "<Filepath>"
    
    ' Get SW interface object
    Set swApp = Application.SldWorks
    swApp.Visible = True 
    Convert docFileName
    
    Exit Sub
       
Fail:
    Log "Error while converting file '" & docFileName & "': " & vbCrLf & _
        "An unexpected error occurred while executing the generated script. Script syntax error?" & vbCrLf & _
        "Error number: " & Err.Number & vbCrLf & _
        "Error description: '" & Err.Description & "'" & vbCrLf
End Sub
