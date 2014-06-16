/**
 * I am a Sticker pre-processor
 * I take any LESS files as input and output CSS files :)
 */
component output=false {
	public Less function init() output=false {
		var rhinoWrapper = new sticker.util.RhinoWrapper( "/sticker/lib/rhino-1.7R4.jar" );

		rhinoWrapper.loadJs( ExpandPath( "/sticker/lib/less/source-map-0.1.31.js"         ) );
		rhinoWrapper.loadJs( ExpandPath( "/sticker/preprocessors/javascript/lessProxy.js" ) );
		rhinoWrapper.loadJs( ExpandPath( "/sticker/lib/less/less-1.7.1.js"                ) );

		_setRhinoWrapper( rhinoWrapper );

		return this;
	}

	public void function process( required array source, required string destination ) output=false {
		var css          = "";
		var rhinoWrapper = _getRhinoWrapper();

		if ( arguments.source.len() > 1 ) {
			throw(
				  type    = "sticker.Less.tooManyInputFiles"
				, message = "The LESS preprocess for sticker can only convert a single LESS file into a single CSS file."
				, details = "Received destination [#arguments.destination#] and source files #SerializeJson( arguments.source )#"
			);
		}

		var result = rhinoWrapper.callJs( "compileLess", [ FileRead( arguments.source[1] ), arguments.source[1] ] );

		FileWrite( arguments.destination, result[ "css" ] );
	}

// PRIVATE METHODS


// GETTERS AND SETTERS
	private any function _getRhinoWrapper() output=false {
		return _rhinoWrapper;
	}
	private void function _setRhinoWrapper( required any rhinoWrapper ) output=false {
		_rhinoWrapper = arguments.rhinoWrapper;
	}
}