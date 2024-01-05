({
    onClick : function(component, event, helper) {
        var id = event.target.dataset.menuItemId;
        if (id) {
            component.getSuper().navigate(id);
        }
    },
    showSearch: function(component, event, helper) {
        component.set('v.isSearchBoxVisible', true);
        $A.util.toggleClass(component.find("showsearchbar"), "slds-hide");
        
    },  
    searchKeyCheck : function(component, event, helper){
        if (event.which == 13){
            component.set('v.isSearchBoxVisible', false);
            $A.util.toggleClass(component.find("showsearchbar"), "slds-hide");
        }    
    },
    closeSearch: function(component, event, helper) {
        component.set('v.isSearchBoxVisible', false);
        $A.util.toggleClass(component.find("showsearchbar"), "slds-hide");
    },
})