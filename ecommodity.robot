*** Settings ***
Library     Selenium2Library
Library     DateTime
Library     Collections
Library     ecommodity_helper.py


*** Variables ***
${login_email}                                 id=Email
${login_pass}                                  id=Password
${locator.assetID}                             name=auction_tenderID
${locator.lotID}                               name=auction_tenderID
${locator.assetsID}                            name=assetID
${locator.auctionID}                           name=auction_tenderID
${locator.date}                                name=asset_date
${locator.dateModified}                        name=asset_dateModified
${locator.rectificationPeriod.endDate}         name=auction_rectificationPeriod_endDate
${locator.status}                              name=auction_status
${locator.title}                               name=auction_title
${locator.description}                         name=auction_description
${locator.minNumberOfQualifiedBids}            name=auction_minNumberOfQualifiedBids
${locator.procurementMethodType}               name=auction_procurementMethodType
${locator.procuringEntity.name}                name=auction_procuringEntity_name
${locator.value.amount}                        name=auction_value_amount
${locator.minimalStep.amount}                  name=auction_minimalStep_amount
${locator.guarantee.amount}                    name=auction_guarantee_amount
${locator.registrationFee.amount}              name=auction_registrationFee_amount
${locator.tenderPeriod.endDate}                name=auction_tenderPeriod_endDate
${locator.cancellations[0].reason}                   id=tenderCancellationReason
${locator.cancellations[0].status}                   id=tenderCancellationReason@title

*** Keywords ***

