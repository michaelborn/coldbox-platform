<!-----------------------------------------------------------------------Author 	 :	Luis MajanoDate     :	September 25, 2005Description : 				General handler for my hello application. 		Modification History:Sep/25/2005 - Luis Majano	-Created the template.-----------------------------------------------------------------------><cfcomponent name="ehGeneral" extends="coldbox.system.eventhandler" output="false">	<!--- ************************************************************* --->	<cffunction name="dspHello" access="public" returntype="void" output="false">		<!--- EXIT HANDLERS: --->		<cfset setValue("xehHello", "ehGeneral.doHello")>		<cfset setValue("xehStartOver", "ehGeneral.doStartOver")>		<!--- Do Your Logic Here --->		<cfset getPlugin("logger").tracer("Starting dspHello. Using default name")>		<cfset setValue("firstname",getSetting("Codename", true) & getSetting("Version", true) )>		<!--- Set the View To Display, after Logic --->		<cfset setView("vwHello")>		<cfset getPlugin("logger").tracer("View has been set")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="doHello" access="public" returntype="void" output="false">		<!--- EXIT HANDLERS: --->		<cfset setValue("xehHello", "ehGeneral.doHello")>		<cfset setValue("xehStartOver", "ehGeneral.doStartOver")>		<!--- Logger --->		<cfset getPlugin("logger").tracer(getValue("firstname"))>		<!--- Do Your Logic Here --->		<cfif getValue("firstname") eq "">			<cfset setValue("firstname","Not Found")>		<cfelse>			<cfset setValue("firstname",getValue("firstname"))>		</cfif>		<!--- Set the View To Display, after Logic --->		<cfset setView("vwHelloRich")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="doStartOver" access="public" returntype="void" output="false"> 		<!--- Do Your Logic Here --->		<cfset setNextEvent("ehGeneral.dspHello")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="dspPopup" access="public" returntype="void" output="false">		<!--- Render a view with no layout. --->		<cfset setView("vwTest",true)>	</cffunction>	<!--- ************************************************************* --->	</cfcomponent>