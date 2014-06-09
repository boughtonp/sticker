component extends="testbox.system.testing.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.mockManifestParser = getMockBox().createEmptyMock( "sticker.util.ManifestParser" );
		variables.manager            = new sticker.util.BundleManager(
			manifestParser = mockManifestParser
		);
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "calling addBundle() multiple times followed by getManifest()", function(){
			it( "should return a merged manifest based on the manifest file for each bundle", function(){
				var manifestParserResult = { some="structure" };

				mockManifestParser.$( "parseFiles" ).$args( filePaths=[
					  "/resources/bundles/bundle1/sticker-bundle.json"
					, "/resources/bundles/bundle3/sticker-bundle.json"
					, "/resources/bundles/bundle2/sticker-bundle.json"
					, "/resources/bundles/bundle4/sticker-bundle.json"
				] ).$results( manifestParserResult );

				expect( manager.addBundle( rootDirectory="/resources/bundles/bundle1", rootUrl="http://bundle1.com/assets" )
				       .addBundle( rootDirectory="/resources/bundles/bundle3", rootUrl="/" )
				       .addBundle( rootDirectory="/resources/bundles/bundle2", rootUrl="http://bundle2.com/assets" )
				       .addBundle( rootDirectory="/resources/bundles/bundle4", rootUrl="/assets" )
				       .getManifest()
				).toBe( manifestParserResult );
			} );
		} );
	}

}