Підготувати клієнт для користувача
  [Arguments]     @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=ec_${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'ecommodity_viewer'   Login   ${ARGUMENTS[0]}

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


Підготувати дані для оголошення тендера
  [Documentation]  Це слово використовується в майданчиків, тому потрібно, щоб воно було і тут
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${tender_data}=  Run Keyword If   '${username}' == 'ecommodity_owner'
  ...  ecommodity_set_custodian   ${tender_data}
  ...  ELSE   Set Variable   ${tender_data}
  [return]  ${tender_data}



Створити об'єкт МП
    [Arguments]    ${username}  ${tender_data}
    Click Element  xpath=//ul[@name='ul_cabinet_md']/descendant::a[@id='ddTCabinetMenuId']
    Sleep  1
    Click Element  xpath=//ul[@name='ul_cabinet_md']/descendant::a[@id='linkMyAssetsID']
    Sleep  2
    Click Element  xpath=//a[@id='linkCreateNewAssetID']
    Sleep  1
    ${title}=          Get From Dictionary  ${tender_data.data}                 title
    ${description}=    Get From Dictionary  ${tender_data.data}                 description
    ${decisionDate}=   Get From Dictionary  ${tender_data.data.decisions[0]}    decisionDate
    ${decisionID}=     Get From Dictionary  ${tender_data.data.decisions[0]}    decisionID
    ${decisionTitle}=  Get From Dictionary  ${tender_data.data.decisions[0]}    title
    Input text         id=title                       ${title}
    Input text         id=description                 ${description}
    Input text         name=[0].title                 ${decisionTitle}
    Input text         name=[0].decisionDate          ${decisionDate}
    Input text         name=[0].decisionID            ${decisionID}
    Click Element      xpath=//a[@id='actionCreateHolderID']
    Sleep  2
    Wait Until Page Contains Element  xpath=//form[@id = 'formCreateAssetHolderID']  15
    ${holder}=                  Get From Dictionary  ${tender_data.data}        assetHolder
    ${h_name}=                  Get From Dictionary  ${holder}                  name
    ${h_address_countryName}    Get From Dictionary  ${holder.address}          countryName
    ${h_address_locality}       Get From Dictionary  ${holder.address}          locality
    ${h_address_postalCode}     Get From Dictionary  ${holder.address}          postalCode
    ${h_address_region}         Get From Dictionary  ${holder.address}          region
    ${h_address_streetAddress}  Get From Dictionary  ${holder.address}          streetAddress
    ${h_address_countryName}    Get From Dictionary  ${holder.address}          countryName
    ${h_CP_email}               Get From Dictionary  ${holder.contactPoint}     email
    ${h_CP_faxNumber}           Get From Dictionary  ${holder.contactPoint}     faxNumber
    ${h_CP_name}                Get From Dictionary  ${holder.contactPoint}     name
    ${h_CP_telephone}           Get From Dictionary  ${holder.contactPoint}     telephone
    ${h_CP_url}                 Get From Dictionary  ${holder.contactPoint}     url
    ${h_identifier_id}          Get From Dictionary  ${holder.identifier}       id
    ${h_identifier_legalName}   Get From Dictionary  ${holder.identifier}       legalName
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::textarea[@id='name']                  ${h_name}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::textarea[@id='identifier_legalName']  ${h_identifier_legalName}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='identifier_id']            ${h_identifier_id}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='address_streetAddress']    ${h_address_streetAddress}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='address_locality']         ${h_address_locality}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='address_region']           ${h_address_region}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='address_postalCode']       ${h_address_postalCode}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='address_countryName']      ${h_address_countryName}
    Click Element  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::a[@href='#contactPointData_ID']
    Sleep  1
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='contactPoint_name']        ${h_CP_name}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='contactPoint_email']       ${h_CP_email}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='contactPoint_telephone']   ${h_CP_telephone}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='contactPoint_faxNumber']   ${h_CP_faxNumber}
    Input text  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='contactPoint_url']         ${h_CP_url}
    Click Element  xpath=//form[@id = 'formCreateAssetHolderID']/descendant::input[@id='saveCreateAssetHolderID']
    Sleep  1
    Wait Until Page Does Not Contain Element  xpath=//form[@id = 'formCreateAssetHolderID']  15
    Sleep  1
    Click Element  xpath=//input[@id='tenderCreateSubmitId']
    Sleep  1
    Wait Until Page Contains Element  xpath=//input[@id = 'clickPublishSubmitId']  15
    Sleep  1
    Input text  xpath=//form[@id='formSPAssetEditID']/descendant::input[@name='[0].decisionDate']               ${decisionDate}
    ${items}=  Get From Dictionary  ${tender_data.data}  items
    ${number_of_items}=  Get Length  ${items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Додати актив МП  ${items[${index}]}
    Click Button        id=clickPublishSubmitId
    Wait Until Element Is Visible   xpath=//span[@id = 'assetUAID']   30
    ${asset_uaid}=      Get Text    xpath=//span[@id = 'assetUAID']
    [Return]            ${asset_uaid}


Додати актив МП
    [Arguments]  ${item}
    ${item_description}=                     Get From Dictionary         ${item}                       description
    ${classification_scheme}=                Get From Dictionary         ${item.classification}        scheme
    ${classification_id}=                    Get From Dictionary         ${item.classification}        id
    ${classification_id}=                    convert_CAVMP               ${classification_id}
    ${address_postalcode}=                   Get From Dictionary         ${item.address}               postalCode
    ${address_countryname}=                  Get From Dictionary         ${item.address}               countryName
    ${address_streetaddress}=                Get From Dictionary         ${item.address}               streetAddress
    ${address_region}=                       Get From Dictionary         ${item.address}               region
    ${address_locality}=                     Get From Dictionary         ${item.address}               locality
    ${unit_code}=                            Get From Dictionary         ${item.unit}                  code
    ${unit_name}=                            Get From Dictionary         ${item.unit}                  name
    ${quantity}=                             Get From Dictionary         ${item}                       quantity
    ${registrationDetails_status}=           Get From Dictionary         ${item.registrationDetails}   status
    ${quantity}=                             Convert To String           ${quantity}
    ${present_location}=                     Run Keyword And Return Status   Dictionary Should Contain Key  ${item}  location
    ${location_latitude}=                    Run Keyword If                  ${present_location}
    ...   Get From Dictionary                ${item.location}                latitude
    ...   ELSE                               Set Variable                    ${EMPTY}
    ${location_latitude}=                    Run Keyword If                  ${present_location}
    ...   Convert To String                  ${location_latitude}
    ...   ELSE                               Set Variable                    ${EMPTY}
    ${location_longitude}=                   Run Keyword If                  ${present_location}
    ...   Get From Dictionary                ${item.location}                longitude
    ...   ELSE                               Set Variable                    ${EMPTY}
    ${location_longitude}=                   Run Keyword If                  ${present_location}
    ...   Convert To String                  ${location_longitude}
    ...   ELSE                               Set Variable                    ${EMPTY}
    ${present_registrationID}=               Run Keyword And Return Status   Dictionary Should Contain Key  ${item.registrationDetails}  registrationID
    ${registrationID}=                       Run Keyword If                  ${present_registrationID}
    ...   Get From Dictionary                ${item.registrationDetails}     registrationID
    ...   ELSE                               Set Variable                    ${EMPTY}
    ${present_registrationDate}=             Run Keyword And Return Status   Dictionary Should Contain Key  ${item.registrationDetails}  registrationDate
    ${registrationDate}=                     Run Keyword If                  ${present_registrationDate}
    ...   Get From Dictionary                ${item.registrationDetails}     registrationDate
    ...   ELSE                               Set Variable                    ${EMPTY}
    Wait Until Element Is Visible   xpath=//a[@id = 'actionCreateItemID']   10
    Click Element                   xpath=//a[@id = 'actionCreateItemID']
    Wait Until Element Is Visible   xpath=//div[@id='tender_item_template_id']   10
    Sleep   2
    Input text                      xpath=//div[@id='tender_item_template_id']/descendant::textarea[@id='description']  ${item_description}
    Input text                      xpath=//div[@id='tender_item_template_id']/descendant::input[@id='quantityId']      ${quantity}
    Click Element                   xpath=//div[@id='tender_item_template_id']/descendant::a[@id='CAVPS_Classifier_select_ID']
    Sleep   1
    Wait Until Page Contains Element    xpath=//div[@id = 'modalBodyClassifyID']/descendant::input[@id='KeyWord']   15
    Wait Until Element Is Not Visible   xpath=//div[@id = 'modalBodyClassifyID']/descendant::img[@name='loadingIDHeader']   15
    Sleep   1
    Input text                      xpath=//div[@id = 'modalBodyClassifyID']/descendant::input[@id='KeyWord']  ${classification_id}
    Click Element                   xpath=//div[@id = 'modalBodyClassifyID']/descendant::div[@id='searchId']
    Sleep   1
    Wait Until Element Is Not Visible   xpath=//div[@id = 'modalBodyClassifyID']/descendant::img[@name='loadingIDBody']   15
    Click Element       xpath=//div[@id = 'modalBodyClassifyID']/descendant::table/descendant::td[@data-id='${classification_id}']
    Click Button        id=okButton
    Sleep   1
    Select From List    xpath=//div[@id='tender_item_template_id']/descendant::select[@id="unit_code"]                   ${unit_code}
    Select From List    xpath=//div[@id='tender_item_template_id']/descendant::select[@id="registrationDetails_status"]  ${registrationDetails_status}
    Sleep   1
    Run Keyword If      '${registrationDetails_status}' == 'complete'  Run Keywords
    ...         Input text    xpath=//div[@id='tender_item_template_id']/descendant::input[@id='registrationDetails_registrationID']    ${registrationID}
    ...   AND   Input text    xpath=//div[@id='tender_item_template_id']/descendant::input[@id='registrationDetails_registrationDate']  ${registrationDate}
    Click Element       xpath=//div[@id='tender_item_template_id']/descendant::a[@href='#addressDataId']
    Sleep   1
    Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_streetAddress']   ${address_streetaddress}
    Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_locality']        ${address_locality}
    Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_region']          ${address_region}
    Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_postalCode']      ${address_postalcode}
    Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='address_countryName']     ${address_countryname}
    Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='location_latitude']       ${location_latitude}
    Input text          xpath=//div[@id='tender_item_template_id']/descendant::input[@id='location_longitude']      ${location_longitude}
    Click Button        id=saveNewItemID
    Sleep   1


Пошук об’єкта МП по ідентифікатору
    [Arguments]  ${username}  ${asset_uaid}
    Switch browser   ec_${username}
    Go to   ${USERS.users['${username}'].homepage}
    Click Element   xpath=//a[@id='ddTPrivatizationId']
    Click Element   xpath=//a[@id='SPAssetsListID']
    Wait Until Element Is Visible   xpath=//input[@id='btnClearFilter']   15
    Scroll Page To Element XPATH   xpath=//input[@id='btnClearFilter']
    Click Button   id=btnClearFilter
    Input Text   id=assetID   ${asset_uaid}
    Scroll Page To Element XPATH   xpath=//input[@id='btnFilter']
    Click Button   id=btnFilter
    Wait Until Element Is Not Visible   xpath=//div[@id='divFilter']/descendant::div[@name='loadingIDFilter']   25
    Scroll Page To Top
    Click Element   xpath=//a[@id='showDetails_${asset_uaid}']
    Wait Until Element Is Visible   xpath=//div[@name = 'divTenderDetails']   15


