*** Settings ***
Library     Selenium2Library
Library     DateTime
Library     Collections
Library     ecommodity_helper.py


*** Variables ***
${sign_in}                                           id=loginLink
${login_email}                                       id=Email
${login_pass}                                        id=Password
${prozorropage}                                      id=tendersPageBtn
${locator.title}                                     name=auction_title
${locator.minNumberOfQualifiedBids}                  name=auction_minNumberOfQualifiedBids
${locator.dgfID}                                     name=auction_dgfID
${locator.tenderAttempts}                            xpath=//span[@id='info_tenderAttempts']
${locator.eligibilityCriteria}                       name=auction_eligibilityCriteria
${locator.status}                                    name=auction_status
${locator.description}                               name=auction_description
${locator.procurementMethodType}                     name=auction_procurementMethodType
${locator.minimalStep.amount}                        name=auction_minimalStep_amount
${locator.guarantee.amount}                          name=auction_guarantee_amount
${locator.value.amount}                              xpath=//dd[@name='auction_value_amount']
${locator.value.currency}                            name=auction_value_currency
${locator.value.valueAddedTaxIncluded}               name=auction_valueAddedTaxIncluded
${locator.tenderId}                                  name=auction_tenderID
${locator.procuringEntity.name}                      name=auction_procuringEntity_name
${locator.enquiryPeriod.startDate}                   name=auction_enquiryPeriod_startDate
${locator.enquiryPeriod.endDate}                     name=auction_enquiryPeriod_endDate
${locator.tenderPeriod.startDate}                    name=auction_tenderPeriod_startDate
${locator.tenderPeriod.endDate}                      name=auction_tenderPeriod_endDate
${locator.auctionPeriod.startDate}                   name=auction_auctionPeriod_startDate
${locator.auctionPeriod.endDate}                     name=auction_auctionPeriod_endDate
${locator.proposition.value.amount}                  xpath=//div[contains(@class, 'userbidinfo')]/span[contains(@id, 'userbidamount')]
${locator.items[0].quantity}                         xpath=//dd[@name='items[0].quantity']
${locator.items.quantity}                            name={0}
${locator.items.description}                         name={0}
${locator.items.unit.code}                           name={0}
${locator.items.unit.name}                           name={0}
${locator.items.classification.scheme}               name={0}
${locator.items.classification.id}                   name={0}
${locator.items.classification.description}          name={0}
${locator.cancellations[0].reason}                   id=tenderCancellationReason
${locator.cancellations[0].status}                   id=tenderCancellationReason@title
${locator.patchTender.value.amount}                  id=value_amount
${locator.patchTender.guarantee.amount}              id=guarantee_amount
${locator.patchTender.minimalStep.amount}            id=minimalStep_amount
${locator.patchTender.tenderPeriod.startDate}        id=Tender_tenderPeriod_startDate


