SuperStrict

Import Vertex.BNetEx

Const FinRSV:Int = %10000000 

Const optcode_continuation:Byte = %0000  '0 
Const optcode_text:Byte 		= %0001  '1
Const optcode_binary:Byte 		= %0010  '2
Const optcode_close:Byte		= %1000  '8
Const optcode_ping:Byte		= %1001  '9
Const optcode_pong:Byte		= %1010  '10

Rem 
bbdoc: The Client Type. You can access the User:Object and add you Userdata. 
End Rem 
Type TClient
	Field Stream:TTCPStream
	Field IP:String
	Field Port:Int 

	Field User:Object

	Field binaryMode:Byte
	
	Function Create:TClient(Stream:TTCPStream)
		Local Client:TClient = New TClient
		Client.Stream = Stream
		Client.IP = TNetwork.StringIP(Stream.GetLocalIP())
		Client.Port = Stream.GetLocalPort()
		Return Client
	End Function 

	Method FlushSend()
		If Self.Stream.SendSize > 0 Then MemFree(Self.Stream.SendBuffer)
	End Method

	Method Send(Str:String)
		Self.Stream.WriteString(Chr(FinRSV ~ optcode_text)+Chr(Str. length)+Str)' Fin = OK OpCode = Text
		While Self.Stream.SendMsg(); Wend 
	End Method 
	
	Method switchToBinary()
		Self.binaryMode = True
	End Method
	
End Type
