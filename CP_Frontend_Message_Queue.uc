class CP_Frontend_Message_Queue extends Object;

struct Message
{
	var string MessageTitle, MessageBody;
	var EProgressMessageType MessageType;
};

var array<Message> Messages;

function AddMessage(string strMsgTitle, string strMsgBody, EProgressMessageType EMessageType)
{
	local Message newMessage;
	newMessage.MessageTitle = strMsgTitle;
	newMessage.MessageBody = strMsgBody;
	newMessage.MessageType = EMessageType;

	Messages.AddItem(newMessage);

	`Log("Message Added to Message_Queue");
	`Log(strMsgTitle @ ":" @ strMsgBody @ ":" @ EMessageType);
}

function bool HasMessages()
{
	if(Messages.Length != 0)
		return true;

	return false;
}

function Message GetLastMessage()
{
	local Message NoMessage;

	if(Messages.Length != 0)
	{
		return Messages[Messages.Length - 1];
	}

	return NoMessage; //not sure about the logic here... i expect it never to come here if theres no messages...
}

function RemoveAllMessages()
{
	Messages.Remove(0,Messages.Length);
}

DefaultProperties
{
}
