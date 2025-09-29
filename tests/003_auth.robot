*** Settings ***
Library      RequestsLibrary

Variables      data/auth_data.json

Resource       resources/keywords/controller.resource
Resource       resources/keywords.resource

*** Test Cases ***
TC_AUTH_01 Verify expired token
    [Tags]    
    ...    Regression
    
    ${data}                   Set Variable    ${expired_token}
    ${products_response}      Get Products    access_token=${data}[access_token]
    ${products_data}          Set Variable    ${products_response.json()}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_AUTH_02 Verify invalid token
    [Tags]    
    ...    Regression
    
    ${data}                   Set Variable    ${invalid_token}
    ${products_response}      Get Products    access_token=${data.access_token}
    ${products_data}          Set Variable    ${products_response.json()}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}