*** Keywords ***
#SV
Підготувати клієнт для користувача
  [Arguments]     @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=ec_${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'ecommodity_viewer'   Login   ${ARGUMENTS[0]}

#SV
Login
  [Arguments]  @{ARGUMENTS}
  Click Element        xpath=//a[@id='ddTCabinetMenuId']
  Sleep   1
  Click Element        xpath=//a[@id='loginLink']
  Sleep   1
  Clear Element Text   id=Email
  Input text      ${login_email}      ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text      ${login_pass}       ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Button    id=loginBtn
  Sleep   2

#SV
Підготувати дані для оголошення тендера
  [Documentation]  Це слово використовується в майданчиків, тому потрібно, щоб воно було і тут
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${tender_data}=  Run Keyword If   '${username}' == 'ecommodity_owner'
  ...  set_procuringEntity_name   ${tender_data}  ${USERS.users['${username}'].name}
  ...  ELSE   Set Variable   ${tender_data}
  ${tender_data}=  set_item_property   ${tender_data}
  [return]  ${tender_data}

#SV
Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
    Switch browser   ec_${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
    ecommodity.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}

#SV
Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data

    ${title}=                                    Get From Dictionary     ${ARGUMENTS[1].data}                   title
    ${dgfID}=                                    Get From Dictionary     ${ARGUMENTS[1].data}                   dgfID
    ${description}=                              Get From Dictionary     ${ARGUMENTS[1].data}                   description
    ${auctionperiod_startdate}=                  Get From Dictionary     ${ARGUMENTS[1].data.auctionPeriod}     startDate
    ${minimalstep_amount}=                       Get From Dictionary     ${ARGUMENTS[1].data.minimalStep}       amount
    ${minimalstep_currency}=                     Get From Dictionary     ${ARGUMENTS[1].data.minimalStep}       currency
    ${value_amount}=                             Get From Dictionary     ${ARGUMENTS[1].data.value}             amount
    ${value_currency}=                           Get From Dictionary     ${ARGUMENTS[1].data.value}             currency
    ${value_valueaddedtaxincluded}=              Convert To String       ${ARGUMENTS[1].data.value.valueAddedTaxIncluded}
    ${value_valueaddedtaxincluded}=              convert_ecommodity_string   ${value_valueaddedtaxincluded}
    ${guarantee_amount}=                         Get From Dictionary     ${ARGUMENTS[1].data.guarantee}         amount
    ${items}=                                    Get From Dictionary     ${ARGUMENTS[1].data}                   items
    ${procuringEntity}=                          Get From Dictionary     ${ARGUMENTS[1].data}                   procuringEntity
    ${procuringEntity_address_countryName}=      Get From Dictionary     ${procuringEntity.address}             countryName
    ${procuringEntity_address_locality}=         Get From Dictionary     ${procuringEntity.address}             locality
    ${procuringEntity_address_postalCode}=       Get From Dictionary     ${procuringEntity.address}             postalCode
    ${procuringEntity_address_region}=           Get From Dictionary     ${procuringEntity.address}             region
    ${procuringEntity_address_streetAddress}=    Get From Dictionary     ${procuringEntity.address}             streetAddress
    ${procuringEntity_contactPoint_name}=        Get From Dictionary     ${procuringEntity.contactPoint}        name
    ${procuringEntity_contactPoint_telephone}=   Get From Dictionary     ${procuringEntity.contactPoint}        telephone
    ${procuringEntity_identifier_id}=            Get From Dictionary     ${procuringEntity.identifier}          id
    ${procuringEntity_identifier_scheme}=        Get From Dictionary     ${procuringEntity.identifier}          scheme
    ${procuringEntity_name}=                     Get From Dictionary     ${procuringEntity}                     name
    ${minimalstep_amount}=                       Convert To String       ${minimalstep_amount}
    ${value_amount}=                             Convert To String       ${value_amount}
    ${guarantee_amount}=                         Convert To String       ${guarantee_amount}
    ${auctionperiod_startdate}=                  ecommodity_convertdate  ${auctionperiod_startdate}
    ${number_of_items}=                          Get Length              ${items}
    ${tenderAttempts}=                           Convert To String       ${ARGUMENTS[1].data.tenderAttempts}

    ${present_minNumberOfQualifiedBids}=         Run Keyword And Return Status   Dictionary Should Contain Key  ${ARGUMENTS[1].data}  minNumberOfQualifiedBids
	${minNumberOfQualifiedBids}=                 Run Keyword If          ${present_minNumberOfQualifiedBids}
	...   Get From Dictionary                    ${ARGUMENTS[1].data}    minNumberOfQualifiedBids
	...   ELSE                                   Set Variable            2

	##====================== Продаж / Оренда ========================
	${is_lease}=          Set Variable    ${FALSE}
	:FOR  ${index}        IN RANGE        ${number_of_items}
	\  ${is_lease}=       Run Keyword And Return Status    Should Be Equal   ${items[${index}].additionalClassifications[0].id}   PA01-7
	\  Exit For Loop If   ${is_lease}
	\  ${is_lease}=       Run Keyword And Return Status    Should Be Equal   ${items[${index}].additionalClassifications[0].id}   PA02-0
	\  Exit For Loop If   ${is_lease}
	##====================== Продаж / Оренда ========================

	Switch browser   ec_${ARGUMENTS[0]}
	Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
	Sleep   1
	Click Element       xpath=//ul[@name='ul_cabinet_md']/descendant::a[@id='ddTCabinetMenuId']
	Click Element       xpath=//ul[@name='ul_cabinet_md']/descendant::a[@id='linkMyTendersID']
	Sleep   1
	Click Element       xpath=//a[@id = 'linkCreateNewTenderID']
	Sleep   1
	Input text          id=dgfID                                                                  ${dgfID}
	Select From List    xpath=//select[@id="status"]                                              active.tendering
	Select From List    xpath=//select[@id="tenderAttempts"]                                      ${tenderAttempts}
	Run Keyword If      ${is_lease}                                    Click Element              xpath=//input[@id='IsLeaseId']
	Sleep   1
	Run Keyword If      '${minNumberOfQualifiedBids}' == '1'           Click Element              xpath=//input[@id='BiddersOneId']
	Input text          id=title                                                                  ${title}
	Input text          id=description                                                            ${description}
	Input text          id=value_amount                                                           ${value_amount}
	UnSelect Checkbox   id=value_valueAddedTaxIncludedBool
	Run Keyword If      ${value_valueaddedtaxincluded} == True         Select Checkbox            id=value_valueAddedTaxIncludedBool
	Sleep   1
	Input text          id=minimalStep_amount                                                     ${minimalstep_amount}
	Input text          id=guarantee_amount                                                       ${guarantee_amount}
	Sleep   1
	Input text          id=auctionPeriod_startDate                                                ${auctionperiod_startdate}
	Sleep   1
	Click Button        id=tenderCreateSubmitId
	Sleep   2

	##====================== Предмети продажу ========================
	
	:FOR  ${index}  IN RANGE  ${number_of_items}
	\  Додати предмет продажу  ${items[${index}]}
	
	##====================== Предмети продажу ========================

	Click Button   		id=clickPublishSubmitId
	Wait Until Element Is Visible   xpath=//span[@id = 'tenderUAID']   30
	${tender_uaid}=     Get Text        xpath=//span[@id = 'tenderUAID']
	[Return]    ${tender_uaid}

#SV
Додати предмет продажу
  [Arguments]  ${item}
    ${item_description}=                     Get From Dictionary         ${item}                               description
    ${classification_scheme}=                Get From Dictionary         ${item.classification}                scheme
    ${classification_description}=           Get From Dictionary         ${item.classification}                description
    ${classification_id}=                    Get From Dictionary         ${item.classification}                id
    ${deliveryaddress_postalcode}=           Get From Dictionary         ${item.deliveryAddress}               postalCode
    ${deliveryaddress_countryname}=          Get From Dictionary         ${item.deliveryAddress}               countryName
    ${deliveryaddress_streetaddress}=        Get From Dictionary         ${item.deliveryAddress}               streetAddress
    ${deliveryaddress_region}=               Get From Dictionary         ${item.deliveryAddress}               region
    ${deliveryaddress_locality}=             Get From Dictionary         ${item.deliveryAddress}               locality
    ${unit_code}=                            Get From Dictionary         ${item.unit}                          code
    ${unit_name}=                            Get From Dictionary         ${item.unit}                          name
    ${quantity}=                             Get From Dictionary         ${item}                               quantity
    ${deliverylocation_latitude}=            Get From Dictionary         ${item.deliveryLocation}              latitude
    ${deliverylocation_longitude}=           Get From Dictionary         ${item.deliveryLocation}              longitude
    ${deliverylocation_latitude}=            Convert To String           ${deliverylocation_latitude}
    ${deliverylocation_longitude}=           Convert To String           ${deliverylocation_longitude}
    ${quantity}=                             Convert To String           ${quantity}

	${present_cp_startDate}=                 Run Keyword And Return Status   Dictionary Should Contain Key  ${item.contractPeriod}  startDate
	${contractPeriod_startdate}=             Run Keyword If                  ${present_cp_startDate}
	...   Get From Dictionary                ${item.contractPeriod}     startDate
	...   ELSE                               Set Variable                    ${EMPTY}
	${contractPeriod_startdate}=             Run Keyword If                  ${present_cp_startDate}
	...   ecommodity_convertdate             ${contractPeriod_startdate}
	...   ELSE                               Set Variable                    ${EMPTY}
	
	${present_cp_endDate}=                   Run Keyword And Return Status   Dictionary Should Contain Key  ${item.contractPeriod}  endDate
	${contractPeriod_endDate}=               Run Keyword If                  ${present_cp_endDate}
	...   Get From Dictionary                ${item.contractPeriod}     endDate
	...   ELSE                               Set Variable                    ${EMPTY}
	${contractPeriod_endDate}=               Run Keyword If                  ${present_cp_endDate}
	...   ecommodity_convertdate             ${contractPeriod_endDate}
	...   ELSE                               Set Variable                    ${EMPTY}

	Wait Until Element Is Visible   xpath=//a[@id = 'actionCreateItemID']   10
	Click Element                   xpath=//a[@id = 'actionCreateItemID']
	Wait Until Element Is Visible   xpath=//div[@id='tender_item_template_id']   10
	Sleep   2
	Input text                      xpath=//div[@id='tender_item_template_id']/descendant::textarea[@id='description']       ${item_description}
	Input text                      xpath=//div[@id='tender_item_template_id']/descendant::input[@id='quantityId']           ${quantity}
	Run Keyword If                  ${present_cp_startDate}  Input text  xpath=//div[@id='tender_item_template_id']/descendant::input[@id='contractPeriod_startDate']  ${contractPeriod_startdate}
	Run Keyword If                  ${present_cp_endDate}    Input text  xpath=//div[@id='tender_item_template_id']/descendant::input[@id='contractPeriod_endDate']    ${contractPeriod_endDate}
	Run Keyword If                  '${classification_scheme}' == 'CPV'
	...   Click Element             xpath=//div[@id='tender_item_template_id']/descendant::a[@id='CPV_Classifier_select_ID']
	...   ELSE   Click Element      xpath=//div[@id='tender_item_template_id']/descendant::a[@id='CAVPS_Classifier_select_ID']
	Sleep   1
	Wait Until Page Contains Element    xpath=//div[@id = 'modalBodyClassifyID']/descendant::input[@id='KeyWord']   15
	Wait Until Element Is Not Visible   xpath=//div[@id = 'modalBodyClassifyID']/descendant::img[@name='loadingIDHeader']   15
	Sleep   1
	Input text                      xpath=//div[@id = 'modalBodyClassifyID']/descendant::input[@id='KeyWord']   ${classification_id}
	Click Element                   xpath=//div[@id = 'modalBodyClassifyID']/descendant::div[@id='searchId']
	Sleep   1
	Wait Until Element Is Not Visible   xpath=//div[@id = 'modalBodyClassifyID']/descendant::img[@name='loadingIDBody']   15
	Click Element       xpath=//div[@id = 'modalBodyClassifyID']/descendant::table/descendant::tr[1]
	Click Button        id=okButton
	Sleep   1
	Select From List                xpath=//div[@id='tender_item_template_id']/descendant::select[@id="unit_code"]        ${unit_code}
	Click Element       xpath=//div[@id='tender_item_template_id']/descendant::a[@href='#addressDataId']
	Sleep   1
	Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_streetAddress']   ${deliveryaddress_streetaddress}
	Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_locality']        ${deliveryaddress_locality}
	Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_region']          ${deliveryaddress_region}
	Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_postalCode']      ${deliveryaddress_postalcode}
	Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_countryName']     ${deliveryaddress_countryname}
	Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='location_latitude']       ${deliverylocation_latitude}
	Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='location_longitude']      ${deliverylocation_longitude}
	Click Button        id=saveNewItemID
	Sleep   1

