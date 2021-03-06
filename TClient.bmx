SuperStrict

Import Vertex.BNetEx


Include "const.bmx"

Rem 
bbdoc: The Client Type. You can access the User:Object and add you Userdata. 
End Rem 
Type TClient
	Field Stream:TTCPStream
	Field IP:String
	Field Port:Int 

	Field User:Object

	Field webSocketMode:Byte
	Field version:Int
	
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

	Method Send(message:String)
		If (Self.version = 3) Then 
			Self.Stream.WriteString(Chr(0)+message+Chr(255))
		Else If (Self.version > 3) Then 
			Self.Stream.WriteString(Chr(FinRSV ~ opcode_text)+TClient.getPayloadLength(message.length)+message)' Fin = OK OpCode = Text
		End If 
		While Self.Stream.SendMsg(); Wend 
	End Method
	
	
	Method Close(message:String, reason:Int = close_ok)
			message:+Chr(Byte(reason Shr 8))
			message:+Chr(Byte(reason))
			Self.Stream.WriteString(Chr(FinRSV ~ opcode_close)+TClient.getPayloadLength(message.length)+message)
			While Self.Stream.SendMsg(); Wend 
	End Method 
	
	
	Method Ping() 
	
	End Method
	
	Method Pong()
	
	End Method
	
	
	Method inWebSocketMode:Byte() 
		Return Self.webSocketMode
	End Method
		
	Method switchToWebSocket()
		Self.webSocketMode = True
	End Method
	
	Method setVersion(ver:Int)
		Self.version = ver
	End Method
	Method getVersion:Int()
		Return Self.version
	End Method
	
	Function getPayloadLength:String(length:Int)
		Local res:String = ""
		If length < 126 Then 
			res:+Chr(length)
		Else If length < 65536 
			res:+Chr(126)
			res:+Chr(Byte(length Shr 8))	
			res:+Chr(Byte(length))	
		Else
			res:+Chr(127) ' I only get a Integer for this… should be enought
			res:+Chr(0)
			res:+Chr(0)
			res:+Chr(0)
			res:+Chr(0)
			res:+Chr(Byte(length Shr 24)) 
			res:+Chr(Byte(length Shr 16))
			res:+Chr(Byte(length Shr 8))
			res:+Chr(Byte(length))
		End If
		Return res
	End Function 
	
End Type