Отримати інформацію із об'єкта МП
    [Arguments]  ${username}  ${asset_uaid}  ${field_name}
    Execute JavaScript    $('.hiddenContentDetails').show();
    ${return_value}=   Run KeyWord  Отримати інформацію про ${fieldname}
    [Return]  ${return_value}


Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [Return]  ${return_value}


Отримати інформацію про assetID
  ${return_value}=   Отримати текст із поля і показати на сторінці   assetID
  [Return]  ${return_value}


Отримати інформацію про title
  ${return_value}=   Отримати текст із поля і показати на сторінці   title
  [Return]  ${return_value}


Отримати інформацію про description
  ${return_value}=   Отримати текст із поля і показати на сторінці   description
  [Return]  ${return_value}


Отримати інформацію про rectificationPeriod.endDate
  ${return_value}=   Get Element Attribute   name=auction_rectificationPeriod_endDate@isodate
  [Return]    ${return_value}


Отримати інформацію про status
  Reload Page
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${return_value}=   Отримати текст із поля і показати на сторінці   status
  ${return_value}=   Run Keyword If  '${MODE}'=='lots'   convert_ecommodity_string   LOT_${return_value}
  ...   ELSE IF   '${MODE}'=='assets'                    convert_ecommodity_string   ASSET_${return_value}
  ...   ELSE IF   '${MODE}'=='auctions'                  convert_ecommodity_string   SELLOUT_${return_value}
  ...   ELSE   Set Variable   ${return_value}
  [Return]  ${return_value}


Отримати інформацію про date
  ${return_value}=   Get Element Attribute   name=asset_date@isodate
  [Return]  ${return_value}

Отримати інформацію про dateModified
  Reload Page
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${return_value}=   Get Element Attribute   name=asset_dateModified@isodate
  [Return]  ${return_value}

Отримати інформацію про decisions[${decision_num}].title
  ${return_value}=   Get Text  name=decisions[${decision_num}].title
  [Return]  ${return_value}


Отримати інформацію про decisions[${decision_num}].decisionID
  ${return_value}=   Get Text  name=decisions[${decision_num}].decisionID
  [Return]  ${return_value}


Отримати інформацію про decisions[${decision_num}].decisionDate
  ${return_value}=  Get Element Attribute  name=decisions[${decision_num}].decisionDate@isodate
  [Return]  ${return_value}


Отримати інформацію про assetHolder.${holder_field}
  ${return_value}=   Run KeyWord If   '${holder_field}' == 'identifier.scheme'
  ...   Отримати інформацію про attribute assetHolder.identifier.scheme
  ...   ELSE   Get Text   name=assetHolder.${holder_field}
  [Return]  ${return_value}


Отримати інформацію про attribute assetHolder.identifier.scheme
  ${return_value}=   Get Element Attribute   name=assetHolder.identifier.id@ident_scheme
  [Return]  ${return_value}


Отримати інформацію про assetCustodian.${custodian_field}
  ${return_value}=   Run KeyWord If   '${custodian_field}' == 'identifier.scheme'
  ...   Отримати інформацію про attribute assetCustodian.identifier.scheme
  ...   ELSE   Get Text   name=assetCustodian.${custodian_field}
  [Return]  ${return_value}


Отримати інформацію про attribute assetCustodian.identifier.scheme
  ${return_value}=   Get Element Attribute   name=assetCustodian.identifier.id@ident_scheme
  [Return]  ${return_value}


Отримати інформацію про documents[${document_index}].documentType
  ${path_value}=   Set Variable  xpath=//div[@name='partialDocumentDetails']/descendant::div[@name='div_document_body_${document_index}']/descendant::dd[@name='documents.documentType']
  ${return_value}=   Get Element Attribute   ${path_value}@title
  [Return]  ${return_value}


Отримати інформацію з активу об'єкта МП
  [Arguments]  ${username}  ${asset_uaid}  ${item_id}  ${field_name}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${path_value}=   Set Variable  xpath=//dd[contains(text(),'${item_id}')]/ancestor::div[contains(@id,'ItemDetails_')]
  ${item_num}=  Get Element Attribute   ${path_value}@item_num
  ${return_value}=   Run KeyWord   Отримати інформацію про items[${item_num}].${field_name}
  [Return]  ${return_value}


Отримати інформацію про items[${item_num}].${field_name}
  ${return_value}=   Get Text  name=items[${item_num}].${field_name}
  ${return_value}=   Run KeyWord If   '${field_name}' == 'quantity'   Конвертація числа зі сторінки   ${return_value}
  ...   ELSE IF   '${field_name}' == 'registrationDetails.status'     Отримати інформацію з активу про attribute registrationDetails.status   ${item_num}
  ...   ELSE   Set Variable   ${return_value}
  [Return]  ${return_value}


Конвертація числа зі сторінки
  [Arguments]  ${value_to_convert}
  ${return_value}=   ecommodity_convert_usnumber   ${value_to_convert}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]  ${return_value}


Отримати інформацію з активу про attribute registrationDetails.status
  [Arguments]  ${item_num}
  ${return_value}=   Get Element Attribute   name=items[${item_num}].registrationDetails.status@title
  [Return]  ${return_value}


Завантажити документ в об'єкт МП з типом
  [Arguments]  ${username}  ${asset_uaid}  ${filepath}  ${documentType}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}
  Click Element   id=btnEditAsset
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

Завантажити ілюстрацію в об'єкт МП
  [Arguments]  ${username}  ${asset_uaid}  ${filepath}
  ecommodity.Завантажити документ в об'єкт МП з типом  ${username}  ${asset_uaid}  ${filepath}  illustration

Внести зміни в об'єкт МП
  [Arguments]  ${username}  ${asset_uaid}  ${fieldname}  ${fieldvalue}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}
  Click Element  id=btnEditAsset
  Sleep   1
  Run KeyWord  Внести зміни в об'єкт МП поле ${fieldname}  ${fieldvalue}
  Click Button  id=clickPublishSubmitId
  Sleep   1
  Wait Until Element Is Visible   xpath=//span[@id = 'assetUAID']   30
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}

Внести зміни в об'єкт МП поле title
  [Arguments]  ${fieldvalue}
  Input text  xpath=//form[@id='formSPAssetEditID']/descendant::textarea[@id='title']  ${fieldvalue}

Внести зміни в об'єкт МП поле description
  [Arguments]  ${fieldvalue}
  Input text  xpath=//form[@id='formSPAssetEditID']/descendant::textarea[@id='description']  ${fieldvalue}

