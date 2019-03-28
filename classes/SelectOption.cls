/**
* @author Raja Bhandari
* @date 24/03/2019
*
* @group My World
*
* @description Select Option Picklist class
*/
public class SelectOption {
    
    @AuraEnabled
    public String label { get;set; }
    @AuraEnabled
    public String value { get;set; }
    @AuraEnabled
    public Boolean disabled { get;set; }
    @AuraEnabled
    public Boolean escapeItem { get;set; }

    /**
    * @description  Contructor to populate the Select Option Value
    * @param  value: value of picklist option, label: label of picklist option
    * @return 
    */ 
    public SelectOption(String value, String label) {
        this.value = value;
        this.label = label;
        this.disabled = false;
        this.escapeItem = false;
    }

}