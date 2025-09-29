*** Settings ***
Library      RequestsLibrary

Variables    data/users_data.json

Resource     resources/keywords/controller.resource
Resource     resources/keywords.resource
Suite Setup    Suite Setup

*** Test Cases ***
TC_USERS_01 Verify get all users with admin role
    [Tags]    
    ...    Regression
    
    ${data}                   Set Variable    ${get_all_users_with_admin_role}
    ${users_response}         Get Users       access_token=${admin_access_token}
    ${products_data}          Set Variable    ${users_response.json()}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${users_response.status_code}
    ...    ${expected_status_code}

    Verify List Item
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_USERS_02 Verify get all users with user role
    [Tags]    
    ...    Regression
    
    ${data}                   Set Variable    ${get_all_users_with_user_role}
    ${users_response}         Get Users       access_token=${user_access_token}
    ${products_data}          Set Variable    ${users_response.json()}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${users_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

*** Keywords ***
Suite Setup
    ${admin_access_token}       Get Token    admin     123
    ${user_access_token}        Get Token    user1     abc
    Set Suite Variable    ${admin_access_token}    ${admin_access_token}
    Set Suite Variable    ${user_access_token}     ${user_access_token}