Внести зміни в об'єкт МП поле decisions[0].title
  [Arguments]  ${fieldvalue}
  Input text  xpath=//form[@id='formSPAssetEditID']/descendant::textarea[@id='AssetDecision_title']  ${fieldvalue}

Внести зміни в об'єкт МП поле decisions[0].decisionDate
  [Arguments]  ${fieldvalue}
  Input text  xpath=//form[@id='formSPAssetEditID']/descendant::input[@id='AssetDecision_decisionDate']  ${fieldvalue}

Внести зміни в об'єкт МП поле decisions[0].decisionID
  [Arguments]  ${fieldvalue}
  Input text  xpath=//form[@id='formSPAssetEditID']/descendant::textarea[@id='AssetDecision_decisionID']  ${fieldvalue}

Внести зміни в актив об'єкта МП
  [Arguments]  ${username}  ${item_id}  ${asset_uaid}  ${fieldname}  ${fieldvalue}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}
  Click Element  id=btnEditAsset
  Sleep   1
  ${path_value}=   Set Variable  xpath=//span[@name='item_header_description' and contains(text(),'${item_id}')]
  ${item_num_id}=  Get Element Attribute   ${path_value}@item_num_id
  Click Element  id=btnItemEdit_${item_num_id}
  Wait Until Element Is Visible   xpath=//div[@id='tender_item_template_id']   10
  Sleep   1
  Run KeyWord  Внести зміни в актив об'єкта МП поле ${fieldname}  ${fieldvalue}
  Click Element  id=saveEditItemID
  Wait Until Page Does Not Contain Element   xpath=//div[@id='tender_item_template_id']   25
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}

Внести зміни в актив об'єкта МП поле quantity
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=  Convert To String  ${fieldvalue}
  Input text  xpath=//div[@id='tender_item_template_id']/descendant::input[@id='quantityId']  ${fieldvalue}

Внести зміни в актив об'єкта МП поле description
  [Arguments]  ${fieldvalue}
  Input text  xpath=//div[@id='tender_item_template_id']/descendant::textarea[@id='description']  ${fieldvalue}

Внести зміни в актив об'єкта МП поле registrationDetails.status
  [Arguments]  ${fieldvalue}
  Select From List    xpath=//div[@id='tender_item_template_id']/descendant::select[@id="registrationDetails_status"]  ${fieldvalue}

Додати актив до об'єкта МП
  [Arguments]  ${username}  ${asset_uaid}  ${item}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}
  Click Element  id=btnEditAsset
  Sleep   1
  Run KeyWord  Додати актив МП  ${item}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}

Завантажити документ для видалення об'єкта МП
  [Arguments]  ${username}  ${asset_uaid}  ${file_path}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}
  Click Element  id=btnDeleteAsset
  Sleep   1
  Click Element   xpath=//a[@id="actionCreateDocumentID"]
  Wait Until Element Is Visible    xpath=//div[@id="createADocForm"]   15
  ${documentTypeID}=   convert_documentType_string   cancellationDetails
  Page Should Contain Element    xpath=//select[@id='DocumentType_ID']/option[@value="${documentTypeID}"]
  Select From List By Value   xpath=//select[@id='DocumentType_ID']   ${documentTypeID}
  Execute JavaScript   $('input[id="createUploadFileId"]').show()
  Choose File     xpath=//input[@id="createUploadFileId"]    ${filepath}
  ${fake_name}=   Get Value   xpath=//input[@id='title_adoc']
  Sleep   1
  Click Button    id=createSubmitId
  Wait Until Page Contains  ${fake_name}  25

Видалити об'єкт МП
  [Arguments]  ${username}  ${asset_uaid}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}
  Click Element  id=btnDeleteAsset
  Sleep   1
  Click Element  id=clickPublishSubmitId
  Sleep   2
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}

Отримати документ
  [Arguments]  ${username}  ${asset_uaid}  ${doc_id}
  Execute JavaScript   $('.hiddenContentDetails').show();
  ${file_name}=   Get Text   xpath=//div[@name='partialDocumentDetails']/descendant::dd[contains(text(),'${doc_id}')]/ancestor::div[contains(@name,'div_document_body_')]/descendant::dd[@name='documents.title']
  ${url}=   Get Element Attribute   xpath=//div[@name='partialDocumentDetails']/descendant::dd[contains(text(),'${doc_id}')]/ancestor::div[contains(@name,'div_document_body_')]/descendant::a[@name='documents.url']@href
  ecommodity_download_file   ${url}  ${file_name}  ${OUTPUT_DIR}
  [return]  ${file_name}


Отримати кількість активів в об'єкті МП
  [Arguments]  ${username}  ${asset_uaid}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}
  ${res}=   Get Text   xpath=//span[@name='span_items_count']
  [return]  ${res}


############# ЛОТЫ ################################################################

Створити лот
    [Arguments]    ${username}  ${tender_data}  ${asset_uaid}
    ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}
    Click Element   id=btnCreateLot
    Sleep   1
    Input text  id=decision_decisionID    ${tender_data.data.decisions[0].decisionID}
    Input text  id=decision_decisionDate  ${tender_data.data.decisions[0].decisionDate}
    Click Element  id=tenderCreateSubmitId
    Wait Until Element Is Visible   xpath=//span[@id = 'lotUAID']   30
    ${lot_uaid}=  Get Text  xpath=//span[@id = 'lotUAID']
    [Return]  ${lot_uaid}

Пошук лоту по ідентифікатору
    [Arguments]  ${username}  ${lot_uaid}
    Switch browser   ec_${username}
    Go to   ${USERS.users['${username}'].homepage}
    Click Element   xpath=//a[@id='ddTPrivatizationId']
    Click Element   xpath=//a[@id='SPAssetLotsListID']
    Wait Until Element Is Visible   xpath=//input[@id='btnClearFilter']   15
    Scroll Page To Element XPATH   xpath=//input[@id='btnClearFilter']
    Click Button   id=btnClearFilter
    Input Text   id=lotID   ${lot_uaid}
    Scroll Page To Element XPATH   xpath=//input[@id='btnFilter']
    Click Button   id=btnFilter
    Wait Until Element Is Not Visible   xpath=//div[@id='divFilter']/descendant::div[@name='loadingIDFilter']   25
    Scroll Page To Top
    Click Element   xpath=//a[@id='showDetails_${lot_uaid}']
    Wait Until Element Is Visible   xpath=//div[@name = 'divTenderDetails']   15

Отримати інформацію із лоту
    [Arguments]  ${username}  ${lot_uaid}  ${field_name}
    Execute JavaScript    $('.hiddenContentDetails').show();
    ${return_value}=  Run Keyword  Отримати інформацію про ${fieldname}
    [Return]  ${return_value}

