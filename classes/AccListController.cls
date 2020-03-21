public class AccListController{

    public AccListController() {

    }


    public AccListController(ApexPages.StandardSetController controller) {

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