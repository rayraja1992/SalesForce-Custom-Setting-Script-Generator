({
	init : function(component, event, helper) {
        component.set("v.progressSpinner", true); 
		var action = component.get("c.returnCustomSettingsOfOrg");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseVar = response.getReturnValue();
                if(responseVar != null && responseVar != undefined && responseVar != ''){
                	component.set("v.options", response.getReturnValue());
                }else{
                    alert("There is some error, Please check debug log");
                }
            }
            else{
                alert("There is some error, Please check debug log");
            }
            component.set("v.progressSpinner", false); 
        });
        $A.enqueueAction(action);
	},
	
	exportButton : function(component, event, helper) {
	   var values = component.find("Csetting").get("v.value");
	   if(values != "--None--"){
            component.set("v.progressSpinner", true); 
		    component.set("v.customSettingName",values);
		    var action = component.get("c.returnCSRecords");
		    action.setParams({ "selectedCustomSetting" : values });
		    action.setCallback(this, function(response) {
			   var state = response.getState();
			   if (state === "SUCCESS"){   
					var responseVar = response.getReturnValue();
					if(responseVar != null && responseVar != undefined && responseVar != ''){
						if(responseVar.typeOfSetting == 'List'){
							var records = responseVar.sObjList;
							
							var cols = [{label: "Id", fieldName: "Id", type: "text"},
										{label: "Name", fieldName: "Name", type: "text"},
										{label: "View", type: "button", initialWidth: 135, typeAttributes: { label: "View Details", name: "view_details", title: "Click to View Details"}}]
						
							component.set("v.data", records); 
							
						}else{
							var records = responseVar.ObjectForHierarchicalList;
							
							var cols = [{label: "Id", fieldName: "Id", type: "text"},
										{label: "Name", fieldName: "Name", type: "text"},
										{label: "View", type: "button", initialWidth: 135, typeAttributes: { label: "View Details", name: "view_details", title: "Click to View Details"}}]
							
							component.set("v.data", records); 
						}
						
						component.set("v.columns", cols);					
						component.set("v.selectedValue", true);
						component.set("v.selectedStep", "step1");
					}else{
						alert("There is some error, Please check debug log");
					}
				}
				else {
						alert("There is some error, Please check debug log");
				}
                component.set("v.progressSpinner", false); 
			});
		$A.enqueueAction(action);
	   }
	},
    
	handleRowAction: function (component, event, helper) {
        var action = event.getParam("action");
        var row = event.getParam("row");
        if(action.name === "view_details"){
            component.set("v.progressSpinner", true); 
            var csName = component.get("v.customSettingName");
            var action = component.get("c.customSettingShowDetailMethod");
                action.setParams({ "selectedCSName" : csName, "selectedCSRecord" :  row.Id, "isScriptNeeded":false, "selectedCS":null});
                action.setCallback(this, function(response) {
                   var state = response.getState();
                   if (state === "SUCCESS") {
					   	var responseVar = response.getReturnValue();
						if(responseVar != null && responseVar != undefined && responseVar != ''){
							alert(response.getReturnValue());
						}else{
							alert("There is some error, Please check debug log");
						}
                   }
                   else{
                       alert("There is some error, Please check debug log");
                   }
                   component.set("v.progressSpinner", false); 
                })
             $A.enqueueAction(action);
        }
    },
	
	generateScriptMethod: function(component, event, helper) {
        component.set("v.progressSpinner", true); 
        var selectedtRowListId = new Array();
        var values = component.find("Csetting").get("v.value");
        var selectedrows = component.find("datatableid").getSelectedRows();
        for(var i=0;i<selectedrows.length;i++){
       		selectedtRowListId.push(selectedrows[i].Id);
        }
		var action = component.get("c.customSettingShowDetailMethod");
        action.setParams({"selectedCSName" : values, "selectedCSRecord" : null, "isScriptNeeded": true,"selectedCS" :  selectedtRowListId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var responseVar = response.getReturnValue();
				if(responseVar != null && responseVar != undefined && responseVar != ''){
					component.set("v.generateButtonPressed", true); 
					component.set("v.generatedScript", response.getReturnValue());
					component.set("v.selectedStep", "step3");
					component.set("v.openModal", true);
				}else{
					alert("There is some error, Please check debug log");
				}
            }
            else{
				alert("There is some error, Please check debug log");
            }
            component.set("v.progressSpinner", false); 
        });
        $A.enqueueAction(action);
	},
	
    populateCsettngValues : function(component, event, helper) {
	   var source = event.getSource();
	   var values = component.find("Csetting").get("v.value");
	   if(values === "--None--"){
			component.set("v.reset", false);
	   }else{
			component.set("v.reset", true);
	   }
	},
    
    resetButton : function(component, event, helper) {
	    var values = component.find("Csetting").get("v.value");
	    if(values != "--None--"){	   
		   component.find("Csetting").set("v.value","--None--");
		   component.set("v.reset", false);
		   component.set("v.selectedValue", false);
		   component.set("v.generateButtonVisibility", false); 
		   component.set("v.generateButtonPressed", false);
		   component.set("v.selectedStep", "step0");
		   component.set("v.selectedRowsCount", 0);
	    }
	},
    
    
    
    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam("selectedRows");
        component.set("v.selectedRowsCount", selectedRows.length);         
        if(selectedRows != 0){
            component.set("v.generateButtonVisibility", true);
            component.set("v.selectedStep", "step2");
        }
        if(selectedRows == 0){
            component.set("v.generateButtonVisibility", false);
            component.set("v.selectedStep", "step1");
        }
    },
    
    
    
    handleCloseModal: function(component, event, helper) { 
       component.set("v.openModal", false);
       component.find("Csetting").set("v.value","--None--");
       component.set("v.reset", false);
       component.set("v.selectedValue", false);
       component.set("v.generateButtonVisibility", false); 
       component.set("v.generateButtonPressed", false);
       component.set("v.selectedStep", "step0");
       component.set("v.selectedRowsCount", 0);
    }
    
})