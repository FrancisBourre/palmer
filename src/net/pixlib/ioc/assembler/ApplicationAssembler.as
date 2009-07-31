package net.pixlib.ioc.assembler
{
	import net.pixlib.ioc.assembler.builder.DisplayObjectBuilder;

	import flash.net.URLRequest;

	/**
	 * @author Francis Bourre
	 */
	public interface ApplicationAssembler
	{
		function registerID(				ID							: String			) 		: Boolean;

		function setDisplayObjectBuilder( 	displayObjectExpert 		: DisplayObjectBuilder ) 	: void;
		function getDisplayObjectBuilder() 															: DisplayObjectBuilder;
											
		function buildRoot(					ID							: String			)		: void;

		function buildDisplayObject( 		ID 							: String,
											parentID 					: String, 
											url 						: URLRequest= null,
											isVisible 					: Boolean	= true,
											type 						: String	= null	) 		: void;
		
		function buildDLL( 					url 						: URLRequest 		) 		: void;
		
		/**
		 * Builds <code>Resource</code> object.
		 * 
		 * @param	ID				Registration ID.
		 * @param	url				File URL.
		 * @param	type			(optional) Resource type : 'binary' or 'text'
		 * @param	deserializer	(optional) Resource content deserializer
		 */	
		function buildResource(				id							: String,
											url							: URLRequest,
											type						: String = null,
											deserializer 				: String = null		)	: void;
		
		function buildProperty( 			ownerID 					: String, 
											name 						: String 	= null, 
											value 						: String 	= null, 
											type 						: String 	= null, 
											ref 						: String 	= null, 
											method 						: String 	= null	) 		: void;

		function buildObject( 				id 							: String, 
											type 						: String 	= null, 
											args 						: Array 	= null, 
											factory 					: String 	= null, 
											singleton 					: String 	= null  ) 		: void;
		
		function buildMethodCall( 			id 							: String, 
											methodCallName 				: String, 
											args 						: Array 	= null 	) 		: void;

		function buildChannelListener( 		id 							: String, 
											channelName 				: String, 
											args 						: Array 	= null 	) 		: void;
	}
}