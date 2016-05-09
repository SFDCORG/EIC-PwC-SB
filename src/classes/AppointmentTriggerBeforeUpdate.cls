/**************************************************************************************************
 * Name: AppointmentTriggerBeforeUpdate
 * Object: Appointment__c
 * Purpose: The before update trigger
            1. Update the customer visited Center times
 * Author:  ()
 * Create Date: 2016-04-18
 * Modify History:
 * 2016-04-18    Ray Cen    Writes comments and optimizes the code
 * 2016-05-06    Allen    Format the code
 **************************************************************************************************/
public class AppointmentTriggerBeforeUpdate implements TriggerHandler.HandlerInterface {

    public void handle() {

        AppointmentTriggerHelper.beforeUpdateOrInsert(Trigger.new);
        AppointmentTriggerHelper.appointmentVistiedTimesCheck(Trigger.new);
    }
}