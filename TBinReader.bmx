SuperStrict 

Import Brl.StandardIO

Type TBinReader
	Field by:Byte[]
	Field arr:Byte[]
	Field currPos:Int = 0

	Function Create:TBinReader(by:Byte[])
		Local reader:TBinReader = New TBinReader
		reader.by = by
		reader.arr = reader.arr[..by.Length*8*4]
		For Local i:Int = 0 To by.length-1
			Local currByte:Byte = by[i]		
			For Local b:Int = 7 To 0 Step -1				
				reader.arr[(i*8)+b] = currByte&1
				currByte:Shr 1
			Next 
		Next
		Return reader
	End Function 
	
	Rem
	Just for testing
	Function CreateFromString:TBinReader(Str:String)
		Local reader:TBinReader = New TBinReader
		reader.arr = reader.arr[..Str.Length*8*4]
		For Local i:Int = 0 To Str.length-1
			Local currByte:Byte = Byte(Str[i])
			For Local b:Int = 7 To 0 Step -1
				reader.arr[(i*8)+b] = currByte&1
				currByte:Shr 1
			Next 
		Next
		Return reader
	End Function 
	End Rem 
	
	Method seek(p:Int)
		Self.currPos = p
	End Method
	
	Method getCurrentPos:Int()
		Return Self.currPos
	End Method
	
	Method readNextBit:Byte()
		Local b:Byte = Self.arr[Self.currPos]
		Self.currPos:+1
		Return b
	End Method
	
	Method getByte:Byte()
		Local byS:String = "%"+Self._byteArrToString(Self.arr[Self.currPos..Self.currPos+4])
		Self.currPos:+4
		Return Byte(byS)
	End Method
	
	Method getRangeInt:Int(t:Int)
		If Self.currPos+t-1>Self.arr.length Then RuntimeError "Out of Range"
		Local res:String = "%"+Self._byteArrToString(Self.arr[Self.currPos..Self.currPos+t])
		Self.currPos:+t
		Return Int(res)
	End Method	
	
	Method getRangeLong:Long(t:Int)
		If Self.currPos+t-1>Self.arr.length Then RuntimeError "Out of Range"
		Local res:String = "%"+Self._byteArrToString(Self.arr[Self.currPos..Self.currPos+t])
		Self.currPos:+t
		Return Long(res)
	End Method
			
	Method readRangeString:String(t:Int)
		If Self.currPos+t-1>Self.arr.length Then RuntimeError "Out of Range"
		Local by:Byte[] = Self.arr[Self.currPos..Self.currPos+t]
		Local str:String
		For Local i:Int = 0 To by.length-1 Step 8
			str:+Chr(Int("%"+Self._byteArrToString(by[i..i+8])))
		Next
		Self.currPos:+t
		Return str
	End Method			
	
	Method readRangeBin:String(t:Int)
		If Self.currPos+t-1>Self.arr.length Then RuntimeError "Out of Range"
		Local res:String = Self._byteArrToString(Self.arr[Self.currPos..Self.currPos+t])
		Self.currPos:+t
		Return res
	End Method
	
	
	Method _byteArrToString:String(newa:Byte[])
		Local res:String = ""
		For Local i:Int = 0 To newa.length-1
			res:+newa[i]
		Next
		Return res
	End Method 
	
End Type

