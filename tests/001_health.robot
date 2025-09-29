*** Settings ***
Library        RequestsLibrary

Variables      data/health_data.json

Resource       resources/keywords/controller.resource
Resource       resources/keywords.resource

*** Test Cases ***
TC_HEALTH_01 Verify health check endpoint
    [Tags]
    ...    Smoke

    ${data}                   Set Variable    ${health_check_endpoint}
    ${health_response}        Get Health
    ${products_data}          Set Variable    ${health_response.json()}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}
    ${ignore_keys}            Set Variable    ${data.ignore_keys}

    Should Be Equal As Integers
    ...    ${health_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}
    ...    ignore_keys=${ignore_keys}