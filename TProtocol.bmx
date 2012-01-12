SuperStrict
Import brl.LinkedList
Import "TClient.bmx"
Rem
bbdoc: The abstract protocol you have to implement.
End Rem 
Type TProtocol Abstract
	Field Name:String
	
	Field ClientList:TList
	
	Method New()
		Self.ClientList = New TList
	End Method
	
	Method Init(Name:String)
		Self.Name = Name
	End Method
	

	Method Respond(Msg:String, Client:TClient) Abstract 
End Type
