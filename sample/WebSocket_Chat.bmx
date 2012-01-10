SuperStrict

Import brl.Timer
Import fab.websocket

Local 	Timer:TTimer = CreateTimer(60)
Local 	Protocol:TChat_Protocol = New TChat_Protocol
		Protocol.Init("Chat")
Local 	WebSocket:TWebSocket = TWebSocket.Create(Protocol)

While Not AppTerminate()
	WaitTimer Timer 	
	
	WebSocket.Run()		
Wend

Type TChat_Protocol Extends TProtocol

	Method Respond(Msg:String, Client:TClient)
				If Msg.Contains(":") Then 
					Local Part:String[] = SplitFirst(Msg,":", 1)
					Select Part[0]
						Case "name"
							Client.User = String(Part[1])
							Client.Send("Server: Wilkommen "+String(Client.User))
							While Client.Stream.SendMsg(); Wend
							Local Name:String = String(Client.User)
							For Local OtherClient:TClient = EachIn Self.ClientList
								If Client <> OtherClient Then 
									OtherClient.Send(Name + " joined")
									While OtherClient.Stream.SendMsg(); Wend
								End If  
							Next		
								
					End Select
				Else			
					Local Name:String = String(Client.User)
					For Local OtherClient:TClient = EachIn Self.ClientList
						If Client <> OtherClient Then 
							OtherClient.Send(Name+": "+Msg)
							While OtherClient.Stream.SendMsg(); Wend
						End If  
					Next			
				EndIf
	End Method 
End Type

