/**
 * I am an Asset bean, I represent a single asset in a bundle
 */
component accessors=true output=false {

	property name="type"            type="string";
	property name="url"             type="string";
	property name="path"            type="string" default="";
	property name="_before"          type="array" ;
	property name="_after"           type="array" ;
	property name="_dependsOn"       type="array" ;
	property name="_dependents"      type="array" ;
	property name="renderedInclude" type="string" default="";
	property name="ie"              type="string" default="";
	property name="media"           type="string" default="";

	function init()
	{
		setType(arguments.type?:'');
		setUrl(arguments.url?:'');
		setPath(arguments.path?:'');
		set_before    (arguments.before?:[]);
		set_after     (arguments.after?:[]);
		set_dependsOn (arguments.dependsOn?:[]);
		set_dependents(arguments.dependents?:[]);
		setRenderedInclude(arguments.renderedInclude?:'');
		setIe(arguments.ie?:'');
		setMedia(arguments.media?:'');
		this.getBefore    =get_before;
		this.getAfter     =get_after;
		this.getDependsOn =get_dependsOn;
		this.getDependents=get_dependents;
		this.setBefore    =set_before;
		this.setAfter     =set_after;
		this.setDependsOn =set_dependsOn;
		this.setDependents=set_dependents;
		return this;
	}

	public Asset function before() output=false {
		var bf = get_Before();
		for( var i=1; i <= arguments.Count(); i++ ) {
			bf.append( arguments[ i ] );
		}
		set_Before( bf );
		return this;
	}

	public Asset function after() output=false {
		var af = get_After();
		for( var i=1; i <= arguments.Count(); i++ ) {
			af.append( arguments[ i ] );
		}
		set_After( af );
		return this;
	}

	public Asset function dependents() output=false {
		this.before( argumentCollection=arguments );

		var dp = get_Dependents();
		for( var i=1; i <= arguments.Count(); i++ ) {
			dp.append( arguments[ i ] );
		}
		set_Dependents( dp );
		return this;
	}

	public Asset function dependsOn() output=false {
		this.after( argumentCollection=arguments );

		var dp = get_DependsOn();
		for( var i=1; i <= arguments.Count(); i++ ) {
			dp.append( arguments[ i ] );
		}
		set_DependsOn( dp );
		return this;
	}

	public struct function getMemento() output=false {

		return {
			  type            = getType()
			, url             = getUrl()
			, path            = getPath()
			, before          = get_Before()
			, after           = get_After()
			, dependsOn       = get_DependsOn()
			, dependents      = get_Dependents()
			, renderedInclude = getRenderedInclude()
			, ie              = getIe()
			, media           = getMedia()
		};
	}

}