Отримати інформацію з активу лоту
  [Arguments]  ${username}  ${lot_uaid}  ${item_id}  ${field_name}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${path_value}=   Set Variable  xpath=//dd[contains(text(),'${item_id}')]/ancestor::div[contains(@id,'ItemDetails_')]
  ${item_num}=  Get Element Attribute   ${path_value}@item_num
  ${return_value}=   Run KeyWord   Отримати інформацію про items[${item_num}].${field_name}
  [Return]  ${return_value}


Додати умови проведення аукціону
  [Arguments]  ${username}  ${auction}  ${index}  ${lot_uaid}
  Run KeyWord  Додати умови проведення аукціону номер ${index}  ${username}  ${lot_uaid}  ${auction}

Додати умови проведення аукціону номер 0
  [Arguments]  ${username}  ${lot_uaid}  ${auction}
  Sleep  60
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}
  Click Element  id=btnEditLot
  Sleep   1
  Click Element  id=btnAuctionsEdit
  Sleep   1
  ${accelerator}=  convert_ecommodity_accelerator_from_string  ${auction.procurementMethodDetails}
  Input Text  id=Accelerator  ${accelerator}
  Input Text  id=auctionPeriod_startDate  ${auction.auctionPeriod.startDate}
  ${value_amount}=  Convert To String  ${auction.value.amount}
  Input Text  id=value_amount  ${value_amount}
  ${value_valueaddedtaxincluded}=  Convert To String  ${auction.value.valueAddedTaxIncluded}
  ${value_valueaddedtaxincluded}=  convert_ecommodity_string  ${value_valueaddedtaxincluded}
  UnSelect Checkbox  id=value_valueAddedTaxIncludedBool
  Run Keyword If  ${value_valueaddedtaxincluded} == True  Select Checkbox  id=value_valueAddedTaxIncludedBool
  ${minimalStep}=  Convert To String  ${auction.minimalStep.amount}
  Input Text  id=minimalStep_amount  ${minimalStep}
  ${guarantee_amount}=  Convert To String  ${auction.guarantee.amount}
  Input Text  id=guarantee_amount  ${guarantee_amount}
  ${registrationFee}=  Convert To String  ${auction.registrationFee.amount}
  Input Text  id=registrationFee_amount  ${registrationFee}
  Input Text  id=accountDetails_description  ${auction.bankAccount.description}
  Input Text  id=accountDetails_bankName  ${auction.bankAccount.bankName}
  Click Element  id=actionCreateItemID
  Sleep  2
  Wait Until Element Is Visible  id=formCreateAccIdentID  15
  Select From List By Value   xpath=//form[@id='formCreateAccIdentID']/descendant::select[@id='scheme']  ${auction.bankAccount.accountIdentification[0].scheme}
  Input Text  xpath=//form[@id='formCreateAccIdentID']/descendant::input[@id='id']  ${auction.bankAccount.accountIdentification[0].id}
  Input Text  xpath=//form[@id='formCreateAccIdentID']/descendant::textarea[@id='description']  ${auction.bankAccount.accountIdentification[0].description}
  Click Element  id=saveNewAccIdentID
  Sleep  1
  Wait Until Page Does Not Contain Element  id=formCreateAccIdentID  15

Додати умови проведення аукціону номер 1
  [Arguments]  ${username}  ${lot_uaid}  ${auction}
  ${duration}=  convert_iso8601Duration  ${auction.tenderingDuration}
  Input Text  id=Duration_Days  ${duration}
  Scroll Page To Element XPATH  xpath=//input[@id='clickPublishSubmitId']
  Sleep   1
  Click Element  id=clickPublishSubmitId
  Sleep   1
  ${ispost}=   Run Keyword And Return Status   Wait Until Element Is Visible  id=btnAuctionsEdit  15
  Run Keyword Unless  ${ispost}  Run Keywords
  ...  Click Element  id=clickPublishSubmitId
  ...  AND  Sleep  1
  ...  AND  Wait Until Element Is Visible  id=btnAuctionsEdit  15
  Click Element  id=clickPublishSubmitId
  Sleep   1

Отримати інформацію про lotID
  ${return_value}=   Отримати текст із поля і показати на сторінці   lotID
  [Return]  ${return_value}

Отримати інформацію про assets
  ${return_value}=   Отримати текст із поля і показати на сторінці   assetsID
  [Return]  ${return_value}

Отримати інформацію про lotHolder.${holder_field}
  ${return_value}=   Run KeyWord If   '${holder_field}' == 'identifier.scheme'
  ...   Отримати інформацію про attribute lotHolder.identifier.scheme
  ...   ELSE   Get Text   name=lotHolder.${holder_field}
  [Return]  ${return_value}


Отримати інформацію про attribute lotHolder.identifier.scheme
  ${return_value}=   Get Element Attribute   name=lotHolder.identifier.id@ident_scheme
  [Return]  ${return_value}


Отримати інформацію про lotCustodian.${custodian_field}
  ${return_value}=   Run KeyWord If   '${custodian_field}' == 'identifier.scheme'
  ...   Отримати інформацію про attribute lotCustodian.identifier.scheme
  ...   ELSE   Get Text   name=lotCustodian.${custodian_field}
  [Return]  ${return_value}

Отримати інформацію про attribute lotCustodian.identifier.scheme
  ${return_value}=   Get Element Attribute   name=lotCustodian.identifier.id@ident_scheme
  [Return]  ${return_value}

Отримати інформацію про auctions[${auc_num}].procurementMethodType
  ${return_value}=   Get Element Attribute   name=auctions[${auc_num}].procurementMethodType@title
  [Return]  ${return_value}

Отримати інформацію про auctions[${auc_num}].status
  ${return_value}=   Get Element Attribute   name=auctions[${auc_num}].status@title
  [Return]  ${return_value}

Отримати інформацію про auctions[${auc_num}].tenderAttempts
  ${return_value}=   Get Text   name=auctions[${auc_num}].tenderAttempts
  ${return_value}=   convert_ecommodity_string   ${return_value}
  [Return]  ${return_value}

Отримати інформацію про auctions[${auc_num}].auctionID
  Sleep   60
  Reload Page
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${return_value}=   Get Text   name=auctions[${auc_num}].auctionID
  [Return]  ${return_value}

Отримати інформацію про auctions[${auc_num}].${value_type}.amount
  ${status}  ${return_value}=  Run Keyword And Ignore Error  Get Element Attribute   name=auctions[${auc_num}].${value_type}.amount@value_amount_us
  ${return_value}=   Run KeyWord If  '${status}' == 'PASS'
  ...   Convert To Number   ${return_value}
  ...   ELSE   Convert To Number  0
  [Return]  ${return_value}