#SV
Додати предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  ecommodity.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element   id=btnEditTender
  Sleep   1
  Run Keyword And Ignore Error   Додати предмет продажу   ${item}

#SV  
Видалити предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}
  ecommodity.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element   id=btnEditTender
  Sleep   1
  Run Keyword And Ignore Error   Click Element   xpath=//a[contains(text(),'${item_id}')]/ancestor::div[@name='div_item_row']/descendant::a[@name='delete_item']
  Run Keyword And Ignore Error   Wait Until Element Is Visible   xpath=//div[@id='tender_item_details_id']   10
  Run Keyword And Ignore Error   Click Element   id=submitDeleteItemId
	
#SV
Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}
	Switch browser   ec_${username}
	Go to   ${USERS.users['${username}'].homepage}
	Click Element   ${prozorropage}
	Wait Until Element Is Visible   xpath=//input[@id = 'btnClearFilter']   15
	Scroll Page To Element XPATH   xpath=//input[@id='btnClearFilter']
	Click Button   id=btnClearFilter
	Input Text          id=tenderID   ${tender_uaid}
	Scroll Page To Element XPATH   xpath=//input[@id='btnFilter']
	Click Button       id=btnFilter
	Wait Until Element Is Not Visible   xpath=//div[@id = 'divFilter']/descendant::div[@name='loadingIDFilter']   25
	Scroll Page To Top
	Click Element   xpath=//a[@id = 'showDetails_${tender_uaid}']
	Wait Until Element Is Visible   xpath=//div[@name = 'divTenderDetails']   15
	

