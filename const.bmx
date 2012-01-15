
Const FinRSV:Int = %10000000 



Const opcode_continuation:Byte = %0000  '0  
Const opcode_text:Byte 		= %0001  '1
Const opcode_binary:Byte 		= %0010  '2
Const opcode_close:Byte		= %1000  '8
Const opcode_ping:Byte		= %1001  '9
Const opcode_pong:Byte		= %1010  '10





Const close_ok:Int				= 1000	' indicates a normal closure, meaning that the purpose for
    									' which the connection was established has been fulfilled.


Const close_goingAway:Int 		= 1001	' indicates that an endpoint is "going away", such as a server
									' going down or a browser having navigated away from a page.

Const close_protocolError:Int	= 1002	' indicates that an endpoint is terminating the connection due
									' to a protocol error.


Const close_dataError:Int		= 1003	' indicates that an endpoint is terminating the connection
     								' because it has received a Type of data it cannot accept (e.g., an
									' endpoint that understands only text data MAY send this If it
									' receives a binary message).
