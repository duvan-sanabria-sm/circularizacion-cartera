Sub FormatStatementReport(sheetName As String)

    Dim ws As Worksheet
    Dim headerRow As Long
    Dim dataStartRow As Long
    Dim lastRow As Long
    Dim lastCol As Long
    Dim totalRow As Long
    Dim tableRange As Range
    Dim bordersArray As Variant
    Dim borderType As Variant
    
    ' Referencia a la hoja
    Set ws = ThisWorkbook.Sheets(sheetName)
    
    ' Fila del encabezado y fila inicial de datos
    headerRow = 7
    dataStartRow = 8
    
    ' Buscar la última fila con datos tomando como base la columna B
    lastRow = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row
    
    ' Validar si realmente hay datos debajo del encabezado
    If lastRow < dataStartRow Then
        MsgBox "No se encontraron datos para formatear.", vbExclamation
        Exit Sub
    End If
    
    ' Definir la fila donde se colocará el total
    totalRow = lastRow + 1
    
    ' Definir la última columna de la tabla usando la fila del encabezado
    lastCol = ws.Cells(headerRow, ws.Columns.Count).End(xlToLeft).Column
    
    ' Limpiar posibles valores anteriores en la fila del total
    ws.Range("I" & totalRow & ":K" & totalRow).ClearContents
    
    ' Escribir el texto del total
    ws.Range("I" & totalRow).Value = "TOTAL CARTERA PENDIENTE:"
    
    ' Escribir la fórmula de suma en la columna K
    ws.Range("K" & totalRow).Formula = "=SUM(K" & dataStartRow & ":K" & lastRow & ")"
    
    ' Poner texto y total en rojo y negrita
    ws.Range("I" & totalRow).Font.Bold = True
    ws.Range("K" & totalRow).Font.Bold = True
    ws.Range("I" & totalRow).Font.Color = RGB(255, 0, 0)
    ws.Range("K" & totalRow).Font.Color = RGB(255, 0, 0)
    
    ' Formato número
    ws.Range("K" & totalRow).NumberFormat = "#,##0.00"
    
    ' Definir el rango completo de la tabla incluyendo la fila del total
    Set tableRange = ws.Range(ws.Cells(headerRow, "B"), ws.Cells(totalRow, lastCol))
    
    ' Aplicar bordes azules al rango completo
    bordersArray = Array(xlEdgeLeft, xlEdgeRight, xlEdgeTop, xlEdgeBottom, xlInsideVertical, xlInsideHorizontal)
    
    For Each borderType In bordersArray
        With tableRange.Borders(borderType)
            .LineStyle = xlContinuous
            .Weight = xlThin
            .Color = RGB(48, 84, 150)
        End With
    Next borderType
    
    ' Centrar horizontal y verticalmente todo el rango
    With tableRange
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
    End With
    
    ' Alinear a la izquierda la columna Nombre
    ws.Range("E" & headerRow & ":E" & totalRow).HorizontalAlignment = xlLeft
    
    ' Alinear a la derecha columnas numéricas
    ws.Range("G" & headerRow & ":G" & totalRow).HorizontalAlignment = xlRight
    ws.Range("J" & headerRow & ":J" & totalRow).HorizontalAlignment = xlRight
    ws.Range("K" & headerRow & ":K" & totalRow).HorizontalAlignment = xlRight
    
    ' Colocar en rojo los días vencidos
    ws.Range("H" & dataStartRow & ":H" & lastRow).Font.Color = RGB(255, 0, 0)
    
    Set tableRange = Nothing
    Set ws = Nothing

End Sub