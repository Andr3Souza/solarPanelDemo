trigger InstallationTrigger on Installation__c (before insert, before update) {

    InstallationTriggerHandler handler = new InstallationTriggerHandler();
    if (Trigger.isBefore && Trigger.isInsert) {
        handler.beforeInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}