/**
 * I provide methods for running preprocessor definitions
 */

component output=false {

	/**
	 * I execute the passed preProcessorDefinition method
	 *
	 * @preProcessorDefinition.hint an instantiated sticker.util.PreProcessorDefinition bean that will be executed
	 * @rootDirectory.hint          root directory used to resolve all relative paths in the definition
	 */
	public void function run( required PreProcessorDefinition definition, required string rootDirectory ) output=false {
		var options            = IsNull( definition.getOptions() ) ? {} : definition.getOptions();
		var preProcessorObject = _getPreProcessorInstance( definition.getPreProcessor(), options );
		var root               = ReReplace( arguments.rootDirectory, "(^/)$", "\1/" );
		var src                = definition.getSource();
		var dest               = definition.getDestination();
		var destinationMap     = StructNew( "linked" );

		src = _resolveWildcardFileArray( arguments.rootDirectory, src );
		if ( !IsNull( definition.getFilter() ) ){
			src = src.filter( definition.getFilter() );
		}

		if ( IsSimpleValue( dest ) ) {
			destinationMap[ dest ] = src;
		} elseif ( IsClosure( dest ) ) {
			for( var srcPath in src ){
				var calculatedDest = dest( Right( srcPath, Len( srcPath ) - Len( root ) ) );

				destinationMap[ calculatedDest ] = destinationMap[ calculatedDest ] ?: [];
				destinationMap[ calculatedDest ].append( srcPath );
			}
		}

		for( var destPath in destinationMap ){
			preProcessorObject.process(
				  source             = destinationMap[ destPath ]
				, destination        = root & ReReplace( destPath, "^/", "" )
				, argumentCollection = options
			);
		}
	}

// PRIVATE HELPERS
	private array function _resolveWildcardFileArray( required string rootDirectory, required array globPatternArray ) output=false {
		var expandedRoot = ExpandPath( arguments.rootDirectory );
		var matches      = new Wildcard().directoryList( expandedRoot, arguments.globPatternArray );


		for( var i=1; i <= matches.len(); i++ ){
			var relative = Right( matches[i], Len( matches[i] ) - Len( expandedRoot ) );
			    relative = Replace( relative, "\", "/", "all" );

			matches[i] = arguments.rootDirectory & relative;
		}

		return matches;
	}

	private any function _getPreProcessorInstance( required any preProcessor, required struct initOptions ) output=false {

		if ( IsSimpleValue( arguments.preProcessor ) ) {
			var obj  = CreateObject( arguments.preProcessor );
			var meta = GetMetaData( obj );
			var functions = ( meta.functions ?: [] );

			for( var func in functions ){
				if ( ( func.name ?: "" ) == "init" ) {
					return obj.init( argumentCollection = initOptions );
				}
			}
			return obj;
		}

		return arguments.preProcessor;
	}

}