#SV
Scroll Page To Element XPATH
    [Arguments]    ${xpath}
    Execute JavaScript    document.evaluate("/html/.${xpath.replace('xpath=', '')}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(false);
	
#SV
Click Element By XPATH
    [Arguments]    ${xpath}
    Execute JavaScript    $(document.evaluate("/html/.${xpath.replace('xpath=', '')}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue).click();

#SV
Scroll Page To Top
    Execute JavaScript    window.scrollTo(0,0);
	
#SV
Отримати кількість документів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  ecommodity.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${number_of_documents}=  Get Matching Xpath Count  //div[@id='tenderDocumentsDetails']/descendant::div[contains(@name,'div_document_body_')]
  [return]  ${number_of_documents}

#SV  
Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  Execute JavaScript    $('.hiddenContentDetails').show();  
  ${div_id}=   Run Keyword If   'скасування' in '${TEST_NAME}'
  ...   Set Variable          cancellationDocumentsDetails
  ...   ELSE   Set Variable   tenderDocumentsDetails
  ${path_value}=     Set Variable  xpath=//div[@id='${div_id}']/descendant::dd[contains(text(),'${doc_id}')]/ancestor::div[contains(@name,'div_document_body_')]/descendant::dd[@name='documents.${field}']
  ${return_value}=   Get Text   ${path_value}
  ${return_value}=   Run Keyword If   "${field}" == "documentType"   Get Element Attribute   ${path_value}@title
  ...   ELSE   Set Variable   ${return_value}
  [Return]  ${return_value}
  
#SV
Отримати документ
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
    ${file_name}=          Get Text   xpath=//div[@id='tenderDocumentsDetails']/descendant::dd[contains(text(),'${doc_id}')]/ancestor::div[contains(@name,'div_document_body_')]/descendant::dd[@name='documents.title']
    ${url}=   Get Element Attribute   xpath=//div[@id='tenderDocumentsDetails']/descendant::dd[contains(text(),'${doc_id}')]/ancestor::div[contains(@name,'div_document_body_')]/descendant::a[@name='documents.url']@href
    ecommodity_download_file   ${url}  ${file_name}  ${OUTPUT_DIR}
    [return]  ${file_name}
	
#SV
Отримати інформацію із документа по індексу
  [Arguments]  ${username}  ${tender_uaid}  ${document_index}  ${field}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${path_value}=     Set Variable  xpath=//div[@id='tenderDocumentsDetails']/descendant::div[@name='div_document_body_${document_index}']/descendant::dd[@name='documents.${field}']
  ${return_value}=   Get Text   ${path_value}
  ${return_value}=   Run Keyword If   "${field}" == "documentType"   Get Element Attribute   ${path_value}@title
  ...   ELSE   Set Variable   ${return_value} 
  [return]  ${return_value}
  
#SV
Отримати кількість документів в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}
  ecommodity.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Click Element   xpath=//a[@id='action_bids_details']
  Sleep   1
  Wait Until Element Is Not Visible   xpath=//img[@id='loaderBids']   25
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${bid_index}=   Run KeyWord If     ${bid_index} == -1
  ...   Set Variable   1
  ...   ELSE   Set Variable   ${bid_index}
  ${number_of_documents}=  Get Matching Xpath Count  //div[@id='bids_details_${bid_index}']/descendant::div[contains(@name,'div_document_body_')]
  [return]  ${number_of_documents}

#SV
Отримати дані із документу пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}  ${document_index}  ${field}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${present}=  Run Keyword And Return Status    Page Should Contain Element   xpath=//img[@id='loaderBids']
  Run Keyword If  ${present}   Run Keywords
  ...   Execute Javascript   $('div[id="bidsViewID"]').hide();
  ...   AND   Click Element   xpath=//a[@id='action_bids_details']
  ...   AND   Wait Until Element Is Not Visible   xpath=//img[@id='loaderBids']   25
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${bid_index}=   Run KeyWord If     ${bid_index} == -1
  ...   Set Variable   1
  ...   ELSE   Set Variable   ${bid_index}
  ${path_value}=     Set Variable  xpath=//div[@id='bids_details_${bid_index}']/descendant::div[@name='div_document_body_${document_index}']/descendant::dd[@name='documents.${field}']
  ${return_value}=   Get Text   ${path_value}
  ${return_value}=   Run Keyword If   "${field}" == "documentType"   Get Element Attribute   ${path_value}@title
  ...   ELSE   Set Variable   ${return_value} 
  [return]  ${return_value}
	
#SV
Отримати кількість предметів в тендері
    [Arguments]  ${username}  ${tender_uaid}
    ecommodity.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
    ${res}=   Get Text      xpath=//span[@name='span_items_count']
    [return]  ${res}
	
#BOV 2017/10/12
Отримати інформацію із тендера
    [Arguments]  ${username}  ${tender_uaid}  ${field_name}
    Execute JavaScript    $('.hiddenContentDetails').show();
    ${return_value}=   Отримати інформацію із поля тендера  ${field_name}
    [Return]  ${return_value}

#BOV 2017/10/12
Отримати інформацію із поля тендера
    [Arguments]  ${field_name}
	${check_for_items}=  Get Substring  ${field_name}  0  6
    ${return_value}=   Set Variable  ${EMPTY}
	${return_value}=   Run Keyword If   "${check_for_items}" == "items["   Отримати інформацію із предмету тендера   ${field_name}
    ...   ELSE   Отримати інформацію про ${field_name}
    [Return]  ${return_value}
	
#SV
Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${field_namefull}=  Отримати шлях до поля об’єкта  ${username}  ${field_name}  ${item_id}
  ${text_to_replace}=  Set Variable  {0}
  ${field_path}=   ecommodity_replace  ${locator.items.${field_name}}  ${text_to_replace}  ${field_namefull}
  ${return_value}=   Get Text   ${field_path}
  
  ##=========== QUANTITY ===================
  ${return_value}=   Run Keyword If   "${field_name}" == "quantity"   Convert To Number   ${return_value.replace(" ", "").replace(u' ', '').replace(u',', u'.')}
  ...   ELSE   Set Variable   ${return_value}
  ${return_value}=   Run Keyword If   'contractPeriod' in '${field_name}'   convert_ecommodity_contractPeriod_to_iso_format   ${return_value}
  ...   ELSE   Set Variable   ${return_value}
  ##=========== QUANTITY ===================
  
  [Return]  ${return_value}
  
#SV
Отримати інформацію із предмету тендера
  [Arguments]  ${field_name}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${return_value}=  Get Text  name=${field_name}
  
  ##=========== QUANTITY ===================
  ${return_value}=   Run Keyword If   'quantity' in '${field_name}'   Convert To Number   ${return_value.replace(" ", "").replace(u' ', '').replace(u',', u'.')}
  ...   ELSE   Set Variable   ${return_value}
  ${return_value}=   Run Keyword If   'contractPeriod' in '${field_name}'   convert_ecommodity_contractPeriod_to_iso_format   ${return_value}
  ...   ELSE   Set Variable   ${return_value}
  ##=========== QUANTITY ===================
  
  [Return]  ${return_value}

#SV
Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [Return]  ${return_value}

#SV
Отримати інформацію про title
  ${return_value}=   Отримати текст із поля і показати на сторінці   title
  [Return]  ${return_value}

#SV
Отримати інформацію про dgfID
  ${return_value}=   Отримати текст із поля і показати на сторінці   dgfID
  [Return]  ${return_value}

#SV
Отримати інформацію про eligibilityCriteria
  ${return_value}=   Отримати текст із поля і показати на сторінці   eligibilityCriteria
  [Return]  ${return_value}

#SV
Отримати інформацію про status
  reload page
  ${return_value}=   Отримати текст із поля і показати на сторінці   status
  ${return_value}=   convert_ecommodity_string     ${return_value}
  [Return]  ${return_value}

#SV
Отримати інформацію про description
  ${return_value}=   Отримати текст із поля і показати на сторінці   description
  [Return]  ${return_value}
  
#SV
Отримати інформацію про procurementMethodType
  ${return_value}=   Отримати текст із поля і показати на сторінці   procurementMethodType
  ${return_value}=   convert_ecommodity_string     ${return_value}
  [Return]  ${return_value}

#SV
Отримати інформацію про minNumberOfQualifiedBids
  ${present}=        Run Keyword And Return Status      Page Should Contain Element   ${locator.minNumberOfQualifiedBids}
  ${return_value}=   Run Keyword If  ${present}
  ...   Отримати текст із поля і показати на сторінці   minNumberOfQualifiedBids
  ...   ELSE  Set Variable   2
  ${return_value}=   Convert To Number                  ${return_value}
  [Return]  ${return_value}

#SV
Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   ecommodity_convert_usnumber   ${return_value}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]  ${return_value}

#SV
Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   ecommodity_convert_usnumber   ${return_value}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]   ${return_value}

#SV
Отримати інформацію про guarantee.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   guarantee.amount
  ${return_value}=   ecommodity_convert_usnumber   ${return_value}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]   ${return_value}

#SV
Отримати інформацію про items[0].quantity
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   ecommodity_convert_usnumber   ${return_value}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]  ${return_value}

#SV
Отримати інформацію про value.currency
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.currency
  ${return_value}=   Convert To String     ${return_value}
  [Return]  ${return_value}

#SV  
Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.valueAddedTaxIncluded
  ${return_value}=   convert_ecommodity_string      ${return_value}
  [Return]  ${return_value}

#SV
Отримати інформацію про auctionId
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderId
  [Return]  ${return_value}

#SV
Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [Return]  ${return_value}
  
#SV
Отримати інформацію про tenderAttempts
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderAttempts
  ${return_value}=   convert_ecommodity_string   ${return_value}
  [Return]  ${return_value}

#SV
Отримати інформацію про tenderPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=   convert_ecommodity_date_to_iso_format   ${return_value}
  ${return_value}=   add_timezone_to_date                    ${return_value.split('.')[0]}
  [Return]    ${return_value}

#SV
Отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=   convert_ecommodity_date_to_iso_format   ${return_value}
  ${return_value}=   add_timezone_to_date                    ${return_value.split('.')[0]}
  [Return]    ${return_value}

#SV
Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  enquiryPeriod.startDate
  ${return_value}=   convert_ecommodity_date_to_iso_format   ${return_value}
  ${return_value}=   add_timezone_to_date                    ${return_value.split('.')[0]}
  [Return]    ${return_value}

#SV
Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  enquiryPeriod.endDate
  ${return_value}=   convert_ecommodity_date_to_iso_format   ${return_value}
  ${return_value}=   add_timezone_to_date                    ${return_value.split('.')[0]}
  [Return]  ${return_value}

#SV
Отримати інформацію про auctionPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  auctionPeriod.startDate
  ${return_value}=   convert_ecommodity_date_to_iso_format   ${return_value}
  ${return_value}=   add_timezone_to_date                    ${return_value.split('.')[0]}
  [return]  ${return_value}

#SV
Отримати інформацію про auctionPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  auctionPeriod.endDate
  ${return_value}=   convert_ecommodity_date_to_iso_format   ${return_value}
  ${return_value}=   add_timezone_to_date                    ${return_value.split('.')[0]}
  [Return]  ${return_value}

