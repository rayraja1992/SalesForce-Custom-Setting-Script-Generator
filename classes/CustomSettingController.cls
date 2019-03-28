/**
* @author Raja Bhandari
* @date 24/03/2019
*
* @group MyWorld
*
* @description Controller class to generate custom setting script
*/
public with sharing class CustomSettingController{
    
    @Testvisible
    private static String typeOfCs = '';			//Type of custom setting
    private static Map<Id,User> userMap;			//User Map to Hold User objects
    private static Map<Id,Profile> profileMap;		//Profile Map to Hold profile objects
    
    /**
    * @description  Function to populate the picklist values dynamically with custom setting names as options
    * @param  
    * @return List<SelectOption> : List of records to send to component controller
    */ 
    @AuraEnabled
    public static List<SelectOption> returnCustomSettingsOfOrg(){
    try{
        List<Schema.SObjectType> globaldescribeList = Schema.getGlobalDescribe().Values();     
        List<SelectOption> optionsList = new List<SelectOption>();
        List<String> optionsStringList = new List<String>();
        
        for(Schema.SObjectType gdObj : globaldescribeList){
            Boolean iscustomSetting = gdObj.getDescribe().isCustomSetting();
            if(iscustomSetting){
                optionsStringList.add(gdObj.getDescribe().getlabel()+' ('+gdObj.getDescribe().getname()+')');
            }
        }
        if(optionsStringList.size() > 0){
            optionsStringList.sort();
            for(String optionStr : optionsStringList){
                optionsList.add(new SelectOption(optionStr.substringBetween('(', ')'), optionStr));
            }
            return optionsList;
        }
        return null;
    }catch(Exception ex){
            System.debug(ex.getMessage());
            throw ex;
    }
        
    }
    
    /**
    * @description  Function to query and fetch the records from the selected custom setting
    * @param  selectedCustomSetting : Selected custom setting name
    * @return ReturnData : To return the List of custom setting records and type of custom setting in wrapper form
    */ 
    @AuraEnabled
    public static ReturnData returnCSRecords(String selectedCustomSetting) {
    try{
        String csName = selectedCustomSetting.substringBetween('(', ')');
        Integer lengthOfNameField = Schema.getGlobalDescribe().get(csName).getDescribe().fields.getMap().get('Name').getDescribe().getLength();
        List<sObject> customSettingList = Database.Query('Select Id, Name, SetupOwnerId From '+ csName);
        if(lengthOfNameField == 80){
            List<ObjectForHierarchical> sobjList = new List<ObjectForHierarchical>();
            populateUserProfileMap(customSettingList);
            for(sObject sObj : customSettingList){
                String setupOwnerIdStr = String.valueOf(sobj.get('SetupOwnerId'));
                if(!String.isEmpty(setupOwnerIdStr)){
                    ObjectForHierarchical ObjectForHierarchicalObj;
                    if(setupOwnerIdStr.startsWithIgnoreCase('005')){
                        String nameValue = userMap.get(setupOwnerIdStr).Name;
                        ObjectForHierarchicalObj = new ObjectForHierarchical(String.valueOf(sobj.get('Id')), nameValue + ' (User Name)');
                    }else if(setupOwnerIdStr.startsWithIgnoreCase('00D')){
                        ObjectForHierarchicalObj = new ObjectForHierarchical(String.valueOf(sobj.get('Id')), UserInfo.getOrganizationName() + ' (Orgnization Name)');
                    }else{
                        String nameValue = profileMap.get(setupOwnerIdStr).Name;
                        ObjectForHierarchicalObj = new ObjectForHierarchical(String.valueOf(sobj.get('Id')), nameValue + ' (Profile Name)');
                    }
                    sobjList.add(ObjectForHierarchicalObj);
                }
            }
            ReturnData returnDataObj = new ReturnData('Hierarchical', null, sobjList);
            return returnDataObj;
        }else{
             ReturnData returnDataObj = new ReturnData('List', customSettingList, null);
             return returnDataObj;
        }
    }catch(Exception ex){
        System.debug(ex.getMessage());
        throw ex;
    }
        
    }
    
    /**
    * @description  Function to query and fetch the records from the selected custom setting
    * @param  selectedCSName: Name of custom setting, Id: Id of custom setting record selected in component
    * @return List<sObject> : To Return the List of custom setting records
    */ 
    @AuraEnabled    
    public static String customSettingShowDetailMethod(String selectedCSName, Id selectedCSRecord, Boolean isScriptNeeded, List<String> selectedCS) {
    try{
        if(!String.isEmpty(selectedCSName)){
        	String csNameStr = selectedCSName.substringBetween('(', ')');
            Map<String,Schema.SObjectField> csFieldsMap = returnCSFieldMap(csNameStr); 
            if(!csFieldsMap.isEmpty()){
            	String fieldsAPIName = '';
                for(Schema.SObjectField fieldAPIObj : csFieldsMap.values()){     
                	fieldsAPIName += fieldAPIObj + ',';              
                }    
                if(!String.isEmpty(fieldsAPIName)){
                    List<sobject> csRecordsList = new List<sobject>();
                    if(fieldsAPIName.endsWith(',')){
                        fieldsAPIName = fieldsAPIName.substring(0, fieldsAPIName.length()-1);
                    }
                    String qryString = '';
                    if(!isScriptNeeded){
                        qryString =  'Select '+fieldsAPIName+' from'+' '+csNameStr+' '+'where Id = \''+string.escapeSingleQuotes(selectedCSRecord)+'\'';
                    }else{
                        qryString =  'Select '+fieldsAPIName+' from'+' '+csNameStr+' '+'where Id IN: selectedCS';
                    }
                    csRecordsList = Database.query(qryString); 
                    if(csRecordsList.size() > 0){
                        if(!isScriptNeeded){                    
                            return String.valueOf(csRecordsList);
                        }else{
                            if(!typeOfCs.equalsIgnoreCase('List')){
                                populateUserProfileMap(csRecordsList);
                            }
                            return scriptGenMethod(csFieldsMap, csNameStr, csRecordsList);
                        }
                    }
                }
                return null;
            }
            return null;
       }
       return null;
    }catch(Exception ex){
        system.debug(ex.getMessage());
        throw ex;
    }
        
    }
    
    /**
    * @description To query Name of profiles and User 
    * @param  csRecordsList: sObject List
    * @return void : It return nothing
    */ 
    @TestVisible
    private static void populateUserProfileMap(List<sObject> csRecordsList){
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> profileIdSet = new Set<Id>();
        for(sObject sObj: csRecordsList){
            String fieldValue = String.valueOf(sobj.get('SetupOwnerId'));
            if(!String.isEmpty(fieldValue)){
                if(fieldValue.startsWithIgnoreCase('005')){
                    userIdSet.add(fieldValue);
                }else{
                    profileIdSet.add(fieldValue);
                }
            }
        }
        if(userIdSet.size() > 0){
            userMap = new Map<Id,User>([Select Id, Name from User where Id IN: userIdSet]);
        }
        if(profileIdSet.size() > 0){
            profileMap = new Map<Id,Profile>([Select Id, Name from Profile where Id IN: profileIdSet]);
        }
    }
    
    /**
    * @description Function to return the Map of fields based on custom setting type
    * @param  csName: Name of custom setting
    * @return Map<String,Schema.SObjectField> : To return the map of fields
    */ 
    @Testvisible
    private static Map<String,Schema.SObjectField> returnCSFieldMap(String csName){
        
        Map<String,Schema.SObjectField> requiredFieldMap = new Map<String,Schema.SObjectField>();
        Map<String, Schema.SObjectField> csFieldsMap = Schema.getGlobalDescribe().get(csName).getDescribe().fields.getMap();
        for(Schema.SObjectField fieldStr: csFieldsMap.values()){ 
            String fieldName = String.valueOf(fieldStr);
            Schema.SObjectField fieldObj = csFieldsMap.get(fieldName);
            Schema.DescribeFieldResult fieldDetails = fieldObj.getDescribe();
            if(fieldName != 'Id' && fieldName != 'IsDeleted' && fieldName != 'CreatedDate' && fieldName != 'SystemModstamp' && fieldName !='LastModifiedById' && fieldName !='CreatedById' && fieldName !='LastModifiedDate'){
                if(fieldName.equalsIgnoreCase('Name') && fieldDetails.getLength() == 38){
                    typeOfCs = 'List';
                }
                if(fieldName.equalsIgnoreCase('Name') && fieldDetails.getLength() == 80){
                    typeOfCs = 'Hierarichal';
                }
                requiredFieldMap.put(fieldName, fieldObj);                            
            } 
        }
        if(typeOfCs.equalsIgnoreCase('List')){
            requiredFieldMap.remove('SetupOwnerid');              
        }       
        return requiredFieldMap;
    } 

    /**
    * @description Funtion to generate the custom setting script
    * @param  requiredFieldMap: Name of fields and its details in map, csName: Custom Setting Name, records: List of custom setting records
    * @return String: Generated script in string form
    */ 
    @TestVisible
    private static String scriptGenMethod(Map<String,Schema.SObjectField> requiredFieldMap, String csName, List<sobject> records){  
        String scriptString = '';  
        String listName = ''; 
        if(csName.length() > 15){
            listName = csName.substring(0, 16);
        }
        if(csName.length() > 3){
            listName = csName.substring(0, csName.length()-3);
        }else{
            listName = csName;
        }
        listName =  listName.toLowerCase() + 'List';
        Integer i = 0;
        scriptString = '/************************ ' + csName + ' Script Starts*****************************/<br/><br/>';
        scriptString+= 'List&lt'+csName+'&gt '+listName +' = new List&lt'+csName+'&gt ();<br/><br/>';      
        for(sobject sobj : records){
            i++;
            String objShortName = 'csRecord' + i;
            scriptString+= csName + ' ' + objShortName + ' = new ' + csName + ' ();';       
            for(String fieldName : requiredFieldMap.keyset()){
                if(sobj.get(fieldName) != null){
					if((typeOfCs.equalsIgnoreCase('Hierarichal') &&  fieldName.equalsIgnoreCase('name')) || fieldName.equalsIgnoreCase('CurrencyIsoCode')){
						continue;
					}
					
					Schema.DisplayType displayTypeObj = requiredFieldMap.get(fieldName).getDescribe().getType();
					
					if((displayTypeObj == Schema.DisplayType.boolean) || (displayTypeObj == Schema.DisplayType.Integer) || (displayTypeObj == Schema.DisplayType.Double) || (displayTypeObj == Schema.DisplayType.Percent) || (displayTypeObj == Schema.DisplayType.Currency)){
					   scriptString+='<br/>' + objShortName + '.' + fieldName + ' = ' + sobj.get(fieldName) + ';'; 
					}
					else if((displayTypeObj == Schema.DisplayType.Date)){
						scriptString+= '<br/>'+ objShortName + '.' + fieldName + ' = ' + 'Date.valueOf(\'' + sobj.get(fieldName) + '\')' + ';'; 
					}
					else if((displayTypeObj == Schema.DisplayType.DateTime)){
						scriptString+= '<br/>'+ objShortName + '.' + fieldName + ' = ' + 'DateTime.valueOf(\'' + sobj.get(fieldName) + '\')' + ';'; 
					}
					else if(fieldName.equalsIgnoreCase('SetupOwnerId')){
						if(typeOfCs.equalsIgnoreCase('Hierarichal')){
							String chkOrgId = String.valueof(sobj.get(fieldName));
                            if(!String.isEmpty(chkOrgId)){
                                if(chkOrgId.startsWithIgnoreCase('00D')){
                                    scriptString+='<br/>' + objShortName + '.' + fieldName + ' = UserInfo.getOrganizationId();'; 
                                }else if(chkOrgId.startsWithIgnoreCase('005')){
                                    String nameValue = userMap.get(chkOrgId).Name;
                                    scriptString+='<br/>' + objShortName + '.' + 'Name' + ' = \'' + nameValue +  '\';';  
                                    scriptString+='<br/>' + objShortName + '.' + fieldName + ' = \'' + sobj.get(fieldName) + '\';    //Replace this id with your current org Id';
                                }else {
                                    String nameValue = profileMap.get(chkOrgId).Name;
                                    scriptString+='<br/>' + objShortName + '.' + 'Name' + ' = \'' + nameValue +  '\';'; 
                                    scriptString+='<br/>' + objShortName + '.' + fieldName + ' = \'' + sobj.get(fieldName) +  '\';    //Replace this id with your current org Id';
                                }
                            }else{
                                continue;
                            }
						}else{
							continue;
						}
					}else{
						scriptString+= '<br/>'+ objShortName + '.' + fieldName + ' = \'' + String.valueOf(sobj.get(fieldName)) + '\';'; 
						}
					}
                }
               scriptString+='<br/>'+ listName+'.add('+ objShortName+');<br/><br/>';
          }
          scriptString+= '<br/>'+ 'insert '+ listName+';';
          scriptString+= '<br/><br/>'; 
          scriptString+= '/************************ '+ csName + ' Script Ends*****************************/'; 
       return scriptString;
    }
    
    /**
    * @author Raja Bhandari
    * @date 
    *
    * @group My World
    *
    * @description Wrapper class to contain the type of custom setting and records values
    */
    public class ReturnData{
         @AuraEnabled
         public String typeOfSetting {get;set;}
         @AuraEnabled
         public List<sObject> sObjList  {get;set;}
         @AuraEnabled
         public List<ObjectForHierarchical> ObjectForHierarchicalList  {get;set;}
        
         public ReturnData(String typeOfSetting, List<sObject> sObjList, List<ObjectForHierarchical> ObjectForHierarchicalList){
            this.typeOfSetting = typeOfSetting;
            this.sObjList = sObjList; 
            this.ObjectForHierarchicalList = ObjectForHierarchicalList;
        }
    }  
    
    /**
    * @author Raja Bhandari
    * @date 
    *
    * @group MyWorld
    *
    * @description Wrapper class to contain the Id and Name field from hierarchical custom setting
    */
    public class ObjectForHierarchical{
         @AuraEnabled
         public String Id {get;set;}
         @AuraEnabled
         public String Name {get;set;}
         
         public ObjectForHierarchical(String Id, String name){
             this.Id = Id;
             this.name = name;
         }
     }
}