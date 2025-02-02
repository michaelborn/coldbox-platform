component extends="coldbox.system.web.ControllerDecorator" {

	this.decorator = "true";

	function configure(){

		variables.logger = getLogBox().getLogger( this );
	}

	/**
	 * Set the next event to run and relocate the browser to that event. If you are in SES mode, this method will use routing instead. You can also use this method to relocate to an absolute URL or a relative URI
	 * @event The name of the event to relocate to, if not passed, then it will use the default event found in your configuration file.
	 * @queryString The query string to append, if needed. If in SES mode it will be translated to convention name value pairs
	 * @addToken Wether to add the tokens or not to the relocation. Default is false
	 * @persist What request collection keys to persist in flash RAM automatically for you
	 * @persistStruct A structure of key-value pairs to persist in flash RAM automatically for you
	 * @ssl Whether to relocate in SSL or not. You need to explicitly say TRUE or FALSE if going out from SSL. If none passed, we look at the even's SES base URL (if in SES mode)
	 * @baseURL Use this baseURL instead of the index.cfm that is used by default. You can use this for SSL or any full base url you would like to use. Ex: https://mysite.com/index.cfm
	 * @postProcessExempt Do not fire the postProcess interceptors, by default it does
	 * @URL The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
	 * @URI The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
	 * @statusCode The status code to use in the relocation
	 */
	function relocate(
		event                = getSetting( "DefaultEvent" ),
		queryString          = "",
		boolean addToken     = false,
		persist              = "",
		struct persistStruct = structNew()
		boolean ssl,
		baseURL                   = "",
		boolean postProcessExempt = false,
		URL,
		URI,
		numeric statusCode = 0
	){
		var rc = getRequestService().getContext().getCollection();

		// copy over to rc
		for ( var thisArg in arguments ) {
			if ( structKeyExists( arguments, thisArg ) ) {
				rc[ "relocate_#thisArg#" ] = arguments[ thisArg ];
			}
		}

		// Post Process
		if ( arguments.postProcessExempt ) {
			getInterceptorService().announce( "postProcess" );
		}

		throw( message = "Relocating via relocate: #arguments.toString()#", type = "TestController.relocate" );
	}

	function runEvent(
		event                  = "",
		boolean prePostExempt  = false,
		boolean private        = false,
		boolean defaultEvent   = false,
		struct eventArguments  = {},
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template"
	 ){
		// useful debugging to pinpoint execution exceptions
		logger.debug(
			"=>Called decorator runEvent(#arguments.toString()#)",
			!len( arguments.event ) ? callStackGet() : ""
		);
		return getController().runEvent( argumentCollection = arguments );
	}

}