Отримати інформацію про auctions[${auc_num}].tenderingDuration
  ${return_value}=   Get Element Attribute   name=auctions[${auc_num}].tenderingDuration@isodate
  [Return]  ${return_value}

Отримати інформацію про auctions[${auc_num}].auctionPeriod.startDate
  Reload Page
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${return_value}=   Get Element Attribute   name=auctions[${auc_num}].auctionPeriod.startDate@isodate
  [Return]  ${return_value}

Завантажити документ в лот з типом
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}  ${documentType}
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}
  Click Element   id=btnEditLot
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

Завантажити ілюстрацію в лот
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}
  ecommodity.Завантажити документ в лот з типом  ${username}  ${lot_uaid}  ${filepath}  illustration

Внести зміни в лот
  [Arguments]  ${username}  ${lot_uaid}  ${fieldname}  ${fieldvalue}
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}
  Click Element  id=btnEditLot
  Sleep   1
  Run KeyWord  Внести зміни в лот поле ${fieldname}  ${fieldvalue}
  Scroll Page To Element XPATH  xpath=//input[@id='clickPublishSubmitId']
  Click Element  xpath=//input[@id='clickPublishSubmitId']
  Sleep   1
  ${ispost}=   Run Keyword And Return Status   Wait Until Page Does Not Contain Element  xpath=//form[@id='formSPLotEditID']  15
  Run Keyword Unless  ${ispost}  Click Element  xpath=//input[@id='clickPublishSubmitId']
  Wait Until Page Does Not Contain Element  xpath=//form[@id='formSPLotEditID']  15
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}

Внести зміни в лот поле title
  [Arguments]  ${fieldvalue}
  Input text  xpath=//form[@id='formSPLotEditID']/descendant::textarea[@id='title']  ${fieldvalue}

Внести зміни в лот поле description
  [Arguments]  ${fieldvalue}
  Input text  xpath=//form[@id='formSPLotEditID']/descendant::textarea[@id='description']  ${fieldvalue}

Внести зміни в актив лоту
  [Arguments]  ${username}  ${item_id}  ${lot_uaid}  ${fieldname}  ${fieldvalue}
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}
  Click Element  id=btnEditLot
  Sleep   1
  ${path_value}=   Set Variable  xpath=//span[@name='item_header_description' and contains(text(),'${item_id}')]
  ${item_num_id}=  Get Element Attribute   ${path_value}@item_num_id
  Click Element  id=btnItemEdit_${item_num_id}
  Wait Until Element Is Visible   xpath=//div[@id='tender_item_template_id']   10
  Sleep   1
  Run KeyWord  Внести зміни в актив лоту поле ${fieldname}  ${fieldvalue}
  Click Element  id=saveEditItemID
  Wait Until Page Does Not Contain Element   xpath=//div[@id='tender_item_template_id']   15
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}

Внести зміни в актив лоту поле quantity
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=  Convert To String  ${fieldvalue}
  Input text  xpath=//div[@id='tender_item_template_id']/descendant::input[@id='quantityId']  ${fieldvalue}

Внести зміни в умови проведення аукціону
  [Arguments]  ${username}  ${lot_uaid}  ${fieldname}  ${fieldvalue}  ${auc_num}
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}
  Click Element  id=btnEditLot
  Sleep   1
  Click Element  id=datаOfAuctionsID
  Sleep   1
  Click Element  id=btnAuctionsEdit
  Sleep   1
  Run KeyWord  Внести зміни в умови проведення аукціону поле ${fieldname}  ${fieldvalue}
  Scroll Page To Element XPATH  xpath=//input[@id='clickPublishSubmitId']
  Sleep   1
  Click Element  id=clickPublishSubmitId
  ${ispost}=   Run Keyword And Return Status   Wait Until Page Contains Element  id=formSPLotEditID  15
  Run Keyword Unless  ${ispost}  Click Element  id=clickPublishSubmitId
  Sleep   1
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}

Внести зміни в умови проведення аукціону поле value.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=  Convert To String  ${fieldvalue}
  Input Text  id=value_amount  ${fieldvalue}

Внести зміни в умови проведення аукціону поле minimalStep.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=  Convert To String  ${fieldvalue}
  Input Text  id=minimalStep_amount  ${fieldvalue}

Внести зміни в умови проведення аукціону поле guarantee.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=  Convert To String  ${fieldvalue}
  Input Text  id=guarantee_amount  ${fieldvalue}

Внести зміни в умови проведення аукціону поле registrationFee.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=  Convert To String  ${fieldvalue}
  Input Text  id=registrationFee_amount  ${fieldvalue}

Внести зміни в умови проведення аукціону поле auctionPeriod.startDate
  [Arguments]  ${fieldvalue}
  Input Text  id=auctionPeriod_startDate  ${fieldvalue}

Завантажити документ в умови проведення аукціону
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}  ${documentType}  ${auction_index}
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}
  Click Element  id=btnEditLot
  Sleep   1
  Click Element  id=datаOfAuctionsID
  Sleep   1
  Click Element  xpath=//div[@name='aDocumentsList_aucnum_${auction_index}']/descendant::a[@id='actionCreateDocumentID']
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

Завантажити документ для видалення лоту
  [Arguments]  ${username}  ${lot_uaid}  ${file_path}
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}
  Click Element  id=btnDeleteLot
  Sleep   1
  Click Element   xpath=//a[@id="actionCreateDocumentID"]
  Wait Until Element Is Visible    xpath=//div[@id="createADocForm"]   15
  ${documentTypeID}=   convert_documentType_string   cancellationDetails
  Page Should Contain Element    xpath=//select[@id='DocumentType_ID']/option[@value="${documentTypeID}"]
  Select From List By Value   xpath=//select[@id='DocumentType_ID']   ${documentTypeID}
  Execute JavaScript   $('input[id="createUploadFileId"]').show()
  Choose File     xpath=//input[@id="createUploadFileId"]    ${filepath}
  ${fake_name}=   Get Value   xpath=//input[@id='title_adoc']
  Sleep   1
  Click Button    id=createSubmitId
  Wait Until Page Contains  ${fake_name}  25

Видалити лот
  [Arguments]  ${username}  ${lot_uaid}
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}
  Click Element  id=btnDeleteLot
  Sleep   1
  Click Element  id=clickPublishSubmitId
  Sleep   2
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}

