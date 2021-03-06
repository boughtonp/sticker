/**
 * I represent an asset bundle and provide methods
 * for configuring myself
 *
 */
component output=false {

// CONSTRUCTOR
	/**
	 * I am the constructor, pass me the root URL of this bundle
	 *
	 * @rootUrl.hint The root URL of the bundle, all generated URLs for each asset in the bundle will be relative to this
	 */
	public Bundle function init( required string rootDirectory, required string rootUrl ) output=false {
		_setRootDirectory( arguments.rootDirectory );
		_setRootUrl( arguments.rootUrl );
		_setAssetCollection( {} );
		return this;
	}

// PUBLIC API METHODS
	/**
	 * I return a structure of all the asset definitions stored in the bundle
	 */
	public struct function getAssets() output=false {
		return _getAssetCollection();
	}

	/**
	 * I add a single asset to the bundle
	 *
	 * @id.hint   ID to use for the asset - you will use this later in calls to sticker.include( idOfAsset )
	 * @url.hint  URL of the asset. Used only for externally hosted assets
	 * @path.hint Path to the file, relative to the root URL of this bundle
	 * @type.hint Type of the file, either "js" or "css". If not supplied, it will be inferred from the file extension
	 */
	public Bundle function addAsset(
		  required string id
	    ,          string url
	    ,          string path
	    ,          string type
	    ,          string ie    = ""
	    ,          string media = ""
	) output=false {
		var assetCollection = _getAssetCollection();
		var asset = {};

		if ( StructKeyExists( arguments, "path" ) ) {
			asset.path = _resolvePath( arguments.path );
			asset.url = _getRootUrl() & asset.path;
		} else if ( StructKeyExists( arguments, "url" ) ) {
			asset.url = arguments.url;
		}

		asset.type         = arguments.type ?: ListLast( asset.url, "." );
		asset.before       = [];
		asset.after        = [];
		asset.dependsOn    = [];
		asset.dependents   = [];
		asset.ie           = arguments.ie;
		asset.media        = arguments.media;

		assetCollection[ arguments.id ] = new Asset( argumentCollection=asset );

		return this;
	}

	/**
	 * I add multiple assets at the same time by finding
	 * files within the given directory that match the given
	 * matching pattern.
	 *
	 * @directory.hint   Directory in which to find files, relative to the bundle's root directory
	 * @match.hint       Wildcard pattern with which to match files, e.g. "*.min.css", or a function that returns whether or not the passed 'path' shoudl match
	 * @idGenerator.hint Function to generate an asset ID for each matched file. Takes a 'path' parameter that path of the matched file, relative to the root of the bundle
	 */
	public Bundle function addAssets(
		  required string   directory
		, required any      match
		, required function idGenerator
	) output=false {
		var rootDir   = _getRootDirectory();
		if ( NOT Server.ColdFusion.ProductName EQ 'ColdFusion Server' )
			rootDir = expandPath( rootDir );
		local.directory = rootDir;
		var matches   = "";

		if ( Left( arguments.directory, 1 ) != "/" ) {
			local.directory &= "/";
		}
		local.directory &= arguments.directory;

		if ( DirectoryExists( local.directory ) ) {
			var filter = IsSimpleValue( arguments.match ) ? arguments.match : "*";
			matches = DirectoryList( local.directory, true, "path", filter );

			for( var path in matches ){
				var relativePath = Replace( Replace( path, rootDir, "" ), "\", "/", "all" );
				if ( NOT relativePath.startsWith('/') AND NOT refind('^[A-Za-z]:',relativePath) )
					relativePath = '/' & relativePath;

				if ( !IsClosure( arguments.match ) || arguments.match( relativePath ) ) {
					addAsset(
						  id   = arguments.idGenerator( relativePath )
						, path = relativePath
					);
				}
			}

		}

		return this;
	}

// PRIVATE HELPERS
	private string function _resolvePath( required string path ) output=false {
		var fullPath  = _getRootDirectory();
		var directory = "";
		var file      = "";
		var matches   = "";
		var resolved  = GetDirectoryFromPath( arguments.path );

		if ( Left( arguments.path, 1 ) != "/" ) {
			fullPath &= "/";
		}
		fullPath &= arguments.path;

		directory = GetDirectoryFromPath( fullPath );
		file      = ListLast( fullPath, "\/" );

		if ( Server.ColdFusion.ProductName EQ 'ColdFusion Server' AND !DirectoryExists( directory ) )
			directory = expandPath(directory);

		if ( !DirectoryExists( directory ) ) {
			throw( type="Sticker.missingAsset", message="The asset [#arguments.path#] could not be found in the bundle who's root directory is at [#_getRootDirectory()#]" );
		}

		matches = DirectoryList( directory, false, "name", file );
		if ( !matches.len() ) {
			throw( type="Sticker.missingAsset", message="The asset [#arguments.path#] could not be found in the bundle who's root directory is at [#_getRootDirectory()#]" );
		}
		if ( matches.len() > 1 ) {
			throw( type="Sticker.multipleAssets", message="The asset path [#arguments.path#] returned multiple assets. Wildcard asset paths must resolve to a single file." );
		}

		return resolved & matches[1];
	}

	/**
	 * I return an Asset object for the given asset id
	 *
	 * @id.hint ID of the asset to fetch
	 */
	public Asset function asset( required string id ) output=false {
		var assetCollection = _getAssetCollection();

		if ( !assetCollection.keyExists( arguments.id ) ) {
			throw( type="Sticker.missingAsset", message="The asset with id [#arguments.id#] could not be found in this bundle. Registered bundles: #SerializeJson( assetCollection.keyArray() )#" );
		}

		return assetCollection[ arguments.id ];
	}

// GETTERS AND SETTERS
	private string function _getRootDirectory() output=false {
		if ( Server.Coldfusion.ProductName EQ 'ColdFusion Server' AND NOT DirectoryExists(_rootDirectory) )
		{
			return expandPath(_rootDirectory);
		}
		else
		{
			return _rootDirectory;
		}
	}
	private void function _setRootDirectory( required string rootDirectory ) output=false {
		_rootDirectory = ReReplace( arguments.rootDirectory, "(.*?)/$", "\1" );
	}

	private string function _getRootUrl() output=false {
		return _rootUrl;
	}
	private void function _setRootUrl( required string rootUrl ) output=false {
		_rootUrl = ReReplace( arguments.rootUrl, "(.*?)/$", "\1" );
	}

	private struct function _getAssetCollection() output=false {
		return _assetCollection;
	}
	private void function _setAssetCollection( required struct assetCollection ) output=false {
		_assetCollection = arguments.assetCollection;
	}
}