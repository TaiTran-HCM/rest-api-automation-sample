*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Keywords ***
Verify API Status Success
    [Arguments]    
    ...    ${api_response}
    ...    ${keywords}=${NONE}
    ...    ${arguments}=${NONE}
    
    ${api_response_json}    Set Variable    ${api_response.json()}
        
    Request Should Be Successful    ${api_response}

    ${args}    Create Dictionary    
    ...    current_data=${api_response_json}
    
    FOR    ${argument}    IN    &{arguments}
        Set To Dictionary    ${args}    ${argument}[0]=${argument}[1]
    END

    IF    $keywords
        Run Keyword    ${keywords}    &{args}
    END

Verify API Status Failure
    [Arguments]    
    ...    ${api_response}
    ...    ${keywords}=${NONE}
    ...    ${arguments}=${NONE}

    Status Should Be    404    ${api_response}

    ${args}    Create Dictionary

    FOR    ${argument}    IN    &{arguments}
        Set To Dictionary    ${args}    ${argument}[0]=${argument}[1]
    END

    IF    $keywords
        Run Keyword    ${keywords}    &{args}
    END
    
Verify List Item
    [Arguments]    
    ...    ${current_data}
    ...    ${expected_data}
    ...    ${ignore_keys}=${NONE}

    ${current_length}    Get Length        ${current_data}
    Length Should Be    ${expected_data}    ${current_length}

    FOR    ${index}    IN RANGE    ${current_length}
       Verify Item Data    ${current_data}[${index}]    ${expected_data}[${index}]
    END

Verify Item Data
    [Arguments]
    ...    ${current_data}
    ...    ${expected_data}
    ...    ${ignore_keys}=${NONE}
    
    Dictionaries Should Be Equal    ${current_data}    ${expected_data}    ignore_keys=${ignore_keys}