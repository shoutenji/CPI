// Wrapper class for Engine.JsonObject with added functionality
class CPIJsonObject extends JsonObject;

struct CPIObject
{
	var string Key;
	var CPIJsonObject cpiObject;
};
var array<CPIObject> CPIObjectArray;

struct AssocArray
{
	var string Key;
	var array<CPIJsonObject> objArray;
};
var array<AssocArray> JsonArrays;

function SetArray(string key, array<CPIJsonObject> objects)
{
	local AssocArray newArray;
	newArray.Key = key;
	newArray.objArray = objects;
	JsonArrays.AddItem(newArray);
}

// Internal use only
function CPISetObject(const string key, CPIJsonObject objectarg)
{
	local CPIObject newObject;
	newObject.Key = key;
	newObject.cpiObject = objectarg;
	CPIObjectArray.AddItem(newObject);
}

function SetObject(const string key, JsonObject objectarg)
{
	CPISetObject(key, CPIJsonObject(objectarg));
}

// Internal use only
function CPIJsonObject CPIGetObject(const string key)
{
	local CPIObject newObject;
	
	Foreach CPIObjectArray(newObject)
	{
		if( newObject.Key == key )
			return newObject.cpiObject;
	}
}

function JsonObject GetObject(const string key)
{
	return CPIGetObject(key);
}

function array<CPIJsonObject> GetArray(string key)
{
	local AssocArray newArray;
	
	Foreach JsonArrays(newArray)
	{
		if( newArray.Key == key)
			return newArray.objArray;
	}
}

// Internal use only
static function string DoCPIEncodeJson(CPIJsonObject objectarg)
{
	local string buffer, tmpbuffer;
	local CPIJsonObject jsonObj;
	local AssocArray jsonArray;
	local int index, index2;
	local CPIObject aObject;
	
	buffer = "";
	// This will grab primitive values while ignoring our custom arrays
	buffer $= class'JsonObject'.static.EncodeJson(objectarg);
	buffer = Left(buffer, Len(buffer)-1);
	//buffer = Right(buffer, Len(buffer)-1);
	if( objectarg.JsonArrays.Length > 0 )
	{
		if( Len(buffer) > 1 )
			buffer $= ",";
		Foreach objectarg.JsonArrays(jsonArray, index)
		{
			buffer $= "\""$jsonArray.Key$"\"";
			buffer $= ":";
			buffer $= "[";
			Foreach objectarg.JsonArrays[index].objArray(jsonObj, index2)
			{
				tmpbuffer = class'CPIJsonObject'.static.CPIEncodeJson(jsonObj);
				// Commate between objects in an AssocArray
				if( index2 < objectarg.JsonArrays[index].objArray.length-1 )
					tmpbuffer $= ",";
				buffer $= tmpbuffer;
				tmpbuffer = "";
			}
			buffer $= "]";
			if( index < objectarg.JsonArrays.length-1 )
				buffer $= ",";
		}
	}
	if( objectarg.CPIObjectArray.Length > 0 )
	{
		if( Len(buffer) > 1 )
			buffer $= ",";
		Foreach objectarg.CPIObjectArray(aObject, index2)
		{
			tmpbuffer = class'CPIJsonObject'.static.CPIEncodeJson(aObject.cpiObject);
			buffer $= "\""$aObject.Key$"\"";
			buffer $= ":";
			buffer $= tmpbuffer;
			if( index2 < objectarg.CPIObjectArray.Length-1 )
					buffer $= ",";
			tmpbuffer = "";
		}
	}
	return buffer;
}

// Use this function for encoding
static function string CPIEncodeJson(CPIJsonObject objectarg)
{
	return DoCPIEncodeJson(objectarg)$"}";
}


