Module fab.websocket
ModuleInfo "Version: 1.0"
ModuleInfo "Author: Fabrice Weinberg"
ModuleInfo "License: Public Domain"

ModuleInfo "Rewrite of the 'core' now implementing Draft 13"
ModuleInfo "First Release 1.0 Alpha implementing Draft 03"

SuperStrict

Import Vertex.BNetEx
Import Brl.StandardIO
Import Brl.Map
Import Brl.LinkedList
Import Bah.Base64
Import "TClient.bmx"
Import "TProtocol.bmx"
Import "TBinReader.bmx"
Import "crypto.bmx"


Const MAGIC_KEY:String = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

Rem
bbdoc: Main Type
End Rem 
Type TWebSocket

	Field Server:TTCPStream
	Field Protocol:TProtocol

	Function Create:TWebSocket(Protocol:Object, Port:Int = 8080)
		Local WS:TWebSocket = New TWebSocket
		WS.Server =  New TTCPStream
		WS.Server.Init()
		WS.Protocol = TProtocol(Protocol)
		WS.Server.SetLocalPort(Port)
		WS.Server.Listen()
		Return WS	
	End Function 

	Method Run()
		Local Join:TTCPStream =  Self.Server.Accept()
		If Join Then 
			?Debug
				Print "New client joined"					
			?
			Local Client:TClient = TClient.Create(Join)	
			Protocol.ClientList.AddLast(Client)
		End If 
		
		For Local Client:TClient = EachIn Protocol.ClientList
				If Client.Stream.GetState() <> 1 Then 				
					?Debug
						Print "--Disconnect"
						Print "- IP:"+Client.IP
					?
					Client.Stream.Close()
					Protocol.ClientList.Remove(Client)
					Continue
				End If 
				If Client.Stream.RecvAvail() Then 
						While Client.Stream.RecvMsg(); Wend
						
						Client.FlushSend()
						
						If Client.Stream.Size() > 0 Then 
							If Client.inBinaryMode() Then 	
								Local by:Byte[Client.Stream.Size()] 
								For Local i:Int = 0 To Client.Stream.Size()-1
									by[i] = Client.Stream.ReadByte()
								Next
								Local Message:String = processMessage(by, Client)
								If Message <> Null Then 
									Protocol.Respond(Message, Client)
								EndIf 									
							Else	
								Local Line:String
								While Not Client.Stream.Eof()
									Line = Client.Stream.ReadLine()
									Select Line[..Line.Find(" ")]
										Case "GET"
											Self.doHandshake(Client)
									End Select	
								Wend  							
						
							End If 
						End If 	
				EndIf 
		Next
	End Method
	
	Method doHandshake(Client:TClient)
			Local Header:TMap = New TMap,Line:String 	
			Repeat
				Line = Client.Stream.ReadLine()
				If Line <> "" Then 
					Local Items:String[] = SplitFirst(Line, ":")
					Header.Insert(Items[0].ToLower(), Items[1])
				End If
			Until Line = "" 			
						
			Local Handshake:String = String(Header.ValueForKey("sec-websocket-key"))
			
			
			
			'Base64(sha1(Handshake + MagicGUID)) 
			Local Accept:String = Handshake + MAGIC_KEY
			Accept = toRawBinary(sha1(Accept))
			Accept = TBase64.encode(Accept, Accept.length)
			
			
			Client.Stream.Flush() ' Make shure there is nothing in the Buffer.
			
			Client.Stream.WriteLine ("HTTP/1.1 101 Switching Protocols")
			Client.Stream.WriteLine ("Upgrade: websocket")
			Client.Stream.WriteLine ("Connection: Upgrade")
			Client.Stream.WriteLine ("Sec-WebSocket-Origin: "+String(Header.ValueForKey("origin")))
			Client.Stream.WriteLine ("Sec-WebSocket-Location: ws://"+String(Header.ValueForKey("host"))+"/")
			Client.Stream.WriteLine ("Sec-WebSocket-Accept: " + Accept)
			Client.Stream.WriteLine ("Sec-WebSocket-Version: 13")
			
			
			If Protocol.Name Then 
				Client.Stream.WriteLine("Sec-WebSocket-Protocol: "+Protocol.Name+Chr(13)+Chr(10))
			Else
				Client.Stream.WriteLine(Chr(13)+Chr(10))
			End If 
						
			Client.switchToBinary()
			
			While Client.Stream.SendMsg(); Wend
	End Method
End Type

'This Function might be moved!
Function processMessage:String(Message:Byte[], client:TClient)
	Local payloadData:String = Null 
	Local reader:TBinReader = TBinReader.Create(Message)
	Local isMasked:Byte = False
	If (reader.readNextBit() = 1) Then 
		If reader.readRangeBin(3) = "000" Then 
			Local opCode:Byte = reader.getByte()
			
			Select opCode			
				Case opcode_text
					isMasked = reader.readNextBit()
			
					Local payloadLength:Int = reader.getRangeInt(7)
					If payloadLength = 126 Then 
						payloadLength = reader.getRangeInt(16)
					Else If payloadLength = 127 Then 
						payloadLength = reader.getRangeInt(64)							
					EndIf 
					
					payloadLength:*8
					
					Local maskingKey:String 
					If (isMasked) Then 
						maskingKey =reader.readRangeString(32)
					End If 
					
					payloadData = reader.readRangeString(payloadLength)
					
					If (isMasked) Then 
						payloadData = unMask(payloadData,maskingKey)
					End If 	
				Case opcode_binary
					client.close("Binary Data is not supported", close_dataError)	
			End Select			
		End If 
	End If
	Return payloadData
End Function 


Function unMask:String(Data:String, MaskingKeyData:String)
	Local result:String 
	For Local i:Int = 0 To Data.length-1
		Local j:Int = i Mod 4
		result :+ Chr(data[i] ~ MaskingKeyData[j])		
	Next
	Return result
End Function 


Function toRawBinary:String(in:String)
	Local out:String
 	For Local i:Int = 0 Until in.Length-1 Step 2
  		out:+Chr(Int("$" + Chr(in[i])) * 16 + Int("$" + Chr(in[i + 1])))
	Next
 	Return out
End Function

Function SplitFirst:String[](Str:String, Char:String, Cut:Int = 2)
	Local tmpStr:String[2],aPos:Int = Str.Find(Char)
	tmpStr[0] = Str[..aPos]
	tmpStr[1] = Str[aPos+Cut..]
	Return tmpStr
End Function 
