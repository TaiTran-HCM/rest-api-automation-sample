*** Settings ***
Library    RequestsLibrary
Library    Collections

Resource    resources/variables.resource

*** Keywords ***
Login
    [Arguments]    ${username}    ${password}
    ${payload}     Create Dictionary    username=${username}    password=${password}
    ${response}    POST    ${LOGIN_ENDPOINT}    json=${payload}    expected_status=any
    RETURN    ${response}

Get Token
    [Arguments]    ${username}    ${password}
    ${response}    Login    ${username}    ${password}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}   Get From Dictionary    ${response.json()}    token
    RETURN    ${token}

Get Products
    [Arguments]    ${access_token}=${NONE}    ${id}=${NONE}
    
    ${PRODUCTS_ENDPOINT}
    ...    Set Variable If
    ...    $id
    ...    ${PRODUCTS_ENDPOINT}/${id}
    ...    ${PRODUCTS_ENDPOINT}
    
    ${args}    Create Dictionary    
    ...    expected_status=any
    
    IF    $access_token
        ${headers}    Create Dictionary    Authorization=${access_token}
        Set To Dictionary    ${args}    headers=${headers}
    END
        
    ${response}    GET    ${PRODUCTS_ENDPOINT}    &{args}
    RETURN    ${response}

Create Product
    [Arguments]    ${access_token}    ${name}=${NONE}    ${price}=${NONE}    ${id}=${NONE}
    
    ${headers}     Create Dictionary    Authorization=${access_token}
    ${payload}     Create Dictionary    name=${name}    price=${price}    id=${id}
    ${response}    POST    ${PRODUCTS_ENDPOINT}    json=${payload}    headers=${headers}    expected_status=any
    RETURN    ${response}

Update Product
    [Arguments]    ${access_token}=${NONE}    ${name}=${NONE}    ${price}=${NONE}    ${id}=${NONE}
    ${fields}    Create List    name    price
    
    ${PRODUCTS_ENDPOINT}
    ...    Set Variable If
    ...    $id
    ...    ${PRODUCTS_ENDPOINT}/${id}
    ...    ${PRODUCTS_ENDPOINT}

    ${args}    Create Dictionary
    ...    expected_status=any
    
    ${payload}     Create Dictionary
    FOR    ${field}    IN    @{fields}
        ${value}    Get Variable Value    ${${field}}    ${NONE}
        Run Keyword If    $value
        ...    Set To Dictionary    ${payload}    ${field}=${value}
    END
    IF    $payload
        Set To Dictionary    ${args}    json=${payload}
    END

    IF    $access_token
        ${headers}    Create Dictionary    Authorization=${access_token}
        Set To Dictionary    ${args}    headers=${headers}
    END

    ${response}    PUT    ${PRODUCTS_ENDPOINT}    &{args}
    RETURN    ${response}

Delete Product
    [Arguments]    ${access_token}=${NONE}    ${id}=${NONE}
    
    ${PRODUCTS_ENDPOINT}
    ...    Set Variable If
    ...    $id
    ...    ${PRODUCTS_ENDPOINT}/${id}
    ...    ${PRODUCTS_ENDPOINT}
    
    ${args}    Create Dictionary    
    ...    expected_status=any
    
    IF    $access_token
        ${headers}    Create Dictionary    Authorization=${access_token}
        Set To Dictionary    ${args}    headers=${headers}
    END
        
    ${response}    DELETE    ${PRODUCTS_ENDPOINT}    &{args}
    RETURN    ${response}

Get Users
    [Arguments]    ${access_token}=${NONE}

    ${args}    Create Dictionary
    ...    expected_status=any

    IF    $access_token
        ${headers}    Create Dictionary    Authorization=${access_token}
        Set To Dictionary    ${args}    headers=${headers}
    END

    ${response}    GET    ${USERS_ENDPOINT}    &{args}
    RETURN    ${response}

Get Health
    ${args}    Create Dictionary
    ...    expected_status=any

    ${response}    GET    ${HEALTH_ENDPOINT}    &{args}
    RETURN    ${response}
