*** Settings ***
Library      RequestsLibrary

Variables    data/products_data.json

Resource     resources/keywords/controller.resource
Resource     resources/keywords.resource

Suite Setup    Suite Setup

*** Test Cases ***
TC_PRODUCTS_01 Verify get all products with valid token
    [Tags]    
    ...    Smoke
    ...   Regression

    ${products_response}      Get Products    access_token=${admin_access_token}
    ${products_data}          Set Variable    ${products_response.json()}
    ${data}                   Set Variable    ${get_all_products_with_valid_token}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify List Item
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_02 Verify get all products without token
    [Tags]    
    ...    Regression

    ${products_response}      Get Products
    ${products_data}          Set Variable    ${products_response.json()}
    ${data}                   Set Variable    ${get_all_products_without_token}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_03 Verify get single product with valid ID
    [Tags]    
    ...    Smoke
    ...    Regression
    
    ${data}                   Set Variable    ${get_single_product_with_valid_id}
    ${products_response}      Get Products    access_token=${admin_access_token}    id=${data}[id]
    ${products_data}          Set Variable    ${products_response.json()}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_04 Verify get single product with invalid ID
    [Tags]    
    ...    Regression
    
    ${data}                   Set Variable    ${get_single_product_with_invalid_id}
    ${products_response}      Get Products    access_token=${admin_access_token}    id=${data}[id]
    ${products_data}          Set Variable    ${products_response.json()}
    ${expected_data}          Set Variable    ${data.expected_data}
    ${expected_status_code}   Set Variable    ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_05 Verify create product with admin role
    [Tags]
    ...    Smoke
    ...    Regression

    ${data}                   Set Variable      ${create_product_with_admin_role}
    ${products_response}      Create Product    access_token=${admin_access_token}    name=${data}[name]    price=${data}[price]
    ${products_data}          Set Variable      ${products_response.json()}
    ${expected_data}          Set Variable      ${data.expected_data}
    ${expected_status_code}   Set Variable      ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_06 Verify create product with user role
    [Tags]
    ...    Regression

    ${data}                   Set Variable      ${create_product_with_user_role}
    ${products_response}      Create Product    access_token=${user_access_token}    name=${data}[name]    price=${data}[price]
    ${products_data}          Set Variable      ${products_response.json()}
    ${expected_data}          Set Variable      ${data.expected_data}
    ${expected_status_code}   Set Variable      ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_07 Verify update product with admin role
    [Tags]
    ...    Regression

    ${data}                   Set Variable      ${update_product_with_admin_role}
    ${products_response}      Update Product   access_token=${admin_access_token}    price=${data}[price]    id=${data}[id]
    ${products_data}          Set Variable      ${products_response.json()}
    ${expected_data}          Set Variable      ${data.expected_data}
    ${expected_status_code}   Set Variable      ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_08 Verify update product with user role
    [Tags]
    ...    Regression

    ${data}                   Set Variable      ${update_product_with_user_role}
    ${products_response}      Update Product   access_token=${user_access_token}    price=${data}[price]    id=${data}[id]
    ${products_data}          Set Variable      ${products_response.json()}
    ${expected_data}          Set Variable      ${data.expected_data}
    ${expected_status_code}   Set Variable      ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_09 Verify delete product with admin role
    [Tags]
    ...    Regression

    ${data}                   Set Variable      ${delete_product_with_admin_role}
    ${products_response}      Delete Product    access_token=${admin_access_token}    id=${data}[id]
    ${products_data}          Set Variable      ${products_response.json()}
    ${expected_data}          Set Variable      ${data.expected_data}
    ${expected_status_code}   Set Variable      ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
    ...    ${expected_status_code}

    Verify Item Data
    ...    current_data=${products_data}
    ...    expected_data=${expected_data}

TC_PRODUCTS_10 Verify delete product with user role
    [Tags]
    ...    Regression

    ${data}                   Set Variable      ${delete_product_with_user_role}
    ${products_response}      Delete Product    access_token=${user_access_token}    id=${data}[id]
    ${products_data}          Set Variable      ${products_response.json()}
    ${expected_data}          Set Variable      ${data.expected_data}
    ${expected_status_code}   Set Variable      ${data.status_code}

    Should Be Equal As Integers
    ...    ${products_response.status_code}
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