#SV  
Отримати інформацію про bids
	Execute JavaScript    $('.hiddenContentDetails').show();
	Page Should Contain Element   xpath=//div[@id="bidsViewID"]
	${present}=  Run Keyword And Return Status    Page Should Contain Element   xpath=//img[@id='loaderBids']
	Run Keyword If  ${present}   Run Keywords
	...   Execute Javascript   $('div[id="bidsViewID"]').hide();
	...   AND   Click Element   xpath=//a[@id='action_bids_details']
	...   AND   Wait Until Element Is Not Visible   xpath=//img[@id='loaderBids']   25
	Execute JavaScript    $('.hiddenContentDetails').show();
	Page Should Contain Element   xpath=//div[contains(@id,'bids_details_')]
	${return_value}=     Get Matching Xpath Count  //div[contains(@id,'bids_details_')]
	[Return]   ${return_value}
  
#SV
Подати цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId
    ...    ${ARGUMENTS[2]} ==  ${test_bid_data}
    ${qualified}=       Get From Dictionary     ${ARGUMENTS[2].data}          qualified
    ${amount}=          Get From Dictionary     ${ARGUMENTS[2].data.value}    amount
    ${amount}=          Convert To String       ${amount}
    ecommodity.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
    Click Element       id=btnAddBid
    Sleep   1
    Wait Until Element Is Visible   xpath=//input[@id = 'value_amount']   15
    Input Text          xpath=//input[@id = 'value_amount']       ${amount}
    Sleep   1
    Run Keyword If  ${qualified}   Select Checkbox   xpath=//input[@id = 'selfQualifiedBool']
    Sleep   2
    Click Element       xpath=//input[@id = 'btnLabelSubmitBid']
    Sleep   1
    Click Element       xpath=//button[@data-bb-handler='success']
    Wait Until Element Is Visible       xpath=//input[@type='submit' and @name='SendRequestToAdmin']   30
    ${resp}=            Get Value                        xpath=//input[@id = 'value_amount']
    ${resp}=            ecommodity_convert_usnumber      ${resp}
    ${resp}=            Convert To Number                ${resp}
    Click Element       xpath=//input[@type='submit' and @name='SendRequestToAdmin']
    Sleep   2
    [Return]    ${resp}

#SV
Змінити цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId
    ...    ${ARGUMENTS[2]} ==  amount
    ...    ${ARGUMENTS[3]} ==  amount.value
    ecommodity.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
    Click Element       id=btnViewOwnBid
    Sleep   1
    Wait Until Element Is Visible   xpath=//a[@id = 'btnEditBid']   15
    Click Element       xpath=//a[@id = 'btnEditBid']
    Sleep   1
    Wait Until Element Is Visible   xpath=//input[@id = 'value_amount']   15
    ${ARGUMENTS[3]}=    Convert To String     ${ARGUMENTS[3]}
    Input Text          xpath=//input[@id = 'value_amount']       ${ARGUMENTS[3]}
    Sleep   2
    Click Element       xpath=//input[@id = 'btnLabelSubmitBid']
    Sleep   1
    Click Element       xpath=//button[@data-bb-handler='success']
    Wait Until Element Is Visible       xpath=//input[@type='submit' and @name='SendRequestToAdmin']   30
    ${resp}=            Get Value                        xpath=//input[@id = 'value_amount']
    ${resp}=            ecommodity_convert_usnumber      ${resp}
    ${resp}=            Convert To Number                ${resp}
    Click Element       xpath=//input[@type='submit' and @name='SendRequestToAdmin']
    Sleep   2
    [Return]    ${resp}

#SV
Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  ecommodity.Отримати пропозицію  ${username}  ${tender_uaid}
  Click Element       xpath=//input[@name='bSendBidToAPIDelete']
  Sleep   1
  Click Element       xpath=//button[@data-bb-handler='success']

#SV
Отримати пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  ecommodity.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element       id=btnViewOwnBid
  Sleep   1
  Wait Until Element Is Visible       xpath=//span[@id = 'span_cbd_published']   15
  ${status}=               Get Element Attribute         xpath=//span[@id = 'span_bid_statusID']@title
  ${data}=                 Create Dictionary             status=${status}
  ${proposition_amount}=   Get Value                     xpath=//input[@id = 'value_amount']
  ${proposition_amount}=   ecommodity_convert_usnumber   ${proposition_amount}
  ${proposition_amount}=   Convert To Number             ${proposition_amount}
  ${value}=                Create Dictionary             amount=${proposition_amount}
  Set To Dictionary  ${data}    value=${value}
  ${bid}=   Create Dictionary   data=${data}
  [return]  ${bid}
  
#SV
Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  ${bid}=   ecommodity.Отримати пропозицію  ${username}  ${tender_uaid}
  [return]  ${bid.data.${field}}
  