Оновити сторінку з об'єктом МП
  [Arguments]  ${username}  ${asset_uaid}
  Switch browser   ec_${username}
  Go to   ${USERS.users['${username}'].homepage}
  ecommodity.Пошук об’єкта МП по ідентифікатору  ${username}  ${asset_uaid}

Оновити сторінку з лотом
  [Arguments]  ${username}  ${lot_uaid}
  Switch browser   ec_${username}
  Go to   ${USERS.users['${username}'].homepage}
  ecommodity.Пошук лоту по ідентифікатору  ${username}  ${lot_uaid}

############################### АУКЦИОН ######################################################

Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser   ec_${username}
  Go to   ${USERS.users['${username}'].homepage}
  Click Element   id=tendersPageBtn
  Wait Until Element Is Visible   xpath=//input[@id = 'btnClearFilter']   15
  Scroll Page To Element XPATH   xpath=//input[@id='btnClearFilter']
  Click Button   id=btnClearFilter
  Input Text     id=tenderID   ${tender_uaid}
  Scroll Page To Element XPATH   xpath=//input[@id='btnFilter']
  Click Button   id=btnFilter
  Wait Until Element Is Not Visible   xpath=//div[@id = 'divFilter']/descendant::div[@name='loadingIDFilter']   25
  Scroll Page To Top
  Click Element   xpath=//a[@id = 'showDetails_${tender_uaid}']
  Wait Until Element Is Visible   xpath=//div[@name = 'divTenderDetails']   15

Оновити сторінку з тендером
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser   ec_${username}
  Go to   ${USERS.users['${username}'].homepage}
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}

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
  Wait Until Page Does Not Contain Element   xpath=//div[@id="questionBodyId"]   20

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  ${btnlocator}=   Set Variable   xpath=//a[@id='сbtnAddQuestion']
  ecommodity.Задати питання  ${username}  ${tender_uaid}  ${question}  ${btnlocator}

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
  ${btnlocator}=   Set Variable   xpath=//dd[contains(text(),'${item_id}')]/ancestor::div[contains(@id,'ItemDetails_')]/descendant::a[contains(@id,'btnAddItemQuestion_')]
  ecommodity.Задати питання  ${username}  ${tender_uaid}  ${question}  ${btnlocator}

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
  Wait Until Page Does Not Contain Element   xpath=//div[@id="questionBodyId"]   20

Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${return_value}=   Run KeyWord  Отримати інформацію про ${fieldname}
  [Return]  ${return_value}

Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${path_value}=   Set Variable  xpath=//dd[contains(text(),'${item_id}')]/ancestor::div[contains(@id,'ItemDetails_')]
  ${item_num}=  Get Element Attribute   ${path_value}@item_num
  ${return_value}=   Run KeyWord   Отримати інформацію про items[${item_num}].${field_name}
  [Return]  ${return_value}

Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  ${field_namefull}=  Отримати шлях до поля об’єкта  ${username}  ${field_name}  ${question_id}
  ${value}=  Run Keyword  Отримати інформацію про ${field_namefull}
  [return]  ${value}

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

Подати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${test_bid_data}
    ${qualified}=       Get From Dictionary     ${test_bid_data.data}          qualified
    ${amount}=          Get From Dictionary     ${test_bid_data.data.value}    amount
    ${amount}=          Convert To String       ${amount}
    ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
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

Отримати інформацію про auctionID
  ${return_value}=   Отримати текст із поля і показати на сторінці   auctionID
  [Return]  ${return_value}

Отримати інформацію про minNumberOfQualifiedBids
  ${return_value}=   Отримати текст із поля і показати на сторінці   minNumberOfQualifiedBids
  ${return_value}=   Convert To Number   ${return_value}
  [Return]  ${return_value}

Отримати інформацію про procurementMethodType
  ${return_value}=   Отримати текст із поля і показати на сторінці   procurementMethodType
  ${return_value}=  convert_ecommodity_string  SELLOUT_${return_value}
  [Return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [Return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   ecommodity_convert_usnumber   ${return_value}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   ecommodity_convert_usnumber   ${return_value}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]   ${return_value}

Отримати інформацію про guarantee.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   guarantee.amount
  ${return_value}=   ecommodity_convert_usnumber   ${return_value}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]   ${return_value}

Отримати інформацію про registrationFee.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   registrationFee.amount
  ${return_value}=   ecommodity_convert_usnumber   ${return_value}
  ${return_value}=   Convert To Number             ${return_value}
  [Return]   ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=   convert_ecommodity_date_to_iso_format   ${return_value}
  ${return_value}=   add_timezone_to_date                    ${return_value.split('.')[0]}
  [Return]    ${return_value}

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

Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  ${bid}=   ecommodity.Отримати пропозицію  ${username}  ${tender_uaid}
  [return]  ${bid.data.${field}}

Змінити цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
    ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Click Element       id=btnViewOwnBid
    Sleep   1
    Wait Until Element Is Visible   xpath=//a[@id = 'btnEditBid']   15
    Click Element       xpath=//a[@id = 'btnEditBid']
    Sleep   1
    Wait Until Element Is Visible   xpath=//input[@id = 'value_amount']   15
    ${fieldvalue}=      Convert To String     ${fieldvalue}
    Input Text          xpath=//input[@id = 'value_amount']       ${fieldvalue}
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

Завантажити документ в ставку
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${documentType}=commercialProposal
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

Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  ecommodity.Отримати пропозицію  ${username}  ${tender_uaid}
  Click Element  xpath=//input[@name='bSendBidToAPIDelete']
  Sleep   1
  Click Element  xpath=//button[@data-bb-handler='success']

Отримати посилання на аукціон для глядача
    [Arguments]  ${username}  ${tender_uaid}
    ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Execute JavaScript  $('.hiddenContentDetails').show();
    ${result}=  Get Element Attribute  id=public_auctionUrl@href
    [Return]  ${result}

Отримати посилання на аукціон для учасника
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    ecommodity.Отримати пропозицію   ${username}   ${tender_uaid}
    ${notpresent}=   Run Keyword And Return Status   Page Should Not Contain Element   id=private_participationUrl
    Run Keyword If   ${notpresent}   Run Keywords
    ...   Sleep   102
    ...   AND   ecommodity.Отримати пропозицію   ${username}   ${tender_uaid}
    ${result}=   Get Element Attribute   id=private_participationUrl@href
    [Return]   ${result}

