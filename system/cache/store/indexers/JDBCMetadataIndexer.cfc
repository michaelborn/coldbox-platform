﻿/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * This is a utility object that helps object stores keep their elements indexed
 * and stored nicely.  It is also a nice way to give back metadata results.
 *
 * @author Luis Majano
 */
component extends="coldbox.system.cache.store.indexers.MetadataIndexer" accessors="true" {

	/**
	 * The SQL Type: Defaults to MySQL
	 */
	property name="sqlType";

	/**
	 * The jdbc config structure
	 */
	property name="config" type="struct";

	/**
	 * The JDBC Store we connect to
	 */
	property name="store" type="coldbox.system.cache.store.indexers.JDBCMetadataIndexer";

	/**
	 * Constructor
	 *
	 * @fields The list or array of fields to bind this index on
	 * @config JDBC Configuration structure
	 * @store  The associated storage
	 */
	function init(
		required fields,
		required struct config,
		required store
	){
		// Super init
		super.init( arguments.fields );

		// Get db data
		cfdbinfo(
			type       = "version",
			datasource = "#arguments.config.dsn#",
			name       = "local.DBData"
		);

		// store db sql compatibility type: used mostly for pagination
		variables.sqlType = ( findNoCase( "Microsoft SQL", DBData.database_productName ) ? "MSSQL" : "MySQL" );

		// store jdbc configuration
		variables.config = arguments.config;

		// store storage reference
		variables.store = arguments.store;

		variables.isLucee = server.keyExists( "lucee" );

		return this;
	}

	/**
	 * Check if the metadata entry exists for an object
	 *
	 * @objectKey The key to get
	 */
	boolean function objectExists( required objectKey ){
		return queryExecute(
			"SELECT id
			  FROM #variables.config.table#
			 WHERE id = ?",
			[ variables.store.getNormalizedID( arguments.objectKey ) ],
			{
				datasource : variables.config.dsn,
				username   : variables.config.dsnUsername,
				password   : variables.config.dsnPassword
			}
		).recordCount eq 1;
	}

	/**
	 * Get the top 100 pool of metadata elements
	 *
	 * @max The number of records to get, defaults to 100
	 *
	 * @return Struct of { hits, timeout, lastAccessTimeout, created, lastAccessed, isExpired, isSimple }
	 *
	 * @throws InvalidMaxRecords - When the max argument is not an integer
	 */
	struct function getPoolMetadata( numeric max = 100 ){
		var results = {};
		var params  = [ arguments.max ];

		// make sure the max argument is a valid integer
		if ( !isValid( "integer", arguments.max ) ) {
			throw( type: "InvalidMaxRecords", message: "Invalid max records specified - it must be an integer" );
		}

		// MySQL Default
		var sql = "SELECT #variables.fields# FROM #variables.config.table# ORDER BY objectKey LIMIT ?";
		// MSSQL
		if ( variables.sqlType == "MSSQL" ) {
			sql    = "SELECT TOP #arguments.max# #variables.fields# FROM #variables.config.table# ORDER BY objectKey";
			params = [];
		}

		queryExecute(
			sql,
			params,
			{
				datasource : variables.config.dsn,
				username   : variables.config.dsnUsername,
				password   : variables.config.dsnPassword
			}
		).each( function( row ){
			results[ row.objectKey ] = {
				"hits"              : row.hits,
				"timeout"           : row.timeout,
				"lastAccessTimeout" : row.lastAccessTimeout,
				"created"           : row.created,
				"lastAccessed"      : row.lastAccessed,
				"isExpired"         : row.isExpired,
				"isSimple"          : row.isSimple
			};
		} );

		return results;
	}

	/**
	 * Get a metadata entry for a specific entry. Exception if key not found
	 *
	 * @objectKey The key to get
	 */
	struct function getObjectMetadata( required objectKey ){
		var qData = queryExecute(
			"SELECT #variables.fields#
			  FROM #variables.config.table#
			 WHERE id = ?",
			[ variables.store.getNormalizedID( arguments.objectKey ) ],
			{
				datasource : variables.config.dsn,
				username   : variables.config.dsnUsername,
				password   : variables.config.dsnPassword
			}
		);

		return variables.fields.listReduce( function( accumulator, target ){
			accumulator[ target ] = qData[ target ];
			return accumulator;
		}, {} );
	}

	/**
	 * Get a metadata entry for a specific entry. Exception if key not found
	 *
	 * @objectKey    The key to get
	 * @property     The metadata property to get
	 * @defaultValue The default value if property doesn't exist
	 */
	function getObjectMetadataProperty(
		required objectKey,
		required property,
		defaultValue
	){
		var metadata = queryExecute(
			"SELECT #variables.fields#
			  FROM #variables.config.table#
			 WHERE id = ?",
			[ variables.store.getNormalizedID( arguments.objectKey ) ],
			{
				datasource : variables.config.dsn,
				username   : variables.config.dsnUsername,
				password   : variables.config.dsnPassword
			}
		);

		if ( structKeyExists( metadata, arguments.property ) ) {
			return metadata[ arguments.property ];
		}

		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		throw(
			type    = "InvalidProperty",
			message = "Invalid property requested: #arguments.property#",
			detail  = "Valid properties are: #variables.fields#"
		);
	}

	/**
	 * Get the size of the store
	 */
	numeric function getSize(){
		// Delegate to storage
		return variables.store.size();
	}

	/**
	 * Get an array of sorted keys for this indexer according to parameters
	 *
	 * @property  The property to order the keys with
	 * @sortType  The sorting type, not used by this indexer
	 * @sortOrder Either `asc` or `desc` for sorting the keys
	 *
	 * @return Sorted keys
	 */
	array function getSortedKeys(
		required property,
		sortType  = "text",
		sortOrder = "asc"
	){
		var qResults = queryExecute(
			"SELECT id, objectKey
			FROM #variables.config.table#
		    ORDER BY #arguments.property# #arguments.sortOrder#",
			[],
			{
				datasource : variables.config.dsn,
				username   : variables.config.dsnUsername,
				password   : variables.config.dsnPassword
			}
		);

		return (
			variables.isLucee ? queryColumnData( qResults, "objectKey" ) : listToArray(
				valueList( qResults.objectKey )
			)
		);
	}

}