#SV
Завантажити документ в ставку
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${documentType}=commercialProposal
    [Documentation]
	...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  file
    ...    ${ARGUMENTS[2]} ==  tenderId
	...    ${ARGUMENTS[3]} ==  filetype
	ecommodity.Отримати пропозицію   ${username}   ${tender_uaid}
	Click Element        xpath=//a[@id = 'btnEditBid']
	Sleep   1
	Wait Until Element Is Visible   xpath=//a[@id='add_bid_doc_']   15
	Click Element        xpath=//a[@id='add_bid_doc_']
	${documentTypeID}=   convert_documentType_string   ${documentType}
	Wait Until Element Is Visible   xpath=//div[@id="DocumentBid"]/descendant::input[@id='titleID_NewDocument']   25
	Page Should Contain Element     xpath=//div[@id='DocumentBid']/descendant::select[@id="NewDocument_DocumentType_ID"]/option[@value="${documentTypeID}"]
	Select From List     xpath=//div[@id='DocumentBid']/descendant::select[@id="NewDocument_DocumentType_ID"]   ${documentTypeID}
	Execute JavaScript   $(document.evaluate("/html/.//div[@id='DocumentBid']/descendant::input[@id='uploadFileId_NewDocument']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue).show()
	Choose File          xpath=//div[@id="DocumentBid"]/descendant::input[@id="uploadFileId_NewDocument"]    ${filepath}
	Sleep   1
	${fake_name}=   Get Value   xpath=//div[@id="DocumentBid"]/descendant::input[@id="DocumentuploadFileId_NewDocument"]
	Input Text      xpath=//div[@id="DocumentBid"]/descendant::input[@id='titleID_NewDocument']   ${fake_name}
	Click Element   xpath=//div[@id="DocumentBid"]/descendant::input[@name='AddBidDocument']
	Wait Until Page Does Not Contain   xpath=//div[@id="DocumentBid"]   20
	Click Button       id=btnLabelSubmitBid
	Sleep   1
	Click Element       xpath=//button[@data-bb-handler='success']
    Wait Until Element Is Visible    xpath=//input[@type='submit' and @name='SendRequestToAdmin']   30
	Click Element       xpath=//input[@type='submit' and @name='SendRequestToAdmin']
	Sleep   1

#SV
Змінити документ в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${file_path}  ${docid}
	ecommodity.Отримати пропозицію   ${username}   ${tender_uaid}
	Click Element   xpath=//a[@id = 'btnEditBid']
	Sleep   1
	Wait Until Element Is Visible   xpath=//a[@name = 'edit_bid_doc_${docid}']   15
	Scroll Page To Element XPATH   xpath=//a[@name = 'edit_bid_doc_${docid}']
	Click Element   xpath=//a[@name = 'edit_bid_doc_${docid}']
	Wait Until Element Is Visible   xpath=//div[@id="DocumentBid"]/descendant::input[@id='titleID_NewDocument']   10
	Execute JavaScript   $(document.evaluate("/html/.//div[@id='DocumentBid']/descendant::input[@id='uploadFileId_NewDocument']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue).show()
	Choose File     xpath=//div[@id="DocumentBid"]/descendant::input[@id="uploadFileId_NewDocument"]    ${file_path}
	Sleep   1
	${fake_name}=   Get Value   xpath=//div[@id="DocumentBid"]/descendant::input[@id="DocumentuploadFileId_NewDocument"]
	Input Text      xpath=//div[@id="DocumentBid"]/descendant::input[@id='titleID_NewDocument']   ${fake_name}
	Click Element   xpath=//div[@id="DocumentBid"]/descendant::input[@name='AddBidDocument']
	Wait Until Page Does Not Contain   xpath=//div[@id="DocumentBid"]   10
	Click Button       id=btnLabelSubmitBid
	Sleep   1
	Click Element   xpath=//button[@data-bb-handler='success']
    Wait Until Element Is Visible    xpath=//input[@type='submit' and @name='SendRequestToAdmin']   30
	Click Element   xpath=//input[@type='submit' and @name='SendRequestToAdmin']
	Sleep   1
	
#SV
Завантажити протокол аукціону
    [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
	ecommodity.Отримати пропозицію   ${username}   ${tender_uaid}
	Click Element       id=btnAddAuctionProtocol
	Wait Until Element Is Visible   xpath=//div[@id="auctionProtocolBid"]/descendant::input[@id='titleID_NewDocument']   25
	Execute JavaScript   $(document.evaluate("/html/.//div[@id='auctionProtocolBid']/descendant::input[@id='uploadFileId_NewDocument']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue).show()
	Choose File   xpath=//div[@id="auctionProtocolBid"]/descendant::input[@id="uploadFileId_NewDocument"]    ${filepath}
	Sleep   1
	${fake_name}=   Get Value   xpath=//div[@id="auctionProtocolBid"]/descendant::input[@id="DocumentuploadFileId_NewDocument"]
	Input Text      xpath=//div[@id="auctionProtocolBid"]/descendant::input[@id='titleID_NewDocument']   ${fake_name}
	Click Element   xpath=//div[@id="auctionProtocolBid"]/descendant::input[@name='AddAuctionProtocol']
	Wait Until Page Does Not Contain   xpath=//div[@id="auctionProtocolBid"]   20
	Sleep   1

#SV
Завантажити фінансову ліцензію
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}
  ecommodity.Завантажити документ в ставку  ${username}  ${filepath}  ${tender_uaid}  financialLicense
  
#==================Документы аукциона======================

#SV
Завантажити документ в тендер з типом
	[Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${documentType}
	ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
	Click Element   id=btnEditTender
	Sleep   1
	Click Element   xpath=//div[@id="aDocumentsList_ID"]/descendant::a[@id="actionCreateDocumentID"]
	Wait Until Element Is Visible    xpath=//div[@id="createADocForm"]   15
	${documentTypeID}=   convert_documentType_string   ${documentType}
	Page Should Contain Element    xpath=//select[@id='DocumentType_ID']/option[@value="${documentTypeID}"]
	Select From List By Value   xpath=//select[@id='DocumentType_ID']   ${documentTypeID}
	Execute JavaScript   $('input[id="createUploadFileId"]').show()
	Choose File     xpath=//input[@id="createUploadFileId"]    ${filepath}
	${fake_name}=   Get Value   xpath=//input[@id='title_adoc']
	Sleep   1
	Click Button    id=createSubmitId
	Wait Until Page Contains  ${fake_name}  25

#SV
Завантажити документ
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}
    ecommodity.Завантажити документ в тендер з типом  ${username}  ${tender_uaid}  ${filepath}  tenderNotice

#SV
Завантажити ілюстрацію
    [Arguments]  ${username}  ${tender_uaid}  ${filepath}
	ecommodity.Завантажити документ в тендер з типом  ${username}  ${tender_uaid}  ${filepath}  illustration

#SV
Додати Virtual Data Room
    [Arguments]  ${username}  ${tender_uaid}  ${vdr_url}  ${title}=Sample Virtual Data Room
    ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Click Element   id=btnEditTender
	Sleep   1
	Click Element   xpath=//a[@id="actionTenderDocs"]
	Wait Until Element Is Visible    xpath=//img[@id="showAddDoc_ID"]   5
	Click Element   id=showAddDoc_ID
	${documentTypeID}=   convert_documentType_string   virtualDataRoom
	Page Should Contain Element    xpath=//select[@id='DocumentType_ID']/option[@value="${documentTypeID}"]
    Select From List By Value   xpath=//select[@id='DocumentType_ID']  ${documentTypeID}
	Sleep   1
	Input Text   xpath=//div[@id="createDocPartialId"]/descendant::input[@id='url']   ${vdr_url}
    Input Text   xpath=//div[@id="createDocPartialId"]/descendant::input[@id='title']   ${title}
    Click Button    id=createSubmitId
	Wait Until Page Contains  ${title}  25

#SV
Додати публічний паспорт активу
  [Arguments]  ${username}  ${tender_uaid}  ${certificate_url}  ${title}=Public Asset Certificate
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element   id=btnEditTender
  Sleep   1
  Click Element   xpath=//a[@id="actionTenderDocs"]
  Wait Until Element Is Visible    xpath=//img[@id="showAddDoc_ID"]   5
  Click Element   id=showAddDoc_ID
  ${documentTypeID}=   convert_documentType_string   x_dgfPublicAssetCertificate
  Page Should Contain Element    xpath=//select[@id='DocumentType_ID']/option[@value="${documentTypeID}"]
  Select From List By Value   xpath=//select[@id='DocumentType_ID']  ${documentTypeID}
  Sleep   1
  Input Text   xpath=//div[@id="createDocPartialId"]/descendant::input[@id='url']   ${certificate_url}
  Input Text   xpath=//div[@id="createDocPartialId"]/descendant::input[@id='title']   ${title}
  Click Button    id=createSubmitId
  Wait Until Page Contains  ${title}  25

#SV
Додати офлайн документ
	[Arguments]  ${username}  ${tender_uaid}  ${accessDetails}  ${title}=Familiarization with bank asset
	ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
	Click Element   id=btnEditTender
	Sleep   1
	Click Element   xpath=//div[@id="aDocumentsList_ID"]/descendant::a[@id="actionCreateDocumentID"]
	Wait Until Element Is Visible    xpath=//div[@id="createADocForm"]   15
	${documentTypeID}=   convert_documentType_string   x_dgfAssetFamiliarization
	Page Should Contain Element    xpath=//select[@id='DocumentType_ID']/option[@value="${documentTypeID}"]
	Select From List By Value   xpath=//select[@id='DocumentType_ID']   ${documentTypeID}
	Sleep   1
	Input Text      xpath=//div[@id="createADocForm"]/descendant::textarea[@id='accessDetails']   ${accessDetails}
	Input Text      xpath=//div[@id="createADocForm"]/descendant::input[@id='title_adoc']   ${title}
	Sleep   1
	Click Button    id=createSubmitId
	Wait Until Page Contains  ${title}  25

#==================Документы аукциона======================

#SV
Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}  ${field_value}
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element                 id=btnPatchTender
  Sleep   1
  Page Should Contain Element   id=clickEditSubmitId
  ${value}=  Convert To String  ${field_value}
  Input Text                    ${locator.patchTender.${field_name}}  ${value}
  Click Element                 id=clickEditSubmitId

#==================Питання======================  

#SV
Задати питання
  [Arguments]  ${username}  ${tender_uaid}  ${question}  ${btnlocator}
  ${title}=        Get From Dictionary  ${question.data}  title
  ${description}=  Get From Dictionary  ${question.data}  description
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute JavaScript    $('.hiddenContentDetails').show();
  Scroll Page To Element XPATH   ${btnlocator}
  Sleep   1
  Click Element       ${btnlocator}
  Wait Until Element Is Visible    xpath=//div[@id='questionBodyId']   20
  Input Text          xpath=//div[@id='questionBodyId']/descendant::input[@id='title']             ${title}
  Input Text          xpath=//div[@id='questionBodyId']/descendant::textarea[@id='description']    ${description}
  Sleep  1
  Click Element       xpath=//div[@id="questionBodyId"]/descendant::input[@type='submit']
  Wait Until Element Is Not Visible   xpath=//div[@id="questionBodyId"]   20

#SV
Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  ${btnlocator}=   Set Variable   xpath=//a[@id='сbtnAddQuestion']
  ecommodity.Задати питання  ${username}  ${tender_uaid}  ${question}  ${btnlocator}

#SV
Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
  ${btnlocator}=   Set Variable   xpath=//dd[contains(text(),'${item_id}')]/ancestor::div[contains(@id,'ItemDetails_')]/descendant::a[contains(@id,'btnAddItemQuestion_')]
  ecommodity.Задати питання  ${username}  ${tender_uaid}  ${question}  ${btnlocator}

#SV
Відповісти на запитання
	[Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
	ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
	Execute JavaScript    $('.hiddenContentDetails').show();
	${present}=  Run Keyword And Return Status    Page Should Contain Element   xpath=//img[@name='IMG_Load_Question']
	Run Keyword If  ${present}   Run Keywords
	...   Execute Javascript   $('div[name="Div_Questions"]').hide();
	...   AND   Execute Javascript   $('a[name="ActionShowQuestions"]').click();
	...   AND   Wait Until Page Does Not Contain Element   xpath=//img[@name='IMG_Load_Question']  30
	${locator_send_answer}=   Set Variable   xpath=//dd[contains(text(),'${question_id}')]/ancestor::div[@name='div_show_question']/descendant::a[@name='ActionSendAnswer']
	Scroll Page To Element XPATH   ${locator_send_answer}
	Sleep   1
	Click Element   ${locator_send_answer}
	Wait Until Element Is Visible   xpath=//div[@id="questionBodyId"]   20
	Input Text      xpath=//div[@id="questionBodyId"]/descendant::textarea[@id='answer']        ${answer_data.data.answer}
	Sleep   1
	Click Element   xpath=//div[@id="questionBodyId"]/descendant::input[@type='submit']
	Wait Until Element Is Not Visible   xpath=//div[@id="questionBodyId"]   20


#SV	
Отримати інформацію про questions[${q_id}].${field_name}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${present}=  Run Keyword And Return Status    Page Should Contain Element   xpath=//img[@name='IMG_Load_Question']
  Run Keyword If  ${present}   Run Keywords
  ...   Execute Javascript   $('div[name="Div_Questions"]').hide();
  ...   AND   Execute Javascript   $('a[name="ActionShowQuestions"]').click();
  ...   AND   Wait Until Page Does Not Contain Element   xpath=//img[@name='IMG_Load_Question']  30
  ${return_value}=  Get Text  name=questions[${q_id}].${field_name}
  ${return_value}=   Run Keyword If   "${field_name}" == "date"   ecommodity_convertdate   ${return_value}
  ...   ELSE   Set Variable   ${return_value}
  [Return]  ${return_value}

#==================Питання======================  

#SV
Отримати інформацію про cancellations[0].reason
  ${return_value}=  Get text          ${locator.cancellations[0].reason}
  [Return]  ${return_value}

#SV  
Отримати інформацію про cancellations[0].status
  ${return_value}=  Get Element Attribute          ${locator.cancellations[0].status}
  [Return]  ${return_value}

#SV
Знайти кваліфікацію по індексу
   [Arguments]  ${username}  ${tender_uaid}  ${award_num}
   ecommodity.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
   Sleep  1
   ${not_present_qual}=   Run Keyword And Return Status   Page Should Not Contain Element   xpath=//a[@id="btnQualification"]
   Run Keyword If   ${not_present_qual}   Run Keywords
   ...   Sleep   102
   ...   AND   ecommodity.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
   ...   AND   Sleep   1
   Click Element                    xpath=//a[@id="btnQualification"]
   ${award_num}=   Run KeyWord If     ${award_num} == -1
   ...   Set Variable   1
   ...   ELSE   Set Variable   ${award_num}
   Click Element                    xpath=//a[@id="btnQualificationEdit_${award_num}"]
   Sleep  1

#SV
Скасування рішення кваліфікаційної комісії
	[Arguments]  ${username}  ${tender_uaid}  ${award_num}
	Run Keyword If   'provider' in '${username}'
	...  ecommodity.Скасування рішення кваліфікаційної комісії учасником  ${username}  ${tender_uaid}  ${award_num}
	...  ELSE  ecommodity.Скасування рішення кваліфікаційної комісії замовником  ${username}  ${tender_uaid}  ${award_num}

#BO
Скасування рішення кваліфікаційної комісії замовником
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    Знайти кваліфікацію по індексу      ${username}  ${tender_uaid}  ${award_num}
    Page Should Contain Element			xpath=//div[@name="awardDetails_${award_num}"]/descendant::select[@name="status"]/option[@value="cancelled"]
    Select From List					xpath=//div[@name="awardDetails_${award_num}"]/descendant::select[@name="status"]   cancelled
    Click Element						xpath=//div[@name="awardDetails_${award_num}"]/descendant::input[@name="awardPublishSubmit"]

#SV
Скасування рішення кваліфікаційної комісії учасником
	[Arguments]  ${username}  ${tender_uaid}  ${award_num}
	ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
	Click Element       id=btnViewOwnBid
	Sleep   1
	Wait Until Element Is Visible   id=buttonRejectSecondPlaceBidUser   15
	Click Button        id=buttonRejectSecondPlaceBidUser
	Sleep   1
	Click Element       xpath=//button[@data-bb-handler='success']

#BO
Дискваліфікувати постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}  ${description}
    Знайти кваліфікацію по індексу      ${username}  ${tender_uaid}  ${award_num}
    ${not_award_disc_page}=   Run Keyword And Return Status   Page Should Not Contain Element   xpath=//button[@id='btnDisqualYN']
    Run Keyword If   ${not_award_disc_page}   Click Element   xpath=//a[@id='aSet_unsuccessful']
    Wait Until Page Contains Element   xpath=//button[@id='btnDisqualYN']   15
    Input Text      xpath=//textarea[@id='description']   ${description}
    ${temp_file_path}  ${temp_file_title}  ${temp_file_content}=  create_fake_doc
    ${present_file_download}=   Run Keyword And Return Status   Page Should Contain Element   xpath=//a[@id="actionCreateDocumentID"]
    Run Keyword If   ${present_file_download}   ecommodity.Додати документ до кваліфікації   ${temp_file_path}   awardDisqualification
    Remove File  ${temp_file_path}
    Click Element   xpath=//button[@id='btnDisqualYN']
    Sleep   1
    Click Element                    xpath=//button[@data-bb-handler='success']

Додати документ до кваліфікації
	[Arguments]   ${filepath}   ${documentType}
	Click Element                              xpath=//a[@id="actionCreateDocumentID"]
	Wait Until Element Is Visible              xpath=//div[@id="createADocForm"]   15
	${documentTypeID}=                         convert_documentType_string   ${documentType}
	Page Should Contain Element                xpath=//select[@id='DocumentType_ID']/option[@value="${documentTypeID}"]
	Select From List By Value                  xpath=//select[@id='DocumentType_ID']   ${documentTypeID}
	Execute JavaScript                         $('input[id="createUploadFileId"]').show()
	Choose File                                xpath=//input[@id="createUploadFileId"]    ${filepath}
	Click Button                               id=createSubmitId
	Wait Until Page Does Not Contain Element   xpath=//div[@id="createADocForm"]   20

#SV
Завантажити протокол аукціону в авард
	[Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
	Знайти кваліфікацію по індексу      ${username}  ${tender_uaid}  ${award_index}
	ecommodity.Додати документ до кваліфікації   ${filepath}   auctionProtocol

#BO
Підтвердити постачальника
  [Documentation]
  ...      [Arguments] Username, tender uaid and number of the award to confirm
  ...      [Return] Nothing
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Знайти кваліфікацію по індексу   ${username}  ${tender_uaid}  ${award_num}
  Click Element                    xpath=//button[@id='bSet_active']
  Sleep   2
  Click Element                    xpath=//button[@data-bb-handler='success']
  Sleep   1

#SV
Підтвердити наявність протоколу аукціону
    [Arguments]  ${username}  ${tender_uaid}  ${award_index}
    ${not_award_page}=   Run Keyword And Return Status   Page Should Not Contain Element   xpath=//form[@id='formAward']
    Run Keyword If   ${not_award_page}        Знайти кваліфікацію по індексу   ${username}  ${tender_uaid}  ${award_index}
    Click Element                             xpath=//a[@id='aSet_pending_payment']
    Wait Until Page Does Not Contain Element  xpath=//a[@id='aSet_pending_payment']   15

#SV
Отримати інформацію про awards[${award_index}].status
	${award_index}=   Run Keyword If     ${award_index} == -1
	...   Set Variable   1
	...   ELSE   Set Variable   ${award_index}
	${status}=   Get Element Attribute   xpath=//dd[@name="awards[${award_index}].status"]@title
	[Return]   ${status}

#SV
Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  ${field_namefull}=  Отримати шлях до поля об’єкта  ${username}  ${field_name}  ${question_id}
  ${value}=  Run Keyword  Отримати інформацію про ${field_namefull}
  [return]  ${value}

#SV
Отримати посилання на аукціон для глядача
    [Arguments]  @{ARGUMENTS}
    ecommodity.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
	Execute JavaScript    $('.hiddenContentDetails').show();
    ${result}=                  Get Element Attribute               id=public_auctionUrl@href
    [Return]   ${result}

#SV
Отримати посилання на аукціон для учасника
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    ecommodity.Отримати пропозицію   ${username}   ${tender_uaid}
    ${notpresent}=   Run Keyword And Return Status   Page Should Not Contain Element   id=private_participationUrl
    Run Keyword If   ${notpresent}   Run Keywords
    ...   Sleep   102
    ...   AND   ecommodity.Отримати пропозицію   ${username}   ${tender_uaid}
    ${result}=                  Get Element Attribute               id=private_participationUrl@title
    [Return]   ${result}

#BO
Скасувати закупівлю
	[Documentation]
	...      [Arguments] Username, tender uaid, cancellation reason,
	...      document and new description of document
	...      [Description] Find tender using uaid, set cancellation reason, get data from cancel_tender
	...      and call create_cancellation
	...      After that add document to cancellation and change description of document
	...      [Return] Nothing
	[Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${document}  ${new_description}
	ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
	Wait Until Element Is Visible       id=btnCancelTender   10
	Click Element                       id=btnCancelTender
	Sleep  2
	Input text                          xpath=//textarea[@id="Cancel_reason"]      ${cancellation_reason}
	Click Element                       xpath=//a[@id='actionCreateDocumentID']
	Wait Until Element Is Visible       xpath=//div[@id="createADocForm"]   15
	Execute JavaScript                  $('input[id="createUploadFileId"]').show()
	Choose File                         xpath=//input[@id="createUploadFileId"]    ${document}
	Execute JavaScript                  $('input[id="title_adoc"]').val($('input[id="createUploadFileId"]')[0].files[0].name)
	Input text                          xpath=//div[@id="createADocForm"]/descendant::textarea[@id="description_adoc"]        ${new_description}
	Sleep   1
	Click Button                        id=createSubmitId
	Wait Until Element Is Not Visible   xpath=//div[@id="createADocForm"]   20
	Click Element                       xpath=//input[@id="submitClickId"]
	Wait Until Page Does Not Contain Element   xpath=//input[@id="submitClickId"]   20

Завантажити угоду до тендера
	[Arguments]  ${username}  ${tender_uaid}  ${contract_num}  ${filepath}
	ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
	Wait Until Element Is Visible       xpath=//a[@id="btnContractSigning"]         30
	Click Element                       xpath=//a[@id="btnContractSigning"]
	Wait Until Element Is Visible       xpath=//button[@id="bSetContractPending"]   30
	Click Element                       xpath=//a[@name="addContractDoc"]
	Sleep   2
	Execute JavaScript                  $(document.evaluate("/html/.//div[@name='newContractDoc']/descendant::input[@id='uploadFile']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue).show()
	Choose File                         xpath=//div[@name='newContractDoc']/descendant::input[@id='uploadFile']    ${filepath}
	Sleep   1
	Click Element     	                xpath=//button[@id="bSetContractPending"]

Підтвердити підписання контракту
	[Documentation]
	...      [Arguments] Username, tender uaid, contract number
	...      [Return] Nothing
	[Arguments]  ${username}  ${tender_uaid}  ${contract_num}
	ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
	Wait Until Element Is Visible       xpath=//a[@id="btnContractSigning"]        30
	Click Element                       xpath=//a[@id="btnContractSigning"]
	Wait Until Element Is Visible       xpath=//button[@id="bSetContractActive"]   30
	Input text                          xpath=//input[@id="contractNumber"]   12345
	Input text                          xpath=//textarea[@id="title"]         contract title
	Click Element                       xpath=//button[@id="bSetContractActive"]