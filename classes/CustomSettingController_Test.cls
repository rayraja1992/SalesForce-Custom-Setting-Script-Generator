/**
* @author Raja Bhandari
* @date 25/03/2019
*
* @group My World
*
* @description Test Class for ustomSettingController class to generate custom setting script 
*/
@isTest(seeAllData=true)
private class CustomSettingController_Test{
    
    /**
    * @description To unit test CustomSettingController class
    * @param  
    * @return void : It does not return anything
    */ 
    private static testmethod void CustomSettingControllerTestMethod(){   
    
        String testClassName = Label.Custom_Setting_For_Test_Class;
        List<String> testClassNameStrList = testClassName.split('--'); 
        List<SelectOption> optionList = CustomSettingController.returnCustomSettingsOfOrg();
        for(Integer i = 0; i< testClassNameStrList.size(); i++){
            String customSettingName = testClassNameStrList[i];
            List<String> idsCsSelectedSet = new List<String>();
            List<sObject> sObjectList = Database.query('Select id, Name, SetupOwnerId from '+customSettingName);
            for(sObject sObj : sObjectList){
                idsCsSelectedSet.add(sObj.Id);
            }
            String customSettingNameOptions = '('+customSettingName+')';
            CustomSettingController.ReturnData returnDataObj = CustomSettingController.returnCSRecords(customSettingNameOptions);
            CustomSettingController.customSettingShowDetailMethod(customSettingNameOptions, null, true, idsCsSelectedSet);
            CustomSettingController.customSettingShowDetailMethod(customSettingNameOptions, idsCsSelectedSet[0], false, null);
            System.assert(optionList.size() != null, 'optionList is empty');
            System.assert(returnDataObj != null, 'Data is empty');
        }
    }
}