Скасувати закупівлю
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
    Input text                          xpath=//div[@id="createADocForm"]/descendant::textarea[@id="description_adoc"]        ${new_description}
    Sleep   1
    Click Button                        id=createSubmitId
    Wait Until Page Does Not Contain Element   xpath=//div[@id="createADocForm"]   20
    Sleep   2
    Click Element                       xpath=//input[@id="submitClickId"]
    Wait Until Page Does Not Contain Element   xpath=//input[@id="submitClickId"]   20

Отримати інформацію про cancellations[0].reason
  ${return_value}=  Get text          ${locator.cancellations[0].reason}
  [Return]  ${return_value}

Отримати інформацію про cancellations[0].status
  ${return_value}=  Get Element Attribute          ${locator.cancellations[0].status}
  [Return]  ${return_value}

Активувати процедуру
  [Arguments]  ${username}  ${tender_uaid}
  Sleep   60
  ecommodity.Оновити сторінку з тендером  ${username}  ${tender_uaid}

############################### КВАЛИФИКАЦИЯ ###################################################

Отримати інформацію про awards[${award_index}].status
  ${status}=   Get Element Attribute   xpath=//dd[@name="awards[${award_index}].status"]@title
  [Return]   ${status}

Отримати кількість авардів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute JavaScript    $('.hiddenContentDetails').show();
  ${return_value}=  Get Element Count  xpath=//div[@id="awardViewID"]/descendant::div[contains(@id,"awardDiv_")]
  [Return]  ${return_value}

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
  Click Element                    xpath=//a[@id="btnQualificationEdit_${award_num}"]
  Sleep  1

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

Завантажити протокол аукціону в авард
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
  ecommodity.Знайти кваліфікацію по індексу  ${username}  ${tender_uaid}  ${award_index}
  ecommodity.Додати документ до кваліфікації  ${filepath}  auctionProtocol

Завантажити протокол погодження в авард
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
  ecommodity.Знайти кваліфікацію по індексу  ${username}  ${tender_uaid}  ${award_index}
  ecommodity.Додати документ до кваліфікації  ${filepath}  admissionProtocol

Активувати кваліфікацію учасника
  [Arguments]  ${username}  ${tender_uaid}
  ${award_num}=  Set Variable  0
  ecommodity.Знайти кваліфікацію по індексу   ${username}  ${tender_uaid}  ${award_num}
  Click Element  xpath=//button[@id='bSet_active']
  Sleep   2
  Click Element  xpath=//button[@data-bb-handler='success']
  Sleep   1

Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  ecommodity.Знайти кваліфікацію по індексу   ${username}  ${tender_uaid}  ${award_num}
  Click Element  xpath=//button[@id='bSet_active']
  Sleep   2
  Click Element  xpath=//button[@data-bb-handler='success']
  Sleep   1

Завантажити протокол дискваліфікації в авард
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_num}
  ecommodity.Знайти кваліфікацію по індексу      ${username}  ${tender_uaid}  ${award_num}
  Click Element   xpath=//a[@id='aSet_unsuccessful']
  Wait Until Page Contains Element   xpath=//button[@id='btnDisqualProtocolYN']   15
  ecommodity.Додати документ до кваліфікації  ${filepath}  rejectionProtocol

Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}  ${description}
  ecommodity.Знайти кваліфікацію по індексу    ${username}  ${tender_uaid}  ${award_num}
  Click Element   xpath=//a[@id='aSet_unsuccessful']
  Wait Until Page Contains Element   xpath=//button[@id='btnDisqualProtocolYN']   15
  Input Text    xpath=//textarea[@id='description']   ${description}
  Click Element  xpath=//button[@id='btnDisqualProtocolYN']
  Sleep   1
  Click Element  xpath=//button[@data-bb-handler='success']

Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element       id=btnViewOwnBid
  Sleep   1
  Wait Until Element Is Visible   id=buttonRejectSecondPlaceBidUser   15
  Click Button        id=buttonRejectSecondPlaceBidUser
  Sleep   1
  Click Element       xpath=//button[@data-bb-handler='success']

############################### КОНТРАКТ ###################################################

Додати документ до контракту
  [Arguments]   ${username}  ${tender_uaid}  ${filepath}  ${documentType}
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible              xpath=//a[@id="btnContractSigning"]      30
  Click Element                              xpath=//a[@id="btnContractSigning"]
  Wait Until Element Is Visible              xpath=//a[@id="actionCreateDocumentID"]  30
  Click Element                              xpath=//a[@id="actionCreateDocumentID"]
  Wait Until Element Is Visible              xpath=//div[@id="createADocForm"]   15
  ${documentTypeID}=                         convert_documentType_string   ${documentType}
  Page Should Contain Element                xpath=//select[@id='DocumentType_ID']/option[@value="${documentTypeID}"]
  Select From List By Value                  xpath=//select[@id='DocumentType_ID']   ${documentTypeID}
  Execute JavaScript                         $('input[id="createUploadFileId"]').show()
  Choose File                                xpath=//input[@id="createUploadFileId"]    ${filepath}
  Click Button                               id=createSubmitId
  Wait Until Page Does Not Contain Element   xpath=//div[@id="createADocForm"]   20

Завантажити протокол скасування в контракт
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${contract_index}
  ecommodity.Додати документ до контракту  ${username}  ${tender_uaid}  ${filepath}  rejectionProtocol

Скасувати контракт
  [Arguments]  ${username}  ${tender_uaid}  ${contract_index}
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible       xpath=//a[@id="btnContractSigning"]      30
  Click Element                       xpath=//a[@id="btnContractSigning"]
  Wait Until Page Contains Element   xpath=//button[@id='btnDisqualProtocolYN']   15
  Click Element  xpath=//button[@id='btnDisqualProtocolYN']
  Sleep   1
  Click Element  xpath=//button[@data-bb-handler='success']

Встановити дату підписання угоди
  [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${fieldvalue}
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible       xpath=//a[@id="btnContractSigning"]      30
  Click Element                       xpath=//a[@id="btnContractSigning"]
  Wait Until Page Contains Element    xpath=//input[@id='dateSigned']   15
  ${fieldvalue}=  ecommodity_convertdateS  ${fieldvalue}
  Input Text  xpath=//input[@id='dateSigned']  ${fieldvalue}
  Click Element  id=bSetContractPending

Завантажити угоду до тендера
  [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${filepath}
  ecommodity.Додати документ до контракту  ${username}  ${tender_uaid}  ${filepath}  contractSigned

Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_index}
  ecommodity.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible       xpath=//a[@id="btnContractSigning"]      30
  Click Element                       xpath=//a[@id="btnContractSigning"]
  Wait Until Page Contains Element    id=bSetContractActive   15
  Click Element                       id=bSetContractActive

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
