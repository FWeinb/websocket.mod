 SuperStrict

Import brl.Timer
Import fab.websocket

Local 	Timer:TTimer = CreateTimer(60)
Local 	Protocol:TChat_Protocol = New TChat_Protocol
		Protocol.Init("Chat") ' Init with the Name of the WebSocket-Protocol
Local 	WebSocket:TWebSocket = TWebSocket.Create(Protocol)

While Not AppTerminate()
	WaitTimer Timer 	
	
	WebSocket.Run()		
Wend

Type TChat_Protocol Extends TProtocol

	Method Respond(Msg:String, Client:TClient)
				If Msg.Contains(Chr(0)) Then 
					Local Part:String[] = SplitFirst(Msg,Chr(0), 1)
					Select Part[0]
						Case "name"
							Client.User = String(Part[1])
							Client.Send("Server: Wilkommen "+String(Client.User))
							Local Name:String = String(Client.User)
							For Local OtherClient:TClient = EachIn Self.ClientList
								If Client <> OtherClient Then 
									OtherClient.Send(Name + " joined")
								End If  
							Next		
								
					End Select
				Else			
					Local Name:String = String(Client.User)
					For Local OtherClient:TClient = EachIn Self.ClientList
						If Client <> OtherClient Then 
							OtherClient.Send(Name+": "+Msg)
						End If  
					Next			
				EndIf
	End Method 
End Type

