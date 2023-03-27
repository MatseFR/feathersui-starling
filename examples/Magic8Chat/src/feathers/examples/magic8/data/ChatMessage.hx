package feathers.examples.magic8.data;

class ChatMessage 
{
	public static inline var TYPE_USER:String = "user";
	public static inline var TYPE_MAGIC_8BALL:String = "magic8Ball";
	
	public function new(type:String, message:String) 
	{
		this.type = type;
		this.message = message;
	}
	
	public var type:String;
	public var message:String;
}