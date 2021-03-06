option explicit

!INC Local Scripts.EAConstants-VBScript

'
' Script Name: 	AddMissingTags
' Author: 		Magnus Karge
' Purpose: 		To add missing tags defined in the Norwegian standard "SOSI regler for UML-modellering"
' 				to model elements (application schemas, feature types & attributes, data types & attributes,
'				code lists, enumerations)
' Date: 		11.09.2015   + Moddet av Kent 2016-03-09: Legger n� inn forslag til verdi i alle taggene!
' scriptnavn: leggInnGMLformatTagger


' Project Browser Script main function
sub OnProjectBrowserScript()

	' Get the type of element selected in the Project Browser
	dim treeSelectedType
	treeSelectedType = Repository.GetTreeSelectedItemType()

	'find out what type is selected
	select case treeSelectedType

'		case otElement
'			' Code for when an element is selected
'			dim theElement as EA.Element
'			set theElement = Repository.GetTreeSelectedObject()
'
		case otPackage
			' Code for when a package is selected
			dim thePackage as EA.Package
			set thePackage = Repository.GetTreeSelectedObject()
			'Msgbox "The selected package is: [" & thePackage.Name &"]. Starting search for elements with missing tags."
			FindElementsWithMissingTagsInPackage(thePackage)

'
'		case otDiagram
'			' Code for when a diagram is selected
'			dim theDiagram as EA.Diagram
'			set theDiagram = Repository.GetTreeSelectedObject()
'
'		case otAttribute
'			' Code for when an attribute is selected
'			dim theAttribute as EA.Attribute
'			set theAttribute = Repository.GetTreeSelectedObject()
'
'		case otMethod
'			' Code for when a method is selected
'			dim theMethod as EA.Method
'			set theMethod = Repository.GetTreeSelectedObject()

		case else
			' Error message
			Session.Prompt "This script does not support items of this type. Please choose a package in order to start the script.", promptOK

	end select

end sub

'sub procedure to check the content of a given package and all its subpackages and add missing tags to elements
'@param[in]: package (EA.package) The package containing elements with potentially missing tags.
			Dim ASpackage
