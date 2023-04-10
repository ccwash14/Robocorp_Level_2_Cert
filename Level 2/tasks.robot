*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    OperatingSystem
Library    RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${csvfile}=    Download the Excel file
    Open the robot order website
    FOR    ${orders}    IN    @{csvfile}
        Close the annoying modal
        Fill out data from CSV file    ${orders}
        Wait Until Keyword Succeeds    5x    3s    Preview the Robot
        Wait Until Keyword Succeeds    120x    3s    Submit the order
        Store the receipt as a PDF file    ${orders}[Order number]
        Take a Screenshot of the Robot    ${orders}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${OUTPUT_DIR}${/}${orders}[Order number]
        Delete Screenshot    ${OUTPUT_DIR}${/}${orders}[Order number]
        Close Receipt   
    END
    Archive pdfs

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}
    ${orders}=   Read table from CSV    orders.csv    header=${True}
    RETURN    ${orders}

Fill out data from CSV file
    [Arguments]    ${orders}
    Select From List By Value    id:head    ${orders}[Head]
    FOR    ${choice}    IN    @{orders}
        Select Radio Button    body    ${orders}[Body]   
    END
    #Select Radio Button    id:body    id-body-${orders}[Body]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input   ${orders}[Legs]
    Input Text    id:address    ${orders}[Address]

Close the annoying modal
    Wait And Click Button    xpath://html/body/div/div/div[2]/div/div/div/div/div/button[1]

Preview the Robot
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image

Submit the order
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt

Take a Screenshot of the Robot
    [Arguments]    ${orders}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${orders}_screenshot.png

Store the receipt as a PDF file
    [Arguments]    ${orders}
    ${htmltostring}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${htmltostring}    ${OUTPUT_DIR}${/}${orders}_pdf.pdf     
    
Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${outputdir}
    @{list}=    Create List    ${outputdir}_screenshot.png
    Open Pdf    ${outputdir}_pdf.pdf
    Add Watermark Image To Pdf    ${outputdir}_screenshot.png    ${outputdir}_pdf.pdf
    Close Pdf    ${outputdir}_pdf.pdf

Delete Screenshot
    [Arguments]    ${outputdir}
    Remove File    ${outputdir}_screenshot.png

Close Receipt
    Click Button    id:order-another

Archive pdfs
    Archive Folder With Zip    ${OUTPUT_DIR}    receipts.zip    include=*.pdf

    
    
    
