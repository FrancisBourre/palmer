package com.bourre.ioc.assembler
{
	import flash.net.URLRequest;	

	/**
	 * @author Francis Bourre
	 */
	public interface ApplicationAssembler
	{
		function registerID(				ID							: String			) 		: Boolean;

		function setDisplayObjectBuilder( 	displayObjectExpert 		: DisplayObjectBuilder ) 	: void;
		function getDisplayObjectBuilder() 															: DisplayObjectBuilder;

		function buildLoader( 				ID 							: String, 
											url 						: URLRequest, 
											progressCallback 			: String 	= null, 
											nameCallback 				: String 	= null, 
											timeoutCallback 			: String 	= null, 
											parsedCallback 				: String 	= null, 
											methodsCallCallback 		: String 	= null, 
											objectsBuiltCallback		: String 	= null, 
											channelsAssignedCallback	: String 	= null, 
											initCallback 				: String 	= null	) 		: void;
											
		function buildRoot(					ID							: String			)		: void;

		function buildDisplayObject( 		ID 							: String,
											parentID 					: String, 
											url 						: URLRequest= null,
											isVisible 					: Boolean	= true,
											type 						: String	= null	) 		: void;

		function buildDLL( 					url 						: URLRequest 		) 		: void;

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