sub FindElementsWithMissingTagsInPackage(package)

			Session.Output("The current package is: " & package.Name)
			'if the current package has stereotype applicationSchema then check tagged values
			if package.element.stereotype = "applicationSchema" or package.element.stereotype = "ApplicationSchema" then
				' Kapittel13kravSOSI: language, version, targetNamespace, SOSI_kortnavn, SOSI_modellstatus, SOSI_versjon
				' Kapittel13kravGML: language, version, targetNamespace, xmlns, xsdDocument, SOSI_modellstatus
				' Kapittel13kravAlle: designation og definition for engelsk
				ASpackage = "http://skjema.geonorge.no/SOSI/produktspesifikasjon/" + toNCName(package.Name,"/")
				'Call TVSetElementTaggedValue("ApplicationSchema",package.element, "SOSI_kortnavn",toNCName(package.Name,"-"))
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "SOSI_modellstatus","underArbeid")
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "language","no")
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "version","0.1")
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "targetNamespace",ASpackage)
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "xmlns","app")
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "xsdDocument",toNCName(package.Name, "-") & ".xsd")
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "definition","""""@en")
				' TODO: Klipp inn engelsk fra notefeltet der du finner --Definition --
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "designation","""""@en")
				' TODO: Klipp inn det engelske navnet fra Alias-feltet der dette finnes
				' Er denne ogs� praktisk � ha med her n�?
				Call TVSetElementTaggedValue("ApplicationSchema",package.element, "xsdEncodingRule","sosi")
				'
				'TODO: sette korrekt case p� stereotypen?
				'TODO: package.element.stereotype = "ApplicationSchema"
				'TODO: package.element.stereotype.Update()
				'
			end if

			dim elements as EA.Collection
			'collection of elements that belong to this package (classes, notes... BUT NO packages)
			set elements = package.Elements

			dim packages as EA.Collection
			'collection of packages that belong to this package
			set packages = package.Packages

			'navigate the package collection and call the FindElementsWithMissingTagsInPackage
			'sub procedure for each of them
			dim packageCounter
			for packageCounter = 0 to packages.Count - 1
				dim currentPackage as EA.Package
				set currentPackage = packages.GetAt( packageCounter )
				FindElementsWithMissingTagsInPackage(currentPackage)
			next

			'navigate the elements collection
			dim elementsCounter
			for elementsCounter = 0 to elements.Count - 1
				dim currentElement as EA.Element
				set currentElement = elements.GetAt( elementsCounter )

				Session.Output("The current element is: " & currentElement.Name & " [Stereotype: " & currentElement.Stereotype & "]")

				'check if the currentElement has stereotype FeatureType.
				if ((currentElement.Stereotype = "FeatureType") or (currentElement.Stereotype = "featureType")) then
					'call sub function TVSetElementTaggedValue
					'one function call for each of the required tags
					'Call TVSetElementTaggedValue(currentElement, "SOSI_navn")
					'Call TVSetElementTaggedValue(currentElement, "isCollection")
					' F�lgende er ikke p�krevet!
					'Call TVSetElementTaggedValue("FeatureType", currentElement, "byValuePropertyType", "false")
					'Call TVSetElementTaggedValue("FeatureType", currentElement, "noPropertyType", "true")
				end if

				'check if the currentElement has stereotype CodeList.
				if ((currentElement.Stereotype = "CodeList") or (currentElement.Stereotype = "codeList")) then
					'call sub function TVSetElementTaggedValue
					'one function call for each of the required tags
					'Call TVSetElementTaggedValue(currentElement, "SOSI_navn")
					'Call TVSetElementTaggedValue(currentElement, "SOSI_datatype")
					'Call TVSetElementTaggedValue(currentElement, "SOSI_lengde")
					' F�lgende er ikke p�krevet!
					Call TVSetElementTaggedValue("CodeList", currentElement, "asDictionary", "false")
					if ASpackage <> "" then
						Call TVSetElementTaggedValue("CodeList", currentElement, "codeList", ASpackage + "/" + currentElement.Name)
					end if
				end if

				'check if the currentElement has stereotype dataType.
				if ((currentElement.Stereotype = "DataType") or (currentElement.Stereotype = "dataType")) then
					'call sub function TVSetElementTaggedValue
					'one function call for each of the required tags
					'Call TVSetElementTaggedValue(currentElement, "SOSI_navn")
				end if

				'check if the currentElement has stereotype enumeration.
				if ((currentElement.Stereotype = "Enumeration") or (currentElement.Stereotype = "enumeration")) then
					'Call TVSetElementTaggedValue(currentElement, "SOSI_navn")
					'call sub function TVSetElementTaggedValue
					'one function call for each of the required tags
				end if

				'if the currentElement has stereotype dataType or FeatureType then
				'navigate the attributes and check for missing tags
				if ((currentElement.Stereotype = "DataType") or (currentElement.Stereotype = "dataType") or (currentElement.Stereotype = "FeatureType") or (currentElement.Stereotype = "featureType")) then
					dim attributesCounter
					for attributesCounter = 0 to currentElement.Attributes.Count - 1
						dim currentAttribute as EA.Attribute
						set currentAttribute = currentElement.Attributes.GetAt ( attributesCounter )
						'Session.Output( "  The current attribute is ["& currentAttribute.Name &"]")
						'call sub function TVSetElementTaggedValue
						'one function call for each of the required tags
						'Call TVSetElementTaggedValue(currentAttribute, "SOSI_navn")
						'Call TVSetElementTaggedValue(currentAttribute, "SOSI_datatype")
						'Call TVSetElementTaggedValue(currentAttribute, "SOSI_lengde")
						' F�lgende er ikke p�krevet!
						'Call TVSetElementTaggedValue(currentElement.Name, currentAttribute, "inLineOrByReference", "inline")
						'Call TVSetElementTaggedValue(currentElement.Name, currentAttribute, "isMetadata", "false")

						'Call TVSetElementTaggedValue(currentElement.Name, currentAttribute, "sequenceNumber", "1")
						'Call TVSetElementTaggedValue(currentElement.Name, currentAttribute, "sequenceNumber", "")
					Next
					' traverse all roles: tbd

					' reset sequenceNumber to the sequence the attributes currently have in the model
					' resequenceAttributes()
					' reset sequenceNumber to a sequence after all the attributes, keep the old internal role sequence
					' resequenceRoles()


				end if

				Session.Output( "Done with element ["& currentElement.Name &"]")
			next
	Session.Output( "Done with package ["& package.Name &"]")

