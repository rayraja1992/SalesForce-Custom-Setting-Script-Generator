/**
 * @File Name          : AccListController.cls
 * @Description        : 
 * @Author             : Raja Bhandari
 * @Group              : 
 * @Last Modified By   : Raja Bhandari
 * @Last Modified On   : 21/3/2020, 8:46:38 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/3/2020   Raja Bhandari     Initial Version
**/
public class AccListController{

    public AccListController() {

    }


    public AccListController(ApexPages.StandardSetController controller) {
        integer i = 1;
    }
    public ApexPages.StandardSetController hh {
    get {
    if(hh == null) {
    hh = new ApexPages.StandardSetController(Database.getQueryLocator(
    [SELECT Name FROM Account limit 3]));
    }
    return hh;
    }
    set;
    }

    // Initialize setCon and return a list of records
    public List<Account> getAccountList() {
    return (List<Account>) hh.getRecords();
    }
}