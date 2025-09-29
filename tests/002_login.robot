*** Settings ***
Library      RequestsLibrary

Variables    data/login_data.json

Resource     resources/keywords/controller.resource
Resource     resources/keywords.resource


*** Test Cases ***
TC_LOGIN_01 Verify login with valid credentials
    [Tags]    
    ...    Smoke
    ...    Regression
    
    ${authentication_response}
    ...    Login    
    ...    username=admin
    ...    password=123
    
    ${authentication_data}    Set Variable    ${authentication_response.json()}
    ${data}                   Set Variable    ${valid_credentials}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${ignore_keys}            Set Variable    ${data.ignore_keys}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${authentication_response.status_code}
    ...    ${expected_status_code}
    
    Verify Item Data
    ...    current_data=${authentication_data}
    ...    expected_data=${expected_data}
    ...    ignore_keys=${ignore_keys}
    
    Should Not Be Empty
    ...    ${authentication_data}[token]

TC_LOGIN_02 Verify login with invalid credentials
    [Tags]    
    ...    Regression

    ${authentication_response}
    ...    Login
    ...    username=admin
    ...    password=wrong_password
    
    ${authentication_data}    Set Variable    ${authentication_response.json()}
    
    ${data}                   Set Variable    ${invalid_credentials}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${authentication_response.status_code}
    ...    ${expected_status_code}
    
    Verify Item Data
    ...    ${authentication_data}
    ...    ${expected_data}