end sub


' Sets the specified TaggedValue on the provided element. If the provided element does not already
' contain a TaggedValue with the specified name, a new TaggedValue is created with the requested
' name and value. If a TaggedValue already exists with the specified name then nothing will be changed.
'
'
sub TVSetElementTaggedValue( ownerElementName, theElement, taggedValueName, theValue)
	'Session.Output( "  Checking if tagged value [" & taggedValueName & "] exists")
	if not theElement is nothing and Len(taggedValueName) > 0 then
		dim newTaggedValue as EA.TaggedValue
		set newTaggedValue = nothing
		dim taggedValueExists, taggedValueValue
		taggedValueExists = False
		taggedValueValue = ""

		'check if the element has a tagged value with the provided name
		dim currentExistingTaggedValue AS EA.TaggedValue
		dim taggedValuesCounter
		for taggedValuesCounter = 0 to theElement.TaggedValues.Count - 1
			set currentExistingTaggedValue = theElement.TaggedValues.GetAt(taggedValuesCounter)
			if currentExistingTaggedValue.Name = taggedValueName then
				taggedValueValue = currentExistingTaggedValue.Value
				taggedValueExists = True
			end if
		next

		'if the element does not contain a tagged value with the provided name, create a new one
		if not taggedValueExists = True then
			set newTaggedValue = theElement.TaggedValues.AddNew( taggedValueName, theValue )
			newTaggedValue.Update()
			Session.Output( "    ADDED To " & ownerElementName & " " & theElement.Name & " tagged value [" & taggedValueName & " = " & theValue & "]")
		else
			Session.Output( "    FOUND On " & ownerElementName & " " & theElement.Name & " tagged value [" & taggedValueName & " = " & taggedValueValue & "]")
		end if
	end if
end sub

function toNCName(namestring, blankbeforenumber)
		' make name legal NCName
    Dim txt, res, tegn, i, u
    u=0
		txt = Trim(namestring)
		res = UCase( Mid(txt,1,1) )
			'Repository.WriteOutput "Script", "New NCName: " & txt & " " & res,0

		' loop gjennom alle tegn
		For i = 2 To Len(txt)
		  ' blank, komma, !, ", #, $, %, &, ', (, ), *, +, /, :, ;, <, =, >, ?, @, [, \, ], ^, `, {, |, }, ~
		  ' (tatt med flere fnuttetyper, men hva med "."?)
		  tegn = Mid(txt,i,1)
		  if tegn = " " or tegn = "," or tegn = """" or tegn = "#" or tegn = "$" or tegn = "%" or tegn = "&" or tegn = "(" or tegn = ")" or tegn = "*" Then
			  'Repository.WriteOutput "Script", "Bad1: " & tegn,0
			  u=1
		  Else
		    if tegn = "+" or tegn = "/" or tegn = ":" or tegn = ";" or tegn = "<" or tegn = ">" or tegn = "?" or tegn = "@" or tegn = "[" or tegn = "\" Then
			    'Repository.WriteOutput "Script", "Bad2: " & tegn,0
			    u=1
		    Else
		      If tegn = "]" or tegn = "^" or tegn = "`" or tegn = "{" or tegn = "|" or tegn = "}" or tegn = "~" or tegn = "'" or tegn = "�" or tegn = "�" Then
			      'Repository.WriteOutput "Script", "Bad3: " & tegn,0
			      u=1
		      else
			      'Repository.WriteOutput "Script", "Good: " & tegn,0
			      If u = 1 Then
		          If tegn = "1" or tegn = "2" or tegn = "3" or tegn = "4" or tegn = "5" or tegn = "6" or tegn = "7" or tegn = "8" or tegn = "9" or tegn = "0" Then
		            res = res + blankbeforenumber + tegn
  			      else
		            res = res + UCase(tegn)
		          End If
		          u=0
			      else
		          res = res + tegn
		        End If
		      End If
		    End If
		  End If
		Next
		'Repository.WriteOutput "Script", "New NCName: " & res,0
    toNCName = res
		Exit function
end function

'start the main function
OnProjectBrowserScript
